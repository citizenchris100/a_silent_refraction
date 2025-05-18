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
- Implements state-based camera system (IDLE, MOVING, FOLLOWING_PLAYER)
- Provides smooth scrolling when player approaches screen edges
- Offers various easing functions for camera movement
- Supports different initial camera positions (left, center, right)
- Includes comprehensive debug visualization capabilities
- Implements coordinate validation and transformation methods

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

## Camera States

The camera operates in three distinct states:

### IDLE State
- Camera is stationary
- Not actively following the player or transitioning
- The camera will remain fixed at its current position
- Methods like `move_to_position()` will transition to the MOVING state

### MOVING State
- Camera is transitioning between two positions
- Transition is governed by the current easing function
- Progress is tracked with the `movement_progress` variable
- When the transition completes, the camera returns to IDLE or FOLLOWING_PLAYER

### FOLLOWING_PLAYER State
- Camera is actively tracking the player's movement
- Maintains player visibility using edge margins to trigger scrolling
- Smoothly adjusts position to keep player in comfortable viewing area
- Can be triggered with the `start_following_player()` method

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

The camera system handles several coordinate spaces:

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

### Coordinate Validation

The ScrollingCamera includes coordinate validation to ensure robustness and handle edge cases:

```gdscript
# Validate coordinates to ensure they are valid and handle edge cases
func validate_coordinates(position: Vector2) -> Vector2:
    # Check for NaN values
    if is_nan(position.x) or is_nan(position.y):
        push_warning("Camera: Invalid coordinate detected (NaN). Using camera position as fallback.")
        return global_position
    
    # Check for infinite values
    if is_inf(position.x) or is_inf(position.y):
        push_warning("Camera: Invalid coordinate detected (Infinite). Using camera position as fallback.")
        return global_position
        
    # Check for extremely large values that likely indicate errors
    if abs(position.x) > 100000 or abs(position.y) > 100000:
        push_warning("Camera: Suspiciously large coordinate detected. Using camera position as fallback.")
        debug_log("camera", "Large coordinate detected: " + str(position))
        return global_position
        
    # Return the validated position
    return position
```

### Camera Movement and State Transitions

The camera state system manages transitions between different camera behaviors:

```gdscript
# Set camera state and handle state transitions
func set_camera_state(new_state: int) -> void:
    # Don't do anything if state isn't changing
    if current_camera_state == new_state:
        return
        
    var old_state = current_camera_state
    current_camera_state = new_state
    
    # Handle state entry actions
    match new_state:
        CameraState.IDLE:
            is_transition_active = false
            movement_progress = 0.0
            emit_signal("camera_move_completed")
            
        CameraState.MOVING:
            is_transition_active = true
            movement_progress = 0.0
            emit_signal("camera_move_started", target_position)
            
        CameraState.FOLLOWING_PLAYER:
            is_transition_active = false
            
    # Emit the state change signal
    emit_signal("camera_state_changed", new_state)
```

State-based movement is handled in the _process method:

```gdscript
func _process(delta):
    # Handle camera movement based on state
    match current_camera_state:
        CameraState.FOLLOWING_PLAYER:
            if follow_player:
                _handle_camera_movement(delta)
                
        CameraState.MOVING:
            if is_transition_active:
                _handle_transition_movement(delta)
            else:
                # If transition is complete but we're still in MOVING state, go to IDLE
                set_camera_state(CameraState.IDLE)
                
        CameraState.IDLE:
            # If follow_player is enabled but we're idle, switch to FOLLOWING_PLAYER
            if follow_player and target_player:
                set_camera_state(CameraState.FOLLOWING_PLAYER)
```

### Flexible Initial Positioning

The camera supports three standard positions that can be set in the district properties:

1. **Left**: Shows the leftmost portion of the background
2. **Center**: Centers the camera on the background
3. **Right**: Shows the rightmost portion of the background

## CoordinateManager Integration

The camera system integrates with the CoordinateManager singleton for consistent coordinate transformations:

```gdscript
# Register this camera with the CoordinateManager singleton
func register_with_coordinate_manager():
    if Engine.has_singleton("CoordinateManager"):
        var coord_manager = Engine.get_singleton("CoordinateManager")
        
        # Get parent district if available
        var district = get_parent() if get_parent() is BaseDistrict else null
        
        if district:
            # Register the district with the coordinate manager
            coord_manager.set_current_district(district)
        
        debug_log("camera", "Camera registered with CoordinateManager")
```

## Usage

### Basic Camera Setup

```gdscript
# In a district scene
var camera = ScrollingCamera.new()
add_child(camera)

# Configure basic properties
camera.follow_player = true
camera.follow_smoothing = 5.0
camera.edge_margin = Vector2(150, 100)

# Set bounds based on the district's walkable area
camera.bounds_enabled = true
```

### Camera Movement API

```gdscript
# Move camera to specific position immediately
camera.move_to_position(target_position, true)

# Move camera with transition
camera.move_to_position(target_position)

# Center camera on player
camera.focus_on_player()

# Start following player
camera.start_following_player()

# Stop following player
camera.stop_following_player()
```

### State Management API

```gdscript
# Get current camera state
var state = camera.get_camera_state()

# Check if camera is moving
if camera.is_moving():
    print("Camera is in transition")

# Check if camera is following player
if camera.is_following_player():
    print("Camera is tracking player movement")

# Set whether camera should follow player
camera.set_follow_player(true)
```

### Coordinate Transformations

```gdscript
# Convert screen coordinates to world coordinates
var world_pos = camera.screen_to_world(screen_pos)

# Convert world coordinates to screen coordinates
var screen_pos = camera.world_to_screen(world_pos)

# Validate coordinates to ensure they're within bounds
var validated_position = camera.validate_coordinates(position)

# Check if a world point is visible in the camera view
var is_visible = camera.is_point_in_view(world_position)
```

## Events and Signals

The camera emits the following signals:

```gdscript
signal camera_move_started(target_position)  # When transition begins
signal camera_move_completed()               # When transition ends
signal view_bounds_changed(new_bounds)       # When camera bounds update
signal camera_state_changed(new_state)       # When camera state changes
```

## Testing

A dedicated test scene is available at `src/test/camera_system_test.tscn` to verify camera functionality:

1. **State Tests** - Verify camera state transitions
2. **Transform Tests** - Validate coordinate transformations
3. **Validation Tests** - Test coordinate validation and error handling
4. **Transition Tests** - Test smooth camera movement between positions
5. **Integration Tests** - Verify CoordinateManager integration

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

## Related Documentation

- [Coordinate System](coordinate_system.md): Details on coordinate spaces and transformations
- [Walkable Area System](walkable_area_system.md): Information on walkable area implementation
- [Debug Tools](debug_tools.md): Documentation for the debug tools and visualization options