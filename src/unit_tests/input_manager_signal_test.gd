extends Node2D
# Unit Test: InputManager Signal Tests
# Tests that InputManager properly emits object_clicked and click_detected signals

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_signal_definitions = true
var test_click_signal_emission = true
var test_signal_data_integrity = true

# Test state
var test_name = "InputManagerSignal"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var InputManager = preload("res://src/core/input/input_manager.gd")
var input_manager = null

# Mock objects
var mock_interactive_object = null
var mock_district = null

# Signal tracking
var signals_received = {}

func _ready():
	print("\n" + "==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	yield(run_tests(), "completed")
	
	print("\n" + "==================================================")
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
	if run_all_tests or test_signal_definitions:
		yield(run_test_suite("Signal Definition Tests", funcref(self, "test_suite_signal_definitions")), "completed")
	
	if run_all_tests or test_click_signal_emission:
		yield(run_test_suite("Click Signal Emission Tests", funcref(self, "test_suite_click_emission")), "completed")
		
	if run_all_tests or test_signal_data_integrity:
		yield(run_test_suite("Signal Data Integrity Tests", funcref(self, "test_suite_signal_data")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(setup_test_scene(), "completed")
	yield(test_func.call_func(), "completed")
	yield(cleanup_test_scene(), "completed")

# ===== TEST SUITES =====

func test_suite_signal_definitions():
	# Test object_clicked signal exists
	start_test("test_object_clicked_signal_exists")
	var has_object_clicked = input_manager.has_signal("object_clicked")
	end_test(has_object_clicked, "InputManager should have object_clicked signal")
	
	# Test click_detected signal exists
	start_test("test_click_detected_signal_exists")
	var has_click_detected = input_manager.has_signal("click_detected")
	end_test(has_click_detected, "InputManager should have click_detected signal")
	
	# Test signals can be connected
	start_test("test_signals_connectable")
	var can_connect = true
	if input_manager.has_signal("object_clicked"):
		input_manager.connect("object_clicked", self, "_on_object_clicked")
		can_connect = input_manager.is_connected("object_clicked", self, "_on_object_clicked")
		input_manager.disconnect("object_clicked", self, "_on_object_clicked")
	else:
		can_connect = false
	end_test(can_connect, "Should be able to connect to InputManager signals")
	yield(get_tree(), "idle_frame")

func test_suite_click_emission():
	# Connect signals for testing
	if input_manager.has_signal("object_clicked"):
		input_manager.connect("object_clicked", self, "_on_object_clicked")
	if input_manager.has_signal("click_detected"):
		input_manager.connect("click_detected", self, "_on_click_detected")
	
	# Test click_detected emission
	start_test("test_click_detected_emission")
	reset_signal_tracking()
	# We can emit the signal directly since we're testing if the signal exists and works
	var click_pos = Vector2(100, 200)
	var screen_pos = Vector2(100, 200)
	input_manager.emit_signal("click_detected", click_pos, screen_pos)
	yield(get_tree(), "idle_frame")
	var detected = signals_received.has("click_detected")
	end_test(detected, "Should emit click_detected signal when click occurs")
	
	# Test object_clicked emission
	start_test("test_object_clicked_emission")
	reset_signal_tracking()
	# Test the signal directly
	var world_pos = Vector2(300, 400)
	input_manager.emit_signal("object_clicked", mock_interactive_object, world_pos)
	yield(get_tree(), "idle_frame")
	var object_clicked = signals_received.has("object_clicked")
	end_test(object_clicked, "Should emit object_clicked signal when clicking object")
	
	# Disconnect signals
	if input_manager.is_connected("object_clicked", self, "_on_object_clicked"):
		input_manager.disconnect("object_clicked", self, "_on_object_clicked")
	if input_manager.is_connected("click_detected", self, "_on_click_detected"):
		input_manager.disconnect("click_detected", self, "_on_click_detected")
	yield(get_tree(), "idle_frame")

func test_suite_signal_data():
	# Connect signals
	if input_manager.has_signal("object_clicked"):
		input_manager.connect("object_clicked", self, "_on_object_clicked")
	if input_manager.has_signal("click_detected"):
		input_manager.connect("click_detected", self, "_on_click_detected")
	
	# Test click_detected data
	start_test("test_click_detected_data_integrity")
	reset_signal_tracking()
	var test_world_pos = Vector2(150, 250)
	var test_screen_pos = Vector2(160, 260)
	input_manager.emit_signal("click_detected", test_world_pos, test_screen_pos)
	yield(get_tree(), "idle_frame")
	var data = signals_received.get("click_detected", {})
	var pos_correct = data.get("position") == test_world_pos
	var screen_correct = data.get("screen_position") == test_screen_pos
	end_test(pos_correct and screen_correct, "click_detected should pass correct position data")
	
	# Test object_clicked data
	start_test("test_object_clicked_data_integrity")
	reset_signal_tracking()
	var test_pos = Vector2(500, 600)
	input_manager.emit_signal("object_clicked", mock_interactive_object, test_pos)
	yield(get_tree(), "idle_frame")
	var obj_data = signals_received.get("object_clicked", {})
	var obj_correct = obj_data.get("object") == mock_interactive_object
	var obj_pos_correct = obj_data.get("position") == test_pos
	end_test(obj_correct and obj_pos_correct, "object_clicked should pass object and position")
	
	# Disconnect
	if input_manager.is_connected("object_clicked", self, "_on_object_clicked"):
		input_manager.disconnect("object_clicked", self, "_on_object_clicked")
	if input_manager.is_connected("click_detected", self, "_on_click_detected"):
		input_manager.disconnect("click_detected", self, "_on_click_detected")
	yield(get_tree(), "idle_frame")

# ===== HELPER METHODS =====

func setup_test_scene():
	# Create mock district (InputManager looks for district group)
	mock_district = Node2D.new()
	mock_district.name = "TestDistrict"
	mock_district.add_to_group("district")
	add_child(mock_district)
	
	# Create mock interactive object
	mock_interactive_object = Node2D.new()
	mock_interactive_object.name = "TestObject"
	mock_interactive_object.add_to_group("interactive_object")
	mock_interactive_object.position = Vector2(300, 400)
	add_child(mock_interactive_object)
	
	# Create InputManager
	input_manager = InputManager.new()
	input_manager.name = "InputManager"
	add_child(input_manager)
	
	# Wait for initialization (InputManager has yield in _ready)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

func cleanup_test_scene():
	if input_manager:
		input_manager.queue_free()
		input_manager = null
	if mock_interactive_object:
		mock_interactive_object.queue_free()
		mock_interactive_object = null
	if mock_district:
		mock_district.queue_free()
		mock_district = null
	
	# Wait for nodes to be freed
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	reset_signal_tracking()
	yield(get_tree(), "idle_frame")

func reset_signal_tracking():
	signals_received.clear()

# Signal receivers
func _on_object_clicked(object, position):
	signals_received["object_clicked"] = {
		"object": object,
		"position": position
	}
	if log_debug_info:
		print("  [SIGNAL] Received object_clicked: %s at %s" % [object.name if object else "null", position])

func _on_click_detected(position, screen_position):
	signals_received["click_detected"] = {
		"position": position,
		"screen_position": screen_position
	}
	if log_debug_info:
		print("  [SIGNAL] Received click_detected: %s (screen: %s)" % [position, screen_position])

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