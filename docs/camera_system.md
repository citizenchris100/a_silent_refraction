# Camera System Documentation

## Overview

The Camera System in A Silent Refraction enables players to explore environments that extend beyond screen boundaries while maintaining a consistent coordinate space for gameplay and debugging. This system is a core requirement for creating immersive, spacious environments that players can navigate through using point-and-click interactions.

This document provides a comprehensive understanding of the system's architecture, implementation details, and integration with other game systems.

## Architecture

The camera system follows a layered architecture with clear separation of concerns:

1. **ScrollingCamera** - Core camera implementation that handles player following and camera movement
2. **BoundsCalculator** - Service that calculates camera boundaries from walkable areas
3. **CoordinateManager** - Singleton that manages coordinate transformations between different spaces and views
4. **Debug Tools** - Visualization and validation tools for camera and coordinate systems

### Key Components

#### 1. ScrollingCamera (`src/core/camera/scrolling_camera.gd`)
- Extends Camera2D to handle larger-than-screen backgrounds
- Provides smooth scrolling when player approaches screen edges
- Offers various easing functions for camera movement
- Supports different initial camera positions (left, center, right)
- Includes comprehensive debug visualization capabilities

#### 2. BoundsCalculator (`src/core/camera/bounds_calculator.gd`)
- Service that generates camera bounds from walkable area polygons
- Provides a buffer layer between camera and walkable area systems
- Applies safety checks and corrections for edge cases
- Creates visualizations of the calculated bounds for debugging

#### 3. CoordinateManager (`src/core/coordinate_manager.gd`)
- Singleton for handling all coordinate transformations
- Manages transitions between screen, world, and local coordinate spaces
- Handles conversions between game view and world view modes
- Validates coordinates to ensure proper context usage

#### 4. Validation Tools (`src/core/debug/validate_walkable_area.gd`)
- Debug tools for walkable area validation
- Visualizes valid and invalid points against walkable areas
- Helps detect coordinate errors during development

## Core Camera Features

### Intelligent Boundary Management
The camera uses walkable area polygons to define its movement boundaries. The BoundsCalculator service processes these polygons to create a bounding rectangle:

```gdscript
# Calculate camera bounds from walkable areas
static func calculate_bounds_from_walkable_areas(walkable_areas: Array) -> Rect2:
    var result_bounds = Rect2(0, 0, 0, 0)
    var first_point = true
    
    # Process each walkable area
    for area in walkable_areas:
        if area.polygon.size() == 0:
            continue
            
        # Process each point in the polygon
        for i in range(area.polygon.size()):
            var point = area.polygon[i]
            var global_point = area.to_global(point)
            
            if first_point:
                result_bounds = Rect2(global_point, Vector2.ZERO)
                first_point = false
            else:
                result_bounds = result_bounds.expand(global_point)
    
    # Apply safety checks and corrections
    result_bounds = apply_safety_corrections(result_bounds)
    
    return result_bounds
```

### Coordinate Space Management

The camera system needs to handle several coordinate spaces:

1. **Screen Space**: UI coordinates relative to the viewport (used by mouse clicks)
2. **World Space**: Global game coordinates (used for positioning game objects)
3. **Local Space**: Coordinates relative to a specific object's parent

The CoordinateManager singleton provides methods to transform between these spaces:

```gdscript
# Transform screen coordinates to world coordinates
func screen_to_world(screen_pos):
    # Get the appropriate camera
    var camera = _get_current_camera()
    if camera == null:
        push_error("CoordinateManager: screen_to_world - No camera found")
        return screen_pos
    
    var world_pos = CoordinateSystem.screen_to_world(screen_pos, camera)
    
    # Apply scale factor if needed and in world view mode
    if _current_district != null and _current_view_mode == ViewMode.WORLD_VIEW:
        if "background_scale_factor" in _current_district:
            var scale_factor = _current_district.background_scale_factor
            if scale_factor != 1.0:
                world_pos = CoordinateSystem.apply_scale_factor(world_pos, scale_factor)
    
    return world_pos
```

### View Mode Handling

The camera system supports two main view modes that affect coordinate handling and visualization:

1. **Game View**: Normal playing perspective with properly positioned camera
2. **World View**: Zoomed-out debug view showing the entire scene

CoordinateManager provides methods to transform coordinates between these view modes:

```gdscript
# Transform coordinates between different view modes
func transform_view_mode_coordinates(coords, from_view_mode, to_view_mode):
    if from_view_mode == to_view_mode:
        return coords  # No transformation needed
    
    match [from_view_mode, to_view_mode]:
        [ViewMode.WORLD_VIEW, ViewMode.GAME_VIEW]:
            return CoordinateSystem.world_view_to_game_view(coords, _current_district)
            
        [ViewMode.GAME_VIEW, ViewMode.WORLD_VIEW]:
            return CoordinateSystem.game_view_to_world_view(coords, _current_district)
```

### Camera Movement Logic

The camera movement is handled through a series of steps:

