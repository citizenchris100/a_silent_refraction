#!/bin/bash

# iteration_planner.sh - Advanced iteration planning script for A Silent Refraction
# This script helps create, update, and track iteration plans

# Text formatting
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"

# Function for displaying help
show_help() {
    echo -e "${BOLD}A Silent Refraction - Iteration Planning Tool${RESET}"
    echo
    echo "Usage:"
    echo "  $0 create <iteration_number> \"<iteration_name>\" - Create new iteration plan"
    echo "  $0 update <iteration_number> <task_number> <status> - Update task status (pending|in_progress|complete)"
    echo "  $0 report - Generate progress report for all iterations"
    echo "  $0 link <iteration_number> <task_number> \"<file_path>\" - Link task to source file"
    echo "  $0 init - Initialize docs directory and copy existing iteration progress"
    echo
    echo "Examples:"
    echo "  $0 create 2 \"NPC Framework and Suspicion System\""
    echo "  $0 update 2 3 complete"
    echo "  $0 report"
    echo "  $0 link 2 3 \"src/core/suspicion_system.gd\""
    echo "  $0 init"
    exit 1
}

# Function to initialize docs directory and import existing iteration data
initialize_docs() {
    echo -e "${BOLD}Initializing docs directory...${RESET}"
    
    # Create docs directory if it doesn't exist
    mkdir -p docs
    
    # Check if Iteration Progress file exists and import it
    if [ -f "Iteration Progress" ]; then
        echo -e "${YELLOW}Found existing Iteration Progress file.${RESET}"
        
        # Create iteration1_plan.md from the existing progress
        cat > "docs/iteration1_plan.md" << EOL
# Iteration 1: Basic Environment and Navigation

## Goals
- Complete the project setup
- Create a basic room with walkable areas
- Implement player character movement
- Test navigation in the shipping district

## Tasks
- [x] Task 1: Set up project structure with organized directories
- [x] Task 2: Create configuration in project.godot
- [x] Task 3: Implement shipping district scene with background
- [x] Task 4: Add walkable area with collision detection
- [x] Task 5: Create functional player character
- [x] Task 6: Implement point-and-click navigation
- [x] Task 7: Develop smooth movement system
- [x] Task 8: Test navigation within defined boundaries

## Testing Criteria
- Project structure is clean and organized
- Shipping district has proper background and walkable areas
- Player character responds to input
- Navigation works within defined boundaries

## Timeline
- Start date: $(date -d "-14 days" +%Y-%m-%d)
- Completion date: $(date +%Y-%m-%d)

## Dependencies
- None

## Code Links
- Task 3: src/districts/shipping/shipping_district.tscn
- Task 4: src/core/districts/walkable_area.gd
- Task 5: src/characters/player/player.gd
- Task 6: src/core/input/input_manager.gd

## Notes
Additional achievements beyond Iteration 1:
- Created a verb-based interaction system (SCUMM style)
- Implemented an interactive object framework
- Built a game manager to coordinate systems
- Added UI elements for displaying verbs and interaction text
EOL
        echo -e "${GREEN}Created docs/iteration1_plan.md from existing progress.${RESET}"
    else
        echo -e "${YELLOW}No existing Iteration Progress file found.${RESET}"
    fi
    
    echo -e "${GREEN}Docs directory initialized.${RESET}"
}

# Function to create iteration plan
create_iteration_plan() {
    ITERATION_NUM=$1
    ITERATION_NAME=$2
    
    if [ -z "$ITERATION_NUM" ] || [ -z "$ITERATION_NAME" ]; then
        echo -e "${RED}Error: Missing arguments${RESET}"
        show_help
    fi
    
    # Create docs directory if it doesn't exist
    mkdir -p docs
    
    FILE_PATH="docs/iteration${ITERATION_NUM}_plan.md"
    
    # Check if file already exists
    if [ -f "$FILE_PATH" ]; then
        echo -e "${RED}Error: $FILE_PATH already exists${RESET}"
        exit 1
    fi
    
    # Generate template based on iteration number
    case $ITERATION_NUM in
        2)
            cat > "$FILE_PATH" << EOL
