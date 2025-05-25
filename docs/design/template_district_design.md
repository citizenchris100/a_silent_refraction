# Template District Design Document

## Overview

The Template District serves as the canonical implementation pattern for all game locations in A Silent Refraction. This document defines both MVP and Full implementations, ensuring consistent architecture based on the base_district system while providing clear patterns for content creation.

## Design Philosophy

- **Architecture Compliance**: Strictly follows base_district.gd requirements
- **Visual Correctness**: No grey bars, proper camera scaling
- **Reusability**: Patterns that work for all 7 distinct districts
- **Performance**: Optimized for smooth camera scrolling and navigation
- **Modularity**: Clear separation between structure and content

## MVP Implementation (Phase 1)

### Core Requirements

The MVP Template District demonstrates essential functionality for the Intro Quest:

1. **Base District Compliance**: Properly extends base_district.gd
2. **Single Room**: One functional play area
3. **Basic Navigation**: Simple walkable area with clear boundaries
4. **Interactive Elements**: 3-5 interactive objects
5. **NPC Placement**: Support for 2-3 NPCs
6. **Camera Functionality**: Proper scrolling without grey bars

### Technical Specification

```gdscript
# template_district_mvp.gd
extends "res://src/core/districts/base_district.gd"

# District identification
export var district_id: String = "template_district_mvp"

# Visual theme
export var color_theme: String = "industrial"  # Affects color palette subset

func _ready():
    # REQUIRED: Set district properties
    district_name = "Template District"
    district_description = "A fully functional template district"
    
    # Camera configuration
    use_scrolling_camera = true
    camera_follow_smoothing = 5.0
    camera_edge_margin = Vector2(150, 100)
    initial_camera_view = "center"  # For MVP, always start centered
    
    # Create required scene structure
    _create_background()
    _create_walkable_areas()
    _create_interactive_objects()
    _create_npc_spawn_points()
    
    # CRITICAL: Call parent _ready() after setup
    ._ready()
    
    # Set up player at designated spawn point
    setup_player_and_controller(_get_player_spawn())

func _create_background():
    # REQUIRED: Background must be direct child named "Background"
    var background = Sprite.new()
    background.name = "Background"
    background.texture = preload("res://src/assets/backgrounds/template_district_mvp.png")
    background.centered = false
    background.position = Vector2.ZERO
    add_child(background)
    
    # REQUIRED: Set background size for camera calculations
    background_size = background.texture.get_size()

func _create_walkable_areas():
    # REQUIRED: WalkableAreas container
    var walkable_container = Node2D.new()
    walkable_container.name = "WalkableAreas"
    add_child(walkable_container)
    
    # Main walkable area (simple rectangle for MVP)
    var main_area = Polygon2D.new()
    main_area.name = "MainArea"
    main_area.polygon = PoolVector2Array([
        Vector2(200, 500),
        Vector2(1720, 500),
        Vector2(1720, 700),
        Vector2(200, 700)
    ])
    main_area.color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
    walkable_container.add_child(main_area)

func _create_interactive_objects():
    # Objects container
    var objects_container = Node2D.new()
    objects_container.name = "Objects"
    add_child(objects_container)
    
    # Example: Exit door
    var exit_door = InteractiveObject.new()
    exit_door.name = "ExitDoor"
    exit_door.position = Vector2(1800, 600)
    exit_door.object_name = "Exit Door"
    exit_door.examine_text = "A door leading to the tram station."
    exit_door.add_to_group("interactive_object")
    objects_container.add_child(exit_door)
    
    # Example: Information terminal
    var terminal = InteractiveObject.new()
    terminal.name = "InfoTerminal"
    terminal.position = Vector2(960, 550)
    terminal.object_name = "Information Terminal"
    terminal.examine_text = "A public information terminal."
    terminal.add_to_group("interactive_object")
    objects_container.add_child(terminal)
    
    # Example: Bench
    var bench = InteractiveObject.new()
    bench.name = "Bench"
    bench.position = Vector2(500, 600)
    bench.object_name = "Bench"
    bench.examine_text = "A simple bench for waiting."
    bench.add_to_group("interactive_object")
    objects_container.add_child(bench)

func _create_npc_spawn_points():
    # NPCs container
    var npcs_container = Node2D.new()
    npcs_container.name = "NPCs"
    add_child(npcs_container)
    
    # Spawn point markers (NPCs loaded separately)
    var spawn_points = Node2D.new()
    spawn_points.name = "SpawnPoints"
    npcs_container.add_child(spawn_points)
    
    # Define spawn positions
    _add_spawn_point(spawn_points, "npc_spawn_1", Vector2(400, 600))
    _add_spawn_point(spawn_points, "npc_spawn_2", Vector2(1200, 600))

func _add_spawn_point(parent: Node2D, point_name: String, pos: Vector2):
    var marker = Position2D.new()
    marker.name = point_name
    marker.position = pos
    parent.add_child(marker)

func _get_player_spawn() -> Vector2:
    # Default spawn position for this district
    return Vector2(300, 600)

# Handle district-specific interactions
func handle_exit_interaction(exit_name: String):
    match exit_name:
        "ExitDoor":
            # Transition to tram station
            emit_signal("district_exit_triggered", "tram_station", "from_template")
        _:
            push_error("Unknown exit: " + exit_name)
```

