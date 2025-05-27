# Iteration 10: Advanced NPC Systems

## Epic Description
**Phase**: 2 - Full Systems  
**Cohesive Goal**: "NPCs have routines, relationships, and can be disguised as"

As a player, I want to interact with NPCs who feel like real people with their own relationships, daily routines, and secrets, while being able to disguise myself to infiltrate their social circles and uncover the truth about the assimilation.

## Goals
- Implement NPC Trust/Relationship System
- Create Full NPC Templates with all behaviors
- Implement complete NPC Daily Routines
- Build Disguise System for infiltration gameplay
- Establish social simulation foundation
- Create believable station inhabitants

## Requirements

### Business Requirements
- **B1:** Develop deep NPC relationships and trust mechanics
  - **Rationale:** Social gameplay adds strategic depth and replayability
  - **Success Metric:** Player choices meaningfully affect NPC relationships

- **B2:** Enable disguise mechanics for stealth gameplay
  - **Rationale:** Alternative playstyles increase player agency
  - **Success Metric:** Players can successfully infiltrate using disguises

- **B3:** Create living NPCs with believable behaviors
  - **Rationale:** Immersive world requires NPCs that feel alive
  - **Success Metric:** Players report NPCs feel like real people

### User Requirements
- **U1:** As a player, I want to build relationships with NPCs
  - **User Value:** Social gameplay adds depth and personalization
  - **Acceptance Criteria:** Trust levels affect dialog options and quest availability

- **U2:** As a player, I want to use disguises for infiltration
  - **User Value:** Alternative approaches enable creative problem solving
  - **Acceptance Criteria:** Disguises grant access to restricted areas and fool NPCs

- **U3:** As a player, I want NPCs to have predictable routines
  - **User Value:** Learning patterns enables strategic planning
  - **Acceptance Criteria:** NPCs follow schedules with logical activities

### Technical Requirements
- **T1:** Design scalable relationship tracking system
  - **Rationale:** Many NPCs with interconnected relationships
  - **Constraints:** Must handle 150+ NPCs efficiently

- **T2:** Create flexible disguise detection mechanics
  - **Rationale:** Different NPCs should have different detection abilities
  - **Constraints:** Must integrate with existing suspicion system

- **T3:** Implement performance-optimized routine system
  - **Rationale:** Many NPCs with complex schedules could impact FPS
  - **Constraints:** LOD system for distant NPCs

## Tasks

### Trust and Relationship System
- [ ] Task 1: Create RelationshipManager singleton
- [ ] Task 2: Implement trust level mechanics
- [ ] Task 3: Build relationship graph structure
- [ ] Task 4: Create relationship UI display
- [ ] Task 5: Add relationship-based dialog branches

### NPC Template Enhancement
- [ ] Task 6: Expand BaseNPC with full behavior set
- [ ] Task 7: Create personality trait system
- [ ] Task 8: Implement memory system for NPCs
- [ ] Task 9: Add emotional state tracking
- [ ] Task 10: Build NPC reaction tables

### Daily Routine System
- [ ] Task 11: Enhance schedule system from MVP
- [ ] Task 12: Add routine interruption handling
- [ ] Task 13: Create activity animations/states
- [ ] Task 14: Implement need-based behaviors
- [ ] Task 15: Add routine variation system

### Disguise System
- [ ] Task 16: Create DisguiseManager
- [ ] Task 17: Implement clothing/uniform system
- [ ] Task 18: Build identity verification mechanics
- [ ] Task 19: Add disguise effectiveness ratings
- [ ] Task 20: Create disguise detection system

### Social Integration
- [ ] Task 21: Implement social group dynamics
- [ ] Task 22: Create gossip/information spread
- [ ] Task 23: Add faction reputation tracking
- [ ] Task 24: Build social event system
- [ ] Task 25: Implement relationship consequences

### Advanced Tram Transportation System
- [ ] Task 26: Implement ring-based district layout with distance calculation
- [ ] Task 27: Create dynamic pricing system with time/demand modifiers
- [ ] Task 28: Build transit screen with route visualization
- [ ] Task 29: Implement transit event system with NPC encounters
- [ ] Task 30: Add transit passes and subscription system
- [ ] Task 31: Create route disruption mechanics
- [ ] Task 32: Implement transit security and scanning
- [ ] Task 33: Add coalition transit benefits
- [ ] Task 34: Build emergency transit mechanics
- [ ] Task 35: Create economic pressure through travel costs

