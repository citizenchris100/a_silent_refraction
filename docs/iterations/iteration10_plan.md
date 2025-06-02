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
- Implement Barracks Rent System for economic pressure

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

- **B4:** Establish economic pressure through rent system
  - **Rationale:** Weekly rent creates constant resource management tension
  - **Success Metric:** Players feel economic pressure affects their decisions

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

- **U4:** As a player, I want to manage weekly rent payments
  - **User Value:** Economic survival adds tension and strategic resource planning
  - **Acceptance Criteria:** Weekly rent deducted, warnings given, eviction/re-admittance works

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

- **T4:** Create automated rent collection system
  - **Rationale:** Weekly cycles must integrate with time and economy systems
  - **Constraints:** Must handle save/load across rent cycles

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

### Barracks Rent System
- [ ] Task 36: Create RentManager singleton
- [ ] Task 37: Implement weekly rent collection mechanics
- [ ] Task 38: Add rent warning and notification system
- [ ] Task 39: Create eviction process with grace period
- [ ] Task 40: Implement Concierge re-admittance dialog
- [ ] Task 41: Add rent system UI integration
- [ ] Task 42: Create BarracksSerializer for save/load
- [ ] Task 43: Integrate rent with economic assistance events

### Key NPC Implementation (Phase 2)
- [ ] Task 44: Implement Security Chief NPC with advanced routines
- [ ] Task 45: Create Bank Teller NPC with economic integration

## User Stories

### Task 1: Create RelationshipManager singleton
**User Story:** As a game system, I need a centralized manager to track and maintain all NPC relationships with multi-dimensional trust, so that complex social dynamics can be consistently managed across the entire game.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Core Components - RelationshipManager)

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Singleton RelationshipManager tracks all player-NPC relationships
  2. Stores multi-dimensional RelationshipData for each NPC
  3. Handles trust modifications with personality modifiers
  4. Emits signals for trust changes and milestones
  5. Manages NPC-to-NPC connection networks
  6. Tracks faction standings affecting member trust
  7. Logs interaction history for reference
  8. Provides API for trust queries and modifications

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (RelationshipManager)
- Core structure:
  ```gdscript
  var relationships: Dictionary = {}  # npc_id: RelationshipData
  var npc_connections: Dictionary = {}  # npc_id: {other_npc_id: relationship_value}
  var faction_standings: Dictionary = {}  # faction: reputation_value
  var interaction_history: Array = []
  ```
- Signals: trust_changed, relationship_milestone, trust_decayed, reputation_changed
- Auto-initialize relationships on first access
- Apply personality and gender modifiers to all trust changes

### Task 2: Implement trust level mechanics
**User Story:** As a player, I want my actions to build or destroy trust with NPCs across multiple dimensions (personal, professional, emotional, ideological, fear), so that relationships feel nuanced and my choices have complex social consequences throughout the game.

**BaseNPC Migration Phase 2a:** This task implements the multi-dimensional trust system and dialog context required for personality-driven interactions with gender dynamics.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Multi-dimensional trust: Personal (0-100), Professional (0-100), Emotional (0-100), Ideological (0-100), Fear (0-100)
  2. RelationshipData structure tracks all dimensions with weighted total trust calculation
  3. Actions modify specific trust dimensions based on context
  4. Trust affects available dialog options with dimension-specific thresholds
  5. Trust changes trigger NPC reactions and milestone events
  6. Trust persists across sessions with full dimension data
  7. **Phase 2a:** Dialog context Dictionary passed to all dialog methods
  8. **Phase 2a:** Context includes player_gender and npc_gender fields for gender dynamics
  9. Trust milestone system triggers at key thresholds (30, 50, 70)
  10. Personality modifiers affect trust gain/loss rates

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (Core Components)
- Trust actions: Complete favor (+5 personal, +10 professional), Share story (+8 personal, +5 emotional), Betray (-40 personal, -30 emotional)
- Implement daily trust decay: -1/day after 3 days no interaction (emotional decays fastest at 1.5x)
- Different NPCs have personality-based trust modifiers (paranoid: gains 0.5x, loses 1.5x)
- **Phase 2a:** Full context structure: `{"player_gender": String, "npc_gender": String, "time_of_day": String, "location": String, "player_job": String, "trust_level": float}`
- **Phase 2a:** Store RelationshipData in interaction_memory with all dimensions
- Special relationship flags: knows_player_name, has_shared_meal, saved_their_life, betrayed_trust

### Task 8: Implement memory system for NPCs
**User Story:** As an NPC, I want to remember my interactions with the player including relationship events and favors, so that our relationship history affects trust building and creates meaningful long-term consequences.

