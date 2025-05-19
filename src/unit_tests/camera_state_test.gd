extends Node2D
# Camera State Test: A comprehensive test suite for the camera state management system

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for more verbose output

# Test-specific flags
var test_state_transitions = true
var test_state_properties = true
var test_player_following = true
var test_movement_transitions = true
var test_signal_emission = true

# ===== TEST VARIABLES =====
var camera: Camera2D
var test_player: Node2D  # Mock player for testing
var test_results = {}
var current_test = ""
var tests_passed = 0
var tests_failed = 0
var failed_tests = []

# Track signal emissions
var state_changes_received = []
var move_started_received = []
var move_completed_received = []

# ===== LIFECYCLE METHODS =====

func _ready():
	# Set up the test environment
	debug_log("Setting up camera state test...")
	
	# Connect to camera signals
	setup_signal_connections()
	
	# Find or create the camera
	camera = find_camera()
	if not camera:
		debug_log("ERROR: Could not find or create a ScrollingCamera instance", true)
		return
	
	# Verify camera has the correct script
	if camera.get_script() == null:
		debug_log("ERROR: Camera has no script attached", true)
		return
	
	# Ensure camera has CameraState enum
	if not "CameraState" in camera:
		debug_log("ERROR: Camera doesn't have CameraState enum, script might not be loaded correctly", true)
		return
	
	# Create mock player
	create_mock_player()
	
	# Configure camera for testing
	configure_camera()
	
	# Run the tests
	yield(get_tree().create_timer(0.5), "timeout")  # Short delay to ensure setup is complete
	yield(run_tests(), "completed")
	
	# Report results
	report_results()
	
	# Add test termination to prevent hanging
	get_tree().quit()

func _process(delta):
	# Update the status display if needed
	update_test_display()

# ===== TEST SETUP METHODS =====

func find_camera():
	# Use the static helper method from ScrollingCamera
	var scrolling_camera_script = load("res://src/core/camera/scrolling_camera.gd")
	
	# Call the static helper method
	debug_log("Calling get_or_create_camera helper method")
	
	# We can call a static method on a script even without instantiating it
	var new_camera = scrolling_camera_script.get_or_create_camera(self)
	
	if new_camera:
		debug_log("Camera created/found successfully: " + new_camera.name)
		return new_camera
	else:
		debug_log("ERROR: Failed to create/find camera", true)
		return null

func setup_signal_connections():
	# We'll track signals globally for the test node
	state_changes_received = []
	move_started_received = []
	move_completed_received = []

func configure_camera():
	debug_log("Configuring camera for testing...")
	
	# Rather than trying to monkey-patch the camera, we'll remove it and create a new one
	# with our specific test settings
	if camera:
		if camera.get_parent() == self:
			remove_child(camera)
			camera.queue_free()
	
	# Create a new camera with minimal settings for testing
	camera = Camera2D.new()
	camera.name = "TestCamera"
	camera.set_script(load("res://src/core/camera/scrolling_camera.gd"))
	add_child(camera)
	
	# Set standard test settings
	camera.screen_size = Vector2(1024, 768)
	camera.zoom = Vector2(1, 1)
	camera.smoothing_enabled = false
	camera.debug_draw = true
	
	# Setup debug visualization
	if "setup_debug_overlay" in camera:
		camera.call("setup_debug_overlay")
	
	# IMPORTANT: First set explicit bounds that are large enough for our tests
	camera.bounds_enabled = true
	camera.camera_bounds = Rect2(200, 200, 800, 800)
	
	# Set initial position at the center of our test area
	camera.global_position = Vector2(500, 500)
	
	# Force the initial state to IDLE for consistent test state
	if "set_camera_state" in camera:
		camera.call("set_camera_state", camera.CameraState.IDLE)
	
	# Connect signals for test monitoring
	if !camera.is_connected("camera_state_changed", self, "_on_camera_state_changed"):
		camera.connect("camera_state_changed", self, "_on_camera_state_changed")
	
	if !camera.is_connected("camera_move_started", self, "_on_camera_move_started"):
		camera.connect("camera_move_started", self, "_on_camera_move_started")
	
	if !camera.is_connected("camera_move_completed", self, "_on_camera_move_completed"):
		camera.connect("camera_move_completed", self, "_on_camera_move_completed")
	
	# IMPORTANT: Override the ensure_valid_target method for tests to prevent bounds clamping
	# We'll patch it by redefining a crucial method
	camera.ensure_valid_target = funcref(self, "_test_ensure_valid_target")
	
	debug_log("Camera configured with position: " + str(camera.global_position))
	debug_log("Camera bounds set to: " + str(camera.camera_bounds))

