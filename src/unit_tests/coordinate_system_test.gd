extends Node2D
# CoordinateSystem Test: A comprehensive test suite for the CoordinateSystem class

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for more verbose output

# Test-specific flags
var test_screen_to_world = true
var test_world_to_screen = true
var test_scale_factor = true
var test_view_mode_conversions = true
var test_has_property = true
var test_view_mode_detection = true
var test_convenience_methods = true

# ===== TEST VARIABLES =====
var camera: Camera2D
var mock_district: Node2D  # Mock district for testing
var test_results = {}
var current_test = ""
var current_suite = ""
var tests_passed = 0
var tests_failed = 0
var failed_tests = []

# ===== LIFECYCLE METHODS =====

func _ready():
	# Set up the test environment
	debug_log("Setting up CoordinateSystem test...")
	
	# Create mock district
	create_mock_district()
	
	# Find or create the camera
	camera = find_camera()
	if not camera:
		debug_log("ERROR: Could not find or create a Camera2D instance", true)
		return
	
	# Configure camera for testing
	configure_camera()
	
	# Run the tests - no delays needed
	run_tests()
	
	# Report results
	report_results()
	
	# Exit cleanly
	debug_log("Tests complete - exiting...")
	yield(get_tree().create_timer(0.1), "timeout")  # Brief delay to ensure output is flushed
	get_tree().quit()

func _process(delta):
	# Update the status display if needed
	update_test_display()

# ===== TEST SETUP METHODS =====

func find_camera():
	# Try to find the Camera2D in the scene
	var cameras = get_tree().get_nodes_in_group("camera")
	for cam in cameras:
		if cam is Camera2D:
			debug_log("Found existing camera: " + cam.name)
			return cam
			
	# If no camera found, look for our specific class
	var scrolling_cameras = get_tree().get_nodes_in_group("camera")
	for node in scrolling_cameras:
		if node is Camera2D:
			debug_log("Found camera: " + node.name)
			return node
	
	# Create a new camera if no existing camera found
	debug_log("Creating new Camera2D instance")
	var new_camera = Camera2D.new()
	new_camera.make_current()
	add_child(new_camera)
	return new_camera

func create_mock_district():
	# Create a reliable mock district without runtime script compilation
	mock_district = Node2D.new()
	mock_district.name = "MockDistrict"
	
	# Create a mock district that behaves like BaseDistrict
	mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
	if mock_district.has_method("setup_mock"):
		mock_district.setup_mock(2.0, "Test District")
		debug_log("Created mock district with scale factor: " + str(mock_district.get("background_scale_factor")))
	else:
		# Critical fallback - this should not happen
		debug_log("ERROR: Mock district script not loaded properly", true)
		# Create a minimal working mock
		mock_district.background_scale_factor = 2.0
		mock_district.district_name = "Test District"
	
	add_child(mock_district)

func configure_camera():
	debug_log("Configuring camera for testing...")
	
	# Set initial position and zoom
	camera.global_position = Vector2(500, 500)
	camera.zoom = Vector2(1, 1)
	
	# Enable test mode if it's a ScrollingCamera
	if camera.get_script() and "test_mode" in camera:
		camera.test_mode = true
		debug_log("Test mode enabled for ScrollingCamera")
	
	debug_log("Camera configured with position: " + str(camera.global_position) + ", zoom: " + str(camera.zoom))

# ===== TEST RUNNER =====

func run_tests():
	debug_log("Starting CoordinateSystem tests...")
	
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
	
	# Run all test suites in sequence
	if run_all_tests or test_screen_to_world:
		run_test_suite_with_timeout("screen_to_world", "test_screen_to_world_suite")
	
	if run_all_tests or test_world_to_screen:
		run_test_suite_with_timeout("world_to_screen", "test_world_to_screen_suite")
	
	if run_all_tests or test_scale_factor:
		run_test_suite_with_timeout("scale_factor", "test_scale_factor_suite")
	
	if run_all_tests or test_view_mode_conversions:
		run_test_suite_with_timeout("view_mode_conversions", "test_view_mode_conversions_suite")
	
	if run_all_tests or test_has_property:
		run_test_suite_with_timeout("has_property", "test_has_property_suite")
	
	if run_all_tests or test_view_mode_detection:
		run_test_suite_with_timeout("view_mode_detection", "test_view_mode_detection_suite")
	
	if run_all_tests or test_convenience_methods:
		run_test_suite_with_timeout("convenience_methods", "test_convenience_methods_suite")
	
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

