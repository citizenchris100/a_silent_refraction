# Coordinate System Documentation

This document explains the coordinate systems used in A Silent Refraction, including how coordinates are transformed between different spaces and how to properly capture and use coordinates for walkable areas and other game elements.

## Architecture

The coordinate system follows a layered architecture with clear separation of concerns:

1. **CoordinateManager** - Core singleton that manages all coordinate transformations
2. **ScrollingCamera** - Provides camera-specific coordinate transformations
3. **BaseDistrict** - Implements district-specific coordinate handling
4. **Debug Tools** - Tools for capturing and validating coordinates

## Coordinate Spaces

The game uses multiple coordinate spaces that need to be properly understood when working with positions:

1. **Screen Space**: Coordinates relative to the screen/viewport (0,0 is top-left)
   - Used by: Mouse clicks, UI elements
   - Example: Mouse position from `get_viewport().get_mouse_position()`

2. **World Space**: Global game world coordinates
   - Used by: Game objects, NPC positions, walkable areas
   - Note: World coordinates may be affected by the background_scale_factor

3. **Local Space**: Coordinates relative to a parent node
   - Used by: Child nodes positioned relative to their parent
   - Example: A point on a walkable area polygon relative to the walkable area's position

## View Modes

The system supports two distinct view modes that affect coordinate transformations:

1. **Game View**: Normal playing perspective with properly positioned camera
   - Default mode for gameplay
   - Camera smoothly follows player
   - Limited visibility of the scene

2. **World View**: Zoomed-out debug view showing the entire scene
   - Activated with Alt+W key combination
   - Shows the entire background/scene
   - Used for capturing walkable area coordinates
   - For debugging and level design purposes

## The CoordinateManager Singleton

The `CoordinateManager` singleton centralizes all coordinate transformations in the game:

```gdscript
# src/core/coordinate_manager.gd
extends Node

# Enum for different coordinate spaces
enum CoordinateSpace {
    SCREEN_SPACE,  # UI coordinates relative to the viewport
    WORLD_SPACE,   # Global game coordinates
    LOCAL_SPACE    # Coordinates relative to a specific object's parent
}

# Enum for different view modes
enum ViewMode {
    GAME_VIEW,    # Normal game view with gameplay-appropriate camera zoom
    WORLD_VIEW    # Debug view showing the entire world/background (zoomed out)
}

# The current view mode, defaults to game view
var _current_view_mode = ViewMode.GAME_VIEW
```

### Key Methods

The CoordinateManager provides these essential methods:

```gdscript
# Transform coordinates from one space to another
func transform_coordinates(coords, from_space, to_space, reference_object = null)

# Transform screen coordinates to world coordinates
func screen_to_world(screen_pos)

# Transform world coordinates to screen coordinates
func world_to_screen(world_pos)

# Transform local coordinates to world coordinates
func local_to_world(local_pos, reference_object)

# Transform world coordinates to local coordinates
func world_to_local(world_pos, reference_object)

# Transform coordinates between different view modes
func transform_view_mode_coordinates(coords, from_view_mode, to_view_mode)

# Convert a PoolVector2Array of coordinates from one view mode to another
func transform_coordinate_array(points, from_view_mode, to_view_mode)

# Validate coordinates for the expected view mode
func validate_coordinates_for_view_mode(points, expected_view_mode)
```

### Using the CoordinateManager

To use the CoordinateManager in your code:

```gdscript
# Transform a screen position to world position
var screen_pos = get_viewport().get_mouse_position()
var world_pos = CoordinateManager.screen_to_world(screen_pos)

# Transform a world position to screen position
var screen_pos = CoordinateManager.world_to_screen(world_pos)

# Convert coordinates from world view to game view
var game_view_coords = CoordinateManager.transform_view_mode_coordinates(
    world_view_coords,
    CoordinateManager.ViewMode.WORLD_VIEW,
    CoordinateManager.ViewMode.GAME_VIEW
)

# Transform an array of points
var transformed_points = CoordinateManager.transform_coordinate_array(
    original_points,
    CoordinateManager.ViewMode.WORLD_VIEW,
    CoordinateManager.ViewMode.GAME_VIEW
)

# Validate coordinates for expected view mode
var is_valid = CoordinateManager.validate_coordinates_for_view_mode(
    points,
    CoordinateManager.ViewMode.WORLD_VIEW
)
```

