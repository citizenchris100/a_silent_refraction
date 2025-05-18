# Walkable Area Workflow Guide

This document provides step-by-step procedures for creating, editing, and validating walkable areas in A Silent Refraction. Following these standardized workflows will help ensure consistency and avoid common errors.

## Creating a New Walkable Area

### Step 1: Plan the Walkable Area

1. **Identify the floor area** where the player should be able to walk
2. **Consider natural boundaries** like walls, furniture, and other obstacles
3. **Plan for camera behavior** - the walkable area will determine camera bounds
4. **Sketch the rough outline** of your planned walkable area (optional but recommended)

### Step 2: Capture Coordinates in World View

1. Run the scene where you need to add a walkable area
2. Enable debug tools by pressing `` ` `` and typing `debug on`
3. Press **Alt+W** to toggle to World View mode (shows entire background)
4. Type `debug coordinates` in the console to activate the coordinate picker
5. Click on points around the perimeter of your walkable area
   - Start at the top-left corner and work clockwise
   - Capture points at all corners and significant contours
   - Add enough points to accurately represent the shape (usually 8-12 points)
   - Ensure the walkable area forms a closed polygon
6. Copy the coordinates by pressing **C** after each capture, or from the log file
   - Log file location: `~/.local/share/godot/app_userdata/A Silent Refraction/logs/coordinates.log`

### Step 3: Create the Walkable Area in Code

1. Add the following code to your scene's script, typically in a function named `setup_walkable_area()`:

```gdscript
func setup_walkable_area():
    # Create the walkable area node
    var walkable = Polygon2D.new()
    walkable.name = "WalkableArea"
    walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green
    
    # Set the polygon coordinates (captured in World View mode)
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
    
    # Add to appropriate groups
    walkable.add_to_group("designer_walkable_area")
    walkable.add_to_group("walkable_area")
    
    # Add to scene
    add_child(walkable)
    
    # Set visibility for debugging only
    walkable.visible = OS.is_debug_build()
    
    # Document the view mode used for capture
    # NOTE: These coordinates were captured in WORLD_VIEW mode
```

2. Make sure to call this function in your scene's `_ready()` method:

```gdscript
func _ready():
    setup_walkable_area()
    # Other initialization code...
```

### Step 4: Validate the Walkable Area

1. Run the scene with your new walkable area
2. Enable debug tools with `` ` `` key and `debug on`
3. Validate the coordinates with the validate_walkable command:

```
debug validate_walkable Vector2(234, 816) Vector2(-2, 826) Vector2(-2, 944) Vector2(4686, 944) Vector2(4676, 840) Vector2(3672, 854) Vector2(3186, 812) Vector2(1942, 802) Vector2(692, 851) Vector2(480, 889) Vector2(258, 871)
```

4. Check that all points are valid (shown in green)
5. If any points are invalid (shown in red):
   - Note the distance to the nearest walkable area
   - Adjust the coordinates as needed
   - Run the validation again

### Step 5: Test Camera Integration

1. Press **Alt+W** to return to Game View
2. Test all camera views:
   - Set `initial_view = "left"` in the camera properties and test
   - Set `initial_view = "center"` and test
   - Set `initial_view = "right"` and test
3. Test player movement:
   - Make sure the player can walk in all walkable areas
   - Verify the player cannot walk outside the walkable area
   - Check that the camera follows properly near the edges

## Editing an Existing Walkable Area

### Step 1: Visualize the Current Walkable Area

