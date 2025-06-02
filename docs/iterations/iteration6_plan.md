# Iteration 6: Dialog and Character Systems

## Epic Description
**Phase**: 1 - MVP Foundation  
**Cohesive Goal**: "I can create my character and interact through dialog"

As a player, I want to create a character that represents me in the game world and engage in meaningful conversations with NPCs using the classic SCUMM verb-based interaction system.

## Goals
- Implement Character Gender Selection system
- Refactor Dialog System to be gender-aware
- Implement Verb UI System for SCUMM-style interactions
- Create Main Menu and Start Game UI
- Integrate all systems with existing serialization and notification systems

## Requirements

### Business Requirements
- **B1:** Create inclusive character creation experience
  - **Rationale:** Player identification with their character increases engagement
  - **Success Metric:** Character creation takes <2 minutes with clear options

- **B2:** Establish iconic SCUMM-style interaction system
  - **Rationale:** Classic adventure game UI creates nostalgic appeal
  - **Success Metric:** Players intuitively understand verb-based interactions

- **B3:** Ensure dialog system supports narrative complexity
  - **Rationale:** Rich dialog trees are core to the investigation gameplay
  - **Success Metric:** Dialog system supports 5+ level deep conversations

### User Requirements
- **U1:** As a player, I want to choose my character's gender
  - **User Value:** Personal representation in the game world
  - **Acceptance Criteria:** Can select male/female/non-binary with appropriate pronouns

- **U2:** As a player, I want to interact using familiar adventure game verbs
  - **User Value:** Intuitive interaction system reduces learning curve
  - **Acceptance Criteria:** 9 verbs clearly displayed and functional

- **U3:** As a player, I want engaging conversations with NPCs
  - **User Value:** Dialog drives story and investigation forward
  - **Acceptance Criteria:** Conversations feel natural with multiple choice options

### Technical Requirements
- **T1:** Implement pronoun system throughout codebase
  - **Rationale:** Gender-aware text requires systematic pronoun handling
  - **Constraints:** Must work with all existing and future dialog

- **T2:** Create extensible verb processing system
  - **Rationale:** New verbs may be added in future iterations
  - **Constraints:** Must integrate with existing interaction system

- **T3:** Refactor dialog system for maintainability
  - **Rationale:** Current system has architectural violations
  - **Constraints:** Must maintain backwards compatibility

## Tasks

### Character Creation System
- [ ] Task 1: Create character creation UI screen
- [ ] Task 2: Implement gender selection with preview
- [ ] Task 3: Create pronoun system (he/she/they)
- [ ] Task 4: Implement character data persistence
- [ ] Task 5: Integrate with main menu flow

### Dialog System Refactoring
- [ ] Task 6: Refactor dialog system architecture
- [ ] Task 7: Implement gender-aware text substitution
- [ ] Task 8: Create dialog tree editor improvements
- [ ] Task 9: Add dialog history/log system
- [ ] Task 10: Integrate with notification system

### Verb UI Implementation
- [ ] Task 11: Create verb UI panel with 9 verbs
- [ ] Task 12: Implement verb highlighting on hover
- [ ] Task 13: Create verb-object interaction system
- [ ] Task 14: Add verb shortcuts/hotkeys
- [ ] Task 15: Implement context-sensitive verb availability

### Main Menu System
- [ ] Task 16: Create title screen with minimalist UI layout
- [ ] Task 17: Implement save file detection and load button states
- [ ] Task 18: Create save overwrite warning dialog system
- [ ] Task 19: Build gender selection screen with radio buttons
- [ ] Task 20: Implement prologue scrolling text system
- [ ] Task 21: Create new game initialization sequence
- [ ] Task 22: Implement direct load functionality (no UI)
- [ ] Task 23: Add atmospheric effects and CRT shader
- [ ] Task 24: Create error handling for failed loads
- [ ] Task 25: Integrate with existing game systems

### Dialog Architecture Refactoring
- [ ] Task 26: Implement ServiceRegistry singleton pattern
- [ ] Task 27: Create IDialogService interface and DialogService
- [ ] Task 28: Extract DialogData and dialog state classes
- [ ] Task 29: Implement DialogUIFactory for UI separation
- [ ] Task 30: Create NPCDialogController for dialog logic
- [ ] Task 31: Implement DialogEventBus for signal architecture
- [ ] Task 32: Create DialogValidator and error handling
- [ ] Task 33: Build dialog testing infrastructure with mocks
- [ ] Task 34: Implement LegacyDialogAdapter for migration
- [ ] Task 35: Add feature flags for progressive rollout

### UI Consolidation
- [ ] Task 36: Migrate Sleep system dialogs to PromptNotificationSystem
- [ ] Task 37: Migrate Save system dialogs to PromptNotificationSystem
- [ ] Task 38: Migrate Detection system dialogs to PromptNotificationSystem
- [ ] Task 39: Create MorningReportManager for centralized reports
- [ ] Task 40: Remove all redundant dialog implementations

## User Stories

### Task 1: Create character creation UI screen
**User Story:** As a player, I want a clean and intuitive character creation interface, so that I can customize my character without confusion or frustration.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Clean UI layout with clear sections
  2. Navigation between creation steps
  3. Preview area shows character
  4. Confirm/back buttons clearly labeled
  5. Integrates with main menu flow

