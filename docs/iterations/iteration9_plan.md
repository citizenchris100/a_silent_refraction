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
- [ ] Task 33: Create AccessControlManager singleton
- [ ] Task 34: Implement AccessPoint base class and system
- [ ] Task 35: Create access item types (PhysicalKey, Keycard, AccessBadge classes)
- [ ] Task 36: Implement access code system for keypads
- [ ] Task 37: Create access control UI components (keypad, card reader interfaces)
- [ ] Task 38: Implement AccessSerializer for save/load
- [ ] Task 39: Create lost/replacement access system with economy integration

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
**User Story:** As a developer, I need a central detection coordination system with morning report integration, so that all detection sources work together coherently and overnight heat decay is properly reported.

**Design Reference:** `docs/design/suspicion_system_full_design.md` & `docs/design/morning_report_manager_design.md`

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
  6. Reports overnight heat decay to MorningReportManager

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md (DetectionManager design)
- Reference: docs/design/morning_report_manager_design.md lines 197-211 (detection integration)
- Implement as autoload singleton
- Follow detection state machine design
- Coordinate with NPCRegistry
- Handle escape routes calculation
- Call MorningReportManager.add_event() when heat reduces overnight

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

### Task 28: Create access permission system
**User Story:** As a developer, I want a centralized system for managing access permissions throughout the station, so that all access control is consistent and easily maintainable.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2, T1
- **Acceptance Criteria:**
  1. Define access level hierarchy (Guest, Staff, Security, Admin)
  2. Permission checking interface
  3. Area-based access zones
  4. Role-based permissions
  5. Debug visualization of access areas

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Foundation for all access control features
- Consider future expansion for special permissions

### Task 30: Add restricted area warnings
**User Story:** As a player, I want clear visual and audio warnings when approaching restricted areas, so that I don't accidentally trespass and raise suspicion.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Visual warning signs/barriers
  2. Audio cues near restricted zones
  3. UI notification when approaching
  4. Different warning levels
  5. Consistent warning design language

**Implementation Notes:**
- Use Area2D for proximity detection
- Integrate with UI notification system
- Different warnings for different security levels

### Task 31: Create security checkpoint system
**User Story:** As a player, I want to encounter security checkpoints at key locations, so that accessing secure areas feels appropriately challenging and realistic.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Checkpoint scenes with interaction
  2. Guard NPC integration
  3. ID verification process
  4. Queue system for NPCs
  5. Bypass options available

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Place at district boundaries
- Different security levels per checkpoint

### Task 32: Implement access violation consequences
**User Story:** As a player, I want meaningful consequences for access violations, so that security systems feel impactful and I must carefully consider my actions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Suspicion increase on violations
  2. Guard alert system
  3. Temporary lockdowns
  4. Access revocation mechanics
  5. Escalating consequences

**Implementation Notes:**
- Integrate with suspicion system
- Different severity levels
- Some violations trigger immediate response

### Task 33: Create AccessControlManager singleton
**User Story:** As a developer, I want a centralized AccessControlManager to coordinate all access control systems, so that access logic is unified and maintainable.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. Singleton autoload implementation
  2. Access point registry
  3. Player access item tracking
  4. Access validation methods
  5. Signal emission for access events

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Core component managing all access control
- Must integrate with existing managers

### Task 34: Implement AccessPoint base class and system
**User Story:** As a developer, I want a flexible AccessPoint class for doors and barriers, so that I can easily create various locked areas throughout the station.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. Base AccessPoint class extending Area2D
  2. Support multiple access types
  3. Visual state management
  4. Interaction with verb system
  5. Alarm trigger capability

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Extensible for different lock types
- Must work with existing interaction system

### Task 35: Create access item types (PhysicalKey, Keycard, AccessBadge classes)
**User Story:** As a player, I want various types of access items that work differently, so that gaining access feels varied and strategic.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. PhysicalKey class with unique IDs
  2. Keycard with security levels
  3. AccessBadge with visual ID
  4. Item inheritance from ItemData
  5. Validation methods per type
  6. Badge visual matching with disguise system

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Integrate with inventory system
- Support for future item types
- AccessBadge includes owner_photo and matches_wearer() method
- Badge/disguise mismatch triggers suspicion

