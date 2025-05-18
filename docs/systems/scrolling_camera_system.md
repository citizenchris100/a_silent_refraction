# Scrolling Camera System Documentation

## Overview

The Scrolling Camera System enables players to explore backgrounds larger than the screen boundaries in A Silent Refraction. This feature is a core requirement for creating immersive, spacious environments that players can navigate through using point-and-click interactions.

This document provides a comprehensive understanding of the system, its current implementation status, planned enhancements, and how it integrates with the game's architecture.

## Requirements (Iteration 3, Task 1)

### Technical Requirement T1
> **T1:** Enhance scrolling camera system with improved coordinate conversions
> - **Rationale:** Proper coordinate conversion is essential for consistent gameplay interactions across different view modes
> - **Constraints:** Must maintain compatibility with existing systems while improving coordinate transformation accuracy

### User Story
> **As a player,** I want the game camera to track my character smoothly and accurately, **so that** I can focus on gameplay rather than managing my view of the action.

### Acceptance Criteria
1. Camera follows player character smoothly without jerky movements
2. Screen-to-world and world-to-screen coordinate conversions work accurately at all zoom levels
3. Camera maintains proper boundaries based on the current district
4. Edge case handling prevents camera from showing areas outside the playable space
5. Camera movement uses appropriate easing for natural feel
6. Walkable areas are properly visualized for development and testing

## Previous Requirements (Iteration 2, Task 6)

### Technical Requirement T2
> **T2:** Implement a scrolling background system that enables environments larger than the game window
> - **Rationale:** Point-and-click adventures require expansive environments to explore, which necessitates a system for handling backgrounds larger than the visible screen area
> - **Constraints:** Must maintain performance with large image files and integrate seamlessly with walkable area and navigation systems

### User Story
> **As a player,** I want to explore scrolling backgrounds in the Shipping District that extend beyond the screen boundaries, **so that** I can experience larger, more immersive environments that feel like real spaces rather than confined screens.

### Acceptance Criteria
1. Background image loads properly and extends beyond screen boundaries
2. Scene can designate starting position (left, middle, right) within the background
3. Walkable areas are properly defined across the entire background
4. Camera smoothly scrolls to follow player when approaching screen boundaries
5. Player movement remains consistent across screen transitions
6. Visual style follows the game's aesthetic guidelines

## Current Implementation

### Core Components

1. **ScrollingCamera (src/core/camera/scrolling_camera.gd)**
   - Extends Camera2D to handle larger-than-screen backgrounds
   - Implements state-based camera system (IDLE, MOVING, FOLLOWING_PLAYER)
   - Provides smooth scrolling when player approaches screen edges
   - Offers various easing functions for camera movement
   - Supports different initial camera positions (left, center, right)
   - Includes comprehensive debug visualization capabilities
   - Features robust coordinate validation and transformation methods
   - Prevents player following when in world view mode

2. **BoundsCalculator (src/core/camera/bounds_calculator.gd)**
   - Service that generates camera bounds from walkable area polygons
   - Provides a buffer layer between camera and walkable area systems
   - Applies safety checks and corrections for edge cases
   - Creates visualizations of the calculated bounds for debugging

3. **BaseDistrict (src/core/districts/base_district.gd)**
   - Contains properties for configuring the scrolling camera:
     - `use_scrolling_camera`: Flag to enable/disable scrolling camera
     - `camera_follow_smoothing`: Camera smoothing factor for movement
     - `camera_edge_margin`: Distance from screen edge that triggers scrolling
     - `initial_camera_view`: Starting position ("left", "right", "center")
     - `camera_initial_position`: Optional explicit starting position
     - `camera_easing_type`: Easing function for camera movement
   - Manages walkable areas that define player movement boundaries
   - Provides methods to set up and configure scrolling camera

4. **CleanCameraTest2 (src/test/clean_camera_test2.gd)**
   - Enhanced template district with improved camera system integration
   - Demonstrates coordinate transformation between view modes
   - Shows marker-based walkable area visualization
   - Provides a working starting point for new districts

### Key Features

