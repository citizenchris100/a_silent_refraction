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
- Fetch pending tasks from iteration planning system

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

### Task Management

| Command | Description | Example |
|---------|-------------|---------|
| `add-task "description"` | Add a task to the current session | `./tools/session_logger.sh add-task "Implement scrolling camera"` |
| `complete-task <number>` | Mark a task as completed | `./tools/session_logger.sh complete-task 1` |
| `link-task <number> <file>` | Link a task to a specific file | `./tools/session_logger.sh link-task 1 "src/core/camera.gd"` |
| `update-progress "keyword"` | Update the iteration progress file | `./tools/session_logger.sh update-progress "camera"` |
| `get-iteration-tasks <iter#>` | List pending tasks for a specific iteration | `./tools/session_logger.sh get-iteration-tasks 2` |

### Session Content

| Command | Description | Example |
|---------|-------------|---------|
| `add-note "content"` | Add a note to the current session | `./tools/session_logger.sh add-note "Found bug in camera implementation"` |
| `set-goal "description"` | Add a goal to the current session | `./tools/session_logger.sh set-goal "Complete scrolling camera system"` |
| `add-next-step "description"` | Add a next step for future sessions | `./tools/session_logger.sh add-next-step "Test with large backgrounds"` |

### Claude Code Integration

| Command | Description | Example |
|---------|-------------|---------|
| `claude start "title" "focus" "iter#"` | Start a Claude-managed session | `./tools/session_logger.sh claude start "Camera Fixes" "Scrolling Camera" "2"` |
| `claude end "summary"` | End a Claude-managed session | `./tools/session_logger.sh claude end "Fixed camera jittering issues"` |
| `claude continue` | Continue with existing session in Claude mode | `./tools/session_logger.sh claude continue` |
| `get-recent-session` | Get path to most recent session file | `./tools/session_logger.sh get-recent-session` |

## Session Files

Session logs are stored in Markdown format in the `dev_logs/sessions` directory. They contain structured sections:

```markdown
# Development Session: Implement Scrolling Camera
**Date:** May 12, 2025
**Time:** 10:30:45
**Iteration:** 2
**Task Focus:** Camera System

## Session Goals
- Complete the scrolling camera implementation
- Test with different background sizes

## Related Iteration Tasks
- [ ] Implement scrolling camera system for wide backgrounds
- [ ] Add camera bounds validation
- [ ] Create camera debug visualization tools

## Progress Tracking
### Outstanding Items from Previous Session
- [ ] Fix camera jitter when moving near screen edges

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

The new "Related Iteration Tasks" section shows pending tasks from the iteration planning system that are relevant to the current session. The "Outstanding Items from Previous Session" section under Progress Tracking carries over incomplete tasks from your previous work sessions.

## Integration with Iteration Progress

When you mark a task as completed, you'll be prompted to update the iteration progress file. This helps maintain synchronization between your session logs and the overall project progress.

The Session Logger can:

- Find matching tasks in the iteration progress file
- Update their status from "Pending" to "Complete"
- Show you available tasks if an exact match isn't found
- Automatically recalculate and update iteration completion percentages

## Error Recovery and Maintenance

The Session Logger includes several tools for error recovery and maintenance:

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

### Session Migration

To update to a new version of the session logger while preserving all data:

```bash
./tools/session_logger.sh migrate
```

## Tips for Effective Use

1. **Start Each Work Session with the Session Logger**
   ```bash
   ./tools/session_logger.sh start
   ```

2. **Add Tasks at the Beginning**
   Plan what you want to accomplish and add tasks before you start coding.
   ```bash
   ./tools/session_logger.sh add-task "Implement camera bounds"
   ./tools/session_logger.sh add-task "Add debug visualization"
   ```

3. **Link Tasks to Files as You Work**
   When you modify or create files, link them to the relevant task.
   ```bash
   ./tools/session_logger.sh link-task 1 "src/core/camera/scrolling_camera.gd"
   ```

4. **Add Notes About Challenges and Solutions**
   Document issues you encounter and how you solve them.
   ```bash
   ./tools/session_logger.sh add-note "Fixed camera jitter by updating position in _process instead of _physics_process"
   ```

5. **End Your Session with a Good Summary**
   When ending a session, provide a clear, concise summary of what you accomplished.

6. **Use `list` and `view` to Refer to Previous Sessions**
   ```bash
   ./tools/session_logger.sh list
   ./tools/session_logger.sh view 2025-05-10
   ```

7. **Regularly Clean and Maintain Your Session Logs**
   ```bash
   ./tools/session_logger.sh clean
   ```

## Advanced Usage

### Searching Session Logs

You can use standard command-line tools to search across all session logs:

```bash
# Search for all mentions of "camera" in session logs
grep -r "camera" dev_logs/sessions/

