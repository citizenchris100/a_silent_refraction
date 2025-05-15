#!/bin/bash
# Unified Session Logger for A Silent Refraction development
# Helps track progress across multiple development sessions with Claude integration

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

# Validate required inputs with appropriate error messages
function validate_input() {
    local field_name="$1"
    local field_value="$2"
    
    if [ -z "$field_value" ] || [[ "$field_value" =~ ^[[:space:]]*$ ]]; then
        echo -e "${RED}Error: $field_name cannot be empty.${NC}"
        return 1
    fi
    
    return 0
}

# Backup session logs before performing risky operations
function backup_sessions() {
    ensure_log_dir
    
    # Create backup folder
    BACKUP_DIR="${SESSION_LOG_DIR}/backup_$(date +"%Y%m%d_%H%M%S")"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing session files
    echo -e "${BLUE}Creating backup of existing session logs...${NC}"
    cp -r "${SESSION_LOG_DIR}"/*.md "$BACKUP_DIR/" 2>/dev/null
    echo -e "${GREEN}Backup created at: $BACKUP_DIR${NC}"
    
    return 0
}

# Get pending tasks from iteration progress file
function get_iteration_tasks() {
    local iteration_number="$1"
    local tasks=""
    
    if [ ! -f "$ITERATION_PROGRESS_FILE" ]; then
        echo ""
        return 0
    fi
    
    # Find the section for the specified iteration
    local section_start=$(grep -n "^### Iteration $iteration_number:" "$ITERATION_PROGRESS_FILE"  < /dev/null |  cut -d: -f1)
    
    if [ -z "$section_start" ]; then
        # Try with a more flexible search if the exact match isn't found
        section_start=$(grep -n "^### Iteration $iteration_number[^0-9]" "$ITERATION_PROGRESS_FILE" | cut -d: -f1)
    fi
    
    if [ -n "$section_start" ]; then
        # Find the next iteration section or end of file
        local next_section=$(tail -n +$((section_start + 1)) "$ITERATION_PROGRESS_FILE" | grep -n "^### Iteration" | head -1 | cut -d: -f1)
        
        if [ -n "$next_section" ]; then
            next_section=$((section_start + next_section))
        else
            next_section=$(wc -l < "$ITERATION_PROGRESS_FILE")
        fi
        
        # Extract pending tasks
        tasks=$(sed -n "${section_start},${next_section}p" "$ITERATION_PROGRESS_FILE" | grep "| Pending |" | sed 's/^| /- [ ] /' | sed 's/ | Pending |.*$//' | sed 's/ *$//')
    fi
    
    echo "$tasks"
}

# Get the name of the current iteration from the iteration progress file
function get_current_iteration_name() {
    local iteration_number="$1"
    local name=""
    
    if [ ! -f "$ITERATION_PROGRESS_FILE" ]; then
        echo "Unknown"
        return 0
    fi
    
    # Find the section for the specified iteration
    local line=$(grep "^### Iteration $iteration_number:" "$ITERATION_PROGRESS_FILE" | head -1)
    
    if [ -z "$line" ]; then
        # Try with a more flexible search if the exact match isn't found
        line=$(grep "^### Iteration $iteration_number[^0-9]" "$ITERATION_PROGRESS_FILE" | head -1)
    fi
    
    if [ -n "$line" ]; then
        name=$(echo "$line" | sed -E 's/^### Iteration [0-9.]+: (.*)/\1/')
    else
        name="Unknown"
    fi
    
    echo "$name"
}

# Get incomplete tasks from the most recent session
function get_previous_incomplete_tasks() {
    local previous_tasks=""
    
    # Find the most recent session file (excluding the current one if it exists)
    local previous_session_file=""
    
    if [ -f "$CURRENT_SESSION_FILE" ] && [ -L "$CURRENT_SESSION_FILE" ]; then
        # If there's a current session, get the file it points to
        previous_session_file=$(readlink -f "$CURRENT_SESSION_FILE")
    else
        # Otherwise find the most recent session file
        previous_session_file=$(find "$SESSION_LOG_DIR" -name "session_*.md" -type f | sort -r | head -n 1)
    fi
    
    if [ -n "$previous_session_file" ] && [ -f "$previous_session_file" ]; then
        # Extract incomplete tasks
        previous_tasks=$(grep -n "- \[ \]" "$previous_session_file" | sed 's/^[0-9]*://')
    fi
    
    echo "$previous_tasks"
}

# Get next steps from the most recent session
function get_previous_next_steps() {
    local next_steps=""
    
    # Find the most recent session file (excluding the current one if it exists)
    local previous_session_file=""
    
    if [ -f "$CURRENT_SESSION_FILE" ] && [ -L "$CURRENT_SESSION_FILE" ]; then
        # If there's a current session, get the file it points to
        previous_session_file=$(readlink -f "$CURRENT_SESSION_FILE")
    else
        # Otherwise find the most recent session file
        previous_session_file=$(find "$SESSION_LOG_DIR" -name "session_*.md" -type f | sort -r | head -n 1)
    fi
    
    if [ -n "$previous_session_file" ] && [ -f "$previous_session_file" ]; then
        # Extract next steps section
        next_steps=$(awk '/^## Next Steps$/{flag=1; next} /^## /{flag=0} flag' "$previous_session_file")
    fi
    
    echo "$next_steps"
}

# Create a new development session
function start_session() {
    ensure_log_dir
    
    # Check if additional arguments were provided for non-interactive use
    local noninteractive=false
    local session_title=""
    local task_focus=""
    local iteration_number=""
    
    if [ ! -z "$1" ] && [ ! -z "$2" ] && [ ! -z "$3" ]; then
        noninteractive=true
        session_title="$1"
        task_focus="$2"
        iteration_number="$3"
        
        # Validate inputs for non-interactive mode
        if ! validate_input "Session title" "$session_title"; then
            return 1
        fi
        if ! validate_input "Task focus" "$task_focus"; then
            return 1
        fi
        if ! validate_input "Iteration number" "$iteration_number"; then
            return 1
        fi
        
        # Validate that iteration number is numeric
        if ! [[ "$iteration_number" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            echo -e "${RED}Error: Iteration number must be a number (e.g., 2 or 3.5).${NC}"
            return 1
        fi
    fi
    
    # Check if a session is already in progress
    if [ -f "$CURRENT_SESSION_FILE" ]; then
        if [ "$noninteractive" = true ]; then
            echo -e "${YELLOW}A session is already in progress. Ending it first...${NC}"
            end_session_noninteractive
        else
            echo -e "${YELLOW}A session is already in progress.${NC}"
            echo -e "Do you want to:"
            echo -e "  ${CYAN}1${NC} - Continue the existing session"
            echo -e "  ${CYAN}2${NC} - End the current session and start a new one"
            echo -e "  ${CYAN}3${NC} - View current session details"
            echo -e "  ${CYAN}4${NC} - Recover from an incomplete session"
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
                4)
                    recover_session
                    return $?
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
    fi
    
    # If not in non-interactive mode, gather session information with validation
    if [ "$noninteractive" = false ]; then
        while true; do
            read -p "Enter session title: " session_title
            if validate_input "Session title" "$session_title"; then
                break
            fi
        done
        
        while true; do
            read -p "Enter task focus: " task_focus
            if validate_input "Task focus" "$task_focus"; then
                break
            fi
        done
        
        while true; do
            read -p "Enter iteration number: " iteration_number
            if validate_input "Iteration number" "$iteration_number"; then
                # Validate that iteration number is numeric
                if [[ "$iteration_number" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                    break
                else
                    echo -e "${RED}Error: Iteration number must be a number (e.g., 2 or 3.5).${NC}"
                fi
            fi
        done
    fi
    
    # Create new session file
    SESSION_FILE="$SESSION_LOG_DIR/session_${TIMESTAMP}.md"
    
    # Get iteration name for more context
    local iteration_name=$(get_current_iteration_name "$iteration_number")
    
    # Get pending tasks from iteration progress file
    local iteration_tasks=$(get_iteration_tasks "$iteration_number")
    
    # Get incomplete tasks from previous session
    local previous_tasks=$(get_previous_incomplete_tasks)
    
    # Get next steps from previous session
    local previous_next_steps=$(get_previous_next_steps)
    
    # Generate session file with appropriate sections
    cat > "$SESSION_FILE" << EOL
# Development Session: $session_title
**Date:** $DATE_FORMATTED
**Time:** $TIME_FORMATTED
**Iteration:** $iteration_number - $iteration_name
**Task Focus:** $task_focus

## Session Goals
- 

EOL

    # Add iteration tasks section if there are any
    if [ -n "$iteration_tasks" ]; then
        cat >> "$SESSION_FILE" << EOL
## Related Iteration Tasks
$iteration_tasks

EOL
    fi

    # Start progress tracking section
    cat >> "$SESSION_FILE" << EOL
## Progress Tracking
EOL

    # Add outstanding tasks from previous session if any
    if [ -n "$previous_tasks" ]; then
        cat >> "$SESSION_FILE" << EOL
### Outstanding Tasks from Previous Session
$previous_tasks

### New Tasks
- [ ] 
EOL
    else
        cat >> "$SESSION_FILE" << EOL
- [ ] 
EOL
    fi

    # Add remaining sections
    cat >> "$SESSION_FILE" << EOL

## Notes
- 

## Next Steps
EOL

    # Add next steps from previous session if any
    if [ -n "$previous_next_steps" ]; then
        cat >> "$SESSION_FILE" << EOL
$previous_next_steps
EOL
    else
        cat >> "$SESSION_FILE" << EOL
- 
EOL
    fi

    # Add final sections
    cat >> "$SESSION_FILE" << EOL

## Time Log
- Started: $TIME_FORMATTED
- Ended: [IN PROGRESS]

## Summary
[TO BE COMPLETED]
EOL
    
    # Create a link to the current session - use absolute paths to ensure it works correctly
    ln -sf "$(realpath "$SESSION_FILE")" "$CURRENT_SESSION_FILE"
    
    echo -e "${GREEN}Started new development session: $session_title${NC}"
    echo -e "${GREEN}Session log created at: $SESSION_FILE${NC}"
    echo -e "${CYAN}You can now edit this file to track your progress.${NC}"
    echo ""
    echo -e "Use the following commands to manage your session:"
    echo -e "  ${YELLOW}$0 add-task \"Task description\"${NC} - Add a new task"
    echo -e "  ${YELLOW}$0 complete-task <task_number>${NC} - Mark a task as completed"
    echo -e "  ${YELLOW}$0 add-note \"Note content\"${NC} - Add a note"
    echo -e "  ${YELLOW}$0 set-goal \"Goal description\"${NC} - Add a session goal"
    echo -e "  ${YELLOW}$0 add-next-step \"Step description\"${NC} - Add a next step"
    echo -e "  ${YELLOW}$0 end${NC} - End the current session"
    
    # Update session summary file
    update_summary
}

# Non-interactive version of end_session for use when auto-closing sessions
function end_session_noninteractive() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Check if file exists and is readable
    if [ ! -f "$SESSION_FILE" ] || [ ! -r "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Cannot access session file ($SESSION_FILE).${NC}"
        return 1
    fi
    
    # Update end time
    END_TIME=$(date +"%H:%M:%S")
    if ! sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$SESSION_FILE"; then
        echo -e "${RED}Error: Failed to update end time in session file.${NC}"
        return 1
    fi
    
    # Update summary with auto-generated message - using a more robust approach
    # Write to a temporary file for safe replacement
    TEMP_SUMMARY_FILE=$(mktemp)
    echo "Auto-closed during non-interactive operation" > "$TEMP_SUMMARY_FILE"
    TEMP_OUTPUT_FILE=$(mktemp)
    
    # Try to use Perl first (best handling of special characters)
    if command -v perl &>/dev/null; then
        # Replace the placeholder with the contents of the temp file using Perl
        if ! perl -0777 -i -pe 's/\[TO BE COMPLETED\]/`cat $TEMP_SUMMARY_FILE`/ee' "$SESSION_FILE"; then
            echo -e "${RED}Error: Failed to update summary in session file using Perl.${NC}"
            # Fall back to alternative method
            perl_failed=true
        else
            perl_failed=false
        fi
    else
        perl_failed=true
    fi
    
    # Fallback method if Perl isn't available or fails
    if [ "$perl_failed" = true ]; then
        # Use awk with null record separator as fallback
        if ! awk -v RS='\0' -v ORS='' '{gsub(/\[TO BE COMPLETED\]/, "'$(cat $TEMP_SUMMARY_FILE | sed 's/[\&/]/\\&/g')'"); print}' "$SESSION_FILE" > "$TEMP_OUTPUT_FILE"; then
            echo -e "${RED}Error: Failed to update summary in session file using awk.${NC}"
            # Final fallback - direct file replacement approach
            awk '{gsub(/\[TO BE COMPLETED\]/, "Auto-closed during non-interactive operation."); print}' "$SESSION_FILE" > "$TEMP_OUTPUT_FILE" \
                && mv "$TEMP_OUTPUT_FILE" "$SESSION_FILE" \
                || echo -e "${RED}Error: All methods failed to update summary.${NC}"
        else
            mv "$TEMP_OUTPUT_FILE" "$SESSION_FILE"
        fi
    fi
    
    # Clean up temporary files
    rm -f "$TEMP_SUMMARY_FILE" "$TEMP_OUTPUT_FILE" 2>/dev/null
    
    # Remove current session link
    rm -f "$CURRENT_SESSION_FILE"
    
    echo -e "${GREEN}Session ended and logged to: $SESSION_FILE${NC}"
    
    # Update session summary file
    update_summary
    
    return 0
}

# End the current development session
function end_session() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Check if file exists and is readable
    if [ ! -f "$SESSION_FILE" ] || [ ! -r "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Cannot access session file ($SESSION_FILE).${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Update end time
    END_TIME=$(date +"%H:%M:%S")
    if ! sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$SESSION_FILE"; then
        echo -e "${RED}Error: Failed to update end time in session file.${NC}"
        return 1
    fi
    
    # Check if a summary argument was provided for non-interactive use
    if [ -n "$1" ]; then
        session_summary="$1"
    else
        # Prompt for session summary
        echo -e "${BLUE}Please provide a summary of what was accomplished in this session:${NC}"
        read -p "> " session_summary
        
        if [ -z "$session_summary" ]; then
            echo -e "${YELLOW}Warning: Empty summary provided. Would you like to add one? (y/n)${NC}"
            read -p "> " choice
            if [ "$choice" = "y" ]; then
                echo -e "${BLUE}Please provide a summary:${NC}"
                read -p "> " session_summary
            else
                session_summary="Session ended without summary."
            fi
        fi
    fi
    
    # Update summary - using a more robust approach that handles all special characters
    # Write to a temporary file for safe replacement
    TEMP_SUMMARY_FILE=$(mktemp)
    echo "$session_summary" > "$TEMP_SUMMARY_FILE"
    TEMP_OUTPUT_FILE=$(mktemp)
    
    # Try to use Perl first (best handling of special characters)
    if command -v perl &>/dev/null; then
        # Replace the placeholder with the contents of the temp file using Perl
        if ! perl -0777 -i -pe 's/\[TO BE COMPLETED\]/`cat $TEMP_SUMMARY_FILE`/ee' "$SESSION_FILE"; then
            echo -e "${RED}Error: Failed to update summary in session file using Perl.${NC}"
            # Fall back to alternative method
            perl_failed=true
        else
            perl_failed=false
        fi
    else
        perl_failed=true
    fi
    
    # Fallback method if Perl isn't available or fails
    if [ "$perl_failed" = true ]; then
        # Use awk with null record separator as fallback
        if ! awk -v RS='\0' -v ORS='' '{gsub(/\[TO BE COMPLETED\]/, "'$(cat $TEMP_SUMMARY_FILE | sed 's/[\&/]/\\&/g')'"); print}' "$SESSION_FILE" > "$TEMP_OUTPUT_FILE"; then
            echo -e "${RED}Error: Failed to update summary in session file using awk.${NC}"
            # Final fallback - direct file replacement approach
            awk '{gsub(/\[TO BE COMPLETED\]/, "Session completed."); print}' "$SESSION_FILE" > "$TEMP_OUTPUT_FILE" \
                && mv "$TEMP_OUTPUT_FILE" "$SESSION_FILE" \
                || echo -e "${RED}Error: All methods failed to update summary.${NC}"
        else
            mv "$TEMP_OUTPUT_FILE" "$SESSION_FILE"
        fi
    fi
    
    # Clean up temporary files
    rm -f "$TEMP_SUMMARY_FILE" "$TEMP_OUTPUT_FILE" 2>/dev/null
    
    # Remove current session link
    rm -f "$CURRENT_SESSION_FILE"
    
    echo -e "${GREEN}Session ended and logged to: $SESSION_FILE${NC}"
    
    # Update session summary file
    update_summary
}

# Recover from a broken or incomplete session
function recover_session() {
    echo -e "${YELLOW}Session recovery tool${NC}"
    
    # Check for orphaned IN PROGRESS sessions
    echo -e "${BLUE}Searching for incomplete sessions...${NC}"
    INCOMPLETE_SESSIONS=$(grep -l "\[IN PROGRESS\]" $SESSION_LOG_DIR/session_*.md 2>/dev/null)
    INCOMPLETE_COUNT=$(echo "$INCOMPLETE_SESSIONS" | grep -c "^")
    
    if [ "$INCOMPLETE_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}No incomplete sessions found.${NC}"
        # If current_session.md exists but doesn't point to a valid file, remove it
        if [ -L "$CURRENT_SESSION_FILE" ] && [ ! -e "$(readlink -f "$CURRENT_SESSION_FILE")" ]; then
            echo -e "${YELLOW}Removing broken current session link.${NC}"
            rm -f "$CURRENT_SESSION_FILE"
            echo -e "${GREEN}Broken session link removed. You can now start a new session.${NC}"
            return 0
        fi
        return 1
    fi
    
    # Check if an argument was provided for non-interactive use (auto-fix)
    if [ "$1" = "auto" ]; then
        # Auto-fix all incomplete sessions
        echo -e "${BLUE}Auto-fixing all incomplete sessions...${NC}"
        END_TIME=$(date +"%H:%M:%S")
        for session in $INCOMPLETE_SESSIONS; do
            sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$session"
            sed -i "s/\[TO BE COMPLETED\]/Auto-closed during recovery/" "$session"
            echo -e "${GREEN}Fixed: $(basename "$session")${NC}"
        done
        # Fix the current session link if it's broken
        if [ -L "$CURRENT_SESSION_FILE" ]; then
            rm -f "$CURRENT_SESSION_FILE"
        fi
        echo -e "${GREEN}All incomplete sessions have been fixed.${NC}"
        update_summary
        return 0
    fi
    
    # Display list of incomplete sessions
    echo -e "${GREEN}Found $INCOMPLETE_COUNT incomplete sessions:${NC}"
    
    i=1
    for session in $INCOMPLETE_SESSIONS; do
        session_date=$(grep "Date:" "$session" | sed 's/\*\*Date:\*\* //')
        session_title=$(grep "# Development Session:" "$session" | sed 's/# Development Session: //')
        session_iteration=$(grep "Iteration:" "$session" | sed 's/\*\*Iteration:\*\* //')
        
        echo -e "  ${CYAN}$i${NC}. $session_date - $session_title (Iteration $session_iteration)"
        i=$((i + 1))
    done
    
    echo -e "  ${CYAN}a${NC}. Auto-fix all incomplete sessions"
    echo -e "  ${CYAN}c${NC}. Cancel"
    
    # Ask user which session to recover
    read -p "Select a session to recover (1-$INCOMPLETE_COUNT, a for all, c to cancel): " choice
    
    if [[ "$choice" == "c" ]]; then
        echo -e "${YELLOW}Recovery cancelled.${NC}"
        return 0
    elif [[ "$choice" == "a" ]]; then
        # Auto-fix all incomplete sessions
        echo -e "${BLUE}Auto-fixing all incomplete sessions...${NC}"
        END_TIME=$(date +"%H:%M:%S")
        for session in $INCOMPLETE_SESSIONS; do
            sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$session"
            sed -i "s/\[TO BE COMPLETED\]/Session auto-closed during recovery/" "$session"
            echo -e "${GREEN}Fixed: $(basename "$session")${NC}"
        done
        # Fix the current session link if it's broken
        if [ -L "$CURRENT_SESSION_FILE" ]; then
            rm -f "$CURRENT_SESSION_FILE"
        fi
        echo -e "${GREEN}All incomplete sessions have been fixed.${NC}"
        update_summary
        return 0
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$INCOMPLETE_COUNT" ]; then
        # Select the chosen session
        selected_session=$(echo "$INCOMPLETE_SESSIONS" | sed -n "${choice}p")
        
        echo -e "${BLUE}Selected: $(basename "$selected_session")${NC}"
        echo -e "Do you want to:"
        echo -e "  ${CYAN}1${NC} - Resume this session"
        echo -e "  ${CYAN}2${NC} - End this session"
        echo -e "  ${CYAN}3${NC} - View this session"
        read -p "Your choice: " action
        
        case $action in
            1)
                # Resume the selected session
                ln -sf "$selected_session" "$CURRENT_SESSION_FILE"
                echo -e "${GREEN}Resumed session: $(basename "$selected_session")${NC}"
                return 0
                ;;
            2)
                # End the selected session
                ln -sf "$selected_session" "$CURRENT_SESSION_FILE"
                end_session
                return $?
                ;;
            3)
                # View the selected session
                less "$selected_session"
                echo ""
                recover_session  # Call recovery again
                return $?
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                recover_session  # Call recovery again
                return $?
                ;;
        esac
    else
        echo -e "${RED}Invalid selection.${NC}"
        recover_session  # Call recovery again
        return 1
    fi
}

# Add a new task to the current session
function add_task() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No task description provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Validate that the file exists
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Check if the task should be added under a specific section
    if grep -q "### New Tasks" "$SESSION_FILE"; then
        # Add task to the new tasks section
        if ! sed -i "/### New Tasks/a - [ ] $1" "$SESSION_FILE"; then
            echo -e "${RED}Error: Failed to add task to session file.${NC}"
            return 1
        fi
    else
        # Add task to the progress tracking section
        if ! sed -i "/## Progress Tracking/a - [ ] $1" "$SESSION_FILE"; then
            echo -e "${RED}Error: Failed to add task to session file.${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}Task added to session log.${NC}"
}

# Mark a task as completed
function complete_task() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No task number provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Validate session file
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Extract tasks
    TASKS=$(grep -n "- \[ \]" "$SESSION_FILE" | sed 's/:.*//')
    
    # Check if any tasks exist
    if [ -z "$TASKS" ]; then
        echo -e "${YELLOW}No pending tasks found in the current session.${NC}"
        return 1
    fi
    
    # Check if the task number is valid
    TASK_COUNT=$(echo "$TASKS" | wc -l)
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt "$TASK_COUNT" ]; then
        echo -e "${RED}Invalid task number. Tasks range from 1 to $TASK_COUNT.${NC}"
        echo -e "${YELLOW}Available tasks:${NC}"
        i=1
        for task_line in $TASKS; do
            task_desc=$(sed -n "${task_line}p" "$SESSION_FILE" | sed 's/- \[ \] //')
            echo -e "  ${CYAN}$i${NC}. $task_desc"
            i=$((i + 1))
        done
        return 1
    fi
    
    # Get the line number of the task
    TASK_LINE=$(echo "$TASKS" | sed -n "${1}p")
    
    # Mark the task as completed
    if ! sed -i "${TASK_LINE}s/- \[ \]/- \[x\]/" "$SESSION_FILE"; then
        echo -e "${RED}Error: Failed to mark task as completed.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Task $1 marked as completed.${NC}"
    
    # Check if we should update the iteration progress file automatically
    if [ "$2" = "auto-update" ]; then
        # Get the task description
        TASK_DESCRIPTION=$(sed -n "${TASK_LINE}p" "$SESSION_FILE" | sed 's/- \[x\] //')
        echo -e "${BLUE}Automatically updating iteration progress for: '${TASK_DESCRIPTION}'${NC}"
        
        # Try to update the iteration progress file
        update_iteration_progress "$TASK_DESCRIPTION"
    else
        # Ask if user wants to update iteration progress file
        echo -e "${BLUE}Do you want to update the iteration progress file for this task? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            # Get the task description
            TASK_DESCRIPTION=$(sed -n "${TASK_LINE}p" "$SESSION_FILE" | sed 's/- \[x\] //')
            echo -e "${BLUE}Updating iteration progress for: '${TASK_DESCRIPTION}'${NC}"
            
            # Try to update the iteration progress file
            update_iteration_progress "$TASK_DESCRIPTION"
        fi
    fi
}

