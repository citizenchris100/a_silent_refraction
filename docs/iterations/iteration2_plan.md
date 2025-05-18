# Iteration 2: NPC Framework and Suspicion System

## Goals
- Implement basic NPCs with interactive capabilities
- Create the suspicion system as a core gameplay mechanic
- Apply visual style guide to one area as a prototype
- Develop placeholder art generation for NPCs

## Requirements

### Business Requirements
- **B1:** Establish core game mechanic of NPC suspicion to drive gameplay tension
  - **Rationale:** The suspicion mechanic is a central selling point and distinguishing feature of the game
  - **Success Metric:** Playtesters report feeling tension when suspicion rises, measured via satisfaction surveys

- **B2:** Create reusable NPC framework to streamline future character development
  - **Rationale:** Efficient character creation will accelerate development of future game areas
  - **Success Metric:** New NPCs can be created and integrated within 2 hours or less

### User Requirements
- **U1:** As a player, I want to observe subtle cues that help identify assimilated NPCs
  - **User Value:** Creates engaging gameplay through detective-like observation
  - **Acceptance Criteria:** Multiple visual cues exist that are subtle but detectable with close observation

- **U2:** As a player, I want to track my suspicion level with accessible UI
  - **User Value:** Provides immediate feedback on risky actions
  - **Acceptance Criteria:** Suspicion meter visibly reacts to player actions in real-time

- **U3:** As a player, I want NPCs to feel distinct through dialog and behavior
  - **User Value:** Creates an immersive world with memorable characters
  - **Acceptance Criteria:** NPCs have unique dialog patterns and state-based behavioral differences

### Technical Requirements (Optional)
- **T1:** Create extensible NPC state machine system
  - **Rationale:** State-based behavior is core to the NPC system
  - **Constraints:** Must support at least 4 emotional states and assimilation status

- **T2:** Implement a scrolling background system that enables environments larger than the game window
  - **Rationale:** Point-and-click adventures require expansive environments to explore
  - **Constraints:** Must maintain performance with large image files and integrate with navigation systems

## Tasks
- [x] Task 1: Create base NPC class with state machine
- [x] Task 2: Implement NPC dialog system
- [x] Task 3: Create suspicion meter UI element
- [x] Task 4: Implement suspicion tracking system
- [x] Task 5: Script NPC reactions based on suspicion levels
- [x] Task 6: Apply visual style guide to Shipping District

### Task 1: Create base NPC class with state machine

**User Story:** As a developer, I want a flexible, reusable NPC base class with a state machine, so that I can efficiently create interactive characters with consistent behavior patterns.

**Status History:**
- **⏳ PENDING** (05/05/25)
- **🔄 IN PROGRESS** (05/06/25)
- **✅ COMPLETE** (05/07/25)

**Requirements:**
- **Linked to:** B2, U3, T1
- **Acceptance Criteria:**
  1. NPC base class can be easily extended for different character types
  2. State machine supports at least 4 emotional states (normal, suspicious, hostile, assimilated)
  3. States trigger appropriate visual and behavioral changes
  4. Transitions between states are smooth and logical
  5. NPCs can be placed and configured in scenes easily

**Implementation Notes:**
- Implement state pattern for NPC behavior
- Create clean interface for state transitions
- Ensure states persist correctly between scene loads
- Use signals for state change communication

### Task 2: Implement NPC dialog system

**User Story:** As a player, I want to engage in dialog with NPCs that feels unique to each character, so that I can build a mental model of each personality and detect when they might be assimilated.

**Status History:**
- **⏳ PENDING** (05/06/25)
- **🔄 IN PROGRESS** (05/07/25)
- **✅ COMPLETE** (05/08/25)

**Requirements:**
- **Linked to:** B1, B2, U1, U3
- **Acceptance Criteria:**
  1. Dialog system supports branching conversations
  2. NPC responses vary based on state (normal, suspicious, hostile, assimilated)
  3. Dialog trees can be defined in external files for easy editing
  4. System supports player dialog choices
  5. Dialog influences suspicion level appropriately

**Implementation Notes:**
- Create JSON-based dialog definition format
- Build dialog UI with character portraits
- Implement dialog state machine
- Connect dialog choices to suspicion system

### Task 3: Create suspicion meter UI element

**User Story:** As a player, I want to see a visual indicator of my current suspicion level, so that I can make informed decisions about my actions and interactions with NPCs.