1. **Edge Detection**: The system checks if the player approaches a defined margin from the screen edge
2. **Target Position Calculation**: If the player crosses the margin, a new camera position is calculated
3. **Bounds Clamping**: The target position is clamped to ensure the camera stays within defined boundaries
4. **Smooth Movement**: The camera position is interpolated using the selected easing function
5. **Safety Checks**: Additional checks ensure the player remains visible at all times

```gdscript
func _handle_camera_movement(delta):
    # Get player's position
    var player_pos = target_player.global_position
    
    # Get current camera view rect in world space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    
    # Calculate the area within the view that doesn't trigger scrolling
    var inner_margin = Rect2(
        current_view.position + edge_margin,
        current_view.size - (edge_margin * 2)
    )
    
    # Check if player is outside the inner margin area
    var needs_scroll = !inner_margin.has_point(player_pos)
    
    if needs_scroll:
        # [Movement calculation code...]
        
        # Apply the position with proper easing
        var weight = follow_smoothing * delta
        global_position = _apply_easing(global_position, target_pos, weight)
```

### Flexible Initial Positioning

The camera supports three standard positions that can be set in the district properties:

1. **Left**: Shows the leftmost portion of the background
2. **Center**: Centers the camera on the background
3. **Right**: Shows the rightmost portion of the background

Each view is implemented with careful calculations to ensure proper positioning regardless of background dimensions:

```gdscript
match initial_view.to_lower():
    "left":
        # Position camera to show only the left portion of the background
        var screen_half_width = get_viewport_rect().size.x / 2 / zoom.x
        var left_side_position = camera_bounds.position.x + screen_half_width
        new_position = Vector2(
            left_side_position,
            camera_bounds.position.y + camera_bounds.size.y / 2
        )
        
    "right":
        # Position camera to show the rightmost portion of the background
        var viewport_size = get_viewport_rect().size
        var screen_half_width = viewport_size.x / 2 / zoom.x
        var right_side_position = full_bg_width - screen_half_width
        new_position = Vector2(right_side_position, center_y)
        
    "center", _:
        # Default to center of the background
        new_position = Vector2(
            camera_bounds.position.x + camera_bounds.size.x / 2,
            camera_bounds.position.y + camera_bounds.size.y / 2
        )
```

## Debug Capabilities

### Walkable Area Validation

The system includes a ValidateWalkableArea tool that checks if coordinates are inside walkable areas:

```gdscript
# Validate a list of coordinates against walkable areas
func validate(coordinates):
    # Transform coordinates based on current view mode
    var view_mode = CoordinateManager.get_view_mode()
    var transformed_coords = []
    
    for point in points_to_validate:
        var transformed_point = point
        
        # If we're in world view, convert to game view for validation
        if view_mode == CoordinateManager.ViewMode.WORLD_VIEW:
            transformed_point = CoordinateManager.transform_view_mode_coordinates(
                point, 
                CoordinateManager.ViewMode.WORLD_VIEW, 
                CoordinateManager.ViewMode.GAME_VIEW
            )
        
        transformed_coords.append(transformed_point)
    
    # Check each point against walkable areas
    for i in range(transformed_coords.size()):
        var point = transformed_coords[i]
        var is_valid = is_point_in_any_walkable_area(point)
        # [Processing results...]
```

### Coordinate Validation

The CoordinateManager provides validation functions to ensure coordinates are used in the correct context:

```gdscript
# Utility method: Check if coordinates were captured in World View
func validate_coordinates_for_view_mode(points, expected_view_mode):
    # If we're not in the expected view mode, show a warning
    if _current_view_mode != expected_view_mode:
        var actual_mode = "WORLD_VIEW" if _current_view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"
        var expected_mode = "WORLD_VIEW" if expected_view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"
        
        push_warning("CoordinateManager: Coordinate validation warning - Current view mode is " + 
            actual_mode + " but coordinates are expected for " + expected_mode)
        # [Additional warnings...]
    return true
```

### Bounds Visualization

The BoundsCalculator service can create visual representations of the calculated camera bounds:

```gdscript
# Create a visualization of the calculated bounds for debugging
static func create_bounds_visualization(bounds: Rect2, parent_node):
    if not OS.is_debug_build():
        return null
        
    var visualization = Node2D.new()
    visualization.name = "BoundsVisualization"
    parent_node.add_child(visualization)
    
    # Create a polygon that represents the bounds
    var rect = Polygon2D.new()
    rect.name = "BoundsRect"
    rect.color = Color(1, 0, 0, 0.2)  # Semi-transparent red
    rect.polygon = PoolVector2Array([
        Vector2(bounds.position.x, bounds.position.y),
        Vector2(bounds.position.x + bounds.size.x, bounds.position.y),
        Vector2(bounds.position.x + bounds.size.x, bounds.position.y + bounds.size.y),
        Vector2(bounds.position.x, bounds.position.y + bounds.size.y)
    ])
    visualization.add_child(rect)
    # [Additional visualization elements...]
```

## Implementation Details