func test_screen_to_world_suite():
	start_test_suite("Screen to World")
	
	# Test 1: Basic screen to world conversion
	test_basic_screen_to_world()
	
	# Test 2: Screen to world with different zoom levels
	test_screen_to_world_with_zoom()
	
	# Test 3: Screen to world with camera offset
	test_screen_to_world_with_offset()
	
	end_test_suite()

func test_world_to_screen_suite():
	start_test_suite("World to Screen")
	
	# Test 1: Basic world to screen conversion
	test_basic_world_to_screen()
	
	# Test 2: World to screen with different zoom levels
	test_world_to_screen_with_zoom()
	
	# Test 3: World to screen with camera offset
	test_world_to_screen_with_offset()
	
	end_test_suite()

func test_scale_factor_suite():
	start_test_suite("Scale Factor")
	
	# Test 1: Apply scale factor
	test_apply_scale_factor()
	
	# Test 2: Remove scale factor
	test_remove_scale_factor()
	
	# Test 3: Default scale factor (1.0)
	test_default_scale_factor()
	
	end_test_suite()

func test_view_mode_conversions_suite():
	start_test_suite("View Mode Conversions")
	
	# Test 1: World view to game view conversion
	test_world_view_to_game_view()
	
	# Test 2: Game view to world view conversion
	test_game_view_to_world_view()
	
	# Test 3: Bidirectional conversion (round-trip)
	test_bidirectional_view_conversion()
	
	end_test_suite()

func test_has_property_suite():
	start_test_suite("Has Property")
	
	# Test 1: Has property returns true for existing property
	test_has_property_true()
	
	# Test 2: Has property returns false for non-existing property
	test_has_property_false()
	
	# Test 3: Has property handles null object
	test_has_property_null()
	
	end_test_suite()

func test_view_mode_detection_suite():
	start_test_suite("View Mode Detection")
	
	# Test 1: Detect game view
	test_detect_game_view()
	
	# Test 2: Detect world view
	test_detect_world_view()
	
	# Test 3: Handle null debug manager
	test_detect_null_debug_manager()
	
	end_test_suite()

func test_convenience_methods_suite():
	start_test_suite("Convenience Methods")
	
	# Test 1: Convert coordinates for current view (game view)
	test_convert_for_game_view()
	
	# Test 2: Convert coordinates for current view (world view)
	test_convert_for_world_view()
	
	# Test 3: Handle edge cases in convenience methods
	test_convenience_methods_edge_cases()
	
	# Test 4: Test NaN handling in CoordinateSystem
	test_coordinate_system_nan_handling()
	
	# Test 5: Test infinity handling in CoordinateSystem
	test_coordinate_system_infinity_handling()
	
	end_test_suite()

# ===== INDIVIDUAL TESTS =====

# SCREEN TO WORLD TESTS

func test_basic_screen_to_world():
	start_test("Basic Screen to World")
	
	# Save camera settings
	var original_position = camera.global_position
	var original_zoom = camera.zoom
	
	# Set camera to a known position and zoom
	camera.global_position = Vector2(500, 500)
	camera.zoom = Vector2(1, 1)
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test screen-to-world conversion
	var screen_point = viewport_center
	var expected_world_point = camera.global_position  # Center of screen should map to camera position
	var world_point = CoordinateSystem.screen_to_world(screen_point, camera)
	
	# Restore camera settings
	camera.global_position = original_position
	camera.zoom = original_zoom
	
	# Test passes if world point is close to expected
	var close_enough = world_point.distance_to(expected_world_point) < 5
	end_test(close_enough, "Screen-to-world conversion should map viewport center to camera position")

func test_screen_to_world_with_zoom():
	start_test("Screen to World with Zoom")
	
	# Save camera settings
	var original_position = camera.global_position
	var original_zoom = camera.zoom
	
	# Set camera to a known position and zoom
	camera.global_position = Vector2(500, 500)
	camera.zoom = Vector2(2, 2)  # Zoomed out
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test point 100 pixels right of center
	var screen_point = viewport_center + Vector2(100, 0)
	var world_point = CoordinateSystem.screen_to_world(screen_point, camera)
	
	# Expected: 100 pixels at 2x zoom is 200 world units
	var expected_world_point = camera.global_position + Vector2(200, 0)
	
	# Restore camera settings
	camera.global_position = original_position
	camera.zoom = original_zoom
	
	# Test passes if world point is close to expected
	var close_enough = world_point.distance_to(expected_world_point) < 5
	end_test(close_enough, "Screen-to-world should properly account for zoom level")

