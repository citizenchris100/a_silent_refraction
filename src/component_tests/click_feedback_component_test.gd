extends Node2D
# Component Test: Tests interaction between click detection and visual feedback systems
#
# Components Under Test:
# - ClickFeedbackSystem: Displays visual indicators for clicks
# - InputManager: Triggers feedback on click events
# - CoordinateManager: Provides coordinate validation for feedback placement
#
# Interaction Contract:
# - InputManager validates clicks and notifies feedback system
# - Feedback system creates visual markers at click positions
# - Markers show different states (valid/invalid/adjusted)
# - Feedback clears after appropriate duration

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_feedback_creation = true
var test_feedback_states = true
var test_feedback_timing = true
var test_feedback_cleanup = true

# Test state
var test_name = "ClickFeedbackComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# ===== COMPONENTS =====
var MockClickFeedbackSystem = preload("res://src/component_tests/mocks/mock_click_feedback_system.gd")
var feedback_system = null
var captured_feedback_events = []

# Visual feedback constants
const FEEDBACK_DURATION = 0.5  # How long feedback stays visible
const VALID_COLOR = Color(0, 1, 0, 0.6)  # Green with transparency
const INVALID_COLOR = Color(1, 0, 0, 0.6)  # Red with transparency
const ADJUSTED_COLOR = Color(1, 1, 0, 0.6)  # Yellow with transparency

