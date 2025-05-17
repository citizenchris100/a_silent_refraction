# A Silent Refraction - Iteration Progress

This file tracks the progress of all iterations for the project.

## Overview

| Iteration | Name | Status | Progress |
|-----------|------|--------|----------|
| 1 | Basic Environment and Navigation | COMPLETE | 100% (8/8) |
| 2 | NPC Framework, Suspicion System, and Initial Asset Creation | IN PROGRESS | 62% (5/8) |
| 3 | Game Districts and Time Management | Not started | 0% (0/11) |
| 4 | Investigation Mechanics and Inventory | Not started | 0% (0/10) |
| 5 | Coalition Building | Not started | 0% (0/8) |
| 6 | Game Progression and Multiple Endings | Not started | 0% (0/8) |

## Detailed Progress

### Iteration 1: Basic Environment and Navigation

**Goals:**
- Complete the project setup
- Create a basic room with walkable areas
- Implement player character movement
- Test navigation in the shipping district
- **B1:** Establish foundational gameplay movement systems
- **U1:** As a player, I want intuitive point-and-click movement
- **T1:** Implement efficient collision detection for walkable areas
- [x] Task 1: Set up project structure with organized directories
- [x] Task 2: Create configuration in project.godot
- [x] Task 3: Implement shipping district scene with background
- [x] Task 4: Add walkable area with collision detection
- [x] Task 5: Create functional player character
- [x] Task 6: Implement point-and-click navigation
- [x] Task 7: Develop smooth movement system
- [x] Task 8: Test navigation within defined boundaries
- Player can move around the shipping district
- Movement is smooth and responsive
- Player stays within walkable areas
- Project structure follows the defined organization
- Start date: 2025-05-16
- Target completion: 2025-05-30
- None
- No links yet

**Key Requirements:**
- **B1:** Establish foundational gameplay movement systems
- **U1:** As a player, I want intuitive point-and-click movement

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Set up project structure with organized directories | Complete | - |
| Create configuration in project.godot | Complete | - |
| Implement shipping district scene with background | Complete | - |
| Add walkable area with collision detection | Complete | - |
| Create functional player character | Complete | - |
| Implement point-and-click navigation | Complete | - |
| Develop smooth movement system | Complete | - |
| Test navigation within defined boundaries | Complete | - |

**Testing Criteria:**
- Player can move around the shipping district
- Movement is smooth and responsive
- Player stays within walkable areas
- Project structure follows the defined organization
- Start date: 2025-05-16
- Target completion: 2025-05-30
- None
- No links yet

### Iteration 2: NPC Framework, Suspicion System, and Initial Asset Creation

**Goals:**
- Implement basic NPCs with interactive capabilities
- Create the suspicion system as a core gameplay mechanic
- Apply visual style guide to one area as a prototype
- Develop placeholder art generation for NPCs
- **B5:** Develop a core set of game assets that establish the game's visual identity and support key gameplay mechanics
- **B4:** Establish a suspicion mechanic that creates gameplay tension and drives player decision-making
- **B3:** Create an immersive NPC interaction system that supports narrative and gameplay progression
- **B1:** Establish core game mechanic of NPC suspicion to drive gameplay tension
- **B2:** Create reusable NPC framework to streamline future character development
- **U1:** As a player, I want to observe subtle cues that help identify assimilated NPCs
- **U2:** As a player, I want to track my suspicion level with accessible UI
- **U3:** As a player, I want NPCs to feel distinct through dialog and behavior
- **T1:** Create extensible NPC state machine system
- **T2:** Implement a scrolling background system that enables environments larger than the game window
- [x] Task 1: Create base NPC class with state machine
- [x] Task 2: Implement NPC dialog system
- [x] Task 3: Create suspicion meter UI element
- [x] Task 4: Implement suspicion tracking system
- [x] Task 5: Script NPC reactions based on suspicion levels
- [~] Task 6: Apply visual style guide to Shipping District
- [ ] Task 7: Create bash script for generating NPC placeholders
- [ ] Task 8: Implement observation mechanics for detecting assimilated NPCs
- **Linked to:** B1, U2
- **Acceptance Criteria:**
- Use ProgressBar node as the base for the meter implementation
- Consider shader effects for visual polish (glowing, pulsing at high suspicion)
- Integrate with the global_suspicion_manager.gd for data binding
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 1 (Basic Environment and Navigation)
- Task 7: [tools/create_npc_registry.sh](tools/create_npc_registry.sh)

