#!/bin/bash
# Session logger tool for A Silent Refraction development
# Helps track progress across multiple development sessions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Constants
SESSION_LOG_DIR="dev_logs/sessions"
CURRENT_SESSION_FILE="$SESSION_LOG_DIR/current_session.md"
SESSION_SUMMARY_FILE="$SESSION_LOG_DIR/session_summary.md"
ITERATION_PROGRESS_FILE="docs/iteration_progress.md"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_FORMATTED=$(date +"%B %d, %Y")
TIME_FORMATTED=$(date +"%H:%M:%S")

# Check if session log directory exists, create if not
function ensure_log_dir() {
    if [ ! -d "$SESSION_LOG_DIR" ]; then
        mkdir -p "$SESSION_LOG_DIR"
        echo -e "${GREEN}Created session log directory: $SESSION_LOG_DIR${NC}"
    fi
}

# Create a new development session
function start_session() {
    ensure_log_dir
    
    # Check if a session is already in progress
    if [ -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${YELLOW}A session is already in progress.${NC}"
        echo -e "Do you want to:"
        echo -e "  ${CYAN}1${NC} - Continue the existing session"
        echo -e "  ${CYAN}2${NC} - End the current session and start a new one"
        echo -e "  ${CYAN}3${NC} - View current session details"
        echo -e "  ${CYAN}q${NC} - Quit"
        read -p "Your choice: " choice
        
        case $choice in
            1)
                echo -e "${GREEN}Continuing existing session.${NC}"
                return 0
                ;;
            2)
                end_session
                ;;
            3)
                cat "$CURRENT_SESSION_FILE"
                echo ""
                return 0
                ;;
            q|Q)
                return 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Exiting.${NC}"
                return 1
                ;;
        esac
    fi
    
    # Gather session information
    read -p "Enter session title: " session_title
    read -p "Enter task focus: " task_focus
    read -p "Enter iteration number: " iteration_number
    
    # Create new session file
    SESSION_FILE="$SESSION_LOG_DIR/session_${TIMESTAMP}.md"
    
    cat > "$SESSION_FILE" << EOL
# Development Session: $session_title
**Date:** $DATE_FORMATTED
**Time:** $TIME_FORMATTED
**Iteration:** $iteration_number
**Task Focus:** $task_focus

## Session Goals
- 

## Progress Tracking
- [ ] 

## Notes
- 

## Next Steps
- 

## Time Log
- Started: $TIME_FORMATTED
- Ended: [IN PROGRESS]

## Summary
[TO BE COMPLETED]
EOL
    
    # Create a link to the current session
    ln -sf "$SESSION_FILE" "$CURRENT_SESSION_FILE"
    
    echo -e "${GREEN}Started new development session: $session_title${NC}"
    echo -e "${GREEN}Session log created at: $SESSION_FILE${NC}"
    echo -e "${CYAN}You can now edit this file to track your progress.${NC}"
    echo ""
    echo -e "Use the following commands to manage your session:"
    echo -e "  ${YELLOW}$0 add-task \"Task description\"${NC} - Add a new task"
    echo -e "  ${YELLOW}$0 complete-task <task_number>${NC} - Mark a task as completed"
    echo -e "  ${YELLOW}$0 add-note \"Note content\"${NC} - Add a note"
    echo -e "  ${YELLOW}$0 set-goal \"Goal description\"${NC} - Add a session goal"
    echo -e "  ${YELLOW}$0 end${NC} - End the current session"
    
    # Update session summary file
    update_summary
}

# End the current development session
function end_session() {
    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Update end time
    END_TIME=$(date +"%H:%M:%S")
    sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$SESSION_FILE"
    
    # Prompt for session summary
    echo -e "${BLUE}Please provide a summary of what was accomplished in this session:${NC}"
    read -p "> " session_summary
    
    # Update summary
    sed -i "s/\[TO BE COMPLETED\]/$session_summary/" "$SESSION_FILE"
    
    # Remove current session link
    rm -f "$CURRENT_SESSION_FILE"
    
    echo -e "${GREEN}Session ended and logged to: $SESSION_FILE${NC}"
    
    # Update session summary file
    update_summary
}

# Add a new task to the current session
function add_task() {
    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No task description provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Add task to the progress tracking section
    sed -i "/## Progress Tracking/a - [ ] $1" "$SESSION_FILE"
    
    echo -e "${GREEN}Task added to session log.${NC}"
}