func _ready():
	print("\n==================================================")
	print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	# Set up components once
	setup_test_components()
	
	# Wait for setup
	yield(get_tree(), "idle_frame")
	
	# Run test suites
	yield(run_tests(), "completed")
	
	# Cleanup
	cleanup_test_components()
	
	# Report and exit
	report_results()
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	if run_all_tests or test_feedback_creation:
		yield(run_test_suite("Feedback Creation on Click", funcref(self, "test_suite_feedback_creation")), "completed")
	
	if run_all_tests or test_feedback_states:
		yield(run_test_suite("Feedback Visual States", funcref(self, "test_suite_feedback_states")), "completed")
	
	if run_all_tests or test_feedback_timing:
		yield(run_test_suite("Feedback Timing and Duration", funcref(self, "test_suite_feedback_timing")), "completed")
		
	if run_all_tests or test_feedback_cleanup:
		yield(run_test_suite("Feedback Cleanup and Performance", funcref(self, "test_suite_feedback_cleanup")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(test_func.call_func(), "completed")

func setup_test_components():
	# Create feedback system
	feedback_system = MockClickFeedbackSystem.new()
	feedback_system.name = "ClickFeedbackSystem"
	add_child(feedback_system)
	
	# Connect to capture events
	feedback_system.connect("feedback_created", self, "_on_feedback_created")
	feedback_system.connect("feedback_removed", self, "_on_feedback_removed")
	
	# Clear captured events
	captured_feedback_events.clear()
	
	# Wait for initialization
	yield(get_tree(), "idle_frame")

func cleanup_test_components():
	if feedback_system:
		feedback_system.queue_free()
		feedback_system = null

# ===== FEEDBACK CREATION TESTS =====
func test_suite_feedback_creation():
	start_test("test_creates_feedback_on_valid_click")
	
	# Simulate a valid click
	var click_pos = Vector2(400, 300)
	feedback_system.show_click_feedback(click_pos, feedback_system.FeedbackType.VALID)
	
	# Check that feedback was created
	yield(get_tree(), "idle_frame")
	var feedbacks = feedback_system.get_active_feedbacks()
	
	end_test(feedbacks.size() == 1 and feedbacks[0].position == click_pos,
		"Should create feedback marker at click position")
	
	start_test("test_creates_feedback_on_invalid_click")
	
	# Clear previous feedback
	feedback_system.clear_all_feedback()
	
	# Simulate an invalid click
	var invalid_pos = Vector2(100, 100)
	feedback_system.show_click_feedback(invalid_pos, feedback_system.FeedbackType.INVALID)
	
	yield(get_tree(), "idle_frame")
	var invalid_feedbacks = feedback_system.get_active_feedbacks()
	
	end_test(invalid_feedbacks.size() == 1 and invalid_feedbacks[0].type == feedback_system.FeedbackType.INVALID,
		"Should create invalid feedback marker for invalid clicks")
	
	start_test("test_handles_multiple_rapid_clicks")
	
	# Clear previous feedback
	feedback_system.clear_all_feedback()
	
	# Simulate rapid clicks
	var click_positions = [
		Vector2(100, 100),
		Vector2(200, 200),
		Vector2(300, 300),
	]
	
	for pos in click_positions:
		feedback_system.show_click_feedback(pos, feedback_system.FeedbackType.VALID)
	
	yield(get_tree(), "idle_frame")
	var multiple_feedbacks = feedback_system.get_active_feedbacks()
	
	end_test(multiple_feedbacks.size() == 3,
		"Should handle multiple rapid clicks without issues")

# ===== FEEDBACK VISUAL STATES TESTS =====
func test_suite_feedback_states():
	start_test("test_valid_click_shows_green_feedback")
	
	feedback_system.clear_all_feedback()
	
	var click_pos = Vector2(400, 300)
	feedback_system.show_click_feedback(click_pos, feedback_system.FeedbackType.VALID)
	
	yield(get_tree(), "idle_frame")
	var valid_feedbacks = feedback_system.get_active_feedbacks()
	
	end_test(valid_feedbacks.size() > 0 and valid_feedbacks[0].color.is_equal_approx(VALID_COLOR),
		"Valid clicks should show green feedback")
	
	start_test("test_invalid_click_shows_red_feedback")
	
	feedback_system.clear_all_feedback()
	
	feedback_system.show_click_feedback(Vector2(100, 100), feedback_system.FeedbackType.INVALID)
	
	yield(get_tree(), "idle_frame")
	var invalid_state_feedbacks = feedback_system.get_active_feedbacks()
	
	end_test(invalid_state_feedbacks.size() > 0 and invalid_state_feedbacks[0].color.is_equal_approx(INVALID_COLOR),
		"Invalid clicks should show red feedback")
	
	start_test("test_adjusted_click_shows_yellow_feedback")
	
	feedback_system.clear_all_feedback()
	
	# Show adjusted feedback (click was modified)
	var original_click = Vector2(100, 100)
	var adjusted_pos = Vector2(120, 100)
	feedback_system.show_adjusted_click_feedback(original_click, adjusted_pos)
	
	yield(get_tree(), "idle_frame")
	var adjusted_feedbacks = feedback_system.get_active_feedbacks()
	
	# Should have two markers: original (yellow) and adjusted (green)
	end_test(adjusted_feedbacks.size() == 2,
		"Adjusted clicks should show both original and final positions")
	
	start_test("test_feedback_includes_adjustment_line")
	
	# Check if adjustment line exists
	var has_line = feedback_system.has_adjustment_line(original_click, adjusted_pos)
	
	end_test(has_line,
		"Adjusted clicks should show a line from original to adjusted position")

# ===== FEEDBACK TIMING TESTS =====
func test_suite_feedback_timing():
	start_test("test_feedback_fades_after_duration")
	
	feedback_system.clear_all_feedback()
	
	# Create feedback
	feedback_system.show_click_feedback(Vector2(200, 200), feedback_system.FeedbackType.VALID)
	
	# Check it exists
	yield(get_tree(), "idle_frame")
	var initial_count = feedback_system.get_active_feedbacks().size()
	
	# Wait for fade duration
	yield(get_tree().create_timer(FEEDBACK_DURATION + 0.1), "timeout")
	
	# Check it's gone
	var final_count = feedback_system.get_active_feedbacks().size()
	
	end_test(initial_count == 1 and final_count == 0,
		"Feedback should automatically fade after duration")
	
	start_test("test_feedback_fade_animation")
	
	feedback_system.clear_all_feedback()
	
	# Create feedback and track opacity
	feedback_system.show_click_feedback(Vector2(300, 300), feedback_system.FeedbackType.VALID)
	
	yield(get_tree(), "idle_frame")
	var feedbacks = feedback_system.get_active_feedbacks()
	var initial_alpha = feedbacks[0].color.a if feedbacks.size() > 0 else 0
	
	# Check opacity during fade (halfway through)
	yield(get_tree().create_timer(FEEDBACK_DURATION * 0.5), "timeout")
	
	feedbacks = feedback_system.get_active_feedbacks()
	var mid_alpha = feedbacks[0].color.a if feedbacks.size() > 0 else 0
	
	end_test(mid_alpha < initial_alpha,
		"Feedback should fade gradually over time")

# ===== FEEDBACK CLEANUP TESTS =====
func test_suite_feedback_cleanup():
	start_test("test_clear_all_feedback")
	
	# Create multiple feedbacks
	for i in range(5):
		feedback_system.show_click_feedback(Vector2(i * 100, i * 100), 
			feedback_system.FeedbackType.VALID)
	
	yield(get_tree(), "idle_frame")
	
	# Clear all
	feedback_system.clear_all_feedback()
	yield(get_tree(), "idle_frame")
	
	var remaining = feedback_system.get_active_feedbacks().size()
	
	end_test(remaining == 0,
		"Clear all should remove all active feedback")
	
	start_test("test_feedback_performance_with_many_clicks")
	
	feedback_system.clear_all_feedback()
	
	# Create many feedbacks quickly
	var start_time = OS.get_ticks_msec()
	for i in range(20):
		feedback_system.show_click_feedback(Vector2(randf() * 1000, randf() * 1000), 
			feedback_system.FeedbackType.VALID)
	
	var creation_time = OS.get_ticks_msec() - start_time
	
	# Should handle 20 feedbacks in under 50ms
	end_test(creation_time < 50,
		"Should handle many feedbacks efficiently (took %dms)" % creation_time)
	
	start_test("test_old_feedback_cleanup")
	
	# Verify system cleans up old feedback nodes
	var initial_child_count = feedback_system.get_child_count()
	
	# Wait for all feedbacks to expire
	yield(get_tree().create_timer(FEEDBACK_DURATION + 0.5), "timeout")
	
	var final_child_count = feedback_system.get_child_count()
	
	end_test(final_child_count <= initial_child_count,
		"System should clean up expired feedback nodes")

# Event capture helpers
func _on_feedback_created(feedback_data):
	captured_feedback_events.append({
		"type": "created",
		"data": feedback_data
	})

func _on_feedback_removed(feedback_data):
	captured_feedback_events.append({
		"type": "removed",
		"data": feedback_data
	})

# Test helpers
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

func report_results():
	print("\n==================================================")
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("==================================================\n")
	
	if tests_failed == 0:
		print("[PASS] All %s tests passed!" % test_name)
	else:
		print("[FAIL] Some tests failed!")
		for failed in failed_tests:
			print("  - " + failed)