### MVP Data Structure

```json
{
    "district_id": "template_district_mvp",
    "display_name": "Template District",
    "description": "A simple functional district",
    "connections": {
        "tram_station": {
            "exit_id": "ExitDoor",
            "entry_point": "default"
        }
    },
    "spawn_points": {
        "default": {"x": 300, "y": 600},
        "from_tram": {"x": 1700, "y": 600}
    },
    "npcs": [
        {
            "npc_id": "template_greeter",
            "spawn_point": "npc_spawn_1",
            "schedule": "always_present"
        }
    ],
    "objects": [
        {
            "object_id": "exit_door",
            "type": "door",
            "interaction": "district_transition"
        },
        {
            "object_id": "info_terminal",
            "type": "terminal",
            "interaction": "examine_only"
        }
    ]
}
```

### MVP Visual Requirements

```gdscript
# Background image specifications
const MVP_BACKGROUND_SPECS = {
    "min_width": 1920,
    "min_height": 1080,
    "max_width": 2560,  # For simple scrolling
    "color_limit": 16,  # Canonical palette only
    "format": "png"
}

# Color theme subsets (from canonical palette)
const COLOR_THEMES = {
    "industrial": ["#3c3537", "#494543", "#58504b", "#5e6259"],
    "commercial": ["#726b73", "#907577", "#b18da1", "#c2a783"],
    "medical": ["#7b8e95", "#cec6c0", "#e4d2c6", "#fbede4"],
    "residential": ["#5e6259", "#726b73", "#7b8e95", "#cec6c0"]
}
```

## Full Implementation (Phase 2)

### Extended Requirements

The Full Template District expands to demonstrate all possible district features:

1. **Multiple Sub-locations**: Main area plus 3-5 connected rooms
2. **Complex Navigation**: Multi-polygon walkable areas with obstacles
3. **Dynamic Elements**: Time-based changes, animated objects
4. **Advanced Audio**: Multiple diegetic sound sources
5. **Environmental Storytelling**: Visual clues about assimilation
6. **Performance Optimization**: LOD system for large districts

### Technical Specification

