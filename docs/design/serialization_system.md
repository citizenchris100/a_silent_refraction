# Serialization/Deserialization System Design
**For Single-Slot Save System**

## Overview

The serialization system for A Silent Refraction must handle complex game state while maintaining the integrity of a single-slot save system inspired by Dead Rising. This system needs to serialize extensive world state including 100+ NPC states, event histories, time data, and player progress - all while being corruption-resistant and performant.

## Design Goals

1. **Data Integrity**: Single slot means corruption is catastrophic - must be bulletproof
2. **Performance**: Save/load should be fast despite complex state
3. **Compression**: Minimize file size without sacrificing speed
4. **Version Compatibility**: Support save migration across game updates
5. **Atomic Operations**: Save process must be all-or-nothing
6. **Transparency**: Clear save progress indication to player

## Save System Architecture

### Save File Structure

```
a_silent_refraction_save/
├── current.srf          # Active save file
├── backup.srf           # Previous save (automatic backup)
├── temp.srf             # Temporary during write operation
└── meta.json            # Metadata about saves
```

### Core Save Data Structure

```gdscript
# src/core/systems/save_manager.gd
class_name SaveManager

const SAVE_VERSION = 1
const SAVE_MAGIC = "SRF1"  # Silent Refraction Format v1

class SaveData:
    # Header
    var magic: String = SAVE_MAGIC
    var version: int = SAVE_VERSION
    var timestamp: int  # Unix timestamp
    var checksum: String  # SHA-256 of data section
    var play_time: float  # Total playtime in seconds
    
    # Core Game State
    var player_data: Dictionary = {}
    var time_data: Dictionary = {}
    var world_state: Dictionary = {}
    
    # Complex Systems
    var npc_states: Dictionary = {}  # 100+ NPCs
    var event_history: Array = []  # Compressed event log
    var living_world_state: Dictionary = {}
    var narrative_state: Dictionary = {}
    
    # Reputation and Relationships
    var relationship_matrix: Dictionary = {}
    var temporal_reputation: Dictionary = {}
    var coalition_state: Dictionary = {}
```

## Serialization Strategy

### 1. Hierarchical Data Organization

```gdscript
func organize_save_data() -> Dictionary:
    return {
        "header": create_header(),
        "player": serialize_player_data(),
        "time": serialize_time_data(),
        "world": serialize_world_state(),
        "npcs": serialize_npc_states(),
        "events": serialize_event_history(),
        "narrative": serialize_narrative_state()
    }
```

### 2. Player Data Serialization

```gdscript
func serialize_player_data() -> Dictionary:
    return {
        "location": {
            "district": Player.current_district,
            "room": Player.current_room,
            "position": var2str(Player.global_position)
        },
        "inventory": serialize_inventory(),
        "stats": {
            "exhaustion": Player.exhaustion_level,
            "money": Player.money,
            "suspicion_level": Player.global_suspicion
        },
        "flags": Player.game_flags  # Story progression flags
    }
```

### 3. Time System Serialization

```gdscript
func serialize_time_data() -> Dictionary:
    return {
        "current_time": GameClock.current_time,
        "current_day": GameClock.current_day,
        "last_sleep_day": DayCycleController.last_sleep_day,
        "time_costs_modifiers": TimeCostManager.get_modifiers(),
        
        # Deadline data
        "deadlines": serialize_deadlines(),
        "missed_deadlines": DeadlineManager.missed_deadlines,
        "completed_deadlines": DeadlineManager.completed_deadlines,
        
        # Fatigue data
        "fatigue_value": FatigueSystem.fatigue_value,
        "fatigue_multiplier": FatigueSystem.fatigue_multiplier,
        "stimulant_resistance": FatigueSystem.stimulant_resistance
    }
```

### 4. NPC State Compression

With 100+ NPCs, efficient serialization is critical:

```gdscript
func serialize_npc_states() -> Dictionary:
    var compressed_states = {}
    
    for npc_id in NPCManager.all_npcs:
        var npc = NPCManager.get_npc(npc_id)
        
        # Only save non-default values
        var state = {}
        
        if npc.status != NPCStatus.NORMAL:
            state["s"] = npc.status  # Short keys for compression
        
        if npc.location != npc.default_location:
            state["l"] = npc.location
        
        if npc.assimilated:
            state["a"] = true
            state["ad"] = npc.assimilation_day  # When assimilated
        
        if npc.suspicion_level > 0:
            state["su"] = npc.suspicion_level
        
        if npc.relationship_values.size() > 0:
            state["r"] = compress_relationships(npc.relationship_values)
        
        if state.size() > 0:  # Only save if differs from default
            compressed_states[npc_id] = state
    
    return compressed_states
```

### 5. Event History Compression

Events can accumulate significantly over a playthrough:

```gdscript
class CompressedEvent:
    var id: int  # Maps to event type enum
    var t: int   # Time offset from game start
    var d: Dictionary  # Minimal event-specific data

func serialize_event_history() -> Array:
    var compressed = []
    var event_type_map = create_event_type_map()
    
    for event in EventScheduler.event_history:
        compressed.append({
            "i": event_type_map[event.type],  # ID instead of string
            "t": int(event.timestamp),
            "d": extract_essential_data(event)
        })
    
    # Further compress similar consecutive events
    return run_length_encode_events(compressed)
```

### 6. Narrative State Serialization

```gdscript
func serialize_narrative_state() -> Dictionary:
    return {
        "active_branches": TemporalNarrativeManager.active_branch_path,
        "locked_content": TemporalNarrativeManager.locked_out_content,
        "discovered_events": EventDiscovery.discovered_events.keys(),  # Just IDs
        "rumors": compress_rumor_network(),
        "evidence": serialize_active_evidence()
    }
```

## Deserialization Strategy

### 1. Validation First

```gdscript
func load_save_file(path: String) -> SaveData:
    var file = File.new()
    if not file.file_exists(path):
        return null
    
    file.open(path, File.READ)
    var data = file.get_var()
    file.close()
    
    # Validate before processing
    if not validate_save_data(data):
        push_error("Save file validation failed")
        return null
    
    return deserialize_save_data(data)

func validate_save_data(data: Dictionary) -> bool:
    # Check magic number
    if not data.has("header") or data.header.magic != SAVE_MAGIC:
        return false
    
    # Verify checksum
    var calculated_checksum = calculate_checksum(data)
    if calculated_checksum != data.header.checksum:
        return false
    
    # Check version compatibility
    if not is_version_compatible(data.header.version):
        return false
    
    return true
```

### 2. Progressive Loading

Load data in stages to show progress:

```gdscript
func deserialize_save_data(data: Dictionary) -> SaveData:
    var save = SaveData.new()
    
    # Stage 1: Core data (quick)
    emit_signal("load_progress", 0.1, "Loading player data...")
    deserialize_player_data(data.player)
    
    emit_signal("load_progress", 0.2, "Loading time data...")
    deserialize_time_data(data.time)
    
    # Stage 2: World state (medium)
    emit_signal("load_progress", 0.3, "Loading world state...")
    deserialize_world_state(data.world)
    
    # Stage 3: NPCs (slow)
    emit_signal("load_progress", 0.4, "Loading NPC states...")
    deserialize_npc_states(data.npcs)
    
    # Stage 4: Events (slow)
    emit_signal("load_progress", 0.7, "Loading event history...")
    deserialize_event_history(data.events)
    
    # Stage 5: Narrative (quick)
    emit_signal("load_progress", 0.9, "Loading story progress...")
    deserialize_narrative_state(data.narrative)
    
    emit_signal("load_progress", 1.0, "Complete!")
    return save
```

### 3. NPC State Restoration