### Task 36: Implement access code system for keypads
**User Story:** As a player, I want to use keypads with codes to access areas, so that I can gain entry through knowledge rather than items.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Keypad interaction UI
  2. Code validation system
  3. Code discovery mechanics
  4. Failed attempt tracking
  5. Code hint system

**Implementation Notes:**
- Codes can be found in notes/dialog
- Some codes change periodically
- Track player's known codes

### Task 37: Create access control UI components (keypad, card reader interfaces)
**User Story:** As a player, I want intuitive interfaces for different access control methods, so that interacting with security systems feels natural.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Keypad number entry UI
  2. Card reader slot animation
  3. Access denied/granted feedback
  4. Consistent UI design language
  5. Audio feedback integration

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Reusable UI components
- Clear visual feedback for all states

### Task 38: Implement AccessSerializer for save/load
**User Story:** As a player, I want all access states to persist between game sessions, so that my progress with keycards and unlocked doors is maintained.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. Serialize access point states
  2. Save player's access items
  3. Track revoked access
  4. Remember known codes
  5. Version migration support

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Self-register with SaveManager
- Medium priority (60) serialization

### Task 39: Create lost/replacement access system with economy integration
**User Story:** As a player, I want to replace lost keycards for a fee, so that losing access items has consequences but isn't game-ending.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Replacement request interface
  2. Credit cost calculation
  3. Time delay for processing
  4. Security logging of replacements
  5. Higher costs for higher clearance

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Integrate with economy system
- Alternative black market options

### Inventory Investigation Integration
- [ ] Task 40: Create ItemCombiner system
- [ ] Task 41: Implement CombinationData resources
- [ ] Task 42: Build combination discovery mechanics
- [ ] Task 43: Create container search system
- [ ] Task 44: Implement container locking/unlocking
- [ ] Task 45: Add evidence chain system for inventory items
- [ ] Task 46: Create quest item state tracking
- [ ] Task 47: Implement security scanning of inventory
- [ ] Task 48: Add investigation clue items
- [ ] Task 49: Create item-based puzzle mechanics
- [ ] Task 50: Build container interaction with observation system
- [ ] Task 51: Implement hidden item discovery mechanics

### Task 40: Create ItemCombiner system
**User Story:** As a player, I want to combine items in my inventory to create new items or solve puzzles, so that collected items have multiple uses and enable creative problem solving.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. ItemCombiner singleton manages combinations
  2. Bidirectional combination checking
  3. Result items created correctly
  4. Source items consumed/preserved as designed
  5. Combination events trigger appropriately

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 214-236 (ItemCombiner class)
- Reference: docs/design/template_quest_design.md (puzzle combinations)
- Check both item orderings
- Support location-specific combinations
- Trigger events on successful combination

### Task 41: Implement CombinationData resources
**User Story:** As a developer, I want a data-driven system for item combinations, so that designers can easily create new puzzles without code changes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. CombinationData resource type defined
  2. Supports all combination properties
  3. JSON/resource file loading
  4. Validation of combination data
  5. Hot-reload in editor

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 237-249 (CombinationData)
- Properties: item1_id, item2_id, result_id, destroy_sources
- Support trigger_event for quest progression
- Optional location requirements

### Task 42: Build combination discovery mechanics with hint system UI
**User Story:** As a player, I want clear hints about which items might combine with visual feedback in the UI, so that I can experiment intelligently rather than trying random combinations.

