#!/bin/bash

# iteration_planner.sh - Iteration Planning System for A Silent Refraction
# Version 1.3

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
TEMPLATE_DIR="${DOCS_DIR}/iterations"

# Function to display help
function show_help {
    echo -e "${BLUE}A Silent Refraction - Iteration Planning System${NC}"
    echo ""
    echo "Usage: ./tools/iteration_planner.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  init                              - Initialize the iteration planning system"
    echo "  create <iteration_number> <n>     - Create a new iteration plan"
    echo "  list <iteration_number>           - List tasks for a specific iteration"
    echo "  update <iter> <task> <status>     - Update task status (pending/in_progress/complete)"
    echo "  report                            - Generate progress report across all iterations"
    echo "  link <iter> <task> <file_path>    - Link a task to a code file"
    echo "  add-req <iter> <type> <text>      - Add requirement to iteration (type: business/user/technical)"
    echo "  add-story <iter> <task> <story>   - Add user story to a task (format: 'As a X, I want Y, so that Z')"
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
        echo "Usage: ./tools/iteration_planner.sh create <iteration_number> \"<iteration_name>\""
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
            echo "- Implement improved point-and-click navigation system" >> "${iteration_file}"
            echo "- Create multi-perspective character system" >> "${iteration_file}"
            echo "- Enhance camera system with proper coordinate transformations" >> "${iteration_file}"
            echo "- Implement robust walkable area integration" >> "${iteration_file}"
            echo "- Develop comprehensive test cases for both systems" >> "${iteration_file}"
            ;;
        4)
            echo "- Implement modular serialization architecture" >> "${iteration_file}"
            echo "- Create self-registering serialization system for all game components" >> "${iteration_file}"
            echo "- Establish save/load testing framework" >> "${iteration_file}"
            echo "- Document serialization patterns for future systems" >> "${iteration_file}"
            echo "- Enable compressed save file format" >> "${iteration_file}"
            ;;
        5)
            echo "- Implement investigation mechanics" >> "${iteration_file}"
            echo "- Create quest log system for tracking progress" >> "${iteration_file}"
            echo "- Develop advanced inventory system for collecting evidence" >> "${iteration_file}"
            echo "- Add system for logging known assimilated NPCs" >> "${iteration_file}"
            echo "- Implement overflow storage in player's room" >> "${iteration_file}"
            ;;
        6)
            echo "- Implement recruiting NPCs to the coalition" >> "${iteration_file}"
            echo "- Add risk/reward mechanisms for revealing information" >> "${iteration_file}"
            echo "- Create coalition strength tracking" >> "${iteration_file}"
            ;;
        7)
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
    
    # Add Requirements Section (NEW)
    echo "" >> "${iteration_file}"
    echo "## Requirements" >> "${iteration_file}"
    echo "" >> "${iteration_file}"
    echo "### Business Requirements" >> "${iteration_file}"
    
    # Add business requirements based on iteration number
    case ${iteration_number} in
        1)
            echo "- **B1:** Establish foundational gameplay movement systems" >> "${iteration_file}"
            echo "  - **Rationale:** Basic navigation is essential for all game interactions" >> "${iteration_file}"
            echo "  - **Success Metric:** Player can navigate the environment fluidly within defined boundaries" >> "${iteration_file}"
            ;;
        2)
            echo "- **B1:** Establish core game mechanic of NPC suspicion to drive gameplay tension" >> "${iteration_file}"
            echo "  - **Rationale:** The suspicion mechanic is a central selling point and distinguishing feature of the game" >> "${iteration_file}"
            echo "  - **Success Metric:** Playtesters report feeling tension when suspicion rises, measured via satisfaction surveys" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Create reusable NPC framework to streamline future character development" >> "${iteration_file}"
            echo "  - **Rationale:** Efficient character creation will accelerate development of future game areas" >> "${iteration_file}"
            echo "  - **Success Metric:** New NPCs can be created and integrated within 2 hours or less" >> "${iteration_file}"
            ;;
        3)
            echo "- **B1:** Create a more responsive and predictable navigation system" >> "${iteration_file}"
            echo "  - **Rationale:** Intuitive, smooth navigation is essential for the point-and-click genre" >> "${iteration_file}"
            echo "  - **Success Metric:** Player movement feels natural with minimal user frustration" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Support multiple visual perspectives across different game districts" >> "${iteration_file}"
            echo "  - **Rationale:** Visual variety enhances player engagement and world-building" >> "${iteration_file}"
            echo "  - **Success Metric:** Seamless character movement and interaction across different perspective types" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B3:** Maintain consistent visual quality and gameplay mechanics across all perspectives" >> "${iteration_file}"
            echo "  - **Rationale:** Consistent quality ensures a cohesive player experience" >> "${iteration_file}"
            echo "  - **Success Metric:** Players report similar levels of satisfaction across all district perspectives" >> "${iteration_file}"
            ;;
        4)
            echo "- **B1:** Create a sense of progression and urgency through time management" >> "${iteration_file}"
            echo "  - **Rationale:** Time-based gameplay creates strategic choices and replay value" >> "${iteration_file}"
            echo "  - **Success Metric:** Players report making meaningful time allocation decisions in test sessions" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Expand game world with multiple distinct areas" >> "${iteration_file}"
            echo "  - **Rationale:** Diverse environments increase perceived game size and exploration value" >> "${iteration_file}"
            echo "  - **Success Metric:** Each district has unique visual identity and gameplay purpose" >> "${iteration_file}"
            ;;
        5)
            echo "- **B1:** Implement core investigation mechanics that drive main storyline" >> "${iteration_file}"
            echo "  - **Rationale:** Investigation is the primary gameplay loop for narrative progression" >> "${iteration_file}"
            echo "  - **Success Metric:** Players can advance the story through evidence collection and analysis" >> "${iteration_file}"
            ;;
        6)
            echo "- **B1:** Create meaningful NPC relationships through coalition building" >> "${iteration_file}"
            echo "  - **Rationale:** Social gameplay adds depth and strategic options" >> "${iteration_file}"
            echo "  - **Success Metric:** Player choices regarding recruitment affect game outcomes" >> "${iteration_file}"
            ;;
        7)
            echo "- **B1:** Deliver multiple game endings based on player choices" >> "${iteration_file}"
            echo "  - **Rationale:** Meaningful consequences increase replay value and player agency" >> "${iteration_file}"
            echo "  - **Success Metric:** Each ending is distinct and reflects player decisions throughout the game" >> "${iteration_file}"
            ;;
        8)
            echo "- **B1:** Complete Phase 1 MVP with explorable districts and living world" >> "${iteration_file}"
            echo "  - **Rationale:** Validates all core systems work together before expanding to full features" >> "${iteration_file}"
            echo "  - **Success Metric:** Intro Quest is fully playable from start to finish" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Establish district template system for efficient content creation" >> "${iteration_file}"
            echo "  - **Rationale:** Reusable templates accelerate development of remaining districts" >> "${iteration_file}"
            echo "  - **Success Metric:** New districts can be created in under 1 week using templates" >> "${iteration_file}"
            ;;
        9)
            echo "- **B1:** Implement core observation and investigation mechanics" >> "${iteration_file}"
            echo "  - **Rationale:** Central gameplay loop requires players to observe and investigate" >> "${iteration_file}"
            echo "  - **Success Metric:** Players can discover clues and track investigation progress" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Create tension through detection and access control systems" >> "${iteration_file}"
            echo "  - **Rationale:** Risk/reward mechanics enhance player engagement" >> "${iteration_file}"
            echo "  - **Success Metric:** Players report feeling tension when accessing restricted areas" >> "${iteration_file}"
            ;;
        10)
            echo "- **B1:** Develop deep NPC relationships and trust mechanics" >> "${iteration_file}"
            echo "  - **Rationale:** Social gameplay adds strategic depth and replayability" >> "${iteration_file}"
            echo "  - **Success Metric:** Player choices meaningfully affect NPC relationships" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Enable disguise mechanics for stealth gameplay" >> "${iteration_file}"
            echo "  - **Rationale:** Alternative playstyles increase player agency" >> "${iteration_file}"
            echo "  - **Success Metric:** Players can successfully infiltrate using disguises" >> "${iteration_file}"
            ;;
        11)
            echo "- **B1:** Implement comprehensive quest and job systems" >> "${iteration_file}"
            echo "  - **Rationale:** Structured progression keeps players engaged and provides clear goals" >> "${iteration_file}"
            echo "  - **Success Metric:** Players can track and complete multiple quest types" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Validate Phase 2 systems with First Quest implementation" >> "${iteration_file}"
            echo "  - **Rationale:** Integration testing ensures all systems work together" >> "${iteration_file}"
            echo "  - **Success Metric:** First Quest exercises all major game systems successfully" >> "${iteration_file}"
            ;;
        12)
            echo "- **B1:** Create dynamic station response to assimilation threat" >> "${iteration_file}"
            echo "  - **Rationale:** Living world that reacts to events increases immersion" >> "${iteration_file}"
            echo "  - **Success Metric:** Station security and NPCs adapt to assimilation spread" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Enable multiple story outcomes through coalition mechanics" >> "${iteration_file}"
            echo "  - **Rationale:** Player agency in story resolution increases satisfaction" >> "${iteration_file}"
            echo "  - **Success Metric:** At least 5 distinct endings based on player choices" >> "${iteration_file}"
            ;;
        13)
            echo "- **B1:** Bring the game world to life through comprehensive audio" >> "${iteration_file}"
            echo "  - **Rationale:** Audio enhances immersion and provides gameplay feedback" >> "${iteration_file}"
            echo "  - **Success Metric:** All actions and environments have appropriate audio" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Implement diegetic audio for enhanced realism" >> "${iteration_file}"
            echo "  - **Rationale:** In-world audio sources increase believability" >> "${iteration_file}"
            echo "  - **Success Metric:** Players can locate audio sources spatially" >> "${iteration_file}"
            ;;
        14)
            echo "- **B1:** Polish visual presentation to professional standards" >> "${iteration_file}"
            echo "  - **Rationale:** Visual quality directly impacts player perception and reviews" >> "${iteration_file}"
            echo "  - **Success Metric:** Consistent visual quality across all game areas" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Implement perspective and occlusion for depth" >> "${iteration_file}"
            echo "  - **Rationale:** Advanced visual features differentiate from competition" >> "${iteration_file}"
            echo "  - **Success Metric:** Characters scale and occlude naturally in all scenes" >> "${iteration_file}"
            ;;
        15)
            echo "- **B1:** Complete all advanced gameplay systems" >> "${iteration_file}"
            echo "  - **Rationale:** Full feature set required before content creation phase" >> "${iteration_file}"
            echo "  - **Success Metric:** All designed systems implemented and integrated" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Optimize performance for target hardware" >> "${iteration_file}"
            echo "  - **Rationale:** Smooth gameplay essential for player satisfaction" >> "${iteration_file}"
            echo "  - **Success Metric:** Maintains 60 FPS on minimum spec hardware" >> "${iteration_file}"
            ;;
        16)
            echo "- **B1:** Enable character adaptation to any visual perspective" >> "${iteration_file}"
            echo "  - **Rationale:** Flexible perspective system allows diverse district designs" >> "${iteration_file}"
            echo "  - **Success Metric:** Character displays correctly in all perspective types" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Enhance visual atmosphere with shader effects" >> "${iteration_file}"
            echo "  - **Rationale:** Advanced effects support the dystopian sci-fi aesthetic" >> "${iteration_file}"
            echo "  - **Success Metric:** Heat distortion, holograms, and CRT effects implemented" >> "${iteration_file}"
            ;;
        17)
            echo "- **B1:** Complete all game districts for full explorable world" >> "${iteration_file}"
            echo "  - **Rationale:** Complete game world required for full player experience" >> "${iteration_file}"
            echo "  - **Success Metric:** All 7 districts fully implemented and explorable" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **B2:** Implement Trading Floor minigame for economic gameplay" >> "${iteration_file}"
            echo "  - **Rationale:** Unique gameplay mechanics add variety and depth" >> "${iteration_file}"
            echo "  - **Success Metric:** Trading minigame provides meaningful economic choices" >> "${iteration_file}"
            ;;
        18)
            echo "- **B1:** Populate initial districts with diverse NPCs" >> "${iteration_file}"
            echo "  - **Rationale:** Living world requires sufficient NPC population" >> "${iteration_file}"
            echo "  - **Success Metric:** 55+ unique NPCs with distinct personalities" >> "${iteration_file}"
            ;;
        19)
            echo "- **B1:** Complete NPC population for all districts" >> "${iteration_file}"
            echo "  - **Rationale:** Full cast required for complete game experience" >> "${iteration_file}"
            echo "  - **Success Metric:** 150+ total NPCs across all districts" >> "${iteration_file}"
            ;;
        20)
            echo "- **B1:** Implement main story and job quests" >> "${iteration_file}"
            echo "  - **Rationale:** Core narrative drives player progression" >> "${iteration_file}"
            echo "  - **Success Metric:** 20+ hours of quest content implemented" >> "${iteration_file}"
            ;;
        21)
            echo "- **B1:** Add investigation and side quest content" >> "${iteration_file}"
            echo "  - **Rationale:** Optional content increases replay value" >> "${iteration_file}"
            echo "  - **Success Metric:** 10+ hours of optional content available" >> "${iteration_file}"
            ;;
        22)
            echo "- **B1:** Complete all dialog and narrative polish" >> "${iteration_file}"
            echo "  - **Rationale:** Polished writing essential for narrative game" >> "${iteration_file}"
            echo "  - **Success Metric:** All dialog professionally written and edited" >> "${iteration_file}"
            ;;
        23)
            echo "- **B1:** Prepare game for commercial release" >> "${iteration_file}"
            echo "  - **Rationale:** Professional polish required for market success" >> "${iteration_file}"
            echo "  - **Success Metric:** Game passes platform certification requirements" >> "${iteration_file}"
            ;;
        *)
            echo "- **B1:** Business requirement placeholder" >> "${iteration_file}"
            echo "  - **Rationale:** Explanation of why this is important" >> "${iteration_file}"
            echo "  - **Success Metric:** How we will measure success" >> "${iteration_file}"
            ;;
    esac
    
    echo "" >> "${iteration_file}"
    echo "### User Requirements" >> "${iteration_file}"
    
    # Add user requirements based on iteration number
    case ${iteration_number} in
        1)
            echo "- **U1:** As a player, I want intuitive point-and-click movement" >> "${iteration_file}"
            echo "  - **User Value:** Accessible gameplay without complex controls" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Player character moves to clicked locations with appropriate pathfinding" >> "${iteration_file}"
            ;;
        2)
            echo "- **U1:** As a player, I want to observe subtle cues that help identify assimilated NPCs" >> "${iteration_file}"
            echo "  - **User Value:** Creates engaging gameplay through detective-like observation" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Multiple visual cues exist that are subtle but detectable with close observation" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want to track my suspicion level with accessible UI" >> "${iteration_file}"
            echo "  - **User Value:** Provides immediate feedback on risky actions" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Suspicion meter visibly reacts to player actions in real-time" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U3:** As a player, I want NPCs to feel distinct through dialog and behavior" >> "${iteration_file}"
            echo "  - **User Value:** Creates an immersive world with memorable characters" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** NPCs have unique dialog patterns and state-based behavioral differences" >> "${iteration_file}"
            ;;
        3)
            echo "- **U1:** As a player, I want navigation to feel smooth and responsive" >> "${iteration_file}"
            echo "  - **User Value:** Reduces frustration and enhances immersion" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Character movement follows clicks with appropriate pathfinding and obstacle avoidance" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want my character to appear correctly in different game areas" >> "${iteration_file}"
            echo "  - **User Value:** Maintains visual immersion and aesthetic quality" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Character sprite adapts correctly to each perspective type (isometric, side-scrolling, top-down)" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U3:** As a player, I want consistent gameplay mechanics regardless of visual perspective" >> "${iteration_file}"
            echo "  - **User Value:** Reduces cognitive load when moving between areas" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Core interactions work identically across all perspective types" >> "${iteration_file}"
            ;;
        4)
            echo "- **U1:** As a player, I want to manage my time to prioritize activities" >> "${iteration_file}"
            echo "  - **User Value:** Creates strategic decision-making and consequences" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Different actions consume varying amounts of in-game time" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want to explore distinct areas of the station" >> "${iteration_file}"
            echo "  - **User Value:** Provides variety and discovery" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Each district has unique visuals, NPCs, and activities" >> "${iteration_file}"
            ;;
        5)
            echo "- **U1:** As a player, I want to collect and analyze evidence" >> "${iteration_file}"
            echo "  - **User Value:** Creates detective gameplay satisfaction" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Evidence can be found, stored, examined, and combined to progress" >> "${iteration_file}"
            ;;
        6)
            echo "- **U1:** As a player, I want to recruit NPCs to help against the assimilation" >> "${iteration_file}"
            echo "  - **User Value:** Creates social strategy gameplay" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** NPCs can be convinced through dialog choices and evidence presentation" >> "${iteration_file}"
            ;;
        7)
            echo "- **U1:** As a player, I want my choices to affect the game's outcome" >> "${iteration_file}"
            echo "  - **User Value:** Provides sense of agency and consequence" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Different ending sequences play based on key decisions and game state" >> "${iteration_file}"
            ;;
        8)
            echo "- **U1:** As a player, I want to explore multiple districts with unique content" >> "${iteration_file}"
            echo "  - **User Value:** Variety keeps gameplay fresh and interesting" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Each district has distinct visuals, NPCs, and activities" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want hover text to identify interactive objects" >> "${iteration_file}"
            echo "  - **User Value:** Clear interaction affordances reduce frustration" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** SCUMM-style hover text appears for all interactive elements" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U3:** As a player, I want to complete the Intro Quest" >> "${iteration_file}"
            echo "  - **User Value:** Clear initial goal provides direction" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Intro Quest playable from start to finish" >> "${iteration_file}"
            ;;
        9)
            echo "- **U1:** As a player, I want to observe and investigate my surroundings" >> "${iteration_file}"
            echo "  - **User Value:** Detective gameplay provides intellectual satisfaction" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Can discover clues through observation and track investigations" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want tension when accessing restricted areas" >> "${iteration_file}"
            echo "  - **User Value:** Risk/reward mechanics create excitement" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Detection system creates meaningful consequences" >> "${iteration_file}"
            ;;
        10)
            echo "- **U1:** As a player, I want to build relationships with NPCs" >> "${iteration_file}"
            echo "  - **User Value:** Social gameplay adds depth and personalization" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Trust levels affect dialog options and quest availability" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want to use disguises for infiltration" >> "${iteration_file}"
            echo "  - **User Value:** Alternative approaches enable creative problem solving" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Disguises grant access to restricted areas and fool NPCs" >> "${iteration_file}"
            ;;
        11)
            echo "- **U1:** As a player, I want to track my quests and objectives" >> "${iteration_file}"
            echo "  - **User Value:** Clear goals and progress tracking" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Quest log shows current objectives and completion status" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want meaningful job opportunities" >> "${iteration_file}"
            echo "  - **User Value:** Economic gameplay provides progression path" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Jobs provide income and advance the story" >> "${iteration_file}"
            ;;
        12)
            echo "- **U1:** As a player, I want the station to react to the assimilation threat" >> "${iteration_file}"
            echo "  - **User Value:** Dynamic world feels alive and responsive" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Security increases and NPCs change behavior as threat grows" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want to build a coalition to fight back" >> "${iteration_file}"
            echo "  - **User Value:** Leadership gameplay provides agency" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Can recruit allies and influence the ending" >> "${iteration_file}"
            ;;
        13)
            echo "- **U1:** As a player, I want immersive audio that enhances the atmosphere" >> "${iteration_file}"
            echo "  - **User Value:** Audio creates emotional connection and immersion" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** All actions and environments have appropriate sound" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want to locate sounds in the game world" >> "${iteration_file}"
            echo "  - **User Value:** Spatial audio aids navigation and investigation" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Can identify sound sources by direction and distance" >> "${iteration_file}"
            ;;
        14)
            echo "- **U1:** As a player, I want visually polished game environments" >> "${iteration_file}"
            echo "  - **User Value:** Professional presentation enhances immersion" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Consistent visual quality throughout the game" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want characters to scale naturally with perspective" >> "${iteration_file}"
            echo "  - **User Value:** Realistic depth perception improves visual clarity" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Characters and objects scale appropriately" >> "${iteration_file}"
            ;;
        15)
            echo "- **U1:** As a player, I want smooth performance on my hardware" >> "${iteration_file}"
            echo "  - **User Value:** Fluid gameplay essential for enjoyment" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Maintains 60 FPS on recommended specs" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want all game systems to work together seamlessly" >> "${iteration_file}"
            echo "  - **User Value:** Cohesive experience without technical issues" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** No conflicts between game systems" >> "${iteration_file}"
            ;;
        16)
            echo "- **U1:** As a player, I want my character to look correct in any perspective" >> "${iteration_file}"
            echo "  - **User Value:** Consistent character representation" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Character displays properly in all view types" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want atmospheric visual effects" >> "${iteration_file}"
            echo "  - **User Value:** Enhanced sci-fi atmosphere" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Shader effects enhance without distracting" >> "${iteration_file}"
            ;;
        17)
            echo "- **U1:** As a player, I want to explore all areas of the station" >> "${iteration_file}"
            echo "  - **User Value:** Complete game world to discover" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** All 7 districts are accessible and fully implemented" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **U2:** As a player, I want to engage in economic trading gameplay" >> "${iteration_file}"
            echo "  - **User Value:** Alternative gameplay provides variety" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Trading minigame is fun and rewarding" >> "${iteration_file}"
            ;;
        18)
            echo "- **U1:** As a player, I want to meet diverse and interesting NPCs" >> "${iteration_file}"
            echo "  - **User Value:** Rich cast of characters enhances story" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** 55+ unique NPCs with distinct personalities" >> "${iteration_file}"
            ;;
        19)
            echo "- **U1:** As a player, I want a fully populated living station" >> "${iteration_file}"
            echo "  - **User Value:** Believable world with sufficient population" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** 150+ NPCs make the station feel alive" >> "${iteration_file}"
            ;;
        20)
            echo "- **U1:** As a player, I want engaging main story content" >> "${iteration_file}"
            echo "  - **User Value:** Compelling narrative drives progression" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** 20+ hours of main quest content" >> "${iteration_file}"
            ;;
        21)
            echo "- **U1:** As a player, I want optional content to explore" >> "${iteration_file}"
            echo "  - **User Value:** Additional content for completionists" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** 10+ hours of side quests and investigations" >> "${iteration_file}"
            ;;
        22)
            echo "- **U1:** As a player, I want well-written dialog throughout" >> "${iteration_file}"
            echo "  - **User Value:** Quality writing enhances immersion" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** All dialog is polished and engaging" >> "${iteration_file}"
            ;;
        23)
            echo "- **U1:** As a player, I want a polished, bug-free experience" >> "${iteration_file}"
            echo "  - **User Value:** Professional quality product" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** Game is stable and ready for release" >> "${iteration_file}"
            ;;
        *)
            echo "- **U1:** As a player, I want to do something" >> "${iteration_file}"
            echo "  - **User Value:** How this benefits the player" >> "${iteration_file}"
            echo "  - **Acceptance Criteria:** How we'll know it works" >> "${iteration_file}"
            ;;
    esac
    
    echo "" >> "${iteration_file}"
    echo "### Technical Requirements (Optional)" >> "${iteration_file}"
    
    # Add technical requirements based on iteration number
    case ${iteration_number} in
        1)
            echo "- **T1:** Implement efficient collision detection for walkable areas" >> "${iteration_file}"
            echo "  - **Rationale:** Performance is critical for smooth gameplay" >> "${iteration_file}"
            echo "  - **Constraints:** Must work with irregularly-shaped walkable areas" >> "${iteration_file}"
            ;;
        2)
            echo "- **T1:** Create extensible NPC state machine system" >> "${iteration_file}"
            echo "  - **Rationale:** State-based behavior is core to the NPC system" >> "${iteration_file}"
            echo "  - **Constraints:** Must support at least 4 emotional states and assimilation status" >> "${iteration_file}"
            ;;
        3)
            echo "- **T1:** Maintain architectural principles while refactoring" >> "${iteration_file}"
            echo "  - **Rationale:** Code quality and maintainability must be preserved" >> "${iteration_file}"
            echo "  - **Constraints:** Changes must follow established patterns and coupling guidelines" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **T2:** Implement flexible, configuration-driven system for perspectives" >> "${iteration_file}"
            echo "  - **Rationale:** Facilitate easy addition of new perspectives and characters" >> "${iteration_file}"
            echo "  - **Constraints:** Performance must remain optimal with multiple perspectives" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **T3:** All camera system enhancements must preserve background scaling visual correctness and pass both unit tests and visual validation using camera-system test scene" >> "${iteration_file}"
            echo "  - **Rationale:** Phase 1 implementation broke background scaling by prioritizing architectural purity over visual correctness" >> "${iteration_file}"
            echo "  - **Constraints:** Visual display requirements take precedence over internal architectural elegance" >> "${iteration_file}"
            ;;
        4)
            echo "- **T1:** Implement modular serialization architecture" >> "${iteration_file}"
            echo "  - **Rationale:** Self-registering systems reduce coupling and maintenance burden" >> "${iteration_file}"
            echo "  - **Constraints:** Must support versioning for save compatibility" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **T2:** Use Godot's native serialization capabilities efficiently" >> "${iteration_file}"
            echo "  - **Rationale:** Leveraging engine features reduces complexity" >> "${iteration_file}"
            echo "  - **Constraints:** Must handle custom resources and node references" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "- **T3:** Implement save file compression" >> "${iteration_file}"
            echo "  - **Rationale:** Reduces storage requirements and improves load times" >> "${iteration_file}"
            echo "  - **Constraints:** Compression must not significantly impact save/load performance" >> "${iteration_file}"
            ;;
        *)
            echo "- **T1:** Technical requirement placeholder" >> "${iteration_file}"
            echo "  - **Rationale:** Why this is technically important" >> "${iteration_file}"
            echo "  - **Constraints:** Any limitations to be aware of" >> "${iteration_file}"
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
            ;;
        3)
            echo "### Point-and-Click Navigation Refactoring" >> "${iteration_file}"
            echo "- [ ] Task 1: Enhance scrolling camera system with improved coordinate conversions" >> "${iteration_file}"
            echo "- [ ] Task 2: Implement state signaling and synchronization for camera" >> "${iteration_file}"
            echo "- [ ] Task 3: Create test scene for validating camera system improvements" >> "${iteration_file}"
            echo "- [ ] Task 4: Enhance player controller for consistent physics behavior" >> "${iteration_file}"
            echo "- [ ] Task 5: Implement proper pathfinding with Navigation2D" >> "${iteration_file}"
            echo "- [ ] Task 6: Create test scene for player movement validation" >> "${iteration_file}"
            echo "- [ ] Task 7: Enhance walkable area system with improved polygon algorithms" >> "${iteration_file}"
            echo "- [ ] Task 8: Implement click detection and validation refinements" >> "${iteration_file}"
            echo "- [ ] Task 9: Create test scene for walkable area validation" >> "${iteration_file}"
            echo "- [ ] Task 10: Enhance system communication through signals" >> "${iteration_file}"
            echo "- [ ] Task 11: Implement comprehensive debug tools and visualizations" >> "${iteration_file}"
            echo "- [ ] Task 12: Create integration test for full navigation system" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Multi-Perspective Character System" >> "${iteration_file}"
            echo "- [ ] Task 13: Create directory structure and base files for the multi-perspective system" >> "${iteration_file}"
            echo "- [ ] Task 14: Define perspective types enum and configuration templates" >> "${iteration_file}"
            echo "- [ ] Task 15: Extend district base class to support perspective information" >> "${iteration_file}"
            echo "- [ ] Task 16: Implement character controller class with animation support" >> "${iteration_file}"
            echo "- [ ] Task 17: Create test character with basic animations" >> "${iteration_file}"
            echo "- [ ] Task 18: Test animation transitions within a perspective" >> "${iteration_file}"
            echo "- [ ] Task 19: Implement movement controller with direction support" >> "${iteration_file}"
            echo "- [ ] Task 20: Connect movement controller to point-and-click navigation" >> "${iteration_file}"
            echo "- [ ] Task 21: Test character movement in a single perspective" >> "${iteration_file}"
            echo "- [ ] Task 22: Create test districts with different perspective types" >> "${iteration_file}"
            echo "- [ ] Task 23: Implement perspective switching in character controller" >> "${iteration_file}"
            echo "- [ ] Task 24: Create test for transitions between different perspective districts" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Documentation and Review" >> "${iteration_file}"
            echo "- [ ] Task 25: Create comprehensive documentation for both systems" >> "${iteration_file}"
            echo "- [ ] Task 26: Perform code review and optimization" >> "${iteration_file}"
            echo "- [ ] Task 27: Update existing documentation to reflect new systems" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Sprite Perspective Scaling System" >> "${iteration_file}"
            echo "- [ ] Task 28: Create simple POC test sprites for perspective scaling validation" >> "${iteration_file}"
            echo "- [ ] Task 29: Implement basic sprite perspective scaling system" >> "${iteration_file}"
            echo "- [ ] Task 30: Create sprite scaling test scene for validation" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Audio System MVP Foundation" >> "${iteration_file}"
            echo "- [ ] Task 31: Create audio system directory structure and core architecture" >> "${iteration_file}"
            echo "- [ ] Task 32: Implement basic AudioManager singleton" >> "${iteration_file}"
            echo "- [ ] Task 33: Create simplified DiegeticAudioController component" >> "${iteration_file}"
            echo "- [ ] Task 34: Implement diegetic audio scaling system for perspective immersion" >> "${iteration_file}"
            echo "- [ ] Task 35: Integrate audio with perspective scaling system" >> "${iteration_file}"
            echo "- [ ] Task 36: Create audio foundation test scene and verify integration" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Foreground Occlusion MVP" >> "${iteration_file}"
            echo "- [ ] Task 37: Create ForegroundOcclusionManager singleton for Y-position based sprite layering" >> "${iteration_file}"
            echo "- [ ] Task 38: Implement basic foreground element loading in base_district.gd" >> "${iteration_file}"
            echo "- [ ] Task 39: Extend district JSON configuration for foreground elements" >> "${iteration_file}"
            echo "- [ ] Task 40: Create test foreground sprites for camera test backgrounds" >> "${iteration_file}"
            echo "- [ ] Task 41: Build foreground occlusion test scene with debug visualization" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Player Character Sprite Creation" >> "${iteration_file}"
            echo "- [ ] Task 42: Create male Alex character sprites following sprite workflow" >> "${iteration_file}"
            echo "- [ ] Task 43: Create female Alex character sprites following sprite workflow" >> "${iteration_file}"
            echo "- [ ] Task 44: Generate character portraits for gender selection screen" >> "${iteration_file}"
            echo "- [ ] Task 45: Validate both sprite sets work with multi-perspective system" >> "${iteration_file}"
            ;;
        4)
            echo "### Core Serialization System" >> "${iteration_file}"
            echo "- [ ] Task 1: Create SerializationManager singleton" >> "${iteration_file}"
            echo "- [ ] Task 2: Implement ISerializable interface" >> "${iteration_file}"
            echo "- [ ] Task 3: Create self-registration system for serializable components" >> "${iteration_file}"
            echo "- [ ] Task 4: Implement save data versioning system" >> "${iteration_file}"
            echo "- [ ] Task 5: Create compressed save file format" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### System Integration" >> "${iteration_file}"
            echo "- [ ] Task 6: Implement player state serialization" >> "${iteration_file}"
            echo "- [ ] Task 7: Implement NPC state serialization" >> "${iteration_file}"
            echo "- [ ] Task 8: Implement district state serialization" >> "${iteration_file}"
            echo "- [ ] Task 9: Implement game manager state serialization" >> "${iteration_file}"
            echo "- [ ] Task 10: Create serialization for time system (prep for I5)" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Testing Framework" >> "${iteration_file}"
            echo "- [ ] Task 11: Create unit tests for serialization system" >> "${iteration_file}"
            echo "- [ ] Task 12: Implement save/load integration tests" >> "${iteration_file}"
            echo "- [ ] Task 13: Create save file validation tools" >> "${iteration_file}"
            echo "- [ ] Task 14: Implement backwards compatibility tests" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Documentation" >> "${iteration_file}"
            echo "- [ ] Task 15: Document serialization architecture" >> "${iteration_file}"
            echo "- [ ] Task 16: Create serialization implementation guide" >> "${iteration_file}"
            echo "- [ ] Task 17: Document save file format specification" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Platform Support" >> "${iteration_file}"
            echo "- [ ] Task 18: Create platform abstraction layer for hardware detection" >> "${iteration_file}"
            echo "- [ ] Task 19: Implement build system for multi-platform support" >> "${iteration_file}"
            echo "- [ ] Task 20: Add platform-specific configuration system" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Inventory Serialization" >> "${iteration_file}"
            echo "- [ ] Task 21: Create InventorySerializer class" >> "${iteration_file}"
            echo "- [ ] Task 22: Implement personal inventory serialization" >> "${iteration_file}"
            echo "- [ ] Task 23: Implement barracks storage serialization" >> "${iteration_file}"
            echo "- [ ] Task 24: Add container state persistence" >> "${iteration_file}"
            echo "- [ ] Task 25: Implement loadout saving system" >> "${iteration_file}"
            echo "- [ ] Task 26: Create item instance serialization with conditions" >> "${iteration_file}"
            echo "- [ ] Task 27: Add inventory version migration support" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Multi-Perspective System" >> "${iteration_file}"
            echo "- [ ] Task 28: Create MultiPerspectiveSerializer for character perspective states" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Observation System Serialization" >> "${iteration_file}"
            echo "- [ ] Task 29: Create ObservationSerializer for observation history and discovered clues" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Performance Monitoring" >> "${iteration_file}"
            echo "- [ ] Task 30: Implement save/load performance metrics" >> "${iteration_file}"
            echo "- [ ] Task 31: Create performance target validation" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Verb System Serialization" >> "${iteration_file}"
            echo "- [ ] Task 32: Create VerbSerializer extending BaseSerializer" >> "${iteration_file}"
            echo "- [ ] Task 33: Implement VerbStateManager for state persistence" >> "${iteration_file}"
            echo "- [ ] Task 34: Add verb preference serialization (hotkeys, custom settings)" >> "${iteration_file}"
            echo "" >> "${iteration_file}"
            echo "### Suspicion System Serialization Extension" >> "${iteration_file}"
            echo "- [ ] Task 35: Create SuspicionSerializerFull implementation" >> "${iteration_file}"
            echo "- [ ] Task 36: Implement suspicion network compression" >> "${iteration_file}"
            echo "- [ ] Task 37: Add migration support from MVP to full suspicion system" >> "${iteration_file}"
            ;;
        5)
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
            echo "- [ ] Task 11: Implement observation mechanics for detecting assimilated NPCs" >> "${iteration_file}"
            ;;
        6)
            echo "- [ ] Task 1: Implement NPC recruitment dialog options" >> "${iteration_file}"
            echo "- [ ] Task 2: Create coalition membership tracking system" >> "${iteration_file}"
            echo "- [ ] Task 3: Develop trust/mistrust mechanics" >> "${iteration_file}"
            echo "- [ ] Task 4: Implement coalition strength indicators" >> "${iteration_file}"
            echo "- [ ] Task 5: Add coalition member special abilities" >> "${iteration_file}"
            echo "- [ ] Task 6: Create consequences for failed recruitment attempts" >> "${iteration_file}"
            echo "- [ ] Task 7: Develop coalition headquarters location" >> "${iteration_file}"
            echo "- [ ] Task 8: Implement coalition mission assignment system" >> "${iteration_file}"
            ;;
        7)
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
    
    # Get current date for timestamp
    current_date=$(date +"%m/%d/%y")
    # Default status
    status_md="**⏳ PENDING** (${current_date})"
    
    # Add task requirement templates (NEW)
    if [ "$iteration_number" = "2" ]; then
        echo "" >> "${iteration_file}"
        echo "### Task 3: Create suspicion meter UI element" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**User Story:** As a player, I want to see a visual indicator of my current suspicion level, so that I can make informed decisions about my actions and interactions with NPCs." >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Status History:**" >> "${iteration_file}"
        echo "- ${status_md}" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Requirements:**" >> "${iteration_file}"
        echo "- **Linked to:** B1, U2" >> "${iteration_file}"
        echo "- **Acceptance Criteria:**" >> "${iteration_file}"
        echo "  1. Suspicion meter is clearly visible in the game UI" >> "${iteration_file}"
        echo "  2. Meter visually changes as suspicion level increases/decreases" >> "${iteration_file}"
        echo "  3. Critical thresholds are visually distinct (safe, caution, danger)" >> "${iteration_file}"
        echo "  4. Meter updates in real-time when player performs suspicious actions" >> "${iteration_file}"
        echo "  5. Visual design matches the game's dystopian sci-fi aesthetic" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Implementation Notes:**" >> "${iteration_file}"
        echo "- Use ProgressBar node as the base for the meter implementation" >> "${iteration_file}"
        echo "- Consider shader effects for visual polish (glowing, pulsing at high suspicion)" >> "${iteration_file}"
        echo "- Integrate with the global_suspicion_manager.gd for data binding" >> "${iteration_file}"
    fi
    
    # Add example user stories for key iteration 3 tasks
    if [ "$iteration_number" = "3" ]; then
        echo "" >> "${iteration_file}"
        echo "### Task 1: Enhance scrolling camera system with improved coordinate conversions" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**User Story:** As a player, I want the game camera to track my character smoothly and accurately, so that I can focus on gameplay rather than managing my view of the action." >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Status History:**" >> "${iteration_file}"
        echo "- ${status_md}" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Requirements:**" >> "${iteration_file}"
        echo "- **Linked to:** B1, U1, T1" >> "${iteration_file}"
        echo "- **Acceptance Criteria:**" >> "${iteration_file}"
        echo "  1. Camera follows player character smoothly without jerky movements" >> "${iteration_file}"
        echo "  2. Screen-to-world and world-to-screen coordinate conversions work accurately at all zoom levels" >> "${iteration_file}"
        echo "  3. Camera maintains proper boundaries based on the current district" >> "${iteration_file}"
        echo "  4. Edge case handling prevents camera from showing areas outside the playable space" >> "${iteration_file}"
        echo "  5. Camera movement uses appropriate easing for natural feel" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Implementation Notes:**" >> "${iteration_file}"
        echo "- Refine coordinate handling in scrolling_camera.gd" >> "${iteration_file}"
        echo "- Add validation methods to ensure coordinates are always valid" >> "${iteration_file}"
        echo "- Update camera targeting to prevent edge cases" >> "${iteration_file}"
        echo "- Maintain alignment with signal-based architectural pattern" >> "${iteration_file}"
    fi
    
    # Add example user stories for key iteration 4 tasks
    if [ "$iteration_number" = "4" ]; then
        echo "" >> "${iteration_file}"
        echo "### Task 1: Create SerializationManager singleton" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**User Story:** As a developer, I want a central serialization manager, so that all game systems can save and load their state through a unified interface." >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Design Reference:** \`docs/design/modular_serialization_architecture.md\`" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Status History:**" >> "${iteration_file}"
        echo "- ${status_md}" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Requirements:**" >> "${iteration_file}"
        echo "- **Linked to:** B1, T1" >> "${iteration_file}"
        echo "- **Acceptance Criteria:**" >> "${iteration_file}"
        echo "  1. SerializationManager exists as autoload singleton" >> "${iteration_file}"
        echo "  2. Provides register(), save(), and load() methods" >> "${iteration_file}"
        echo "  3. Handles file I/O operations safely" >> "${iteration_file}"
        echo "  4. Includes error handling and validation" >> "${iteration_file}"
        echo "  5. Supports multiple save slots (future expansion)" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Implementation Notes:**" >> "${iteration_file}"
        echo "- Use Godot's autoload system for singleton" >> "${iteration_file}"
        echo "- Implement using GDScript for consistency" >> "${iteration_file}"
        echo "- Store saves in user://saves/ directory" >> "${iteration_file}"
        echo "- Use .save extension for save files" >> "${iteration_file}"
    fi
    
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
            echo "- Camera system properly handles coordinate conversions" >> "${iteration_file}"
            echo "- Player movement is smooth with proper acceleration/deceleration" >> "${iteration_file}"
            echo "- Pathfinding correctly navigates around obstacles" >> "${iteration_file}"
            echo "- Walkable areas are properly respected with accurate boundaries" >> "${iteration_file}"
            echo "- Characters display correctly in each perspective" >> "${iteration_file}"
            echo "- Animation transitions are smooth in all perspectives" >> "${iteration_file}"
            echo "- Character movement adapts correctly to each perspective type" >> "${iteration_file}"
            echo "- Performance remains optimal across all test cases" >> "${iteration_file}"
            echo "- All debug tools work properly" >> "${iteration_file}"
            echo "- Sprites scale appropriately based on Y-position" >> "${iteration_file}"
            echo "- Audio sources scale volume based on distance and perspective" >> "${iteration_file}"
            echo "- Stereo panning creates spatial audio effect" >> "${iteration_file}"
            echo "- Diegetic audio enhances environmental immersion" >> "${iteration_file}"
            echo "- AudioManager singleton properly tracks player position" >> "${iteration_file}"
            echo "- DiegeticAudioController components update efficiently" >> "${iteration_file}"
            echo "- Audio integrates seamlessly with perspective scaling" >> "${iteration_file}"
            echo "- Test scene validates all audio MVP functionality" >> "${iteration_file}"
            echo "- Foreground elements correctly occlude player based on Y-position" >> "${iteration_file}"
            echo "- Foreground system integrates cleanly with existing coordinate system" >> "${iteration_file}"
            echo "- No performance impact from foreground occlusion updates" >> "${iteration_file}"
            echo "- Debug visualization clearly shows occlusion thresholds" >> "${iteration_file}"
            echo "- Both male and female Alex sprites are created following the sprite workflow" >> "${iteration_file}"
            echo "- Character portraits display correctly on gender selection screen" >> "${iteration_file}"
            echo "- Both sprite sets work identically in all perspective types" >> "${iteration_file}"
            echo "- Sprite animations are smooth and consistent for both genders" >> "${iteration_file}"
            ;;
        4)
            echo "- SerializationManager successfully saves and loads game state" >> "${iteration_file}"
            echo "- All registered systems persist their data correctly" >> "${iteration_file}"
            echo "- Save files are compressed and validate properly" >> "${iteration_file}"
            echo "- Backwards compatibility is maintained" >> "${iteration_file}"
            echo "- Performance targets are met (save <1s, load <2s)" >> "${iteration_file}"
            echo "- Save system handles errors gracefully" >> "${iteration_file}"
            echo "- Unit tests achieve >90% coverage" >> "${iteration_file}"
            echo "- Inventory items persist correctly between sessions" >> "${iteration_file}"
            echo "- Item conditions and custom data save/load properly" >> "${iteration_file}"
            echo "- Container states maintain across saves" >> "${iteration_file}"
            echo "- Loadout system saves and restores correctly" >> "${iteration_file}"
            echo "- Inventory migration handles version changes" >> "${iteration_file}"
            echo "- Save file corruption detection works correctly" >> "${iteration_file}"
            echo "- Platform-specific save directories function properly" >> "${iteration_file}"
            echo "- Performance metrics track and validate targets" >> "${iteration_file}"
            echo "- Checksum validation prevents data corruption" >> "${iteration_file}"
            ;;
        5)
            echo "- Quest log accurately tracks active and completed quests" >> "${iteration_file}"
            echo "- Player can collect and use items/evidence" >> "${iteration_file}"
            echo "- Puzzles can be solved to progress investigation" >> "${iteration_file}"
            echo "- Player can track which NPCs are known to be assimilated" >> "${iteration_file}"
            echo "- Player can store extra items in their room" >> "${iteration_file}"
            echo "- Inventory management creates meaningful gameplay decisions" >> "${iteration_file}"
            echo "- Observation mechanics allow players to detect assimilated NPCs" >> "${iteration_file}"
            echo "- Different observation intensities reveal appropriate information" >> "${iteration_file}"
            ;;
        6)
            echo "- NPCs can be successfully recruited to the coalition" >> "${iteration_file}"
            echo "- Failed recruitment attempts have meaningful consequences" >> "${iteration_file}"
            echo "- Coalition strength affects game progression" >> "${iteration_file}"
            echo "- Coalition members provide tangible benefits" >> "${iteration_file}"
            ;;
        7)
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
    
    # Set timeline based on iteration number
    case ${iteration_number} in
        1)
            echo "- Start date: 2025-05-01" >> "${iteration_file}"
            echo "- Target completion: 2025-05-15" >> "${iteration_file}"
            ;;
        2)
            echo "- Start date: 2025-05-15" >> "${iteration_file}"
            echo "- Target completion: 2025-05-29" >> "${iteration_file}"
            ;;
        3)
            echo "- Start date: 2025-05-18" >> "${iteration_file}"
            echo "- Target completion: 2025-06-01" >> "${iteration_file}"
            ;;
        4)
            echo "- Start date: TBD" >> "${iteration_file}"
            echo "- Target completion: 2 weeks from start" >> "${iteration_file}"
            echo "- Critical for: Iteration 5 (Time System) and Iteration 7 (Save/Sleep)" >> "${iteration_file}"
            ;;
        5)
            echo "- Start date: 2025-06-26" >> "${iteration_file}"
            echo "- Target completion: 2025-07-10" >> "${iteration_file}"
            ;;
        6)
            echo "- Start date: 2025-07-10" >> "${iteration_file}"
            echo "- Target completion: 2025-07-24" >> "${iteration_file}"
            ;;
        7)
            echo "- Start date: 2025-07-24" >> "${iteration_file}"
            echo "- Target completion: 2025-08-07" >> "${iteration_file}"
            ;;
        *)
            echo "- Start date: $(date +%Y-%m-%d)" >> "${iteration_file}"
            echo "- Target completion: $(date -d "+14 days" +%Y-%m-%d)" >> "${iteration_file}"
            ;;
    esac
    
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
            echo "- Iteration 2: NPC Framework (need base classes to serialize)" >> "${iteration_file}"
            echo "- Iteration 3: Navigation System (completed - provides stable systems to test with)" >> "${iteration_file}"
            ;;
        5)
            echo "- Iteration 2 (NPC Framework and Suspicion System)" >> "${iteration_file}"
            echo "- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)" >> "${iteration_file}"
            echo "- Iteration 4 (Game Districts and Time Management)" >> "${iteration_file}"
            ;;
        6)
            echo "- Iteration 2 (NPC Framework and Suspicion System)" >> "${iteration_file}"
            echo "- Iteration 5 (Investigation Mechanics)" >> "${iteration_file}"
            ;;
        7)
            echo "- Iteration 5 (Investigation Mechanics)" >> "${iteration_file}"
            echo "- Iteration 6 (Coalition Building)" >> "${iteration_file}"
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
    
    # Add notes for iteration 3
    if [ "$iteration_number" = "3" ]; then
        echo "This iteration implements the plans in the following design documents:" >> "${iteration_file}"
        echo "- docs/design/point_and_click_navigation_refactoring_plan.md" >> "${iteration_file}"
        echo "- docs/design/multi_perspective_character_system_plan.md" >> "${iteration_file}"
        echo "- docs/design/sprite_perspective_scaling_plan.md" >> "${iteration_file}"
        echo "- docs/design/foreground_occlusion_mvp_plan.md" >> "${iteration_file}"
        echo "- docs/design/audio_system_iteration3_mvp.md" >> "${iteration_file}"
        echo "- docs/design/audio_system_technical_implementation.md" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "Template References:" >> "${iteration_file}"
        echo "- Template integration patterns should follow docs/design/template_integration_standards.md throughout implementation" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "These systems provide the foundation for all future gameplay elements and will be extended in subsequent iterations." >> "${iteration_file}"
    elif [ "$iteration_number" = "4" ]; then
        echo "- This iteration was reorganized from the original plan to establish serialization first" >> "${iteration_file}"
        echo "- Critical foundation for save/sleep system in Iteration 7" >> "${iteration_file}"
        echo "- Self-registration pattern reduces coupling and maintenance" >> "${iteration_file}"
        echo "- Consider save file encryption for future anti-cheat measures" >> "${iteration_file}"
        echo "- Suspicion system serialization enables complex social dynamics to persist" >> "${iteration_file}"
    else
        echo "Add any additional notes or considerations here." >> "${iteration_file}"
    fi
    
    # Update progress file
    update_progress_file
    
    echo -e "${GREEN}Iteration ${iteration_number} created: ${iteration_file}${NC}"
}

