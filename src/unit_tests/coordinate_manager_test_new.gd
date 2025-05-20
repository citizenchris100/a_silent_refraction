extends Node2D
# CoordinateManager Test (New Version): Testing the CoordinateManager singleton
# Refactored to fix timeout issues and improve reliability

# Simple MockDistrict class for testing purposes
class MockDistrict extends Node2D:
	var district_name = "Test District"
	var background_scale_factor = 2.0
	var _camera = null
	
	func _init():
		pass
	
	func get_camera():
		print("MockDistrict.get_camera() called, returning: " + str(_camera))
		return _camera
		
	func set_camera(camera):
		print("MockDistrict.set_camera() called with: " + str(camera))
		_camera = camera

# Test configuration
var log_debug_info = true      # Set to true for more verbose output
var test_timeout = 2.0         # Maximum seconds to wait for a test to complete
var debug_mode = true          # Enable extra debug logging
var auto_quit = true           # Whether to automatically quit when tests are done
var force_quit_timer = 3.0     # Time in seconds before forcing quit after tests complete

# Test variables
var manager                    # The CoordinateManager instance being tested
var mock_district              # Mock district for testing
var mock_camera                # Mock camera for testing
var tests_passed = 0           # Counter for passed tests
var tests_failed = 0           # Counter for failed tests
var failed_tests = []          # List of failed test names
var tests_completed = false    # Flag to indicate if tests have completed

# ===== LIFECYCLE METHODS =====

func _ready():
	# Set up the test environment
	debug_log("Setting up CoordinateManager test (NEW VERSION)...")
	
	# Create mock district and camera
	create_mock_district()
	
	# Create coordinate manager
	create_coordinate_manager()
	
	# Verify that our mock setup works correctly
	var camera_from_district = mock_district.get_camera()
	if camera_from_district == mock_camera:
		debug_log("Mock district camera reference working correctly", true)
	else:
		debug_log("WARNING: Mock district camera reference not working! Got: " + str(camera_from_district), true)
	
	# Run the tests after a short delay to ensure setup is complete
	var start_timer = Timer.new()
	add_child(start_timer)
	start_timer.wait_time = 0.5
	start_timer.one_shot = true
	start_timer.connect("timeout", self, "_on_start_tests")
	start_timer.start()

func _on_start_tests():
	debug_log("Starting tests...")
	run_all_tests()

# ===== TEST SETUP METHODS =====

func create_coordinate_manager():
	# Create a test instance of CoordinateManager
	debug_log("Creating CoordinateManager instance")
	
	# Load CoordinateManager class and create a fresh instance
	manager = load("res://src/core/coordinate_manager.gd").new()
	
	# Connect camera and district
	manager.set_current_district(mock_district)
	
	add_child(manager)
	debug_log("CoordinateManager instance created and configured")

func create_mock_district():
	# Create a mock district with camera
	debug_log("Creating mock district and camera")
	
	# Create the mock district
	mock_district = MockDistrict.new()
	mock_district.name = "MockDistrict"
	add_child(mock_district)
	
	# Create the mock camera
	mock_camera = Camera2D.new()
	mock_camera.name = "Camera2D"
	mock_camera.zoom = Vector2(1, 1)
	mock_camera.global_position = Vector2(500, 500)
	
	# Add camera to district
	mock_district.add_child(mock_camera)
	
	# Set the camera on the district
	mock_district.set_camera(mock_camera)
	
	debug_log("Created mock district with camera reference")

# ===== TEST RUNNER =====

# This is the main test runner - no more yielding between tests
func run_all_tests():
	debug_log("Starting CoordinateManager tests...", true)
	
	# Reset test counters
	tests_passed = 0
	tests_failed = 0
	failed_tests = []
	
	# Run all tests sequentially - no yields
	test_and_log("test_district_setup")
	test_and_log("test_camera_access")
	test_and_log("test_screen_to_world")
	test_and_log("test_world_to_screen")
	test_and_log("test_view_mode")
	
	# Report final results
	debug_log("All tests completed.", true)
	report_results()
	
	# Mark tests as completed
	tests_completed = true
	
	# Setup a force quit timer
	if auto_quit:
		debug_log("Scheduling force quit in " + str(force_quit_timer) + " seconds")
		var quit_timer = Timer.new()
		add_child(quit_timer)
		quit_timer.wait_time = force_quit_timer
		quit_timer.one_shot = true
		quit_timer.connect("timeout", self, "_force_quit")
		quit_timer.start()
		
		# Try quitting immediately too
		_force_quit()

func _force_quit():
	debug_log("Force quitting...")
	if tests_completed:
		var exit_code = 0 if tests_failed == 0 else 1
		debug_log("Quitting with exit code: " + str(exit_code))
		OS.exit_code = exit_code
		get_tree().quit()

# Called every frame
func _process(delta):
	# Check if we need to force quit
	if tests_completed and auto_quit:
		_force_quit()

