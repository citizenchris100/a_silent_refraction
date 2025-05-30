# Subsystem Testing Guide for A Silent Refraction

## Overview

This guide documents the subsystem testing approach for A Silent Refraction. Subsystem tests verify that multiple related systems (4+ components) work together as a cohesive functional unit. These tests complement unit tests (single component) and integration tests (2-3 components) by validating complete game features end-to-end.

## Quick Start

### Running Subsystem Tests

```bash
# Run all subsystem tests
./tools/run_subsystem_tests.sh

# Run specific subsystem test
./tools/run_subsystem_tests.sh camera_movement_subsystem

# Run with visual validation enabled
./tools/run_subsystem_tests.sh camera_movement_subsystem --visual

# Run with performance profiling
./tools/run_subsystem_tests.sh camera_movement_subsystem --profile
```

### Test Output

Subsystem tests produce detailed output including:
- System initialization status
- Feature workflow execution
- Performance metrics
- Visual validation results (when applicable)
- Detailed failure diagnostics

### Log Files

Subsystem test logs are stored in `/logs/subsystem_tests/`:
- Individual test logs: `{subsystem_name}_subsystem_{timestamp}.log`
- Performance profiles: `{subsystem_name}_profile_{timestamp}.json`
- Visual captures: `{subsystem_name}_visual_{timestamp}/`

## When to Create Subsystem Tests

Create subsystem tests when:
- **4+ components** must work together for a feature
- Testing **complete user workflows** end-to-end
- Validating **emergent behaviors** from system interactions
- Ensuring **performance** under realistic conditions
- Verifying **visual correctness** (not just logical correctness)

Examples of subsystem test candidates:
- Camera/Movement/Navigation working together
- Complete NPC interaction workflows
- Save/Load with all active systems
- Time-based event systems
- Complex UI workflows

## Subsystem Test Structure

### File Organization

```
src/subsystem_tests/
├── camera_movement_subsystem_test.gd
├── camera_movement_subsystem_test.tscn
├── npc_interaction_subsystem_test.gd
├── npc_interaction_subsystem_test.tscn
└── common/
    ├── subsystem_test_base.gd
    ├── performance_monitor.gd
    └── visual_validator.gd
```

### Critical: Using Base District in Subsystem Tests

**IMPORTANT**: When testing subsystems that involve districts, cameras, or spatial gameplay, your test MUST extend `base_district.gd` instead of `subsystem_test_base.gd`. This ensures you're testing the actual game architecture, not a simplified mock.

#### Why This Matters

1. **Architectural Accuracy**: The camera system, walkable areas, and coordinate systems are tightly integrated with base_district
2. **Visual Correctness**: Base district's `calculate_optimal_zoom()` prevents grey bars and ensures proper scaling
3. **Automatic Setup**: Base district handles camera creation, player setup, and system initialization correctly

#### Correct Pattern for District-Based Subsystem Tests

```gdscript
extends "res://src/core/districts/base_district.gd"
# Subsystem Test: Camera Movement - Tests complete camera, movement, and navigation integration
# This test extends base_district to accurately represent the actual game architecture

# Test configuration (manual since we don't extend subsystem_test_base)
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var failed_tests = []
var test_start_time = 0

func _ready():
    # Set up district properties
    district_name = "Camera Movement Test District"
    district_description = "Test district for subsystem validation"
    
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
    setup_player_and_controller(Vector2(400, 400))
    
    # Run tests
    yield(run_test_scenarios(), "completed")
    
    # Exit with appropriate code
    get_tree().quit(tests_failed)
```

#### Common Mistakes to Avoid

1. **Don't extend subsystem_test_base for district tests** - It lacks the necessary architecture
2. **Don't create cameras manually** - Let base_district handle it
3. **Don't wrap nodes in containers** - Background must be a direct child
4. **Don't skip ._ready()** - This initializes all district systems

### Basic Subsystem Test Template

**Note**: Use this template for non-spatial subsystems (e.g., save/load, dialog, inventory). For tests involving districts, cameras, or movement, extend `base_district.gd` instead (see above).

