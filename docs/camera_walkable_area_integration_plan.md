# Camera and Walkable Area Integration Plan

This document outlines a comprehensive plan for addressing issues with the tightly coupled camera and walkable area systems while adhering to the architectural principles defined in `docs/architecture.md`.

## System Analysis

### Current Coupling Points

1. **Coordinate Transformation**:
   - Camera System provides `screen_to_world()` and `world_to_screen()` methods
   - Coordinate Picker references district-specific `screen_to_world_coords()` and `world_to_screen_coords()` methods
   - Missing clear ownership of coordinate transformation between various views (World View vs Game View)

2. **Camera Bounds Calculation**:
   - ScrollingCamera uses walkable areas to define its movement boundaries
   - `_calculate_district_bounds()` depends on properly defined walkable areas
   - Changes to walkable area coordinates directly affect camera behavior

3. **Debugging Visualization**:
   - Debug tools (Coordinate Picker) create inconsistent results between different view modes
   - Visualization settings (visibility) affect usability but not core functionality

4. **Debug System Integration**:
   - Debug tools (`docs/debug_tools.md`) are designed to capture coordinates in World View
   - The documentation explicitly instructs users to press 'V' to toggle full background view before capturing coordinates
   - Debug Coordinate Picker is the primary tool used for defining walkable areas
   - The coordinate picker functions as a mediator between the camera and walkable area systems

### Architecture Principles at Risk

