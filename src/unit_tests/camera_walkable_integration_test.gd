extends Node2D
# Camera-Walkable Area Integration Test: Tests the integration between camera and walkable area systems

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for more verbose output

# Test-specific flags
var test_bounds_calculation = true
var test_camera_constraint = true
var test_coordinate_transformations = true
var test_view_modes = true
var test_player_movement = true

# ===== TEST VARIABLES =====
var district: Node2D
var camera: Camera2D
var walkable_area: Polygon2D
var player: Node2D
var test_results = {}
var current_test = ""
var current_suite = ""
var tests_passed = 0
var tests_failed = 0
var failed_tests = []

# ===== LIFECYCLE METHODS =====

func _ready():
	# Set up the test environment
	debug_log("Setting up Camera-Walkable Area Integration test...")
	
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
	
	# Create a walkable area
	walkable_area = create_walkable_area()
	district.add_child(walkable_area)
	district.add_walkable_area(walkable_area)
	
	# Create a camera
	camera = create_scrolling_camera()
	district.add_child(camera)
	
	# Create a mock player
	player = create_mock_player()
	district.add_child(player)
	
	debug_log("Test scene created with district, walkable area, camera, and player")

func create_mock_district():
	# Create a district node using preloaded mock script
	var new_district = Node2D.new()
	new_district.name = "MockDistrict"
	
	# Use the preloaded mock district script with walkable areas support
	new_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
	
	# Initialize with default values
	if new_district.has_method("setup_mock"):
		new_district.setup_mock()
	
	return new_district

func create_walkable_area():
	# Create a polygon for walkable area
	var polygon = Polygon2D.new()
	polygon.name = "WalkableArea"
	
	# Add to walkable area group
	polygon.add_to_group("walkable_area")
	
	# Define a rectangle
	polygon.polygon = PoolVector2Array([
		Vector2(100, 100),
		Vector2(900, 100),
		Vector2(900, 500),
		Vector2(100, 500)
	])
	
	# Set appearance
	polygon.color = Color(0, 1, 0, 0.3)
	
	return polygon

func create_scrolling_camera():
	# Create a camera node
	var camera_script = load("res://src/core/camera/scrolling_camera.gd")
	var new_camera = Camera2D.new()
	new_camera.name = "ScrollingCamera"
	new_camera.set_script(camera_script)
	
	# Configure camera
	new_camera.current = true
	new_camera.global_position = Vector2(500, 300)
	new_camera.smoothing_enabled = true
	new_camera.bounds_enabled = true
	
	# Enable test mode for integration tests
	new_camera.test_mode = false  # We want to test actual bounds validation in these tests
	
	# Add to camera group
	new_camera.add_to_group("camera")
	
	return new_camera

func create_mock_player():
	# Create a player node
	var new_player = Node2D.new()
	new_player.name = "MockPlayer"
	
	# Add to player group for camera to recognize
	new_player.add_to_group("player")
	
	# Position the player
	new_player.global_position = Vector2(500, 300)
	
	return new_player

func cleanup_test_scene():
	# Remove test scene elements
	if district:
		district.queue_free()
	
	district = null
	camera = null
	walkable_area = null
	player = null

# ===== TEST RUNNER =====

func run_tests():
	debug_log("Starting Camera-Walkable Area Integration tests...")
	
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
	if run_all_tests or test_bounds_calculation:
		run_test_suite_with_timeout("bounds_calculation", "test_bounds_calculation_suite")
	
	if run_all_tests or test_camera_constraint:
		run_test_suite_with_timeout("camera_constraint", "test_camera_constraint_suite")
	
	if run_all_tests or test_coordinate_transformations:
		run_test_suite_with_timeout("coordinate_transformations", "test_coordinate_transformations_suite")
	
	if run_all_tests or test_view_modes:
		run_test_suite_with_timeout("view_modes", "test_view_modes_suite")
	
	if run_all_tests or test_player_movement:
		run_test_suite_with_timeout("player_movement", "test_player_movement_suite")
	
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

func test_bounds_calculation_suite():
	start_test_suite("Bounds Calculation")
	
	# Test 1: Camera calculates bounds from walkable areas
	test_camera_calculates_bounds()
	
	# Test 2: Bounds contain all walkable areas
	test_bounds_contain_walkable_areas()
	
	# Test 3: Bounds updating when district changes
	test_bounds_update_on_district_change()
	
	end_test_suite()