# Function to list tasks for a specific iteration
function list_tasks {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Missing iteration number.${NC}"
        echo "Usage: ./tools/iteration_planner.sh list <iteration_number>"
        exit 1
    fi
    
    iteration_number=$1
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./tools/iteration_planner.sh create ${iteration_number} \"Iteration Name\""
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
        echo "Usage: ./tools/iteration_planner.sh update <iteration_number> <task_number> <status>"
        echo "Status can be: pending, in_progress, complete"
        exit 1
    fi
    
    iteration_number=$1
    task_number=$2
    status=$3
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    # Get current date for timestamp
    current_date=$(date +"%m/%d/%y")
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./tools/iteration_planner.sh create ${iteration_number} \"Iteration Name\""
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
    
    # Find the actual task line by searching for tasks after the Tasks section
    # Get all task lines and find the Nth one
    task_lines=($(grep -n "^- \[" "${iteration_file}" | cut -d: -f1))
    if [ ${#task_lines[@]} -lt $task_number ]; then
        echo -e "${RED}Error: Task ${task_number} not found. Only ${#task_lines[@]} tasks exist.${NC}"
        exit 1
    fi
    
    # Get the line number for the specific task (arrays are 0-indexed)
    task_line=${task_lines[$((task_number - 1))]}
    
    # Get the task text to extract description (for task section update)
    task_text=$(sed -n "${task_line}p" "${iteration_file}")
    task_desc=$(echo "${task_text}" | sed -n 's/^- \[[xX~ ]\] \(.*\)/\1/p')
    
    # Extract just the task description without "Task N:" prefix for section matching
    task_desc_clean=$(echo "${task_desc}" | sed -n 's/^Task [0-9]*: \(.*\)/\1/p')
    
    # Define status emojis and markdown formatting
    case "$status" in
        "pending")
            checkbox=" "
            status_emoji="⏳"
            status_text="PENDING"
            ;;
        "in_progress")
            checkbox="~"
            status_emoji="🔄"
            status_text="IN PROGRESS"
            ;;
        "complete")
            checkbox="x"
            status_emoji="✅"
            status_text="COMPLETE"
            ;;
    esac
    
    # Full status with timestamp
    status_md="**${status_emoji} ${status_text}** (${current_date})"
    
    # Update the checkbox in the task list
    sed -i "${task_line}s/- \[[xX~ ]\]/- \[${checkbox}\]/g" "${iteration_file}"
    
    # Update the task section if it exists (use clean description if available, otherwise full description)
    if [ ! -z "${task_desc_clean}" ]; then
        task_section_exists=$(grep -n "^### Task ${task_number}: ${task_desc_clean}" "${iteration_file}" | cut -d: -f1)
    else
        task_section_exists=$(grep -n "^### Task ${task_number}: ${task_desc}" "${iteration_file}" | cut -d: -f1)
    fi
    if [ ! -z "${task_section_exists}" ]; then
        # Check if status history section already exists within this task section
        # Search for Status History within the current task section
        # First, find the next task section to limit our search scope
        next_task_line=$(awk -v start="$task_section_exists" 'NR > start && /^### Task/ {print NR; exit}' "${iteration_file}")
        
        if [ -z "${next_task_line}" ]; then
            # No next task section, search to end of file
            search_end='$'
        else
            # Limit search to before next task section
            search_end=$((next_task_line - 1))
        fi
        
        # Look for Status History within this task's section
        status_history_exists=$(awk -v start="$task_section_exists" -v end="$search_end" 'NR >= start && (end == "$" || NR <= end) && /^\*\*Status History:\*\*/ {print NR; exit}' "${iteration_file}")
        
        # Status history search complete
        
        if [ -z "${status_history_exists}" ]; then
            # Find where to insert status history within this task section
            # Look for Requirements section within this task
            if [ -z "${next_task_line}" ]; then
                req_line=$(awk -v start="$task_section_exists" 'NR >= start && /^\*\*Requirements:\*\*/ {print NR; exit}' "${iteration_file}")
            else
                req_line=$(awk -v start="$task_section_exists" -v end="$next_task_line" 'NR >= start && NR < end && /^\*\*Requirements:\*\*/ {print NR; exit}' "${iteration_file}")
            fi
            
            if [ ! -z "${req_line}" ]; then
                # Insert before Requirements section
                insert_line=$((req_line - 1))
            else
                # If no requirements section, insert after user story line
                insert_line=$((task_section_exists + 2))
            fi
            
            # Insert the status history section
            sed -i "${insert_line}a\\
