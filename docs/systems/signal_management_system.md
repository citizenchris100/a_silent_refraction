# Signal Management System Documentation

## Overview

The Signal Management System, implemented in Task 10, provides a robust and centralized approach to managing signal connections between game systems. This system prevents common issues like duplicate connections, memory leaks from orphaned signals, and provides proper cleanup during scene transitions.

## Architecture

The signal management system is primarily implemented in the GameManager, which acts as a central hub for coordinating signal connections between major game systems.

### Core Components

1. **GameManager** (`src/core/game/game_manager.gd`)
   - Central signal coordinator
   - Tracks all active connections
   - Provides cleanup and validation methods
   - Monitors scene tree for dynamic changes

2. **Group-Based Discovery**
   - Systems register themselves in groups for easy discovery
   - Eliminates hard-coded node paths
   - Enables dynamic system connection

3. **Connection Tracking**
   - All connections are tracked in a central registry
   - Prevents duplicate connections
   - Enables comprehensive cleanup

## Key Features

### 1. Automatic System Discovery

Systems automatically register themselves in groups during initialization:

```gdscript
# In InputManager._ready()
add_to_group("input_manager")

# In ScrollingCamera._ready()
add_to_group("camera")

# In GameManager._ready()
add_to_group("game_manager")
```

This allows systems to find each other dynamically:

```gdscript
func _find_and_connect_player():
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        var player = players[0]
        connect_to_player(player)
```

### 2. Connection Tracking

All signal connections are tracked in a central dictionary:

```gdscript
var active_connections = {}

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

### 3. Duplicate Connection Prevention

Before connecting any signal, the system checks if it's already connected:

```gdscript
func connect_to_player(player_node):
    if not player_node or not is_instance_valid(player_node):
        return
    
    if player_node.has_signal("movement_state_changed"):
        if not player_node.is_connected("movement_state_changed", self, "_on_player_movement_state_changed"):
            player_node.connect("movement_state_changed", self, "_on_player_movement_state_changed")
            _track_connection(player_node, "movement_state_changed", self, "_on_player_movement_state_changed")
```

### 4. Comprehensive Cleanup

The system provides multiple levels of cleanup:

```gdscript
# Clean up all tracked connections
func cleanup_connections():
    print("Cleaning up all signal connections")
    for key in active_connections.keys():
        var conn = active_connections[key]
        if is_instance_valid(conn.signal_owner) and is_instance_valid(conn.target):
            if conn.signal_owner.is_connected(conn.signal_name, conn.target, conn.method_name):
                conn.signal_owner.disconnect(conn.signal_name, conn.target, conn.method_name)
    active_connections.clear()

# Specific cleanup methods
func disconnect_player_signals():
    # Disconnect player-specific signals

func disconnect_camera_signals():
    # Disconnect camera-specific signals
```

### 5. Scene Tree Monitoring

The system monitors the scene tree for dynamic changes:

```gdscript
func _ready():
    # Monitor scene tree changes
    get_tree().connect("node_added", self, "_on_node_added")
    get_tree().connect("node_removed", self, "_on_node_removed")

func _on_node_added(node):
    # Check if it's a system we care about
    if node.is_in_group("npc"):
        _on_npc_added(node)
    elif node.is_in_group("player"):
        connect_to_player(node)

func _on_node_removed(node):
    # Clean up connections for removed nodes
    if node.is_in_group("npc"):
        _on_npc_removed(node)
```

### 6. Connection Integrity Verification

The system can verify that all tracked connections are still valid:

```gdscript
func verify_connections():
    var invalid_connections = []
    
    for key in active_connections.keys():
        var conn = active_connections[key]
        
        # Check if objects are still valid
        if not is_instance_valid(conn.signal_owner) or not is_instance_valid(conn.target):
            invalid_connections.append(key)
            continue
        
        # Check if connection still exists
        if not conn.signal_owner.is_connected(conn.signal_name, conn.target, conn.method_name):
            invalid_connections.append(key)
    
    # Remove invalid connections
    for key in invalid_connections:
        active_connections.erase(key)
    
    return invalid_connections.size()
