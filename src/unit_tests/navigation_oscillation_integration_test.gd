extends Node2D
# Navigation Oscillation Integration Test: Tests the integration between player movement, navigation, and walkable area boundary systems

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_corner_navigation = true
var test_narrow_corridor = true
var test_boundary_interaction = true

# ===== TEST VARIABLES =====
var district: Node2D
var navigation: Navigation2D
var walkable_area: Polygon2D
var player: Node2D
var test_results = {}
var current_test = ""
var current_suite = ""
var tests_passed = 0
var tests_failed = 0
var failed_tests = []

# Oscillation tracking
var position_history = []
var oscillation_events = []

# ===== LIFECYCLE METHODS =====

func _ready():
	debug_log("Setting up Navigation Oscillation Integration test...")
	
	# Create test scene
	create_test_scene()
	
	# Run the tests and wait for completion
	yield(run_tests(), "completed")
	
	# Report results
	report_results()
	
	# Clean up
	cleanup_test_scene()
	
	# Exit cleanly
	debug_log("Tests complete - exiting...")
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

# ===== TEST SCENE SETUP =====

func create_test_scene():
	debug_log("Creating test scene...")
	
	# Create district with navigation mock
	district = Node2D.new()
	district.name = "TestDistrict"
	district.add_to_group("district")
	district.set_script(preload("res://src/unit_tests/mocks/mock_district_navigation.gd"))
	add_child(district)
	
	# Create Navigation2D
	navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	district.add_child(navigation)
	
	# Create walkable area with problematic geometry
	create_problematic_walkable_area()
	
	# Create player
	create_player()
	
	# Allow everything to initialize
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	debug_log("Test scene created successfully")

func create_problematic_walkable_area():
	# Create a walkable area that's known to cause oscillation issues
	walkable_area = Polygon2D.new()
	walkable_area.name = "WalkableArea"
	
	# Create geometry similar to what's shown in the GIFs
	# Tighter corners and narrower passages to ensure oscillation
	walkable_area.polygon = PoolVector2Array([
		# Horizontal corridor (30 pixels high) - narrower!
		Vector2(100, 365),
		Vector2(400, 365),
		Vector2(400, 395),
		# Very sharp corner
		Vector2(230, 395),  # Even tighter corner
		# Vertical corridor (30 pixels wide) - narrower!
		Vector2(230, 600),
		Vector2(200, 600),
		Vector2(200, 395),
		Vector2(100, 395)
	])
	
	walkable_area.add_to_group("walkable_area")
	district.add_child(walkable_area)
	
	# Create navigation polygon
	var nav_instance = NavigationPolygonInstance.new()
	var nav_poly = NavigationPolygon.new()
	nav_poly.add_outline(walkable_area.polygon)
	nav_poly.make_polygons_from_outlines()
	nav_instance.navpoly = nav_poly
	navigation.add_child(nav_instance)
	
	# Manually register with district
	if district.has_method("add_walkable_area"):
		district.add_walkable_area(walkable_area)

func create_player():
	var Player = preload("res://src/characters/player/player.gd")
	player = Node2D.new()
	player.set_script(Player)
	player.position = Vector2(300, 380)  # Center of horizontal corridor
	
	# Pre-configure player to avoid initialization issues
	player.target_position = player.position
	player.current_district = district
	player.navigation_node = navigation
	player.is_moving = false
	player.velocity = Vector2.ZERO
	player.navigation_path = []
	player.current_path_index = 0
	player.current_movement_state = 0  # IDLE
	
	add_child(player)

func cleanup_test_scene():
	if player:
		player.queue_free()
	if district:
		district.queue_free()
	position_history.clear()
	oscillation_events.clear()

# ===== TEST EXECUTION =====

