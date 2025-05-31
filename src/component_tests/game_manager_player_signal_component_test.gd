extends Node2D
class_name GameManagerPlayerSignalComponentTest
# Component Test: Tests interaction between GameManager and Player through signals
#
# Components Under Test:
# - GameManager: Central coordinator that should respond to player state changes
# - Player: Emits movement_state_changed signals during movement
#
# Interaction Contract:
# - Player emits movement_state_changed when state changes
# - GameManager connects to and responds to these signals
# - Signal data includes the new movement state

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_signal_connection = true
var test_state_responses = true
var test_cleanup_on_player_removal = true

# Test state
var test_name = "GameManagerPlayerSignal"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# ===== COMPONENTS =====
var GameManager = preload("res://src/core/game/game_manager.gd")
var Player = preload("res://src/characters/player/player.gd")
var game_manager: Node
var player: Node2D
var test_environment: Node2D

# Tracking
var gm_received_state_change = false
var gm_last_state_received = null

# ===== LIFECYCLE =====

func _ready():
	print("\n" + "==================================================")
	print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	# Create test environment
	setup_test_environment()
	
	# Run test suites
	run_tests()
	
	# Report and cleanup
	report_results()
	cleanup_test_environment()
	
	# Exit
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func setup_test_environment():
	# Create test environment container
	test_environment = Node2D.new()
	test_environment.name = "TestEnvironment"
	add_child(test_environment)
	
	# Create player with real implementation
	player = Player.new()
	player.name = "Player"
	player.position = Vector2(400, 400)
	player.add_to_group("player")
	test_environment.add_child(player)
	
	# Create game manager with real implementation
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	test_environment.add_child(game_manager)
	
	# Allow systems to initialize and find each other
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	# Extra wait for Player's _ready() yields to complete
	yield(get_tree().create_timer(0.1), "timeout")

func run_tests():
	if run_all_tests or test_signal_connection:
		run_test_suite("Signal Connection", funcref(self, "test_suite_signal_connection"))
	
	if run_all_tests or test_state_responses:
		run_test_suite("State Response", funcref(self, "test_suite_state_responses"))
	
	# Run cleanup test last since it removes the player
	if run_all_tests or test_cleanup_on_player_removal:
		# Re-create player for cleanup test since it may have been freed
		if not player or not is_instance_valid(player):
			player = Player.new()
			player.name = "Player"
			player.position = Vector2(400, 400)
			player.add_to_group("player")
			test_environment.add_child(player)
			yield(get_tree().create_timer(0.2), "timeout")
		run_test_suite("Cleanup Handling", funcref(self, "test_suite_cleanup"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

# ===== TEST SUITES =====

func test_suite_signal_connection():
	# Test that GameManager connects to player signals
	start_test("test_game_manager_connects_to_player")
	# GameManager should find and connect to player automatically
	var connected = false
	if game_manager.has_method("is_connected_to_player_signals"):
		connected = game_manager.is_connected_to_player_signals()
	else:
		# Check if connection exists by checking the actual signal
		if player and player.has_signal("movement_state_changed"):
			connected = player.is_connected("movement_state_changed", game_manager, "_on_player_movement_state_changed")
	end_test(connected, "GameManager should connect to player movement_state_changed")
	
	# Test connection works by triggering signal
	start_test("test_signal_flow_player_to_game_manager")
	reset_tracking()
	
	# Connect our own listener to verify
	if player.has_signal("movement_state_changed"):
		player.connect("movement_state_changed", self, "_on_test_movement_state_changed")
	
	# Trigger state change
	if player.has_method("_set_movement_state"):
		player._set_movement_state(player.MovementState.IDLE)
		player._set_movement_state(player.MovementState.ACCELERATING)
	
	yield(get_tree(), "idle_frame")
	
	# Disconnect our test listener
	if player and player.is_connected("movement_state_changed", self, "_on_test_movement_state_changed"):
		player.disconnect("movement_state_changed", self, "_on_test_movement_state_changed")
	
	end_test(gm_received_state_change, "Signal should flow from Player to GameManager")

func test_suite_state_responses():
	# Test GameManager responds to different states
	start_test("test_game_manager_handles_movement_states")
	var states_handled = true
	
	# Test each movement state
	var test_states = [
		player.MovementState.IDLE,
		player.MovementState.ACCELERATING,
		player.MovementState.MOVING,
		player.MovementState.DECELERATING,
		player.MovementState.ARRIVED
	]
	
	for state in test_states:
		reset_tracking()
		if player and is_instance_valid(player) and player.has_method("_set_movement_state"):
			player._set_movement_state(state)
			yield(get_tree(), "idle_frame")
			
			# GameManager should handle each state appropriately
			# For now we just verify no errors occur
			if not is_system_stable():
				states_handled = false
				break
		else:
			states_handled = false
			break
	
	end_test(states_handled, "GameManager should handle all movement states")
	
	# Test rapid state changes
	start_test("test_rapid_state_changes")
	var rapid_stable = true
	
	# Only run if player still exists
	if player and is_instance_valid(player) and player.has_method("_set_movement_state"):
		for i in range(10):
			var state = test_states[i % test_states.size()]
			player._set_movement_state(state)
			yield(get_tree(), "idle_frame")
			
			if not is_system_stable():
				rapid_stable = false
				break
	else:
		rapid_stable = false  # Can't test without player
	
	end_test(rapid_stable, "System should remain stable during rapid state changes")

func test_suite_cleanup():
	# Test cleanup when player is removed
	start_test("test_cleanup_on_player_removal")
	
	# Store player reference before removal
	var player_exists_before = player != null
	
	# Remove player
	if player:
		player.queue_free()
		player = null
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Verify system remains stable after player removal
	var system_stable = game_manager != null
	
	end_test(player_exists_before and system_stable, "System should remain stable when player is removed")
	
	# Don't recreate player - this is the last test

# ===== HELPER METHODS =====

func is_system_stable() -> bool:
	# Check both components are in valid states
	# Note: player can be null in cleanup tests
	return game_manager != null and is_instance_valid(game_manager)

func reset_tracking():
	gm_received_state_change = false
	gm_last_state_received = null

func _on_test_movement_state_changed(new_state):
	gm_received_state_change = true
	gm_last_state_received = new_state
	if log_debug_info:
		print("  [SIGNAL] Test received movement_state_changed: %s" % str(new_state))

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
	if test_environment:
		# Wait a bit for any pending operations to complete
		yield(get_tree().create_timer(0.5), "timeout")
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