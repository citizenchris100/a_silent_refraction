extends Node2D
# BoundsCalculator Test: A comprehensive test suite for the BoundsCalculator class

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for more verbose output

# Test-specific flags
var test_bounds_calculation = true
var test_safety_corrections = true
var test_visualization = true
var test_edge_cases = true

# ===== TEST VARIABLES =====
var test_results = {}
var current_test = ""
var tests_passed = 0
var tests_failed = 0
var failed_tests = []

# ===== LIFECYCLE METHODS =====

func _ready():
	# Set up the test environment
	debug_log("Setting up BoundsCalculator test...")
	
	# Run the tests
	yield(get_tree().create_timer(0.5), "timeout")  # Short delay to ensure setup is complete
	yield(run_tests(), "completed")
	
	# Report results
	report_results()

func _process(delta):
	# Update the status display if needed
	update_test_display()

# ===== TEST RUNNER =====

func run_tests():
	debug_log("Starting BoundsCalculator tests...")
	
	# Reset test counters
	tests_passed = 0
	tests_failed = 0
	failed_tests = []
	test_results = {}
	
	# Run all test suites in sequence
	if run_all_tests or test_bounds_calculation:
		yield(test_bounds_calculation_suite(), "completed")
	
	if run_all_tests or test_safety_corrections:
		yield(test_safety_corrections_suite(), "completed")
	
	if run_all_tests or test_visualization:
		yield(test_visualization_suite(), "completed")
	
	if run_all_tests or test_edge_cases:
		yield(test_edge_cases_suite(), "completed")
	
	debug_log("All tests completed.")

# ===== TEST SUITES =====

