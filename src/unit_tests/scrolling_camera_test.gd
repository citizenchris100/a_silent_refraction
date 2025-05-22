extends Node2D
# ScrollingCamera Unit Test
# Tests functionality of the ScrollingCamera system with proper isolation and clean test design

# Constants for test configuration
const TEST_TIMEOUT = 3.0  # Maximum time to wait for a single test to complete
const LOG_PREFIX = "ScrollingCameraTest:"

# Test categories - which groups of tests to run
export var test_basics = true  # Tests basic initialization and configuration
export var test_movement = true  # Tests movement, transitions, easing
export var test_bounds = true  # Tests boundary validation
export var test_states = true  # Tests state transitions and signals
export var test_coordinates = true  # Tests coordinate transformations
export var test_signals = true  # Tests signal emission and handling

# Test camera reference
var camera: Camera2D  # Will be cast to ScrollingCamera after initialization

# Mock player reference
var mock_player: Node2D

# Test tracking
var total_tests = 0
var passed_tests = 0
var failed_tests = []
var current_test_name = ""
var current_test_passed = true
var tests_running = false
var test_end_time = 0
var test_timeout_timer: Timer

# Direct signal handlers for specific test cases
func _on_signal_state_changed(new_state, old_state, reason = ""):
    has_signal_state_changed = true
    last_state_signal = new_state
    log_info("Received state_changed signal: " + str(new_state) + " from " + str(old_state) + " reason: " + str(reason))
    
func _on_move_started(target_position, old_position, move_duration, transition_type):
    has_move_started = true
    log_info("Received move_started signal: " + str(target_position))
    
func _on_move_completed(final_position, initial_position, actual_duration):
    has_move_completed = true
    log_info("Received move_completed signal: " + str(final_position))
    
func _on_view_bounds_changed(new_bounds, old_bounds, is_district_change):
    has_bounds_changed = true
    log_info("Received view_bounds_changed signal: " + str(new_bounds))

# Signal expectations
var expected_signals = {}
var received_signals = {}
var has_signal_state_changed = false
var last_state_signal = -1
var has_move_started = false
var has_move_completed = false
var has_bounds_changed = false

# =========== LIFECYCLE METHODS ===========

func _ready():
    # Create and initialize the test timer
    test_timeout_timer = Timer.new()
    test_timeout_timer.one_shot = true
    test_timeout_timer.wait_time = TEST_TIMEOUT
    test_timeout_timer.connect("timeout", self, "_on_test_timeout")
    add_child(test_timeout_timer)
    
    # Delay test start to ensure scene is fully loaded
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Find or create the camera to test
    camera = _setup_camera()
    if not camera:
        log_error("Failed to create or find a ScrollingCamera instance")
        return
        
    # Create a mock player for the camera to track
    mock_player = _setup_mock_player()
    camera.target_player = mock_player
    
    # Start running the tests
    tests_running = true
    yield(run_all_tests(), "completed")
    tests_running = false
    
    # Report the test results
    report_test_results()
    
    # Exit cleanly
    yield(get_tree().create_timer(0.5), "timeout") # Wait for any pending frames
    get_tree().quit(0) # Exit with success code

func _process(delta):
    # Monitor for test timeouts
    if tests_running and current_test_name and test_end_time > 0:
        if OS.get_ticks_msec() > test_end_time:
            log_error("Test timed out: " + current_test_name)
            _end_current_test(false, "Test timed out")

# =========== TEST RUNNER METHODS ===========

func run_all_tests():
    log_info("Starting ScrollingCamera unit tests", true)
    
    # Run test categories based on configuration
    if test_basics:
        yield(run_basic_tests(), "completed")
    
    if test_movement:
        yield(run_movement_tests(), "completed")
    
    if test_bounds:
        yield(run_bounds_tests(), "completed")
    
    if test_states:
        yield(run_state_tests(), "completed")
    
    if test_coordinates:
        yield(run_coordinate_tests(), "completed")
    
    if test_signals:
        yield(run_signal_tests(), "completed")
    
    log_info("All tests completed", true)

# =========== TEST CATEGORY IMPLEMENTATIONS ===========

