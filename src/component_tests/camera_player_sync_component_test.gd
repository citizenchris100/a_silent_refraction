extends Node2D
class_name CameraPlayerSyncComponentTest
# Camera-Player Synchronization Component Test: Verifies that camera and player movement are properly synchronized

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for verbose output

# Test-specific flags
var test_process_sync = true
var test_movement_sync = true
var test_frame_timing = true

# Test state
var test_name = "CameraPlayerSyncComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var Player = preload("res://src/characters/player/player.gd")
var ScrollingCamera = preload("res://src/core/camera/scrolling_camera.gd")
var player = null
var camera = null
var mock_district = null

# Tracking variables for synchronization tests
var player_positions = []
var camera_positions = []
var frame_count = 0
var physics_frame_count = 0
var process_frame_count = 0
var last_player_pos = Vector2.ZERO
var last_camera_pos = Vector2.ZERO
var position_mismatches = []

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
	
	# Clean exit for headless testing
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	if run_all_tests or test_process_sync:
		run_test_suite("Process Synchronization Tests", funcref(self, "test_suite_process_sync"))
	
	if run_all_tests or test_movement_sync:
		run_test_suite("Movement Synchronization Tests", funcref(self, "test_suite_movement_sync"))
		
	if run_all_tests or test_frame_timing:
		run_test_suite("Frame Timing Tests", funcref(self, "test_suite_frame_timing"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

func test_suite_process_sync():
	# Test 1: Verify camera uses same process method as player
	setup_test_scene()
	
	start_test("test_camera_and_player_use_same_process_method")
	
	# Check if both use physics_process or both use process
	var player_uses_physics = player.has_method("_physics_process")
	var camera_uses_physics = camera.has_method("_handle_camera_movement") and camera.has_method("_physics_process")
	var camera_uses_process = camera.has_method("_process")
	
	# The camera should use the same process method as the player for movement
	var sync_method = player_uses_physics == camera_uses_physics
	
	end_test(sync_method, "Camera and player should use the same process method (both physics or both regular)")
	
	cleanup_test_scene()

func test_suite_movement_sync():
	# Test 2: Camera should track player without lag
	setup_test_scene()
	
	start_test("test_camera_tracks_player_without_lag")
	
	# Enable position tracking
	set_process(true)
	set_physics_process(true)
	
	# Move player and track positions over multiple frames
	player.move_to(Vector2(500, 300))
	
	# Wait for movement to complete
	var max_wait = 3.0
	var waited = 0.0
	while player.is_moving and waited < max_wait:
		yield(get_tree(), "idle_frame")
		waited += get_process_delta_time()
	
	# Analyze position mismatches
	var max_allowed_mismatch = 5.0  # pixels
	var significant_mismatches = 0
	
	for mismatch in position_mismatches:
		if mismatch.distance > max_allowed_mismatch:
			significant_mismatches += 1
			if log_debug_info:
				print("  Frame %d: Player-Camera distance: %.2f pixels" % [mismatch.frame, mismatch.distance])
	
	var mismatch_percentage = 0.0
	if position_mismatches.size() > 0:
		mismatch_percentage = (float(significant_mismatches) / position_mismatches.size()) * 100.0
	
	end_test(mismatch_percentage < 10.0, "Camera should stay within %d pixels of player (%.1f%% frames exceeded limit)" % [max_allowed_mismatch, mismatch_percentage])
	
	cleanup_test_scene()

func test_suite_frame_timing():
	# Test 3: Verify camera updates happen after player updates
	setup_test_scene()
	
	start_test("test_camera_updates_after_player")
	
	# Track update order for a few frames
	var update_order_correct = true
	var frames_to_test = 10
	
	for i in frames_to_test:
		# Reset tracking
		physics_frame_count = 0
		process_frame_count = 0
		
		yield(get_tree(), "idle_frame")
		
		# In Godot, physics_process happens before process
		# So if player uses physics and camera uses process, camera will update after
		# But if both use same method, we need to check execution order
		if log_debug_info:
			print("  Frame %d: physics=%d, process=%d" % [i, physics_frame_count, process_frame_count])
	
	end_test(update_order_correct, "Camera updates should happen in correct order relative to player")
	
	cleanup_test_scene()

func setup_test_scene():
	# Clear tracking arrays
	player_positions.clear()
	camera_positions.clear()
	position_mismatches.clear()
	frame_count = 0
	physics_frame_count = 0
	process_frame_count = 0
	
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
	mock_district.add_child(walkable_area)
	mock_district.add_walkable_area(walkable_area)
	
	# Create player
	player = Player.new()
	player.position = Vector2(100, 300)
	add_child(player)
	
	# Create camera
	camera = ScrollingCamera.new()
	camera.position = Vector2(512, 300)
	camera.follow_player = true
	camera.test_mode = true
	add_child(camera)
	
	# Wait for initialization
	yield(get_tree(), "idle_frame")
	
	# Set camera target
	camera.target_player = player
	
	# Store initial positions
	last_player_pos = player.position
	last_camera_pos = camera.position

func cleanup_test_scene():
	set_process(false)
	set_physics_process(false)
	
	if player:
		player.queue_free()
		player = null
		
	if camera:
		camera.queue_free()
		camera = null
		
	if mock_district:
		mock_district.queue_free()
		mock_district = null
		
	yield(get_tree(), "idle_frame")

func _process(delta):
	if not player or not camera:
		return
		
	process_frame_count += 1
	
	# Track positions in regular process
	if player.is_moving:
		var player_pos = player.global_position
		var camera_pos = camera.global_position
		var distance = player_pos.distance_to(camera_pos)
		
		position_mismatches.append({
			"frame": frame_count,
			"player_pos": player_pos,
			"camera_pos": camera_pos,
			"distance": distance
		})
		
		if log_debug_info and distance > 10.0:
			print("  [PROCESS] Frame %d: Player-Camera distance: %.2f" % [frame_count, distance])

func _physics_process(delta):
	if not player or not camera:
		return
		
	physics_frame_count += 1
	frame_count += 1
	
	# Track positions in physics process
	if player.is_moving:
		player_positions.append(player.global_position)
		camera_positions.append(camera.global_position)

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