func test_camera_constraint_suite():
	start_test_suite("Camera Constraint")
	
	# Test 1: Camera stays within bounds while following player
	test_camera_stays_within_bounds()
	
	# Test 2: Camera handles movement to invalid targets
	test_camera_handles_invalid_targets()
	
	# Test 3: Camera bounds calculation uses BoundsCalculator
	test_camera_uses_bounds_calculator()
	
	end_test_suite()

func test_coordinate_transformations_suite():
	start_test_suite("Coordinate Transformations")
	
	# Test 1: Screen to world coordinates with camera
	test_screen_to_world_with_camera()
	
	# Test 2: World to screen coordinates with camera
	test_world_to_screen_with_camera()
	
	# Test 3: District and camera coordinate methods match
	test_district_camera_coordinate_methods_match()
	
	end_test_suite()

func test_view_modes_suite():
	start_test_suite("View Modes")
	
	# Test 1: World view mode affects coordinate transformations
	test_world_view_coordinate_transformations()
	
	# Test 2: Game view mode affects coordinate transformations
	test_game_view_coordinate_transformations()
	
	# Test 3: Transformations between view modes are consistent
	test_view_mode_transformation_consistency()
	
	end_test_suite()

func test_player_movement_suite():
	start_test_suite("Player Movement")
	
	# Test 1: Camera follows player movement
	test_camera_follows_player_movement()
	
	# Test 2: Camera stops at boundaries when player approaches edge
	test_camera_stops_at_boundaries()
	
	# Test 3: Player stays within walkable areas
	test_player_stays_within_walkable_areas()
	
	end_test_suite()

# ===== INDIVIDUAL TESTS =====

# BOUNDS CALCULATION TESTS

func test_camera_calculates_bounds():
	start_test("Camera Calculates Bounds")
	
	# Force camera to update bounds
	camera._calculate_district_bounds(district)
	
	# Check if camera bounds are non-zero
	var bounds_calculated = camera.camera_bounds.size != Vector2.ZERO
	
	end_test(bounds_calculated, "Camera should calculate bounds from walkable areas")

func test_bounds_contain_walkable_areas():
	start_test("Bounds Contain Walkable Areas")
	
	# Force camera to update bounds
	camera._calculate_district_bounds(district)
	
	# Check if all corners of walkable area are within bounds
	var all_contained = true
	for point in walkable_area.polygon:
		var global_point = walkable_area.to_global(point)
		if !camera.camera_bounds.has_point(global_point):
			all_contained = false
			break
	
	end_test(all_contained, "Camera bounds should contain all walkable area points")

func test_bounds_update_on_district_change():
	start_test("Bounds Update on District Change")
	
	# Save original bounds
	var original_bounds = camera.camera_bounds
	
	# Modify walkable area
	var original_polygon = walkable_area.polygon
	walkable_area.polygon = PoolVector2Array([
		Vector2(200, 200),
		Vector2(800, 200),
		Vector2(800, 400),
		Vector2(200, 400)
	])
	
	# Force bounds update
	camera.update_bounds()
	
	# Check if bounds changed
	var bounds_changed = camera.camera_bounds != original_bounds
	
	# Restore original walkable area
	walkable_area.polygon = original_polygon
	
	end_test(bounds_changed, "Camera bounds should update when walkable areas change")

# CAMERA CONSTRAINT TESTS

func test_camera_stays_within_bounds():
	start_test("Camera Stays Within Bounds")
	
	# Enable bounds constraint
	camera.bounds_enabled = true
	
	# Save original position
	var original_position = camera.global_position
	
	# Test moving camera outside bounds
	var outside_position = Vector2(2000, 2000)  # Way outside bounds
	camera.move_to_position(outside_position, true)  # Immediate movement
	
	# Check if camera position was constrained within bounds
	var is_within_bounds = camera.camera_bounds.has_point(camera.global_position)
	
	# Restore original position
	camera.move_to_position(original_position, true)
	
	end_test(is_within_bounds, "Camera should stay within calculated bounds")

func test_camera_handles_invalid_targets():
	start_test("Camera Handles Invalid Targets")
	
	# Save original position
	var original_position = camera.global_position
	
	# Create invalid NaN position
	var invalid_position = Vector2(NAN, 100)
	
	# Try to move camera to invalid position
	camera.move_to_position(invalid_position, true)  # Immediate movement
	
	# Check if camera handled invalid position
	var position_valid = !is_nan(camera.global_position.x) && !is_nan(camera.global_position.y)
	
	# Restore original position
	camera.move_to_position(original_position, true)
	
	end_test(position_valid, "Camera should handle invalid target positions")

