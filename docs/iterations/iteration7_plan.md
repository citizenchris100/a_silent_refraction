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
- [ ] Task 6: Create Basic Shop System Architecture
- [ ] Task 7: Implement Core Shop Items
- [ ] Task 8: Create Basic Job Infrastructure

### Save/Sleep System
- [ ] Task 9: Create SaveManager (extends SerializationManager)
- [ ] Task 10: Implement sleep locations and costs
- [ ] Task 11: Create sleep UI with save confirmation
- [ ] Task 12: Implement save file management (single slot)
- [ ] Task 13: Add save failure handling

### Morning Report System
- [ ] Task 14: Create MorningReportManager
- [ ] Task 15: Implement event collection during sleep
- [ ] Task 16: Design morning report UI
- [ ] Task 17: Create report generation logic
- [ ] Task 18: Add priority/severity system for events

### Barracks District
- [ ] Task 19: Create Barracks district scene
- [ ] Task 20: Implement player quarters (Room 306)
- [ ] Task 21: Add quarter customization basics
- [ ] Task 22: Create storage system in quarters
- [ ] Task 23: Add Barracks common areas

### Inventory System
- [ ] Task 24: Create InventoryManager with dual storage system
- [ ] Task 25: Implement item data structure with full properties
- [ ] Task 26: Add dual inventory capacity limits (on-person vs barracks)
- [ ] Task 27: Create comprehensive inventory UI with grid and barracks interface
- [ ] Task 28: Implement item usage system
- [ ] Task 29: Implement item degradation system
- [ ] Task 30: Create stackable item management
- [ ] Task 31: Build barracks storage transfer mechanics
- [ ] Task 32: Implement item category system
- [ ] Task 33: Create item selling mechanics
- [ ] Task 34: Add contraband detection system
- [ ] Task 35: Implement container system basics

### Advanced Time Management
- [ ] Task 36: Create DeadlineManager for time-sensitive objectives
- [ ] Task 37: Implement deadline conflict detection system
- [ ] Task 38: Add cascading consequence analysis for missed deadlines
- [ ] Task 39: Create complex fatigue system with gameplay effects
- [ ] Task 40: Implement stimulant usage with diminishing returns
- [ ] Task 41: Add microsleep and hallucination mechanics
- [ ] Task 42: Create temporal narrative branching system
- [ ] Task 43: Implement flexible scheduling and time optimization
- [ ] Task 44: Add activity interruption and resumption system
- [ ] Task 45: Create time pressure visualization UI

## User Stories

### Task 1: Create EconomyManager singleton
**User Story:** As a developer, I want a centralized economy system, so that all credit transactions are managed consistently throughout the game.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Singleton manages player credits
  2. Thread-safe transaction methods
  3. Signal emissions for UI updates
  4. Integration with save system
  5. Debug commands for testing

**Implementation Notes:**
- Reference: docs/design/economy_system_design.md lines 26-60 (EconomyManager)
- Autoload singleton pattern
- Starting balance: 100 credits
- Emit balance_changed signal
- Log all transactions

### Task 2: Implement credit balance tracking
**User Story:** As a player, I want to see my current credit balance at all times, so that I can make informed economic decisions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Current balance always visible
  2. Balance updates immediately
  3. Cannot go negative
  4. Formatted with commas
  5. Shows in multiple UIs

**Implementation Notes:**
- Reference: docs/design/economy_system_design.md (UI integration)
- Display in HUD corner
- Update on any transaction
- Flash on changes
- Consider color coding

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
- Reference: docs/design/economy_system_design.md lines 62-88 (transaction methods)
- Transaction types: PURCHASE, SALARY, RENT, FINE, QUEST_REWARD
- Log last 50 transactions for debugging

### Task 6: Create Basic Shop System Architecture
**User Story:** As a player, I want to purchase items from shops using my credits, so that I can acquire necessary items like civilian clothes for the First Quest.

**Design Reference:** `docs/design/economy_system_design.md` (MVP Implementation)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. ShopSystem base class implemented
  2. Purchase mechanics validate credit balance
  3. Integration with EconomyManager for transactions
  4. Support for Mall district shops
  5. Purchase success/failure notifications via PromptNotificationSystem