1. Run the scene with the walkable area you want to edit
2. Enable debug tools with `` ` `` key and `debug on`
3. Type `debug polygon` in the console to show the polygon visualizer

### Step 2: Edit the Walkable Area

#### Using the Polygon Visualizer

1. Use number keys to switch between modes:
   - **1**: View/Select Mode
   - **2**: Move Mode (drag vertices)
   - **3**: Add Mode (add new vertices)
   - **4**: Delete Mode (remove vertices)
   - **5**: Drag All Mode (move entire polygon)
2. Edit the walkable area as needed:
   - Move vertices to adjust the boundaries
   - Add vertices to create more detailed contours
   - Delete vertices that aren't needed
3. Press **P** to print/copy the updated polygon data

#### Recapturing in World View

For major changes, it may be easier to recapture the entire walkable area:

1. Press **Alt+W** to switch to World View mode
2. Type `debug coordinates` in the console to show the coordinate picker
3. Capture new coordinates following the steps in "Creating a New Walkable Area"

### Step 3: Update the Code

1. Update the coordinates in the `setup_walkable_area()` function:

```gdscript
walkable.polygon = PoolVector2Array([
    Vector2(234, 816),     # Top-left edge
    Vector2(-2, 826),      # Left edge
    # ... Updated coordinates ...
])
```

2. Document the changes in a code comment
3. Note the view mode used for the coordinates (Game View or World View)

### Step 4: Validate and Test

1. Follow the validation and testing steps from "Creating a New Walkable Area"
2. Ensure all camera views and player movement work correctly

## Debugging Walkable Area Issues

### Issue: Player Can Walk Outside Boundaries

1. Enable debug visualization:
   ```gdscript
   walkable.visible = true
   ```
2. Check if the polygon has gaps or open sections
3. Use validate_walkable to check if problematic coordinates are inside the area
4. Ensure the walkable area is in the correct groups:
   ```gdscript
   walkable.add_to_group("designer_walkable_area")
   walkable.add_to_group("walkable_area")
   ```

### Issue: Camera Bounds Don't Match Walkable Area

1. Check BoundsCalculator output in the console:
   ```
   ========== BOUNDS CALCULATION STARTED ==========
   ```
2. Verify walkable area dimensions in the output
3. Check for any safety corrections applied by BoundsCalculator
4. Make sure coordinates were captured in World View mode
5. Verify the walkable area spans the entire playable space

### Issue: Different Results Between View Modes

1. Check which view mode was used to capture coordinates
2. Use CoordinateManager to transform between view modes:
   ```gdscript
   var game_view_coords = CoordinateManager.transform_coordinate_array(
       world_view_coords,
       CoordinateManager.ViewMode.WORLD_VIEW,
       CoordinateManager.ViewMode.GAME_VIEW
   )
   ```
3. Document the view mode used in code comments

## Best Practices

1. **Always capture walkable areas in World View mode** (Alt+W)
   - This ensures you can see the entire background
   - Allows for defining areas larger than the screen

2. **Document coordinate capture mode**
   ```gdscript
   # NOTE: These coordinates were captured in WORLD_VIEW mode
   walkable.polygon = PoolVector2Array([...])
   ```

3. **Use distinctive naming** for walkable areas
   ```gdscript
   walkable.name = "WalkableArea_MainFloor"
   ```

4. **Keep walkable areas invisible in production**
   ```gdscript
   walkable.visible = OS.is_debug_build()
   ```

5. **Add enough vertices** to accurately represent the walkable shape
   - Add points at all corners and significant contours
   - Typical walkable areas need 8-12 points for accuracy
   - Avoid too many vertices (more than 20) as it increases complexity

6. **Test with all camera views** (left, center, right)
   - Ensure proper camera behavior in all positions
   - Check for edge cases near boundaries

7. **Validate coordinates** before committing changes
   - Use the ValidateWalkableArea tool
   - Verify all points are valid (green)

## Reference Implementation

The `clean_camera_test.gd` script in `src/test/clean_camera_test.gd` provides an ideal reference implementation:

```gdscript
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
    
    # Set visibility for debugging only
    walkable.visible = OS.is_debug_build()
    
    # NOTE: These coordinates were captured in WORLD_VIEW mode
    return walkable
```

Always refer to this implementation when setting up new walkable areas for districts.

## Related Documentation

- [Camera System](camera_system.md): Details on camera bounds calculation
- [Walkable Area System](walkable_area_system.md): Information on the walkable area implementation
- [Coordinate System](coordinate_system.md): Documentation on coordinate spaces and transformations
- [Debug Tools](debug_tools.md): Information on the debug tools for walkable areas