func test_camera_uses_bounds_calculator():
	start_test("Camera Uses BoundsCalculator")
	
	# Check if the camera's _calculate_district_bounds method is using BoundsCalculator
	# This is a little tricky to test directly without modifying code, so we'll use an indirect approach
	
	# First, capture the original bounds
	var original_bounds = camera.camera_bounds
	
	# Now, add a new walkable area that should expand the bounds
	var new_walkable_area = create_walkable_area()
	new_walkable_area.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(1000, 0),
		Vector2(1000, 600),
		Vector2(0, 600)
	])
	district.add_child(new_walkable_area)
	district.add_walkable_area(new_walkable_area)
	
	# Force bounds update
	camera._calculate_district_bounds(district)
	
	# Check if bounds were expanded
	var bounds_updated = camera.camera_bounds != original_bounds
	
	# Clean up
	district.walkable_areas.erase(new_walkable_area)
	new_walkable_area.queue_free()
	
	# Reset bounds to original
	camera.camera_bounds = original_bounds
	
	end_test(bounds_updated, "Camera should use BoundsCalculator to calculate bounds")

# COORDINATE TRANSFORMATIONS TESTS

func test_screen_to_world_with_camera():
	start_test("Screen to World with Camera")
	
	# Set camera to a known position
	var original_position = camera.global_position
	camera.global_position = Vector2(500, 300)
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var screen_center = viewport_size / 2
	
	# Transform screen center to world space
	var world_pos = camera.screen_to_world(screen_center)
	
	# Check if transformed position matches camera position
	var matches_camera_pos = world_pos.distance_to(camera.global_position) < 5
	
	# Restore original position
	camera.global_position = original_position
	
	end_test(matches_camera_pos, "Screen-to-world conversion should map screen center to camera position")

func test_world_to_screen_with_camera():
	start_test("World to Screen with Camera")
	
	# Set camera to a known position
	var original_position = camera.global_position
	camera.global_position = Vector2(500, 300)
	
	# Get viewport size
	var viewport_size = get_viewport().get_size()
	var screen_center = viewport_size / 2
	
	# Transform camera position to screen space
	var screen_pos = camera.world_to_screen(camera.global_position)
	
	# Check if transformed position matches screen center
	var matches_screen_center = screen_pos.distance_to(screen_center) < 5
	
	# Restore original position
	camera.global_position = original_position
	
	end_test(matches_screen_center, "World-to-screen conversion should map camera position to screen center")

func test_district_camera_coordinate_methods_match():
	start_test("District Camera Coordinate Methods Match")
	
	# Set camera to a known position
	var original_position = camera.global_position
	camera.global_position = Vector2(500, 300)
	
	# Get a test point
	var test_world_point = Vector2(600, 400)
	var test_screen_point = Vector2(700, 500)
	
	# Transform using district methods
	var district_world_to_screen = district.world_to_screen_coords(test_world_point)
	var district_screen_to_world = district.screen_to_world_coords(test_screen_point)
	
	# Transform using camera methods
	var camera_world_to_screen = camera.world_to_screen(test_world_point)
	var camera_screen_to_world = camera.screen_to_world(test_screen_point)
	
	# Compare results
	var world_to_screen_match = district_world_to_screen.distance_to(camera_world_to_screen) < 5
	var screen_to_world_match = district_screen_to_world.distance_to(camera_screen_to_world) < 5
	
	# Restore original position
	camera.global_position = original_position
	
	end_test(world_to_screen_match && screen_to_world_match, "District and camera coordinate methods should give consistent results")

# VIEW MODES TESTS

func test_world_view_coordinate_transformations():
	start_test("World View Coordinate Transformations")
	
	# Save original state
	var original_world_view_mode = camera.world_view_mode
	
	# Set to world view mode
	camera.world_view_mode = true
	
	# Create a test point
	var test_point = Vector2(600, 400)
	
	# Convert using CoordinateManager via CoordinateSystem
	var converted_point = CoordinateSystem.world_view_to_game_view(test_point, district)
	
	# Check if conversion is applied 
	var scale_factor = district.background_scale_factor
	var expected_point = test_point / scale_factor
	var correctly_scaled = converted_point.distance_to(expected_point) < 1
	
	# Restore original state
	camera.world_view_mode = original_world_view_mode
	
	end_test(correctly_scaled, "World view coordinates should be properly transformed to game view")

