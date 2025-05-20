extends Node2D
# CoordinateManager Test (New Version): Testing the CoordinateManager singleton
# Refactored to fix timeout issues and improve reliability

# Simple MockDistrict class for testing purposes
class MockDistrict extends Node2D:
	var district_name = "Test District"
	var background_scale_factor = 2.0
	var _camera = null
	
	func _init():
		pass
	
	func get_camera():
		print("MockDistrict.get_camera() called, returning: " + str(_camera))
		return _camera
		
	func set_camera(camera):
		print("MockDistrict.set_camera() called with: " + str(camera))
		_camera = camera

# Test configuration
var log_debug_info = true      # Set to true for more verbose output
var test_timeout = 2.0         # Maximum seconds to wait for a test to complete
var debug_mode = true          # Enable extra debug logging
var auto_quit = true           # Whether to automatically quit when tests are done
var force_quit_timer = 5.0     # Time in seconds before forcing quit after tests complete

# Test variables
var manager                    # The CoordinateManager instance being tested
var mock_district              # Mock district for testing
var mock_camera                # Mock camera for testing
var tests_passed = 0           # Counter for passed tests
var tests_failed = 0           # Counter for failed tests
var failed_tests = []          # List of failed test names
var tests_completed = false    # Flag to indicate if tests have completed
var enhanced_tests_enabled = true # Flag to enable enhanced tests

# ===== LIFECYCLE METHODS =====

func _ready():
	# Set up the test environment
	debug_log("Setting up CoordinateManager test (NEW VERSION)...")
	
	# Create mock district and camera
	create_mock_district()
	
	# Create coordinate manager
	create_coordinate_manager()
	
	# Verify that our mock setup works correctly
	var camera_from_district = mock_district.get_camera()
	if camera_from_district == mock_camera:
		debug_log("Mock district camera reference working correctly", true)
	else:
		debug_log("WARNING: Mock district camera reference not working! Got: " + str(camera_from_district), true)
	
	# Run the tests after a short delay to ensure setup is complete
	var start_timer = Timer.new()
	add_child(start_timer)
	start_timer.wait_time = 0.5
	start_timer.one_shot = true
	start_timer.connect("timeout", self, "_on_start_tests")
	start_timer.start()

func _on_start_tests():
	debug_log("Starting tests...")
	run_all_tests()

# ===== TEST SETUP METHODS =====

func create_coordinate_manager():
	# Create a test instance of CoordinateManager
	debug_log("Creating CoordinateManager instance")
	
	# Load CoordinateManager class and create a fresh instance
	manager = load("res://src/core/coordinate_manager.gd").new()
	
	# Connect camera and district
	manager.set_current_district(mock_district)
	
	add_child(manager)
	debug_log("CoordinateManager instance created and configured")

func create_mock_district():
	# Create a mock district with camera
	debug_log("Creating mock district and camera")
	
	# Create the mock district
	mock_district = MockDistrict.new()
	mock_district.name = "MockDistrict"
	add_child(mock_district)
	
	# Create the mock camera
	mock_camera = Camera2D.new()
	mock_camera.name = "Camera2D"
	mock_camera.zoom = Vector2(1, 1)
	mock_camera.global_position = Vector2(500, 500)
	
	# Add camera to district
	mock_district.add_child(mock_camera)
	
	# Set the camera on the district
	mock_district.set_camera(mock_camera)
	
	debug_log("Created mock district with camera reference")

# ===== TEST RUNNER =====

