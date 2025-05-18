# Common Pitfalls and Solutions: Walkable Areas and Coordinate Systems

This document outlines common issues developers may encounter when working with walkable areas and coordinate systems in A Silent Refraction, along with their solutions.

## Coordinate System Pitfalls

### 1. Mixing Coordinate Spaces

**Problem:** Coordinates captured in one space (e.g., screen space) are used directly in another space (e.g., world space) without proper transformation.

**Symptoms:**
- Objects positioned incorrectly
- Player moves to wrong locations
- UI elements misaligned with game objects

**Solution:**
- Always use the `CoordinateManager` to transform coordinates between spaces
- Use code like: `var world_pos = CoordinateManager.screen_to_world(screen_pos)`
- Check the current view mode with `CoordinateManager.get_view_mode()`
- Use the coordinate debug overlay (Alt+D) to visualize coordinate spaces

### 2. Using Raw Coordinates Without Considering View Mode

**Problem:** Coordinates captured in World View are used in Game View contexts or vice versa.

**Symptoms:**
- Coordinates are dramatically offset in different view modes
- Walkable areas don't align with visual elements
- Player movement seems incorrect in one view mode

**Solution:**
- Always capture coordinates in the appropriate view mode for their intended use
- Use the color-coded coordinate picker to track which view mode was active
- Transform between view modes with `CoordinateManager.transform_view_mode_coordinates()`
- Standardize your team on which view mode to use for specific tasks

### 3. Not Accounting for District Scale Factors

**Problem:** Coordinates are used without accounting for district scale factors.

**Symptoms:**
- Elements positioned correctly in some districts but not others
- Unexpected behavior when moving between districts
- Scaling issues with walkable areas

**Solution:**
- Always access coordinates through the `CoordinateManager`
- Ensure the `CoordinateManager` is updated with the current district
- Check district scale factors with `district.background_scale_factor`
- Use the coordinate visualizer tool (Alt+V) to see transformations

### 4. Using Hardcoded Viewport Dimensions

**Problem:** Code assumes fixed viewport dimensions rather than getting actual dimensions.

**Symptoms:**
- UI elements mispositioned on different screen sizes
- Camera behavior changes with window resizing
- Coordinate calculations off-center

**Solution:**
- Always use `get_viewport_rect().size` to get current dimensions
- Avoid fixed pixel positions when possible
- Use relative positioning based on viewport size
- Test on different viewport sizes

## Walkable Area Pitfalls

### 1. Self-Intersecting Polygons

**Problem:** Walkable area polygons have vertices that create self-intersections.

**Symptoms:**
- Erratic player movement
- Unexpected navigation failures
- Areas where player should be able to walk but can't

**Solution:**
- Use the walkable area editor (Alt+E) to visualize polygons
- Check for polygon segments that cross each other
- Simplify complex polygons into multiple non-intersecting shapes
- Run validation on walkable areas with `debug validate_walkable`

### 2. Clockwise vs. Counter-Clockwise Vertex Order

**Problem:** Polygon vertices are ordered in the wrong direction.

**Symptoms:**
- Walkable area appears to work but certain calculations fail
- Issue may only appear in specific situations
- Collision detection may behave strangely

**Solution:**
- Standardize on counter-clockwise vertex order for all polygons
- Use the walkable area editor which enforces correct ordering
- Verify with `debug validate_walkable` which checks ordering
- If needed, reverse vertex order with `polygon.invert()`

### 3. Missing Group Assignment

**Problem:** Walkable area nodes aren't added to the "walkable_area" group.

**Symptoms:**
- Areas not recognized as walkable
- Camera bounds calculations ignore certain areas
- ValidateWalkableArea tool doesn't find the areas

**Solution:**
- Always add walkable areas to the "walkable_area" group
- Use `area.add_to_group("walkable_area")` in code
- When creating areas in the editor, add to the group in the Inspector
- Use the walkable area editor which automatically handles grouping

### 4. Polygon Coordinate Precision Issues

**Problem:** Using floating-point coordinates can cause precision issues.

**Symptoms:**
- Slight jitter at polygon edges
- Inconsistent collision detection
- Areas where player gets "stuck"

**Solution:**
- Round coordinates to integers: `Vector2(int(position.x), int(position.y))`
- Use the coordinate picker which automatically rounds for you
- Avoid unnecessary decimal precision in polygon definitions
- Test edge cases with the validate_walkable command

## Camera System Pitfalls

### 1. Improper Bounds Calculation

**Problem:** Camera bounds are calculated incorrectly relative to walkable areas.