1. **Minimal Coupling (Principle #1)**:
   - Current implementation creates strong dependencies between camera and walkable areas
   - Coordinate transformations span multiple systems without clear responsibility

2. **Single Responsibility (Principle #2)**:
   - Both systems have overlapping responsibilities for coordinate handling
   - No clear ownership of coordinate space transformations

3. **Testability (Principle #4)**:
   - Changes to one system can silently break the other
   - Testing in isolation is difficult due to interdependencies

## Implementation Plan

This plan follows a phased approach to address issues while minimizing risk. Each phase builds on the previous one and focuses on specific architectural improvements.

### Phase 1: Fix Immediate Issues (LOW RISK)

**Objective**: Restore correct walkable area functionality without breaking camera system.

**Actions**:

1. **Restore Working Coordinates**:
   - Edit `src/test/clean_camera_test.gd` to restore the original, working walkable area coordinates from commit 3ceb3e7
   - Test camera behavior extensively after restoring coordinates to ensure no regressions

2. **Fix Debug Coordinates System**:
   - Identify the last commit where the debug coordinates system functioned correctly
   - Compare debug_manager.gd, coordinate_picker.gd, and related debug files between working and current versions
   - Apply necessary fixes to restore proper coordinate capture and transformation functionality
   - Test coordinate capture in both World View and Game View modes

3. **Document the Fix**:
   - Add detailed comments explaining the coordinate system and its importance
   - Note the camera-walkable area relationship to prevent future issues
   - Document the correct process for capturing walkable area coordinates

### Phase 2: Clear Interface Definition (MEDIUM RISK)

**Objective**: Establish clear responsibilities and interfaces between systems.

**Actions**:

1. **Define Coordinate System Interface**:
   - Create a new class `src/core/coordinate_system.gd` following Single Responsibility principle
   - Implement standard methods for coordinate transformations between different spaces
   - Document the different coordinate spaces (Screen, World, Local) and their relationships

2. **Update District Implementation**:
   - Add proper implementations of `screen_to_world_coords()` and `world_to_screen_coords()` to `BaseDistrict`
   - Define the `background_scale_factor` property with proper documentation
   - Ensure implementation properly handles both World View and Game View

3. **Update Coordinate Picker**:
   - Modify to use the newly defined interfaces for coordinate transformation
   - Add clear warnings about coordinate spaces when capturing in different modes
   - Improve validation to prevent incorrect coordinate usage

### Phase 3: Decoupling and Testing (MEDIUM-HIGH RISK)

**Objective**: Reduce coupling between systems while preserving functionality.

**Actions**:

1. **Introduce Coordinate Manager**:
   - Implement a singleton `CoordinateManager` to handle all coordinate transformations
   - Move transformation logic from individual components to this manager
   - Update all components to use this central service

2. **Refactor Camera Bounds Calculation**:
   - Create a `BoundsCalculator` service that generates camera bounds from walkable areas
   - Modify ScrollingCamera to use this service instead of direct walkable area manipulation
   - This creates a buffer layer between the two systems

3. **Improve Debug System Integration**:
   - Update `coordinate_picker.gd` to explicitly indicate when in World View vs Game View
   - Add validation to prevent usage of untransformed coordinates between views
   - Add warning dialogs when attempting to use coordinates captured in the wrong view mode
   - Implement a "Validate Walkable Area" debug command to check for common issues

4. **Create Comprehensive Tests**:
   - Implement test scenes for coordinate transformations in different views
   - Add automated tests for camera bounds calculation 
   - Create regression tests that verify walkable areas work correctly with camera system
   - Test coordinate capture in both World View and Game View

### Phase 4: Documentation and Standardization (LOW RISK)

**Objective**: Ensure long-term maintainability and prevent regression.

**Actions**:

1. **Enhance Existing Documentation**:
   - Update `docs/walkable_area_system.md` with implementation details
   - Create `docs/coordinate_system.md` explaining all coordinate spaces
   - Add `docs/camera_system.md` with details on camera bounds calculation
   - Update `docs/debug_tools.md` with clear instructions on coordinate capture in different view modes

2. **Create Debug Visualizations**:
   - Implement a debug overlay showing coordinate systems
   - Add visual indicators for coordinate transformations
   - Create a dedicated debug tool for walkable area editing
   - Add color-coding to show coordinates captured in different view modes

3. **Standardize Workflows**:
   - Define clear procedures for adding/editing walkable areas
   - Create standard testing protocol for changes to either system
   - Document common pitfalls and their solutions
   - Create a step-by-step guide for capturing and using coordinates
   - Add walkable area validation steps to the development workflow

## Implementation Details

### Coordinate System Interface

```gdscript
# src/core/coordinate_system.gd
class_name CoordinateSystem
extends Reference

# Convert screen coordinates to world coordinates
static func screen_to_world(screen_pos: Vector2, camera: Camera2D) -> Vector2:
    if camera.has_method("screen_to_world"):
        return camera.screen_to_world(screen_pos)
    return camera.global_position + ((screen_pos - get_viewport_rect().size/2) * camera.zoom)

# Convert world coordinates to screen coordinates
static func world_to_screen(world_pos: Vector2, camera: Camera2D) -> Vector2:
    if camera.has_method("world_to_screen"):
        return camera.world_to_screen(world_pos)
    return (world_pos - camera.global_position) / camera.zoom + get_viewport_rect().size/2

# Convert between world view and game view coordinates
static func world_view_to_game_view(world_view_pos: Vector2, district: BaseDistrict) -> Vector2:
    # Implementation details here
    pass

# Convert between game view and world view coordinates
static func game_view_to_world_view(game_view_pos: Vector2, district: BaseDistrict) -> Vector2:
    # Implementation details here
    pass
```

### BaseDistrict Implementation

```gdscript
# Additions to src/core/districts/base_district.gd

# Scale factor for the background (affects coordinate transformations)
export var background_scale_factor: float = 1.0

# Convert screen coordinates to world coordinates
func screen_to_world_coords(screen_pos: Vector2) -> Vector2:
    # Find the camera
    var camera = get_camera()
    if camera:
        # Use CoordinateSystem utility for conversion
        return CoordinateSystem.screen_to_world(screen_pos, camera)
    return screen_pos

# Convert world coordinates to screen coordinates
func world_to_screen_coords(world_pos: Vector2) -> Vector2:
    # Find the camera
    var camera = get_camera()
    if camera:
        # Use CoordinateSystem utility for conversion
        return CoordinateSystem.world_to_screen(world_pos, camera)
    return world_pos

# Get the camera in this district
func get_camera() -> Camera2D:
    # Find a camera in the district
    for child in get_children():
        if child is Camera2D:
            return child
    return null
```

### BoundsCalculator Implementation

```gdscript
# src/core/camera/bounds_calculator.gd
class_name BoundsCalculator
extends Reference

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

# Apply safety checks and corrections to the calculated bounds
static func apply_safety_corrections(bounds: Rect2) -> Rect2:
    # Implementation details here
    # Ensure minimum size, adjust height for floor walkable areas, etc.
    return bounds
```

## Testing Strategy

### Unit Tests for Coordinate Transformations

1. Test screen_to_world and world_to_screen with various camera positions and zoom levels
2. Test coordinate transformations between World View and Game View
3. Verify all coordinate transformations are bidirectional (A→B→A should return original value)

### Integration Tests for Camera-Walkable Area Interaction

1. Test camera bounds calculation with different walkable area shapes
2. Verify camera stays within bounds when player approaches edges
3. Test camera behavior with all view positions (left, center, right)

### Regression Tests

1. Create test case that reproduces the original issue
2. Verify fix works correctly without breaking other functionality
3. Add test to prevent future regressions

## Risk Assessment

| Action | Risk Level | Potential Issues | Mitigation |
|--------|------------|------------------|------------|
| Restore working coordinates | LOW | Minor visual changes | Test extensively before committing |
| Fix debug coordinates system | MEDIUM | May affect coordinate capture in other scenes | Apply minimal changes, thoroughly test before and after |
| Implement missing methods in BaseDistrict | MEDIUM | Conflicts with existing code | Start with minimal implementations, then expand |
| Create CoordinateSystem class | MEDIUM | Overlooking edge cases | Thorough testing with various scenarios |
| Refactor camera bounds calculation | HIGH | Breaking camera functionality | Create parallel implementation before switching |
| Documentation updates | LOW | None | N/A |

## Success Criteria

1. Clean_camera_test scene shows correct walkable area spanning the entire floor
2. Camera properly constrains to walkable area boundaries
3. All camera views (left, center, right) work correctly
4. Coordinate picker captures and transforms coordinates correctly in both view modes
5. All architectural principles are properly followed, especially minimal coupling and single responsibility

By following this phased approach, we can address the issues while minimizing risk of breaking working functionality and ensuring adherence to the project's architectural principles.