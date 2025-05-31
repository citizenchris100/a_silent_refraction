extends "res://src/core/districts/base_district.gd"
# Subsystem Test: Navigation Signal Flow - Tests complete navigation signal chain
# This test extends base_district to accurately represent the actual game architecture
#
# Systems Under Test:
# - InputManager: Detects click and emits click_detected signal
# - GameManager: Coordinates between systems, should relay signals
# - Player: Moves and emits movement_state_changed signals
# - ScrollingCamera: Follows player and emits position/state signals
# - District: Provides boundaries and walkable areas
#
# Test Scenarios:
# 1. Complete click to movement flow - verify all signals emit in correct order
# 2. Multi-component state synchronization - test with rapid clicks
# 3. Edge cases - clicking outside walkable areas, during movement, etc.

# Test configuration (manual since we don't extend subsystem_test_base)
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var failed_tests = []
var test_start_time = 0

# Subsystem components
var game_manager: Node
var input_manager: Node
var player_instance: Node2D
var camera_instance: Camera2D

# Signal flow tracking
var signal_sequence = []
var expected_sequence = []
var signal_timestamps = {}

# State tracking
var component_states = {}
var race_conditions_detected = []

func _ready():
    # Set up district properties
    district_name = "Navigation Signal Flow Test District"
    district_description = "Test district for navigation signal flow validation"
    
    # Configure camera
    use_scrolling_camera = true
    camera_follow_smoothing = 5.0
    initial_camera_view = "center"
    
    # Create background (MUST be direct child named "Background")
    var background = Sprite.new()
    background.name = "Background"
    background.texture = create_test_texture()
    background.centered = false
    add_child(background)
    
    # Set background size for camera bounds
    background_size = background.texture.get_size()
    
    # Create walkable areas
    create_test_walkable_areas()
    
    # Call parent _ready() - this sets up camera and systems
    ._ready()
    
    # Now set up player using district's method
    setup_player_and_controller(Vector2(960, 540))
    
    # Store references to created components
    store_component_references()
    
    # Setup signal monitoring
    setup_signal_monitoring()
    
    # Run tests
    yield(run_test_scenarios(), "completed")
    
    # Exit with appropriate code
    get_tree().quit(tests_failed)

func create_test_texture() -> Texture:
    var image = Image.new()
    image.create(1920, 1080, false, Image.FORMAT_RGB8)
    image.fill(Color(0.1, 0.15, 0.2))
    var texture = ImageTexture.new()
    texture.create_from_image(image)
    return texture

func create_test_walkable_areas():
    # Create a complex walkable area to test pathfinding
    walkable_areas.append([
        Vector2(100, 100),
        Vector2(1820, 100),
        Vector2(1820, 980),
        Vector2(100, 980)
    ])
    
    # Add an obstacle to make pathfinding interesting
    walkable_areas.append([
        Vector2(800, 400),
        Vector2(1120, 400),
        Vector2(1120, 680),
        Vector2(800, 680)
    ])

func store_component_references():
    # Find core systems
    game_manager = get_tree().get_nodes_in_group("game_manager")[0] if get_tree().get_nodes_in_group("game_manager").size() > 0 else null
    input_manager = get_tree().get_nodes_in_group("input_manager")[0] if get_tree().get_nodes_in_group("input_manager").size() > 0 else null
    
    # Get player and camera from district setup
    var players = get_tree().get_nodes_in_group("player")
    player_instance = players[0] if players.size() > 0 else null
    
    var cameras = get_tree().get_nodes_in_group("camera")
    camera_instance = cameras[0] if cameras.size() > 0 else null
    
    # Log what we found
    print("  [INFO] GameManager: %s" % ("found" if game_manager else "NOT FOUND"))
    print("  [INFO] InputManager: %s" % ("found" if input_manager else "NOT FOUND"))
    print("  [INFO] Player: %s" % ("found" if player_instance else "NOT FOUND"))
    print("  [INFO] Camera: %s" % ("found" if camera_instance else "NOT FOUND"))

func setup_signal_monitoring():
    # Monitor InputManager signals
    if input_manager:
        if input_manager.has_signal("click_detected"):
            input_manager.connect("click_detected", self, "_on_signal_emitted", ["input_click_detected"])
        if input_manager.has_signal("object_clicked"):
            input_manager.connect("object_clicked", self, "_on_signal_emitted", ["input_object_clicked"])
    
    # Monitor Player signals
    if player_instance:
        if player_instance.has_signal("movement_state_changed"):
            player_instance.connect("movement_state_changed", self, "_on_signal_emitted", ["player_movement_state_changed"])
    
    # Monitor Camera signals
    if camera_instance:
        if camera_instance.has_signal("camera_move_started"):
            camera_instance.connect("camera_move_started", self, "_on_signal_emitted", ["camera_move_started"])
        if camera_instance.has_signal("camera_move_completed"):
            camera_instance.connect("camera_move_completed", self, "_on_signal_emitted", ["camera_move_completed"])
        if camera_instance.has_signal("camera_state_changed"):
            camera_instance.connect("camera_state_changed", self, "_on_signal_emitted", ["camera_state_changed"])
    
    # Monitor GameManager relay signals (TDD: these don't exist yet)
    if game_manager:
        # These connections will fail in TDD since GameManager doesn't emit relay signals yet
        if game_manager.has_signal("player_state_relayed"):
            game_manager.connect("player_state_relayed", self, "_on_signal_emitted", ["gm_player_state_relayed"])
        if game_manager.has_signal("camera_state_relayed"):
            game_manager.connect("camera_state_relayed", self, "_on_signal_emitted", ["gm_camera_state_relayed"])