# This is the main test runner - no more yielding between tests
func run_all_tests():
	debug_log("Starting CoordinateManager tests...", true)
	
	# Reset test counters
	tests_passed = 0
	tests_failed = 0
	failed_tests = []
	
	# Run basic tests first to validate setup and basic functionality
	debug_log("=== Running Basic Tests ===")
	test_and_log("test_district_setup")
	test_and_log("test_camera_access")
	test_and_log("test_screen_to_world")
	test_and_log("test_world_to_screen")
	test_and_log("test_view_mode")
	
	if enhanced_tests_enabled:
		# Run enhanced tests for more robust validation
		debug_log("=== Running Enhanced Tests ===")
		test_and_log("test_precise_coordinate_transformations")
		test_and_log("test_scale_factor_application")
		test_and_log("test_coordinate_array_transformations")
		test_and_log("test_edge_cases")
		test_and_log("test_validation_for_view_modes")
	
	# Report final results
	debug_log("All tests completed.", true)
	report_results()
	
	# Mark tests as completed
	tests_completed = true
	
	# Setup a force quit timer
	if auto_quit:
		debug_log("Scheduling force quit in " + str(force_quit_timer) + " seconds")
		var quit_timer = Timer.new()
		add_child(quit_timer)
		quit_timer.wait_time = force_quit_timer
		quit_timer.one_shot = true
		quit_timer.connect("timeout", self, "_force_quit")
		quit_timer.start()
		
		# Try quitting immediately too - this creates a racing condition
		# but ensures we'll quit within a reasonable time
		call_deferred("_force_quit")

func _force_quit():
	debug_log("Force quitting...")
	if tests_completed:
		var exit_code = 0 if tests_failed == 0 else 1
		debug_log("Quitting with exit code: " + str(exit_code))
		OS.exit_code = exit_code
		get_tree().quit()

# Called every frame
func _process(delta):
	# Check if we need to force quit
	if tests_completed and auto_quit:
		_force_quit()

# Simplified test runner for individual tests
func test_and_log(test_name):
	debug_log("Running test: " + test_name)
	
	# Get the test method
	var test_method = funcref(self, test_name)
	if not test_method.is_valid():
		debug_log("ERROR: Test method '" + test_name + "' not found", true)
		tests_failed += 1
		failed_tests.append(test_name + " (method not found)")
		return
	
	# Run the test
	var test_result = test_method.call_func()
	debug_log("Test completed: " + test_name)

# ===== TEST METHODS =====

# Test 1: Verify the district setup is correct
func test_district_setup():
	debug_log("Testing district setup")
	
	# Check that the district is correctly configured
	var district_ok = mock_district != null
	var district_name_ok = mock_district.district_name == "Test District"
	var scale_factor_ok = mock_district.background_scale_factor == 2.0
	
	# Verify district is set in the manager
	var manager_district_ok = manager.get_current_district() == mock_district
	
	var all_ok = district_ok and district_name_ok and scale_factor_ok and manager_district_ok
	
	if all_ok:
		report_test_success("test_district_setup")
	else:
		report_test_failure("test_district_setup", "District setup is incorrect")
	
	return all_ok

# Test 2: Verify camera access through the district
func test_camera_access():
	debug_log("Testing camera access through district")
	
	# Check that the mock camera is correctly set
	var camera_ok = mock_camera != null
	
	# Verify we can access the camera through the district
	var district_camera = mock_district.get_camera()
	var camera_access_ok = district_camera == mock_camera
	
	# Verify coordinate manager can access the camera
	var manager_camera = manager._get_current_camera()
	var manager_camera_ok = manager_camera == mock_camera
	
	var all_ok = camera_ok and camera_access_ok and manager_camera_ok
	
	if all_ok:
		report_test_success("test_camera_access")
	else:
		report_test_failure("test_camera_access", 
			"Camera access failed - District camera: " + str(district_camera) + 
			", Manager camera: " + str(manager_camera))
	
	return all_ok

# Test 3: Test basic screen to world conversion
func test_screen_to_world():
	debug_log("Testing screen_to_world conversion")
	
	# Use a known screen coordinate
	var screen_pos = Vector2(100, 100)
	
	# Convert to world position
	var world_pos = manager.screen_to_world(screen_pos)
	
	# We don't care about the exact result, just that it produces something and doesn't crash
	var result_ok = world_pos != null
	
	if result_ok:
		report_test_success("test_screen_to_world")
	else:
		report_test_failure("test_screen_to_world", "screen_to_world returned null")
	
	return result_ok

