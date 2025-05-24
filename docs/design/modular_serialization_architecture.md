# Modular Serialization Architecture

## Overview

This document defines the modular serialization architecture for A Silent Refraction that minimizes refactoring as new systems are added throughout development. The architecture uses a plugin-based approach where each game system provides its own serializer that integrates seamlessly with the core save system.

## Core Architecture

### 1. SaveManager (Orchestrator)

```gdscript
# src/core/systems/save_manager.gd
extends Node

class_name SaveManager

# Serializer registry
var serializers: Dictionary = {}  # {system_name: serializer_instance}
var serializer_order: Array = []  # Order matters for dependencies

# Register a serializer for a game system
func register_serializer(system_name: String, serializer: BaseSerializer, priority: int = 0):
    serializers[system_name] = serializer
    serializer.system_name = system_name
    
    # Insert in priority order
    var entry = {"name": system_name, "priority": priority}
    serializer_order.append(entry)
    serializer_order.sort_custom(self, "_sort_by_priority")
    
    print("Registered serializer: %s (priority: %d)" % [system_name, priority])

func _sort_by_priority(a, b):
    return a.priority < b.priority  # Lower number = higher priority

# Main save operation
func save_game() -> bool:
    var save_data = SaveData.new()
    save_data.version = SAVE_VERSION
    save_data.timestamp = OS.get_unix_time()
    
    # Collect data from all serializers
    save_data.modules = {}
    for entry in serializer_order:
        var name = entry.name
        var serializer = serializers[name]
        
        # Let each serializer add its data
        var module_data = serializer.serialize()
        if module_data != null:
            save_data.modules[name] = {
                "version": serializer.get_version(),
                "data": module_data
            }
    
    # Calculate checksum
    save_data.checksum = calculate_checksum(save_data.modules)
    
    # Write atomically
    return write_save_file(save_data)

# Main load operation
func load_game() -> bool:
    var save_data = read_save_file()
    if save_data == null:
        return false
    
    # Verify checksum
    if not verify_checksum(save_data):
        push_error("Save file checksum mismatch")
        return false
    
    # Load each module
    for entry in serializer_order:
        var name = entry.name
        if not name in save_data.modules:
            continue  # Module didn't exist when saved
        
        var module_data = save_data.modules[name]
        var serializer = serializers[name]
        
        # Handle version differences
        if module_data.version != serializer.get_version():
            module_data.data = serializer.migrate(
                module_data.data, 
                module_data.version, 
                serializer.get_version()
            )
        
        # Deserialize
        serializer.deserialize(module_data.data)
    
    return true
```

### 2. Base Serializer Interface

```gdscript
# src/core/systems/serializers/base_serializer.gd
extends Reference

class_name BaseSerializer

var system_name: String = ""

# Override these in subclasses
func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    push_error("serialize() not implemented for " + system_name)
    return {}

func deserialize(data: Dictionary) -> void:
    push_error("deserialize() not implemented for " + system_name)

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    # Default: no migration needed
    return data

# Helper methods available to all serializers
func compress_vector2(v: Vector2) -> Array:
    return [v.x, v.y]

func decompress_vector2(a: Array) -> Vector2:
    return Vector2(a[0], a[1])

func compress_bool_flags(flags: Dictionary) -> int:
    var result = 0
    var bit = 0
    for key in flags:
        if flags[key]:
            result |= (1 << bit)
        bit += 1
    return result
```

### 3. System-Specific Serializers

#### Player Serializer (Simple - Iteration 5)

```gdscript
# src/core/serializers/player_serializer.gd
extends BaseSerializer

class_name PlayerSerializer

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    var player = get_node("/root/Game/Player")
    if not player:
        return {}
    
    return {
        "position": compress_vector2(player.global_position),
        "district": player.current_district,
        "room": player.current_room,
        "facing": player.facing_direction,
        "inventory": serialize_inventory(player.inventory),
        "stats": {
            "money": player.money,
            "suspicion": player.suspicion_level
        }
    }

func deserialize(data: Dictionary) -> void:
    var player = get_node("/root/Game/Player")
    if not player:
        return
    
    player.global_position = decompress_vector2(data.position)
    player.current_district = data.district
    player.current_room = data.room
    player.facing_direction = data.facing
    deserialize_inventory(player.inventory, data.inventory)
    player.money = data.stats.money
    player.suspicion_level = data.stats.suspicion

func serialize_inventory(inventory: Node) -> Array:
    var items = []
    for item in inventory.get_items():
        items.append({
            "id": item.id,
            "quantity": item.quantity
        })
    return items
```

#### NPC Serializer (Will grow complex - Iteration 5 simple version)

