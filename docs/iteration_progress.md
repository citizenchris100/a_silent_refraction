# A Silent Refraction - Iteration Progress

This file tracks the progress of all iterations for the project.

## Overview

| Iteration | Name | Status | Progress |
|-----------|------|--------|----------|
| 1 | Basic Environment and Navigation | COMPLETE | 100% (8/8) |
| 2 | NPC Framework and Suspicion System | COMPLETE | 100% (6/6) |
| 3 | Navigation Refactoring and Multi-Perspective Character System | IN PROGRESS | 6% (2/30) |
| 4 | Dialog and Verb UI System Refactoring | Not started | 0% (0/20) |
| 5 | Game Districts and Time Management | Not started | 0% (0/12) |
| 6 | Investigation Mechanics and Inventory | Not started | 0% (0/17) |
| 7 | Coalition Building | Not started | 0% (0/8) |
| 8 | Game Progression and Multiple Endings | Not started | 0% (0/8) |

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
- **⏳ PENDING** (05/01/25)
- **🔄 IN PROGRESS** (05/02/25)
- **✅ COMPLETE** (05/03/25)
- **Linked to:** B1, T1
- **Acceptance Criteria:**
- Follow Godot best practices for project organization
- Create separate directories for code, assets, documentation, and tests
- Organize code by feature/system rather than by file type
- **⏳ PENDING** (05/01/25)
- **🔄 IN PROGRESS** (05/02/25)
- **✅ COMPLETE** (05/03/25)
- **Linked to:** B1, T1
- **Acceptance Criteria:**
- Set up appropriate project settings for 2D point-and-click adventure
- Configure input map for mouse events
- Set up autoloads for core game systems
- **⏳ PENDING** (05/04/25)
- **🔄 IN PROGRESS** (05/04/25)
- **✅ COMPLETE** (05/08/25)
- **Linked to:** B1, U1
- **Acceptance Criteria:**
- Create background scene with proper Godot nodes
- Import and configure background image assets
- Set up camera for proper viewing of the scene

**Key Requirements:**
- **B1:** Establish foundational gameplay movement systems
- **U1:** As a player, I want intuitive point-and-click movement

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|

**Testing Criteria:**
- Player can move around the shipping district
- Movement is smooth and responsive
- Player stays within walkable areas
- Project structure follows the defined organization
- Start date: 2025-05-01
- Target completion: 2025-05-10
- None
- Task 6: [src/core/player_controller.gd](src/core/player_controller.gd)
- Task 7: [src/core/coordinate_system.gd](src/core/coordinate_system.gd)
- Task 4: [src/core/districts/walkable_area.gd](src/core/districts/walkable_area.gd)

### Iteration 2: NPC Framework and Suspicion System

**Goals:**
- Implement basic NPCs with interactive capabilities
- Create the suspicion system as a core gameplay mechanic
- Apply visual style guide to one area as a prototype
- Develop placeholder art generation for NPCs
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
- [x] Task 6: Apply visual style guide to Shipping District
- **⏳ PENDING** (05/05/25)
- **🔄 IN PROGRESS** (05/06/25)
- **✅ COMPLETE** (05/07/25)
- **Linked to:** B2, U3, T1
- **Acceptance Criteria:**
- Implement state pattern for NPC behavior
- Create clean interface for state transitions
- Ensure states persist correctly between scene loads
- Use signals for state change communication
- **⏳ PENDING** (05/06/25)
- **🔄 IN PROGRESS** (05/07/25)
- **✅ COMPLETE** (05/08/25)
- **Linked to:** B1, B2, U1, U3
- **Acceptance Criteria:**
- Create JSON-based dialog definition format
- Build dialog UI with character portraits
- Implement dialog state machine
- Connect dialog choices to suspicion system

**Key Requirements:**
- **B1:** Establish core game mechanic of NPC suspicion to drive gameplay tension
- **B2:** Create reusable NPC framework to streamline future character development
- **U1:** As a player, I want to observe subtle cues that help identify assimilated NPCs
- **U2:** As a player, I want to track my suspicion level with accessible UI

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|

