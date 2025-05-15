#!/bin/bash

# Backup existing session_logger.sh
echo "Creating backup of session_logger.sh..."
cp ./tools/session_logger.sh ./tools/session_logger.sh.backup
echo "Backup created at ./tools/session_logger.sh.backup"

# Path to session_logger.sh
SESSION_LOGGER="./tools/session_logger.sh"

# Fix 1: Improve the iteration number regex check
echo "Fixing iteration number validation..."
sed -i 's/if ! \[\[ "$iteration_number" =~ \^[0-9]+(\[.\][0-9]+)?\$ \]\]; then/if ! [[ "$(echo "$iteration_number" | tr -d "[:space:]")" =~ ^[0-9]+([.][0-9]+)?$ ]]; then/' "$SESSION_LOGGER"

# Fix 2: Improve the check for current_session.md to support symlinks
echo "Improving current session detection..."
# Modify file exists checks to include symlinks
sed -i 's/if \[ ! -f "$CURRENT_SESSION_FILE" \]; then/if [ ! -e "$CURRENT_SESSION_FILE" ]; then/' "$SESSION_LOGGER"

# Fix 3: Enhance claude_start function
echo "Enhancing Claude integration..."
# Find the claude_start function and replace it with an improved version
awk '
BEGIN { found=0; replaced=0; print_line=1 }
/^function claude_start\(\)/ { found=1; print_line=0 }
/^}/ { 
    if (found && !replaced) {
        replaced=1
        print "function claude_start() {"
        print "    # Check if required arguments are provided"
        print "    if [ -z \"$1\" ] || [ -z \"$2\" ] || [ -z \"$3\" ]; then"
        print "        echo -e \"${RED}Error: Missing required parameters for Claude session start.${NC}\""
        print "        echo -e \"${YELLOW}Usage: $0 claude start \\\"Session Title\\\" \\\"Task Focus\\\" \\\"Iteration Number\\\"${NC}\""
        print "        return 1"
        print "    fi"
        print ""
        print "    # Sanitize and validate iteration number"
        print "    local iteration_number=\"$(echo \"$3\" | tr -d \"[:space:]\")\""
        print "    if ! [[ \"$iteration_number\" =~ ^[0-9]+([.][0-9]+)?$ ]]; then"
        print "        echo -e \"${RED}Error: Iteration number must be a number (e.g., 2 or 3.5).${NC}\""
        print "        echo -e \"${YELLOW}You provided: \\\"$3\\\"${NC}\""
        print "        return 1"
        print "    fi"
        print ""
        print "    # End any existing session first"
        print "    if [ -e \"$CURRENT_SESSION_FILE\" ]; then"
        print "        echo -e \"${YELLOW}A session is already in progress. Ending it first...${NC}\""
        print "        end_session_noninteractive"
        print "    fi"
        print ""
        print "    # Create backup"
        print "    backup_sessions"
        print ""
        print "    # Start a new session with the provided arguments"
        print "    if ! start_session \"$1\" \"$2\" \"$iteration_number\"; then"
        print "        echo -e \"${RED}Failed to start new session.${NC}\""
        print "        return 1"
        print "    fi"
        print ""
        print "    # Verify the current session link was created"
        print "    if [ ! -e \"$CURRENT_SESSION_FILE\" ]; then"
        print "        echo -e \"${RED}Current session link was not created properly.${NC}\""
        print "        return 1"
        print "    fi"
        print ""
        print "    # Output created session for Claude to read"
        print "    cat \"$CURRENT_SESSION_FILE\""
        print "    echo \"Session started successfully.\""
        print "    return 0"
        print "}"
        print_line=1
    } else {
        print_line=1
    }
}
{ if (print_line) print }
' "$SESSION_LOGGER" > "$SESSION_LOGGER.tmp" && mv "$SESSION_LOGGER.tmp" "$SESSION_LOGGER"