**Status History:**
- **⏳ PENDING** (05/07/25)
- **🔄 IN PROGRESS** (05/08/25)
- **✅ COMPLETE** (05/08/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Suspicion meter is clearly visible in the game UI
  2. Meter visually changes as suspicion level increases/decreases
  3. Critical thresholds are visually distinct (safe, caution, danger)
  4. Meter updates in real-time when player performs suspicious actions
  5. Visual design matches the game's dystopian sci-fi aesthetic

**Implementation Notes:**
- Use ProgressBar node as the base for the meter implementation
- Consider shader effects for visual polish (glowing, pulsing at high suspicion)
- Integrate with the global_suspicion_manager.gd for data binding

### Task 4: Implement suspicion tracking system

**User Story:** As a developer, I want a centralized system for tracking and managing NPC suspicion levels, so that player actions have consistent and predictable effects on the game state.

**Status History:**
- **⏳ PENDING** (05/08/25)
- **🔄 IN PROGRESS** (05/09/25)
- **✅ COMPLETE** (05/09/25)

**Requirements:**
- **Linked to:** B1, U1, U2
- **Acceptance Criteria:**
  1. Suspicion levels are tracked globally and per-NPC
  2. System defines actions that increase/decrease suspicion
  3. Suspicion changes trigger appropriate NPC state transitions
  4. System provides API for game events to modify suspicion
  5. Suspicion decay occurs over time when not performing suspicious actions

**Implementation Notes:**
- Implement singleton pattern for global suspicion tracking
- Create weighted action dictionary for different suspicious behaviors
- Implement per-NPC suspicion tracking for more nuanced gameplay
- Use signals to notify UI and NPCs of suspicion changes

### Task 5: Script NPC reactions based on suspicion levels

**User Story:** As a player, I want NPCs to react realistically to suspicious behavior, so that the game provides natural feedback and consequences for my actions.

**Status History:**
- **⏳ PENDING** (05/09/25)
- **🔄 IN PROGRESS** (05/10/25)
- **✅ COMPLETE** (05/11/25)

**Requirements:**
- **Linked to:** B1, U1, U3, T1
- **Acceptance Criteria:**
  1. NPCs transition between states based on suspicion levels
  2. Each state has distinct dialog and behavior patterns
  3. High suspicion triggers appropriate consequences (hostile NPCs, limited access)
  4. NPC reactions feel natural and proportional to player actions
  5. Different NPC types have varying tolerance for suspicious behavior

**Implementation Notes:**
- Connect suspicion manager signals to NPC state machine
- Define suspicion thresholds for state transitions
- Create varied response patterns for different NPC types
- Implement behavioral changes (following player, alerting others) for suspicious and hostile states

### Task 6: Apply visual style guide to Shipping District

**User Story:** As a player, I want to explore scrolling backgrounds in the Shipping District that extend beyond the screen boundaries, so that I can experience larger, more immersive environments that feel like real spaces.

**Status History:**
- **⏳ PENDING** (05/11/25)
- **🔄 IN PROGRESS** (05/12/25)
- **✅ COMPLETE** (05/15/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Background image loads properly and extends beyond screen boundaries
  2. Scene can designate starting position (left, middle, right) within the background
  3. Walkable areas are properly defined across the entire background
  4. Camera smoothly scrolls to follow player when approaching screen boundaries
  5. Player movement remains consistent across screen transitions
  6. Visual style follows the game's aesthetic guidelines

**Implementation Notes:**
- Implement a background manager that handles large image loading
- Create a scrolling camera system that tracks player position
- Integrate with existing walkable area system
- Ensure performance optimization for large background images

## Testing Criteria
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly

## Timeline
- Start date: 2025-05-11
- Target completion: 2025-05-17

## Dependencies
- Iteration 1 (Basic Environment and Navigation)

## Code Links
- Task 1: [src/characters/npc/base_npc.gd](src/characters/npc/base_npc.gd)
- Task 3: [src/ui/suspicion_meter/global_suspicion_meter.gd](src/ui/suspicion_meter/global_suspicion_meter.gd)
- Task 6: [src/core/camera/scrolling_camera.gd](src/core/camera/scrolling_camera.gd)

## Notes
Iteration 2 adds the core NPC and suspicion systems that form the foundation of the game's key mechanics. These systems provide the tension and strategic decision-making that will drive the gameplay loop.