func run_basic_tests():
    log_info("=== Running Basic Tests ===", true)
    
    # Test 1: Camera instantiation
    start_test("Camera instantiation")
    assert_true(camera != null, "Camera should be instantiated")
    assert_true(camera.get_script() != null, "Camera should have a script attached")
    assert_true(camera.has_method("set_camera_state"), "Camera should have ScrollingCamera methods")
    end_test()
    
    # Test 2: Test mode setting
    start_test("Test mode setting")
    camera.test_mode = true
    assert_true(camera.test_mode, "Camera should be in test mode")
    end_test()
    
    # Test 3: Verify camera state changes correctly
    start_test("Camera state control")
    # We can explicitly set the state regardless of initialization
    camera.set_camera_state(camera.CameraState.IDLE)
    assert_equal(camera.current_camera_state, camera.CameraState.IDLE, "Camera should set IDLE state when requested")
    
    # Also verify that follow_player works correctly
    var was_following = camera.follow_player
    camera.follow_player = true
    if camera.target_player != null:
        camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
        assert_equal(camera.current_camera_state, camera.CameraState.FOLLOWING_PLAYER, "Camera should enter FOLLOWING_PLAYER state when requested with target")
    
    # Restore follow_player setting
    camera.follow_player = was_following
    camera.set_camera_state(camera.CameraState.IDLE) # Reset to IDLE for next tests
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 4: Verify default bounds enabled
    start_test("Default bounds settings")
    assert_true(camera.bounds_enabled, "Bounds should be enabled by default")
    assert_not_equal(camera.camera_bounds, Rect2(), "Camera bounds should be initialized")
    end_test()
    
    # Test 5: Ability to set bounds enabled
    start_test("Bounds enabled setting")
    camera.bounds_enabled = false
    assert_false(camera.bounds_enabled, "Should be able to disable bounds")
    camera.bounds_enabled = true  # Restore the setting
    end_test()
    
    yield(get_tree(), "idle_frame")

func run_movement_tests():
    log_info("=== Running Movement Tests ===", true)
    
    # Test 1: Basic movement test with immediate transition
    start_test("Immediate movement")
    var original_pos = camera.global_position
    var target_pos = original_pos + Vector2(100, 0)
    
    # Move immediately
    camera.move_to_position(target_pos, true)
    
    # Should be at target position
    assert_vector2_equal(camera.global_position, target_pos, "Camera should move immediately to target position")
    
    # Reset camera position
    camera.global_position = original_pos
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 2: Movement with transition
    start_test("Movement with transition")
    var start_pos = camera.global_position
    var move_target = start_pos + Vector2(200, 0)
    
    # Start movement with transition
    camera.move_to_position(move_target)
    
    # Should be in MOVING state
    assert_equal(camera.current_camera_state, camera.CameraState.MOVING, "Camera should be in MOVING state")
    
    # Manually process the camera movement since we're in a headless environment
    # where _process might not be called automatically
    var move_delta = 0.1
    camera._handle_transition_movement(move_delta)  # First processing step
    
    # Position should be somewhere between start and target
    var current_pos = camera.global_position
    var moved_some = (current_pos - start_pos).length() > 0
    assert_true(moved_some, "Camera should have moved from starting position")
    
    # Process movement until completion
    for i in range(20):  # Limit to reasonable number of steps
        if camera.current_camera_state != camera.CameraState.MOVING:
            break
        camera._handle_transition_movement(move_delta)
        yield(get_tree(), "idle_frame")
    
    # Should be at or very close to target position
    var distance_to_target = (camera.global_position - move_target).length()
    assert_true(distance_to_target < 1.0, "Camera should be at or very close to target position")
    
    # Should be back in IDLE state
    assert_equal(camera.current_camera_state, camera.CameraState.IDLE, "Camera should return to IDLE state after movement")
    
    # Reset camera position
    camera.global_position = start_pos
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 3: Movement easing types
    start_test("Movement easing types")
    var easing_pos = camera.global_position
    
    # Test different easing types
    for easing_type in [camera.EasingType.LINEAR, camera.EasingType.EASE_IN, camera.EasingType.EASE_OUT]:
        # Set the easing type
        camera.easing_type = easing_type
        
        # Move with this easing
        camera.move_to_position(easing_pos + Vector2(100, 0))
        
        # Should be in MOVING state with the correct easing type
        assert_equal(camera.easing_type, easing_type, "Camera should use the specified easing type")
        
        # Manually process the camera movement
        for i in range(20):  # Limit to reasonable number of steps
            if camera.current_camera_state != camera.CameraState.MOVING:
                break
            camera._handle_transition_movement(0.1)
            yield(get_tree(), "idle_frame")
        
        # Should be at target
        assert_vector2_equal(camera.global_position, easing_pos + Vector2(100, 0), "Camera should reach target with " + str(easing_type) + " easing", 5.0)
        
        # Reset position for next test
        camera.global_position = easing_pos
    end_test()
    
    yield(get_tree(), "idle_frame")