```gdscript
extends "res://src/subsystem_tests/common/subsystem_test_base.gd"
# Subsystem Test: [Name] - Tests [brief description of what systems are tested together]
#
# Systems Under Test:
# - Component A: [role in subsystem]
# - Component B: [role in subsystem]
# - Component C: [role in subsystem]
# - Component D: [role in subsystem]
#
# Test Scenarios:
# 1. [Scenario 1 description]
# 2. [Scenario 2 description]
# 3. [Scenario 3 description]

# ===== SUBSYSTEM CONFIGURATION =====
var subsystem_name = "ExampleSubsystem"
var required_components = [
    "ComponentA",
    "ComponentB", 
    "ComponentC",
    "ComponentD"
]

# Test scenarios to run
var test_scenarios = {
    "basic_workflow": true,
    "edge_cases": true,
    "error_conditions": true,
    "performance": true,
    "visual_correctness": true
}

# Performance thresholds
var performance_targets = {
    "initialization_time": 1.0,  # seconds
    "workflow_completion": 5.0,  # seconds
    "frame_time_avg": 16.7,     # milliseconds (60 FPS)
    "frame_time_max": 33.3      # milliseconds (30 FPS minimum)
}

# ===== SUBSYSTEM COMPONENTS =====
var component_a: Node
var component_b: Node
var component_c: Node
var component_d: Node
var test_environment: Node2D

# ===== LIFECYCLE =====

func _ready():
    print("\n" + "="*60)
    print(" %s SUBSYSTEM TEST SUITE" % subsystem_name.to_upper())
    print("="*60 + "\n")
    
    # Initialize subsystem
    var init_success = yield(initialize_subsystem(), "completed")
    if not init_success:
        log_error("Failed to initialize subsystem")
        cleanup_and_exit(1)
        return
    
    # Run test scenarios
    yield(run_test_scenarios(), "completed")
    
    # Generate reports
    generate_subsystem_report()
    
    # Cleanup and exit
    cleanup_and_exit(tests_failed)

func initialize_subsystem() -> bool:
    start_performance_monitor("initialization")
    
    log_section("Initializing Subsystem Components")
    
    # Create test environment
    test_environment = create_test_environment()
    if not test_environment:
        return false
    
    # Initialize each component
    for component_name in required_components:
        if not yield(initialize_component(component_name), "completed"):
            return false
    
    # Verify component interactions
    if not yield(verify_component_connections(), "completed"):
        return false
    
    stop_performance_monitor("initialization")
    
    log_success("Subsystem initialized successfully")
    return true

func run_test_scenarios():
    log_section("Running Test Scenarios")
    
    if test_scenarios.basic_workflow:
        yield(run_scenario("Basic Workflow", funcref(self, "test_basic_workflow")), "completed")
    
    if test_scenarios.edge_cases:
        yield(run_scenario("Edge Cases", funcref(self, "test_edge_cases")), "completed")
    
    if test_scenarios.error_conditions:
        yield(run_scenario("Error Conditions", funcref(self, "test_error_conditions")), "completed")
    
    if test_scenarios.performance:
        yield(run_scenario("Performance", funcref(self, "test_performance")), "completed")
    
    if test_scenarios.visual_correctness and enable_visual_validation:
        yield(run_scenario("Visual Correctness", funcref(self, "test_visual_correctness")), "completed")

# ===== TEST SCENARIOS =====

func test_basic_workflow():
    """Test the primary use case for this subsystem"""
    
    start_test("complete_user_workflow")
    
    # Step 1: User initiates action
    var action_result = yield(simulate_user_action("primary_action"), "completed")
    assert_state(component_a, "active", "Component A should activate")
    
    # Step 2: Systems respond
    yield(wait_for_system_response(), "completed")
    assert_state(component_b, "processing", "Component B should be processing")
    
    # Step 3: Verify results
    var final_state = get_subsystem_state()
    end_test(final_state.success, "Basic workflow completed successfully")

func test_edge_cases():
    """Test boundary conditions and unusual scenarios"""
    
    # Test rapid state changes
    start_test("rapid_state_changes")
    for i in range(10):
        yield(trigger_state_change(), "completed")
        yield(get_tree(), "idle_frame")
    
    var system_stable = verify_system_stability()
    end_test(system_stable, "System remains stable under rapid changes")
    
    # Test resource limits
    start_test("resource_limits")
    yield(push_to_limits(), "completed")
    var within_limits = check_resource_usage()
    end_test(within_limits, "System respects resource limits")

func test_error_conditions():
    """Test system behavior under error conditions"""
    
    start_test("component_failure_handling")
    
    # Simulate component failure
    simulate_component_failure(component_b)
    yield(get_tree().create_timer(1.0), "timeout")
    
    # Verify graceful degradation
    var system_operational = is_subsystem_operational()
    var error_handled = was_error_handled_gracefully()
    
    end_test(system_operational and error_handled, 
             "System handles component failure gracefully")

func test_performance():
    """Test subsystem performance under load"""
    
    start_test("performance_under_load")
    
    # Create load scenario
    var load_scenario = create_performance_load()
    
    # Monitor performance
    start_performance_monitor("workflow_under_load")
    
    # Execute workflow multiple times
    for i in range(100):
        yield(execute_workflow(), "completed")
    
    var perf_data = stop_performance_monitor("workflow_under_load")
    
    # Verify performance targets
    var meets_targets = validate_performance_targets(perf_data)
    end_test(meets_targets, "Performance meets targets under load")

func test_visual_correctness():
    """Test visual display correctness"""
    
    start_test("visual_display_validation")
    
    # Capture initial state
    var initial_capture = capture_visual_state("initial")
    
    # Execute visual changes
    yield(trigger_visual_changes(), "completed")
    
    # Capture final state
    var final_capture = capture_visual_state("final")
    
    # Validate visual correctness
    var visually_correct = validate_visual_correctness(initial_capture, final_capture)
    end_test(visually_correct, "Visual display is correct")

# ===== HELPER METHODS =====

func create_test_environment() -> Node2D:
    """Create a realistic test environment for the subsystem"""
    var env = Node2D.new()
    env.name = "TestEnvironment"
    add_child(env)
    
    # Add environment-specific setup here
    
    return env

func verify_component_connections() -> bool:
    """Verify all components can communicate properly"""
    # Implementation specific to subsystem
    return true

func simulate_user_action(action: String):
    """Simulate realistic user input"""
    # Implementation specific to subsystem
    yield(get_tree(), "idle_frame")

func get_subsystem_state() -> Dictionary:
    """Get current state of all subsystem components"""
    return {
        "success": true,
        "component_states": {},
        "metrics": {}
    }

# ===== SUBSYSTEM-SPECIFIC METHODS =====
# Add methods specific to this subsystem's testing needs
```

