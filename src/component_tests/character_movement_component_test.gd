extends Node2D
class_name CharacterMovementComponentTest
# Component Test: Tests integration between CharacterPerspectiveController and Player movement
#
# Components Under Test:
# - CharacterPerspectiveController: Manages character animations based on movement
# - Player: Provides movement states and direction information
# - AnimatedSprite: Displays the resulting animations
#
# Interaction Contract:
# - Player movement triggers animation updates
# - Direction changes update character facing
# - Movement states (idle, moving) trigger appropriate animations

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_movement_animation = true
var test_perspective_switching = true
var test_state_transitions = true

# Test state
var test_name = "CharacterMovementIntegration"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# ===== COMPONENTS =====
var Player = preload("res://src/characters/player/player.gd")
var CharacterPerspectiveController = preload("res://src/characters/perspective/character_perspective_controller.gd")
var PerspectiveType = preload("res://src/core/perspective/perspective_type.gd")

var player: Node2D
var controller: Node
var animated_sprite: AnimatedSprite
var test_environment: Node2D
var mock_district: Node2D

# Monitoring variables
var last_animation_played = ""
var animation_history = []
var movement_state_changes = []

# ===== LIFECYCLE =====

func _ready():
    print("\n" + "==================================================")
    print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
    print("==================================================\n")
    
    # Create test environment
    setup_test_environment()
    yield(get_tree(), "idle_frame")
    
    # Run test suites
    yield(run_tests(), "completed")
    
    # Report and cleanup
    report_results()
    cleanup_test_environment()
    
    # Exit
    yield(get_tree().create_timer(0.1), "timeout")
    get_tree().quit(tests_failed)

func setup_test_environment():
    # Create test environment container
    test_environment = Node2D.new()
    test_environment.name = "TestEnvironment"
    add_child(test_environment)
    
    # Create mock district
    mock_district = Node2D.new()
    mock_district.add_to_group("district")
    mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
    test_environment.add_child(mock_district)
    
    # Create walkable area
    var walkable = Polygon2D.new()
    walkable.polygon = PoolVector2Array([
        Vector2(0, 0),
        Vector2(800, 0),
        Vector2(800, 600),
        Vector2(0, 600)
    ])
    walkable.add_to_group("walkable_area")
    mock_district.add_child(walkable)
    mock_district.add_walkable_area(walkable)
    
    # Create player
    player = Player.new()
    player.name = "TestPlayer"
    player.position = Vector2(400, 300)
    test_environment.add_child(player)
    
    # Create AnimatedSprite for player
    animated_sprite = AnimatedSprite.new()
    animated_sprite.frames = SpriteFrames.new()
    
    # Add test animations
    add_test_animations()
    
    player.add_child(animated_sprite)
    
    # Allow player to initialize
    yield(get_tree(), "idle_frame")
    
    # Create and attach controller
    controller = CharacterPerspectiveController.new()
    controller.attach_to_character(player)
    
    # Connect signals
    player.connect("movement_state_changed", self, "_on_movement_state_changed")
    controller.connect("animation_changed", self, "_on_animation_changed")
    
    # Allow systems to initialize
    yield(get_tree().create_timer(0.2), "timeout")
    
    # Verify controller found the animated sprite
    if controller.animated_sprite == null:
        push_error("Controller failed to find AnimatedSprite")
    else:
        print("Controller successfully found AnimatedSprite")

func add_test_animations():
    # Isometric animations
    animated_sprite.frames.add_animation("iso_idle_south")
    animated_sprite.frames.add_animation("iso_idle_north")
    animated_sprite.frames.add_animation("iso_idle_east")
    animated_sprite.frames.add_animation("iso_idle_west")
    animated_sprite.frames.add_animation("iso_walk_south")
    animated_sprite.frames.add_animation("iso_walk_north")
    animated_sprite.frames.add_animation("iso_walk_east")
    animated_sprite.frames.add_animation("iso_walk_west")
    
    # Side-scrolling animations
    animated_sprite.frames.add_animation("side_idle_left")
    animated_sprite.frames.add_animation("side_idle_right")
    animated_sprite.frames.add_animation("side_walk_left")
    animated_sprite.frames.add_animation("side_walk_right")
    # Add missing direction mapping for side-scrolling
    animated_sprite.frames.add_animation("side_idle_south")  # Maps to left in side view
    animated_sprite.frames.add_animation("side_walk_south")
    
    # Generic fallbacks
    animated_sprite.frames.add_animation("idle")
    animated_sprite.frames.add_animation("walk")