**Implementation Notes:**
- Reference: docs/design/character_gender_selection_system.md (UI requirements)
- Reference: docs/design/main_menu_start_game_ui_design.md (UI style guide)
- Use consistent UI style with rest of game
- Consider accessibility for all options
- Include help text for choices
- Preview updates in real-time

### Task 2: Implement gender selection with preview
**User Story:** As a player, I want to see how my character choice affects the game, so that I can make an informed decision about my character's gender.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Three options clearly presented: Male, Female, Non-binary
  2. Character sprite preview updates based on selection
  3. Example dialog shows pronoun usage
  4. Selection can be changed before confirming
  5. Choice persists through game sessions

**Implementation Notes:**
- Reference: docs/design/character_gender_selection_system.md lines 30-85 (implementation)
- Reference: docs/design/main_menu_start_game_ui_design.md (gender selection screen)
- Use character portraits for preview
- Show example: "They walked into the room" with proper pronoun
- Store selection in GameState singleton

### Task 3: Create pronoun system (he/she/they)
**User Story:** As a player, I want the game to use my chosen pronouns consistently throughout all text, so that I feel properly represented in the game world.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, U1
- **Acceptance Criteria:**
  1. Pronoun sets defined for all genders
  2. Subject/object/possessive forms supported
  3. Pronoun substitution works globally
  4. Capitalization handled correctly
  5. Plural forms work for non-binary

**Implementation Notes:**
- Reference: docs/design/character_gender_selection_system.md lines 86-120 (pronoun system)
- Reference: docs/design/dialog_system_refactoring_plan.md (text substitution)
- Create PronounManager singleton
- Support: he/him/his, she/her/hers, they/them/theirs
- Handle grammatical number agreement
- Test with all existing dialog

### Task 4: Implement character data persistence
**User Story:** As a player, I want my character choices to be saved with my game, so that I don't have to recreate my character every time I play.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Character data saves to file
  2. Gender selection preserved
  3. Character name saved (future)
  4. Integrates with save system
  5. Loads correctly on game start

**Implementation Notes:**
- Reference: docs/design/character_gender_selection_system.md lines 176-200 (persistence)
- Reference: docs/design/modular_serialization_architecture.md (data persistence)
- Store in GameData singleton
- Include in serialization system
- Prepare for future customization options
- Handle missing/corrupt data gracefully

### Task 5: Integrate with main menu flow
**User Story:** As a player, I want character creation to flow smoothly from the main menu, so that starting a new game feels seamless and polished.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. New Game leads to character creation
  2. Can return to main menu
  3. Creation completes to game start
  4. Save created after character creation
  5. Skip option for returning players

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md (flow design)
- Reference: docs/design/character_gender_selection_system.md (integration)
- Scene transition management
- Prevent accidental back navigation
- Auto-save after creation
- Clear flow indicators

### Task 7: Implement gender-aware text substitution
**User Story:** As a player, I want all game text to use the correct pronouns for my character, so that the narrative feels personalized to my choices.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1, U1
- **Acceptance Criteria:**
  1. Dialog system supports {pronoun} tags
  2. Automatic substitution based on player gender
  3. Supports subject/object/possessive forms
  4. Works in all languages (future localization)
  5. No hardcoded gender assumptions

**Implementation Notes:**
- Tags: {they}, {them}, {their}, {theirs}, {themselves}
- Create PronounManager for centralized handling
- Test with all existing dialog content
- Reference: docs/design/dialog_system_refactoring_plan.md

### Task 11: Create verb UI panel with 9 verbs
**User Story:** As a player, I want to see all available actions clearly displayed, so that I know what interactions are possible in the game.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. 9 verbs in 3x3 grid: Look, Talk, Use, Open, Close, Push, Pull, Give, Take
  2. Verbs highlight on mouse hover
  3. Selected verb shows different visual state
  4. Verb panel always visible during gameplay
  5. Responsive to different screen sizes

**Implementation Notes:**
- Reference: docs/design/verb_ui_system_refactoring_plan.md
- Use retro pixel font for authenticity
- Color scheme matches game aesthetic
- Consider tooltip descriptions for verbs

### Task 12: Implement comprehensive verb hover text and highlighting system with inventory integration
**User Story:** As a player, I want rich hover feedback on verbs that shows me exactly what action I'm about to perform, including inventory item interactions and combination hints, so that I can make informed interaction choices and understand the classic adventure game interface.

