extends Node2D
# Player API Test: Tests for new player API methods needed by test scenes

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_navigation_path_api = true
var test_state_api = true

# Test state
var test_name = "PlayerAPITest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var Player = preload("res://src/characters/player/player.gd")
var player = null
var mock_district = null

func _ready():
	print("\n==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	run_tests()
	
	print("\n==================================================")
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("==================================================\n")
	
	if tests_failed == 0:
		print("[PASS] All %s tests passed!" % test_name)
	else:
		print("[FAIL] Some tests failed!")
		for failed in failed_tests:
			print("  - " + failed)
	
	# Clean exit
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	if run_all_tests or test_navigation_path_api:
		run_test_suite("Navigation Path API", funcref(self, "test_suite_navigation_path"))
	
	if run_all_tests or test_state_api:
		run_test_suite("State API", funcref(self, "test_suite_state_api"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	setup_test_scene()
	test_func.call_func()
	cleanup_test_scene()

func setup_test_scene():
	# Create mock district
	mock_district = Node2D.new()
	mock_district.name = "TestDistrict"
	mock_district.add_to_group("district")
	mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
	add_child(mock_district)
	
	# Create walkable area
	var walkable_area = Polygon2D.new()
	walkable_area.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(1000, 0),
		Vector2(1000, 600),
		Vector2(0, 600)
	])
	walkable_area.add_to_group("walkable_area")
	mock_district.add_child(walkable_area)
	mock_district.add_walkable_area(walkable_area)
	
	# Create player
	player = Player.new()
	player.position = Vector2(100, 100)
	add_child(player)
	
	# Wait for initialization
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

func cleanup_test_scene():
	if player:
		player.queue_free()
		player = null
	if mock_district:
		mock_district.queue_free()
		mock_district = null
	yield(get_tree(), "idle_frame")

# ===== TEST SUITES =====

func test_suite_navigation_path():
	# Test 1: Method exists
	start_test("test_get_navigation_path_exists")
	var has_method = player.has_method("get_navigation_path")
	end_test(has_method, "Player should have get_navigation_path method")
	
	# Test 2: Returns empty array when not navigating
	start_test("test_get_navigation_path_empty_when_idle")
	if player.has_method("get_navigation_path"):
		var path = player.get_navigation_path()
		var is_array = typeof(path) == TYPE_ARRAY
		var is_empty = path.size() == 0
		end_test(is_array and is_empty, "Should return empty array when idle")
	else:
		end_test(false, "Method doesn't exist")
	
	# Test 3: Returns path when navigating
	start_test("test_get_navigation_path_returns_path_when_moving")
	if player.has_method("get_navigation_path"):
		# Set up navigation path manually to test in isolation
		player.navigation_path = [Vector2(100, 100), Vector2(200, 100), Vector2(300, 100)]
		var path = player.get_navigation_path()
		end_test(path.size() == 3, "Should return navigation path when set")
	else:
		end_test(false, "Method doesn't exist")

func test_suite_state_api():
	# Test 1: Method exists
	start_test("test_get_state_exists")
	var has_method = player.has_method("get_state")
	end_test(has_method, "Player should have get_state method")
	
	# Test 2: Returns string
	start_test("test_get_state_returns_string")
	if player.has_method("get_state"):
		var state = player.get_state()
		end_test(typeof(state) == TYPE_STRING, "get_state should return a string")
	else:
		end_test(false, "Method doesn't exist")
	
	# Test 3: Returns correct state names
	start_test("test_get_state_returns_correct_names")
	if player.has_method("get_state") and player.has_method("_set_movement_state"):
		var test_cases = [
			{"state": player.MovementState.IDLE, "expected": "IDLE"},
			{"state": player.MovementState.ACCELERATING, "expected": "ACCELERATING"},
			{"state": player.MovementState.MOVING, "expected": "MOVING"},
			{"state": player.MovementState.DECELERATING, "expected": "DECELERATING"},
			{"state": player.MovementState.ARRIVED, "expected": "ARRIVED"}
		]
		
		var all_passed = true
		for test in test_cases:
			player._set_movement_state(test.state)
			var result = player.get_state()
			if result != test.expected:
				all_passed = false
				if log_debug_info:
					print("    Expected '%s', got '%s'" % [test.expected, result])
		
		end_test(all_passed, "All state names should match enum values")
	else:
		end_test(false, "Required methods don't exist")

# ===== HELPER FUNCTIONS =====

func start_test(test_method_name: String):
	current_test = test_method_name
	if log_debug_info:
		print("\n[TEST] " + test_method_name)

func end_test(passed: bool, message: String):
	if passed:
		tests_passed += 1
		print("  ✓ PASS: %s: %s" % [current_test, message])
	else:
		tests_failed += 1
		failed_tests.append(current_test)
		print("  ✗ FAIL: %s: %s" % [current_test, message])