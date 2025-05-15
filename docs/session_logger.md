# Session Logger for A Silent Refraction

The Session Logger is a powerful tool designed to help you maintain continuity across development sessions. It allows you to track progress, manage tasks, and document your work in a structured, searchable format.

## Overview

When working on complex game development tasks, it's common to spread work across multiple sessions. The Session Logger helps you:

- Easily pick up where you left off
- Track task status and completion
- Maintain development notes and observations
- Connect tasks to specific code files
- Generate comprehensive session summaries
- Update the iteration progress file automatically
- Integrate with Claude Code for AI-assisted development

## Getting Started

### Installation

The Session Logger is included with the project in the `tools` directory. To install it for system-wide use:

```bash
./tools/session_logger.sh install
```

This will create a symbolic link to the script in `/usr/local/bin`, allowing you to use the command `session-logger` from anywhere.

### Basic Workflow

A typical development workflow with the Session Logger looks like this:

1. **Start a session** when you begin working
2. **Add tasks** you plan to work on
3. **Add notes** as you encounter issues or make discoveries
4. **Mark tasks as completed** as you finish them
5. **Link tasks to files** that you've modified
6. **End the session** when you're done, providing a summary

## Available Commands

### Managing Sessions

| Command | Description | Example |
|---------|-------------|---------|
| `start` | Start a new development session | `./tools/session_logger.sh start` |
| `end` | End the current session | `./tools/session_logger.sh end` |
| `list` | List all development sessions | `./tools/session_logger.sh list` |
| `view [date]` | View a specific session | `./tools/session_logger.sh view 2025-05-12` |
| `recover` | Recover from incomplete or broken sessions | `./tools/session_logger.sh recover` |
| `clean` | Clean up session logs directory | `./tools/session_logger.sh clean` |
| `backup` | Backup all session logs | `./tools/session_logger.sh backup` |
| `update-summary` | Update the session summary file | `./tools/session_logger.sh update-summary` |

### Task Management

| Command | Description | Example |
|---------|-------------|---------|
| `add-task "description"` | Add a task to the current session | `./tools/session_logger.sh add-task "Implement scrolling camera"` |
| `complete-task <number>` | Mark a task as completed | `./tools/session_logger.sh complete-task 1` |
| `link-task <number> <file>` | Link a task to a specific file | `./tools/session_logger.sh link-task 1 "src/core/camera.gd"` |
| `update-progress "keyword"` | Update the iteration progress file | `./tools/session_logger.sh update-progress "camera"` |

### Session Content

| Command | Description | Example |
|---------|-------------|---------|
| `add-note "content"` | Add a note to the current session | `./tools/session_logger.sh add-note "Found bug in camera implementation"` |
| `set-goal "description"` | Add a goal to the current session | `./tools/session_logger.sh set-goal "Complete scrolling camera system"` |
| `add-next-step "description"` | Add a next step to the current session | `./tools/session_logger.sh add-next-step "Test camera with larger backgrounds"` |

### Claude Code Integration

| Command | Description | Example |
|---------|-------------|---------|
| `claude-session "title" "focus" "iter#"` | Start a new session with robust error handling (RECOMMENDED) | `./tools/session_logger.sh claude-session "Camera System" "Camera Effects" "2"` |
| `claude get-recent` | Get the most recent session info for Claude | `./tools/session_logger.sh claude get-recent` |
| `claude start "title" "focus" "iter#"` | Start a new session for Claude (legacy) | `./tools/session_logger.sh claude start "Camera System" "Camera Effects" "2"` |
| `claude end "summary"` | End the current session with Claude's summary | `./tools/session_logger.sh claude end "Implemented scrolling camera"` |

## Directory Structure and File Locations

All session logs are stored in the `dev_logs/sessions` directory:

```
dev_logs/
└── sessions/
    ├── session_summary.md                 # Overview of all sessions
    ├── current_session.md                 # Symlink to the active session
    ├── session_YYYY-MM-DD_HH-MM-SS.md     # Individual session logs
    └── backup_YYYYMMDD_HHMMSS/            # Backup directories
```

### Key Files

