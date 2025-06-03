# Commands Reference

## Game Management Commands

### Running the Game
```bash
./a_silent_refraction.sh run          # Run full game
./a_silent_refraction.sh navigation   # Test navigation system
./a_silent_refraction.sh dialog       # Test dialog system  
./a_silent_refraction.sh test         # Test NPC system
./a_silent_refraction.sh check        # Check project for errors
./a_silent_refraction.sh clean        # Clean up redundant files
./a_silent_refraction.sh build        # Build for distribution
```

### Content Creation
```bash
./a_silent_refraction.sh new-npc <npc_name>           # Create new NPC
./a_silent_refraction.sh new-district <district_name> # Create new district
```

## Testing Commands

### Test Runners
```bash
./tools/run_all_tests.sh                    # Run all tests (gated)
./tools/run_unit_tests.sh [test_name]       # Run unit tests
./tools/run_component_tests.sh [test_name]  # Run component tests
./tools/run_subsystem_tests.sh [test_name]  # Run subsystem tests
```

## Session Management

### Session Logging
```bash
./tools/session_logger.sh claude-session "Title" "Focus" "2"  # Start session
./tools/session_logger.sh claude get-recent                   # View recent
./tools/session_logger.sh claude end "Summary"                # End session
./tools/session_logger.sh add-task "Task"                     # Add task
./tools/session_logger.sh complete-task <number>              # Complete task
./tools/session_logger.sh link-task <number> "file"           # Link file
./tools/session_logger.sh add-note "Note"                     # Add note
./tools/session_logger.sh set-goal "Goal"                     # Set goal
./tools/session_logger.sh add-next-step "Step"                # Add next step
./tools/session_logger.sh list                                # List sessions
./tools/session_logger.sh view <date>                         # View session
./tools/session_logger.sh clean auto                          # Clean logs
./tools/session_logger.sh backup                              # Backup logs
```

### Iteration Planning
```bash
./tools/iteration_planner.sh init                                    # Initialize
./tools/iteration_planner.sh create <num> "<name>"                   # Create iteration
./tools/iteration_planner.sh list <num>                              # List tasks
./tools/iteration_planner.sh update <num> <task> <status>            # Update status
./tools/iteration_planner.sh report                                  # Progress report
./tools/iteration_planner.sh link <num> <task> "<file>"              # Link file
./tools/iteration_planner.sh add-req <num> <type> "<text>"           # Add requirement
./tools/iteration_planner.sh add-story <num> <task> "<story>"        # Add user story
./tools/iteration_planner.sh help                                    # Show help
```

Status values: pending, in_progress, complete
Requirement types: business, user, technical