```gdscript
# template_district_full.gd
extends "res://src/core/districts/base_district.gd"

# District properties
export var district_id: String = "template_district_full"
export var district_tier: String = "major"  # major, minor, restricted

# Sub-location management
var sub_locations: Dictionary = {}
var current_sub_location: String = "main"

# Dynamic elements
var animated_objects: Array = []
var ambient_sounds: Array = []
var time_based_elements: Dictionary = {}

# Performance
export var use_lod_system: bool = true
export var lod_distances: Dictionary = {
    "high": 500,
    "medium": 1000,
    "low": 1500
}

func _ready():
    # Set up district
    district_name = "Template District Full"
    district_description = "A complete multi-room district with all features"
    
    # Advanced camera configuration
    use_scrolling_camera = true
    camera_follow_smoothing = 8.0
    camera_edge_margin = Vector2(200, 150)
    initial_camera_view = "dynamic"  # Calculates based on entry point
    
    # Create district structure
    _create_multi_room_layout()
    _create_complex_walkable_areas()
    _create_advanced_objects()
    _create_ambient_elements()
    _setup_time_based_changes()
    
    # Initialize sub-systems
    _initialize_lod_system()
    _initialize_audio_sources()
    
    # Parent ready
    ._ready()
    
    # Dynamic player spawn
    var spawn_pos = _calculate_spawn_position()
    setup_player_and_controller(spawn_pos)

func _create_multi_room_layout():
    # Main area background
    var main_bg = Sprite.new()
    main_bg.name = "Background"  # Required name
    main_bg.texture = preload("res://src/assets/backgrounds/template_main.png")
    main_bg.centered = false
    add_child(main_bg)
    
    background_size = main_bg.texture.get_size()
    
    # Sub-locations (loaded dynamically)
    sub_locations = {
        "main": {
            "background": main_bg,
            "bounds": Rect2(0, 0, 2560, 1080),
            "connections": ["office", "storage", "elevator"]
        },
        "office": {
            "background_path": "res://src/assets/backgrounds/template_office.png",
            "bounds": Rect2(2560, 0, 1920, 1080),
            "connections": ["main"]
        },
        "storage": {
            "background_path": "res://src/assets/backgrounds/template_storage.png",
            "bounds": Rect2(0, 1080, 1920, 1080),
            "connections": ["main", "maintenance"]
        }
    }

func _create_complex_walkable_areas():
    var walkable_container = Node2D.new()
    walkable_container.name = "WalkableAreas"
    add_child(walkable_container)
    
    # Main area with obstacles
    var main_area = Polygon2D.new()
    main_area.name = "MainFloor"
    main_area.polygon = _generate_complex_polygon("main_floor")
    main_area.color = Color(1, 1, 0, 0.2)
    walkable_container.add_child(main_area)
    
    # Elevated platform
    var platform = Polygon2D.new()
    platform.name = "Platform"
    platform.polygon = PoolVector2Array([
        Vector2(800, 400),
        Vector2(1200, 400),
        Vector2(1200, 500),
        Vector2(800, 500)
    ])
    platform.color = Color(1, 0.8, 0, 0.2)
    walkable_container.add_child(platform)
    
    # Connect areas with stairs
    var stairs = Polygon2D.new()
    stairs.name = "Stairs"
    stairs.polygon = PoolVector2Array([
        Vector2(750, 500),
        Vector2(850, 400),
        Vector2(850, 500),
        Vector2(750, 600)
    ])
    stairs.color = Color(0.8, 0.8, 0, 0.2)
    walkable_container.add_child(stairs)

func _create_advanced_objects():
    var objects_container = Node2D.new()
    objects_container.name = "Objects"
    add_child(objects_container)
    
    # Animated machinery
    var machine = AnimatedObject.new()
    machine.name = "IndustrialMachine"
    machine.position = Vector2(1500, 500)
    machine.animation_name = "running"
    machine.object_name = "Industrial Processor"
    machine.states = {
        "running": {"examine": "The machine hums with activity."},
        "broken": {"examine": "The machine sputters and sparks."},
        "assimilated": {"examine": "Strange goo drips from the machine."}
    }
    animated_objects.append(machine)
    objects_container.add_child(machine)
    
    # Interactive computer terminal
    var computer = InteractiveComputer.new()
    computer.name = "MainTerminal"
    computer.position = Vector2(600, 450)
    computer.object_name = "Computer Terminal"
    computer.add_screen_states({
        "normal": "res://src/assets/ui/terminal_normal.png",
        "error": "res://src/assets/ui/terminal_error.png",
        "corrupted": "res://src/assets/ui/terminal_corrupted.png"
    })
    objects_container.add_child(computer)
    
    # Multi-state door
    var security_door = StatefulDoor.new()
    security_door.name = "SecurityDoor"
    security_door.position = Vector2(2400, 600)
    security_door.states = ["locked", "unlocked", "broken", "sealed"]
    security_door.current_state = "locked"
    objects_container.add_child(security_door)

func _create_ambient_elements():
    var ambient_container = Node2D.new()
    ambient_container.name = "AmbientElements"
    add_child(ambient_container)
    
    # Flickering lights
    var light_system = LightingSystem.new()
    light_system.name = "DistrictLighting"
    light_system.add_light_source(Vector2(400, 200), "ceiling_standard")
    light_system.add_light_source(Vector2(1200, 200), "ceiling_flicker")
    light_system.add_light_source(Vector2(2000, 200), "emergency_red")
    ambient_container.add_child(light_system)
    
    # Particle effects (steam, sparks, etc)
    var steam_vent = CPUParticles2D.new()
    steam_vent.name = "SteamVent"
    steam_vent.position = Vector2(1600, 700)
    steam_vent.texture = preload("res://src/assets/particles/steam.png")
    steam_vent.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
    steam_vent.emission_box_extents = Vector2(50, 10)
    steam_vent.direction = Vector2(0, -1)
    steam_vent.initial_velocity = 100
    steam_vent.emitting = true
    ambient_container.add_child(steam_vent)

func _initialize_audio_sources():
    # Diegetic audio sources
    var audio_container = Node2D.new()
    audio_container.name = "AudioSources"
    add_child(audio_container)
    
    # Ambient machinery hum
    var machine_audio = AudioStreamPlayer2D.new()
    machine_audio.name = "MachineryHum"
    machine_audio.position = Vector2(1500, 500)
    machine_audio.stream = preload("res://src/assets/audio/ambient/machinery_loop.ogg")
    machine_audio.max_distance = 800
    machine_audio.attenuation = 2.0
    machine_audio.autoplay = true
    audio_container.add_child(machine_audio)
    ambient_sounds.append(machine_audio)
    
    # PA system speaker
    var pa_speaker = AudioStreamPlayer2D.new()
    pa_speaker.name = "PASpeaker"
    pa_speaker.position = Vector2(960, 100)
    pa_speaker.max_distance = 1200
    pa_speaker.attenuation = 1.5
    audio_container.add_child(pa_speaker)
    
    # Schedule PA announcements
    TimeManager.connect("hour_changed", self, "_play_pa_announcement", [pa_speaker])

func _setup_time_based_changes():
    # Define changes based on game time
    time_based_elements = {
        "morning": {
            "lighting": "bright",
            "npcs": ["morning_shift_worker", "janitor"],
            "sounds": ["morning_announcement", "cleaning_sounds"]
        },
        "afternoon": {
            "lighting": "normal",
            "npcs": ["afternoon_shift_worker", "supervisor"],
            "sounds": ["work_sounds", "machinery_active"]
        },
        "evening": {
            "lighting": "dim",
            "npcs": ["evening_shift_worker", "security_patrol"],
            "sounds": ["evening_announcement", "machinery_winding_down"]
        },
        "night": {
            "lighting": "emergency_only",
            "npcs": ["night_security"],
            "sounds": ["emergency_lighting_hum", "distant_sounds"]
        }
    }
    
    # Connect to time manager
    TimeManager.connect("time_period_changed", self, "_update_time_based_elements")

func _initialize_lod_system():
    if not use_lod_system:
        return
    
    # Set up LOD groups
    for obj in animated_objects:
        obj.set_lod_enabled(true)
        obj.set_lod_distances(lod_distances)
    
    # Configure update rates based on distance
    set_process(true)

func _process(delta):
    if use_lod_system:
        _update_lod_states()

func _update_lod_states():
    var player_pos = get_player_position()
    
    for obj in animated_objects:
        var distance = obj.global_position.distance_to(player_pos)
        
        if distance < lod_distances.high:
            obj.set_update_rate(1.0)  # Full rate
        elif distance < lod_distances.medium:
            obj.set_update_rate(0.5)  # Half rate
        elif distance < lod_distances.low:
            obj.set_update_rate(0.1)  # Minimal rate
        else:
            obj.set_update_rate(0.0)  # Frozen

# Sub-location transitions
func transition_to_sub_location(location_name: String, entry_point: String = "default"):
    if not sub_locations.has(location_name):
        push_error("Unknown sub-location: " + location_name)
        return
    
    current_sub_location = location_name
    
    # Update camera bounds
    var loc_data = sub_locations[location_name]
    _update_camera_for_sub_location(loc_data.bounds)
    
    # Move player to entry point
    var entry_pos = _get_sub_location_entry(location_name, entry_point)
    move_player_to(entry_pos)
    
    # Update active elements
    _activate_sub_location_elements(location_name)

# Environmental storytelling
func show_assimilation_progress(level: float):
    # Visual indicators of station degradation
    if level > 0.2:
        # Add goo decals
        _add_goo_traces()
    
    if level > 0.4:
        # Flicker lights
        _enable_light_flickering()
    
    if level > 0.6:
        # Break some objects
        _damage_environment()
    
    if level > 0.8:
        # Major environmental changes
        _show_heavy_infestation()
```