# Add a note to the current session
function add_note() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No note content provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Validate session file
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Add note to the notes section
    if ! sed -i "/## Notes/a - $1" "$SESSION_FILE"; then
        echo -e "${RED}Error: Failed to add note to session file.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Note added to session log.${NC}"
}

# Add a goal to the current session
function set_goal() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No goal description provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Validate session file
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Add goal to the goals section
    if ! sed -i "/## Session Goals/a - $1" "$SESSION_FILE"; then
        echo -e "${RED}Error: Failed to add goal to session file.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Goal added to session log.${NC}"
}

# Add a next step to the current session
function add_next_step() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}No active session found. Start a session first.${NC}"
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo -e "${RED}No next step content provided.${NC}"
        return 1
    fi
    
    # Get the actual session file path
    SESSION_FILE=$(readlink -f "$CURRENT_SESSION_FILE")
    
    # Validate session file
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Add next step to the next steps section
    if ! sed -i "/## Next Steps/a - $1" "$SESSION_FILE"; then
        echo -e "${RED}Error: Failed to add next step to session file.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Next step added to session log.${NC}"
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
    # Extract header from the summary file (up to and including "## Sessions")
    grep -B 100 -m 1 "^## Sessions" "$SESSION_SUMMARY_FILE" > "$SESSION_SUMMARY_FILE.tmp" || {
        # If the pattern is not found, start with a fresh file
        cat > "$SESSION_SUMMARY_FILE.tmp" << EOL
# A Silent Refraction - Development Session Summary

This file provides an overview of all development sessions for the project.

## Sessions
EOL
    }
    
    # Use an associative array to prevent duplicates
    declare -A processed_sessions
    
    # Add all sessions to the summary
    for session_file in $(find "$SESSION_LOG_DIR" -name "session_*.md" -type f | sort -r); do
        # Skip empty or invalid files
        if [ ! -s "$session_file" ]; then
            continue
        fi
        
        # Get base filename to use as a key for de-duplication
        base_name=$(basename "$session_file")
        
        # Skip if we've already processed this session
        if [ -n "${processed_sessions[$base_name]}" ]; then
            continue
        fi
        
        # Mark this session as processed
        processed_sessions[$base_name]=1
        
        # Extract session metadata with error handling
        session_date=$(grep "Date:" "$session_file" | sed 's/\*\*Date:\*\* //' || echo "Unknown date")
        session_title=$(grep "# Development Session:" "$session_file" | sed 's/# Development Session: //' || echo "Untitled session")
        session_iteration=$(grep "Iteration:" "$session_file" | sed 's/\*\*Iteration:\*\* //' || echo "Unknown")
        session_focus=$(grep "Task Focus:" "$session_file" | sed 's/\*\*Task Focus:\*\* //' || echo "Unknown focus")
        
        # Get session summary with error handling
        summary_line=$(grep -A 1 "^## Summary" "$session_file" | tail -n 1)
        if [ -z "$summary_line" ] || [ "$summary_line" = "[TO BE COMPLETED]" ]; then
            session_summary="No summary provided"
        else
            session_summary=$summary_line
        fi
        
        # Check if session is in progress
        if grep -q "\[IN PROGRESS\]" "$session_file"; then
            status="🟢 IN PROGRESS"
        else
            status="✅ COMPLETED"
        fi
        
        # Only add entries with valid titles
        if [ -n "$session_title" ] && [ "$session_title" != "Untitled session" ]; then
            echo "### $session_date - $session_title ($status)" >> "$SESSION_SUMMARY_FILE.tmp"
            echo "- **Iteration:** $session_iteration" >> "$SESSION_SUMMARY_FILE.tmp"
            echo "- **Focus:** $session_focus" >> "$SESSION_SUMMARY_FILE.tmp"
            echo "- **Summary:** $session_summary" >> "$SESSION_SUMMARY_FILE.tmp"
            echo "- [Session Log]($(basename "$session_file"))" >> "$SESSION_SUMMARY_FILE.tmp"
            echo "" >> "$SESSION_SUMMARY_FILE.tmp"
        fi
    done
    
    # Replace the summary file
    mv "$SESSION_SUMMARY_FILE.tmp" "$SESSION_SUMMARY_FILE"
    
    echo -e "${GREEN}Session summary updated.${NC}"
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
    sessions=$(grep -n "^### " "$SESSION_SUMMARY_FILE")
    
    if [ -z "$sessions" ]; then
        echo -e "${YELLOW}No sessions found in summary file.${NC}"
        
        # Check if there are any session files
        session_files=$(find "$SESSION_LOG_DIR" -name "session_*.md" -type f)
        if [ -n "$session_files" ]; then
            echo -e "${YELLOW}But session files exist. Would you like to rebuild the summary file? (y/n)${NC}"
            read -p "> " choice
            if [ "$choice" = "y" ]; then
                update_summary
                list_sessions
                return $?
            fi
        fi
        return 0
    fi
    
    # Display sessions in a clean format
    current_line=0
    while IFS= read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        session_header=$(echo "$line" | cut -d: -f2-)
        
        echo -e "$session_header"
        
        # Extract the next 4 lines (session details)
        for ((i=1; i<=4; i++)); do
            detail_line=$((line_num + i))
            detail=$(sed -n "${detail_line}p" "$SESSION_SUMMARY_FILE")
            echo "$detail"
        done
        echo ""
        
    done <<< "$sessions"
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
        # Try to find the session by date or any keyword
        session_files=$(find "$SESSION_LOG_DIR" -name "session_*$1*.md" -type f)
        session_count=$(echo "$session_files" | grep -c "^")
        
        if [ "$session_count" -eq 0 ]; then
            # Try searching in session content
            content_matches=$(grep -l "$1" "$SESSION_LOG_DIR"/session_*.md 2>/dev/null)
            content_count=$(echo "$content_matches" | grep -c "^")
            
            if [ "$content_count" -eq 0 ]; then
                echo -e "${RED}No session found matching '$1'.${NC}"
                return 1
            elif [ "$content_count" -eq 1 ]; then
                session_file="$content_matches"
                echo -e "${GREEN}Found session with content matching '$1'.${NC}"
            else
                echo -e "${YELLOW}Multiple sessions found with content matching '$1':${NC}"
                i=1
                for match in $content_matches; do
                    session_date=$(grep "Date:" "$match" | sed 's/\*\*Date:\*\* //')
                    session_title=$(grep "# Development Session:" "$match" | sed 's/# Development Session: //')
                    echo -e "  ${CYAN}$i${NC}. $session_date - $session_title"
                    i=$((i + 1))
                done
                
                read -p "Select a session to view (1-$content_count): " choice
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$content_count" ]; then
                    session_file=$(echo "$content_matches" | sed -n "${choice}p")
                else
                    echo -e "${RED}Invalid selection.${NC}"
                    return 1
                fi
            fi
        elif [ "$session_count" -eq 1 ]; then
            session_file="$session_files"
        else
            echo -e "${YELLOW}Multiple sessions found matching '$1':${NC}"
            i=1
            for match in $session_files; do
                session_date=$(grep "Date:" "$match" | sed 's/\*\*Date:\*\* //')
                session_title=$(grep "# Development Session:" "$match" | sed 's/# Development Session: //')
                echo -e "  ${CYAN}$i${NC}. $session_date - $session_title"
                i=$((i + 1))
            done
            
            read -p "Select a session to view (1-$session_count): " choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$session_count" ]; then
                session_file=$(echo "$session_files" | sed -n "${choice}p")
            else
                echo -e "${RED}Invalid selection.${NC}"
                return 1
            fi
        fi
    fi
    
    # Display the session
    if [ -f "$session_file" ]; then
        less "$session_file"
    else
        echo -e "${RED}Error: Session file not found.${NC}"
        return 1
    fi
}

