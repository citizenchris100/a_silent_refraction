# Iteration 7: Economy and Save/Sleep

## Epic Description
**Phase**: 1 - MVP Foundation  
**Cohesive Goal**: "I can sleep, save my progress, and manage resources"

As a player, I need to manage my limited credits while finding safe places to sleep, which saves my progress and advances time, creating a risk/reward dynamic where cheaper accommodations may be less safe.

## Goals
- Implement basic Economy System with credits and transactions
- Create unified Save/Sleep System (circular dependency - implement together)
- Implement Morning Report Manager for overnight events
- Create Barracks District with player quarters
- Implement basic Inventory System
- Design Inventory UI

## Requirements

### Business Requirements
- **B1:** Create resource management gameplay
  - **Rationale:** Economic constraints force strategic decisions
  - **Success Metric:** Players report meaningful economic choices

- **B2:** Establish save system tied to gameplay mechanics
  - **Rationale:** Sleep-to-save creates narrative tension and prevents save-scumming
  - **Success Metric:** Players accept and enjoy the save limitation

- **B3:** Provide player home base
  - **Rationale:** Personal space increases player investment
  - **Success Metric:** Players utilize their quarters regularly

### User Requirements
- **U1:** As a player, I want to manage my credits carefully
  - **User Value:** Resource management adds strategic depth
  - **Acceptance Criteria:** Can view balance, make purchases, earn income

- **U2:** As a player, I want to save my progress when I sleep
  - **User Value:** Progress preservation without breaking immersion
  - **Acceptance Criteria:** Sleeping saves game and advances time

- **U3:** As a player, I want to know what happened overnight
  - **User Value:** World feels alive even when player sleeps
  - **Acceptance Criteria:** Morning report summarizes key events

- **U4:** As a player, I want to store items safely
  - **User Value:** Inventory management without constant burden
  - **Acceptance Criteria:** Can store/retrieve items from quarters

### Technical Requirements
- **T1:** Implement transaction system with validation
  - **Rationale:** Prevent negative balances and transaction errors
  - **Constraints:** Must integrate with serialization system

- **T2:** Create atomic save/sleep operation
  - **Rationale:** Save and time advance must happen together
  - **Constraints:** Must handle save failures gracefully

- **T3:** Design expandable inventory system
  - **Rationale:** Future items and categories will be added
  - **Constraints:** Performance with 100+ items

## Tasks

### Economy System
- [ ] Task 1: Create EconomyManager singleton
- [ ] Task 2: Implement credit balance tracking
- [ ] Task 3: Create transaction system with validation
- [ ] Task 4: Add economy UI display
- [ ] Task 5: Implement vendor/shop interface

### Save/Sleep System
- [ ] Task 6: Create SaveManager (extends SerializationManager)
- [ ] Task 7: Implement sleep locations and costs
- [ ] Task 8: Create sleep UI with save confirmation
- [ ] Task 9: Implement save file management (single slot)
- [ ] Task 10: Add save failure handling

### Morning Report System
- [ ] Task 11: Create MorningReportManager
- [ ] Task 12: Implement event collection during sleep
- [ ] Task 13: Design morning report UI
- [ ] Task 14: Create report generation logic
- [ ] Task 15: Add priority/severity system for events

### Barracks District
- [ ] Task 16: Create Barracks district scene
- [ ] Task 17: Implement player quarters (Room 306)
- [ ] Task 18: Add quarter customization basics
- [ ] Task 19: Create storage system in quarters
- [ ] Task 20: Add Barracks common areas

### Inventory System
- [ ] Task 21: Create InventoryManager
- [ ] Task 22: Implement item data structure
- [ ] Task 23: Add inventory capacity limits
- [ ] Task 24: Create inventory UI
- [ ] Task 25: Implement item usage system

### Advanced Time Management
- [ ] Task 26: Create DeadlineManager for time-sensitive objectives
- [ ] Task 27: Implement deadline conflict detection system
- [ ] Task 28: Add cascading consequence analysis for missed deadlines
- [ ] Task 29: Create complex fatigue system with gameplay effects
- [ ] Task 30: Implement stimulant usage with diminishing returns
- [ ] Task 31: Add microsleep and hallucination mechanics
- [ ] Task 32: Create temporal narrative branching system
- [ ] Task 33: Implement flexible scheduling and time optimization
- [ ] Task 34: Add activity interruption and resumption system
- [ ] Task 35: Create time pressure visualization UI

## User Stories

### Task 3: Create transaction system with validation
**User Story:** As a player, I want all my purchases to be secure and validated, so that I never lose credits to bugs or have an invalid game state.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Transactions atomic - all or nothing
  2. Cannot spend more credits than available
  3. Transaction history is logged
  4. Supports different transaction types
  5. Emits signals for UI updates

