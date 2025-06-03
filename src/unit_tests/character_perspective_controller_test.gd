extends Node2D
# CharacterPerspectiveController Test: Tests for the character perspective controller functionality

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for verbose output

# Test-specific flags
var test_controller_basics = true
var test_perspective_animations = true

# Test state
var test_name = "CharacterPerspectiveController"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var CharacterPerspectiveController = preload("res://src/characters/perspective/character_perspective_controller.gd")
var PerspectiveType = preload("res://src/core/perspective/perspective_type.gd")
var mock_character = null
var controller = null

# Signal tracking
var signal_received = false
var old_perspective_received = null
var new_perspective_received = null

func _ready():
    print("\n" + "==================================================")
    print(" %s TEST SUITE" % test_name.to_upper())
    print("==================================================" + "\n")
    
    yield(run_tests(), "completed")
    
    print("\n" + "==================================================")
    print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
    print("==================================================" + "\n")
    
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
    if run_all_tests or test_controller_basics:
        print("\n===== TEST SUITE: Controller Basic Tests =====")
        setup_test_scene()
        yield(test_suite_controller_basics(), "completed")
        cleanup_test_scene()
        yield(get_tree(), "idle_frame")
    
    if run_all_tests or test_perspective_animations:
        print("\n===== TEST SUITE: Perspective Animation Tests =====")
        test_suite_perspective_animations()

func test_suite_controller_basics():
    # Test controller initialization
    start_test("test_controller_initialization")
    controller = CharacterPerspectiveController.new()
    var init_ok = (controller != null and 
                   controller.current_perspective == PerspectiveType.ISOMETRIC and
                   controller.character_node == null and
                   controller.perspective_configs != null)
    end_test(init_ok, "Controller initializes with correct defaults")
    controller.queue_free()
    controller = null
    yield(get_tree(), "idle_frame")
    
    # Test attach to character
    start_test("test_attach_to_character")
    controller = CharacterPerspectiveController.new()
    controller.attach_to_character(mock_character)
    yield(get_tree(), "idle_frame")
    
    var attached = (controller.character_node == mock_character and
                   mock_character.has_node("PerspectiveController"))
    end_test(attached, "Controller attaches to character correctly")
    
    # Test set perspective
    start_test("test_set_perspective")
    controller.set_perspective(PerspectiveType.SIDE_SCROLLING)
    var side_set = controller.current_perspective == PerspectiveType.SIDE_SCROLLING
    
    controller.set_perspective(PerspectiveType.TOP_DOWN)
    var top_set = controller.current_perspective == PerspectiveType.TOP_DOWN
    
    end_test(side_set and top_set, "Perspective changes correctly")
    
    # Test perspective change signal
    start_test("test_perspective_change_signal")
    # Reset signal tracking
    signal_received = false
    old_perspective_received = null
    new_perspective_received = null
    
    # Reset to isometric first
    controller.set_perspective(PerspectiveType.ISOMETRIC)
    yield(get_tree(), "idle_frame")
    
    controller.connect("perspective_changed", self, "_on_perspective_changed")
    controller.set_perspective(PerspectiveType.SIDE_SCROLLING)
    yield(get_tree(), "idle_frame")
    
    end_test(signal_received and 
             old_perspective_received == PerspectiveType.ISOMETRIC and
             new_perspective_received == PerspectiveType.SIDE_SCROLLING,
             "Signal emitted with correct parameters")
    
    if controller.is_connected("perspective_changed", self, "_on_perspective_changed"):
        controller.disconnect("perspective_changed", self, "_on_perspective_changed")
    
    # Test get current configuration
    start_test("test_get_current_configuration")
    controller.set_perspective(PerspectiveType.ISOMETRIC)
    var config = controller.get_current_configuration()
    var has_config = config != null and config.perspective_type == PerspectiveType.ISOMETRIC
    
    controller.set_perspective(PerspectiveType.TOP_DOWN)
    config = controller.get_current_configuration()
    var updated_config = config != null and config.perspective_type == PerspectiveType.TOP_DOWN
    
    end_test(has_config and updated_config, "Configuration retrieved correctly")
    
    # Test direction conversion
    start_test("test_direction_conversion")
    controller.set_perspective(PerspectiveType.ISOMETRIC)
    var iso_dir = controller.convert_movement_to_direction(Vector2(1, 0))
    
    controller.set_perspective(PerspectiveType.SIDE_SCROLLING)
    var side_dir = controller.convert_movement_to_direction(Vector2(1, 0))
    
    end_test(iso_dir == "east" and side_dir == "right",
             "Direction conversion works for different perspectives")
    
    # Test invalid perspective handling
    start_test("test_invalid_perspective_handling")
    var original = controller.current_perspective
    controller.set_perspective(999)
    
    end_test(controller.current_perspective == original,
             "Invalid perspective rejected correctly")

func test_suite_perspective_animations():
    # Test animation prefix management
    start_test("test_animation_prefix_management")
    controller = CharacterPerspectiveController.new()
    
    var iso_prefix = controller.get_animation_prefix(PerspectiveType.ISOMETRIC)
    var side_prefix = controller.get_animation_prefix(PerspectiveType.SIDE_SCROLLING)
    var top_prefix = controller.get_animation_prefix(PerspectiveType.TOP_DOWN)
    
    end_test(iso_prefix == "iso_" and side_prefix == "side_" and top_prefix == "top_",
             "Animation prefixes are correct")
    controller.queue_free()
    controller = null
    
    # Test animation name conversion
    start_test("test_animation_name_conversion")
    controller = CharacterPerspectiveController.new()
    controller.current_perspective = PerspectiveType.ISOMETRIC
    
    var iso_anim = controller.get_perspective_animation_name("walk", "south")
    
    controller.current_perspective = PerspectiveType.SIDE_SCROLLING
    var side_anim = controller.get_perspective_animation_name("walk", "left")
    
    end_test(iso_anim == "iso_walk_south" and side_anim == "side_walk_left",
             "Animation names formatted correctly")
    controller.queue_free()
    controller = null
    
    # Test fallback animation handling
    start_test("test_fallback_animation_handling")
    controller = CharacterPerspectiveController.new()
    
    var walk_fallback = controller.get_fallback_animation("iso_walk_south")
    var idle_fallback = controller.get_fallback_animation("side_idle_left")
    
    end_test(walk_fallback == "walk" and idle_fallback == "idle",
             "Fallback animations extracted correctly")
    controller.queue_free()
    controller = null

# Helper functions
func setup_test_scene():
    mock_character = Node2D.new()
    mock_character.name = "TestCharacter"
    add_child(mock_character)
    yield(get_tree(), "idle_frame")

func cleanup_test_scene():
    if controller:
        if controller.has_signal("perspective_changed") and controller.is_connected("perspective_changed", self, "_on_perspective_changed"):
            controller.disconnect("perspective_changed", self, "_on_perspective_changed")
        controller.set_process(false)
        controller.queue_free()
        controller = null
    
    if mock_character:
        mock_character.queue_free()
        mock_character = null
    
    # Wait for cleanup
    yield(get_tree().create_timer(0.1), "timeout")

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

func _on_perspective_changed(old, new):
    signal_received = true
    old_perspective_received = old
    new_perspective_received = new