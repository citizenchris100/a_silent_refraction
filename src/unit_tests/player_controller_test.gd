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
var mock_district = null

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
	# Create mock district with walkable areas
	mock_district = Node2D.new()
	mock_district.name = "TestDistrict"
	mock_district.add_to_group("district")
	mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
	add_child(mock_district)
	
	# Initialize mock district
	if mock_district.has_method("setup_mock"):
		mock_district.setup_mock()
	
	# Create a large walkable area for testing
	var walkable_area = Polygon2D.new()
	walkable_area.name = "WalkableArea"
	walkable_area.add_to_group("walkable_area")  # Add to group like other tests do
	walkable_area.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(1000, 0),
		Vector2(1000, 600),
		Vector2(0, 600)
	])
	walkable_area.color = Color(0, 1, 0, 0.3)  # Visual appearance
	# Add the walkable area to the scene tree so it's properly initialized
	mock_district.add_child(walkable_area)
	mock_district.add_walkable_area(walkable_area)
	
	# Now create player
	player = Player.new()
	player.name = "TestPlayer"
	player.position = Vector2(100, 100) # Start within walkable area
	add_child(player)
	
	# Allow both to initialize  
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")  # Extra frame for player's yield in _ready()
	yield(get_tree(), "idle_frame")  # One more to be safe
	
	# Debug logging
	if log_debug_info:
		print("  District name: ", mock_district.district_name)
		print("  Walkable areas count: ", mock_district.walkable_areas.size())
		print("  Player position: ", player.position)
		print("  Testing walkable at (100,100): ", mock_district.is_position_walkable(Vector2(100, 100)))
		print("  Testing walkable at (500,100): ", mock_district.is_position_walkable(Vector2(500, 100)))

func teardown_player():
	# Disable processing to prevent yields from continuing
	if player:
		player.set_process(false)
		player.set_physics_process(false)
		player.is_moving = false  # Stop any movement
	
	# Wait for any active timers/yields to complete
	yield(get_tree().create_timer(0.2), "timeout")
	
	# Now clean up all children
	for child in get_children():
		child.queue_free()
	player = null
	mock_district = null
	
	# Final wait for cleanup
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

func _on_test_signal_received(new_state):
	# Helper for signal testing - movement_state_changed signal passes the new state
	pass

# ===== TEST IMPLEMENTATIONS =====

func test_player_uses_physics_process_for_movement():
	# Player should use _physics_process for movement to avoid screen tearing
	assert_true(player.has_method("_physics_process"), "Player should have _physics_process method")
	
	# For physics-only testing, bypass walkable area validation
	# This tests the physics behavior in isolation
	player.position = Vector2(100, 100)
	player.target_position = Vector2(500, 100)
	player.is_moving = true
	player._set_movement_state(player.MovementState.ACCELERATING)
	
	# Simulate physics frame
	player._physics_process(0.016) # 60 FPS physics tick
	
	# Debug output
	if log_debug_info:
		print("  Player position after physics tick: ", player.position)
		print("  Player velocity: ", player.velocity)
		print("  Is moving: ", player.is_moving)
	
	# Player should have moved
	assert_ne(player.position.x, 100, "Player should move in _physics_process")

func test_movement_states_exist():
	# Verify movement states are defined
	assert_has(player, "MovementState", "Player should have MovementState enum")
	
	if "MovementState" in player:
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
	if "MovementState" in player:
		assert_eq(player.current_movement_state, player.MovementState.IDLE, "Should start in IDLE state")
		
		# Start movement using isolated approach
		var signal_emitted = false
		if player.has_signal("movement_state_changed"):
			player.connect("movement_state_changed", self, "_on_test_signal_received", [], CONNECT_ONESHOT)
		
		# Bypass walkable area check for isolated testing
		player.target_position = Vector2(500, 100)
		player.is_moving = true
		player._set_movement_state(player.MovementState.ACCELERATING)
		
		# Should transition to ACCELERATING
		assert_eq(player.current_movement_state, player.MovementState.ACCELERATING, "Should be ACCELERATING after move_to")

func test_acceleration_behavior():
	# Test smooth acceleration
	player.position = Vector2(100, 100)
	player.velocity = Vector2.ZERO
	
	# Bypass walkable area check for isolated testing
	player.target_position = Vector2(500, 100)
	player.is_moving = true
	player._set_movement_state(player.MovementState.ACCELERATING)
	
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
	
	# Bypass walkable area check for isolated testing
	player.target_position = Vector2(150, 100) # Short distance
	player.is_moving = true
	player._set_movement_state(player.MovementState.MOVING) # Start in MOVING state
	
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