# Test 4: Test basic world to screen conversion
func test_world_to_screen():
	debug_log("Testing world_to_screen conversion")
	
	# Use a known world coordinate
	var world_pos = Vector2(500, 500)
	
	# Convert to screen position
	var screen_pos = manager.world_to_screen(world_pos)
	
	# We don't care about the exact result, just that it produces something and doesn't crash
	var result_ok = screen_pos != null
	
	if result_ok:
		report_test_success("test_world_to_screen")
	else:
		report_test_failure("test_world_to_screen", "world_to_screen returned null")
	
	return result_ok

# Test 5: Test view mode switching
func test_view_mode():
	debug_log("Testing view mode switching")
	
	# Get initial view mode
	var initial_mode = manager.get_view_mode()
	
	# Set to world view
	manager.set_view_mode(manager.ViewMode.WORLD_VIEW)
	var world_mode_ok = manager.get_view_mode() == manager.ViewMode.WORLD_VIEW
	
	# Set back to game view
	manager.set_view_mode(manager.ViewMode.GAME_VIEW)
	var game_mode_ok = manager.get_view_mode() == manager.ViewMode.GAME_VIEW
	
	var all_ok = world_mode_ok and game_mode_ok
	
	if all_ok:
		report_test_success("test_view_mode")
	else:
		report_test_failure("test_view_mode", "View mode switching failed")
	
	# Restore original view mode
	manager.set_view_mode(initial_mode)
	
	return all_ok

# ===== ENHANCED TEST METHODS =====

# Test 6: Test precise coordinate transformations with known values
func test_precise_coordinate_transformations():
	debug_log("Testing precise coordinate transformations")
	
	# Use fixed camera position and zoom for consistent testing
	var original_position = mock_camera.global_position
	var original_zoom = mock_camera.zoom
	
	mock_camera.global_position = Vector2(500, 500)
	mock_camera.zoom = Vector2(1, 1)
	
	# Get viewport size for calculations
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test case 1: Screen center should map to camera position
	var screen_center = viewport_center
	var expected_world_center = mock_camera.global_position
	var actual_world_center = manager.screen_to_world(screen_center)
	
	var center_ok = actual_world_center.distance_to(expected_world_center) < 1.0
	debug_log("Screen center test: " + ("PASS" if center_ok else "FAIL - Expected " + str(expected_world_center) + ", got " + str(actual_world_center)))
	
	# Test case 2: Known offset from center (100, 100)
	var screen_offset = viewport_center + Vector2(100, 100)
	var expected_world_offset = mock_camera.global_position + Vector2(100, 100) * mock_camera.zoom
	var actual_world_offset = manager.screen_to_world(screen_offset)
	
	var offset_ok = actual_world_offset.distance_to(expected_world_offset) < 1.0
	debug_log("Screen offset test: " + ("PASS" if offset_ok else "FAIL - Expected " + str(expected_world_offset) + ", got " + str(actual_world_offset)))
	
	# Test round-trip conversion (world -> screen -> world)
	var original_world_pos = Vector2(600, 600)
	var screen_pos = manager.world_to_screen(original_world_pos)
	var round_trip_pos = manager.screen_to_world(screen_pos)
	
	var round_trip_ok = round_trip_pos.distance_to(original_world_pos) < 1.0
	debug_log("Round trip test: " + ("PASS" if round_trip_ok else "FAIL - Expected " + str(original_world_pos) + ", got " + str(round_trip_pos)))
	
	# Restore camera settings
	mock_camera.global_position = original_position
	mock_camera.zoom = original_zoom
	
	var all_ok = center_ok and offset_ok and round_trip_ok
	
	if all_ok:
		report_test_success("test_precise_coordinate_transformations")
	else:
		report_test_failure("test_precise_coordinate_transformations", 
			"Precision test failed. Check logs for details.")
	
	return all_ok

