# Component Testing Guide for A Silent Refraction

## Overview

Component tests verify the interaction between 2-3 closely related components/systems. These tests focus on the "contracts" between components to ensure they communicate correctly. Component tests bridge the gap between unit tests (single component isolation) and subsystem tests (4+ components working as a complete feature).

## Scope Definition

Component tests focus on testing **2-3 closely related components working together**. They verify the contracts, interfaces, and communication between components that must interact to provide functionality. Component tests are:

- **Scope**: 2-3 components/systems working together
- **Focus**: Contracts between components, interface correctness, timing/sequencing of interactions
- **Dependencies**: Minimal mocking (only mock external dependencies)
- **Speed**: Moderate execution (seconds)
- **Purpose**: Ensure components integrate and communicate correctly

For testing single components in isolation, see the [Unit Testing Guide](unit_testing_guide.md). For testing 4+ components as complete features, see the [Subsystem Testing Guide](subsystem_testing_guide.md).

## Quick Start

### Running Component Tests

```bash
# Run all component tests
./tools/run_component_tests.sh

# Run specific component test
./tools/run_component_tests.sh navigation_oscillation_component_test

# Run with full scene name
./tools/run_component_tests.sh navigation_oscillation_component_test.tscn

# Run multiple specific tests
./tools/run_component_tests.sh camera_player_sync navigation_pathfinding
```

### Test Output

Component tests use the same output format as unit tests:
- ✓ Green checkmarks for passed tests
- ✗ Red X marks for failed tests
- Yellow headers for test suites
- Summary statistics at the end

### Log Files

Component test logs are stored separately in `/logs/`:
- Individual test logs: `{test_name}_{timestamp}.log`
- Master log file: `component_tests_{timestamp}.log`

## When to Use Component Tests

Choose component testing when:
- The bug or feature involves 2-3 interacting systems
- The issue emerges from timing or sequencing between components
- You need to test realistic scenarios with system interactions
- Unit-level mocking would hide the actual problem
- Full subsystem testing would be overkill

Examples of component test scenarios:
- Player navigation around obstacles (movement + pathfinding + boundaries)
- Camera following player through districts (camera + coordinate system + player)
- NPC dialog affecting game state (dialog + game manager + NPC state)
- Save/load with active game systems (serialization + all stateful components)

## Component Test Structure

Component tests follow the same file structure and patterns as unit tests but typically:
- Create more complete test scenes with multiple systems
- Use fewer mocks (only mock external dependencies)
- Test longer sequences of operations
- Monitor for emergent behaviors

### File Structure

Each component test requires two files in `/src/component_tests/`:
- `{components}_component_test.gd` - The test script
- `{components}_component_test.tscn` - The scene file

Example for a navigation-boundary component test:
- `/src/component_tests/navigation_boundary_component_test.gd`
- `/src/component_tests/navigation_boundary_component_test.tscn`

Note: Mock files shared between unit and component tests remain in `/src/unit_tests/mocks/`

### Component Test Template

