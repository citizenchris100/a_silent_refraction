# Foreground Occlusion Full Implementation Design Document

**Status: 📋 DESIGN**  
**Target: Iteration 10**  
**Created: May 23, 2025**

## Executive Summary

This document outlines the complete foreground occlusion system that builds upon the MVP from Iteration 3. The full implementation adds polygon-based occlusion zones, automated asset extraction, animated foreground elements, and sophisticated per-perspective rendering rules to create a rich, layered visual experience.

## Design Goals

### Core Objectives
1. **Complex Depth**: Support arbitrary occlusion shapes beyond simple Y-thresholds
2. **Automated Pipeline**: Tools for extracting foreground elements from backgrounds
3. **Dynamic Elements**: Support for animated foreground objects
4. **Perspective Integration**: Different occlusion rules per perspective type
5. **Performance**: Optimized for complex scenes with many occlusion zones
6. **Editor Tools**: Visual editing of occlusion zones and properties

### Full Implementation Features
- Polygon-based occlusion zones with arbitrary shapes
- Multi-layer foreground system (near, mid, far)
- Animated foreground elements with state machines
- Automated foreground extraction tools
- Per-perspective occlusion configurations
- Visual occlusion zone editor
- Advanced performance optimizations
- Comprehensive debug visualization

## Technical Architecture

### System Overview

```
AdvancedForegroundOcclusionSystem
├── OcclusionZoneManager (Enhanced Singleton)
│   ├── Spatial indexing for zones
│   ├── Multi-layer management
│   └── Perspective-aware rules
├── ForegroundLayerSystem
│   ├── NearForeground (Node2D)
│   ├── MidForeground (Node2D)
│   └── FarForeground (Node2D)
├── OcclusionZone (Resource)
│   ├── Polygon definition
│   ├── Layer assignment
│   ├── Perspective rules
│   └── Animation state
├── ForegroundElement (Scene)
│   ├── Static or animated sprite
│   ├── Occlusion properties
│   └── Interactive components
└── Tools
    ├── OcclusionZoneEditor
    ├── ForegroundExtractor
    └── OcclusionDebugger
```

### Core Components

#### OcclusionZone Resource
```gdscript
extends Resource
class_name OcclusionZone

export var zone_id: String = ""
export var polygon: PoolVector2Array = PoolVector2Array()
export var layer: int = 0  # 0=near, 1=mid, 2=far
export var base_z_index: int = 100
export var perspective_rules: Dictionary = {}  # perspective_type -> rules

# Advanced properties
export var soft_edges: bool = false
export var edge_fade_distance: float = 10.0
export var height_offset: float = 0.0  # For pseudo-3D effect
export var occlusion_mode: String = "full"  # full, partial, gradient

func get_occlusion_strength(position: Vector2) -> float:
    if not Geometry.is_point_in_polygon(position, polygon):
        return 0.0
    
    if soft_edges:
        var distance = _distance_to_edge(position)
        return smoothstep(0, edge_fade_distance, distance)
    
    return 1.0

func _distance_to_edge(point: Vector2) -> float:
    # Calculate minimum distance to polygon edge
    var min_dist = INF
    for i in range(polygon.size()):
        var p1 = polygon[i]
        var p2 = polygon[(i + 1) % polygon.size()]
        var dist = Geometry.get_closest_point_to_segment_2d(point, p1, p2).distance_to(point)
        min_dist = min(min_dist, dist)
    return min_dist
```