```

## Signal Flow Examples

### Player Movement State Changes

```
Player moves → Emits movement_state_changed → GameManager receives → Relays to other systems
```

### Camera State Changes

```
Camera state changes → Emits camera_state_changed → GameManager receives → Updates UI/systems
```

### Click Detection

```
User clicks → InputManager validates → Emits click_detected → GameManager routes → Action executed
```

## NPC Lifecycle Management

The system handles dynamic NPC creation and removal:

```gdscript
func _on_npc_added(npc):
    if not npc or not is_instance_valid(npc):
        return
    _connect_npc_signals(npc)

func _on_npc_removed(npc):
    if not npc or not is_instance_valid(npc):
        return
    _disconnect_npc_signals(npc)

func _connect_npc_signals(npc):
    if npc.has_signal("interacted"):
        if not npc.is_connected("interacted", self, "_on_npc_interacted"):
            npc.connect("interacted", self, "_on_npc_interacted", [npc])
            _track_connection(npc, "interacted", self, "_on_npc_interacted")
```

## Best Practices

### 1. Use Group-Based Discovery

Instead of hard-coded paths:
```gdscript
# Bad
var player = get_node("/root/Game/Player")

# Good
var players = get_tree().get_nodes_in_group("player")
if players.size() > 0:
    var player = players[0]
```

### 2. Always Check Connections

Before connecting:
```gdscript
if not signal_owner.is_connected(signal_name, target, method):
    signal_owner.connect(signal_name, target, method)
```

### 3. Track Important Connections

For connections that need cleanup:
```gdscript
connection_tracker.track_connection(signal_owner, signal_name, target, method)
```

### 4. Clean Up on Exit

Always clean up in _exit_tree():
```gdscript
func _exit_tree():
    cleanup_connections()
```

### 5. Verify Connection Integrity

Periodically verify connections are still valid:
```gdscript
func _on_timer_timeout():
    var cleaned = verify_connections()
    if cleaned > 0:
        print("Cleaned up %d invalid connections" % cleaned)
```

## Integration Guide

### Adding a New System

1. **Register in a group**:
```gdscript
func _ready():
    add_to_group("my_system")
```

2. **Define signals**:
```gdscript
signal my_state_changed(new_state)
signal my_action_completed(result)
```

3. **Connect through GameManager**:
```gdscript
# In GameManager
func _find_and_connect_my_system():
    var systems = get_tree().get_nodes_in_group("my_system")
    if systems.size() > 0:
        var system = systems[0]
        if not system.is_connected("my_state_changed", self, "_on_my_system_state_changed"):
            system.connect("my_state_changed", self, "_on_my_system_state_changed")
            _track_connection(system, "my_state_changed", self, "_on_my_system_state_changed")
```

### Removing a System

The signal management system automatically handles removal through scene tree monitoring. Just ensure your system:

1. Properly frees itself with `queue_free()`
2. Doesn't manually disconnect tracked signals (let GameManager handle it)

## Testing

The signal management system is thoroughly tested at all three levels:

### Unit Tests
- `game_manager_signal_test.gd` - Tests connection tracking and cleanup
- `input_manager_signal_test.gd` - Tests input signal emission
- `player_signal_emission_test.gd` - Tests player state signals

### Component Tests
- `game_manager_camera_signal_component_test.gd` - Tests GameManager-Camera integration
- `game_manager_player_signal_component_test.gd` - Tests GameManager-Player integration
- `input_game_manager_signal_component_test.gd` - Tests Input-GameManager chain

### Subsystem Tests
- `navigation_signal_flow_subsystem_test.gd` - Tests complete signal flow
- `signal_cleanup_subsystem_test.gd` - Tests cleanup on scene changes

## Common Issues and Solutions

### Signals Not Connecting
- Check if system is in the expected group
- Verify signal exists with `has_signal()`
- Ensure objects are in the scene tree

### Duplicate Connections
- Always use `is_connected()` check
- Use the connection tracking system
- Don't manually connect tracked signals

### Memory Leaks
- Ensure `cleanup_connections()` is called
- Check for circular references
- Verify scene tree monitoring is working

### Performance Issues
- Use `verify_connections()` sparingly
- Consider connection pooling for frequently created objects
- Profile signal emission frequency

## Future Enhancements

1. **Connection Pooling** - Reuse connections for frequently created/destroyed objects
2. **Signal Batching** - Batch multiple signals into single emissions
3. **Priority System** - Handle signal priorities for ordering
4. **Debug Visualization** - Visual representation of active connections
5. **Performance Metrics** - Track signal emission frequency and timing