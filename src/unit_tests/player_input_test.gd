extends "res://src/core/districts/base_district.gd"
# Player Input Test: Tests coordinate conversion in player input handling
# This test extends base_district to test within the actual game architecture

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test state
var test_name = "PlayerInputTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Track mouse clicks
var last_move_to_position = null
var test_player = null

func _ready():
	# Set up the district first
	district_name = "Test Input District"
	district_description = "Testing player input coordinate conversion"
	
	# Enable scrolling camera (required for coordinate conversion)
	use_scrolling_camera = true
	
	# Disable debug features for testing
	OS.set_environment("DISABLE_CAMERA_DEBUG", "1")
	
	# Create minimal required nodes
	setup_test_district()
	
	# Call parent _ready() - This sets up camera and systems
	._ready()
	
	# Set up CoordinateManager to know about this district
	CoordinateManager.set_current_district(self)
	
	# Wait for everything to initialize
	yield(get_tree().create_timer(0.2), "timeout")
	
	# Now run our tests
	print("\n==================================================")
	print(" %s TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
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
	
	# Clean up before exit
	cleanup_test_scene()
	
	# Force clean up all child nodes recursively
	_recursive_free_children(self)
	
	# Wait for nodes to be freed
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Clear any remaining references
	walkable_areas.clear()
	interactive_objects.clear()
	camera = null
	test_player = null
	test_texture = null
	
	# Ensure CoordinateManager is cleaned up
	if CoordinateManager.get_current_district() == self:
		CoordinateManager.set_current_district(null)
	
	# Final wait to ensure everything is cleaned
	yield(get_tree(), "idle_frame")
	
	# Clean exit for headless testing
	get_tree().quit(tests_failed)

var test_texture = null  # Store reference to free later

func setup_test_district():
	# Create background (required by base_district)
	var background = Sprite.new()
	background.name = "Background"
	
	# Create a minimal texture
	var image = Image.new()
	image.create(1920, 1080, false, Image.FORMAT_RGB8)
	image.fill(Color(0.2, 0.2, 0.2))
	test_texture = ImageTexture.new()
	test_texture.create_from_image(image)
	background.texture = test_texture
	background.centered = false
	add_child(background)
	
	# Set background size for camera
	background_size = background.texture.get_size()
	
	# Create walkable areas
	create_test_walkable_area()

func create_test_walkable_area():
	var walkable_container = Node2D.new()
	walkable_container.name = "WalkableAreas"
	add_child(walkable_container)
	
	var area = Polygon2D.new()
	area.name = "TestWalkableArea"
	area.polygon = PoolVector2Array([
		Vector2(0, 400),
		Vector2(1920, 400),
		Vector2(1920, 800),
		Vector2(0, 800)
	])
	area.color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
	area.add_to_group("walkable_area")
	walkable_container.add_child(area)

func run_tests():
	if run_all_tests:
		yield(run_test_suite("Player Input Coordinate Tests", funcref(self, "test_suite_coordinates")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(setup_test_scene(), "completed")
	yield(test_func.call_func(), "completed")
	cleanup_test_scene()
	print("Suite completed: %d/%d tests passed" % [tests_passed, tests_passed + tests_failed])

func test_suite_coordinates():
	# Test that player controller converts screen coordinates to world coordinates
	start_test("test_click_uses_world_coordinates")
	
	# Get the camera that base_district created
	var camera = get_camera()
	if not camera:
		end_test(false, "No camera found - base_district setup failed")
		return
		
	# Move camera to a non-zero position to ensure screen != world
	camera.global_position = Vector2(500, 300)
	var camera_pos = camera.global_position
	
	# Verify the camera is properly accessible through different methods
	if log_debug_info:
		print("  Camera from get_camera(): ", camera)
		print("  Camera position: ", camera_pos)
		print("  Camera has screen_to_world?: ", camera.has_method("screen_to_world"))
		print("  CoordinateManager has current district: ", CoordinateManager.get_current_district() != null)
		
	# Simulate a click event at screen position (100, 100)
	var click_event = InputEventMouseButton.new()
	click_event.button_index = BUTTON_LEFT
	click_event.pressed = true
	click_event.position = Vector2(100, 100)  # Screen coordinates
	
	# The expected world position should be properly converted
	# Using CoordinateManager's screen_to_world which should now work
	var expected_world_pos = CoordinateManager.screen_to_world(Vector2(100, 100))
	
	# Get the player controller (created by base_district)
	var player_controller = get_node_or_null("PlayerController")
	if not player_controller:
		end_test(false, "No PlayerController found - base_district setup failed")
		return
	
	# Send the input event
	player_controller._input(click_event)
	
	# Wait a frame for any processing
	yield(get_tree(), "idle_frame")
	
	# Check what position was sent to move_to
	if log_debug_info:
		print("  Click screen position: %s" % str(click_event.position))
		print("  Camera position: %s" % str(camera_pos))
		print("  Expected world position: %s" % str(expected_world_pos))
		print("  Actual move_to position: %s" % str(last_move_to_position))
	
	# Test should pass if the positions match
	end_test(
		last_move_to_position != null and last_move_to_position.distance_to(expected_world_pos) < 1.0,
		"Player should move to world coordinates, not screen coordinates"
	)

func setup_test_scene():
	# Replace the base_district's player with our mock
	var existing_player = get_node_or_null("Player")
	if existing_player:
		existing_player.queue_free()
		yield(get_tree(), "idle_frame")
	
	# Create a mock player that tracks move_to calls
	test_player = KinematicBody2D.new()
	test_player.name = "Player"
	test_player.add_to_group("player")
	test_player.set_script(load("res://src/unit_tests/mocks/mock_player_for_input.gd"))
	test_player.test_parent = self
	add_child(test_player)
	
	# Let base_district's systems initialize with our mock player
	yield(get_tree(), "idle_frame")
	
	# Set up player controller with our mock player
	setup_player_and_controller(Vector2(960, 540))
	
	yield(get_tree(), "idle_frame")

func cleanup_test_scene():
	last_move_to_position = null
	
	# Clean up the player controller first
	var player_controller = get_node_or_null("PlayerController")
	if player_controller:
		player_controller.player = null
		player_controller.queue_free()
	
	# Clean up test player
	if test_player:
		test_player.queue_free()
		test_player = null
	
	# Base district cleanup happens automatically

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

# Called by mock player to record move_to calls
func record_move_to(position: Vector2):
	last_move_to_position = position

# Override setup_camera to disable debug features
func setup_camera():
	# Call parent to set up camera
	.setup_camera()
	
	# Disable debug features after camera is created
	if camera and "debug_draw" in camera:
		camera.debug_draw = false

func _recursive_free_children(node):
	for child in node.get_children():
		_recursive_free_children(child)
		child.queue_free()

func _exit_tree():
	# Clean up any remaining references
	test_player = null
	last_move_to_position = null
	
	# Clean up the camera reference
	camera = null
	
	# Clean up animated background manager
	if animated_bg_manager:
		animated_bg_manager.queue_free()
		animated_bg_manager = null
	
	# Clean up texture resource
	if test_texture:
		test_texture = null
	
	# Clear walkable areas
	walkable_areas.clear()
	
	# Clear interactive objects
	interactive_objects.clear()
	
	# Unregister from CoordinateManager
	if CoordinateManager.get_current_district() == self:
		CoordinateManager.set_current_district(null)