**Testing Criteria:**
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly
- Start date: 2025-05-11
- Target completion: 2025-05-17
- Iteration 1 (Basic Environment and Navigation)
- Task 1: [src/characters/npc/base_npc.gd](src/characters/npc/base_npc.gd)
- Task 3: [src/ui/suspicion_meter/global_suspicion_meter.gd](src/ui/suspicion_meter/global_suspicion_meter.gd)
- Task 6: [src/core/camera/scrolling_camera.gd](src/core/camera/scrolling_camera.gd)

### Iteration 3: Navigation Refactoring and Multi-Perspective Character System

**Goals:**
- Implement improved point-and-click navigation system
- Create multi-perspective character system
- Enhance camera system with proper coordinate transformations
- Implement robust walkable area integration
- Develop comprehensive test cases for both systems
- **B1:** Create a more responsive and predictable navigation system
- **B2:** Support multiple visual perspectives across different game districts
- **B3:** Maintain consistent visual quality and gameplay mechanics across all perspectives
- **U1:** As a player, I want navigation to feel smooth and responsive
- **U2:** As a player, I want my character to appear correctly in different game areas
- **U3:** As a player, I want consistent gameplay mechanics regardless of visual perspective
- **T1:** Maintain architectural principles while refactoring
- **T2:** Implement flexible, configuration-driven system for perspectives
- **T3:** All camera system enhancements must preserve background scaling visual correctness and pass both unit tests and visual validation using camera-system test scene
- [x] Task 1: Enhance scrolling camera system with improved coordinate conversions *(REQUIRES VISUAL FIXES)*
- [x] Task 2: Implement state signaling and synchronization for camera
- [ ] Task 3: Create test scene for validating camera system improvements
- [ ] Task 4: Enhance player controller for consistent physics behavior
- [ ] Task 5: Implement proper pathfinding with Navigation2D
- [ ] Task 6: Create test scene for player movement validation
- [ ] Task 7: Enhance walkable area system with improved polygon algorithms
- [ ] Task 8: Implement click detection and validation refinements
- [ ] Task 9: Create test scene for walkable area validation
- [ ] Task 10: Enhance system communication through signals
- [ ] Task 11: Implement comprehensive debug tools and visualizations
- [ ] Task 12: Create integration test for full navigation system
- [ ] Task 13: Create directory structure and base files for the multi-perspective system
- [ ] Task 14: Define perspective types enum and configuration templates
- [ ] Task 15: Extend district base class to support perspective information
- [ ] Task 16: Implement character controller class with animation support
- [ ] Task 17: Create test character with basic animations
- [ ] Task 18: Test animation transitions within a perspective
- [ ] Task 19: Implement movement controller with direction support
- [ ] Task 20: Connect movement controller to point-and-click navigation
- [ ] Task 21: Test character movement in a single perspective
- [ ] Task 22: Create test districts with different perspective types
- [ ] Task 23: Implement perspective switching in character controller
- [ ] Task 24: Create test for transitions between different perspective districts
- [ ] Task 25: Create comprehensive documentation for both systems
- [ ] Task 26: Perform code review and optimization
- [ ] Task 27: Update existing documentation to reflect new systems
- [ ] Task 28: Create simple POC test sprites for perspective scaling validation
- [ ] Task 29: Implement basic sprite perspective scaling system
- [ ] Task 30: Create sprite scaling test scene for validation
- Camera system properly handles coordinate conversions
- Player movement is smooth with proper acceleration/deceleration
- Pathfinding correctly navigates around obstacles
- Walkable areas are properly respected with accurate boundaries
- Characters display correctly in each perspective
- Animation transitions are smooth in all perspectives
- Character movement adapts correctly to each perspective type
- Performance remains optimal across all test cases
- All debug tools work properly

