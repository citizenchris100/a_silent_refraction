extends Node

# Signals for relaying state changes (for testing)
signal player_state_relayed(state)
signal camera_state_relayed(state)

# References to UI and game systems
var verb_ui
var interaction_text
var dialog_manager
var input_manager
var player
var camera

# Current state
var current_verb = "Look at"
var current_object = null

# Connection tracking
var active_connections = {}

# Debug mode - set to false to disable debug prints
var debug_mode = false

# Debug print helper
func _debug_print(message: String):
    if debug_mode:
        print(message)

func _ready():
    if debug_mode:
        print("Game Manager initializing...")
    
    # Add to game_manager group for easy finding
    add_to_group("game_manager")
    
    # Find the input manager (may already exist in the scene)
    # First check if there's one in the input_manager group
    var input_managers = get_tree().get_nodes_in_group("input_manager")
    if input_managers.size() > 0:
        input_manager = input_managers[0]
        print("Found existing InputManager in group")
    else:
        # Try to find by name
        input_manager = _find_node_of_type("InputManager")
        
    if not input_manager:
        print("Creating input manager...")
        input_manager = load("res://src/core/input/input_manager.gd").new()
        input_manager.name = "InputManager"
        add_child(input_manager)  # Add as child of GameManager, not parent
    
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
    if input_manager and is_instance_valid(input_manager) and input_manager.has_signal("object_clicked"):
        if not input_manager.is_connected("object_clicked", self, "handle_object_click"):
            input_manager.connect("object_clicked", self, "handle_object_click")
            _track_connection(input_manager, "object_clicked", self, "handle_object_click")
            print("Connected to InputManager object_clicked signal")
    
    # Find UI elements
    _find_ui_elements()
    
    # Find player
    _find_player()
    
    # Find and connect to player and camera signals
    _find_and_connect_player()
    _find_and_connect_camera()
    
    # Monitor scene tree changes for dynamic components
    get_tree().connect("node_added", self, "_on_node_added")
    get_tree().connect("node_removed", self, "_on_node_removed")
    
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
    if dialog_manager and dialog_manager.has_signal("dialog_ended"):
        if not dialog_manager.is_connected("dialog_ended", self, "_on_dialog_ended"):
            dialog_manager.connect("dialog_ended", self, "_on_dialog_ended")
            _track_connection(dialog_manager, "dialog_ended", self, "_on_dialog_ended")


# Handle dialog ended event
func _on_dialog_ended(npc):
    # Re-enable input handling after dialog ends
    if input_manager and is_instance_valid(input_manager):
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
    if input_manager and is_instance_valid(input_manager):
        input_manager.set_process_input(false)
        input_manager.set_process(false)

    # Move player to the NPC first
    if player and player.has_method("move_to") and player.is_inside_tree() and npc.is_inside_tree():
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

# Handle object clicks (used for non-NPC objects and movement)
func handle_object_click(object, position):
    current_object = object
    
    # Handle null object case (movement click)
    if not object:
        # This is a movement click - move the player to the position
        if player and player.has_method("move_to"):
            player.move_to(position)
        return
    
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
    if player and current_verb != "Look at" and player.is_inside_tree() and object.is_inside_tree():
        # Calculate a position near the object
        var direction = (player.global_position - object.global_position).normalized()
        var target_pos = object.global_position + direction * 50
        
        # Move the player if they have the move_to method
        if player.has_method("move_to"):
            player.move_to(target_pos)

# ===== SIGNAL CONNECTION METHODS =====

# Find and connect to player signals
func _find_and_connect_player():
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        var player_node = players[0]
        player = player_node  # Update the stored reference
        connect_to_player(player_node)
    else:
        print("No player found in 'player' group for signal connection")

# Find and connect to camera signals  
func _find_and_connect_camera():
    var cameras = get_tree().get_nodes_in_group("camera")
    if cameras.size() > 0:
        camera = cameras[0]
        _connect_camera_signals(camera)
    else:
        print("No camera found in 'camera' group for signal connection")

