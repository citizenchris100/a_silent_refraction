# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Silent Refraction is a SCUMM-style point-and-click adventure game built with Godot 3.5.2. In this game, players navigate a space station where a mysterious substance is assimilating inhabitants, focusing on point-and-click navigation, verb-based interactions, NPC dialog, and suspicion mechanics.

## Common Commands

### Running the Game and Test Scenes

```bash
# Run the full game
./a_silent_refraction.sh run

# Run specific test scenes
./a_silent_refraction.sh navigation    # Test navigation system
./a_silent_refraction.sh dialog        # Test dialog system
./a_silent_refraction.sh test          # Test NPC system
```

### Project Management

```bash
# Check project for errors
./a_silent_refraction.sh check

# Clean up redundant files
./a_silent_refraction.sh clean

# Build the game for distribution
./a_silent_refraction.sh build

# Create a new NPC
./a_silent_refraction.sh new-npc <npc_name>

# Create a new district
./a_silent_refraction.sh new-district <district_name>
```

### Session Logging

```bash
# Start a new development session with Claude (recommended)
./tools/session_logger.sh claude-session "Session Title" "Task Focus" "2"

# View most recent session info
./tools/session_logger.sh claude get-recent

# End the current session with a summary
./tools/session_logger.sh claude end "Summary of work completed"

# Add tasks to the current session
./tools/session_logger.sh add-task "Task description"

# Mark a task as completed
./tools/session_logger.sh complete-task <number>

# Link a task to a specific file
./tools/session_logger.sh link-task <number> "file_path"

# Add development notes
./tools/session_logger.sh add-note "Note content"

# Set session goals
./tools/session_logger.sh set-goal "Goal description"

# Add next steps for future sessions
./tools/session_logger.sh add-next-step "Next step description"

# List all development sessions
./tools/session_logger.sh list

# View a specific session by date
./tools/session_logger.sh view <date>

# Clean up session logs and fix issues
./tools/session_logger.sh clean auto

# Create a backup of all session logs
./tools/session_logger.sh backup
```

### Iteration Planning

```bash
# Initialize planning system
./tools/iteration_planner.sh init

# Create a new iteration plan
./tools/iteration_planner.sh create <iteration_number> "<iteration_name>"

# List tasks for a specific iteration
./tools/iteration_planner.sh list <iteration_number>

# Update task status
./tools/iteration_planner.sh update <iteration_number> <task_number> <status>
# Where status can be: pending, in_progress, or complete

# Generate progress report
./tools/iteration_planner.sh report

# Link tasks to code files
./tools/iteration_planner.sh link <iteration_number> <task_number> "<file_path>"

# Add a requirement to an iteration (type: business/user/technical)
./tools/iteration_planner.sh add-req <iteration_number> <type> "<text>"

# Add a user story to a task
./tools/iteration_planner.sh add-story <iteration_number> <task_number> "<story>"

# Show help message
./tools/iteration_planner.sh help
```

## Architecture

The game follows a component-based design with clear separation of concerns:

### Core Systems

1. **Game Manager** (`src/core/game/game_manager.gd`):
   - Central coordinator for all game systems
   - Handles object clicks and interactions
   - Routes user input to appropriate systems

2. **Input Manager** (`src/core/input/input_manager.gd`):
   - Processes user input
   - Manages point-and-click movement
   - Detects interactive objects

3. **Dialog Manager** (`src/core/dialog/dialog_manager.gd`):
   - Handles NPC conversations
   - Shows dialog UI with options
   - Processes player dialog choices

4. **District System** (`src/core/districts/base_district.gd`):
   - Base class for all game areas
   - Manages walkable areas
   - Contains interactive objects

### Entity Framework

1. **Base NPC** (`src/characters/npc/base_npc.gd`):
   - Implements state machine (IDLE, TALKING, SUSPICIOUS, HOSTILE, etc.)
   - Manages dialog trees
   - Tracks suspicion level
   - Handles assimilation status

2. **Interactive Objects** (`src/objects/base/interactive_object.gd`):
   - Base class for all interactive items
   - Responds to verb-based interactions

3. **Player Character** (`src/characters/player/player.gd`):
   - Handles movement with acceleration/deceleration
   - Stays within walkable area boundaries
   - Responds to point-and-click input

### UI Systems

1. **Verb UI** (`src/ui/verb_ui/verb_ui.gd`):
   - SCUMM-style verb selection interface
   - Communicates selected verbs to the game manager

2. **Suspicion Meter** (`src/ui/suspicion_meter/global_suspicion_meter.gd`):
   - Displays current NPC suspicion level

## Code Conventions

1. When extending base classes, always call parent ready methods with `._ready()` in child classes
2. Use signal-based communication between systems when possible
3. NPCs should be added to both "npc" and "interactive_object" groups
4. All interactive objects should implement the `interact(verb, item = null)` method
5. Use state machines for complex entity behavior

## Development Approach

1. **Step-by-Step Problem Solving**
   - Think through solutions step-by-step
   - Explain reasoning and decision-making process
   - Show how decisions contribute to the overall project goals

2. **Iterative Collaboration**
   - Wait for confirmation after each step before proceeding
   - Address issues immediately before moving forward
   - Present solutions incrementally to allow for course correction

3. **Architecture Adherence**
   - Always adhere to the structure and approach outlined in the 'docs/reference/architecture.md' document
   - Maintain the component-based design with clear separation of concerns

4. **Iterative Development**
   - Focus on short, achievable, and testable goals
   - Ensure each iteration is testable
   - Build features incrementally with testing at each stage

5. **Refactoring Approach**
   - Review and get approval before performing significant refactoring
   - Avoid excessive refactoring unless explicitly requested or approved

6. **Code Quality**
   - Reduce cyclomatic and cognitive complexity
   - Keep code clean and easy to maintain
   - Focus on readability and maintainability

7. **Reusability**
   - Emphasize code reusability and modularity
   - Follow the DRY (Don't Repeat Yourself) principle
   - Create generic, reusable components when possible
   - Ensure any given piece of knowledge or logic exists only once in the codebase

## Development Notes

- The game is currently in Iteration 2 (NPC Framework and Suspicion System), with 50% completion
- Core systems are implemented but many features are still pending
- Test scenes should be used for isolated testing of specific systems
- The project uses GDScript and follows Godot 3.5.2 conventions