extends Node2D
class_name BaseNPCDebug

# NPC properties
export var npc_name = "Unknown NPC"
export var description = "An unknown person"
export var is_assimilated = false

# Visual representation
var visual_rect
var collision_shape

# Suspicion system
var suspicion_level = 0.0  # 0.0 to 1.0
var suspicion_threshold = 0.8  # Level at which NPC becomes suspicious of player

# Dialog properties
var dialog_tree = {}
var current_dialog_node = "root"

func _ready():
    print("NPC " + npc_name + " initializing...")
    
    # Add to NPC group
    add_to_group("npc")
    add_to_group("interactive_object")
    
    # Create visual representation if not present
    _ensure_visual_exists()
    
    # Initialize dialog tree
    initialize_dialog()
    
    # Listen for input directly
    set_process_input(true)
    
    print("NPC " + npc_name + " ready")

# Listen for direct input
func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        # Check if click was on this NPC
        if visual_rect and visual_rect is Control:
            var rect_global_pos = visual_rect.rect_position + global_position
            var rect_size = visual_rect.rect_size
            var click_rect = Rect2(rect_global_pos, rect_size)
            
            if click_rect.has_point(event.position):
                print("NPC " + npc_name + " clicked directly!")
                # Find game manager
                var game_manager = find_game_manager()
                if game_manager:
                    print("Calling game manager's handle_npc_click")
                    game_manager.handle_npc_click(self)
                else:
                    print("Game manager not found!")

# Ensure NPC has visual representation
func _ensure_visual_exists():
    # Check if we already have a sprite
    if has_node("Visual"):
        visual_rect = get_node("Visual")
        print("Found existing visual for " + npc_name)
    else:
        # Create a default visual
        var rect = ColorRect.new()
        rect.name = "Visual"
        rect.rect_size = Vector2(40, 60)
        rect.rect_position = Vector2(-20, -60)
        rect.color = Color(0.7, 0.7, 0.7)  # Default gray
        add_child(rect)
        visual_rect = rect
        print("Created new visual for " + npc_name)
    
    # Add label if needed
    if not has_node("Label"):
        var label = Label.new()
        label.name = "Label"
        label.text = npc_name
        label.rect_position = Vector2(-40, -80)
        add_child(label)
        print("Added label for " + npc_name)
    
    # Add collision if needed
    if not has_node("NpcArea"):
        var area = Area2D.new()
        area.name = "NpcArea"
        add_child(area)
        
        var shape = CollisionShape2D.new()
        shape.name = "CollisionShape"
        var rect_shape = RectangleShape2D.new()
        rect_shape.extents = Vector2(20, 30)  # Half of visual size
        shape.shape = rect_shape
        shape.position = Vector2(0, -30)  # Center on visual
        area.add_child(shape)
        collision_shape = shape
        
        # Connect area signals
        print("Connecting input_event signal for " + npc_name)
        area.connect("input_event", self, "_on_NpcArea_input_event")
        print("Area2D and collision shape created for " + npc_name)

# Handle input events
func _on_NpcArea_input_event(viewport, event, shape_idx):
    print("NpcArea input event detected for " + npc_name)
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        print("Area2D click on " + npc_name + " detected!")
        # Find game manager
        var game_manager = find_game_manager()
        if game_manager:
            print("Found game manager, calling handle_npc_click")
            game_manager.handle_npc_click(self)
        else:
            print("Game manager not found!")

# Find game manager in scene
func find_game_manager():
    var root = get_tree().get_root()
    for child in root.get_children():
        if child.has_method("handle_npc_click"):
            print("Game manager found: " + child.name)
            return child
        
        # Try checking direct children of scene
        for grandchild in child.get_children():
            if grandchild.has_method("handle_npc_click"):
                print("Game manager found in child: " + grandchild.name)
                return grandchild
    
    print("No game manager found in scene tree!")
    return null

# Initialize dialog tree - should be overridden
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
    print("Dialog tree initialized for " + npc_name)

# Handle interaction with this NPC
func interact(verb, item = null):
    print("NPC " + npc_name + " interacting with verb: " + verb)
    match verb:
        "Look at":
            return "You see " + npc_name + ". " + description
        "Talk to":
            print("Starting dialog with " + npc_name)
            start_dialog()
            return "You begin talking to " + npc_name
        "Use", "Pick up", "Push", "Pull", "Give":
            change_suspicion(0.1)
            return npc_name + " doesn't appreciate that."
        _:
            return "You can't " + verb + " " + npc_name

# Start a dialog with this NPC
func start_dialog():
    print("NPC " + npc_name + " start_dialog called")
    current_dialog_node = "root"
    var dialog_manager = get_dialog_manager()
    if dialog_manager:
        print("Dialog manager found, showing dialog")
        dialog_manager.show_dialog(self)
    else:
        print("Dialog manager not found!")

# Get dialog manager from scene
func get_dialog_manager():
    var root = get_tree().get_root()
    # First look for the GameManager node
    var game_manager = null
    for child in root.get_children():
        if child.has_method("handle_npc_click"):
            game_manager = child
            break
    
    # If found, look for DialogManager as child of GameManager
    if game_manager:
        for child in game_manager.get_children():
            if child.has_method("show_dialog"):
                print("Dialog manager found as child of game manager")
                return child
    
    # Otherwise look in the scene tree
    for child in root.get_children():
        if child.has_method("show_dialog"):
            print("Dialog manager found as direct child")
            return child
        # Try checking children too
        for grandchild in child.get_children():
            if grandchild.has_method("show_dialog"):
                print("Dialog manager found as grandchild")
                return grandchild
    
    print("No dialog manager found in scene tree!")
    return null

# Get current dialog node
func get_current_dialog():
    if current_dialog_node in dialog_tree:
        return dialog_tree[current_dialog_node]
    return null

# Choose a dialog option
func choose_dialog_option(option_index):
    print("NPC " + npc_name + " choose_dialog_option: " + str(option_index))
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # Check if this option affects suspicion
        if "suspicion_change" in option:
            change_suspicion(option.suspicion_change)
        
        # Move to next dialog node
        current_dialog_node = option.next
        print("Moving to dialog node: " + current_dialog_node)
        
        # Check if dialog has ended
        if current_dialog_node == "exit" or get_current_dialog().options.size() == 0:
            var dialog_manager = get_dialog_manager()
            if dialog_manager:
                dialog_manager.end_dialog()
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
    
    print(npc_name + " suspicion changed: " + str(old_level) + " -> " + str(suspicion_level))

# Called when NPC becomes suspicious
func become_suspicious():
    print(npc_name + " has become suspicious!")
    # Override in child classes