```gdscript
func deserialize_npc_states(compressed_states: Dictionary):
    # First pass: Create all NPCs in default state
    for npc_id in NPCRegistry.all_npc_ids:
        NPCManager.initialize_npc(npc_id)
    
    # Second pass: Apply saved states
    for npc_id in compressed_states:
        var state = compressed_states[npc_id]
        var npc = NPCManager.get_npc(npc_id)
        
        if "s" in state:
            npc.status = state.s
        
        if "l" in state:
            npc.set_location(state.l)
        
        if "a" in state:
            npc.assimilated = true
            npc.assimilation_day = state.ad
            npc.apply_assimilation_effects()
        
        if "su" in state:
            npc.suspicion_level = state.su
        
        if "r" in state:
            npc.relationship_values = decompress_relationships(state.r)
```

## Save Operation Flow

### 1. Atomic Save Process

```gdscript
func save_game():
    # Show saving UI
    UI.show_saving_indicator()
    
    # Step 1: Serialize to memory
    var save_data = organize_save_data()
    
    # Step 2: Write to temporary file
    var temp_path = SAVE_DIR + "/temp.srf"
    if not write_save_file(temp_path, save_data):
        UI.show_save_error("Failed to write save file")
        return false
    
    # Step 3: Backup current save
    var current_path = SAVE_DIR + "/current.srf"
    var backup_path = SAVE_DIR + "/backup.srf"
    
    if File.new().file_exists(current_path):
        OS.move_to_trash(backup_path)  # Remove old backup
        DirAccess.rename_absolute(current_path, backup_path)
    
    # Step 4: Promote temp to current
    DirAccess.rename_absolute(temp_path, current_path)
    
    # Step 5: Update metadata
    update_save_metadata()
    
    UI.hide_saving_indicator()
    return true
```

### 2. File Format

Use Godot's binary serialization with compression:

```gdscript
func write_save_file(path: String, data: Dictionary) -> bool:
    var file = File.new()
    var error = file.open_compressed(
        path, 
        File.WRITE, 
        File.COMPRESSION_ZSTD  # Best compression ratio
    )
    
    if error != OK:
        return false
    
    file.store_var(data)
    file.close()
    return true
```

## Version Migration

### 1. Version Compatibility

```gdscript
const MIN_COMPATIBLE_VERSION = 1
const MAX_COMPATIBLE_VERSION = 1

func migrate_save_data(data: Dictionary, from_version: int) -> Dictionary:
    if from_version == SAVE_VERSION:
        return data  # No migration needed
    
    # Apply migrations sequentially
    for version in range(from_version, SAVE_VERSION):
        data = apply_migration(data, version, version + 1)
    
    return data

func apply_migration(data: Dictionary, from: int, to: int) -> Dictionary:
    match [from, to]:
        [1, 2]:
            return migrate_1_to_2(data)
        _:
            push_error("Unknown migration path: %d to %d" % [from, to])
            return data
```

### 2. Migration Strategies

```gdscript
func migrate_1_to_2(data: Dictionary) -> Dictionary:
    # Example: Adding new field to NPC states
    if "npcs" in data:
        for npc_id in data.npcs:
            if not "temporal_rep" in data.npcs[npc_id]:
                data.npcs[npc_id]["temporal_rep"] = 0.0
    
    # Update version
    data.header.version = 2
    return data
```

## Performance Optimization

### 1. Lazy Loading for Large Data

```gdscript
class LazyEventHistory:
    var _compressed_data: PoolByteArray
    var _cached_events: Array = []
    var _cache_valid: bool = false
    
    func get_events() -> Array:
        if not _cache_valid:
            _cached_events = decompress_events(_compressed_data)
            _cache_valid = true
        return _cached_events
```

### 2. Background Saving

For smooth gameplay during saves:

```gdscript
func save_game_async():
    # Serialize in main thread (required for accessing game state)
    var save_data = organize_save_data()
    
    # Write in background thread
    var thread = Thread.new()
    thread.start(self, "_background_save", save_data)

func _background_save(save_data: Dictionary):
    # Perform file I/O in background
    write_save_file(SAVE_DIR + "/temp.srf", save_data)
    
    # Return to main thread for file swapping
    call_deferred("_complete_save")
```

