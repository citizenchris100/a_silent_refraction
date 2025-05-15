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
| `claude get-recent` | Get the most recent session info for Claude | `./tools/session_logger.sh claude get-recent` |
| `claude start "title" "focus" "iter#"` | Start a new session for Claude | `./tools/session_logger.sh claude start "Camera System" "Camera Effects" "2"` |
| `claude end "summary"` | End the current session with Claude's summary | `./tools/session_logger.sh claude end "Implemented scrolling camera"` |

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

### Adding New Tasks

Tasks can be linked with specific iteration tasks:

1. Each session clearly shows which iteration it belongs to
2. New tasks can be designed to fulfill specific pending iteration tasks
3. Tasks remain linked with related files for better tracking

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

### Session Backup

Before performing risky operations, you can create a backup of your session logs:

```bash
./tools/session_logger.sh backup
```

This creates a timestamped backup directory with all session logs.

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

7. **Update Iteration Progress for Completed Tasks**
   ```bash
   ./tools/session_logger.sh update-progress "camera system"
   ```

8. **Regularly Clean and Maintain Your Session Logs**
   ```bash
   ./tools/session_logger.sh clean
   ```

## Using with Claude Code

The Session Logger has special integration with Claude Code to assist with AI-powered development:

### Starting a Claude Session

When starting a session with Claude, use the claude start command:

```bash
./tools/session_logger.sh claude start "Camera System" "Camera Effects" "2"
```

This will:
1. Create a properly formatted session file
2. Automatically gather iteration tasks
3. Import outstanding tasks from previous sessions
4. Return the session content to Claude

### Ending a Claude Session

When Claude has completed its work, use:

```bash
./tools/session_logger.sh claude end "Implemented camera system with smooth scrolling and bounds validation"
```

This properly ends the session with Claude's provided summary.

### Viewing Recent Sessions

Claude can get information about recent sessions:

```bash
./tools/session_logger.sh claude get-recent
```

This provides Claude with the context of the latest work to continue work in the right direction.

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

### Automating Session Logger Operations

You can use the non-interactive versions of many commands to automate workflows:

```bash
# Non-interactive start session
./tools/session_logger.sh start "Camera Enhancements" "Camera Effects" "2"

# Auto-complete and update a task
./tools/session_logger.sh complete-task 1 auto-update

# Non-interactive end session
./tools/session_logger.sh end "Added smooth camera transitions and zoom functionality"

# Auto-fix sessions
./tools/session_logger.sh recover auto
./tools/session_logger.sh clean auto
```

## Troubleshooting

If you encounter issues with the Session Logger:

- Run `./tools/session_logger.sh recover` to fix broken or incomplete sessions
- Run `./tools/session_logger.sh clean` to clean up and fix session logs
- Ensure the log directory (`dev_logs/sessions`) exists
- Check file permissions (`chmod +x tools/session_logger.sh`)
- Verify that required dependencies (sed, grep) are installed
- Ensure the iteration progress file exists at the expected path

## Example: Complete Development Session

Here's an example of a full development session workflow:

```bash
# Start a new session
./tools/session_logger.sh start
# (enter session title, focus, and iteration number)

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
./tools/session_logger.sh add-next-step "Test with larger backgrounds"

# End the session with a summary
./tools/session_logger.sh end
# (enter summary of what was accomplished)
```

This creates a comprehensive record of your development session that you can refer back to later and helps ensure continuity between work sessions.