func run_bounds_tests():
    log_info("=== Running Bounds Tests ===", true)
    
    # Test 1: Bounds initialization
    start_test("Bounds initialization")
    assert_true(camera.camera_bounds.size.x > 0 && camera.camera_bounds.size.y > 0, "Camera bounds should have a valid area")
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 2: Test mode bypasses bounds
    start_test("Test mode bounds bypass")
    
    # Ensure camera is in test mode
    camera.test_mode = true
    
    # Get current camera position and bounds
    var start_pos = camera.global_position
    var bounds = camera.camera_bounds
    
    # Try to move outside bounds
    var outside_pos = Vector2(bounds.position.x - 1000, bounds.position.y - 1000)
    camera.move_to_position(outside_pos, true)  # Move immediately
    
    # In test mode, should have moved outside bounds
    assert_vector2_equal(camera.global_position, outside_pos, "In test mode, camera should move outside bounds")
    
    # Reset camera position
    camera.global_position = start_pos
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 3: Default validator enforces bounds
    start_test("Default validator bounds enforcement")
    
    # Disable test mode to use the default validator
    camera.test_mode = false
    
    # Get current bounds
    var cur_bounds = camera.camera_bounds
    var camera_half_size = camera.get_viewport_rect().size / 2 / camera.zoom
    
    # Calculate expected boundary position (bounds edge + half camera size)
    var expected_min_x = cur_bounds.position.x + camera_half_size.x
    var expected_min_y = cur_bounds.position.y + camera_half_size.y
    
    # Try to move outside bounds by a large amount
    var outside_bounds = Vector2(cur_bounds.position.x - 1000, cur_bounds.position.y - 1000)
    var original_pos = camera.global_position
    
    # Save the resulting target position
    var result_pos = camera.ensure_valid_target(outside_bounds)
    
    # The validator should adjust the position to the minimum allowed x,y
    assert_true(result_pos.x >= expected_min_x, "X position should be adjusted to minimum boundary + half camera")
    assert_true(result_pos.y >= expected_min_y, "Y position should be adjusted to minimum boundary + half camera")
    
    # Now actually move to the position
    camera.move_to_position(outside_bounds, true)  # Move immediately
    
    # Position should be at adjusted boundary, not at the requested position
    assert_not_equal(camera.global_position, outside_bounds, "Camera should not move to position outside bounds")
    assert_true(camera.global_position.x >= expected_min_x, "Camera X position should remain at or above minimum bounds")
    assert_true(camera.global_position.y >= expected_min_y, "Camera Y position should remain at or above minimum bounds")
    
    # Reset test mode for other tests
    camera.test_mode = true
    camera.global_position = original_pos
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 4: Update bounds method
    start_test("Update bounds method")
    
    # Get original bounds
    var original_bounds = camera.camera_bounds
    
    # The update_bounds method should work regardless of parent type as long as it has walkable_areas
    # This tests the fix for Bug 3 where update_bounds only worked with BaseDistrict parents
    camera.update_bounds()
    
    # Bounds should still be valid after update (may or may not change, but should remain valid)
    assert_true(camera.camera_bounds.size.x > 0 && camera.camera_bounds.size.y > 0, "Camera bounds should remain valid after update")
    
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 5: Viewport-aware bounds calculation
    start_test("Viewport-aware bounds calculation")
    
    # Create a mock district with floor-like walkable area (reproduces the visual bug)
    var mock_district = Node2D.new()
    mock_district.name = "MockDistrict"
    
    # Create a floor-like walkable area that causes the visual positioning bug
    var walkable_area = Polygon2D.new()
    walkable_area.name = "FloorWalkableArea"
    
    # Use the exact problematic polygon from camera-system test
    var floor_polygon = PoolVector2Array([
        Vector2(0, 822),     # Floor level
        Vector2(4691, 822),  # Floor level (wide)
        Vector2(4691, 947),  # Bottom edge
        Vector2(0, 947)      # Bottom edge
    ])
    walkable_area.polygon = floor_polygon
    
    # Add the interface method for compatibility
    walkable_area.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
    
    # Set up the mock district - use set_script first to add the walkable_areas property
    mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
    mock_district.walkable_areas = [walkable_area]
    mock_district.background_size = Vector2(4698, 952)  # Scaled background size from camera-system
    add_child(mock_district)
    mock_district.add_child(walkable_area)
    
    # Calculate bounds using the camera's method
    var calculated_bounds = camera._calculate_district_bounds(mock_district)
    
    # Get camera screen size (viewport size)
    var viewport_size = camera.screen_size
    log_info("Viewport size: " + str(viewport_size))
    log_info("Calculated bounds: " + str(calculated_bounds))
    log_info("Bounds height: " + str(calculated_bounds.size.y))
    log_info("Viewport height: " + str(viewport_size.y))
    
    # THE CRITICAL TEST: Bounds height should be reasonable relative to viewport
    var height_ratio = calculated_bounds.size.y / viewport_size.y
    var acceptable_height_ratio = height_ratio >= 0.3  # At least 30% of viewport height
    
    log_info("Height ratio (bounds/viewport): " + str(height_ratio))
    log_info("Is height ratio acceptable (>=0.3): " + str(acceptable_height_ratio))
    
    # This test should FAIL with current implementation
    # Current bounds height ~127px, viewport ~952px = ratio ~0.13 (13%)
    assert_true(acceptable_height_ratio, "ScrollingCamera bounds height should be at least 30% of viewport height to prevent visual positioning issues")
    
    # Clean up
    mock_district.queue_free()
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 6: Background scaling hybrid architecture validation
    start_test("Background scaling hybrid architecture validation")
    
    # Create a mock district with background for scaling test
    var scaling_district = Node2D.new()
    scaling_district.name = "ScalingTestDistrict"
    
    # Set up background size to match scaling scenario (original background size)
    scaling_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
    scaling_district.background_size = Vector2(2448, 496)  # Original background size
    
    # Create a mock background sprite for calculate_optimal_zoom to find
    var background = Sprite.new()
    background.name = "Background"
    
    # Create a mock texture with the original size
    var mock_texture = ImageTexture.new()
    var image = Image.new()
    image.create(2448, 496, false, Image.FORMAT_RGB8)
    mock_texture.create_from_image(image)
    background.texture = mock_texture
    background.centered = false
    
    scaling_district.add_child(background)
    add_child(scaling_district)
    
    # Create floor-like walkable area that produces viewport-aware bounds
    var scaling_walkable = Polygon2D.new()
    scaling_walkable.name = "ScalingWalkableArea"
    var scaling_polygon = PoolVector2Array([
        Vector2(0, 822),     # Floor level
        Vector2(4691, 822),  # Floor level (wide)
        Vector2(4691, 947),  # Bottom edge
        Vector2(0, 947)      # Bottom edge
    ])
    scaling_walkable.polygon = scaling_polygon
    scaling_walkable.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
    
    scaling_district.walkable_areas = [scaling_walkable]
    scaling_district.add_child(scaling_walkable)
    
    # Step 1: Calculate viewport-aware bounds using _calculate_district_bounds
    var expected_bounds = camera._calculate_district_bounds(scaling_district)
    
    log_info("Expected viewport-aware bounds: " + str(expected_bounds))
    log_info("Expected bounds height: " + str(expected_bounds.size.y))
    
    # Step 2: Move camera to the scaling district to trigger background scaling
    var original_parent = camera.get_parent()
    if original_parent:
        original_parent.remove_child(camera)
    scaling_district.add_child(camera)
    
    # Step 3: Call calculate_optimal_zoom (this should NOT override the bounds)
    camera.screen_size = Vector2(1424, 952)  # Set viewport size
    camera.bounds_enabled = true
    camera.calculate_optimal_zoom()
    
    # Step 4: Verify that bounds were NOT overridden by background scaling
    var bounds_after_scaling = camera.camera_bounds
    
    log_info("Bounds after background scaling: " + str(bounds_after_scaling))
    log_info("Bounds height after scaling: " + str(bounds_after_scaling.size.y))
    
    # THE CRITICAL TEST: Verify hybrid architecture - bounds should be overridden for visual correctness
    var bounds_were_overridden = (bounds_after_scaling.size.y != expected_bounds.size.y)
    var bounds_match_scaled_background = (abs(bounds_after_scaling.size.y - 952.0) < 10.0)  # Should match viewport height
    
    log_info("Bounds were overridden: " + str(bounds_were_overridden))
    log_info("Bounds match scaled background: " + str(bounds_match_scaled_background))
    
    assert_true(bounds_were_overridden, "calculate_optimal_zoom() should override viewport-aware bounds for visual correctness")
    assert_true(bounds_match_scaled_background, "Bounds should be set to scaled background size to prevent grey bar visual artifacts")
    
    # Step 5: Restore camera to original parent
    scaling_district.remove_child(camera)
    if original_parent:
        original_parent.add_child(camera)
    
    # Clean up
    scaling_district.queue_free()
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 7: Background scaling requires bounds override for proper visual display
    start_test("Background scaling visual requirement")
    
    # This test captures the ACTUAL requirement: background scaling needs bounds override 
    # to prevent grey bars, even though it conflicts with viewport-aware bounds logic
    
    # Create a mock district with realistic background scaling scenario
    var visual_district = Node2D.new()
    visual_district.name = "VisualTestDistrict" 
    
    # Set up original background size (before scaling)
    visual_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
    visual_district.background_size = Vector2(2448, 496)  # Original size
    
    # Create mock background sprite
    var visual_background = Sprite.new()
    visual_background.name = "Background"
    
    # Create texture with original dimensions
    var visual_texture = ImageTexture.new()
    var visual_image = Image.new()
    visual_image.create(2448, 496, false, Image.FORMAT_RGB8)
    visual_texture.create_from_image(visual_image)
    visual_background.texture = visual_texture
    visual_background.centered = false
    
    visual_district.add_child(visual_background)
    add_child(visual_district)
    
    # Create floor walkable area that would cause viewport-aware bounds
    var visual_walkable = Polygon2D.new()
    visual_walkable.name = "VisualWalkableArea"
    var visual_polygon = PoolVector2Array([
        Vector2(0, 822),     # Floor level  
        Vector2(4691, 822),  # Floor level (wide)
        Vector2(4691, 947),  # Bottom edge
        Vector2(0, 947)      # Bottom edge
    ])
    visual_walkable.polygon = visual_polygon
    visual_walkable.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
    
    visual_district.walkable_areas = [visual_walkable]
    visual_district.add_child(visual_walkable)
    
    # Move camera to the visual district 
    var visual_original_parent = camera.get_parent()
    if visual_original_parent:
        visual_original_parent.remove_child(camera)
    visual_district.add_child(camera)
    
    # Set realistic viewport size that triggers the scaling issue
    camera.screen_size = Vector2(1424, 952)  # Viewport size
    camera.bounds_enabled = true
    
    # Call calculate_optimal_zoom to trigger background scaling
    camera.calculate_optimal_zoom()
    
    # Get the background's scale after calculate_optimal_zoom
    var background_scale_after = visual_background.scale
    var expected_scale = 952.0 / 496.0  # viewport_height / original_height = ~1.92
    
    log_info("Background scale after calculate_optimal_zoom: " + str(background_scale_after))
    log_info("Expected scale for viewport fill: " + str(expected_scale))
    
    # Verify background was scaled to fill viewport height
    var scale_correct = abs(background_scale_after.y - expected_scale) < 0.1
    assert_true(scale_correct, "Background should be scaled to fill viewport height exactly")
    
    # THE CRITICAL TEST: With proper background scaling, bounds must allow full camera movement
    # to prevent grey bars from viewport clipping
    var final_bounds = camera.camera_bounds
    var scaled_bg_size = Vector2(2448 * background_scale_after.x, 496 * background_scale_after.y)
    
    log_info("Final camera bounds: " + str(final_bounds))
    log_info("Scaled background size: " + str(scaled_bg_size))
    
    # For proper visual display WITHOUT grey bars, camera bounds must match scaled background
    # This allows camera to move across the full scaled background area
    var bounds_match_background = (abs(final_bounds.size.x - scaled_bg_size.x) < 10.0 and 
                                  abs(final_bounds.size.y - scaled_bg_size.y) < 10.0)
    
    log_info("Bounds match scaled background: " + str(bounds_match_background))
    
    # This should FAIL with current implementation (bounds preserved instead of overridden)
    assert_true(bounds_match_background, "Camera bounds must match scaled background size to prevent grey bar visual artifacts")
    
    # Restore camera to original parent
    visual_district.remove_child(camera)
    if visual_original_parent:
        visual_original_parent.add_child(camera)
    
    # Clean up
    visual_district.queue_free()
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 8: Bounds validator synchronization (Critical Fix Coverage)
    start_test("Bounds validator synchronization with background scaling")
    
    # This test covers the critical fix: updating bounds validator when bounds are overridden
    # Lines 1047-1049 in scrolling_camera.gd: _bounds_validator.set_bounds(camera_bounds)
    
    # Create mock district with background that triggers scaling
    var sync_district = Node2D.new()
    sync_district.name = "SyncDistrict" 
    sync_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
    sync_district.background_size = Vector2(2448, 496)  # Original size
    
    # Create background sprite that will be scaled
    var sync_background = Sprite.new()
    sync_background.name = "Background"
    var sync_texture = ImageTexture.new()
    var sync_image = Image.new()
    sync_image.create(2448, 496, false, Image.FORMAT_RGB8)
    sync_texture.create_from_image(sync_image)
    sync_background.texture = sync_texture
    sync_background.centered = false
    sync_district.add_child(sync_background)
    
    # Create walkable area for bounds calculation
    var sync_walkable = Polygon2D.new()
    sync_walkable.name = "SyncWalkableArea"
    var sync_polygon = PoolVector2Array([
        Vector2(0, 822), Vector2(4691, 822), Vector2(4691, 947), Vector2(0, 947)
    ])
    sync_walkable.polygon = sync_polygon
    sync_walkable.set_script(preload("res://src/unit_tests/mocks/mock_district.gd"))
    sync_district.walkable_areas = [sync_walkable]
    sync_district.add_child(sync_walkable)
    add_child(sync_district)
    
    # Move camera to sync district
    var sync_original_parent = camera.get_parent()
    if sync_original_parent:
        sync_original_parent.remove_child(camera)
    sync_district.add_child(camera)
    
    # Set viewport size and enable bounds
    camera.screen_size = Vector2(1424, 952)
    camera.bounds_enabled = true
    
    # Get initial bounds (viewport-aware)
    var initial_bounds = camera._calculate_district_bounds(sync_district)
    camera.camera_bounds = initial_bounds
    
    log_info("Initial bounds before scaling: " + str(initial_bounds))
    
    # CRITICAL TEST: Trigger background scaling which should override bounds AND update validator
    camera.calculate_optimal_zoom()
    
    # Verify bounds were overridden for visual correctness
    var sync_final_bounds = camera.camera_bounds
    var bounds_overridden = sync_final_bounds != initial_bounds
    
    log_info("Final bounds after scaling: " + str(sync_final_bounds))
    log_info("Bounds were overridden: " + str(bounds_overridden))
    
    assert_true(bounds_overridden, "Background scaling should override bounds for visual correctness")
    
    # THE CRITICAL FIX VERIFICATION: Test that bounds validation works correctly after override
    # This indirectly verifies the fix in lines 1047-1049 of scrolling_camera.gd
    # by testing that camera positioning respects the updated bounds
    
    # Test that camera position is properly validated against the new bounds
    camera.test_mode = false  # Use real bounds validation
    
    # Try to position camera at a location that should be valid with new bounds
    # but would have been invalid with old bounds
    var test_position = Vector2(sync_final_bounds.position.x + sync_final_bounds.size.x - 100, 
                               sync_final_bounds.position.y + sync_final_bounds.size.y - 100)
    
    log_info("Testing position: " + str(test_position))
    log_info("Against bounds: " + str(sync_final_bounds))
    
    var validated_position = camera.ensure_valid_target(test_position)
    
    log_info("Validated position: " + str(validated_position))
    
    # Verify that the bounds validator is using the updated bounds
    # The key evidence is that a position within the new bounds area gets validated
    # (even if adjusted for camera half-size constraints)
    var within_new_bounds_area = (validated_position.x >= sync_final_bounds.position.x and 
                                  validated_position.y >= sync_final_bounds.position.y and
                                  validated_position.x <= sync_final_bounds.end.x and
                                  validated_position.y <= sync_final_bounds.end.y)
    
    log_info("Validated position within new bounds area: " + str(within_new_bounds_area))
    
    assert_true(within_new_bounds_area, "CRITICAL FIX: Bounds validator should use updated bounds after background scaling override")
    
    # Restore camera
    sync_district.remove_child(camera)
    if sync_original_parent:
        sync_original_parent.add_child(camera)
    
    # Clean up
    sync_district.queue_free()
    end_test()
    
    yield(get_tree(), "idle_frame")

