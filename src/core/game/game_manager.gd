extends Node

# References to UI and game systems
var verb_ui
var interaction_text
var dialog_manager
var input_manager
var player

# Current state
var current_verb = "Look at"
var current_object = null

func _ready():
    print("Game Manager initializing...")
    
    # Find the input manager (may already exist in the scene)
    input_manager = _find_node_of_type("InputManager")
    if not input_manager:
        print("Creating input manager...")
        input_manager = load("res://src/core/input/input_manager.gd").new()
        input_manager.name = "InputManager"
        get_parent().add_child(input_manager)
    
    # Create dialog manager if it doesn't exist
    dialog_manager = _find_node_of_type("DialogManager")
    if not dialog_manager:
        print("Creating dialog manager...")
        dialog_manager = load("res://src/core/dialog/dialog_manager.gd").new()
        dialog_manager.name = "DialogManager"
        add_child(dialog_manager)
    
    # Wait a frame to make sure all nodes are loaded
    yield(get_tree(), "idle_frame")
    
    # Connect signals from input manager
    input_manager.connect("object_clicked", self, "handle_object_click")
    
    # Find UI elements
    _find_ui_elements()
    
    # Find player
    _find_player()
    
    print("Game Manager initialized")

# Helper function to find nodes by class type
func _find_node_of_type(node_name):
    var root = get_tree().get_root()
    # Check direct children of root
    for child in root.get_children():
        if child.name == node_name:
            return child
        # Check children of current scene
        for grandchild in child.get_children():
            if grandchild.name == node_name:
                return grandchild
    return null

# Find UI elements
func _find_ui_elements():
    var root = get_tree().get_root()
    for node in root.get_children():
        if node.has_node("UI/VerbUI"):
            verb_ui = node.get_node("UI/VerbUI")
            verb_ui.connect("verb_selected", self, "_on_verb_selected")
            print("Connected to VerbUI")
        
        if node.has_node("UI/InteractionText"):
            interaction_text = node.get_node("UI/InteractionText")
            print("Found InteractionText")

# Find player
func _find_player():
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
        print("Found player: " + str(player.name))
    else:
        print("Player not found")

# Handle verb selection
func _on_verb_selected(verb):
    current_verb = verb
    if interaction_text:
        interaction_text.text = current_verb + "..."
    print("Verb selected: " + verb)

# Handle object clicks
func handle_object_click(object, position):
    current_object = object
    
    # Show interaction result
    if object.has_method("interact"):
        var response = object.interact(current_verb)
        if interaction_text:
            interaction_text.text = response
    else:
        if interaction_text:
            interaction_text.text = "You can't " + current_verb + " that."
    
    # Move player to object if needed
    if player and current_verb != "Look at":
        # Calculate a position near the object
        var direction = (player.global_position - object.global_position).normalized()
        var target_pos = object.global_position + direction * 50
        
        # Move the player if they have the move_to method
        if player.has_method("move_to"):
            player.move_to(target_pos)
