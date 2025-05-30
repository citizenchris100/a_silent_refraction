# Testing Quick Reference for A Silent Refraction

## Overview

This document provides a quick reference for all testing types in A Silent Refraction. The project uses a three-tier testing strategy with increasing levels of integration complexity.

## Test Type Scopes

### 🔵 Unit Tests
- **Scope**: Single component in isolation
- **Components**: 1
- **Mocking**: Heavy (all dependencies mocked)
- **Speed**: Fast (milliseconds)
- **Purpose**: Verify internal logic and component correctness

### 🟢 Component Tests
- **Scope**: 2-3 closely related components
- **Components**: 2-3
- **Mocking**: Minimal (only external dependencies)
- **Speed**: Moderate (seconds)
- **Purpose**: Verify contracts and interfaces between components

### 🟠 Subsystem Tests
- **Scope**: 4+ components as complete features
- **Components**: 4 or more
- **Mocking**: None (real implementations)
- **Speed**: Slower (seconds to minutes)
- **Purpose**: Verify complete feature functionality end-to-end

## Running Tests

### Running All Tests (Omni Test Runner)

```bash
# Run all test types sequentially (Unit → Component → Subsystem)
./tools/run_all_tests.sh
```

**Note**: The omni test runner uses gated execution - each test type must pass completely before the next type runs.

### Running Individual Test Types

#### Unit Tests
```bash
# Run all unit tests
./tools/run_unit_tests.sh

# Run specific unit test
./tools/run_unit_tests.sh coordinate_system_test

# Run multiple unit tests
./tools/run_unit_tests.sh coordinate_system_test camera_state_test
```

#### Component Tests
```bash
# Run all component tests
./tools/run_component_tests.sh

# Run specific component test
./tools/run_component_tests.sh navigation_pathfinding_component_test

# Run multiple component tests
./tools/run_component_tests.sh camera_player_sync navigation_pathfinding
```

#### Subsystem Tests
```bash
# Run all subsystem tests
./tools/run_subsystem_tests.sh

# Run specific subsystem test
./tools/run_subsystem_tests.sh camera_movement_subsystem

# Run with visual validation
./tools/run_subsystem_tests.sh camera_movement_subsystem --visual
```

## Test Locations

| Test Type | Directory | File Pattern | Example |
|-----------|-----------|--------------|---------|
| Unit Tests | `/src/unit_tests/` | `{component}_test.gd` | `coordinate_system_test.gd` |
| Component Tests | `/src/component_tests/` | `{components}_component_test.gd` | `camera_player_sync_component_test.gd` |
| Subsystem Tests | `/src/subsystem_tests/` | `{feature}_subsystem_test.gd` | `camera_movement_subsystem_test.gd` |
| Mock Files | `/src/unit_tests/mocks/` | `mock_{component}.gd` | `mock_district.gd` |

## Test Output

### Console Output
- ✓ Green checkmarks = Passed tests
- ✗ Red X marks = Failed tests
- ⊗ Yellow circles = Skipped tests
- Colored headers for test organization

### Log Files

| Test Type | Log Location | File Pattern |
|-----------|--------------|--------------|
| Unit Tests | `/logs/` | `unit_tests_{timestamp}.log` |
| Component Tests | `/logs/` | `component_tests_{timestamp}.log` |
| Subsystem Tests | `/logs/subsystem_tests/` | `{subsystem}_subsystem_{timestamp}.log` |
| All Tests | `/logs/` | `all_tests_summary_{timestamp}.log` |

## When to Use Each Test Type

### Write Unit Tests When:
- Testing a single class or function
- Verifying calculations or data transformations
- Testing state management within a component
- Need fast feedback during development

### Write Component Tests When:
- Testing communication between 2-3 systems
- Verifying timing or sequencing between components
- Testing contracts/interfaces between systems
- Unit-level mocking would hide the real issue

### Write Subsystem Tests When:
- Testing complete user workflows
- Verifying 4+ components work together
- Testing emergent behaviors
- Validating visual correctness
- Performance testing under realistic conditions

## Quick Decision Tree

```
How many components are involved?
├─ 1 component → Unit Test
├─ 2-3 components → Component Test
└─ 4+ components → Subsystem Test
```

## Test Runner Features

### Omni Test Runner (`run_all_tests.sh`)
- **Gated Execution**: Stops if any test type fails
- **Sequential Order**: Unit → Component → Subsystem
- **Summary Report**: Overall pass/fail status
- **Timing Information**: Duration for each test type
- **Detailed Logging**: Combined summary log file

### Individual Test Runners
- **Selective Execution**: Run specific tests by name
- **Timeout Protection**: Prevents hanging tests
- **Detailed Output**: Individual test results
- **Exit Codes**: 0 for success, non-zero for failure

## Further Documentation

For detailed information about each test type:

- **Unit Testing**: See [Unit Testing Guide](unit_testing_guide.md)
- **Component Testing**: See [Component Testing Guide](component_testing_guide.md)
- **Subsystem Testing**: See [Subsystem Testing Guide](subsystem_testing_guide.md)

## Common Commands Reference

```bash
# Quick test health check
./tools/run_all_tests.sh

# Debug a failing unit test
./tools/run_unit_tests.sh failing_test_name

# Check component interactions
./tools/run_component_tests.sh

# Validate complete features
./tools/run_subsystem_tests.sh

# View latest test results
ls -la logs/*_test*.log | tail -10

# Check test summary
cat logs/all_tests_summary_*.log | tail -1
```