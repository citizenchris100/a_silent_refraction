#!/bin/bash

# iteration_planner.sh - Iteration Planning System for A Silent Refraction
# Version 1.1

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Constants
DOCS_DIR="docs"
ITERATIONS_DIR="${DOCS_DIR}/iterations"
PROGRESS_FILE="${DOCS_DIR}/iteration_progress.md"

# Function to display help
function show_help {
    echo -e "${BLUE}A Silent Refraction - Iteration Planning System${NC}"
    echo ""
    echo "Usage: ./iteration_planner.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  init                              - Initialize the iteration planning system"
    echo "  create <iteration_number> <name>  - Create a new iteration plan"
    echo "  list <iteration_number>           - List tasks for a specific iteration"
    echo "  update <iter> <task> <status>     - Update task status (pending/in_progress/complete)"
    echo "  report                            - Generate progress report across all iterations"
    echo "  link <iter> <task> <file_path>    - Link a task to a code file"
    echo "  help                              - Show this help message"
    echo ""
}

# Function to initialize the system
function init_system {
    echo -e "${YELLOW}Initializing iteration planning system...${NC}"
    
    # Create docs directory if it doesn't exist
    mkdir -p "${ITERATIONS_DIR}"
    
    # Create progress tracking file
    echo "# A Silent Refraction - Iteration Progress" > "${PROGRESS_FILE}"
    echo "" >> "${PROGRESS_FILE}"
    echo "This file tracks the progress of all iterations for the project." >> "${PROGRESS_FILE}"
    echo "" >> "${PROGRESS_FILE}"
    echo "## Overview" >> "${PROGRESS_FILE}"
    echo "" >> "${PROGRESS_FILE}"
    echo "| Iteration | Name | Status | Progress |" >> "${PROGRESS_FILE}"
    echo "|-----------|------|--------|----------|" >> "${PROGRESS_FILE}"
    
    echo -e "${GREEN}Initialization complete.${NC}"
    echo "You can now create iteration plans with the 'create' command."
}