#### Advanced OcclusionZoneManager
```gdscript
extends Node

# Spatial indexing for performance
var zone_quadtree: QuadTree
var active_zones: Array = []
var zone_cache: Dictionary = {}

# Multi-layer management
var foreground_layers: Dictionary = {
    "near": {"node": null, "z_base": 200},
    "mid": {"node": null, "z_base": 150},
    "far": {"node": null, "z_base": 100}
}

# Perspective-aware settings
var current_perspective: String = "side_scrolling"
var perspective_configs: Dictionary = {}

func _ready():
    zone_quadtree = QuadTree.new(Rect2(0, 0, 10000, 10000))
    _load_perspective_configs()

func register_zone(zone: OcclusionZone, sprite: Node2D):
    var bounds = _calculate_polygon_bounds(zone.polygon)
    zone_quadtree.insert(bounds, {
        "zone": zone,
        "sprite": sprite,
        "bounds": bounds
    })

func update_player_occlusion_advanced(player_pos: Vector2):
    # Query nearby zones using quadtree
    var search_rect = Rect2(player_pos - Vector2(200, 200), Vector2(400, 400))
    var nearby_zones = zone_quadtree.query(search_rect)
    
    # Process each zone
    for zone_data in nearby_zones:
        var zone = zone_data.zone
        var sprite = zone_data.sprite
        
        # Check perspective-specific rules
        var rules = zone.perspective_rules.get(current_perspective, {})
        if rules.get("disabled", false):
            continue
        
        # Calculate occlusion
        var occlusion_strength = zone.get_occlusion_strength(player_pos)
        if occlusion_strength > 0:
            _apply_occlusion(sprite, zone, occlusion_strength, rules)
        else:
            _remove_occlusion(sprite, zone)

func _apply_occlusion(sprite: Node2D, zone: OcclusionZone, strength: float, rules: Dictionary):
    var target_z = zone.base_z_index + foreground_layers[_get_layer_name(zone.layer)].z_base
    
    # Apply perspective-specific modifications
    if "z_offset" in rules:
        target_z += rules.z_offset
    
    # Smooth transitions for soft edges
    if zone.soft_edges and strength < 1.0:
        sprite.modulate.a = lerp(1.0, rules.get("fade_alpha", 0.8), strength)
    
    sprite.z_index = target_z
```

#### ForegroundElement Scene Structure
```
ForegroundElement (Node2D)
├── AnimatedSprite (for animated elements)
├── Sprite (for static elements)
├── OcclusionProperties (Node)
├── InteractionArea (Area2D) [optional]
└── AnimationController (Node) [optional]
```

### Asset Pipeline

#### Automated Foreground Extraction Tool
```gdscript
tool
extends EditorScript

func _run():
    var dialog = preload("res://src/tools/ForegroundExtractorDialog.tscn").instance()
    get_editor_interface().get_base_control().add_child(dialog)
    dialog.popup_centered(Vector2(800, 600))

class ForegroundExtractorDialog extends WindowDialog:
    var source_image: Image
    var selection_polygon: PoolVector2Array
    var preview_sprite: Sprite
    
    func extract_foreground():
        # Create mask from polygon
        var mask = Image.new()
        mask.create(source_image.get_width(), source_image.get_height(), false, Image.FORMAT_RGBA8)
        
        # Fill polygon area
        for y in range(mask.get_height()):
            for x in range(mask.get_width()):
                if Geometry.is_point_in_polygon(Vector2(x, y), selection_polygon):
                    mask.set_pixel(x, y, Color.white)
                else:
                    mask.set_pixel(x, y, Color.transparent)
        
        # Apply mask to source
        var result = Image.new()
        result.create(source_image.get_width(), source_image.get_height(), false, Image.FORMAT_RGBA8)
        
        for y in range(source_image.get_height()):
            for x in range(source_image.get_width()):
                var mask_pixel = mask.get_pixel(x, y)
                if mask_pixel.a > 0:
                    result.set_pixel(x, y, source_image.get_pixel(x, y))
        
        return result
```

### Configuration System

