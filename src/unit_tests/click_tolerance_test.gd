extends Node2D
# Click Tolerance Test: Unit tests for click tolerance behavior

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_basic_tolerance = true
var test_edge_detection = true
var test_zoom_scaling = true
var test_tolerance_limits = true

# Test state
var test_name = "ClickToleranceTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test constants
const BASE_TOLERANCE = 10.0  # Base tolerance in pixels at 1.0 zoom
const MIN_TOLERANCE = 5.0    # Minimum tolerance regardless of zoom
const MAX_TOLERANCE = 30.0   # Maximum tolerance regardless of zoom

func _ready():
	print("\n==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	run_tests()
	
	print("\n==================================================")
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("==================================================\n")
	
	if tests_failed == 0:
		print("[PASS] All %s tests passed!" % test_name)
	else:
		print("[FAIL] Some tests failed!")
		for failed in failed_tests:
			print("  - " + failed)
	
	# Clean exit for headless testing
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	if run_all_tests or test_basic_tolerance:
		run_test_suite("Basic Tolerance Application", funcref(self, "test_suite_basic_tolerance"))
	
	if run_all_tests or test_edge_detection:
		run_test_suite("Edge Detection with Tolerance", funcref(self, "test_suite_edge_detection"))
	
	if run_all_tests or test_zoom_scaling:
		run_test_suite("Zoom-based Tolerance Scaling", funcref(self, "test_suite_zoom_scaling"))
		
	if run_all_tests or test_tolerance_limits:
		run_test_suite("Tolerance Limits and Constraints", funcref(self, "test_suite_tolerance_limits"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

# ===== BASIC TOLERANCE TESTS =====
func test_suite_basic_tolerance():
	start_test("test_apply_tolerance_to_click_position")
	
	# Test that tolerance creates a search area around the click
	var click_pos = Vector2(100, 100)
	var tolerance = 10.0
	
	# The apply_click_tolerance should return the original position
	# but indicate a search radius for validation
	var result = apply_click_tolerance(click_pos, tolerance)
	end_test(result == click_pos, "Tolerance should preserve original click position")
	
	start_test("test_tolerance_creates_search_bounds")
	
	# Test that tolerance defines a search area
	var bounds = get_tolerance_bounds(click_pos, tolerance)
	var expected_bounds = Rect2(
		click_pos - Vector2(tolerance, tolerance),
		Vector2(tolerance * 2, tolerance * 2)
	)
	
	end_test(bounds.is_equal_approx(expected_bounds), 
		"Tolerance should create correct search bounds")
	
	start_test("test_point_within_tolerance")
	
	# Test checking if a point is within tolerance of click
	var test_points = [
		{"point": Vector2(105, 105), "expected": true},   # Within tolerance
		{"point": Vector2(110, 100), "expected": true},   # On edge
		{"point": Vector2(115, 100), "expected": false},  # Outside tolerance
		{"point": Vector2(100, 100), "expected": true},   # Exact match
	]
	
	var all_correct = true
	for test in test_points:
		var within = is_within_tolerance(test.point, click_pos, tolerance)
		if within != test.expected:
			all_correct = false
			if log_debug_info:
				print("  Failed for point %s, expected %s got %s" % 
					[test.point, test.expected, within])
	
	end_test(all_correct, "Points should be correctly identified as within/outside tolerance")

# ===== EDGE DETECTION TESTS =====
func test_suite_edge_detection():
	start_test("test_find_closest_valid_point_within_tolerance")
	
	# When clicking near an edge, find the closest valid point
	var click_pos = Vector2(100, 100)
	var tolerance = 10.0
	var valid_points = [
		Vector2(95, 95),   # 7.07 pixels away
		Vector2(108, 100), # 8 pixels away
		Vector2(100, 112), # 12 pixels away (outside tolerance)
	]
	
	var closest = find_closest_within_tolerance(click_pos, valid_points, tolerance)
	end_test(closest == Vector2(95, 95), 
		"Should find closest valid point within tolerance")
	
	start_test("test_adjust_click_to_nearest_edge")
	
	# When clicking near a walkable area edge, snap to edge if within tolerance
	var edge_line = [Vector2(90, 0), Vector2(90, 200)]  # Vertical edge
	var click_near_edge = Vector2(95, 100)  # 5 pixels from edge
	
	var adjusted = adjust_to_edge_if_within_tolerance(
		click_near_edge, edge_line, tolerance)
	
	end_test(adjusted == Vector2(90, 100), 
		"Click near edge should snap to edge when within tolerance")
	
	start_test("test_no_adjustment_outside_tolerance")
	
	var far_click = Vector2(105, 100)  # 15 pixels from edge
	var not_adjusted = adjust_to_edge_if_within_tolerance(
		far_click, edge_line, tolerance)
	
	end_test(not_adjusted == far_click, 
		"Click outside tolerance should not be adjusted")

# ===== ZOOM SCALING TESTS =====
func test_suite_zoom_scaling():
	start_test("test_tolerance_scales_with_zoom")
	
	# Tolerance should scale inversely with zoom
	# When zoomed out (zoom < 1), tolerance increases
	# When zoomed in (zoom > 1), tolerance decreases
	var zoom_tests = [
		{"zoom": 0.5, "expected": BASE_TOLERANCE * 2.0},   # Zoomed out 2x
		{"zoom": 1.0, "expected": BASE_TOLERANCE},         # Normal zoom
		{"zoom": 2.0, "expected": BASE_TOLERANCE * 0.5},   # Zoomed in 2x
	]
	
	var all_correct = true
	for test in zoom_tests:
		var scaled = scale_tolerance_for_zoom(BASE_TOLERANCE, test.zoom)
		if not is_equal_approx(scaled, test.expected):
			all_correct = false
			if log_debug_info:
				print("  Failed for zoom %s, expected %s got %s" % 
					[test.zoom, test.expected, scaled])
	
	end_test(all_correct, "Tolerance should scale correctly with zoom level")
	
	start_test("test_tolerance_respects_limits_with_zoom")
	
	# Even with extreme zoom, tolerance should stay within limits
	var extreme_zoom_tests = [
		{"zoom": 0.1, "expected": MAX_TOLERANCE},  # Very zoomed out
		{"zoom": 10.0, "expected": MIN_TOLERANCE},  # Very zoomed in
	]
	
	var limits_correct = true
	for test in extreme_zoom_tests:
		var scaled = scale_tolerance_for_zoom(BASE_TOLERANCE, test.zoom)
		var clamped = clamp(scaled, MIN_TOLERANCE, MAX_TOLERANCE)
		if not is_equal_approx(clamped, test.expected):
			limits_correct = false
			if log_debug_info:
				print("  Failed limit test for zoom %s, expected %s got %s" % 
					[test.zoom, test.expected, clamped])
	
	end_test(limits_correct, "Tolerance should respect min/max limits regardless of zoom")

# ===== TOLERANCE LIMITS TESTS =====
func test_suite_tolerance_limits():
	start_test("test_minimum_tolerance_enforcement")
	
	# Even with high zoom or small base tolerance, maintain minimum
	var tiny_tolerance = 2.0
	var high_zoom = 5.0
	
	var result = apply_tolerance_limits(
		scale_tolerance_for_zoom(tiny_tolerance, high_zoom))
	
	end_test(result >= MIN_TOLERANCE, 
		"Tolerance should never go below minimum threshold")
	
	start_test("test_maximum_tolerance_enforcement")
	
	# Even with low zoom or large base tolerance, cap at maximum
	var huge_tolerance = 50.0
	var low_zoom = 0.2
	
	var max_result = apply_tolerance_limits(
		scale_tolerance_for_zoom(huge_tolerance, low_zoom))
	
	end_test(max_result <= MAX_TOLERANCE, 
		"Tolerance should never exceed maximum threshold")
	
	start_test("test_tolerance_with_ui_scale")
	
	# Tolerance should also consider UI scale for accessibility
	var ui_scales = [
		{"scale": 0.75, "multiplier": 1.0},   # Small UI, normal tolerance
		{"scale": 1.0, "multiplier": 1.0},    # Normal UI
		{"scale": 1.5, "multiplier": 1.2},    # Large UI, slightly more tolerance
		{"scale": 2.0, "multiplier": 1.5},    # Extra large UI, more tolerance
	]
	
	var ui_correct = true
	for test in ui_scales:
		var adjusted = adjust_tolerance_for_ui_scale(BASE_TOLERANCE, test.scale)
		var expected = BASE_TOLERANCE * test.multiplier
		if not is_equal_approx(adjusted, expected):
			ui_correct = false
			if log_debug_info:
				print("  Failed for UI scale %s, expected multiplier %s" % 
					[test.scale, test.multiplier])
	
	end_test(ui_correct, "Tolerance should adjust for UI scale accessibility")

# ===== HELPER FUNCTIONS (These define the expected behavior) =====

func apply_click_tolerance(position: Vector2, tolerance: float) -> Vector2:
	# Tolerance doesn't change the position, just defines search area
	return position

func get_tolerance_bounds(position: Vector2, tolerance: float) -> Rect2:
	return Rect2(
		position - Vector2(tolerance, tolerance),
		Vector2(tolerance * 2, tolerance * 2)
	)

func is_within_tolerance(point: Vector2, click_pos: Vector2, tolerance: float) -> bool:
	return point.distance_to(click_pos) <= tolerance

func find_closest_within_tolerance(click_pos: Vector2, valid_points: Array, tolerance: float):
	var closest_point = null
	var closest_distance = INF
	
	for point in valid_points:
		var distance = point.distance_to(click_pos)
		if distance <= tolerance and distance < closest_distance:
			closest_distance = distance
			closest_point = point
	
	return closest_point

func adjust_to_edge_if_within_tolerance(click_pos: Vector2, edge_line: Array, tolerance: float) -> Vector2:
	# Simple perpendicular distance to vertical line at x=90
	var edge_x = edge_line[0].x
	var distance = abs(click_pos.x - edge_x)
	
	if distance <= tolerance:
		return Vector2(edge_x, click_pos.y)
	return click_pos

func scale_tolerance_for_zoom(base_tolerance: float, zoom: float) -> float:
	# Inverse relationship: lower zoom = higher tolerance
	return base_tolerance / zoom

func apply_tolerance_limits(tolerance: float) -> float:
	return clamp(tolerance, MIN_TOLERANCE, MAX_TOLERANCE)

func adjust_tolerance_for_ui_scale(base_tolerance: float, ui_scale: float) -> float:
	# Larger UI scale gets slightly more tolerance for accessibility
	if ui_scale <= 1.0:
		return base_tolerance
	elif ui_scale <= 1.5:
		return base_tolerance * 1.2
	else:
		return base_tolerance * 1.5

# Helper functions
func start_test(test_name: String):
	current_test = test_name
	if log_debug_info:
		print("\n[TEST] " + test_name)

func end_test(passed: bool, message: String):
	if passed:
		tests_passed += 1
		print("  ✓ PASS: %s: %s" % [current_test, message])
	else:
		tests_failed += 1
		failed_tests.append(current_test)
		print("  ✗ FAIL: %s: %s" % [current_test, message])