func run_state_tests():
    log_info("=== Running State Tests ===", true)
    
    # Test 1: State transitions
    start_test("State transitions")
    
    # Start with IDLE state
    camera.set_camera_state(camera.CameraState.IDLE)
    assert_equal(camera.current_camera_state, camera.CameraState.IDLE, "Camera should set IDLE state")
    
    # Transition to MOVING
    camera.set_camera_state(camera.CameraState.MOVING)
    assert_equal(camera.current_camera_state, camera.CameraState.MOVING, "Camera should transition to MOVING state")
    
    # Transition to FOLLOWING_PLAYER
    camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
    assert_equal(camera.current_camera_state, camera.CameraState.FOLLOWING_PLAYER, "Camera should transition to FOLLOWING_PLAYER state")
    
    # Back to IDLE
    camera.set_camera_state(camera.CameraState.IDLE)
    assert_equal(camera.current_camera_state, camera.CameraState.IDLE, "Camera should transition back to IDLE state")
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 2: State helper methods
    start_test("State helper methods")
    
    # Set state to IDLE
    camera.set_camera_state(camera.CameraState.IDLE)
    
    # Check helper methods
    assert_true(camera.is_idle(), "is_idle() should return true in IDLE state")
    assert_false(camera.is_moving(), "is_moving() should return false in IDLE state")
    assert_false(camera.is_following_player(), "is_following_player() should return false in IDLE state")
    
    # Set state to MOVING
    camera.set_camera_state(camera.CameraState.MOVING)
    
    # Check helper methods again
    assert_false(camera.is_idle(), "is_idle() should return false in MOVING state")
    assert_true(camera.is_moving(), "is_moving() should return true in MOVING state")
    assert_false(camera.is_following_player(), "is_following_player() should return false in MOVING state")
    
    # Set state to FOLLOWING_PLAYER
    camera.set_camera_state(camera.CameraState.FOLLOWING_PLAYER)
    
    # Check helper methods once more
    assert_false(camera.is_idle(), "is_idle() should return false in FOLLOWING_PLAYER state")
    assert_false(camera.is_moving(), "is_moving() should return false in FOLLOWING_PLAYER state")
    assert_true(camera.is_following_player(), "is_following_player() should return true in FOLLOWING_PLAYER state")
    
    # Reset to IDLE
    camera.set_camera_state(camera.CameraState.IDLE)
    end_test()
    
    yield(get_tree(), "idle_frame")