**Key Requirements:**
- **B5:** Develop a core set of game assets that establish the game's visual identity and support key gameplay mechanics
- **B4:** Establish a suspicion mechanic that creates gameplay tension and drives player decision-making
- **U1:** As a player, I want to observe subtle cues that help identify assimilated NPCs
- **U2:** As a player, I want to track my suspicion level with accessible UI

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Create base NPC class with state machine | Complete | - |
| Implement NPC dialog system | Complete | - |
| Create suspicion meter UI element (As a player, I want to see a visual indicator of my current suspicion level, so that I can make informed decisions about my actions and interactions with NPCs.) | Complete | - |
| Implement suspicion tracking system | Complete | - |
| Script NPC reactions based on suspicion levels | Complete | - |
| Apply visual style guide to Shipping District (As a player, I want to explore scrolling backgrounds in the Shipping District that extend beyond the screen boundaries, so that I can experience larger, more immersive environments that feel like real spaces rather than confined screens) | In Progress | - |
| Create bash script for generating NPC placeholders (As a developer, I want a bash script that manages the NPC registry and creates appropriate directory structures for NPC sprites, so that I can easily add new characters to the game with proper integration into the existing systems without manual configuration.) | Pending | tools/create_npc_registry.sh |
| Implement observation mechanics for detecting assimilated NPCs | Pending | - |

**Testing Criteria:**
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 1 (Basic Environment and Navigation)
- Task 7: [tools/create_npc_registry.sh](tools/create_npc_registry.sh)
- **Linked to:** B5, T2
- **Acceptance Criteria:**
- Implement a background manager that handles large image loading
- Create a scrolling camera system that tracks player position
- Integrate with existing walkable area system
- Ensure performance optimization for large background images

### Iteration 3: Game Districts and Time Management

**Goals:**
- Implement multiple station districts with transitions
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- Implement random NPC assimilation tied to time
- Implement single-slot save system
- Create basic limited inventory system
- **B1:** Create a sense of progression and urgency through time management
- **B2:** Expand game world with multiple distinct areas
- **U1:** As a player, I want to manage my time to prioritize activities
- **U2:** As a player, I want to explore distinct areas of the station
- **T1:** Implement robust scene transition system
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
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time
- Player can save game by returning to their room
- Player has limited inventory space
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- No links yet

**Key Requirements:**
- **B1:** Create a sense of progression and urgency through time management
- **B2:** Expand game world with multiple distinct areas
- **U1:** As a player, I want to manage my time to prioritize activities
- **U2:** As a player, I want to explore distinct areas of the station

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Create at least one additional district besides Shipping | Pending | - |
| Implement district transitions via tram system | Pending | - |
| Develop in-game clock and calendar system | Pending | - |
| Create time progression through player actions | Pending | - |
| Implement day cycle with sleep mechanics | Pending | - |
| Design and implement time UI indicators | Pending | - |
| Create system for random NPC assimilation over time | Pending | - |
| Add time-based events and triggers | Pending | - |
| Implement player bedroom as save point location | Pending | - |
| Create single-slot save system with confirmation UI | Pending | - |
| Create basic inventory system with size limitations | Pending | - |

**Testing Criteria:**
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time
- Player can save game by returning to their room
- Player has limited inventory space
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- No links yet

### Iteration 4: Investigation Mechanics and Inventory

**Goals:**
- Implement investigation mechanics
- Create quest log system for tracking progress
- Develop advanced inventory system for collecting evidence
- Add system for logging known assimilated NPCs
- Implement overflow storage in player's room
- **B1:** Implement core investigation mechanics that drive main storyline
- **U1:** As a player, I want to collect and analyze evidence
- **T1:** Technical requirement placeholder
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
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated
- Player can store extra items in their room
- Inventory management creates meaningful gameplay decisions
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Game Districts and Time Management)
- No links yet

