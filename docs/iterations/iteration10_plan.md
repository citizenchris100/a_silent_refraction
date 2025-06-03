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
- [ ] Task 25: Implement relationship consequences with social puzzles

### Advanced Tram Transportation System
- [ ] Task 26: Implement ring-based district layout with distance calculation
- [ ] Task 27: Create dynamic pricing system with time/demand modifiers
- [ ] Task 28: Build transit screen with route visualization
- [ ] Task 29: Implement transit event system with NPC encounters
- [ ] Task 30: Add transit passes and subscription system with trust-based puzzle assistance
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

### Mall Squat Sleep System
- [ ] Task 46: Implement Mall maintenance area squat location
- [ ] Task 47: Create forced homeless sleep mechanics
- [ ] Task 48: Add squat sleep penalties and risks

### Coalition Safe House Sleep System
- [ ] Task 49: Implement coalition safe house sleep locations
- [ ] Task 50: Create trust-based safe house access
- [ ] Task 51: Add coalition sleep benefits

### Emergency Wake Events
- [ ] Task 52: Implement emergency wake system
- [ ] Task 53: Create station emergency types
- [ ] Task 54: Add partial rest mechanics

### Advanced Sleep Integration
- [ ] Task 55: Implement overnight detection decay
- [ ] Task 56: Create overnight coalition operations
- [ ] Task 57: Add overnight theft mechanics

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
  9. **Hover Text Integration:** Provides trust-based NPC hover descriptions
  10. **Relationship Awareness:** Connects relationship state to dynamic hover text

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (RelationshipManager)
- Reference: docs/design/scumm_hover_text_system_design.md (NPC State Display section)
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
- **Hover Integration:** Implement relationship-aware hover text provider:
  ```gdscript
  # In RelationshipManager
  func get_npc_relationship_hover_text(npc_id: String) -> String
  func get_trust_level_descriptor(npc_id: String) -> String
  func should_show_relationship_hint(npc_id: String) -> bool
  ```
- **Trust Display:** Connect trust levels to hover descriptions ("wary", "friendly", "suspicious", "trusted")

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
  7. **Hover Text Integration:** Provides memory-based NPC activity descriptions
  8. **Activity Context:** Shows what NPCs are currently doing and why based on their memory/schedule
  7. **Phase 4:** Integration with trust milestone events
  8. Track favors done/owed for reciprocity mechanics
  9. Remember specific trust-building actions

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (Memory System)
- Reference: docs/design/scumm_hover_text_system_design.md (NPC State Display section)
- Memory types: Interactions, Promises, Betrayals, Shared_Events, Trust_Milestones
- **Hover Integration:** Implement activity-aware hover text based on NPC memory and schedule:
  ```gdscript
  # In NPCMemory
  func get_current_activity_description() -> String
  func get_activity_context_for_hover() -> String
  func should_show_activity_details() -> bool
  ```
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