func test_game_view_coordinate_transformations():
	start_test("Game View Coordinate Transformations")
	
	# Save original state
	var original_world_view_mode = camera.world_view_mode
	
	# Set to game view mode
	camera.world_view_mode = false
	
	# Create a test point
	var test_point = Vector2(300, 200)
	
	# Convert using CoordinateManager via CoordinateSystem
	var converted_point = CoordinateSystem.game_view_to_world_view(test_point, district)
	
	# Check if conversion is applied 
	var scale_factor = district.background_scale_factor
	var expected_point = test_point * scale_factor
	var correctly_scaled = converted_point.distance_to(expected_point) < 1
	
	# Restore original state
	camera.world_view_mode = original_world_view_mode
	
	end_test(correctly_scaled, "Game view coordinates should be properly transformed to world view")

func test_view_mode_transformation_consistency():
	start_test("View Mode Transformation Consistency")
	
	# Test points
	var test_points = [
		Vector2(100, 100),
		Vector2(500, 300),
		Vector2(900, 500)
	]
	
	# Check bidirectional conversions
	var all_consistent = true
	for point in test_points:
		# Convert to world view then back to game view
		var to_world = CoordinateSystem.game_view_to_world_view(point, district)
		var back_to_game = CoordinateSystem.world_view_to_game_view(to_world, district)
		
		# Check if round-trip conversion preserves the point
		if back_to_game.distance_to(point) > 1:
			all_consistent = false
			break
	
	end_test(all_consistent, "View mode transformations should be consistent when applied bidirectionally")

# PLAYER MOVEMENT TESTS

func test_camera_follows_player_movement():
	start_test("Camera Follows Player Movement")
	
	# Save original positions
	var original_camera_pos = camera.global_position
	var original_player_pos = player.global_position
	
	# Enable player following
	camera.follow_player = true
	camera.target_player = player
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Move player
	player.global_position = Vector2(700, 400)
	
	# Let camera follow for a short time
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Check if camera moved toward player
	var camera_moved = camera.global_position.distance_to(original_camera_pos) > 10
	var camera_following = camera.global_position.distance_to(player.global_position) < original_camera_pos.distance_to(player.global_position)
	
	# Restore original positions
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_camera_pos
	player.global_position = original_player_pos
	
	end_test(camera_moved && camera_following, "Camera should follow player movement when in FOLLOWING_PLAYER state")

func test_camera_stops_at_boundaries():
	start_test("Camera Stops at Boundaries")
	
	# Save original positions
	var original_camera_pos = camera.global_position
	var original_player_pos = player.global_position
	
	# Enable player following
	camera.follow_player = true
	camera.target_player = player
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Move player far outside walkable area
	player.global_position = Vector2(2000, 2000)
	
	# Let camera follow for a short time
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Check if camera stayed within bounds
	var within_bounds = camera.camera_bounds.has_point(camera.global_position)
	
	# Restore original positions
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_camera_pos
	player.global_position = original_player_pos
	
	end_test(within_bounds, "Camera should stop at boundaries even when following player")

func test_player_stays_within_walkable_areas():
	start_test("Player Stays Within Walkable Areas")
	
	# Save original position
	var original_position = player.global_position
	
	# Test various positions to check if is_position_walkable works correctly
	var inside_position = Vector2(500, 300)  # Inside walkable area
	var outside_position = Vector2(50, 50)   # Outside walkable area
	
	# Check if walkable area detection works
	var inside_is_walkable = district.is_position_walkable(inside_position)
	var outside_is_walkable = district.is_position_walkable(outside_position)
	
	# Restore original position
	player.global_position = original_position
	
	end_test(inside_is_walkable && !outside_is_walkable, "Walkable area detection should correctly identify valid positions")

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
	var suite_name = current_suite
	var passed = test_results[suite_name].passed
	var failed = test_results[suite_name].failed
	var total = passed + failed
	debug_log("Suite completed: " + str(passed) + "/" + str(total) + " tests passed", true)

func start_test(test_name):
	current_test = test_name
	debug_log("Running test: " + test_name)

func end_test(passed, message = ""):
	var suite_name = current_suite
	var test_name = current_test
	
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
			var suite_name = current_suite
			var test_name = test
			var message = test_results[suite_name].tests.get(test_name, {}).get("message", "")
			debug_log("- " + test + (": " + message if message else ""), true)
	
	if tests_failed == 0:
		debug_log("\nAll tests passed! 🎉", true)

func debug_log(message, force_print = false):
	if log_debug_info || force_print:
		print(message)