# Foreground Occlusion MVP Design Document

**Status: 📋 DESIGN**  
**Target: Iteration 3**  
**Created: May 23, 2025**

## Executive Summary

This document outlines the MVP implementation of a foreground occlusion system that creates visual depth by rendering certain environmental elements in front of the player character. This system integrates with the existing sprite perspective scaling system to enhance the illusion of depth in our 2D game world.

## Design Goals

### Core Objectives
1. **Visual Depth**: Create convincing depth by having characters pass behind foreground objects
2. **Simple Integration**: Work seamlessly with existing coordinate and perspective systems
3. **Performance**: Minimal impact on rendering performance
4. **Flexibility**: Easy to extend for full implementation later

### MVP Scope Limitations
- Y-position based sorting only (no complex polygons)
- Static foreground elements only (no animation)
- Single foreground layer per district
- Manual foreground sprite creation (no automated extraction)
- Basic configuration through existing district JSON

## Technical Architecture

### System Components

```
ForegroundOcclusionSystem
├── ForegroundLayer (Node2D)
│   └── Individual foreground sprites
├── OcclusionManager (Singleton)
│   ├── Y-threshold management
│   └── Player tracking
└── Integration Points
    ├── CoordinateManager (for position tracking)
    ├── PerspectiveController (shared Y-position logic)
    └── District configuration (JSON)
```

### Core Classes

#### ForegroundOcclusionManager (Singleton)
```gdscript
extends Node

# Track player for occlusion updates
var player_node: Node2D
var current_district_config: Dictionary = {}

# Foreground elements registry
var foreground_elements: Dictionary = {}  # element_id -> sprite_data

func register_foreground_element(element_id: String, sprite: Node2D, occlusion_y: float):
    foreground_elements[element_id] = {
        "sprite": sprite,
        "occlusion_y": occlusion_y,
        "original_z_index": sprite.z_index
    }

func update_player_occlusion():
    if not player_node:
        return
    
    var player_y = player_node.global_position.y
    
    for element_data in foreground_elements.values():
        var sprite = element_data.sprite
        var threshold_y = element_data.occlusion_y
        
        # Simple rule: if player is above threshold, they render behind
        if player_y < threshold_y:
            sprite.z_index = 100  # Render in front
        else:
            sprite.z_index = element_data.original_z_index  # Normal order
```

#### District Integration
Extends existing base_district.gd to load foreground elements:

```gdscript
# In base_district.gd
func load_foreground_elements():
    if not animated_elements_config:
        return
        
    var config = load_json_config()
    if "foreground_elements" in config:
        var foreground_layer = Node2D.new()
        foreground_layer.name = "ForegroundLayer"
        add_child(foreground_layer)
        
        for element in config.foreground_elements:
            var sprite = Sprite.new()
            sprite.texture = load(element.sprite_path)
            sprite.position = Vector2(element.position.x, element.position.y)
            sprite.centered = false
            foreground_layer.add_child(sprite)
            
            # Register with occlusion manager
            var occlusion_y = element.get("occlusion_y", element.position.y + sprite.texture.get_height())
            ForegroundOcclusionManager.register_foreground_element(
                element.name, 
                sprite, 
                occlusion_y
            )
```

### Configuration Format

Extend existing district JSON configuration:

```json
{
  "district": "trading_floor",
  "background": "res://...",
  "animated_elements": [...],
  "foreground_elements": [
    {
      "name": "desk_cluster_1",
      "sprite_path": "res://src/assets/backgrounds/trading_floor/foreground/desk_cluster_1.png",
      "position": {"x": 200, "y": 250},
      "occlusion_y": 300
    },
    {
      "name": "desk_cluster_2",
      "sprite_path": "res://src/assets/backgrounds/trading_floor/foreground/desk_cluster_2.png",
      "position": {"x": 400, "y": 350},
      "occlusion_y": 400
    }
  ]
}
```

## Asset Pipeline

### Foreground Sprite Creation Process

1. **Source Background Analysis**
   - Identify elements that should occlude the player
   - Mark Y-thresholds for occlusion boundaries

2. **Sprite Extraction**
   ```bash
   # Extract foreground elements using ImageMagick
   convert background.png \
     -crop [width]x[height]+[x]+[y] \
     -background transparent \
     foreground_element.png
   ```

3. **Processing Pipeline**
   - Apply same 32-bit styling as backgrounds
   - Ensure transparent backgrounds
   - Optimize file size