**Key Requirements:**
- **B1:** Create a more responsive and predictable navigation system
- **B2:** Support multiple visual perspectives across different game districts
- **U1:** As a player, I want navigation to feel smooth and responsive
- **U2:** As a player, I want my character to appear correctly in different game areas

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Enhance scrolling camera system with improved coordinate conversions *(REQUIRES VISUAL FIXES)* | Complete | - |
| Implement state signaling and synchronization for camera (As a player, I want the camera to correctly synchronize with my character's movement and game events, so that I always have a clear view of relevant gameplay elements without jarring transitions.) | Complete | - |
| Create test scene for validating camera system improvements | Pending | - |
| Enhance player controller for consistent physics behavior (As a player, I want my character to move naturally with smooth acceleration and deceleration, so that navigation feels responsive and realistic.) | Pending | - |
| Implement proper pathfinding with Navigation2D | Pending | - |
| Create test scene for player movement validation | Pending | - |
| Enhance walkable area system with improved polygon algorithms (As a player, I want clear boundaries for where my character can walk, so that I don't experience frustration from attempting to navigate to inaccessible areas.) | Pending | - |
| Implement click detection and validation refinements | Pending | - |
| Create test scene for walkable area validation | Pending | - |
| Enhance system communication through signals | Pending | - |
| Implement comprehensive debug tools and visualizations | Pending | - |
| Create integration test for full navigation system | Pending | - |
| Create directory structure and base files for the multi-perspective system (As a developer, I want a well-organized foundation for the multi-perspective character system, so that we can build and extend it systematically with minimal refactoring.) | Pending | - |
| Define perspective types enum and configuration templates | Pending | - |
| Extend district base class to support perspective information | Pending | - |
| Implement character controller class with animation support (As a player, I want my character's appearance to adapt correctly to different visual perspectives, so that the game maintains visual consistency and immersion.) | Pending | - |
| Create test character with basic animations | Pending | - |
| Test animation transitions within a perspective | Pending | - |
| Implement movement controller with direction support (As a player, I want my character to move correctly regardless of the visual perspective, so that gameplay feels consistent throughout the game.) | Pending | - |
| Connect movement controller to point-and-click navigation | Pending | - |
| Test character movement in a single perspective | Pending | - |
| Create test districts with different perspective types | Pending | - |
| Implement perspective switching in character controller | Pending | - |
| Create test for transitions between different perspective districts | Pending | - |
| Create comprehensive documentation for both systems (As a developer, I want clear documentation for both the navigation and multi-perspective systems, so that I can understand, maintain, and extend these systems effectively.) | Pending | - |
| Perform code review and optimization | Pending | - |
| Update existing documentation to reflect new systems | Pending | - |
| Create simple POC test sprites for perspective scaling validation (As a developer, I want simple geometric test sprites at multiple scales, so that I can validate the perspective scaling system without complex art assets.) | Pending | - |
| Implement basic sprite perspective scaling system (As a developer, I want sprites to scale based on Y-position in perspective backgrounds, so that depth illusion is maintained in scenes with visual perspective.) | Pending | - |
| Create sprite scaling test scene for validation (As a developer, I want a dedicated test scene for sprite scaling, so that I can validate perspective effects work correctly with different backgrounds and movement patterns.) | Pending | - |

**Testing Criteria:**
- Camera system properly handles coordinate conversions
- Player movement is smooth with proper acceleration/deceleration
- Pathfinding correctly navigates around obstacles
- Walkable areas are properly respected with accurate boundaries
- Characters display correctly in each perspective
- Animation transitions are smooth in all perspectives
- Character movement adapts correctly to each perspective type
- Performance remains optimal across all test cases
- All debug tools work properly
- Start date: 2025-05-18
- Target completion: 2025-06-01
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- No links yet
- docs/design/point_and_click_navigation_refactoring_plan.md
- docs/design/multi_perspective_character_system_plan.md
- **⏳ PENDING** (05/22/25)
- **✅ COMPLETE** (05/22/25)
- **✅ COMPLETE** (05/22/25)
- **✅ COMPLETE** (05/22/25)
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
- Refine coordinate handling in scrolling_camera.gd
- Add validation methods to ensure coordinates are always valid
- Update camera targeting to prevent edge cases
- Maintain alignment with signal-based architectural pattern

### Iteration 4: Dialog and Verb UI System Refactoring

**Goals:**
- Refactor dialog system to comply with architectural principles
- Refactor verb UI system to comply with architectural principles
- Implement service-based architecture with dependency injection
- Establish comprehensive unit testing for both systems
- Maintain all existing functionality while improving maintainability
- Create extensible foundation for future enhancements
- **B1:** Eliminate technical debt in core interaction systems
- **B2:** Establish sustainable development practices
- **B3:** Maintain player experience continuity
- **U1:** As a player, I want dialog interactions to work reliably and smoothly
- **U2:** As a player, I want verb-based interactions to be responsive and intuitive
- **U3:** As a player, I want the game to be stable and error-free
- **T1:** Eliminate architectural violations in dialog and verb UI systems
- **T2:** Implement service-based architecture with dependency injection
- **T3:** Establish comprehensive unit testing infrastructure
- [ ] Task 1: Implement dialog service interfaces and dependency injection
- [ ] Task 2: Create dialog data abstraction layer (DialogData, DialogNode classes)
- [ ] Task 3: Refactor dialog processing with validation pipeline
- [ ] Task 4: Implement dialog UI factory and controller separation
- [ ] Task 5: Establish dialog signal-based event system
- [ ] Task 6: Create comprehensive dialog unit tests and mocks
- [ ] Task 7: Implement progressive dialog system migration with adapters
- [ ] Task 8: Implement verb service interfaces and configuration system
- [ ] Task 9: Create interaction processing pipeline (validators/processors)
- [ ] Task 10: Refactor verb UI with factory pattern and controller separation
- [ ] Task 11: Establish verb interaction event bus and signal architecture
- [ ] Task 12: Create comprehensive verb interaction unit tests and mocks
- [ ] Task 13: Implement progressive verb system migration with adapters
- [ ] Task 14: Integrate both refactored systems with ServiceRegistry
- [ ] Task 15: Perform comprehensive integration testing
- [ ] Task 16: Validate 100% functional parity with original systems
- [ ] Task 17: Update system documentation for both refactored systems
- All existing dialog functionality works identically to pre-refactoring behavior
- All verb+object interactions produce identical responses to original system  
- Dialog system achieves >90% unit test coverage with comprehensive mocks
- Verb UI system achieves >90% unit test coverage with comprehensive mocks
- Zero scene tree dependencies in core dialog and verb processing logic
- Service-based architecture enables isolated component testing
- Signal-based communication eliminates tight coupling between systems
- Error handling provides structured context for all failure scenarios
- Performance matches or exceeds original system response times
- Start date: 2025-05-29
- Target completion: 2025-06-12
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- [Dialog System Refactoring Plan](docs/design/dialog_system_refactoring_plan.md)
- [Verb UI System Refactoring Plan](docs/design/verb_ui_system_refactoring_plan.md)
- [Project Architecture Reference](docs/reference/architecture.md)

**Key Requirements:**
- **B1:** Eliminate technical debt in core interaction systems
- **B2:** Establish sustainable development practices
- **U1:** As a player, I want dialog interactions to work reliably and smoothly
- **U2:** As a player, I want verb-based interactions to be responsive and intuitive

**Tasks:**

| Task | Status | Linked Files |
|------|--------|--------------|
| Implement dialog service interfaces and dependency injection (As a developer, I want dialog services to use dependency injection instead of scene tree traversal, so that I can test dialog logic in isolation and eliminate tight coupling between systems.) | Pending | - |
| Create dialog data abstraction layer (DialogData, DialogNode classes) (As a developer, I want dialog data separated from UI and processing logic, so that I can modify dialog content without affecting system behavior and test dialog logic with predictable data.) | Pending | - |
| Refactor dialog processing with validation pipeline (As a developer, I want dialog processing to use a validation pipeline, so that I can catch errors early with structured context and extend validation rules without modifying core logic.) | Pending | - |
| Implement dialog UI factory and controller separation (As a developer, I want dialog UI creation separated from business logic, so that I can test UI behavior independently and modify dialog presentation without affecting core dialog processing.) | Pending | - |
| Establish dialog signal-based event system (As a developer, I want dialog system communication to use signals instead of direct method calls, so that I can decouple dialog components and enable extensible event handling.) | Pending | - |
| Create comprehensive dialog unit tests and mocks (As a developer, I want comprehensive unit tests for the dialog system, so that I can prevent regressions and validate behavior changes during refactoring.) | Pending | - |
| Implement progressive dialog system migration with adapters (As a developer, I want to migrate the dialog system gradually without breaking existing functionality, so that I can refactor safely while maintaining system stability.) | Pending | - |
| Implement verb service interfaces and configuration system (As a developer, I want verb definitions to be configurable and verb processing to use service interfaces, so that I can add new verbs easily and test interaction logic without full UI dependencies.) | Pending | - |
| Create interaction processing pipeline (validators/processors) (As a developer, I want verb interactions to use a validation and processing pipeline, so that I can add new interaction rules without modifying core logic and handle edge cases consistently.) | Pending | - |
| Refactor verb UI with factory pattern and controller separation (As a developer, I want verb UI creation separated from interaction logic, so that I can test UI behavior independently and support different UI themes without affecting core interaction processing.) | Pending | - |
| Establish verb interaction event bus and signal architecture (As a developer, I want verb system communication to use signals instead of direct method calls, so that I can decouple interaction components and enable extensible event handling for interactions.) | Pending | - |
| Create comprehensive verb interaction unit tests and mocks (As a developer, I want comprehensive unit tests for the verb interaction system, so that I can prevent regressions and validate interaction behavior during refactoring.) | Pending | - |
| Implement progressive verb system migration with adapters (As a developer, I want to migrate the verb system gradually without breaking existing interactions, so that I can refactor safely while maintaining player experience continuity.) | Pending | - |
| Integrate both refactored systems with ServiceRegistry (As a developer, I want both dialog and verb systems to integrate cleanly with the ServiceRegistry, so that all game systems use consistent dependency injection patterns and can be tested in isolation.) | Pending | - |
| Perform comprehensive integration testing (As a developer, I want comprehensive integration testing for both refactored systems, so that I can verify they work together correctly and catch any integration issues before deployment.) | Pending | - |
| Validate 100% functional parity with original systems (As a player, I want all dialog and verb interactions to work exactly as they did before the refactoring, so that my gameplay experience is unaffected by internal system improvements.) | Pending | - |
| Update system documentation for both refactored systems (As a developer, I want updated documentation for both refactored systems, so that I can understand the new architecture and maintain the systems effectively in the future.) | Pending | - |

**Testing Criteria:**
- All existing dialog functionality works identically to pre-refactoring behavior
- All verb+object interactions produce identical responses to original system  
- Dialog system achieves >90% unit test coverage with comprehensive mocks
- Verb UI system achieves >90% unit test coverage with comprehensive mocks
- Zero scene tree dependencies in core dialog and verb processing logic
- Service-based architecture enables isolated component testing
- Signal-based communication eliminates tight coupling between systems
- Error handling provides structured context for all failure scenarios
- Performance matches or exceeds original system response times
- Start date: 2025-05-29
- Target completion: 2025-06-12
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- [Dialog System Refactoring Plan](docs/design/dialog_system_refactoring_plan.md)
- [Verb UI System Refactoring Plan](docs/design/verb_ui_system_refactoring_plan.md)
- [Project Architecture Reference](docs/reference/architecture.md)
- docs/design/dialog_system_refactoring_plan.md
- docs/design/verb_ui_system_refactoring_plan.md
- **⏳ PENDING** (05/22/25)
- **Linked to:** B1, B2, T1, T2
- **Acceptance Criteria:**
- Follow established ServiceRegistry pattern from camera system refactoring
- Create dialog service abstractions that can be mocked for testing
- Implement adapter pattern for gradual migration from legacy system
- **Reference:** See Phase 1 of docs/design/dialog_system_refactoring_plan.md
- **⏳ PENDING** (05/22/25)
- **Linked to:** B1, T1, T3
- **Acceptance Criteria:**
- Extract dialog tree data structures from BaseNPC into dedicated classes
- Create pure functions for text transformation and validation
- Design for extensibility to support future dialog features
- **⏳ PENDING** (05/22/25)
- **Linked to:** B1, B2, T1, T3
- **Acceptance Criteria:**
- Follow validator pattern established in camera system architecture
- Create priority-based validation pipeline for consistent error checking
- Implement comprehensive error context for debugging support

### Iteration 5: Game Districts and Time Management

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
- [ ] Task 2: Create bash script for generating NPC placeholders
- [ ] Task 3: Implement district transitions via tram system
- [ ] Task 4: Develop in-game clock and calendar system
- [ ] Task 5: Create time progression through player actions
- [ ] Task 6: Implement day cycle with sleep mechanics
- [ ] Task 7: Design and implement time UI indicators
- [ ] Task 8: Create system for random NPC assimilation over time
- [ ] Task 9: Add time-based events and triggers
- [ ] Task 10: Implement player bedroom as save point location
- [ ] Task 11: Create single-slot save system with confirmation UI
- [ ] Task 12: Create basic inventory system with size limitations
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time
- Player can save game by returning to their room
- Player has limited inventory space
- NPC placeholder script successfully creates properly structured directories and registry entries
- Multiple NPCs can be easily added across different districts using the script
- Start date: 2025-06-15
- Target completion: 2025-06-29
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- Iteration 4 (Dialog and Verb UI System Refactoring)
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
| Create bash script for generating NPC placeholders (As a developer, I want a bash script that manages the NPC registry and creates appropriate directory structures for NPC sprites, so that I can easily add new characters to the game with proper integration into the existing systems without manual configuration.) | Pending | - |
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
- NPC placeholder script successfully creates properly structured directories and registry entries
- Multiple NPCs can be easily added across different districts using the script
- Start date: 2025-06-15
- Target completion: 2025-06-29
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- Iteration 4 (Dialog and Verb UI System Refactoring)
- No links yet

### Iteration 6: Investigation Mechanics and Inventory

**Goals:**
- Implement investigation mechanics
- Create quest log system for tracking progress
- Develop advanced inventory system for collecting evidence
- Add system for logging known assimilated NPCs
- Implement overflow storage in player's room
- **B2:** Validate game performance on target hardware platform to ensure viability of purpose-built gaming appliance distribution strategy
- **B1:** Implement core investigation mechanics that drive main storyline
- **U2:** As a potential customer, I want assurance that the gaming appliance will run smoothly and provide a premium experience when I receive it
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
- [ ] Task 11: Implement observation mechanics for detecting assimilated NPCs
- [ ] Task 12: Set up Raspberry Pi 5 hardware validation environment
- [ ] Task 13: Conduct POC performance testing on target hardware
- [ ] Task 14: Document hardware requirements and optimization roadmap
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated
- Player can store extra items in their room
- Inventory management creates meaningful gameplay decisions
- Observation mechanics allow players to detect assimilated NPCs
- Different observation intensities reveal appropriate information
- Game runs stably at 30fps on Raspberry Pi 5 hardware
- Complete POC playthrough completes without performance issues
- Hardware validation documentation provides clear optimization roadmap
- Start date: 2025-06-29
- Target completion: 2025-07-13
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- Iteration 4 (Dialog and Verb UI System Refactoring)
- Iteration 5 (Game Districts and Time Management)
- Task 14: [docs/design/hardware_validation_plan.md](docs/design/hardware_validation_plan.md)
- Task 13: [docs/design/hardware_validation_plan.md](docs/design/hardware_validation_plan.md)
- Task 12: [docs/design/hardware_validation_plan.md](docs/design/hardware_validation_plan.md)

**Key Requirements:**
- **B2:** Validate game performance on target hardware platform to ensure viability of purpose-built gaming appliance distribution strategy
- **B1:** Implement core investigation mechanics that drive main storyline
- **U2:** As a potential customer, I want assurance that the gaming appliance will run smoothly and provide a premium experience when I receive it
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
| Implement observation mechanics for detecting assimilated NPCs (As a player, I want to carefully observe NPCs for subtle clues that indicate they have been assimilated, so that I can identify threats and make informed decisions about whom to trust and recruit.) | Pending | - |
| Set up Raspberry Pi 5 hardware validation environment (As a developer, I want to set up a complete Raspberry Pi 5 testing environment, so that I can validate our game's performance on the actual target hardware before committing to the gaming appliance distribution strategy) | Pending | docs/design/hardware_validation_plan.md |
| Conduct POC performance testing on target hardware (As a developer, I want to conduct comprehensive performance testing of the complete POC on Raspberry Pi 5 hardware, so that I can identify any optimization needs and confirm the viability of our gaming appliance approach) | Pending | docs/design/hardware_validation_plan.md |
| Document hardware requirements and optimization roadmap (As a project stakeholder, I want detailed documentation of hardware requirements and performance characteristics, so that I can make informed decisions about manufacturing and distribution of the gaming appliance) | Pending | docs/design/hardware_validation_plan.md |

**Testing Criteria:**
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated
- Player can store extra items in their room
- Inventory management creates meaningful gameplay decisions
- Observation mechanics allow players to detect assimilated NPCs
- Different observation intensities reveal appropriate information
- Game runs stably at 30fps on Raspberry Pi 5 hardware
- Complete POC playthrough completes without performance issues
- Hardware validation documentation provides clear optimization roadmap
- Start date: 2025-06-29
- Target completion: 2025-07-13
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- Iteration 4 (Dialog and Verb UI System Refactoring)
- Iteration 5 (Game Districts and Time Management)
- Task 14: [docs/design/hardware_validation_plan.md](docs/design/hardware_validation_plan.md)
- Task 13: [docs/design/hardware_validation_plan.md](docs/design/hardware_validation_plan.md)
- Task 12: [docs/design/hardware_validation_plan.md](docs/design/hardware_validation_plan.md)
- **✅ COMPLETE** (05/22/25)
- **🔄 IN PROGRESS** (05/22/25)
- **✅ COMPLETE** (05/22/25)
- **⏳ PENDING** (05/22/25)
- **Linked to:** B1, U1
- **Acceptance Criteria:**
- Create a sliding scale of observation intensity with corresponding information reveals
- Design subtle visual cues that fit the game's aesthetic (slight color shifts, animation differences)
- Balance difficulty so observation feels like skilled detective work but not frustratingly obscure
- Link with existing suspicion and NPC state systems from Iteration 2
- **⏳ PENDING** (05/22/25)
- **Linked to:** [List related Epic-level requirements]
- **Acceptance Criteria:**
- [Technical guidance or approach]
- **⏳ PENDING** (05/22/25)
- **Linked to:** [List related Epic-level requirements]
- **Acceptance Criteria:**
- [Technical guidance or approach]

### Iteration 7: Coalition Building

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
- Start date: 2025-07-13
- Target completion: 2025-07-27
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 6 (Investigation Mechanics)
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
- Start date: 2025-07-13
- Target completion: 2025-07-27
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 6 (Investigation Mechanics)
- No links yet

### Iteration 8: Game Progression and Multiple Endings

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
- Start date: 2025-07-27
- Target completion: 2025-08-10
- Iteration 6 (Investigation Mechanics)
- Iteration 7 (Coalition Building)
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
- Start date: 2025-07-27
- Target completion: 2025-08-10
- Iteration 6 (Investigation Mechanics)
- Iteration 7 (Coalition Building)
- No links yet