### Task 5: Add relationship-based dialog branches with template dialog integration
**User Story:** As a player, I want NPCs to speak differently based on our relationship using template-driven dialog generation, so that building trust feels rewarding and meaningful through personality-aware conversations.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md`, `docs/design/template_dialog_design.md`

**BaseNPC Migration Phase 2a:** This task establishes the dialog context system that enables personality and relationship-driven conversations with template dialog support.

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
  8. **Template Integration:** Context passed to template dialog generation
  9. **Template Integration:** Trust level affects template selection
  10. **Template Integration:** Relationship history influences dialog patterns

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md
- Reference: docs/design/template_dialog_design.md (Contextual Dialog System, lines 604-663)
- Trust thresholds: Hostile < -50, Neutral -50 to 50, Friendly > 50
- Trusted NPCs reveal sensitive information
- **Phase 2a:** Implement dialog context structure compatible with template system:
  ```gdscript
  var dialog_context = {
      "time_of_day": TimeManager.get_time_period(),
      "location": get_current_district(),
      "player_reputation": interaction_memory.player_reputation,
      "is_assimilated": is_assimilated,
      "suspicion_level": suspicion_level,
      "player_gender": GameManager.player_gender,
      "npc_gender": npc_gender,
      "relationship_level": get_relationship_level(),
      "trust_dimensions": get_trust_dimensions(),
      "recent_events": get_recent_relationship_events()
  }
  ```
- **Phase 2a:** Pass context to all dialog generation methods
- **Template Integration:** Connect context to template dialog system from Iteration 6
- **Template Integration:** Relationship state affects greeting template selection
- **Template Integration:** Trust level influences topic availability and response tone

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
  6. **Hover Text Integration:** Provides disguise-aware hover descriptions
  7. **Role Awareness:** Shows role-specific object and NPC descriptions based on current disguise

**Implementation Notes:**
- Reference: docs/design/disguise_clothing_system_design.md
- Reference: docs/design/scumm_hover_text_system_design.md (Disguise System Integration section)
- Verification types: Visual, Verbal, Documentation, Biometric
- Quick-time events for tense moments
- Consider allowing bluff/persuasion options
- **Hover Integration:** Implement disguise-aware hover text system:
  ```gdscript
  # In DisguiseManager
  func get_disguise_aware_hover_text(obj: Node) -> String
  func get_role_specific_description(obj: Node, role: String) -> String
  func is_object_accessible_to_role(obj: Node, role: String) -> bool
  ```
- **Role-Based Descriptions:** Objects show different names/descriptions based on player's current role
- **Access Indicators:** Hover text shows "off-limits", "authorized access", "fellow staff member" based on disguise

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

### Task 6: Expand BaseNPC with full behavior set and template dialog personality support
**User Story:** As a developer, I want to enhance BaseNPC to support the full template design with template dialog personality integration, so that all NPCs can utilize advanced features including personality-driven dialog generation without breaking existing functionality.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/template_dialog_design.md`

**BaseNPC Migration Phase 2b-2c:** This task implements personality-driven responses and gender dynamics as core NPC features with template dialog support.

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
  8. **Template Dialog:** Personality traits compatible with template dialog system
  9. **Template Dialog:** Personality affects dialog pattern selection
  10. **Template Dialog:** Formality and verbosity drive template modulation

**Implementation Notes:**
- Reference: docs/design/template_npc_design.md
- Reference: docs/design/template_dialog_design.md (Personality-Driven Generation, lines 381-467)
- Maintain backward compatibility
- Use feature flags for new behaviors
- **Phase 2b:** Implement personality-based dialog modifiers compatible with template system:
  ```gdscript
  if personality.friendliness > 0.7:
      dialog_modifier = "friendly"
  # Also set template personality for dialog generation
  dialog_personality = NPCPersonality.new(personality)
  ```
- **Phase 2c:** Add gender dynamics to personality Dictionary:
  ```gdscript
  personality = {
      "progressiveness": 0.5,
      "sexism_level": 0.3,
      "competitiveness": 0.5,
      "gender_comfort": 0.7,
      "formality": 0.6,          # For template dialog modulation
      "verbosity": 0.4,          # For template dialog modulation
      "friendliness": 0.8        # For template dialog tone
  }
  ```
- **Template Dialog:** Connect personality to template dialog generation from Iteration 6
- **Template Dialog:** Implement NPCPersonality wrapper for template dialog compatibility
- **Template Dialog:** Ensure personality changes affect dialog generation in real-time

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

### Task 46: Implement Mall maintenance area squat location
**User Story:** As a player who has been evicted from barracks, I need a fallback sleep location in the Mall, so that I can continue playing even when I can't afford safe accommodations.

**Design Reference:** `docs/design/save_system_design.md`, `docs/design/sleep_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Hidden maintenance area accessible when evicted
  2. No cost to sleep but increased risks
  3. Discovery chance by security
  4. Poor sleep quality (comfort 0.3)
  5. Wake earlier than barracks (5:00 AM)
  6. Integration with eviction system

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 107-137 (HomelessSquat class)
- Reference: docs/design/sleep_system_design.md (forced sleep mechanics)
- Location: mall_maintenance_area sub-location
- 20% discovery risk per night
- Only available when has_barracks_access = false
- Apply poor sleep penalties to all stats

### Task 47: Create forced homeless sleep mechanics
**User Story:** As a player without barracks access, I need the game to force sleep at midnight, so that I can't avoid the consequences of homelessness but still continue playing.

**Design Reference:** `docs/design/sleep_system_design.md`, `docs/design/save_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Cannot voluntarily sleep when homeless
  2. Forced sleep at midnight (24:00)
  3. Automatic transport to Mall squat
  4. No player control over sleep timing
  5. Warning system before forced sleep
  6. Integrates with save system

