extends Node2D
class_name IntegrationNPC

# NPC properties
export var npc_name = "Unknown NPC"
export var description = "An unknown person"
export var is_assimilated = false

# Visual representation
var visual_rect
var label

# Suspicion system
var suspicion_level = 0.0  # 0.0 to 1.0
var suspicion_threshold = 0.8  # Level at which NPC becomes suspicious of player

# Dialog properties
var dialog_tree = {}
var current_dialog_node = "root"

# Cache references
var game_manager = null
var dialog_manager = null

func _ready():
    # Add to NPC group
    add_to_group("npc")
    add_to_group("interactive_object")
    
    # Create visual representation
    _create_visual()
    
    # Initialize dialog tree
    initialize_dialog()
    
    # Set process input
    set_process_input(true)
    
    # Find game manager
    game_manager = _find_game_manager()

# Create visual representation
func _create_visual():
    # Create visual rectangle if not already a child
    if not has_node("Visual"):
        visual_rect = ColorRect.new()
        visual_rect.name = "Visual"
        visual_rect.rect_size = Vector2(32, 48)
        visual_rect.rect_position = Vector2(-16, -48)
        visual_rect.color = Color(0.7, 0.7, 0.7)  # Default color
        add_child(visual_rect)
    else:
        visual_rect = get_node("Visual")
    
    # Create label if not already a child
    if not has_node("Label"):
        label = Label.new()
        label.name = "Label"
        label.text = npc_name
        label.rect_position = Vector2(-40, -60)
        add_child(label)
    else:
        label = get_node("Label")
        label.text = npc_name

# Handle input events
func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        # Check if clicked on this NPC
        var click_pos = event.position
        var rect_global_pos = visual_rect.rect_position + global_position
        
        if Rect2(rect_global_pos, visual_rect.rect_size).has_point(click_pos) and game_manager:
            print("Clicked on NPC: " + npc_name)
            game_manager._on_object_clicked(self, global_position)

# Find the game manager in the scene tree
func _find_game_manager():
    var root = get_tree().get_root()
    
    # Try to find game manager as a direct child of root
    for child in root.get_children():
        if child.has_method("_on_object_clicked"):
            return child
            
    # Try to find game manager as a child of other nodes
    for child in root.get_children():
        for grandchild in child.get_children():
            if grandchild.has_method("_on_object_clicked"):
                return grandchild
    
    # If not found, return null
    print("Game manager not found for " + npc_name)
    return null

# Initialize the dialog tree - should be overridden by child classes
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Hello there.",
            "options": [
                {"text": "Hello.", "next": "greeting"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "greeting": {
            "text": "How can I help you?",
            "options": [
                {"text": "Just looking around.", "next": "looking"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "looking": {
            "text": "Feel free to look around.",
            "options": [
                {"text": "Thanks.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Goodbye.",
            "options": []
        }
    }

# Handle interaction with this NPC
func interact(verb, item = null):
    match verb:
        "Look at":
            return "You see " + npc_name + ". " + description
        "Talk to":
            start_dialog()
            return "You begin talking to " + npc_name
        "Use", "Pick up", "Push", "Pull", "Give":
            change_suspicion(0.1)
            return npc_name + " doesn't appreciate that."
        _:
            return "You can't " + verb + " " + npc_name

# Start a dialog with this NPC
func start_dialog():
    current_dialog_node = "root"
    
    # Find dialog manager if not already found
    if not dialog_manager:
        var root = get_tree().get_root()
        for child in root.get_children():
            if child.has_method("show_dialog"):
                dialog_manager = child
                break
    
    # Show dialog if manager found
    if dialog_manager:
        dialog_manager.show_dialog(self)
    else:
        print("Dialog manager not found!")

# End dialog with this NPC
func end_dialog():
    if dialog_manager:
        dialog_manager.hide_dialog()

# Get current dialog node
func get_current_dialog():
    if current_dialog_node in dialog_tree:
        return dialog_tree[current_dialog_node]
    return null

# Choose a dialog option
func choose_dialog_option(option_index):
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # Check if this option affects suspicion
        if "suspicion_change" in option:
            change_suspicion(option.suspicion_change)
        
        # Move to next dialog node
        current_dialog_node = option.next
        
        # Check if dialog has ended
        if current_dialog_node == "exit" or get_current_dialog().options.size() == 0:
            end_dialog()
            return null
            
        return get_current_dialog()
    return null

# Change suspicion level
func change_suspicion(amount):
    var old_level = suspicion_level
    suspicion_level = clamp(suspicion_level + amount, 0.0, 1.0)
    
    # Check if NPC is now suspicious
    if suspicion_level >= suspicion_threshold and old_level < suspicion_threshold:
        become_suspicious()

# Called when NPC becomes suspicious
func become_suspicious():
    print(npc_name + " has become suspicious!")
    # This should be overridden by child classes

# Get assimilation status - used by player to detect if NPC is assimilated
func is_assimilated():
    return is_assimilated
