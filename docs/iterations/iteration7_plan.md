# Iteration 7: Character Gender Selection System

## Goals
- Implement character gender selection at game start
- Integrate gender data with save system and dialog system
- Create UI for gender selection matching 90s aesthetic
- Ensure all game systems work correctly with both gender options
- Enable pronoun substitution throughout all dialog

## Requirements

### Business Requirements
- **B1:** Provide character choice to increase player identification and broaden appeal
  - **Rationale:** Gender selection allows more players to connect with the protagonist, potentially expanding the audience
  - **Success Metric:** Both gender options feel equally polished and integrated into the narrative

- **B2:** Maintain narrative integrity while supporting player choice
  - **Rationale:** The core story and themes must work regardless of gender selection
  - **Success Metric:** All dialog and story beats work naturally with either gender choice

### User Requirements
- **U1:** As a player, I want to choose my character's gender at the start of the game
  - **User Value:** Increased connection to the protagonist and personal representation
  - **Acceptance Criteria:** Clear gender selection screen appears after "New Game" with visual representation of both options

- **U2:** As a player, I want NPCs to address me correctly based on my gender choice
  - **User Value:** Immersive experience that respects player choice
  - **Acceptance Criteria:** All NPC dialog uses correct pronouns and titles (Mr./Ms.) consistently

- **U3:** As a player, I want the game to remember my choice across sessions
  - **User Value:** Continuity of experience without having to reselect
  - **Acceptance Criteria:** Gender choice is saved and restored correctly with game saves

### Technical Requirements
- **T1:** Extend save system to support gender data with version migration
  - **Rationale:** Gender must persist across save/load cycles following modular serialization architecture
  - **Constraints:** Must follow established serialization patterns; old saves default to male

- **T2:** Implement pronoun substitution system for dialog
  - **Rationale:** Dialog must dynamically adjust based on player gender without duplicating content
  - **Constraints:** Performance impact must be minimal; substitution happens at runtime

## Tasks
- [ ] Task 1: Design and implement gender selection UI scene
- [ ] Task 2: Create gender selection screen with character portraits
- [ ] Task 3: Implement gender data persistence in PlayerController
- [ ] Task 4: Extend PlayerSerializer for gender data (version 2)
- [ ] Task 5: Implement pronoun substitution in DialogManager
- [ ] Task 6: Update all NPC dialog to use pronoun markers
- [ ] Task 7: Create gender-specific sprite loading system
- [ ] Task 8: Test both gender options through complete game flow
- [ ] Task 9: Add gender selection to new game flow
- [ ] Task 10: Implement save migration for existing saves
- [ ] Task 11: Update main menu to show selected character portrait
- [ ] Task 12: Create comprehensive tests for gender system

## Testing Criteria
- Gender selection screen appears after "New Game" selection
- Both character portraits display correctly at 64x64 resolution
- Selected gender persists through save/load cycles
- All NPC dialog uses correct pronouns and titles
- Both sprite sets load and animate correctly
- Dialog substitution has no noticeable performance impact
- Old saves migrate to default gender without errors
- Gender selection integrates smoothly with existing game flow
- All existing functionality works identically for both genders

## Timeline
- Start date: 2025-07-07
- Target completion: 2025-07-14

## Dependencies
- Iteration 3 (Multi-Perspective Character System) - Sprites must be created first
- Iteration 4 (Dialog and Verb UI System Refactoring) - Need refactored dialog system
- Iteration 5 (Save System Foundation) - Need modular serialization in place
- Iteration 6 (Game Districts and Time Management) - Complete before major content

## Code Links
- Character Gender Selection System Design: docs/design/character_gender_selection_system.md
- GenderSelectionUI: src/ui/gender_selection/gender_selection_ui.gd (to be created)
- Extended PlayerController: src/core/player_controller.gd (to be modified)
- Extended PlayerSerializer: src/core/serializers/player_serializer.gd (to be modified)
- Extended DialogManager: src/core/dialog/dialog_manager.gd (to be modified)

## Notes
This iteration implements the character gender selection system as designed in docs/design/character_gender_selection_system.md. The system allows players to choose between male and female versions of Alex at game start, with full integration into all game systems including saves, dialog, and sprites.

Key implementation notes:
- Gender selection happens immediately after "New Game" selection
- The system follows the modular serialization architecture for save compatibility
- Dialog uses runtime pronoun substitution to avoid content duplication
- Both sprite sets must be created in Iteration 3 before this can be implemented
- The feature is designed to feel like it was always part of the game
