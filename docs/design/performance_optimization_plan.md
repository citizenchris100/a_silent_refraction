# Performance Optimization Plan
**Target: Phase 2 - Full Systems Development**

## Overview

This document outlines the performance optimization strategy for A Silent Refraction, focusing on maintaining smooth gameplay on modest hardware while preserving the authentic 90's adventure game aesthetic. The goal is consistent 60 FPS performance with minimal memory footprint.

## Performance Targets

### Minimum Specifications
- **CPU**: Dual-core 2.0 GHz
- **RAM**: 4 GB
- **GPU**: DirectX 10 compatible
- **Storage**: 500 MB available space

### Performance Goals
- **Frame Rate**: Stable 60 FPS (with V-Sync)
- **Load Times**: < 2 seconds between districts
- **Memory Usage**: < 1 GB RAM
- **Save/Load**: < 1 second for operations

## Optimization Areas

### 1. Asset Optimization

#### Textures
- **Maximum Resolution**: 1920x1080 for backgrounds
- **Compression**: Use Godot's lossy compression (0.7 quality)
- **Mipmaps**: Disabled (pixel art doesn't benefit)
- **Import Settings**: Disable filter, disable mipmaps

#### Sprites
- **Sprite Sheets**: Pack related animations together
- **Trim Transparent Pixels**: Use Godot's automatic trimming
- **Animation Frames**: Limit to necessary frames (no excessive smoothness)

#### Audio
- **Format**: OGG Vorbis for music, WAV for short SFX
- **Quality**: 128 kbps for music, 44.1 kHz sample rate
- **Streaming**: Enable for music tracks > 1 minute

### 2. Scene Optimization

#### Node Structure
```gdscript
# Bad: Deep nesting
District
  └── Area1
      └── SubArea1
          └── NPCs
              └── NPC1
                  └── Sprite
                      └── AnimationPlayer

# Good: Flat structure
District
  ├── Areas
  ├── NPCs
  └── InteractiveObjects
```

#### Object Pooling
- **Dialog Boxes**: Reuse single instance
- **Particle Effects**: Pool common effects
- **Audio Players**: Limit concurrent sounds to 8

### 3. Script Optimization

#### Update Loops
```gdscript
# Bad: Checking every frame
func _process(delta):
    check_all_npcs_for_interaction()
    update_all_ui_elements()
    check_suspicion_levels()

# Good: Event-driven and throttled
func _ready():
    # Use timers for periodic checks
    var check_timer = Timer.new()
    check_timer.wait_time = 0.5  # Check twice per second
    check_timer.timeout.connect(_check_interactions)
    
    # Use signals for reactive updates
    player.position_changed.connect(_on_player_moved)
```

#### Memory Management
```gdscript
# Explicitly free heavy resources
func change_district(new_district: String):
    # Clear current district
    if current_district:
        current_district.cleanup()
        current_district.queue_free()
    
    # Force garbage collection before loading
    OS.call_deferred("dump_memory_to_file", "user://memory_dump.txt")
    
    # Load new district
    current_district = load(new_district).instance()
```

### 4. Rendering Optimization

#### Culling
- **Visibility**: Use VisibilityEnabler2D for off-screen objects
- **Y-Sorting**: Only for necessary layers (characters, interactive objects)
- **Light2D**: Avoid or use sparingly (not authentic to era)

#### Draw Calls
- **Batch Similar Sprites**: Use same material/shader
- **Static Elements**: Convert to single texture where possible
- **UI**: Use Control nodes, not sprites for interface

### 5. Save System Optimization

#### Data Compression
```gdscript
# Compress save data
func save_game():
    var save_dict = collect_save_data()
    var json_string = JSON.print(save_dict)
    var compressed = json_string.to_utf8().compress(File.COMPRESSION_GZIP)
    save_file.store_var(compressed)

# Only save changed data
var last_save_state = {}
func get_save_delta():
    var current_state = collect_save_data()
    var delta = {}
    for key in current_state:
        if current_state[key] != last_save_state.get(key):
            delta[key] = current_state[key]
    return delta
```

### 6. District Loading Strategy

#### Preloading
```gdscript
# Preload adjacent districts in background
var adjacent_districts = {
    "barracks": ["mall", "spaceport"],
    "mall": ["barracks", "engineering"],
    # etc...
}

func preload_adjacent():
    for district in adjacent_districts[current_district_name]:
        ResourceLoader.load_threaded_request(district_path)
```

#### Asset Streaming
- Load base assets first (walkable area, background)
- Stream in NPCs and interactive objects
- Load audio last

### 7. NPC Optimization

#### LOD System (Simple)
```gdscript
# Reduce processing for distant NPCs
func update_npc_lod():
    var player_pos = player.global_position
    for npc in get_tree().get_nodes_in_group("npcs"):
        var distance = player_pos.distance_to(npc.global_position)
        if distance > 1000:
            npc.set_physics_process(false)
            npc.animation_player.stop()
        elif distance > 500:
            npc.set_physics_process_internal_rate(0.5)  # Half rate
        else:
            npc.set_physics_process(true)
            npc.set_physics_process_internal_rate(1.0)
```

### 8. Time System Optimization

#### Event Scheduling
```gdscript
# Batch time-based checks
var time_subscribers = []
func notify_time_change():
    var current_minute = int(game_time)
    if current_minute != last_minute:
        for subscriber in time_subscribers:
            subscriber.call_deferred("on_minute_changed", current_minute)
        last_minute = current_minute
```

## Profiling Strategy

### Built-in Tools
1. **Godot Profiler**: Monitor frame time, physics, scripts
2. **Monitor Variables**: Track draw calls, vertex count, object count
3. **Custom Metrics**: Add performance counters for critical systems

### Performance Monitoring
```gdscript
# Performance singleton
extends Node

var frame_time_history = []
var max_history = 60

func _process(delta):
    frame_time_history.append(delta)
    if frame_time_history.size() > max_history:
        frame_time_history.pop_front()
    
    # Alert if average frame time > 20ms (50 FPS)
    var avg_frame_time = 0.0
    for time in frame_time_history:
        avg_frame_time += time
    avg_frame_time /= frame_time_history.size()
    
    if avg_frame_time > 0.02:
        push_warning("Performance degradation: " + str(1.0/avg_frame_time) + " FPS")
```

## Platform-Specific Optimizations

### Windows
- Enable GPU scheduling
- Use exclusive fullscreen for better performance

### Linux
- Test with both X11 and Wayland
- Ensure compatibility with common distributions

### Steam Deck (Future Consideration)
- 800p resolution support
- Gamepad-first UI considerations
- Battery optimization settings

## Debug Tools

### Performance Commands
```gdscript
# Console commands for testing
"perf_show": Show performance overlay
"perf_stress": Spawn many NPCs for stress testing  
"perf_report": Generate performance report
"mem_dump": Dump memory usage to file
"profile_start/stop": Start/stop profiling session
```

## Implementation Priority

### Phase 2 MVP
1. Asset import settings optimization
2. Basic object pooling for UI
3. District loading optimization
4. Save data compression

### Phase 2 Full
1. NPC LOD system
2. Advanced pooling
3. Memory management
4. Full profiling suite

### Phase 3 (Polish)
1. Platform-specific optimizations
2. Advanced streaming
3. Final performance pass

## Testing Protocol

### Performance Regression Tests
1. Load each district, verify < 2 second load time
2. Spawn maximum NPCs, verify > 60 FPS
3. Save/load with full game state, verify < 1 second
4. Run for 2 hours, check for memory leaks
5. Test on minimum spec hardware

## Conclusion

Performance optimization in A Silent Refraction focuses on smart asset management, efficient scripting, and respecting the target era's constraints. By following these guidelines, the game will run smoothly on modest hardware while maintaining its authentic retro aesthetic.