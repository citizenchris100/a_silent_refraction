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

## Testing Criteria
- Economy transactions process correctly
- Save/sleep operation is atomic and reliable
- Morning reports generate appropriate content
- Barracks district loads and performs well
- Inventory system handles capacity correctly
- All systems integrate with serialization
- UI responds smoothly to all operations
- Save files are valid and loadable

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

## Notes
- Save/Sleep are intentionally coupled to prevent save-scumming
- Economy balance will need extensive playtesting
- Morning reports add narrative flavor and information
- Barracks serves as tutorial area for many systems
- Inventory is simplified for MVP, expandable later