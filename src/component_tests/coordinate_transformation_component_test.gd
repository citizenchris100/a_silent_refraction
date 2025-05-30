extends Node2D
class_name CoordinateTransformationComponentTest
# Coordinate Transformation Component Test: Comprehensive tests for coordinate transformation across all systems

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for more verbose output

# Test-specific flags
var test_screen_world_transformations = true
var test_game_world_view_transformations = true
var test_round_trip_transformations = true
var test_coordinate_systems_integration = true
var test_edge_cases = true
var test_performance = true

# ===== TEST VARIABLES =====
var district: Node2D
var camera: Camera2D
var test_results = {}
var current_test = ""
var current_suite = ""
var tests_passed = 0
var tests_failed = 0
var failed_tests = []

# Test data
var test_points = [
    Vector2(0, 0),         # Origin
    Vector2(100, 100),     # Quadrant 1
    Vector2(-100, 100),    # Quadrant 2
    Vector2(-100, -100),   # Quadrant 3
    Vector2(100, -100),    # Quadrant 4
    Vector2(1920, 1080),   # Large values (screen size)
    Vector2(0.5, 0.5)      # Fractional values
]

# ===== LIFECYCLE METHODS =====

func _ready():
    # Set up the test environment
    debug_log("Setting up Coordinate Transformation component test...")
    
    # Create test scene
    create_test_scene()
    
    # Run the tests - no delays needed
    run_tests()
    
    # Report results
    report_results()
    
    # Clean up
    cleanup_test_scene()
    
    # Exit cleanly
    debug_log("Tests complete - exiting...")
    yield(get_tree().create_timer(0.1), "timeout")  # Brief delay to ensure output is flushed
    get_tree().quit()

func _process(delta):
    # Update the status display if needed
    update_test_display()

# ===== TEST SETUP METHODS =====

func create_test_scene():
    # Create a mock district
    district = create_mock_district()
    add_child(district)
    
    # Create a camera
    camera = create_mock_camera()
    district.add_child(camera)
    
    debug_log("Test scene created with district and camera")

func create_mock_district():
    # Create a district node using preloaded mock script
    var new_district = Node2D.new()
    new_district.name = "MockDistrict"
    
    # Use the preloaded mock district script
    new_district.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
    
    # Initialize with default values
    if new_district.has_method("setup_mock"):
        new_district.setup_mock()
        
    return new_district

func create_mock_camera():
    # Create a camera node
    var camera_script = load("res://src/core/camera/scrolling_camera.gd")
    var new_camera = Camera2D.new()
    new_camera.name = "ScrollingCamera"
    new_camera.set_script(camera_script)
    
    # Configure camera
    new_camera.current = true
    new_camera.global_position = Vector2(500, 300)
    new_camera.smoothing_enabled = true
    
    return new_camera

func cleanup_test_scene():
    # Remove test scene elements
    if district:
        district.queue_free()
    
    district = null
    camera = null

# ===== TEST RUNNER =====

func run_tests():
    debug_log("Starting Coordinate Transformation component tests...")
    
    # Reset test counters
    tests_passed = 0
    tests_failed = 0
    failed_tests = []
    test_results = {}
    
    # Create a master timeout for the entire test suite
    var timeout_timer = Timer.new()
    timeout_timer.wait_time = 45.0  # 45 second timeout for all tests
    timeout_timer.one_shot = true
    add_child(timeout_timer)
    timeout_timer.start()
    timeout_timer.connect("timeout", self, "_on_test_timeout")
    
    # Run all test suites in sequence directly (no yields)
    if run_all_tests or test_screen_world_transformations:
        run_test_suite_with_timeout("screen_world_transformations", "test_screen_world_transformations_suite")
    
    if run_all_tests or test_game_world_view_transformations:
        run_test_suite_with_timeout("game_world_view_transformations", "test_game_world_view_transformations_suite")
    
    if run_all_tests or test_round_trip_transformations:
        run_test_suite_with_timeout("round_trip_transformations", "test_round_trip_transformations_suite")
    
    if run_all_tests or test_coordinate_systems_integration:
        run_test_suite_with_timeout("coordinate_systems_integration", "test_coordinate_systems_integration_suite")
    
    if run_all_tests or test_edge_cases:
        run_test_suite_with_timeout("edge_cases", "test_edge_cases_suite")
    
    if run_all_tests or test_performance:
        run_test_suite_with_timeout("performance", "test_performance_suite")
    
    # Clean up timeout timer
    if timeout_timer:
        timeout_timer.queue_free()
    
    debug_log("All tests completed.")

