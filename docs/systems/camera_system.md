# Camera System Documentation

## Overview

The Camera System in A Silent Refraction enables players to explore environments that extend beyond screen boundaries while maintaining a consistent coordinate space for gameplay and debugging. This system is a core requirement for creating immersive, spacious environments that players can navigate through using point-and-click interactions.

This document provides a comprehensive understanding of the system's architecture, implementation details, and integration with other game systems.

## Critical Requirements

### Base District Extension Requirement

**IMPORTANT**: All scenes using the ScrollingCamera system MUST extend `base_district.gd`. This is not optional - the camera system depends on the district architecture for proper functionality.

### Required Node Structure

The following node structure is mandatory for the camera system to function correctly:

```
YourDistrict (extends base_district.gd)
├── Background (Sprite) - MUST be named "Background"
├── ScrollingCamera (created automatically by base_district)
├── Player (KinematicBody2D)
└── WalkableAreas (Node2D)
```

**Critical Notes:**
- The Background node MUST be a direct child of the district
- The Background node MUST be named exactly "Background" 
- Do NOT wrap these nodes in container nodes (e.g., TestEnvironment)
- The camera expects to find Background as a sibling node

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
- Implements robust coordinate validation and transformation methods
- Features signal-based state change communication
- Includes world_view_mode flag to control player following behavior

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

### Enhanced Coordinate Transformation

The camera system now includes robust coordinate transformation with validation to handle edge cases:

```gdscript
# Helper method to convert screen coordinates to world coordinates
func screen_to_world(screen_pos: Vector2) -> Vector2:
    # First validate the screen position to catch any invalid values
    if is_nan(screen_pos.x) or is_nan(screen_pos.y) or is_inf(screen_pos.x) or is_inf(screen_pos.y):
        push_warning("Camera: Invalid screen coordinates detected. Using viewport center as fallback.")
        screen_pos = get_viewport_rect().size / 2
        
    # Calculate the transformation
    var result = global_position + ((screen_pos - get_viewport_rect().size/2) * zoom)
    
    # Validate the result
    result = validate_coordinates(result)
    
    return result
```

The system also provides validation methods to ensure coordinates remain valid:

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
        return global_position
        
    # Return the validated position
    return position
```

### Walkable Area Visualization

The camera system now supports marker-based walkable area visualization for better visibility and debugging:

```gdscript
# Create visible yellow markers at each vertex for visual reference
var walkable_markers = Node2D.new()
walkable_markers.name = "WalkableAreaMarkers"
walkable_markers.z_index = 100  # Make sure markers appear above other elements
add_child(walkable_markers)

# Add a marker at each vertex of the walkable area
for i in range(game_view_coords.size()):
    var marker = ColorRect.new()
    marker.name = "Marker_" + str(i)
    marker.rect_size = Vector2(10, 10)
    marker.rect_position = game_view_coords[i] - Vector2(5, 5)  # Center marker on point
    marker.color = Color(1, 1, 0, 0.9)  # Bright yellow with high opacity
    walkable_markers.add_child(marker)
```

This technique provides clear visualization of walkable area boundaries for designers and developers, even when traditional polygon rendering encounters issues.

### World View Mode Integration

The camera now properly integrates with the world view mode, allowing for coordinate debugging without affecting player following:

```gdscript
# Skip this check if in world view mode
func _ensure_player_visible():
    if world_view_mode:
        return
        
    # Rest of the player visibility logic
    # ...
```

### Automatic Background Scaling (Visual Correctness Priority)

The camera system implements the Visual Correctness Priority principle through the `calculate_optimal_zoom()` function, which ensures backgrounds fill the viewport to prevent grey bars:

```gdscript
# Called automatically during _ready() if auto_adjust_zoom is true
func calculate_optimal_zoom():
    # Get the district (parent) which has background information
    var district = get_parent()
    
    # Find the background sprite - MUST be named "Background" and be a sibling
    var background_node = district.get_node_or_null("Background")
    
    if background_node and background_node is Sprite and background_node.texture:
        # Calculate scale to fill viewport height
        var height_scale = screen_size.y / background_node.texture.get_size().y
        
        # Apply scale to background sprite
        background_node.scale = Vector2(height_scale, height_scale)
        
        # Update camera bounds to match scaled background
        var scaled_width = background_node.texture.get_size().x * height_scale
        camera_bounds = Rect2(0, 0, scaled_width, screen_size.y)
