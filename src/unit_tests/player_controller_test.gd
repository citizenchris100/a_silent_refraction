extends Node2D
# Player Controller Test: Comprehensive test suite for enhanced physics behavior

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_physics_process = true
var test_movement_states = true
var test_acceleration = true
var test_deceleration = true
var test_arrival = true
var test_movement_interruption = true
var test_visual_separation = true
var test_movement_constants = true

# Test state
var test_name = "PlayerControllerTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""

# Test objects
var Player = preload("res://src/characters/player/player.gd")
var player = null

func _ready():
	print("\n==================================================")
	print(" PLAYER CONTROLLER TEST SUITE")
	print("==================================================\n")
	
	run_tests()
	
	print("\n==================================================")
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("==================================================\n")
	
	if tests_failed == 0:
		print("[PASS] All player controller tests passed!")
	else:
		print("[FAIL] Some tests failed!")
	
	# Clean exit for headless testing
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	if run_all_tests or test_physics_process:
		run_test("test_player_uses_physics_process_for_movement")
	
	if run_all_tests or test_movement_states:
		run_test("test_movement_states_exist")
		run_test("test_movement_state_transitions")
	
	if run_all_tests or test_acceleration:
		run_test("test_acceleration_behavior")
	
	if run_all_tests or test_deceleration:
		run_test("test_deceleration_behavior")
	
	if run_all_tests or test_arrival:
		run_test("test_arrival_precision")
	
	if run_all_tests or test_movement_interruption:
		run_test("test_movement_interruption")
	
	if run_all_tests or test_visual_separation:
		run_test("test_visual_update_in_process")
	
	if run_all_tests or test_movement_constants:
		run_test("test_movement_constants")

func run_test(test_func_name: String):
	current_test = test_func_name
	print("\n[TEST] " + test_func_name)
	
	# Create fresh player for each test
	setup_player()
	
	# Run the test
	call(test_func_name)
	
	# Clean up
	teardown_player()

func setup_player():
	# Create mock district first (player looks for it in _ready)
	var mock_district = Node2D.new()
	mock_district.name = "TestDistrict"
	mock_district.add_to_group("district")
	mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
	add_child(mock_district)
	
	# Now create player
	player = Player.new()
	player.name = "TestPlayer"
	add_child(player)
	
	# Allow both to initialize
	yield(get_tree(), "idle_frame")

func teardown_player():
	# Clean up all children (player and mock district)
	for child in get_children():
		child.queue_free()
	player = null
	yield(get_tree(), "idle_frame")

# Helper functions
func assert_true(condition: bool, message: String = ""):
	if condition:
		log_pass(message)
	else:
		log_fail(message)

func assert_false(condition: bool, message: String = ""):
	assert_true(!condition, message)

func assert_eq(actual, expected, message: String = ""):
	if actual == expected:
		log_pass(message)
	else:
		log_fail("%s - Expected: %s, Got: %s" % [message, str(expected), str(actual)])

func assert_ne(actual, expected, message: String = ""):
	if actual != expected:
		log_pass(message)
	else:
		log_fail("%s - Expected different from: %s, Got: %s" % [message, str(expected), str(actual)])

func assert_gt(actual, expected, message: String = ""):
	if actual > expected:
		log_pass(message)
	else:
		log_fail("%s - Expected > %s, Got: %s" % [message, str(expected), str(actual)])

func assert_ge(actual, expected, message: String = ""):
	if actual >= expected:
		log_pass(message)
	else:
		log_fail("%s - Expected >= %s, Got: %s" % [message, str(expected), str(actual)])

func assert_lt(actual, expected, message: String = ""):
	if actual < expected:
		log_pass(message)
	else:
		log_fail("%s - Expected < %s, Got: %s" % [message, str(expected), str(actual)])

func assert_le(actual, expected, message: String = ""):
	if actual <= expected:
		log_pass(message)
	else:
		log_fail("%s - Expected <= %s, Got: %s" % [message, str(expected), str(actual)])

func assert_has(obj, property: String, message: String = ""):
	if property in obj:
		log_pass(message)
	else:
		log_fail("%s - Object missing property: %s" % [message, property])

func assert_has_signal(obj, signal_name: String, message: String = ""):
	if obj.has_signal(signal_name):
		log_pass(message)
	else:
		log_fail("%s - Object missing signal: %s" % [message, signal_name])

func log_pass(message: String):
	tests_passed += 1
	print("  ✓ " + message)

func log_fail(message: String):
	tests_failed += 1
	print("  ✗ " + message)
	print("    in: " + current_test)

func _on_test_signal_received(args = null):
	# Helper for signal testing
	pass

# ===== TEST IMPLEMENTATIONS =====

func test_player_uses_physics_process_for_movement():
	# Player should use _physics_process for movement to avoid screen tearing
	assert_true(player.has_method("_physics_process"), "Player should have _physics_process method")
	
	# Set up movement
	player.position = Vector2(100, 100)
	player.move_to(Vector2(500, 100))
	
	# Simulate physics frame
	player._physics_process(0.016) # 60 FPS physics tick
	
	# Player should have moved
	assert_ne(player.position.x, 100, "Player should move in _physics_process")