\\
**Status History:**\\
- ${status_md}" "${iteration_file}"
        else
            # Add new status to history (prepend to keep newest at top)
            status_line=$((status_history_exists + 1))
            sed -i "${status_line}a\\- ${status_md}" "${iteration_file}"
        fi
    fi
    
    echo -e "${GREEN}Task ${task_number} updated to ${status_text} with timestamp ${current_date}.${NC}"
    
    # Update progress file
    update_progress_file
}

# Function to link a task to a code file
function link_task_to_file {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo -e "${RED}Error: Missing parameters.${NC}"
        echo "Usage: ./tools/iteration_planner.sh link <iteration_number> <task_number> \"<file_path>\""
        exit 1
    fi
    
    iteration_number=$1
    task_number=$2
    file_path=$3
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./tools/iteration_planner.sh create ${iteration_number} \"Iteration Name\""
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

# Function to add a requirement to an iteration (NEW)
function add_requirement {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo -e "${RED}Error: Missing parameters.${NC}"
        echo "Usage: ./tools/iteration_planner.sh add-req <iteration_number> <type> <requirement_text>"
        echo "Type can be: business, user, technical"
        exit 1
    fi
    
    iteration_number=$1
    req_type=$2
    req_text=$3
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./tools/iteration_planner.sh create ${iteration_number} \"Iteration Name\""
        exit 1
    fi
    
    # Check if type is valid
    if [ "$req_type" != "business" ] && [ "$req_type" != "user" ] && [ "$req_type" != "technical" ]; then
        echo -e "${RED}Error: Invalid requirement type.${NC}"
        echo "Type can be: business, user, technical"
        exit 1
    fi
    
    # Determine the section to add to
    case "$req_type" in
        "business")
            section_header="### Business Requirements"
            prefix="B"
            ;;
        "user")
            section_header="### User Requirements"
            prefix="U"
            ;;
        "technical")
            section_header="### Technical Requirements (Optional)"
            prefix="T"
            ;;
    esac
    
    # Count existing requirements of this type
    existing_count=$(grep -c "^- \*\*${prefix}[0-9]\+:\*\*" "${iteration_file}")
    new_number=$((existing_count + 1))
    
    # Add the new requirement after the section header
    awk -v section="$section_header" -v text="- **${prefix}${new_number}:** ${req_text}" '
    {
        print $0
        if ($0 ~ section) {
            print ""
            print text
            print "  - **Rationale:** [Add rationale here]"
            if ("'"${prefix}"'" == "U") {
                print "  - **User Value:** [Add user value here]"
            } else {
                print "  - **Success Metric/Constraints:** [Add metric or constraints here]"
            }
        }
    }' "${iteration_file}" > "${iteration_file}.tmp" && mv "${iteration_file}.tmp" "${iteration_file}"
    
    echo -e "${GREEN}Added ${req_type} requirement ${prefix}${new_number} to iteration ${iteration_number}.${NC}"
}

