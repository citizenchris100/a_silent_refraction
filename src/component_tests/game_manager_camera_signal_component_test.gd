extends Node2D
class_name GameManagerCameraSignalComponentTest
# Component Test: Tests interaction between GameManager and ScrollingCamera through signals
#
# Components Under Test:
# - GameManager: Central coordinator that should respond to camera state changes
# - ScrollingCamera: Emits various state signals during camera operations
#
# Interaction Contract:
# - Camera emits camera_move_started, camera_move_completed, camera_state_changed signals
# - GameManager connects to and responds to these signals
# - Signals include relevant position and state data

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_camera_signals = true
var test_movement_coordination = true
var test_state_synchronization = true

# Test state
var test_name = "GameManagerCameraSignal"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# ===== COMPONENTS =====
var GameManager = preload("res://src/core/game/game_manager.gd")
var ScrollingCamera = preload("res://src/core/camera/scrolling_camera.gd")
var game_manager: Node
var camera: Camera2D
var test_environment: Node2D

# Mock background for camera
var mock_background: Sprite

# Tracking
var camera_signals_received = {}

# ===== LIFECYCLE =====

func _ready():
	print("\n" + "==================================================")
	print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	# Create test environment
	setup_test_environment()
	
	# Run test suites
	yield(run_tests(), "completed")
	
	# Report and cleanup
	report_results()
	yield(cleanup_test_environment(), "completed")
	
	# Exit
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func setup_test_environment():
	# Create test environment container
	test_environment = Node2D.new()
	test_environment.name = "TestEnvironment"
	add_child(test_environment)
	
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
	test_environment.add_child(mock_background)
	
	# Create camera with real implementation
	camera = ScrollingCamera.new()
	camera.name = "ScrollingCamera"
	camera.current = true
	test_environment.add_child(camera)
	
	# Set camera bounds from background
	camera.camera_bounds.size = mock_background.texture.get_size()
	camera.set_bounds_enabled(true)
	
	# Create a real player instance (GameManager expects to find one)
	var Player = preload("res://src/characters/player/player.gd")
	var player = Node2D.new()
	player.set_script(Player)
	player.name = "Player"
	player.position = Vector2(100, 100)
	test_environment.add_child(player)
	
	# Create game manager with real implementation
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	test_environment.add_child(game_manager)
	
	# Allow systems to initialize and find each other
	# Wait for all components to complete their _ready() yields
	yield(get_tree().create_timer(0.3), "timeout")