func test_movement_states_exist():
	# Verify movement states are defined
	assert_has(player, "MovementState", "Player should have MovementState enum")
	
	if player.has("MovementState"):
		var states = player.MovementState
		assert_has(states, "IDLE", "Should have IDLE state")
		assert_has(states, "ACCELERATING", "Should have ACCELERATING state")
		assert_has(states, "MOVING", "Should have MOVING state")
		assert_has(states, "DECELERATING", "Should have DECELERATING state")
		assert_has(states, "ARRIVED", "Should have ARRIVED state")

func test_movement_state_transitions():
	# Test state machine transitions
	assert_has(player, "current_movement_state", "Player should track movement state")
	assert_has_signal(player, "movement_state_changed", "Player should emit state change signal")
	
	# Initially should be IDLE
	if player.has("MovementState"):
		assert_eq(player.current_movement_state, player.MovementState.IDLE, "Should start in IDLE state")
		
		# Start movement
		var signal_emitted = false
		if player.has_signal("movement_state_changed"):
			player.connect("movement_state_changed", self, "_on_test_signal_received", [signal_emitted], CONNECT_ONESHOT)
		
		player.move_to(Vector2(500, 100))
		
		# Should transition to ACCELERATING
		assert_eq(player.current_movement_state, player.MovementState.ACCELERATING, "Should be ACCELERATING after move_to")

func test_acceleration_behavior():
	# Test smooth acceleration
	player.position = Vector2(100, 100)
	player.velocity = Vector2.ZERO
	player.move_to(Vector2(500, 100))
	
	var initial_velocity = player.velocity.length()
	
	# Simulate several physics frames
	for i in range(10):
		player._physics_process(0.016)
		
		if i > 0:
			var current_velocity = player.velocity.length()
			assert_gt(current_velocity, initial_velocity, "Velocity should increase during acceleration")
			initial_velocity = current_velocity
			
		# Velocity should not jump instantly to max
		assert_le(player.velocity.length(), player.movement_speed, "Velocity should not exceed max speed")

func test_deceleration_behavior():
	# Test smooth deceleration when approaching target
	player.position = Vector2(100, 100)
	player.velocity = Vector2(player.movement_speed, 0) # Start at full speed
	player.move_to(Vector2(150, 100)) # Short distance
	
	var velocities = []
	
	# Simulate movement until arrival
	var max_iterations = 100
	var iterations = 0
	while player.is_moving and iterations < max_iterations:
		player._physics_process(0.016)
		velocities.append(player.velocity.length())
		iterations += 1
	
	# Verify deceleration occurred
	assert_lt(iterations, max_iterations, "Should arrive at destination")
	assert_gt(velocities.size(), 3, "Should have multiple frames of movement")
	
	# Check that velocity decreased near the end
	if velocities.size() > 3:
		var late_velocity = velocities[velocities.size() - 3]
		var final_velocity = velocities[velocities.size() - 1]
		assert_lt(final_velocity, late_velocity, "Should decelerate when approaching target")

func test_arrival_precision():
	# Test that player arrives precisely at target
	player.position = Vector2(100, 100)
	var target = Vector2(500, 100)
	player.move_to(target)
	
	# Simulate until arrival
	var max_iterations = 200
	var iterations = 0
	while player.is_moving and iterations < max_iterations:
		player._physics_process(0.016)
		iterations += 1
	
	assert_false(player.is_moving, "Should have stopped moving")
	assert_eq(player.position, target, "Should arrive exactly at target position")
	assert_eq(player.velocity, Vector2.ZERO, "Velocity should be zero when arrived")
	
	if player.has("MovementState") and player.has("current_movement_state"):
		assert_eq(player.current_movement_state, player.MovementState.ARRIVED, "Should be in ARRIVED state")

func test_boundary_handling():
	# Test that player respects walkable area boundaries
	# This requires a mock district with walkable areas
	log_pass("Skipped - Requires district mock with walkable areas")

func test_movement_interruption():
	# Test changing destination mid-movement
	player.position = Vector2(100, 100)
	player.move_to(Vector2(500, 100))
	
	# Move partway
	for i in range(5):
		player._physics_process(0.016)
	
	var mid_position = player.position
	assert_gt(mid_position.x, 100, "Should have moved from start")
	assert_lt(mid_position.x, 500, "Should not have reached destination")
	
	# Change destination
	player.move_to(Vector2(300, 300))
	
	# Should smoothly redirect
	for i in range(5):
		player._physics_process(0.016)
	
	# Should be moving toward new target
	var direction_to_new_target = (Vector2(300, 300) - mid_position).normalized()
	var actual_direction = player.velocity.normalized()
	
	# Directions should be similar (allowing for acceleration curve)
	var dot_product = direction_to_new_target.dot(actual_direction)
	assert_gt(dot_product, 0.7, "Should be moving toward new target")

func test_visual_update_in_process():
	# Visual updates should happen in _process, not _physics_process
	assert_true(player.has_method("_process"), "Player should have _process for visuals")
	assert_true(player.has_method("_update_visuals"), "Player should have visual update method")

func test_movement_constants():
	# Verify movement constants exist and are reasonable
	assert_has(player, "movement_speed", "Should have movement_speed")
	assert_has(player, "acceleration", "Should have acceleration")
	assert_has(player, "deceleration", "Should have deceleration")
	
	assert_gt(player.movement_speed, 0, "Movement speed should be positive")
	assert_gt(player.acceleration, 0, "Acceleration should be positive")
	assert_gt(player.deceleration, 0, "Deceleration should be positive")
	
	# Deceleration should typically be higher for responsive stopping
	assert_ge(player.deceleration, player.acceleration, "Deceleration should be >= acceleration")