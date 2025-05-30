extends Node2D
# Click Detection Test: Unit tests for InputManager click detection logic

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_position_validation = true
var test_ui_detection = true
var test_dialog_state = true
var test_click_blocking = true

# Test state
var test_name = "ClickDetectionTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var MockInputManager = preload("res://src/unit_tests/mocks/mock_input_manager.gd")
var mock_input_manager = null
var mock_dialog_manager = null
var mock_ui_layer = null

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
	if run_all_tests or test_position_validation:
		run_test_suite("Click Position Validation", funcref(self, "test_suite_position_validation"))
	
	if run_all_tests or test_ui_detection:
		run_test_suite("UI Element Detection", funcref(self, "test_suite_ui_detection"))
	
	if run_all_tests or test_dialog_state:
		run_test_suite("Dialog State Checking", funcref(self, "test_suite_dialog_state"))
	
	if run_all_tests or test_click_blocking:
		run_test_suite("Click Blocking Mechanism", funcref(self, "test_suite_click_blocking"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	setup_test_scene()
	test_func.call_func()
	cleanup_test_scene()

func setup_test_scene():
	# Create mock input manager with testable methods
	mock_input_manager = MockInputManager.new()
	mock_input_manager.name = "MockInputManager"
	add_child(mock_input_manager)
	
	# Create mock dialog manager
	mock_dialog_manager = Node.new()
	mock_dialog_manager.name = "MockDialogManager"
	add_child(mock_dialog_manager)
	
	# Add dialog panel after adding to tree
	var dialog_panel = Control.new()
	dialog_panel.name = "dialog_panel"
	dialog_panel.visible = false
	mock_dialog_manager.add_child(dialog_panel)
	
	# Create mock UI layer
	mock_ui_layer = CanvasLayer.new()
	mock_ui_layer.name = "UI"
	add_child(mock_ui_layer)
	
	# Let scene initialize
	yield(get_tree(), "idle_frame")

func cleanup_test_scene():
	if mock_input_manager:
		mock_input_manager.queue_free()
		mock_input_manager = null
	if mock_dialog_manager:
		mock_dialog_manager.queue_free()
		mock_dialog_manager = null
	if mock_ui_layer:
		mock_ui_layer.queue_free()
		mock_ui_layer = null

# ===== POSITION VALIDATION TESTS =====
func test_suite_position_validation():
	# Test 1: Valid screen bounds
	test_valid_screen_bounds()
	
	# Test 2: Invalid screen bounds
	test_invalid_screen_bounds()
	
	# Test 3: Edge cases
	test_edge_cases()

func test_valid_screen_bounds():
	start_test("test_click_validates_screen_bounds")
	
	# Test clicking within screen bounds
	var valid_click = InputEventMouseButton.new()
	valid_click.button_index = BUTTON_LEFT
	valid_click.pressed = true
	valid_click.position = Vector2(400, 300)  # Within typical screen
	
	var result = mock_input_manager.validate_click_position(valid_click.position)
	end_test(result == true, "Valid screen position should be accepted")

func test_invalid_screen_bounds():
	start_test("test_click_rejects_outside_screen")
	
	var invalid_positions = [
		Vector2(-10, 300),     # Negative X
		Vector2(400, -10),     # Negative Y
		Vector2(2000, 300),    # Beyond typical screen width
		Vector2(400, 1500),    # Beyond typical screen height
		Vector2(-100, -100),   # Both negative
	]
	
	var all_rejected = true
	for pos in invalid_positions:
		var click = InputEventMouseButton.new()
		click.button_index = BUTTON_LEFT
		click.pressed = true
		click.position = pos
		
		if mock_input_manager.validate_click_position(click.position):
			all_rejected = false
			if log_debug_info:
				print("  Failed to reject position: %s" % str(pos))
	
	end_test(all_rejected, "Invalid screen positions should be rejected")

func test_edge_cases():
	start_test("test_click_handles_edge_cases")
	
	var edge_cases = [
		Vector2(0, 0),              # Exact corner
		Vector2(1920, 1080),        # Opposite corner (typical screen)
		Vector2.INF,               # Infinity
		Vector2(NAN, NAN),          # Not a number
	]
	
	var handled_correctly = true
	for pos in edge_cases:
		var click = InputEventMouseButton.new()
		click.button_index = BUTTON_LEFT
		click.pressed = true
		click.position = pos
		
		# Should handle without crashing and return false for invalid
		var edge_result = mock_input_manager.validate_click_position(click.position)
		if is_inf(pos.x) or is_inf(pos.y) or is_nan(pos.x) or is_nan(pos.y):
			if edge_result != false:
				handled_correctly = false
				if log_debug_info:
					print("  Failed to handle edge case: %s" % str(pos))
	
	end_test(handled_correctly, "Edge cases should be handled gracefully")

# ===== UI ELEMENT DETECTION TESTS =====
func test_suite_ui_detection():
	start_test("test_detects_click_on_ui_element")
	
	# Create a test UI control
	var test_button = Button.new()
	test_button.rect_position = Vector2(100, 100)
	test_button.rect_size = Vector2(200, 50)
	test_button.visible = true
	mock_ui_layer.add_child(test_button)
	
	# Test clicking on the UI element
	var ui_click = Vector2(200, 125)  # Center of button
	var ui_result = mock_input_manager.is_click_on_ui(ui_click, mock_ui_layer)
	
	test_button.queue_free()
	end_test(ui_result == true, "Click on UI element should be detected")
	
	start_test("test_ignores_invisible_ui_elements")
	
	# Create an invisible UI control
	var invisible_button = Button.new()
	invisible_button.rect_position = Vector2(300, 300)
	invisible_button.rect_size = Vector2(200, 50)
	invisible_button.visible = false
	mock_ui_layer.add_child(invisible_button)
	
	# Test clicking on the invisible element
	var click_pos = Vector2(400, 325)  # Center of invisible button
	var invisible_result = mock_input_manager.is_click_on_ui(click_pos, mock_ui_layer)
	
	invisible_button.queue_free()
	end_test(invisible_result == false, "Click on invisible UI element should be ignored")
	
	start_test("test_handles_nested_ui_elements")
	
	# Create nested UI structure
	var container = Control.new()
	container.rect_position = Vector2(500, 500)
	container.rect_size = Vector2(300, 200)
	container.visible = true
	mock_ui_layer.add_child(container)
	
	var nested_button = Button.new()
	nested_button.rect_position = Vector2(50, 50)  # Relative to container
	nested_button.rect_size = Vector2(100, 40)
	nested_button.visible = true
	container.add_child(nested_button)
	
	# Test clicking on nested element
	var nested_click = Vector2(600, 570)  # Should hit nested button
	var nested_result = mock_input_manager.is_click_on_ui(nested_click, mock_ui_layer)
	
	container.queue_free()
	end_test(nested_result == true, "Click on nested UI element should be detected")

# ===== DIALOG STATE TESTS =====
func test_suite_dialog_state():
	start_test("test_blocks_clicks_during_dialog")
	
	# Set dialog to visible
	if mock_dialog_manager.has_node("dialog_panel"):
		mock_dialog_manager.get_node("dialog_panel").visible = true
	
	# Test that clicks are blocked
	var dialog_result = mock_input_manager.should_block_click_for_dialog(mock_dialog_manager)
	end_test(dialog_result == true, "Clicks should be blocked when dialog is visible")
	
	start_test("test_allows_clicks_without_dialog")
	
	# Set dialog to invisible
	if mock_dialog_manager.has_node("dialog_panel"):
		mock_dialog_manager.get_node("dialog_panel").visible = false
	
	# Test that clicks are allowed
	var no_dialog_result = mock_input_manager.should_block_click_for_dialog(mock_dialog_manager)
	end_test(no_dialog_result == false, "Clicks should be allowed when dialog is not visible")
	
	start_test("test_handles_missing_dialog_manager")
	
	# Test with null dialog manager
	var null_result = mock_input_manager.should_block_click_for_dialog(null)
	end_test(null_result == false, "Should handle missing dialog manager gracefully")

# ===== CLICK BLOCKING TESTS =====
func test_suite_click_blocking():
	start_test("test_blocks_clicks_for_duration")
	
	# Block clicks for 100ms
	mock_input_manager.block_clicks(100)
	
	# Test immediate check
	var blocked = mock_input_manager.is_click_blocked()
	end_test(blocked == true, "Clicks should be blocked immediately after blocking")
	
	# For synchronous testing, test the blocking mechanism without actual delays
	start_test("test_blocking_mechanism")
	
	# Reset blocking
	mock_input_manager.block_clicks_until = 0
	
	# Test that unblocked state works
	var unblocked = mock_input_manager.is_click_blocked()
	end_test(unblocked == false, "Clicks should not be blocked when block_clicks_until is 0")
	
	start_test("test_blocking_time_calculation")
	
	# Test that blocking sets future time correctly
	var current_time = OS.get_ticks_msec()
	mock_input_manager.block_clicks(500)
	
	# The block_clicks_until should be approximately current_time + 500
	var time_diff = mock_input_manager.block_clicks_until - current_time
	var within_tolerance = time_diff >= 490 and time_diff <= 510  # Allow 10ms tolerance
	end_test(within_tolerance, "Block time should be set correctly (within 10ms tolerance)")

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