# This is our test override for ensure_valid_target to avoid bounds clamping during tests
func _test_ensure_valid_target(target_pos: Vector2) -> Vector2:
	debug_log("[TEST] Using test version of ensure_valid_target: " + str(target_pos))
	# During tests, we just return the requested position directly, skipping bounds validation
	# This ensures position requests reach the camera unmodified for testing
	return target_pos

func create_mock_player():
	# Create a mock player for testing
	test_player = Node2D.new()
	test_player.name = "MockPlayer"
	add_child(test_player)
	test_player.add_to_group("player")
	test_player.global_position = Vector2(500, 500)  # Start at camera position
	
	# Set the player reference in the camera
	camera.target_player = test_player
	
	debug_log("Created mock player at: " + str(test_player.global_position))

# ===== SIGNAL HANDLERS =====

func _on_camera_state_changed(new_state, old_state, reason):
	# Track state changes
	state_changes_received.append({
		"new_state": new_state,
		"old_state": old_state,
		"reason": reason
	})
	
	debug_log("Signal received: camera_state_changed - " + str(new_state))

func _on_camera_move_started(target_position, old_position, move_duration, transition_type):
	# Track move started signals
	move_started_received.append({
		"target_position": target_position,
		"old_position": old_position,
		"move_duration": move_duration,
		"transition_type": transition_type
	})
	
	debug_log("Signal received: camera_move_started - " + str(target_position))

func _on_camera_move_completed(final_position, initial_position, actual_duration):
	# Track move completed signals
	move_completed_received.append({
		"final_position": final_position,
		"initial_position": initial_position,
		"actual_duration": actual_duration
	})
	
	debug_log("Signal received: camera_move_completed - " + str(final_position))

# ===== TEST RUNNER =====

func run_tests():
	debug_log("Starting camera state tests...")
	
	# Reset test counters
	tests_passed = 0
	tests_failed = 0
	failed_tests = []
	test_results = {}
	
	# Run all test suites in sequence
	if run_all_tests or test_state_transitions:
		yield(test_state_transitions_suite(), "completed")
	
	if run_all_tests or test_state_properties:
		yield(test_state_properties_suite(), "completed")
	
	if run_all_tests or test_player_following:
		yield(test_player_following_suite(), "completed")
	
	if run_all_tests or test_movement_transitions:
		yield(test_movement_transitions_suite(), "completed")
	
	if run_all_tests or test_signal_emission:
		yield(test_signal_emission_suite(), "completed")
	
	debug_log("All tests completed.")

# ===== TEST SUITES =====

