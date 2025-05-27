# Iteration 9: Core Gameplay Systems

## Epic Description
**Phase**: 2 - Full Systems  
**Cohesive Goal**: "I can observe, investigate, and be detected"

As a player, I need to carefully observe my surroundings for clues about who might be assimilated, investigate suspicious behavior while managing my own actions to avoid detection, creating the core tension that drives the entire game experience.

## Goals
- Implement full Observation System
- Complete Suspicion/Detection System with game over mechanics
- Create Detection Game Over System
- Build Interactive Object Templates
- Implement Investigation Clue Tracking System
- Add District Access Control System
- Establish core investigation gameplay loop

## Requirements

### Business Requirements
- **B1:** Implement core observation and investigation mechanics
  - **Rationale:** Central gameplay loop requires players to observe and investigate
  - **Success Metric:** Players can discover clues and track investigation progress

- **B2:** Create tension through detection and access control systems
  - **Rationale:** Risk/reward mechanics enhance player engagement
  - **Success Metric:** Players report feeling tension when accessing restricted areas

- **B3:** Establish reusable interaction patterns
  - **Rationale:** Template system accelerates content creation
  - **Success Metric:** New interactive objects created in <30 minutes

### User Requirements
- **U1:** As a player, I want to observe and investigate my surroundings
  - **User Value:** Detective gameplay provides intellectual satisfaction
  - **Acceptance Criteria:** Can discover clues through observation and track investigations

- **U2:** As a player, I want tension when accessing restricted areas
  - **User Value:** Risk/reward mechanics create excitement
  - **Acceptance Criteria:** Detection system creates meaningful consequences

- **U3:** As a player, I want to track my investigation progress
  - **User Value:** Clear goals and sense of advancement
  - **Acceptance Criteria:** Investigation log shows discovered clues and connections

### Technical Requirements
- **T1:** Create modular observation system
  - **Rationale:** Many objects and NPCs need observable properties
  - **Constraints:** Must not impact performance with many observables

- **T2:** Implement detection state machine
  - **Rationale:** Complex detection states need clear transitions
  - **Constraints:** Must integrate with existing NPC state machines

- **T3:** Design flexible clue system
  - **Rationale:** Various clue types and combinations needed
  - **Constraints:** Must support save/load of investigation state

## Tasks

### Observation System
- [ ] Task 1: Create ObservationManager singleton
- [ ] Task 2: Implement observable properties system
- [ ] Task 3: Create observation UI interface
- [ ] Task 4: Add observation skill progression
- [ ] Task 5: Implement observation notifications

### Detection and Suspicion
- [ ] Task 6: Expand suspicion system to full implementation
- [ ] Task 7: Create detection state machine
- [ ] Task 8: Implement line-of-sight detection
- [ ] Task 9: Add detection UI warnings
- [ ] Task 10: Create game over sequence

### Investigation System
- [ ] Task 11: Create InvestigationManager singleton
- [ ] Task 12: Implement clue discovery mechanics
- [ ] Task 13: Build clue connection system
- [ ] Task 14: Create investigation journal UI
- [ ] Task 15: Add investigation progress tracking

### Interactive Object Templates
- [ ] Task 16: Create BaseInteractiveObject class
- [ ] Task 17: Implement standard interaction verbs
- [ ] Task 18: Create object state system
- [ ] Task 19: Add interaction feedback system
- [ ] Task 20: Build object template library

### District Access Control
- [ ] Task 21: Create access permission system
- [ ] Task 22: Implement keycard/credential mechanics
- [ ] Task 23: Add restricted area warnings
- [ ] Task 24: Create security checkpoint system
- [ ] Task 25: Implement access violation consequences

## User Stories

### Task 2: Implement observable properties system
**User Story:** As a player, I want to examine objects and NPCs for subtle details, so that I can gather clues about the assimilation threat.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Objects have observable properties list
  2. Properties revealed based on observation skill
  3. Some properties only visible under conditions
  4. Observations logged for later review
  5. Visual feedback when discovering properties

**Implementation Notes:**
- Properties: appearance, behavior, recent_changes, hidden_details
- Skill levels: Novice (1-2 props), Skilled (3-4), Expert (all)
- Reference: docs/design/observation_system_full_design.md
- Consider highlighting observable areas

### Task 7: Create detection state machine
**User Story:** As a guard NPC, I need to detect and respond to suspicious player behavior, so that restricted areas remain secure and the player faces consequences for reckless actions.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. States: UNAWARE, ALERT, INVESTIGATING, PURSUING, HOSTILE
  2. Clear visual indicators for each state
  3. State transitions based on player actions
  4. Different NPCs have different detection sensitivity
  5. States persist appropriately

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md
- Reference: docs/design/detection_game_over_system_design.md
- Use state pattern for clean implementation
- Consider "heat" cooldown mechanic

### Task 12: Implement clue discovery mechanics
**User Story:** As a player, I want to discover clues through various investigation methods, so that I can piece together the mystery of the assimilation.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3, T3
- **Acceptance Criteria:**
  1. Clues found through observation, dialog, items
  2. Clues have categories and importance levels
  3. Some clues only available at certain times
  4. Discovery provides satisfying feedback
  5. Clues connect to form theories

**Implementation Notes:**
- Clue types: Physical, Behavioral, Testimonial, Documentary
- Reference: docs/design/investigation_clue_tracking_system_design.md
- Use graph structure for clue connections
- Consider red herrings for complexity

### Task 22: Implement keycard/credential mechanics
**User Story:** As a player, I want to gain access to restricted areas through various means, so that I can investigate deeper into the station's mysteries.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Different access levels (Guest, Staff, Security, Admin)
  2. Cards can be found, stolen, or forged
  3. Biometric locks for high security
  4. Temporary passes with time limits
  5. Access logs track usage

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Integrate with inventory system
- Consider social engineering options
- Access violations increase suspicion

## Testing Criteria
- Observation system reveals appropriate details
- Detection states transition correctly
- Investigation progress saves/loads properly
- Interactive objects respond to all verbs
- Access control prevents/allows appropriately
- Game over sequence triggers correctly
- Performance remains smooth with many observables
- All systems integrate with existing mechanics

## Timeline
- Start date: After Phase 1 completion
- Target completion: 2-3 weeks
- Critical for: Core gameplay establishment

## Dependencies
- Phase 1 complete (Iterations 1-8)
- Particularly: NPC system, Save system, Districts

## Code Links
- src/core/observation/observation_manager.gd (to be created)
- src/core/detection/detection_state_machine.gd (to be created)
- src/core/investigation/investigation_manager.gd (to be created)
- src/objects/base/base_interactive_object.gd (to be refactored)
- src/core/access/access_control_manager.gd (to be created)
- docs/design/observation_system_full_design.md
- docs/design/suspicion_system_full_design.md
- docs/design/detection_game_over_system_design.md
- docs/design/investigation_clue_tracking_system_design.md
- docs/design/district_access_control_system_design.md
- docs/design/template_interactive_object_design.md

## Notes
- This iteration establishes the core investigation loop
- Detection system must be balanced - challenging but fair
- Investigation should reward careful observation
- Access control adds strategic layer to exploration
- These systems form the heart of the gameplay experience