### Base Class for Subsystem Tests

```gdscript
# src/subsystem_tests/common/subsystem_test_base.gd
extends Node2D

# ===== TEST STATE =====
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_scenario = ""
var failed_tests = []
var test_start_time = 0

# ===== CONFIGURATION =====
var log_verbose = true
var enable_visual_validation = false
var enable_performance_profiling = false
var capture_test_artifacts = true

# ===== PERFORMANCE MONITORING =====
var performance_monitors = {}
var frame_time_samples = []

# ===== VISUAL VALIDATION =====
var visual_validator = null
var visual_captures = {}

# ===== LOGGING METHODS =====

func log_section(title: String):
    print("\n" + "-"*50)
    print(" " + title)
    print("-"*50)

func log_success(message: String):
    print("[SUCCESS] " + message)

func log_error(message: String):
    print("[ERROR] " + message)

func log_warning(message: String):
    print("[WARNING] " + message)

func log_info(message: String):
    if log_verbose:
        print("[INFO] " + message)

# ===== TEST EXECUTION =====

func start_test(test_name: String):
    current_test = test_name
    test_start_time = OS.get_ticks_msec()
    log_info("Starting test: " + test_name)

func end_test(passed: bool, message: String):
    var duration = (OS.get_ticks_msec() - test_start_time) / 1000.0
    
    if passed:
        tests_passed += 1
        print("  ✓ PASS: %s - %s (%.2fs)" % [current_test, message, duration])
    else:
        tests_failed += 1
        failed_tests.append(current_test)
        print("  ✗ FAIL: %s - %s (%.2fs)" % [current_test, message, duration])

func run_scenario(scenario_name: String, test_func: FuncRef):
    current_scenario = scenario_name
    print("\n===== SCENARIO: %s =====" % scenario_name)
    yield(test_func.call_func(), "completed")

# ===== ASSERTIONS =====

func assert_state(component: Node, expected_state: String, message: String):
    if component.has_method("get_state"):
        var actual_state = component.get_state()
        if actual_state != expected_state:
            log_error("%s - Expected: %s, Got: %s" % [message, expected_state, actual_state])
            return false
    return true

func assert_within_range(value: float, min_val: float, max_val: float, message: String):
    if value < min_val or value > max_val:
        log_error("%s - Value %f outside range [%f, %f]" % [message, value, min_val, max_val])
        return false
    return true

# ===== PERFORMANCE MONITORING =====

func start_performance_monitor(monitor_name: String):
    performance_monitors[monitor_name] = {
        "start_time": OS.get_ticks_msec(),
        "frame_count": 0,
        "frame_times": []
    }

func stop_performance_monitor(monitor_name: String) -> Dictionary:
    if not monitor_name in performance_monitors:
        return {}
    
    var monitor = performance_monitors[monitor_name]
    monitor["end_time"] = OS.get_ticks_msec()
    monitor["duration"] = (monitor.end_time - monitor.start_time) / 1000.0
    
    # Calculate statistics
    if monitor.frame_times.size() > 0:
        monitor["avg_frame_time"] = _calculate_average(monitor.frame_times)
        monitor["max_frame_time"] = _calculate_max(monitor.frame_times)
        monitor["min_frame_time"] = _calculate_min(monitor.frame_times)
    
    return monitor

func validate_performance_targets(perf_data: Dictionary) -> bool:
    # Override in derived classes
    return true

# ===== VISUAL VALIDATION =====

func capture_visual_state(state_name: String) -> Dictionary:
    if not enable_visual_validation:
        return {}
    
    # Capture viewport
    var viewport = get_viewport()
    var image = viewport.get_texture().get_data()
    
    return {
        "name": state_name,
        "image": image,
        "timestamp": OS.get_ticks_msec()
    }

func validate_visual_correctness(initial: Dictionary, final: Dictionary) -> bool:
    # Override in derived classes for specific validation
    return true

# ===== CLEANUP =====

func cleanup_and_exit(exit_code: int):
    log_section("Test Summary")
    print("Tests Passed: %d" % tests_passed)
    print("Tests Failed: %d" % tests_failed)
    
    if tests_failed > 0:
        print("\nFailed Tests:")
        for test in failed_tests:
            print("  - " + test)
    
    # Cleanup
    if test_environment:
        test_environment.queue_free()
    
    yield(get_tree().create_timer(0.5), "timeout")
    get_tree().quit(exit_code)

# ===== UTILITY METHODS =====

func _calculate_average(values: Array) -> float:
    if values.empty():
        return 0.0
    var sum = 0.0
    for v in values:
        sum += v
    return sum / values.size()

func _calculate_max(values: Array) -> float:
    if values.empty():
        return 0.0
    var max_val = values[0]
    for v in values:
        if v > max_val:
            max_val = v
    return max_val

func _calculate_min(values: Array) -> float:
    if values.empty():
        return 0.0
    var min_val = values[0]
    for v in values:
        if v < min_val:
            min_val = v
    return min_val

func wait_for_system_response(timeout: float = 5.0):
    """Wait for systems to reach stable state"""
    var timer = 0.0
    while timer < timeout:
        yield(get_tree(), "idle_frame")
        timer += get_process_delta_time()
        
        # Check if system is stable (override in derived class)
        if is_system_stable():
            return
    
    log_warning("System did not stabilize within timeout")

func is_system_stable() -> bool:
    """Override to implement stability check"""
    return true
```