**Implementation Notes:**
- Transaction types: PURCHASE, SALARY, RENT, FINE, QUEST_REWARD
- Log last 50 transactions for debugging
- Reference: docs/design/economy_system_design.md

### Task 8: Create sleep UI with save confirmation
**User Story:** As a player, I want clear feedback when saving my game through sleep, so that I know my progress is safely preserved.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Shows current save file info (date, playtime)
  2. Confirms overwrite of existing save
  3. Shows save progress indicator
  4. Displays save success/failure clearly
  5. Integrates with PromptNotificationSystem

**Implementation Notes:**
- Use PromptNotificationSystem for confirmations
- Show last save: "Day 5, 14:30 - 3 hours played"
- Reference: docs/design/save_system_design.md
- Reference: docs/design/sleep_system_design.md

### Task 12: Implement event collection during sleep
**User Story:** As a developer, I want the game world to progress while the player sleeps, so that the world feels alive and dynamic.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. NPCs execute overnight routines
  2. Assimilation may spread
  3. Coalition performs operations
  4. Random events can occur
  5. All events are logged for morning report

**Implementation Notes:**
- Events have priority levels for report ordering
- Maximum 10 events shown in report
- Reference: docs/design/morning_report_manager_design.md

### Task 24: Create inventory UI
**User Story:** As a player, I want an intuitive inventory interface, so that I can easily manage my items without frustration.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Grid-based display with item icons
  2. Item descriptions on hover
  3. Drag-and-drop organization
  4. Category filtering (All, Consumables, Key Items, etc.)
  5. Shows weight/capacity limits

**Implementation Notes:**
- 8x6 grid = 48 item slots
- Categories: All, Consumables, Tools, Evidence, Key Items
- Reference: docs/design/inventory_system_design.md
- Reference: docs/design/inventory_ui_design.md

### Task 26: Create DeadlineManager for time-sensitive objectives
**User Story:** As a player, I want to see and track time-sensitive objectives, so that I can prioritize my actions and understand the consequences of my time management choices.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Deadlines display with clear due times
  2. Warning notifications at multiple thresholds
  3. Consequences clearly communicated before missing
  4. Prerequisite chains visible to player
  5. Conflict detection warns of impossible combinations

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Warning thresholds: 24h, 12h, 6h, 2h before deadline
- Support hidden deadlines revealed through investigation
- Integrate with quest system for objective deadlines

### Task 27: Implement deadline conflict detection system
**User Story:** As a player, I want to know when my commitments conflict, so that I can make informed decisions about which objectives to prioritize.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Automatic detection of time conflicts
  2. Visual indicators for conflicting deadlines
  3. Time calculation shows if both can be completed
  4. Suggested priority based on consequences
  5. Player can acknowledge and choose priority

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Calculate total time needed vs time available
- Consider travel time between objectives
- Show conflict resolution suggestions

### Task 28: Add cascading consequence analysis for missed deadlines
**User Story:** As a developer, I want missed deadlines to have realistic cascading effects, so that player choices create meaningful narrative branches and consequences.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Missing deadlines affects NPC relationships
  2. Some story branches become inaccessible
  3. New deadlines may emerge from failures
  4. Coalition strength affected by reliability
  5. Consequences persist across save/load

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Track missed deadline history for reputation
- Some NPCs more forgiving than others
- Critical deadlines can trigger game over scenarios

### Task 29: Create complex fatigue system with gameplay effects
**User Story:** As a player, I want fatigue to meaningfully affect my abilities, so that sleep becomes a strategic resource I must manage carefully.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Five fatigue levels with distinct effects
  2. Movement speed decreases with exhaustion
  3. Dialog options reduced when tired
  4. Investigation success rates drop
  5. All actions take longer when fatigued

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Fatigue levels: Rested, Alert, Tired, Exhausted, Critical
- Exponential fatigue accumulation after 16 hours awake
- Visual indicators: screen darkening, slower animations

### Task 30: Implement stimulant usage with diminishing returns
**User Story:** As a player, I want to use stimulants to postpone sleep, so that I can push through critical moments at the cost of building resistance and side effects.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Multiple stimulant types available
  2. Each use less effective than the last
  3. Resistance builds up over time
  4. Side effects at high resistance
  5. Recovery requires extended sleep

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Stimulant types: Coffee, Pills, Injections
- Resistance decay: 10% per full sleep cycle
- Side effects: jitters, crashes, health impacts