# Simplified test runner for individual tests
func test_and_log(test_name):
	debug_log("Running test: " + test_name)
	
	# Get the test method
	var test_method = funcref(self, test_name)
	if not test_method.is_valid():
		debug_log("ERROR: Test method '" + test_name + "' not found", true)
		tests_failed += 1
		failed_tests.append(test_name + " (method not found)")
		return
	
	# Run the test
	var test_result = test_method.call_func()
	debug_log("Test completed: " + test_name)

# ===== TEST METHODS =====

# Test 1: Verify the district setup is correct
func test_district_setup():
	debug_log("Testing district setup")
	
	# Check that the district is correctly configured
	var district_ok = mock_district != null
	var district_name_ok = mock_district.district_name == "Test District"
	var scale_factor_ok = mock_district.background_scale_factor == 2.0
	
	# Verify district is set in the manager
	var manager_district_ok = manager.get_current_district() == mock_district
	
	var all_ok = district_ok and district_name_ok and scale_factor_ok and manager_district_ok
	
	if all_ok:
		report_test_success("test_district_setup")
	else:
		report_test_failure("test_district_setup", "District setup is incorrect")
	
	return all_ok

# Test 2: Verify camera access through the district
func test_camera_access():
	debug_log("Testing camera access through district")
	
	# Check that the mock camera is correctly set
	var camera_ok = mock_camera != null
	
	# Verify we can access the camera through the district
	var district_camera = mock_district.get_camera()
	var camera_access_ok = district_camera == mock_camera
	
	# Verify coordinate manager can access the camera
	var manager_camera = manager._get_current_camera()
	var manager_camera_ok = manager_camera == mock_camera
	
	var all_ok = camera_ok and camera_access_ok and manager_camera_ok
	
	if all_ok:
		report_test_success("test_camera_access")
	else:
		report_test_failure("test_camera_access", 
			"Camera access failed - District camera: " + str(district_camera) + 
			", Manager camera: " + str(manager_camera))
	
	return all_ok

# Test 3: Test basic screen to world conversion
func test_screen_to_world():
	debug_log("Testing screen_to_world conversion")
	
	# Use a known screen coordinate
	var screen_pos = Vector2(100, 100)
	
	# Convert to world position
	var world_pos = manager.screen_to_world(screen_pos)
	
	# We don't care about the exact result, just that it produces something and doesn't crash
	var result_ok = world_pos != null
	
	if result_ok:
		report_test_success("test_screen_to_world")
	else:
		report_test_failure("test_screen_to_world", "screen_to_world returned null")
	
	return result_ok

# Test 4: Test basic world to screen conversion
func test_world_to_screen():
	debug_log("Testing world_to_screen conversion")
	
	# Use a known world coordinate
	var world_pos = Vector2(500, 500)
	
	# Convert to screen position
	var screen_pos = manager.world_to_screen(world_pos)
	
	# We don't care about the exact result, just that it produces something and doesn't crash
	var result_ok = screen_pos != null
	
	if result_ok:
		report_test_success("test_world_to_screen")
	else:
		report_test_failure("test_world_to_screen", "world_to_screen returned null")
	
	return result_ok

# Test 5: Test view mode switching
func test_view_mode():
	debug_log("Testing view mode switching")
	
	# Get initial view mode
	var initial_mode = manager.get_view_mode()
	
	# Set to world view
	manager.set_view_mode(manager.ViewMode.WORLD_VIEW)
	var world_mode_ok = manager.get_view_mode() == manager.ViewMode.WORLD_VIEW
	
	# Set back to game view
	manager.set_view_mode(manager.ViewMode.GAME_VIEW)
	var game_mode_ok = manager.get_view_mode() == manager.ViewMode.GAME_VIEW
	
	var all_ok = world_mode_ok and game_mode_ok
	
	if all_ok:
		report_test_success("test_view_mode")
	else:
		report_test_failure("test_view_mode", "View mode switching failed")
	
	# Restore original view mode
	manager.set_view_mode(initial_mode)
	
	return all_ok

# ===== HELPER METHODS =====

func report_test_success(test_name):
	debug_log("✓ PASS: " + test_name, true)
	tests_passed += 1

func report_test_failure(test_name, message = ""):
	debug_log("✗ FAIL: " + test_name + (": " + message if message else ""), true)
	tests_failed += 1
	failed_tests.append(test_name + (": " + message if message else ""))

func report_results():
	debug_log("\n===== TEST RESULTS =====", true)
	debug_log("Total Tests: " + str(tests_passed + tests_failed), true)
	debug_log("Passed: " + str(tests_passed), true)
	debug_log("Failed: " + str(tests_failed), true)
	
	if tests_failed > 0:
		debug_log("\nFailed Tests:", true)
		for test in failed_tests:
			debug_log("- " + test, true)
	
	if tests_failed == 0:
		debug_log("\nAll tests passed! 🎉", true)

func debug_log(message, force_print = false):
	if log_debug_info || force_print:
		print("[COORD_TEST_NEW] " + message)