- **current_session.md**: This is a symbolic link to the currently active session file. Commands like `add-task` modify this file.
- **session_summary.md**: Provides an overview of all sessions with their status and summaries.
- **session_YYYY-MM-DD_HH-MM-SS.md**: Actual session log files named with timestamps.

## Session Files

Session logs are stored in Markdown format in the `dev_logs/sessions` directory. They contain structured sections:

```markdown
# Development Session: Implement Scrolling Camera
**Date:** May 12, 2025
**Time:** 10:30:45
**Iteration:** 2 - Camera and Movement Systems
**Task Focus:** Camera System

## Session Goals
- Complete the scrolling camera implementation
- Test with different background sizes

## Related Iteration Tasks
- [ ] Implement camera bounds validation
- [ ] Add screen edge detection for scrolling

## Progress Tracking
### Outstanding Tasks from Previous Session
- [ ] Fix camera position at startup

### New Tasks
- [x] Create base scrolling camera class
  ▶ Related files: src/core/camera/scrolling_camera.gd
- [x] Modify district class to support camera
  ▶ Related files: src/core/districts/base_district.gd
- [ ] Add camera bounds validation

## Notes
- Found issue with camera positioning when background is centered
- Need to ensure camera bounds are respected at screen edges

## Next Steps
- Test with larger background images
- Add interpolation for smoother camera movement

## Time Log
- Started: 10:30:45
- Ended: 12:45:32

## Summary
Implemented basic scrolling camera system that follows player when they approach screen edges. Modified district system to support camera initialization and configuration.
```

## Integration with Iteration Planning System

The Session Logger fully integrates with the Iteration Planning system to ensure your session work is properly tracked and updated in the project's overall progress:

### Starting a Session

When you start a new session, the logger automatically:

1. Retrieves the **iteration name** from the `docs/iteration_progress.md` file, based on the iteration number you provide
2. Pulls **pending tasks** from the current iteration into a "Related Iteration Tasks" section
3. Retrieves **incomplete tasks** and **next steps** from your previous session

### Completing Tasks

When you mark a task as completed:

1. You're prompted to update the corresponding task in the iteration progress file
2. The iteration progress file is automatically updated with the task marked as "Complete"
3. The iteration progress summary is recalculated to show the new completion percentage

## Error Recovery and Maintenance

The Session Logger includes several tools for error recovery and maintenance, and is designed to handle special characters in summaries and task descriptions gracefully:

### Session Recovery

If a session is interrupted abnormally, you can use the `recover` command to:

- Find incomplete sessions (those marked as "IN PROGRESS")
- Resume an incomplete session
- Properly close an incomplete session
- Fix broken session links

```bash
./tools/session_logger.sh recover
```

### Session Cleanup

For general maintenance and to fix issues, use the `clean` command:

- Remove empty session files
- Auto-close lingering incomplete sessions
- Fix broken session links
- Regenerate the session summary file if it has issues

```bash
./tools/session_logger.sh clean
```

## Using with Claude Code

### Special Instructions for Claude

When working with Claude Code, follow these specific steps to ensure seamless session handling:

#### 1. Continuing from Previous Sessions

When a user asks to pick up where they left off or continue previous work:

```
Using session manager (/docs/session_logger.md). I would like to pick up where we left off from the most recent session please.
```

Claude should:

1. Use the `claude-session` command to start a new session (NOT the legacy `claude start` command):
   ```bash
   ./tools/session_logger.sh claude-session "Debug System Testing" "Testing Debug Tools" "2"
   ```
   - First parameter: Session title (based on the ongoing work)
   - Second parameter: Task focus (more specific area of focus)
   - Third parameter: Iteration number (IMPORTANT: always use "2" unless explicitly told otherwise)

2. If there are any issues with starting the session, use the cleanup tools:
   ```bash
   ./tools/session_logger.sh clean auto
   ```
   Then try starting the session again.

3. After creating a new session, add goals and tasks based on previous work:
   ```bash
   ./tools/session_logger.sh set-goal "Continue debug system implementation"
   ./tools/session_logger.sh add-task "Test coordinate picker visualization"
   ```

#### 2. Adding Tasks and Notes

During a session, always use the session logger to track work:

```bash
# Add tasks
./tools/session_logger.sh add-task "Task description"

# Add notes about findings
./tools/session_logger.sh add-note "Note content"

# Add goals
./tools/session_logger.sh set-goal "Goal description"
```

#### 3. Finding Previous Work

To access previous work:

```bash
# Get all sessions (you'll see this in the summary file)
./tools/session_logger.sh list

# View the most recent session
./tools/session_logger.sh claude get-recent

# View a specific session by date
./tools/session_logger.sh view 2025-05-14
```

#### 4. Ending a Session

When concluding work:

```bash
./tools/session_logger.sh claude end "Brief summary of what was accomplished"
```

### Starting a Claude Session

When starting a session with Claude, use the claude-session command (preferred over claude start):

```bash
./tools/session_logger.sh claude-session "Camera System" "Camera Effects" "2"
```

This will:
1. Create a properly formatted session file
2. Automatically gather iteration tasks
3. Import outstanding tasks from previous sessions
4. Return the session content to Claude

### Common Issues and Solutions

If you encounter any of these issues:

0. **Summary with special characters**: The system handles special characters in summaries using a robust approach with multiple fallback methods. No special escaping is required when writing summaries.

1. **"No active session found"**: The current_session.md symlink is missing or broken.
   ```bash
   # Fix by creating a new session
   ./tools/session_logger.sh claude-session "Session Title" "Task Focus" "2"
   ```

2. **"Error: Iteration number must be a number"**: The iteration parameter has whitespace or formatting issues.
   ```bash
   # Use a plain number without quotes
   ./tools/session_logger.sh claude-session "Session Title" "Task Focus" 2
   ```

3. **Cleanup required**: When multiple broken sessions exist
   ```bash
   # Run cleanup before starting a new session
   ./tools/session_logger.sh clean auto
   ```

## Tips for Effective Use

1. **Always use claude-session** instead of other methods for starting sessions with Claude
   ```bash
   ./tools/session_logger.sh claude-session "Session Title" "Task Focus" "2"
   ```

2. **Add Tasks at the Beginning**
   Plan what you want to accomplish and add tasks before you start coding.
   ```bash
   ./tools/session_logger.sh add-task "Implement camera bounds"
   ./tools/session_logger.sh add-task "Add debug visualization"
   ```

3. **Add Notes About Challenges and Solutions**
   Document issues you encounter and how you solve them.
   ```bash
   ./tools/session_logger.sh add-note "Fixed camera jitter by updating position in _process instead of _physics_process"
   ```

4. **End Your Session with a Good Summary**
   When ending a session, provide a clear, concise summary of what you accomplished. You can safely include special characters in your summaries, as the system now handles them correctly.

5. **Check for Task Progress from Previous Sessions**
   Always check what was happening in the previous session by examining both completed and incomplete tasks.

## Troubleshooting

If you encounter issues with the Session Logger:

- Run `./tools/session_logger.sh recover` to fix broken or incomplete sessions
- Run `./tools/session_logger.sh clean auto` to clean up and fix session logs
- Ensure the log directory (`dev_logs/sessions`) exists
- Check file permissions (`chmod +x tools/session_logger.sh`)
- Verify that required dependencies (sed, grep) are installed
- Ensure the iteration progress file exists at the expected path

## Example: Claude Development Session

Here's an example of how Claude should handle a development session:

```bash
# User: "Using session manager. Please pick up where we left off."

# Claude should:
# 1. Check recent sessions
./tools/session_logger.sh claude get-recent

# 2. Start a new session based on previous work
./tools/session_logger.sh claude-session "Debug System Testing" "Coordinate Picker Enhancements" "2"

# 3. After reviewing the output, add tasks based on previous work
./tools/session_logger.sh set-goal "Improve coordinate picker visibility"
./tools/session_logger.sh add-task "Fix crosshair size and color"
./tools/session_logger.sh add-task "Add animation to coordinate notifications"

# 4. After completing work
./tools/session_logger.sh claude end "Enhanced coordinate picker visibility with larger crosshairs and animated notifications for better visibility during debug sessions"
```

This approach ensures seamless continuity between sessions and proper documentation of development work.