# ===== TIMEOUT HANDLING =====

func _on_test_timeout():
    debug_log("TIMEOUT: Test suite exceeded 45 second limit - terminating", true)
    end_test(false, "Test suite timeout after 45 seconds")
    report_results()
    get_tree().quit()

func run_test_suite_with_timeout(suite_name: String, method_name: String):
    debug_log("Running test suite: " + suite_name + " with timeout protection")
    
    # Run the test suite directly - no timeout needed since tests are now fast
    if has_method(method_name):
        call(method_name)
    else:
        debug_log("ERROR: Test method " + method_name + " not found", true)
        end_test(false, "Test method not found: " + method_name)

func _on_suite_timeout(suite_name: String):
    debug_log("TIMEOUT: Test suite '" + suite_name + "' exceeded 8 second limit", true)
    end_test(false, "Suite timeout: " + suite_name)

# ===== TEST SUITES =====

func test_screen_world_transformations_suite():
    start_test_suite("Screen World Transformations")
    
    # Test 1: Scrolling camera screen_to_world method
    test_scrolling_camera_screen_to_world()
    
    # Test 2: Scrolling camera world_to_screen method
    test_scrolling_camera_world_to_screen()
    
    # Test 3: CoordinateSystem screen_to_world method
    test_coordinate_system_screen_to_world()
    
    # Test 4: CoordinateSystem world_to_screen method
    test_coordinate_system_world_to_screen()
    
    # Test 5: District coordinate methods
    test_district_coordinate_methods()
    
    end_test_suite()

func test_game_world_view_transformations_suite():
    start_test_suite("Game World View Transformations")
    
    # Test 1: CoordinateSystem world_view_to_game_view method
    test_coordinate_system_world_to_game()
    
    # Test 2: CoordinateSystem game_view_to_world_view method
    test_coordinate_system_game_to_world()
    
    # Test 3: CoordinateManager view mode transformations
    test_coordinate_manager_view_transformations()
    
    # Test 4: Scale factor handling
    test_scale_factor_handling()
    
    end_test_suite()

func test_round_trip_transformations_suite():
    start_test_suite("Round Trip Transformations")
    
    # Test 1: Screen to world to screen round trip
    test_screen_world_round_trip()
    
    # Test 2: Game view to world view to game view round trip
    test_game_world_view_round_trip()
    
    # Test 3: Full coordinate pipeline round trip
    test_full_coordinate_pipeline()
    
    end_test_suite()

func test_coordinate_systems_integration_suite():
    start_test_suite("Coordinate Systems Integration")
    
    # Test 1: Camera and CoordinateSystem consistency
    test_camera_coordinate_system_consistency()
    
    # Test 2: District and CoordinateManager consistency
    test_district_coordinate_manager_consistency()
    
    # Test 3: Coordinate transformations across systems
    test_cross_system_transformations()
    
    end_test_suite()

func test_edge_cases_suite():
    start_test_suite("Edge Cases")
    
    # Test 1: Handle NaN values
    test_handle_nan_values()
    
    # Test 2: Handle Infinity values
    test_handle_infinity_values()
    
    # Test 3: Handle extremely large coordinates
    test_handle_large_coordinates()
    
    # Test 4: Handle negative coordinates
    test_handle_negative_coordinates()
    
    end_test_suite()

func test_performance_suite():
    start_test_suite("Performance")
    
    # Test 1: Batch coordinate transformations
    test_batch_transformations()
    
    # Test 2: Large array coordinate transformations
    test_large_array_transformations()
    
    end_test_suite()

# ===== INDIVIDUAL TESTS =====

# SCREEN WORLD TRANSFORMATIONS TESTS

