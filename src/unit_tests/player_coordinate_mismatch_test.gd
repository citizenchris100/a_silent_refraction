extends Node2D
# Player Coordinate Mismatch Test: Tests for position vs global_position issues

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test state
var test_name = "PlayerCoordinateMismatchTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var failed_tests = []

# Test objects
var Player = preload("res://src/characters/player/player.gd")

func _ready():
	print("\n==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	# Run tests with yields handled properly
	yield(run_tests(), "completed")
	
	print("\n==================================================")
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("==================================================\n")
	
	if tests_failed == 0:
		print("[PASS] All %s tests passed!" % test_name)
	else:
		print("[FAIL] Some tests failed!")
		for failed in failed_tests:
			print("  - " + failed)
	
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	# Test position vs global_position in navigation
	yield(test_coordinate_space_navigation(), "completed")
	
	# Test waypoint reaching with both coordinate systems
	yield(test_waypoint_distance_calculation(), "completed")
	
	# Test the actual bug in player movement
	yield(test_player_movement_bug(), "completed")

func test_coordinate_space_navigation():
	start_test("test_position_global_position_mismatch")
	
	# Create a container at non-zero position
	var container = Node2D.new()
	container.position = Vector2(100, 100)
	add_child(container)
	
	# Create player as child
	var player = Player.new()
	player.position = Vector2(50, 50)  # Local position
	container.add_child(player)
	
	yield(get_tree(), "idle_frame")
	
	# Player's global position should be (150, 150)
	var expected_global = Vector2(150, 150)
	var actual_global = player.global_position
	
	if log_debug_info:
		print("  Container position: %s" % container.position)
		print("  Player local position: %s" % player.position)
		print("  Player global position: %s" % player.global_position)
		print("  Expected global position: %s" % expected_global)
	
	# Set up navigation path in global coordinates
	player.navigation_path = [Vector2(200, 150), Vector2(250, 150)]
	player.current_path_index = 0
	player.target_position = Vector2(250, 150)
	player.is_moving = true
	
	# Get the current target from _handle_movement logic
	var current_target = player.navigation_path[0]  # Vector2(200, 150)
	
	# Calculate direction using position (local) - this is the bug!
	var direction_using_position = current_target - player.position
	# This gives: (200, 150) - (50, 50) = (150, 100)
	
	# Calculate direction using global_position - this is correct
	var direction_using_global = current_target - player.global_position
	# This gives: (200, 150) - (150, 150) = (50, 0)
	
	if log_debug_info:
		print("  Current target: %s" % current_target)
		print("  Direction using position: %s" % direction_using_position)
		print("  Direction using global_position: %s" % direction_using_global)
	
	# The directions should be different when container is not at origin
	var mismatch_exists = direction_using_position != direction_using_global
	
	# Clean up
	container.queue_free()
	
	# We want this test to FAIL to show the bug exists
	# The test passes if there's NO mismatch (which would mean the bug is fixed)
	end_test(!mismatch_exists, "Player should use same coordinate space regardless of parent position")

func test_waypoint_distance_calculation():
	start_test("test_waypoint_distance_checks")
	
	# Create player at origin for simplicity
	var player = Player.new()
	player.position = Vector2(100, 100)
	add_child(player)
	
	yield(get_tree(), "idle_frame")
	
	# Set navigation path
	player.navigation_path = [Vector2(110, 100)]  # 10 pixels away
	player.current_path_index = 0
	
	# Test distance calculation methods
	var distance_using_position = player.position.distance_to(player.navigation_path[0])
	var distance_using_global = player.global_position.distance_to(player.navigation_path[0])
	
	if log_debug_info:
		print("  Player position: %s" % player.position)
		print("  Player global_position: %s" % player.global_position)
		print("  Waypoint: %s" % player.navigation_path[0])
		print("  Distance using position: %f" % distance_using_position)
		print("  Distance using global_position: %f" % distance_using_global)
	
	# In this case they should be the same since player is at root
	var consistent = abs(distance_using_position - distance_using_global) < 0.1
	
	# Clean up
	player.queue_free()
	
	end_test(consistent, "Distance calculations are consistent when player is at root level")

func test_player_movement_bug():
	start_test("test_navigation_direction_calculation_bug")
	
	# Create mock district at non-zero position to simulate the bug
	var district = Node2D.new()
	district.position = Vector2(100, 100)  # District offset
	district.add_to_group("district")
	district.set_script(GDScript.new())
	district.script.source_code = """
extends Node2D
var district_name = 'Test District'
func is_position_walkable(pos): return true
"""
	district.script.reload()
	add_child(district)
	
	# Create player as child of offset district
	var player = Player.new()
	player.position = Vector2(875, 50)  # Local position (T3 - district offset)
	district.add_child(player)
	
	yield(get_tree(), "idle_frame")
	
	# Set up navigation path
	player.navigation_path = [Vector2(500, 500)]  # Target far away
	player.current_path_index = 0
	player.target_position = Vector2(500, 500)
	player.is_moving = true
	player._set_movement_state(player.MovementState.MOVING)
	
	# The bug: _handle_movement uses position instead of global_position
	# This causes wrong direction calculation
	
	# Get what the current code calculates (WRONG)
	var current_target = player.navigation_path[0]
	var wrong_direction = current_target - player.position
	var wrong_distance = wrong_direction.length()
	
	# Get what it SHOULD calculate (CORRECT)
	var correct_direction = current_target - player.global_position  
	var correct_distance = correct_direction.length()
	
	if log_debug_info:
		print("  Player position: %s" % player.position)
		print("  Player global_position: %s" % player.global_position)
		print("  Navigation target: %s" % current_target)
		print("  Wrong direction (using position): %s" % wrong_direction)
		print("  Correct direction (using global_position): %s" % correct_direction)
		print("  Wrong distance: %f" % wrong_distance)
		print("  Correct distance: %f" % correct_distance)
	
	# The bug exists if these are different
	var bug_exists = wrong_direction != correct_direction
	
	# Clean up
	district.queue_free()
	yield(get_tree(), "idle_frame")
	
	# This test should FAIL because the bug exists
	end_test(!bug_exists, "Player should use global_position for navigation calculations")

# ===== HELPER FUNCTIONS =====

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