### Full Data Structure

```json
{
    "district_id": "template_district_full",
    "display_name": "Industrial Sector A",
    "tier": "major",
    "description": "Primary industrial processing center",
    "sub_locations": {
        "main": {
            "name": "Main Factory Floor",
            "walkable_areas": ["main_floor", "platform", "stairs"],
            "objects": ["industrial_machine", "main_terminal", "security_door"],
            "npcs": ["shift_supervisor", "worker_1", "worker_2"],
            "ambient_audio": ["machinery_hum", "steam_vents"]
        },
        "office": {
            "name": "Supervisor's Office",
            "walkable_areas": ["office_floor"],
            "objects": ["desk", "filing_cabinet", "office_terminal"],
            "npcs": ["supervisor"],
            "ambient_audio": ["computer_hum", "ventilation"]
        },
        "storage": {
            "name": "Storage Room",
            "walkable_areas": ["storage_floor"],
            "objects": ["crates", "shelves", "inventory_terminal"],
            "npcs": ["warehouse_worker"],
            "ambient_audio": ["refrigeration_unit"]
        }
    },
    "connections": {
        "tram_station": {
            "from_location": "main",
            "exit_object": "main_exit",
            "entry_point": "from_industrial"
        },
        "maintenance_tunnels": {
            "from_location": "storage",
            "exit_object": "maintenance_hatch",
            "entry_point": "from_industrial",
            "requirement": "maintenance_key"
        }
    },
    "time_schedules": {
        "morning_shift": {
            "time_range": [6, 14],
            "npcs": ["morning_supervisor", "morning_workers"],
            "activities": ["active_production", "deliveries"]
        },
        "evening_shift": {
            "time_range": [14, 22],
            "npcs": ["evening_supervisor", "evening_workers"],
            "activities": ["maintenance", "cleanup"]
        },
        "night_shift": {
            "time_range": [22, 6],
            "npcs": ["night_security"],
            "activities": ["security_patrols", "emergency_only"]
        }
    },
    "environmental_states": {
        "normal": {
            "lighting": "industrial_standard",
            "sounds": ["machinery_normal", "worker_chatter"],
            "particle_effects": ["steam_normal", "welding_sparks"]
        },
        "suspicious": {
            "lighting": "slightly_dimmed",
            "sounds": ["machinery_irregular", "whispers"],
            "particle_effects": ["steam_excessive", "electrical_sparks"]
        },
        "infested": {
            "lighting": "emergency_red",
            "sounds": ["machinery_failing", "organic_sounds"],
            "particle_effects": ["goo_drips", "toxic_fumes"]
        }
    }
}
```