**Implementation Notes:**
- Reference: docs/design/economy_system_design.md (Shop System section)
- Focus on MVP features: fixed prices, simple inventory
- Mall shops priority for First Quest requirement
- Use transaction system from Task 3

### Task 7: Implement Core Shop Items
**User Story:** As a player, I want essential items available for purchase in shops, so that I can buy civilian clothes and other necessities for gameplay.

**Design Reference:** `docs/design/economy_system_design.md` (MVP Implementation)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Civilian clothes item (required for First Quest)
  2. Basic necessities (food, water)
  3. Fixed pricing structure
  4. Items integrate with inventory system
  5. Shop inventory data structure defined

**Implementation Notes:**
- Reference: docs/design/economy_system_design.md (MVP Data Examples)
- Civilian clothes: 75 credits (as per design)
- Food ration: 10 credits
- Simple ShopItem resource structure

### Task 8: Create Basic Job Infrastructure
**User Story:** As a player, I want to work jobs to earn credits, so that I can afford necessary purchases and manage my economic survival.

**Design Reference:** `docs/design/economy_system_design.md` (MVP Implementation)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Job execution framework
  2. Time-based job completion
  3. Credit rewards on completion
  4. Support for patrol "job" in First Quest
  5. Integration with TimeManager

**Implementation Notes:**
- Reference: docs/design/economy_system_design.md (Job System section)
- Mall Security job: 4 hours, 50 credits
- Basic job states: not_started, in_progress, completed
- Schedule completion with TimeManager

### Task 11: Create sleep UI with save confirmation
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
- Reference: docs/design/save_system_design.md (save UI requirements)
- Reference: docs/design/sleep_system_design.md (sleep-to-save mechanics)
- Reference: docs/design/prompt_notification_system_design.md (UI integration)
- Use PromptNotificationSystem for confirmations
- Show last save: "Day 5, 14:30 - 3 hours played"

### Task 15: Implement event collection during sleep
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
- Reference: docs/design/morning_report_manager_design.md (event collection)
- Reference: docs/design/sleep_system_design.md (overnight progression)
- Events have priority levels for report ordering
- Maximum 10 events shown in report

### Task 24: Create InventoryManager with dual storage system
**User Story:** As a player, I want to manage both my on-person inventory and barracks storage, so that I can strategically decide what to carry and what to store safely.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Personal inventory with 10-slot limit
  2. Barracks storage with infinite capacity
  3. Transfer items between storages at barracks
  4. Access control for barracks storage
  5. Different UI states for each storage type

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 25-169 (InventoryManager class)
- Reference: docs/design/barracks_system_design.md (storage access mechanics)
- Implement storage duality concept
- Personal slots always accessible
- Barracks requires physical presence
- Consider future expansion to more slots

### Task 25: Implement item data structure with full properties
**User Story:** As a developer, I want a comprehensive item system that supports all gameplay features, so that items can have varied properties and behaviors.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. ItemData resource with all properties
  2. Support for stackable/non-stackable items
  3. Item categories and types
  4. Degradation and condition tracking
  5. Custom data for quest items

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 182-209 (ItemData resource)
- Reference: docs/design/disguise_clothing_system_design.md (disguise item properties)
- Reference: docs/design/district_access_control_system_design.md (key item properties)
- Create ItemData and ItemInstance classes
- Properties: id, name, description, icon, stackable, category
- Support illegal flag for contraband
- Include disguise and key properties

### Task 26: Add dual inventory capacity limits (on-person vs barracks)
**User Story:** As a player, I want clear capacity limits that create meaningful decisions about what to carry, so that inventory management becomes a strategic element.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Personal inventory limited to 10 slots
  2. Barracks storage unlimited
  3. Clear UI indication of capacity
  4. Cannot exceed personal limit
  5. Full inventory notifications

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 9-13 (Storage Duality)
- Reference: docs/design/inventory_system_design.md lines 720-742 (Balance Considerations)
- Slots not weight-based
- Essential items take 2-3 slots minimum
- Create inventory pressure mechanic
- Future: expandable personal slots

### Task 27: Create comprehensive inventory UI with grid and barracks interface
**User Story:** As a player, I want intuitive interfaces for both my personal inventory and barracks storage, so that I can easily manage items in both locations.

