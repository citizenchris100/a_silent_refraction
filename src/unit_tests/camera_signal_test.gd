extends Node2D
# Unit Test: ScrollingCamera Signal Tests
# Tests that ScrollingCamera properly emits its various signals

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_signal_definitions = true
var test_movement_signals = true
var test_state_signals = true

# Test state
var test_name = "CameraSignal"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var ScrollingCamera = preload("res://src/core/camera/scrolling_camera.gd")
var camera = null

# Mock objects
var mock_background = null

# Signal tracking
var signals_received = {}

func _ready():
	print("\n" + "==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	yield(run_all_tests(), "completed")
	
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

func run_all_tests():
	if run_all_tests or test_signal_definitions:
		yield(run_test_suite("Signal Definition Tests", funcref(self, "test_suite_signal_definitions")), "completed")
	
	if run_all_tests or test_movement_signals:
		yield(run_test_suite("Movement Signal Tests", funcref(self, "test_suite_movement_signals")), "completed")
		
	if run_all_tests or test_state_signals:
		yield(run_test_suite("State Signal Tests", funcref(self, "test_suite_state_signals")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(setup_test_scene(), "completed")
	yield(test_func.call_func(), "completed")
	yield(cleanup_test_scene(), "completed")

# ===== TEST SUITES =====

func test_suite_signal_definitions():
	# Test camera_move_started signal exists
	start_test("test_camera_move_started_signal_exists")
	var has_move_started = camera.has_signal("camera_move_started")
	end_test(has_move_started, "ScrollingCamera should have camera_move_started signal")
	
	# Test camera_move_completed signal exists
	start_test("test_camera_move_completed_signal_exists")
	var has_move_completed = camera.has_signal("camera_move_completed")
	end_test(has_move_completed, "ScrollingCamera should have camera_move_completed signal")
	
	# Test camera_state_changed signal exists
	start_test("test_camera_state_changed_signal_exists")
	var has_state_changed = camera.has_signal("camera_state_changed")
	end_test(has_state_changed, "ScrollingCamera should have camera_state_changed signal")
	
	# Test signals can be connected
	start_test("test_signals_connectable")
	var can_connect = true
	if camera.has_signal("camera_move_started"):
		camera.connect("camera_move_started", self, "_on_camera_move_started")
		can_connect = camera.is_connected("camera_move_started", self, "_on_camera_move_started")
		camera.disconnect("camera_move_started", self, "_on_camera_move_started")
	else:
		can_connect = false
	end_test(can_connect, "Should be able to connect to camera signals")
	yield(get_tree(), "idle_frame")

func test_suite_movement_signals():
	# Connect movement signals
	if camera.has_signal("camera_move_started"):
		camera.connect("camera_move_started", self, "_on_camera_move_started")
	if camera.has_signal("camera_move_completed"):
		camera.connect("camera_move_completed", self, "_on_camera_move_completed")
	
	# Test camera_move_started emission
	start_test("test_camera_move_started_emission")
	reset_signal_tracking()
	# Move camera to starting position immediately
	camera.move_to_position(Vector2(0, 0), true)  # immediate = true
	yield(get_tree(), "idle_frame")
	# Trigger camera movement to a different position
	var target_pos = Vector2(800, 600)  # Use a position that should be valid
	camera.move_to_position(target_pos, false)  # animated movement
	yield(get_tree(), "idle_frame")
	var move_started = signals_received.has("camera_move_started")
	end_test(move_started, "Should emit camera_move_started when movement begins")
	
	# Wait for movement to complete (or timeout)
	var wait_time = 0.0
	var max_wait = 3.0
	while wait_time < max_wait and not signals_received.has("camera_move_completed"):
		yield(get_tree().create_timer(0.1), "timeout")
		wait_time += 0.1
	
	# Test camera_move_completed emission
	start_test("test_camera_move_completed_emission")
	var move_completed = signals_received.has("camera_move_completed")
	if not move_completed:
		print("  [DEBUG] Camera state: " + str(camera.get("current_camera_state")))
		print("  [DEBUG] Camera position: " + str(camera.global_position))
		print("  [DEBUG] Signals received: " + str(signals_received.keys()))
	end_test(move_completed, "Should emit camera_move_completed when movement ends")
	
	# Disconnect signals
	if camera.is_connected("camera_move_started", self, "_on_camera_move_started"):
		camera.disconnect("camera_move_started", self, "_on_camera_move_started")
	if camera.is_connected("camera_move_completed", self, "_on_camera_move_completed"):
		camera.disconnect("camera_move_completed", self, "_on_camera_move_completed")
	
	# Wait a bit more to ensure camera finishes any pending operations
	yield(get_tree().create_timer(0.5), "timeout")

func test_suite_state_signals():
	# Connect state signal
	if camera.has_signal("camera_state_changed"):
		camera.connect("camera_state_changed", self, "_on_camera_state_changed")
	
	# Test state change emission
	start_test("test_camera_state_changed_emission")
	reset_signal_tracking()
	# Trigger state change by moving camera
	camera.move_to_position(Vector2(100, 100))
	yield(get_tree(), "idle_frame")
	var state_changed = signals_received.has("camera_state_changed")
	end_test(state_changed, "Should emit camera_state_changed when state changes")
	
	# Test signal data
	start_test("test_camera_state_signal_data")
	var data = signals_received.get("camera_state_changed", {})
	var has_new_state = data.has("new_state")
	var has_old_state = data.has("old_state")
	var has_reason = data.has("reason")
	end_test(has_new_state and has_old_state and has_reason, 
		"State change signal should include new_state, old_state, and reason")
	
	# Disconnect
	if camera.is_connected("camera_state_changed", self, "_on_camera_state_changed"):
		camera.disconnect("camera_state_changed", self, "_on_camera_state_changed")
	
	# Wait for any pending operations
	yield(get_tree().create_timer(0.5), "timeout")

# ===== HELPER METHODS =====

func setup_test_scene():
	# Create mock background (camera needs this)
	mock_background = Sprite.new()
	mock_background.name = "Background"
	var img = Image.new()
	img.create(1920, 1080, false, Image.FORMAT_RGB8)
	img.fill(Color(0.2, 0.2, 0.2))
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	mock_background.texture = tex
	mock_background.centered = false
	add_child(mock_background)
	
	# Create camera
	camera = ScrollingCamera.new()
	camera.name = "ScrollingCamera"
	camera.current = true
	add_child(camera)
	
	# Set camera bounds from background
	camera.camera_bounds.size = mock_background.texture.get_size()
	camera.set_bounds_enabled(true)
	
	# Wait for initialization
	yield(get_tree().create_timer(0.3), "timeout")

func cleanup_test_scene():
	signals_received.clear()
	
	if camera:
		camera.queue_free()
		camera = null
	if mock_background:
		mock_background.queue_free()
		mock_background = null
	
	yield(get_tree(), "idle_frame")

func reset_signal_tracking():
	signals_received.clear()

# Signal receivers
func _on_camera_move_started(target_pos, old_pos, duration, transition_type):
	signals_received["camera_move_started"] = {
		"target_position": target_pos,
		"old_position": old_pos,
		"duration": duration,
		"transition_type": transition_type
	}
	if log_debug_info:
		print("  [SIGNAL] Received camera_move_started: target=%s" % target_pos)

func _on_camera_move_completed(final_pos, initial_pos, duration):
	signals_received["camera_move_completed"] = {
		"final_position": final_pos,
		"initial_position": initial_pos,
		"duration": duration
	}
	if log_debug_info:
		print("  [SIGNAL] Received camera_move_completed: final=%s" % final_pos)

func _on_camera_state_changed(new_state, old_state, reason):
	signals_received["camera_state_changed"] = {
		"new_state": new_state,
		"old_state": old_state,
		"reason": reason
	}
	if log_debug_info:
		print("  [SIGNAL] Received camera_state_changed: %s -> %s (%s)" % [old_state, new_state, reason])

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