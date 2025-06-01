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
- [ ] Task 11: Implement save file deletion on game over
- [ ] Task 12: Create assimilation ending cinematics
- [ ] Task 13: Build post-game revelation system
- [ ] Task 14: Add detection state serialization
- [ ] Task 15: Create DetectionManager singleton
- [ ] Task 16: Implement detection triggers system
- [ ] Task 17: Add detection evidence tracking

### Investigation System
- [ ] Task 18: Create InvestigationManager singleton
- [ ] Task 19: Implement clue discovery mechanics
- [ ] Task 20: Build clue connection system
- [ ] Task 21: Create investigation journal UI
- [ ] Task 22: Add investigation progress tracking

### Interactive Object Templates
- [ ] Task 23: Create BaseInteractiveObject class
- [ ] Task 24: Implement standard interaction verbs
- [ ] Task 25: Create object state system
- [ ] Task 26: Add interaction feedback system
- [ ] Task 27: Build object template library

### District Access Control
- [ ] Task 28: Create access permission system
- [ ] Task 29: Implement keycard/credential mechanics
- [ ] Task 30: Add restricted area warnings
- [ ] Task 31: Create security checkpoint system
- [ ] Task 32: Implement access violation consequences

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

### Task 10: Create game over sequence
**User Story:** As a player, I want a dramatic and informative game over sequence when I'm caught, so that I understand what went wrong and feel motivated to try again.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. Game over triggers when detection reaches CAPTURING stage
  2. Cinematic sequence shows assimilation process
  3. Player receives feedback on what led to detection
  4. Save file is handled according to design
  5. Smooth transition back to main menu

**Implementation Notes:**
- Reference: docs/design/detection_game_over_system_design.md
- Integrate with GameOverManager class
- Must feel consequential but fair

### Task 11: Implement save file deletion on game over
**User Story:** As a game designer, I want permanent consequences for failure through save deletion, so that players feel genuine tension and every decision matters.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Save file is deleted upon assimilation
  2. Clear warning shown before deletion
  3. Confirmation message after deletion
  4. Graceful handling of permission errors
  5. No way to recover deleted save

**Implementation Notes:**
- Show 5-second warning before deletion
- Create .assimilated backup temporarily
- Document cloud save incompatibility
- Reference brutal save deletion section in design

### Task 12: Create assimilation ending cinematics
**User Story:** As a player, I want to see a haunting visualization of my character's assimilation, so that the consequence of failure is emotionally impactful.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Contextual dialog from assimilator
  2. Visual transformation sequence
  3. Consciousness fading effect
  4. Different variations based on who caught player
  5. Appropriate audio and visual effects

**Implementation Notes:**
- Create AssimilationEnding scene
- Support multiple assimilator contexts
- Use shader effects for transformation
- Keep it disturbing but not gratuitous

### Task 13: Build post-game revelation system
**User Story:** As a player, I want to see what I missed after game over, so that I can learn for my next playthrough.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Shows total assimilated count
  2. Reveals hidden leaders
  3. Lists missed coalition members
  4. Shows unsolved mysteries
  5. Displays progress percentage

**Implementation Notes:**
- Create PostGameRevelations UI
- Calculate investigation progress
- Show statistics attractively
- Motivate replay without spoiling everything

### Task 14: Add detection state serialization
**User Story:** As a player, I want detection states to persist across saves, so that I can't exploit save/load to escape consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T2, T3
- **Acceptance Criteria:**
  1. All detection states save properly
  2. Evidence tracking persists
  3. Alerted NPC lists maintained
  4. Pursuit timers resume correctly
  5. Heat levels persist between sessions

**Implementation Notes:**
- Create DetectionSerializer class
- Self-register with SaveManager
- High priority (20) for critical state
- Handle version migration

### Task 15: Create DetectionManager singleton
**User Story:** As a developer, I need a central detection coordination system, so that all detection sources work together coherently.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Singleton manages all detection states
  2. Coordinates multiple detection sources
  3. Handles state transitions smoothly
  4. Emits appropriate signals
  5. Integrates with existing systems

**Implementation Notes:**
- Implement as autoload singleton
- Follow detection state machine design
- Coordinate with NPCRegistry
- Handle escape routes calculation

### Task 16: Implement detection triggers system
**User Story:** As a player, I want my suspicious actions to have consequences, so that I must be careful about what I say and do.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Dialog choices can trigger detection
  2. Restricted area entry detected
  3. Suspicious items cause alerts
  4. Different severity levels
  5. Context-sensitive triggers