**Design Reference:** `docs/design/inventory_system_design.md` lines 712-721 (Combination Hints section)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Visual hints for combinable items (glow effect)
  2. Verb UI shows combination potential
  3. Failed combinations give helpful feedback
  4. Discovery tracking for found combinations
  5. Progressive hint system for stuck players
  6. **"This might combine with something..." tooltip on hover**
  7. **Compatible items highlight when one is selected**
  8. **Combination journal tracks attempted combinations**
  9. **Hint intensity increases based on failed attempts**
  10. **Optional combination recipe book unlockable**

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 712-721 (get_combination_hint method)
- Reference: docs/design/verb_ui_system_refactoring_plan.md (hint display integration)
- "This might combine with something..." hints appear after 3 seconds hover
- Track attempted combinations in Dictionary for progressive hints
- After 3 failed attempts, highlight compatible items faintly
- After 5 failed attempts, show category hints ("Try with a tool...")
- Successful combinations added to recipe journal
- ItemCombiner.get_possible_combinations(item_id) returns hint list
- Visual feedback: soft glow for combinable, pulse for highly compatible
- Consider Investigation skill affecting hint clarity
- Recipe book found in-world provides combination documentation

### Task 43: Create container search system
**User Story:** As a player, I want to search containers throughout the station, so that exploration is rewarded with useful items and clues.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Containers have searchable inventories
  2. Search action takes time
  3. Some containers require tools
  4. Visual/audio feedback on search
  5. Empty containers show appropriate message

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 397-426 (Container System)
- Reference: docs/design/template_interactive_object_design.md (container base)
- Extend InteractiveObject for containers
- Support one-time and respawning containers
- Integrate with investigation system

### Task 44: Implement container locking/unlocking
**User Story:** As a player, I want some containers to be locked, requiring keys or skills to open, so that access to valuable items requires effort or the right tools.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Containers can be locked
  2. Different lock types (key, code, biometric)
  3. Keys/items unlock specific containers
  4. Failed unlock attempts tracked
  5. Some locks can be bypassed

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 403-416 (_try_unlock)
- Reference: docs/design/district_access_control_system_design.md (lock types)
- Support multiple unlock methods
- Track lockpicking attempts
- Some containers alarm on failure

### Task 45: Add evidence chain system for inventory items with visual UI
**User Story:** As a player, I want to collect evidence items that connect to form larger conclusions with clear visual representation, so that investigation feels like solving a real mystery with tangible progress.

**Design Reference:** `docs/design/inventory_system_design.md` lines 467-483 (Evidence Chain System section)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Evidence items marked in inventory with special icon
  2. Connections form automatically when related evidence collected
  3. Conclusions unlock new dialog options and areas
  4. Evidence log tracks all findings chronologically
  5. Visual representation of connections between evidence pieces
  6. **Evidence Chain UI shows node graph of connections**
  7. **Animated lines connect related evidence pieces**
  8. **Completed chains highlighted in different color**
  9. **Hover over connections shows relationship details**
  10. **Export evidence map as investigation report**

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 467-483 (EvidenceChain class)
- Reference: docs/design/investigation_clue_tracking_system_design.md (evidence system integration)
- Auto-connect related evidence using _check_connections() method
- Trigger events on conclusions (e.g., "discovered_smuggling")
- Support red herring evidence that leads nowhere
- Use GraphEdit node for visual evidence map
- Node types: Physical Evidence, Testimony, Documents, Deductions
- Connection strength shown by line thickness
- Click evidence nodes to view detailed information
- Evidence chains persist in investigation journal

### Task 46: Create quest item state tracking
**User Story:** As a developer, I want quest items to maintain custom state data, so that items can change based on player actions and story progression.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Quest items have custom_data Dictionary
  2. State changes persist
  3. State affects item behavior
  4. Integration with quest system
  5. State visualization in UI

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 282-294 (update_quest_item_state)
- Reference: docs/design/template_quest_design.md (quest item integration)
- Custom data per item instance
- Notify quest system of changes
- Support complex state machines

### Task 47: Implement security scanning of inventory
**User Story:** As a security system, I want to scan player inventory at checkpoints, so that carrying contraband has meaningful risks and consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Checkpoints trigger inventory scans
  2. Illegal items detected based on security level
  3. Detection increases suspicion
  4. Some items can be hidden
  5. Scan results affect NPC behavior

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 524-536 (security_scan)
- Reference: docs/design/detection_game_over_system_design.md (checkpoint integration)
- Different security levels detect different items
- Support scan-blocking items
- Integrate with suspicion system