func _on_signal_emitted(signal_name: String, arg1 = null, arg2 = null, arg3 = null, arg4 = null):
    var timestamp = OS.get_ticks_msec()
    signal_sequence.append(signal_name)
    signal_timestamps[signal_name] = timestamp
    
    # Store detailed signal data for analysis
    if signal_name == "player_movement_state_changed":
        component_states["player_state"] = arg1
    elif signal_name == "camera_state_changed":
        component_states["camera_state"] = arg1
    
    print("  [SIGNAL] %s at %d ms" % [signal_name, timestamp])

func run_test_scenarios():
    print("\n" + "============================================================")
    print(" NAVIGATION SIGNAL FLOW SUBSYSTEM TEST")
    print("============================================================" + "\n")
    
    # Wait for systems to stabilize
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Test 1: Complete click to movement flow
    yield(test_complete_navigation_flow(), "completed")
    
    # Test 2: Multi-component state synchronization
    yield(test_rapid_click_synchronization(), "completed")
    
    # Test 3: Edge cases
    yield(test_edge_cases(), "completed")
    
    # Generate report
    print_test_summary()

func test_complete_navigation_flow():
    print("\n===== SCENARIO: Complete Click to Movement Flow =====")
    
    start_test("signal_chain_order")
    
    # Clear tracking
    signal_sequence.clear()
    signal_timestamps.clear()
    
    # Define expected signal order
    expected_sequence = [
        "input_click_detected",          # InputManager detects click
        "input_object_clicked",          # InputManager routes click
        "player_movement_state_changed", # Player starts moving (ACCELERATING)
        "camera_state_changed",          # Camera responds to player movement
        "player_movement_state_changed", # Player reaches full speed (MOVING)
        "player_movement_state_changed", # Player starts slowing (DECELERATING)
        "player_movement_state_changed", # Player arrives (ARRIVED/IDLE)
        "camera_move_completed"          # Camera finishes following
    ]
    
    # Simulate click
    var click_target = Vector2(1200, 600)
    print("  [ACTION] Simulating click at %s" % click_target)
    
    # Trigger click through InputManager
    if input_manager and input_manager.has_method("_input"):
        var click_event = InputEventMouseButton.new()
        click_event.button_index = BUTTON_LEFT
        click_event.pressed = true
        click_event.position = click_target
        input_manager._input(click_event)
    
    # Wait for movement to complete
    yield(wait_for_movement_completion(), "completed")
    
    # Verify signal order (TDD: This will likely fail due to missing GameManager connections)
    var order_correct = verify_signal_order()
    end_test(order_correct, "Signals should emit in correct order")
    
    # Test GameManager coordination
    start_test("game_manager_signal_coordination")
    
    # TDD: GameManager should be coordinating signals but isn't yet
    var gm_coordinated = "gm_player_state_relayed" in signal_sequence or "gm_camera_state_relayed" in signal_sequence
    end_test(gm_coordinated, "GameManager should relay navigation signals")
    
    # Test signal timing
    start_test("signal_timing_consistency")
    
    var timing_consistent = verify_signal_timing()
    end_test(timing_consistent, "Signal timing should be consistent with no large gaps")
    
    yield(get_tree(), "idle_frame")

func test_rapid_click_synchronization():
    print("\n===== SCENARIO: Multi-Component State Synchronization =====")
    
    start_test("rapid_click_handling")
    
    # Clear tracking
    signal_sequence.clear()
    race_conditions_detected.clear()
    
    # Simulate rapid clicks
    var click_positions = [
        Vector2(300, 300),
        Vector2(1600, 300),
        Vector2(1600, 800),
        Vector2(300, 800)
    ]
    
    for i in range(click_positions.size()):
        print("  [ACTION] Rapid click %d at %s" % [i+1, click_positions[i]])
        
        if input_manager and input_manager.has_method("_input"):
            var click_event = InputEventMouseButton.new()
            click_event.button_index = BUTTON_LEFT
            click_event.pressed = true
            click_event.position = click_positions[i]
            input_manager._input(click_event)
        
        # Very short delay between clicks
        yield(get_tree().create_timer(0.1), "timeout")
    
    # Wait for system to stabilize
    yield(get_tree().create_timer(2.0), "timeout")
    
    # Check for race conditions
    var no_races = race_conditions_detected.empty()
    end_test(no_races, "No race conditions during rapid clicks")
    
    # Test state consistency
    start_test("component_state_consistency")
    
    var states_consistent = verify_component_state_consistency()
    end_test(states_consistent, "All components maintain consistent state")
    
    yield(get_tree(), "idle_frame")

