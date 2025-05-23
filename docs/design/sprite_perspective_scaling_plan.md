# Sprite Perspective Scaling System Plan

**Status: 📋 DESIGN**  
**Target: Iteration 3 Extension**  
**Created: May 22, 2025**

## Executive Summary

This document outlines a comprehensive plan for implementing a sprite perspective scaling system that enables characters and objects to scale appropriately based on their position within perspective-based backgrounds (like `camera_test_background001.png`). The system adheres to the architectural principles of A Silent Refraction while providing visual correctness for SCUMM-style perspective environments.

## Core Requirements

### Visual Requirements
1. **Depth-based Scaling**: Sprites scale smaller when "further away" (higher Y position)
2. **Natural Movement**: Movement speed appears consistent with perspective
3. **Proper Layering**: Objects further back render behind closer objects
4. **Smooth Transitions**: Scaling changes gradually as characters move
5. **Consistency**: All interactive elements follow the same scaling rules

### Audio Requirements (Added for POC)
1. **Diegetic Audio Scaling**: Sound sources in the game world scale volume based on distance and perspective
2. **Spatial Audio**: Stereo panning reflects horizontal position relative to listener
3. **Environmental Immersion**: Multiple audio sources create realistic soundscapes
4. **Gameplay Integration**: Audio cues provide gameplay information based on proximity

### Technical Requirements
1. **Architectural Compliance**: Follows component-based design with minimal coupling
2. **Performance**: Efficient scaling calculations without frame drops
3. **Testability**: All scaling behaviors independently testable
4. **Extensibility**: Easy to add new perspective types or scaling curves
5. **Integration**: Works seamlessly with existing coordinate and camera systems

## System Architecture

### Component Overview

```
PerspectiveScalingSystem (Node)
├── ScalingZoneManager (Singleton)
│   ├── Zone definitions
│   ├── Scaling calculations
│   ├── Audio source management
│   └── Debug visualization
├── PerspectiveController (Component)
│   ├── Applies scaling to entities
│   ├── Manages z-index layering
│   ├── Handles movement speed adjustment
│   └── Updates nearby audio sources
├── DiegeticAudioSource (Component)
│   ├── Distance-based volume scaling
│   ├── Stereo panning
│   └── Perspective integration
└── DistrictPerspectiveConfig (Resource)
    ├── Scaling parameters
    ├── Zone boundaries
    ├── Audio falloff curves
    └── Curve definitions
```

### Key Design Decisions

1. **Component-Based Approach**: Scaling is handled by a component that can be attached to any Node2D
2. **Zone-Based System**: Districts define perspective zones rather than pure Y-position scaling
3. **Resource-Driven Configuration**: Perspective settings stored as resources for easy editing
4. **Singleton Coordination**: ScalingZoneManager provides centralized scaling calculations
5. **Visual Priority**: When precision conflicts with visual appearance, visual correctness wins

## Implementation Details

### 1. ScalingZoneManager (Singleton)

Located at: `src/core/perspective/scaling_zone_manager.gd`

```gdscript
extends Node

# Singleton pattern
static var instance = null

# Current district's perspective configuration
var current_config: DistrictPerspectiveConfig = null

# Scaling zone definitions
var scaling_zones = []

func _ready():
    if instance == null:
        instance = self
    else:
        queue_free()

# Calculate scale for a given world position
func get_scale_at_position(world_pos: Vector2) -> float:
    if current_config == null:
        return 1.0
    
    # Find which zone the position is in
    var zone = _find_zone_for_position(world_pos)
    if zone == null:
        return current_config.default_scale
    
    # Calculate scale based on zone's curve
    return _calculate_scale_in_zone(world_pos, zone)

# Get z-index for layering
func get_z_index_at_position(world_pos: Vector2) -> int:
    # Simple approach: use Y position as z-index
    # Can be overridden per-district for complex needs
    return int(world_pos.y)

# Calculate adjusted movement speed
func get_movement_speed_multiplier(world_pos: Vector2) -> float:
    var scale = get_scale_at_position(world_pos)
    # Movement speed scales with visual size
    return scale
```

### 2. PerspectiveController (Component)

Located at: `src/core/perspective/perspective_controller.gd`