# Link a task to specific code files
function link_task_to_files() {
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
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
    
    # Validate session file
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        echo -e "${YELLOW}Would you like to recover from this error? (y/n)${NC}"
        read -p "> " choice
        if [ "$choice" = "y" ]; then
            recover_session
            return $?
        else
            return 1
        fi
    fi
    
    # Extract tasks (both completed and pending)
    ALL_TASKS=$(grep -n "- \[[x ]\]" "$SESSION_FILE" | sed 's/:.*//')
    
    # Check if any tasks exist
    if [ -z "$ALL_TASKS" ]; then
        echo -e "${YELLOW}No tasks found in the current session.${NC}"
        return 1
    fi
    
    # Check if the task number is valid
    TASK_COUNT=$(echo "$ALL_TASKS" | wc -l)
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt "$TASK_COUNT" ]; then
        echo -e "${RED}Invalid task number. Tasks range from 1 to $TASK_COUNT.${NC}"
        echo -e "${YELLOW}Available tasks:${NC}"
        i=1
        for task_line in $ALL_TASKS; do
            task_desc=$(sed -n "${task_line}p" "$SESSION_FILE" | sed 's/- \[[x ]\] //')
            echo -e "  ${CYAN}$i${NC}. $task_desc"
            i=$((i + 1))
        done
        return 1
    fi
    
    # Get the line number of the task
    TASK_LINE=$(echo "$ALL_TASKS" | sed -n "${1}p")
    
    # Get the task description
    TASK_DESCRIPTION=$(sed -n "${TASK_LINE}p" "$SESSION_FILE")
    
    # Check if the file exists
    if [ ! -f "$2" ] && [ ! -d "$2" ]; then
        echo -e "${YELLOW}Warning: File/directory '$2' does not exist.${NC}"
        if [ "$3" = "force" ]; then
            echo -e "${YELLOW}Forcing link to non-existent file due to 'force' parameter.${NC}"
        else
            echo -e "${YELLOW}Do you want to continue anyway? (y/n)${NC}"
            read -p "> " choice
            if [ "$choice" != "y" ]; then
                return 1
            fi
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
    
    # Validate session file
    if [ ! -f "$SESSION_FILE" ]; then
        echo -e "${RED}Error: Session file not found. The current session link might be broken.${NC}"
        return 1
    fi
    
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
    PROGRESS_LINE=$(grep -n "| $TASK_DESCRIPTION " "$ITERATION_PROGRESS_FILE" | head -n 1 | sed 's/:.*//')
    
    if [ -z "$PROGRESS_LINE" ]; then
        # Try a more flexible search
        PROGRESS_LINE=$(grep -n "$TASK_DESCRIPTION" "$ITERATION_PROGRESS_FILE" | head -n 1 | sed 's/:.*//')
    fi
    
    if [ -z "$PROGRESS_LINE" ]; then
        echo -e "${YELLOW}Could not find task in iteration progress file.${NC}"
        echo -e "${YELLOW}Available tasks in progress file:${NC}"
        grep "| .* | Pending" "$ITERATION_PROGRESS_FILE"
        
        # Check if this is automated (non-interactive)
        if [ "$2" = "auto" ]; then
            echo -e "${YELLOW}Skipping manual task selection due to 'auto' parameter.${NC}"
            return 1
        fi
        
        # Ask user if they want to see a list of tasks
        echo -e "${YELLOW}Would you like to update a specific task instead? (y/n)${NC}"
        read -p "> " choice
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
        
        # Update the iteration progress
        update_iteration_summary
        return 0
    else
        echo -e "${RED}Failed to update iteration progress file.${NC}"
        return 1
    fi
}