**Symptoms:**
- Camera shows empty areas outside the playable zone
- Camera stops following player too early
- Visual elements cut off at the edges

**Solution:**
- Use the `BoundsCalculator` service to calculate bounds
- Ensure walkable areas are properly defined
- Call `camera.update_bounds()` when walkable areas change
- Test with the camera test scene

### 2. Conflicting Zoom Settings

**Problem:** Multiple systems trying to control camera zoom simultaneously.

**Symptoms:**
- Camera zoom changes unexpectedly
- Zoom level resets during gameplay
- Inconsistent view size

**Solution:**
- Use the `auto_adjust_zoom` property consistently
- Don't manually set zoom while `auto_adjust_zoom` is enabled
- Coordinate zoom changes through a single controller
- Test view transitions with Alt+W toggle

### 3. Inconsistent Camera Smoothing

**Problem:** Camera smoothing settings conflict with position updates.

**Symptoms:**
- Camera movement feels jerky
- Camera overshoots target position
- Elastic-like camera behavior

**Solution:**
- Use consistent easing settings
- Check if `smoothing_enabled` is set correctly
- Adjust `follow_smoothing` parameter to taste
- Don't force position updates while smoothing is active

## Debugging Techniques

### Coordinate Systems

1. **View Mode Inspection:**
   ```gdscript
   var view_mode = CoordinateManager.get_view_mode()
   print("Current view mode: " + ("WORLD_VIEW" if view_mode == CoordinateManager.ViewMode.WORLD_VIEW else "GAME_VIEW"))
   ```

2. **Coordinate Transformation Test:**
   ```gdscript
   var screen_pos = get_viewport().get_mouse_position()
   var world_pos = CoordinateManager.screen_to_world(screen_pos)
   print("Screen: " + str(screen_pos) + " → World: " + str(world_pos))
   ```

3. **Debug Commands:**
   - `debug coordinate_overlay` - Show the coordinate system debug overlay
   - `debug coordinate_visualizer` - Show visual indicators for transformations
   - `debug coordinates` - Activate the coordinate picker

### Walkable Areas

1. **Walkable Area Check:**
   ```gdscript
   func is_point_in_walkable_area(point: Vector2) -> bool:
       var areas = get_tree().get_nodes_in_group("walkable_area")
       for area in areas:
           var local_point = area.to_local(point)
           if Geometry.is_point_in_polygon(local_point, area.polygon):
               return true
       return false
   ```

2. **Debugging Vertex Order:**
   ```gdscript
   func is_counter_clockwise(polygon: PoolVector2Array) -> bool:
       var sum = 0.0
       for i in range(polygon.size()):
           var p1 = polygon[i]
           var p2 = polygon[(i + 1) % polygon.size()]
           sum += (p2.x - p1.x) * (p2.y + p1.y)
       return sum < 0  # Counter-clockwise if sum is negative
   ```

3. **Debug Commands:**
   - `debug edit_walkable` - Open the walkable area editor
   - `debug validate_walkable x1 y1 x2 y2 ...` - Check if points are in walkable areas

## Best Practices

1. **Always Use the CoordinateManager:** Let it handle all coordinate transformations.

2. **Color Code by View Mode:** Use green for Game View and orange for World View coordinates.

3. **Document Coordinate Space:** In comments, specify which coordinate space your values use.

4. **Validate Walkable Areas:** Run validation whenever changing polygon definitions.

5. **Test All View Modes:** Ensure functionality works in both Game View and World View.

6. **Round Coordinates:** For walkable areas, round to integer values to avoid precision issues.

7. **Use Debug Tools:** Make frequent use of the coordinate overlay and visualizer tools.

8. **Follow the Testing Protocol:** Use the standard testing protocol document for thorough testing.

## Reference Table: Common Error Messages and Solutions

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| "Failed to find player in walkable area" | Player position outside all walkable areas | Ensure walkable areas cover all necessary spaces |
| "NaN value detected in camera position" | Division by zero in camera calculations | Check for zero scale factors or dimensions |
| "Coordinate transformation failed" | Missing district reference | Ensure CoordinateManager has the current district |
| "Invalid coordinate space" | Using incorrect enum value | Use CoordinateManager.CoordinateSpace enums |
| "No walkable areas found in group" | Missing group assignment | Add areas to "walkable_area" group |
| "Self-intersecting polygon detected" | Invalid walkable area shape | Fix polygon vertices to avoid intersections |
| "Background scale factor is zero" | Scaling issue in district | Set a valid background_scale_factor |

By following these guidelines and solutions, you can avoid common pitfalls when working with coordinate systems and walkable areas in A Silent Refraction.