# Iteration ${ITERATION_NUM}: ${ITERATION_NAME}

## Goals
- Implement basic NPCs with interactive capabilities
- Create the suspicion system as a core gameplay mechanic
- Apply visual style guide to one area as a prototype
- Develop placeholder art generation for NPCs

## Tasks
- [ ] Task 1: Create base NPC class with state machine
- [ ] Task 2: Implement NPC dialog system
- [ ] Task 3: Create suspicion meter UI element
- [ ] Task 4: Implement suspicion tracking system
- [ ] Task 5: Script NPC reactions based on suspicion levels
- [ ] Task 6: Apply visual style guide to Shipping District
- [ ] Task 7: Create bash script for generating NPC placeholders
- [ ] Task 8: Implement observation mechanics for detecting assimilated NPCs

## Testing Criteria
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly

## Timeline
- Start date: $(date +%Y-%m-%d)
- Target completion: $(date -d "+14 days" +%Y-%m-%d)

## Dependencies
- Iteration 1 (Basic Environment and Navigation)

## Code Links
- No links yet

## Notes
This iteration focuses on implementing the core NPC and suspicion systems, 
while also beginning to apply the visual style guide to establish the game's aesthetic.
EOL
            ;;
        3)
            cat > "$FILE_PATH" << EOL
# Iteration ${ITERATION_NUM}: ${ITERATION_NAME}

## Goals
- Implement multiple station districts with transitions
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- Implement random NPC assimilation tied to time

## Tasks
- [ ] Task 1: Create at least one additional district besides Shipping
- [ ] Task 2: Implement district transitions via tram system
- [ ] Task 3: Develop in-game clock and calendar system
- [ ] Task 4: Create time progression through player actions
- [ ] Task 5: Implement day cycle with sleep mechanics
- [ ] Task 6: Design and implement time UI indicators
- [ ] Task 7: Create system for random NPC assimilation over time
- [ ] Task 8: Add time-based events and triggers

## Testing Criteria
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time

## Timeline
- Start date: $(date +%Y-%m-%d)
- Target completion: $(date -d "+21 days" +%Y-%m-%d)

## Dependencies
- Iteration 2 (NPC Framework and Suspicion System)

## Code Links
- No links yet

## Notes
This iteration focuses on expanding the game world and implementing the time management system,
which is a crucial mechanic for the game's progression and tension.
EOL
            ;;
        4)
            cat > "$FILE_PATH" << EOL
# Iteration ${ITERATION_NUM}: ${ITERATION_NAME}

## Goals
- Implement investigation mechanics
- Create quest log system for tracking progress
- Develop item/inventory system for collecting evidence
- Add system for logging known assimilated NPCs

## Tasks
- [ ] Task 1: Create quest data structure and manager
- [ ] Task 2: Implement quest log UI
- [ ] Task 3: Develop inventory system for evidence items
- [ ] Task 4: Create puzzles for accessing restricted areas
- [ ] Task 5: Implement clue discovery and collection system
- [ ] Task 6: Create assimilated NPC tracking log
- [ ] Task 7: Develop investigation progress tracking
- [ ] Task 8: Add quest state persistence

## Testing Criteria
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated

## Timeline
- Start date: $(date +%Y-%m-%d)
- Target completion: $(date -d "+21 days" +%Y-%m-%d)

## Dependencies
- Iteration 3 (Game Districts and Time Management)

## Code Links
- No links yet

## Notes
This iteration implements the core investigation gameplay loop, allowing players 
to gather evidence, solve puzzles, and track their progress in discovering the 
conspiracy on the station.
EOL
            ;;
        *)
            cat > "$FILE_PATH" << EOL
# Iteration ${ITERATION_NUM}: ${ITERATION_NAME}

## Goals
- Goal 1
- Goal 2
- Goal 3