1. **Enhanced Coordinate Transformation**
   - Robust screen-to-world and world-to-screen conversions
   - Validation methods to detect and handle NaN, infinite, or extremely large coordinates
   - Integration with CoordinateManager singleton for consistent transformation
   - Proper transformation between Game View and World View modes

2. **Camera State System**
   - Clear state definitions: IDLE, MOVING, FOLLOWING_PLAYER
   - State transitions with appropriate entry/exit actions
   - Signal emission for state changes to notify other systems
   - World View mode detection to prevent inappropriate player following

3. **Automatic Background Scaling**
   - Automatically scales background to fill viewport height
   - Preserves aspect ratio while ensuring screen coverage
   - Handles large backgrounds efficiently
   - Proper coordinate adjustment based on scaling

4. **Intelligent Boundary Management**
   - Uses walkable area polygons to define camera movement boundaries
   - Prevents camera from showing empty/non-game areas
   - Accommodates different background dimensions
   - Robust bounds calculation with safety corrections

5. **Smooth Movement**
   - Multiple easing functions for camera movement:
     - LINEAR, EASE_IN, EASE_OUT, EASE_IN_OUT, EXPONENTIAL, SINE, ELASTIC, CUBIC, QUAD
   - Configurable smoothing factor
   - Handles edge cases to prevent stuttering or visual artifacts
   - Proper state tracking during transitions

6. **Flexible Initial Positioning**
   - Supports three standard positions: left, center, right
   - Allows custom initial position when needed
   - Uses logical positioning based on background dimensions
   - Enhanced calculation for proper RIGHT view positioning

7. **Walkable Area Visualization**
   - Alternative marker-based visualization for walkable areas
   - Yellow markers placed at each polygon vertex
   - Connecting lines to visualize the area shape
   - Higher visibility without polygon rendering issues

8. **Debug Capabilities**
   - Visual representation of camera boundaries
   - Real-time display of camera and player positions
   - Coordinate picking for walkable area definition
   - Enhanced debug logging for camera behavior

## Integration With Shipping District

The Shipping District currently requires implementation of the scrolling camera system with the following specifications:

1. **Background Configuration**
   - Background image extends beyond screen boundaries (approx. 3000x1500px)
   - Walkable areas defined across the broader environment
   - Visual style matches the game's aesthetic guidelines

2. **Camera Setup**
   - Initial position shows the right side of the district (docking area)
   - Smooth scrolling based on player movement
   - Boundaries properly constrained to walkable areas

3. **Player Experience**
   - Player can move across the entire district with the camera following smoothly
   - Screen transitions feel natural and consistent
   - Walkable areas remain accurate regardless of camera position

## Implementation Tasks

To complete the scrolling camera implementation for the Shipping District:

1. **Update the shipping_district.gd script:**
   - Enable scrolling camera (`use_scrolling_camera = true`)
   - Configure camera parameters (smoothing, margins, initial view)
   - Ensure background_size is properly set based on actual background dimensions

2. **Adjust the shipping_district.tscn scene:**
   - Verify or update background sprite configuration
   - Ensure walkable areas are defined across the entire background
   - Test integration with interactive objects

3. **Create a wider background for the shipping district:**
   - Design a background image approximately 3000px wide
   - Follow visual style guidelines
   - Ensure proper import settings for optimal performance

4. **Testing:**
   - Verify the camera follows the player correctly
   - Ensure smooth scrolling with appropriate easing
   - Check walkable area boundaries across the entire background
   - Test different starting positions (left, center, right)
   - Ensure all interactive objects remain functional

## Technical Details

### Enhanced Coordinate Conversion

The enhanced coordinate conversion system adds several important improvements:

```gdscript
# Helper method to convert screen coordinates to world coordinates
# This ensures proper conversion regardless of zoom level
func screen_to_world(screen_pos: Vector2) -> Vector2:
    # First validate the screen position to catch any invalid values
    if is_nan(screen_pos.x) or is_nan(screen_pos.y) or is_inf(screen_pos.x) or is_inf(screen_pos.y):
        push_warning("Camera: Invalid screen coordinates detected. Using viewport center as fallback.")
        screen_pos = get_viewport_rect().size / 2
        
    # Calculate the transformation
    var result = global_position + ((screen_pos - get_viewport_rect().size/2) * zoom)
    
    # Validate the result
    result = validate_coordinates(result)
    
    # If CoordinateManager singleton exists, notify it of the transformation
    if Engine.has_singleton("CoordinateManager"):
        var coord_manager = Engine.get_singleton("CoordinateManager")
        debug_log("camera", "Notifying CoordinateManager of screen_to_world transformation: " +
                 str(screen_pos) + " -> " + str(result))
    
    return result
```

### Camera State System

The camera now operates in three distinct states:

1. **IDLE State**
   - Camera is stationary
   - Not actively following the player or transitioning
   - The camera will remain fixed at its current position
   - Methods like `move_to_position()` will transition to the MOVING state

2. **MOVING State**
   - Camera is transitioning between two positions
   - Transition is governed by the current easing function
   - Progress is tracked with the `movement_progress` variable
   - When the transition completes, the camera returns to IDLE or FOLLOWING_PLAYER

3. **FOLLOWING_PLAYER State**
   - Camera is actively tracking the player's movement
   - Maintains player visibility using edge margins to trigger scrolling
   - Smoothly adjusts position to keep player in comfortable viewing area
   - Can be triggered with the `start_following_player()` method
   - Disabled when in world_view_mode

### Camera Movement Logic

The camera movement is handled through a series of steps:

1. **Edge Detection:** The system checks if the player approaches a defined margin from the screen edge
2. **Target Position Calculation:** If the player crosses the margin, a new camera position is calculated
3. **Bounds Clamping:** The target position is clamped to ensure the camera stays within defined boundaries
4. **Smooth Movement:** The camera position is interpolated using the selected easing function
5. **Safety Checks:** Additional checks ensure the player remains visible at all times
6. **View Mode Awareness:** Camera behavior adapts based on game view versus world view mode

### Walkable Area Integration

Walkable areas are critical for proper camera operation:

1. Districts define polygons representing walkable areas
2. Camera uses BoundsCalculator service to calculate its boundaries from polygons
3. The system expands the bounds slightly to provide visual context
4. Camera movement is constrained within these calculated bounds
5. Walkable areas can now be visualized with markers at vertices for better visibility

### Coordinate Validation

The new coordinate validation system prevents many common issues:

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

### Performance Considerations

For optimal performance with large backgrounds:

1. Use appropriate texture compression for background images
2. Consider splitting very large backgrounds into sections if needed
3. Memory optimization techniques should be applied for large assets
4. Ensure walkable areas are defined efficiently (not too many vertices)

## Debug & Testing Tools

The system includes several tools to help with debugging and testing:

1. **Debug Drawing:** Visual representation of camera boundaries, margins, and viewports
2. **Debug Console:** Commands to control camera properties at runtime
3. **Coordinate Picker:** Tool to help define walkable areas accurately
4. **Test Controls:** Keys to test different camera behaviors:
   - E: Cycle through easing functions
   - V: Toggle between partial view and full background view
   - Z: Cycle through zoom levels

## API Reference

### ScrollingCamera Properties

| Property | Type | Description |
|----------|------|-------------|
| `follow_player` | bool | Whether camera should follow the player |
| `follow_smoothing` | float | Smoothing factor for camera movement |
| `edge_margin` | Vector2 | Distance from edge that triggers scrolling |
| `bounds_enabled` | bool | Whether camera should respect boundaries |
| `initial_position` | Vector2 | Custom initial camera position |
| `initial_view` | String | Which part to show initially: "left", "right", "center" |
| `easing_type` | Enum | Type of easing to use for camera movement |
| `auto_adjust_zoom` | bool | Whether to automatically adjust zoom to fill viewport |
| `world_view_mode` | bool | Flag indicating if camera is in world view debug mode |
| `current_camera_state` | int | Current camera state (IDLE, MOVING, FOLLOWING_PLAYER) |

### ScrollingCamera Signals