# Function to create a new iteration plan
function create_iteration {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Error: Missing parameters.${NC}"
        echo "Usage: ./iteration_planner.sh create <iteration_number> \"<iteration_name>\""
        exit 1
    fi
    
    iteration_number=$1
    iteration_name=$2
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} already exists.${NC}"
        echo "If you want to recreate it, delete the file first: ${iteration_file}"
        exit 1
    fi
    
    echo -e "${YELLOW}Creating iteration ${iteration_number}: ${iteration_name}${NC}"
    
    # Create the iteration file with template based on iteration number
    echo "# Iteration ${iteration_number}: ${iteration_name}" > "${iteration_file}"
    echo "" >> "${iteration_file}"
    echo "## Goals" >> "${iteration_file}"
    
    # Add goals based on iteration number
    case ${iteration_number} in
        1)
            echo "- Complete the project setup" >> "${iteration_file}"
            echo "- Create a basic room with walkable areas" >> "${iteration_file}"
            echo "- Implement player character movement" >> "${iteration_file}"
            echo "- Test navigation in the shipping district" >> "${iteration_file}"
            ;;
        2)
            echo "- Implement basic NPCs with interactive capabilities" >> "${iteration_file}"
            echo "- Create the suspicion system as a core gameplay mechanic" >> "${iteration_file}"
            echo "- Apply visual style guide to one area as a prototype" >> "${iteration_file}"
            echo "- Develop placeholder art generation for NPCs" >> "${iteration_file}"
            ;;
        3)
            echo "- Implement multiple station districts with transitions" >> "${iteration_file}"
            echo "- Create detailed time management system (Persona-style)" >> "${iteration_file}"
            echo "- Develop day/night cycle and time progression" >> "${iteration_file}"
            echo "- Implement random NPC assimilation tied to time" >> "${iteration_file}"
            echo "- Implement single-slot save system" >> "${iteration_file}"
            echo "- Create basic limited inventory system" >> "${iteration_file}"
            ;;
        4)
            echo "- Implement investigation mechanics" >> "${iteration_file}"
            echo "- Create quest log system for tracking progress" >> "${iteration_file}"
            echo "- Develop advanced inventory system for collecting evidence" >> "${iteration_file}"
            echo "- Add system for logging known assimilated NPCs" >> "${iteration_file}"
            echo "- Implement overflow storage in player's room" >> "${iteration_file}"
            ;;
        5)
            echo "- Implement recruiting NPCs to the coalition" >> "${iteration_file}"
            echo "- Add risk/reward mechanisms for revealing information" >> "${iteration_file}"
            echo "- Create coalition strength tracking" >> "${iteration_file}"
            ;;
        6)
            echo "- Implement game state progression" >> "${iteration_file}"
            echo "- Add multiple endings" >> "${iteration_file}"
            echo "- Create transition between narrative branches" >> "${iteration_file}"
            ;;
        *)
            echo "- Goal 1" >> "${iteration_file}"
            echo "- Goal 2" >> "${iteration_file}"
            echo "- Goal 3" >> "${iteration_file}"
            ;;
    esac
    
    echo "" >> "${iteration_file}"
    echo "## Tasks" >> "${iteration_file}"
    
    # Add tasks based on iteration number
    case ${iteration_number} in
        1)
            echo "- [ ] Task 1: Set up project structure with organized directories" >> "${iteration_file}"
            echo "- [ ] Task 2: Create configuration in project.godot" >> "${iteration_file}"
            echo "- [ ] Task 3: Implement shipping district scene with background" >> "${iteration_file}"
            echo "- [ ] Task 4: Add walkable area with collision detection" >> "${iteration_file}"
            echo "- [ ] Task 5: Create functional player character" >> "${iteration_file}"
            echo "- [ ] Task 6: Implement point-and-click navigation" >> "${iteration_file}"
            echo "- [ ] Task 7: Develop smooth movement system" >> "${iteration_file}"
            echo "- [ ] Task 8: Test navigation within defined boundaries" >> "${iteration_file}"
            ;;
        2)
            echo "- [ ] Task 1: Create base NPC class with state machine" >> "${iteration_file}"
            echo "- [ ] Task 2: Implement NPC dialog system" >> "${iteration_file}"
            echo "- [ ] Task 3: Create suspicion meter UI element" >> "${iteration_file}"
            echo "- [ ] Task 4: Implement suspicion tracking system" >> "${iteration_file}"
            echo "- [ ] Task 5: Script NPC reactions based on suspicion levels" >> "${iteration_file}"
            echo "- [ ] Task 6: Apply visual style guide to Shipping District" >> "${iteration_file}"
            echo "- [ ] Task 7: Create bash script for generating NPC placeholders" >> "${iteration_file}"
            echo "- [ ] Task 8: Implement observation mechanics for detecting assimilated NPCs" >> "${iteration_file}"
            ;;
        3)
            echo "- [ ] Task 1: Create at least one additional district besides Shipping" >> "${iteration_file}"
            echo "- [ ] Task 2: Implement district transitions via tram system" >> "${iteration_file}"
            echo "- [ ] Task 3: Develop in-game clock and calendar system" >> "${iteration_file}"
            echo "- [ ] Task 4: Create time progression through player actions" >> "${iteration_file}"
            echo "- [ ] Task 5: Implement day cycle with sleep mechanics" >> "${iteration_file}"
            echo "- [ ] Task 6: Design and implement time UI indicators" >> "${iteration_file}"
            echo "- [ ] Task 7: Create system for random NPC assimilation over time" >> "${iteration_file}"
            echo "- [ ] Task 8: Add time-based events and triggers" >> "${iteration_file}"
            echo "- [ ] Task 9: Implement player bedroom as save point location" >> "${iteration_file}"
            echo "- [ ] Task 10: Create single-slot save system with confirmation UI" >> "${iteration_file}"
            echo "- [ ] Task 11: Create basic inventory system with size limitations" >> "${iteration_file}"
            ;;
        4)
            echo "- [ ] Task 1: Create quest data structure and manager" >> "${iteration_file}"
            echo "- [ ] Task 2: Implement quest log UI" >> "${iteration_file}"
            echo "- [ ] Task 3: Develop advanced inventory features including categorization" >> "${iteration_file}"
            echo "- [ ] Task 4: Create puzzles for accessing restricted areas" >> "${iteration_file}"
            echo "- [ ] Task 5: Implement clue discovery and collection system" >> "${iteration_file}"
            echo "- [ ] Task 6: Create assimilated NPC tracking log" >> "${iteration_file}"
            echo "- [ ] Task 7: Develop investigation progress tracking" >> "${iteration_file}"
            echo "- [ ] Task 8: Add quest state persistence" >> "${iteration_file}"
            echo "- [ ] Task 9: Implement overflow inventory storage in player's room" >> "${iteration_file}"
            echo "- [ ] Task 10: Create UI for transferring items between personal inventory and room storage" >> "${iteration_file}"
            ;;
        5)
            echo "- [ ] Task 1: Implement NPC recruitment dialog options" >> "${iteration_file}"
            echo "- [ ] Task 2: Create coalition membership tracking system" >> "${iteration_file}"
            echo "- [ ] Task 3: Develop trust/mistrust mechanics" >> "${iteration_file}"
            echo "- [ ] Task 4: Implement coalition strength indicators" >> "${iteration_file}"
            echo "- [ ] Task 5: Add coalition member special abilities" >> "${iteration_file}"
            echo "- [ ] Task 6: Create consequences for failed recruitment attempts" >> "${iteration_file}"
            echo "- [ ] Task 7: Develop coalition headquarters location" >> "${iteration_file}"
            echo "- [ ] Task 8: Implement coalition mission assignment system" >> "${iteration_file}"
            ;;
        6)
            echo "- [ ] Task 1: Implement game state manager" >> "${iteration_file}"
            echo "- [ ] Task 2: Create win/lose conditions" >> "${iteration_file}"
            echo "- [ ] Task 3: Develop multiple ending scenarios" >> "${iteration_file}"
            echo "- [ ] Task 4: Add narrative branching system" >> "${iteration_file}"
            echo "- [ ] Task 5: Implement final confrontation sequence" >> "${iteration_file}"
            echo "- [ ] Task 6: Create ending cinematics" >> "${iteration_file}"
            echo "- [ ] Task 7: Add game over screens" >> "${iteration_file}"
            echo "- [ ] Task 8: Implement statistics tracking for playthrough" >> "${iteration_file}"
            ;;
        *)
            echo "- [ ] Task 1: Description of task 1" >> "${iteration_file}"
            echo "- [ ] Task 2: Description of task 2" >> "${iteration_file}"
            echo "- [ ] Task 3: Description of task 3" >> "${iteration_file}"
            ;;
    esac
    
    echo "" >> "${iteration_file}"
    echo "## Testing Criteria" >> "${iteration_file}"
    
    # Add testing criteria based on iteration number
    case ${iteration_number} in
        1)
            echo "- Player can move around the shipping district" >> "${iteration_file}"
            echo "- Movement is smooth and responsive" >> "${iteration_file}"
            echo "- Player stays within walkable areas" >> "${iteration_file}"
            echo "- Project structure follows the defined organization" >> "${iteration_file}"
            ;;
        2)
            echo "- NPCs can be interacted with using the verb system" >> "${iteration_file}"
            echo "- Suspicion level changes based on player actions" >> "${iteration_file}"
            echo "- Visual style matches the style guide specifications" >> "${iteration_file}"
            echo "- Observation mechanics work correctly" >> "${iteration_file}"
            ;;
        3)
            echo "- Player can travel between at least two districts" >> "${iteration_file}"
            echo "- Time advances through specific actions (tram travel, conversations, etc.)" >> "${iteration_file}"
            echo "- Day advances when player sleeps" >> "${iteration_file}"
            echo "- NPCs change status (assimilated/not) over time" >> "${iteration_file}"
            echo "- Player can save game by returning to their room" >> "${iteration_file}"
            echo "- Player has limited inventory space" >> "${iteration_file}"
            ;;
        4)
            echo "- Quest log accurately tracks active and completed quests" >> "${iteration_file}"
            echo "- Player can collect and use items/evidence" >> "${iteration_file}"
            echo "- Puzzles can be solved to progress investigation" >> "${iteration_file}"
            echo "- Player can track which NPCs are known to be assimilated" >> "${iteration_file}"
            echo "- Player can store extra items in their room" >> "${iteration_file}"
            echo "- Inventory management creates meaningful gameplay decisions" >> "${iteration_file}"
            ;;
        5)
            echo "- NPCs can be successfully recruited to the coalition" >> "${iteration_file}"
            echo "- Failed recruitment attempts have meaningful consequences" >> "${iteration_file}"
            echo "- Coalition strength affects game progression" >> "${iteration_file}"
            echo "- Coalition members provide tangible benefits" >> "${iteration_file}"
            ;;
        6)
            echo "- Game can be completed with multiple different outcomes" >> "${iteration_file}"
            echo "- Narrative branches based on player choices" >> "${iteration_file}"
            echo "- Game state properly tracks progress through the story" >> "${iteration_file}"
            echo "- Complete game flow can be tested from start to finish" >> "${iteration_file}"
            ;;
        *)
            echo "- Criterion 1" >> "${iteration_file}"
            echo "- Criterion 2" >> "${iteration_file}"
            echo "- Criterion 3" >> "${iteration_file}"
            ;;
    esac
    
    echo "" >> "${iteration_file}"
    echo "## Timeline" >> "${iteration_file}"
    echo "- Start date: $(date +%Y-%m-%d)" >> "${iteration_file}"
    echo "- Target completion: $(date -d "+14 days" +%Y-%m-%d)" >> "${iteration_file}"
    
    echo "" >> "${iteration_file}"
    echo "## Dependencies" >> "${iteration_file}"
    
    # Add dependencies based on iteration number
    case ${iteration_number} in
        1)
            echo "- None" >> "${iteration_file}"
            ;;
        2)
            echo "- Iteration 1 (Basic Environment and Navigation)" >> "${iteration_file}"
            ;;
        3)
            echo "- Iteration 1 (Basic Environment and Navigation)" >> "${iteration_file}"
            echo "- Iteration 2 (NPC Framework and Suspicion System)" >> "${iteration_file}"
            ;;
        4)
            echo "- Iteration 2 (NPC Framework and Suspicion System)" >> "${iteration_file}"
            echo "- Iteration 3 (Game Districts and Time Management)" >> "${iteration_file}"
            ;;
        5)
            echo "- Iteration 2 (NPC Framework and Suspicion System)" >> "${iteration_file}"
            echo "- Iteration 4 (Investigation Mechanics)" >> "${iteration_file}"
            ;;
        6)
            echo "- Iteration 4 (Investigation Mechanics)" >> "${iteration_file}"
            echo "- Iteration 5 (Coalition Building)" >> "${iteration_file}"
            ;;
        *)
            echo "- List any dependencies here" >> "${iteration_file}"
            ;;
    esac
    
    echo "" >> "${iteration_file}"
    echo "## Code Links" >> "${iteration_file}"
    echo "- No links yet" >> "${iteration_file}"
    
    echo "" >> "${iteration_file}"
    echo "## Notes" >> "${iteration_file}"
    echo "Add any additional notes or considerations here." >> "${iteration_file}"
    
    # Update progress file
    update_progress_file
    
    echo -e "${GREEN}Iteration ${iteration_number} created: ${iteration_file}${NC}"
}