```

**Important Implementation Details:**
- This function is called automatically if `auto_adjust_zoom = true` (default)
- It scales the background sprite directly to fill the viewport height
- It overrides viewport-aware bounds with visual-correct bounds
- It implements the hybrid architecture: sophisticated bounds for logic, overrides for visuals
- If the Background node isn't found, the function fails silently (no error)

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
   - Default mode for gameplay
   - Camera follows player according to defined rules
   - Shows a portion of the scene based on camera position
   - Uses default coordinate space for normal gameplay

2. **World View**: Zoomed-out debug view showing the entire scene
   - Activated with Alt+W key combination
   - Shows the entire background/scene for debugging
   - Camera does not follow player in this mode
   - Used for capturing walkable area coordinates
   - Coordinates captured in this mode need transformation for use in Game View

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
signal bounds_changed(new_bounds)            # When bounds are recalculated
signal camera_moved(new_position)            # During camera movement
```

### Signal Management (Task 10 Enhancement)

As of Task 10, ScrollingCamera now includes enhanced signal management:

1. **Automatic Group Registration**
   - ScrollingCamera adds itself to the "camera" group on initialization
   - This allows other systems (like GameManager) to easily find and connect to it

2. **Enhanced Signal Emissions**
   - More granular signals for state transitions
   - Additional signals for movement tracking
   - Proper signal parameters for debugging

3. **GameManager Integration**
   - GameManager automatically finds and connects to camera signals
   - Tracks camera state changes for coordination
   - Handles camera movement events

These signals enable proper synchronization between systems:

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

Other systems can connect to these signals to synchronize their behavior with camera movements and state changes.

## Testing

Multiple test scenes are available to verify camera functionality:

1. **Camera System Test (`src/test/camera_system_test.tscn`)** ⚠️ **NEEDS REFACTORING**
   - Currently has incorrect node structure (uses TestEnvironment wrapper)
   - Does NOT extend base_district (causes grey bars)
   - Scheduled for refactoring to follow correct architecture
   - Until fixed, use clean_camera_test2 as reference

2. **Clean Camera Test (`src/test/clean_camera_test.tscn`)**
   - Basic camera functionality with standard walkable areas
   - Test viewport-scale considerations

3. **Clean Camera Test 2 (`src/test/clean_camera_test2.tscn`)** ✅ **RECOMMENDED PATTERN**
   - Correctly extends base_district
   - Demonstrates proper node structure
   - Shows coordinate transformation between view modes
   - Includes marker-based walkable area visualization
   - Provides proper player positioning with coordinate transformation
   - **USE THIS AS A TEMPLATE FOR NEW DISTRICTS AND TEST SCENES**
   
**Important**: Always use clean_camera_test2.gd as your reference for creating new test scenes. It follows the correct architecture that prevents issues like grey bars.

## Best Practices

### Coordinate Management

1. **Proper Space Usage**:
   - Use World View mode when defining walkable areas that span the entire background
   - Use Game View mode for local interactions and testing normal gameplay
   - Clearly document which view mode coordinates were captured in with comments

2. **CoordinateManager Usage**:
   - Always use CoordinateManager for coordinate transformations between spaces
   - Validate coordinates when capturing input or defining walkable areas
   - Be aware of the current view mode when working with coordinates
   - Use `transform_coordinate_array()` for transforming arrays of coordinates between view modes

3. **View Mode Awareness**:
   - Use Alt+W to toggle between Game View and World View modes
   - Ensure coordinates captured in World View are properly transformed before use in Game View
   - Use the following pattern to transform coordinates captured in World View:

```gdscript
# Transform coordinates from WORLD_VIEW to GAME_VIEW using system architecture
var game_view_coords = CoordinateManager.transform_coordinate_array(
   world_view_coords,
   CoordinateManager.ViewMode.WORLD_VIEW,
   CoordinateManager.ViewMode.GAME_VIEW
)
```

4. **Coordinate Validation**:
   - Use the camera's `validate_coordinates()` method to ensure valid coordinates
   - Check for NaN, infinite, or extremely large values that indicate errors
   - Use `ensure_valid_target()` to validate positions for camera movement
   - Document any special handling or edge cases in your code

### Walkable Area Definition

1. **Comprehensive Coverage**:
   - Define walkable areas that span the entire playable region
   - Include points along the outer edges and any interior boundaries
   - Ensure all walkable points are contained within the polygon
   - Document the coordinates clearly, specifying which view mode they were captured in

2. **Visualizing Walkable Areas**:
   - Use marker-based visualization for better visibility during development
   - Create yellow markers at each polygon vertex for clear visual reference
   - Consider adding connecting lines between markers for better area visualization
   - Use a high z_index to ensure markers appear above other scene elements