```gdscript
extends Node

# Target node to apply scaling to (usually parent)
var target: Node2D = null

# Configuration
export var enable_scaling = true
export var enable_z_sorting = true
export var enable_speed_adjustment = true
export var smooth_scaling = true
export var scaling_speed = 5.0

# Internal state
var current_scale = 1.0
var target_scale = 1.0

func _ready():
    # Get the parent node as target by default
    target = get_parent() as Node2D
    if target == null:
        push_error("PerspectiveController: No valid Node2D parent found")
        set_process(false)

func _process(delta):
    if not enable_scaling or target == null:
        return
    
    # Get target scale from manager
    target_scale = ScalingZoneManager.get_scale_at_position(target.global_position)
    
    # Apply scaling (smooth or instant)
    if smooth_scaling:
        current_scale = lerp(current_scale, target_scale, scaling_speed * delta)
    else:
        current_scale = target_scale
    
    # Apply to target
    target.scale = Vector2(current_scale, current_scale)
    
    # Update z-index for proper layering
    if enable_z_sorting:
        target.z_index = ScalingZoneManager.get_z_index_at_position(target.global_position)
    
    # Update audio sources if this is the player
    if target.is_in_group("player"):
        _update_audio_sources()

# Get adjusted movement speed for physics calculations
func get_adjusted_speed(base_speed: float) -> float:
    if not enable_speed_adjustment:
        return base_speed
    
    var multiplier = ScalingZoneManager.get_movement_speed_multiplier(target.global_position)
    return base_speed * multiplier

# Update all diegetic audio sources based on player position and scale
func _update_audio_sources():
    var audio_sources = get_tree().get_nodes_in_group("diegetic_audio")
    for source in audio_sources:
        if source.has_method("update_for_listener"):
            source.update_for_listener(target.global_position, current_scale)
```

### 3. DistrictPerspectiveConfig (Resource)

Located at: `src/core/perspective/district_perspective_config.gd`

```gdscript
extends Resource
class_name DistrictPerspectiveConfig

# Basic scaling parameters
export var enable_perspective = true
export var default_scale = 1.0
export var min_scale = 0.5
export var max_scale = 1.0

# Zone-based scaling
export var use_zones = true
export(Array, Resource) var scaling_zones = []  # Array of ScalingZone resources

# Simple Y-based scaling (fallback)
export var use_y_scaling = false
export var y_min = 0.0  # Y position for minimum scale
export var y_max = 600.0  # Y position for maximum scale
export(Curve) var scaling_curve = null  # Optional curve for non-linear scaling

# Movement speed adjustment
export var adjust_movement_speed = true
export var speed_curve: Curve = null  # Optional separate curve for speed

# Audio adjustments
export var adjust_audio_volume = false
export var volume_curve: Curve = null

# Visual effects
export var adjust_sprite_detail = false
export var detail_thresholds = {
    "high": 0.8,    # Scale > 0.8 uses high detail
    "medium": 0.5,  # Scale 0.5-0.8 uses medium detail  
    "low": 0.0      # Scale < 0.5 uses low detail
}
```

### 4. ScalingZone (Resource)

Located at: `src/core/perspective/scaling_zone.gd`

```gdscript
extends Resource
class_name ScalingZone

# Zone definition
export var name = "Zone"
export var polygon: PoolVector2Array = []  # Zone boundary
export var y_range = Vector2(0, 600)  # Y range within zone

# Scaling parameters for this zone
export var min_scale = 0.5
export var max_scale = 1.0
export(Curve) var scaling_curve = null

# Optional zone-specific overrides
export var override_speed_adjustment = false
export var speed_multiplier = 1.0
export var override_z_sorting = false
export var z_index_offset = 0
```

### 5. Enhanced Player Controller

Modifications to: `src/characters/player/player.gd`

```gdscript
extends Node2D

# Existing properties...
export var movement_speed = 200
export var acceleration = 800
export var deceleration = 1200

# Add perspective controller
onready var perspective_controller = $PerspectiveController

func _ready():
    # Existing initialization...
    
    # Add perspective controller if not present
    if not has_node("PerspectiveController"):
        var pc = preload("res://src/core/perspective/perspective_controller.gd").new()
        pc.name = "PerspectiveController"
        add_child(pc)
        perspective_controller = pc

func _handle_movement(delta):
    var direction = target_position - position
    var distance = direction.length()
    
    if distance < 5:
        position = target_position
        velocity = Vector2.ZERO
        is_moving = false
        return
    
    direction = direction.normalized()
    
    # Get perspective-adjusted speed
    var adjusted_speed = movement_speed
    if perspective_controller:
        adjusted_speed = perspective_controller.get_adjusted_speed(movement_speed)
    
    # Calculate desired velocity with adjusted speed
    var desired_velocity = direction * adjusted_speed
    
    # Rest of movement code remains the same...
```

