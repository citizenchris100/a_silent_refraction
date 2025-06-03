# Unit Testing Guide for A Silent Refraction

## Overview

This guide documents the unit testing system used in A Silent Refraction. The system is custom-built for Godot 3.5.2 and provides a lightweight, headless testing framework without external dependencies.

## Scope Definition

Unit tests focus on testing **single components in isolation**. They verify the internal logic and behavior of individual classes, functions, or systems without dependencies on other components. Unit tests are:

- **Scope**: Single component/class/system
- **Focus**: Internal logic, state management, calculations, and component correctness
- **Dependencies**: Heavy use of mocks to isolate the component under test
- **Speed**: Fast execution (milliseconds)
- **Purpose**: Ensure each component works correctly on its own

For testing interactions between 2-3 components, see the [Component Testing Guide](component_testing_guide.md). For testing 4+ components working together, see the [Subsystem Testing Guide](subsystem_testing_guide.md).

## Quick Start

### Running Tests

```bash
# Run all tests
./tools/run_unit_tests.sh

# Run specific test(s)
./tools/run_unit_tests.sh coordinate_system_test
./tools/run_unit_tests.sh coordinate_system_test camera_state_test

# Run with full scene name
./tools/run_unit_tests.sh coordinate_system_test.tscn
```

### Test Output

Tests produce colored console output:
- ✓ Green checkmarks for passed tests
- ✗ Red X marks for failed tests
- Yellow headers for test suites
- Summary statistics at the end

### Log Files

All test runs generate logs in the `/logs/` directory:
- Individual test logs: `{test_name}_{timestamp}.log`
- Master log file: `unit_tests_{timestamp}.log`
- Contains full Godot output including any errors or warnings

## Creating New Tests

### 1. File Structure

Each test requires two files in `/src/unit_tests/`:
- `{component}_test.gd` - The test script
- `{component}_test.tscn` - The scene file

Example for a new "inventory" test:
- `/src/unit_tests/inventory_test.gd`
- `/src/unit_tests/inventory_test.tscn`

### 2. Basic Test Template

```gdscript
extends Node2D
# Component Test: Brief description of what's being tested

# ===== TEST CONFIGURATION =====
var run_all_tests = true  # Set to false to run only specific tests
var log_debug_info = true  # Set to true for verbose output

# Test-specific flags
var test_feature_one = true
var test_feature_two = true

# Test state
var test_name = "ComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# Test objects
var MyClass = preload("res://src/path/to/class.gd")
var test_object = null

func _ready():
	print("\n" + "="*50)
	print(" %s TEST SUITE" % test_name.to_upper())
	print("="*50 + "\n")
	
	run_tests()
	
	print("\n" + "="*50)
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("="*50 + "\n")
	
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
	if run_all_tests or test_feature_one:
		run_test_suite("Feature One Tests", funcref(self, "test_suite_feature_one"))
	
	if run_all_tests or test_feature_two:
		run_test_suite("Feature Two Tests", funcref(self, "test_suite_feature_two"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

func test_suite_feature_one():
	# Test 1
	start_test("test_basic_functionality")
	var result = test_object.some_method()
	end_test(result == expected_value, "Basic functionality works")
	
	# Test 2
	start_test("test_edge_case")
	var edge_result = test_object.handle_edge_case()
	end_test(edge_result != null, "Edge case handled properly")

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
```

### 3. Scene File Template

Create a minimal scene file:

```
[gd_scene load_steps=2 format=2]

[ext_resource path="res://src/unit_tests/{component}_test.gd" type="Script" id=1]

[node name="{ComponentName}Test" type="Node2D"]
script = ExtResource( 1 )
```

## Test Patterns

### Method 1: Start/End Test Pattern (Recommended)

This is the most common pattern in the codebase:

```gdscript
func test_suite_example():
	# Setup
	var obj = MyClass.new()
	
	# Test
	start_test("test_method_returns_correct_value")
	var result = obj.calculate(5, 10)
	end_test(result == 15, "Calculate returns correct sum")
	
	# Cleanup
	obj.queue_free()
```

### Method 2: Traditional Assertions

Some tests use assertion-style methods:

```gdscript
func test_with_assertions():
	setup_test_object()
	
	assert_true(obj.is_valid(), "Object should be valid")
	assert_eq(obj.value, 42, "Value should be 42")
	assert_has_signal(obj, "value_changed", "Should have value_changed signal")
	
	teardown_test_object()

# Helper assertions
func assert_true(condition: bool, message: String = ""):
	if condition:
		log_pass(message)
	else:
		log_fail(message)

func assert_eq(actual, expected, message: String = ""):
	if actual == expected:
		log_pass(message)
	else:
		log_fail("%s - Expected: %s, Got: %s" % [message, str(expected), str(actual)])
```

## Using Mocks

Mock objects are stored in `/src/unit_tests/mocks/`. They provide minimal implementations for testing:

### Creating a Mock

```gdscript
# src/unit_tests/mocks/mock_game_manager.gd
extends Node

var dialog_manager = null
var npc_clicked_count = 0
var last_clicked_npc = null

func handle_npc_clicked(npc):
	npc_clicked_count += 1
	last_clicked_npc = npc
	
	if dialog_manager:
		dialog_manager.start_dialog(npc)

func _ready():
	# Minimal setup
	pass
```

### Using Mocks in Tests

```gdscript
var MockGameManager = preload("res://src/unit_tests/mocks/mock_game_manager.gd")

func test_with_mock():
	var mock_gm = MockGameManager.new()
	add_child(mock_gm)
	
	# Test using mock
	mock_gm.handle_npc_clicked(test_npc)
	
	assert_eq(mock_gm.npc_clicked_count, 1, "Click count incremented")
	assert_eq(mock_gm.last_clicked_npc, test_npc, "Correct NPC recorded")
	
	mock_gm.queue_free()
```

## Best Practices

### 1. Test Organization

- Group related tests into suites using `test_suite_*` functions
- Use configuration flags to control test execution
- Keep test methods focused on single behaviors

### 2. Setup and Teardown

**IMPORTANT: Always add test objects to the scene tree!**

Many Godot features require objects to be in the scene tree to function properly:
- Signal connections
- `_ready()` callbacks  
- `get_tree()` access
- Group membership
- Node paths
- Physics processing

```gdscript
func setup_test_scene():
	# Create test objects
	test_object = MyClass.new()
	add_child(test_object)  # CRITICAL: Add to scene tree!
	yield(get_tree(), "idle_frame")  # Let scene initialize

func cleanup_test_scene():
	if test_object:
		test_object.queue_free()
		test_object = null
	yield(get_tree(), "idle_frame")  # Ensure cleanup completes
```

**Common Pattern:**
```gdscript
# ✅ CORRECT - Object added to scene tree
var player = Player.new()
add_child(player)
yield(get_tree(), "idle_frame")  # Let _ready() run

# ❌ WRONG - Object not in scene tree
var player = Player.new()
# Attempting to use player here may fail!
```

### 3. Handling Async Operations

```gdscript
func test_async_operation():
	start_test("test_signal_emission")
	
	var signal_received = false
	test_object.connect("operation_complete", self, "_on_test_signal")
	
	test_object.start_operation()
	
	# Wait for signal or timeout
	var timer = 0.0
	while !signal_received and timer < 1.0:
		yield(get_tree(), "idle_frame")
		timer += get_process_delta_time()
	
	end_test(signal_received, "Signal emitted within timeout")
```

### 3.1 Test Suite Yield Pattern

When writing test suites with multiple tests that use yields, follow the established pattern:

**❌ WRONG - Individual test cleanup pattern:**
```gdscript
func test_suite_example():
    # Test 1
    start_test("test_something")
    setup_test_objects()
    yield(get_tree(), "idle_frame")
    # ... test logic ...
    end_test(condition, "message")
    cleanup_test_objects()  # DON'T cleanup inside suite
    
    # Test 2 - This may not run!
    start_test("test_another_thing")
    # ...
```

**✅ CORRECT - Suite-level setup/cleanup pattern:**
```gdscript
func _ready():
    yield(run_tests(), "completed")  # Yield on run_tests if it's a coroutine
    # ... print summary ...
    get_tree().quit(tests_failed)

func run_tests():
    if run_all_tests or test_feature:
        print("\n===== TEST SUITE: Feature Tests =====")
        setup_test_scene()  # Setup once for the suite
        yield(test_suite_feature(), "completed")  # Yield on the suite
        cleanup_test_scene()  # Cleanup once after suite
        yield(get_tree(), "idle_frame")

func test_suite_feature():
    # Test 1
    start_test("test_something")
    # ... test logic with yields ...
    yield(get_tree(), "idle_frame")
    end_test(condition, "message")
    
    # Test 2 - This WILL run
    start_test("test_another_thing")
    # ... more tests ...
    
    # No cleanup here - done at suite level

func setup_test_scene():
    # Create test objects
    test_obj = TestClass.new()
    add_child(test_obj)
    yield(get_tree(), "idle_frame")

func cleanup_test_scene():
    if test_obj:
        test_obj.set_process(false)  # Disable processing first
        test_obj.queue_free()
        test_obj = null
    yield(get_tree().create_timer(0.1), "timeout")
```