## Subsystem Test Patterns

### Pattern 1: Workflow Testing

Test complete user workflows from start to finish:

```gdscript
func test_complete_player_movement_workflow():
    """Test player clicking, pathfinding, movement, and camera follow"""
    
    start_test("click_to_move_workflow")
    
    # 1. Simulate player click
    var click_pos = Vector2(800, 600)
    input_manager.simulate_click(click_pos)
    
    # 2. Verify pathfinding initiated
    yield(get_tree(), "idle_frame")
    assert_true(player.is_navigating, "Player should start navigation")
    assert_not_null(player.navigation_path, "Path should be generated")
    
    # 3. Monitor movement and camera
    var movement_data = yield(monitor_movement_until_complete(), "completed")
    
    # 4. Verify end state
    assert_position_near(player.position, click_pos, 10.0, "Player reached destination")
    assert_true(camera.is_player_in_view(), "Camera kept player in view")
    assert_eq(movement_data.stuck_count, 0, "No navigation stuck events")
    
    end_test(movement_data.success, "Complete movement workflow executed correctly")
```

### Pattern 2: State Synchronization Testing

Test that all components maintain synchronized state:

```gdscript
func test_subsystem_state_synchronization():
    """Verify all components maintain consistent state during operations"""
    
    start_test("state_synchronization")
    
    # Create state snapshot function
    var get_system_snapshot = funcref(self, "_capture_all_states")
    
    # Execute series of operations
    var operations = [
        "move_player",
        "scroll_camera", 
        "change_district",
        "toggle_view_mode"
    ]
    
    var snapshots = []
    for op in operations:
        yield(execute_operation(op), "completed")
        snapshots.append(get_system_snapshot.call_func())
    
    # Verify state consistency
    var consistent = verify_state_consistency(snapshots)
    end_test(consistent, "All components maintained synchronized state")
```

