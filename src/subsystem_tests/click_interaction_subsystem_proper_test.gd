extends "res://src/core/districts/base_district.gd"
# Subsystem Test: Click Interaction - Tests complete click detection, validation, and action flow
# This test extends base_district to accurately represent the actual game architecture
#
# Systems Under Test:
# - InputManager: Processes mouse clicks and initiates actions
# - CoordinateManager: Transforms screen to world coordinates
# - Camera System: Provides coordinate transformation context
# - Player Controller: Receives movement commands from clicks
# - District/WalkableArea: Validates click positions
# - Visual Feedback System: Shows click validation results (TO BE IMPLEMENTED)
# - Click Priority System: Handles overlapping clickable areas (TO BE IMPLEMENTED)
#
# Test Scenarios:
# 1. Click Detection Refinements: New validation methods in InputManager
# 2. Visual Feedback: Click feedback system existence and behavior
# 3. Priority System: Overlapping clickable area handling
# 4. Tolerance & Perspective: Click tolerance and zoom awareness

# ===== SUBSYSTEM CONFIGURATION =====
var subsystem_name = "ClickInteraction"
var required_components = [
	"InputManager",
	"CoordinateManager",
	"ScrollingCamera",
	"PlayerController",
	"BaseDistrict"
]

# Test scenarios to run
var test_scenarios = {
	"click_refinements": true,
	"visual_feedback": true,
	"priority_system": true,
	"tolerance_perspective": true
}

# Test configuration (manual since we don't extend subsystem_test_base)
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var failed_tests = []
var test_start_time = 0
var current_scenario = ""

# Test state
var player = null
var real_input_manager = null

# ===== LIFECYCLE =====

func _ready():
	print("\n============================================================")
	print(" %s SUBSYSTEM TEST SUITE" % subsystem_name.to_upper())
	print("============================================================\n")
	
	# Set up district properties
	district_name = "Click Interaction Test District"
	district_description = "Test district for click interaction subsystem validation"
	
	# Configure camera system
	use_scrolling_camera = true
	camera_follow_smoothing = 5.0
	initial_camera_view = "center"
	
	# Create test background (MUST be direct child named "Background")
	create_test_background()
	
	# Create test walkable areas BEFORE calling parent _ready()
	create_test_walkable_areas()
	
	# Call parent _ready() - this sets up the district, creates camera, finds walkable areas
	._ready()
	
	print("DEBUG: Base district initialized")
	print("DEBUG: Camera created: %s" % (camera != null))
	print("DEBUG: Background size: %s" % background_size)
	print("DEBUG: Walkable areas found: %d" % walkable_areas.size())
	
	# Set up CoordinateManager
	CoordinateManager.set_current_district(self)
	
	# Now set up the player using the district's method
	setup_player_and_controller(Vector2(960, 540))
	
	# Get reference to the player that was created
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("DEBUG: Player created at position: %s" % player.position)
	else:
		print("ERROR: Failed to create player!")
	
	# Create InputManager for this test
	# In the real game, GameManager would create this
	yield(setup_real_input_manager(), "completed")
	
	# Wait for everything to stabilize
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Run test scenarios
	yield(run_test_scenarios(), "completed")
	
	# Generate reports
	print_test_summary()
	
	# Exit with appropriate code
	get_tree().quit(tests_failed)

func create_test_background():
	"""Create a test background sprite"""
	var background = Sprite.new()
	background.name = "Background"
	
	# Create a simple test texture
	var image = Image.new()
	image.create(1920, 1080, false, Image.FORMAT_RGB8)
	image.fill(Color(0.3, 0.3, 0.3))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	background.texture = texture
	background.centered = false
	add_child(background)
	
	# Set background size for district
	background_size = Vector2(1920, 1080)