## Tasks
- [ ] Task 1: Description of task 1
- [ ] Task 2: Description of task 2
- [ ] Task 3: Description of task 3

## Testing Criteria
- Criterion 1
- Criterion 2
- Criterion 3

## Timeline
- Start date: $(date +%Y-%m-%d)
- Target completion: $(date -d "+14 days" +%Y-%m-%d)

## Dependencies
- List any dependencies here

## Code Links
- No links yet

## Notes
Add any additional notes or considerations here.
EOL
            ;;
    esac
    
    echo -e "${GREEN}Created iteration plan: $FILE_PATH${RESET}"
}

# Function to update task status
update_task_status() {
    ITERATION_NUM=$1
    TASK_NUM=$2
    STATUS=$3
    
    if [ -z "$ITERATION_NUM" ] || [ -z "$TASK_NUM" ] || [ -z "$STATUS" ]; then
        echo -e "${RED}Error: Missing arguments${RESET}"
        show_help
    fi
    
    # Create docs directory if it doesn't exist
    mkdir -p docs
    
    FILE_PATH="docs/iteration${ITERATION_NUM}_plan.md"
    
    # Check if file exists
    if [ ! -f "$FILE_PATH" ]; then
        echo -e "${RED}Error: $FILE_PATH does not exist${RESET}"
        exit 1
    fi
    
    # Status symbols
    case $STATUS in
        pending)
            STATUS_SYMBOL="[ ]"
            ;;
        in_progress)
            STATUS_SYMBOL="[~]"
            ;;
        complete)
            STATUS_SYMBOL="[x]"
            ;;
        *)
            echo -e "${RED}Error: Invalid status. Use pending, in_progress, or complete${RESET}"
            exit 1
            ;;
    esac
    
    # Update task - Windows compatible version
    if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "cygwin" ]; then
        # Using perl for Windows/MinGW
        perl -i -pe "s/- \[.\] Task $TASK_NUM:/- $STATUS_SYMBOL Task $TASK_NUM:/g" "$FILE_PATH"
    else
        # Using sed for Linux/Mac
        sed -i "s/- \[.\] Task $TASK_NUM:/- $STATUS_SYMBOL Task $TASK_NUM:/g" "$FILE_PATH"
    fi
    
    echo -e "${GREEN}Updated task $TASK_NUM in iteration $ITERATION_NUM to status: $STATUS${RESET}"
}

# Function to generate progress report
generate_report() {
    echo -e "${BOLD}A Silent Refraction - Iteration Progress Report${RESET}"
    echo "Generated on $(date +%Y-%m-%d)"
    echo
    
    # Create docs directory if it doesn't exist
    mkdir -p docs
    
    # Check if any iteration plans exist
    iteration_files=( docs/iteration*_plan.md )
    if [ ! -f "${iteration_files[0]}" ]; then
        echo -e "${YELLOW}No iteration plans found. Run '$0 init' to initialize from existing progress or create a new plan.${RESET}"
        return
    fi
    
    TOTAL_TASKS=0
    COMPLETED_TASKS=0
    
    # Find all iteration plans
    for PLAN in docs/iteration*_plan.md; do
        # Extract iteration info using simpler methods that work in MinGW
        ITER_NAME=$(head -30 "$PLAN" | grep "# Iteration" | head -1 | cut -d ":" -f 2- | sed 's/^ *//')
        ITER_NUM=$(head -30 "$PLAN" | grep "# Iteration" | head -1 | sed 's/# Iteration \([0-9]*\):.*/\1/')
        
        echo -e "${BOLD}Iteration $ITER_NUM: $ITER_NAME${RESET}"
        
        # Count tasks with simpler methods for MinGW
        ITER_TOTAL=$(grep "Task [0-9]*:" "$PLAN" | wc -l)
        ITER_COMPLETED=$(grep -c "\[x\] Task [0-9]*:" "$PLAN")
        ITER_IN_PROGRESS=$(grep -c "\[~\] Task [0-9]*:" "$PLAN")
        ITER_PENDING=$((ITER_TOTAL - ITER_COMPLETED - ITER_IN_PROGRESS))
        
        TOTAL_TASKS=$((TOTAL_TASKS + ITER_TOTAL))
        COMPLETED_TASKS=$((COMPLETED_TASKS + ITER_COMPLETED))
        
        # Calculate percentage
        if [ $ITER_TOTAL -gt 0 ]; then
            PERCENTAGE=$((ITER_COMPLETED * 100 / ITER_TOTAL))
        else
            PERCENTAGE=0
        fi
        
        echo "Progress: $ITER_COMPLETED/$ITER_TOTAL tasks complete ($PERCENTAGE%)"
        echo "Status: $ITER_COMPLETED complete, $ITER_IN_PROGRESS in progress, $ITER_PENDING pending"
        echo
    done
    
    # Overall progress
    if [ $TOTAL_TASKS -gt 0 ]; then
        OVERALL_PERCENTAGE=$((COMPLETED_TASKS * 100 / TOTAL_TASKS))
    else
        OVERALL_PERCENTAGE=0
    fi
    
    echo -e "${BOLD}Overall Project Progress: $COMPLETED_TASKS/$TOTAL_TASKS tasks complete ($OVERALL_PERCENTAGE%)${RESET}"
}