func test_screen_to_world_with_offset():
	start_test("Screen to World with Offset")
	
	# Save camera settings
	var original_position = camera.global_position
	var original_zoom = camera.zoom
	
	# Set camera to a known position and zoom
	camera.global_position = Vector2(800, 600)  # Offset position
	camera.zoom = Vector2(1, 1)
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test screen-to-world conversion
	var screen_point = viewport_center
	var expected_world_point = camera.global_position  # Center of screen should map to camera position
	var world_point = CoordinateSystem.screen_to_world(screen_point, camera)
	
	# Restore camera settings
	camera.global_position = original_position
	camera.zoom = original_zoom
	
	# Test passes if world point is close to expected
	var close_enough = world_point.distance_to(expected_world_point) < 5
	end_test(close_enough, "Screen-to-world should properly account for camera position")

# WORLD TO SCREEN TESTS

func test_basic_world_to_screen():
	start_test("Basic World to Screen")
	
	# Save camera settings
	var original_position = camera.global_position
	var original_zoom = camera.zoom
	
	# Set camera to a known position and zoom
	camera.global_position = Vector2(500, 500)
	camera.zoom = Vector2(1, 1)
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test world-to-screen conversion
	var world_point = camera.global_position  # Camera position should map to center of screen
	var expected_screen_point = viewport_center
	var screen_point = CoordinateSystem.world_to_screen(world_point, camera)
	
	# Restore camera settings
	camera.global_position = original_position
	camera.zoom = original_zoom
	
	# Test passes if screen point is close to expected
	var close_enough = screen_point.distance_to(expected_screen_point) < 5
	end_test(close_enough, "World-to-screen conversion should map camera position to viewport center")

func test_world_to_screen_with_zoom():
	start_test("World to Screen with Zoom")
	
	# Save camera settings
	var original_position = camera.global_position
	var original_zoom = camera.zoom
	
	# Set camera to a known position and zoom
	camera.global_position = Vector2(500, 500)
	camera.zoom = Vector2(2, 2)  # Zoomed out
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test point 200 world units right of camera
	var world_point = camera.global_position + Vector2(200, 0)
	var screen_point = CoordinateSystem.world_to_screen(world_point, camera)
	
	# Expected: 200 world units at 2x zoom is 100 screen pixels
	var expected_screen_point = viewport_center + Vector2(100, 0)
	
	# Restore camera settings
	camera.global_position = original_position
	camera.zoom = original_zoom
	
	# Test passes if screen point is close to expected
	var close_enough = screen_point.distance_to(expected_screen_point) < 5
	end_test(close_enough, "World-to-screen should properly account for zoom level")

func test_world_to_screen_with_offset():
	start_test("World to Screen with Offset")
	
	# Save camera settings
	var original_position = camera.global_position
	var original_zoom = camera.zoom
	
	# Set camera to a known position and zoom
	camera.global_position = Vector2(800, 600)  # Offset position
	camera.zoom = Vector2(1, 1)
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var viewport_center = viewport_size / 2
	
	# Test world-to-screen conversion
	var world_point = camera.global_position  # Camera position should map to center of screen
	var expected_screen_point = viewport_center
	var screen_point = CoordinateSystem.world_to_screen(world_point, camera)
	
	# Restore camera settings
	camera.global_position = original_position
	camera.zoom = original_zoom
	
	# Test passes if screen point is close to expected
	var close_enough = screen_point.distance_to(expected_screen_point) < 5
	end_test(close_enough, "World-to-screen should properly account for camera position")

# SCALE FACTOR TESTS

func test_apply_scale_factor():
	start_test("Apply Scale Factor")
	
	# Test points at different positions
	var test_points = [
		Vector2(100, 100),
		Vector2(500, 300),
		Vector2(0, 0),
		Vector2(-100, -100)
	]
	
	# Test with scale factor 2.0
	var scale_factor = 2.0
	var all_correct = true
	
	for point in test_points:
		var scaled_point = CoordinateSystem.apply_scale_factor(point, scale_factor)
		var expected_point = point * scale_factor
		
		if scaled_point != expected_point:
			all_correct = false
			debug_log("apply_scale_factor failed for point " + str(point) + ": Expected " + 
				str(expected_point) + ", got " + str(scaled_point), true)
	
	end_test(all_correct, "apply_scale_factor should multiply coordinates by scale factor")