# Test 7: Test scale factor application for view mode transformations
func test_scale_factor_application():
	debug_log("Testing scale factor application")
	
	# Save original scale factor
	var original_scale_factor = mock_district.background_scale_factor
	
	# Set a known scale factor for testing
	mock_district.background_scale_factor = 3.0
	debug_log("Set test scale factor to 3.0")
	
	# Test point in game view
	var game_view_point = Vector2(100, 100)
	
	# Transform from game view to world view (multiply by scale factor)
	manager.set_view_mode(manager.ViewMode.GAME_VIEW)
	var world_view_point = manager.transform_view_mode_coordinates(
		game_view_point,
		manager.ViewMode.GAME_VIEW,
		manager.ViewMode.WORLD_VIEW
	)
	
	# Expected: Scale factor of 3.0 applied
	var expected_world_point = Vector2(300, 300)  # 100 * 3.0
	
	var world_transform_ok = world_view_point.distance_to(expected_world_point) < 0.01
	debug_log("Game to World test: " + ("PASS" if world_transform_ok else "FAIL - Expected " + str(expected_world_point) + ", got " + str(world_view_point)))
	
	# Transform back from world view to game view (divide by scale factor)
	var back_to_game_point = manager.transform_view_mode_coordinates(
		world_view_point,
		manager.ViewMode.WORLD_VIEW,
		manager.ViewMode.GAME_VIEW
	)
	
	var round_trip_ok = back_to_game_point.distance_to(game_view_point) < 0.01
	debug_log("World to Game test: " + ("PASS" if round_trip_ok else "FAIL - Expected " + str(game_view_point) + ", got " + str(back_to_game_point)))
	
	# Restore original scale factor
	mock_district.background_scale_factor = original_scale_factor
	
	var all_ok = world_transform_ok and round_trip_ok
	
	if all_ok:
		report_test_success("test_scale_factor_application")
	else:
		report_test_failure("test_scale_factor_application", 
			"Scale factor application failed. Check logs for details.")
	
	return all_ok

# Test 8: Test coordinate array transformations
func test_coordinate_array_transformations():
	debug_log("Testing coordinate array transformations")
	
	# Save original scale factor
	var original_scale_factor = mock_district.background_scale_factor
	
	# Set a known scale factor for testing
	mock_district.background_scale_factor = 2.0
	
	# Create test array of points
	var test_points = PoolVector2Array([
		Vector2(100, 100),
		Vector2(200, 200),
		Vector2(300, 300)
	])
	
	# Transform array from game view to world view
	var transformed_points = manager.transform_coordinate_array(
		test_points,
		manager.ViewMode.GAME_VIEW,
		manager.ViewMode.WORLD_VIEW
	)
	
	# Verify each point was correctly transformed
	var expected_points = PoolVector2Array([
		Vector2(200, 200),  # 100 * 2.0
		Vector2(400, 400),  # 200 * 2.0
		Vector2(600, 600)   # 300 * 2.0
	])
	
	var all_points_correct = true
	for i in range(test_points.size()):
		if transformed_points[i].distance_to(expected_points[i]) > 0.01:
			all_points_correct = false
			debug_log("Point " + str(i) + " transform failed: Expected " + 
				str(expected_points[i]) + ", got " + str(transformed_points[i]))
	
	# Transform back to game view
	var round_trip_points = manager.transform_coordinate_array(
		transformed_points,
		manager.ViewMode.WORLD_VIEW,
		manager.ViewMode.GAME_VIEW
	)
	
	# Verify round-trip conversion is accurate
	var round_trip_correct = true
	for i in range(test_points.size()):
		if round_trip_points[i].distance_to(test_points[i]) > 0.01:
			round_trip_correct = false
			debug_log("Point " + str(i) + " round-trip failed: Expected " + 
				str(test_points[i]) + ", got " + str(round_trip_points[i]))
	
	# Restore original scale factor
	mock_district.background_scale_factor = original_scale_factor
	
	var all_ok = all_points_correct and round_trip_correct
	
	if all_ok:
		report_test_success("test_coordinate_array_transformations")
	else:
		report_test_failure("test_coordinate_array_transformations", 
			"Array transformation failed. Check logs for details.")
	
	return all_ok

