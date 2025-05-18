# Coordinate Capture and Usage Guide

This guide provides detailed steps for capturing, transforming, and using coordinates in A Silent Refraction. It explains the coordinate systems, view modes, and best practices to ensure consistent results.

## Understanding Coordinate Spaces

Before capturing coordinates, it's important to understand the three coordinate spaces used in the game:

1. **Screen Space**: Coordinates relative to the screen/viewport (0,0 is top-left)
   - Raw mouse position from `get_viewport().get_mouse_position()`
   - UI element positions
   - Directly visible to the player

2. **World Space**: Global game world coordinates
   - Used for positioning game objects
   - Independent of screen/camera position
   - May be affected by background_scale_factor

3. **Local Space**: Coordinates relative to a parent node
   - Points in a walkable area polygon relative to the area's position
   - Child nodes positioned relative to their parent

## Understanding View Modes

The game supports two view modes that affect how coordinates are captured:

1. **Game View**: Normal playing perspective
   - Default view mode
   - Camera positioned according to view settings (left, center, right)
   - Limited visibility of the scene

2. **World View**: Zoomed-out debug view
   - Shows the entire background/scene
   - Activated with Alt+W key combination
   - Used for capturing walkable area coordinates and debugging

## Coordinate Capture Process

### Basic Coordinate Capture