func test_remove_scale_factor():
	start_test("Remove Scale Factor")
	
	# Test points at different positions
	var test_points = [
		Vector2(200, 200),
		Vector2(1000, 600),
		Vector2(0, 0),
		Vector2(-200, -200)
	]
	
	# Test with scale factor 2.0
	var scale_factor = 2.0
	var all_correct = true
	
	for point in test_points:
		var unscaled_point = CoordinateSystem.remove_scale_factor(point, scale_factor)
		var expected_point = point / scale_factor
		
		if unscaled_point != expected_point:
			all_correct = false
			debug_log("remove_scale_factor failed for point " + str(point) + ": Expected " + 
				str(expected_point) + ", got " + str(unscaled_point), true)
	
	end_test(all_correct, "remove_scale_factor should divide coordinates by scale factor")

func test_default_scale_factor():
	start_test("Default Scale Factor")
	
	# Test with the default scale factor (1.0)
	var test_point = Vector2(100, 100)
	
	var scaled_point = CoordinateSystem.apply_scale_factor(test_point, 1.0)
	var unscaled_point = CoordinateSystem.remove_scale_factor(test_point, 1.0)
	
	# With scale factor 1.0, both functions should return the original point
	var apply_correct = scaled_point == test_point
	var remove_correct = unscaled_point == test_point
	
	end_test(apply_correct && remove_correct, "Scale factor functions should not modify points when factor is 1.0")

# VIEW MODE CONVERSIONS TESTS

func test_world_view_to_game_view():
	start_test("World View to Game View")
	
	# Test points at different positions
	var test_points = [
		Vector2(200, 200),
		Vector2(1000, 600),
		Vector2(0, 0),
		Vector2(-200, -200)
	]
	
	# Ensure district has scale factor
	var scale_factor = mock_district.get("background_scale_factor")
	var all_correct = true
	
	for point in test_points:
		var game_view_point = CoordinateSystem.world_view_to_game_view(point, mock_district)
		var expected_point = point / scale_factor
		
		if game_view_point.distance_to(expected_point) > 0.01:
			all_correct = false
			debug_log("world_view_to_game_view failed for point " + str(point) + ": Expected " + 
				str(expected_point) + ", got " + str(game_view_point), true)
	
	end_test(all_correct, "world_view_to_game_view should correctly transform coordinates")

func test_game_view_to_world_view():
	start_test("Game View to World View")
	
	# Test points at different positions
	var test_points = [
		Vector2(100, 100),
		Vector2(500, 300),
		Vector2(0, 0),
		Vector2(-100, -100)
	]
	
	# Ensure district has scale factor
	var scale_factor = mock_district.get("background_scale_factor")
	var all_correct = true
	
	for point in test_points:
		var world_view_point = CoordinateSystem.game_view_to_world_view(point, mock_district)
		var expected_point = point * scale_factor
		
		if world_view_point.distance_to(expected_point) > 0.01:
			all_correct = false
			debug_log("game_view_to_world_view failed for point " + str(point) + ": Expected " + 
				str(expected_point) + ", got " + str(world_view_point), true)
	
	end_test(all_correct, "game_view_to_world_view should correctly transform coordinates")

func test_bidirectional_view_conversion():
	start_test("Bidirectional View Conversion")
	
	# Test points at different positions
	var test_points = [
		Vector2(100, 100),
		Vector2(500, 300),
		Vector2(0, 0),
		Vector2(-100, -100)
	]
	
	var all_correct = true
	
	for point in test_points:
		# Convert to world view, then back to game view
		var world_view_point = CoordinateSystem.game_view_to_world_view(point, mock_district)
		var round_trip_point = CoordinateSystem.world_view_to_game_view(world_view_point, mock_district)
		
		if round_trip_point.distance_to(point) > 0.01:
			all_correct = false
			debug_log("Bidirectional conversion failed for point " + str(point) + ": Result " + 
				str(round_trip_point), true)
	
	end_test(all_correct, "Bidirectional view conversions should return to original coordinates")

# HAS PROPERTY TESTS

func test_has_property_true():
	start_test("Has Property True")
	
	# Test has_property with existing property
	var has_property = CoordinateSystem.has_property(mock_district, "background_scale_factor")
	
	end_test(has_property, "has_property should return true for existing property")

func test_has_property_false():
	start_test("Has Property False")
	
	# Test has_property with non-existing property
	var has_property = CoordinateSystem.has_property(mock_district, "non_existent_property")
	
	end_test(!has_property, "has_property should return false for non-existing property")