4. **Integration**
   - Place in district's foreground/ directory
   - Add to district configuration JSON
   - Test occlusion behavior

## Implementation Plan

### Phase 1: Core System (Tasks 37-38)
- Create ForegroundOcclusionManager singleton
- Implement basic Y-position based sorting
- Add _process loop for continuous updates

### Phase 2: District Integration (Task 39)
- Extend base_district.gd with foreground loading
- Update district JSON schema
- Create helper methods for configuration

### Phase 3: Asset Creation (Task 40)
- Create test foreground sprites for camera test backgrounds
- Document extraction process
- Build simple tools for threshold calculation

### Phase 4: Testing and Polish (Task 41)
- Create dedicated test scene
- Verify integration with perspective scaling
- Performance profiling
- Debug visualization (optional)

## Performance Considerations

### Optimization Strategies
1. **Update Frequency**: Only update when player Y changes significantly
2. **Element Culling**: Don't process off-screen elements
3. **Batch Updates**: Update all elements in single pass
4. **Simple Calculations**: Y-comparison only, no complex math

### Expected Performance
- Target: < 0.1ms per frame with 10-20 foreground elements
- Memory: Minimal (sprite textures already loaded)
- No additional draw calls (just Z-order changes)

## Integration Points

### Coordinate System
- Use existing coordinate transformations
- Respect viewport and camera positions

### Perspective Scaling
- Share Y-position logic with scaling system
- Ensure consistent depth perception

### Walkable Areas
- Foreground elements don't affect navigation
- Visual-only system

## Save/Load Considerations

Occlusion zones are largely static configuration, but certain dynamic states need persistence. Following `docs/design/modular_serialization_architecture.md`, the foreground occlusion system tracks minimal state:

### Serializable State

The ForegroundSerializer (when needed) will handle:
- **Player Occlusion State**: Current occlusion zone the player is in
- **Dynamic Z-indices**: Any runtime-modified Z-index values
- **Disabled Elements**: Foreground elements temporarily hidden
- **Debug Settings**: Whether debug visualization is enabled

### Implementation Note

```gdscript
# src/core/serializers/foreground_serializer.gd (future)
extends BaseSerializer

func serialize() -> Dictionary:
    var dynamic_state = {}
    
    # Only save elements with non-default state
    for element_id in ForegroundOcclusionManager.foreground_elements:
        var element = ForegroundOcclusionManager.foreground_elements[element_id]
        if element.sprite.z_index != element.original_z_index:
            dynamic_state[element_id] = {
                "z_index": element.sprite.z_index,
                "visible": element.sprite.visible
            }
    
    return {
        "player_occlusion_zone": ForegroundOcclusionManager.current_player_zone,
        "dynamic_elements": dynamic_state,
        "debug_enabled": ForegroundOcclusionManager.debug_mode
    }
```

Most foreground data comes from district configuration and doesn't need serialization. Only runtime state that affects visual consistency is saved.

## Testing Strategy

### Test Scenarios
1. **Basic Occlusion**: Player walks behind single object
2. **Multiple Objects**: Several foreground elements at different depths
3. **Edge Cases**: Player at exact threshold Y
4. **Performance**: Many foreground elements active
5. **District Transitions**: Foreground elements load/unload correctly

### Debug Features
- Visual threshold lines (toggle in debug mode)
- Z-index overlay display
- Performance metrics in debug panel

## Future Expansion Paths

This MVP provides foundation for:
- Polygon-based occlusion zones
- Animated foreground elements
- Multiple occlusion layers
- Automated foreground extraction tools
- Per-perspective occlusion rules
- Dynamic foreground loading

## Success Criteria

The MVP is successful when:
1. Player character correctly renders behind foreground objects
2. Transitions feel natural and smooth
3. No performance impact on target hardware
4. Easy to add new foreground elements
5. System integrates cleanly with existing code

## Risk Mitigation

### Potential Issues and Solutions
1. **Z-fighting**: Use distinct Z-index ranges
2. **Performance**: Implement update throttling
3. **Visual Glitches**: Add transition smoothing
4. **Configuration Errors**: Validate JSON on load

## Conclusion

This MVP provides a simple but effective foreground occlusion system that enhances visual depth with minimal complexity. By focusing on Y-position based sorting and leveraging existing systems, we can deliver meaningful visual improvements while maintaining performance and code quality.