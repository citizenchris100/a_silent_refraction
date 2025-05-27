# Iteration 11: Quest and Progression Systems

## Epic Description
**Phase**: 2 - Full Systems  
**Cohesive Goal**: "I can accept, track, and complete quests"

As a player, I need structured objectives that guide my investigation while allowing freedom to pursue leads in my own way, with job opportunities providing both income and access to restricted areas of the station.

## Goals
- Build comprehensive Quest System Framework
- Implement Job/Work Quest System for economic gameplay
- Create Quest Log UI for tracking progress
- Develop First Quest as Phase 2 validation
- Establish progression mechanics
- Create quest template system for content creation

## Requirements

### Business Requirements
- **B1:** Implement comprehensive quest and job systems
  - **Rationale:** Structured progression keeps players engaged and provides clear goals
  - **Success Metric:** Players can track and complete multiple quest types

- **B2:** Validate Phase 2 systems with First Quest implementation
  - **Rationale:** Integration testing ensures all systems work together
  - **Success Metric:** First Quest exercises all major game systems successfully

- **B3:** Create economic progression through jobs
  - **Rationale:** Jobs provide income and narrative opportunities
  - **Success Metric:** Players use jobs strategically for access and income

### User Requirements
- **U1:** As a player, I want to track my quests and objectives
  - **User Value:** Clear goals and progress tracking
  - **Acceptance Criteria:** Quest log shows current objectives and completion status

- **U2:** As a player, I want meaningful job opportunities
  - **User Value:** Economic gameplay provides progression path
  - **Acceptance Criteria:** Jobs provide income and advance the story

- **U3:** As a player, I want freedom in how I complete objectives
  - **User Value:** Player agency increases satisfaction
  - **Acceptance Criteria:** Multiple solutions available for most quests

### Technical Requirements
- **T1:** Design flexible quest state machine
  - **Rationale:** Complex quests need clear state management
  - **Constraints:** Must support branching and parallel objectives

- **T2:** Create data-driven quest system
  - **Rationale:** Content creators need easy quest creation
  - **Constraints:** Quest files should be human-readable

- **T3:** Implement robust quest tracking
  - **Rationale:** Players need clear progress indicators
  - **Constraints:** Must handle 20+ active quests

## Tasks

### Quest Framework
- [ ] Task 1: Create QuestManager singleton
- [ ] Task 2: Implement quest state machine
- [ ] Task 3: Build quest prerequisite system
- [ ] Task 4: Create quest reward system
- [ ] Task 5: Add quest save/load integration

### Job System
- [ ] Task 6: Create JobManager system
- [ ] Task 7: Implement job board UI
- [ ] Task 8: Build work shift mechanics
- [ ] Task 9: Create job performance evaluation
- [ ] Task 10: Add job-specific access permissions

### Quest UI
- [ ] Task 11: Design quest log interface
- [ ] Task 12: Implement quest tracking HUD
- [ ] Task 13: Create quest detail view
- [ ] Task 14: Add quest filtering/sorting
- [ ] Task 15: Build quest notification system

### Quest Templates
- [ ] Task 16: Create quest data format
- [ ] Task 17: Build quest template types
- [ ] Task 18: Implement quest scripting system
- [ ] Task 19: Add quest validation tools
- [ ] Task 20: Create quest debug commands

### First Quest Implementation
- [ ] Task 21: Design First Quest narrative
- [ ] Task 22: Implement all quest objectives
- [ ] Task 23: Create quest-specific content
- [ ] Task 24: Add multiple solution paths
- [ ] Task 25: Full integration testing

### Trading Floor Minigame
- [ ] Task 26: Create TradingTerminal scene with Game Boy UI layout
- [ ] Task 27: Implement BlockTrader core Tetris-style gameplay mechanics
- [ ] Task 28: Create Game Boy shader and visual effects
- [ ] Task 29: Implement score-to-credits conversion system
- [ ] Task 30: Add gender-based modifiers and harassment events
- [ ] Task 31: Create persistent leaderboard system
- [ ] Task 32: Implement time consumption mechanics
- [ ] Task 33: Integrate minigame with job shift system
- [ ] Task 34: Add save/load functionality for minigame progress
- [ ] Task 35: Create practice mode and tutorial

## User Stories

### Task 2: Implement quest state machine
**User Story:** As a developer, I want quests to have clear states and transitions, so that complex quest logic remains manageable and bug-free.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. States: INACTIVE, AVAILABLE, ACTIVE, COMPLETED, FAILED
  2. Clear transition conditions between states
  3. Support for branching quest paths
  4. Parallel objective tracking
  5. State persistence through save/load