### Task 48: Add investigation clue items
**User Story:** As a player, I want to find clue items that help me understand the mystery, so that careful exploration and inventory management aids my investigation.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Clue items have special properties
  2. Examining clues reveals information
  3. Clues connect to form theories
  4. Some clues are time-sensitive
  5. Clue discovery tracked

**Implementation Notes:**
- Reference: docs/design/investigation_clue_tracking_system_design.md (clue items)
- Reference: docs/design/inventory_system_design.md (quest item properties)
- Clue categories: Physical, Documentary, Digital
- Support partial clues
- Time-sensitive clues degrade

### Task 49: Create item-based puzzle mechanics
**User Story:** As a player, I want to use items from my inventory to solve environmental puzzles, so that collected items feel useful beyond their obvious purposes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Items interact with world objects
  2. Multiple solution paths using different items
  3. Failed attempts provide hints
  4. Puzzle state persists
  5. Rewards for creative solutions

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 692-710 (Puzzle Design)
- Reference: docs/design/template_interactive_object_design.md (puzzle objects)
- Example: keycard fragments puzzle
- Support alternative solutions
- Track puzzle completion methods

### Task 50: Build container interaction with observation system
**User Story:** As a player, I want my observation skills to help me find hidden compartments and secret items, so that careful examination is rewarded.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Observation reveals hidden containers
  2. Higher skill finds more secrets
  3. Visual hints for observant players
  4. Hidden items have better rewards
  5. Discovery tracked in stats

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (container observation)
- Reference: docs/design/inventory_system_design.md (container system)
- Observation skill affects discovery chance
- Hidden compartments in normal containers
- Environmental storytelling through hidden items

### Task 51: Implement hidden item discovery mechanics
**User Story:** As a player, I want to discover hidden items through investigation and observation, so that thorough exploration feels rewarding.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Items can be hidden in scenes
  2. Discovery requires specific actions
  3. Hints available for hidden items
  4. Valuable/unique items hidden
  5. Discovery achievements tracked

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (hidden object detection)
- Reference: docs/design/investigation_clue_tracking_system_design.md (discovery tracking)
- Hide items behind/under objects
- Require specific verbs to find
- Track discovery statistics

## Testing Criteria
- Observation system reveals appropriate details
- Detection states transition correctly through all stages
- Investigation progress saves/loads properly
- Interactive objects respond to all verbs
- Access control prevents/allows appropriately
- AccessControlManager manages all access points correctly
- All access item types function as designed
- Access codes work with proper validation
- UI components provide clear feedback
- Access states persist through save/load
- Lost item replacement system integrates with economy
- Game over sequence triggers correctly
- Save file deletion works as designed
- Assimilation cinematics play properly
- Post-game revelations display correctly
- Detection evidence tracks accurately
- Detection state persists across saves
- DetectionManager coordinates all sources
- Detection triggers fire appropriately
- Item combinations work bidirectionally
- Container search mechanics function properly
- Evidence items connect to form conclusions
- Security scans detect contraband correctly
- Hidden items discoverable through observation
- Quest item states persist and update
- Puzzle mechanics accept multiple solutions
- Investigation clues integrate with inventory
- Container locks work with appropriate keys
- Combination hints display appropriately
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
- src/core/access/access_point.gd (to be created)
- src/resources/access_items.gd (to be created)
- src/ui/access/access_interface.gd (to be created)
- src/ui/access/keypad_interface.gd (to be created)
- src/ui/access/card_reader_interface.gd (to be created)
- src/ui/access/lost_access_ui.gd (to be created)
- src/core/serializers/access_serializer.gd (to be created)
- src/core/systems/item_combiner.gd (to be created)
- src/resources/combination_data.gd (to be created)
- src/core/investigation/evidence_chain.gd (to be created)
- src/objects/base/container.gd (to be created)
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