# Game Manager System Documentation

## Overview

The GameManager is the central coordinator for all major game systems in A Silent Refraction. It manages verb-based interactions, coordinates between systems, handles signal connections, and maintains game state. As of Task 10, it includes comprehensive signal management capabilities.

## Architecture

### Core Responsibilities

1. **System Coordination**
   - Creates and manages InputManager
   - Coordinates between Player, Camera, NPCs, and UI systems
   - Routes interactions to appropriate handlers

2. **Verb System Management**
   - Tracks current active verb
   - Processes verb-object interactions
   - Manages verb UI state

3. **Signal Management** (Task 10 Enhancement)
   - Automatically discovers and connects to game systems
   - Tracks all active signal connections
   - Provides cleanup on scene changes
   - Prevents duplicate connections

4. **Scene Management**
   - Handles district transitions
   - Manages save/load operations
   - Coordinates system cleanup on scene changes

## Class Structure

### Properties

```gdscript
# Core Systems
var input_manager = null
var dialog_manager = null
var current_district = null

# Verb System
var current_verb = "walk_to"
var verb_ui = null

# Signal Management (Task 10)
var active_connections = {}  # Tracks all managed signal connections
```

### Signals

```gdscript
# Relay signals for system coordination
signal player_state_relayed(state)
signal camera_state_relayed(state)
```

## Signal Management System

### Automatic System Discovery

GameManager automatically finds and connects to systems using Godot's group system:

```gdscript
func _ready():
    # Add self to group for discovery
    add_to_group("game_manager")
    
    # Find and connect to existing systems
    _find_and_connect_player()
    _find_and_connect_camera()
    
    # Monitor for dynamically added systems
    get_tree().connect("node_added", self, "_on_node_added")
    get_tree().connect("node_removed", self, "_on_node_removed")
```

### Connection Tracking

All signal connections are tracked to enable proper cleanup:

```gdscript
func _track_connection(signal_owner, signal_name: String, target, method_name: String):
    var key = str(signal_owner.get_instance_id()) + "_" + signal_name
    active_connections[key] = {
        "signal_owner": signal_owner,
        "signal_name": signal_name,
        "target": target,
        "method_name": method_name,
        "connected_at": OS.get_ticks_msec()
    }
```

### Duplicate Prevention

Before connecting signals, the system checks for existing connections:

```gdscript
func connect_to_player(player_node):
    if not player_node or not is_instance_valid(player_node):
        return
    
    if player_node.has_signal("movement_state_changed"):
        if not player_node.is_connected("movement_state_changed", self, "_on_player_movement_state_changed"):
            player_node.connect("movement_state_changed", self, "_on_player_movement_state_changed")
            _track_connection(player_node, "movement_state_changed", self, "_on_player_movement_state_changed")
```

### Comprehensive Cleanup

The system provides multiple levels of cleanup:

```gdscript
func cleanup_connections():
    print("Cleaning up all signal connections")
    for key in active_connections.keys():
        var conn = active_connections[key]
        if is_instance_valid(conn.signal_owner) and is_instance_valid(conn.target):
            if conn.signal_owner.is_connected(conn.signal_name, conn.target, conn.method_name):
                conn.signal_owner.disconnect(conn.signal_name, conn.target, conn.method_name)
    active_connections.clear()

func _exit_tree():
    cleanup_connections()
```

### Connection Integrity

The system can verify and clean up invalid connections:

```gdscript
func verify_connections():
    var invalid_connections = []
    
    for key in active_connections.keys():
        var conn = active_connections[key]
        
        if not is_instance_valid(conn.signal_owner) or not is_instance_valid(conn.target):
            invalid_connections.append(key)
            continue
        
        if not conn.signal_owner.is_connected(conn.signal_name, conn.target, conn.method_name):
            invalid_connections.append(key)
    
    for key in invalid_connections:
        active_connections.erase(key)
    
    return invalid_connections.size()
```

## Verb System

### Verb Processing Flow

1. User selects verb from UI
2. GameManager stores current verb
3. User clicks on object
4. InputManager validates and routes click
5. GameManager processes interaction based on verb and target

