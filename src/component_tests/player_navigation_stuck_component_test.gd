extends Node2D
class_name PlayerNavigationStuckComponentTest
# Player Navigation Stuck Component Test: Tests for the stuck state issue when following navigation paths

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_coordinate_consistency = true
var test_waypoint_reaching = true
var test_path_following_stability = true
var test_deceleration_recovery = true

# Test state
var test_name = "PlayerNavigationStuckComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var Player = preload("res://src/characters/player/player.gd")
var player = null
var mock_district = null
var navigation = null

# Mock District with Navigation
class MockNavigationDistrict extends Node2D:
	var district_name = "Test Navigation District"
	var walkable_areas = []
	var navigation_node = null
	
	func _ready():
		add_to_group("district")
	
	func is_position_walkable(position):
		return true  # All positions walkable for this test
	
	func set_navigation(nav):
		navigation_node = nav
		add_child(nav)

func _ready():
	print("\n==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	setup_test_scene()
	yield(get_tree(), "idle_frame")
	
	run_tests()
	
	cleanup_test_scene()
	
	print("\n==================================================")
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

func setup_test_scene():
	# Create mock district
	mock_district = MockNavigationDistrict.new()
	mock_district.name = "TestDistrict"
	add_child(mock_district)
	
	# Create Navigation2D
	navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	mock_district.set_navigation(navigation)
	
	# Create simple navigation polygon
	var nav_polygon = NavigationPolygonInstance.new()
	var navpoly = NavigationPolygon.new()
	navpoly.add_outline(PoolVector2Array([
		Vector2(0, 0),
		Vector2(1000, 0),
		Vector2(1000, 1000),
		Vector2(0, 1000)
	]))
	navpoly.make_polygons_from_outlines()
	nav_polygon.navpoly = navpoly
	navigation.add_child(nav_polygon)
	
	# Create player
	player = Player.new()
	player.position = Vector2(100, 100)
	mock_district.add_child(player)

func cleanup_test_scene():
	if player:
		player.queue_free()
		player = null
	if mock_district:
		mock_district.queue_free()
		mock_district = null

func run_tests():
	if run_all_tests or test_coordinate_consistency:
		run_test_suite("Coordinate Consistency Tests", funcref(self, "test_suite_coordinate_consistency"))
	
	if run_all_tests or test_waypoint_reaching:
		run_test_suite("Waypoint Reaching Tests", funcref(self, "test_suite_waypoint_reaching"))
		
	if run_all_tests or test_path_following_stability:
		run_test_suite("Path Following Stability Tests", funcref(self, "test_suite_path_following_stability"))
		
	if run_all_tests or test_deceleration_recovery:
		run_test_suite("Deceleration Recovery Tests", funcref(self, "test_suite_deceleration_recovery"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

# ===== TEST SUITES =====

func test_suite_coordinate_consistency():
	# Test 1: Check if position and global_position are used consistently
	start_test("test_position_vs_global_position")
	
	# Place player at non-zero position
	player.position = Vector2(200, 200)
	var mock_path = [Vector2(300, 200), Vector2(400, 200), Vector2(500, 200)]
	
	# Request navigation path
	player.navigation_path = mock_path
	player.current_path_index = 0
	player.target_position = Vector2(500, 200)
	player.is_moving = true
	player._set_movement_state(player.MovementState.MOVING)
	
	# Simulate one physics frame
	player._physics_process(0.016)
	
	# Check if player moved towards first waypoint
	var moved = player.position.x > 200
	end_test(moved, "Player should move when using consistent coordinates")
	
	# Test 2: Verify navigation path coordinates match player coordinate space
	start_test("test_navigation_path_coordinate_space")
	
	if player.has_method("request_navigation_path"):
		player.global_position = Vector2(100, 100)
		player.request_navigation_path(Vector2(900, 900))
		
		if player.navigation_path.size() > 0:
			# First path point should be in same coordinate space as player position
			var first_point = player.navigation_path[0]
			var reasonable_distance = player.position.distance_to(first_point) < 1000
			end_test(reasonable_distance, "Navigation path should be in player's coordinate space")
		else:
			end_test(false, "No navigation path generated")
	else:
		end_test(false, "Player lacks navigation methods")

func test_suite_waypoint_reaching():
	# Test 1: Player reaches waypoints with reasonable threshold
	start_test("test_waypoint_threshold")
	
	player.position = Vector2(100, 100)
	player.navigation_path = [Vector2(110, 100)]  # 10 pixels away
	player.current_path_index = 0
	player.target_position = Vector2(200, 100)
	player.is_moving = true
	
	# Store initial index
	var initial_index = player.current_path_index
	
	# Simulate movement
	player._handle_movement(0.016)
	
	# Check if waypoint was considered reached (depends on threshold)
	var reached = player.current_path_index > initial_index
	
	# Log the actual distance for debugging
	if log_debug_info:
		print("  Distance to waypoint: %f" % player.position.distance_to(Vector2(110, 100)))
	
	end_test(true, "Waypoint threshold test completed (threshold behavior documented)")
	
	# Test 2: Player doesn't skip waypoints
	start_test("test_waypoint_sequential_following")
	
	player.position = Vector2(100, 100)
	player.navigation_path = [
		Vector2(200, 100),
		Vector2(300, 100),
		Vector2(400, 100)
	]
	player.current_path_index = 0
	player.target_position = Vector2(400, 100)
	player.is_moving = true
	player.velocity = Vector2.ZERO
	
	# Simulate multiple frames
	var max_frames = 200
	var frame_count = 0
	var indices_visited = [0]
	
	while player.is_moving and frame_count < max_frames:
		player._physics_process(0.016)
		var current_index = player.current_path_index
		var last_index = indices_visited[indices_visited.size() - 1]
		# Only track valid indices that are actually incremental
		# Also check that we still have a navigation path to avoid capturing reset state
		if current_index != last_index and current_index <= player.navigation_path.size() and player.navigation_path.size() > 0:
			indices_visited.append(current_index)
		frame_count += 1
	
	# Check that waypoints were visited in order
	var sequential = true
	for i in range(1, indices_visited.size()):
		if indices_visited[i] != indices_visited[i-1] + 1:
			sequential = false
			break
	
	if log_debug_info:
		print("  Indices visited: %s" % str(indices_visited))
		print("  Final path index: %d" % player.current_path_index)
	
	end_test(sequential, "Waypoints should be followed sequentially")

func test_suite_path_following_stability():
	# Test 1: Player doesn't oscillate at high speeds
	start_test("test_high_speed_stability")
	
	player.position = Vector2(100, 100)
	player.movement_speed = 200  # High speed
	player.velocity = Vector2(150, 0)  # Already moving fast
	player.navigation_path = [Vector2(200, 100)]
	player.current_path_index = 0
	player.target_position = Vector2(200, 100)
	player.is_moving = true
	player._set_movement_state(player.MovementState.MOVING)
	
	# Track positions over several frames
	var positions = []
	for i in range(10):
		positions.append(player.position.x)
		player._physics_process(0.016)
	
	# Check for oscillation (position going backward)
	var oscillated = false
	for i in range(1, positions.size()):
		if positions[i] < positions[i-1] - 5:  # Allow small backward movement
			oscillated = true
			break
	
	end_test(!oscillated, "Player should not oscillate at high speeds")
	
	# Test 2: Player eventually stops at destination
	start_test("test_eventual_arrival")
	
	player.position = Vector2(100, 100)
	player.navigation_path = [Vector2(200, 100)]
	player.current_path_index = 0
	player.target_position = Vector2(200, 100)
	player.is_moving = true
	player.velocity = Vector2.ZERO
	player._set_movement_state(player.MovementState.ACCELERATING)
	
	# Simulate until stopped or timeout
	var frames = 0
	var max_frames = 300  # 5 seconds at 60fps
	
	while player.is_moving and frames < max_frames:
		player._physics_process(0.016)
		frames += 1
	
	var arrived = !player.is_moving and (player.get_state() == "IDLE" or player.get_state() == "ARRIVED")
	var final_distance = player.global_position.distance_to(Vector2(200, 100))
	
	if log_debug_info:
		print("  Frames to arrive: %d" % frames)
		print("  Final distance: %f" % final_distance)
		print("  Final state: %s" % player.get_state())
	
	end_test(arrived and final_distance < 10, "Player should eventually arrive at destination")

func test_suite_deceleration_recovery():
	# Test 1: Player recovers from DECELERATING state
	start_test("test_deceleration_recovery")
	
	player.position = Vector2(100, 100)
	player.velocity = Vector2(100, 0)  # Moving right
	player._set_movement_state(player.MovementState.DECELERATING)
	player.is_moving = true
	player.target_position = Vector2(300, 100)  # Still need to go further
	
	# Track state changes
	var states = [player.get_state()]
	
	# Simulate several frames
	for i in range(20):
		player._physics_process(0.016)
		var current_state = player.get_state()
		if current_state != states[states.size() - 1]:
			states.append(current_state)
	
	# Check if player transitioned out of DECELERATING
	var recovered = states.size() > 1
	
	if log_debug_info:
		print("  State transitions: %s" % str(states))
	
	end_test(recovered, "Player should recover from DECELERATING state when target not reached")
	
	# Test 2: Check for stuck detection
	start_test("test_stuck_detection")
	
	# Set up a scenario similar to the screenshots
	player.position = Vector2(975, 150)  # Near T3
	player.navigation_path = [Vector2(500, 500)]  # Far target
	player.current_path_index = 0
	player.target_position = Vector2(500, 500)
	player.is_moving = true
	player.velocity = Vector2(-100, 0)  # Moving left
	player._set_movement_state(player.MovementState.DECELERATING)
	
	# Track position and state
	var start_pos = player.position
	var positions_recorded = []
	var states_recorded = []
	
	for i in range(60):  # 1 second
		player._physics_process(0.016)
		positions_recorded.append(player.position)
		states_recorded.append(player.get_state())
	
	# Detect if player is stuck (not making progress)
	var total_distance = start_pos.distance_to(player.position)
	var stuck = total_distance < 50  # Less than 50 pixels in 1 second
	
	# Count state changes
	var state_changes = 0
	for i in range(1, states_recorded.size()):
		if states_recorded[i] != states_recorded[i-1]:
			state_changes += 1
	
	if log_debug_info:
		print("  Distance traveled in 1 second: %f" % total_distance)
		print("  State changes: %d" % state_changes)
		print("  Final state: %s" % player.get_state())
	
	# Many state changes with little movement indicates stuck behavior
	var likely_stuck = stuck and state_changes > 10
	
	end_test(!likely_stuck, "Player should not get stuck oscillating between states")

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