```gdscript
extends Node2D
class_name ComponentInteractionComponentTest
# Component Test: Tests interaction between System A and System B
#
# Components Under Test:
# - Component A: [role in interaction]
# - Component B: [role in interaction]
# - Component C (if applicable): [role in interaction]
#
# Interaction Contract:
# - [How components communicate]
# - [Expected behaviors]
# - [Error conditions]

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test-specific flags
var test_normal_interaction = true
var test_edge_cases = true
var test_error_conditions = true

# Test state
var test_name = "ComponentInteractionTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

# ===== COMPONENTS =====
var component_a: Node
var component_b: Node
var test_environment: Node2D
var interaction_monitor = {}

# ===== LIFECYCLE =====

func _ready():
    print("\n" + "==================================================")
    print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
    print("==================================================\n")
    
    # Create test environment
    setup_test_environment()
    
    # Run test suites
    run_tests()
    
    # Report and cleanup
    report_results()
    cleanup_test_environment()
    
    # Exit
    yield(get_tree().create_timer(0.1), "timeout")
    get_tree().quit(tests_failed)

func setup_test_environment():
    # Create systems with real implementations
    component_a = preload("res://src/core/component_a.gd").new()
    component_b = preload("res://src/core/component_b.gd").new()
    
    # Set up realistic environment
    test_environment = Node2D.new()
    test_environment.name = "TestEnvironment"
    test_environment.add_child(component_a)
    test_environment.add_child(component_b)
    add_child(test_environment)
    
    # Allow systems to initialize and find each other
    yield(get_tree(), "idle_frame")

func run_tests():
    if run_all_tests or test_normal_interaction:
        run_test_suite("Normal Interaction", funcref(self, "test_suite_normal"))
    
    if run_all_tests or test_edge_cases:
        run_test_suite("Edge Cases", funcref(self, "test_suite_edge_cases"))
    
    if run_all_tests or test_error_conditions:
        run_test_suite("Error Conditions", funcref(self, "test_suite_errors"))

# ===== TEST SUITES =====

func test_suite_normal():
    # Test basic interaction
    start_test("test_components_communicate")
    var result = component_a.interact_with(component_b)
    end_test(result.success, "Components communicate successfully")
    
    # Test data exchange
    start_test("test_data_exchange")
    component_a.send_data({"value": 42})
    yield(get_tree(), "idle_frame")
    var received = component_b.get_last_received_data()
    end_test(received.value == 42, "Data exchanged correctly")

func test_suite_edge_cases():
    # Test rapid interactions
    start_test("test_rapid_interactions")
    var success = true
    for i in range(10):
        component_a.interact_with(component_b)
        yield(get_tree(), "idle_frame")
        if not is_interaction_stable():
            success = false
            break
    end_test(success, "Components handle rapid interactions")

func test_suite_errors():
    # Test error propagation
    start_test("test_error_propagation")
    component_a.simulate_error()
    yield(get_tree(), "idle_frame")
    var handled = component_b.last_error_handled
    end_test(handled, "Errors propagate and are handled correctly")

# ===== HELPER METHODS =====

func is_interaction_stable() -> bool:
    return component_a.is_stable() and component_b.is_stable()

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
    if test_environment:
        test_environment.queue_free()
```

## Monitoring System Interactions

Component tests often need to monitor complex behaviors over time:

```gdscript
func monitor_interaction(duration: float) -> Dictionary:
    var timer = 0.0
    var events = []
    
    while timer < duration:
        yield(get_tree(), "idle_frame")
        timer += get_process_delta_time()
        
        # Record system states
        events.append({
            "time": timer,
            "component_a_state": component_a.get_state(),
            "component_b_state": component_b.get_state(),
            "interaction_active": component_a.is_interacting_with(component_b)
        })
    
    # Analyze collected data
    return analyze_interaction_pattern(events)
```

## Common Component Test Patterns

### Pattern 1: Sequential Operations
Test a sequence of operations across components:
```gdscript
func test_player_quest_completion():
    # Player picks up item
    player.collect_item(quest_item)
    yield(get_tree(), "idle_frame")
    
    # Verify inventory updated
    assert_true(inventory.has_item(quest_item))
    
    # Verify quest system notified
    assert_true(quest_manager.is_objective_complete("collect_item"))
    
    # Verify UI updated
    assert_true(ui_manager.quest_indicator.visible)
```

### Pattern 2: Timing-Dependent Behavior
Test behaviors that emerge from specific timing:
```gdscript
func test_animation_state_transition():
    # Start animation
    character.play_animation("walk")
    
    # Wait for specific frame
    yield(get_tree().create_timer(0.3), "timeout")
    
    # Trigger state change mid-animation
    character.set_state("idle")
    
    # Verify smooth transition
    assert_true(character.is_blending_animation())
```

### Pattern 3: Error Propagation
Test how errors propagate through components:
```gdscript
func test_network_failure_handling():
    # Simulate network failure
    network_manager.simulate_disconnect()
    
    # Verify game manager responds
    yield(game_manager, "network_error")
    assert_eq(game_manager.state, "offline_mode")
    
    # Verify UI shows error
    assert_true(ui_manager.error_dialog.visible)
```

## Example: Navigation Oscillation Component Test

Here's a real example testing the interaction between player movement, pathfinding, and boundary systems:

```gdscript
func test_corner_navigation_oscillation():
    # Create environment with problematic geometry
    create_narrow_corridor_with_corner()
    
    # Position player before corner
    player.position = Vector2(300, 380)
    
    # Navigate around corner
    player.move_to(Vector2(220, 500))
    
    # Monitor for oscillation
    var position_history = []
    var oscillations = 0
    
    while player.is_moving and oscillations < 5:
        yield(get_tree(), "idle_frame")
        
        position_history.append(player.position)
        if position_history.size() > 10:
            position_history.pop_front()
        
        # Detect back-and-forth movement
        if is_oscillating(position_history):
            oscillations += 1
    
    # This test EXPECTS the bug to exist
    assert_true(oscillations > 0, "Player should oscillate at corner")
```

## Best Practices for Component Tests