```gdscript
# src/core/serializers/npc_serializer.gd
extends BaseSerializer

class_name NPCSerializer

func get_version() -> int:
    return 1  # Will increment as complexity grows

func serialize() -> Dictionary:
    var result = {
        "npcs": {}
    }
    
    # Only save non-default states
    for npc in NPCManager.get_all_npcs():
        var state = {}
        
        # Position (only if moved from spawn)
        if npc.global_position != npc.spawn_position:
            state["pos"] = compress_vector2(npc.global_position)
        
        # State machine (only if not IDLE)
        if npc.current_state != NPC.State.IDLE:
            state["st"] = npc.current_state
        
        # Suspicion (only if > 0)
        if npc.suspicion_level > 0:
            state["sus"] = npc.suspicion_level
        
        # Dialog progress (only if started)
        if npc.dialog_progress > 0:
            state["dlg"] = npc.dialog_progress
        
        # Only save if NPC has non-default state
        if state.size() > 0:
            result.npcs[npc.id] = state
    
    return result

func deserialize(data: Dictionary) -> void:
    # Reset all NPCs to default first
    NPCManager.reset_all_npcs()
    
    # Apply saved states
    for npc_id in data.npcs:
        var npc = NPCManager.get_npc(npc_id)
        if not npc:
            continue
        
        var state = data.npcs[npc_id]
        
        if "pos" in state:
            npc.global_position = decompress_vector2(state.pos)
        
        if "st" in state:
            npc.set_state(state.st)
        
        if "sus" in state:
            npc.suspicion_level = state.sus
        
        if "dlg" in state:
            npc.dialog_progress = state.dlg

# Future migration when schedules are added (Iteration 6)
func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    if from_version == 1 and to_version == 2:
        # Add default schedule state to all NPCs
        for npc_id in data.npcs:
            if not "sch" in data.npcs[npc_id]:
                data.npcs[npc_id]["sch"] = null  # Use default schedule
    
    return data
```

### 4. Future System Integration

When new systems are added, they simply create their own serializer:

#### Time System Serializer (Future - Iteration 6)

```gdscript
# src/core/serializers/time_serializer.gd
extends BaseSerializer

class_name TimeSerializer

func _ready():
    # Self-register when time system initializes
    SaveManager.register_serializer("time", self, 10)  # High priority

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "current_time": GameClock.current_time,
        "current_day": GameClock.current_day,
        "last_sleep": DayCycleController.last_sleep_day
    }

func deserialize(data: Dictionary) -> void:
    GameClock.current_time = data.current_time
    GameClock.current_day = data.current_day
    DayCycleController.last_sleep_day = data.last_sleep
```

#### Event System Serializer (Future - Iteration 6)

```gdscript
# src/core/serializers/event_serializer.gd
extends BaseSerializer

class_name EventSerializer

func _ready():
    SaveManager.register_serializer("events", self, 20)

func serialize() -> Dictionary:
    # Compress events aggressively
    var compressed_history = compress_event_history()
    
    return {
        "history": compressed_history,
        "scheduled": SimpleEventScheduler.get_scheduled_events(),
        "discovered": EventDiscovery.discovered_events
    }

func compress_event_history() -> Array:
    # Implementation of RLE compression for events
    var compressed = []
    # ... compression logic ...
    return compressed
```

### 5. System Initialization Order

```gdscript
# src/core/game.gd
extends Node

func _ready():
    # Initialize SaveManager first
    SaveManager.initialize()
    
    # Systems register their serializers as they initialize
    PlayerController.initialize()  # Registers PlayerSerializer
    NPCManager.initialize()        # Registers NPCSerializer
    WorldManager.initialize()      # Registers WorldSerializer
    
    # Future systems will auto-register when added
    # TimeManager.initialize()     # Will register TimeSerializer
    # EventScheduler.initialize()  # Will register EventSerializer
```

## Key Design Principles

### 1. Self-Registration
Each system is responsible for registering its own serializer. This means new systems can be added without modifying SaveManager.

### 2. Differential Serialization
Only save data that differs from defaults. This is crucial for NPCs and events.

### 3. Version Independence
Each serializer tracks its own version and handles its own migrations.

### 4. Priority-Based Ordering
Systems can specify load priority to handle dependencies (e.g., Time must load before Events).

### 5. Graceful Degradation
If a serializer isn't registered (system not implemented yet), SaveManager continues without error.

## Migration Example

When NPCs gain schedules in Iteration 6:

```gdscript
# npc_serializer.gd gets updated:

func get_version() -> int:
    return 2  # Increment version

func serialize() -> Dictionary:
    var result = {
        "npcs": {}
    }
    
    for npc in NPCManager.get_all_npcs():
        var state = {}
        
        # ... existing serialization ...
        
        # NEW: Schedule state
        if npc.schedule_state != null:
            state["sch"] = serialize_schedule_state(npc.schedule_state)
        
        if state.size() > 0:
            result.npcs[npc.id] = state
    
    return result

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    if from_version == 1 and to_version == 2:
        print("Migrating NPC data from v1 to v2")
        # Old saves get default schedule states
        # No data loss, just new fields added
    
    return data
```

## Benefits of This Architecture

1. **Minimal Refactoring**: New systems add serializers without touching existing code
2. **Clear Ownership**: Each system owns its serialization logic
3. **Easy Testing**: Each serializer can be unit tested independently
4. **Flexible Evolution**: Systems can change their data format with migrations
5. **Performance**: Only serialize active systems and non-default values
6. **Debugging**: Each module's data is clearly separated in save files

## Implementation Timeline

### Iteration 5 (Save System Foundation)
- Implement SaveManager with modular architecture
- Create PlayerSerializer (simple)
- Create NPCSerializer (simple) 
- Create WorldSerializer (doors, switches)

### Iteration 6+ (As Systems Are Added)
- TimeSerializer when time system is added
- EventSerializer when event system is added
- Each new system brings its own serializer

This architecture ensures that the save system grows naturally with the game, requiring minimal refactoring as complexity increases.