### 6. DiegeticAudioSource (Component)

Located at: `src/core/perspective/diegetic_audio_source.gd`

```gdscript
extends AudioStreamPlayer2D
class_name DiegeticAudioSource

# Audio configuration
export var base_volume_db = 0.0
export var max_distance = 1000.0
export var min_distance = 50.0  # Full volume within this distance
export var falloff_curve: Curve  # Optional custom falloff
export var enable_panning = true
export var pan_strength = 1.0

# Perspective integration
export var consider_listener_scale = true
export var scale_influence = 0.5  # How much listener scale affects volume

# Internal state
var current_volume_db = 0.0
var current_pan = 0.0

func _ready():
    add_to_group("diegetic_audio")
    # Set audio to 2D mode for spatial audio
    if not stream:
        push_warning("DiegeticAudioSource: No audio stream assigned")

func update_for_listener(listener_pos: Vector2, listener_scale: float = 1.0):
    # Calculate distance
    var distance = global_position.distance_to(listener_pos)
    
    # Calculate base distance factor
    var distance_factor = 0.0
    if distance <= min_distance:
        distance_factor = 1.0
    elif distance >= max_distance:
        distance_factor = 0.0
    else:
        var range = max_distance - min_distance
        distance_factor = 1.0 - ((distance - min_distance) / range)
    
    # Apply custom curve if available
    if falloff_curve:
        distance_factor = falloff_curve.interpolate(distance_factor)
    
    # Apply perspective scaling influence
    if consider_listener_scale:
        var scale_factor = lerp(1.0, listener_scale, scale_influence)
        distance_factor *= scale_factor
    
    # Calculate volume
    current_volume_db = base_volume_db + (distance_factor - 1.0) * 80  # -80db when factor is 0
    volume_db = current_volume_db
    
    # Calculate stereo panning
    if enable_panning:
        var relative_x = global_position.x - listener_pos.x
        current_pan = clamp(relative_x / 500.0 * pan_strength, -1.0, 1.0)
        # Note: Godot 3.5 doesn't have built-in panning, would need audio bus setup
    
    # Update playing state based on distance
    if distance > max_distance * 1.5 and playing:
        stop()  # Save performance by stopping distant sounds
    elif distance <= max_distance * 1.5 and not playing and stream:
        play()

# Helper to visualize audio range in editor
func _draw():
    if Engine.editor_hint:
        draw_circle(Vector2.ZERO, min_distance, Color(0, 1, 0, 0.3))
        draw_circle(Vector2.ZERO, max_distance, Color(1, 1, 0, 0.2))
```

### 7. District Integration

Modifications to: `src/core/districts/base_district.gd`

```gdscript
extends Node2D
class_name BaseDistrict

# Existing properties...

# Perspective configuration
export(Resource) var perspective_config = null  # DistrictPerspectiveConfig

func _ready():
    # Existing initialization...
    
    # Set up perspective system for this district
    if perspective_config and perspective_config.enable_perspective:
        ScalingZoneManager.current_config = perspective_config
        print("Perspective scaling enabled for district: ", district_name)

func _exit_tree():
    # Clear perspective config when leaving district
    if ScalingZoneManager.current_config == perspective_config:
        ScalingZoneManager.current_config = null
```

## Integration with Existing Systems

### Coordinate System Integration

The perspective scaling system works seamlessly with the existing coordinate system:

1. **World Coordinates**: All scaling calculations use world coordinates
2. **View Mode Compatibility**: Scaling adjusts appropriately in both GAME_VIEW and WORLD_VIEW
3. **Coordinate Validation**: Leverages existing validation from CoordinateManager

```gdscript
# Example integration in perspective_controller.gd
func _process(delta):
    # Get validated world position
    var world_pos = CoordinateManager.validate_coordinates(target.global_position)
    
    # Calculate scaling based on validated position
    target_scale = ScalingZoneManager.get_scale_at_position(world_pos)
```

### Camera System Integration

The camera system remains unaffected but benefits from proper sprite scaling:

1. **Visual Consistency**: Sprites scale appropriately as camera pans
2. **Bounds Calculation**: Camera bounds remain independent of sprite scaling
3. **Debug Visualization**: Camera debug tools can show scaling zones

### Walkable Area Integration

Perspective zones can align with walkable areas for consistency:

1. **Zone Definition**: Use walkable area boundaries as scaling zone boundaries
2. **Movement Validation**: Walkable areas still control where player can move
3. **Visual Coherence**: Scaling zones match logical walking areas

## Implementation Phases

### Phase 0: POC Test Sprites (1 day)
Since we don't have proper character sprites yet, we need simple geometric sprites for testing:

1. **Create Simple Test Sprites**
   - Generate colored squares/rectangles as placeholder characters
   - Multiple sizes (32x32, 48x48, 64x64, 96x96) for testing scale visibility
   - Include directional indicators (arrows) for rotation testing
   - Use distinct colors for easy visual tracking

2. **POC Sprite Generation Script**
   ```bash
   #!/bin/bash
   # generate_poc_sprites.sh
   
   # Create simple geometric sprites for perspective testing
   mkdir -p src/assets/test_sprites
   
   # Function to create a test sprite
   create_test_sprite() {
       local size=$1
       local color=$2
       local name=$3
       
       # Create sprite with arrow indicator
       convert -size ${size}x${size} xc:transparent \
           -fill "$color" -draw "rectangle 5,5 $((size-5)),$((size-5))" \
           -fill white -pointsize $((size/4)) -gravity center \
           -annotate +0+0 "↑" \
           -strokewidth 2 -stroke black \
           "src/assets/test_sprites/${name}_${size}.png"
   }
   
   # Generate test sprites in different sizes
   create_test_sprite 32 "#FF6B6B" "player"    # Red
   create_test_sprite 48 "#4ECDC4" "npc1"      # Teal  
   create_test_sprite 64 "#45B7D1" "npc2"      # Blue
   create_test_sprite 96 "#F7DC6F" "large"     # Yellow
   
   echo "POC sprites created in src/assets/test_sprites/"
   ```

3. **Benefits of Simple POC Sprites**
   - No external dependencies (Midjourney, RunwayML)
   - Quick iteration on scaling behavior
   - Clear visual feedback for testing
   - Foundation ready for real sprites later

4. **POC Audio Test Setup**
   - Create simple looping audio sources for each test background
   - Use free/CC0 ambient sounds (machinery hum, crowd chatter, etc.)
   - Place 2-3 audio sources per test scene at different distances
   - Test volume scaling and stereo panning based on position

5. **Audio Test Script**
   ```bash
   #!/bin/bash
   # setup_poc_audio.sh
   
   # Create audio directory
   mkdir -p src/assets/test_audio
   
   echo "POC Audio Setup Instructions:"
   echo "1. Download CC0 ambient sounds from freesound.org:"
   echo "   - Industrial hum (for spaceport)"
   echo "   - Crowd chatter (for mall/trading floor)"
   echo "   - Computer beeps (for security/medical)"
   echo "   - Steam hiss (for engineering)"
   echo ""
   echo "2. Convert to OGG format:"
   echo "   ffmpeg -i input.wav -c:a libvorbis -q:a 4 output.ogg"
   echo ""
   echo "3. Place in src/assets/test_audio/"
   echo ""
   echo "4. Create DiegeticAudioSource nodes in test scenes"
   ```

### Phase 1: Core Infrastructure (2-3 days)
1. Create directory structure: `src/core/perspective/`
2. Implement ScalingZoneManager singleton
3. Create PerspectiveController component
4. Define DistrictPerspectiveConfig and ScalingZone resources
5. Write unit tests for scaling calculations

### Phase 2: Basic Sprite Scaling (1 day)
1. Implement simplified Y-position based scaling for POC
2. Add PerspectiveController to test sprites
3. Test with camera test backgrounds
4. Verify smooth scaling as sprites move

### Phase 3: Player Integration (1-2 days)
1. Add PerspectiveController to player prefab
2. Modify player movement to use adjusted speeds
3. Test player scaling in camera test scene
4. Validate z-index sorting works correctly

### Phase 4: District Configuration (2-3 days)
1. Create perspective configs for each test background
2. Define scaling zones for spaceport background
3. Integrate with BaseDistrict
4. Test district transitions with different configs

### Phase 5: Visual Polish (1-2 days)
1. Implement smooth scaling transitions
2. Add debug visualization for scaling zones
3. Fine-tune scaling curves for natural appearance
4. Optimize performance

### Phase 6: Extended Features (Optional, 2-3 days)
1. Audio volume scaling based on distance
2. Sprite detail level switching
3. Special effects for perspective transitions
4. Advanced movement behaviors (diagonal speed compensation)