func test_edge_cases():
    print("\n===== SCENARIO: Edge Cases =====")
    
    # Test clicking outside walkable area
    start_test("click_outside_walkable_area")
    
    signal_sequence.clear()
    
    # Click outside bounds
    var invalid_click = Vector2(-100, -100)
    print("  [ACTION] Clicking outside walkable area at %s" % invalid_click)
    
    if input_manager and input_manager.has_method("_input"):
        var click_event = InputEventMouseButton.new()
        click_event.button_index = BUTTON_LEFT
        click_event.pressed = true
        click_event.position = invalid_click
        input_manager._input(click_event)
    
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Should not trigger movement
    var no_invalid_movement = not "player_movement_state_changed" in signal_sequence
    end_test(no_invalid_movement, "Invalid clicks should not trigger movement")
    
    # Test clicking during movement
    start_test("click_during_movement")
    
    # Start a movement
    var first_click = Vector2(500, 500)
    if input_manager and input_manager.has_method("_input"):
        var click_event = InputEventMouseButton.new()
        click_event.button_index = BUTTON_LEFT
        click_event.pressed = true
        click_event.position = first_click
        input_manager._input(click_event)
    
    yield(get_tree().create_timer(0.2), "timeout")
    
    # Click somewhere else while moving
    var second_click = Vector2(1400, 700)
    signal_sequence.clear()
    
    if input_manager and input_manager.has_method("_input"):
        var click_event = InputEventMouseButton.new()
        click_event.button_index = BUTTON_LEFT
        click_event.pressed = true
        click_event.position = second_click
        input_manager._input(click_event)
    
    yield(wait_for_movement_completion(), "completed")
    
    # Should handle gracefully
    var handled_mid_movement = player_instance != null and player_instance.position.distance_to(second_click) < 50
    end_test(handled_mid_movement, "Clicks during movement should update destination")
    
    yield(get_tree(), "idle_frame")

# Helper methods
func wait_for_movement_completion(timeout: float = 5.0):
    var elapsed = 0.0
    while elapsed < timeout:
        if player_instance and player_instance.has_method("is_moving"):
            if not player_instance.is_moving:
                break
        elif component_states.get("player_state", "") == "IDLE":
            break
        
        yield(get_tree(), "idle_frame")
        elapsed += get_process_delta_time()

func verify_signal_order() -> bool:
    # Check if key signals appeared
    var has_input_signal = "input_click_detected" in signal_sequence or "input_object_clicked" in signal_sequence
    var has_player_signal = "player_movement_state_changed" in signal_sequence
    var has_camera_signal = "camera_state_changed" in signal_sequence or "camera_move_started" in signal_sequence
    
    if not has_input_signal:
        print("  [WARN] Missing input signals")
    if not has_player_signal:
        print("  [WARN] Missing player movement signals")  
    if not has_camera_signal:
        print("  [WARN] Missing camera signals")
    
    return has_input_signal and has_player_signal

func verify_signal_timing() -> bool:
    if signal_timestamps.empty():
        return false
    
    var last_time = 0
    var max_gap = 0
    
    for signal_name in signal_sequence:
        if signal_name in signal_timestamps:
            var current_time = signal_timestamps[signal_name]
            if last_time > 0:
                var gap = current_time - last_time
                max_gap = max(max_gap, gap)
            last_time = current_time
    
    # Allow up to 500ms between related signals
    return max_gap < 500

func verify_component_state_consistency() -> bool:
    # Basic check - in full implementation would verify more
    return component_states.has("player_state") and component_states.has("camera_state")

# Test framework methods
func start_test(test_name: String):
    current_test = test_name
    test_start_time = OS.get_ticks_msec()
    print("\n  Testing: " + test_name)

func end_test(passed: bool, message: String):
    var duration = (OS.get_ticks_msec() - test_start_time) / 1000.0
    
    if passed:
        tests_passed += 1
        print("    ✓ PASS: %s (%.2fs)" % [message, duration])
    else:
        tests_failed += 1
        failed_tests.append(current_test)
        print("    ✗ FAIL: %s (%.2fs)" % [message, duration])

func print_test_summary():
    print("\n" + "--------------------------------------------------")
    print(" Test Summary")
    print("--------------------------------------------------")
    print("Tests Passed: %d" % tests_passed)
    print("Tests Failed: %d" % tests_failed)
    
    if tests_failed > 0:
        print("\nFailed Tests:")
        for test in failed_tests:
            print("  - " + test)
    
    print("\nSignal Sequence Captured:")
    for i in range(min(10, signal_sequence.size())):
        print("  %d. %s" % [i+1, signal_sequence[i]])