**Implementation Notes:**
- Reference: docs/design/template_quest_design.md
- Use state pattern for clean implementation
- Consider quest chains and dependencies
- Support optional objectives

### Task 8: Build work shift mechanics
**User Story:** As a player, I want to work scheduled shifts at various jobs, so that I can earn credits while gaining access to restricted areas and information.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U2
- **Acceptance Criteria:**
  1. Jobs have specific shift times
  2. Must arrive on time or face penalties
  3. Work activities vary by job type
  4. Performance affects payment
  5. Jobs grant temporary access permissions

**Implementation Notes:**
- Reference: docs/design/job_work_quest_system_design.md
- Shift durations: 2-4 hours game time
- Jobs: Janitor, Clerk, Technician, Security
- Performance mini-games for some jobs

### Task 11: Design quest log interface
**User Story:** As a player, I want an intuitive quest log that helps me track multiple objectives, so that I always know what I can do next without feeling overwhelmed.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, T3
- **Acceptance Criteria:**
  1. Categorized quests (Main, Side, Jobs, Personal)
  2. Progress bars for multi-part quests
  3. Map markers for quest locations
  4. Priority/recommendation system
  5. Completed quest archive

**Implementation Notes:**
- Reference: docs/design/quest_log_ui_design.md
- Consider color coding by quest type
- Quick access hotkey (J for Journal)
- Search/filter functionality

### Task 22: Implement all quest objectives
**User Story:** As a player, I want to experience a complex quest that uses all game systems, so that I understand the full depth of gameplay possibilities.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Uses investigation mechanics
  2. Requires social interactions
  3. Includes economic elements
  4. Features time pressure
  5. Multiple completion methods

**Implementation Notes:**
- First Quest: "The Missing Researcher"
- Tests all Phase 2 systems
- 45-60 minutes completion time
- At least 3 different endings

### Task 26: Create TradingTerminal scene with Game Boy UI layout
**User Story:** As a player, I want to access a retro-styled trading terminal at my job, so that I can engage in a nostalgic mini-game that provides both entertainment and income.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, B3, U2
- **Acceptance Criteria:**
  1. Terminal UI matches authentic Game Boy resolution (160x144)
  2. Main menu includes Play, Leaderboard, Practice, and Exit options
  3. Game screen layout includes play area, next piece, score, and time displays
  4. Visual style uses 4-color Game Boy palette
  5. UI scales correctly for modern displays (4x scaling)

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Use viewport scaling for pixel-perfect rendering
- Implement shader for authentic Game Boy look
- Terminal should feel like a separate device within the game world

### Task 27: Implement BlockTrader core Tetris-style gameplay mechanics
**User Story:** As a player, I want to play a familiar block-falling game with smooth controls, so that my trading performance directly reflects my skill and concentration.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, B3, U2
- **Acceptance Criteria:**
  1. Seven different block types (I, O, T, S, Z, L, J pieces)
  2. Smooth rotation and movement controls
  3. Line clearing mechanics work correctly
  4. Progressive difficulty through level increases
  5. Responsive input handling without lag

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Grid size: 10x18 blocks
- Fall speed increases with level progression
- Use _unhandled_input for responsive controls
- Implement proper collision detection for blocks

### Task 28: Create Game Boy shader and visual effects
**User Story:** As a player, I want the trading terminal to have an authentic retro aesthetic, so that the mini-game feels like a genuine Game Boy experience that enhances immersion.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. 4-color palette shader (dark green to pea green)
  2. Pixel-perfect rendering at all zoom levels
  3. Optional CRT-style effects for authenticity
  4. No performance impact from shader effects
  5. Clean, readable display without artifacts

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Shader uses grayscale quantization to 4 colors
- Keep effects simple (KISS principle)
- Test on various display resolutions

### Task 29: Implement score-to-credits conversion system
**User Story:** As a player, I want my game performance to translate directly into earnings, so that improving my skills provides tangible economic benefits in the main game.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, B3, U2
- **Acceptance Criteria:**
  1. Clear score-to-credits conversion rate
  2. Bonus multipliers for combos and level
  3. Minimum score threshold for payment
  4. End-of-shift payment calculation
  5. Integration with main game economy

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Base rates: 100/300/500/800 for 1/2/3/4 lines
- Consider shift-specific modifiers
- Payment occurs at shift completion

### Task 30: Add gender-based modifiers and harassment events
**User Story:** As a female player character, I want to experience the additional challenges women faced in 1950s workplaces, so that the game provides meaningful commentary on historical gender discrimination while maintaining engaging gameplay.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Gender modifier affects difficulty and scoring
  2. Random harassment events (30% chance for female characters)
  3. Three distinct harassment types with different effects
  4. Effects are challenging but not game-breaking
  5. Male characters experience normal difficulty

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Harassment types: view blocking, input lag, score reduction
- Keep tone appropriate - educational not exploitative
- Effects last 5-10 seconds maximum