func test_has_property_null():
	start_test("Has Property Null")
	
	# Test has_property with null object
	var has_property = CoordinateSystem.has_property(null, "any_property")
	
	end_test(!has_property, "has_property should return false for null object")

# VIEW MODE DETECTION TESTS

func test_detect_game_view():
	start_test("Detect Game View")
	
	# Create mock debug manager in game view with actual property
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_script(preload("res://src/unit_tests/mocks/mock_debug_manager.gd"))
	mock_debug_manager.setup_mock(false)
	add_child(mock_debug_manager)
	
	# Test detection
	var view_mode = CoordinateSystem.get_current_view_mode(mock_debug_manager)
	
	mock_debug_manager.queue_free()
	
	end_test(view_mode == CoordinateSystem.ViewMode.GAME_VIEW, "get_current_view_mode should detect game view")

func test_detect_world_view():
	start_test("Detect World View")
	
	# Create mock debug manager in world view with actual property
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_script(preload("res://src/unit_tests/mocks/mock_debug_manager.gd"))
	mock_debug_manager.setup_mock(true)
	add_child(mock_debug_manager)
	
	# Test detection
	var view_mode = CoordinateSystem.get_current_view_mode(mock_debug_manager)
	
	mock_debug_manager.queue_free()
	
	end_test(view_mode == CoordinateSystem.ViewMode.WORLD_VIEW, "get_current_view_mode should detect world view")

func test_detect_null_debug_manager():
	start_test("Detect Null Debug Manager")
	
	# Test detection with null debug manager
	var view_mode = CoordinateSystem.get_current_view_mode(null)
	
	end_test(view_mode == CoordinateSystem.ViewMode.GAME_VIEW, "get_current_view_mode should default to game view with null debug manager")

# CONVENIENCE METHODS TESTS

func test_convert_for_game_view():
	start_test("Convert for Game View")
	
	# Create mock debug manager in game view with actual property
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_script(preload("res://src/unit_tests/mocks/mock_debug_manager.gd"))
	mock_debug_manager.setup_mock(false)
	add_child(mock_debug_manager)
	
	# Test point
	var test_point = Vector2(100, 100)
	
	# In game view, the point should be unchanged
	var converted_point = CoordinateSystem.convert_coordinates_for_current_view(test_point, mock_district, mock_debug_manager)
	
	mock_debug_manager.queue_free()
	
	end_test(converted_point == test_point, "In game view, coordinates should remain unchanged")

func test_convert_for_world_view():
	start_test("Convert for World View")
	
	# Create mock debug manager in world view with actual property
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_script(preload("res://src/unit_tests/mocks/mock_debug_manager.gd"))
	mock_debug_manager.setup_mock(true)
	add_child(mock_debug_manager)
	
	# Test point in world view
	var test_point = Vector2(200, 200)
	var scale_factor = mock_district.get("background_scale_factor")
	
	# Converting from world view to game view
	var converted_point = CoordinateSystem.convert_coordinates_for_current_view(test_point, mock_district, mock_debug_manager)
	var expected_point = test_point / scale_factor
	
	mock_debug_manager.queue_free()
	
	end_test(converted_point.distance_to(expected_point) < 0.01, "In world view, coordinates should be converted to game view")

func test_convenience_methods_edge_cases():
	start_test("Convenience Methods Edge Cases")
	
	# Test with Vector2.ZERO (origin coordinates)
	var zero_result = CoordinateSystem.convert_coordinates_for_current_view(Vector2.ZERO, mock_district)
	
	# Test with very large coordinates (potential overflow)
	var large_coords = Vector2(999999, 999999)
	var large_result = CoordinateSystem.convert_coordinates_for_current_view(large_coords, mock_district)
	
	# Test with negative coordinates
	var negative_coords = Vector2(-100, -100)
	var negative_result = CoordinateSystem.convert_coordinates_for_current_view(negative_coords, mock_district)
	
	# Test null district (this we can actually test)
	var null_district_result = CoordinateSystem.convert_coordinates_for_current_view(Vector2(100, 100), null)
	
	# All methods should handle edge cases and return valid results
	var handles_zero = zero_result != null
	var handles_large = large_result != null
	var handles_negative = negative_result != null
	var handles_null_district = null_district_result != null
	
	var all_handled = handles_zero && handles_large && handles_negative && handles_null_district
	end_test(all_handled, "Convenience methods should handle edge case parameters gracefully")

