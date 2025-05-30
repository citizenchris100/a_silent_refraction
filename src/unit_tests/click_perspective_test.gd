extends Node2D
# Click Perspective Test: Unit tests for perspective and zoom-aware click handling

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_zoom_adjustment = true
var test_perspective_types = true
var test_screen_edges = true
var test_combined_effects = true

# Test state
var test_name = "ClickPerspectiveTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test constants
const PERSPECTIVE_SCALE_BASE = 1.0
const ISOMETRIC_Y_FACTOR = 0.5  # Y-axis is compressed in isometric view
const SIDE_SCROLL_Y_FACTOR = 1.0  # Normal Y-axis in side-scrolling
const TOP_DOWN_FACTOR = 1.0  # Both axes normal in top-down

# Perspective types
enum PerspectiveType {
	ISOMETRIC,
	SIDE_SCROLLING,
	TOP_DOWN
}

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
	if run_all_tests or test_zoom_adjustment:
		run_test_suite("Zoom-based Click Adjustment", funcref(self, "test_suite_zoom_adjustment"))
	
	if run_all_tests or test_perspective_types:
		run_test_suite("Perspective Type Click Handling", funcref(self, "test_suite_perspective_types"))
	
	if run_all_tests or test_screen_edges:
		run_test_suite("Screen Edge Click Behavior", funcref(self, "test_suite_screen_edges"))
		
	if run_all_tests or test_combined_effects:
		run_test_suite("Combined Zoom and Perspective Effects", funcref(self, "test_suite_combined_effects"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

# ===== ZOOM ADJUSTMENT TESTS =====
func test_suite_zoom_adjustment():
	start_test("test_click_position_adjusts_for_zoom")
	
	# When zoomed, click positions need adjustment
	var screen_click = Vector2(400, 300)
	var camera_pos = Vector2(800, 600)
	var zoom_levels = [
		{"zoom": 0.5, "desc": "zoomed out"},
		{"zoom": 1.0, "desc": "normal"},
		{"zoom": 2.0, "desc": "zoomed in"},
	]
	
	var all_pass = true
	for test in zoom_levels:
		var adjusted = adjust_click_for_zoom(screen_click, camera_pos, test.zoom)
		# Verify the adjustment maintains the relative offset scaled by zoom
		var expected_offset = (screen_click - get_viewport_center()) * test.zoom
		var expected = camera_pos + expected_offset
		if not adjusted.is_equal_approx(expected):
			all_pass = false
			if log_debug_info:
				print("  Failed for zoom %s: got %s, expected %s" % 
					[test.zoom, adjusted, expected])
	
	end_test(all_pass, "Click positions should adjust correctly for zoom level")
	
	start_test("test_click_area_scales_with_zoom")
	
	# The effective click area should scale with zoom
	var base_click_radius = 10.0
	var zoom_tests = [
		{"zoom": 0.5, "expected_radius": 20.0},  # Zoomed out = larger click area
		{"zoom": 1.0, "expected_radius": 10.0},  # Normal
		{"zoom": 2.0, "expected_radius": 5.0},   # Zoomed in = smaller click area
	]
	
	all_pass = true
	for test in zoom_tests:
		var scaled_radius = scale_click_radius_for_zoom(base_click_radius, test.zoom)
		if not is_equal_approx(scaled_radius, test.expected_radius):
			all_pass = false
			if log_debug_info:
				print("  Failed for zoom %s: got radius %s, expected %s" % 
					[test.zoom, scaled_radius, test.expected_radius])
	
	end_test(all_pass, "Click detection radius should scale inversely with zoom")

# ===== PERSPECTIVE TYPE TESTS =====
func test_suite_perspective_types():
	start_test("test_isometric_click_adjustment")
	
	# In isometric view, Y-axis clicks need adjustment
	var click_pos = Vector2(400, 300)
	var adjusted = adjust_click_for_perspective(click_pos, PerspectiveType.ISOMETRIC)
	
	# Y component should be expanded to account for compression
	var expected_y = click_pos.y / ISOMETRIC_Y_FACTOR
	var expected = Vector2(click_pos.x, expected_y)
	
	end_test(adjusted.is_equal_approx(expected), 
		"Isometric perspective should adjust Y-axis clicks correctly")
	
	start_test("test_side_scrolling_click_adjustment")
	
	# Side-scrolling typically has normal click mapping
	adjusted = adjust_click_for_perspective(click_pos, PerspectiveType.SIDE_SCROLLING)
	
	end_test(adjusted == click_pos, 
		"Side-scrolling perspective should not modify click positions")
	
	start_test("test_top_down_click_adjustment")
	
	# Top-down also has normal click mapping
	adjusted = adjust_click_for_perspective(click_pos, PerspectiveType.TOP_DOWN)
	
	end_test(adjusted == click_pos, 
		"Top-down perspective should not modify click positions")
	
	start_test("test_perspective_affects_click_tolerance")
	
	# Different perspectives might need different tolerances
	var base_tolerance = 10.0
	var tolerance_tests = [
		{"perspective": PerspectiveType.ISOMETRIC, "multiplier": 1.2},  # Harder to click precisely
		{"perspective": PerspectiveType.SIDE_SCROLLING, "multiplier": 1.0},
		{"perspective": PerspectiveType.TOP_DOWN, "multiplier": 0.8},  # Easier to click precisely
	]
	
	var tolerances_correct = true
	for test in tolerance_tests:
		var adjusted_tolerance = adjust_tolerance_for_perspective(
			base_tolerance, test.perspective)
		var expected_tolerance = base_tolerance * test.multiplier
		if not is_equal_approx(adjusted_tolerance, expected_tolerance):
			tolerances_correct = false
			if log_debug_info:
				print("  Failed for perspective %s: expected multiplier %s" % 
					[test.perspective, test.multiplier])
	
	end_test(tolerances_correct, 
		"Click tolerance should adjust based on perspective type")

# ===== SCREEN EDGE TESTS =====
func test_suite_screen_edges():
	start_test("test_edge_click_detection_with_zoom")
	
	# Clicks near screen edges need special handling with zoom
	var viewport_size = Vector2(1920, 1080)
	var edge_margin = 50.0
	var zoom = 0.75
	
	var edge_clicks = [
		Vector2(edge_margin, 540),  # Left edge
		Vector2(1920 - edge_margin, 540),  # Right edge
		Vector2(960, edge_margin),  # Top edge
		Vector2(960, 1080 - edge_margin),  # Bottom edge
	]
	
	var all_handled = true
	for click in edge_clicks:
		# When zoomed out, effective margin should be larger (harder to reach edge)
		var effective_margin = edge_margin / zoom
		var is_edge = is_click_near_edge(click, viewport_size, effective_margin)
		if not is_edge:
			all_handled = false
			if log_debug_info:
				print("  Failed to detect edge click at %s with zoom %s" % 
					[click, zoom])
	
	end_test(all_handled, "Edge clicks should be detected with zoom consideration")
	
	start_test("test_edge_click_adjustment")
	
	# Clicks very close to edges might need adjustment
	var click_at_edge = Vector2(5, 540)  # Very close to left edge
	var adjusted = adjust_edge_click(click_at_edge, viewport_size, 10.0)
	
	# Should be pushed inward from edge
	end_test(adjusted.x >= 10.0, 
		"Clicks too close to edge should be adjusted inward")

# ===== COMBINED EFFECTS TESTS =====
func test_suite_combined_effects():
	start_test("test_combined_zoom_and_perspective")
	
	# Both zoom and perspective affect click handling
	var screen_click = Vector2(800, 600)
	var camera_pos = Vector2(1000, 1000)
	var test_cases = [
		{
			"zoom": 0.5,
			"perspective": PerspectiveType.ISOMETRIC,
			"desc": "zoomed out isometric"
		},
		{
			"zoom": 2.0,
			"perspective": PerspectiveType.ISOMETRIC,
			"desc": "zoomed in isometric"
		},
		{
			"zoom": 1.5,
			"perspective": PerspectiveType.TOP_DOWN,
			"desc": "zoomed in top-down"
		},
	]
	
	var combined_correct = true
	for test in test_cases:
		var adjusted = adjust_click_for_perspective_and_zoom(
			screen_click, camera_pos, test.zoom, test.perspective)
		
		# First apply zoom adjustment
		var zoom_adjusted = adjust_click_for_zoom(screen_click, camera_pos, test.zoom)
		# Then apply perspective adjustment
		var expected_combined = adjust_click_for_perspective(zoom_adjusted, test.perspective)
		
		if not adjusted.is_equal_approx(expected_combined):
			combined_correct = false
			if log_debug_info:
				print("  Failed for %s: got %s, expected %s" % 
					[test.desc, adjusted, expected_combined])
	
	end_test(combined_correct, 
		"Combined zoom and perspective adjustments should apply correctly")
	
	start_test("test_effective_click_area_with_all_factors")
	
	# Test how all factors combine to affect click detection area
	var base_tolerance = 10.0
	var zoom = 0.75
	var perspective = PerspectiveType.ISOMETRIC
	var ui_scale = 1.25
	
	# Calculate combined effect
	var effective_tolerance = calculate_effective_tolerance(
		base_tolerance, zoom, perspective, ui_scale)
	
	# Expected calculation:
	# 1. Zoom adjustment: 10.0 / 0.75 = 13.33
	# 2. Perspective multiplier: 13.33 * 1.2 = 16.0
	# 3. UI scale adjustment: 16.0 * 1.2 = 19.2 (ui_scale > 1.0)
	var expected_combined_tolerance = 19.2
	
	end_test(is_equal_approx(effective_tolerance, expected_combined_tolerance), 
		"All factors should combine correctly for effective click tolerance")

# ===== HELPER FUNCTIONS (These define the expected behavior) =====

func get_viewport_center() -> Vector2:
	return Vector2(960, 540)  # Assuming 1920x1080

func adjust_click_for_zoom(screen_pos: Vector2, camera_pos: Vector2, zoom: float) -> Vector2:
	var offset_from_center = screen_pos - get_viewport_center()
	return camera_pos + (offset_from_center * zoom)

func scale_click_radius_for_zoom(base_radius: float, zoom: float) -> float:
	return base_radius / zoom

func adjust_click_for_perspective(click_pos: Vector2, perspective: int) -> Vector2:
	match perspective:
		PerspectiveType.ISOMETRIC:
			# Expand Y to compensate for isometric compression
			return Vector2(click_pos.x, click_pos.y / ISOMETRIC_Y_FACTOR)
		PerspectiveType.SIDE_SCROLLING, PerspectiveType.TOP_DOWN:
			return click_pos
		_:
			return click_pos

func adjust_tolerance_for_perspective(base_tolerance: float, perspective: int) -> float:
	match perspective:
		PerspectiveType.ISOMETRIC:
			return base_tolerance * 1.2  # Harder to click precisely
		PerspectiveType.TOP_DOWN:
			return base_tolerance * 0.8  # Easier to click precisely
		_:
			return base_tolerance

func is_click_near_edge(click_pos: Vector2, viewport_size: Vector2, margin: float) -> bool:
	return (click_pos.x <= margin or 
			click_pos.x >= viewport_size.x - margin or
			click_pos.y <= margin or
			click_pos.y >= viewport_size.y - margin)

func adjust_edge_click(click_pos: Vector2, viewport_size: Vector2, min_margin: float) -> Vector2:
	var adjusted = click_pos
	adjusted.x = max(min_margin, min(click_pos.x, viewport_size.x - min_margin))
	adjusted.y = max(min_margin, min(click_pos.y, viewport_size.y - min_margin))
	return adjusted

func adjust_click_for_perspective_and_zoom(screen_pos: Vector2, camera_pos: Vector2, 
		zoom: float, perspective: int) -> Vector2:
	var zoom_adjusted = adjust_click_for_zoom(screen_pos, camera_pos, zoom)
	return adjust_click_for_perspective(zoom_adjusted, perspective)

func calculate_effective_tolerance(base: float, zoom: float, perspective: int, ui_scale: float) -> float:
	# Apply zoom scaling (from click_tolerance_test.gd)
	var zoom_adjusted = base / zoom
	
	# Apply perspective adjustment
	var perspective_adjusted = adjust_tolerance_for_perspective(zoom_adjusted, perspective)
	
	# Apply UI scale adjustment (from click_tolerance_test.gd logic)
	var ui_multiplier = 1.0
	if ui_scale > 1.0 and ui_scale <= 1.5:
		ui_multiplier = 1.2
	elif ui_scale > 1.5:
		ui_multiplier = 1.5
		
	return perspective_adjusted * ui_multiplier

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