### Task 31: Create persistent leaderboard system
**User Story:** As a player, I want to see my high scores compared to other traders, so that I have competitive goals to strive for and can track my improvement over time.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Top 10 scores displayed with names and dates
  2. Player's best score highlighted if in top 10
  3. NPC scores evolve realistically over time
  4. Leaderboard persists between sessions
  5. Separate practice mode scores from shift scores

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Store in SaveManager minigame data
- NPC scores should feel competitive but beatable
- Consider daily/weekly/all-time boards in future

### Task 32: Implement time consumption mechanics
**User Story:** As a player, I want the mini-game to consume in-game time realistically, so that I must balance the desire to earn credits with other investigation activities.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Real time to game time conversion (1 second = 15 minutes)
  2. Time display updates during gameplay
  3. Shift ends automatically at scheduled time
  4. Warning when shift is nearly over
  5. Time progression integrates with TimeManager

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Typical shift: 2-4 hours game time
- Force end game with "Shift Complete" message
- No time consumption in practice mode

### Task 33: Integrate minigame with job shift system
**User Story:** As a player working as a trader, I want the mini-game to launch seamlessly when I start my shift, so that the job system and mini-game feel like one cohesive experience.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, B3, U2
- **Acceptance Criteria:**
  1. Mini-game launches via JobWorkQuestSystem.start_trader_shift()
  2. Shift parameters passed to mini-game (duration, modifiers)
  3. Performance evaluation affects job standing
  4. Credits automatically added to player inventory
  5. Can't leave terminal until shift ends or quit job

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Reference: docs/design/job_work_quest_system_design.md
- Handle early quit with penalties
- Return to trading floor after shift

### Task 34: Add save/load functionality for minigame progress
**User Story:** As a player, I want my trading statistics and high scores to persist, so that my accomplishments and progress in the mini-game are remembered across play sessions.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, T3
- **Acceptance Criteria:**
  1. High score saved and restored
  2. Total games played tracked
  3. Lifetime earnings recorded
  4. Current leaderboard position maintained
  5. Gender-specific statistics tracked

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Use TradingFloorSerializer class
- Integrate with main save system
- Handle save corruption gracefully

### Task 35: Create practice mode and tutorial
**User Story:** As a new player, I want to practice the trading mini-game without time pressure or consequences, so that I can learn the mechanics and improve my skills before taking on paid shifts.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Practice mode accessible from main menu
  2. No time limit in practice mode
  3. No credits earned in practice
  4. Optional tutorial explains controls
  5. Practice scores tracked separately

**Implementation Notes:**
- Reference: docs/design/trading_floor_minigame_system_design.md
- Tutorial shows control scheme overlay
- Consider ghost piece for practice mode
- Allow difficulty selection in practice

## Testing Criteria
- Quest states transition correctly
- Jobs function with proper schedules
- Quest log displays accurate information
- Save/load preserves quest progress
- First Quest completable via multiple paths
- Performance with many active quests
- Quest notifications work properly
- All systems integrate smoothly
- Trading terminal launches correctly from job system
- Tetris-style gameplay mechanics work smoothly
- Game Boy visual aesthetic renders correctly
- Score-to-credits conversion calculates properly
- Gender modifiers and harassment events trigger appropriately
- Leaderboard persists and updates correctly
- Time consumption matches expected rates
- Mini-game saves and loads progress properly
- Practice mode functions without affecting main game

## Timeline
- Start date: After Iteration 10
- Target completion: 2-3 weeks
- Critical for: Phase 2 validation

## Dependencies
- Iteration 10: NPC relationships (for social quests)
- Iteration 9: Investigation system
- All Phase 1 systems

## Code Links
- src/core/quests/quest_manager.gd (to be created)
- src/core/quests/quest_state_machine.gd (to be created)
- src/core/jobs/job_manager.gd (to be created)
- src/ui/quest_log/quest_log_ui.gd (to be created)
- data/quests/first_quest.json (to be created)
- docs/design/job_work_quest_system_design.md
- docs/design/quest_log_ui_design.md
- docs/design/template_quest_design.md
- docs/design/trading_floor_minigame_system_design.md

## Notes
- Quest system must be flexible for Phase 3 content
- Jobs provide both gameplay and narrative opportunities
- First Quest validates all Phase 2 systems
- Multiple solution paths encourage replay
- This iteration enables structured gameplay progression
- Trading Floor minigame provides economic job gameplay
- All job systems should integrate with the quest framework