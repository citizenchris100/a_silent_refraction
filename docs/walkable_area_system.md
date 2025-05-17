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
- **`src/core/debug/coordinate_picker.gd`**: Debug tool for capturing coordinates to define walkable areas

### 2. Walkable Area Creation

Walkable areas can be created in two ways:

1. **Programmatically**: Created in code with specific coordinates (as in `clean_camera_test.gd`)
   ```gdscript
   var walkable = Polygon2D.new()
   walkable.name = "WalkableArea"
   walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green
   walkable.polygon = PoolVector2Array([
       Vector2(15, 861),      # Left edge
       Vector2(491, 889),
       Vector2(671, 865),
       Vector2(1644, 812),
       Vector2(3193, 819),
       Vector2(3669, 865),
       Vector2(4672, 844),    # Right edge
       Vector2(4683, 941),    
       Vector2(11, 930)       # Bottom-left corner
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

The `ScrollingCamera` class uses walkable areas to calculate camera bounds:

1. In `_setup_camera_bounds()`, the camera finds walkable areas from its parent district
2. `_calculate_district_bounds(district)` extracts points from walkable area polygons
3. The resulting bounds rectangle constrains camera movement

```gdscript
func _calculate_district_bounds(district) -> Rect2:
    # Create a Rect2 that encompasses all walkable areas
    var result_bounds = Rect2(0, 0, 0, 0)
    var first_point = true
    
    # Process each walkable area
    for area in district.walkable_areas:
        for i in range(area.polygon.size()):
            var point = area.polygon[i]
            var global_point = area.to_global(point)
            
            if first_point:
                result_bounds = Rect2(global_point, Vector2.ZERO)
                first_point = false
            else:
                result_bounds = result_bounds.expand(global_point)
    
    return result_bounds
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

## Coordinate Systems

A critical aspect of the walkable area system is its interaction with different coordinate spaces:

### 1. Coordinate Spaces

1. **Screen Space**: UI coordinates relative to the viewport (used by mouse clicks)
2. **World Space**: Global game coordinates (used for positioning game objects)
3. **Local Space**: Coordinates relative to a specific object's parent

### 2. Coordinate Transformations

When creating or modifying walkable areas, proper coordinate transformations are crucial:

```gdscript
# In coordinate_picker.gd
func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        var click_pos = get_viewport().get_mouse_position()
        var world_pos = click_pos
        
        if camera:
            # Check if we are in full view mode
            var is_in_full_view = false
            # [Detection code...]
            
            # Convert screen coords to world coords
            if camera.has_method("screen_to_world"):
                world_pos = camera.screen_to_world(click_pos)
            else:
                world_pos = camera.get_global_position() + ((click_pos - get_viewport_rect().size/2) * camera.zoom)
```

### 3. Debugging Views

The system supports two main view modes that affect coordinate handling:

1. **Game View**: Normal playing perspective with properly positioned camera
2. **World View**: Zoomed-out debug view showing the entire scene

Coordinates captured in World View need transformation to work correctly in Game View.

## Common Issues and Solutions

### Issue 1: Walkable Area Not Matching Intended Region

**Cause**: Coordinates defined in the wrong coordinate space (e.g., captured in World View but used directly in Game View)

**Solution**: 
- Ensure coordinates are properly transformed for the context they're used in
- Use the coordinate picker's warnings about "full view mode" and apply appropriate transformations

### Issue 2: Camera Not Following Proper Boundaries

**Cause**: Walkable area too small or incorrectly positioned, giving the camera incorrect bounds

**Solution**:
- Verify walkable area spans the entire intended area
- Check that the walkable area is in the correct groups
- Test all camera views (left, center, right) to ensure proper behavior

### Issue 3: Walkable Area Visible When It Shouldn't Be

**Cause**: Debug settings left enabled in production code

**Solution**:
- Set `walkable.visible = false` for production, only enable for testing
- Use debug tools only in development builds with `if OS.is_debug_build()`

## Best Practices

1. **Create Adequate Walking Space**: Walkable areas should span the entire region where the player can logically walk

2. **Define Clear Boundaries**: Make sure walkable polygon vertices clearly mark the edges of traversable areas

3. **Coordinate Transformation Awareness**:
   - Understand which coordinate system you're working in
   - Apply proper transformations when capturing and using coordinates
   - Be careful with coordinates captured in different view modes

4. **Testing Procedure**:
   - Test walkable areas with the player character to ensure proper movement constraints
   - Test camera behavior at edges of walkable areas
   - Test different camera views (left, center, right) to ensure proper scrolling

5. **Debugging Tips**:
   - Set `walkable.visible = true` temporarily to visualize the area during testing
   - Use coordinate picker's visual markers to verify coordinate positions
   - Test in both World View and Game View to ensure consistency

## Reference Implementation

The `clean_camera_test.gd` script provides an ideal reference implementation that:

1. Defines a properly sized walkable area spanning the full environment
2. Correctly sets up the camera with the walkable area
3. Demonstrates proper coordinate usage

Always refer to this implementation when setting up new walkable areas for districts.