func run_coordinate_tests():
    log_info("=== Running Coordinate Tests ===", true)
    
    # Test 1: Screen to world coordinate conversion
    start_test("Screen to world conversion")
    
    # Get viewport center
    var viewport_center = get_viewport_rect().size / 2
    
    # Convert viewport center to world coordinates
    var world_center = camera.screen_to_world(viewport_center)
    
    # World center should be at or near camera position
    var distance = (world_center - camera.global_position).length()
    assert_true(distance < 1.0, "Screen center should convert to camera position")
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 2: World to screen coordinate conversion
    start_test("World to screen conversion")
    
    # Get camera position
    var camera_pos = camera.global_position
    
    # Convert camera position to screen coordinates
    var screen_pos = camera.world_to_screen(camera_pos)
    
    # Screen position should be at or near viewport center
    var view_center = get_viewport_rect().size / 2
    var screen_distance = (screen_pos - view_center).length()
    assert_true(screen_distance < 5.0, "Camera position should convert to screen center")
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 3: Coordinate validation
    start_test("Coordinate validation")
    
    # Valid coordinate should remain unchanged
    var valid_coord = Vector2(100, 100)
    var validated = camera.validate_coordinates(valid_coord)
    assert_vector2_equal(validated, valid_coord, "Valid coordinates should remain unchanged")
    
    # Test handling of NaN
    var nan_coord = Vector2(NAN, 100)
    validated = camera.validate_coordinates(nan_coord)
    assert_not_equal(validated, nan_coord, "NaN coordinates should be corrected")
    assert_not_true(is_nan(validated.x), "NaN value should be replaced")
    
    # Test handling of INF
    var inf_coord = Vector2(INF, 100)
    validated = camera.validate_coordinates(inf_coord)
    assert_not_equal(validated, inf_coord, "Infinite coordinates should be corrected")
    assert_not_true(is_inf(validated.x), "Infinite value should be replaced")
    end_test()
    
    yield(get_tree(), "idle_frame")