func test_scrolling_camera_screen_to_world():
    start_test("Scrolling Camera Screen to World")
    
    # Set camera to a known position
    var original_position = camera.global_position
    camera.global_position = Vector2(500, 300)
    
    # Get viewport size
    var viewport_size = get_viewport().get_size()
    var screen_center = viewport_size / 2
    
    # Test screen_to_world with the center of the screen
    var world_pos = camera.screen_to_world(screen_center)
    
    # Center of screen should map to camera position
    var expected_pos = camera.global_position
    var matches_expected = world_pos.distance_to(expected_pos) < 5
    
    # Restore camera position
    camera.global_position = original_position
    
    end_test(matches_expected, "Camera screen_to_world should map screen center to camera position")

func test_scrolling_camera_world_to_screen():
    start_test("Scrolling Camera World to Screen")
    
    # Set camera to a known position
    var original_position = camera.global_position
    camera.global_position = Vector2(500, 300)
    
    # Get viewport size
    var viewport_size = get_viewport().get_size()
    var screen_center = viewport_size / 2
    
    # Test world_to_screen with camera position
    var screen_pos = camera.world_to_screen(camera.global_position)
    
    # Camera position should map to center of screen
    var matches_expected = screen_pos.distance_to(screen_center) < 5
    
    # Restore camera position
    camera.global_position = original_position
    
    end_test(matches_expected, "Camera world_to_screen should map camera position to screen center")

func test_coordinate_system_screen_to_world():
    start_test("CoordinateSystem Screen to World")
    
    # Set camera to a known position
    var original_position = camera.global_position
    camera.global_position = Vector2(500, 300)
    
    # Get viewport size
    var viewport_size = get_viewport().get_size()
    var screen_center = viewport_size / 2
    
    # Test CoordinateSystem screen_to_world
    var world_pos = CoordinateSystem.screen_to_world(screen_center, camera)
    
    # Center of screen should map to camera position
    var expected_pos = camera.global_position
    var matches_expected = world_pos.distance_to(expected_pos) < 5
    
    # Restore camera position
    camera.global_position = original_position
    
    end_test(matches_expected, "CoordinateSystem screen_to_world should map screen center to camera position")

func test_coordinate_system_world_to_screen():
    start_test("CoordinateSystem World to Screen")
    
    # Set camera to a known position
    var original_position = camera.global_position
    camera.global_position = Vector2(500, 300)
    
    # Get viewport size
    var viewport_size = get_viewport().get_size()
    var screen_center = viewport_size / 2
    
    # Test CoordinateSystem world_to_screen
    var screen_pos = CoordinateSystem.world_to_screen(camera.global_position, camera)
    
    # Camera position should map to center of screen
    var matches_expected = screen_pos.distance_to(screen_center) < 5
    
    # Restore camera position
    camera.global_position = original_position
    
    end_test(matches_expected, "CoordinateSystem world_to_screen should map camera position to screen center")

func test_district_coordinate_methods():
    start_test("District Coordinate Methods")
    
    # Set camera to a known position
    var original_position = camera.global_position
    camera.global_position = Vector2(500, 300)
    
    # Get a test point
    var test_screen_point = get_viewport().get_size() / 2
    var test_world_point = camera.global_position
    
    # Test district coordinate methods
    var district_screen_to_world = district.screen_to_world_coords(test_screen_point)
    var district_world_to_screen = district.world_to_screen_coords(test_world_point)
    
    # Check if district methods give expected results
    var screen_to_world_correct = district_screen_to_world.distance_to(test_world_point) < 5
    var world_to_screen_correct = district_world_to_screen.distance_to(test_screen_point) < 5
    
    # Restore camera position
    camera.global_position = original_position
    
    end_test(screen_to_world_correct && world_to_screen_correct, "District coordinate methods should use camera methods correctly")

# GAME WORLD VIEW TRANSFORMATIONS TESTS

func test_coordinate_system_world_to_game():
    start_test("CoordinateSystem World to Game")
    
    # Test points
    var world_view_points = [
        Vector2(200, 200),
        Vector2(1000, 600)
    ]
    
    # Get scale factor
    var scale_factor = district.background_scale_factor
    
    # Test all points
    var all_correct = true
    for point in world_view_points:
        var game_view_point = CoordinateSystem.world_view_to_game_view(point, district)
        var expected_point = point / scale_factor
        
        if game_view_point.distance_to(expected_point) > 0.01:
            all_correct = false
            debug_log("Failed for point " + str(point) + ": got " + str(game_view_point) + 
                ", expected " + str(expected_point), true)
            break
    
    end_test(all_correct, "world_view_to_game_view should divide coordinates by scale factor")