### BaseDistrict Configuration

The `BaseDistrict` class contains properties for configuring the scrolling camera:

- `use_scrolling_camera`: Flag to enable/disable scrolling camera
- `camera_follow_smoothing`: Camera smoothing factor for movement
- `camera_edge_margin`: Distance from screen edge that triggers scrolling
- `initial_camera_view`: Starting position ("left", "right", "center")
- `camera_initial_position`: Optional explicit starting position
- `camera_easing_type`: Easing function for camera movement
- `background_scale_factor`: Scale factor for coordinate transformations

### CoordinateManager Initialization

The CoordinateManager singleton needs to be properly initialized with the current district:

```gdscript
# In BaseDistrict's _ready() method:
func _ready():
    # Initialize camera and coordinate systems
    if CoordinateManager:
        CoordinateManager.set_current_district(self)
```

### Setting Up Walkable Areas

Walkable areas need to be properly defined for correct camera behavior:

```gdscript
# In a district or test scene _ready() method:
func setup_walkable_area():
    var walkable = Polygon2D.new()
    walkable.name = "WalkableArea"
    walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green
    walkable.polygon = PoolVector2Array([
        Vector2(234, 816),     # Top-left edge
        Vector2(-2, 826),      # Left edge
        Vector2(-2, 944),      # Bottom-left corner
        Vector2(4686, 944),    # Bottom-right corner
        Vector2(4676, 840),    # Right edge
        Vector2(3672, 854),    # Upper-right area
        Vector2(3186, 812),    # Mid-upper area
        Vector2(1942, 802),    # Mid-upper area
        Vector2(692, 851),     # Mid-left area
        Vector2(480, 889),     # Lower-left area
        Vector2(258, 871)      # Upper-left area
    ])
    walkable.add_to_group("designer_walkable_area")
    walkable.add_to_group("walkable_area")
    add_child(walkable)
```

## Testing Tools

### Debug Keys

The camera system supports several debug keys to aid in testing:

- **Alt+W**: Toggle between Game View and World View modes
- **F1**: Toggle coordinate picker for defining walkable areas
- **F2**: Toggle polygon visualizer for editing walkable areas
- **F3**: Toggle debug console
- **F4**: Toggle debug overlay

### Debug Console Commands

Several debug commands are available for testing the camera system:

```
debug fullview           # Toggle world view mode (Alt+W)
debug worldview          # Toggle world view mode (Alt+W)
debug validate_walkable  # Validate coordinates against walkable areas
```

### Test Scene

The `clean_camera_test.gd` scene demonstrates proper usage of the camera system and walkable areas:

```gdscript
# In clean_camera_test.gd:
func _ready():
    # Setup the walkable area with proper coordinates
    setup_walkable_area()
    
    # Create the scrolling camera
    var camera = ScrollingCamera.new()
    camera.name = "Camera"
    camera.initial_view = "center"  # Show center view initially
    add_child(camera)
    
    # Test different camera views:
    # - Press 1 for left view
    # - Press 2 for center view
    # - Press 3 for right view
```

## Best Practices

### Coordinate Management

1. **Proper Space Usage**:
   - Use World View mode when defining walkable areas that span the entire background
   - Use Game View mode for local interactions and testing normal gameplay

2. **CoordinateManager Usage**:
   - Always use CoordinateManager for coordinate transformations between spaces
   - Validate coordinates when capturing input or defining walkable areas
   - Be aware of the current view mode when working with coordinates

3. **View Mode Awareness**:
   - Use Alt+W to toggle between Game View and World View modes
   - Ensure coordinates captured in World View are properly transformed before use in Game View
   - Document which view mode coordinates were captured in

### Walkable Area Definition

1. **Comprehensive Coverage**:
   - Define walkable areas that span the entire playable region
   - Include points along the outer edges and any interior boundaries
   - Ensure all walkable points are contained within the polygon

2. **Validation**:
   - Use the validate_walkable debug command to check coordinates
   - Visually verify walkable areas with the polygon visualizer
   - Test with the camera in different positions (left, center, right)

### Camera Configuration

1. **Performance Optimization**:
   - Use appropriate easing functions for smooth movement
   - Consider the distance from screen edge that triggers scrolling
   - Balance smoothness with responsiveness

2. **Testing Each View**:
   - Test camera behavior with each initial view (left, center, right)
   - Verify camera constraints at boundaries of walkable areas
   - Check camera response when player approaches screen edges

## Future Enhancements

Potential improvements for the camera system:

1. **Multi-layer parallax backgrounds** for depth perception
2. **Camera zones** that define special camera behaviors in specific areas
3. **Transition effects** when moving between districts
4. **Camera focusing** on important objects or events
5. **Screen edge interaction** for district transitions

## Related Documentation

- [Coordinate System](coordinate_system.md): Details on coordinate spaces and transformations
- [Walkable Area System](walkable_area_system.md): Information on walkable area implementation
- [Debug Tools](debug_tools.md): Documentation for the debug tools and visualization options