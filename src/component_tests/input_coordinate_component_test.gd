extends "res://src/core/districts/base_district.gd"
# Component Test: Tests interaction between InputManager and CoordinateManager
#
# Components Under Test:
# - InputManager: Handles mouse click events and coordinate transformation
# - CoordinateManager: Provides screen-to-world coordinate conversion
# - Camera System: Required for coordinate transformations
#
# Interaction Contract:
# - InputManager receives screen coordinates from mouse clicks
# - InputManager uses CoordinateManager to convert to world coordinates
# - Converted coordinates are validated before being used

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_basic_conversion = true
var test_camera_states = true
var test_edge_cases = true

# Test state
var test_name = "InputCoordinateComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# ===== COMPONENTS =====
var test_input_manager = null
var test_player = null
var captured_world_positions = []

func _ready():
	print("\n==================================================")
	print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	# Set up the district first
	district_name = "Test Input Coordinate District"
	district_description = "Testing InputManager and CoordinateManager interaction"
	
	# Enable scrolling camera (required for coordinate conversion)
	use_scrolling_camera = true
	
	# Create minimal required nodes
	setup_test_district()
	
	# Call parent _ready() - This sets up camera and systems
	._ready()
	
	# Set up CoordinateManager to know about this district
	CoordinateManager.set_current_district(self)
	
	# Wait for everything to initialize
	yield(get_tree().create_timer(0.2), "timeout")
	
	# Create test components
	setup_test_components()
	
	# Run test suites
	yield(run_tests(), "completed")
	
	# Report and cleanup
	report_results()
	cleanup_test_components()
	
	# Exit
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func setup_test_district():
	# Create background (required by base_district)
	var background = Sprite.new()
	background.name = "Background"
	
	# Create a larger texture for camera movement tests
	var image = Image.new()
	image.create(2400, 1800, false, Image.FORMAT_RGB8)
	image.fill(Color(0.2, 0.2, 0.2))
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	background.texture = texture
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
		Vector2(100, 100),
		Vector2(2300, 100),
		Vector2(2300, 1700),
		Vector2(100, 1700)
	])
	area.color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
	area.add_to_group("walkable_area")
	walkable_container.add_child(area)

func setup_test_components():
	# Create test input manager that captures world positions
	test_input_manager = Node.new()
	test_input_manager.name = "TestInputManager"
	test_input_manager.set_script(preload("res://src/component_tests/mocks/mock_input_manager_component.gd"))
	test_input_manager.test_parent = self
	add_child(test_input_manager)
	
	# Replace the base_district's player with our test player
	var existing_player = get_node_or_null("Player")
	if existing_player:
		existing_player.queue_free()
		yield(get_tree(), "idle_frame")
	
	# Create test player that records move_to calls
	test_player = KinematicBody2D.new()
	test_player.name = "Player"
	test_player.add_to_group("player")
	test_player.set_script(preload("res://src/unit_tests/mocks/mock_player_for_input.gd"))
	test_player.test_parent = self
	add_child(test_player)
	
	# Let components initialize
	yield(get_tree(), "idle_frame")
	
	# Set up player controller with our test components
	setup_player_and_controller(Vector2(960, 540))
	
	yield(get_tree(), "idle_frame")

