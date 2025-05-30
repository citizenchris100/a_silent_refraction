# Base District System Documentation

## Overview

The Base District system is the foundational architecture for all game locations in A Silent Refraction. Every playable area in the game MUST extend `base_district.gd` to ensure consistent behavior, proper camera functionality, and integration with game systems.

## Critical Importance

**ALL game scenes and test scenes that represent playable areas MUST extend base_district.gd**

This is not a recommendation - it's a requirement. The camera system, walkable areas, and many other core systems depend on the base district architecture.

## Required Node Structure

When creating a district that extends base_district, you must follow this node structure:

```
YourDistrict (extends base_district.gd)
├── Background (Sprite) - MUST be named "Background"
├── WalkableAreas (Node2D) - Contains Polygon2D children
├── NPCs (Node2D) - Optional, contains NPC nodes
├── Objects (Node2D) - Optional, contains interactive objects
└── [Camera and Player are created by base_district]
```

**Critical Notes:**
- The Background node MUST be a direct child named exactly "Background"
- Do NOT manually create Camera or Player nodes - base_district handles this
- Do NOT wrap nodes in container nodes (like TestEnvironment)

## What Base District Provides

### Automatic Camera Setup

Base district automatically:
1. Creates a ScrollingCamera instance
2. Configures it based on district properties
3. Calls `calculate_optimal_zoom()` to prevent grey bars
4. Sets up proper parent-child relationships

### Camera Configuration Properties

```gdscript
# Camera configuration
export var use_scrolling_camera: bool = true
export var camera_follow_smoothing: float = 5.0
export var camera_edge_margin: Vector2 = Vector2(150, 100)
export var initial_camera_view: String = "center" # "left", "center", "right"
export var camera_initial_position: Vector2 = Vector2.ZERO
export var camera_easing_type: String = "CUBIC"
```

### Walkable Area Management

Base district provides:
- Automatic detection of walkable area polygons
- Integration with camera bounds calculation
- Coordinate transformation support
- Debug visualization tools

### Player Setup

The `setup_player_and_controller()` method:
- Creates the player instance
- Sets up point-and-click navigation with enhanced InputManager
- Configures camera to follow player
- Handles initial positioning
- Integrates with click validation and visual feedback systems

Note: The district works seamlessly with the enhanced InputManager which provides:
- Click validation (preventing clicks outside valid areas)
- Visual feedback (green for valid clicks, red for invalid, yellow for adjusted)
- Priority handling for overlapping interactive elements

## Creating a New District

### 1. Create Your Script

```gdscript
extends "res://src/core/districts/base_district.gd"

func _ready():
    # Set district properties
    district_name = "Your District Name"
    district_description = "Description of your district"
    
    # Configure camera (optional - has defaults)
    use_scrolling_camera = true
    initial_camera_view = "left"
    
    # Create and configure background
    var background = Sprite.new()
    background.name = "Background"  # MUST be named "Background"
    background.texture = load("res://path/to/your/background.png")
    background.centered = false
    add_child(background)
    
    # Set background size for camera
    background_size = background.texture.get_size()
    
    # Create walkable areas
    create_walkable_area()
    
    # Call parent _ready() - This sets up camera and systems
    ._ready()
    
    # Set up player (optional position)
    setup_player_and_controller(Vector2(400, 300))
```

### 2. Create Walkable Areas

```gdscript
func create_walkable_area():
    var walkable_container = Node2D.new()
    walkable_container.name = "WalkableAreas"
    add_child(walkable_container)
    
    var area = Polygon2D.new()
    area.name = "MainWalkableArea"
    area.polygon = PoolVector2Array([
        Vector2(0, 500),
        Vector2(1920, 500),
        Vector2(1920, 700),
        Vector2(0, 700)
    ])
    area.color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
    walkable_container.add_child(area)
```

## Common Mistakes to Avoid

### 1. Not Extending Base District

```gdscript
# WRONG - Will cause grey bars and camera issues
extends Node2D

# CORRECT
extends "res://src/core/districts/base_district.gd"
```

### 2. Wrong Node Structure

```gdscript
# WRONG - Background in wrong place
func _ready():
    var env = Node2D.new()
    env.name = "Environment"
    add_child(env)
    
    var bg = Sprite.new()
    bg.name = "Background"
    env.add_child(bg)  # Background is not direct child!

# CORRECT - Background as direct child
func _ready():
    var bg = Sprite.new()
    bg.name = "Background"
    add_child(bg)  # Direct child of district
```

### 3. Creating Camera Manually

```gdscript
# WRONG - Don't create camera yourself
func _ready():
    var camera = Camera2D.new()
    add_child(camera)

# CORRECT - Let base_district create it
func _ready():
    ._ready()  # Base district creates camera
```

## Test Scene Guidelines

When creating test scenes for camera or district functionality:

1. **ALWAYS extend base_district** - Even for test scenes
2. **Use clean_camera_test2.gd as template** - It's the correct pattern
3. **Don't create special test architectures** - Test the actual game architecture

## Visual Correctness and calculate_optimal_zoom()

Base district's camera setup includes calling `calculate_optimal_zoom()` which:
- Scales the Background sprite to fill the viewport height
- Prevents grey bars from appearing
- Updates camera bounds to match the scaled background
- Implements the Visual Correctness Priority principle

This ONLY works if:
- Your scene extends base_district
- Background is a direct child named "Background"
- You call `._ready()` after setting up your scene

## Integration with Other Systems

Base district integrates with:
- **CoordinateManager**: For coordinate transformations
- **InputManager**: For click validation and routing (created by GameManager)
- **WalkableAreaSystem**: For movement boundaries
- **NPCSystem**: For NPC placement and management
- **DialogSystem**: For location-specific dialogs
- **DebugSystem**: For development tools
- **ClickFeedbackSystem**: For visual click indicators
- **ClickPrioritySystem**: For handling overlapping interactive elements

## Best Practices

1. **Always call parent _ready()**: `._ready()` must be called after your setup
2. **Set background_size**: Required for proper camera bounds
3. **Use provided methods**: Don't reinvent functionality that base_district provides
4. **Follow the node structure**: Deviating causes issues
5. **Test with different camera views**: Use left, center, and right initial views

## Example: Minimal District

```gdscript
extends "res://src/core/districts/base_district.gd"

func _ready():
    district_name = "Test District"
    
    # Background
    var bg = Sprite.new()
    bg.name = "Background"
    bg.texture = preload("res://src/assets/backgrounds/test_background.png")
    bg.centered = false
    add_child(bg)
    
    background_size = bg.texture.get_size()
    
    # Simple walkable area
    var walkable = Node2D.new()
    walkable.name = "WalkableAreas"
    add_child(walkable)
    
    var area = Polygon2D.new()
    area.polygon = PoolVector2Array([
        Vector2(100, 400),
        Vector2(1800, 400),
        Vector2(1800, 600),
        Vector2(100, 600)
    ])
    walkable.add_child(area)
    
    # Let base_district handle everything else
    ._ready()
    
    # Add player
    setup_player_and_controller()
```

## Related Documentation

- [Camera System](camera_system.md): Detailed camera functionality
- [Scrolling Camera System](scrolling_camera_system.md): Camera implementation details
- [Walkable Area System](walkable_area_system.md): Movement boundaries
- [Architecture](../reference/architecture.md): Overall architectural principles