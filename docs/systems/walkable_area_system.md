# Walkable Area System Documentation

This document explains the walkable area system in A Silent Refraction, detailing its purpose, implementation, and integration with other game systems. It serves as a reference for understanding how walkable areas define player movement boundaries and interact with the camera system.

## Overview

The walkable area system defines where the player character can walk within game environments. It uses polygon-based boundaries to constrain player movement and influence camera behavior. The system plays a critical role in:

1. Defining valid movement boundaries for the player
2. Setting camera movement constraints
3. Creating gameplay boundaries within districts

## Key Components

### 1. File Structure and Classes

- **`src/core/districts/walkable_area.gd`**: Base implementation of walkable areas
- **`src/core/districts/base_district.gd`**: Defines district behavior including walkable area management
- **`src/test/clean_camera_test.gd`**: Example implementation of walkable areas in a test scene
- **`src/core/camera/scrolling_camera.gd`**: Camera system that uses walkable areas for boundary calculations
- **`src/core/camera/bounds_calculator.gd`**: Service for calculating camera bounds from walkable areas
- **`src/core/coordinate_manager.gd`**: Singleton for handling coordinate transformations
- **`src/core/debug/coordinate_picker.gd`**: Debug tool for capturing coordinates to define walkable areas
- **`src/core/debug/validate_walkable_area.gd`**: Debug tool for validating walkable area coordinates

### 2. Walkable Area Creation

Walkable areas can be created in two ways:

1. **Programmatically**: Created in code with specific coordinates (as in `clean_camera_test.gd`)
   ```gdscript
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

2. **In the Editor**: Created visually in the Godot editor and added to necessary groups

### 3. Group System

Walkable areas use Godot's group system for identification:

- `walkable_area`: Base group for all walkable areas
- `designer_walkable_area`: Special priority group for walkable areas designed specifically for a scene
- `debug_walkable_area`: Group for temporary walkable areas used in debugging

## Integration with Other Systems

### 1. Camera Integration

The camera system now uses the `BoundsCalculator` service to calculate its boundaries from walkable areas:

```gdscript
# In scrolling_camera.gd
func _calculate_district_bounds(district) -> Rect2:
    # Use the BoundsCalculator service to calculate bounds from walkable areas
    # This decouples the camera system from direct walkable area manipulation
    
    print("\n========== DISTRICT BOUNDS CALCULATION STARTED ==========")
    print("Background dimensions: " + str(district.background_size) if "background_size" in district else "Unknown")
    print("Screen size: " + str(screen_size))
    print("Current camera zoom: " + str(zoom))
    print("Number of walkable areas: " + str(district.walkable_areas.size()))
    
    # Use the BoundsCalculator service to calculate bounds
    var result_bounds = BoundsCalculator.calculate_bounds_from_walkable_areas(district.walkable_areas)
    
    # Further processing and validation...
    
    return result_bounds
```

The `BoundsCalculator` service provides a decoupled way to process walkable areas into camera bounds:

```gdscript
# In bounds_calculator.gd
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

The BoundsCalculator also includes safety corrections for common walkable area issues:

```gdscript
static func apply_safety_corrections(bounds: Rect2, district = null) -> Rect2:
    var corrected_bounds = bounds
    
    # Check 1: Very small height (normal for floor walkable areas)
    if corrected_bounds.size.y < 100:
        # Expand the height slightly for better camera behavior
        var center_y = corrected_bounds.position.y + corrected_bounds.size.y / 2
        var expanded_height = 200 # Enough to show some space above and below the floor
        corrected_bounds.position.y = center_y - expanded_height / 2
        corrected_bounds.size.y = expanded_height
    
    # More safety checks...
    
    return corrected_bounds
```

### 2. Player Movement Constraints

The player controller uses walkable areas to determine valid movement positions:

```gdscript
# In player_controller.gd
func is_position_valid(position: Vector2) -> bool:
    var current_district = get_current_district()
    if current_district:
        return current_district.is_position_walkable(position)
    return false
```

### 3. District Management

Each `BaseDistrict` manages its walkable areas:

```gdscript
# In base_district.gd
func _ready():
    # Clear active walkable areas before searching
    walkable_areas.clear()

    # First, handle any "designer_walkable_area" marked walkable areas
    var designer_areas_found = false
    
    for child in get_children():
        if child.is_in_group("designer_walkable_area"):
            walkable_areas.append(child)
            designer_areas_found = true
            
    # If no designer walkable areas were found, fall back to regular walkable areas
    if not designer_areas_found:
        for child in get_children():
            if child.is_in_group("walkable_area") and !child.is_in_group("debug_walkable_area"):
                walkable_areas.append(child)
```

### 4. Coordinate Manager Integration

The new `CoordinateManager` singleton provides a central service for all coordinate transformations:

```gdscript
# Using CoordinateManager to transform a point from world view to game view
var game_view_point = CoordinateManager.transform_view_mode_coordinates(
    world_view_point,
    CoordinateManager.ViewMode.WORLD_VIEW,
    CoordinateManager.ViewMode.GAME_VIEW
)
```