# Mark a task as completed
function complete_task() {
    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No task number provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Extract tasks
    TASKS=$(grep -n "- \[ \]" "$SESSION_FILE" | sed 's/:.*//')
    
    # Check if the task number is valid
    TASK_COUNT=$(echo "$TASKS" | wc -l)
    if [ "$1" -lt 1 ] || [ "$1" -gt "$TASK_COUNT" ]; then
        echo -e "${RED}Invalid task number. Tasks range from 1 to $TASK_COUNT.${NC}"
        return 1
    fi
    
    # Get the line number of the task
    TASK_LINE=$(echo "$TASKS" | sed -n "${1}p")
    
    # Mark the task as completed
    sed -i "${TASK_LINE}s/- \[ \]/- \[x\]/" "$SESSION_FILE"
    
    echo -e "${GREEN}Task $1 marked as completed.${NC}"
    
    # Ask if user wants to update iteration progress file
    read -p "Do you want to update the iteration progress file for this task? (y/n): " choice
    if [ "$choice" = "y" ]; then
        # Get the task description
        TASK_DESCRIPTION=$(sed -n "${TASK_LINE}p" "$SESSION_FILE" | sed 's/- \[x\] //')
        echo -e "${BLUE}Updating iteration progress for: '${TASK_DESCRIPTION}'${NC}"
        
        # Try to update the iteration progress file
        update_iteration_progress "$TASK_DESCRIPTION"
    fi
}

# Add a note to the current session
function add_note() {
    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No note content provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Add note to the notes section
    sed -i "/## Notes/a - $1" "$SESSION_FILE"
    
    echo -e "${GREEN}Note added to session log.${NC}"
}

# Add a goal to the current session
function set_goal() {
    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No goal description provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Add goal to the goals section
    sed -i "/## Session Goals/a - $1" "$SESSION_FILE"
    
    echo -e "${GREEN}Goal added to session log.${NC}"
}

# Update the session summary file
function update_summary() {
    ensure_log_dir
    
    # Create summary file if it doesn't exist
    if [ ! -f "$SESSION_SUMMARY_FILE" ]; then
        cat > "$SESSION_SUMMARY_FILE" << EOL
# A Silent Refraction - Development Session Summary

This file provides an overview of all development sessions for the project.

## Sessions
EOL
    fi
    
    # Recreate the sessions list
    # Extract header from the summary file
    grep -B 100 "## Sessions" "$SESSION_SUMMARY_FILE" > "$SESSION_SUMMARY_FILE.tmp"
    echo "## Sessions" >> "$SESSION_SUMMARY_FILE.tmp"
    echo "" >> "$SESSION_SUMMARY_FILE.tmp"
    
    # Add all sessions to the summary
    for session_file in $(find "$SESSION_LOG_DIR" -name "session_*.md" -type f | sort -r); do
        session_date=$(grep "Date:" "$session_file" | sed 's/\*\*Date:\*\* //')
        session_title=$(grep "# Development Session:" "$session_file" | sed 's/# Development Session: //')
        session_iteration=$(grep "Iteration:" "$session_file" | sed 's/\*\*Iteration:\*\* //')
        session_focus=$(grep "Task Focus:" "$session_file" | sed 's/\*\*Task Focus:\*\* //')
        session_summary=$(grep -A 100 "## Summary" "$session_file" | tail -n +2 | grep -v "^$" | head -n 1)
        
        # Check if session is in progress
        if grep -q "\[IN PROGRESS\]" "$session_file"; then
            status="🟢 IN PROGRESS"
        else
            status="✅ COMPLETED"
        fi
        
        echo "### $session_date - $session_title ($status)" >> "$SESSION_SUMMARY_FILE.tmp"
        echo "- **Iteration:** $session_iteration" >> "$SESSION_SUMMARY_FILE.tmp"
        echo "- **Focus:** $session_focus" >> "$SESSION_SUMMARY_FILE.tmp"
        echo "- **Summary:** $session_summary" >> "$SESSION_SUMMARY_FILE.tmp"
        echo "- [Session Log]($(basename "$session_file"))" >> "$SESSION_SUMMARY_FILE.tmp"
        echo "" >> "$SESSION_SUMMARY_FILE.tmp"
    done
    
    # Replace the summary file
    mv "$SESSION_SUMMARY_FILE.tmp" "$SESSION_SUMMARY_FILE"
}

# List all development sessions
function list_sessions() {
    ensure_log_dir
    
    echo -e "${BLUE}A Silent Refraction - Development Sessions${NC}"
    echo ""
    
    if [ ! -f "$SESSION_SUMMARY_FILE" ]; then
        echo -e "${YELLOW}No sessions recorded yet.${NC}"
        return 0
    fi
    
    # Extract and format session information
    grep -A 4 "### " "$SESSION_SUMMARY_FILE" | sed '/^--$/d' | sed 's/### /\n### /'
}