**Key Points:**
- Setup/cleanup happen at the suite level, not per test
- Individual tests run sequentially within a suite
- Only yield on suite functions in `run_tests()`, not on individual test functions
- If test functions don't yield, don't try to yield on them
- Always disable processing before cleanup to prevent hanging yields

### 4. Test Independence

- Each test should be independent
- Don't rely on test execution order
- Clean up all created objects
- Reset global state if modified

### 5. Meaningful Test Names

Use descriptive test names that explain what's being tested:
- ✅ `test_player_stops_at_walkable_boundary`
- ❌ `test_1` or `test_boundary`

### 6. Performance Considerations

```gdscript
# For performance-critical tests
var PERFORMANCE_TEST_TIMEOUT = 5.0  # seconds

func test_performance():
	start_test("test_operation_completes_quickly")
	
	var start_time = OS.get_ticks_msec()
	
	# Run operation many times
	for i in range(1000):
		test_object.expensive_operation()
	
	var elapsed = (OS.get_ticks_msec() - start_time) / 1000.0
	end_test(elapsed < PERFORMANCE_TEST_TIMEOUT, 
		"Operation completed in %.2fs (limit: %.2fs)" % [elapsed, PERFORMANCE_TEST_TIMEOUT])
```

## Common Issues and Solutions

### Issue: String Multiplication Parse Error

**Problem**: Parse error with string multiplication like `"="*50`
**Solution**: GDScript doesn't support string multiplication. Use explicit strings instead:
```gdscript
# ❌ WRONG - Will cause parse error
print("="*50)

# ✅ CORRECT - Use explicit string
print("==================================================")
```

### Issue: Test Timeout

**Problem**: Test exceeds 60-second timeout
**Solution**: 
- Break up large tests into smaller units
- For legitimately long tests, modify timeout in `run_unit_tests.sh`

### Issue: Scene Tree Errors

**Problem**: "Attempt to call function in base 'null instance'"
**Solution**: 
- Ensure objects are added to scene tree with `add_child()`
- Use `yield(get_tree(), "idle_frame")` after scene modifications

### Issue: Resource Loading

**Problem**: "Failed loading resource" errors
**Solution**:
- Use `preload()` instead of `load()` for test dependencies
- Ensure all file paths start with `res://`

### Issue: Signal Connection Errors

**Problem**: "Signal not found" or connection failures
**Solution**:
```gdscript
# Check signal exists before connecting
if obj.has_signal("my_signal"):
	obj.connect("my_signal", self, "_on_signal")
```

## Integration with CI/CD

The test system is designed for CI/CD integration:

1. **Exit Codes**: Tests return 0 for success, non-zero for failure
2. **Headless Mode**: Tests run without window using `--no-window`
3. **Timeout Protection**: Prevents hanging builds
4. **Log Artifacts**: Generated logs can be collected as build artifacts

Example CI script:
```bash
#!/bin/bash
./tools/run_unit_tests.sh
TEST_RESULT=$?

# Archive logs
tar -czf test_logs.tar.gz logs/

exit $TEST_RESULT
```

## Adding Tests to Existing Test Files

To add new tests to an existing test file:

1. Add a new test configuration flag if needed:
```gdscript
var test_new_feature = true  # Add with other test flags
```

2. Add test to `run_tests()`:
```gdscript
if run_all_tests or test_new_feature:
	run_test_suite("New Feature Tests", funcref(self, "test_suite_new_feature"))
```

3. Implement the test suite:
```gdscript
func test_suite_new_feature():
	start_test("test_new_behavior")
	# Test implementation
	end_test(condition, "New behavior works correctly")
```

## Testing Within the District Architecture

### When to Use Base District in Tests

According to the base district system documentation, certain systems MUST be tested within the proper district architecture:

1. **Camera System Tests** - The ScrollingCamera depends on base_district
2. **Coordinate Conversion Tests** - CoordinateManager expects a current district
3. **Player Input Tests** - Input handling uses CoordinateManager which needs district context
4. **Walkable Area Tests** - These are inherently part of the district system

For these tests, your test file should extend base_district rather than Node2D:

```gdscript
# ✅ CORRECT - Testing camera/coordinate systems
extends "res://src/core/districts/base_district.gd"

# ❌ WRONG - Will cause issues with camera and coordinate systems
extends Node2D
```

### Creating District-Based Unit Tests

When your test requires the district architecture:

```gdscript
extends "res://src/core/districts/base_district.gd"
# Test Name: Description of what's being tested

# Test state variables
var test_name = "DistrictBasedTest"
var tests_passed = 0
var tests_failed = 0
# ... other test variables ...

func _ready():
    # Set up the district first
    district_name = "Test District"
    district_description = "Unit test district"
    
    # Create minimal required nodes
    setup_test_district()
    
    # Call parent _ready() - This sets up camera and systems
    ._ready()
    
    # Wait for initialization
    yield(get_tree().create_timer(0.2), "timeout")
    
    # Run tests
    yield(run_tests(), "completed")
    
    # Exit with test results
    get_tree().quit(tests_failed)

func setup_test_district():
    # Create background (required by base_district)
    var background = Sprite.new()
    background.name = "Background"
    
    # Create a minimal texture
    var image = Image.new()
    image.create(1920, 1080, false, Image.FORMAT_RGB8)
    image.fill(Color(0.2, 0.2, 0.2))
    var texture = ImageTexture.new()
    texture.create_from_image(image)
    background.texture = texture
    background.centered = false
    add_child(background)
    
    # Set background size for camera
    background_size = background.texture.get_size()
    
    # Create walkable areas if needed
    create_test_walkable_areas()

func create_test_walkable_areas():
    var walkable_container = Node2D.new()
    walkable_container.name = "WalkableAreas"
    add_child(walkable_container)
    
    # Add test walkable area
    var area = Polygon2D.new()
    area.polygon = PoolVector2Array([
        Vector2(0, 400),
        Vector2(1920, 400),
        Vector2(1920, 800),
        Vector2(0, 800)
    ])
    area.add_to_group("walkable_area")
    walkable_container.add_child(area)
```

### Benefits of District-Based Testing

1. **Proper System Integration** - Camera, coordinates, and input work as in the actual game
2. **CoordinateManager Access** - The singleton can find the camera through the district
3. **Realistic Testing** - Tests the actual architecture, not artificial scenarios
4. **Automatic Setup** - Base district handles camera creation and configuration

### When NOT to Use District-Based Tests

Simple unit tests that don't involve camera, coordinates, or district-specific features should still use the standard Node2D approach:

- Pure logic tests (calculations, data structures)
- Signal emission tests
- Simple state machine tests
- Mock-based interaction tests

## Testing Player Movement and Districts

### Overview

Testing player movement often requires simulating districts and walkable areas. This section covers patterns specific to these tests.

### District and Player Dependencies

The player controller has these key dependencies:
1. Searches for districts in the "district" group
2. Expects districts to have `is_position_walkable(position)` method
3. Won't move if the target position isn't walkable

### Test Isolation vs Integration

#### Isolated Physics Testing
When testing only physics behavior (acceleration, deceleration, states):
```gdscript
# Bypass walkable area validation
player.position = Vector2(100, 100)
player.target_position = Vector2(500, 100)
player.is_moving = true
player._set_movement_state(player.MovementState.ACCELERATING)

# Now test physics
player._physics_process(0.016)
assert_ne(player.position.x, 100, "Player should move")
```

#### Integration Testing with Walkable Areas
When testing the full movement system:
```gdscript
# Set up mock district with walkable areas
mock_district = Node2D.new()
mock_district.add_to_group("district")
mock_district.set_script(preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd"))
add_child(mock_district)

# Create walkable area
var walkable = Polygon2D.new()
walkable.polygon = PoolVector2Array([
    Vector2(0, 0),
    Vector2(600, 0),
    Vector2(600, 400),
    Vector2(0, 400)
])
# IMPORTANT: Add to walkable_area group for proper detection
walkable.add_to_group("walkable_area")
mock_district.add_child(walkable)
mock_district.add_walkable_area(walkable)

# Create player - will find district automatically
player = Player.new()
player.position = Vector2(100, 100)
add_child(player)
yield(get_tree(), "idle_frame")

# Test movement through normal API
player.move_to(Vector2(500, 100))
```