**BaseNPC Migration Phase 4:** This task implements the comprehensive memory system with relationship event tracking.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Relationship Memory)

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T1
- **Acceptance Criteria:**
  1. NPCs remember last 10 interactions with trust context
  2. Memory affects future dialog and trust calculations
  3. Significant relationship events never forgotten
  4. Memories can be shared between NPCs (gossip system)
  5. Memory saves with game state including all relationship data
  6. **Phase 4:** Full NPCMemory with relationship tracking
  7. **Phase 4:** Integration with trust milestone events
  8. Track favors done/owed for reciprocity mechanics
  9. Remember specific trust-building actions

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (Memory System)
- Memory types: Interactions, Promises, Betrayals, Shared_Events, Trust_Milestones
- Relationship event structure:
  ```gdscript
  var remembered_events: Array = [
      {"topic": String, "response": String, "time": float, "trust_level": float},
      {"event": "shared_meal", "date": int, "impact": {"emotional": 8, "personal": 5}}
  ]
  ```
- **Phase 4:** Enhanced memory structure:
  ```gdscript
  var interaction_memory: Dictionary = {
      "times_talked": 0,
      "topics_discussed": [],
      "given_quests": [],
      "player_reputation": 0.0,
      "last_interaction_day": -1,
      "favors_done": 0,
      "favors_owed": 0,
      "relationship_milestones": [],
      "trust_actions": []  # Track specific trust-building/damaging actions
  }
  ```
- NPCs reference past events in dialog based on trust level

### Task 5: Add relationship-based dialog branches
**User Story:** As a player, I want NPCs to speak differently based on our relationship, so that building trust feels rewarding and meaningful.

**BaseNPC Migration Phase 2a:** This task establishes the dialog context system that enables personality and relationship-driven conversations.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Dialog options change based on trust level
  2. New dialog branches unlock at higher trust
  3. Hostile NPCs refuse certain conversations
  4. Context affects available responses
  5. Dialog reflects relationship history
  6. **Phase 2a:** Dialog context system implemented
  7. **Phase 2a:** All dialog methods accept context Dictionary

**Implementation Notes:**
- Trust thresholds: Hostile < -50, Neutral -50 to 50, Friendly > 50
- Trusted NPCs reveal sensitive information
- **Phase 2a:** Implement dialog context structure:
  ```gdscript
  var dialog_context = {
      "time_of_day": TimeManager.get_time_period(),
      "location": get_current_district(),
      "player_reputation": interaction_memory.player_reputation,
      "is_assimilated": is_assimilated,
      "suspicion_level": suspicion_level,
      "player_gender": GameManager.player_gender,
      "npc_gender": npc_gender
  }
  ```
- **Phase 2a:** Pass context to all dialog generation methods

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

### Task 6: Expand BaseNPC with full behavior set
**User Story:** As a developer, I want to enhance BaseNPC to support the full template design, so that all NPCs can utilize advanced features without breaking existing functionality.

**BaseNPC Migration Phase 2b-2c:** This task implements personality-driven responses and gender dynamics as core NPC features.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T1
- **Acceptance Criteria:**
  1. BaseNPC supports all template behaviors
  2. Existing NPCs continue functioning
  3. New features are opt-in via configuration
  4. Performance remains acceptable
  5. All state handlers properly implemented
  6. **Phase 2b:** Personality affects dialog generation
  7. **Phase 2c:** Gender dynamics traits fully integrated

**Implementation Notes:**
- Reference: docs/design/template_npc_design.md
- Maintain backward compatibility
- Use feature flags for new behaviors
- **Phase 2b:** Implement personality-based dialog modifiers:
  ```gdscript
  if personality.friendliness > 0.7:
      dialog_modifier = "friendly"
  ```
- **Phase 2c:** Add gender dynamics to personality Dictionary:
  ```gdscript
  personality = {
      "progressiveness": 0.5,
      "sexism_level": 0.3,
      "competitiveness": 0.5,
      "gender_comfort": 0.7
  }
  ```

### Task 7: Create personality trait system
**User Story:** As an NPC, I want personality traits including detailed gender dynamics that affect my behavior, dialog, and trust interactions, so that each character feels unique with realistic social barriers and biases reflective of the 1950s setting.

**BaseNPC Migration Phase 2b-2c:** This task creates the comprehensive personality system with gender-aware trust modifiers.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Personality & Gender Modifiers)

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Personality traits affect dialog tone and trust gain/loss rates
  2. Traits influence NPC reactions with specific modifiers
  3. Gender dynamics create varied trust building barriers
  4. Personality persists across saves
  5. Traits are data-driven (JSON configurable)
  6. **Phase 2b:** Core personality traits with trust modifiers
  7. **Phase 2c:** Comprehensive gender-aware trust dynamics
  8. Gender-profession barriers affect initial trust
  9. Personality types modify trust calculations

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (Trust Modifiers)
- Trait ranges: 0.0 to 1.0
- **Phase 2b:** Core traits with trust effects:
  - personality_type: paranoid (trust gains 0.5x, losses 1.5x), trusting (gains 1.3x, losses 0.7x), analytical (all changes 0.8x), emotional (large changes 1.4x)
  - formality, suspicion, friendliness, verbosity