### Pattern 3: Performance Under Load

Test subsystem performance with realistic load:

```gdscript
func test_performance_with_multiple_entities():
    """Test subsystem performance with many active entities"""
    
    start_test("performance_under_load")
    
    # Create load scenario
    var npcs = []
    for i in range(50):
        var npc = create_test_npc(Vector2(randf() * 1920, randf() * 1080))
        npcs.append(npc)
    
    # Start performance monitoring
    start_performance_monitor("heavy_load")
    
    # Execute typical operations
    for i in range(60):  # 1 second at 60 FPS
        # Move player
        player.move_to(Vector2(randf() * 1920, randf() * 1080))
        
        # Move NPCs
        for npc in npcs:
            npc.wander()
        
        # Let frame process
        yield(get_tree(), "idle_frame")
        
        # Record frame time
        record_frame_time()
    
    var perf_data = stop_performance_monitor("heavy_load")
    
    # Validate against targets
    var meets_fps_target = perf_data.avg_frame_time <= 16.7  # 60 FPS
    var no_frame_spikes = perf_data.max_frame_time <= 33.3   # No drops below 30 FPS
    
    end_test(meets_fps_target and no_frame_spikes, 
             "Performance acceptable under load (Avg: %.1fms, Max: %.1fms)" % 
             [perf_data.avg_frame_time, perf_data.max_frame_time])
```

### Pattern 4: Visual Correctness Validation

Test that visual display remains correct:

```gdscript
func test_camera_visual_correctness():
    """Verify camera maintains visual correctness per architectural guidelines"""
    
    start_test("visual_correctness_validation")
    
    # Test background scaling preservation
    var initial_bg_scale = background.scale
    
    # Execute camera operations that previously broke visuals
    camera.set_bounds_from_walkable_area(complex_walkable_area)
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Verify visual correctness
    assert_eq(background.scale, initial_bg_scale, "Background scale preserved")
    assert_false(has_grey_bars(), "No grey bars visible")
    assert_true(background_fills_viewport(), "Background fills viewport")
    
    # Test coordinate accuracy is maintained
    var test_points = generate_test_points()
    var coord_accurate = true
    
    for point in test_points:
        var world_pos = camera.screen_to_world(point)
        var screen_pos = camera.world_to_screen(world_pos)
        if not point.is_equal_approx(screen_pos):
            coord_accurate = false
            break
    
    end_test(coord_accurate and background_fills_viewport(), 
             "Visual correctness maintained while preserving coordinate accuracy")
```

