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
- [ ] Task 16: Create main menu scene and UI
- [ ] Task 17: Implement new game flow
- [ ] Task 18: Add continue game functionality
- [ ] Task 19: Create options/settings menu
- [ ] Task 20: Add credits screen

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

## Testing Criteria
- Character creation flow completes successfully
- Gender selection persists across sessions
- All dialog displays correct pronouns
- Verb UI responds to all interactions
- Dialog trees navigate without errors
- Main menu functions properly
- Save/load preserves character data
- Performance remains smooth with UI updates

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