- **Phase 2c:** Gender trust modifiers:
  - progressiveness (0-1): Affects gender barrier strength
  - sexism_level (0-1): Creates professional trust barriers
  - competitiveness (0-1): Same-gender rivalry reduces professional trust
  - gender_comfort (0-1): Opposite-gender interaction ease
- Gender-profession barriers: female_security (-15), female_dock_worker (-20), male_nurse (-10)
- Progressive NPCs (>0.7) reduce gender barriers by 70%

### Task 11: Enhance schedule system from MVP
**User Story:** As an NPC, I want to follow daily routines and schedules, so that the station feels alive and my behavior is predictable for strategic players.

**BaseNPC Migration Phase 3a-3b:** This task implements the schedule foundation and location awareness for dynamic NPC behavior.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U3, T3
- **Acceptance Criteria:**
  1. NPCs follow time-based schedules
  2. Schedules drive location changes
  3. Activities match current schedule entry
  4. Interruptions handled gracefully
  5. Schedule data loaded from JSON
  6. **Phase 3a:** Basic schedule array structure
  7. **Phase 3b:** Location tracking and transitions

**Implementation Notes:**
- Reference: Living World design docs
- Schedule format matches template design
- **Phase 3a:** Add schedule structure:
  ```gdscript
  var schedule: Array = []
  var current_schedule_index: int = 0
  ```
- **Phase 3b:** Implement location awareness:
  - Track current_location
  - Handle district transitions
  - Update activity based on location

### Task 36: Create RentManager singleton
**User Story:** As a developer, I want a centralized system to manage all rent-related mechanics, so that weekly payments, evictions, and re-admittance are handled consistently.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4, U4, T4
- **Acceptance Criteria:**
  1. Tracks weeks_owed and payment history
  2. Calculates rent based on current status
  3. Manages eviction dates and grace periods
  4. Integrates with TimeManager for weekly cycles
  5. Provides API for other systems

**Implementation Notes:**
- Reference: docs/design/barracks_system_design.md
- Weekly rent: 450 credits
- Grace period: 7 days after first missed payment
- Eviction after 2 weeks of non-payment

### Task 37: Implement weekly rent collection mechanics
**User Story:** As a player, I want rent automatically deducted every Friday, so that I must maintain steady income to keep my housing.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4, U4
- **Acceptance Criteria:**
  1. Rent deducted every Friday (day % 7 == 5)
  2. Successful payment clears debt
  3. Failed payment starts grace period
  4. Transaction logged in EconomyManager
  5. Notification shows payment result

**Implementation Notes:**
- Check happens at day change to Friday
- If insufficient funds, increment weeks_owed
- First failure triggers grace period
- Second failure triggers eviction

### Task 38: Add rent warning and notification system
**User Story:** As a player, I want advance warning about rent payments, so that I can ensure I have sufficient credits before Friday.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4, U4
- **Acceptance Criteria:**
  1. Warning on Wednesday if funds insufficient
  2. Grace period notice shows eviction date
  3. Eviction notice explains re-admittance
  4. All notices use PromptNotificationSystem
  5. Critical deadlines shown in time display

**Implementation Notes:**
- Wednesday warning: 2 days before rent due
- Use notification types: info, warning, critical
- Add to quest log as reminders
- Time display shows "Eviction in X days" when applicable

### Task 39: Create eviction process with grace period
**User Story:** As a player, I want a grace period after missing rent, so that temporary financial hardship doesn't immediately cost me my home.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4, U4
- **Acceptance Criteria:**
  1. 7-day grace period after first missed payment
  2. Must pay 2 weeks rent to avoid eviction
  3. Eviction revokes barracks access
  4. Storage locked but items preserved
  5. Save location changes to mall_squat

**Implementation Notes:**
- Set eviction_date = current_day + 7
- Lock storage with InventoryManager.lock_barracks_storage()
- Update SleepSystem with player_homeless = true
- Add "evicted_from_barracks" flag

### Task 40: Implement Concierge re-admittance dialog
**User Story:** As a player, I want to pay the Concierge to regain barracks access, so that eviction is a setback but not permanent.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4, U4
- **Acceptance Criteria:**
  1. Concierge has context-sensitive dialog
  2. Shows exact amount owed
  3. Payment restores full access
  4. Storage unlocked after payment
  5. Next rent date clearly communicated