**Implementation Notes:**
- Reference: docs/design/sleep_system_design.md lines 100-150 (forced sleep flow)
- Reference: docs/design/save_system_design.md lines 107-137 (homeless sleep)
- Warnings at 23:30 and 23:45
- Force sleep triggers automatically at midnight
- Use same save integration as barracks sleep
- Spawn player on Mall main floor after sleep

### Task 48: Add squat sleep penalties and risks
**User Story:** As a player sleeping in the Mall squat, I need to face realistic consequences for this risky choice, so that maintaining barracks access feels valuable and the game has meaningful economic pressure.

**Design Reference:** `docs/design/save_system_design.md`, `docs/design/sleep_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Poor sleep reduces morale by 10
  2. Increased base suspicion by 5
  3. 10% chance of item theft
  4. Security discovery triggers consequences
  5. Fatigue recovery reduced (poor sleep penalty)
  6. Morning reports reflect squat risks

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 132-137 (squat penalties)
- Reference: docs/design/sleep_system_design.md (sleep quality effects)
- Apply penalties in handle_security_discovery()
- Integrate with morning report system for theft/discovery events
- Use DetectionManager.increase_base_suspicion(5)
- FatigueSystem.apply_poor_sleep_penalty() reduces recovery

### Task 3: Build relationship graph structure
**User Story:** As a developer, I want NPCs to have interconnected relationships with each other, so that social dynamics create emergent storytelling opportunities.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Relationship Networks)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. NPCs track relationships with other NPCs
  2. Graph structure supports bidirectional connections
  3. Relationship values range from -100 to 100
  4. Updates propagate through network
  5. Efficient queries for relationship chains

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md
- Use adjacency list for performance
- Support relationship types: friend, rival, family, colleague
- Enable pathfinding through social connections

### Task 4: Create relationship UI display
**User Story:** As a player, I want to see my relationships with NPCs visually, so that I can track my social progress and plan interactions.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (UI Components)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. Journal page shows relationship summary
  2. Trust levels displayed with visual bars
  3. Recent interactions listed
  4. Relationship milestones marked
  5. Sort/filter by trust level or faction

**Implementation Notes:**
- Integrate with quest log UI
- Color coding: green (positive), yellow (neutral), red (negative)
- Show multi-dimensional trust breakdown on hover
- Include relationship history timeline

### Task 9: Add emotional state tracking
**User Story:** As an NPC, I want to have emotional states that affect my behavior, so that I react realistically to events and create dynamic interactions.

**Design Reference:** `docs/design/template_npc_design.md` (Emotional States)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Track current emotional state (happy, sad, angry, fearful, neutral)
  2. Emotions affect dialog tone and choices
  3. Recent events influence emotional state
  4. Emotions decay over time to baseline
  5. Visible through animations and hover text

**Implementation Notes:**
- Reference: docs/design/template_npc_design.md
- Emotion values: -1.0 to 1.0 on multiple axes
- Personality affects emotional volatility
- Integrate with dialog system for tone modifiers

### Task 10: Build NPC reaction tables
**User Story:** As a developer, I want NPCs to have consistent reactions to player actions, so that the world responds logically to player choices.

**Design Reference:** `docs/design/template_npc_design.md` (Reaction System)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, T1
- **Acceptance Criteria:**
  1. Define reaction categories (help, harm, ignore, etc.)
  2. Personality modifies reaction intensity
  3. Context affects reaction choice
  4. Reactions trigger appropriate responses
  5. Data-driven for easy modification

**Implementation Notes:**
- Store in JSON reaction tables
- Consider trust level in reaction selection
- Support delayed reactions for complex events
- Enable reaction chaining for escalation

### Task 12: Add routine interruption handling
**User Story:** As an NPC, I want to handle interruptions to my routine gracefully, so that unexpected events don't break my behavior.

**Design Reference:** `docs/design/template_npc_design.md` (Schedule System)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Remember interrupted activity
  2. React appropriately to interruption type
  3. Resume or abandon based on priority
  4. Update schedule dynamically
  5. Communicate disruption to player

**Implementation Notes:**
- Priority levels for activities
- Emergency overrides for critical events
- Grace period before abandoning tasks
- Stack interruptions for complex scenarios

### Task 13: Create activity animations/states
**User Story:** As a player, I want to see NPCs performing their activities visually, so that the world feels alive and inhabited.

**Design Reference:** `docs/design/template_npc_design.md` (Activity System)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Animations for common activities (eating, working, talking)
  2. Props appear during activities
  3. Smooth transitions between states
  4. Activities match schedule entries
  5. Interruptible with appropriate reactions

**Implementation Notes:**
- Use state machine for activity transitions
- Preload common activity animations
- Support location-specific activities
- Enable ambient activity sounds

### Task 15: Add routine variation system
**User Story:** As an NPC, I want my routine to have natural variations, so that I don't feel robotic or completely predictable.

**Design Reference:** `docs/design/template_npc_design.md` (Dynamic Schedules)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. 10-20% time variation in activities
  2. Occasional schedule deviations
  3. Weather/events affect routines
  4. Personality influences variation amount
  5. Core activities remain predictable

**Implementation Notes:**
- Add random factors to schedule timing
- Special events can override routine
- Maintain investigatability despite variations
- Log variations for player discovery

### Task 16: Create DisguiseManager
**User Story:** As a developer, I want a centralized system to manage all disguise mechanics, so that identity verification and role-playing elements work consistently.

**Design Reference:** `docs/design/disguise_clothing_system_design.md` (Core Architecture)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Track current disguise and effectiveness
  2. Calculate detection chances
  3. Manage disguise inventory
  4. Handle quick-change mechanics
  5. Integrate with suspicion system

**Implementation Notes:**
- Reference: docs/design/disguise_clothing_system_design.md
- Singleton pattern for global access
- Support partial disguises
- Track disguise wear and tear

### Task 17: Implement clothing/uniform system
**User Story:** As a player, I want to collect and wear different uniforms, so that I can access restricted areas and blend in with various groups.

**Design Reference:** `docs/design/disguise_clothing_system_design.md` (Clothing System)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Multiple uniform types (security, medical, maintenance)
  2. Visual representation on player
  3. Inventory integration
  4. Condition affects effectiveness
  5. Size/fit considerations

**Implementation Notes:**
- Reference: docs/design/disguise_clothing_system_design.md
- Each uniform has access permissions
- Damaged uniforms less effective
- Some uniforms have special properties

### Task 19: Add disguise effectiveness ratings
**User Story:** As a player, I want to see how effective my disguise is, so that I can gauge the risk of detection before entering dangerous situations.

**Design Reference:** `docs/design/disguise_clothing_system_design.md` (Effectiveness Calculation)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Effectiveness score 0-100%
  2. Factors: completeness, condition, behavior
  3. Visual indicator in UI
  4. Context-sensitive warnings
  5. Real-time updates

**Implementation Notes:**
- Base effectiveness from clothing quality
- Behavior modifiers (walking, running, actions)
- NPC familiarity reduces effectiveness
- Environmental factors (lighting, crowds)

### Task 20: Create disguise detection system
**User Story:** As an NPC, I want to detect suspicious individuals in disguise, so that security feels meaningful and infiltration requires skill.

**Design Reference:** `docs/design/disguise_clothing_system_design.md` (Detection Mechanics)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Detection checks based on proximity and attention
  2. Different NPCs have different detection skills
  3. Gradual suspicion building
  4. Behavioral giveaways increase detection
  5. Environmental factors affect detection

**Implementation Notes:**
- Reference: docs/design/disguise_clothing_system_design.md
- Security NPCs have higher detection
- Close scrutiny increases detection chance
- Quick-time events for tense moments

### Task 21: Implement social group dynamics
**User Story:** As a developer, I want NPCs to form and maintain social groups, so that the station feels like a real community with cliques and alliances.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Social Networks)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. NPCs belong to multiple social groups
  2. Groups have leaders and hierarchies
  3. Group membership affects behavior
  4. Groups can merge or split
  5. Player actions affect group dynamics

**Implementation Notes:**
- Groups: department, shift, social, interest-based
- Group events bring members together
- Gossip spreads faster within groups
- Group loyalty affects trust building

### Task 22: Create gossip/information spread
**User Story:** As a player, I want information to spread naturally through NPC networks, so that my actions have social consequences and reputation matters.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` (Information Networks)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Information spreads based on relationships
  2. Details change/distort over time
  3. Speed based on importance and trust
  4. Player can influence spread
  5. Some NPCs are gossip hubs