3. **Validation**:
   - Use the validate_walkable debug command to check coordinates
   - Visually verify walkable areas with the marker visualization system
   - Test with the camera in different positions (left, center, right)
   - Verify walkable areas function properly for both collision and visual purposes

### Camera Configuration

1. **Performance Optimization**:
   - Use appropriate easing functions for smooth movement
   - Consider the distance from screen edge that triggers scrolling
   - Balance smoothness with responsiveness

2. **Testing Each View**:
   - Test camera behavior with each initial view (left, center, right)
   - Verify camera constraints at boundaries of walkable areas
   - Check camera response when player approaches screen edges

## Common Pitfalls and Solutions

### 1. Grey Bars Appearing (Background Not Filling Viewport)

**Cause**: Scene doesn't extend base_district or has incorrect node structure

**Solution**: 
- Ensure your scene extends `base_district.gd`
- Verify Background is a direct child named "Background"
- Check that `auto_adjust_zoom` is true (default)
- Don't wrap nodes in extra containers

### 2. calculate_optimal_zoom() Not Working

**Cause**: Background node not found due to incorrect structure

**Symptoms**: 
- Grey bars at top/bottom of screen
- Background doesn't scale to fill viewport
- No error messages (fails silently)

**Solution**:
```gdscript
# WRONG - Background is not a sibling of camera
TestScene (Node2D)
└── TestEnvironment
    ├── Background
    └── Camera

# CORRECT - Background is sibling of camera under district
YourDistrict (extends base_district)
├── Background
└── Camera
```

### 3. Test Scenes Not Working Like Game Scenes

**Cause**: Test scenes using different architecture than game

**Solution**: 
- Test scenes MUST use the same architecture as game scenes
- Always extend base_district for camera test scenes
- Use clean_camera_test2.gd as a template

### 4. Camera Not Following Player

**Cause**: Multiple possible issues

**Checklist**:
- Verify `follow_player = true`
- Check `target_player` is set correctly
- Ensure not in world_view_mode
- Verify camera state is FOLLOWING_PLAYER

### 5. Coordinate Transformation Issues

**Cause**: Not using proper view mode transformations

**Solution**: Always use CoordinateManager for transformations between World View and Game View

## Test Scene Guidelines

### Creating Camera Test Scenes

1. **Always extend base_district**:
```gdscript
extends "res://src/core/districts/base_district.gd"
```

2. **Follow the required node structure**:
- No wrapper nodes
- Background as direct child
- Let base_district create the camera

3. **Use clean_camera_test2.gd as reference**:
- It demonstrates the correct pattern
- Shows proper coordinate transformation
- Includes debug visualization

### Test Scene Anti-Patterns to Avoid

1. **DON'T create custom node structures**
2. **DON'T manually create cameras** (let base_district handle it)
3. **DON'T wrap everything in a TestEnvironment node**
4. **DON'T ignore the established architecture**

## Navigation System Update

### Migration to Navigation2DServer

As of the latest update, the player navigation system has been migrated from the deprecated `Navigation2D.get_simple_path()` to the modern `Navigation2DServer.map_get_path()` API. This provides:

1. **Better Performance**: Navigation2DServer is more efficient for pathfinding calculations
2. **Thread Safety**: Can be called from background threads
3. **Layer Support**: Supports navigation layers for more complex navigation setups
4. **Future Compatibility**: Ensures compatibility with future Godot versions

### Implementation Details

The player now uses a navigation map RID instead of a direct Navigation2D node reference:

```gdscript
# Old way (deprecated)
navigation_path = navigation_node.get_simple_path(global_position, target_pos)

# New way
navigation_path = Navigation2DServer.map_get_path(
    navigation_map_rid,
    global_position,
    target_pos,
    true,  # optimize path
    0xFFFFFFFF  # use all navigation layers
)
```

## Related Documentation

- [Coordinate System](coordinate_system.md): Details on coordinate spaces and transformations
- [Walkable Area System](walkable_area_system.md): Information on walkable area implementation
- [Debug Tools](debug_tools.md): Documentation for the debug tools and visualization options
- [Scrolling Camera System](scrolling_camera_system.md): Comprehensive documentation for scrolling camera implementation
- [Background Dimensions](../reference/background_dimensions.md): Standard dimensions and camera behavior for different view types
- [Architecture](../reference/architecture.md): Visual Correctness Priority and hybrid architecture principles