## Lower Level Transformations

### Camera Transformations

The `ScrollingCamera` class provides basic transformations:

```gdscript
# Convert screen position to world position
func screen_to_world(screen_pos: Vector2) -> Vector2:
    return global_position + ((screen_pos - get_viewport_rect().size/2) * zoom)

# Convert world position to screen position
func world_to_screen(world_pos: Vector2) -> Vector2:
    return (world_pos - global_position) / zoom + get_viewport_rect().size/2
```

### District Transformations

The `BaseDistrict` class provides district-specific transformations that handle the background scale factor:

```gdscript
# Convert screen coordinates to world coordinates
func screen_to_world_coords(screen_pos: Vector2) -> Vector2:
    # Find the camera
    var camera_node = get_camera()
    if camera_node:
        # Use the camera's conversion method if available
        if camera_node.has_method("screen_to_world"):
            var world_pos = camera_node.screen_to_world(screen_pos)
            # Apply background scale factor if needed
            if background_scale_factor != 1.0:
                world_pos *= background_scale_factor
            return world_pos
        # Fallback code omitted for brevity
    return screen_pos  # Default fallback

# Convert world coordinates to screen coordinates
func world_to_screen_coords(world_pos: Vector2) -> Vector2:
    # Find the camera
    var camera_node = get_camera()
    if camera_node:
        # Apply background scale factor if needed
        var adjusted_world_pos = world_pos
        if background_scale_factor != 1.0:
            adjusted_world_pos /= background_scale_factor
            
        # Use the camera's conversion method if available
        if camera_node.has_method("world_to_screen"):
            return camera_node.world_to_screen(adjusted_world_pos)
        # Fallback code omitted for brevity
    return world_pos  # Default fallback
```

## Coordinate Capture and Usage

### Capturing Coordinates in World View

When capturing coordinates for walkable areas or other large elements:

1. Press Alt+W to toggle World View (shows the entire background)
2. Use the debug coordinate picker (press F1 or type 'debug coordinates' in console)
3. Click to capture coordinates
4. The coordinate picker will automatically handle the transformation
5. Press C to copy the last coordinate in the correct format for code

The Coordinate Picker now uses the CoordinateManager to handle transformations:

```gdscript
# In coordinate_picker.gd
func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        var click_pos = get_viewport().get_mouse_position()
        
        # Get world position using CoordinateManager
        var world_pos = CoordinateManager.screen_to_world(click_pos)
        
        # Store the current view mode for proper context
        var current_view_mode = CoordinateManager.get_view_mode()
        var mode_text = "WORLD_VIEW" if current_view_mode == CoordinateManager.ViewMode.WORLD_VIEW else "GAME_VIEW"
        
        # Add coordinate to history with mode information
        add_coordinate(world_pos, mode_text)
```

### Validation and Error Prevention

The CoordinateManager provides validation to help prevent common errors:

```gdscript
# Utility method: Check if coordinates were captured in the expected view mode
func validate_coordinates_for_view_mode(points, expected_view_mode):
    # If we're not in the expected view mode, show a warning
    if _current_view_mode != expected_view_mode:
        var actual_mode = "WORLD_VIEW" if _current_view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"
        var expected_mode = "WORLD_VIEW" if expected_view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"
        
        push_warning("CoordinateManager: Coordinate validation warning - Current view mode is " + 
            actual_mode + " but coordinates are expected for " + expected_mode)
            
        # For walkable areas specifically, provide detailed warnings
        if expected_view_mode == ViewMode.WORLD_VIEW:
            push_warning("For walkable areas that span the entire background, coordinates should be captured in WORLD_VIEW mode")
            push_warning("Press 'Alt+W' to switch to WORLD_VIEW mode before capturing coordinates")
        
        return false
    
    return true
```

## Background Scale Factor

