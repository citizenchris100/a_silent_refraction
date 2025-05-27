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

## User Stories

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
- Reference: docs/design/character_gender_selection_system.md
- Use character portraits for preview
- Show example: "They walked into the room" with proper pronoun
- Store selection in GameState singleton

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

### Task 22: Implement direct load functionality (no UI)
**User Story:** As a player with a saved game, I want to jump directly into my game without additional menus, so that I can resume playing as quickly as possible.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Load button immediately starts loading process
  2. Simple "Loading..." overlay appears
  3. No save slot selection (single slot system)
  4. Direct transition to game at saved position
  5. Error handling returns to title screen

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- No intermediate UI needed
- Show loading overlay with fade
- Use SaveManager.load_game() directly

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

### Task 24: Create error handling for failed loads
**User Story:** As a player, I want clear feedback if my save file can't be loaded, so that I understand what happened and can take appropriate action.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. Clear error message displayed
  2. Automatic return to title screen
  3. No crash or hang on corrupted save
  4. Option to start new game after error
  5. Error logged for debugging

**Implementation Notes:**
- Reference: docs/design/main_menu_start_game_ui_design.md
- Use simple dialog for error display
- Log full error details to console
- Consider save backup system for future

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

### Design Documents Implemented
- docs/design/character_gender_selection_system.md
- docs/design/dialog_system_refactoring_plan.md
- docs/design/verb_ui_system_refactoring_plan.md
- docs/design/main_menu_start_game_ui_design.md

### Template References
- Dialog implementation should follow patterns in docs/design/template_dialog_design.md
- UI components should follow docs/design/template_integration_standards.md