| Signal | Description |
|--------|-------------|
| `camera_move_started(target_position)` | Emitted when camera begins movement |
| `camera_move_completed()` | Emitted when camera finishes movement |
| `view_bounds_changed(new_bounds)` | Emitted when camera bounds are updated |
| `camera_state_changed(new_state)` | Emitted when camera state changes |

### ScrollingCamera Methods

| Method | Description |
|--------|-------------|
| `screen_to_world(screen_pos)` | Converts screen coordinates to world coordinates |
| `world_to_screen(world_pos)` | Converts world coordinates to screen coordinates |
| `validate_coordinates(position)` | Ensures coordinates are valid |
| `is_point_in_view(world_pos)` | Checks if a world point is visible in camera view |
| `ensure_valid_target(target_pos)` | Ensures target position is valid for camera movement |
| `move_to_position(pos, immediate)` | Moves camera to a specific position |
| `start_following_player()` | Begins following the player character |
| `stop_following_player()` | Stops following the player character |
| `focus_on_player(with_transition)` | Centers camera on player immediately or with transition |
| `set_camera_state(new_state)` | Sets camera state and handles transitions |
| `is_moving()` | Checks if camera is currently in MOVING state |
| `is_following_player()` | Checks if camera is currently in FOLLOWING_PLAYER state |

### BaseDistrict Methods

| Method | Description |
|--------|-------------|
| `setup_scrolling_camera()` | Sets up scrolling camera for the district |
| `update_bounds()` | Updates camera bounds based on walkable areas |
| `force_update_scroll()` | Force camera to update its position immediately |
| `calculate_optimal_zoom()` | Calculate optimal zoom level to ensure background fills viewport |

### BoundsCalculator Methods

| Method | Description |
|--------|-------------|
| `calculate_bounds_from_walkable_areas(walkable_areas)` | Generates camera bounds from walkable area polygons |
| `apply_safety_corrections(bounds, district)` | Applies corrections to bounds for better camera behavior |
| `create_bounds_visualization(bounds, parent)` | Creates visual representation of calculated bounds |

## Walkable Area Visualization

The enhanced system introduces a new approach to walkable area visualization using marker-based rendering:

```gdscript
# Create visible yellow markers at each vertex for visual reference
# This makes the walkable area visible to level designers without rendering issues
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
    
# Add connecting lines between markers to make the area more visible
var lines_container = Node2D.new()
lines_container.name = "ConnectingLines"
walkable_markers.add_child(lines_container)
```

This approach offers several advantages:

1. **Improved Visibility**: Yellow markers are clearly visible even on complex backgrounds
2. **No Rendering Issues**: Bypasses problems with Polygon2D rendering in certain contexts
3. **Better Debugging**: Makes it easier to identify and fix walkable area problems
4. **Vertex Identification**: Each vertex is clearly marked for easier editing

## Template District Implementation

The `clean_camera_test2.gd` script provides a complete template district with the enhanced camera system integration:

1. Proper background setup with scaling
2. Walkable area definition with coordinate transformation
3. Camera configuration with appropriate bounds
4. Player setup with world view coordinate transformation
5. Debug information display

This template serves as an excellent starting point for creating new districts with properly configured camera systems and coordinate handling.

## Future Enhancements

Potential improvements for the scrolling camera system:

1. **Multi-layer parallax backgrounds** for depth perception
2. **Camera zones** that define special camera behaviors in specific areas
3. **Transition effects** when moving between districts
4. **Camera focusing** on important objects or events
5. **Screen edge interaction** for district transitions
6. **Performance optimizations** for large districts with complex walkable areas
7. **Animation enhancements** for smoother view transitions between perspectives

## Conclusion

The enhanced Scrolling Camera System with improved coordinate conversions is a critical component for creating immersive, expansive environments in A Silent Refraction. The addition of proper coordinate validation, state management, and robust visualization tools makes the system more reliable and easier to work with for developers. The clear separation of camera states and improved signal communication also aligns with the project's architectural principles, ensuring that the system remains maintainable and extensible as the game continues to evolve.