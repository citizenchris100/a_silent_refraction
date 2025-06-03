# CLAUDE.md - Essential Instructions Only

## Project
A Silent Refraction - SCUMM-style point-and-click adventure game (Godot 3.5.2)

## Critical Commands
```bash
# Tests (TDD mandatory - write tests BEFORE implementation)
./tools/run_unit_tests.sh [test_name]      # Run unit tests
./tools/run_component_tests.sh [test_name] # Run component tests  
./tools/run_subsystem_tests.sh [test_name] # Run subsystem tests
./tools/run_all_tests.sh                   # Run all tests

# Game execution
./a_silent_refraction.sh run       # Run full game
./a_silent_refraction.sh check     # Check for errors
```

## Architecture Rules
1. Check for existing tests before modifying ANY class
2. Write tests BEFORE implementation (TDD)
3. Follow component-based design with clear separation
4. Call parent ._ready() in child classes
5. Use signal-based communication between systems
6. Interactive objects must implement interact(verb, item = null)

## Development Approach
- Step-by-step problem solving
- Wait for confirmation between steps  
- No unsolicited file creation (especially docs)
- Avoid excessive refactoring without approval

## References (read when needed)
- **Architecture**: docs/reference/architecture.md
- **Testing Guide**: docs/reference/testing/testing_quick_reference.md
- **Session Logging**: ./tools/session_logger.sh help
- **Iteration Planning**: ./tools/iteration_planner.sh help
- **Full Commands**: docs/reference/commands_reference.md