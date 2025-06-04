extends Node2D
# District Perspective Test: Tests perspective support in BaseDistrict class

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for verbose output

# Test-specific flags
var test_perspective_properties = true
var test_perspective_configuration = true
var test_perspective_signals = true
var test_backward_compatibility = true

# Test state
var test_name = "DistrictPerspective"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var BaseDistrict = preload("res://src/core/districts/base_district.gd")
var PerspectiveType = preload("res://src/core/perspective/perspective_type.gd")
var PerspectiveConfiguration = preload("res://src/core/perspective/perspective_configuration.gd")
var MockDistrict = preload("res://src/unit_tests/mocks/mock_district.gd")

var test_district = null
var signal_received = false
var received_perspective = null

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
    if run_all_tests or test_perspective_properties:
        run_test_suite("Perspective Properties", funcref(self, "test_suite_perspective_properties"))
    
    if run_all_tests or test_perspective_configuration:
        run_test_suite("Perspective Configuration", funcref(self, "test_suite_perspective_configuration"))
    
    if run_all_tests or test_perspective_signals:
        run_test_suite("Perspective Signals", funcref(self, "test_suite_perspective_signals"))
    
    if run_all_tests or test_backward_compatibility:
        run_test_suite("Backward Compatibility", funcref(self, "test_suite_backward_compatibility"))

func run_test_suite(suite_name: String, test_func: FuncRef):
    current_suite = suite_name
    print("\n===== TEST SUITE: %s =====" % suite_name)
    test_func.call_func()

func test_suite_perspective_properties():
    # Test that perspective_type property exists
    start_test("test_perspective_type_property_exists")
    setup_test_district()
    
    var has_property = test_district.has("perspective_type")
    end_test(has_property, "District has perspective_type property")
    cleanup_test_district()
    
    # Test default perspective type
    start_test("test_default_perspective_type")
    setup_test_district()
    
    var is_isometric = test_district.perspective_type == PerspectiveType.ISOMETRIC
    end_test(is_isometric, "Default perspective type is ISOMETRIC")
    cleanup_test_district()
    
    # Test setting perspective type
    start_test("test_set_perspective_type")
    setup_test_district()
    
    test_district.perspective_type = PerspectiveType.SIDE_SCROLLING
    var is_set = test_district.perspective_type == PerspectiveType.SIDE_SCROLLING
    end_test(is_set, "Can set perspective type")
    cleanup_test_district()
    
    # Test perspective parameters property
    start_test("test_perspective_parameters_property")
    setup_test_district()
    
    var has_params = test_district.has("perspective_parameters")
    end_test(has_params, "District has perspective_parameters property")
    cleanup_test_district()

func test_suite_perspective_configuration():
    # Test get_perspective_configuration method
    start_test("test_get_perspective_configuration_method")
    setup_test_district()
    
    var has_method = test_district.has_method("get_perspective_configuration")
    end_test(has_method, "District has get_perspective_configuration method")
    cleanup_test_district()
    
    # Test configuration returns correct type
    start_test("test_configuration_returns_correct_type")
    setup_test_district()
    
    if test_district.has_method("get_perspective_configuration"):
        var config = test_district.get_perspective_configuration()
        var correct_type = (config != null and 
                           config.has("perspective_type") and
                           config.perspective_type == test_district.perspective_type)
        end_test(correct_type, "Configuration matches district perspective type")
    else:
        end_test(false, "get_perspective_configuration method not found")
    cleanup_test_district()
    
    # Test configuration with custom parameters
    start_test("test_configuration_with_custom_parameters")
    setup_test_district()
    
    if test_district.has("perspective_parameters"):
        test_district.perspective_parameters = {"custom_param": 42}
        if test_district.has_method("get_perspective_configuration"):
            var config = test_district.get_perspective_configuration()
            var has_custom = (config != null and 
                             config.has("custom_param") and
                             config.custom_param == 42)
            end_test(has_custom, "Configuration includes custom parameters")
        else:
            end_test(false, "get_perspective_configuration method not found")
    else:
        end_test(false, "perspective_parameters property not found")
    cleanup_test_district()
    
    # Test configuration for different perspective types
    start_test("test_configuration_for_different_types")
    setup_test_district()
    
    var configs_valid = true
    var perspective_types = [
        PerspectiveType.ISOMETRIC,
        PerspectiveType.SIDE_SCROLLING,
        PerspectiveType.TOP_DOWN
    ]
    
    for type in perspective_types:
        test_district.perspective_type = type
        if test_district.has_method("get_perspective_configuration"):
            var config = test_district.get_perspective_configuration()
            if config == null or config.perspective_type != type:
                configs_valid = false
                break
        else:
            configs_valid = false
            break
    
    end_test(configs_valid, "Configuration works for all perspective types")
    cleanup_test_district()