## User Stories

### Task 2: Implement trust level mechanics
**User Story:** As a player, I want my actions to build or destroy trust with NPCs, so that my choices have meaningful social consequences throughout the game.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Trust levels: Hostile (-100), Suspicious (-50), Neutral (0), Friendly (50), Trusted (100)
  2. Actions modify trust incrementally
  3. Trust affects available dialog options
  4. Trust changes trigger NPC reactions
  5. Trust persists across sessions

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md
- Trust changes: Help (+10), Betray (-30), Small talk (+2)
- Consider trust decay over time without interaction
- Different NPCs have different trust gain rates

### Task 8: Implement memory system for NPCs
**User Story:** As an NPC, I want to remember my interactions with the player, so that our relationship feels continuous and meaningful across multiple encounters.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T1
- **Acceptance Criteria:**
  1. NPCs remember last 10 interactions
  2. Memory affects future dialog
  3. Significant events never forgotten
  4. Memories can be shared between NPCs
  5. Memory saves with game state

**Implementation Notes:**
- Memory types: Interactions, Promises, Betrayals, Shared_Events
- Use circular buffer for recent memories
- Flag important memories as permanent
- Consider "gossip" system for memory sharing

### Task 14: Implement need-based behaviors
**User Story:** As an NPC, I want to fulfill my basic needs throughout the day, so that my routine feels natural and provides opportunities for player interaction.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Needs: Hunger, Rest, Social, Work, Entertainment
  2. Needs drive routine priorities
  3. Unfulfilled needs affect mood
  4. Player can help fulfill needs
  5. Needs create predictable patterns

**Implementation Notes:**
- Need levels: 0-100, decay at different rates
- Activities fulfill specific needs
- Emergency behaviors when needs critical
- Reference: Living world design docs

### Task 18: Build identity verification mechanics
**User Story:** As a player in disguise, I want to pass identity checks through various means, so that infiltration requires preparation and quick thinking.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. ID checks at security points
  2. Knowledge tests from suspicious NPCs
  3. Behavioral consistency requirements
  4. Biometric scans for high security
  5. Backup plans when caught

**Implementation Notes:**
- Reference: docs/design/disguise_clothing_system_design.md
- Verification types: Visual, Verbal, Documentation, Biometric
- Quick-time events for tense moments
- Consider allowing bluff/persuasion options

### Task 26: Implement ring-based district layout with distance calculation
**User Story:** As a player, I want travel costs to reflect actual distances, so that strategic planning of my routes saves both time and money.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. 7 districts in ring configuration
  2. Calculate shortest path (clockwise/counter)
  3. Distance-based pricing: 10cr per hop
  4. Distance-based time: 30min per hop
  5. Maximum 3 hops to any destination

**Implementation Notes:**
- Districts: Spaceport→Security→Medical→Mall→Trading→Barracks→Engineering→(loop)
- Always calculate both directions
- Show route on station map

### Task 27: Create dynamic pricing system with time/demand modifiers
**User Story:** As a player, I want tram prices to reflect station conditions, so that the economic system feels reactive and alive.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Rush hour pricing (+50-80%)
  2. Late night discount (-50%)
  3. Surge pricing in crisis areas
  4. Corruption affects all prices
  5. Coalition discounts available

**Implementation Notes:**
- Morning rush: 07:00-09:00
- Evening rush: 17:00-19:00
- Integrate with AssimilationManager for corruption

### Task 28: Build transit screen with route visualization
**User Story:** As a player, I want to see my journey progress visually, so that travel time feels meaningful and engaging.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. Animated route progress bar
  2. Show each district stop
  3. Display time remaining
  4. Show current location
  5. Random event notifications

**Implementation Notes:**
- Non-skippable travel sequence
- Opportunity for ambient storytelling
- Show other passengers occasionally

### Task 29: Implement transit event system with NPC encounters
**User Story:** As a player, I want interesting encounters during travel, so that tram journeys offer gameplay opportunities beyond mere transportation.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. 10-20% chance of events per trip
  2. Event types: social, security, criminal
  3. Coalition members can pass intel
  4. Pickpocket attempts possible
  5. Overhear useful rumors