**Design Reference:** `docs/design/scumm_hover_text_system_design.md`, `docs/design/verb_ui_system_refactoring_plan.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. **Verb Highlighting:** Verbs highlight visually when hovered (color, glow, or outline effect)
  2. **Verb-Object Integration:** Selected verb + hovered object shows "Verb Object" format in hover text
  3. **Context Hints:** Hover text shows appropriate prepositions ("Look at", "Talk to", "Use", etc.)
  4. **State Feedback:** Unavailable verb combinations show helpful feedback ("Can't talk to that")
  5. **Tooltip Descriptions:** Optional tooltips explain what each verb does for new players
  6. **Visual Polish:** Smooth hover transitions and consistent styling with game aesthetic
  7. **Enhanced Inventory Integration:** Verb system shows inventory item interaction descriptions
  8. **Item Combination Preview:** Hover text shows potential item combinations with verb context
  9. **Contextual Item Interaction:** "Use item with object" shows helpful guidance in hover text

**Implementation Notes:**
- Reference: docs/design/scumm_hover_text_system_design.md (Verb Integration, Inventory Integration sections)
- Reference: docs/design/verb_ui_system_refactoring_plan.md (hover behavior)
- Reference: docs/design/inventory_system_design.md (item combination hints)
- Integrate with main hover text system from Iteration 8
- Connect to verb selection state management
- Implement VerbHoverHandler class for verb-specific hover behavior:
  ```gdscript
  class_name VerbHoverHandler extends Node
  func get_verb_hover_text(verb: String, target: Node = null) -> String
  func get_verb_preposition(verb: String) -> String
  func is_verb_available_for_target(verb: String, target: Node) -> bool
  func get_inventory_item_verb_text(verb: String, item_id: String, target: Node = null) -> String
  func get_item_combination_hint(verb: String, item1: String, item2: String) -> String
  ```
- **Enhanced Item Integration:** Connect verb system to inventory hover descriptions
- **Combination Guidance:** Show "Try combining with..." hints for Use verb on inventory items
- **Visual Effects:** Use shader effects for smooth hover highlighting
- **Performance:** Cache verb-object combination validity checks

### Task 16: Create title screen with minimalist UI layout
**User Story:** As a player, I want a clean and atmospheric title screen that immediately sets the tone, so that I'm immersed in the game world from the very first moment.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Title "A SILENT REFRACTION" prominently displayed
  2. Only two buttons: "Start Game" and "Load Game"
  3. Version number displayed subtly
  4. CRT shader effect applied for atmosphere
  5. Clean, centered layout with proper spacing

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Use CenterContainer for layout
- Apply slight blue tint to text (0.8, 0.8, 1.0)
- Include ambient station hum at -20db

### Task 17: Implement save file detection and load button states
**User Story:** As a player, I want to clearly see whether I have a saved game available, so that I don't accidentally try to load a non-existent save.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Load button disabled/grayed when no save exists
  2. Load button text shows "(No Save)" when disabled
  3. Save detection happens on title screen load
  4. Visual feedback clearly indicates button state
  5. Button re-enables if save is created elsewhere

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Use SaveManager.has_save_file() for detection
- Gray out with modulate = Color(0.5, 0.5, 0.5)
- Update button state in _ready()

### Task 18: Create save overwrite warning dialog system
**User Story:** As a player with an existing save, I want clear warning before starting a new game, so that I don't accidentally delete hours of progress.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Warning only appears if save file exists
  2. Clear message about permanent deletion
  3. Explicit "Yes, Start New Game" confirmation
  4. "No, Return to Menu" cancellation option
  5. No accidental deletion possible

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Use ConfirmationDialog for consistency
- Message: "Starting a new game will permanently delete your existing save."
- Block other inputs during dialog

### Task 19: Build gender selection screen with radio buttons
**User Story:** As a player, I want to select my character's gender in a simple, clear interface, so that I can customize my game experience without complexity.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Two options: "Play as Alex (Male)" and "Play as Alex (Female)"
  2. Radio button behavior (only one selected)
  3. Confirm button disabled until selection made
  4. Clean transition to prologue after confirmation
  5. Selection stored in GameData.player_gender

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Reference: docs/design/character_gender_selection_system.md
- Use toggle_mode = true for radio behavior
- Simple text options, no complex portraits needed

### Task 20: Implement prologue scrolling text system
**User Story:** As a player, I want an atmospheric prologue that sets the story context, so that I understand my role and the game's premise before playing.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Text scrolls upward at 30 pixels/second
  2. Text fades as it approaches top of screen
  3. Skip option appears after 2 seconds
  4. SPACE key skips to game start
  5. Automatic transition when text completes

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Blade Runner-style blue tint (0.8, 0.8, 1.0)
- Line height: 24 pixels
- Fade distance: 100 pixels from top
- Full prologue text provided in design

### Task 21: Create new game initialization sequence
**User Story:** As a developer, I want the new game to properly initialize all systems with correct starting values, so that players begin with a consistent, bug-free experience.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Time set to Day 1, 8:00 AM
  2. Player starts in spaceport/docked_ship_1
  3. Initial items added (courier bag, manifest, package)
  4. Starting credits set to 100
  5. Patient zero already assimilated

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Initialize all managers before scene change
- Create initial save after initialization
- Set GameData.new_game = true flag

### Task 22: Implement comprehensive load functionality with progress tracking
**User Story:** As a player with a saved game, I want to load my game with clear progress feedback and robust error handling, so that I can resume playing confidently and understand any issues that occur.

**Design Reference:** `docs/design/save_system_design.md`, `docs/design/main_menu_start_game_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Load button immediately starts loading process
  2. Comprehensive loading screen with progress indicators
  3. No save slot selection (single slot system)
  4. Direct transition to game at saved position
  5. Module-by-module load progress display
  6. Load failure recovery flow with specific error messages
  7. Save file validation before load attempt
  8. Loading screen shows current module being loaded

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Reference: docs/design/save_system_design.md lines 219-245 (load system implementation)
- Show loading overlay with module progress
- Use SaveManager.load_game() with progress callbacks
- Connect to modular load events: module_load_start, module_load_complete
- Validate save file before attempting load
- Show loading screen similar to save system design mockup
- Handle corruption recovery and backup restoration

### Task 23: Add atmospheric effects and CRT shader
**User Story:** As a player, I want the title screen to have a retro-futuristic atmosphere, so that the game's aesthetic is established immediately.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. CRT shader effect applied to entire screen
  2. Subtle screen curvature and scanlines
  3. Ambient station hum plays quietly
  4. Slow fade-in on initial load
  5. All effects enhance without distracting

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Use existing CRT shader from shaders/
- Ambient sound at -20db volume
- 2-second fade-in on startup