When working with walkable area coordinates, the CoordinateManager ensures proper transformations:

```gdscript
# In validate_walkable_area.gd
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
    
    # Continue with validation...
```

## Coordinate Systems

A critical aspect of the walkable area system is its interaction with different coordinate spaces:

### 1. Coordinate Spaces

1. **Screen Space**: UI coordinates relative to the viewport (used by mouse clicks)
2. **World Space**: Global game coordinates (used for positioning game objects)
3. **Local Space**: Coordinates relative to a specific object's parent

### 2. View Modes

The system supports two main view modes that affect coordinate handling:

1. **Game View**: Normal playing perspective with properly positioned camera
2. **World View**: Zoomed-out debug view showing the entire scene

Coordinates captured in World View need transformation to work correctly in Game View.

### 3. Coordinate Transformation

The `CoordinateManager` singleton provides methods for transforming between different coordinate spaces and view modes:

```gdscript
# Transform screen to world coordinates
var world_pos = CoordinateManager.screen_to_world(screen_pos)

# Transform world to screen coordinates
var screen_pos = CoordinateManager.world_to_screen(world_pos)

# Transform between world view and game view coordinates
var game_view_coords = CoordinateManager.transform_view_mode_coordinates(
    world_view_coords, 
    CoordinateManager.ViewMode.WORLD_VIEW, 
    CoordinateManager.ViewMode.GAME_VIEW
)
```

## Walkable Area Validation

The new `ValidateWalkableArea` tool provides a way to validate coordinates against walkable areas:

```gdscript
# In a test script
func test_validate_walkable_area():
    # Create a validator
    var validator = ValidateWalkableArea.new()
    add_child(validator)
    
    # Define points to test
    var test_points = [
        Vector2(100, 100),
        Vector2(500, 500),
        Vector2(2000, 900)
    ]
    
    # Validate points against walkable areas
    var result = validator.validate(test_points)
    
    # result contains information about valid and invalid points
    print("All points valid: " + str(result))
```

The validator provides visual feedback for valid and invalid points:

- Valid points are shown in green
- Invalid points are shown in red with a line to the nearest walkable area
- Distance information is displayed for invalid points

## Common Issues and Solutions

### Issue 1: Coordinates in Wrong View Mode

**Cause**: Coordinates defined in the wrong view mode (e.g., captured in World View but used directly in Game View)

**Solution**: 
- Use `CoordinateManager.transform_view_mode_coordinates()` to convert between view modes
- Use `CoordinateManager.validate_coordinates_for_view_mode()` to check for view mode issues
- Press Alt+W to toggle between Game View and World View modes when capturing coordinates

### Issue 2: Camera Not Following Proper Boundaries

**Cause**: Walkable area too small or incorrectly positioned, giving the camera incorrect bounds

**Solution**:
- Use the BoundsCalculator's safety corrections to ensure reasonable camera bounds
- Use the ValidateWalkableArea tool to visualize and check walkable area coverage
- Test all camera views (left, center, right) to ensure proper behavior

### Issue 3: Different Results Between View Modes

**Cause**: Proper coordinate transformations not applied between view modes

**Solution**:
- Always use the CoordinateManager for coordinate transformations
- Document which view mode coordinates were captured in
- Use the ValidateWalkableArea tool to check coordinates in both view modes

## Best Practices

### 1. Coordinate Capture

- Press Alt+W to toggle World View when capturing walkable area coordinates
- Use the coordinate picker (F1) to capture precise coordinates
- Always capture walkable area coordinates in World View for consistent results
- Document the view mode used for any set of coordinates

### 2. Proper Validation

- Use the ValidateWalkableArea tool to check coordinates against walkable areas
- Test walkable areas with the player character to ensure proper constraints
- Validate coordinates for both World View and Game View transformations
- Check camera behavior at walkable area edges in all camera views

### 3. Using BoundsCalculator

- Let BoundsCalculator handle camera bounds calculation
- Use BoundsCalculator's safety corrections for better camera behavior
- Ensure walkable areas are properly defined before using BoundsCalculator
- Create visualizations of bounds during development with `create_bounds_visualization()`

### 4. Debugging Tools

- Set `walkable.visible = true` temporarily to visualize areas during testing
- Use ValidateWalkableArea tool to visualize valid and invalid points
- Check distance to nearest walkable area for invalid points
- Test in both World View and Game View to ensure consistency

## Reference Implementation

The `clean_camera_test.gd` script provides an ideal reference implementation that:

1. Defines a properly sized walkable area spanning the full environment
2. Correctly sets up the camera with the walkable area
3. Demonstrates proper coordinate usage with the new BoundsCalculator
4. Shows how to validate walkable areas

```gdscript
# In clean_camera_test.gd
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

    # Set visibility for debugging
    walkable.visible = OS.is_debug_build()
```

Always refer to this implementation when setting up new walkable areas for districts.