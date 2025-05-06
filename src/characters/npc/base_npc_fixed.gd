extends Node2D
class_name BaseNPCFixed

# NPC properties
export var npc_name = "Unknown NPC"
export var description = "An unknown person"
export var is_assimilated = false

# Suspicion system
var suspicion_level = 0.0  # 0.0 to 1.0
var suspicion_threshold = 0.8  # Level at which NPC becomes suspicious of player

# Dialog properties
var dialog_tree = {}
var current_dialog_node = "root"

# Signals
signal suspicion_changed(old_level, new_level)
signal dialog_started(npc)
signal dialog_ended(npc)

func _ready():
    # Add to NPC group
    add_to_group("npc")
    add_to_group("interactive_object")
    
    # Initialize dialog tree
    initialize_dialog()
    
    # Add clickable area to NPC
    _add_clickable_area()

# Add a clickable area to the NPC
func _add_clickable_area():
    var area = Area2D.new()
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    
    # Set shape size based on visual representation
    shape.extents = Vector2(20, 30)
    collision.shape = shape
    collision.position = Vector2(0, -30)  # Position above base point
    
    area.add_child(collision)
    area.connect("input_event", self, "_on_input_event")
    add_child(area)

# Handle input events on the NPC
func _on_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        # Find the game manager
        var game_manager = _find_game_manager()
        if game_manager:
            # Let the game manager know this NPC was clicked
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
    emit_signal("dialog_started", self)

# End dialog with this NPC
func end_dialog():
    emit_signal("dialog_ended", self)

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
    
    emit_signal("suspicion_changed", old_level, suspicion_level)

# Called when NPC becomes suspicious
func become_suspicious():
    print(npc_name + " has become suspicious!")
    # This should be overridden by child classes

# Get assimilation status - used by player to detect if NPC is assimilated
func is_assimilated():
    return is_assimilated