### Performance Optimization

```gdscript
class DistrictOptimizer:
    var active_elements: Array = []
    var dormant_elements: Array = []
    var visibility_culler: VisibilityNotifier2D
    
    func optimize_district(district: BaseDistrict):
        # Visibility culling
        setup_visibility_culling(district)
        
        # Audio optimization
        optimize_audio_sources(district)
        
        # Particle optimization
        optimize_particle_systems(district)
        
        # NPC optimization
        optimize_npc_updates(district)
    
    func setup_visibility_culling(district: BaseDistrict):
        # Only render objects in camera view
        for obj in district.get_all_objects():
            var notifier = VisibilityNotifier2D.new()
            obj.add_child(notifier)
            notifier.connect("screen_entered", self, "_activate_object", [obj])
            notifier.connect("screen_exited", self, "_deactivate_object", [obj])
    
    func optimize_audio_sources(district: BaseDistrict):
        # Limit concurrent audio streams
        var max_concurrent = 8
        var audio_manager = AudioManager.new()
        audio_manager.max_streams = max_concurrent
        
        for source in district.ambient_sounds:
            audio_manager.register_source(source)
```

## Implementation Guidelines

### MVP Phase Guidelines

1. **One Room Focus**: Perfect one area before adding complexity
2. **Essential Objects Only**: 3-5 objects that serve gameplay
3. **Simple Geometry**: Rectangular walkable areas
4. **Basic Interactions**: Focus on core verbs (LOOK, TAKE, USE)
5. **Minimal NPCs**: 2-3 to test basic interactions