# View a specific session log
function view_session() {
    ensure_log_dir
    
    local session_file
    
    # If no argument, show the current session if it exists
    if [ -z "$1" ]; then
        if [ -f "$CURRENT_SESSION_FILE" ]; then
            session_file="$CURRENT_SESSION_FILE"
        else
            echo -e "${YELLOW}No current session found.${NC}"
            echo -e "${YELLOW}Use '$0 view <session_date>' to view a specific session.${NC}"
            list_sessions
            return 1
        fi
    else
        # Try to find the session by date
        session_files=$(find "$SESSION_LOG_DIR" -name "session_*$1*.md" -type f)
        session_count=$(echo "$session_files" | grep -c "^")
        
        if [ "$session_count" -eq 0 ]; then
            echo -e "${RED}No session found matching '$1'.${NC}"
            return 1
        elif [ "$session_count" -gt 1 ]; then
            echo -e "${YELLOW}Multiple sessions found matching '$1':${NC}"
            echo "$session_files" | sed 's|.*/||' | sed 's|_| |g' | sed 's|session ||' | sed 's|\.md$||'
            return 1
        else
            session_file="$session_files"
        fi
    fi
    
    # Display the session
    less "$session_file"
}

# Link a task to specific code files
function link_task_to_files() {
    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No task number provided.${NC}"
        return 1
    fi
    
    if [ -z "$2" ]; then
        echo -e "${RED}No file path provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Extract tasks (both completed and pending)
    ALL_TASKS=$(grep -n "- \[[x ]\]" "$SESSION_FILE" | sed 's/:.*//')
    
    # Check if the task number is valid
    TASK_COUNT=$(echo "$ALL_TASKS" | wc -l)
    if [ "$1" -lt 1 ] || [ "$1" -gt "$TASK_COUNT" ]; then
        echo -e "${RED}Invalid task number. Tasks range from 1 to $TASK_COUNT.${NC}"
        return 1
    fi
    
    # Get the line number of the task
    TASK_LINE=$(echo "$ALL_TASKS" | sed -n "${1}p")
    
    # Get the task description
    TASK_DESCRIPTION=$(sed -n "${TASK_LINE}p" "$SESSION_FILE")
    
    # Check if the file exists
    if [ ! -f "$2" ] && [ ! -d "$2" ]; then
        echo -e "${YELLOW}Warning: File/directory '$2' does not exist.${NC}"
        read -p "Do you want to continue anyway? (y/n): " choice
        if [ "$choice" != "y" ]; then
            return 1
        fi
    fi
    
    # Check if the task already has a link section
    if ! grep -q "▶ Related files:" <<< "$TASK_DESCRIPTION"; then
        # Add a link section to the task
        NEW_TASK="$TASK_DESCRIPTION\n  ▶ Related files: $2"
        sed -i "${TASK_LINE}c\\${NEW_TASK}" "$SESSION_FILE"
    else
        # Append to the existing link section
        NEW_TASK=$(echo "$TASK_DESCRIPTION" | sed "s|▶ Related files:.*|▶ Related files: &, $2|")
        sed -i "${TASK_LINE}c\\${NEW_TASK}" "$SESSION_FILE"
    fi
    
    echo -e "${GREEN}Linked task to file: $2${NC}"
    
    return 0
}

# Update the iteration progress file when a task is marked complete
function update_iteration_progress() {
    if [ ! -f "$CURRENT_SESSION_FILE" ] || [ -z "$1" ]; then
        return 1
    fi
    
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    TASK_LINE=$(grep -n "- \[x\]" "$SESSION_FILE" | grep -i "$1" | head -n 1 | sed 's/:.*//')
    
    if [ -z "$TASK_LINE" ]; then
        echo -e "${YELLOW}No completed task matching '$1' found in current session.${NC}"
        return 1
    fi
    
    # Get task description and remove the task marker and any related files info
    TASK_DESCRIPTION=$(sed -n "${TASK_LINE}p" "$SESSION_FILE" | sed 's/- \[x\] //' | sed 's/  ▶ Related files:.*//')
    
    if [ ! -f "$ITERATION_PROGRESS_FILE" ]; then
        echo -e "${RED}Iteration progress file not found at $ITERATION_PROGRESS_FILE${NC}"
        return 1
    fi
    
    # Look for the task in the iteration progress file
    PROGRESS_LINE=$(grep -n "$TASK_DESCRIPTION" "$ITERATION_PROGRESS_FILE" | head -n 1 | sed 's/:.*//')
    
    if [ -z "$PROGRESS_LINE" ]; then
        echo -e "${YELLOW}Could not find task in iteration progress file.${NC}"
        echo -e "${YELLOW}Available tasks in progress file:${NC}"
        grep "| .* | Pending" "$ITERATION_PROGRESS_FILE"
        
        # Ask user if they want to see a list of tasks
        read -p "Would you like to update a specific task instead? (y/n): " choice
        if [ "$choice" = "y" ]; then
            echo -e "${BLUE}Enter the task number to update:${NC}"
            grep -n "| .* | Pending" "$ITERATION_PROGRESS_FILE" | sed 's/:/ - /'
            read -p "Task number: " task_num
            if [ ! -z "$task_num" ]; then
                PROGRESS_LINE=$(grep -n "| .* | Pending" "$ITERATION_PROGRESS_FILE" | sed -n "${task_num}p" | sed 's/:.*//')
            fi
        fi
    fi
    
    if [ ! -z "$PROGRESS_LINE" ]; then
        # Update the task status from "Pending" to "Complete"
        sed -i "${PROGRESS_LINE}s/| Pending |/| Complete |/" "$ITERATION_PROGRESS_FILE"
        echo -e "${GREEN}Updated task status in iteration progress file.${NC}"
        return 0
    else
        echo -e "${RED}Failed to update iteration progress file.${NC}"
        return 1
    fi
}