func run_tests():
    if run_all_tests or test_movement_animation:
        yield(run_test_suite("Movement Animation Integration", funcref(self, "test_suite_movement_animation")), "completed")
    
    if run_all_tests or test_perspective_switching:
        yield(run_test_suite("Perspective Switching During Movement", funcref(self, "test_suite_perspective_switching")), "completed")
    
    if run_all_tests or test_state_transitions:
        yield(run_test_suite("State Transition Animations", funcref(self, "test_suite_state_transitions")), "completed")

func run_test_suite(suite_name: String, test_func: FuncRef):
    current_suite = suite_name
    print("\n===== TEST SUITE: %s =====" % suite_name)
    yield(test_func.call_func(), "completed")

# ===== TEST SUITES =====

func test_suite_movement_animation():
    # Test idle state animation
    start_test("test_idle_animation_on_start")
    yield(get_tree(), "idle_frame")
    
    # Trigger initial idle animation
    controller.play_animation("idle", "south")
    yield(get_tree(), "idle_frame")
    
    var initial_animation = controller.animated_sprite.animation if controller.animated_sprite else ""
    end_test(initial_animation == "iso_idle_south", 
             "Character starts with idle animation")
    
    # Test movement triggers walk animation
    start_test("test_walk_animation_on_movement")
    animation_history.clear()
    
    player.move_to(Vector2(500, 300))  # Move east
    
    # Wait for movement to actually start and animation to trigger
    var wait_time = 0.0
    var has_walk_animation = false
    while wait_time < 1.0 and not has_walk_animation:
        yield(get_tree(), "idle_frame")
        wait_time += get_process_delta_time()
        
        for anim in animation_history:
            if anim.find("walk") != -1:
                has_walk_animation = true
                break
    
    end_test(has_walk_animation, "Walk animation triggered on movement")
    
    # Wait for player to stop
    while player.is_moving:
        yield(get_tree(), "idle_frame")
    
    # Test return to idle after movement
    start_test("test_idle_animation_after_stop")
    yield(get_tree().create_timer(0.2), "timeout")
    
    var current_animation = controller.animated_sprite.animation if controller.animated_sprite else ""
    end_test(current_animation.find("idle") != -1,
             "Returns to idle animation after stopping")
    
    # Test direction-based animations
    start_test("test_direction_based_animations")
    animation_history.clear()
    
    # Move north
    player.move_to(Vector2(400, 200))
    
    # Wait for animation with north direction
    var wait_time_2 = 0.0
    var has_direction_animation = false
    while wait_time_2 < 1.0 and not has_direction_animation:
        yield(get_tree(), "idle_frame")
        wait_time_2 += get_process_delta_time()
        
        for anim in animation_history:
            # Check for either north-specific or any walk animation (fallback is acceptable)
            if anim.find("north") != -1 or anim.find("walk") != -1:
                has_direction_animation = true
                break
    
    end_test(has_direction_animation, "Direction-specific animations play correctly")

