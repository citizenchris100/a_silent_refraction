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

## Tasks
- [ ] Task 1: Create base NPC class with state machine
- [ ] Task 2: Implement NPC dialog system
- [ ] Task 3: Create suspicion meter UI element
- [ ] Task 4: Implement suspicion tracking system
- [ ] Task 5: Script NPC reactions based on suspicion levels
- [ ] Task 6: Apply visual style guide to Shipping District
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
- No links yet

## Notes
Add any additional notes or considerations here.