### Task 24: Create comprehensive error handling for failed loads with backup recovery
**User Story:** As a player, I want comprehensive feedback if my save file can't be loaded, with automatic backup recovery options, so that I can understand what happened and recover my progress when possible.

**Design Reference:** `docs/design/save_system_design.md`, `docs/design/main_menu_start_game_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. Clear error message displayed with specific failure reason
  2. Automatic return to title screen
  3. No crash or hang on corrupted save
  4. Option to start new game after error
  5. Error logged for debugging
  6. Backup save recovery attempt when available
  7. Corruption detection with specific error types
  8. Fallback to backup save when corruption detected

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Reference: docs/design/save_system_design.md lines 406-441 (corruption recovery)
- Use PromptNotificationSystem for error display
- Log full error details to console
- Implement backup save recovery flow
- Detect corruption types: checksum mismatch, missing modules, format errors
- Show backup availability info to player
- Automatic backup restoration attempt before showing error

### Task 25: Integrate with existing game systems
**User Story:** As a developer, I want the main menu to properly connect with all game systems, so that the transition from menu to gameplay is seamless.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. All managers initialize in correct order
  2. Scene transitions work smoothly
  3. Character data properly passed through
  4. Save system integration complete
  5. No memory leaks during transitions

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Test with all existing systems
- Ensure proper cleanup on scene change
- Verify autoload singletons persist

### Task 6: Refactor dialog system architecture
**User Story:** As a developer, I want a clean, maintainable dialog system architecture that supports procedural generation, so that I can efficiently implement complex personality-driven conversations.

**Dialog Manager Migration Phase 1a-1c:** This task establishes the foundation for the template dialog system by implementing core navigation and state tracking features.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. DialogManager follows service architecture pattern from refactoring plan
  2. Clean separation between UI, data, and logic layers
  3. Support for flexible dialog tree navigation
  4. Foundation for future procedural generation
  5. Maintains backwards compatibility with existing NPCs
  6. **Phase 1a:** Extended dialog_panel UI with personality/mood indicators
  7. **Phase 1b:** Flexible node navigation methods (get_entry_node, get_node_options)
  8. **Phase 1c:** Option selection tracking for future personality adaptation

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md
- Follow service registry pattern for dependency injection
- Create IDialogService interface
- **Phase 1a:** Add visual personality hints to dialog UI (mood icon, tone indicator)
- **Phase 1b:** Implement navigation methods from template_dialog_design.md:
  ```gdscript
  func get_entry_node() -> String
  func get_node_text(node_id: String) -> String
  func get_node_options(node_id: String) -> Array
  ```
- **Phase 1c:** Track player choices in conversation_history for future analysis

### Task 7: Implement gender-aware text substitution
**User Story:** As a player, I want NPCs to address me with appropriate pronouns and gender-specific language, so that conversations feel natural and personalized.

**Dialog Manager Migration Phase 2a:** This task implements the context system required for gender-aware and personality-driven dialog generation.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Pronoun system replaces {PLAYER_PRONOUN} tags correctly
  2. Gender-specific dialog variations work seamlessly
  3. NPCs use appropriate titles (Mr./Ms./Mx.)
  4. Context passed to all dialog methods
  5. System handles all three gender options gracefully
  6. **Phase 2a:** Full DialogContext system implemented
  7. **Phase 2a:** Context includes gender, time, location, relationship data

**Implementation Notes:**
- Reference: docs/design/character_gender_selection_system.md
- Create PronounManager singleton
- Implement text substitution engine
- **Phase 2a:** Create DialogContext class from template_dialog_design.md:
  ```gdscript
  var dialog_context = {
      "player_gender": GameManager.player_gender,
      "npc_gender": npc.gender,
      "time_of_day": TimeManager.get_time_period(),
      "location": get_current_district(),
      "player_reputation": interaction_memory.player_reputation,
      "is_assimilated": is_assimilated,
      "suspicion_level": suspicion_level
  }
  ```
- Pass context to all dialog generation methods

### Task 8: Create dialog tree editor improvements
**User Story:** As a content creator, I want improved tools for creating complex dialog trees, so that I can efficiently write branching conversations that support the game's investigation mechanics.

**Dialog Manager Migration Phase 2b:** This task enhances the dialog system with template support and guideline-based generation preparation.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. Visual dialog tree editor in Godot
  2. Support for conditional branches
  3. Preview with pronoun substitution
  4. Template system for common patterns
  5. Export/import JSON dialog format
  6. **Phase 2b:** Dialog template library structure
  7. **Phase 2b:** Personality-based response variations

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md
- Build on Godot's GraphEdit node
- Support node types: Text, Choice, Condition, Action
- **Phase 2b:** Implement DialogTemplates class structure:
  ```gdscript
  const GREETING_TEMPLATES = {}
  const TOPIC_TEMPLATES = {}
  const SUSPICION_RESPONSES = {}
  ```
- Prepare for personality-driven text modulation

### Task 9: Add dialog history/log system
**User Story:** As a player, I want to review past conversations with NPCs, so that I can track important information and notice inconsistencies that might indicate assimilation.

**Dialog Manager Migration Phase 3a:** This task implements memory and history tracking essential for relationship-based dialog.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Dialog log UI accessible from pause menu
  2. Conversations grouped by NPC
  3. Searchable text with keywords
  4. Important lines can be marked/starred
  5. History persists through save/load
  6. **Phase 3a:** NPCMemory integration for conversation tracking
  7. **Phase 3a:** Topic frequency and relationship tracking

**Implementation Notes:**
- Reference: docs/design/investigation_clue_tracking_system_design.md
- Store last 50 conversations per NPC
- Highlight suspicious dialog automatically
- **Phase 3a:** Implement conversation memory structure:
  ```gdscript
  var conversation_history: Array = []
  var topics_discussed: Dictionary = {}
  var player_choices: Dictionary = {}
  var relationship_score: float = 0.0
  ```
- Link to investigation system for clue extraction

### Task 10: Integrate with notification system
**User Story:** As a player, I want consistent notification when dialog events occur, so that I'm aware of important conversation outcomes and relationship changes.

**Dialog Manager Migration Phase 3b:** This task completes the integration with game systems and enables suspicion-based dialog variations.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U3, T1
- **Acceptance Criteria:**
  1. Dialog events trigger notifications
  2. Relationship changes shown via prompts
  3. Suspicion changes integrated smoothly
  4. All dialog UI uses prompt_notification_system
  5. Consistent look/feel across all systems
  6. **Phase 3b:** Suspicion level affects dialog generation
  7. **Phase 3b:** Assimilation effects on dialog implemented

**Implementation Notes:**
- Reference: docs/design/prompt_notification_system_design.md
- Remove custom dialog UI from Sleep/Save systems
- Consolidate all through notification system
- **Phase 3b:** Implement suspicion responses:
  ```gdscript
  const SUSPICION_RESPONSES = {
      "low": {"question": "Is there something specific you wanted to know?"},
      "medium": {"question": "Why all these questions?"},
      "high": {"question": "What are you really after?"},
      "critical": {"question": "Are you security? What's this about?"}
  }
  ```
- Apply assimilation text transforms based on infection level

### Task 26: Implement ServiceRegistry singleton pattern
**User Story:** As a developer, I want a centralized service registry for dependency injection, so that dialog system components can be loosely coupled and easily testable.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. ServiceRegistry singleton implemented
  2. Services can register and retrieve by name
  3. Supports interface-based service contracts
  4. Handles missing services gracefully
  5. Debug mode lists all registered services

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 1 (Service Architecture)
- Reference: docs/design/modular_serialization_architecture.md (singleton pattern)
- Create as autoload singleton
- Use weak references to prevent memory leaks
- Include debug commands for service inspection

### Task 27: Create IDialogService interface and DialogService
**User Story:** As a developer, I want clean dialog service interfaces, so that the dialog system can be extended without modifying core components.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. IDialogService interface defines contract
  2. DialogService implements the interface
  3. No scene tree dependencies
  4. Clean separation from UI layer
  5. Supports multiple dialog instances

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 1
- Interface methods: show_dialog(), hide_dialog(), is_dialog_active()
- Use signals for all communication
- Factory pattern for UI creation

### Task 28: Extract DialogData and dialog state classes
**User Story:** As a developer, I want dialog data separated from logic, so that dialog state can be easily serialized and tested.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. DialogData resource class created
  2. Clean data structures for serialization
  3. No logic in data classes
  4. Supports versioning
  5. Handles legacy format conversion

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 2
- Pure data classes with no side effects
- Include validation methods
- Support for procedural generation fields

### Task 29: Implement DialogUIFactory for UI separation
**User Story:** As a developer, I want UI creation separated from dialog logic, so that we can easily modify or replace the dialog UI without affecting the system.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. DialogUIFactory creates all UI components
  2. Clean interface between UI and logic
  3. Supports different UI styles
  4. Handles UI cleanup properly
  5. No business logic in UI layer

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 2
- Factory methods for each UI component
- Support for custom UI themes
- Proper memory management for UI nodes

### Task 30: Create NPCDialogController for dialog logic
**User Story:** As a developer, I want dialog logic centralized per NPC, so that each character's conversation behavior is encapsulated and maintainable.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. NPCDialogController handles all dialog logic
  2. Clean interface with BaseNPC
  3. Supports personality-driven responses
  4. Integrates with suspicion system
  5. No UI dependencies

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 2
- One controller per NPC instance
- Handles option selection and branching
- Integrates with template dialog system

### Task 31: Implement DialogEventBus for signal architecture
**User Story:** As a developer, I want all dialog communication through signals, so that components remain decoupled and the system is maintainable.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. DialogEventBus centralizes all dialog signals
  2. Replaces direct method calls
  3. Supports event filtering
  4. Debug mode shows event flow
  5. No circular dependencies

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 4
- Central hub for all dialog events
- Event types: dialog_requested, option_chosen, dialog_ended
- Include event logging for debugging

### Task 32: Create DialogValidator and error handling
**User Story:** As a developer, I want comprehensive dialog validation, so that content creators get clear feedback about dialog tree errors.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. DialogValidator checks tree structure
  2. Validates all node references
  3. Provides clear error messages
  4. Includes context in errors
  5. Can run in editor or runtime

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 5
- Validate: missing nodes, circular references, dead ends
- ErrorContextService for structured reporting
- Integration with editor tools

### Task 33: Build dialog testing infrastructure with mocks
**User Story:** As a developer, I want comprehensive dialog system tests, so that refactoring doesn't break existing functionality.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. MockDialogService for testing
  2. Unit tests for all components
  3. Integration test suite
  4. >90% code coverage
  5. Automated test runs

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 6
- Mock implementations of all services
- Test dialog flow, state management, serialization
- Performance benchmarks included

### Task 34: Implement LegacyDialogAdapter for migration
**User Story:** As a developer, I want to migrate gradually to the new system, so that we can maintain stability while refactoring.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. LegacyDialogAdapter bridges old/new systems
  2. Existing NPCs continue working
  3. Can migrate NPCs individually
  4. No breaking changes
  5. Clear migration path

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 7
- Adapter pattern for backward compatibility
- Converts between old/new formats
- Deprecation warnings for old API usage

### Task 35: Add feature flags for progressive rollout
**User Story:** As a developer, I want to control the rollout of new dialog features, so that we can test in production without risk.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. FeatureFlags system implemented
  2. Can toggle dialog features at runtime
  3. Persists flag settings
  4. Debug UI for flag management
  5. Performance monitoring per feature

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md Phase 7
- Flags: use_new_dialog_system, enable_validation, debug_performance
- Integration with debug menu
- A/B testing support

### Task 36: Migrate Sleep system dialogs to PromptNotificationSystem
**User Story:** As a player, I want consistent UI for all notifications, so that I can quickly understand and respond to game events.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. All Sleep dialogs use PromptNotificationSystem
  2. Remove custom dialog implementations
  3. Maintain existing functionality
  4. Consistent look/feel
  5. Proper priority handling

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md UI Consolidation
- Replace: NotificationDialog, UrgentDialog, ForcedReturnDialog
- Use prompt types: WARNING, CRITICAL, INFO
- Test all sleep warning scenarios

### Task 37: Migrate Save system dialogs to PromptNotificationSystem
**User Story:** As a player, I want save system feedback through the standard notification system, so that save operations feel integrated with the rest of the game.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. All Save dialogs use PromptNotificationSystem
  2. Progress indicators work correctly
  3. Error messages are clear
  4. No custom UI code remains
  5. Maintains save system reliability

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md UI Consolidation
- Replace: SaveProgressUI, SaveErrorDialog, CorruptionDialog
- Handle progress updates appropriately
- Test error scenarios thoroughly

### Task 38: Migrate Detection system dialogs to PromptNotificationSystem
**User Story:** As a player, I want security alerts through the standard notification system, so that all warnings have consistent urgency and presentation.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. All Detection dialogs use PromptNotificationSystem
  2. Alert urgency properly conveyed
  3. Lockdown announcements work
  4. Sound integration maintained
  5. Clear threat communication

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md UI Consolidation
- Replace custom alert and lockdown dialogs
- Use CRITICAL priority for immediate threats
- Maintain audio cue integration

### Task 39: Create MorningReportManager for centralized reports
**User Story:** As a player, I want a unified morning report system, so that I get consistent daily updates about station events.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. MorningReportManager centralizes all reports
  2. Collects data from all systems
  3. Formats consistent morning briefing
  4. Integrates with notification system
  5. Customizable report sections

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md UI Consolidation
- Gather: sleep quality, station events, rumors, alerts
- Use INFO prompt type with special formatting
- Support for future report expansions

### Task 40: Remove all redundant dialog implementations
**User Story:** As a developer, I want a clean codebase without duplicate dialog systems, so that maintenance is simplified and bugs are reduced.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. All custom dialog code removed
  2. No functionality lost
  3. Code coverage maintained
  4. Documentation updated
  5. Migration guide created

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md
- Final cleanup phase after all migrations
- Update all documentation
- Remove deprecated code paths

### Inventory Verb Integration
- [ ] Task 41: Implement item examination system with verb UI
- [ ] Task 42: Create item combination interface for verb system
- [ ] Task 43: Add "Give" verb integration with inventory
- [ ] Task 44: Implement "Take" verb for world items
- [ ] Task 45: Create inventory-aware dialog options
- [ ] Task 46: Add item-based dialog branches

### Task 41: Implement item examination system with verb UI
**User Story:** As a player, I want to examine items in my inventory using the verb UI, so that I can learn more about items and discover clues or usage hints.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. "Look" verb works on inventory items
  2. Detailed descriptions shown for items
  3. Examination can reveal hidden properties
  4. UI displays item sprite during examination
  5. Supports both inventory and world items

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md (item examination)
- Reference: docs/design/verb_ui_system_refactoring_plan.md (verb processing)
- Reference: docs/design/template_interactive_object_design.md lines 126-151 (examine behavior)
- Hook into existing verb processing system
- Show item icon alongside description
- Consider investigation skill for detail level

### Task 42: Create item combination interface for verb system
**User Story:** As a player, I want to use items from my inventory with other items or world objects through the verb UI, so that I can solve puzzles and create new items.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. "Use" verb allows item selection from inventory
  2. Selected item highlighted in UI
  3. Can use items on world objects
  4. Can combine two inventory items
  5. Clear feedback for successful/failed combinations

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 140-163 (combine_items method)
- Reference: docs/design/inventory_system_design.md lines 214-249 (ItemCombiner system)
- Reference: docs/design/verb_ui_system_refactoring_plan.md (item selection UI)
- Two-step process: select item, then target
- Visual feedback during combination attempt
- Success/failure messages via notification system

### Task 43: Add "Give" verb integration with inventory
**User Story:** As a player, I want to give items from my inventory to NPCs, so that I can complete quests, build relationships, or bribe my way out of trouble.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. "Give" verb opens inventory selection
  2. Only appropriate items shown as options
  3. NPCs react based on item given
  4. Items removed from inventory on success
  5. Trust/relationship impacts from gifts

**Implementation Notes:**
- Reference: docs/design/verb_ui_system_refactoring_plan.md (Give verb implementation)
- Reference: docs/design/npc_trust_relationship_system_design.md (gift reactions)
- Reference: docs/design/template_npc_design.md (item acceptance logic)
- Filter items based on NPC preferences
- NPCs can refuse inappropriate items
- Special reactions for quest items
- Update relationship scores

### Task 44: Implement "Take" verb for world items
**User Story:** As a player, I want to take items from the game world into my inventory, so that I can collect useful objects and clues during exploration.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. "Take" verb works on takeable objects
  2. Items add to inventory if space available
  3. Full inventory shows appropriate message
  4. Visual feedback when item taken
  5. World object disappears/updates state

**Implementation Notes:**
- Reference: docs/design/template_interactive_object_design.md lines 195-220 (takeable objects)
- Reference: docs/design/inventory_system_design.md lines 47-94 (add_item method)
- Reference: docs/design/verb_ui_system_refactoring_plan.md (Take verb)
- Check inventory capacity before taking
- Update object state to "taken"
- Remove visual representation from world
- Log item acquisition for investigation

### Task 45: Create inventory-aware dialog options
**User Story:** As a player, I want dialog options that reference items in my inventory, so that conversations can be more dynamic and context-sensitive.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Dialog system checks inventory contents
  2. Item-specific options appear in conversations
  3. Can show/discuss items with NPCs
  4. Options hidden if item not possessed
  5. Items can unlock new dialog branches

**Implementation Notes:**
- Reference: docs/design/dialog_system_refactoring_plan.md (conditional dialog)
- Reference: docs/design/inventory_system_design.md (inventory queries)
- Reference: docs/design/template_dialog_design.md (context-aware dialog)
- Dialog condition: has_item("item_id")
- Dynamic option generation based on inventory
- NPCs comment on shown items
- Some items trigger special conversations

### Task 46: Add item-based dialog branches
**User Story:** As an NPC, I want to react differently based on items the player possesses or shows me, so that conversations feel more realistic and responsive.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. NPCs detect specific items in inventory
  2. Dialog branches based on item possession
  3. Reactions to contraband/suspicious items
  4. Quest items trigger special dialogs
  5. Item-based conversation memories

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 513-536 (contraband suspicion)
- Reference: docs/design/suspicion_system_full_design.md (item-based suspicion)
- Reference: docs/design/template_npc_design.md (personality reactions)
- Integrate with suspicion system for illegal items
- Quest items can auto-trigger conversations
- NPCs remember items shown to them
- Different reactions based on NPC personality

## Testing Criteria
- Character creation flow completes successfully
- Gender selection persists across sessions
- All dialog displays correct pronouns
- Verb UI responds to all interactions
- Dialog trees navigate without errors
- Main menu functions properly
- Save/load preserves character data
- Performance remains smooth with UI updates
- Title screen displays correctly with CRT effects
- Save detection properly enables/disables load button
- Save overwrite warning prevents accidental deletion
- Gender selection enforces single choice
- Prologue text scrolls smoothly and can be skipped
- New game initialization sets all values correctly
- Direct load bypasses all intermediate screens
- Failed loads handled gracefully with clear messaging
- All scene transitions work without memory leaks
- Item examination shows detailed descriptions
- Item combination interface works intuitively
- Give verb properly transfers items to NPCs
- Take verb respects inventory capacity
- Dialog options reflect inventory contents
- NPCs react appropriately to shown items

## Timeline
- Start date: After Iteration 5 completion
- Target completion: 2 weeks
- Critical for: All future NPC interactions

## Dependencies
- Iteration 4: Serialization (for saving character data)
- Iteration 5: Notification System (for dialog feedback)
- Existing dialog and interaction systems

## Code Links
- src/ui/character_creation/ (to be created)
- src/core/dialog/dialog_manager.gd (to be refactored)
- src/core/dialog/pronoun_manager.gd (to be created)
- src/ui/verb_ui/verb_ui.gd (to be refactored)
- src/ui/main_menu/ (to be created)
- docs/design/character_gender_selection_system.md
- docs/design/dialog_system_refactoring_plan.md
- docs/design/verb_ui_system_refactoring_plan.md
- docs/design/main_menu_start_game_ui_design.md

## Notes
- Gender system must be respectful and inclusive
- Dialog refactoring addresses technical debt from early development
- Verb UI is critical for game's identity as SCUMM-style adventure
- Main menu sets first impression - polish is important

### Suspicion-Based Dialog System Extension
- [ ] Task 47: Implement suspicion-based dialog modifications
- [ ] Task 48: Create group suspicion behavior responses
- [ ] Task 49: Add tier-based NPC behavioral changes for suspicion
- [ ] Task 50: Implement suspicion dialog tone modifiers
- [ ] Task 51: Create panic/flee dialog variations for critical suspicion

### Task 47: Implement suspicion-based dialog modifications
**User Story:** As a player, I want NPCs to speak differently based on their suspicion of me, so that social interactions become more tense and realistic as suspicion rises.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Dialog tone changes based on suspicion tier (none, low, medium, high, critical)
  2. Dialog options restricted at higher suspicion levels
  3. NPCs use appropriate greetings for suspicion level
  4. Conversation content filtered by trust relationship
  5. Integration with existing dialog system architecture

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 871-911 (modify_dialog_for_suspicion)
- **Suspicion Tiers:** none (normal), low (guarded), medium (actively suspicious), high (panicked), critical (no dialog)
- **Dialog Modifications:**
  - Low: "Oh... hello.", "Can I help you?", tone = "guarded"
  - Medium: "Stay back!", "I don't want trouble.", refuse_interaction = true
  - High: "Get away from me!", "SECURITY! HELP!", force_end_dialog = true
  - Critical: no_dialog = true, immediate_action = "flee_or_attack"
- Integrate with dialog_manager.gd refactoring
- Store suspicion-modified dialog in parallel trees

### Task 48: Create group suspicion behavior responses
**User Story:** As an NPC in a group, I want to coordinate with other suspicious NPCs when facing a threat, so that groups respond realistically to dangerous situations.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U2
- **Acceptance Criteria:**
  1. Groups of 3+ suspicious NPCs coordinate responses
  2. Different group compositions trigger different strategies
  3. Security-heavy groups attempt capture
  4. Assimilated-heavy groups set traps
  5. Civilian-heavy groups flee and spread panic

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 913-967 (coordinate_group_response)
- **Group Response Types:**
  - Security groups (50%+ security): coordinate_capture_attempt with perimeter formation
  - Assimilated groups (50%+ assimilated): coordinate_assimilated_trap with deception
  - Civilian groups: coordinate_civilian_panic with area evacuation
- Minimum 3 NPCs required for group behavior
- Calculate surrounding positions for capture attempts
- Leaders maintain cover in assimilated traps
- Dialog reflects group coordination plans

### Task 49: Add tier-based NPC behavioral changes for suspicion
**User Story:** As an NPC, I want my behavior to change gradually as my suspicion of the player increases, so that escalation feels natural and gives the player clear feedback.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U2
- **Acceptance Criteria:**
  1. Movement speed increases with suspicion (1.0x to 1.6x)
  2. Interaction willingness decreases (1.0 to 0.0)
  3. Special actions triggered by suspicion tier
  4. Visual indicators for behavioral changes
  5. Smooth transitions between behavior tiers

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 834-869 (get_tier_behaviors)
- **Behavior Modifiers by Tier:**
  - None: movement_speed 1.0, interaction_willingness 1.0, no special actions
  - Low: movement_speed 1.1, interaction_willingness 0.8, actions: ["glance_at_player", "whisper_to_others"]
  - Medium: movement_speed 1.2, interaction_willingness 0.5, actions: ["avoid_player", "report_to_security"]
  - High: movement_speed 1.4, interaction_willingness 0.2, actions: ["flee_from_player", "call_security"]
  - Critical: movement_speed 1.6, interaction_willingness 0.0, actions: ["panic", "lockdown_area"]
- Apply modifiers in NPC _process() and interaction methods
- Visual cues: nervous animations, looking over shoulder, backing away

### Task 50: Implement suspicion dialog tone modifiers
**User Story:** As a player, I want to hear the suspicion in NPCs' voices through word choice and sentence structure, so that rising tension is communicated clearly.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Dialog modifier affects word choice and phrasing
  2. Tone ranges from friendly to hostile to panicked
  3. Sentence structure becomes shorter/more clipped at high suspicion
  4. Question deflection increases with suspicion
  5. Integration with personality-based speech patterns

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md (dialog modifications)
- **Tone Modifiers:**
  - Friendly (low suspicion): verbose, helpful, asks follow-up questions
  - Guarded (medium): shorter responses, evasive answers
  - Hostile (high): clipped speech, demands, threats
  - Panicked (critical): fragmented speech, repetition, fear
- Modify base dialog through tone filters before display
- Combine with personality traits for unique voices

### Task 51: Create panic/flee dialog variations for critical suspicion
**User Story:** As an NPC at maximum suspicion, I want to express genuine fear and panic in my final interactions, so that the escalation feels dramatic and consequential.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Critical suspicion triggers panic dialog variations
  2. Dialog includes calls for help and security
  3. NPCs express knowledge of player's true nature
  4. Different panic responses based on NPC role/personality
  5. Dialog can trigger immediate flee or attack behaviors

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md (critical suspicion responses)
- **Panic Dialog Examples:**
  - Security: "I KNOW WHAT YOU ARE! CODE RED!"
  - Civilian: "SOMEONE HELP ME! THEY'RE ONE OF THEM!"
  - Medical: "Stay back! I won't let you assimilate me!"
- Trigger immediate state changes: FLEEING, CALLING_SECURITY, LOCKDOWN
- Some NPCs may attempt to bargain or negotiate
- Dialog duration shortened to 1-2 exchanges before action

### Design Documents Implemented
- docs/design/character_gender_selection_system.md
- docs/design/dialog_system_refactoring_plan.md
- docs/design/verb_ui_system_refactoring_plan.md
- docs/design/main_menu_start_game_ui_design.md
- docs/design/suspicion_system_full_design.md (behavioral response system)

### Template References
- Dialog implementation should follow patterns in docs/design/template_dialog_design.md
- UI components should follow docs/design/template_integration_standards.md