# Function to list tasks for a specific iteration
function list_tasks {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Missing iteration number.${NC}"
        echo "Usage: ./iteration_planner.sh list <iteration_number>"
        exit 1
    fi
    
    iteration_number=$1
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./iteration_planner.sh create ${iteration_number} \"Iteration Name\""
        exit 1
    fi
    
    echo -e "${BLUE}Tasks for Iteration ${iteration_number}:${NC}"
    echo ""
    
    # Extract and display tasks
    grep -A 100 "^## Tasks" "${iteration_file}" | grep -B 100 "^## Testing" | grep "^\- \[" | grep -v "^## Testing" | nl -n ln
}

# Function to update task status
function update_task {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo -e "${RED}Error: Missing parameters.${NC}"
        echo "Usage: ./iteration_planner.sh update <iteration_number> <task_number> <status>"
        echo "Status can be: pending, in_progress, complete"
        exit 1
    fi
    
    iteration_number=$1
    task_number=$2
    status=$3
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./iteration_planner.sh create ${iteration_number} \"Iteration Name\""
        exit 1
    fi
    
    # Check if status is valid
    if [ "$status" != "pending" ] && [ "$status" != "in_progress" ] && [ "$status" != "complete" ]; then
        echo -e "${RED}Error: Invalid status.${NC}"
        echo "Status can be: pending, in_progress, complete"
        exit 1
    fi
    
    # Find the line number after "## Tasks" plus the task number
    tasks_line=$(grep -n "^## Tasks" "${iteration_file}" | cut -d: -f1)
    if [ -z "$tasks_line" ]; then
        echo -e "${RED}Error: Could not find Tasks section in iteration file.${NC}"
        exit 1
    fi
    
    # Calculate the line number for the specific task
    task_line=$((tasks_line + task_number))
    
    # Update the line based on status
    case "$status" in
        "pending")
            sed -i "${task_line}s/- \[[xX~]\]/- \[ \]/g" "${iteration_file}"
            ;;
        "in_progress")
            sed -i "${task_line}s/- \[[xX ]\]/- \[~\]/g" "${iteration_file}"
            ;;
        "complete")
            sed -i "${task_line}s/- \[[~ ]\]/- \[x\]/g" "${iteration_file}"
            ;;
    esac
    
    echo -e "${GREEN}Task ${task_number} updated to ${status}.${NC}"
    
    # Update progress file
    update_progress_file
}

