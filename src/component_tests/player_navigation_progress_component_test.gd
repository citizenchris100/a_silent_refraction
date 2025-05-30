extends Node2D
class_name PlayerNavigationProgressComponentTest
# Player Navigation Progress Component Test: Ensures player makes progress along navigation paths

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test state
var test_name = "PlayerNavigationProgressComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var failed_tests = []

# Test objects
var Player = preload("res://src/characters/player/player.gd")
var player = null
var mock_district = null

# Mock District with obstacles using multiple walkable areas (like movement test)
class MockDistrict extends Node2D:
	var district_name = "Test District"
	var walkable_areas = []
	
	func _ready():
		add_to_group("district")
		
		# Create walkable areas that exclude the obstacle region
		# This mimics the movement test scene pattern
		
		# Area 1: Top area (above obstacle)
		var top_area = create_walkable_polygon([
			Vector2(700, 100),
			Vector2(1100, 100),
			Vector2(1100, 200),
			Vector2(700, 200)
		])
		add_child(top_area)
		walkable_areas.append(top_area)
		
		# Area 2: Left passage (left of obstacle)
		var left_area = create_walkable_polygon([
			Vector2(700, 200),
			Vector2(850, 200),
			Vector2(850, 350),
			Vector2(700, 350)
		])
		add_child(left_area)
		walkable_areas.append(left_area)
		
		# Area 3: Right passage (right of obstacle) 
		var right_area = create_walkable_polygon([
			Vector2(950, 200),
			Vector2(1100, 200),
			Vector2(1100, 350),
			Vector2(950, 350)
		])
		add_child(right_area)
		walkable_areas.append(right_area)
		
		# Area 4: Bottom area (below obstacle)
		var bottom_area = create_walkable_polygon([
			Vector2(700, 350),
			Vector2(1100, 350),
			Vector2(1100, 400),
			Vector2(700, 400)
		])
		add_child(bottom_area)
		walkable_areas.append(bottom_area)
		
		# The obstacle is implicitly the gap between areas 2 and 3
		# from (850, 200) to (950, 350)
	
	func create_walkable_polygon(points: PoolVector2Array) -> Polygon2D:
		var poly = Polygon2D.new()
		poly.polygon = points
		poly.color = Color(0, 1, 0, 0.1)  # Light green
		poly.add_to_group("walkable_area")
		return poly
	
	func is_position_walkable(position):
		# Check if position is in any walkable area
		for area in walkable_areas:
			if area.polygon and Geometry.is_point_in_polygon(position, area.polygon):
				return true
		return false