**Implementation Notes:**
- Create detection_triggers.gd
- Define DETECTION_REASONS dictionary
- Check dialog for keywords
- Integrate with area system

### Task 17: Add detection evidence tracking
**User Story:** As a player, I want to understand what gave me away during detection, so that I can learn from my mistakes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. System tracks what triggered detection
  2. Evidence includes time and location
  3. Shows which NPC detected what
  4. Evidence used in game over sequence
  5. Clear cause and effect relationship

**Implementation Notes:**
- Store evidence in dictionary
- Include in serialization
- Display in post-game revelations
- Help players understand mistakes

### Task 19: Implement clue discovery mechanics
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

### Task 29: Implement keycard/credential mechanics
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

### Task 23: Create BaseInteractiveObject class
**User Story:** As a developer, I want a robust base class for all interactive objects, so that I can quickly create consistent interactable items throughout the game world.

**Interactive Object Migration Phase 2a-2b:** This task implements the interaction area system and item combination support.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. Base class supports all SCUMM verbs
  2. Consistent interaction patterns
  3. State persistence built-in
  4. Visual feedback support
  5. Easy to extend for specific objects
  6. **Phase 2a:** Interaction area with mouse detection
  7. **Phase 2b:** Item combination system

**Implementation Notes:**
- Refactor existing interactive_object.gd
- Reference: docs/design/template_interactive_object_design.md
- **Phase 2a:** Add interaction area:
  ```gdscript
  var interaction_area: Area2D
  func _setup_interaction_area()
  func _on_mouse_entered()
  func _on_mouse_exited()
  ```
- **Phase 2b:** Add item combination:
  ```gdscript
  func interact(verb: String, item = null)
  var item_combinations: Dictionary = {}
  func _get_item_combination_response(item: String)
  ```

### Task 25: Create object state system
**User Story:** As a player, I want objects to have persistent states that change based on my interactions, so that the game world feels responsive and dynamic.

**Interactive Object Migration Phase 3a-3b:** This task implements the full state machine system with transitions and state-based responses.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Objects can have multiple named states
  2. States transition based on interactions
  3. Each state has unique properties
  4. States persist across saves
  5. Visual changes per state
  6. **Phase 3a:** Full state machine implementation
  7. **Phase 3b:** State-based responses and visuals

**Implementation Notes:**
- State examples: locked/unlocked, open/closed, on/off, broken/functional
- **Phase 3a:** Implement state system:
  ```gdscript
  export var states: Dictionary = {}
  export var initial_state: String = "default"
  var current_state: String
  func change_state(new_state: String)
  func _apply_state(state_name: String)
  ```
- **Phase 3b:** State-based responses:
  ```gdscript
  export var state_sprites: Dictionary = {}
  export var interaction_responses: Dictionary = {}
  func _get_interaction_response(verb: String, item = null)
  ```

### Task 27: Build object template library
**User Story:** As a content creator, I want a library of pre-built object templates, so that I can quickly populate game scenes with interactive elements.

**Interactive Object Migration Phase 4:** This task adds advanced features like audio, particles, and environmental effects.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Common object types templated
  2. Easy customization of templates
  3. Documentation for each template
  4. Example implementations
  5. Performance optimized
  6. **Phase 4:** Particle and lighting effects

**Implementation Notes:**
- Template types: doors, containers, machines, terminals, switches
- **Phase 4:** Add environmental features:
  ```gdscript
  export var particle_effects: Dictionary = {}
  export var light_states: Dictionary = {}
  var particle_system: CPUParticles2D
  var dynamic_light: Light2D
  ```
- Create prefab scenes for common objects
- Include usage examples in documentation

## Testing Criteria
- Observation system reveals appropriate details
- Detection states transition correctly through all stages
- Investigation progress saves/loads properly
- Interactive objects respond to all verbs
- Access control prevents/allows appropriately
- Game over sequence triggers correctly
- Save file deletion works as designed
- Assimilation cinematics play properly
- Post-game revelations display correctly
- Detection evidence tracks accurately
- Detection state persists across saves
- DetectionManager coordinates all sources
- Detection triggers fire appropriately
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
- src/core/detection/detection_manager.gd (to be created)
- src/core/detection/detection_triggers.gd (to be created)
- src/core/systems/game_over_manager.gd (to be created)
- src/core/serializers/detection_serializer.gd (to be created)
- src/ui/game_over/assimilation_ending.tscn (to be created)
- src/ui/game_over/post_game_revelations.gd (to be created)
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