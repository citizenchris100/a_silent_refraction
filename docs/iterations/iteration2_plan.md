# Iteration 2: NPC Framework, Suspicion System, and Initial Asset Creation

## Goals
- Implement basic NPCs with interactive capabilities
- Create the suspicion system as a core gameplay mechanic
- Apply visual style guide to one area as a prototype
- Develop placeholder art generation for NPCs

## Requirements

### Business Requirements

- **B5:** Develop a core set of game assets that establish the game's visual identity and support key gameplay mechanics
  - **Rationale:** [Add rationale here]
  - **Success Metric/Constraints:** [Add metric or constraints here]

- **B4:** Establish a suspicion mechanic that creates gameplay tension and drives player decision-making
  - **Rationale:** [Add rationale here]
  - **Success Metric/Constraints:** [Add metric or constraints here]

- **B3:** Create an immersive NPC interaction system that supports narrative and gameplay progression
  - **Rationale:** [Add rationale here]
  - **Success Metric/Constraints:** [Add metric or constraints here]
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
  - **Rationale:** Point-and-click adventures require expansive environments to explore, which necessitates a system for handling backgrounds larger than the visible screen area
  - **Constraints:** Must maintain performance with large image files and integrate seamlessly with walkable area and navigation systems

## Tasks
- [x] Task 1: Create base NPC class with state machine
- [x] Task 2: Implement NPC dialog system
- [x] Task 3: Create suspicion meter UI element
- [x] Task 4: Implement suspicion tracking system
- [x] Task 5: Script NPC reactions based on suspicion levels
- [~] Task 6: Apply visual style guide to Spaceport/Shipping
- [ ] Task 7: Create bash script for generating NPC placeholders
- [ ] Task 8: Implement observation mechanics for detecting assimilated NPCs

### Task 3: Create suspicion meter UI element

**User Story:** As a player, I want to see a visual indicator of my current suspicion level, so that I can make informed decisions about my actions and interactions with NPCs.

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

## Testing Criteria
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly

## Timeline
- Start date: 2025-05-16
- Target completion: 2025-05-30

## Dependencies
- Iteration 1 (Basic Environment and Navigation)

## Code Links
- Task 7: [tools/create_npc_registry.sh](tools/create_npc_registry.sh)

## Notes
Add any additional notes or considerations here.

### Task 6: Apply visual style guide to Spaceport/Shipping

**User Story:** As a player, I want to explore scrolling backgrounds in the Spaceport/Shipping area that extend beyond the screen boundaries, so that I can experience larger, more immersive environments that feel like real spaces rather than confined screens

**Requirements:**
- **Linked to:** B5, T2
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

### Task 7: Create bash script for generating NPC placeholders

**User Story:** As a developer, I want a bash script that manages the NPC registry and creates appropriate directory structures for NPC sprites, so that I can easily add new characters to the game with proper integration into the existing systems without manual configuration.

**Requirements:**
- **Linked to:** B2, B5
- **Acceptance Criteria:**
  1. Script creates proper directory structures for each NPC's sprite states (normal, suspicious, hostile, assimilated)
  2. NPCs are registered in the NPC registry system with default values (not assimilated, normal suspicion level)
  3. NPCs are properly categorized by district/location in the registry
  4. New NPCs can be added with a single command specifying their designation/name and location
  5. Script handles the backend integration with the JSON registry and GDScript access layer
  6. Registry tracks both assimilation status and suspicion level as separate properties
  7. Script prepares the structure for the four different sprite states without placing actual assets

**Implementation Notes:**
- Default NPCs should be initialized in a normal (not assimilated) state with normal suspicion
- Maintain clear separation between assimilation status and suspicion level in the registry
- Ensure the directory structure aligns with the game's asset loading expectations
- Use JSON for data persistence and create a GDScript interface for game access