### Task 31: Add microsleep and hallucination mechanics
**User Story:** As a player, I want extreme exhaustion to create dramatic gameplay moments, so that pushing too hard has memorable consequences beyond simple stat penalties.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Microsleeps cause brief blackouts
  2. Player loses 5-30 minutes during microsleep
  3. Hallucinations show false NPCs/objects
  4. Critical fatigue forces collapse
  5. NPCs comment on player's condition

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Microsleeps trigger randomly at high fatigue
- Hallucinations could reveal assimilated NPCs incorrectly
- Forced collapse requires immediate rest location

### Task 32: Create temporal narrative branching system
**User Story:** As a developer, I want time-based choices to create distinct story paths, so that the game has meaningful replay value based on time management strategies.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Key events locked after certain times
  2. NPCs remember missed appointments
  3. Some content mutually exclusive by time
  4. Different strategies yield different stories
  5. At least 3 major branch points

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Track "point of no return" moments
- Some branches only available to efficient players
- Emergency choices for time-crunched situations

### Task 33: Implement flexible scheduling and time optimization
**User Story:** As an experienced player, I want to optimize my time usage, so that mastery of the game systems allows me to accomplish more within time constraints.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Some activities can be shortened with skill
  2. Efficient routes save travel time
  3. Multitasking options for compatible activities
  4. Schedule flexibility increases with relationships
  5. Time bonuses for good performance

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Quick dialog options for repeat conversations
- Fast travel unlocked through exploration
- Some NPCs offer schedule flexibility when befriended

### Task 34: Add activity interruption and resumption system
**User Story:** As a player, I want to interrupt long activities for emergencies, so that I can respond to urgent situations without losing all progress on current tasks.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Long activities can be paused
  2. Progress saved when interrupted
  3. Can resume with small time penalty
  4. Some activities cannot be interrupted
  5. NPCs react to interruptions appropriately

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Interruption penalty: 10-30 minutes depending on activity
- Critical activities marked as non-interruptible
- Save interruption state in serialization

### Task 35: Create time pressure visualization UI
**User Story:** As a player, I want clear visual feedback about time pressure, so that I can feel the mounting tension and make informed decisions quickly.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Deadline countdown timers visible
  2. Clock speed visualization during time skip
  3. Fatigue meter with stage indicators
  4. Schedule conflict warnings prominent
  5. Time remaining for current activity shown

**Implementation Notes:**
- Reference: docs/design/time_management_system_full.md
- Use color coding: green->yellow->red for urgency
- Pulsing effects for imminent deadlines
- Integrate with existing time display UI

## Testing Criteria
- Economy transactions process correctly
- Save/sleep operation is atomic and reliable
- Morning reports generate appropriate content
- Barracks district loads and performs well
- Inventory system handles capacity correctly
- All systems integrate with serialization
- UI responds smoothly to all operations
- Save files are valid and loadable
- Deadlines track and warn appropriately
- Deadline conflicts detected accurately
- Fatigue affects gameplay as designed
- Stimulants work with diminishing returns
- Microsleeps and hallucinations trigger correctly
- Time-based narrative branches lock properly
- Schedule optimization mechanics function
- Activity interruption saves progress correctly
- Time pressure UI provides clear feedback

## Timeline
- Start date: After Iteration 6 completion
- Target completion: 2-3 weeks (complex integration)
- Critical for: Phase 1 completion

## Dependencies
- Iteration 4: Serialization (save system foundation)
- Iteration 5: Time System (sleep advances time)
- Iteration 5: Notification System (save confirmations)
- Iteration 6: Character System (save character data)

## Code Links
- src/core/economy/economy_manager.gd (to be created)
- src/core/save/save_manager.gd (to be created)
- src/core/save/morning_report_manager.gd (to be created)
- src/districts/barracks/ (to be created)
- src/core/inventory/inventory_manager.gd (to be created)
- src/ui/inventory/inventory_ui.gd (to be created)
- docs/design/economy_system_design.md
- docs/design/save_system_design.md
- docs/design/sleep_system_design.md
- docs/design/morning_report_manager_design.md
- docs/design/barracks_system_design.md
- docs/design/inventory_system_design.md
- docs/design/inventory_ui_design.md
- docs/design/time_management_system_mvp.md (already in iteration 5)
- docs/design/time_management_system_full.md (extends MVP with advanced features)

## Notes
- Save/Sleep are intentionally coupled to prevent save-scumming
- Economy balance will need extensive playtesting
- Morning reports add narrative flavor and information
- Barracks serves as tutorial area for many systems
- Inventory is simplified for MVP, expandable later
- Time Management Full extends the MVP from Iteration 5 with advanced scheduling