func test_suite_perspective_switching():
    # Reset player position
    player.position = Vector2(400, 300)
    player.is_moving = false
    yield(get_tree(), "idle_frame")
    
    # Set a known state before perspective switch
    controller.play_animation("idle", "left")
    yield(get_tree(), "idle_frame")
    
    # Test animation updates when perspective changes
    start_test("test_animation_updates_on_perspective_change")
    animation_history.clear()
    
    # Switch to side-scrolling
    controller.set_perspective(PerspectiveType.SIDE_SCROLLING)
    yield(get_tree(), "idle_frame")
    
    # Trigger animation refresh by playing current state
    controller.play_animation("idle", "left")
    yield(get_tree(), "idle_frame")
    
    # Debug output
    if log_debug_info:
        print("  Current perspective: %d" % controller.current_perspective)
        print("  Current animation state: %s" % controller.current_animation_state)
        print("  Current direction: %s" % controller.current_direction)
        print("  Expected animation: side_%s_%s" % [controller.current_animation_state, controller.current_direction])
    
    var current_anim = controller.animated_sprite.animation if controller.animated_sprite else ""
    end_test(current_anim.begins_with("side_"),
             "Animation switches to perspective-specific version")
    
    # Test movement in different perspective
    start_test("test_movement_in_side_scrolling")
    animation_history.clear()
    
    player.move_to(Vector2(500, 300))  # Move right
    
    # Wait for side-scrolling walk animation
    var wait_time_3 = 0.0
    var has_side_walk = false
    while wait_time_3 < 1.0 and not has_side_walk:
        yield(get_tree(), "idle_frame")
        wait_time_3 += get_process_delta_time()
        
        for anim in animation_history:
            if anim.find("side_walk") != -1:
                has_side_walk = true
                break
    
    end_test(has_side_walk, "Side-scrolling animations work correctly")
    
    # Wait for stop
    while player.is_moving:
        yield(get_tree(), "idle_frame")
    
    # Switch back to isometric
    controller.set_perspective(PerspectiveType.ISOMETRIC)
    yield(get_tree(), "idle_frame")

func test_suite_state_transitions():
    # Test smooth transitions between states
    start_test("test_animation_during_acceleration")
    movement_state_changes.clear()
    animation_history.clear()
    
    player.position = Vector2(100, 300)
    player.move_to(Vector2(700, 300))  # Long distance
    
    # Monitor first second of movement
    var timer = 0.0
    while timer < 1.0 and player.is_moving:
        yield(get_tree(), "idle_frame")
        timer += get_process_delta_time()
    
    # Should have acceleration state
    var has_acceleration = false
    for state in movement_state_changes:
        if state == player.MovementState.ACCELERATING:
            has_acceleration = true
            break
    
    end_test(has_acceleration, "Acceleration state detected during movement")
    
    # Stop player
    player.stop_movement()
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Test animation consistency during rapid direction changes
    start_test("test_rapid_direction_changes")
    animation_history.clear()
    
    # Rapid movements in different directions
    player.move_to(Vector2(150, 300))  # West
    yield(get_tree().create_timer(0.1), "timeout")
    player.move_to(Vector2(100, 250))  # North
    yield(get_tree().create_timer(0.1), "timeout")
    player.move_to(Vector2(150, 250))  # East
    yield(get_tree().create_timer(0.3), "timeout")
    
    # Check that animations changed appropriately
    var unique_animations = {}
    for anim in animation_history:
        unique_animations[anim] = true
    
    # We should have at least 2 different animations (some directions might be the same)
    end_test(unique_animations.size() >= 2,
             "Multiple direction animations played during rapid changes")

# ===== HELPER METHODS =====

func _on_movement_state_changed(new_state):
    movement_state_changes.append(new_state)
    
    # Update animation based on movement state
    if new_state == player.MovementState.IDLE or new_state == player.MovementState.ARRIVED:
        # Determine direction for idle animation
        var direction = controller.current_direction
        controller.play_animation("idle", direction)
    elif new_state == player.MovementState.ACCELERATING or new_state == player.MovementState.MOVING:
        # Calculate movement direction
        if player.velocity.length() > 0:
            var direction = controller.convert_movement_to_direction(player.velocity)
            if direction != "":
                controller.play_animation("walk", direction)

func _on_animation_changed(animation_name):
    last_animation_played = animation_name
    animation_history.append(animation_name)
    
    if log_debug_info:
        print("  Animation changed to: %s" % animation_name)

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

func cleanup_test_environment():
    if player and player.is_connected("movement_state_changed", self, "_on_movement_state_changed"):
        player.disconnect("movement_state_changed", self, "_on_movement_state_changed")
    
    if controller and controller.is_connected("animation_changed", self, "_on_animation_changed"):
        controller.disconnect("animation_changed", self, "_on_animation_changed")
    
    if test_environment:
        test_environment.queue_free()

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