1. **Enable Debug Tools**
   - Press the `` ` `` (backtick/tilde) key to open the debug console
   - Type `debug on` to enable debug tools
   - Type `debug coordinates` to activate the coordinate picker

2. **Select View Mode**
   - For small objects or local interactions, stay in Game View
   - For walkable areas or large backgrounds, press **Alt+W** to switch to World View
   - The coordinate picker will show the current view mode in its display

3. **Capture Coordinates**
   - Click on the point(s) you want to capture
   - The coordinate picker will show:
     - The world coordinates of the point
     - The current view mode (GAME_VIEW or WORLD_VIEW)
     - A numbered list of captured points

4. **Copy Coordinates**
   - Press **C** to copy the last captured coordinate to the clipboard
   - Format: `Vector2(x, y)`
   - Coordinates are also logged to: `~/.local/share/godot/app_userdata/A Silent Refraction/logs/coordinates.log`

### Walkable Area Coordinate Capture

For walkable areas, follow this specific process:

1. **Run the scene**
   - Use `./a_silent_refraction.sh camera` for testing camera integration
   - Or run your district scene directly

2. **Switch to World View**
   - Press **Alt+W** to see the entire background
   - This is critical for walkable areas that span the entire background

3. **Activate the coordinate picker**
   - Type `debug coordinates` in the console

4. **Capture walkable area points**
   - Click on points around the perimeter of the walkable area
   - Start at the top-left corner and work clockwise
   - Capture 8-12 points to accurately represent the shape
   - Ensure the polygon will form a closed shape

5. **Organize coordinates**
   - Copy all coordinates from the log file or as you capture them
   - Format them as a `PoolVector2Array` for use in code:
     ```gdscript
     var walkable_coords = PoolVector2Array([
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
     ```

## Using the CoordinateManager

The CoordinateManager singleton provides a centralized way to transform coordinates between different spaces and view modes.

### Transforming Between Coordinate Spaces

```gdscript
# Transform a screen position to world position
var screen_pos = get_viewport().get_mouse_position()
var world_pos = CoordinateManager.screen_to_world(screen_pos)

# Transform a world position to screen position
var screen_pos = CoordinateManager.world_to_screen(world_pos)

# Transform between local and world space (needs a reference object)
var world_pos = CoordinateManager.local_to_world(local_pos, reference_object)
var local_pos = CoordinateManager.world_to_local(world_pos, reference_object)

# Generic transformation function
var transformed_pos = CoordinateManager.transform_coordinates(
    coords,
    CoordinateManager.CoordinateSpace.SCREEN_SPACE,
    CoordinateManager.CoordinateSpace.WORLD_SPACE
)
```

### Transforming Between View Modes

```gdscript
# Convert coordinates from world view to game view
var game_view_coords = CoordinateManager.transform_view_mode_coordinates(
    world_view_coords,
    CoordinateManager.ViewMode.WORLD_VIEW,
    CoordinateManager.ViewMode.GAME_VIEW
)

# Convert coordinates from game view to world view
var world_view_coords = CoordinateManager.transform_view_mode_coordinates(
    game_view_coords,
    CoordinateManager.ViewMode.GAME_VIEW,
    CoordinateManager.ViewMode.WORLD_VIEW
)

# Transform an array of points (e.g., for walkable area vertices)
var transformed_points = CoordinateManager.transform_coordinate_array(
    original_points,
    CoordinateManager.ViewMode.WORLD_VIEW,
    CoordinateManager.ViewMode.GAME_VIEW
)
```

### Validating Coordinates

```gdscript
# Check if coordinates are in the expected view mode
var is_valid = CoordinateManager.validate_coordinates_for_view_mode(
    points,
    CoordinateManager.ViewMode.WORLD_VIEW
)

if !is_valid:
    print("Warning: Coordinates may be in the wrong view mode")
    # Transform them to the correct view mode
    points = CoordinateManager.transform_coordinate_array(
        points,
        CoordinateManager.get_view_mode(),
        CoordinateManager.ViewMode.WORLD_VIEW
    )
```

## Validating with the Walkable Area Validator

After capturing coordinates, use the ValidateWalkableArea tool to verify they are correctly positioned:

```gdscript
# Create a validator
var validator = ValidateWalkableArea.new()
add_child(validator)

# Define points to validate
var test_points = [
    Vector2(234, 816),
    Vector2(-2, 826),
    Vector2(-2, 944),
    # ... more points ...
]

# Validate points against walkable areas
var result = validator.validate(test_points)

# Result will be true if all points are valid
print("All points valid: " + str(result))
```

Or through the debug console:

```
debug validate_walkable Vector2(234, 816) Vector2(-2, 826) Vector2(-2, 944) ...
```

The validator will:
- Show all walkable areas as semi-transparent green polygons
- Show valid points in green with coordinate information
- Show invalid points in red with distance to nearest walkable area
- Apply necessary coordinate transformations based on current view mode

## Common Scenarios and Solutions

### Scenario 1: Capturing Walkable Area Coordinates

**Problem**: You need to define a walkable area for a new district.

**Solution**:
1. Run the district scene
2. Press Alt+W to switch to World View
3. Type `debug coordinates` to open the coordinate picker
4. Click on the floor perimeter to capture points
5. Press C after each click to copy the coordinate
6. Use the coordinates in a `PoolVector2Array` for the walkable area polygon

### Scenario 2: Coordinates Work in One View but Not the Other

**Problem**: Walkable area coordinates work correctly in World View but not in Game View.

**Solution**:
1. Document which view mode the coordinates were captured in:
   ```gdscript
   # NOTE: These coordinates were captured in WORLD_VIEW mode
   ```
2. Use CoordinateManager to transform between view modes:
   ```gdscript
   var game_view_coords = CoordinateManager.transform_coordinate_array(
       world_view_coords,
       CoordinateManager.ViewMode.WORLD_VIEW,
       CoordinateManager.ViewMode.GAME_VIEW
   )
   ```

### Scenario 3: Coordinate Picker Shows Different Values Than Expected

**Problem**: The coordinate picker shows different values than you expected.

**Solution**:
1. Check the current view mode (displayed in the coordinate picker)
2. Consider the background_scale_factor if the district uses one
3. Use `debug transform_coords` to see how coordinates are transformed
4. Make sure the scene is loaded correctly and the camera is properly positioned

### Scenario 4: Camera Bounds Not Matching Walkable Area

**Problem**: Camera bounds don't match the walkable area despite using the same coordinates.

**Solution**:
1. Check BoundsCalculator output in the console:
   ```
   ========== DISTRICT BOUNDS CALCULATION STARTED ==========
   ```
2. Verify walkable area dimensions in the output
3. Check if the BoundsCalculator is applying safety corrections:
   ```
   # Very small height (normal for floor walkable areas)
   if corrected_bounds.size.y < 100:
       # Expand the height slightly for better camera behavior
   ```
4. Use `debug validate_walkable` to verify your coordinates

## Best Practices

1. **Document View Mode**
   - Always note which view mode coordinates were captured in
   - Add a comment to your code:
     ```gdscript
     # NOTE: These coordinates were captured in WORLD_VIEW mode
     ```

2. **Use World View for Walkable Areas**
   - Always capture walkable area coordinates in World View mode
   - Press Alt+W to toggle World View before capturing

3. **Test in Both View Modes**
   - Test your coordinates in both Game View and World View
   - Use the validator to check coordinates in both modes

4. **Validate Before Implementing**
   - Always validate coordinates before using them in code
   - Use `debug validate_walkable` to check walkable area coordinates
   - Check that all points are valid (shown in green)

5. **Use Descriptive Comments**
   - Add comments to describe what each coordinate represents:
     ```gdscript
     Vector2(234, 816),     # Top-left edge
     Vector2(-2, 826),      # Left edge
     Vector2(-2, 944),      # Bottom-left corner
     ```

6. **Keep Coordinates Organized**
   - Group related coordinates together
   - Use a consistent order (e.g., clockwise from top-left)
   - Format arrays with one coordinate per line for readability

7. **Use the CoordinateManager**
   - Always use CoordinateManager for coordinate transformations
   - Avoid direct camera or district transformation methods
   - This ensures consistent behavior across the game

## Reference Implementation

```gdscript
# Example of capturing and using coordinates for a walkable area

# Step 1: Capture coordinates in World View mode
# (Press Alt+W and use debug coordinates)

# Step 2: Create the walkable area using the captured coordinates
func setup_walkable_area():
    var walkable = Polygon2D.new()
    walkable.name = "WalkableArea"
    walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green
    
    # NOTE: These coordinates were captured in WORLD_VIEW mode
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
    
    walkable.visible = OS.is_debug_build()
    return walkable

# Step 3: Validate the coordinates
func validate_walkable_area_coordinates():
    var validator = ValidateWalkableArea.new()
    add_child(validator)
    
    var coordinates = [
        Vector2(234, 816),
        Vector2(-2, 826),
        Vector2(-2, 944),
        Vector2(4686, 944),
        Vector2(4676, 840),
        Vector2(3672, 854),
        Vector2(3186, 812),
        Vector2(1942, 802),
        Vector2(692, 851),
        Vector2(480, 889),
        Vector2(258, 871)
    ]
    
    return validator.validate(coordinates)
```

## Related Documentation

- [Camera System](camera_system.md): Details on camera bounds calculation
- [Walkable Area System](walkable_area_system.md): Information on the walkable area implementation
- [Walkable Area Workflow](walkable_area_workflow.md): Step-by-step workflow for walkable areas
- [Debug Tools](debug_tools.md): Information on the debug tools for coordinate capture