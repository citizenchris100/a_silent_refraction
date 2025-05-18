# Phase 4 Testing Guide

This document provides step-by-step instructions for testing all the new systems and features implemented in Phase 4 of the camera and walkable area integration plan.

## 1. Coordinate Debug Overlay

### How to Activate
1. Launch any scene with a camera (e.g., `./a_silent_refraction.sh camera`)
2. Press backtick (`) to open the debug console
3. Type `debug coordinate_overlay` and press Enter
   - Alternative: Press F4 if the binding is activated

### What to Test
- **View Mode Display**: Verify the overlay correctly shows "Game View" or "World View"
- **Mouse Position**: Move your mouse around and confirm both screen and world coordinates update
- **Coordinate Spaces**: Check that all three coordinate spaces (Screen, World, Local) are displayed
- **Camera Information**: Verify camera position and zoom are accurately displayed

### Expected Results
- The overlay should appear in the corner of the screen
- It should update in real-time as you move the mouse
- When you switch view modes (Alt+W), the overlay should reflect the change
- Camera information should match what you see in the scene

## 2. Coordinate Transformation Visualizer

### How to Activate
1. Launch any scene with a camera
2. Press backtick (`) to open the debug console
3. Type `debug coordinate_visualizer` and press Enter
   - Alternative: Press Alt+V if the binding is activated

### What to Test
- **Point-to-Point Transformations**: Click different areas to see coordinate transformations
- **Animation**: Verify the smooth animation between coordinate spaces
- **Axes Display**: Check that the X and Y axes are clearly visible
- **Space Color-Coding**: Verify different coordinate spaces use different colors

### Expected Results
- When transforming coordinates, you should see animated arrows
- World origin (0,0) should be marked and visible
- Green indicates Game View coordinates
- Orange indicates World View coordinates
- All animations should be smooth and clear

## 3. Color-Coded Coordinate Picker

### How to Activate
1. Launch any scene with a camera
2. Press backtick (`) to open the debug console 
3. Type `debug coordinates` and press Enter
   - Alternative: Press F1 if the binding is activated

### What to Test
- **Game View Coordinates**: Capture coordinates in Game View (default)
- **World View Coordinates**: Press Alt+W to switch to World View, then capture coordinates
- **Color Differentiation**: Verify Game View uses green markers and World View uses orange markers
- **Label Information**: Check that coordinate labels show the view mode
- **Coordinate Persistence**: Make sure coordinates stay visible when switching view modes

### Expected Results
- Game View coordinates should have green markers and labels
- World View coordinates should have orange markers and labels
- Coordinates captured in Game View should remain visible when switching to World View and vice versa
- The coordinate notification panel should be color-coded to match the current view mode

## 4. Walkable Area Editor

### How to Activate
1. Launch any scene with a camera
2. Press backtick (`) to open the debug console
3. Type `debug edit_walkable` and press Enter
   - Alternative: Press Alt+E if the binding is activated

### What to Test
- **Point Adding**: Press 3 to enter Add mode, then click to add points
- **Point Moving**: Press 2 to enter Move mode, then drag points
- **Point Deletion**: Press 4 to enter Delete mode, then click points to remove them
- **Full Polygon Movement**: Press 5 to enter Drag All mode, then drag the entire polygon
- **Code Generation**: Press P to generate code for the walkable area
- **Coordinate Space Awareness**: Test editor in both Game View and World View modes

### Expected Results
- Points should add, move, and delete correctly
- Generated code should match the visible polygon
- The editor should work correctly in both view modes
- Help text should display when pressing H
- The polygon should be properly validated when generated

## 5. Testing the CoordinateManager Integration

### How to Test
1. Launch the camera test scene (`./a_silent_refraction.sh camera`)
2. Toggle between Game View and World View (Alt+W)
3. Use the coordinate picker to capture coordinates in both modes
4. Open the debug console (`) and run various coordinate tools
5. Check that coordinate transformations work correctly

### Expected Results
- CoordinateManager should detect view mode changes
- Coordinates should transform correctly between modes
- Debug tools should work seamlessly with the CoordinateManager
- No coordinate-related errors should appear in the console

## 6. Testing the Documentation

The documentation created in Phase 4 should be comprehensive and accurate. Verify by following these tests:

### Camera System Documentation
1. Open `docs/camera_system.md`
2. Follow the examples for camera bounds calculation
3. Verify that all described methods work as documented

### Walkable Area System Documentation
1. Open `docs/walkable_area_system.md`
2. Test the walkable area validation procedures
3. Verify BoundsCalculator behavior matches documentation

### Coordinate System Documentation
1. Open `docs/coordinate_system.md`
2. Test coordinate transformation examples
3. Verify that CoordinateManager API matches documentation

### Debug Tools Documentation
1. Open `docs/debug_tools.md`
2. Test each debug tool as described
3. Verify all keyboard shortcuts work as documented

### Workflow Documentation
1. Open `docs/walkable_area_workflow.md` and `docs/coordinate_capture_guide.md`
2. Follow the step-by-step procedures
3. Verify that following the guides produces expected results

## 7. Edge Case Testing

### Viewport Size Changes
1. Resize the game window to different dimensions
2. Verify that the coordinate systems still work correctly
3. Check that the camera bounds adapt appropriately

### Multiple Walkable Areas
1. Open a scene with multiple walkable areas
2. Test coordinate validation across different areas
3. Verify that bounds calculation correctly incorporates all areas

### Missing Components
1. Test in a scene without a player to ensure graceful handling
2. Test with missing walkable areas
3. Verify appropriate error messages are displayed

## 8. Regression Testing

### Pre-Phase 4 Features
1. Test basic player movement within walkable areas
2. Verify camera following behavior
3. Check that old coordinate picking still works

### Performance Impact
1. Test with large/complex walkable areas
2. Verify that the new debug tools don't significantly impact performance
3. Check frame rate with and without debug tools active

## 9. Testing Protocol Validation

1. Open `docs/camera_walkable_testing_protocol.md`
2. Follow the pre-commit checklist
3. Run through the specified test scenes
4. Verify that the protocol catches potential issues

## 10. Common Pitfalls Document

1. Open `docs/coordinate_walkable_area_pitfalls.md`
2. Deliberately cause each described pitfall
3. Verify that the provided solutions resolve the issues
4. Test the debugging techniques described in the document

---

## Troubleshooting

If issues arise during testing, consult the following:

1. **Debug Console Errors**: Check the debug console for error messages
2. **Logging Output**: Review the console output for warnings or errors
3. **Coordinate Validation**: Use `debug validate_walkable` to check coordinate validity
4. **View Mode Issues**: Ensure CoordinateManager has the correct view mode
5. **Debug Tool Conflicts**: Make sure only one debug tool is active if they conflict

## Reporting Issues

When reporting issues found during testing, please include:

1. The exact test that failed
2. The expected vs. actual behavior
3. Any error messages from the console
4. Steps to reproduce the issue
5. The game view mode (Game View or World View) when the issue occurred

This helps ensure all issues can be properly addressed and fixed.