extends Node2D
# Visual Bounds Validation Test: Tests that bounds calculations result in proper visual positioning

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for more verbose output

# ===== TEST VARIABLES =====
var tests_passed = 0
var tests_failed = 0
var failed_tests = []
var current_test = ""
var current_suite = ""

# Mock viewport size (simulating the actual game viewport)
var mock_viewport_size = Vector2(1424, 952)

# ===== LIFECYCLE METHODS =====

func _ready():
	debug_log("Setting up Visual Bounds Validation test...")
	run_tests()
	report_results()
	debug_log("Visual bounds validation tests complete - exiting...")
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit()

func run_tests():
	debug_log("Starting Visual Bounds Validation tests...")
	
	# Test suite 1: Bounds-to-Viewport Ratio Validation
	yield(test_viewport_bounds_ratio_suite(), "completed")
	
	# Test suite 2: Background Positioning Validation  
	yield(test_background_positioning_suite(), "completed")

# ===== TEST SUITES =====

func test_viewport_bounds_ratio_suite():
	start_test_suite("Bounds-to-Viewport Ratio Validation")
	
	# Test 1: Bounds height should accommodate viewport height
	yield(test_bounds_height_accommodates_viewport(), "completed")
	
	# Test 2: Floor-like walkable areas should expand bounds properly
	yield(test_floor_walkable_bounds_expansion(), "completed")
	
	# Test 3: Very narrow bounds should be rejected or corrected
	yield(test_narrow_bounds_correction(), "completed")
	
	end_test_suite()

func test_background_positioning_suite():
	start_test_suite("Background Positioning Validation")
	
	# Test 1: Camera bounds should prevent background clipping
	yield(test_camera_bounds_prevent_clipping(), "completed")
	
	# Test 2: Background scaling should maintain proper positioning
	yield(test_background_scaling_positioning(), "completed")
	
	end_test_suite()

# ===== INDIVIDUAL TESTS =====

func test_bounds_height_accommodates_viewport():
	start_test("Bounds Height Accommodates Viewport")
	
	# Create a floor-like walkable area (realistic scenario from the bug)
	# This represents the problematic walkable area from the camera-system test
	var floor_polygon = [
		Vector2(0, 822),     # Floor level
		Vector2(4691, 822),  # Floor level (wide)
		Vector2(4691, 947),  # Bottom edge
		Vector2(0, 947)      # Bottom edge
	]
	
	var walkable_area = create_polygon_node(floor_polygon)
	
	# Calculate bounds using the current system
	var raw_bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Apply safety corrections with viewport awareness
	var calculated_bounds = BoundsCalculator.apply_safety_corrections(raw_bounds, null, mock_viewport_size)
	
	debug_log("Calculated bounds: " + str(calculated_bounds))
	debug_log("Mock viewport size: " + str(mock_viewport_size))
	debug_log("Bounds height: " + str(calculated_bounds.size.y))
	debug_log("Viewport height: " + str(mock_viewport_size.y))
	
	# THE CRITICAL TEST: Bounds height should be reasonable relative to viewport
	# If bounds height is much smaller than viewport, we'll get visual positioning issues
	var height_ratio = calculated_bounds.size.y / mock_viewport_size.y
	var acceptable_height_ratio = height_ratio >= 0.3  # At least 30% of viewport height
	
	debug_log("Height ratio (bounds/viewport): " + str(height_ratio))
	debug_log("Is height ratio acceptable (>=0.3): " + str(acceptable_height_ratio))
	
	# This test should FAIL with current implementation
	# Current bounds height ~127px, viewport 952px = ratio ~0.13 (13%)
	end_test(acceptable_height_ratio, "Bounds height should be at least 30% of viewport height to prevent visual positioning issues")
	
	# Clean up
	walkable_area.queue_free()

func test_floor_walkable_bounds_expansion():
	start_test("Floor Walkable Bounds Expansion")
	
	# Create the exact problematic scenario from camera-system output
	var problematic_polygon = [
		Vector2(4684, 843), 
		Vector2(3731, 864), 
		Vector2(3260, 822), 
		Vector2(4396, 877), 
		Vector2(693, 860), 
		Vector2(523, 895), 
		Vector2(398, 895), 
		Vector2(267, 870), 
		Vector2(215, 822), 
		Vector2(3, 850), 
		Vector2(0, 947), 
		Vector2(4691, 943), 
		Vector2(4677, 843), 
		Vector2(3707, 860)
	]
	
	var walkable_area = create_polygon_node(problematic_polygon)
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	debug_log("Problematic polygon bounds: " + str(bounds))
	
	# Test: When walkable area represents a floor, bounds should expand vertically
	# to provide reasonable camera movement space
	var has_reasonable_height = bounds.size.y >= (mock_viewport_size.y * 0.5)  # At least 50% of viewport
	
	debug_log("Bounds height: " + str(bounds.size.y))
	debug_log("50% of viewport height: " + str(mock_viewport_size.y * 0.5))
	debug_log("Has reasonable height: " + str(has_reasonable_height))
	
	# This should FAIL - current implementation gives ~127px height for 952px viewport
	end_test(has_reasonable_height, "Floor-like walkable areas should expand bounds to at least 50% of viewport height")
	
	walkable_area.queue_free()