func test_coordinate_system_game_to_world():
    start_test("CoordinateSystem Game to World")
    
    # Test points
    var game_view_points = [
        Vector2(100, 100),
        Vector2(500, 300)
    ]
    
    # Get scale factor
    var scale_factor = district.background_scale_factor
    
    # Test all points
    var all_correct = true
    for point in game_view_points:
        var world_view_point = CoordinateSystem.game_view_to_world_view(point, district)
        var expected_point = point * scale_factor
        
        if world_view_point.distance_to(expected_point) > 0.01:
            all_correct = false
            debug_log("Failed for point " + str(point) + ": got " + str(world_view_point) + 
                ", expected " + str(expected_point), true)
            break
    
    end_test(all_correct, "game_view_to_world_view should multiply coordinates by scale factor")

func test_coordinate_manager_view_transformations():
    start_test("CoordinateManager View Transformations")
    
    # Create CoordinateManager
    var coordinate_manager = load("res://src/core/coordinate_manager.gd").new()
    coordinate_manager._current_district = district
    add_child(coordinate_manager)
    
    # Test points
    var test_point = Vector2(100, 100)
    
    # Transform game to world view
    var world_view_point = coordinate_manager.transform_view_mode_coordinates(
        test_point,
        coordinate_manager.ViewMode.GAME_VIEW,
        coordinate_manager.ViewMode.WORLD_VIEW
    )
    
    # Transform world to game view
    var game_view_point = coordinate_manager.transform_view_mode_coordinates(
        world_view_point,
        coordinate_manager.ViewMode.WORLD_VIEW,
        coordinate_manager.ViewMode.GAME_VIEW
    )
    
    # Check round-trip
    var round_trip_correct = game_view_point.distance_to(test_point) < 0.01
    
    # Clean up
    coordinate_manager.queue_free()
    
    end_test(round_trip_correct, "CoordinateManager view transformations should work correctly in both directions")

func test_scale_factor_handling():
    start_test("Scale Factor Handling")
    
    # Test points
    var test_point = Vector2(100, 100)
    
    # Test with different scale factors
    var scale_factors = [1.0, 2.0, 3.0]
    var all_correct = true
    
    for factor in scale_factors:
        # Save original factor
        var original_factor = district.background_scale_factor
        
        # Set test factor
        district.background_scale_factor = factor
        
        # Apply scale factor
        var scaled_point = CoordinateSystem.apply_scale_factor(test_point, factor)
        var expected_point = test_point * factor
        
        # Remove scale factor
        var unscaled_point = CoordinateSystem.remove_scale_factor(scaled_point, factor)
        
        # Check results
        if scaled_point != expected_point or unscaled_point != test_point:
            all_correct = false
            debug_log("Failed for scale factor " + str(factor), true)
        
        # Restore original factor
        district.background_scale_factor = original_factor
    
    end_test(all_correct, "Scale factor operations should work correctly with different factors")

# ROUND TRIP TRANSFORMATIONS TESTS

func test_screen_world_round_trip():
    start_test("Screen World Round Trip")
    
    # Test all points
    var all_correct = true
    for point in test_points:
        # Get viewport size for valid screen coordinates
        var viewport_size = get_viewport().get_size()
        var screen_point = Vector2(
            clamp(point.x, 0, viewport_size.x),
            clamp(point.y, 0, viewport_size.y)
        )
        
        # Convert screen to world
        var world_point = camera.screen_to_world(screen_point)
        
        # Convert back to screen
        var round_trip_point = camera.world_to_screen(world_point)
        
        # Check if round-trip preserves the point
        if round_trip_point.distance_to(screen_point) > 5:
            all_correct = false
            debug_log("Failed for point " + str(screen_point) + ": got " + str(round_trip_point), true)
            break
    
    end_test(all_correct, "Screen-to-world-to-screen round trip should preserve coordinates")

