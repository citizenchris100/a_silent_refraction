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
	
	# Run the tests
	yield(get_tree().create_timer(0.5), "timeout")  # Short delay to ensure setup is complete
	yield(run_tests(), "completed")
	
	# Report results
	report_results()

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
	# Create a simple mock district node
	mock_district = Node2D.new()
	mock_district.name = "MockDistrict"
	
	# Add properties to mock a BaseDistrict
	mock_district.set_meta("background_scale_factor", 2.0)
	mock_district.set_meta("district_name", "Test District")
	
	# Add method to get scale factor
	mock_district.set_script(GDScript.new())
	mock_district.get_script().source_code = """
	extends Node2D
	
	var background_scale_factor = 2.0
	var district_name = "Test District"
	"""
	mock_district.get_script().reload()
	
	add_child(mock_district)
	debug_log("Created mock district with scale factor: " + str(mock_district.get("background_scale_factor")))

func configure_camera():
	debug_log("Configuring camera for testing...")
	
	# Set initial position and zoom
	camera.global_position = Vector2(500, 500)
	camera.zoom = Vector2(1, 1)
	
	debug_log("Camera configured with position: " + str(camera.global_position) + ", zoom: " + str(camera.zoom))

# ===== TEST RUNNER =====

func run_tests():
	debug_log("Starting CoordinateSystem tests...")
	
	# Reset test counters
	tests_passed = 0
	tests_failed = 0
	failed_tests = []
	test_results = {}
	
	# Run all test suites in sequence
	if run_all_tests or test_screen_to_world:
		yield(test_screen_to_world_suite(), "completed")
	
	if run_all_tests or test_world_to_screen:
		yield(test_world_to_screen_suite(), "completed")
	
	if run_all_tests or test_scale_factor:
		yield(test_scale_factor_suite(), "completed")
	
	if run_all_tests or test_view_mode_conversions:
		yield(test_view_mode_conversions_suite(), "completed")
	
	if run_all_tests or test_has_property:
		yield(test_has_property_suite(), "completed")
	
	if run_all_tests or test_view_mode_detection:
		yield(test_view_mode_detection_suite(), "completed")
	
	if run_all_tests or test_convenience_methods:
		yield(test_convenience_methods_suite(), "completed")
	
	debug_log("All tests completed.")

# ===== TEST SUITES =====