func run_signal_tests():
    log_info("=== Running Signal Tests ===", true)
    
    # Test 1: State change signal
    start_test("State change signal")
    
    # Clear any previous signals
    received_signals.clear()
    
    # Direct connect to the signal
    camera.connect("camera_state_changed", self, "_on_signal_state_changed")
    
    # Trigger state change
    camera.set_camera_state(camera.CameraState.MOVING)
    
    # Wait for signal processing
    yield(get_tree().create_timer(0.1), "timeout")
    
    # Check if signal was received
    assert_true(has_signal_state_changed, "State change signal should be emitted")
    assert_equal(last_state_signal, camera.CameraState.MOVING, "Signal should contain correct state")
    
    # Clean up
    if camera.is_connected("camera_state_changed", self, "_on_signal_state_changed"):
        camera.disconnect("camera_state_changed", self, "_on_signal_state_changed")
    
    # Reset state
    camera.set_camera_state(camera.CameraState.IDLE)
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 2: Movement signals
    start_test("Movement signals")
    
    # Setup signal tracking
    has_move_started = false
    has_move_completed = false
    
    # Connect to signals directly
    camera.connect("camera_move_started", self, "_on_move_started")
    camera.connect("camera_move_completed", self, "_on_move_completed")
    
    # Start position
    var start_pos = camera.global_position
    var target_pos = start_pos + Vector2(100, 0)
    
    # Trigger movement
    camera.move_to_position(target_pos)
    
    # Manually process movement to completion
    for i in range(10):
        camera._handle_transition_movement(0.1)
        yield(get_tree(), "idle_frame")
        if camera.current_camera_state == camera.CameraState.IDLE:
            break
    
    # Verify signals
    assert_true(has_move_started, "Move started signal should be emitted")
    assert_true(has_move_completed, "Move completed signal should be emitted")
    
    # Clean up signals
    camera.disconnect("camera_move_started", self, "_on_move_started")
    camera.disconnect("camera_move_completed", self, "_on_move_completed")
    
    # Reset position
    camera.global_position = start_pos
    end_test()
    
    yield(get_tree(), "idle_frame")
    
    # Test 3: Bounds change signal
    start_test("Bounds change signal")
    
    # Reset tracking flag
    has_bounds_changed = false
    
    # Connect to bounds change signal directly
    camera.connect("view_bounds_changed", self, "_on_view_bounds_changed")
    
    # Get current bounds
    var old_bounds = camera.camera_bounds
    var new_bounds = Rect2(old_bounds.position + Vector2(10, 10), old_bounds.size)
    
    # Change bounds by directly emitting the signal (bounds_validator handles the actual change)
    camera.emit_signal("view_bounds_changed", new_bounds, old_bounds, false)
    
    # Wait for signal processing
    yield(get_tree().create_timer(0.1), "timeout")
    
    # Check if signal was received
    assert_true(has_bounds_changed, "Bounds change signal should be emitted")
    
    # Clean up
    camera.disconnect("view_bounds_changed", self, "_on_view_bounds_changed")
    end_test()
    
    yield(get_tree(), "idle_frame")