# Find all tasks related to a specific feature
grep -r "▶ Related files: src/core/camera" dev_logs/sessions/

# List all completed tasks
grep -r "- \[x\]" dev_logs/sessions/
```

### Updating the Iteration Progress File

While tasks are automatically linked to the iteration progress file when marked complete, you can also manually update it:

```bash
# Update a specific task in the iteration progress file
./tools/session_logger.sh update-progress "camera system"
```

## Troubleshooting

If you encounter issues with the Session Logger:

- Run `./tools/session_logger.sh recover` to fix broken or incomplete sessions
- Run `./tools/session_logger.sh clean` to clean up and fix session logs
- Ensure the log directory (`dev_logs/sessions`) exists
- Check file permissions (`chmod +x tools/session_logger.sh`)
- Verify that required dependencies (sed, grep) are installed
- Ensure the iteration progress file exists at the expected path

## Claude Code Integration

The Session Logger includes special features for integration with Claude Code, Anthropic's AI assistant for coding. These features make it easier to track development sessions when working with Claude.

### How Claude Integration Works

1. **Session Continuity**: Claude can start new sessions or continue existing ones, carrying over outstanding tasks and next steps automatically.

2. **Task Extraction**: When Claude ends a session, incomplete tasks are automatically captured and added to the next steps section.

3. **Iteration Task Integration**: Claude can fetch pending tasks from your iteration planning system, helping to prioritize work according to your project roadmap.

4. **Automated Session Management**: Claude can maintain session consistency across conversations, ensuring your development history remains coherent.

### Using Claude with Session Logger

To start a session with Claude:

```bash
./tools/session_logger.sh claude start "Camera Improvements" "Scrolling Camera" "2.5"
```

To end a session and preserve unfinished tasks for next time:

```bash
./tools/session_logger.sh claude end "Implemented smooth camera transitions but still need to fix edge bounds"
```

To continue an existing session:

```bash
./tools/session_logger.sh claude continue
```

## Example: Complete Development Session

Here's an example of a full development session workflow:

```bash
# Start a new session with iteration tasks integration
./tools/session_logger.sh start
# (enter session title, focus, and iteration number)

# View pending tasks for your iteration
./tools/session_logger.sh get-iteration-tasks 2

# Add session goals
./tools/session_logger.sh set-goal "Implement scrolling camera system"
./tools/session_logger.sh set-goal "Test with different background sizes"

# Add specific tasks
./tools/session_logger.sh add-task "Create base scrolling camera class"
./tools/session_logger.sh add-task "Modify district class to support camera"
./tools/session_logger.sh add-task "Add camera bounds validation"

# As you complete tasks, mark them and link to files
./tools/session_logger.sh complete-task 1
./tools/session_logger.sh link-task 1 "src/core/camera/scrolling_camera.gd"

./tools/session_logger.sh complete-task 2
./tools/session_logger.sh link-task 2 "src/core/districts/base_district.gd"

# Add notes about important discoveries
./tools/session_logger.sh add-note "Camera needs to respect screen size when calculating bounds"

# Add next steps for future sessions
./tools/session_logger.sh add-next-step "Implement camera smoothing"
./tools/session_logger.sh add-next-step "Add debug visualization for camera bounds"

# End the session with a summary
./tools/session_logger.sh end
# (enter summary of what was accomplished)
```

This creates a comprehensive record of your development session that you can refer back to later and helps ensure continuity between work sessions.

### Example: Claude Code Workflow

Here's how you might use the Session Logger with Claude Code:

```bash
# Start a Claude-managed session
./tools/session_logger.sh claude start "Camera Fixes" "Camera System" "2"

# Claude works on the tasks, then when finished:
./tools/session_logger.sh claude end "Fixed camera jitter issues and implemented proper bounds checking. Still need to add debug visualization."

# Later, continuing the session:
./tools/session_logger.sh claude continue
# (Claude can see the previous session's outstanding tasks and next steps)
```