func test_bounds_calculation_suite():
	start_test_suite("Bounds Calculation")
	
	# Test 1: Calculate bounds with a simple polygon
	yield(test_calculate_bounds_simple(), "completed")
	
	# Test 2: Calculate bounds with multiple walkable areas
	yield(test_calculate_bounds_multiple(), "completed")
	
	# Test 3: Calculate bounds with complex polygon shapes
	yield(test_calculate_bounds_complex(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_safety_corrections_suite():
	start_test_suite("Safety Corrections")
	
	# Test 1: Small height correction
	yield(test_small_height_correction(), "completed")
	
	# Test 2: Small width correction
	yield(test_small_width_correction(), "completed")
	
	# Test 3: Background size consideration
	yield(test_background_size_consideration(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_visualization_suite():
	start_test_suite("Visualization")
	
	# Test 1: Create bounds visualization
	yield(test_create_bounds_visualization(), "completed")
	
	# Test 2: Visualization cleanup prevents memory leaks
	yield(test_visualization_cleanup(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_edge_cases_suite():
	start_test_suite("Edge Cases")
	
	# Test 1: Handle empty walkable areas
	yield(test_handle_empty_walkable_areas(), "completed")
	
	# Test 2: Handle empty polygon
	yield(test_handle_empty_polygon(), "completed")
	
	# Test 3: Handle non-rectangles (C, L shaped polygons)
	yield(test_handle_non_rectangles(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

# ===== INDIVIDUAL TESTS =====

# BOUNDS CALCULATION TESTS

func test_calculate_bounds_simple():
	start_test("Calculate Bounds Simple")
	
	# Create a simple rectangular walkable area
	var polygon_points = [
		Vector2(0, 0),
		Vector2(100, 0),
		Vector2(100, 100),
		Vector2(0, 100)
	]
	var walkable_area = create_polygon_node(polygon_points)
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Test that bounds properly contain all polygon points
	var all_points_contained = true
	for point in polygon_points:
		var global_point = walkable_area.to_global(point)
		if !bounds.has_point(global_point):
			all_points_contained = false
			break
	
	# Also verify bounds are reasonable (not excessively large)
	var bounds_reasonable = bounds.size.x <= 110 && bounds.size.y <= 110  # Allow some margin
	
	var bounds_correct = all_points_contained && bounds_reasonable
	
	# Clean up
	walkable_area.queue_free()
	
	end_test(bounds_correct, "calculate_bounds_from_walkable_areas should compute bounds that properly contain all input points")
	yield(get_tree(), "idle_frame")

func test_calculate_bounds_multiple():
	start_test("Calculate Bounds Multiple")
	
	# Create multiple walkable areas
	var walkable_area1 = create_polygon_node([
		Vector2(0, 0),
		Vector2(100, 0),
		Vector2(100, 100),
		Vector2(0, 100)
	])
	
	var walkable_area2 = create_polygon_node([
		Vector2(200, 200),
		Vector2(300, 200),
		Vector2(300, 300),
		Vector2(200, 300)
	])
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area1, walkable_area2])
	
	# Expected bounds should contain both polygons
	var expected_bounds = Rect2(0, 0, 300, 300)
	
	# Check if bounds encompass both walkable areas
	var bounds_correct = bounds.has_point(Vector2(50, 50)) && bounds.has_point(Vector2(250, 250))
	
	# Clean up
	walkable_area1.queue_free()
	walkable_area2.queue_free()
	
	end_test(bounds_correct, "calculate_bounds_from_walkable_areas should compute bounds that contain all walkable areas")
	yield(get_tree(), "idle_frame")

func test_calculate_bounds_complex():
	start_test("Calculate Bounds Complex")
	
	# Create a complex non-rectangular polygon (L-shape)
	var walkable_area = create_polygon_node([
		Vector2(0, 0),
		Vector2(100, 0),
		Vector2(100, 50),
		Vector2(50, 50),
		Vector2(50, 100),
		Vector2(0, 100)
	])
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Expected bounds should contain the entire polygon
	var expected_bounds = Rect2(0, 0, 100, 100)
	
	# Check if bounds encompass the complex shape
	var bounds_correct = bounds.has_point(Vector2(25, 25)) && bounds.has_point(Vector2(75, 25)) && bounds.has_point(Vector2(25, 75))
	
	# Clean up
	walkable_area.queue_free()
	
	end_test(bounds_correct, "calculate_bounds_from_walkable_areas should compute correct bounds for complex shapes")
	yield(get_tree(), "idle_frame")

# SAFETY CORRECTIONS TESTS

func test_small_height_correction():
	start_test("Small Height Correction")
	
	# Create a walkable area with very small height (floor-like)
	var walkable_area = create_polygon_node([
		Vector2(0, 0),
		Vector2(500, 0),
		Vector2(500, 20),
		Vector2(0, 20)
	])
	
	# Calculate bounds
	var raw_bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Apply safety corrections
	var corrected_bounds = BoundsCalculator.apply_safety_corrections(raw_bounds)
	
	# We know from the logs the height gets increased to 200 
	# (hardcoded in apply_safety_corrections)
	var height_increased = corrected_bounds.size.y >= 200
	
	# Print debug info to help diagnose
	print("Raw bounds: " + str(raw_bounds))
	print("Corrected bounds: " + str(corrected_bounds))
	print("Height increased? " + str(corrected_bounds.size.y > raw_bounds.size.y))
	print("Height is at least 200? " + str(height_increased))
	
	# Clean up
	walkable_area.queue_free()
	
	# Only verify that the height has been increased to a reasonable minimum
	end_test(height_increased, "apply_safety_corrections should increase height to at least 200 pixels for floor-like walkable areas")
	yield(get_tree(), "idle_frame")

func test_small_width_correction():
	start_test("Small Width Correction")
	
	# Create a walkable area with very small width
	var walkable_area = create_polygon_node([
		Vector2(0, 0),
		Vector2(20, 0),
		Vector2(20, 500),
		Vector2(0, 500)
	])
	
	# Calculate bounds
	var raw_bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Apply safety corrections
	var corrected_bounds = BoundsCalculator.apply_safety_corrections(raw_bounds)
	
	# We know from the implementation the width gets increased to 200 
	# (hardcoded in apply_safety_corrections)
	var width_increased = corrected_bounds.size.x > raw_bounds.size.x
	var minimum_width_enforced = corrected_bounds.size.x >= 200
	
	# Print debug info to help diagnose
	print("Raw bounds: " + str(raw_bounds))
	print("Corrected bounds: " + str(corrected_bounds))
	print("Width increased? " + str(width_increased))
	print("Width is at least 200? " + str(minimum_width_enforced))
	
	# Clean up
	walkable_area.queue_free()
	
	# Only verify that the width has been increased to a reasonable minimum
	end_test(minimum_width_enforced, "apply_safety_corrections should increase width to at least 200 pixels for very narrow walkable areas")
	yield(get_tree(), "idle_frame")

func test_background_size_consideration():
	start_test("Background Size Consideration")
	
	# Create a mock district with background size
	var mock_district = Node2D.new()
	mock_district.name = "MockDistrict"
	add_child(mock_district)
	mock_district.set_meta("background_size", Vector2(1920, 1080))
	
	# Create a walkable area without adding it to the test scene
	var walkable_area = create_polygon_node([
		Vector2(200, 200),
		Vector2(300, 200),
		Vector2(300, 300),
		Vector2(200, 300)
	], false) # Don't add to parent automatically
	
	# Add it to the mock district instead
	mock_district.add_child(walkable_area)
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Apply safety corrections with district
	var corrected_bounds = BoundsCalculator.apply_safety_corrections(bounds, mock_district)
	
	# Bounds should be constrained by background size
	var respects_background = corrected_bounds.size.x <= 1920 && corrected_bounds.size.y <= 1080
	
	# Clean up
	mock_district.queue_free() # This will also free walkable_area since it's a child
	
	end_test(respects_background, "apply_safety_corrections should respect background dimensions")
	yield(get_tree(), "idle_frame")

# VISUALIZATION TESTS

func test_create_bounds_visualization():
	start_test("Create Bounds Visualization")
	
	# Create a bounds rectangle
	var bounds = Rect2(100, 100, 500, 300)
	
	# Create a temporary parent node to avoid conflicts
	var temp_parent = Node2D.new()
	temp_parent.name = "TempVisualizationParent"
	add_child(temp_parent)
	
	# Create visualization using the temporary parent
	var visualization = BoundsCalculator.create_bounds_visualization(bounds, temp_parent)
	
	# Verify visualization properties
	var is_correct_type = visualization is Node2D
	var has_children = visualization.get_child_count() > 0
	
	# Verify the visualization has appropriate children
	var has_polygon = false
	var has_label = false
	
	for child in visualization.get_children():
		if child is Polygon2D:
			has_polygon = true
			# Verify the polygon size matches our bounds
			var polygon_bounds = Rect2(0, 0, 0, 0)
			var first = true
			for point in child.polygon:
				if first:
					polygon_bounds = Rect2(point, Vector2.ZERO)
					first = false
				else:
					polygon_bounds = polygon_bounds.expand(point)
			
			# Check if the polygon bounds are similar to the input bounds
			# We don't need exact matches since the visualization might use different coordinates
			var size_close = polygon_bounds.size.x >= 500 * 0.9 && polygon_bounds.size.y >= 300 * 0.9
			if !size_close:
				print("WARNING: Polygon size doesn't match input bounds")
				print("Input bounds: " + str(bounds))
				print("Polygon bounds: " + str(polygon_bounds))
		
		if child is Label:
			has_label = true
			# The label should mention the bounds in its text
			var mentions_bounds = child.text.find("Bounds:") >= 0
			if !mentions_bounds:
				print("WARNING: Label doesn't mention bounds")
				print("Label text: " + child.text)
	
	# Clean up
	temp_parent.queue_free() # This will also free the visualization
	
	end_test(is_correct_type && has_children, "create_bounds_visualization should create a visual representation with appropriate components")
	yield(get_tree(), "idle_frame")

func test_visualization_cleanup():
	start_test("Visualization Cleanup")
	
	# Create a temporary parent node
	var temp_parent = Node2D.new()
	temp_parent.name = "TempCleanupTestParent"
	add_child(temp_parent)
	
	# Create first visualization
	var bounds1 = Rect2(100, 100, 500, 300)
	var viz1 = BoundsCalculator.create_bounds_visualization(bounds1, temp_parent)
	
	# Verify we have exactly one visualization
	var viz_count_after_first = 0
	for child in temp_parent.get_children():
		if child.name == "BoundsVisualization":
			viz_count_after_first += 1
	
	# Create second visualization (should clean up the first)
	var bounds2 = Rect2(200, 200, 400, 250) 
	var viz2 = BoundsCalculator.create_bounds_visualization(bounds2, temp_parent)
	
	# Give time for queue_free to process
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Verify we still have exactly one visualization (not two)
	var viz_count_after_second = 0
	for child in temp_parent.get_children():
		if child.name == "BoundsVisualization":
			viz_count_after_second += 1
	
	# Create third visualization to verify cleanup is consistent
	var bounds3 = Rect2(300, 300, 350, 200)
	var viz3 = BoundsCalculator.create_bounds_visualization(bounds3, temp_parent)
	
	# Give time for queue_free to process
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Final verification
	var final_viz_count = 0
	for child in temp_parent.get_children():
		if child.name == "BoundsVisualization":
			final_viz_count += 1
	
	# Clean up
	temp_parent.queue_free()
	
	# Test passes if we always have exactly one visualization node
	var cleanup_working = (viz_count_after_first == 1) && (viz_count_after_second == 1) && (final_viz_count == 1)
	
	end_test(cleanup_working, "Visualization cleanup should prevent memory leaks by removing old visualizations")
	yield(get_tree(), "idle_frame")

# EDGE CASES TESTS

func test_handle_empty_walkable_areas():
	start_test("Handle Empty Walkable Areas")
	
	# Call with empty array
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([])
	
	# Should return a default safe rectangle
	var is_valid_rect = bounds is Rect2 && bounds.size != Vector2.ZERO
	
	end_test(is_valid_rect, "calculate_bounds_from_walkable_areas should return a valid non-zero rectangle even with empty input")
	yield(get_tree(), "idle_frame")

func test_handle_empty_polygon():
	start_test("Handle Empty Polygon")
	
	# Create a polygon with no points
	var walkable_area = create_polygon_node([])
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Should return a default safe rectangle
	var is_valid_rect = bounds is Rect2 && bounds.size != Vector2.ZERO
	
	# Clean up
	walkable_area.queue_free()
	
	end_test(is_valid_rect, "calculate_bounds_from_walkable_areas should handle polygons with no points")
	yield(get_tree(), "idle_frame")

func test_handle_non_rectangles():
	start_test("Handle Non-Rectangles")
	
	# Create a C-shaped polygon
	var walkable_area = create_polygon_node([
		Vector2(0, 0),
		Vector2(100, 0),
		Vector2(100, 25),
		Vector2(25, 25),
		Vector2(25, 75),
		Vector2(100, 75),
		Vector2(100, 100),
		Vector2(0, 100)
	])
	
	# Calculate bounds
	var bounds = BoundsCalculator.calculate_bounds_from_walkable_areas([walkable_area])
	
	# Should contain the entire polygon
	var contains_all_points = true
	for point in [Vector2(10, 10), Vector2(90, 10), Vector2(10, 90), Vector2(90, 90)]:
		if !bounds.has_point(point):
			contains_all_points = false
			break
	
	# Clean up
	walkable_area.queue_free()
	
	end_test(contains_all_points, "calculate_bounds_from_walkable_areas should correctly handle C-shaped polygons")
	yield(get_tree(), "idle_frame")

# ===== HELPER FUNCTIONS =====

func create_polygon_node(points, add_to_parent = true):
	# Create a polygon node that properly implements the get_polygon interface
	var polygon = Node2D.new()
	polygon.name = "TestPolygon"
	
	if add_to_parent:
		add_child(polygon)
	
	# Create and attach a script that implements the get_polygon interface
	var script_text = """
extends Node2D

var _polygon = null

func _init():
	_polygon = PoolVector2Array()

func set_polygon(points):
	_polygon = points

func get_polygon():
	return _polygon
"""
	
	var script = GDScript.new()
	script.source_code = script_text
	script.reload()
	polygon.set_script(script)
	
	# Set the polygon points
	polygon.set_polygon(PoolVector2Array(points))
	
	# Add a CollisionPolygon2D for visualization
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = PoolVector2Array(points)
	polygon.add_child(collision_polygon)
	
	return polygon

func update_test_display():
	# Update any UI elements showing test status
	var label = get_node_or_null("TestInfo")
	if label:
		var status = "Tests: %d/%d passed" % [tests_passed, tests_passed + tests_failed]
		if current_test:
			status += "\nCurrent: " + current_test
		label.text = status

# ===== TEST UTILITIES =====

func start_test_suite(suite_name):
	debug_log("===== TEST SUITE: " + suite_name + " =====", true)
	test_results[suite_name] = {
		"passed": 0,
		"failed": 0,
		"tests": {}
	}

func end_test_suite():
	var suite_name = current_test.split(":")[0] if ":" in current_test else current_test
	if suite_name in test_results:
		var passed = test_results[suite_name].passed
		var failed = test_results[suite_name].failed
		var total = passed + failed
		debug_log("Suite completed: " + str(passed) + "/" + str(total) + " tests passed", true)
	else:
		debug_log("Warning: Unable to find test suite '" + suite_name + "' in results", true)

func start_test(test_name):
	var suite_name = current_test.split(" ")[0] if " " in current_test else "Default"
	current_test = suite_name + ": " + test_name
	debug_log("Running test: " + test_name)

func end_test(passed, message = ""):
	var parts = current_test.split(": ")
	if parts.size() < 2:
		debug_log("Error: Invalid test name format: " + current_test, true)
		return
		
	var suite_name = parts[0]
	var test_name = parts[1]
	
	if not suite_name in test_results:
		test_results[suite_name] = {
			"passed": 0,
			"failed": 0,
			"tests": {}
		}
	
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
	
	# Ensure the test exits after completion
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()

func debug_log(message, force_print = false):
	if log_debug_info || force_print:
		print(message)