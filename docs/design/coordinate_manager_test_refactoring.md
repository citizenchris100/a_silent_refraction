# Coordinate Manager Test Refactoring Plan

## Key Issues

1. **Error in the test file compilation**: The error in the log shows "The identifier 'test_district_management_suite' isn't declared in the current scope" which suggests a syntax error or definition issue with the test functions.

2. **MockDistrict implementation**: 
   - The class implements `_get` which handles property access but might not be properly handling all aspects needed for the 'in' operator tests.
   - The `_get_property_list` might need adjustments to properly expose properties.

3. **Timeout in run_suite_with_timeout function**: 
   - The test protection looks incomplete as it sets up a timer and connects a timeout handler, but the handler may not properly interrupt the running test.

4. **Camera access in tests**:
   - The mock camera setup might not be properly initialized or might be getting disconnected.

5. **Funcref use in mock district**: 
   - Using a funcref for the `get_camera` method might be problematic if referencing self rather than the mockDistrict instance.

## Proposed Solution

I recommend a complete overhaul of the test file implementation with these changes:

1. **Simplify the MockDistrict class**:
   ```gdscript
   class MockDistrict extends Node2D:
       var district_name = "Test District"
       var background_scale_factor = 2.0
       var _camera = null
       
       func _init():
           pass
       
       func get_camera():
           return _camera
           
       func set_camera(camera):
           _camera = camera
   ```

2. **Streamline test setup**:
   ```gdscript
   func create_mock_district():
       mock_district = MockDistrict.new()
       mock_district.name = "MockDistrict"
       add_child(mock_district)
       
       # Create camera and add it directly
       mock_camera = Camera2D.new()
       mock_camera.name = "Camera2D"
       mock_camera.zoom = Vector2(1, 1)
       mock_camera.global_position = Vector2(500, 500)
       mock_district.add_child(mock_camera)
       mock_district.set_camera(mock_camera)
   ```

3. **Improve timeout mechanism**:
   ```gdscript
   func run_suite_with_timeout(suite_method):
       var timer = Timer.new()
       add_child(timer)
       timer.wait_time = test_timeout
       timer.one_shot = true
       timer.start()
       
       var suite_done = false
       
       # Start the test suite
       var suite_result = suite_method.call_func()
       
       # If the suite returns something that can be yielded on, yield to it
       if suite_result and suite_result.is_valid():
           yield(suite_result, "completed")
       
       suite_done = true
       timer.queue_free()
       
       # If we get here before the timer finishes, the test completed normally
       if timer.is_inside_tree():
           timer.stop()
           timer.queue_free()
   ```

4. **Fix the run_tests function**:
   ```gdscript
   func run_tests():
       debug_log("Starting CoordinateManager tests...")
       
       # Reset test counters
       tests_passed = 0
       tests_failed = 0
       failed_tests = []
       test_results = {}
       
       # Run limited set of tests first to diagnose issues
       yield(test_district_management_suite(), "completed")
       
       # If that works, run more tests
       if tests_failed == 0:
           yield(test_view_mode_management_suite(), "completed")
           # Add more tests if previous ones work
       
       debug_log("All tests completed.")
   ```

5. **Use direct method definitions instead of FuncRefs**:
   Remove the use of funcref and implement the get_camera method directly on the MockDistrict.

## Implementation Plan

1. Create a completely new file: coordinate_manager_test_new.gd
2. Implement the simplified MockDistrict
3. Add basic test setup for camera and district
4. Add a minimal test suite that just tests getting the camera
5. Gradually add more tests after confirming the basics work
6. Replace the original test file once the new one is working

This solution completely rebuilds the test approach, focusing on simplicity and reliability rather than trying to patch the existing complex implementation.

## Proposed Additional Tests for Future Enhancement

The following tests would provide more robust validation while maintaining the clean structure:

1. **Precise coordinate transformation tests**:
   ```gdscript
   func test_precise_coordinate_transformations():
       # Test with known coordinate pairs and exact expected results
       var screen_pos = Vector2(100, 100)
       var expected_world_pos = Vector2(100 - get_viewport_rect().size.x/2, 100 - get_viewport_rect().size.y/2) * mock_camera.zoom + mock_camera.global_position
       
       var actual_world_pos = manager.screen_to_world(screen_pos)
       
       var precision_ok = actual_world_pos.distance_to(expected_world_pos) < 0.01
       # Assert exact transformation results
   ```

2. **Scale factor tests**:
   ```gdscript
   func test_scale_factor_application():
       # Setup a custom scale factor
       mock_district.background_scale_factor = 3.0
       
       # Test point in world view
       manager.set_view_mode(manager.ViewMode.WORLD_VIEW)
       var point = Vector2(300, 300)
       
       # Transform from world view to game view
       var game_view_point = manager.transform_view_mode_coordinates(
           point,
           manager.ViewMode.WORLD_VIEW,
           manager.ViewMode.GAME_VIEW
       )
       
       # Expected: divide by scale factor
       var expected_point = Vector2(100, 100)  # 300 / 3.0
       
       # Verify correct transformation
       var scale_ok = game_view_point.distance_to(expected_point) < 0.01
   ```

3. **Array transformation tests**:
   ```gdscript
   func test_coordinate_array_transformations():
       # Test array of coordinates
       var points = PoolVector2Array([
           Vector2(100, 100),
           Vector2(200, 200),
           Vector2(300, 300)
       ])
       
       # Set scale factor for testing
       mock_district.background_scale_factor = 2.0
       
       # Transform array from game view to world view
       var transformed = manager.transform_coordinate_array(
           points,
           manager.ViewMode.GAME_VIEW,
           manager.ViewMode.WORLD_VIEW
       )
       
       # Verify each point was correctly transformed
       var expected = PoolVector2Array([
           Vector2(200, 200),  # 100 * 2.0
           Vector2(400, 400),  # 200 * 2.0
           Vector2(600, 600)   # 300 * 2.0
       ])
       
       var all_correct = true
       for i in range(points.size()):
           if transformed[i].distance_to(expected[i]) > 0.01:
               all_correct = false
               break
   ```

4. **Edge case tests**:
   ```gdscript
   func test_edge_cases():
       # Test null district handling
       var saved_district = manager._current_district
       manager._current_district = null
       
       # Operations should gracefully handle null district
       var screen_pos = Vector2(100, 100)
       var result = manager.screen_to_world(screen_pos)
       
       # Should return something reasonable, not crash
       var graceful_null_handling = result != null
       
       # Restore district
       manager._current_district = saved_district
       
       # Test extreme coordinates
       var extreme_pos = Vector2(9999999, 9999999)
       var extreme_result = manager.screen_to_world(extreme_pos)
       
       # Should handle extreme values without crashing
       var handles_extremes = extreme_result != null
   ```

5. **Validate for mismatched view modes**:
   ```gdscript
   func test_validation_for_view_modes():
       # Set to game view
       manager.set_view_mode(manager.ViewMode.GAME_VIEW)
       
       # Create test points
       var points = PoolVector2Array([Vector2(100, 100), Vector2(200, 200)])
       
       # Validate for world view (should fail as we're in game view)
       var validation_result = manager.validate_coordinates_for_view_mode(
           points,
           manager.ViewMode.WORLD_VIEW
       )
       
       # Should correctly identify mismatch
       var correctly_identified = !validation_result
   ```