func test_suite_perspective_signals():
    # Test perspective_changed signal exists
    start_test("test_perspective_changed_signal_exists")
    setup_test_district()
    
    var has_signal = test_district.has_signal("perspective_changed")
    end_test(has_signal, "District has perspective_changed signal")
    cleanup_test_district()
    
    # Test signal emitted on perspective change
    start_test("test_signal_emitted_on_change")
    setup_test_district()
    
    if test_district.has_signal("perspective_changed"):
        test_district.connect("perspective_changed", self, "_on_perspective_changed")
        signal_received = false
        received_perspective = null
        
        # Change perspective
        if test_district.has_method("set_perspective_type"):
            test_district.set_perspective_type(PerspectiveType.TOP_DOWN)
        else:
            test_district.perspective_type = PerspectiveType.TOP_DOWN
            if test_district.has_method("_emit_perspective_changed"):
                test_district._emit_perspective_changed()
        
        yield(get_tree(), "idle_frame")
        
        end_test(signal_received and received_perspective == PerspectiveType.TOP_DOWN,
                 "Signal emitted with correct perspective type")
    else:
        end_test(false, "perspective_changed signal not found")
    cleanup_test_district()
    
    # Test signal not emitted when setting same perspective
    start_test("test_no_signal_on_same_perspective")
    setup_test_district()
    
    if test_district.has_signal("perspective_changed"):
        test_district.connect("perspective_changed", self, "_on_perspective_changed")
        signal_received = false
        
        # Set to same perspective
        var current = test_district.perspective_type
        if test_district.has_method("set_perspective_type"):
            test_district.set_perspective_type(current)
        else:
            test_district.perspective_type = current
        
        yield(get_tree(), "idle_frame")
        
        end_test(!signal_received, "No signal when perspective unchanged")
    else:
        end_test(false, "perspective_changed signal not found")
    cleanup_test_district()

func test_suite_backward_compatibility():
    # Test existing districts work without perspective
    start_test("test_mock_district_compatibility")
    var mock = MockDistrict.new()
    mock.name = "MockDistrict"
    add_child(mock)
    yield(get_tree(), "idle_frame")
    
    # District should still initialize
    var initialized = mock.district_name != null and mock.district_name != ""
    end_test(initialized, "Existing districts work without perspective support")
    
    mock.queue_free()
    yield(get_tree(), "idle_frame")
    
    # Test default values don't break existing functionality
    start_test("test_default_values_safe")
    setup_test_district()
    
    # Test walkable areas still work
    var walkable_test = test_district.is_position_walkable(Vector2(100, 100))
    var has_walkable_method = test_district.has_method("is_position_walkable")
    
    end_test(has_walkable_method, "Walkable area methods still work")
    cleanup_test_district()
    
    # Test camera setup still works
    start_test("test_camera_setup_compatible")
    setup_test_district()
    
    test_district.use_scrolling_camera = true
    if test_district.has_method("setup_scrolling_camera"):
        test_district.setup_scrolling_camera()
        var camera_exists = test_district.camera != null
        end_test(camera_exists, "Camera setup still works with perspective")
    else:
        end_test(false, "setup_scrolling_camera method not found")
    cleanup_test_district()

# Helper functions
func setup_test_district():
    test_district = BaseDistrict.new()
    test_district.name = "TestDistrict"
    test_district.district_name = "Test District"
    add_child(test_district)
    yield(get_tree(), "idle_frame")

func cleanup_test_district():
    if test_district:
        if test_district.has_signal("perspective_changed"):
            if test_district.is_connected("perspective_changed", self, "_on_perspective_changed"):
                test_district.disconnect("perspective_changed", self, "_on_perspective_changed")
        test_district.queue_free()
        test_district = null
    yield(get_tree(), "idle_frame")

func _on_perspective_changed(new_perspective):
    signal_received = true
    received_perspective = new_perspective

func start_test(name: String):
    current_test = name
    if log_debug_info:
        print("\n[TEST] " + name)

func end_test(passed: bool, message: String):
    if passed:
        tests_passed += 1
        print("  ✓ PASS: %s: %s" % [current_test, message])
    else:
        tests_failed += 1
        failed_tests.append(current_test)
        print("  ✗ FAIL: %s: %s" % [current_test, message])