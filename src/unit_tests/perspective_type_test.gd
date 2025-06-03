extends Node2D
# PerspectiveType Test: Tests for the multi-perspective character system enums and configuration

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for verbose output

# Test-specific flags
var test_perspective_enum = true
var test_perspective_configuration = true

# Test state
var test_name = "PerspectiveType"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var PerspectiveType = preload("res://src/core/perspective/perspective_type.gd")
var PerspectiveConfiguration = preload("res://src/core/perspective/perspective_configuration.gd")

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
    if run_all_tests or test_perspective_enum:
        run_test_suite("PerspectiveType Enum Tests", funcref(self, "test_suite_perspective_enum"))
    
    if run_all_tests or test_perspective_configuration:
        run_test_suite("PerspectiveConfiguration Tests", funcref(self, "test_suite_perspective_configuration"))

func run_test_suite(suite_name: String, test_func: FuncRef):
    current_suite = suite_name
    print("\n===== TEST SUITE: %s =====" % suite_name)
    test_func.call_func()

func test_suite_perspective_enum():
    # Test enum constants exist
    start_test("test_perspective_enum_constants")
    var has_isometric = "ISOMETRIC" in PerspectiveType
    var has_side_scrolling = "SIDE_SCROLLING" in PerspectiveType
    var has_top_down = "TOP_DOWN" in PerspectiveType
    end_test(has_isometric and has_side_scrolling and has_top_down, 
             "All perspective constants exist")
    
    # Test enum values
    start_test("test_perspective_enum_values")
    var values_correct = (PerspectiveType.ISOMETRIC == 0 and 
                         PerspectiveType.SIDE_SCROLLING == 1 and 
                         PerspectiveType.TOP_DOWN == 2)
    end_test(values_correct, "Enum values are correct")
    
    # Test get_perspective_name function
    start_test("test_get_perspective_name")
    var iso_name = PerspectiveType.get_perspective_name(PerspectiveType.ISOMETRIC)
    var side_name = PerspectiveType.get_perspective_name(PerspectiveType.SIDE_SCROLLING)
    var top_name = PerspectiveType.get_perspective_name(PerspectiveType.TOP_DOWN)
    end_test(iso_name == "isometric" and side_name == "side_scrolling" and top_name == "top_down",
             "Perspective names are correct")
    
    # Test get_perspective_from_string
    start_test("test_get_perspective_from_string")
    var iso_from_string = PerspectiveType.get_perspective_from_string("isometric")
    var side_from_string = PerspectiveType.get_perspective_from_string("side_scrolling")
    var top_from_string = PerspectiveType.get_perspective_from_string("top_down")
    var invalid_from_string = PerspectiveType.get_perspective_from_string("invalid")
    end_test(iso_from_string == PerspectiveType.ISOMETRIC and 
             side_from_string == PerspectiveType.SIDE_SCROLLING and
             top_from_string == PerspectiveType.TOP_DOWN and
             invalid_from_string == PerspectiveType.ISOMETRIC,
             "String to perspective conversion works correctly")
    
    # Test get_valid_directions
    start_test("test_get_valid_directions_isometric")
    var isometric_dirs = PerspectiveType.get_valid_directions(PerspectiveType.ISOMETRIC)
    var iso_correct = (isometric_dirs.size() == 8 and
                      "north" in isometric_dirs and "northeast" in isometric_dirs and
                      "east" in isometric_dirs and "southeast" in isometric_dirs and
                      "south" in isometric_dirs and "southwest" in isometric_dirs and
                      "west" in isometric_dirs and "northwest" in isometric_dirs)
    end_test(iso_correct, "Isometric has 8 valid directions")
    
    start_test("test_get_valid_directions_side_scrolling")
    var side_dirs = PerspectiveType.get_valid_directions(PerspectiveType.SIDE_SCROLLING)
    var side_correct = (side_dirs.size() == 2 and "left" in side_dirs and "right" in side_dirs)
    end_test(side_correct, "Side scrolling has 2 valid directions")
    
    start_test("test_get_valid_directions_top_down")
    var top_dirs = PerspectiveType.get_valid_directions(PerspectiveType.TOP_DOWN)
    var top_correct = (top_dirs.size() == 4 and
                      "north" in top_dirs and "east" in top_dirs and
                      "south" in top_dirs and "west" in top_dirs)
    end_test(top_correct, "Top down has 4 valid directions")

func test_suite_perspective_configuration():
    # Test configuration creation
    start_test("test_create_default_configuration")
    var config = PerspectiveConfiguration.new()
    end_test(config != null and 
             config.movement_speed_multiplier != null and
             config.sprite_scale != null and
             config.direction_count != null,
             "Default configuration has required properties")
    
    # Test isometric configuration
    start_test("test_isometric_configuration")
    var iso_config = PerspectiveConfiguration.create_isometric_config()
    var iso_valid = (iso_config.perspective_type == PerspectiveType.ISOMETRIC and
                    iso_config.direction_count == 8 and
                    iso_config.movement_speed_multiplier == 1.0 and
                    iso_config.sprite_scale == Vector2(1.0, 1.0) and
                    iso_config.supports_diagonal_movement == true)
    end_test(iso_valid, "Isometric configuration is correct")
    
    # Test side scrolling configuration
    start_test("test_side_scrolling_configuration")
    var side_config = PerspectiveConfiguration.create_side_scrolling_config()
    var side_valid = (side_config.perspective_type == PerspectiveType.SIDE_SCROLLING and
                     side_config.direction_count == 2 and
                     side_config.movement_speed_multiplier == 1.2 and
                     side_config.sprite_scale == Vector2(1.0, 1.0) and
                     side_config.supports_diagonal_movement == false)
    end_test(side_valid, "Side scrolling configuration is correct")
    
    # Test top down configuration
    start_test("test_top_down_configuration")
    var top_config = PerspectiveConfiguration.create_top_down_config()
    var top_valid = (top_config.perspective_type == PerspectiveType.TOP_DOWN and
                    top_config.direction_count == 4 and
                    top_config.movement_speed_multiplier == 1.0 and
                    top_config.sprite_scale == Vector2(0.8, 0.8) and
                    top_config.supports_diagonal_movement == false)
    end_test(top_valid, "Top down configuration is correct")
    
    # Test configuration validation
    start_test("test_configuration_validation")
    var test_config = PerspectiveConfiguration.new()
    
    # Test negative direction count
    test_config.direction_count = -1
    var invalid1 = !test_config.is_valid()
    
    # Test zero speed multiplier
    test_config.direction_count = 8
    test_config.movement_speed_multiplier = 0
    var invalid2 = !test_config.is_valid()
    
    # Test zero sprite scale
    test_config.movement_speed_multiplier = 1.0
    test_config.sprite_scale = Vector2(0, 0)
    var invalid3 = !test_config.is_valid()
    
    # Test valid configuration
    test_config.sprite_scale = Vector2(1.0, 1.0)
    var valid = test_config.is_valid()
    
    end_test(invalid1 and invalid2 and invalid3 and valid,
             "Configuration validation works correctly")

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