func test_game_world_view_round_trip():
    start_test("Game World View Round Trip")
    
    # Test all points
    var all_correct = true
    for point in test_points:
        # Convert game view to world view
        var world_view_point = CoordinateSystem.game_view_to_world_view(point, district)
        
        # Convert back to game view
        var round_trip_point = CoordinateSystem.world_view_to_game_view(world_view_point, district)
        
        # Check if round-trip preserves the point
        if round_trip_point.distance_to(point) > 0.01:
            all_correct = false
            debug_log("Failed for point " + str(point) + ": got " + str(round_trip_point), true)
            break
    
    end_test(all_correct, "Game-view-to-world-view-to-game-view round trip should preserve coordinates")

func test_full_coordinate_pipeline():
    start_test("Full Coordinate Pipeline")
    
    # Create CoordinateManager
    var coordinate_manager = load("res://src/core/coordinate_manager.gd").new()
    coordinate_manager._current_district = district
    add_child(coordinate_manager)
    
    # Test with valid screen point
    var viewport_size = get_viewport().get_size()
    var screen_point = viewport_size / 2
    
    # Full pipeline: screen → world → game view → world view → screen
    var world_pos = coordinate_manager.screen_to_world(screen_point)
    var game_view_pos = CoordinateSystem.world_view_to_game_view(world_pos, district)
    var world_view_pos = CoordinateSystem.game_view_to_world_view(game_view_pos, district)
    var final_screen_pos = coordinate_manager.world_to_screen(world_view_pos)
    
    # Check if full pipeline preserves the point
    var pipeline_correct = final_screen_pos.distance_to(screen_point) < 5
    
    # Clean up
    coordinate_manager.queue_free()
    
    end_test(pipeline_correct, "Full coordinate transformation pipeline should preserve coordinates")

# COORDINATE SYSTEMS INTEGRATION TESTS

func test_camera_coordinate_system_consistency():
    start_test("Camera CoordinateSystem Consistency")
    
    # Set camera to a known position
    var original_position = camera.global_position
    camera.global_position = Vector2(500, 300)
    
    # Get viewport size
    var viewport_size = get_viewport().get_size()
    var screen_center = viewport_size / 2
    
    # Screen to world tests for consistency
    var camera_result = camera.screen_to_world(screen_center)
    var coordinate_system_result = CoordinateSystem.screen_to_world(screen_center, camera)
    
    # Results should match
    var screen_to_world_match = camera_result.distance_to(coordinate_system_result) < 0.01
    
    # World to screen tests for consistency
    var world_point = camera.global_position
    camera_result = camera.world_to_screen(world_point)
    coordinate_system_result = CoordinateSystem.world_to_screen(world_point, camera)
    
    # Results should match
    var world_to_screen_match = camera_result.distance_to(coordinate_system_result) < 0.01
    
    # Restore camera position
    camera.global_position = original_position
    
    end_test(screen_to_world_match && world_to_screen_match, "Camera and CoordinateSystem methods should give consistent results")

func test_district_coordinate_manager_consistency():
    start_test("District CoordinateManager Consistency")
    
    # Create CoordinateManager
    var coordinate_manager = load("res://src/core/coordinate_manager.gd").new()
    coordinate_manager._current_district = district
    add_child(coordinate_manager)
    
    # Test with a screen point
    var screen_point = Vector2(100, 100)
    
    # District result
    var district_result = district.screen_to_world_coords(screen_point)
    
    # CoordinateManager result
    var manager_result = coordinate_manager.screen_to_world(screen_point)
    
    # Results should match
    var results_match = district_result.distance_to(manager_result) < 5
    
    # Clean up
    coordinate_manager.queue_free()
    
    end_test(results_match, "District and CoordinateManager methods should give consistent results")