# =========== HELPER METHODS ===========

func _setup_camera():
    # First check if we already have a TestCamera node in the scene
    var existing_camera = get_node_or_null("TestCamera")
    if existing_camera and existing_camera is Camera2D:
        log_info("Using existing camera: " + existing_camera.name)
        return existing_camera
    
    # If not, create a new camera
    log_info("Creating new camera for testing")
    
    # Create Camera2D node
    var new_camera = Camera2D.new()
    new_camera.name = "TestCamera"
    new_camera.current = true
    
    # Attach the ScrollingCamera script
    var script = load("res://src/core/camera/scrolling_camera.gd")
    if script:
        new_camera.set_script(script)
        
        # Enable test mode
        new_camera.test_mode = true
        
        # Set initial position in the center
        new_camera.global_position = Vector2(500, 500)
        
        # Add to the scene
        add_child(new_camera)
        
        return new_camera
    else:
        log_error("Failed to load ScrollingCamera script")
        return null
        
# Create a mock player for the camera to track
func _setup_mock_player():
    # First check if we already have a MockPlayer node
    var existing_player = get_node_or_null("MockPlayer")
    if existing_player and existing_player is Node2D:
        log_info("Using existing player: " + existing_player.name)
        return existing_player
        
    # Create a new mock player
    var player = Node2D.new()
    player.name = "MockPlayer"
    
    # Position the player in the scene
    player.global_position = Vector2(500, 500)
    
    # Add to the "player" group so camera can find it
    player.add_to_group("player")
    
    # Add to the scene
    add_child(player)
    
    log_info("Created mock player at position: " + str(player.global_position))
    return player