# Fix 4: Adding Claude session helper function to simplify creating new sessions
echo "Adding Claude session helper function..."
# Add the function at the end of the file, before the main function
awk '
/^# Main function/ {
    print ""
    print "# Helper function to start a new session with Claude in a robust way"
    print "function claude_session_handler() {"
    print "    if [ -e \"$CURRENT_SESSION_FILE\" ]; then"
    print "        # If there is an active session, first clean it"
    print "        echo \"Ending current session...\""
    print "        end_session_noninteractive"
    print "    fi"
    print ""
    print "    # Clean up any broken sessions"
    print "    clean_sessions auto"
    print ""
    print "    # Validate iteration number"
    print "    if [ -z \"$3\" ] || ! [[ \"$(echo \"$3\" | tr -d \"[:space:]\" )\" =~ ^[0-9]+([.][0-9]+)?$ ]]; then"
    print "        echo \"Error: Invalid iteration number. Using default iteration 2.\""
    print "        local iteration=\"2\""
    print "    else"
    print "        local iteration=\"$(echo \"$3\" | tr -d \"[:space:]\")\""
    print "    fi"
    print ""
    print "    # Start a new session"
    print "    echo \"Starting new session with title: $1, focus: $2, iteration: $iteration\""
    print "    if ! claude_start \"$1\" \"$2\" \"$iteration\"; then"
    print "        echo \"Attempting fallback method...\""
    print "        # Create session file directly if claude_start fails"
    print "        SESSION_FILE=\"$SESSION_LOG_DIR/session_$(date +\"%Y-%m-%d_%H-%M-%S\").md\""
    print "        mkdir -p \"$SESSION_LOG_DIR\""
    print "        # Create minimal session file"
    print "        cat > \"$SESSION_FILE\" << EOL"
    print "# Development Session: $1"
    print "**Date:** $(date +\"%B %d, %Y\")"
    print "**Time:** $(date +\"%H:%M:%S\")"
    print "**Iteration:** $iteration"
    print "**Task Focus:** $2"
    print ""
    print "## Session Goals"
    print "- "
    print ""
    print "## Progress Tracking"
    print "- [ ] "
    print ""
    print "## Notes"
    print "- "
    print ""
    print "## Next Steps"
    print "- "
    print ""
    print "## Time Log"
    print "- Started: $(date +\"%H:%M:%S\")"
    print "- Ended: [IN PROGRESS]"
    print ""
    print "## Summary"
    print "[TO BE COMPLETED]"
    print "EOL"
    print "        # Create symlink to current session"
    print "        ln -sf \"$SESSION_FILE\" \"$CURRENT_SESSION_FILE\""
    print "        echo \"Created session via fallback method.\""
    print "        cat \"$SESSION_FILE\""
    print "    fi"
    print "}"
    print ""
}
{ print }
' "$SESSION_LOGGER" > "$SESSION_LOGGER.tmp" && mv "$SESSION_LOGGER.tmp" "$SESSION_LOGGER"

# Fix 5: Update main() to include the new handler function
echo "Updating main function..."
# Add a new case for the new claude-session command
awk '
/case \$1 in/ {
    print "    case $1 in"
    print "        claude-session)"
    print "            claude_session_handler \"$2\" \"$3\" \"$4\""
    print "            ;;"
    next
}
{ print }
' "$SESSION_LOGGER" > "$SESSION_LOGGER.tmp" && mv "$SESSION_LOGGER.tmp" "$SESSION_LOGGER"

# Fix 6: Add command to show_help function
echo "Updating help information..."
# Add information about the new command to the help output
awk '
/Claude Code Integration:/ {
    print "    ${CYAN}claude-session${NC} \"title\" \"focus\" \"iter#\" - Start a new session for Claude with robust handling"
    next
}
{ print }
' "$SESSION_LOGGER" > "$SESSION_LOGGER.tmp" && mv "$SESSION_LOGGER.tmp" "$SESSION_LOGGER"

# Make the session_logger.sh executable
chmod +x "$SESSION_LOGGER"

echo "Session logger script has been fixed!"
echo "You can now use: ./tools/session_logger.sh claude-session \"Session Title\" \"Task Focus\" \"2\""