## Testing Strategy

### Unit Tests
Located at: `src/unit_tests/perspective_scaling_test.gd`

1. **Scaling Calculation Tests**
   - Test scale values at various positions
   - Verify zone boundary transitions
   - Test curve interpolation

2. **Speed Adjustment Tests**
   - Verify movement speed scales correctly
   - Test diagonal movement compensation
   - Validate acceleration/deceleration

3. **Z-Index Sorting Tests**
   - Verify proper layering order
   - Test edge cases at same Y position
   - Validate with multiple entities

### Integration Tests
Located at: `src/test/perspective_integration_test.gd`

1. **Camera Integration Test**
   - Verify scaling works during camera movement
   - Test with different zoom levels
   - Validate in both view modes

2. **District Transition Test**
   - Test scaling config switches between districts
   - Verify smooth transitions
   - Check memory cleanup

3. **Performance Test**
   - Measure frame rate with many scaled entities
   - Profile scaling calculations
   - Test on minimum spec hardware

## Configuration Examples

### Spaceport Loading Dock Configuration

```gdscript
# res://src/districts/spaceport/spaceport_perspective_config.tres
[gd_resource type="Resource" script_class="DistrictPerspectiveConfig"]

[resource]
enable_perspective = true
default_scale = 1.0
min_scale = 0.6
max_scale = 1.0
use_zones = true
scaling_zones = [
    preload("res://src/districts/spaceport/zones/foreground_zone.tres"),
    preload("res://src/districts/spaceport/zones/midground_zone.tres"),
    preload("res://src/districts/spaceport/zones/background_zone.tres")
]
adjust_movement_speed = true
adjust_audio_volume = true
```

### Simple Y-Based Scaling (Fallback)

```gdscript
# For simpler scenes without complex perspective
[resource]
enable_perspective = true
use_zones = false
use_y_scaling = true
y_min = 200.0  # Top of walkable area
y_max = 800.0  # Bottom of walkable area
min_scale = 0.7
max_scale = 1.0
```

## Visual Design Guidelines

### Scale Ranges by Scene Type

1. **Deep Perspective (Spaceport, Tram Platform)**
   - Min scale: 0.5-0.6
   - Max scale: 1.0
   - Multiple distinct zones

2. **Moderate Perspective (Mall, Trading Floor)**
   - Min scale: 0.7-0.8
   - Max scale: 1.0
   - 2-3 scaling zones

3. **Shallow Perspective (Medical Bay, Security)**
   - Min scale: 0.85-0.9
   - Max scale: 1.0
   - Simple Y-based scaling

### Movement Speed Guidelines

- Speed should scale proportionally with visual size
- Diagonal movement may need compensation to feel natural
- Consider acceleration/deceleration scaling for realism

## Performance Considerations

1. **Caching**: Cache scale calculations for stationary objects
2. **LOD System**: Switch sprite detail based on scale
3. **Update Frequency**: Scale updates can run at lower frequency than movement
4. **Batch Processing**: Group scaling calculations for multiple entities

## Debug Tools

### Scaling Zone Visualizer

```gdscript
# src/core/debug/scaling_zone_visualizer.gd
extends Node2D

func visualize_zones(config: DistrictPerspectiveConfig):
    for zone in config.scaling_zones:
        var polygon = Polygon2D.new()
        polygon.polygon = zone.polygon
        polygon.color = Color(1, 1, 0, 0.2)
        add_child(polygon)
        
        # Add scale indicators
        _add_scale_labels(zone)
```

### Real-time Scaling Monitor

```gdscript
# Shows current scale, z-index, and speed multiplier for selected entity
extends Control

func _process(delta):
    if target:
        $ScaleLabel.text = "Scale: %.2f" % target.scale.x
        $ZIndexLabel.text = "Z-Index: %d" % target.z_index
        $SpeedLabel.text = "Speed: %.2f" % perspective_controller.get_adjusted_speed(1.0)
```

## Conclusion

This sprite perspective scaling system provides a comprehensive solution for creating believable depth in SCUMM-style environments. By following the architectural principles of A Silent Refraction and prioritizing visual correctness, the system enhances immersion while maintaining code quality and performance.

The modular design allows for easy extension and modification, while the resource-based configuration enables rapid iteration on perspective settings without code changes. Integration with existing systems is seamless, and the phased implementation approach ensures steady progress with testable milestones.