func run_tests():
	if run_all_tests or test_basic_conversion:
		yield(run_test_suite("Basic Coordinate Conversion", funcref(self, "test_suite_basic_conversion")), "completed")
	
	if run_all_tests or test_camera_states:
		yield(run_test_suite("Different Camera States", funcref(self, "test_suite_camera_states")), "completed")
	
	if run_all_tests or test_edge_cases:
		yield(run_test_suite("Edge Cases", funcref(self, "test_suite_edge_cases")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	yield(test_func.call_func(), "completed")

# ===== TEST SUITES =====

func test_suite_basic_conversion():
	# Test that screen coordinates are properly converted to world coordinates
	start_test("test_click_converts_to_world")
	
	# Get the camera
	var camera = get_camera()
	if not camera:
		end_test(false, "No camera found - base_district setup failed")
		return
	
	# Reset camera to known position
	camera.global_position = Vector2.ZERO
	yield(get_tree(), "idle_frame")
	
	# Clear any previous captures
	captured_world_positions.clear()
	
	# Simulate a click at screen position (400, 300)
	var screen_click = Vector2(400, 300)
	var expected_world = CoordinateManager.screen_to_world(screen_click)
	
	# Process the click through the test input manager
	test_input_manager.process_test_click(screen_click)
	yield(get_tree(), "idle_frame")
	
	# Verify conversion happened correctly
	if captured_world_positions.size() > 0:
		var actual_world = captured_world_positions[0]
		var distance = actual_world.distance_to(expected_world)
		
		if log_debug_info:
			print("  Screen click: %s" % str(screen_click))
			print("  Expected world: %s" % str(expected_world))
			print("  Actual world: %s" % str(actual_world))
			print("  Distance: %.2f" % distance)
		
		end_test(distance < 1.0, "Screen coordinates correctly converted to world coordinates")
	else:
		end_test(false, "No world position captured - conversion failed")

func test_suite_camera_states():
	# Test conversion with camera moved
	start_test("test_conversion_with_camera_offset")
	
	var camera = get_camera()
	if not camera:
		end_test(false, "No camera found")
		return
	
	# Move camera to a non-zero position
	camera.global_position = Vector2(500, 300)
	yield(get_tree(), "idle_frame")
	
	captured_world_positions.clear()
	
	# Click at center of screen
	var screen_click = Vector2(960, 540)
	var expected_world = CoordinateManager.screen_to_world(screen_click)
	
	test_input_manager.process_test_click(screen_click)
	yield(get_tree(), "idle_frame")
	
	if captured_world_positions.size() > 0:
		var actual_world = captured_world_positions[0]
		var distance = actual_world.distance_to(expected_world)
		
		if log_debug_info:
			print("  Camera offset: %s" % str(camera.global_position))
			print("  Screen click: %s" % str(screen_click))
			print("  Expected world: %s" % str(expected_world))
			print("  Actual world: %s" % str(actual_world))
		
		end_test(distance < 1.0, "Conversion accounts for camera offset")
	else:
		end_test(false, "No world position captured with camera offset")
	
	# Test conversion with camera zoom
	start_test("test_conversion_with_camera_zoom")
	
	# Reset camera position but change zoom
	camera.global_position = Vector2.ZERO
	camera.zoom = Vector2(0.5, 0.5)  # Zoomed in (smaller values = closer)
	yield(get_tree(), "idle_frame")
	
	captured_world_positions.clear()
	
	# Click at a known position
	screen_click = Vector2(480, 270)
	expected_world = CoordinateManager.screen_to_world(screen_click)
	
	test_input_manager.process_test_click(screen_click)
	yield(get_tree(), "idle_frame")
	
	if captured_world_positions.size() > 0:
		var actual_world = captured_world_positions[0]
		var distance = actual_world.distance_to(expected_world)
		
		if log_debug_info:
			print("  Camera zoom: %s" % str(camera.zoom))
			print("  Screen click: %s" % str(screen_click))
			print("  Expected world: %s" % str(expected_world))
			print("  Actual world: %s" % str(actual_world))
		
		end_test(distance < 1.0, "Conversion accounts for camera zoom")
	else:
		end_test(false, "No world position captured with camera zoom")
	
	# Reset camera for next tests
	camera.zoom = Vector2(1, 1)

func test_suite_edge_cases():
	# Test clicking at exact screen boundaries
	start_test("test_screen_boundary_clicks")
	
	var viewport_size = OS.get_window_size()
	var boundary_clicks = [
		Vector2(0, 0),                              # Top-left corner
		Vector2(viewport_size.x - 1, 0),            # Top-right corner
		Vector2(0, viewport_size.y - 1),            # Bottom-left corner
		Vector2(viewport_size.x - 1, viewport_size.y - 1)  # Bottom-right corner
	]
	
	var all_converted = true
	for click_pos in boundary_clicks:
		captured_world_positions.clear()
		
		# Validate that the position is within viewport
		if CoordinateManager.validate_viewport_coordinates(click_pos, true):
			test_input_manager.process_test_click(click_pos)
			yield(get_tree(), "idle_frame")
			
			if captured_world_positions.size() == 0:
				all_converted = false
				if log_debug_info:
					print("  Failed to convert boundary click: %s" % str(click_pos))
		else:
			if log_debug_info:
				print("  Boundary click outside viewport: %s" % str(click_pos))
	
	end_test(all_converted, "Screen boundary clicks are converted correctly")
	
	# Test rapid successive clicks
	start_test("test_rapid_click_conversion")
	
	var rapid_success = true
	var click_count = 10
	captured_world_positions.clear()
	
	# Send multiple clicks rapidly
	for i in range(click_count):
		var click_pos = Vector2(400 + i * 50, 300 + i * 30)
		test_input_manager.process_test_click(click_pos)
		# Don't yield - test rapid processing
	
	# Wait for all to process
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Should have captured all clicks
	if captured_world_positions.size() != click_count:
		rapid_success = false
		if log_debug_info:
			print("  Expected %d captures, got %d" % [click_count, captured_world_positions.size()])
	
	end_test(rapid_success, "Rapid clicks are all converted correctly")

# ===== HELPER METHODS =====

func capture_world_position(world_pos: Vector2):
	"""Called by mock input manager when it converts coordinates"""
	captured_world_positions.append(world_pos)
	if log_debug_info:
		print("  Captured world position: %s" % str(world_pos))

func record_move_to(position: Vector2):
	"""Called by mock player to record move_to calls"""
	if log_debug_info:
		print("  Player move_to called with: %s" % str(position))

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

func cleanup_test_components():
	if test_input_manager:
		test_input_manager.queue_free()
		test_input_manager = null
	captured_world_positions.clear()

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