# Camera and Walkable Area Testing Protocol

This document outlines a standardized testing protocol for validating changes to the camera system, walkable areas, and coordinate systems. Following this protocol ensures that changes don't introduce regressions and that the systems maintain their expected behavior.

## Pre-Commit Checklist

Before committing any changes to the camera system, walkable areas, or coordinate systems, verify that the following conditions are met:

- [ ] All test scenes run without errors
- [ ] Player movement is properly constrained by walkable areas
- [ ] Camera follows the player as expected
- [ ] Camera respects configured bounds
- [ ] Coordinate transformations work correctly in all view modes
- [ ] All debug tools function properly with the changes

## Test Scenes

Run each of these test scenes to validate different aspects of the system:

### 1. Navigation Test

Run with: `./a_silent_refraction.sh navigation`

This test validates:
- Walkable area boundaries are enforced
- Player movement within walkable areas
- Player cannot move outside walkable areas
- Camera follows player properly

**Test Steps:**
1. Click within the walkable area to move the player
2. Click outside the walkable area and verify the player moves to the nearest valid point
3. Move the player near the edges of the walkable area
4. Verify camera keeps the player in view
5. Verify camera does not show areas outside the configured bounds

### 2. Camera Test

Run with: `./a_silent_refraction.sh clean_camera_test`

This test validates:
- Camera scrolling behavior
- Different view modes (Game View, World View)
- Camera position respects bounds
- Initial view settings (left, right, center)

**Test Steps:**
1. Verify camera initializes in the correct position based on the `initial_view` setting
2. Press Alt+W to toggle World View mode
3. Verify entire background is visible in World View mode
4. Press Alt+W again to return to Game View
5. Move the player to different areas and verify camera follows properly
6. Check camera edge behavior - it should stop at defined bounds

### 3. Debug Tools Test

Run with: `./a_silent_refraction.sh debug_tools_test`

This test validates:
- Coordinate picker tool
- Coordinate transformations
- View mode transitions
- Walkable area validation

**Test Steps:**
1. Press F1 or Alt+C to show the coordinate picker
2. Click to capture coordinates in Game View mode (green markers)
3. Press Alt+W to switch to World View mode
4. Click to capture coordinates in World View mode (orange markers)
5. Verify coordinates are properly color-coded
6. Press Alt+V to show coordinate visualizer
7. Press Alt+E to show walkable area editor
8. Test editing walkable areas
9. Validate coordinates against walkable areas

## Regression Testing

For any change to the camera or walkable area systems, test the following additional scenarios:

### 1. Edge Case Validation

- Test with empty walkable areas
- Test with very small walkable areas
- Test with very large walkable areas
- Test with multiple, disconnected walkable areas

### 2. Performance Testing

- Test camera behavior with many NPCs
- Test with large backgrounds
- Test coordinate transformations with many coordinate points

### 3. Feature-Specific Testing

For **camera changes**:
- Test all easing types
- Test different zoom levels
- Test different margin settings
- Test each `initial_view` option (left, right, center)

For **walkable area changes**:
- Test complex polygon shapes
- Test walkable area validation
- Test coordinate transformation between view modes

For **coordinate system changes**:
- Test all coordinate spaces (Screen, World, Local)
- Test transformations between all spaces
- Test with different district scale factors

## Debug Tools for Testing

Use these tools to assist with testing:

1. **Coordinate Debug Overlay** (Alt+D or `debug coordinate_overlay`)
   - Shows real-time coordinate information
   - Displays current view mode
   - Shows coordinate spaces

2. **Coordinate Visualizer** (Alt+V or `debug coordinate_visualizer`)
   - Visualizes transformations between coordinate spaces
   - Shows animation of coordinate transformations

3. **Walkable Area Editor** (Alt+E or `debug edit_walkable`)
   - Allows creating and editing walkable areas
   - Tests polygon validation
   - Generates code for walkable areas

4. **Coordinate Picker** (F1 or `debug coordinates`)
   - Captures coordinates with color coding by view mode
   - Tests coordinate accuracy

## Automated Tests

Run the following automated tests:

```bash
# Test the coordinate transformation system
./a_silent_refraction.sh test_coordinates

# Test walkable area validation
./a_silent_refraction.sh test_walkable

# Test the camera bounds calculation
./a_silent_refraction.sh test_camera_bounds
```

## Common Issues and Solutions

If tests fail, check for these common issues:

1. **Camera doesn't follow player properly**
   - Verify the player is in the "player" group
   - Check if `follow_player` is enabled
   - Verify edge_margin settings

2. **Player can move outside walkable areas**
   - Check if walkable areas are in the "walkable_area" group
   - Verify input_manager is properly validating positions
   - Check for scale factor issues

3. **Coordinate transformations are incorrect**
   - Verify CoordinateManager has the correct district reference
   - Check if view mode detection is working
   - Verify the BoundsCalculator has correct data

4. **Debug tools don't work**
   - Check key bindings are correctly registered
   - Verify the debug manager is properly instantiated
   - Confirm tool scripts are loaded correctly

## Final Verification

After completing all tests:

1. Run the full game with `./a_silent_refraction.sh run`
2. Test all districts, especially those with complex walkable areas
3. Verify that user experience is smooth and consistent
4. Check console for any warnings or errors