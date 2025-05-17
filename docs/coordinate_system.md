# Coordinate System Documentation

This document explains the coordinate systems used in A Silent Refraction, including how coordinates are transformed between different spaces and how to properly capture and use coordinates for walkable areas and other game elements.

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

## Coordinate Transformations

Converting between coordinate spaces is handled by several transformation methods:

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

## View Modes and Coordinate Capture

The game supports two main view modes that affect how coordinates are captured and used:

1. **Game View**: Normal playing perspective with the camera at the correct position and zoom
2. **World View**: Zoomed-out debug view showing the entire scene/background

### Capturing Coordinates in World View

When capturing coordinates for walkable areas or other large elements:

1. Press V to toggle World View (shows the entire background)
2. Use the debug coordinate picker (press F1 or type 'debug coordinates' in console)
3. Click to capture coordinates
4. The coordinate picker will automatically handle the transformation
5. Press C to copy the last coordinate in the correct format for code

### Important Considerations

1. **Coordinate Consistency**: Always capture coordinate sets in the SAME view mode
2. **World View for Large Areas**: Use World View for walkable areas that span more than one screen
3. **Game View for Local Interactions**: Use Game View for interactive objects and local elements

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

## Debugging Coordinate Issues

If you encounter issues with coordinates not appearing where expected:

1. Check which view mode the coordinates were captured in
2. Verify the background_scale_factor value on the district
3. Test coordinate transformation by printing both screen and world values:
   ```gdscript
   var screen_pos = get_viewport().get_mouse_position()
   var world_pos = get_district().screen_to_world_coords(screen_pos)
   print("Screen: ", screen_pos, " World: ", world_pos)
   ```
4. For walkable areas, verify the coordinates are in the proper space for that area

## Best Practices

1. **Capturing Walkable Areas**: Always use World View for walkable areas that span the entire background
2. **Use District Transformations**: Always use the district's transformation methods rather than direct camera transformations
3. **Document Coordinate Space**: Comment your code to clarify which coordinate space is being used
4. **Test Both Directions**: Test both screen-to-world and world-to-screen transformations to verify they're working correctly

## Related Documents

- [Walkable Area System](walkable_area_system.md): Details on how walkable areas use coordinates
- [Scrolling Camera System](scrolling_camera_system.md): Camera bounds calculation and movement
- [Debug Tools](debug_tools.md): Using the coordinate picker and other debug tools