**Implementation Notes:**
- Events influenced by current game state
- Security checks more common near Security district
- More events during longer trips

### Task 30: Add transit passes and subscription system
**User Story:** As a player, I want to purchase travel passes for savings, so that I can optimize my credits for frequent travel.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Daily pass: 50cr unlimited travel
  2. Weekly pass: 200cr unlimited travel
  3. 10-ride pass: 80cr with 20% discount
  4. Pass UI in tram stations
  5. Active passes shown in inventory

**Implementation Notes:**
- Passes great for investigation-heavy days
- Must balance with starting credits
- Consider theft/loss mechanics

### Task 31: Create route disruption mechanics
**User Story:** As a player, I want to adapt to transportation disruptions, so that the world feels dynamic and unpredictable.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, T3
- **Acceptance Criteria:**
  1. Maintenance delays (extra time)
  2. Security lockdowns (route blocked)
  3. Power failures (slow travel)
  4. Assimilated vandalism
  5. Alternative route calculations

**Implementation Notes:**
- Disruptions last 1-4 hours
- Force players to adapt plans
- More common as assimilation spreads

### Task 32: Implement transit security and scanning
**User Story:** As a player, I want to navigate security checks strategically, so that carrying contraband creates meaningful risk/reward decisions.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Random security scans (5-50% based on alert)
  2. Contraband detection chance varies
  3. Confiscation and suspicion increase
  4. Bribery possible with right NPCs
  5. Coalition can warn of checkpoints

**Implementation Notes:**
- Integrate with global suspicion system
- Higher security near Security district
- Create tension for smuggling quests

### Task 33: Add coalition transit benefits
**User Story:** As a coalition member, I want transit advantages from our network, so that organizing resistance provides tangible benefits.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Allied conductors give discounts
  2. Warning system for security checks
  3. Emergency extraction option
  4. Hidden compartments for items
  5. Coalition credits for group travel

**Implementation Notes:**
- Benefits scale with coalition size
- Conductors must be recruited first
- Emergency extraction very expensive

### Task 34: Build emergency transit mechanics
**User Story:** As a player in crisis, I want emergency travel options, so that desperate situations have desperate solutions.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Emergency loans for travel
  2. Stowaway option (high risk)
  3. Coalition extraction service
  4. Barter for passage
  5. Maintenance tunnel access

**Implementation Notes:**
- Each option has consequences
- Creates drama when broke
- Last resort mechanics

### Task 35: Create economic pressure through travel costs
**User Story:** As a player, I want travel expenses to create meaningful economic decisions, so that every credit spent on transport affects my survival.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Full Implementation)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Daily travel consumes 20-30% of income
  2. Investigation requires expensive travel
  3. Being broke truly limits movement
  4. Creates "trapped in district" scenarios
  5. Forces resource management

**Implementation Notes:**
- Balance: Starting 100cr = 5-10 trips
- Essential travel vs investigation
- Major choice pressure

## Testing Criteria
- Trust levels change appropriately
- NPC memories persist correctly
- Routines execute without breaking
- Disguises fool appropriate NPCs
- Social dynamics create emergent stories
- Performance stays smooth with many NPCs
- All systems integrate properly
- Save/load preserves all NPC states

## Timeline
- Start date: After Iteration 9
- Target completion: 3 weeks (complex systems)
- Critical for: Social gameplay foundation

## Dependencies
- Iteration 9: Detection system (for disguise integration)
- Iteration 8: Living World MVP (routine foundation)
- Iteration 2: Base NPC system

## Code Links
- src/core/social/relationship_manager.gd (to be created)
- src/characters/npc/npc_memory.gd (to be created)
- src/characters/npc/npc_routine_full.gd (to be created)
- src/core/disguise/disguise_manager.gd (to be created)
- src/characters/npc/base_npc_full.gd (to be created)
- docs/design/npc_trust_relationship_system_design.md
- docs/design/disguise_clothing_system_design.md
- docs/design/template_npc_design.md

## Notes
- NPCs are the heart of the social simulation
- Trust system enables pacifist playthroughs
- Disguise system offers stealth alternative
- Routines create investigation opportunities
- This iteration brings NPCs to life