**Interactive Object Migration Phase 1c & 2c:** This task implements visual representation for takeable objects and inventory integration.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Grid-based personal inventory (5x2 layout)
  2. List-based barracks storage UI
  3. Drag-and-drop between storages
  4. Category filtering for both
  5. Visual feedback for all actions
  6. **Phase 1c:** Interactive objects have visual sprites
  7. **Phase 2c:** Takeable objects integrate with inventory

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 620-690 (UI Components)
- Reference: docs/design/inventory_ui_design.md (detailed UI specifications)
- Reference: docs/design/template_interactive_object_design.md lines 152-177 (visual system)
- Personal: 5x2 grid = 10 slots
- Barracks: Scrollable list with quantities
- Transfer UI when at barracks
- **Phase 1c:** Add visual system to interactive_object.gd
- **Phase 2c:** Add takeable functionality

### Task 28: Implement item usage system
**User Story:** As a player, I want to use items from my inventory to solve puzzles and interact with the world, so that collected items have meaningful purposes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Items can be "used" from inventory
  2. Context-sensitive item actions
  3. Item degradation on use
  4. Consumables properly consumed
  5. Clear feedback on item use

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 379-394 (use_item method)
- Reference: docs/design/verb_ui_system_refactoring_plan.md (verb integration)
- Integrate with verb system
- Support item combinations
- Handle degradable items
- Remove consumables after use

### Task 29: Implement item degradation system
**User Story:** As a player, I want items to degrade with use, so that resource management includes maintaining my tools and equipment.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Items have condition value (0.0-1.0)
  2. Usage reduces condition
  3. Broken items unusable
  4. Visual indication of condition
  5. Some items non-degradable

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 379-394 (Degradation System)
- Reference: docs/design/inventory_system_design.md lines 205-209 (condition tracking)
- Degradation rate varies by item
- 0.1 reduction per use typical
- Broken items remain in inventory
- Future: repair mechanics

### Task 30: Create stackable item management
**User Story:** As a player, I want similar items to stack together, so that consumables and resources don't fill my limited inventory slots.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Stackable items combine in one slot
  2. Stack limits per item type
  3. Split stack functionality
  4. Clear quantity display
  5. Proper addition/removal from stacks

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 65-92 (stackable logic)
- Reference: docs/design/inventory_system_design.md lines 341-360 (MVP Item Examples)
- Food rations: max stack 5
- Credits stack infinitely
- Most items non-stackable
- UI shows quantities clearly

### Task 31: Build barracks storage transfer mechanics
**User Story:** As a player, I want to easily transfer items between my personal inventory and barracks storage, so that I can organize my items efficiently.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Transfer UI at barracks location
  2. Bulk transfer options
  3. Quick deposit/withdraw
  4. Loadout system support
  5. Access control verification

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 102-138 (transfer methods)
- Reference: docs/design/barracks_system_design.md (access control)
- Must be physically at barracks
- Support "transfer all" options
- Maintain access state
- Handle eviction scenarios

### Task 32: Implement item category system with smart storage management
**User Story:** As a player, I want items organized by category with smart storage features, so that I can quickly find what I need and efficiently manage my limited inventory space.

**Design Reference:** `docs/design/inventory_system_design.md` lines 427-463 (Smart Storage Management section)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Categories: misc, tool, disguise, quest, consumable
  2. Filter UI by category
  3. Auto-sort by category option with customizable order
  4. Category icons/colors
  5. Search within categories
  6. **Quick loadout system for predefined item sets**
  7. **Save/load up to 5 named loadouts**
  8. **Loadout swap only available at barracks**
  9. **One-click "transfer all to barracks" option**
  10. **Smart sort prioritizes quest items, then tools, then consumables**

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 193 (category property)
- Reference: docs/design/inventory_system_design.md lines 427-439 (auto_sort_inventory method)
- Reference: docs/design/inventory_system_design.md lines 441-463 (loadout system)
- Categories affect shop organization
- Quest items always visible and sorted first
- Sort order customizable via settings
- Quick category switching via hotkeys
- Implement save_loadout(name) and load_loadout(name) methods
- Loadouts stored as name: Array of item_ids in saved_loadouts Dictionary
- Maximum 5 loadouts initially (expandable later)
- Loadout UI shows saved configurations with custom names