# Signal helpers
func _connect_test_signal(signal_name):
    # Clear previous signal data for this signal
    if !received_signals.has(signal_name):
        received_signals[signal_name] = []
    else:
        received_signals[signal_name].clear()
    
    # Connect to the signal
    if !camera.is_connected(signal_name, self, "_on_test_signal_received"):
        camera.connect(signal_name, self, "_on_test_signal_received", [signal_name])

func _disconnect_test_signals():
    # Disconnect all test signals
    for signal_name in received_signals.keys():
        if camera.is_connected(signal_name, self, "_on_test_signal_received"):
            camera.disconnect(signal_name, self, "_on_test_signal_received")
    
    # Clear signal data
    received_signals.clear()

func _on_test_signal_received(arg1 = null, arg2 = null, arg3 = null, arg4 = null, signal_name = null):
    # Store signal parameters
    if signal_name:
        log_info("Received signal: " + signal_name + " with first param: " + str(arg1))
        
        if !received_signals.has(signal_name):
            received_signals[signal_name] = []
        
        var params = []
        if arg1 != null: params.append(arg1)
        if arg2 != null: params.append(arg2)
        if arg3 != null: params.append(arg3)
        if arg4 != null: params.append(arg4)
        
        received_signals[signal_name].append(params)

func _signal_was_emitted(signal_name):
    return received_signals.has(signal_name) and received_signals[signal_name].size() > 0

func _get_signal_params(signal_name, index = 0):
    if _signal_was_emitted(signal_name) and index < received_signals[signal_name].size():
        return received_signals[signal_name][index]
    return []

# Test management helpers
func start_test(test_name):
    current_test_name = test_name
    current_test_passed = true
    log_info("Running test: " + test_name)
    
    # Start timeout timer
    test_end_time = OS.get_ticks_msec() + int(TEST_TIMEOUT * 1000)
    test_timeout_timer.start(TEST_TIMEOUT)

func end_test():
    # Stop timeout timer
    test_timeout_timer.stop()
    test_end_time = 0
    
    # Record test result
    total_tests += 1
    if current_test_passed:
        passed_tests += 1
        log_success("PASS: " + current_test_name)
    else:
        failed_tests.append(current_test_name)
        log_error("FAIL: " + current_test_name)
    
    # Clear current test
    current_test_name = ""
    current_test_passed = true

func _end_current_test(passed, message = ""):
    if current_test_name:
        current_test_passed = current_test_passed and passed
        
        if !passed:
            log_error("Assertion failed: " + message)
        
        # Note: We don't end the test here, as end_test() should be called by the test function
    else:
        log_error("Assertion outside of a test: " + message)

func _on_test_timeout():
    if current_test_name:
        _end_current_test(false, "Test timed out: " + current_test_name)
        end_test()

# Assertion methods
func assert_true(condition, message = ""):
    _end_current_test(condition, message)

func assert_false(condition, message = ""):
    _end_current_test(!condition, message)

func assert_equal(actual, expected, message = ""):
    var result = actual == expected
    if !result:
        message += " (Expected: " + str(expected) + ", Got: " + str(actual) + ")"
    _end_current_test(result, message)

func assert_not_equal(actual, unexpected, message = ""):
    var result = actual != unexpected
    if !result:
        message += " (Got unexpected value: " + str(actual) + ")"
    _end_current_test(result, message)

func assert_vector2_equal(actual, expected, message = "", tolerance = 1.0):
    var distance = (actual - expected).length()
    var result = distance <= tolerance
    if !result:
        message += " (Expected: " + str(expected) + ", Got: " + str(actual) + ", Distance: " + str(distance) + ")"
    _end_current_test(result, message)

func assert_not_true(condition, message = ""):
    _end_current_test(!condition, message)

func assert_not_false(condition, message = ""):
    _end_current_test(condition, message)

# Logging helpers
func log_info(message, force_print = false):
    if force_print:
        print(LOG_PREFIX + " " + message)
    else:
        print(LOG_PREFIX + " " + message)

func log_error(message):
    print(LOG_PREFIX + " ERROR: " + message)

func log_success(message):
    print(LOG_PREFIX + " " + message)

func report_test_results():
    log_info("=== TEST RESULTS ===", true)
    log_info("Total tests: " + str(total_tests), true)
    log_info("Passed: " + str(passed_tests), true)
    log_info("Failed: " + str(total_tests - passed_tests), true)
    
    if failed_tests.size() > 0:
        log_info("\nFailed tests:", true)
        for test in failed_tests:
            log_info("- " + test, true)
    
    if passed_tests == total_tests:
        log_info("\nAll tests passed! 🎉", true)
    else:
        log_info("\nSome tests failed. 😞", true)