# Test 9: Test edge case handling
func test_edge_cases():
	debug_log("Testing edge case handling")
	
	# Test null district handling
	var saved_district = manager._current_district
	manager._current_district = null
	
	# Operations should gracefully handle null district
	var screen_pos = Vector2(100, 100)
	var result_with_null = manager.screen_to_world(screen_pos)
	
	# Should return something reasonable, not crash
	var graceful_null_handling = result_with_null != null
	debug_log("Null district test: " + ("PASS" if graceful_null_handling else "FAIL - Returned null"))
	
	# Restore district
	manager._current_district = saved_district
	
	# Test extreme coordinates
	var extreme_pos = Vector2(9999999, 9999999)
	var extreme_result = manager.screen_to_world(extreme_pos)
	
	# Should handle extreme values without crashing
	var handles_extremes = extreme_result != null
	debug_log("Extreme coordinates test: " + ("PASS" if handles_extremes else "FAIL - Returned null"))
	
	# Test empty array
	var empty_array = PoolVector2Array()
	var empty_result = manager.transform_coordinate_array(
		empty_array,
		manager.ViewMode.GAME_VIEW,
		manager.ViewMode.WORLD_VIEW
	)
	
	var handles_empty = empty_result.size() == 0
	debug_log("Empty array test: " + ("PASS" if handles_empty else "FAIL - Didn't return empty array"))
	
	var all_ok = graceful_null_handling and handles_extremes and handles_empty
	
	if all_ok:
		report_test_success("test_edge_cases")
	else:
		report_test_failure("test_edge_cases", 
			"Edge case handling test failed. Check logs for details.")
	
	return all_ok

# Test 10: Test validation for view mode mismatches
func test_validation_for_view_modes():
	debug_log("Testing view mode validation")
	
	# Get original view mode
	var original_view_mode = manager._current_view_mode
	
	# Set to game view
	manager.set_view_mode(manager.ViewMode.GAME_VIEW)
	
	# Create test points
	var points = PoolVector2Array([Vector2(100, 100), Vector2(200, 200)])
	
	# Validate for game view (should pass)
	var game_validation = manager.validate_coordinates_for_view_mode(
		points,
		manager.ViewMode.GAME_VIEW
	)
	
	debug_log("Game view validation test: " + ("PASS" if game_validation else "FAIL - Should have validated"))
	
	# Validate for world view (should fail as we're in game view)
	var world_validation = manager.validate_coordinates_for_view_mode(
		points,
		manager.ViewMode.WORLD_VIEW
	)
	
	var mismatch_detected = !world_validation
	debug_log("View mode mismatch test: " + ("PASS" if mismatch_detected else "FAIL - Should have failed validation"))
	
	# Restore original view mode
	manager.set_view_mode(original_view_mode)
	
	var all_ok = game_validation and mismatch_detected
	
	if all_ok:
		report_test_success("test_validation_for_view_modes")
	else:
		report_test_failure("test_validation_for_view_modes", 
			"View mode validation test failed. Check logs for details.")
	
	return all_ok

# ===== HELPER METHODS =====

func report_test_success(test_name):
	debug_log("✓ PASS: " + test_name, true)
	tests_passed += 1

func report_test_failure(test_name, message = ""):
	debug_log("✗ FAIL: " + test_name + (": " + message if message else ""), true)
	tests_failed += 1
	failed_tests.append(test_name + (": " + message if message else ""))

func report_results():
	debug_log("\n===== TEST RESULTS =====", true)
	debug_log("Total Tests: " + str(tests_passed + tests_failed), true)
	debug_log("Passed: " + str(tests_passed), true)
	debug_log("Failed: " + str(tests_failed), true)
	
	if tests_failed > 0:
		debug_log("\nFailed Tests:", true)
		for test in failed_tests:
			debug_log("- " + test, true)
	
	if tests_failed == 0:
		debug_log("\nAll tests passed! 🎉", true)

func debug_log(message, force_print = false):
	if log_debug_info || force_print:
		print("[COORD_TEST_NEW] " + message)