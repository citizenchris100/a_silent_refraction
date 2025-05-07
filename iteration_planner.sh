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
    echo "  $0 list <iteration_number> - List all tasks for a specific iteration"
    echo
    echo "Examples:"
    echo "  $0 create 2 \"NPC Framework and Suspicion System\""
    echo "  $0 update 2 3 complete"
    echo "  $0 report"
    echo "  $0 link 2 3 \"src/core/suspicion_system.gd\""
    echo "  $0 init"
    echo "  $0 list 2"
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
# Iteration ${ITERATION_NUM}: Game Districts, Time Management, and Save System

## Goals
- Implement multiple station districts with transitions
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- Implement random NPC assimilation tied to time
- Implement single-slot save system
- Create basic limited inventory system

## Tasks
- [ ] Task 1: Create at least one additional district besides Shipping
- [ ] Task 2: Implement district transitions via tram system
- [ ] Task 3: Develop in-game clock and calendar system
- [ ] Task 4: Create time progression through player actions
- [ ] Task 5: Implement day cycle with sleep mechanics
- [ ] Task 6: Design and implement time UI indicators
- [ ] Task 7: Create system for random NPC assimilation over time
- [ ] Task 8: Add time-based events and triggers
- [ ] Task 9: Implement player bedroom as save point location
- [ ] Task 10: Create single-slot save system with confirmation UI
- [ ] Task 11: Create basic inventory system with size limitations

## Testing Criteria
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time
- Player can save game by returning to their room
- Player has limited inventory space

## Timeline
- Start date: $(date +%Y-%m-%d)
- Target completion: $(date -d "+21 days" +%Y-%m-%d)

## Dependencies
- Iteration 2 (NPC Framework and Suspicion System)

## Code Links
- No links yet

## Notes
This iteration expands the game world while implementing core mechanical systems like time management,
the save system, and basic inventory. These systems create the foundation for the strategic
gameplay where players must manage their time and inventory effectively.
EOL
            ;;
        4)
            cat > "$FILE_PATH" << EOL
# Iteration ${ITERATION_NUM}: Investigation Mechanics and Advanced Inventory

## Goals
- Implement investigation mechanics
- Create quest log system for tracking progress
- Develop advanced inventory system for collecting evidence
- Add system for logging known assimilated NPCs
- Implement overflow storage in player's room

## Tasks
- [ ] Task 1: Create quest data structure and manager
- [ ] Task 2: Implement quest log UI
- [ ] Task 3: Develop advanced inventory features including categorization
- [ ] Task 4: Create puzzles for accessing restricted areas
- [ ] Task 5: Implement clue discovery and collection system
- [ ] Task 6: Create assimilated NPC tracking log
- [ ] Task 7: Develop investigation progress tracking
- [ ] Task 8: Add quest state persistence
- [ ] Task 9: Implement overflow inventory storage in player's room
- [ ] Task 10: Create UI for transferring items between personal inventory and room storage

## Testing Criteria
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated
- Player can store extra items in their room
- Inventory management creates meaningful gameplay decisions

## Timeline
- Start date: $(date +%Y-%m-%d)
- Target completion: $(date -d "+21 days" +%Y-%m-%d)

## Dependencies
- Iteration 3 (Game Districts, Time Management, and Save System)

## Code Links
- No links yet

## Notes
This iteration implements the core investigation gameplay loop, allowing players 
to gather evidence, solve puzzles, and track their progress in discovering the 
conspiracy on the station. The expanded inventory system creates meaningful
strategic choices about what to carry and when to return to home base.
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
    
    # Create docs direct