# Function to link a task to a code file
function link_task_to_file {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo -e "${RED}Error: Missing parameters.${NC}"
        echo "Usage: ./iteration_planner.sh link <iteration_number> <task_number> \"<file_path>\""
        exit 1
    fi
    
    iteration_number=$1
    task_number=$2
    file_path=$3
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./iteration_planner.sh create ${iteration_number} \"Iteration Name\""
        exit 1
    fi
    
    # Update the Code Links section
    if grep -q "^- No links yet" "${iteration_file}"; then
        # Replace the "No links yet" line
        sed -i "/^- No links yet/c\- Task ${task_number}: [${file_path}](${file_path})" "${iteration_file}"
    elif grep -q "^- Task ${task_number}:" "${iteration_file}"; then
        # Update existing link for this task
        sed -i "/^- Task ${task_number}:/c\- Task ${task_number}: [${file_path}](${file_path})" "${iteration_file}"
    else
        # Add new link
        sed -i "/^## Code Links/a\- Task ${task_number}: [${file_path}](${file_path})" "${iteration_file}"
    fi
    
    echo -e "${GREEN}Linked Task ${task_number} to file: ${file_path}${NC}"
    
    # Update progress file
    update_progress_file
}

# Function to update the progress file
function update_progress_file {
    # If progress file doesn't exist, create it
    if [ ! -f "${PROGRESS_FILE}" ]; then
        echo "# A Silent Refraction - Iteration Progress" > "${PROGRESS_FILE}"
        echo "" >> "${PROGRESS_FILE}"
        echo "This file tracks the progress of all iterations for the project." >> "${PROGRESS_FILE}"
        echo "" >> "${PROGRESS_FILE}"
        echo "## Overview" >> "${PROGRESS_FILE}"
        echo "" >> "${PROGRESS_FILE}"
        echo "| Iteration | Name | Status | Progress |" >> "${PROGRESS_FILE}"
        echo "|-----------|------|--------|----------|" >> "${PROGRESS_FILE}"
    fi
    
    # Clear existing table content
    sed -i "/^|----/,$ d" "${PROGRESS_FILE}"
    echo "|-----------|------|--------|----------|" >> "${PROGRESS_FILE}"
    
    # Loop through all iteration files and add to progress
    for iter_file in "${ITERATIONS_DIR}"/iteration*_plan.md; do
        if [ -f "${iter_file}" ]; then
            # Extract iteration number and name
            iter_num=$(echo "${iter_file}" | sed -n 's/.*iteration\([0-9]*\)_plan.md/\1/p')
            iter_name=$(grep "^# Iteration" "${iter_file}" | sed -n 's/# Iteration [0-9]*: \(.*\)/\1/p')
            
            # Count total tasks and completed tasks
            total_tasks=$(grep -c "^\- \[" "${iter_file}")
            completed_tasks=$(grep -c "^\- \[x\]" "${iter_file}")
            in_progress_tasks=$(grep -c "^\- \[~\]" "${iter_file}")
            
            # Calculate progress percentage
            if [ ${total_tasks} -eq 0 ]; then
                progress="0%"
                status="Not started"
            else
                progress_pct=$((completed_tasks * 100 / total_tasks))
                progress="${progress_pct}%"
                
                # Determine status
                if [ ${completed_tasks} -eq ${total_tasks} ]; then
                    status="COMPLETE"
                elif [ ${completed_tasks} -eq 0 ] && [ ${in_progress_tasks} -eq 0 ]; then
                    status="Not started"
                else
                    status="IN PROGRESS"
                fi
            fi
            
            # Add row to progress table
            echo "| ${iter_num} | ${iter_name} | ${status} | ${progress} (${completed_tasks}/${total_tasks}) |" >> "${PROGRESS_FILE}"
        fi
    done
    
    # Add detailed section for each iteration
    echo "" >> "${PROGRESS_FILE}"
    echo "## Detailed Progress" >> "${PROGRESS_FILE}"
    echo "" >> "${PROGRESS_FILE}"
    
    for iter_file in "${ITERATIONS_DIR}"/iteration*_plan.md; do
        if [ -f "${iter_file}" ]; then
            # Extract iteration number and name
            iter_num=$(echo "${iter_file}" | sed -n 's/.*iteration\([0-9]*\)_plan.md/\1/p')
            iter_name=$(grep "^# Iteration" "${iter_file}" | sed -n 's/# Iteration [0-9]*: \(.*\)/\1/p')
            
            echo "### Iteration ${iter_num}: ${iter_name}" >> "${PROGRESS_FILE}"
            echo "" >> "${PROGRESS_FILE}"
            
            # Extract and add tasks with status
            echo "| Task | Status | Linked Files |" >> "${PROGRESS_FILE}"
            echo "|------|--------|--------------|" >> "${PROGRESS_FILE}"
            
            # Get tasks
            tasks=$(grep -A 100 "^## Tasks" "${iter_file}" | grep -B 100 "^## Testing" | grep "^\- \[" | grep -v "^## Testing")
            task_num=1
            
            # Process each task and add to the progress file
            echo "${tasks}" | while read -r task_line; do
                # Extract task description
                task_desc=$(echo "${task_line}" | sed -n 's/^\- \[[xX~]\] Task [0-9]*: \(.*\)/\1/p')
                if [ -z "${task_desc}" ]; then
                    task_desc=$(echo "${task_line}" | sed -n 's/^\- \[[xX~]\] \(.*\)/\1/p')
                    if [ -z "${task_desc}" ]; then
                        task_desc=$(echo "${task_line}" | sed -n 's/^\- \[ \] Task [0-9]*: \(.*\)/\1/p')
                        if [ -z "${task_desc}" ]; then
                            task_desc=$(echo "${task_line}" | sed -n 's/^\- \[ \] \(.*\)/\1/p')
                        fi
                    fi
                fi
                
                # Determine status
                if echo "${task_line}" | grep -q "^\- \[x\]"; then
                    task_status="Complete"
                elif echo "${task_line}" | grep -q "^\- \[~\]"; then
                    task_status="In Progress"
                else
                    task_status="Pending"
                fi
                
                # Check for linked files
                linked_file=$(grep "^- Task ${task_num}:" "${iter_file}" | sed -n 's/^- Task [0-9]*: \[\(.*\)\](.*/\1/p')
                if [ -z "${linked_file}" ]; then
                    linked_file="-"
                fi
                
                # Only add to the progress file if we have a task description
                if [ ! -z "${task_desc}" ]; then
                    echo "| ${task_desc} | ${task_status} | ${linked_file} |" >> "${PROGRESS_FILE}"
                    task_num=$((task_num + 1))
                fi
            done
            
            echo "" >> "${PROGRESS_FILE}"
        fi
    done
}