### Full Phase Guidelines

1. **Multi-Room Design**: Plan connections and flow
2. **Complex Navigation**: Interesting walkable area shapes
3. **Rich Interactivity**: Every object should be meaningful
4. **Dynamic Environment**: Time and event-based changes
5. **Performance First**: Test with full NPC load

## Content Creation Workflow

### MVP Workflow

1. Create background art (single room, 1920x1080 minimum)
2. Extend template_district_mvp.gd
3. Define simple walkable area
4. Place 3-5 interactive objects
5. Add spawn points for 2-3 NPCs
6. Test all camera views (left, center, right)
7. Verify no grey bars appear
8. Connect to tram system

### Full Workflow

1. Design complete district layout (main + sub-locations)
2. Create background art for all areas
3. Extend template_district_full.gd
4. Define complex walkable areas with obstacles
5. Implement sub-location transitions
6. Add time-based elements
7. Create ambient audio sources
8. Implement environmental storytelling
9. Optimize for performance
10. Test with full NPC population

## Visual Design Standards

### Background Art Requirements

- **Resolution**: 2560x1080 (main areas), 1920x1080 (sub-locations)
- **Color Palette**: Strict 16-color canonical palette
- **Style**: Pixel art matching early 90s adventure games
- **Layers**: Background (static), Midground (interactive), Foreground (optional)

### Walkable Area Design

- **Visibility**: Should be intuitive even without debug visualization
- **Complexity**: MVP uses simple shapes, Full can use complex polygons
- **Connectivity**: All areas must be reachable
- **Margins**: Keep 50px margin from screen edges

## Testing Checklist

### MVP Testing
- [ ] Extends base_district.gd properly
- [ ] Background named correctly and displays
- [ ] Camera scrolls without grey bars
- [ ] Walkable areas contain player movement
- [ ] All objects are interactable
- [ ] NPCs spawn in correct positions
- [ ] Exit transitions work
- [ ] Saves/loads correctly

### Full Testing
- [ ] All sub-locations accessible
- [ ] Time-based changes trigger correctly
- [ ] Audio sources attenuate properly
- [ ] LOD system improves performance
- [ ] Environmental states change appropriately
- [ ] Complex navigation works smoothly
- [ ] Memory usage acceptable with all features
- [ ] Stress test with 20+ NPCs

## Integration Points

- **CameraSystem**: Ensures proper scrolling and bounds
- **WalkableAreaSystem**: Manages movement boundaries
- **NPCManager**: Spawns and manages district NPCs
- **AudioManager**: Handles diegetic sound
- **TimeManager**: Triggers time-based changes
- **EventManager**: Notifies of district-wide events
- **SaveManager**: Persists district state

## Common Pitfalls

1. **Not Using base_district**: Causes camera and system integration failures
2. **Wrong Node Structure**: Background must be direct child
3. **Forgetting background_size**: Camera calculations fail
4. **Complex MVP**: Keep it simple for first phase
5. **Poor Performance**: Test early with target NPC count

## Future Enhancements

- **Procedural Layouts**: Generate room variations
- **Dynamic Obstacles**: Moving walkable areas
- **Weather Systems**: Station-appropriate environmental effects
- **Crowd Simulation**: Background NPCs for atmosphere
- **Destruction System**: Progressive environment damage