# Connect to player with duplicate protection
func connect_to_player(player_node):
    if not player_node:
        return
        
    # Check if the signal exists first
    if not player_node.has_signal("movement_state_changed"):
        print("Player does not have movement_state_changed signal")
        return
        
    # Check if already connected to prevent duplicates
    if not player_node.is_connected("movement_state_changed", self, "_on_player_movement_state_changed"):
        player_node.connect("movement_state_changed", self, "_on_player_movement_state_changed")
        _track_connection(player_node, "movement_state_changed", self, "_on_player_movement_state_changed")
        print("Connected to player movement_state_changed signal")

# Connect to camera signals with duplicate protection
func _connect_camera_signals(camera_node):
    if not camera_node:
        return
        
    # Connect camera_move_started
    if camera_node.has_signal("camera_move_started"):
        if not camera_node.is_connected("camera_move_started", self, "_on_camera_move_started"):
            camera_node.connect("camera_move_started", self, "_on_camera_move_started")
            _track_connection(camera_node, "camera_move_started", self, "_on_camera_move_started")
    
    # Connect camera_move_completed
    if camera_node.has_signal("camera_move_completed"):
        if not camera_node.is_connected("camera_move_completed", self, "_on_camera_move_completed"):
            camera_node.connect("camera_move_completed", self, "_on_camera_move_completed")
            _track_connection(camera_node, "camera_move_completed", self, "_on_camera_move_completed")
    
    # Connect camera_state_changed
    if camera_node.has_signal("camera_state_changed"):
        if not camera_node.is_connected("camera_state_changed", self, "_on_camera_state_changed"):
            camera_node.connect("camera_state_changed", self, "_on_camera_state_changed")
            _track_connection(camera_node, "camera_state_changed", self, "_on_camera_state_changed")
    
    print("Connected to camera signals")

# ===== SIGNAL HANDLER METHODS =====

# Handle player movement state changes
func _on_player_movement_state_changed(new_state):
    emit_signal("player_state_relayed", new_state)
    print("Player movement state changed to: " + str(new_state))

# Handle camera move started
func _on_camera_move_started(target_position, old_position, move_duration, transition_type):
    print("Camera move started to: " + str(target_position))

# Handle camera move completed
func _on_camera_move_completed(final_position, initial_position, actual_duration):
    print("Camera move completed at: " + str(final_position))

# Handle camera state changes
func _on_camera_state_changed(new_state, old_state, transition_reason):
    emit_signal("camera_state_relayed", new_state)
    print("Camera state changed from " + str(old_state) + " to " + str(new_state) + " because: " + transition_reason)

# ===== CONNECTION TRACKING METHODS =====

# Track a signal connection
func _track_connection(signal_owner, signal_name, target, method):
    var key = str(signal_owner.get_instance_id()) + "_" + signal_name
    active_connections[key] = {
        "owner": signal_owner,
        "signal": signal_name,
        "target": target,
        "method": method
    }

# Get all active connections
func get_active_connections():
    return active_connections

# Get count of active connections
func get_connection_count():
    verify_connections()  # Clean up invalid connections first
    return active_connections.size()

# Verify all connections are still valid
func verify_connections():
    var invalid_connections = []
    
    for key in active_connections.keys():
        var conn = active_connections[key]
        
        if not is_instance_valid(conn.owner) or not is_instance_valid(conn.target):
            invalid_connections.append(key)
        elif not conn.owner.is_connected(conn.signal, conn.target, conn.method):
            invalid_connections.append(key)
    
    # Remove invalid connections
    for key in invalid_connections:
        active_connections.erase(key)
    
    if invalid_connections.size() > 0:
        print("Removed %d invalid connections" % invalid_connections.size())

# ===== CLEANUP METHODS =====

# Cleanup all connections when scene changes or node exits
func cleanup_connections():
    for key in active_connections:
        var conn = active_connections[key]
        if is_instance_valid(conn.owner) and is_instance_valid(conn.target):
            if conn.owner.is_connected(conn.signal, conn.target, conn.method):
                conn.owner.disconnect(conn.signal, conn.target, conn.method)
    active_connections.clear()
    print("Cleaned up all signal connections")