**Implementation Notes:**
- Add to Concierge NPC in Iteration 19
- Dialog checks is_evicted() and credits
- Full payment required, no partial payments
- Reset all rent tracking on payment

### Task 41: Add rent system UI integration
**User Story:** As a player, I want to see my rent status at a glance, so that I can plan my finances accordingly.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4, U4
- **Acceptance Criteria:**
  1. Rent status in economy UI
  2. Days until next payment shown
  3. Amount owed if in debt
  4. Calendar shows rent due dates
  5. Color coding for urgency

**Implementation Notes:**
- Green: paid up, Yellow: due soon, Red: overdue/evicted
- Calendar recurring event every Friday
- Show in player stats/journal
- Quick access from economy display

### Task 42: Create BarracksSerializer for save/load
**User Story:** As a player, I want my rent status to persist across game sessions, so that I can't avoid payments by reloading.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T4
- **Acceptance Criteria:**
  1. All rent data serialized
  2. Eviction status preserved
  3. Payment history saved
  4. Grace period dates maintained
  5. Integrates with SaveManager

**Implementation Notes:**
- Extend BaseSerializer
- Priority 30 (medium)
- Save: has_access, weeks_owed, eviction_date, etc.
- Restore evicted state on load

### Task 43: Integrate rent with economic assistance events
**User Story:** As a player in the coalition, I want the possibility of rent assistance, so that strong relationships can help in dire situations.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B4
- **Acceptance Criteria:**
  1. Coalition may offer rent help (trust > 75)
  2. Random assistance events (10% chance)
  3. Economic crisis reduces rent (rare)
  4. Amount varies 100-300 credits
  5. Creates coalition loyalty

**Implementation Notes:**
- Only triggers when weeks_owed > 0
- Requires high coalition trust
- Shows as notification with credits added
- Deepens coalition relationship mechanics

### Task 44: Implement Security Chief NPC with advanced routines
**User Story:** As a player, I want the Security Chief to have complex behaviors and routines, so that security feels like a dynamic force within the station.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` & `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U1, U2
- **Acceptance Criteria:**
  1. Complex daily patrol routes with variations
  2. Responds to security events dynamically
  3. Relationships affect security interactions
  4. Trust level impacts player treatment
  5. Integrates with detection system

**Implementation Notes:**
- Uses enhanced NPC template from this iteration
- High suspicion, high lawfulness personality
- Patrol routes vary based on alert level
- Reference: docs/design/template_npc_design.md

### Task 45: Create Bank Teller NPC with economic integration
**User Story:** As a player, I want the Bank Teller to be a fully realized character, so that economic interactions feel personal rather than purely transactional.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` & `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U1
- **Acceptance Criteria:**
  1. Professional demeanor during business hours
  2. Different personality after hours
  3. Handles all banking transactions
  4. Trust affects loan availability
  5. Gossips about economic events

**Implementation Notes:**
- Medium suspicion, high greed personality
- Key to economic questlines
- Knows about station financial status
- Reference: docs/design/template_npc_design.md

## Testing Criteria
- Trust levels change appropriately
- NPC memories persist correctly
- Routines execute without breaking
- Disguises fool appropriate NPCs
- Social dynamics create emergent stories
- Performance stays smooth with many NPCs
- All systems integrate properly
- Save/load preserves all NPC states
- Rent deducted correctly every Friday
- Eviction process follows proper timeline
- Re-admittance through Concierge works
- Rent persists across save/load cycles

## Timeline
- Start date: After Iteration 9
- Target completion: 3 weeks (complex systems)
- Critical for: Social gameplay foundation

## Dependencies
- Iteration 9: Detection system (for disguise integration)
- Iteration 8: Living World MVP (routine foundation)
- Iteration 2: Base NPC system
- Iteration 7: Economy system (for rent transactions)
- Iteration 5: Time system (for weekly cycles)
- Iteration 5: Notification system (for rent warnings)

## Code Links
- src/core/social/relationship_manager.gd (to be created)
- src/characters/npc/npc_memory.gd (to be created)
- src/characters/npc/npc_routine_full.gd (to be created)
- src/core/disguise/disguise_manager.gd (to be created)
- src/characters/npc/base_npc_full.gd (to be created)
- src/core/economy/rent_manager.gd (to be created)
- src/core/economy/barracks_serializer.gd (to be created)
- docs/design/npc_trust_relationship_system_design.md
- docs/design/disguise_clothing_system_design.md
- docs/design/template_npc_design.md
- docs/design/barracks_system_design.md

## Notes
- NPCs are the heart of the social simulation
- Trust system enables pacifist playthroughs
- Disguise system offers stealth alternative
- Routines create investigation opportunities
- This iteration brings NPCs to life
- Rent system creates constant economic pressure
- Concierge becomes critical NPC for housing