# Function to link task to code file
link_task_to_file() {
    ITERATION_NUM=$1
    TASK_NUM=$2
    FILE_PATH=$3
    
    if [ -z "$ITERATION_NUM" ] || [ -z "$TASK_NUM" ] || [ -z "$FILE_PATH" ]; then
        echo -e "${RED}Error: Missing arguments${RESET}"
        show_help
    fi
    
    # Create docs directory if it doesn't exist
    mkdir -p docs
    
    PLAN_PATH="docs/iteration${ITERATION_NUM}_plan.md"
    
    # Check if files exist
    if [ ! -f "$PLAN_PATH" ]; then
        echo -e "${RED}Error: $PLAN_PATH does not exist${RESET}"
        exit 1
    fi
    
    # Check if file exists or is planned to be created
    if [ ! -f "$FILE_PATH" ] && [ ! -d "$(dirname "$FILE_PATH")" ]; then
        echo -e "${YELLOW}Warning: Directory for $FILE_PATH does not exist. Creating it...${RESET}"
        mkdir -p "$(dirname "$FILE_PATH")"
    fi
    
    # Check if Code Links section exists
    if grep -q "## Code Links" "$PLAN_PATH"; then
        # Check if task is already linked
        TASK_PATTERN="- Task $TASK_NUM:"
        if grep -q "$TASK_PATTERN" "$PLAN_PATH"; then
            # Update existing link
            if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "cygwin" ]; then
                # Using perl for Windows/MinGW
                perl -i -pe "s|$TASK_PATTERN.*|$TASK_PATTERN $FILE_PATH|g" "$PLAN_PATH"
            else
                # Using sed for Linux/Mac
                sed -i "s|$TASK_PATTERN.*|$TASK_PATTERN $FILE_PATH|g" "$PLAN_PATH"
            fi
        else
            # Add new link - works in MinGW
            TEMP_FILE=$(mktemp)
            awk -v task="$TASK_NUM" -v file="$FILE_PATH" '
            {
                print $0
                if ($0 ~ /## Code Links/ && !added) {
                    print "- Task " task ": " file
                    added = 1
                }
            }' "$PLAN_PATH" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$PLAN_PATH"
        fi
    else
        echo -e "${RED}Error: Could not find Code Links section in $PLAN_PATH${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}Linked task $TASK_NUM in iteration $ITERATION_NUM to file: $FILE_PATH${RESET}"
}

# Main execution
case $1 in
    create)
        create_iteration_plan "$2" "$3"
        ;;
    update)
        update_task_status "$2" "$3" "$4"
        ;;
    report)
        generate_report
        ;;
    link)
        link_task_to_file "$2" "$3" "$4"
        ;;
    init)
        initialize_docs
        ;;
    *)
        show_help
        ;;
esac