**Implementation Notes:**
- Information has accuracy value that degrades
- Trust level affects sharing likelihood
- Critical info spreads faster
- Can plant false information

### Task 23: Add faction reputation tracking
**User Story:** As a player, I want my actions to affect my standing with different factions, so that choices have long-term social consequences.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Faction System)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Multiple factions with different goals
  2. Actions affect faction standing
  3. Standing affects member interactions
  4. Faction conflicts create choices
  5. Reputation unlocks opportunities

**Implementation Notes:**
- Factions: Security, Medical, Labor, Coalition
- Standing: -100 (hostile) to 100 (allied)
- Some actions please one faction but anger another
- High standing unlocks faction-specific content

### Task 24: Build social event system
**User Story:** As a player, I want to participate in social events, so that I can build relationships and discover information in natural settings.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` (Social Events)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Scheduled social gatherings
  2. Dynamic attendee lists
  3. Event-specific interactions
  4. Relationship building opportunities
  5. Information gathering chances

**Implementation Notes:**
- Events: shift meetings, meal times, recreation
- Attendance based on schedules and relationships
- Special dialog options during events
- Can overhear useful information

### Task 25: Implement relationship consequences with social puzzles
**User Story:** As a player, I want my relationships to unlock puzzle solutions and create new obstacles, so that social gameplay integrates with problem-solving.

**Design Reference:** `docs/design/puzzle_system_design.md` (Social Puzzles)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. High trust unlocks cooperation
  2. Low trust creates obstacles
  3. Multiple social solutions to puzzles
  4. Betrayal has lasting consequences
  5. Relationship networks affect solutions

**Implementation Notes:**
- Reference: docs/design/puzzle_system_design.md
- Some puzzles require multiple NPCs
- Trust level gates certain solutions
- Social engineering as puzzle mechanic

### Task 49: Implement coalition safe house sleep locations
**User Story:** As a player allied with the coalition, I want access to safe house sleeping locations, so that I have alternatives when I lose barracks access.

**Design Reference:** `docs/design/sleep_system_design.md` (Coalition System Integration)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Multiple safe house locations
  2. Better than mall squat (80% quality)
  3. No cost but requires trust
  4. Limited availability
  5. Risk of discovery

**Implementation Notes:**
- Reference: docs/design/sleep_system_design.md lines 405-426
- Locations hidden until discovered
- Only available when trust > 50
- Can be compromised by security

### Task 50: Create trust-based safe house access
**User Story:** As a coalition member, I want my trust level to determine safe house access, so that loyalty to the coalition has tangible benefits.

**Design Reference:** `docs/design/sleep_system_design.md` (Coalition Integration)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Trust threshold of 50 for basic access
  2. Higher trust unlocks better locations
  3. Access can be revoked for betrayal
  4. Emergency access in crisis
  5. Shared with other coalition members

**Implementation Notes:**
- Check CoalitionManager.get_trust_level()
- Different safe houses have different requirements
- Emergency override for critical situations
- Track usage to prevent overuse

### Task 51: Add coalition sleep benefits
**User Story:** As a player sleeping in coalition safe houses, I want unique benefits, so that building coalition relationships provides gameplay advantages.

**Design Reference:** `docs/design/sleep_system_design.md` (Coalition Integration)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Coalition members may visit overnight
  2. Information exchange opportunities
  3. Reduced suspicion decay
  4. Access to coalition supplies
  5. Planning sessions before sleep

**Implementation Notes:**
- NPCs share intel during rest
- Can coordinate next day's actions
- Small chance of raid/discovery
- Better morning reports with coalition info

### Task 52: Implement emergency wake system
**User Story:** As a player, I want to be woken by station emergencies, so that critical events feel impactful and sleep isn't always safe.

**Design Reference:** `docs/design/sleep_system_design.md` (Emergency Wake Events)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Emergencies interrupt sleep
  2. Partial rest based on time slept
  3. Emergency type affects urgency
  4. Location affects wake probability
  5. Clear emergency notifications

**Implementation Notes:**
- Reference: docs/design/sleep_system_design.md lines 495-519
- Check EventManager.should_trigger_emergency()
- Calculate partial rest: hours_slept / 6
- Immediate scene transition on wake

### Task 53: Create station emergency types
**User Story:** As a developer, I want various emergency events that can wake the player, so that the world feels dangerous and unpredictable.

**Design Reference:** `docs/design/sleep_system_design.md` (Emergency Types)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Assimilation outbreak events
  2. Coalition raid emergencies
  3. System malfunction alerts
  4. Security lockdown warnings
  5. Different wake probabilities

**Implementation Notes:**
- Each emergency has urgency level
- Some locations immune to certain emergencies
- Barracks less likely to be interrupted
- Consequences for ignoring emergencies

### Task 54: Add partial rest mechanics
**User Story:** As a player woken early, I want to suffer fatigue penalties, so that interrupted sleep has gameplay consequences.

**Design Reference:** `docs/design/sleep_system_design.md` (Partial Rest)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Rest quality based on hours slept
  2. Minimum 2 hours for any benefit
  3. Fatigue penalties for partial rest
  4. Accumulating sleep debt
  5. Visual indicators of exhaustion

**Implementation Notes:**
- Partial rest = hours_slept / 6 * base_quality
- FatigueSystem.apply_partial_rest(percentage)
- Sleep debt increases exhaustion rate
- Multiple interruptions compound penalties

### Task 55: Implement overnight detection decay
**User Story:** As a player, I want my heat level to decrease while sleeping, so that rest provides a strategic way to reduce suspicion.

**Design Reference:** `docs/design/sleep_system_design.md` (Detection System Integration)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Heat decays during sleep
  2. Decay rate varies by location
  3. Barracks provides best decay (70%)
  4. Mall squat adds base suspicion
  5. Integrates with DetectionManager

**Implementation Notes:**
- Reference: docs/design/sleep_system_design.md lines 380-403
- DetectionManager.apply_overnight_decay(rate)
- Barracks: 0.7, Coalition: 0.5, Squat: 0.3
- Squat adds +5 base suspicion

### Task 56: Create overnight coalition operations
**User Story:** As a coalition ally, I want the coalition to conduct operations while I sleep, so that the resistance feels active and independent.

**Design Reference:** `docs/design/sleep_system_design.md` (Coalition Integration)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Coalition missions execute overnight
  2. Success based on member skills
  3. Player absence enables certain ops
  4. Results in morning report
  5. Can fail with consequences

**Implementation Notes:**
- Reference: docs/design/sleep_system_design.md lines 417-426
- CoalitionManager.get_scheduled_overnight_actions()
- Some missions require player absence
- Success affects coalition resources

### Task 57: Add overnight theft mechanics
**User Story:** As a player sleeping rough, I want to risk having items stolen, so that unsafe sleep locations have real consequences.

**Design Reference:** `docs/design/sleep_system_design.md` (Theft Risk)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. 15% theft chance in mall squat
  2. Lose 1-3 random items
  3. Credits prioritized by thieves
  4. Morning report shows losses
  5. Can't lose key/quest items

**Implementation Notes:**
- Reference: docs/design/sleep_system_design.md lines 250-255
- Select items by value/type
- Some items have theft_priority
- Add to overnight_events["theft"]

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
- Mall squat location only accessible when evicted
- Forced sleep triggers correctly at midnight
- Squat sleep penalties apply appropriately
- Security discovery in squat has consequences
- Item theft risk functions in squat
- Coalition safe houses accessible with proper trust
- Safe house sleep quality provides 80% recovery
- Emergency wake events interrupt sleep appropriately
- Partial rest mechanics calculate correctly
- Station emergencies trigger based on conditions
- Overnight detection decay reduces heat levels
- Coalition overnight operations execute properly
- Overnight theft only affects non-critical items
- All sleep locations integrate with save system
- Relationship graph structure performs efficiently
- Emotional states affect NPC behavior
- Social groups form and maintain correctly
- Gossip system spreads information realistically
- Faction reputation affects interactions
- Disguise effectiveness calculations work properly
- Identity verification provides appropriate challenges

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
- src/core/sleep/coalition_sleep_handler.gd (to be created)
- src/core/sleep/emergency_wake_handler.gd (to be created)
- src/core/sleep/overnight_event_processor.gd (to be created)
- src/characters/npc/npc_emotional_state.gd (to be created)
- src/core/social/gossip_manager.gd (to be created)
- src/core/social/faction_manager.gd (to be created)
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