#### Enhanced District Configuration
```json
{
  "district": "trading_floor",
  "occlusion_config": {
    "perspective_overrides": {
      "isometric": {
        "z_offset_modifier": 1.5,
        "enable_height_sorting": true
      },
      "side_scrolling": {
        "z_offset_modifier": 1.0,
        "enable_height_sorting": false
      }
    },
    "layers": {
      "near": {
        "z_base": 200,
        "fade_enabled": true,
        "fade_distance": 20
      },
      "mid": {
        "z_base": 150,
        "fade_enabled": false
      },
      "far": {
        "z_base": 100,
        "fade_enabled": false
      }
    }
  },
  "occlusion_zones": [
    {
      "id": "reception_desk",
      "resource_path": "res://src/data/occlusion_zones/trading_floor/reception_desk.tres",
      "sprite_elements": [
        {
          "path": "res://src/assets/foreground/trading_floor/reception_desk_front.png",
          "position": {"x": 300, "y": 200},
          "layer": "near",
          "animated": false
        }
      ]
    },
    {
      "id": "holographic_display",
      "resource_path": "res://src/data/occlusion_zones/trading_floor/holo_display.tres",
      "sprite_elements": [
        {
          "scene_path": "res://src/assets/foreground/trading_floor/HolographicDisplay.tscn",
          "position": {"x": 500, "y": 300},
          "layer": "mid",
          "animated": true,
          "animation_config": {
            "default_animation": "idle",
            "animations": {
              "idle": {"speed": 0.5},
              "alert": {"speed": 1.0}
            }
          }
        }
      ]
    }
  ]
}
```

### Editor Tools

#### Visual Occlusion Zone Editor
```gdscript
tool
extends EditorPlugin

var dock

func _enter_tree():
    dock = preload("res://src/tools/OcclusionZoneEditor.tscn").instance()
    add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

func _exit_tree():
    remove_control_from_docks(dock)
    dock.free()

class OcclusionZoneEditor extends Control:
    var edit_mode: String = "polygon"  # polygon, properties, test
    var current_zone: OcclusionZone
    var preview_overlay: Node2D
    
    func _ready():
        # Create preview overlay for visualizing zones
        preview_overlay = Node2D.new()
        preview_overlay.name = "OcclusionPreview"
        
    func start_polygon_edit():
        # Enable click-to-add-point mode
        set_process_unhandled_input(true)
        
    func visualize_zone(zone: OcclusionZone):
        # Draw polygon outline
        preview_overlay.update()
        
    func test_occlusion():
        # Simulate player movement through zone
        var test_path = [Vector2(100, 100), Vector2(500, 500)]
        # Animate test character along path
```

### Performance Optimizations

#### Spatial Indexing (QuadTree)
```gdscript
class QuadTree:
    var boundary: Rect2
    var capacity: int = 4
    var points: Array = []
    var divided: bool = false
    
    var northeast: QuadTree
    var northwest: QuadTree
    var southeast: QuadTree
    var southwest: QuadTree
    
    func insert(rect: Rect2, data):
        if not boundary.intersects(rect):
            return false
        
        if points.size() < capacity and not divided:
            points.append({"rect": rect, "data": data})
            return true
        
        if not divided:
            subdivide()
        
        # Insert into children
        return northeast.insert(rect, data) or northwest.insert(rect, data) or \
               southeast.insert(rect, data) or southwest.insert(rect, data)
    
    func query(search_rect: Rect2) -> Array:
        var found = []
        
        if not boundary.intersects(search_rect):
            return found
        
        for point in points:
            if search_rect.intersects(point.rect):
                found.append(point.data)
        
        if divided:
            found.append_array(northeast.query(search_rect))
            found.append_array(northwest.query(search_rect))
            found.append_array(southeast.query(search_rect))
            found.append_array(southwest.query(search_rect))
        
        return found
```

#### Update Throttling
```gdscript
var update_timer: float = 0.0
var update_interval: float = 0.033  # 30 FPS for occlusion updates

func _process(delta):
    update_timer += delta
    if update_timer >= update_interval:
        update_timer = 0.0
        update_player_occlusion_advanced(player.global_position)
```

### Debug Visualization

