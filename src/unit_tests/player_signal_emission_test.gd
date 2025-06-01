extends Node2D
# Unit Test: Player Signal Emission
# Tests that the Player class properly emits movement_state_changed signal

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_signal_definition = true
var test_state_transitions = true
var test_signal_data = true

# Test state
var test_name = "PlayerSignalEmission"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var Player = preload("res://src/characters/player/player.gd")
var player = null

# Signal tracking
var signal_received = false
var last_signal_data = null

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
	if run_all_tests or test_signal_definition:
		yield(run_test_suite("Signal Definition Tests", funcref(self, "test_suite_signal_definition")), "completed")
	
	if run_all_tests or test_state_transitions:
		yield(run_test_suite("State Transition Tests", funcref(self, "test_suite_state_transitions")), "completed")
		
	if run_all_tests or test_signal_data:
		yield(run_test_suite("Signal Data Tests", funcref(self, "test_suite_signal_data")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(setup_test_scene(), "completed")
	yield(test_func.call_func(), "completed")
	yield(cleanup_test_scene(), "completed")

# ===== TEST SUITES =====

func test_suite_signal_definition():
	# Test signal exists
	start_test("test_movement_state_changed_signal_exists")
	var has_signal = player.has_signal("movement_state_changed")
	end_test(has_signal, "Player should have movement_state_changed signal")
	
	# Test signal can be connected
	start_test("test_signal_can_be_connected")
	var can_connect = true
	if player.has_signal("movement_state_changed"):
		player.connect("movement_state_changed", self, "_on_movement_state_changed")
		can_connect = player.is_connected("movement_state_changed", self, "_on_movement_state_changed")
		player.disconnect("movement_state_changed", self, "_on_movement_state_changed")
	else:
		can_connect = false
	end_test(can_connect, "Should be able to connect to movement_state_changed signal")
	yield(get_tree(), "idle_frame")

func test_suite_state_transitions():
	# Connect to signal for all state tests
	if player.has_signal("movement_state_changed"):
		player.connect("movement_state_changed", self, "_on_movement_state_changed")
	
	# Test IDLE to ACCELERATING
	start_test("test_idle_to_accelerating_signal")
	reset_signal_tracking()
	if player and is_instance_valid(player):
		player._set_movement_state(player.MovementState.IDLE)
		yield(get_tree(), "idle_frame")
		player._set_movement_state(player.MovementState.ACCELERATING)
		yield(get_tree(), "idle_frame")
		end_test(signal_received and last_signal_data == player.MovementState.ACCELERATING, 
			"Should emit signal when changing from IDLE to ACCELERATING")
	else:
		end_test(false, "Player not available for testing")
	
	# Test ACCELERATING to MOVING
	start_test("test_accelerating_to_moving_signal")
	reset_signal_tracking()
	player._set_movement_state(player.MovementState.MOVING)
	yield(get_tree(), "idle_frame")
	end_test(signal_received and last_signal_data == player.MovementState.MOVING,
		"Should emit signal when changing from ACCELERATING to MOVING")
	
	# Test MOVING to DECELERATING
	start_test("test_moving_to_decelerating_signal")
	reset_signal_tracking()
	player._set_movement_state(player.MovementState.DECELERATING)
	yield(get_tree(), "idle_frame")
	end_test(signal_received and last_signal_data == player.MovementState.DECELERATING,
		"Should emit signal when changing from MOVING to DECELERATING")
	
	# Test no signal on same state
	start_test("test_no_signal_same_state")
	reset_signal_tracking()
	var current_state = player.current_movement_state
	player._set_movement_state(current_state)
	yield(get_tree(), "idle_frame")
	end_test(not signal_received, "Should not emit signal when state doesn't change")
	
	# Disconnect after state tests
	if player and is_instance_valid(player) and player.is_connected("movement_state_changed", self, "_on_movement_state_changed"):
		player.disconnect("movement_state_changed", self, "_on_movement_state_changed")
	yield(get_tree(), "idle_frame")

func test_suite_signal_data():
	# Test signal data type
	start_test("test_signal_data_type")
	if player and is_instance_valid(player) and player.has_signal("movement_state_changed"):
		player.connect("movement_state_changed", self, "_on_movement_state_changed")
		reset_signal_tracking()
		player._set_movement_state(player.MovementState.IDLE)
		player._set_movement_state(player.MovementState.MOVING)
		yield(get_tree(), "idle_frame")
		var data_is_int = typeof(last_signal_data) == TYPE_INT
		if player.is_connected("movement_state_changed", self, "_on_movement_state_changed"):
			player.disconnect("movement_state_changed", self, "_on_movement_state_changed")
		end_test(data_is_int, "Signal should pass movement state as integer enum")
	else:
		end_test(false, "Cannot test data without signal")
	yield(get_tree(), "idle_frame")

# ===== HELPER METHODS =====

func setup_test_scene():
	# Create player
	player = Player.new()
	player.name = "TestPlayer"
	player.position = Vector2(400, 400)
	add_child(player)
	
	# Wait for player's _ready() to complete (it has yields)
	yield(get_tree().create_timer(0.3), "timeout")

func cleanup_test_scene():
	if player:
		player.queue_free()
		player = null
	
	reset_signal_tracking()
	yield(get_tree(), "idle_frame")

func reset_signal_tracking():
	signal_received = false
	last_signal_data = null

# Signal receiver
func _on_movement_state_changed(new_state):
	signal_received = true
	last_signal_data = new_state
	if log_debug_info:
		print("  [SIGNAL] Received movement_state_changed: %s" % str(new_state))

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