func test_screen_to_world_suite():
	start_test_suite("Screen to World")
	
	# Test 1: Basic screen to world conversion
	yield(test_basic_screen_to_world(), "completed")
	
	# Test 2: Screen to world with different zoom levels
	yield(test_screen_to_world_with_zoom(), "completed")
	
	# Test 3: Screen to world with camera offset
	yield(test_screen_to_world_with_offset(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_world_to_screen_suite():
	start_test_suite("World to Screen")
	
	# Test 1: Basic world to screen conversion
	yield(test_basic_world_to_screen(), "completed")
	
	# Test 2: World to screen with different zoom levels
	yield(test_world_to_screen_with_zoom(), "completed")
	
	# Test 3: World to screen with camera offset
	yield(test_world_to_screen_with_offset(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_scale_factor_suite():
	start_test_suite("Scale Factor")
	
	# Test 1: Apply scale factor
	yield(test_apply_scale_factor(), "completed")
	
	# Test 2: Remove scale factor
	yield(test_remove_scale_factor(), "completed")
	
	# Test 3: Default scale factor (1.0)
	yield(test_default_scale_factor(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_view_mode_conversions_suite():
	start_test_suite("View Mode Conversions")
	
	# Test 1: World view to game view conversion
	yield(test_world_view_to_game_view(), "completed")
	
	# Test 2: Game view to world view conversion
	yield(test_game_view_to_world_view(), "completed")
	
	# Test 3: Bidirectional conversion (round-trip)
	yield(test_bidirectional_view_conversion(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_has_property_suite():
	start_test_suite("Has Property")
	
	# Test 1: Has property returns true for existing property
	yield(test_has_property_true(), "completed")
	
	# Test 2: Has property returns false for non-existing property
	yield(test_has_property_false(), "completed")
	
	# Test 3: Has property handles null object
	yield(test_has_property_null(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_view_mode_detection_suite():
	start_test_suite("View Mode Detection")
	
	# Test 1: Detect game view
	yield(test_detect_game_view(), "completed")
	
	# Test 2: Detect world view
	yield(test_detect_world_view(), "completed")
	
	# Test 3: Handle null debug manager
	yield(test_detect_null_debug_manager(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_convenience_methods_suite():
	start_test_suite("Convenience Methods")
	
	# Test 1: Convert coordinates for current view (game view)
	yield(test_convert_for_game_view(), "completed")
	
	# Test 2: Convert coordinates for current view (world view)
	yield(test_convert_for_world_view(), "completed")
	
	# Test 3: Handle null inputs in convenience methods
	yield(test_convenience_methods_null_handling(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

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
	yield(get_tree(), "idle_frame")

# HAS PROPERTY TESTS

func test_has_property_true():
	start_test("Has Property True")
	
	# Test has_property with existing property
	var has_property = CoordinateSystem.has_property(mock_district, "background_scale_factor")
	
	end_test(has_property, "has_property should return true for existing property")
	yield(get_tree(), "idle_frame")

func test_has_property_false():
	start_test("Has Property False")
	
	# Test has_property with non-existing property
	var has_property = CoordinateSystem.has_property(mock_district, "non_existent_property")
	
	end_test(!has_property, "has_property should return false for non-existing property")
	yield(get_tree(), "idle_frame")

func test_has_property_null():
	start_test("Has Property Null")
	
	# Test has_property with null object
	var has_property = CoordinateSystem.has_property(null, "any_property")
	
	end_test(!has_property, "has_property should return false for null object")
	yield(get_tree(), "idle_frame")

# VIEW MODE DETECTION TESTS

func test_detect_game_view():
	start_test("Detect Game View")
	
	# Create mock debug manager in game view
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_meta("full_view_mode", false)
	add_child(mock_debug_manager)
	
	# Test detection
	var view_mode = CoordinateSystem.get_current_view_mode(mock_debug_manager)
	
	mock_debug_manager.queue_free()
	
	end_test(view_mode == CoordinateSystem.ViewMode.GAME_VIEW, "get_current_view_mode should detect game view")
	yield(get_tree(), "idle_frame")

func test_detect_world_view():
	start_test("Detect World View")
	
	# Create mock debug manager in world view
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_meta("full_view_mode", true)
	add_child(mock_debug_manager)
	
	# Test detection
	var view_mode = CoordinateSystem.get_current_view_mode(mock_debug_manager)
	
	mock_debug_manager.queue_free()
	
	end_test(view_mode == CoordinateSystem.ViewMode.WORLD_VIEW, "get_current_view_mode should detect world view")
	yield(get_tree(), "idle_frame")

func test_detect_null_debug_manager():
	start_test("Detect Null Debug Manager")
	
	# Test detection with null debug manager
	var view_mode = CoordinateSystem.get_current_view_mode(null)
	
	end_test(view_mode == CoordinateSystem.ViewMode.GAME_VIEW, "get_current_view_mode should default to game view with null debug manager")
	yield(get_tree(), "idle_frame")

# CONVENIENCE METHODS TESTS

func test_convert_for_game_view():
	start_test("Convert for Game View")
	
	# Create mock debug manager in game view
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_meta("full_view_mode", false)
	add_child(mock_debug_manager)
	
	# Test point
	var test_point = Vector2(100, 100)
	
	# In game view, the point should be unchanged
	var converted_point = CoordinateSystem.convert_coordinates_for_current_view(test_point, mock_district, mock_debug_manager)
	
	mock_debug_manager.queue_free()
	
	end_test(converted_point == test_point, "In game view, coordinates should remain unchanged")
	yield(get_tree(), "idle_frame")

func test_convert_for_world_view():
	start_test("Convert for World View")
	
	# Create mock debug manager in world view
	var mock_debug_manager = Node.new()
	mock_debug_manager.set_meta("full_view_mode", true)
	add_child(mock_debug_manager)
	
	# Test point in world view
	var test_point = Vector2(200, 200)
	var scale_factor = mock_district.get("background_scale_factor")
	
	# Converting from world view to game view
	var converted_point = CoordinateSystem.convert_coordinates_for_current_view(test_point, mock_district, mock_debug_manager)
	var expected_point = test_point / scale_factor
	
	mock_debug_manager.queue_free()
	
	end_test(converted_point.distance_to(expected_point) < 0.01, "In world view, coordinates should be converted to game view")
	yield(get_tree(), "idle_frame")

func test_convenience_methods_null_handling():
	start_test("Convenience Methods Null Handling")
	
	# Test null position
	var null_position_result = CoordinateSystem.convert_coordinates_for_current_view(null, mock_district)
	
	# Test null district
	var null_district_result = CoordinateSystem.convert_coordinates_for_current_view(Vector2(100, 100), null)
	
	# Both methods should handle null parameters and return a valid result
	var handles_null_position = null_position_result != null
	var handles_null_district = null_district_result != null
	
	end_test(handles_null_position && handles_null_district, "Convenience methods should handle null parameters gracefully")
	yield(get_tree(), "idle_frame")

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
	test_results[suite_name] = {
		"passed": 0,
		"failed": 0,
		"tests": {}
	}

func end_test_suite():
	var suite_name = current_test.split(":")[0]
	var passed = test_results[suite_name].passed
	var failed = test_results[suite_name].failed
	var total = passed + failed
	debug_log("Suite completed: " + str(passed) + "/" + str(total) + " tests passed", true)

func start_test(test_name):
	var suite_name = test_name.split(" ")[0]
	current_test = suite_name + ": " + test_name
	debug_log("Running test: " + test_name)

func end_test(passed, message = ""):
	var parts = current_test.split(": ")
	var suite_name = parts[0]
	var test_name = parts[1]
	
	if passed:
		debug_log("✓ PASS: " + test_name + (": " + message if message else ""))
		test_results[suite_name].passed += 1
		tests_passed += 1
	else:
		debug_log("✗ FAIL: " + test_name + (": " + message if message else ""), true)
		test_results[suite_name].failed += 1
		tests_failed += 1
		failed_tests.append(current_test)
	
	test_results[suite_name].tests[test_name] = {
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