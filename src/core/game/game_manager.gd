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

    # Connect to dialog manager signals if it exists
    var dialog_manager = null
    for node in get_tree().get_nodes_in_group("dialog_manager"):
        dialog_manager = node
        break

    if dialog_manager:
        dialog_manager.connect("dialog_ended", self, "_on_dialog_ended")

# Find input manager
func _find_input_manager():
    var root = get_tree().get_root()
    for child in root.get_children():
        for grandchild in child.get_children():
            if grandchild.get_class() == "Node" and grandchild.get_script() and grandchild.get_script().get_path().ends_with("input_manager.gd"):
                return grandchild
    return null

# Handle dialog ended event
func _on_dialog_ended(npc):
    # Re-enable input handling after dialog ends
    var input_manager = _find_input_manager()
    if input_manager:
        # Use a timer to delay re-enabling input to prevent accidental clicks
        yield(get_tree().create_timer(0.75), "timeout")
        input_manager.set_process_input(true)
        input_manager.set_process(true)

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

# Handle NPC click specifically for dialog
func handle_npc_click(npc):
    current_object = npc

    # IMPORTANT: Disable input handling for the dialog sequence
    var input_manager = _find_input_manager()
    if input_manager:
        input_manager.set_process_input(false)
        input_manager.set_process(false)

    # Move player to the NPC first
    if player and player.has_method("move_to"):
        var direction = (player.global_position - npc.global_position).normalized()
        var target_pos = npc.global_position + direction * 50
        player.move_to(target_pos)
        
        # Wait until player arrives before starting dialog
        yield(get_tree().create_timer(0.5), "timeout")
    
    # Handle interaction based on current verb
    if current_verb == "Talk to" and npc.has_method("start_dialog"):
        if interaction_text:
            interaction_text.text = "Talking to " + npc.npc_name
        npc._change_state(npc.State.TALKING)
    else:
        # For other verbs, just use the standard interact method
        if npc.has_method("interact"):
            var response = npc.interact(current_verb)
            if interaction_text:
                interaction_text.text = response

# Handle object clicks (used for non-NPC objects)
func handle_object_click(object, position):
    current_object = object
    
    # Check if this is an NPC
    if object.is_in_group("npc"):
        handle_npc_click(object)
        return
    
    # For regular objects, show interaction result
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