#### Comprehensive Debug Overlay
```gdscript
extends Node2D
class_name OcclusionDebugOverlay

var show_zones: bool = true
var show_player_position: bool = true
var show_z_indices: bool = true
var show_performance: bool = true

func _draw():
    if not visible:
        return
    
    if show_zones:
        for zone_data in OcclusionZoneManager.get_active_zones():
            # Draw polygon outline
            draw_polygon(zone_data.zone.polygon, Color(1, 0, 0, 0.3))
            draw_polyline(zone_data.zone.polygon, Color.red, 2.0)
            
            # Draw layer info
            var center = _polygon_center(zone_data.zone.polygon)
            draw_string(default_font, center, "L:%d Z:%d" % [zone_data.zone.layer, zone_data.sprite.z_index])
    
    if show_player_position:
        var player_pos = OcclusionZoneManager.player_node.global_position
        draw_circle(player_pos, 10, Color.green)
        draw_string(default_font, player_pos + Vector2(15, 0), "Y: %d" % player_pos.y)
    
    if show_performance:
        var stats = OcclusionZoneManager.get_performance_stats()
        var text = "Zones: %d\nUpdate: %.2fms" % [stats.active_zones, stats.last_update_ms]
        draw_string(default_font, Vector2(10, 30), text)
```

## Implementation Phases

### Phase 1: Enhanced Core System (Tasks 1-4)
- Implement polygon-based OcclusionZone resource
- Create advanced OcclusionZoneManager with spatial indexing
- Build multi-layer foreground system
- Add perspective-aware rendering rules

### Phase 2: Asset Pipeline and Tools (Tasks 5-8)
- Create automated foreground extraction tool
- Build batch processing scripts
- Implement asset validation system
- Create foreground element templates

### Phase 3: Editor Integration (Tasks 9-12)
- Develop visual occlusion zone editor
- Create zone testing and preview tools
- Build property inspectors
- Implement zone library system

### Phase 4: Animation Support (Tasks 13-16)
- Create animated foreground element system
- Build state machine for foreground animations
- Implement trigger system for animations
- Add particle effect support

### Phase 5: Performance Optimization (Tasks 17-20)
- Implement QuadTree spatial indexing
- Add LOD system for distant elements
- Create update throttling system
- Build performance profiler

### Phase 6: Integration and Polish (Tasks 21-24)
- Complete integration with all perspective types
- Add smooth transitions and effects
- Create comprehensive documentation
- Build example implementations

## Testing Strategy

### Automated Tests
- Unit tests for OcclusionZone calculations
- Integration tests with perspective system
- Performance benchmarks
- Visual regression tests

### Manual Testing
- Complex navigation paths through multiple zones
- Perspective switching with active occlusion
- Performance testing with 50+ zones
- Edge case validation

## Migration from MVP

### Upgrade Path
1. Convert Y-threshold elements to polygon zones
2. Migrate configuration format
3. Update district files
4. Re-export foreground elements with new tools

### Backwards Compatibility
- Support legacy Y-threshold mode
- Automatic conversion utilities
- Gradual migration tools

## Performance Targets

- 60 FPS with 50+ occlusion zones
- < 1ms update time per frame
- < 50MB memory for occlusion data
- Instant zone switching

## Success Criteria

The full implementation succeeds when:
1. Complex occlusion shapes work correctly
2. Performance meets targets in all scenarios
3. Editor tools are intuitive and efficient
4. System handles all perspective types
5. Animated elements integrate smoothly
6. Debug tools provide clear visualization
7. Asset pipeline is fully automated

## Future Possibilities

- Dynamic occlusion based on game state
- Procedural foreground generation
- Advanced lighting integration
- Multiplayer occlusion synchronization
- VR/AR compatibility

## Conclusion

The full foreground occlusion system transforms the MVP's simple Y-sorting into a comprehensive visual depth system. With polygon-based zones, automated tools, and sophisticated rendering rules, this system will provide the visual richness needed for an immersive adventure game experience.