# Update the iteration progress summary
function update_iteration_summary() {
    if [ ! -f "$ITERATION_PROGRESS_FILE" ]; then
        echo -e "${RED}Iteration progress file not found at $ITERATION_PROGRESS_FILE${NC}"
        return 1
    fi
    
    # Process each iteration
    iteration_sections=$(grep -n "^### Iteration" "$ITERATION_PROGRESS_FILE" | sed 's/:.*//')
    
    if [ -z "$iteration_sections" ]; then
        echo -e "${YELLOW}No iteration sections found in the progress file.${NC}"
        return 1
    fi
    
    # Create a temporary file for the updated content
    TEMP_FILE="${ITERATION_PROGRESS_FILE}.tmp"
    
    # Copy the content up to the overview section
    sed -n '1,/^## Overview/p' "$ITERATION_PROGRESS_FILE" > "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    # Extract overview table header
    grep -A 1 "^| Iteration | Name | Status | Progress |" "$ITERATION_PROGRESS_FILE" >> "$TEMP_FILE"
    
    # Process each iteration and update the overview
    prev_iter_end=0
    
    while IFS= read -r iter_start; do
        # Extract iteration number and name
        iter_line=$(sed -n "${iter_start}p" "$ITERATION_PROGRESS_FILE")
        iter_num=$(echo "$iter_line" | sed -E 's/^### Iteration ([0-9.]+):.*/\1/')
        iter_name=$(echo "$iter_line" | sed -E 's/^### Iteration [0-9.]+: (.*)/\1/')
        
        # Find the next iteration or end of file
        next_iter=$(grep -n "^### Iteration" "$ITERATION_PROGRESS_FILE" | awk -F: -v current="$iter_start" '$1 > current {print $1; exit}')
        if [ -z "$next_iter" ]; then
            next_iter=$(wc -l < "$ITERATION_PROGRESS_FILE")
        fi
        
        # Count completed and total tasks
        completed=$(sed -n "${iter_start},${next_iter}p" "$ITERATION_PROGRESS_FILE" | grep -c "| Complete |")
        total=$(sed -n "${iter_start},${next_iter}p" "$ITERATION_PROGRESS_FILE" | grep -c "| .* |" | awk '{print $1-1}')  # Subtract 1 for the header
        
        # Calculate percentage
        if [ "$total" -eq 0 ]; then
            percentage=0
        else
            percentage=$((completed * 100 / total))
        fi
        
        # Determine status
        if [ "$completed" -eq "$total" ] && [ "$total" -gt 0 ]; then
            status="COMPLETE"
        elif [ "$completed" -gt 0 ]; then
            status="IN PROGRESS"
        else
            status="Not started"
        fi
        
        # Add to overview table
        echo "| $iter_num | $iter_name | $status | $percentage% ($completed/$total) |" >> "$TEMP_FILE"
        
        prev_iter_end=$next_iter
    done <<< "$iteration_sections"
    
    # Copy the rest of the file from the detailed progress section
    detailed_start=$(grep -n "^## Detailed Progress" "$ITERATION_PROGRESS_FILE" | sed 's/:.*//')
    if [ -n "$detailed_start" ]; then
        echo "" >> "$TEMP_FILE"
        sed -n "${detailed_start},\$p" "$ITERATION_PROGRESS_FILE" >> "$TEMP_FILE"
    fi
    
    # Replace the original file
    mv "$TEMP_FILE" "$ITERATION_PROGRESS_FILE"
    
    echo -e "${GREEN}Updated iteration progress summary.${NC}"
}

