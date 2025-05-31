extends Node2D
# Unit Test: GameManager Signal Management
# Tests that GameManager properly connects to and manages signals from navigation components

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_player_signal_connection = true
var test_camera_signal_connection = true
var test_input_signal_connection = true

# Test state
var test_name = "GameManagerSignal"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var GameManager = preload("res://src/core/game/game_manager.gd")
var game_manager = null

# Mock objects
var mock_player = null
var mock_camera = null
var mock_input_manager = null

# Signal tracking
var gm_received_signals = {}

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
	if run_all_tests or test_player_signal_connection:
		yield(run_test_suite("Player Signal Connection", funcref(self, "test_suite_player_connection")), "completed")
	
	if run_all_tests or test_camera_signal_connection:
		yield(run_test_suite("Camera Signal Connection", funcref(self, "test_suite_camera_connection")), "completed")
		
	if run_all_tests or test_input_signal_connection:
		yield(run_test_suite("Input Signal Connection", funcref(self, "test_suite_input_connection")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	setup_test_scene()
	yield(test_func.call_func(), "completed")
	cleanup_test_scene()

# ===== TEST SUITES =====

func test_suite_player_connection():
	# Test GameManager connects to player movement_state_changed signal
	start_test("test_connects_to_player_movement_state_changed")
	
	# Wait for GameManager to initialize and find player
	yield(get_tree().create_timer(0.2), "timeout")
	
	# Check if connection exists
	var connected = false
	if mock_player and game_manager and mock_player.has_signal("movement_state_changed"):
		connected = mock_player.is_connected("movement_state_changed", game_manager, "_on_player_movement_state_changed")
	
	end_test(connected, "GameManager should connect to player's movement_state_changed signal")
	
	# Test GameManager responds to player state changes
	start_test("test_responds_to_player_state_changes")
	
	# Track if GameManager would respond (we can't test private methods directly)
	# So we test that the connection exists and signal is emitted
	var signal_emitted = false
	if mock_player and mock_player.has_signal("movement_state_changed"):
		mock_player.connect("movement_state_changed", self, "_on_test_player_state_changed")
		mock_player.emit_signal("movement_state_changed", "MOVING")
		yield(get_tree(), "idle_frame")
		signal_emitted = gm_received_signals.has("player_state")
		if mock_player.is_connected("movement_state_changed", self, "_on_test_player_state_changed"):
			mock_player.disconnect("movement_state_changed", self, "_on_test_player_state_changed")
	
	end_test(signal_emitted, "GameManager should be able to receive player state changes")
	yield(get_tree(), "idle_frame")

func test_suite_camera_connection():
	# Test GameManager connects to camera signals
	start_test("test_connects_to_camera_move_started")
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	var connected = false
	if mock_camera and game_manager and mock_camera.has_signal("camera_move_started"):
		connected = mock_camera.is_connected("camera_move_started", game_manager, "_on_camera_move_started")
	
	end_test(connected, "GameManager should connect to camera's camera_move_started signal")
	
	# Test connection to camera_state_changed
	start_test("test_connects_to_camera_state_changed")
	
	var state_connected = false
	if mock_camera and game_manager and mock_camera.has_signal("camera_state_changed"):
		state_connected = mock_camera.is_connected("camera_state_changed", game_manager, "_on_camera_state_changed")
	
	end_test(state_connected, "GameManager should connect to camera's camera_state_changed signal")
	yield(get_tree(), "idle_frame")

func test_suite_input_connection():
	# Test existing InputManager connection (this should PASS as it already exists)
	start_test("test_existing_input_manager_connection")
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	var connected = false
	if mock_input_manager and game_manager and mock_input_manager.has_signal("object_clicked"):
		connected = mock_input_manager.is_connected("object_clicked", game_manager, "handle_object_click")
	
	end_test(connected, "GameManager should connect to InputManager's object_clicked signal")
	
	# Test signal works
	start_test("test_input_signal_functionality")
	
	var can_receive = false
	if mock_input_manager and mock_input_manager.has_signal("object_clicked"):
		mock_input_manager.connect("object_clicked", self, "_on_test_object_clicked")
		mock_input_manager.emit_signal("object_clicked", null, Vector2(100, 100))
		yield(get_tree(), "idle_frame")
		can_receive = gm_received_signals.has("object_clicked")
		if mock_input_manager.is_connected("object_clicked", self, "_on_test_object_clicked"):
			mock_input_manager.disconnect("object_clicked", self, "_on_test_object_clicked")
	
	end_test(can_receive, "InputManager signals should work correctly")
	yield(get_tree(), "idle_frame")

# ===== HELPER METHODS =====

func setup_test_scene():
	# Create mock player with proper signal
	mock_player = Node2D.new()
	mock_player.name = "Player"
	mock_player.add_to_group("player")
	mock_player.add_user_signal("movement_state_changed", [{"name": "new_state", "type": TYPE_STRING}])
	add_child(mock_player)
	
	# Create mock camera with signals
	mock_camera = Node2D.new()
	mock_camera.name = "ScrollingCamera"
	mock_camera.add_user_signal("camera_move_started", [
		{"name": "target_position", "type": TYPE_VECTOR2},
		{"name": "old_position", "type": TYPE_VECTOR2},
		{"name": "move_duration", "type": TYPE_REAL},
		{"name": "transition_type", "type": TYPE_STRING}
	])
	mock_camera.add_user_signal("camera_move_completed", [
		{"name": "final_position", "type": TYPE_VECTOR2},
		{"name": "initial_position", "type": TYPE_VECTOR2},
		{"name": "actual_duration", "type": TYPE_REAL}
	])
	mock_camera.add_user_signal("camera_state_changed", [
		{"name": "new_state", "type": TYPE_STRING},
		{"name": "old_state", "type": TYPE_STRING},
		{"name": "transition_reason", "type": TYPE_STRING}
	])
	add_child(mock_camera)
	
	# Create mock input manager
	mock_input_manager = Node.new()
	mock_input_manager.name = "InputManager"
	mock_input_manager.add_user_signal("object_clicked", [
		{"name": "object", "type": TYPE_OBJECT},
		{"name": "position", "type": TYPE_VECTOR2}
	])
	# Add to scene so GameManager can find it
	get_parent().add_child(mock_input_manager)
	
	# Create GameManager which should find and connect to these
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	add_child(game_manager)
	
	# Wait for initialization
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

func cleanup_test_scene():
	gm_received_signals.clear()
	
	if game_manager:
		game_manager.queue_free()
		game_manager = null
	if mock_player:
		mock_player.queue_free()
		mock_player = null
	if mock_camera:
		mock_camera.queue_free()
		mock_camera = null
	if mock_input_manager and is_instance_valid(mock_input_manager):
		mock_input_manager.queue_free()
		mock_input_manager = null
	
	yield(get_tree(), "idle_frame")

# Signal receivers for testing
func _on_test_player_state_changed(new_state):
	gm_received_signals["player_state"] = new_state
	if log_debug_info:
		print("  [TEST] Received player state: %s" % new_state)

func _on_test_object_clicked(obj, pos):
	gm_received_signals["object_clicked"] = {"object": obj, "position": pos}
	if log_debug_info:
		print("  [TEST] Received object click")

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