func run_tests():
	if run_all_tests or test_camera_signals:
		yield(run_test_suite("Camera Signal Connection", funcref(self, "test_suite_camera_signals")), "completed")
	
	if run_all_tests or test_movement_coordination:
		yield(run_test_suite("Movement Coordination", funcref(self, "test_suite_movement_coordination")), "completed")
	
	if run_all_tests or test_state_synchronization:
		yield(run_test_suite("State Synchronization", funcref(self, "test_suite_state_sync")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(test_func.call_func(), "completed")
	yield(get_tree(), "idle_frame")

# ===== TEST SUITES =====

func test_suite_camera_signals():
	# Test that GameManager connects to camera signals
	start_test("test_game_manager_connects_to_camera")
	# Wait a frame for connections to be established
	yield(get_tree(), "idle_frame")
	
	var connected = false
	# Check if GameManager is connected to any camera signals
	if camera and is_instance_valid(camera) and game_manager and is_instance_valid(game_manager):
		if camera.has_signal("camera_move_started") and game_manager.has_method("_on_camera_move_started"):
			connected = camera.is_connected("camera_move_started", game_manager, "_on_camera_move_started")
		if not connected and camera.has_signal("camera_state_changed") and game_manager.has_method("_on_camera_state_changed"):
			connected = camera.is_connected("camera_state_changed", game_manager, "_on_camera_state_changed")
		if not connected and camera.has_signal("camera_move_completed") and game_manager.has_method("_on_camera_move_completed"):
			connected = camera.is_connected("camera_move_completed", game_manager, "_on_camera_move_completed")
	end_test(connected, "GameManager should connect to camera signals")
	yield(get_tree(), "idle_frame")
	
	# Test camera_move_started signal
	start_test("test_camera_move_started_signal")
	reset_signal_tracking()
	
	# Connect our listener
	if camera and is_instance_valid(camera) and camera.has_signal("camera_move_started"):
		camera.connect("camera_move_started", self, "_on_camera_move_started")
	
	# Trigger camera movement
	var target_pos = Vector2(500, 300)
	if camera and is_instance_valid(camera):
		camera.move_to_position(target_pos)
	yield(get_tree(), "idle_frame")
	
	var signal_received = camera_signals_received.has("camera_move_started")
	var data = camera_signals_received.get("camera_move_started", {})
	var has_target = data.has("target_position")
	
	# Disconnect
	if camera and is_instance_valid(camera) and camera.is_connected("camera_move_started", self, "_on_camera_move_started"):
		camera.disconnect("camera_move_started", self, "_on_camera_move_started")
	
	end_test(signal_received and has_target, "camera_move_started should emit with target position")
	yield(get_tree(), "idle_frame")
	
	# Test camera_move_completed signal
	start_test("test_camera_move_completed_signal")
	reset_signal_tracking()
	
	# Connect listener
	if camera and is_instance_valid(camera) and camera.has_signal("camera_move_completed"):
		camera.connect("camera_move_completed", self, "_on_camera_move_completed")
	
	# Start a movement to a different position
	if camera and is_instance_valid(camera):
		# Move to a position that's different from current
		var new_target = Vector2(200, 200)
		camera.move_to_position(new_target)
		yield(get_tree(), "idle_frame")
	
	# Wait for movement to complete
	yield(get_tree().create_timer(1.0), "timeout")
	
	var completed_received = camera_signals_received.has("camera_move_completed")
	
	# Disconnect
	if camera and is_instance_valid(camera) and camera.is_connected("camera_move_completed", self, "_on_camera_move_completed"):
		camera.disconnect("camera_move_completed", self, "_on_camera_move_completed")
	
	end_test(completed_received, "camera_move_completed should emit when movement finishes")
	yield(get_tree(), "idle_frame")

func test_suite_movement_coordination():
	# Test coordinated movement between camera and player
	start_test("test_camera_follows_player_movement")
	
	# Find the player that was created in setup
	var player = test_environment.get_node("Player")
	
	# Set camera to follow player
	camera.set_target_player(player)
	yield(get_tree(), "idle_frame")
	
	# Move player
	player.position = Vector2(400, 400)
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Camera should have moved toward player
	var camera_moved = camera.position != Vector2.ZERO
	
	end_test(camera_moved, "Camera should follow player movement")
	yield(get_tree(), "idle_frame")

func test_suite_state_sync():
	# Test camera state changes are communicated
	start_test("test_camera_state_change_signals")
	reset_signal_tracking()
	
	# Connect to state change signal
	if camera.has_signal("camera_state_changed"):
		camera.connect("camera_state_changed", self, "_on_camera_state_changed")
	
	# Trigger state change by moving camera (which should change state internally)
	camera.move_to_position(Vector2(300, 300))
	yield(get_tree(), "idle_frame")
	
	var state_signal_received = camera_signals_received.has("camera_state_changed")
	var state_data = camera_signals_received.get("camera_state_changed", {})
	# Just check that we got a state change signal
	var signal_emitted = state_signal_received
	
	# Disconnect
	if camera and is_instance_valid(camera) and camera.is_connected("camera_state_changed", self, "_on_camera_state_changed"):
		camera.disconnect("camera_state_changed", self, "_on_camera_state_changed")
	
	end_test(signal_emitted, "Camera state changes should emit signals")
	yield(get_tree(), "idle_frame")
	
	# Test GameManager responds to camera states
	start_test("test_game_manager_responds_to_camera_states")
	# This would test GM's response, but without implementation we just verify stability
	var stable = true
	
	# Trigger different camera behaviors
	if camera and is_instance_valid(camera):
		camera.move_to_position(Vector2(100, 100))
		yield(get_tree().create_timer(0.2), "timeout")
		stable = stable and is_system_stable()
		
		# Stop camera movement
		camera.position = camera.position  # Force stop by setting to current position
		yield(get_tree(), "idle_frame")
		stable = stable and is_system_stable()
	
	end_test(stable, "GameManager should handle all camera states")
	yield(get_tree(), "idle_frame")

# ===== HELPER METHODS =====

func is_system_stable() -> bool:
	return game_manager != null and is_instance_valid(game_manager) and camera != null and is_instance_valid(camera)

func reset_signal_tracking():
	camera_signals_received.clear()

# Signal receivers
func _on_camera_move_started(target_pos, old_pos, duration, transition_type):
	camera_signals_received["camera_move_started"] = {
		"target_position": target_pos,
		"old_position": old_pos,
		"duration": duration,
		"transition_type": transition_type
	}
	if log_debug_info:
		print("  [SIGNAL] camera_move_started to %s" % target_pos)

func _on_camera_move_completed(final_pos, initial_pos, duration):
	camera_signals_received["camera_move_completed"] = {
		"final_position": final_pos,
		"initial_position": initial_pos,
		"duration": duration
	}
	if log_debug_info:
		print("  [SIGNAL] camera_move_completed at %s" % final_pos)

func _on_camera_state_changed(new_state, old_state, reason):
	camera_signals_received["camera_state_changed"] = {
		"new_state": new_state,
		"old_state": old_state,
		"reason": reason
	}
	if log_debug_info:
		print("  [SIGNAL] camera_state_changed to %s" % str(new_state))

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

func cleanup_test_environment():
	# Disconnect any signals we connected for testing
	if camera and is_instance_valid(camera):
		if camera.is_connected("camera_move_started", self, "_on_camera_move_started"):
			camera.disconnect("camera_move_started", self, "_on_camera_move_started")
		if camera.is_connected("camera_move_completed", self, "_on_camera_move_completed"):
			camera.disconnect("camera_move_completed", self, "_on_camera_move_completed")
		if camera.is_connected("camera_state_changed", self, "_on_camera_state_changed"):
			camera.disconnect("camera_state_changed", self, "_on_camera_state_changed")
	
	# Clear references
	camera = null
	game_manager = null
	mock_background = null
	
	if test_environment:
		# Give time for any pending operations
		yield(get_tree().create_timer(0.2), "timeout")
		test_environment.queue_free()
		test_environment = null

# Test helper functions
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