# Clean up the session logs directory
function clean_sessions() {
    ensure_log_dir
    
    echo -e "${YELLOW}Session Cleanup Utility${NC}"
    echo -e "${BLUE}This utility will help clean up and fix issues in the session logs.${NC}"
    echo ""
    
    # Check for empty or malformed session files
    EMPTY_FILES=$(find "$SESSION_LOG_DIR" -name "session_*.md" -size 0 -type f)
    EMPTY_COUNT=$(echo "$EMPTY_FILES" | grep -c "^")
    
    # Check for incomplete sessions
    INCOMPLETE_SESSIONS=$(grep -l "\[IN PROGRESS\]" $SESSION_LOG_DIR/session_*.md 2>/dev/null)
    INCOMPLETE_COUNT=$(echo "$INCOMPLETE_SESSIONS" | grep -c "^")
    
    # Check for broken current session link
    BROKEN_LINK=0
    if [ -L "$CURRENT_SESSION_FILE" ] && [ ! -e "$(readlink -f "$CURRENT_SESSION_FILE")" ]; then
        BROKEN_LINK=1
    fi
    
    # Check for session_summary.md issues (duplicate sections)
    SUMMARY_ISSUES=0
    if [ -f "$SESSION_SUMMARY_FILE" ]; then
        duplicate_sections=$(grep -c "^## Sessions" "$SESSION_SUMMARY_FILE")
        if [ "$duplicate_sections" -gt 1 ]; then
            SUMMARY_ISSUES=1
        fi
        
        empty_titles=$(grep -c "###  -" "$SESSION_SUMMARY_FILE")
        if [ "$empty_titles" -gt 0 ]; then
            SUMMARY_ISSUES=1
        fi
    fi
    
    if [ "$EMPTY_COUNT" -eq 0 ] && [ "$INCOMPLETE_COUNT" -eq 0 ] && [ "$BROKEN_LINK" -eq 0 ] && [ "$SUMMARY_ISSUES" -eq 0 ]; then
        echo -e "${GREEN}No issues found. Session logs are clean.${NC}"
        return 0
    fi
    
    echo -e "${BLUE}Issues found:${NC}"
    [ "$EMPTY_COUNT" -gt 0 ] && echo -e "  - ${YELLOW}$EMPTY_COUNT empty session file(s)${NC}"
    [ "$INCOMPLETE_COUNT" -gt 0 ] && echo -e "  - ${YELLOW}$INCOMPLETE_COUNT incomplete session(s)${NC}"
    [ "$BROKEN_LINK" -eq 1 ] && echo -e "  - ${YELLOW}Broken current session link${NC}"
    [ "$SUMMARY_ISSUES" -eq 1 ] && echo -e "  - ${YELLOW}Issues with session summary file${NC}"
    
    # Check if non-interactive mode is requested
    if [ "$1" = "auto" ]; then
        echo -e "${BLUE}Running in auto mode. Fixing all issues...${NC}"
        
        # Fix everything automatically
        if [ "$EMPTY_COUNT" -gt 0 ]; then
            echo -e "${BLUE}Removing empty session files...${NC}"
            for file in $EMPTY_FILES; do
                rm -f "$file"
                echo -e "  ${GREEN}Deleted: $(basename "$file")${NC}"
            done
        fi
        
        if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
            echo -e "${BLUE}Fixing incomplete sessions...${NC}"
            END_TIME=$(date +"%H:%M:%S")
            for session in $INCOMPLETE_SESSIONS; do
                sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$session"
                sed -i "s/\[TO BE COMPLETED\]/Auto-closed during cleanup/" "$session"
                echo -e "  ${GREEN}Fixed: $(basename "$session")${NC}"
            done
        fi
        
        if [ "$BROKEN_LINK" -eq 1 ]; then
            echo -e "${BLUE}Removing broken current session link...${NC}"
            rm -f "$CURRENT_SESSION_FILE"
            echo -e "  ${GREEN}Removed broken session link${NC}"
        fi
        
        if [ "$SUMMARY_ISSUES" -eq 1 ]; then
            echo -e "${BLUE}Regenerating session summary file...${NC}"
            rm -f "$SESSION_SUMMARY_FILE"
            update_summary
            echo -e "  ${GREEN}Session summary regenerated${NC}"
        fi
        
        echo -e "${GREEN}Cleanup complete.${NC}"
        return 0
    fi
    
    # Interactive mode
    echo ""
    echo -e "Do you want to:"
    echo -e "  ${CYAN}1${NC} - Fix all issues automatically"
    echo -e "  ${CYAN}2${NC} - Fix issues selectively"
    echo -e "  ${CYAN}3${NC} - Exit without changes"
    read -p "Your choice: " choice
    
    case $choice in
        1)
            # Fix everything automatically
            if [ "$EMPTY_COUNT" -gt 0 ]; then
                echo -e "${BLUE}Removing empty session files...${NC}"
                for file in $EMPTY_FILES; do
                    rm -f "$file"
                    echo -e "  ${GREEN}Deleted: $(basename "$file")${NC}"
                done
            fi
            
            if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
                echo -e "${BLUE}Fixing incomplete sessions...${NC}"
                END_TIME=$(date +"%H:%M:%S")
                for session in $INCOMPLETE_SESSIONS; do
                    sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$session"
                    sed -i "s/\[TO BE COMPLETED\]/Auto-closed during cleanup/" "$session"
                    echo -e "  ${GREEN}Fixed: $(basename "$session")${NC}"
                done
            fi
            
            if [ "$BROKEN_LINK" -eq 1 ]; then
                echo -e "${BLUE}Removing broken current session link...${NC}"
                rm -f "$CURRENT_SESSION_FILE"
                echo -e "  ${GREEN}Removed broken session link${NC}"
            fi
            
            if [ "$SUMMARY_ISSUES" -eq 1 ]; then
                echo -e "${BLUE}Regenerating session summary file...${NC}"
                rm -f "$SESSION_SUMMARY_FILE"
                update_summary
                echo -e "  ${GREEN}Session summary regenerated${NC}"
            fi
            ;;
        2)
            # Fix issues selectively
            if [ "$EMPTY_COUNT" -gt 0 ]; then
                echo -e "${BLUE}Empty session files:${NC}"
                i=1
                for file in $EMPTY_FILES; do
                    echo -e "  ${CYAN}$i${NC}. $(basename "$file")"
                    i=$((i + 1))
                done
                read -p "Remove all empty files? (y/n): " choice
                if [ "$choice" = "y" ]; then
                    for file in $EMPTY_FILES; do
                        rm -f "$file"
                        echo -e "  ${GREEN}Deleted: $(basename "$file")${NC}"
                    done
                fi
            fi
            
            if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
                echo -e "${BLUE}Incomplete sessions:${NC}"
                i=1
                for session in $INCOMPLETE_SESSIONS; do
                    session_date=$(grep "Date:" "$session" 2>/dev/null | sed 's/\*\*Date:\*\* //' || echo "Unknown date")
                    session_title=$(grep "# Development Session:" "$session" 2>/dev/null | sed 's/# Development Session: //' || echo "Untitled session")
                    echo -e "  ${CYAN}$i${NC}. $session_date - $session_title"
                    i=$((i + 1))
                done
                read -p "Fix all incomplete sessions? (y/n): " choice
                if [ "$choice" = "y" ]; then
                    END_TIME=$(date +"%H:%M:%S")
                    for session in $INCOMPLETE_SESSIONS; do
                        sed -i "s/- Ended: \[IN PROGRESS\]/- Ended: $END_TIME/" "$session"
                        sed -i "s/\[TO BE COMPLETED\]/Auto-closed during cleanup/" "$session"
                        echo -e "  ${GREEN}Fixed: $(basename "$session")${NC}"
                    done
                fi
            fi
            
            if [ "$BROKEN_LINK" -eq 1 ]; then
                read -p "Remove broken current session link? (y/n): " choice
                if [ "$choice" = "y" ]; then
                    rm -f "$CURRENT_SESSION_FILE"
                    echo -e "  ${GREEN}Removed broken session link${NC}"
                fi
            fi
            
            if [ "$SUMMARY_ISSUES" -eq 1 ]; then
                read -p "Regenerate session summary file? (y/n): " choice
                if [ "$choice" = "y" ]; then
                    rm -f "$SESSION_SUMMARY_FILE"
                    update_summary
                    echo -e "  ${GREEN}Session summary regenerated${NC}"
                fi
            fi
            ;;
        3|*)
            echo -e "${YELLOW}No changes made.${NC}"
            ;;
    esac
    
    echo -e "${GREEN}Cleanup complete.${NC}"
}