func test_narrow_bounds_correction():
	start_test("Narrow Bounds Correction")
	
	# Create bounds that would cause the exact issue seen in camera-system
	var narrow_polygon = [
		Vector2(0, 900),
		Vector2(4000, 900),  
		Vector2(4000, 950),  # Only 50px height
		Vector2(0, 950)
	]
	
	var walkable_area = create_polygon_node(narrow_polygon)
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	debug_log("Narrow bounds test - calculated bounds: " + str(bounds))
	
	# Test: System should detect and correct bounds that are too narrow for viewport
	var bounds_too_narrow_for_viewport = bounds.size.y < (mock_viewport_size.y * 0.2)  # Less than 20% of viewport
	
	debug_log("Bounds height: " + str(bounds.size.y))
	debug_log("20% of viewport: " + str(mock_viewport_size.y * 0.2))
	debug_log("Bounds too narrow: " + str(bounds_too_narrow_for_viewport))
	
	# This test should PASS (detect the problem) but then we need to fix the system
	# The issue is that the system should expand these bounds much more aggressively
	end_test(!bounds_too_narrow_for_viewport, "System should expand bounds that are too narrow relative to viewport size")
	
	walkable_area.queue_free()

func test_camera_bounds_prevent_clipping():
	start_test("Camera Bounds Prevent Clipping")
	
	# Simulate the exact scenario from debug001.png
	# Background: 2448x496 scaled to 4698x952
	var background_size = Vector2(4698, 952)
	var calculated_bounds = Rect2(-1, 821, 4693, 127)  # From actual camera-system output
	
	debug_log("Background size: " + str(background_size))
	debug_log("Calculated bounds: " + str(calculated_bounds))
	
	# Test: Camera positioned within these bounds should not cause background clipping
	# If camera is centered in bounds, check if it shows the full background properly
	var camera_center_y = calculated_bounds.position.y + calculated_bounds.size.y / 2
	var half_viewport_height = mock_viewport_size.y / 2
	
	# Calculate what portion of background would be visible
	var visible_top = camera_center_y - half_viewport_height
	var visible_bottom = camera_center_y + half_viewport_height
	
	debug_log("Camera center Y: " + str(camera_center_y))
	debug_log("Visible top: " + str(visible_top))
	debug_log("Visible bottom: " + str(visible_bottom))
	debug_log("Background top: 0, Background bottom: " + str(background_size.y))
	
	# Check if camera view would extend beyond background
	var clips_above = visible_top < 0
	var clips_below = visible_bottom > background_size.y
	var causes_clipping = clips_above || clips_below
	
	debug_log("Clips above background: " + str(clips_above))
	debug_log("Clips below background: " + str(clips_below))
	debug_log("Causes clipping: " + str(causes_clipping))
	
	# This should FAIL - the current bounds cause severe clipping issues
	end_test(!causes_clipping, "Camera bounds should prevent background clipping issues")

func test_background_scaling_positioning():
	start_test("Background Scaling Positioning")
	
	# Test the relationship between background scaling and bounds calculation
	var original_bg_size = Vector2(2448, 496)  # From camera-system output
	var scaled_bg_size = Vector2(4698, 952)    # After scaling
	var bounds = Rect2(-1, 821, 4693, 127)    # Calculated bounds
	
	debug_log("Original background: " + str(original_bg_size))
	debug_log("Scaled background: " + str(scaled_bg_size))
	debug_log("Bounds: " + str(bounds))
	
	# Test: Bounds should be compatible with scaled background dimensions
	var bounds_height_vs_bg_height = bounds.size.y / scaled_bg_size.y
	var reasonable_height_ratio = bounds_height_vs_bg_height >= 0.5  # At least 50% of background height
	
	debug_log("Bounds height vs background height ratio: " + str(bounds_height_vs_bg_height))
	debug_log("Is ratio reasonable (>=0.5): " + str(reasonable_height_ratio))
	
	# This should FAIL - bounds are only ~13% of background height
	end_test(reasonable_height_ratio, "Bounds height should be at least 50% of scaled background height")

# ===== HELPER METHODS =====

func create_polygon_node(points: Array) -> Polygon2D:
	var polygon = Polygon2D.new()
	polygon.name = "TestPolygon"
	var pool_array = PoolVector2Array()
	for point in points:
		pool_array.append(point)
	polygon.polygon = pool_array
	
	# Add get_polygon method for interface compatibility
	polygon.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
	
	add_child(polygon)
	return polygon

# ===== TEST FRAMEWORK METHODS =====

func start_test_suite(suite_name: String):
	current_suite = suite_name
	debug_log("===== TEST SUITE: " + suite_name + " =====")

func end_test_suite():
	debug_log("Suite completed: " + str(tests_passed) + "/" + str(tests_passed + tests_failed) + " tests passed")

func start_test(test_name: String):
	current_test = test_name
	debug_log("Running test: " + test_name)

func end_test(passed: bool, description: String):
	if passed:
		debug_log("✓ PASS: " + current_test + ": " + description)
		tests_passed += 1
	else:
		debug_log("✗ FAIL: " + current_test + ": " + description)
		tests_failed += 1
		failed_tests.append(current_suite + "::" + current_test + ": " + description)
	
	yield(get_tree(), "idle_frame")

func report_results():
	debug_log("")
	debug_log("===== TEST RESULTS =====")
	debug_log("Total Tests: " + str(tests_passed + tests_failed))
	debug_log("Passed: " + str(tests_passed))
	debug_log("Failed: " + str(tests_failed))
	
	if tests_failed > 0:
		debug_log("")
		debug_log("Failed Tests:")
		for failed in failed_tests:
			debug_log("- " + failed)

func debug_log(message: String):
	if log_debug_info:
		print(message)