1. **Clear test boundaries** - Know exactly which components you're testing together
2. **Realistic scenarios** - Use configurations that match actual game situations
3. **Diagnostic output** - Log component states to understand failures
4. **Performance awareness** - Component tests take longer than unit tests; balance coverage vs speed
5. **Incremental complexity** - Start with simple interactions, add complexity gradually
6. **Minimal mocking** - Only mock external dependencies, use real implementations for components under test

## Component Tests vs Other Test Types

| Aspect | Unit Tests | Component Tests | Subsystem Tests |
|--------|------------|-----------------|-----------------|
| Scope | Single component | 2-3 components | 4+ components |
| Focus | Internal logic | Contracts/interfaces | Complete features |
| Mocking | Heavy mocking | Minimal mocking | No mocking |
| Speed | Fast (ms) | Moderate (seconds) | Slower (minutes) |
| Debugging | Easy to isolate | Moderate complexity | More complex |
| Value | Component correctness | Integration correctness | Feature completeness |

## Common Issues and Solutions

### Issue: Component Communication Failures

**Problem**: Components can't find or communicate with each other
**Solution**: Ensure proper setup and initialization:
```gdscript
func setup_test_environment():
    # Add components in correct order
    test_environment.add_child(component_a)
    test_environment.add_child(component_b)
    
    # Wait for initialization
    yield(get_tree(), "idle_frame")
    
    # Verify components can find each other
    assert_not_null(component_a.find_partner())
    assert_not_null(component_b.find_partner())
```

### Issue: Timing-Related Test Failures

**Problem**: Tests pass sometimes but fail others due to timing
**Solution**: Use proper synchronization:
```gdscript
func wait_for_interaction_complete():
    var timeout = 2.0
    var elapsed = 0.0
    
    while elapsed < timeout:
        if component_a.interaction_complete and component_b.interaction_complete:
            return true
        yield(get_tree(), "idle_frame")
        elapsed += get_process_delta_time()
    
    return false
```

### Issue: State Pollution Between Tests

**Problem**: Tests affect each other's state
**Solution**: Proper cleanup and reset:
```gdscript
func teardown_test():
    # Reset component states
    if component_a and component_a.has_method("reset"):
        component_a.reset()
    if component_b and component_b.has_method("reset"):
        component_b.reset()
    
    # Clear any shared state
    interaction_monitor.clear()
```

## Creating Component Tests for Existing Features

When adding component tests to existing features:

1. **Identify the components** that interact
2. **Map the interaction points** and contracts
3. **Create test scenarios** that exercise these interactions
4. **Start with happy path** then add edge cases
5. **Include error scenarios** to test robustness

Example process:
```gdscript
# 1. Identify: Player + Navigation + WalkableArea
# 2. Map: Player asks Navigation for path, Navigation checks WalkableArea
# 3. Scenarios: Normal path, blocked path, partial path
# 4. Happy path: Direct path from A to B
# 5. Error cases: No valid path, path becomes invalid
```

## Available Component Tests

The following component tests are currently available in `/src/component_tests/`:

1. **camera_player_sync_component_test** - Tests synchronization between camera and player movement
2. **camera_walkable_component_test** - Tests integration between camera and walkable area systems
3. **coordinate_transformation_component_test** - Tests coordinate transformation across multiple systems
4. **navigation_oscillation_component_test** - Tests player navigation oscillation at boundaries
5. **navigation_pathfinding_component_test** - Tests Navigation2D integration for point-and-click movement
6. **player_navigation_progress_component_test** - Tests player progress along navigation paths
7. **player_navigation_stuck_component_test** - Tests stuck state issues when following navigation paths
8. **view_mode_transition_component_test** - Tests transitions between game view and world view modes

## Test Runner Configuration

The component test runner (`/tools/run_component_tests.sh`) is configured with:
- **Default timeout**: 120 seconds per test (2x unit test timeout)
- **Extended timeout**: 240 seconds for complex tests (e.g., camera_walkable, navigation_oscillation)
- **Automatic logging**: All output saved to timestamped log files
- **Parallel execution**: Tests run sequentially to avoid resource conflicts

## Integration with CI/CD

Component tests integrate seamlessly with the existing test infrastructure:

```yaml
# CI configuration example
test_components:
  script:
    - ./tools/run_component_tests.sh
  artifacts:
    paths:
      - logs/
    when: always
```

## Summary

Component tests provide essential coverage for the interactions between related game systems. They:
- Verify contracts between 2-3 components
- Catch integration issues early
- Test realistic interaction scenarios
- Balance detail with execution speed
- Complement both unit and subsystem tests

Use component tests to ensure your game systems work together correctly before investing in full subsystem testing.