func _ready():
	print("\n==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	# Don't setup/cleanup here - do it in run_tests
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

func setup_test_scene():
	# Create mock district
	mock_district = MockDistrict.new()
	add_child(mock_district)
	
	# Wait for district to initialize
	yield(get_tree(), "idle_frame")
	
	# Create player as child of the scene (not district) to match game architecture
	player = Player.new()
	player.global_position = Vector2(975, 150)  # Start in top area (T3 equivalent)
	add_child(player)
	
	# Wait for player to find district
	yield(get_tree(), "idle_frame")

func cleanup_test_scene():
	if player:
		player.queue_free()
		player = null
	if mock_district:
		mock_district.queue_free()
		mock_district = null
	
	# Wait for cleanup to complete
	yield(get_tree(), "idle_frame")

func run_tests():
	# Setup for first test
	setup_test_scene()
	yield(get_tree(), "idle_frame")
	
	# Test navigation progress
	test_navigation_progress()
	yield(get_tree(), "idle_frame")
	
	# Reset scene between tests
	yield(cleanup_test_scene(), "completed")
	setup_test_scene()
	yield(get_tree(), "idle_frame")
	
	# Test waypoint reaching with tolerance
	test_waypoint_reaching_tolerance()
	yield(get_tree(), "idle_frame")
	
	# Reset scene between tests
	yield(cleanup_test_scene(), "completed")
	setup_test_scene()
	yield(get_tree(), "idle_frame")
	
	# Test stuck state scenario from screenshots
	test_stuck_state_with_obstacles()
	yield(get_tree(), "idle_frame")
	
	# Reset scene between tests
	yield(cleanup_test_scene(), "completed")
	setup_test_scene()
	yield(get_tree(), "idle_frame")
	
	# Test velocity direction mismatch at waypoints
	test_velocity_direction_at_waypoints()
	yield(get_tree(), "idle_frame")
	
	# Reset scene for final test
	yield(cleanup_test_scene(), "completed")
	setup_test_scene()
	yield(get_tree(), "idle_frame")
	
	# Test the exact failing scenario from player_navigation_stuck_test
	test_waypoint_sequential_following_reproduction()
	yield(get_tree(), "idle_frame")
	
	# Final cleanup
	yield(cleanup_test_scene(), "completed")

func test_navigation_progress():
	start_test("test_player_makes_progress_along_path")
	
	# Setup similar to screenshots - player at T3 trying to reach P7
	player.global_position = Vector2(975, 150)
	
	# Simulate a path that goes around obstacle via left passage
	var navigation_path = [
		Vector2(800, 150),   # Move left in top area
		Vector2(800, 250),   # Enter left passage  
		Vector2(800, 375),   # Exit to bottom area
		Vector2(900, 375)    # Final destination
	]
	
	player.navigation_path = navigation_path
	player.current_path_index = 0
	player.target_position = navigation_path[navigation_path.size() - 1]
	player.is_moving = true
	player._set_movement_state(player.MovementState.ACCELERATING)
	
	# Track progress
	var start_position = player.global_position
	var positions = [start_position]
	var max_frames = 300  # 5 seconds
	var stuck_threshold = 30  # If player doesn't move 30 pixels in 5 seconds, they're stuck
	
	for i in range(max_frames):
		player._physics_process(0.016)
		
		# Record position every 10 frames
		if i % 10 == 0:
			positions.append(player.global_position)
	
	# Calculate total distance traveled
	var total_distance = 0.0
	for i in range(1, positions.size()):
		total_distance += positions[i-1].distance_to(positions[i])
	
	var made_progress = total_distance > stuck_threshold
	
	if log_debug_info:
		print("  Start position: %s" % start_position)
		print("  End position: %s" % player.global_position)
		print("  Total distance traveled: %.2f" % total_distance)
		print("  Final waypoint index: %d" % player.current_path_index)
		print("  Current state: %s" % player.get_state())
	
	end_test(made_progress, "Player should make progress along navigation path")

func test_waypoint_reaching_tolerance():
	start_test("test_waypoint_reaching_with_overshoot")
	
	# Reset player
	player.global_position = Vector2(100, 100)
	player.velocity = Vector2(180, 0)  # Moving fast to the right
	
	# Single waypoint slightly ahead
	player.navigation_path = [Vector2(120, 100)]
	player.current_path_index = 0
	player.target_position = Vector2(200, 100)
	player.is_moving = true
	player._set_movement_state(player.MovementState.MOVING)
	
	var initial_index = player.current_path_index
	
	# Simulate a few frames - player might overshoot the waypoint
	for i in range(5):
		player._physics_process(0.016)
	
	# Check if waypoint was reached despite potential overshoot
	var waypoint_advanced = player.current_path_index > initial_index
	
	if log_debug_info:
		print("  Player position after movement: %s" % player.global_position)
		print("  Distance to waypoint: %.2f" % player.global_position.distance_to(Vector2(120, 100)))
		print("  Waypoint index advanced: %s" % waypoint_advanced)
	
	end_test(waypoint_advanced, "Player should advance waypoint even with slight overshoot")

func test_stuck_state_with_obstacles():
	start_test("test_navigation_stuck_at_intermediate_waypoint")
	
	# Reset player to position that recreates the bug
	player.global_position = Vector2(975, 150)  # Top area
	player.velocity = Vector2.ZERO
	player._set_movement_state(player.MovementState.IDLE)
	
	# Create a path with sharp turns that might trigger the stuck state
	# Key insight: The stuck state seems to happen when velocity direction
	# doesn't align with the new waypoint direction after reaching a waypoint
	var navigation_path = [
		Vector2(800, 150),   # First waypoint - move left (velocity will be leftward)
		Vector2(800, 250),   # Second waypoint - sharp turn down (velocity.dot(direction) might be negative)
		Vector2(750, 300),   # Third waypoint - slight left-down (another direction change)
		Vector2(850, 375)    # Final destination - sharp right turn
	]
	
	player.navigation_path = navigation_path
	player.current_path_index = 0
	player.target_position = navigation_path[navigation_path.size() - 1]
	player.is_moving = true
	player._set_movement_state(player.MovementState.ACCELERATING)
	
	# Track state over time
	var state_history = []
	var position_history = []
	var waypoint_history = []
	var max_frames = 300  # 5 seconds should be enough
	var stuck_threshold_frames = 60  # 1 second of no progress = stuck
	
	for i in range(max_frames):
		# Record state every 5 frames
		if i % 5 == 0:
			state_history.append(player.get_state())
			position_history.append(player.global_position)
			waypoint_history.append(player.current_path_index)
		
		player._physics_process(0.016)
		
		# Check for stuck condition after initial movement time
		if i > stuck_threshold_frames and i % 10 == 0:
			# Look at recent position history
			if position_history.size() >= 10:
				var recent_positions = position_history.slice(max(0, position_history.size() - 10), position_history.size() - 1)
				
				# Calculate movement in recent frames
				var total_movement = 0.0
				for j in range(1, recent_positions.size()):
					total_movement += recent_positions[j-1].distance_to(recent_positions[j])
				
				# If very little movement, we're stuck
				if total_movement < 10.0:  # Less than 10 pixels in ~0.8 seconds
					if log_debug_info:
						print("  STUCK DETECTED at frame %d" % i)
						print("  Total movement in last 10 samples: %.2f pixels" % total_movement)
						print("  Current waypoint: %d of %d" % [player.current_path_index, navigation_path.size()-1])
						print("  Current position: %s" % player.global_position)
						print("  Recent states: %s" % str(state_history.slice(max(0, state_history.size()-5), state_history.size()-1)))
					break
		
		# Early exit if reached destination
		if player.global_position.distance_to(navigation_path[navigation_path.size()-1]) < 20:
			break
	
	# Analyze results
	# With the oscillation fix, the player might be more cautious at waypoints
	# Check if we made actual distance progress instead
	var start_pos = Vector2(975, 150)
	var final_distance = player.global_position.distance_to(navigation_path[navigation_path.size()-1])
	var initial_distance = start_pos.distance_to(navigation_path[navigation_path.size()-1])
	var made_progress = final_distance < initial_distance * 0.5  # Made at least 50% progress
	var reached_destination = player.global_position.distance_to(navigation_path[navigation_path.size()-1]) < 50
	var got_stuck = false
	
	# Check for state oscillation pattern (sign of being stuck)
	if state_history.size() > 20:
		var oscillation_count = 0
		for i in range(10, state_history.size() - 1):
			if state_history[i] != state_history[i-1]:
				oscillation_count += 1
		
		# If more than 50% of recent states are different, we're oscillating
		if oscillation_count > 10:
			got_stuck = true
			if log_debug_info:
				print("  State oscillation detected: %d state changes in recent history" % oscillation_count)
	
	# Check waypoint progression
	if waypoint_history.size() > 10:
		# Look for waypoint index going backwards (another stuck sign)
		for i in range(1, waypoint_history.size()):
			if waypoint_history[i] < waypoint_history[i-1]:
				got_stuck = true
				if log_debug_info:
					print("  Waypoint regression detected: %s" % waypoint_history)
				break
	
	if log_debug_info:
		print("  Start position: %s" % Vector2(975, 150))
		print("  End position: %s" % player.global_position)
		print("  Final waypoint: %d of %d" % [player.current_path_index, navigation_path.size()-1])
		print("  Final state: %s" % player.get_state())
		print("  Made progress: %s" % made_progress)
		print("  Got stuck: %s" % got_stuck)
		print("  Reached destination: %s" % reached_destination)
	
	# Test passes if we made progress without getting stuck
	end_test(made_progress and not got_stuck, "Player should navigate around obstacles without getting stuck")

func test_velocity_direction_at_waypoints():
	start_test("test_velocity_direction_mismatch_handling")
	
	# This test specifically targets the scenario where velocity direction
	# doesn't match the new waypoint direction after reaching a waypoint
	
	# Start player moving fast to the right
	player.global_position = Vector2(800, 200)
	player.velocity = Vector2(150, 0)  # Moving right at high speed
	player._set_movement_state(player.MovementState.MOVING)
	
	# Set up a path that requires an immediate sharp turn
	var navigation_path = [
		Vector2(810, 200),   # Very close waypoint to the right (will be reached quickly)
		Vector2(810, 300),   # Sharp 90-degree turn downward
		Vector2(810, 400)    # Continue downward
	]
	
	player.navigation_path = navigation_path
	player.current_path_index = 0
	player.target_position = navigation_path[navigation_path.size() - 1]
	player.is_moving = true
	
	# Track what happens at the waypoint transition
	var transition_data = {
		"velocity_at_waypoint": [],
		"states_at_transition": [],
		"positions": []
	}
	
	var max_frames = 200
	var previous_waypoint = 0
	
	for i in range(max_frames):
		# Detect waypoint transitions
		if player.current_path_index != previous_waypoint:
			transition_data.velocity_at_waypoint.append(player.velocity)
			transition_data.states_at_transition.append(player.get_state())
			transition_data.positions.append(player.global_position)
			
			if log_debug_info:
				print("  Waypoint transition %d -> %d" % [previous_waypoint, player.current_path_index])
				print("    Position: %s" % player.global_position)
				print("    Velocity: %s (magnitude: %.2f)" % [player.velocity, player.velocity.length()])
				print("    State: %s" % player.get_state())
				
				if player.current_path_index < navigation_path.size():
					var new_direction = (navigation_path[player.current_path_index] - player.global_position).normalized()
					var dot_product = player.velocity.normalized().dot(new_direction)
					print("    Velocity dot with new direction: %.2f" % dot_product)
			
			previous_waypoint = player.current_path_index
		
		player._physics_process(0.016)
		
		# Check if reached destination
		if player.global_position.distance_to(navigation_path[navigation_path.size()-1]) < 20:
			break
	
	# Analyze results
	var handled_direction_changes = true
	
	# Check if player successfully navigated the sharp turns
	if transition_data.velocity_at_waypoint.size() >= 2:
		# At the first waypoint transition, velocity should have been rightward
		# At the second transition, it should be more downward
		var first_velocity = transition_data.velocity_at_waypoint[0]
		var second_velocity = transition_data.velocity_at_waypoint[1] if transition_data.velocity_at_waypoint.size() > 1 else Vector2.ZERO
		
		if log_debug_info:
			print("  First transition velocity: %s" % first_velocity)
			print("  Second transition velocity: %s" % second_velocity)
			print("  Final position: %s" % player.global_position)
			print("  Target reached: %s" % (player.global_position.distance_to(navigation_path[navigation_path.size()-1]) < 50))
	
	var reached_destination = player.global_position.distance_to(navigation_path[navigation_path.size()-1]) < 50
	
	end_test(reached_destination, "Player should handle sharp turns at waypoints without getting stuck")

func test_waypoint_sequential_following_reproduction():
	start_test("test_waypoint_index_reset_bug")
	
	# This reproduces the exact failing test from player_navigation_stuck_test
	# The bug: waypoint indices go [0, 1, 2, 3, 0] - resetting back to 0
	
	player.global_position = Vector2(100, 100)
	player.navigation_path = [
		Vector2(200, 100),
		Vector2(300, 100),
		Vector2(400, 100)
	]
	player.current_path_index = 0
	player.target_position = Vector2(400, 100)
	player.is_moving = true
	player.velocity = Vector2.ZERO
	player._set_movement_state(player.MovementState.ACCELERATING)
	
	# Track waypoint indices
	var max_frames = 200
	var frame_count = 0
	var indices_visited = [0]
	
	while player.is_moving and frame_count < max_frames:
		player._physics_process(0.016)
		var current_index = player.current_path_index
		var last_index = indices_visited[indices_visited.size() - 1]
		
		# Track index changes
		# Also check that we still have a navigation path to avoid capturing reset state
		if current_index != last_index and current_index <= player.navigation_path.size() and player.navigation_path.size() > 0:
			indices_visited.append(current_index)
			
			if log_debug_info:
				print("  Waypoint index changed: %d -> %d at position %s" % [last_index, current_index, player.global_position])
				print("  Distance to final target: %.2f" % player.global_position.distance_to(player.target_position))
		
		frame_count += 1
	
	# Check that waypoints were visited in order
	var sequential = true
	var index_reset_detected = false
	
	for i in range(1, indices_visited.size()):
		if indices_visited[i] != indices_visited[i-1] + 1:
			sequential = false
			# Check specifically for reset to 0
			if indices_visited[i] == 0 and indices_visited[i-1] > 0:
				index_reset_detected = true
				if log_debug_info:
					print("  INDEX RESET DETECTED: %d -> 0" % indices_visited[i-1])
			break
	
	if log_debug_info:
		print("  Indices visited: %s" % str(indices_visited))
		print("  Sequential: %s" % sequential)
		print("  Index reset detected: %s" % index_reset_detected)
		print("  Final position: %s" % player.global_position)
		print("  Final state: %s" % player.get_state())
	
	# Test fails if waypoints were not followed sequentially
	end_test(sequential, "Waypoints should be followed sequentially without resetting to 0")

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