### Pattern 5: Error Recovery Testing

Test subsystem recovery from error conditions:

```gdscript
func test_error_recovery():
    """Test subsystem recovery from various error conditions"""
    
    start_test("error_recovery")
    
    var recovery_success = true
    
    # Test 1: Invalid navigation target
    player.move_to(Vector2(-1000, -1000))  # Outside bounds
    yield(get_tree().create_timer(1.0), "timeout")
    recovery_success = recovery_success and not player.is_moving
    
    # Test 2: Rapid state changes
    for i in range(10):
        camera.set_mode("game_view" if i % 2 == 0 else "world_view")
        yield(get_tree(), "idle_frame")
    recovery_success = recovery_success and is_system_stable()
    
    # Test 3: Component disconnect
    var original_camera = camera
    remove_child(camera)
    yield(get_tree(), "idle_frame")
    
    # System should handle missing camera gracefully
    var handled_gracefully = not has_errors()
    add_child(original_camera)
    
    recovery_success = recovery_success and handled_gracefully
    
    end_test(recovery_success, "Subsystem recovered from all error conditions")
```

## Best Practices

### 1. Test Realistic Scenarios

Subsystem tests should simulate real game scenarios:
- Use actual game assets and configurations
- Test with realistic data volumes
- Include typical player behavior patterns
- Test edge cases users might encounter

### 2. Monitor Emergent Behaviors

Watch for behaviors that emerge from system interactions:
- Oscillations or feedback loops
- Performance degradation patterns
- State synchronization issues
- Visual artifacts

### 3. Measure Performance Impact

Always include performance monitoring:
```gdscript
func _ready():
    # Enable frame time monitoring
    set_process(true)
    
func _process(delta):
    if enable_performance_profiling:
        record_frame_time()
```

### 4. Document System Dependencies

Clearly document what systems are being tested:
```gdscript
# Systems Under Test:
# - ScrollingCamera: Handles viewport and camera movement
# - CoordinateManager: Transforms between coordinate spaces  
# - PlayerController: Manages player movement and pathfinding
# - WalkableArea: Defines movement boundaries
# - InputManager: Processes click input
#
# Dependencies:
# - Requires BaseDistrict for proper initialization
# - Needs Navigation2D for pathfinding
# - Uses BackgroundSprite for visual validation
```

### 5. Capture Diagnostic Information

When tests fail, provide detailed diagnostics:
```gdscript
func on_test_failure():
    print("=== DIAGNOSTIC INFORMATION ===")
    print("Player State: %s" % player.get_state())
    print("Camera Position: %s" % camera.position)
    print("Active Viewport: %s" % get_viewport().size)
    print("Component Versions:")
    for component in get_all_components():
        print("  - %s: %s" % [component.name, component.get_version()])
```

### 6. Use Time Acceleration When Appropriate

For time-based behaviors, consider time acceleration:
```gdscript
func test_time_based_events():
    # Accelerate time for testing
    Engine.time_scale = 10.0
    
    # Test time-based behavior
    yield(test_scheduled_events(), "completed")
    
    # Restore normal time
    Engine.time_scale = 1.0
```

### 7. Separate Visual Tests

Visual validation tests should be clearly marked and skippable:
```gdscript
if test_scenarios.visual_correctness and enable_visual_validation:
    yield(run_scenario("Visual Correctness", funcref(self, "test_visual_correctness")), "completed")
else:
    log_info("Skipping visual tests (enable with --visual flag)")
```

### 8. Create Simple Debug Versions

When subsystem tests fail mysteriously, create a simplified version:
```gdscript
# camera_movement_simple_test.gd - Debug version
extends Node2D

func _ready():
    print("========== SIMPLE TEST ==========")
    
    # Test basic component creation
    var district = create_test_district()
    print("✓ Created district" if district else "✗ Failed to create district")
    
    var player = create_test_player()
    print("✓ Created player" if player else "✗ Failed to create player")
    
    # Test basic interaction
    if player and player.has_method("move_to"):
        player.move_to(Vector2(500, 500))
        yield(get_tree().create_timer(1.0), "timeout")
        print("✓ Movement triggered" if player.is_moving else "✗ Movement failed")
    
    get_tree().quit(0)
```