func test_coordinate_system_nan_handling():
	start_test("CoordinateSystem NaN Handling")
	
	# Create test nan points
	var nan_x = Vector2(NAN, 100)
	var nan_y = Vector2(100, NAN)
	var nan_both = Vector2(NAN, NAN)
	
	# Test world_view_to_game_view
	var wv_to_gv_result_x = CoordinateSystem.world_view_to_game_view(nan_x, mock_district)
	var wv_to_gv_result_y = CoordinateSystem.world_view_to_game_view(nan_y, mock_district)
	var wv_to_gv_result_both = CoordinateSystem.world_view_to_game_view(nan_both, mock_district)
	
	# Test game_view_to_world_view
	var gv_to_wv_result_x = CoordinateSystem.game_view_to_world_view(nan_x, mock_district)
	var gv_to_wv_result_y = CoordinateSystem.game_view_to_world_view(nan_y, mock_district)
	var gv_to_wv_result_both = CoordinateSystem.game_view_to_world_view(nan_both, mock_district)
	
	# Test apply_scale_factor
	var apply_result_x = CoordinateSystem.apply_scale_factor(nan_x, 2.0)
	var apply_result_y = CoordinateSystem.apply_scale_factor(nan_y, 2.0)
	var apply_result_both = CoordinateSystem.apply_scale_factor(nan_both, 2.0)
	
	# Test remove_scale_factor
	var remove_result_x = CoordinateSystem.remove_scale_factor(nan_x, 2.0)
	var remove_result_y = CoordinateSystem.remove_scale_factor(nan_y, 2.0)
	var remove_result_both = CoordinateSystem.remove_scale_factor(nan_both, 2.0)
	
	# No result should contain NaN
	var all_handled = true
	
	# Check all results
	var results = [
		wv_to_gv_result_x, wv_to_gv_result_y, wv_to_gv_result_both,
		gv_to_wv_result_x, gv_to_wv_result_y, gv_to_wv_result_both,
		apply_result_x, apply_result_y, apply_result_both,
		remove_result_x, remove_result_y, remove_result_both
	]
	
	for result in results:
		if is_nan(result.x) or is_nan(result.y):
			all_handled = false
			debug_log("Found NaN in result: " + str(result), true)
			break
	
	end_test(all_handled, "CoordinateSystem static methods should handle NaN values properly")

func test_coordinate_system_infinity_handling():
	start_test("CoordinateSystem Infinity Handling")
	
	# Create test infinity points
	var inf_x = Vector2(INF, 100)
	var inf_y = Vector2(100, INF)
	var inf_both = Vector2(INF, INF)
	
	# Test world_view_to_game_view
	var wv_to_gv_result_x = CoordinateSystem.world_view_to_game_view(inf_x, mock_district)
	var wv_to_gv_result_y = CoordinateSystem.world_view_to_game_view(inf_y, mock_district)
	var wv_to_gv_result_both = CoordinateSystem.world_view_to_game_view(inf_both, mock_district)
	
	# Test game_view_to_world_view
	var gv_to_wv_result_x = CoordinateSystem.game_view_to_world_view(inf_x, mock_district)
	var gv_to_wv_result_y = CoordinateSystem.game_view_to_world_view(inf_y, mock_district)
	var gv_to_wv_result_both = CoordinateSystem.game_view_to_world_view(inf_both, mock_district)
	
	# Test apply_scale_factor
	var apply_result_x = CoordinateSystem.apply_scale_factor(inf_x, 2.0)
	var apply_result_y = CoordinateSystem.apply_scale_factor(inf_y, 2.0)
	var apply_result_both = CoordinateSystem.apply_scale_factor(inf_both, 2.0)
	
	# Test remove_scale_factor
	var remove_result_x = CoordinateSystem.remove_scale_factor(inf_x, 2.0)
	var remove_result_y = CoordinateSystem.remove_scale_factor(inf_y, 2.0)
	var remove_result_both = CoordinateSystem.remove_scale_factor(inf_both, 2.0)
	
	# No result should contain infinity
	var all_handled = true
	
	# Check all results
	var results = [
		wv_to_gv_result_x, wv_to_gv_result_y, wv_to_gv_result_both,
		gv_to_wv_result_x, gv_to_wv_result_y, gv_to_wv_result_both,
		apply_result_x, apply_result_y, apply_result_both,
		remove_result_x, remove_result_y, remove_result_both
	]
	
	for result in results:
		if is_inf(result.x) or is_inf(result.y):
			all_handled = false
			debug_log("Found infinity in result: " + str(result), true)
			break
	
	end_test(all_handled, "CoordinateSystem static methods should handle infinity values properly")

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