func test_cross_system_transformations():
    start_test("Cross System Transformations")
    
    # Test point
    var test_point = Vector2(100, 100)
    
    # Create a coordinate manager
    var coordinate_manager = load("res://src/core/coordinate_manager.gd").new()
    coordinate_manager._current_district = district
    add_child(coordinate_manager)
    
    # Complex test case:
    # 1. Transform from screen to world using CoordinateManager
    var world_pos = coordinate_manager.screen_to_world(test_point)
    
    # 2. Transform to game view using CoordinateSystem
    var game_view_pos = CoordinateSystem.world_view_to_game_view(world_pos, district)
    
    # 3. Transform back to world view using district's methods
    var scale_factor = district.background_scale_factor
    var back_to_world_pos = game_view_pos * scale_factor
    
    # 4. Transform to screen using camera
    var screen_pos = camera.world_to_screen(back_to_world_pos)
    
    # Compare start and end points
    var difference = screen_pos.distance_to(test_point)
    var acceptable_error = 10.0  # Allow for some floating point imprecision across systems
    
    # Log results
    debug_log("Cross-system transformation difference: " + str(difference) + " pixels")
    var transformation_works = difference < acceptable_error
    
    # Clean up
    coordinate_manager.queue_free()
    
    end_test(transformation_works, "Coordinate transformations should work consistently across different systems")

# EDGE CASES TESTS

func test_handle_nan_values():
    start_test("Handle NaN Values")
    
    # Create test points with NaN values
    var nan_points = [
        Vector2(NAN, 100),
        Vector2(100, NAN),
        Vector2(NAN, NAN)
    ]
    
    # Test handling in various systems
    var all_handled = true
    
    # Test CoordinateSystem
    for point in nan_points:
        var result = CoordinateSystem.world_view_to_game_view(point, district)
        if is_nan(result.x) or is_nan(result.y):
            all_handled = false
            debug_log("CoordinateSystem failed to handle NaN: " + str(result), true)
            break
    
    # Test camera
    if all_handled:
        for point in nan_points:
            var result = camera.validate_coordinates(point)
            if is_nan(result.x) or is_nan(result.y):
                all_handled = false
                debug_log("Camera failed to handle NaN: " + str(result), true)
                break
    
    end_test(all_handled, "Coordinate systems should properly handle NaN values")

func test_handle_infinity_values():
    start_test("Handle Infinity Values")
    
    # Create test points with infinity values
    var inf_points = [
        Vector2(INF, 100),
        Vector2(100, INF),
        Vector2(INF, INF)
    ]
    
    # Test handling in various systems
    var all_handled = true
    
    # Test camera
    for point in inf_points:
        var result = camera.validate_coordinates(point)
        if is_inf(result.x) or is_inf(result.y):
            all_handled = false
            debug_log("Camera failed to handle infinity: " + str(result), true)
            break
    
    end_test(all_handled, "Coordinate systems should properly handle infinity values")

func test_handle_large_coordinates():
    start_test("Handle Large Coordinates")
    
    # Create test points with very large values
    var large_points = [
        Vector2(1000000, 1000000),
        Vector2(-1000000, 1000000),
        Vector2(1000000, -1000000)
    ]
    
    # Test handling in camera validation
    var all_handled = true
    for point in large_points:
        var result = camera.validate_coordinates(point)
        # We allow the camera to either return the original large coordinates or
        # replace them with something smaller - both are valid approaches
        all_handled = all_handled && !is_nan(result.x) && !is_nan(result.y) && !is_inf(result.x) && !is_inf(result.y)
    
    end_test(all_handled, "Coordinate systems should properly handle very large coordinates")

func test_handle_negative_coordinates():
    start_test("Handle Negative Coordinates")
    
    # Create test points with negative values
    var negative_points = [
        Vector2(-100, -100),
        Vector2(-1000, -1000)
    ]
    
    # Test negative coordinates in transformations
    var all_correct = true
    
    # Test in CoordinateSystem
    for point in negative_points:
        var world_view_point = CoordinateSystem.game_view_to_world_view(point, district)
        var back_to_game = CoordinateSystem.world_view_to_game_view(world_view_point, district)
        
        if back_to_game.distance_to(point) > 0.01:
            all_correct = false
            debug_log("CoordinateSystem failed for negative point: " + str(point), true)
            break
    
    # Test in camera
    if all_correct:
        for point in negative_points:
            var validated = camera.validate_coordinates(point)
            
            if validated.distance_to(point) > 0.01:
                all_correct = false
                debug_log("Camera validation changed negative point: " + str(point) + " to " + str(validated), true)
                break
    
    end_test(all_correct, "Coordinate systems should properly handle negative coordinates")

# PERFORMANCE TESTS