### Verb Handlers

```gdscript
func handle_npc_click(npc):
    if current_verb == "talk_to":
        start_dialog_with_npc(npc)
    else:
        # Let NPC handle other verbs
        npc.interact(current_verb)

func handle_object_click(object, click_position):
    object.interact(current_verb)
```

## System Integration

### InputManager Integration

GameManager creates and manages the InputManager:

```gdscript
func _ready():
    # Create input manager
    input_manager = preload("res://src/core/input/input_manager.gd").new()
    input_manager.name = "InputManager"
    add_child(input_manager)
    
    # Connect to input signals
    input_manager.connect("object_clicked", self, "_on_object_clicked")
```

### Player Integration

Automatically connects to player signals:

```gdscript
func _find_and_connect_player():
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        var player = players[0]
        connect_to_player(player)

func _on_player_movement_state_changed(new_state):
    # Relay to other systems that need to know
    emit_signal("player_state_relayed", new_state)
```

### Camera Integration

Monitors camera state changes:

```gdscript
func _find_and_connect_camera():
    var cameras = get_tree().get_nodes_in_group("camera")
    if cameras.size() > 0:
        var camera = cameras[0]
        _connect_camera_signals(camera)

func _on_camera_state_changed(new_state, old_state, transition_reason):
    emit_signal("camera_state_relayed", new_state)
```

### NPC Lifecycle Management

Handles dynamic NPC creation and removal:

```gdscript
func _on_node_added(node):
    if node.is_in_group("npc"):
        _on_npc_added(node)

func _on_npc_added(npc):
    _connect_npc_signals(npc)

func _on_npc_removed(npc):
    _disconnect_npc_signals(npc)
```

## Scene Management

### District Transitions

```gdscript
func change_district(district_path: String):
    # Clean up current connections
    cleanup_connections()
    
    # Load new district
    get_tree().change_scene(district_path)
```

### Save/Load Integration

```gdscript
func save_game_state():
    var save_data = {
        "current_verb": current_verb,
        "current_district": current_district.filename if current_district else ""
    }
    return save_data

func load_game_state(save_data):
    current_verb = save_data.get("current_verb", "walk_to")
    # District loading handled separately
```

## Best Practices

### System Discovery

Always use group-based discovery instead of hard-coded paths:

```gdscript
# Good
var players = get_tree().get_nodes_in_group("player")

# Bad
var player = get_node("/root/Game/Player")
```

### Signal Connection

Always check for existing connections:

```gdscript
if not node.is_connected(signal_name, target, method):
    node.connect(signal_name, target, method)
    _track_connection(node, signal_name, target, method)
```

### Cleanup

Always clean up on scene exit:

```gdscript
func _exit_tree():
    cleanup_connections()
```

## Testing

GameManager functionality is tested at multiple levels:

### Unit Tests
- `game_manager_signal_test.gd` - Signal management functionality

### Component Tests
- `game_manager_camera_signal_component_test.gd` - Camera integration
- `game_manager_player_signal_component_test.gd` - Player integration
- `input_game_manager_signal_component_test.gd` - Input chain

### Subsystem Tests
- `navigation_signal_flow_subsystem_test.gd` - Complete signal flow
- `signal_cleanup_subsystem_test.gd` - Scene change cleanup

## Common Issues

### Systems Not Connecting
- Ensure systems add themselves to appropriate groups
- Check timing - systems may not be ready immediately
- Verify signal names match exactly

### Memory Leaks
- Always use cleanup_connections() on scene changes
- Track all connections with _track_connection()
- Implement _exit_tree() cleanup

### Duplicate Connections
- Always check is_connected() before connecting
- Use the connection tracking system
- Don't manually reconnect tracked signals

## Future Enhancements

1. **Event Bus System** - Decouple systems further with event bus
2. **State Persistence** - More comprehensive save/load
3. **Plugin Architecture** - Allow modular system additions
4. **Performance Monitoring** - Track system performance metrics
5. **Debug Visualization** - Visual representation of system connections