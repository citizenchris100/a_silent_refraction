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

### First Quest - Mall Patrol System
- [ ] Task 21: Create SecurityPatrol class and data structures
- [ ] Task 22: Implement mall patrol route system
- [ ] Task 23: Build patrol schedule mechanics
- [ ] Task 24: Create player detection during patrols
- [ ] Task 25: Implement security guard dialog trees
- [ ] Task 26: Add disguise bypass mechanics
- [ ] Task 27: Create patrol area checking system
- [ ] Task 28: Build security encounter UI
- [ ] Task 29: Implement chase initiation from patrol
- [ ] Task 30: Create patrol state persistence

### First Quest Implementation
- [ ] Task 31: Design First Quest narrative
- [ ] Task 32: Implement all quest objectives
- [ ] Task 33: Create quest-specific content
- [ ] Task 34: Add multiple solution paths
- [ ] Task 35: Full integration testing

### Trading Floor Minigame
- [ ] Task 36: Create TradingTerminal scene with Game Boy UI layout
- [ ] Task 37: Implement BlockTrader core Tetris-style gameplay mechanics
- [ ] Task 38: Create Game Boy shader and visual effects
- [ ] Task 39: Implement score-to-credits conversion system
- [ ] Task 40: Add gender-based modifiers and harassment events
- [ ] Task 41: Create persistent leaderboard system
- [ ] Task 42: Implement time consumption mechanics
- [ ] Task 43: Integrate minigame with job shift system
- [ ] Task 44: Add save/load functionality for minigame progress
- [ ] Task 45: Create practice mode and tutorial

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

### Task 21: Create SecurityPatrol class and data structures
**User Story:** As a developer, I want a robust patrol system for security guards, so that the First Quest can feature dynamic guard patrols that create tension and gameplay opportunities.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. SecurityPatrol class with all properties
  2. Route waypoint array support
  3. Schedule dictionary for timing
  4. Alert level state tracking
  5. Detection radius configuration

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 238-247
- Detection radius: 100.0 units default
- Alert levels: 0=routine, 1=suspicious, 2=alert
- Integrate with existing NPC system

### Task 22: Implement mall patrol route system
**User Story:** As a security guard, I want to follow a predefined patrol route through the mall, so that all areas are regularly monitored and players must time their movements carefully.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Waypoint-based route system
  2. Smooth movement between points
  3. Pause at each waypoint
  4. Loop back to start
  5. Visual route indicators (debug mode)

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 253-260
- Route: entrance → fountain → shops_east → food_court → shops_west → entrance
- Use existing navigation system
- 30-second pause at key locations

### Task 23: Build patrol schedule mechanics
**User Story:** As a mall security system, I want guards to patrol on regular schedules, so that players can observe patterns and plan their infiltration accordingly.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Time-based patrol starts
  2. Schedule integration with TimeManager
  3. Frequency configuration (every 30 min)
  4. Operating hours (8 AM - 10 PM)
  5. Schedule variations by day

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 261-265
- Use Living World Event System for scheduling
- Consider lunch breaks in schedule
- Weekend vs weekday patterns

### Task 24: Create player detection during patrols
**User Story:** As a security guard on patrol, I want to detect suspicious player behavior, so that infiltration requires careful planning and isn't trivially easy.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Line-of-sight detection
  2. Distance-based detection
  3. Running increases detection chance
  4. Suspicious items increase detection
  5. Detection chance calculation

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 294-316
- Base detection chance: 50%
- Running modifier: 2x
- Suspicious item modifier: 1.5x
- Must have clear line of sight

### Task 25: Implement security guard dialog trees
**User Story:** As a player caught by security, I want dialog options to talk my way out of trouble, so that social skills provide alternatives to running or fighting.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Suspicious encounter dialog
  2. Alert encounter dialog
  3. Multiple response options
  4. Bribery option with credits
  5. Employee badge bypass

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 539-588
- Suspicious: "What's your business here?"
- Alert: "Security! Stop right there!"
- Bribe amount: 50 credits base

### Task 26: Add disguise bypass mechanics
**User Story:** As a player wearing a security uniform, I want to bypass guard detection, so that disguises provide meaningful gameplay advantages.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Security uniform detection check
  2. Automatic bypass when disguised
  3. Quality of disguise matters
  4. Time limit on disguise effectiveness
  5. Other guards may still investigate

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 305-307
- Check DisguiseManager.current_role
- Perfect disguise = no detection
- Partial disguise = reduced detection

### Task 27: Create patrol area checking system
**User Story:** As a patrolling guard, I want to check specific areas for signs of intrusion, so that my patrol feels purposeful rather than just walking a route.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Area inspection at waypoints
  2. Check for disturbances
  3. Notice missing items
  4. Spot opened doors/containers
  5. React to found issues

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 284-285
- 5-second inspection animation
- Can discover player tampering
- Increases alert level if issues found

### Task 28: Build security encounter UI
**User Story:** As a player in a security encounter, I want clear UI feedback about my situation, so that I understand the stakes and my options.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Alert level indicator
  2. Guard suspicion meter
  3. Available action prompts
  4. Escape route indicators
  5. Time pressure visualization

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Use existing UI framework
- Red/yellow/green alert states
- Show detection radius when spotted

### Task 29: Implement chase initiation from patrol
**User Story:** As a security guard, I want to pursue fleeing suspects, so that players can't simply run away without consequences.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Smooth transition to chase
  2. Guard calls for backup
  3. Increased movement speed
  4. Pathfinding to player
  5. Give up after distance/time

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 574-577
- Link to chase sequence system in Iteration 12
- Guards run 20% faster during chase
- 30-second chase timeout

### Task 30: Create patrol state persistence
**User Story:** As a developer, I want patrol states to save and load correctly, so that guard positions and alert levels persist across game sessions.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. Current waypoint saves
  2. Alert level persists
  3. Schedule state maintained
  4. Detection history saved
  5. Graceful handling of missing guards

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Integrate with save system
- Minimal data per patrol
- Reconstruct routes from data

### Task 32: Implement all quest objectives
**User Story:** As a player, I want to experience a complex quest that uses all game systems including the new patrol mechanics, so that I understand the full depth of gameplay possibilities.

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
  6. Integrates mall patrol puzzle

**Implementation Notes:**
- First Quest: "The Missing Researcher"
- Tests all Phase 2 systems
- Mall infiltration is key objective
- 45-60 minutes completion time
- At least 3 different endings

### Task 36: Create TradingTerminal scene with Game Boy UI layout
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
- Security patrol routes execute correctly
- Guard detection mechanics work at proper distances
- Line-of-sight calculations are accurate
- Disguise bypass functions properly
- Security dialog trees display correct options
- Patrol schedules align with game time
- Chase sequences initiate smoothly
- Patrol states persist across save/load
- Area checking discovers player actions
- Security encounters provide player agency
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