func create_test_walkable_areas():
	"""Create walkable areas for testing"""
	# Create Navigation2D for pathfinding first
	var nav = Navigation2D.new()
	nav.name = "Navigation2D"
	add_child(nav)
	
	# Create main walkable area
	var main_area = Polygon2D.new()
	main_area.name = "MainWalkableArea"
	main_area.polygon = PoolVector2Array([
		Vector2(100, 200),
		Vector2(1820, 200),
		Vector2(1820, 880),
		Vector2(100, 880)
	])
	main_area.color = Color(0.2, 0.5, 0.3, 0.3)
	main_area.add_to_group("walkable_area")
	
	# Add collision for proper detection
	var area2d = Area2D.new()
	area2d.name = "Area2D"
	area2d.collision_layer = 2
	area2d.collision_mask = 0
	main_area.add_child(area2d)
	
	var collision = CollisionPolygon2D.new()
	collision.name = "CollisionPolygon2D"
	collision.polygon = main_area.polygon
	area2d.add_child(collision)
	
	# Add directly to district
	add_child(main_area)
	
	# Create navigation polygon
	var nav_instance = NavigationPolygonInstance.new()
	var nav_poly = NavigationPolygon.new()
	nav_poly.add_outline(main_area.polygon)
	nav_poly.make_polygons_from_outlines()
	nav_instance.navpoly = nav_poly
	nav.add_child(nav_instance)
	
	print("Created walkable area with Navigation2D support")

func setup_real_input_manager():
	"""Create and set up the InputManager for testing"""
	# In a real game, GameManager would create this
	# For this subsystem test, we create it ourselves
	
	# First check if one already exists
	var input_managers = get_tree().get_nodes_in_group("input_manager")
	if input_managers.size() > 0:
		real_input_manager = input_managers[0]
		print("DEBUG: Found existing InputManager")
		return
	
	# Create InputManager
	var InputManagerScript = load("res://src/core/input/input_manager.gd")
	if InputManagerScript:
		real_input_manager = Node.new()
		real_input_manager.set_script(InputManagerScript)
		real_input_manager.name = "InputManager"
		# Add as sibling to this test scene (not to root which might be busy)
		get_parent().call_deferred("add_child", real_input_manager)
		print("DEBUG: Created InputManager for test")
		# Wait a frame for it to initialize
		yield(get_tree(), "idle_frame")
	else:
		print("ERROR: Could not load InputManager script")

func run_test_scenarios():
	log_section("Running Test Scenarios")
	
	if test_scenarios.click_refinements:
		yield(run_scenario("Click Detection Refinements", funcref(self, "test_click_refinements")), "completed")
	
	if test_scenarios.visual_feedback:
		yield(run_scenario("Visual Feedback System", funcref(self, "test_visual_feedback")), "completed")
	
	if test_scenarios.priority_system:
		yield(run_scenario("Click Priority System", funcref(self, "test_priority_system")), "completed")
	
	if test_scenarios.tolerance_perspective:
		yield(run_scenario("Tolerance & Perspective", funcref(self, "test_tolerance_perspective")), "completed")

# ===== TEST SCENARIOS =====

func test_click_refinements():
	"""Test new click detection refinements in InputManager"""
	
	start_test("input_manager_validation_methods")
	
	# Check if InputManager has new validation methods
	var has_validation = false
	if real_input_manager:
		has_validation = (
			real_input_manager.has_method("validate_click_position") or
			real_input_manager.has_method("validate_click") or
			real_input_manager.has_method("is_click_valid")
		)
	
	end_test(has_validation, "InputManager should have click validation methods")
	
	start_test("coordinate_validation_in_click_flow")
	
	# Test that clicks are properly validated
	# Since we can't easily simulate clicks in the real InputManager,
	# we check if the validation happens by looking at the code structure
	var uses_coordinate_validation = false
	if real_input_manager and real_input_manager.has_method("_handle_click"):
		# Check if it has the validation method we implemented
		uses_coordinate_validation = real_input_manager.has_method("validate_click_position")
	
	end_test(uses_coordinate_validation, "Click handling should validate coordinates before processing")
	
	# Add yield to make this function async
	yield(get_tree(), "idle_frame")