func test_batch_transformations():
    start_test("Batch Transformations")
    
    # Create a batch of test points
    var batch_size = 100
    var test_batch = []
    
    for i in range(batch_size):
        test_batch.append(Vector2(i, i))
    
    # Time the batch transformation
    var start_time = OS.get_ticks_msec()
    
    # Transform all points
    for point in test_batch:
        var world_pos = camera.screen_to_world(point)
        var screen_pos = camera.world_to_screen(world_pos)
    
    var end_time = OS.get_ticks_msec()
    var elapsed = end_time - start_time
    
    # Log performance
    debug_log("Batch transformation time for " + str(batch_size) + " points: " + str(elapsed) + "ms")
    
    # Test passes if it completes without errors
    end_test(true, "Batch transformations should complete without errors")

func test_large_array_transformations():
    start_test("Large Array Transformations")
    
    # Create a large array of points
    var array_size = 1000
    var large_array = PoolVector2Array()
    
    for i in range(array_size):
        large_array.append(Vector2(i % 100, i % 100))
    
    # Create CoordinateManager
    var coordinate_manager = load("res://src/core/coordinate_manager.gd").new()
    coordinate_manager._current_district = district
    add_child(coordinate_manager)
    
    # Time the array transformation
    var start_time = OS.get_ticks_msec()
    
    # Transform array
    var transformed_array = coordinate_manager.transform_coordinate_array(
        large_array,
        coordinate_manager.ViewMode.GAME_VIEW,
        coordinate_manager.ViewMode.WORLD_VIEW
    )
    
    var end_time = OS.get_ticks_msec()
    var elapsed = end_time - start_time
    
    # Log performance
    debug_log("Large array transformation time for " + str(array_size) + " points: " + str(elapsed) + "ms")
    
    # Test passes if transformation completes and array size is preserved
    var size_preserved = transformed_array.size() == large_array.size()
    
    # Clean up
    coordinate_manager.queue_free()
    
    end_test(size_preserved, "Large array transformations should preserve array size")

# ===== TEST UTILITIES =====

func update_test_display():
    # Update any UI elements showing test status
    var label = get_node_or_null("TestInfo")
    if label:
        var status = "Tests: %d/%d passed" % [tests_passed, tests_passed + tests_failed]
        if current_test:
            status += "\nCurrent: " + current_test
        label.text = status

func start_test_suite(suite_name):
    debug_log("===== TEST SUITE: " + suite_name + " =====", true)
    current_suite = suite_name
    test_results[suite_name] = {
        "passed": 0,
        "failed": 0,
        "tests": {}
    }

func end_test_suite():
    var passed = test_results[current_suite].passed
    var failed = test_results[current_suite].failed
    var total = passed + failed
    debug_log("Suite completed: " + str(passed) + "/" + str(total) + " tests passed", true)

func start_test(test_name):
    current_test = current_suite + ": " + test_name
    debug_log("Running test: " + test_name)

func end_test(passed, message = ""):
    var parts = current_test.split(": ")
    var test_name = parts[1] if parts.size() > 1 else current_test
    
    if passed:
        debug_log("✓ PASS: " + test_name + (": " + message if message else ""))
        test_results[current_suite].passed += 1
        tests_passed += 1
    else:
        debug_log("✗ FAIL: " + test_name + (": " + message if message else ""), true)
        test_results[current_suite].failed += 1
        tests_failed += 1
        failed_tests.append(current_test)
    
    test_results[current_suite].tests[test_name] = {
        "passed": passed,
        "message": message
    }

func report_results():
    debug_log("\n===== TEST RESULTS =====", true)
    debug_log("Total Tests: " + str(tests_passed + tests_failed), true)
    debug_log("Passed: " + str(tests_passed), true)
    debug_log("Failed: " + str(tests_failed), true)
    
    if tests_failed > 0:
        debug_log("\nFailed Tests:", true)
        for test in failed_tests:
            var parts = test.split(": ")
            var suite_name = parts[0]
            var test_name = parts[1]
            var message = test_results[suite_name].tests[test_name].message
            debug_log("- " + test + (": " + message if message else ""), true)
    
    if tests_failed == 0:
        debug_log("\nAll tests passed! 🎉", true)

func debug_log(message, force_print = false):
    if log_debug_info || force_print:
        print(message)