This helps isolate whether the issue is with:
- Component creation
- Component interaction
- Test framework complexity
- Cleanup/exit handling

## Common Pitfalls and Solutions

### Pitfall 1: GDScript String Operations

**Problem**: String multiplication (e.g., `"="*60`) causes parse errors
**Solution**: Use explicit strings instead:
```gdscript
# ❌ BAD - Causes parse error
print("="*60)

# ✅ GOOD - Use explicit string
print("============================================================")
```

### Pitfall 2: Singleton/Autoload Access

**Problem**: Trying to call `.instance()` on autoloaded singletons
**Solution**: Access singletons directly as globals:
```gdscript
# ❌ BAD - Singletons don't have instance() method
var coord_mgr = CoordinateManager.instance()

# ✅ GOOD - Access singleton directly
if CoordinateManager:
    CoordinateManager.set_current_district(district)
```

### Pitfall 3: Cleanup During Active Yields

**Problem**: Nodes freed while yield operations are still running cause errors
**Solution**: Stop all operations before cleanup:
```gdscript
func cleanup_subsystem():
    # Stop any ongoing operations first
    if player:
        player.is_moving = false
        player.velocity = Vector2.ZERO
    
    # Wait for yields to complete
    yield(get_tree().create_timer(1.0), "timeout")
    
    # Now safe to free nodes
    if test_environment:
        test_environment.queue_free()
```

### Pitfall 4: Test Interdependence

**Problem**: Tests depend on the order of execution
**Solution**: Each test should set up its complete environment:
```gdscript
func setup_test_environment():
    # Reset all systems to known state
    reset_all_systems()
    
    # Create fresh instances
    create_test_components()
    
    # Wait for initialization
    yield(wait_for_initialization(), "completed")
```

### Pitfall 2: Incomplete Cleanup

**Problem**: Tests leave systems in modified states
**Solution**: Implement comprehensive cleanup:
```gdscript
func cleanup_test():
    # Store original state in setup
    var original_state = capture_system_state()
    
    # ... run test ...
    
    # Restore original state
    restore_system_state(original_state)
    
    # Free test objects
    free_test_objects()
```

### Pitfall 3: Timing Issues

**Problem**: Tests fail due to timing/race conditions
**Solution**: Use proper synchronization:
```gdscript
func wait_for_condition(condition_func: FuncRef, timeout: float = 5.0):
    var elapsed = 0.0
    while elapsed < timeout:
        if condition_func.call_func():
            return true
        yield(get_tree(), "idle_frame")
        elapsed += get_process_delta_time()
    return false

# Usage
var stable = yield(wait_for_condition(funcref(self, "is_camera_stable")), "completed")
```

### Pitfall 4: Over-Mocking

**Problem**: Mocking too much hides real integration issues
**Solution**: Only mock external dependencies:
```gdscript
# ✅ GOOD: Use real implementations
var camera = preload("res://src/core/camera/scrolling_camera.gd").new()
var player = preload("res://src/characters/player/player.gd").new()

# ❌ BAD: Over-mocking core components
var camera = preload("res://tests/mocks/mock_camera.gd").new()
```

### Pitfall 5: Starting with Too Many Scenarios

**Problem**: Running all test scenarios at once makes debugging difficult
**Solution**: Start with one scenario and gradually enable more:
```gdscript
var test_scenarios = {
    "basic_movement": true,      # Start here
    "complex_navigation": false, # Enable after basic works
    "performance": false,        # Enable last
    # ... more scenarios
}
```

### Pitfall 6: Debugging Hanging Tests