func test_visual_feedback():
	"""Test visual feedback system for clicks"""
	
	start_test("visual_feedback_system_exists")
	
	# Check if visual feedback system exists
	var feedback_exists = ResourceLoader.exists("res://src/ui/click_feedback/click_feedback_system.gd")
	
	end_test(feedback_exists, "Visual feedback system should be implemented")
	
	start_test("feedback_integration_with_clicks")
	
	# Check if feedback system is integrated with click handling
	var feedback_integrated = false
	if feedback_exists:
		# Would need to check if InputManager creates/uses feedback system
		feedback_integrated = real_input_manager and real_input_manager.get("click_feedback_system") != null
	
	end_test(feedback_integrated, "Visual feedback should be shown on clicks")
	
	# Add yield to make this function async
	yield(get_tree(), "idle_frame")

func test_priority_system():
	"""Test click priority system for overlapping areas"""
	
	start_test("priority_system_exists")
	
	# Check if priority system exists
	var priority_exists = ResourceLoader.exists("res://src/core/input/click_priority_system.gd")
	
	end_test(priority_exists, "Click priority system should be implemented")
	
	start_test("objects_over_movement_priority")
	
	# Test that interactive objects take priority over movement
	# This would require actual implementation to test properly
	var priority_correct = false
	if priority_exists and real_input_manager:
		# Check if InputManager has reference to priority system
		priority_correct = real_input_manager.get("click_priority_system") != null
	
	end_test(priority_correct, "Interactive objects should take priority over movement clicks")
	
	# Add yield to make this function async
	yield(get_tree(), "idle_frame")

func test_tolerance_perspective():
	"""Test click tolerance and perspective awareness"""
	
	start_test("click_tolerance_implementation")
	
	# Check if click validation includes tolerance
	var has_tolerance = false
	if CoordinateManager.has_method("validate_click_with_tolerance"):
		has_tolerance = true
	elif real_input_manager and real_input_manager.has_method("apply_click_tolerance"):
		has_tolerance = true
	
	end_test(has_tolerance, "Click validation should include tolerance for easier clicking")
	
	start_test("perspective_zoom_awareness")
	
	# Check if system accounts for camera zoom in click handling
	var has_zoom_awareness = false
	if CoordinateManager.has_method("adjust_click_for_perspective"):
		has_zoom_awareness = true
	elif CoordinateManager.has_method("adjust_for_zoom"):
		has_zoom_awareness = true
	
	end_test(has_zoom_awareness, "Click system should account for camera zoom and perspective")
	
	# Add yield to make this function async
	yield(get_tree(), "idle_frame")

# ===== HELPER METHODS =====

func run_scenario(scenario_name: String, test_func: FuncRef):
	current_scenario = scenario_name
	print("\n===== SCENARIO: %s =====" % scenario_name)
	yield(test_func.call_func(), "completed")

# ===== LOGGING METHODS =====

func log_section(title: String):
	print("\n--------------------------------------------------")
	print(" " + title)
	print("--------------------------------------------------")

func start_test(test_name: String):
	current_test = test_name
	test_start_time = OS.get_ticks_msec()
	print("\n[TEST] " + test_name)

func end_test(passed: bool, message: String):
	var duration = (OS.get_ticks_msec() - test_start_time) / 1000.0
	
	if passed:
		tests_passed += 1
		print("  ✓ PASS: %s (%.2fs)" % [message, duration])
	else:
		tests_failed += 1
		failed_tests.append(current_test)
		print("  ✗ FAIL: %s (%.2fs)" % [message, duration])

func print_test_summary():
	log_section("Test Summary")
	print("Tests Passed: %d" % tests_passed)
	print("Tests Failed: %d" % tests_failed)
	
	if tests_failed > 0:
		print("\nFailed Tests:")
		for test in failed_tests:
			print("  - " + test)
	
	print("\nMissing Components:")
	if not ResourceLoader.exists("res://src/ui/click_feedback/click_feedback_system.gd"):
		print("  - Visual Feedback System")
	if not ResourceLoader.exists("res://src/core/input/click_priority_system.gd"):
		print("  - Click Priority System")
	print("  - Click validation methods in InputManager")
	print("  - Tolerance implementation in coordinate validation")
	print("  - Perspective/zoom awareness in click handling")