# Disconnect player signals
func disconnect_player_signals():
    if player and is_instance_valid(player):
        if player.has_signal("movement_state_changed") and player.is_connected("movement_state_changed", self, "_on_player_movement_state_changed"):
            player.disconnect("movement_state_changed", self, "_on_player_movement_state_changed")
            # Remove from tracking
            var key = str(player.get_instance_id()) + "_movement_state_changed"
            active_connections.erase(key)
    player = null  # Clear the reference

# Disconnect camera signals
func disconnect_camera_signals():
    if camera and is_instance_valid(camera):
        var signals_to_disconnect = [
            ["camera_move_started", "_on_camera_move_started"],
            ["camera_move_completed", "_on_camera_move_completed"],
            ["camera_state_changed", "_on_camera_state_changed"]
        ]
        
        for signal_info in signals_to_disconnect:
            if camera.has_signal(signal_info[0]) and camera.is_connected(signal_info[0], self, signal_info[1]):
                camera.disconnect(signal_info[0], self, signal_info[1])
                # Remove from tracking
                var key = str(camera.get_instance_id()) + "_" + signal_info[0]
                active_connections.erase(key)


# ===== NPC LIFECYCLE METHODS =====

# Handle NPC added to scene
func _on_npc_added(npc):
    if not npc or not is_instance_valid(npc):
        return
    
    _connect_npc_signals(npc)

# Handle NPC removed from scene
func _on_npc_removed(npc):
    if not npc or not is_instance_valid(npc):
        return
    
    _disconnect_npc_signals(npc)

# Connect NPC signals
func _connect_npc_signals(npc):
    if not npc or not is_instance_valid(npc):
        return
    
    # Connect to NPC interaction signals if they exist
    if npc.has_signal("interacted"):
        if not npc.is_connected("interacted", self, "_on_npc_interacted"):
            npc.connect("interacted", self, "_on_npc_interacted", [npc])
            _track_connection(npc, "interacted", self, "_on_npc_interacted")
    
    print("Connected to NPC: " + str(npc.name))

# Disconnect NPC signals
func _disconnect_npc_signals(npc):
    if not npc or not is_instance_valid(npc):
        return
    
    # Disconnect NPC interaction signals
    if npc.has_signal("interacted") and npc.is_connected("interacted", self, "_on_npc_interacted"):
        npc.disconnect("interacted", self, "_on_npc_interacted")
        var key = str(npc.get_instance_id()) + "_interacted"
        active_connections.erase(key)
    
    print("Disconnected from NPC: " + str(npc.name))

# Handle NPC interaction
func _on_npc_interacted(npc):
    print("NPC interacted: " + str(npc.name))

# ===== SCENE TREE MONITORING =====

# Handle node added to scene tree
func _on_node_added(node):
    # Check if it's a player
    if node.is_in_group("player"):
        # Reconnect to the new player
        _find_and_connect_player()
    # Check if it's a camera
    elif node.is_in_group("camera"):
        _find_and_connect_camera()
    # Check if it's an NPC
    elif node.is_in_group("npc"):
        _on_npc_added(node)

# Handle node removed from scene tree
func _on_node_removed(node):
    # Check if it's the current player
    if node == player:
        disconnect_player_signals()
    # Check if it's the current camera
    elif node == camera:
        disconnect_camera_signals()
        camera = null
    # Check if it's an NPC
    elif node.is_in_group("npc"):
        _on_npc_removed(node)

# Override _exit_tree to cleanup connections
func _exit_tree():
    cleanup_connections()
    
    # Disconnect from scene tree monitoring
    if get_tree().is_connected("node_added", self, "_on_node_added"):
        get_tree().disconnect("node_added", self, "_on_node_added")
    if get_tree().is_connected("node_removed", self, "_on_node_removed"):
        get_tree().disconnect("node_removed", self, "_on_node_removed")