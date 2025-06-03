extends Node2D
# Perspective District Component Test: Tests integration between district and perspective systems

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for verbose output

# Test-specific flags
var test_district_perspective_integration = true
var test_perspective_configuration_loading = true

# Test state
var test_name = "PerspectiveDistrictComponent"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var PerspectiveType = preload("res://src/core/perspective/perspective_type.gd")
var PerspectiveConfiguration = preload("res://src/core/perspective/perspective_configuration.gd")
var MockDistrict = preload("res://src/component_tests/mocks/mock_district_with_perspective.gd")
var CharacterPerspectiveController = preload("res://src/characters/perspective/character_perspective_controller.gd")

var mock_district = null
var test_character = null
var perspective_controller = null

func _ready():
    print("\n" + "==================================================")
    print(" %s TEST SUITE" % test_name.to_upper())
    print("==================================================" + "\n")
    
    run_tests()
    
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
    if run_all_tests or test_district_perspective_integration:
        run_test_suite("District Perspective Integration", funcref(self, "test_suite_district_perspective"))
    
    if run_all_tests or test_perspective_configuration_loading:
        run_test_suite("Perspective Configuration Loading", funcref(self, "test_suite_configuration_loading"))

func run_test_suite(suite_name: String, test_func: FuncRef):
    current_suite = suite_name
    print("\n===== TEST SUITE: %s =====" % suite_name)
    test_func.call_func()

func test_suite_district_perspective():
    # Test district has perspective information
    start_test("test_district_perspective_property")
    setup_test_scene()
    
    var has_perspective = (mock_district.has("perspective_type") and
                          mock_district.perspective_type == PerspectiveType.ISOMETRIC)
    end_test(has_perspective, "District has perspective property")
    cleanup_test_scene()
    
    # Test character detects district perspective
    start_test("test_character_detects_district_perspective")
    setup_test_scene_with_character()
    
    var detected = perspective_controller.current_perspective == mock_district.perspective_type
    end_test(detected, "Character controller detects district perspective")
    cleanup_test_scene()
    
    # Test perspective change when entering new district
    start_test("test_perspective_change_on_district_change")
    setup_test_scene_with_character()
    
    # Change district perspective
    mock_district.perspective_type = PerspectiveType.SIDE_SCROLLING
    mock_district.emit_signal("perspective_changed", PerspectiveType.SIDE_SCROLLING)
    yield(get_tree(), "idle_frame")
    
    var changed = perspective_controller.current_perspective == PerspectiveType.SIDE_SCROLLING
    end_test(changed, "Character perspective updates with district change")
    cleanup_test_scene()
    
    # Test district provides perspective configuration
    start_test("test_district_provides_configuration")
    setup_test_scene()
    
    var config = mock_district.get_perspective_configuration()
    var has_config = (config != null and 
                     config.perspective_type == mock_district.perspective_type)
    end_test(has_config, "District provides perspective configuration")
    cleanup_test_scene()

func test_suite_configuration_loading():
    # Test loading configuration from district
    start_test("test_load_configuration_from_district")
    setup_test_scene_with_character()
    
    var district_config = mock_district.get_perspective_configuration()
    var controller_config = perspective_controller.get_current_configuration()
    
    var configs_match = (district_config != null and controller_config != null and
                        district_config.perspective_type == controller_config.perspective_type and
                        district_config.direction_count == controller_config.direction_count)
    end_test(configs_match, "Controller loads configuration from district")
    cleanup_test_scene()
    
    # Test configuration affects character behavior
    start_test("test_configuration_affects_behavior")
    setup_test_scene_with_character()
    
    # Test isometric directions
    mock_district.perspective_type = PerspectiveType.ISOMETRIC
    perspective_controller.set_perspective(PerspectiveType.ISOMETRIC)
    var iso_dirs = PerspectiveType.get_valid_directions(PerspectiveType.ISOMETRIC)
    
    # Test side scrolling directions
    mock_district.perspective_type = PerspectiveType.SIDE_SCROLLING
    perspective_controller.set_perspective(PerspectiveType.SIDE_SCROLLING)
    var side_dirs = PerspectiveType.get_valid_directions(PerspectiveType.SIDE_SCROLLING)
    
    end_test(iso_dirs.size() == 8 and side_dirs.size() == 2,
             "Configuration affects valid directions")
    cleanup_test_scene()
    
    # Test configuration persistence
    start_test("test_configuration_persistence")
    setup_test_scene_with_character()
    
    # Store original config
    var original_type = perspective_controller.current_perspective
    
    # Change and revert
    perspective_controller.set_perspective(PerspectiveType.TOP_DOWN)
    perspective_controller.set_perspective(original_type)
    
    var reverted = perspective_controller.current_perspective == original_type
    end_test(reverted, "Configuration can be changed and reverted")
    cleanup_test_scene()

# Helper functions
func setup_test_scene():
    # Create mock district with perspective
    mock_district = MockDistrict.new()
    mock_district.name = "TestDistrict"
    mock_district.add_to_group("district")
    add_child(mock_district)
    yield(get_tree(), "idle_frame")

func setup_test_scene_with_character():
    setup_test_scene()
    
    # Create test character
    test_character = Node2D.new()
    test_character.name = "TestCharacter"
    add_child(test_character)
    
    # Add perspective controller
    perspective_controller = CharacterPerspectiveController.new()
    perspective_controller.attach_to_character(test_character)
    
    # Connect to district
    if mock_district.has_signal("perspective_changed"):
        mock_district.connect("perspective_changed", perspective_controller, "set_perspective")
    
    yield(get_tree(), "idle_frame")

func cleanup_test_scene():
    if perspective_controller:
        perspective_controller.queue_free()
        perspective_controller = null
    
    if test_character:
        test_character.queue_free()
        test_character = null
    
    if mock_district:
        mock_district.queue_free()
        mock_district = null
    
    yield(get_tree(), "idle_frame")

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