### Mock District Patterns

#### Minimal Mock (for non-movement tests)
```gdscript
# In mock_district_minimal.gd
extends Node2D

var district_name = "Test District"

func is_position_walkable(pos):
    return true  # Always walkable for simple tests
```

#### Full Mock (for movement validation)
```gdscript
# In mock_district_with_walkable.gd
extends Node2D

var district_name = "Test District"
var walkable_areas = []

func add_walkable_area(area):
    walkable_areas.append(area)

func is_position_walkable(position):
    for area in walkable_areas:
        if area.polygon and Geometry.is_point_in_polygon(position, area.polygon):
            return true
    return false
```

### Setting Up Navigation2D for Pathfinding Tests

When testing navigation and pathfinding behavior (like the oscillation bug), you need to set up Navigation2D:

```gdscript
# Create Navigation2D BEFORE creating walkable areas
var navigation = Navigation2D.new()
navigation.name = "Navigation2D"
mock_district.add_child(navigation)

# Create walkable area
var walkable = Polygon2D.new()
walkable.polygon = PoolVector2Array([
    Vector2(100, 300),  # Define your test area shape
    Vector2(700, 300),
    Vector2(700, 400),
    Vector2(100, 400)
])
walkable.add_to_group("walkable_area")
mock_district.add_child(walkable)
mock_district.add_walkable_area(walkable)

# IMPORTANT: Create NavigationPolygonInstance for pathfinding
var nav_instance = NavigationPolygonInstance.new()
var nav_poly = NavigationPolygon.new()
nav_poly.add_outline(walkable.polygon)
nav_poly.make_polygons_from_outlines()
nav_instance.navpoly = nav_poly
navigation.add_child(nav_instance)
```

#### Creating Complex Shapes for Testing Edge Cases

For testing navigation bugs around corners or obstacles:

```gdscript
# L-shaped walkable area to test corner navigation
var walkable = Polygon2D.new()
walkable.polygon = PoolVector2Array([
    # Horizontal section
    Vector2(100, 300),
    Vector2(700, 300),
    Vector2(700, 400),
    # Inner corner - common source of navigation issues
    Vector2(300, 400),
    # Vertical section
    Vector2(300, 700),
    Vector2(200, 700),
    Vector2(200, 400),
    Vector2(100, 400)
])
```

### Common Issues and Solutions

1. **"Cannot move to: (x,y) - not in walkable area"**
   - Ensure target position is within walkable polygon
   - Check that walkable area was added to mock district
   - Verify coordinate spaces match
   - Remember polygon positions are relative to their parent

2. **"Freed instance" errors**
   - Store mock district as instance variable, not local
   - Clean up in teardown: `mock_district = null`

3. **Player not finding district**
   - Ensure mock is in "district" group
   - Add yields after creating nodes for initialization

4. **Navigation path not generated**
   - Ensure Navigation2D is created before walkable areas
   - Check that NavigationPolygonInstance is properly set up
   - Verify the navigation polygon has valid outlines

### Best Practices

1. **Choose the right level of mocking**
   - Use minimal mocks when testing unrelated features
   - Use full integration when testing movement system

2. **Document test dependencies**
   ```gdscript
   # This test requires:
   # - Mock district with walkable areas
   # - Player to find district in "district" group
   ```

3. **Reference working examples**
   - See `camera_walkable_integration_test.gd` for integration patterns
   - See `player_controller_test.gd` for physics isolation patterns

For more details on the walkable area system, see [Walkable Area Workflow Guide](../systems/walkable_area_workflow.md).

## Related Testing Documentation

- [Component Testing Guide](testing/component_testing_guide.md) - Testing 2-3 interacting components
- [Subsystem Testing Guide](testing/subsystem_testing_guide.md) - Testing 4+ components as complete features

## Summary

The unit testing system provides:
- Simple, dependency-free testing for Godot projects
- Headless execution for CI/CD
- Flexible test organization with suites and flags
- Clear output with visual indicators
- Comprehensive logging for debugging
- Mock support for isolated testing

Follow the patterns established in existing tests for consistency, and always ensure tests are independent and properly clean up resources.