**Key Requirements:**
- **B1:** Implement core investigation mechanics that drive main storyline
- **U1:** As a player, I want to collect and analyze evidence

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Create quest data structure and manager | Pending | - |
| Implement quest log UI | Pending | - |
| Develop advanced inventory features including categorization | Pending | - |
| Create puzzles for accessing restricted areas | Pending | - |
| Implement clue discovery and collection system | Pending | - |
| Create assimilated NPC tracking log | Pending | - |
| Develop investigation progress tracking | Pending | - |
| Add quest state persistence | Pending | - |
| Implement overflow inventory storage in player's room | Pending | - |
| Create UI for transferring items between personal inventory and room storage | Pending | - |

**Testing Criteria:**
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated
- Player can store extra items in their room
- Inventory management creates meaningful gameplay decisions
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Game Districts and Time Management)
- No links yet

### Iteration 5: Coalition Building

**Goals:**
- Implement recruiting NPCs to the coalition
- Add risk/reward mechanisms for revealing information
- Create coalition strength tracking
- **B1:** Create meaningful NPC relationships through coalition building
- **U1:** As a player, I want to recruit NPCs to help against the assimilation
- **T1:** Technical requirement placeholder
- [ ] Task 1: Implement NPC recruitment dialog options
- [ ] Task 2: Create coalition membership tracking system
- [ ] Task 3: Develop trust/mistrust mechanics
- [ ] Task 4: Implement coalition strength indicators
- [ ] Task 5: Add coalition member special abilities
- [ ] Task 6: Create consequences for failed recruitment attempts
- [ ] Task 7: Develop coalition headquarters location
- [ ] Task 8: Implement coalition mission assignment system
- NPCs can be successfully recruited to the coalition
- Failed recruitment attempts have meaningful consequences
- Coalition strength affects game progression
- Coalition members provide tangible benefits
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 4 (Investigation Mechanics)
- No links yet

**Key Requirements:**
- **B1:** Create meaningful NPC relationships through coalition building
- **U1:** As a player, I want to recruit NPCs to help against the assimilation

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Implement NPC recruitment dialog options | Pending | - |
| Create coalition membership tracking system | Pending | - |
| Develop trust/mistrust mechanics | Pending | - |
| Implement coalition strength indicators | Pending | - |
| Add coalition member special abilities | Pending | - |
| Create consequences for failed recruitment attempts | Pending | - |
| Develop coalition headquarters location | Pending | - |
| Implement coalition mission assignment system | Pending | - |

**Testing Criteria:**
- NPCs can be successfully recruited to the coalition
- Failed recruitment attempts have meaningful consequences
- Coalition strength affects game progression
- Coalition members provide tangible benefits
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 4 (Investigation Mechanics)
- No links yet

### Iteration 6: Game Progression and Multiple Endings

**Goals:**
- Implement game state progression
- Add multiple endings
- Create transition between narrative branches
- **B1:** Deliver multiple game endings based on player choices
- **U1:** As a player, I want my choices to affect the game's outcome
- **T1:** Technical requirement placeholder
- [ ] Task 1: Implement game state manager
- [ ] Task 2: Create win/lose conditions
- [ ] Task 3: Develop multiple ending scenarios
- [ ] Task 4: Add narrative branching system
- [ ] Task 5: Implement final confrontation sequence
- [ ] Task 6: Create ending cinematics
- [ ] Task 7: Add game over screens
- [ ] Task 8: Implement statistics tracking for playthrough
- Game can be completed with multiple different outcomes
- Narrative branches based on player choices
- Game state properly tracks progress through the story
- Complete game flow can be tested from start to finish
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 4 (Investigation Mechanics)
- Iteration 5 (Coalition Building)
- No links yet

**Key Requirements:**
- **B1:** Deliver multiple game endings based on player choices
- **U1:** As a player, I want my choices to affect the game's outcome

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Implement game state manager | Pending | - |
| Create win/lose conditions | Pending | - |
| Develop multiple ending scenarios | Pending | - |
| Add narrative branching system | Pending | - |
| Implement final confrontation sequence | Pending | - |
| Create ending cinematics | Pending | - |
| Add game over screens | Pending | - |
| Implement statistics tracking for playthrough | Pending | - |

**Testing Criteria:**
- Game can be completed with multiple different outcomes
- Narrative branches based on player choices
- Game state properly tracks progress through the story
- Complete game flow can be tested from start to finish
- Start date: 2025-05-16
- Target completion: 2025-05-30
- Iteration 4 (Investigation Mechanics)
- Iteration 5 (Coalition Building)
- No links yet