# Function to generate a progress report
function generate_report {
    echo -e "${YELLOW}Generating progress report...${NC}"
    
    # Update progress file
    update_progress_file
    
    # Display progress file content
    if [ -f "${PROGRESS_FILE}" ]; then
        # Count iterations and calculate overall progress
        total_iterations=$(find "${ITERATIONS_DIR}" -name "iteration*_plan.md" | wc -l)
        if [ ${total_iterations} -eq 0 ]; then
            echo -e "${RED}No iterations found.${NC}"
            exit 1
        fi
        
        total_tasks=0
        completed_tasks=0
        
        for iter_file in "${ITERATIONS_DIR}"/iteration*_plan.md; do
            if [ -f "${iter_file}" ]; then
                iter_tasks=$(grep -c "^\- \[" "${iter_file}")
                iter_completed=$(grep -c "^\- \[x\]" "${iter_file}")
                
                total_tasks=$((total_tasks + iter_tasks))
                completed_tasks=$((completed_tasks + iter_completed))
            fi
        done
        
        if [ ${total_tasks} -eq 0 ]; then
            overall_progress="0%"
        else
            overall_progress_pct=$((completed_tasks * 100 / total_tasks))
            overall_progress="${overall_progress_pct}%"
        fi
        
        echo -e "${BLUE}Project Progress Summary${NC}"
        echo "------------------------"
        echo "Total Iterations: ${total_iterations}"
        echo "Total Tasks: ${total_tasks}"
        echo "Completed Tasks: ${completed_tasks}"
        echo "Overall Progress: ${overall_progress}"
        echo ""
        
        echo -e "${BLUE}Iteration Status${NC}"
        echo "------------------------"
        
        # Display iteration status from progress file
        sed -n '/^| Iteration /,/^$/p' "${PROGRESS_FILE}" | grep -v "^$"
    else
        echo -e "${RED}Progress file not found. Run init first.${NC}"
        exit 1
    fi
}

# Main function to process commands
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    init)
        init_system
        ;;
    create)
        create_iteration "$2" "$3"
        ;;
    list)
        list_tasks "$2"
        ;;
    update)
        update_task "$2" "$3" "$4"
        ;;
    report)
        generate_report
        ;;
    link)
        link_task_to_file "$2" "$3" "$4"
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac

exit 0