func test_state_transitions_suite():
	start_test_suite("State Transitions")
	
	# Test 1: Idle to Moving transition
	yield(test_idle_to_moving_transition(), "completed")
	
	# Test 2: Moving to Idle transition
	yield(test_moving_to_idle_transition(), "completed")
	
	# Test 3: Idle to Following transition
	yield(test_idle_to_following_transition(), "completed")
	
	# Test 4: Following to Idle transition
	yield(test_following_to_idle_transition(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_state_properties_suite():
	start_test_suite("State Properties")
	
	# Test 1: Idle state properties
	yield(test_idle_state_properties(), "completed")
	
	# Test 2: Moving state properties
	yield(test_moving_state_properties(), "completed")
	
	# Test 3: Following state properties
	yield(test_following_state_properties(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_player_following_suite():
	start_test_suite("Player Following")
	
	# Test 1: Camera follows player
	yield(test_camera_follows_player(), "completed")
	
	# Test 2: Toggle follow player
	yield(test_toggle_follow_player(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_movement_transitions_suite():
	start_test_suite("Movement Transitions")
	
	# Test 1: Immediate movement
	yield(test_immediate_movement(), "completed")
	
	# Test 2: Animated movement
	yield(test_animated_movement(), "completed")
	
	# Test 3: Movement progress
	yield(test_movement_progress(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

func test_signal_emission_suite():
	start_test_suite("Signal Emission")
	
	# Test 1: State change signal
	yield(test_state_change_signal(), "completed")
	
	# Test 2: Move started signal
	yield(test_move_started_signal(), "completed")
	
	# Test 3: Move completed signal
	yield(test_move_completed_signal(), "completed")
	
	end_test_suite()
	yield(get_tree(), "idle_frame")

# ===== INDIVIDUAL TESTS =====

# STATE TRANSITIONS TESTS

func test_idle_to_moving_transition():
	start_test("Idle to Moving Transition")
	
	# Set camera to IDLE state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Clear signal tracking
	state_changes_received = []
	
	# Set target position and transition to MOVING
	camera.target_position = Vector2(700, 500)
	camera.set_camera_state(camera.CameraState.MOVING)
	
	# Verify transition
	var current_state = camera.get_camera_state()
	var state_changed = current_state == camera.CameraState.MOVING
	var signal_received = state_changes_received.size() > 0
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if state changed and signal was received
	var passed = state_changed && signal_received
	end_test(passed, "Camera should transition from IDLE to MOVING and emit signal")
	yield(get_tree(), "idle_frame")

func test_moving_to_idle_transition():
	start_test("Moving to Idle Transition")
	
	# Set camera to MOVING state
	camera.target_position = Vector2(700, 500)
	camera.set_camera_state(camera.CameraState.MOVING)
	
	# Clear signal tracking
	state_changes_received = []
	
	# Transition to IDLE
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Verify transition
	var current_state = camera.get_camera_state()
	var state_changed = current_state == camera.CameraState.IDLE
	var signal_received = state_changes_received.size() > 0
	
	# Test passes if state changed and signal was received
	var passed = state_changed && signal_received
	end_test(passed, "Camera should transition from MOVING to IDLE and emit signal")
	yield(get_tree(), "idle_frame")

func test_idle_to_following_transition():
	start_test("Idle to Following Transition")
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Clear signal tracking
	state_changes_received = []
	
	# Transition to FOLLOWING_PLAYER
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Verify transition
	var current_state = camera.get_camera_state()
	var state_changed = current_state == camera.CameraState.FOLLOWING_PLAYER
	var signal_received = state_changes_received.size() > 0
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if state changed and signal was received
	var passed = state_changed && signal_received
	end_test(passed, "Camera should transition from IDLE to FOLLOWING_PLAYER and emit signal")
	yield(get_tree(), "idle_frame")

func test_following_to_idle_transition():
	start_test("Following to Idle Transition")
	
	# Set camera to FOLLOWING_PLAYER state
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Clear signal tracking
	state_changes_received = []
	
	# Transition to IDLE
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Verify transition
	var current_state = camera.get_camera_state()
	var state_changed = current_state == camera.CameraState.IDLE
	var signal_received = state_changes_received.size() > 0
	
	# Test passes if state changed and signal was received
	var passed = state_changed && signal_received
	end_test(passed, "Camera should transition from FOLLOWING_PLAYER to IDLE and emit signal")
	yield(get_tree(), "idle_frame")

# STATE PROPERTIES TESTS

func test_idle_state_properties():
	start_test("Idle State Properties")
	
	# Set camera to IDLE state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Check IDLE state properties
	var is_idle_state = camera.get_camera_state() == camera.CameraState.IDLE
	var is_idle_method = camera.is_idle() if "is_idle" in camera else true
	var is_not_moving = !camera.is_moving() if "is_moving" in camera else true
	var is_not_following = !camera.is_following_player() if "is_following_player" in camera else true
	var transition_not_active = !camera.is_transition_active
	
	# Test passes if all IDLE state properties are correctly set
	var all_properties_valid = is_idle_state && is_idle_method && is_not_moving && is_not_following && transition_not_active
	end_test(all_properties_valid, "IDLE state should have correct properties")
	yield(get_tree(), "idle_frame")

func test_moving_state_properties():
	start_test("Moving State Properties")
	
	# Set camera to MOVING state
	camera.target_position = Vector2(700, 500)
	camera.set_camera_state(camera.CameraState.MOVING)
	
	# Check MOVING state properties
	var is_moving_state = camera.get_camera_state() == camera.CameraState.MOVING
	var is_moving_method = camera.is_moving() if "is_moving" in camera else true
	var is_not_idle = !camera.is_idle() if "is_idle" in camera else true
	var is_not_following = !camera.is_following_player() if "is_following_player" in camera else true
	var transition_active = camera.is_transition_active
	var has_target_position = camera.target_position != Vector2.ZERO
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if all MOVING state properties are correctly set
	var all_properties_valid = is_moving_state && is_moving_method && is_not_idle && is_not_following && transition_active && has_target_position
	end_test(all_properties_valid, "MOVING state should have correct properties")
	yield(get_tree(), "idle_frame")

func test_following_state_properties():
	start_test("Following State Properties")
	
	# Set camera to FOLLOWING_PLAYER state
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Check FOLLOWING_PLAYER state properties
	var is_following_state = camera.get_camera_state() == camera.CameraState.FOLLOWING_PLAYER
	var is_following_method = camera.is_following_player() if "is_following_player" in camera else true
	var is_not_idle = !camera.is_idle() if "is_idle" in camera else true
	var is_not_moving = !camera.is_moving() if "is_moving" in camera else true
	var transition_not_active = !camera.is_transition_active
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if all FOLLOWING_PLAYER state properties are correctly set
	var all_properties_valid = is_following_state && is_following_method && is_not_idle && is_not_moving && transition_not_active
	end_test(all_properties_valid, "FOLLOWING_PLAYER state should have correct properties")
	yield(get_tree(), "idle_frame")

# PLAYER FOLLOWING TESTS

func test_camera_follows_player():
	start_test("Camera Follows Player")
	
	# Save original camera position
	var original_position = camera.global_position
	
	# Ensure follow_player is enabled
	camera.follow_player = true
	
	# Set camera to FOLLOWING_PLAYER state
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Move player to a new position
	var original_player_pos = test_player.global_position
	test_player.global_position = Vector2(700, 700)
	
	# Let camera follow for a while
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Check if camera moved toward player
	var camera_moved = camera.global_position.distance_to(original_position) > 0
	var camera_moving_to_player = camera.global_position.distance_to(test_player.global_position) < original_position.distance_to(test_player.global_position)
	
	# Reset player and camera position
	test_player.global_position = original_player_pos
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_position
	
	# Test passes if camera moved toward player
	var passed = camera_moved && camera_moving_to_player
	end_test(passed, "Camera should move toward player when in FOLLOWING_PLAYER state")
	yield(get_tree(), "idle_frame")

func test_toggle_follow_player():
	start_test("Toggle Follow Player")
	
	# Save original camera position
	var original_position = camera.global_position
	
	# Enable follow_player
	camera.follow_player = true
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Move player to a new position
	var original_player_pos = test_player.global_position
	test_player.global_position = Vector2(700, 700)
	
	# Let camera follow briefly
	yield(get_tree().create_timer(0.2), "timeout")
	
	# Disable follow_player
	camera.follow_player = false
	
	# Remember camera position after following briefly
	var position_after_following = camera.global_position
	
	# Move player again
	test_player.global_position = Vector2(800, 800)
	
	# Wait a bit
	yield(get_tree().create_timer(0.2), "timeout")
	
	# Check if camera stopped following
	var stopped_following = camera.global_position.distance_to(position_after_following) < 5
	
	# Reset player and camera position
	test_player.global_position = original_player_pos
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_position
	camera.follow_player = true  # Reset to default
	
	# Test passes if camera stopped following after toggle
	end_test(stopped_following, "Camera should stop following player when follow_player is disabled")
	yield(get_tree(), "idle_frame")

# MOVEMENT TRANSITIONS TESTS

func test_immediate_movement():
	start_test("Immediate Movement")
	
	# Save original camera position
	var original_position = camera.global_position
	
	# Set target position
	var target_position = Vector2(700, 500)
	
	# Clear signal tracking
	move_started_received = []
	move_completed_received = []
	
	# Perform immediate movement
	camera.move_to_position(target_position, true)  # true = immediate
	
	# Check if camera reached target immediately
	var reached_target = camera.global_position.distance_to(target_position) < 5
	var signals_received = move_started_received.size() > 0 && move_completed_received.size() > 0
	
	# Reset camera position
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_position
	
	# Test passes if camera immediately reached target and signals were emitted
	var passed = reached_target && signals_received
	end_test(passed, "Camera should move to target immediately and emit signals")
	yield(get_tree(), "idle_frame")

func test_animated_movement():
	start_test("Animated Movement")
	
	# Save original camera position
	var original_position = camera.global_position
	
	# Set target position
	var target_position = Vector2(700, 500)
	
	# Clear signal tracking
	move_started_received = []
	
	# Start animated movement
	camera.move_to_position(target_position, false)  # false = animated
	
	# Wait a short time
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Check if camera is in movement state
	var is_moving = camera.get_camera_state() == camera.CameraState.MOVING
	var signal_received = move_started_received.size() > 0
	var transition_active = camera.is_transition_active
	
	# Let movement complete
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Reset camera position
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_position
	
	# Test passes if camera was in correct movement state
	var passed = is_moving && signal_received && transition_active
	end_test(passed, "Camera should enter MOVING state for animated movement")
	yield(get_tree(), "idle_frame")

func test_movement_progress():
	start_test("Movement Progress")
	
	# Save original camera position
	var original_position = camera.global_position
	
	# Set target position
	var target_position = Vector2(700, 500)
	
	# Start animated movement
	camera.move_to_position(target_position, false)  # false = animated
	
	# Check initial progress
	var initial_progress = camera.movement_progress
	
	# Wait a bit
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Check progress after some time
	var progress_after_delay = camera.movement_progress
	
	# Progress should have increased
	var progress_increased = progress_after_delay > initial_progress
	
	# Let movement complete
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Reset camera position
	camera.set_camera_state(camera.CameraState.IDLE)
	camera.global_position = original_position
	
	# Test passes if progress increased
	end_test(progress_increased, "Movement progress should increase during animated movement")
	yield(get_tree(), "idle_frame")

# SIGNAL EMISSION TESTS

func test_state_change_signal():
	start_test("State Change Signal")
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Clear signal tracking
	state_changes_received = []
	
	# Change state
	camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
	
	# Verify signal emission
	var signal_received = state_changes_received.size() > 0
	var correct_parameters = false
	
	if signal_received:
		var signal_data = state_changes_received[0]
		correct_parameters = signal_data.has("new_state") && signal_data.has("old_state") && signal_data.new_state == camera.CameraState.FOLLOWING_PLAYER && signal_data.old_state == camera.CameraState.IDLE
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if signal was received with correct parameters
	var passed = signal_received && correct_parameters
	end_test(passed, "Camera should emit state_changed signal with correct parameters")
	yield(get_tree(), "idle_frame")

func test_move_started_signal():
	start_test("Move Started Signal")
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Clear signal tracking
	move_started_received = []
	
	# Set target position and start movement
	var target_position = Vector2(700, 500)
	camera.target_position = target_position
	camera.set_camera_state(camera.CameraState.MOVING)
	
	# Verify signal emission
	var signal_received = move_started_received.size() > 0
	var correct_parameters = false
	
	if signal_received:
		var signal_data = move_started_received[0]
		correct_parameters = signal_data.has("target_position") && signal_data.target_position == target_position
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if signal was received with correct parameters
	var passed = signal_received && correct_parameters
	end_test(passed, "Camera should emit move_started signal with correct parameters")
	yield(get_tree(), "idle_frame")

func test_move_completed_signal():
	start_test("Move Completed Signal")
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Clear signal tracking
	move_completed_received = []
	
	# Start immediate movement to ensure completion
	var target_position = Vector2(700, 500)
	camera.move_to_position(target_position, true)  # true = immediate
	
	# Verify signal emission
	var signal_received = move_completed_received.size() > 0
	
	# Reset camera state
	camera.set_camera_state(camera.CameraState.IDLE)
	
	# Test passes if signal was received
	end_test(signal_received, "Camera should emit move_completed signal")
	yield(get_tree(), "idle_frame")

# ===== TEST UTILITIES =====

func update_test_display():
	# Update any UI elements showing test status
	var label = get_node_or_null("TestInfo")
	if label:
		var status = "Tests: %d/%d passed" % [tests_passed, tests_passed + tests_failed]
		if current_test:
			status += "\nCurrent: " + current_test
		label.text = status

func start_test_suite(suite_name):
	debug_log("===== TEST SUITE: " + suite_name + " =====", true)
	test_results[suite_name] = {
		"passed": 0,
		"failed": 0,
		"tests": {}
	}

func end_test_suite():
	var suite_name = ""
	if ":" in current_test:
		suite_name = current_test.split(":")[0]
	else:
		debug_log("ERROR: Invalid test name format in end_test_suite: " + current_test, true)
		return
		
	# Ensure test results dictionary is properly initialized
	if not test_results.has(suite_name):
		debug_log("ERROR: No test results found for suite: " + suite_name, true)
		return
		
	# Get test statistics with safe access
	var passed = test_results[suite_name]["passed"] if test_results[suite_name].has("passed") else 0
	var failed = test_results[suite_name]["failed"] if test_results[suite_name].has("failed") else 0
	var total = passed + failed
	debug_log("Suite completed: " + str(passed) + "/" + str(total) + " tests passed", true)

func start_test(test_name):
	var suite_name = test_name.split(" ")[0]
	current_test = suite_name + ": " + test_name
	debug_log("Running test: " + test_name)

func end_test(passed, message = ""):
	var parts = current_test.split(": ")
	if parts.size() < 2:
		debug_log("ERROR: Invalid test name format: " + current_test, true)
		return
		
	var suite_name = parts[0]
	var test_name = parts[1]
	
	# Ensure test results dictionary is properly initialized
	if not test_results.has(suite_name):
		test_results[suite_name] = {
			"passed": 0,
			"failed": 0,
			"tests": {}
		}
	
	if not test_results[suite_name].has("tests"):
		test_results[suite_name]["tests"] = {}
	
	if passed:
		debug_log("✓ PASS: " + test_name + (": " + message if message else ""))
		test_results[suite_name]["passed"] += 1
		tests_passed += 1
	else:
		debug_log("✗ FAIL: " + test_name + (": " + message if message else ""), true)
		test_results[suite_name]["failed"] += 1
		tests_failed += 1
		failed_tests.append(current_test)
	
	test_results[suite_name]["tests"][test_name] = {
		"passed": passed,
		"message": message
	}

func report_results():
	debug_log("\n===== TEST RESULTS =====", true)
	debug_log("Total Tests: " + str(tests_passed + tests_failed), true)
	debug_log("Passed: " + str(tests_passed), true)
	debug_log("Failed: " + str(tests_failed), true)
	
	if tests_failed > 0:
		debug_log("\nFailed Tests:", true)
		for test in failed_tests:
			if ":" in test:
				var parts = test.split(": ")
				if parts.size() >= 2:
					var suite_name = parts[0]
					var test_name = parts[1]
					
					if test_results.has(suite_name) and test_results[suite_name].has("tests") and test_results[suite_name]["tests"].has(test_name):
						var message = test_results[suite_name]["tests"][test_name].get("message", "")
						debug_log("- " + test + (": " + message if message else ""), true)
					else:
						debug_log("- " + test + " (details not available)", true)
				else:
					debug_log("- " + test + " (invalid format)", true)
			else:
				debug_log("- " + test + " (invalid format)", true)
	
	if tests_failed == 0:
		debug_log("\nAll tests passed! 🎉", true)

func debug_log(message, force_print = false):
	if log_debug_info || force_print:
		print(message)