### Task 33: Create item selling mechanics
**User Story:** As a player, I want to sell unwanted items for credits, so that I can convert excess items into needed funds.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Sell items at shops
  2. Value based on item properties
  3. Illegal items worth more but risky
  4. Cannot sell quest items
  5. Transaction integration

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 295-314 (sell_item method)
- Reference: docs/design/economy_system_design.md (transaction integration)
- Reference: docs/design/suspicion_system_full_design.md (illegal item suspicion)
- Base value in ItemData
- Illegal items 2x value
- Selling illegal adds suspicion
- Integrate with economy system

### Task 34: Add contraband detection system
**User Story:** As a player, I want to understand the risks of carrying illegal items, so that I can make informed decisions about smuggling versus safety.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Items marked as illegal/contraband
  2. Security scans detect contraband
  3. Carrying illegal items increases suspicion
  4. Different detection rates
  5. Visual warning for illegal items

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 513-536 (Suspicion Integration)
- Reference: docs/design/suspicion_system_full_design.md (contraband mechanics)
- Reference: docs/design/detection_game_over_system_design.md (security scanning)
- 5 suspicion per illegal item
- Security checkpoints scan inventory
- Some areas have higher security
- Integrate with detection system

### Task 35: Implement container system basics
**User Story:** As a player, I want to find items in containers throughout the station, so that exploration is rewarded with useful discoveries.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U4
- **Acceptance Criteria:**
  1. Containers in world can be searched
  2. Containers have inventories
  3. Some containers locked
  4. Searched state persists
  5. Container types vary

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 397-426 (Container System)
- Reference: docs/design/template_interactive_object_design.md (base container class)
- Container class extends InteractiveObject
- Contents defined in scene/data
- Locked containers need keys
- One-time searchable

### Task 36: Create DeadlineManager for time-sensitive objectives
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
- Reference: docs/design/time_management_system_full.md (DeadlineManager section)
- Reference: docs/design/quest_log_ui_design.md (deadline display)
- Warning thresholds: 24h, 12h, 6h, 2h before deadline
- Support hidden deadlines revealed through investigation
- Integrate with quest system for objective deadlines

### Task 37: Implement deadline conflict detection system
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

### Task 38: Add cascading consequence analysis for missed deadlines
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

### Task 39: Create complex fatigue system with gameplay effects
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

### Task 40: Implement stimulant usage with diminishing returns
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

### Task 41: Add microsleep and hallucination mechanics
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

### Task 42: Create temporal narrative branching system
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

### Task 43: Implement flexible scheduling and time optimization
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

### Task 44: Add activity interruption and resumption system
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

### Task 45: Create time pressure visualization UI
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
- Shop purchases validate credit balance
- Shop items available in Mall for First Quest
- Basic job system executes and pays credits
- Save/sleep operation is atomic and reliable
- Morning reports generate appropriate content
- Barracks district loads and performs well
- Inventory system handles capacity correctly
- All systems integrate with serialization
- UI responds smoothly to all operations
- Save files are valid and loadable
- Dual storage system works correctly
- Item transfer between storages functions properly
- Item degradation reduces condition appropriately
- Stackable items combine and split correctly
- Item categories filter and sort properly
- Selling items integrates with economy
- Contraband detection increases suspicion
- Containers can be searched and looted
- Barracks access control works as designed
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
- src/core/economy/shop_system.gd (to be created)
- src/core/economy/job_system.gd (to be created)
- src/resources/shop_item.gd (to be created)
- src/resources/job_data.gd (to be created)
- src/core/save/save_manager.gd (to be created)
- src/core/save/morning_report_manager.gd (to be created)
- src/districts/barracks/ (to be created)
- src/core/inventory/inventory_manager.gd (to be created)
- src/ui/inventory/inventory_ui.gd (to be created)
- src/ui/inventory/inventory_grid.gd (to be created)
- src/ui/inventory/barracks_storage_ui.gd (to be created)
- src/resources/item_data.gd (to be created)
- src/core/inventory/item_instance.gd (to be created)
- src/objects/base/container.gd (to be created)
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