**Problem**: Test appears to hang with no output
**Solution**: Add debug prints and check logs:
```gdscript
func _ready():
    print("DEBUG: Starting initialization...")
    yield(get_tree().create_timer(0.1), "timeout")
    print("DEBUG: About to initialize subsystem...")
    
    # Check process list for stuck Godot instances
    # $ ps aux | grep godot
    
    # Check latest log file
    # $ tail -f logs/subsystem_tests/latest.log
```

### Pitfall 7: Component Not Found Errors

**Problem**: "No district/player/camera found" errors
**Solution**: Ensure proper node setup and group membership:
```gdscript
# Add nodes to required groups
district.add_to_group("district")
player.add_to_group("player")

# Wait for scene tree to update
yield(get_tree(), "idle_frame")
```

## Integration with CI/CD

### Running in CI Pipelines

```yaml
# Example CI configuration
test_subsystems:
  script:
    - ./tools/run_subsystem_tests.sh --headless --timeout 300
  artifacts:
    paths:
      - logs/subsystem_tests/
    when: always
  allow_failure: false
```

### Performance Regression Detection

```bash
#!/bin/bash
# Run performance-sensitive subsystem tests
./tools/run_subsystem_tests.sh camera_movement_subsystem --profile

# Compare with baseline
python3 tools/compare_performance.py \
  --baseline performance_baseline.json \
  --current logs/subsystem_tests/camera_movement_profile_*.json \
  --threshold 10  # Allow 10% degradation
```

## Troubleshooting Subsystem Tests

### Issue: Wrong Script/Class Used

**Symptom**: "Invalid set index 'position'" or similar property errors
**Cause**: Using wrong script (e.g., `player_controller.gd` instead of `player.gd`)
**Solution**: Verify actual class implementations:
```gdscript
# Check what the script actually extends
var Player = preload("res://src/characters/player/player.gd")  # extends Node2D
# NOT
var PlayerController = preload("res://src/core/player_controller.gd")  # extends Node
```

### Issue: Test Completes but Runner Times Out

**Symptom**: Test shows "Exit code: 1" when run directly but times out in runner
**Cause**: Test runner waiting for process that already exited
**Solution**: 
1. Run test directly to verify it completes:
   ```bash
   godot --no-window --path . src/subsystem_tests/my_test.tscn
   echo "Exit code: $?"
   ```
2. Check for error output that might prevent clean exit
3. Ensure proper cleanup with `get_tree().quit(exit_code)`

### Issue: Components Can't Find Each Other

**Symptom**: "CoordinateManager cannot find camera" or similar
**Cause**: Components looking in wrong places or using wrong methods
**Solution**: Understand how components actually communicate:
```gdscript
# Singletons are accessed globally
CoordinateManager.set_current_district(district)

# Scene queries need proper groups
for node in get_tree().get_nodes_in_group("district"):
    # Found district
```

### Debug Checklist

When a subsystem test fails mysteriously:
1. ✓ Run the simple version first (create minimal test)
2. ✓ Check all preload paths are correct
3. ✓ Verify singleton access patterns
4. ✓ Ensure nodes are added to scene tree
5. ✓ Add debug prints at key points
6. ✓ Check logs for parse errors
7. ✓ Kill any stuck Godot processes
8. ✓ Start with one test scenario enabled

## Creating Your First Subsystem Test

1. **Identify the subsystem boundaries**
   - List all components involved
   - Map their interactions
   - Define success criteria

2. **Create test files**
   ```bash
   # Create test script and scene
   touch src/subsystem_tests/my_subsystem_test.gd
   touch src/subsystem_tests/my_subsystem_test.tscn
   ```

3. **Implement using the template**
   - Extend subsystem_test_base.gd
   - Define test scenarios
   - Implement verification logic

4. **Add to test runner**
   ```bash
   # Edit tools/run_subsystem_tests.sh to include new test
   ```

5. **Run and iterate**
   ```bash
   ./tools/run_subsystem_tests.sh my_subsystem --visual
   ```

## Summary

Subsystem tests bridge the gap between unit tests and full integration tests by:
- Testing complete features with 4+ interacting components
- Validating emergent behaviors and system-wide properties
- Ensuring performance and visual correctness
- Providing confidence that major game systems work together correctly

Use subsystem tests to validate critical game features that players directly experience.