## Error Handling

### 1. Corruption Detection

```gdscript
func detect_save_corruption():
    var saves = {
        "current": SAVE_DIR + "/current.srf",
        "backup": SAVE_DIR + "/backup.srf"
    }
    
    for save_name in saves:
        var path = saves[save_name]
        if not File.new().file_exists(path):
            continue
            
        if not validate_save_file(path):
            push_warning("Save file corrupted: " + save_name)
            if save_name == "current" and File.new().file_exists(saves.backup):
                # Attempt recovery from backup
                recover_from_backup()
```

### 2. Recovery Options

```gdscript
func show_corruption_dialog():
    var dialog = ConfirmationDialog.new()
    dialog.dialog_text = "Your save file appears corrupted. Options:\n\n" + \
        "1. Attempt recovery from backup (may lose recent progress)\n" + \
        "2. Start new game\n" + \
        "3. Contact support with save file"
    
    dialog.add_button("Recover from Backup", true, "recover")
    dialog.add_button("New Game", true, "new")
    dialog.add_button("Export Save", true, "export")
```

## Save File Analytics

Track save file metrics for optimization:

```gdscript
func analyze_save_file(path: String) -> Dictionary:
    var file = File.new()
    file.open(path, File.READ)
    var data = file.get_var()
    file.close()
    
    return {
        "file_size": file.get_len(),
        "npc_count": data.npcs.size(),
        "event_count": data.events.size(),
        "play_time": data.header.play_time,
        "game_day": data.time.current_day,
        "compression_ratio": calculate_compression_ratio(data)
    }
```

## Security Considerations

### 1. Checksum Validation

```gdscript
func calculate_checksum(data: Dictionary) -> String:
    # Remove header before calculating
    var content = data.duplicate()
    content.erase("header")
    
    # Convert to bytes
    var bytes = var2bytes(content)
    
    # Calculate SHA-256
    var crypto = Crypto.new()
    return crypto.hash(HashingContext.HASH_SHA256, bytes).hex_encode()
```

### 2. Save File Encryption (Optional)

For preventing save manipulation:

```gdscript
func encrypt_save_data(data: Dictionary, key: String) -> PoolByteArray:
    var crypto = Crypto.new()
    var bytes = var2bytes(data)
    return crypto.encrypt(bytes, key.to_utf8())
```

## Testing Framework

### 1. Save/Load Test Suite

```gdscript
func test_save_load_cycle():
    # Create complex game state
    setup_test_game_state()
    
    # Save
    assert(save_game(), "Save operation failed")
    
    # Modify state
    corrupt_game_state()
    
    # Load
    assert(load_game(), "Load operation failed")
    
    # Verify state restored
    assert_game_state_matches_original()
```

### 2. Stress Testing

```gdscript
func stress_test_save_system():
    # Test with maximum NPCs
    spawn_all_npcs()
    
    # Generate massive event history
    for i in range(10000):
        generate_random_event()
    
    # Measure performance
    var start_time = OS.get_ticks_msec()
    save_game()
    var save_time = OS.get_ticks_msec() - start_time
    
    start_time = OS.get_ticks_msec()
    load_game()
    var load_time = OS.get_ticks_msec() - start_time
    
    print("Save time: %d ms, Load time: %d ms" % [save_time, load_time])
    assert(save_time < 1000, "Save too slow")
    assert(load_time < 2000, "Load too slow")
```

## Success Metrics

1. **Save Performance**: < 1 second for typical game state
2. **Load Performance**: < 2 seconds for full restoration
3. **File Size**: < 1MB for typical playthrough
4. **Corruption Rate**: < 0.001% in production
5. **Version Migration**: 100% success rate
6. **Compression Ratio**: > 10:1 for event history