# Function to add a user story to a task (NEW)
function add_user_story {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo -e "${RED}Error: Missing parameters.${NC}"
        echo "Usage: ./tools/iteration_planner.sh add-story <iteration_number> <task_number> \"<user_story>\""
        echo "User story format should be: 'As a [role], I want [feature], so that [benefit]'"
        exit 1
    fi
    
    iteration_number=$1
    task_number=$2
    user_story=$3
    iteration_file="${ITERATIONS_DIR}/iteration${iteration_number}_plan.md"
    
    # Get current date for timestamp
    current_date=$(date +"%m/%d/%y")
    
    if [ ! -f "${iteration_file}" ]; then
        echo -e "${RED}Error: Iteration ${iteration_number} does not exist.${NC}"
        echo "Create it first with: ./tools/iteration_planner.sh create ${iteration_number} \"Iteration Name\""
        exit 1
    fi
    
    # Find the task line
    tasks_line=$(grep -n "^## Tasks" "${iteration_file}" | cut -d: -f1)
    if [ -z "$tasks_line" ]; then
        echo -e "${RED}Error: Could not find Tasks section in iteration file.${NC}"
        exit 1
    fi
    
    # Calculate the line number for the specific task
    task_line=$((tasks_line + task_number))
    task_text=$(sed -n "${task_line}p" "${iteration_file}")
    
    # Extract task description
    task_desc=$(echo "${task_text}" | sed -n 's/^- \[[xX~ ]\] \(.*\)/\1/p')
    if [ -z "${task_desc}" ]; then
        echo -e "${RED}Error: Could not extract task description at line ${task_line}.${NC}"
        exit 1
    fi
    
    # Get the current task status from checkbox
    if echo "${task_text}" | grep -q "^\- \[x\]"; then
        status_emoji="✅"
        status_text="COMPLETE"
    elif echo "${task_text}" | grep -q "^\- \[~\]"; then
        status_emoji="🔄"
        status_text="IN PROGRESS"
    else
        status_emoji="⏳"
        status_text="PENDING"
    fi
    
    # Full status with timestamp
    status_md="**${status_emoji} ${status_text}** (${current_date})"
    
    # Check if user story section already exists
    task_section_exists=$(grep -n "^### Task ${task_number}: ${task_desc}" "${iteration_file}" | cut -d: -f1)
    
    if [ -z "${task_section_exists}" ]; then
        # Create new task section
        echo "" >> "${iteration_file}"
        echo "### Task ${task_number}: ${task_desc}" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**User Story:** ${user_story}" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Status History:**" >> "${iteration_file}"
        echo "- ${status_md}" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Requirements:**" >> "${iteration_file}"
        echo "- **Linked to:** [List related Epic-level requirements]" >> "${iteration_file}"
        echo "- **Acceptance Criteria:**" >> "${iteration_file}"
        echo "  1. [Specific condition that must be met]" >> "${iteration_file}"
        echo "" >> "${iteration_file}"
        echo "**Implementation Notes:**" >> "${iteration_file}"
        echo "- [Technical guidance or approach]" >> "${iteration_file}"
    else
        # Update existing user story
        user_story_line=$((task_section_exists + 2))
        sed -i "${user_story_line}c\\**User Story:** ${user_story}" "${iteration_file}"
        
        # Check if status history exists
        status_history_exists=$(grep -n "^**Status History:**" "${iteration_file}" | head -n 1 | cut -d: -f1)
        
        if [ -z "${status_history_exists}" ]; then
            # Add status history after user story
            sed -i "${user_story_line}a\\
\\
**Status History:**\\
- ${status_md}" "${iteration_file}"
        fi
    fi
    
    echo -e "${GREEN}Added/updated user story for Task ${task_number} in Iteration ${iteration_number}.${NC}"
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
            
            # Add goals section
            echo "**Goals:**" >> "${PROGRESS_FILE}"
            goals=$(grep -A 100 "^## Goals" "${iter_file}" | grep -B 100 "^##" | grep "^\-" | grep -v "^##")
            echo "${goals}" >> "${PROGRESS_FILE}"
            echo "" >> "${PROGRESS_FILE}"
            
            # Add key requirements (NEW)
            echo "**Key Requirements:**" >> "${PROGRESS_FILE}"
            business_reqs=$(grep -A 10 "^### Business Requirements" "${iter_file}" | grep "^\- \*\*B" | head -2)
            user_reqs=$(grep -A 10 "^### User Requirements" "${iter_file}" | grep "^\- \*\*U" | head -2)
            
            if [ ! -z "$business_reqs" ]; then
                echo "${business_reqs}" >> "${PROGRESS_FILE}"
            fi
            
            if [ ! -z "$user_reqs" ]; then
                echo "${user_reqs}" >> "${PROGRESS_FILE}"
            fi
            
            echo "" >> "${PROGRESS_FILE}"
            
            # Extract and add tasks with status
            echo "**Tasks:**" >> "${PROGRESS_FILE}"
            echo "" >> "${PROGRESS_FILE}"
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
                
                # Check for user story (NEW)
                user_story=""
                if [ ! -z "${task_desc}" ]; then
                    task_section=$(grep -n "^### Task ${task_num}: ${task_desc}" "${iter_file}" | cut -d: -f1)
                    if [ ! -z "${task_section}" ] && [ "${task_section}" -gt 0 ] 2>/dev/null; then
                        user_story_line=$((task_section + 2))
                        user_story=$(sed -n "${user_story_line}p" "${iter_file}" | sed -n 's/^\*\*User Story:\*\* \(.*\)/\1/p')
                        if [ ! -z "${user_story}" ]; then
                            task_desc="${task_desc} (${user_story})"
                        fi
                    fi
                fi
                
                # Only add to the progress file if we have a task description
                if [ ! -z "${task_desc}" ]; then
                    echo "| ${task_desc} | ${task_status} | ${linked_file} |" >> "${PROGRESS_FILE}"
                    task_num=$((task_num + 1))
                fi
            done
            
            echo "" >> "${PROGRESS_FILE}"
            
            # Add testing criteria
            echo "**Testing Criteria:**" >> "${PROGRESS_FILE}"
            testing=$(grep -A 100 "^## Testing Criteria" "${iter_file}" | grep -B 100 "^##" | grep "^\-" | grep -v "^##")
            echo "${testing}" >> "${PROGRESS_FILE}"
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
    add-req)
        add_requirement "$2" "$3" "$4"
        ;;
    add-story)
        add_user_story "$2" "$3" "$4"
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