The `background_scale_factor` property on `BaseDistrict` controls scaling between coordinates:

```gdscript
# District properties
export var background_scale_factor = 1.0  # Scale factor for coordinate transformations
```

This factor is applied during coordinate transformations:
- Values > 1.0 make world coordinates larger than screen coordinates
- Values < 1.0 make world coordinates smaller than screen coordinates 
- The default value of 1.0 means no scaling is applied

The CoordinateManager handles this automatically:

```gdscript
# Apply scale factor if needed and in world view mode
if _current_district != null and _current_view_mode == ViewMode.WORLD_VIEW:
    if "background_scale_factor" in _current_district:
        var scale_factor = _current_district.background_scale_factor
        if scale_factor != 1.0:
            world_pos = CoordinateSystem.apply_scale_factor(world_pos, scale_factor)
```

## Debugging Coordinate Issues

If you encounter issues with coordinates not appearing where expected:

1. Check which view mode the coordinates were captured in
   ```gdscript
   # Print the current view mode
   var mode = "WORLD_VIEW" if CoordinateManager.get_view_mode() == CoordinateManager.ViewMode.WORLD_VIEW else "GAME_VIEW"
   print("Current view mode: " + mode)
   ```

2. Verify the background_scale_factor value on the district
   ```gdscript
   # Print the background scale factor
   if "background_scale_factor" in district:
       print("Background scale factor: " + str(district.background_scale_factor))
   ```

3. Use the ValidateWalkableArea tool to check coordinates
   ```gdscript
   # Create a validator
   var validator = ValidateWalkableArea.new()
   add_child(validator)
   
   # Test coordinates
   validator.validate([Vector2(100, 100), Vector2(500, 500)])
   ```

4. Test coordinate transformations manually
   ```gdscript
   var screen_pos = get_viewport().get_mouse_position()
   var world_pos = CoordinateManager.screen_to_world(screen_pos)
   var back_to_screen = CoordinateManager.world_to_screen(world_pos)
   print("Screen: ", screen_pos, " World: ", world_pos, " Back to screen: ", back_to_screen)
   ```

## Best Practices

1. **Use the CoordinateManager**: Always use the CoordinateManager for coordinate transformations rather than direct camera or district methods
   ```gdscript
   # Prefer this:
   var world_pos = CoordinateManager.screen_to_world(screen_pos)
   
   # Over this:
   var world_pos = camera.screen_to_world(screen_pos)
   ```

2. **Maintain View Mode Awareness**: Be explicit about which view mode coordinates are captured in
   ```gdscript
   # Document the view mode in comments
   # The following coordinates were captured in WORLD_VIEW mode
   var walkable_coords = PoolVector2Array([
       Vector2(234, 816),     # Top-left edge
       Vector2(-2, 826),      # Left edge
       # ...
   ])
   ```

3. **Transform Between View Modes**: When using coordinates captured in a different view mode, always transform them
   ```gdscript
   # Transform coordinates from World View to Game View
   var game_view_coords = CoordinateManager.transform_coordinate_array(
       world_view_coords,
       CoordinateManager.ViewMode.WORLD_VIEW,
       CoordinateManager.ViewMode.GAME_VIEW
   )
   ```

4. **Validate Coordinates**: Use validation to catch view mode mismatches
   ```gdscript
   # Validate coordinates before using them
   if CoordinateManager.validate_coordinates_for_view_mode(
       points, 
       CoordinateManager.ViewMode.WORLD_VIEW
   ):
       # Use the coordinates
   else:
       # Handle the error
       print("Warning: Coordinates may be in the wrong view mode")
   ```

5. **Document Scale Factors**: When a district uses a non-default scale factor, document it clearly
   ```gdscript
   # This district uses a background scale factor of 1.5
   # All world coordinates will be 1.5x larger than screen coordinates
   export var background_scale_factor = 1.5
   ```

## Related Documents

- [Camera System](camera_system.md): Details on camera behavior and bounds calculation
- [Walkable Area System](walkable_area_system.md): Information on walkable area implementation
- [Debug Tools](debug_tools.md): Documentation for coordinate capture and visualization tools