# Claude-specific functions for AI integration

# Get the most recent session information for Claude to continue work
function claude_get_recent() {
    ensure_log_dir
    
    # Find the most recent session file
    if [ -f "$CURRENT_SESSION_FILE" ]; then
        # If there's a current session, return it
        cat "$CURRENT_SESSION_FILE"
    else
        # Otherwise find the most recent completed session
        local recent_session=$(find "$SESSION_LOG_DIR" -name "session_*.md" -type f | sort -r | head -n 1)
        
        if [ -n "$recent_session" ] && [ -f "$recent_session" ]; then
            # Return the session content
            cat "$recent_session"
        else
            echo "No recent sessions found."
        fi
    fi
}

# Start a new session specifically for Claude
function claude_start() {
    # Check if required arguments are provided
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo -e "${RED}Error: Missing required parameters for Claude session start.${NC}"
        echo -e "${YELLOW}Usage: $0 claude start \"Session Title\" \"Task Focus\" \"Iteration Number\"${NC}"
        return 1
    fi

    # Sanitize and validate iteration number
    local iteration_number="$(echo "$3" | tr -d "[:space:]")"
    if ! [[ "$iteration_number" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo -e "${RED}Error: Iteration number must be a number (e.g., 2 or 3.5).${NC}"
        echo -e "${YELLOW}You provided: \"$3\"${NC}"
        return 1
    fi

    # End any existing session first
    if [ -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${YELLOW}A session is already in progress. Ending it first...${NC}"
        end_session_noninteractive
    fi

    # Create backup
    backup_sessions

    # Start a new session with the provided arguments
    if ! start_session "$1" "$2" "$iteration_number"; then
        echo -e "${RED}Failed to start new session.${NC}"
        return 1
    fi

    # Verify the current session link was created
    if [ ! -e "$CURRENT_SESSION_FILE" ]; then
        echo -e "${RED}Current session link was not created properly.${NC}"
        return 1
    fi

    # Output created session for Claude to read
    cat "$CURRENT_SESSION_FILE"
    echo "Session started successfully."
    return 0
}
# End the current session with Claude's summary
function claude_end() {
    # Check if a summary is provided
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Missing required parameter for Claude session end.${NC}"
        echo -e "${YELLOW}Usage: $0 claude end \"Session Summary\"${NC}"
        return 1
    fi
    
    # End the current session with the provided summary
    end_session "$1"
    
    echo "Session ended successfully."
}

# Show help
function show_help() {
    echo -e "${BLUE}A Silent Refraction - Session Logger${NC}"
    echo ""
    echo -e "Usage: $0 [command] [arguments]"
    echo ""
    echo -e "Commands:"
    echo -e "  ${CYAN}start${NC}                       - Start a new development session"
    echo -e "  ${CYAN}start \"title\" \"focus\" \"iter#\"${NC} - Start session non-interactively with given parameters"
    echo -e "  ${CYAN}end${NC}                         - End the current session"
    echo -e "  ${CYAN}end \"summary\"${NC}               - End session non-interactively with given summary"
    echo -e "  ${CYAN}add-task \"description\"${NC}       - Add a task to the current session"
    echo -e "  ${CYAN}complete-task <number>${NC}        - Mark a task as completed"
    echo -e "  ${CYAN}add-note \"content\"${NC}           - Add a note to the current session"
    echo -e "  ${CYAN}set-goal \"description\"${NC}       - Add a goal to the current session"
    echo -e "  ${CYAN}add-next-step \"description\"${NC}  - Add a next step to the current session"
    echo -e "  ${CYAN}list${NC}                        - List all development sessions"
    echo -e "  ${CYAN}view [date]${NC}                 - View a specific session (or current if no date)"
    echo -e "  ${CYAN}link-task <number> <file>${NC}    - Link a task to specific code files"
    echo -e "  ${CYAN}update-progress \"keyword\"${NC}    - Update iteration progress file for a completed task"
    echo -e "  ${CYAN}recover${NC}                     - Recover from incomplete or broken sessions"
    echo -e "  ${CYAN}recover auto${NC}                - Recover all sessions automatically"
    echo -e "  ${CYAN}clean${NC}                       - Clean up session logs directory"
    echo -e "  ${CYAN}clean auto${NC}                  - Clean up session logs non-interactively"
    echo -e "  ${CYAN}backup${NC}                      - Backup all session logs"
    echo -e "  ${CYAN}update-summary${NC}              - Update the session summary file"
    echo -e "  ${CYAN}help${NC}                        - Show this help message"
    echo ""
    echo -e "  ${CYAN}claude-session${NC} \"title\" \"focus\" \"iter#\" - Start a new session for Claude with robust handling"
    echo -e "  ${CYAN}claude get-recent${NC}            - Get the most recent session info for Claude"
    echo -e "  ${CYAN}claude start${NC} \"title\" \"focus\" \"iter#\" - Start a new session for Claude"
    echo -e "  ${CYAN}claude end \"summary\"${NC}         - End the current session with Claude's summary"
    echo ""
    echo -e "Examples:"
    echo -e "  $0 start                     # Start a new session"
    echo -e "  $0 add-task \"Implement scrolling camera system\""
    echo -e "  $0 complete-task 1           # Mark the first task as completed"
    echo -e "  $0 add-note \"Found bug in camera implementation\""
    echo -e "  $0 link-task 1 \"src/core/camera/scrolling_camera.gd\"  # Link task to file"
    echo -e "  $0 update-progress \"camera\"   # Update iteration progress for completed camera task"
    echo -e "  $0 add-next-step \"Test camera with different background sizes\""
    echo -e "  $0 end                       # End the current session"
    echo -e "  $0 list                      # List all sessions"
    echo -e "  $0 view 2025-05-12           # View session from May 12, 2025"
    echo -e "  $0 recover                   # Fix orphaned or broken sessions"
    echo -e "  $0 clean                     # Clean up and fix session logs"
}


# Helper function to start a new session with Claude in a robust way
function claude_session_handler() {
    if [ -e "$CURRENT_SESSION_FILE" ]; then
        # If there is an active session, first clean it
        echo "Ending current session..."
        end_session_noninteractive
    fi

    # Clean up any broken sessions
    clean_sessions auto

    # Validate iteration number
    if [ -z "$3" ] || ! [[ "$(echo "$3" | tr -d "[:space:]" )" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Error: Invalid iteration number. Using default iteration 2."
        local iteration="2"
    else
        local iteration="$(echo "$3" | tr -d "[:space:]")"
    fi

    # Start a new session
    echo "Starting new session with title: $1, focus: $2, iteration: $iteration"
    if ! claude_start "$1" "$2" "$iteration"; then
        echo "Attempting fallback method..."
        # Create session file directly if claude_start fails
        SESSION_FILE="$SESSION_LOG_DIR/session_$(date +"%Y-%m-%d_%H-%M-%S").md"
        mkdir -p "$SESSION_LOG_DIR"
        # Create minimal session file
        cat > "$SESSION_FILE" << EOL
# Development Session: $1
**Date:** $(date +"%B %d, %Y")
**Time:** $(date +"%H:%M:%S")
**Iteration:** $iteration
**Task Focus:** $2

## Session Goals
- 

## Progress Tracking
- [ ] 

## Notes
- 

## Next Steps
- 

## Time Log
- Started: $(date +"%H:%M:%S")
- Ended: [IN PROGRESS]

## Summary
[TO BE COMPLETED]
EOL
        # Create symlink to current session - use absolute paths to ensure it works correctly
        ln -sf "$(realpath "$SESSION_FILE")" "$CURRENT_SESSION_FILE"
        echo "Created session via fallback method."
        cat "$SESSION_FILE"
    fi
}

# Main function
function main() {
    if [ $# -eq 0 ]; then
        show_help
        return 0
    fi
    
    case $1 in
        claude-session)
            claude_session_handler "$2" "$3" "$4"
            ;;
        start)
            if [ $# -ge 4 ]; then
                # Non-interactive mode with parameters
                start_session "$2" "$3" "$4"
            else
                # Interactive mode
                start_session
            fi
            ;;
        end)
            if [ $# -ge 2 ]; then
                # Non-interactive mode with summary
                end_session "$2"
            else
                # Interactive mode
                end_session
            fi
            ;;
        add-task)
            add_task "$2"
            ;;
        complete-task)
            if [ "$3" = "auto-update" ]; then
                # Non-interactive mode with auto-update
                complete_task "$2" "auto-update"
            else
                # Interactive mode
                complete_task "$2"
            fi
            ;;
        add-note)
            add_note "$2"
            ;;
        set-goal)
            set_goal "$2"
            ;;
        add-next-step)
            add_next_step "$2"
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
        update-progress)
            if [ "$3" = "auto" ]; then
                # Non-interactive mode
                update_iteration_progress "$2" "auto"
            else
                # Interactive mode
                update_iteration_progress "$2"
            fi
            ;;
        link-task)
            if [ "$4" = "force" ]; then
                # Non-interactive mode
                link_task_to_files "$2" "$3" "force"
            else
                # Interactive mode
                link_task_to_files "$2" "$3"
            fi
            ;;
        recover)
            if [ "$2" = "auto" ]; then
                # Non-interactive mode
                recover_session "auto"
            else
                # Interactive mode
                recover_session
            fi
            ;;
        clean)
            if [ "$2" = "auto" ]; then
                # Non-interactive mode
                clean_sessions "auto"
            else
                # Interactive mode
                clean_sessions
            fi
            ;;
        backup)
            backup_sessions
            ;;
        update-summary)
            # Add a public command to update the session summary file
            update_summary
            ;;
        claude)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: Missing Claude command.${NC}"
                echo -e "${YELLOW}Usage: $0 claude [get-recent|start|end] [arguments]${NC}"
                return 1
            fi
            
            case $2 in
                get-recent)
                    claude_get_recent
                    ;;
                start)
                    claude_start "$3" "$4" "$5"
                    ;;
                end)
                    claude_end "$3"
                    ;;
                *)
                    echo -e "${RED}Unknown Claude command: $2${NC}"
                    echo -e "${YELLOW}Available commands: get-recent, start, end${NC}"
                    return 1
                    ;;
            esac
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