func run_tests():
	debug_log("\n===== RUNNING INTEGRATION TESTS =====\n")
	
	if test_corner_navigation:
		yield(run_test_suite("Corner Navigation", funcref(self, "test_suite_corner_navigation")), "completed")
		
	if test_narrow_corridor:
		yield(run_test_suite("Narrow Corridor", funcref(self, "test_suite_narrow_corridor")), "completed")
		
	if test_boundary_interaction:
		yield(run_test_suite("Boundary Interaction", funcref(self, "test_suite_boundary_interaction")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	debug_log("\n=== Test Suite: %s ===" % suite_name)
	
	# Reset tracking
	position_history.clear()
	oscillation_events.clear()
	
	# Reset player position
	if player:
		player.position = Vector2(300, 380)
		player.velocity = Vector2.ZERO
		player.is_moving = false
		player.navigation_path = []
		player.current_path_index = 0
		yield(get_tree(), "idle_frame")
	
	# Run the test and wait for completion
	yield(test_func.call_func(), "completed")

# ===== TEST SUITES =====

func test_suite_corner_navigation():
	# Test 1: Navigate around sharp corner
	start_test("sharp_corner_oscillation")
	
	# Navigate from horizontal corridor to vertical corridor
	var start_pos = player.position
	var target_pos = Vector2(220, 500)  # In vertical corridor
	
	debug_log("Testing navigation from %s to %s" % [start_pos, target_pos])
	player.move_to(target_pos)
	
	# Monitor movement for oscillation
	var result = yield(monitor_for_oscillation(5.0), "completed")
	
	# Test expects player to successfully navigate around corner
	if result.reached_destination:
		end_test(true, "Player successfully navigated corner")
	elif result.oscillated:
		end_test(false, "Player oscillated %d times and got stuck at %s" % [result.count, player.position])
	else:
		end_test(false, "Player got stuck without oscillating at %s" % player.position)
	
	yield(get_tree(), "idle_frame")

func test_suite_narrow_corridor():
	# Test 2: Navigate through narrowest part
	start_test("narrow_corridor_oscillation")
	
	# Position at one end of corridor
	player.position = Vector2(150, 380)
	yield(get_tree(), "idle_frame")
	
	# Navigate to corner area
	var target_pos = Vector2(220, 420)  # Near the corner junction
	
	debug_log("Testing narrow corridor navigation to corner junction")
	player.move_to(target_pos)
	
	var result = yield(monitor_for_oscillation(3.0), "completed")
	
	# Test expects player to navigate through narrow corridor
	if result.reached_destination:
		end_test(true, "Player successfully navigated narrow corridor")
	elif result.oscillated:
		end_test(false, "Player oscillated %d times in corridor" % result.count)
	else:
		end_test(false, "Player got stuck in corridor")
	
	yield(get_tree(), "idle_frame")

func test_suite_boundary_interaction():
	# Test 3: Specific boundary pushback scenario
	start_test("boundary_pushback_oscillation")
	
	# Position player near boundary
	player.position = Vector2(235, 395)  # Very close to corner
	yield(get_tree(), "idle_frame")
	
	# Try to move just past the corner
	var target_pos = Vector2(220, 410)
	
	debug_log("Testing boundary pushback near corner")
	player.move_to(target_pos)
	
	# Monitor with more detailed tracking
	var timer = 0.0
	var max_time = 2.0
	var pushback_count = 0
	var last_pos = player.position
	
	while timer < max_time and player.is_moving:
		yield(get_tree(), "idle_frame")
		timer += get_process_delta_time()
		
		var current_pos = player.global_position
		
		# Detect pushback (moving backwards)
		if (current_pos - last_pos).dot(player.velocity) < -0.5 and player.velocity.length() > 10:
			pushback_count += 1
			debug_log("  Pushback detected at %s" % current_pos)
		
		last_pos = current_pos
	
	# Test expects smooth navigation without excessive pushbacks
	if pushback_count < 3 and player.global_position.distance_to(target_pos) < 20:
		end_test(true, "Player navigated smoothly with minimal pushback")
	else:
		end_test(false, "Excessive pushbacks detected: %d" % pushback_count)
	
	yield(get_tree(), "idle_frame")

# ===== OSCILLATION MONITORING =====

func monitor_for_oscillation(max_time: float) -> Dictionary:
	var timer = 0.0
	var oscillation_count = 0
	var oscillation_detected = false
	var reached_destination = false
	position_history.clear()
	
	while timer < max_time and player.is_moving:
		yield(get_tree(), "idle_frame")
		timer += get_process_delta_time()
		
		# Track position
		position_history.append(player.global_position)
		if position_history.size() > 10:
			position_history.pop_front()
		
		# Check for oscillation pattern
		if position_history.size() >= 6:
			var pos1 = position_history[-1]
			var pos2 = position_history[-3]
			var pos3 = position_history[-5]
			
			# Oscillation: returning to similar position with movement in between
			if pos1.distance_to(pos3) < 15.0 and pos2.distance_to(pos1) > 5.0:
				oscillation_count += 1
				if not oscillation_detected and oscillation_count >= 3:
					oscillation_detected = true
					oscillation_events.append({
						"position": pos1,
						"time": timer,
						"path_index": player.current_path_index,
						"velocity": player.velocity
					})
					debug_log("  OSCILLATION DETECTED at %s (count: %d)" % [pos1, oscillation_count])
		
		# Check if reached destination
		if player.global_position.distance_to(player.target_position) < 10:
			reached_destination = true
		
		# Log progress periodically
		if int(timer * 2) != int((timer - get_process_delta_time()) * 2):
			var dist = player.global_position.distance_to(player.target_position)
			debug_log("  Time: %.1f, Pos: %s, Dist to target: %.1f" % [timer, player.global_position, dist])
	
	return {
		"oscillated": oscillation_detected,
		"count": oscillation_count,
		"reached_destination": reached_destination,
		"time_elapsed": timer
	}

# ===== HELPER FUNCTIONS =====

func start_test(test_name: String):
	current_test = test_name
	debug_log("\n[TEST] %s" % test_name)

func end_test(passed: bool, message: String = ""):
	if passed:
		tests_passed += 1
		debug_log("  ✓ PASS: %s" % message)
		test_results[current_test] = "PASS"
	else:
		tests_failed += 1
		failed_tests.append(current_test)
		debug_log("  ✗ FAIL: %s" % message)
		test_results[current_test] = "FAIL"

func report_results():
	debug_log("\n===== TEST RESULTS =====")
	debug_log("Total tests: %d" % (tests_passed + tests_failed))
	debug_log("Passed: %d" % tests_passed)
	debug_log("Failed: %d" % tests_failed)
	
	if tests_failed > 0:
		debug_log("\nFailed tests:")
		for test in failed_tests:
			debug_log("  - %s" % test)
	
	if oscillation_events.size() > 0:
		debug_log("\nOscillation Events:")
		for event in oscillation_events:
			debug_log("  - Position: %s, Time: %.2fs, PathIdx: %d" % 
				[event.position, event.time, event.path_index])

func debug_log(message: String):
	if log_debug_info:
		print(message)