# Show help
function show_help() {
    echo -e "${BLUE}A Silent Refraction - Session Logger${NC}"
    echo ""
    echo -e "Usage: $0 [command] [arguments]"
    echo ""
    echo -e "Commands:"
    echo -e "  ${CYAN}start${NC}                       - Start a new development session"
    echo -e "  ${CYAN}end${NC}                         - End the current session"
    echo -e "  ${CYAN}add-task \"description\"${NC}       - Add a task to the current session"
    echo -e "  ${CYAN}complete-task <number>${NC}        - Mark a task as completed"
    echo -e "  ${CYAN}add-note \"content\"${NC}           - Add a note to the current session"
    echo -e "  ${CYAN}set-goal \"description\"${NC}       - Add a goal to the current session"
    echo -e "  ${CYAN}list${NC}                        - List all development sessions"
    echo -e "  ${CYAN}view [date]${NC}                 - View a specific session (or current if no date)"
    echo -e "  ${CYAN}link-task <number> <file>${NC}    - Link a task to specific code files"
    echo -e "  ${CYAN}update-progress \"keyword\"${NC}    - Update iteration progress file for a completed task"
    echo -e "  ${CYAN}install${NC}                     - Install session logger for system-wide use"
    echo -e "  ${CYAN}help${NC}                        - Show this help message"
    echo ""
    echo -e "Examples:"
    echo -e "  $0 start                     # Start a new session"
    echo -e "  $0 add-task \"Implement scrolling camera system\""
    echo -e "  $0 complete-task 1           # Mark the first task as completed"
    echo -e "  $0 add-note \"Found bug in camera implementation\""
    echo -e "  $0 link-task 1 \"src/core/camera/scrolling_camera.gd\"  # Link task to file"
    echo -e "  $0 update-progress \"camera\"   # Update iteration progress for completed camera task"
    echo -e "  $0 end                       # End the current session"
    echo -e "  $0 list                      # List all sessions"
    echo -e "  $0 view 2025-05-12           # View session from May 12, 2025"
    echo -e "  $0 install                   # Install session logger system-wide"
}

# Install the session logger
function install() {
    ensure_log_dir
    
    # Create a symbolic link to make the script easily accessible
    if [ ! -L "/usr/local/bin/session-logger" ]; then
        echo -e "${YELLOW}Creating symbolic link for easy access...${NC}"
        echo -e "${YELLOW}This may require sudo privileges.${NC}"
        sudo ln -sf "$(readlink -f "$0")" "/usr/local/bin/session-logger"
        echo -e "${GREEN}You can now use 'session-logger' command from anywhere.${NC}"
    fi
    
    # Create initial session summary file
    if [ ! -f "$SESSION_SUMMARY_FILE" ]; then
        update_summary
    fi
    
    echo -e "${GREEN}Session logger installation complete!${NC}"
    echo -e "${BLUE}Usage: session-logger [command] [arguments]${NC}"
    echo -e "${BLUE}Type 'session-logger help' for more information.${NC}"
}

# Main function
function main() {
    if [ $# -eq 0 ]; then
        show_help
        return 0
    fi
    
    case $1 in
        start)
            start_session
            ;;
        end)
            end_session
            ;;
        add-task)
            add_task "$2"
            ;;
        complete-task)
            complete_task "$2"
            ;;
        add-note)
            add_note "$2"
            ;;
        set-goal)
            set_goal "$2"
            ;;
        list)
            list_sessions
            ;;
        view)
            view_session "$2"
            ;;
        help)
            show_help
            ;;
        install)
            install
            ;;
        update-progress)
            update_iteration_progress "$2"
            ;;
        link-task)
            link_task_to_files "$2" "$3"
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            return 1
            ;;
    esac
}

# Run the script
main "$@"