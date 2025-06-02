# Iteration 12: Assimilation and Coalition

## Epic Description
**Phase**: 2 - Full Systems  
**Cohesive Goal**: "The station reacts to assimilation with resistance and multiple endings"

As a player, I experience a living station where the mysterious assimilation spreads dynamically, security responds to threats, and I can build a coalition of allies to fight back, ultimately determining one of multiple possible endings based on my choices.

## Goals
- Implement full Assimilation System with spread mechanics
- Build Coalition/Resistance System for fighting back
- Create Crime/Security Event System
- Develop Multiple Endings Framework
- Establish dynamic world state
- Create emergent narrative possibilities

## Requirements

### Business Requirements
- **B1:** Create dynamic station response to assimilation threat
  - **Rationale:** Living world that reacts to events increases immersion
  - **Success Metric:** Station security and NPCs adapt to assimilation spread

- **B2:** Enable multiple story outcomes through coalition mechanics
  - **Rationale:** Player agency in story resolution increases satisfaction
  - **Success Metric:** At least 5 distinct endings based on player choices

- **B3:** Implement crime and security dynamics
  - **Rationale:** Actions should have consequences in a believable world
  - **Success Metric:** Security responds appropriately to criminal activities

### User Requirements
- **U1:** As a player, I want the station to react to the assimilation threat
  - **User Value:** Dynamic world feels alive and responsive
  - **Acceptance Criteria:** Security increases and NPCs change behavior as threat grows

- **U2:** As a player, I want to build a coalition to fight back
  - **User Value:** Leadership gameplay provides agency
  - **Acceptance Criteria:** Can recruit allies and influence the ending

- **U3:** As a player, I want my choices to determine the outcome
  - **User Value:** Meaningful consequences for decisions
  - **Acceptance Criteria:** Different approaches lead to different endings

### Technical Requirements
- **T1:** Design assimilation spread algorithm
  - **Rationale:** Spread must feel organic but be controllable
  - **Constraints:** Must be deterministic for save/load

- **T2:** Create faction system architecture
  - **Rationale:** Multiple groups with competing interests
  - **Constraints:** Handle complex inter-faction relationships

- **T3:** Implement ending determination logic
  - **Rationale:** Multiple factors influence final outcome
  - **Constraints:** Clear but not obvious ending triggers

## Tasks

### Assimilation System (Core)
- [ ] Task 1: Create AssimilationManager singleton
- [ ] Task 2: Implement infection spread mechanics
- [ ] Task 3: Build assimilation detection methods
- [ ] Task 4: Create visual indicators for infected
- [ ] Task 5: Add assimilation event system

### Assimilation System (Two-Tier Hierarchy)
- [ ] Task 36: Implement leader/drone assimilation types
- [ ] Task 37: Create AssimilatedBehaviors system
- [ ] Task 38: Build leader strategic planning AI
- [ ] Task 39: Implement drone behavioral degradation
- [ ] Task 40: Create leader-drone coordination system

### Assimilation System (Economic Warfare)
- [ ] Task 41: Implement station property value tracking
- [ ] Task 42: Create economic manipulation mechanics
- [ ] Task 43: Build asset transfer system for assimilated
- [ ] Task 44: Implement financial anomaly detection
- [ ] Task 45: Create hostile takeover progression

### Assimilation System (Crime Integration)
- [ ] Task 46: Create DroneCrimeEvents system
- [ ] Task 47: Implement vandalism and property damage
- [ ] Task 48: Build theft and resource drain mechanics
- [ ] Task 49: Create public disturbance events
- [ ] Task 50: Implement coordinated crime waves

### Assimilation System (Advanced Detection)
- [ ] Task 51: Build behavioral pattern analysis
- [ ] Task 52: Create investigation interaction system
- [ ] Task 53: Implement financial investigation mechanics
- [ ] Task 54: Add speech pattern detection
- [ ] Task 55: Create discovery consequence system

### Assimilation System (Serialization)
- [ ] Task 56: Create AssimilationSerializer
- [ ] Task 57: Implement data compression for saves
- [ ] Task 58: Build version migration support
- [ ] Task 59: Add differential serialization
- [ ] Task 60: Create save/load integration tests

### Coalition System
- [ ] Task 6: Create CoalitionManager
- [ ] Task 7: Implement recruitment mechanics
- [ ] Task 8: Build coalition strength tracking
- [ ] Task 9: Create resistance mission system
- [ ] Task 10: Add coalition meeting events

### Crime and Security
- [ ] Task 11: Create SecurityManager
- [ ] Task 12: Implement crime detection system
- [ ] Task 13: Build security alert levels
- [ ] Task 14: Create lockdown mechanics
- [ ] Task 15: Add security response teams

### Multiple Endings
- [ ] Task 16: Create EndingManager
- [ ] Task 17: Define ending conditions
- [ ] Task 18: Build ending determination logic
- [ ] Task 19: Create ending cutscenes
- [ ] Task 20: Implement ending achievements

### World State Integration
- [ ] Task 21: Connect all systems to world state
- [ ] Task 22: Create emergent event system
- [ ] Task 23: Build faction conflict mechanics
- [ ] Task 24: Add news/rumor system
- [ ] Task 25: Implement cascade effects

### Advanced Living World System
- [ ] Task 26: Create advanced event scheduler with conditional chains
- [ ] Task 27: Implement sophisticated NPC state machine
- [ ] Task 28: Build rumor propagation system with accuracy decay
- [ ] Task 29: Create evidence discovery and decay mechanics
- [ ] Task 30: Implement reaction chain system for events
- [ ] Task 31: Add performance optimization for 100+ NPCs
- [ ] Task 32: Create quantum simulation for background NPCs
- [ ] Task 33: Build temporal reputation tracking
- [ ] Task 34: Implement differential serialization for world state
- [ ] Task 35: Create emergent narrative generation system

### Coalition System (Intelligence Network)
- [ ] Task 61: Implement member intelligence gathering
- [ ] Task 62: Create surveillance assignment system
- [ ] Task 63: Build intel report generation
- [ ] Task 64: Add verified/suspected NPC tracking
- [ ] Task 65: Create intel accuracy decay

### Coalition System (Resource Sharing)
- [ ] Task 66: Implement shared credit pool
- [ ] Task 67: Create shared inventory system
- [ ] Task 68: Build safe house management
- [ ] Task 69: Add resource request/contribution mechanics
- [ ] Task 70: Create resource pooling from members

### Coalition System (Advanced Heists)
- [ ] Task 71: Implement heist phase system
- [ ] Task 72: Create role requirements checker
- [ ] Task 73: Build skill check mechanics
- [ ] Task 74: Add heist reward distribution
- [ ] Task 75: Create heist planning interface

### Coalition System (Infiltration & Trust)
- [ ] Task 76: Implement infiltrator detection
- [ ] Task 77: Create infiltration consequences
- [ ] Task 78: Build paranoia mechanics
- [ ] Task 79: Add member verification system
- [ ] Task 80: Create trust building system

### Coalition System (UI Components)
- [ ] Task 81: Create Coalition HQ scene
- [ ] Task 82: Build member list interface
- [ ] Task 83: Implement intelligence board UI
- [ ] Task 84: Add resource management UI
- [ ] Task 85: Create operation planner interface

### Coalition System (Integration & Serialization)
- [ ] Task 86: Create CoalitionSerializer
- [ ] Task 87: Implement coalition-economy integration
- [ ] Task 88: Build coalition-assimilation resistance mechanics
- [ ] Task 89: Add coalition impact on endings
- [ ] Task 90: Create coalition achievement tracking

### Crime Discovery & Reporting System
- [ ] Task 91: Implement crime witness mechanics
- [ ] Task 92: Create NPC crime reporting behavior
- [ ] Task 93: Build player crime interaction choices
- [ ] Task 94: Implement crime discovery system
- [ ] Task 95: Create crime scene investigation mechanics

### Evidence System
- [ ] Task 96: Implement physical evidence generation
- [ ] Task 97: Create evidence decay system
- [ ] Task 98: Build evidence discovery mechanics
- [ ] Task 99: Implement evidence types per crime
- [ ] Task 100: Create evidence UI and tracking

### Player Crime Interactions
- [ ] Task 101: Implement player intervention options
- [ ] Task 102: Create security bribery mechanics
- [ ] Task 103: Build chase sequence system
- [ ] Task 104: Implement hiding from security
- [ ] Task 105: Create consequence system for caught players

### Crime Statistics & Economic Impact
- [ ] Task 106: Create crime statistics tracking
- [ ] Task 107: Implement district crime modifiers
- [ ] Task 108: Build economic impact calculations
- [ ] Task 109: Create social breakdown thresholds
- [ ] Task 110: Implement crime trend analysis

### Crime/Security Serialization
- [ ] Task 111: Create CrimeSecuritySerializer
- [ ] Task 112: Implement crime history persistence
- [ ] Task 113: Build patrol state serialization
- [ ] Task 114: Create security level persistence
- [ ] Task 115: Implement player security record tracking

### Detection Network Integration
- [ ] Task 116: Implement detection network propagation
- [ ] Task 117: Create coalition-based escape routes
- [ ] Task 118: Build detection cooldown mechanics
- [ ] Task 119: Add environmental detection triggers
- [ ] Task 120: Implement bribery mechanics during detection

## User Stories

### Task 2: Implement infection spread mechanics
**User Story:** As the assimilation force, I want to spread through the station population strategically, so that the player faces an evolving and escalating threat.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Infection spreads through close contact
  2. Different NPCs have different resistance
  3. Spread rate affected by security measures
  4. Player actions can slow/accelerate spread
  5. Visual progression of infection stages

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Spread factors: proximity, time, resistance, security
- Stages: Exposed → Infected → Assimilated
- Consider "patient zero" mechanics

### Task 7: Implement recruitment mechanics
**User Story:** As a player, I want to convince NPCs to join the resistance, so that I can build a force capable of fighting the assimilation threat.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. Recruitment based on trust levels
  2. Different NPCs bring different skills
  3. Failed recruitment has consequences
  4. Coalition members can be lost
  5. Size affects available actions

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Skills: Combat, Medical, Technical, Leadership
- Maximum coalition size: 20 active members
- Consider betrayal mechanics

### Task 13: Build security alert levels
**User Story:** As station security, I want to escalate our response based on threat levels, so that we maintain order while adapting to the growing crisis.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Alert levels: Green, Yellow, Orange, Red, Lockdown
  2. Each level has specific restrictions
  3. Player actions influence alert level
  4. Visual/audio indicators for each level
  5. NPC behavior changes with alerts

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Green: Normal operations
- Lockdown: Martial law, shoot on sight
- Consider evacuation scenarios

### Task 17: Define ending conditions
**User Story:** As a player, I want my accumulated choices to lead to a meaningful conclusion, so that my journey feels complete and consequential.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U3, T3
- **Acceptance Criteria:**
  1. At least 5 distinct endings
  2. Clear but not obvious triggers
  3. Ending reflects major choices
  4. Some endings have variations
  5. New game+ considerations

**Implementation Notes:**
- Reference: docs/design/multiple_endings_system_design.md
- Endings: Total Assimilation, Pyrrhic Victory, True Victory, Escape, Sacrifice
- Track: Coalition strength, Assimilation %, Key decisions
- Consider epilogue variations

### Task 26: Create advanced event scheduler with conditional chains
**User Story:** As a developer, I want events to trigger other events conditionally, so that the world feels reactive and player actions have cascading consequences.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Events can have multiple trigger conditions
  2. One event completing can trigger others
  3. Conditional logic based on world state
  4. Chain reactions create emergent stories
  5. All chains properly serialized

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Event types: fixed, conditional, recurring, chain
- Complex conditions: AND/OR logic supported
- Maximum chain depth: 5 to prevent infinite loops

### Task 27: Implement sophisticated NPC state machine
**User Story:** As a player, I want NPCs to have complex internal states that affect their behavior, so that each character feels unique and reactive to the world around them.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. 8 distinct NPC states (Normal, Suspicious, etc.)
  2. States affect dialog and behavior
  3. Transitions based on world events
  4. Knowledge tracking per NPC
  5. Relationship matrices between NPCs

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- States: NORMAL, SUSPICIOUS, INVESTIGATING, PANICKED, ASSIMILATED, MISSING, DETAINED, COALITION_MEMBER
- Knowledge affects available conversation topics
- Relationships influence information sharing

### Task 28: Build rumor propagation system with accuracy decay
**User Story:** As a player, I want to hear rumors about events from NPCs, so that I can learn about the world indirectly and experience how information spreads and distorts.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. NPCs share knowledge based on relationships
  2. Information accuracy decreases with retelling
  3. Some NPCs more reliable than others
  4. Player can trace rumors to sources
  5. False rumors can emerge naturally

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Accuracy decay: -10% per retelling
- Gossips spread faster but less accurately
- Critical info may require verification
- Distortion can create red herrings

### Task 29: Create evidence discovery and decay mechanics
**User Story:** As a player investigating the station, I want to find physical evidence of events, so that I can piece together what happened even if I wasn't present.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Events can leave physical evidence
  2. Evidence has limited lifespan
  3. Different evidence types decay differently
  4. Discovery requires investigation skill
  5. Evidence can be preserved/documented

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Evidence types: Documents, bloodstains, recordings, items
- Decay rates: 30min to 48hrs depending on type
- Cleaning crews remove some evidence
- Critical evidence protected from decay

### Task 30: Implement reaction chain system for events
**User Story:** As a developer, I want major events to create realistic ripple effects, so that the world responds dynamically to both player actions and autonomous events.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Assimilation triggers missing person reports
  2. Security events affect NPC routines
  3. Economic events change prices/availability
  4. Coalition actions provoke responses
  5. All reactions feel logical and timely

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Major event categories with specific chains
- Timing offsets for realistic delays
- Some chains can be interrupted
- Player actions can redirect chains

### Task 31: Add performance optimization for 100+ NPCs
**User Story:** As a player, I want the game to run smoothly even with many NPCs active, so that the living world doesn't compromise gameplay performance.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Maintain 60 FPS with 100+ NPCs
  2. Simulation detail scales with distance
  3. Background NPCs use simplified logic
  4. No noticeable pop-in or behavior jumps
  5. Memory usage remains reasonable

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Three simulation levels: Full, Simplified, Quantum
- LOD system for NPC complexity
- Batch updates for distant NPCs
- Profile and optimize hotspots

### Task 32: Create quantum simulation for background NPCs
**User Story:** As a developer, I want background NPCs to exist efficiently, so that the station feels populated without requiring full simulation for every character.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Background NPCs follow schedules loosely
  2. Quantum state until observed
  3. Smooth transition to full simulation
  4. Reasonable behavior when "collapsed"
  5. Minimal memory footprint

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Store only location and basic state
- Probability-based state changes
- Collapse to full state when player approaches
- 70+ background NPCs supported

### Task 33: Build temporal reputation tracking
**User Story:** As a player, I want NPCs to remember my past actions over time, so that my reputation evolves based on consistent behavior patterns.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Actions affect reputation with factions
  2. Reputation decays/grows over time
  3. NPCs reference past interactions
  4. Reputation affects available options
  5. Can view reputation status

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Track recent actions with timestamps
- Reputation has momentum (hard to change quickly)
- Different factions value different actions
- Some actions have permanent effects

### Task 34: Implement differential serialization for world state
**User Story:** As a developer, I want efficient save files despite complex world state, so that players don't experience long save/load times or huge save files.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Only save changed values
  2. Compress repetitive data
  3. Save files under 10MB
  4. Load times under 3 seconds
  5. Forward compatibility support

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Reference: docs/design/modular_serialization_architecture.md
- Delta compression for NPC states
- Prune expired events/rumors
- Version migration support

### Task 35: Create emergent narrative generation system
**User Story:** As a player, I want unique stories to emerge from system interactions, so that each playthrough feels distinct and personally crafted by my choices.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, B2, U3
- **Acceptance Criteria:**
  1. System interactions create unique scenarios
  2. Emergent stories feel intentional
  3. Player can influence emerging narratives
  4. Stories reference past events naturally
  5. No two playthroughs identical

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_full.md
- Combine multiple systems for emergence
- Track narrative threads across events
- Some emergent stories become quests
- Player interpretation fills gaps

### Task 36: Implement leader/drone assimilation types
**User Story:** As the assimilation collective, I want distinct behavioral types for strategic control (leaders) and chaos creation (drones), so that the takeover employs both subtle manipulation and overt disruption.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Leaders maintain perfect cover while planning
  2. Drones exhibit antisocial behaviors
  3. 20% of assimilated become leaders
  4. Leaders can coordinate drone activities
  5. Visual/behavioral differences are distinct

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Leaders: High positions, strategic planning
- Drones: Crime tendency 70%, degrading behavior
- Leaders assign and coordinate drones

### Task 37: Create AssimilatedBehaviors system
**User Story:** As a player observing NPCs, I want assimilated individuals to exhibit subtle (leaders) or obvious (drones) behavioral changes, so that careful observation can reveal the infection's spread.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Personality parameters modified by type
  2. Dialog slip chances (10% leader, 40% drone)
  3. Collective pronouns occasionally used
  4. Friendliness/aggression changes
  5. Crime tendency modifications

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Leaders: +20% friendliness, -30% suspicion
- Drones: -50% friendliness, +60% aggression
- Dialog modifications per type

### Task 38: Build leader strategic planning AI
**User Story:** As an assimilated leader, I want to strategically select high-value targets for conversion, so that the collective gains control of critical station functions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Priority scoring for all NPCs
  2. Target selection based on role/access
  3. Strategic plan updates dynamically
  4. Leaders coordinate assimilation attempts
  5. High-value targets prioritized

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Priority factors: position, security access, wealth, connections
- Bank managers, security chiefs = highest priority
- Plan adjusts based on successes/failures

### Task 39: Implement drone behavioral degradation
**User Story:** As a drone, I want my behavior to degrade over time becoming more erratic, so that the infection's effect on individuals becomes increasingly apparent.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Degradation rate 10-30% per day
  2. Speech becomes more erratic
  3. Crime frequency increases
  4. Social interactions worsen
  5. Eventually become obviously infected

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Track degradation_rate per drone
- Affects all personality parameters
- Visual indicators intensify

### Task 40: Create leader-drone coordination system
**User Story:** As an assimilated leader, I want to coordinate my assigned drones for maximum station disruption, so that property values drop and the takeover becomes feasible.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B2, T2
- **Acceptance Criteria:**
  1. Leaders assigned drone groups
  2. Coordinated crime waves possible
  3. Strategic targeting of areas
  4. Synchronized disturbances
  5. Maximum economic impact

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- leader_assignments tracking
- Coordination plans by leader role
- Security chief creates distractions
- Bank manager targets investors

### Task 41: Implement station property value tracking
**User Story:** As the collective, I want to track and degrade station property values through coordinated actions, so that the economic takeover becomes possible.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B2, T1
- **Acceptance Criteria:**
  1. Base station value: 1,000,000 credits
  2. Value decreases from crime/chaos
  3. Target threshold: 300,000 credits
  4. Value visible to player (if investigating)
  5. Triggers takeover at threshold

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Vandalism: -50 credits per incident
- Major crimes: larger impacts
- District-specific value tracking

### Task 42: Create economic manipulation mechanics
**User Story:** As an assimilated financial leader, I want to manipulate markets and asset prices, so that the collective can acquire station ownership cheaply.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. Bank managers manipulate rates
  2. Traders create market volatility
  3. Asset prices become unstable
  4. Suspicious transactions traceable
  5. Paper trail for investigation

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Schedule market manipulation events
- Create financial anomalies
- Leave evidence for detective work

### Task 43: Build asset transfer system for assimilated
**User Story:** As an assimilated NPC, I want to transfer my assets to collective-controlled entities, so that the group accumulates wealth and property.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. Track owned assets per NPC
  2. Transfer on assimilation
  3. Collective ownership tracking
  4. Suspicious sales below market
  5. Creates financial evidence

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- assimilated_assets dictionary
- 70% below market = suspicious
- Transaction logs available

### Task 44: Implement financial anomaly detection
**User Story:** As a player investigating, I want to detect financial irregularities in assimilated NPCs, so that I can uncover the economic conspiracy.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Large unexplained transfers
  2. Below-market property sales
  3. Patterns between assimilated
  4. Requires investigation skill
  5. Builds conspiracy evidence

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Check transactions over 10,000
- Property sales < 70% market
- Connect financial web

### Task 45: Create hostile takeover progression
**User Story:** As the collective, I want to execute the final takeover when conditions are met, so that the economic conquest succeeds and triggers an ending.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3, T3
- **Acceptance Criteria:**
  1. Triggers at value threshold
  2. Countdown timer begins
  3. Player can still intervene
  4. Leads to specific ending
  5. Coalition can delay/prevent

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Calculate days to takeover
- Emit takeover_imminent signal
- Multiple intervention methods

### Task 46: Create DroneCrimeEvents system
**User Story:** As a system designer, I want drones to automatically commit crimes, so that station degradation happens naturally through their behavior.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3, T1
- **Acceptance Criteria:**
  1. Five crime types defined
  2. Automatic scheduling system
  3. Location-based crimes
  4. Witness mechanics
  5. Integration with crime system

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Crime types: vandalism, theft, disturbance, assault, sabotage
- Schedule 1-3 crimes per drone per day
- 60% witness chance

### Task 47: Implement vandalism and property damage
**User Story:** As a drone, I want to vandalize station property, so that districts lose value and residents lose faith in security.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3
- **Acceptance Criteria:**
  1. Visual vandalism markers
  2. District value reduction
  3. Repair costs/time
  4. Security response
  5. Cumulative effects

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- -50 credits per vandalism
- Visual: graffiti, damage decals
- Cleaning crews eventually fix

### Task 48: Build theft and resource drain mechanics
**User Story:** As a drone, I want to steal from other NPCs and businesses, so that economic activity is disrupted and trust erodes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3
- **Acceptance Criteria:**
  1. Target selection logic
  2. Success based on security
  3. Victim impact/reaction
  4. Stolen goods tracking
  5. Investigation possibilities

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Target wealthy NPCs preferentially
- Items disappear from economy
- Victims report to security

### Task 49: Create public disturbance events
**User Story:** As a drone, I want to cause public disturbances, so that fear spreads and normal station life is disrupted.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3, U1
- **Acceptance Criteria:**
  1. Screaming, ranting behaviors
  2. Area suspicion increase
  3. NPC reaction/fleeing
  4. Security alert trigger
  5. Escalation possibilities

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- +10% area suspicion
- NPCs avoid disturbed areas
- Can escalate to violence

### Task 50: Implement coordinated crime waves
**User Story:** As a leader coordinating drones, I want to orchestrate simultaneous crimes, so that security is overwhelmed and cannot respond effectively.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3, T2
- **Acceptance Criteria:**
  1. Multi-drone coordination
  2. Synchronized timing
  3. Security overload mechanics
  4. Strategic target selection
  5. Maximum disruption achieved

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- 3+ simultaneous crimes
- Security response delayed
- Planned by leader role type

### Task 51: Build behavioral pattern analysis
**User Story:** As a player investigating NPCs, I want to analyze behavior patterns over time, so that I can identify subtle changes indicating assimilation.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Track NPC behavior history
  2. Compare pre/post patterns
  3. Subtle changes detectable
  4. Requires multiple observations
  5. Leaders harder to detect

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Minimum 3 interactions for leaders
- Track personality shifts
- Success based on investigation skill

### Task 52: Create investigation interaction system with advanced investigation mechanics
**User Story:** As a player, I want specific dialog options for investigating suspected assimilated through a multi-phase investigation system with investigator assignment and report filing, so that I can gather evidence through conversation while facing organized investigation attempts against me.

**Design Reference:** `docs/design/assimilation_system_design.md`, `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Investigation dialog branch with suspicion-based responses
  2. Skill-based success with personality modifiers
  3. Evidence gathering system integrated with clue tracking
  4. NPC reactions vary by assimilation type and relationship
  5. False accusations penalized with suspicion increases
  6. **Multi-Phase Investigations:** Automated investigator assignment when suspicion reaches 0.6+
  7. **Investigation System:** Formal investigation with questioning, evidence gathering, and conclusions
  8. **Player Questioning:** Events triggered when player becomes investigation target
  9. **Report Filing:** Investigations conclude with reports filed to security system

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md (investigation dialog)
- Reference: docs/design/suspicion_system_full_design.md lines 282-516 (Investigation System)
- **Investigation Phases:** questioning (30min), evidence gathering (1hr), conclusion (2hrs total)
- **Investigator Assignment:** Priority order: security personnel, assimilated leaders, high-suspicion NPCs
- **Evidence Thresholds:** Need 3+ evidence for "guilty", -3 for "innocent" conclusions
- **Assimilated Responses:** Leaders excellent liars (-1 evidence weight), drones may slip up (40% chance +1 evidence)
- **Player Investigations:** Can trigger when suspicion > 0.6, emit player_questioned signal
- **Conclusion Effects:** Guilty (+0.4 suspicion), Innocent (-0.3 suspicion), Inconclusive (+0.1 suspicion)
- Special dialog options unlock based on investigation skill
- Leaders deflect skillfully with coordinated stories
- Track investigation attempts and build resistance patterns
- Failed investigations may trigger counter-investigations against player

### Task 53: Implement financial investigation mechanics
**User Story:** As a player with financial access, I want to investigate transaction records, so that I can uncover the economic conspiracy.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3, T1
- **Acceptance Criteria:**
  1. Access transaction logs
  2. Pattern recognition puzzles
  3. Connect financial web
  4. Build conspiracy case
  5. Evidence can be presented

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Requires terminal access
- Mini-game for analysis
- Creates evidence items

### Task 54: Add speech pattern detection
**User Story:** As an observant player, I want to notice when NPCs use collective pronouns or strange speech, so that dialog provides clues to assimilation.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. Collective pronouns highlighted
  2. Speech pattern changes
  3. Slip frequency by type
  4. Player can note suspicious dialog
  5. Evidence for investigation

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- "We" instead of "I" slips
- Different color/style for slips
- Leaders: 10%, Drones: 40%

### Task 55: Create discovery consequence system
**User Story:** As a player who discovers assimilated NPCs, I want my discoveries to have consequences, so that the world reacts to revealed threats.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Security responds to reports
  2. Discovered assimilated react
  3. Cover-ups attempted
  4. Coalition opportunities
  5. Station alert changes

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Process discovery consequences
- Leaders may flee/fight
- Security detention possible

### Task 56: Create AssimilationSerializer
**User Story:** As a developer, I want assimilation state to save and load correctly, so that player progress persists across sessions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. All assimilation data saved
  2. Self-registering serializer
  3. Follows modular architecture
  4. Version number tracking
  5. Efficient data format

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Reference: docs/design/modular_serialization_architecture.md
- Priority: 30 (medium)
- Compress assimilation data

### Task 57: Implement data compression for saves
**User Story:** As a player, I want save files to remain small despite complex assimilation tracking, so that saves are fast and don't consume excessive disk space.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Minimize redundant data
  2. Short keys for common fields
  3. Only save non-defaults
  4. Compress arrays efficiently
  5. Under 1MB for full game

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Single letter type indicators
- Omit empty fields
- Batch similar data

### Task 58: Build version migration support
**User Story:** As a developer, I want old save files to upgrade gracefully, so that players don't lose progress when we update the assimilation system.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Version tracking in saves
  2. Migration function support
  3. V1 to V2 migration path
  4. Graceful handling of missing data
  5. No data loss on upgrade

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- MVP = version 1
- Full = version 2
- Add missing fields with defaults

### Task 59: Add differential serialization
**User Story:** As a developer, I want to save only changed assimilation data, so that save operations are fast even with many NPCs.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Track state changes
  2. Delta saves implemented
  3. Full saves periodically
  4. Reconstruction reliable
  5. Corruption detection

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Reference: docs/design/modular_serialization_architecture.md
- Delta every save
- Full save every 10th

### Task 60: Create save/load integration tests
**User Story:** As a developer, I want comprehensive tests for serialization, so that save/load bugs are caught before release.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Test all data structures
  2. Test compression/decompression
  3. Test version migration
  4. Test corruption handling
  5. Test performance at scale

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- 100+ NPC test cases
- Corruption injection tests
- Performance benchmarks

### Task 1: Create AssimilationManager singleton
**User Story:** As a developer, I want a central system to manage all assimilation mechanics with morning report integration, so that the infection spread is coordinated and consistent across the game with overnight events properly reported.

**Design Reference:** `docs/design/assimilation_system_design.md` & `docs/design/morning_report_manager_design.md`

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Singleton pattern implemented
  2. Tracks all assimilated NPCs
  3. Manages spread mechanics
  4. Provides API for other systems
  5. Handles save/load state
  6. Reports overnight spread to MorningReportManager

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Reference: docs/design/morning_report_manager_design.md lines 78-107 (assimilation integration)
- Central authority for assimilation state
- Emit signals for major events
- Thread-safe for performance
- Call MorningReportManager.report_assimilation_spread() during overnight processing

### Task 3: Build assimilation detection methods
**User Story:** As a player, I want ways to detect who might be assimilated, so that I can investigate and uncover the conspiracy.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Multiple detection methods available
  2. Behavioral observation works
  3. Investigation skill affects success
  4. False positives possible
  5. Evidence can be gathered

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Observation, investigation, evidence
- Different methods for leaders vs drones
- Skill checks required

### Task 4: Create visual indicators for infected
**User Story:** As a player, I want to see subtle visual cues on assimilated NPCs, so that careful observation is rewarded.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. Subtle indicators for leaders
  2. More obvious signs for drones
  3. Progressive visual degradation
  4. Optional highlight mode
  5. Consistent art style

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Eye color shifts, posture changes
- Drone degradation visible
- Toggle for accessibility

### Task 5: Add assimilation event system
**User Story:** As the assimilation force, I want to trigger events that advance the infection, so that the threat feels active and evolving.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Scheduled infection attempts
  2. Event variety (contact, airborne, etc.)
  3. Player can witness some events
  4. Events leave evidence
  5. Integrate with world state

**Implementation Notes:**
- Reference: docs/design/assimilation_system_design.md
- Different event types
- Some visible, some hidden
- Affect spread rate

### Task 6: Create CoalitionManager with hover text integration
**User Story:** As a developer, I want a central system to manage the resistance coalition with morning report and hover text integration, so that recruitment, resources, and operations are coordinated with overnight mission results properly reported and coalition information displayed in hover text.

**Design Reference:** `docs/design/coalition_resistance_system_design.md`, `docs/design/morning_report_manager_design.md`, `docs/design/scumm_hover_text_system_design.md`

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Singleton pattern implemented
  2. Track coalition members with roles and trust levels
  3. Manage shared resources
  4. Calculate coalition strength
  5. Handle coalition events
  6. Report overnight mission results to MorningReportManager
  7. **Hover Text Integration:** Provide coalition awareness information for NPC hover text
  8. **Member Role Display:** Show coalition roles in hover descriptions
  9. **Recruitment Potential:** Indicate recruitability in hover text for non-members

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Reference: docs/design/morning_report_manager_design.md lines 109-133 (coalition integration)
- Reference: docs/design/scumm_hover_text_system_design.md lines 528-540 (Coalition Network Awareness)
- Central coalition authority with hover text provider interface:
  ```gdscript
  # Coalition hover text integration
  func add_coalition_info(base_text: String, npc: BaseNPC) -> String:
      if not is_member(npc.id):
          # Show recruitment potential
          if can_recruit(npc.id):
              return "potential ally " + base_text
      else:
          # Show role in coalition
          var role = get_member_role(npc.id)
          return base_text + " (" + role + ")"
      
      return base_text
  ```
- **Member Information:** Track and expose member roles (intelligence, operations, support, etc.)
- **Recruitment Analysis:** Provide can_recruit() method checking trust, alignment, and suspicion
- **Hover Text Provider:** Implement interface for HoverTextManager to query coalition status
- Signal major coalition events
- Call MorningReportManager.report_coalition_activities() after overnight operations

### Task 8: Build coalition strength tracking
**User Story:** As a player, I want to see how strong our coalition is, so that I understand our chances against the assimilation threat.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Strength calculated from multiple factors
  2. Visual representation available
  3. Affects available actions
  4. Compare to assimilation strength
  5. Dynamic updates

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Members, resources, completed missions
- 0-100 scale
- Visible in UI

### Task 9: Create resistance mission system
**User Story:** As a coalition leader, I want to plan and execute missions against the assimilation, so that we can fight back effectively.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Various mission types available
  2. Success based on coalition strength
  3. Missions have consequences
  4. Rewards for success
  5. Can fail with penalties

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Sabotage, rescue, intelligence missions
- Scale with game progression
- Some unlock heists

### Task 10: Add coalition meeting events
**User Story:** As a coalition member, I want to attend meetings to share information and plan operations, so that we coordinate effectively.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Weekly meeting schedule
  2. Share intelligence at meetings
  3. Vote on operations
  4. Build member relationships
  5. Can be infiltrated

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Time-based events
- Dialog-heavy scenes
- Affect coalition morale

### Task 11: Create SecurityManager
**User Story:** As station security, I want a system to detect and respond to crimes, so that order is maintained despite the growing chaos.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Track security alerts station-wide
  2. Dispatch security to incidents
  3. Manage alert levels
  4. Coordinate with other systems
  5. Security can be compromised

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Central security authority
- NPC security officers
- Response time mechanics

### Task 12: Implement crime detection system
**User Story:** As security, I want to detect crimes when they happen, so that perpetrators can be caught and order maintained.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Witness-based detection
  2. Camera surveillance
  3. Report delay mechanics
  4. Evidence generation
  5. False reports possible

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Multiple detection methods
- Not all crimes detected
- Integrate with evidence system

### Task 14: Create lockdown mechanics
**User Story:** As security, I want to lockdown areas during emergencies, so that threats can be contained and civilians protected.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Area-based lockdowns
  2. Movement restrictions
  3. Override mechanics for player
  4. NPC behavior changes
  5. Time-limited lockdowns

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Doors sealed, areas blocked
- Security checkpoints
- Affect navigation mesh

### Task 15: Add security response teams
**User Story:** As a player, I want to see security teams respond to incidents, so that the world feels reactive to criminal events.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Teams dispatch to crimes
  2. Response time varies
  3. Can apprehend criminals
  4. Player can evade/confront
  5. Teams have different capabilities

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- 2-4 officer teams
- Pathfinding to incidents
- Combat capabilities

### Task 16: Create EndingManager
**User Story:** As a developer, I want a system to track and trigger game endings, so that player choices lead to appropriate conclusions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T3
- **Acceptance Criteria:**
  1. Track ending conditions
  2. Multiple endings supported
  3. Trigger appropriate cutscenes
  4. Save completion state
  5. Enable new game+

**Implementation Notes:**
- Reference: docs/design/multiple_endings_system_design.md
- Central ending authority
- Check conditions regularly
- Smooth transitions

### Task 18: Build ending determination logic
**User Story:** As a player, I want my accumulated choices to determine which ending I receive, so that my journey feels consequential.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3, T3
- **Acceptance Criteria:**
  1. Complex condition checking
  2. Priority system for endings
  3. Track all relevant factors
  4. Clear but not obvious
  5. Debug visualization available

**Implementation Notes:**
- Reference: docs/design/multiple_endings_system_design.md
- Coalition strength, assimilation %, decisions
- Weighted scoring system
- Some endings have sub-variations

### Task 19: Create ending cutscenes
**User Story:** As a player reaching an ending, I want to see a satisfying conclusion cutscene, so that my story feels complete.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Unique scene per ending
  2. Reference player choices
  3. Show consequences
  4. Epilogue information
  5. Credits integration

**Implementation Notes:**
- Reference: docs/design/multiple_endings_system_design.md
- 5+ unique endings
- Some share components
- Skippable but memorable

### Task 20: Implement ending achievements
**User Story:** As a completionist player, I want achievements for reaching different endings, so that I'm encouraged to explore all possibilities.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Achievement per ending
  2. Hidden achievements for secrets
  3. Progress tracking
  4. Steam/platform integration
  5. New game+ rewards

**Implementation Notes:**
- Reference: docs/design/multiple_endings_system_design.md
- Track across playthroughs
- Some require specific paths
- Unlock bonuses

### Task 21: Connect all systems to world state
**User Story:** As a developer, I want all game systems to read and modify a unified world state, so that everything stays synchronized.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** All requirements
- **Acceptance Criteria:**
  1. Central world state object
  2. All systems integrated
  3. State changes propagate
  4. Save/load support
  5. Debug visualization

**Implementation Notes:**
- Major integration task
- Define clear interfaces
- Performance critical

### Task 22: Create emergent event system
**User Story:** As a player, I want unexpected events to emerge from system interactions, so that each playthrough feels unique.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Events emerge from interactions
  2. Not pre-scripted
  3. Feel intentional
  4. Create memorable moments
  5. Properly balanced

**Implementation Notes:**
- System interaction rules
- Emergence from complexity
- Some become mini-quests

### Task 23: Build faction conflict mechanics
**User Story:** As a player, I want to see different factions clash over station control, so that the world feels politically complex.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T2
- **Acceptance Criteria:**
  1. Multiple faction interests
  2. Conflicts over resources
  3. Alliance possibilities
  4. Territory control
  5. Player can influence

**Implementation Notes:**
- Coalition vs Assimilated vs Security vs Civilians
- Dynamic relationships
- Visible consequences

### Task 24: Add news/rumor system
**User Story:** As a player, I want to hear news and rumors about station events, so that I stay informed about the changing world.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. News broadcasts available
  2. Rumors spread naturally
  3. Accuracy varies
  4. Player actions featured
  5. Affect NPC knowledge

**Implementation Notes:**
- Terminal news feeds
- NPC gossip system
- Some false information

### Task 25: Implement cascade effects
**User Story:** As a player taking major actions, I want to see ripple effects throughout the station, so that my choices have far-reaching consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Major events trigger chains
  2. Delayed consequences
  3. Multiple systems affected
  4. Some predictable, some not
  5. Can be interrupted

**Implementation Notes:**
- Define trigger events
- Chain reaction rules
- Balance to avoid chaos

### Task 61: Implement member intelligence gathering
**User Story:** As a coalition member, I want to share intelligence about other NPCs with the coalition, so that we can identify safe recruits and threats.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Each member knows 2-5 other NPCs
  2. Information quality varies by relationship
  3. Verified safe vs suspected lists
  4. Updates when recruiting new members
  5. False intelligence possible

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Network effect multiplies intelligence
- Based on NPC relationships and roles
- Some NPCs have better intel than others

### Task 62: Create surveillance assignment system
**User Story:** As a coalition leader, I want to assign members to watch suspicious NPCs, so that we can detect assimilation attempts early.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Assign watchers to targets
  2. Regular surveillance reports
  3. Risk of detection exists
  4. Watchers unavailable for other tasks
  5. Can discover assimilation

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 8-hour report cycles
- 10% detection chance per report
- Higher chance of catching assimilated

### Task 63: Build intel report generation
**User Story:** As a coalition member, I want to receive detailed intelligence reports, so that I can make informed decisions about recruitment and operations.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Automated report generation
  2. Surveillance observations included
  3. Financial anomalies noted
  4. Behavioral changes tracked
  5. Actionable intelligence highlighted

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Compress old reports for performance
- Visual format for easy scanning
- Priority flagging system

### Task 64: Add verified/suspected NPC tracking
**User Story:** As a player, I want the coalition to maintain lists of verified safe and suspected assimilated NPCs, so that I know who to trust.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Two separate tracking lists
  2. NPCs can move between lists
  3. Verification methods available
  4. UI shows status clearly
  5. Lists affect recruitment options

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Color coding in UI (green/red)
- Verification requires multiple confirmations
- Suspected list helps avoid infiltrators

### Task 65: Create intel accuracy decay
**User Story:** As time passes, I want intelligence to become less reliable, so that the coalition must actively maintain its information network.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Intelligence has timestamps
  2. Accuracy decreases over time
  3. Fresh intel more valuable
  4. Old intel can mislead
  5. Updates refresh accuracy

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 48-hour half-life for most intel
- Critical info decays slower
- Visual indicators for freshness

### Task 66: Implement shared credit pool
**User Story:** As a coalition member, I want to contribute and access shared funds, so that we can support each other financially.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Central credit storage
  2. Contribution tracking
  3. Withdrawal limits
  4. Emergency fund access
  5. Transaction history

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Members contribute based on wealth
- Daily withdrawal limits prevent abuse
- Priority access for operations

### Task 67: Create shared inventory system
**User Story:** As a coalition member, I want to share items with other members, so that resources are used efficiently.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Central item storage
  2. Deposit/withdraw mechanics
  3. Item categorization
  4. Access permissions
  5. Inventory UI

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Medical supplies, weapons, tools
- Some items restricted by role
- Physical storage location

### Task 68: Build safe house management
**User Story:** As a coalition, we want to maintain secret safe houses, so that members have places to hide, meet, and rest safely.

**Design Reference:** `docs/design/coalition_resistance_system_design.md` & `docs/design/sleep_system_design.md` (Coalition Integration)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Multiple safe house locations
  2. Can be discovered/compromised
  3. Provide rest and resources
  4. Meeting locations
  5. Upgrade possibilities
  6. **Sleep functionality with 80% quality**
  7. **Trust threshold of 50 for sleep access**
  8. **Integration with SleepSystemManager**

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Reference: docs/design/sleep_system_design.md lines 405-426 (Coalition sleep integration)
- One per major district when established
- Infiltrators can compromise
- Fallback locations available
- Sleep quality = 0.8 (better than squat, worse than barracks)
- Only accessible when trust >= 50
- Check CoalitionManager.get_accessible_safe_houses()

### Task 69: Add resource request/contribution mechanics
**User Story:** As a coalition member in need, I want to request specific resources from the coalition, so that I can complete my missions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Request system UI
  2. Automatic fulfillment
  3. Priority levels
  4. Contribution rewards
  5. Request history

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- High-priority for operations
- Reputation affects priority
- Some requests denied if low resources

### Task 70: Create resource pooling from members
**User Story:** As the coalition grows, I want new members to automatically contribute resources, so that our collective strength increases.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Automatic contributions on join
  2. Periodic contributions
  3. Based on member wealth
  4. Voluntary extra contributions
  5. Morale affects giving

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 10% initial contribution
- 5% weekly contributions
- Wealthy members give more

### Task 71: Implement heist phase system
**User Story:** As a heist planner, I want operations divided into phases, so that complex missions can be executed step by step.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Multi-phase structure
  2. Phase dependencies
  3. Failure handling per phase
  4. Time costs per phase
  5. Dynamic phase generation

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Infiltration → Execution → Escape pattern
- Some phases optional
- Failure can abort or adapt

### Task 72: Create role requirements checker
**User Story:** As a heist planner, I want to know what roles are needed for each operation, so that I can assemble the right team.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Define role types
  2. Match members to roles
  3. Show missing roles
  4. Alternative role options
  5. Skill level requirements

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Hacker, muscle, face, tech, medic, etc.
- Some roles have substitutes
- Higher difficulty needs better skills

### Task 73: Build skill check mechanics
**User Story:** As a heist participant, I want my skills tested during operations, so that success depends on team composition.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Skill-based dice rolls
  2. Difficulty thresholds
  3. Teamwork bonuses
  4. Failure consequences
  5. Critical success/failure

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- D20-style system internally
- Visualized as percentage chance
- Some checks can be retried

### Task 74: Add heist reward distribution
**User Story:** As a heist participant, I want to receive my share of the rewards, so that successful operations benefit everyone involved.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Automatic distribution
  2. Role-based shares
  3. Coalition tax
  4. Bonus for excellence
  5. Non-monetary rewards

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 20% to coalition fund
- Leaders get larger shares
- Intel and items also distributed

### Task 75: Create heist planning interface
**User Story:** As a player planning heists, I want a clear interface showing phases, requirements, and risks, so that I can make informed decisions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Phase breakdown display
  2. Role assignment UI
  3. Success probability shown
  4. Risk/reward analysis
  5. Team selection interface

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Blueprint-style visual
- Drag-drop team assignment
- Real-time probability updates

### Task 76: Implement infiltrator detection
**User Story:** As a coalition leader, I want to detect when assimilated NPCs try to infiltrate our ranks, so that we can protect the coalition.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Verification checks available
  2. Behavioral analysis
  3. Background investigation
  4. Warning signs system
  5. False positive possibility

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Multiple verification methods
- Some infiltrators very hard to detect
- Investigation takes time

### Task 77: Create infiltration consequences
**User Story:** As a coalition, when we're infiltrated, I want to see realistic consequences, so that the threat feels serious.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Member exposure risk
  2. Resource theft
  3. Safe house compromise
  4. Morale damage
  5. Recovery mechanics

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 30-50% resource loss
- Multiple members exposed
- Triggers paranoia state

### Task 78: Build paranoia mechanics
**User Story:** As a coalition after infiltration, I want members to become paranoid and suspicious, so that trust must be rebuilt.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Paranoia levels per member
  2. Affects cooperation
  3. Additional verification required
  4. Trust rebuilding over time
  5. Paranoia events

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 0-100 paranoia scale
- High paranoia reduces effectiveness
- Special events to reduce paranoia

### Task 79: Add member verification system
**User Story:** As a paranoid coalition, I want to verify existing members aren't compromised, so that we can root out infiltrators.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Verification protocols
  2. Multiple test types
  3. Resource cost
  4. Time requirements
  5. Not 100% accurate

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Question sessions, behavior monitoring
- Can stress relationships
- Some refuse verification

### Task 80: Create trust building system
**User Story:** As a player, I want to build trust with NPCs through actions and dialog, so that I can recruit them to the coalition.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Trust levels 0-100
  2. Multiple building methods
  3. Personality affects approach
  4. Trust unlocks options
  5. Trust can be lost

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Evidence, mutual benefit, moral appeal, protection
- Thresholds at 30, 50, 70
- Some NPCs harder to convince

### Task 81: Create Coalition HQ scene
**User Story:** As a coalition member, I want a physical headquarters to visit, so that I feel part of a real organization.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Physical location in world
  2. Interactive elements
  3. Members present
  4. Functional areas
  5. Can be upgraded

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Hidden location
- Meeting room, armory, infirmary
- Members have schedules

### Task 82: Build member list interface
**User Story:** As a coalition leader, I want to see all members and their status, so that I can manage the organization effectively.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Sortable member list
  2. Status indicators
  3. Skills displayed
  4. Trust levels shown
  5. Assignment status

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Grid or list view options
- Quick filters
- Click for detailed view

### Task 83: Implement intelligence board UI
**User Story:** As a player, I want to see all coalition intelligence in one place, so that I can track threats and opportunities.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Verified/suspected lists
  2. Recent reports display
  3. Map integration
  4. Search functionality
  5. Priority highlighting

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Cork board aesthetic
- Red strings connecting related intel
- Timeline view option

### Task 84: Add resource management UI
**User Story:** As a coalition quartermaster, I want to see and manage shared resources, so that supplies are distributed efficiently.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Credit pool display
  2. Inventory categories
  3. Request queue
  4. Distribution controls
  5. Transaction history

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Tabbed interface
- Graphs for trends
- Quick distribution buttons

### Task 85: Create operation planner interface
**User Story:** As a player planning operations, I want a strategic interface, so that I can coordinate complex missions effectively.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Mission selection
  2. Team assignment
  3. Timeline display
  4. Success prediction
  5. Resource allocation

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- War room style
- Drag-drop planning
- Save operation plans

### Task 86: Create CoalitionSerializer
**User Story:** As a developer, I want coalition state to save correctly, so that player progress persists across sessions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T2
- **Acceptance Criteria:**
  1. All coalition data saved
  2. Follows modular architecture
  3. Compression for intel
  4. Version migration support
  5. Fast save/load

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Reference: docs/design/modular_serialization_architecture.md
- Priority 40 (medium)
- Compress intelligence reports

### Task 87: Implement coalition-economy integration
**User Story:** As a coalition member, I want economic benefits from fellow members, so that cooperation has tangible rewards.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Member shop discounts
  2. Exclusive trade deals
  3. Economic intelligence
  4. Group purchasing power
  5. Black market access

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 30% discount from member shops
- 10% from sympathizers
- Bulk buying options

### Task 88: Build coalition-assimilation resistance mechanics
**User Story:** As a coalition, I want our efforts to slow the assimilation spread, so that we're making a real difference.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B2
- **Acceptance Criteria:**
  1. Coalition size affects spread rate
  2. Safe houses protect areas
  3. Active operations disrupt assimilation
  4. Visible impact on statistics
  5. Max 50% slowdown

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- 2% resistance per member
- 5% per safe house
- 10% during active operations

### Task 89: Add coalition impact on endings
**User Story:** As a player, I want coalition strength to affect available endings, so that building the resistance matters to the outcome.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3, T3
- **Acceptance Criteria:**
  1. Ending variations based on coalition
  2. Some endings require strong coalition
  3. Coalition fate in epilogue
  4. Member outcomes shown
  5. Coalition legacy described

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- Reference: docs/design/multiple_endings_system_design.md
- True Victory needs 75% coalition
- Affects 3 of 5 endings

### Task 90: Create coalition achievement tracking
**User Story:** As a player, I want achievements for coalition milestones, so that I'm rewarded for building the resistance.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. Recruitment milestones
  2. Mission success tracking
  3. Perfect infiltration detection
  4. Resource accumulation
  5. Special heist completion

**Implementation Notes:**
- Reference: docs/design/coalition_resistance_system_design.md
- "Coalition Builder" - 20 members
- "Paranoid Android" - Detect all infiltrators
- "Master Thief" - Complete mainframe heist

### Task 91: Implement crime witness mechanics
**User Story:** As a player or NPC witnessing a crime, I want the system to recognize and track witnesses, so that crimes have social consequences and can be reported.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Line-of-sight witness detection
  2. 60% chance for witnesses to see crimes
  3. Witness memory of events
  4. Multiple witness support
  5. Player as witness option

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Check all NPCs within radius
- Store witness IDs in crime event
- Witnesses can provide testimony

### Task 92: Create NPC crime reporting behavior
**User Story:** As a law-abiding NPC, I want to report crimes I witness to security, so that the station maintains order and criminals face consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Lawfulness personality affects reporting
  2. Drones don't report drone crimes
  3. Reporting delay based on severity
  4. Security response triggered
  5. Reporter becomes target

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Lawfulness > 60 = automatic reporting
- Add temporary dialog about witnessed crime
- Some NPCs can be intimidated not to report

### Task 93: Build player crime interaction choices
**User Story:** As a player witnessing a crime, I want meaningful choices about how to respond, so that I can shape the narrative through my actions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Multiple choice prompt on witnessing
  2. Observe to gather evidence
  3. Intervene if not too dangerous
  4. Report if near comm terminal
  5. Flee to avoid involvement

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 495-535
- Show crime notification UI
- Each choice has different consequences
- Some choices require items/skills

### Task 94: Implement crime discovery system
**User Story:** As a player investigating the station, I want to discover evidence of past crimes, so that I can piece together what happened even if I wasn't present.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Crimes leave discoverable traces
  2. Discovery triggers investigation
  3. Time affects discoverability
  4. Different discovery methods
  5. Links to clue system

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 381-407
- Physical evidence, NPC testimony, records
- Older crimes harder to investigate
- Discovery can trigger security response

### Task 95: Create crime scene investigation mechanics
**User Story:** As a player or security personnel, I want to investigate crime scenes for clues, so that I can identify perpetrators and understand criminal patterns.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Interactive crime scene examination
  2. Evidence collection mechanics
  3. Clue combination for deductions
  4. Time pressure before cleanup
  5. Skills affect success

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Use observation system for examination
- Evidence quality degrades over time
- Security may restrict access

### Task 96: Implement physical evidence generation
**User Story:** As a crime system, I want to generate appropriate physical evidence for each crime type, so that players can investigate crimes forensically.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Each crime type generates evidence
  2. Evidence appropriate to crime
  3. Multiple evidence pieces possible
  4. Evidence has properties
  5. Visible in game world

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 126-233
- Vandalism: graffiti, damage marks
- Theft: forced entry, missing items
- Assault: bloodstains, injuries

### Task 97: Create evidence decay system
**User Story:** As a living world, I want evidence to naturally decay over time, so that investigation has urgency and the world feels dynamic.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Evidence has lifespan
  2. Different decay rates by type
  3. Cleaning crews accelerate decay
  4. Critical evidence protected
  5. Visual decay representation

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Documents: 48 hours
- Bloodstains: 6 hours
- Digital records: permanent
- Cleaning schedules affect decay

### Task 98: Build evidence discovery mechanics
**User Story:** As a player, I want to actively search for and discover evidence, so that investigation feels interactive rather than passive.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Active search mechanics
  2. Skill-based discovery
  3. Tools enhance discovery
  4. Hidden evidence possible
  5. Discovery notifications

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Observation mode for searching
- Investigation skill improves chances
- Some evidence requires specific tools

### Task 99: Implement evidence types per crime
**User Story:** As a developer, I want each crime type to generate specific evidence patterns, so that players can deduce crime types from evidence.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Unique evidence per crime type
  2. Evidence tells story
  3. Red herrings possible
  4. Quality varies
  5. Combinable for deductions

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Vandalism: graffiti style, tool marks
- Theft: entry method, missing items list
- Sabotage: technical modifications

### Task 100: Create evidence UI and tracking
**User Story:** As a player, I want a clear interface for managing discovered evidence, so that I can review findings and make connections.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Evidence inventory screen
  2. Categorization by type/location
  3. Connection drawing interface
  4. Timeline visualization
  5. Export to investigation log

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Reference: docs/design/investigation_clue_tracking_system_design.md
- Cork board style interface
- Drag-and-drop connections

### Task 101: Implement player intervention options
**User Story:** As a player witnessing a crime in progress, I want to intervene if I choose, so that I can actively shape events rather than just observe.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Intervention choices based on crime
  2. Success based on stats/items
  3. Risk of becoming target
  4. Reputation consequences
  5. May prevent crime

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 510-517
- Only for severity <= 3 crimes
- Can gain evidence or trust
- Failure may increase suspicion

### Task 102: Create security bribery mechanics
**User Story:** As a player caught by security, I want the option to bribe guards, so that I have alternatives to combat or capture.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Bribe option in security dialog
  2. Success based on personality
  3. Credit cost varies
  4. Corrupt guards remember
  5. Can backfire

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 559-563
- Base 50 credits for minor infractions
- Some guards incorruptible
- Creates future leverage/blackmail

### Task 103: Build chase sequence system
**User Story:** As a player fleeing from security, I want engaging chase sequences, so that escape feels thrilling and skill-based.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Real-time pursuit mechanics
  2. Environmental obstacles
  3. Multiple escape routes
  4. Stamina/speed factors
  5. Hide mechanics during chase

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 574-577
- Use existing navigation system
- Guards call reinforcements
- Can lose pursuers in crowds

### Task 104: Implement hiding from security
**User Story:** As a player evading security, I want to hide in environmental locations, so that stealth is a viable strategy.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Designated hiding spots
  2. Line-of-sight breaking
  3. Search patterns for guards
  4. Time limits on hiding
  5. Discovery consequences

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Lockers, vents, crowds
- Guards search last known position
- Some spots better than others

### Task 105: Create consequence system for caught players
**User Story:** As security, I want meaningful consequences when catching criminals, so that law enforcement feels impactful.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Detention mechanics
  2. Fine payment system
  3. Confiscation of items
  4. Reputation impact
  5. Record keeping

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 579-585
- Detention time based on severity
- Fines scale with crimes
- Some items permanently lost

### Task 106: Create crime statistics tracking
**User Story:** As the game system, I want to track crime statistics across the station, so that the world can react to crime trends dynamically.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Track all crime metrics
  2. Per-district statistics
  3. Crime type breakdowns
  4. Economic impact totals
  5. Trend analysis

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 634-663
- Dictionary structure for stats
- Update on every crime
- Trigger events at thresholds

### Task 107: Implement district crime modifiers
**User Story:** As a district, I want crime to affect my economic and social properties, so that criminal activity has lasting consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3
- **Acceptance Criteria:**
  1. Crime reduces property values
  2. Different crimes different impacts
  3. Cumulative effects
  4. Recovery over time
  5. Visible to player

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 431-452
- Vandalism: -5% property value
- Theft: +10% prices
- Assault: -30% foot traffic

### Task 108: Build economic impact calculations
**User Story:** As the economy system, I want to calculate and apply crime's economic impact, so that criminal activity affects station economics.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, B3
- **Acceptance Criteria:**
  1. Direct damage calculations
  2. Indirect economic effects
  3. District-specific impacts
  4. Cumulative tracking
  5. Recovery mechanics

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Direct: property damage costs
- Indirect: reduced business, higher prices
- Some effects permanent

### Task 109: Create social breakdown thresholds
**User Story:** As the station, I want to enter crisis mode when crime exceeds thresholds, so that unchecked crime leads to dramatic consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Define breakdown thresholds
  2. Escalating crisis levels
  3. Station-wide effects
  4. Special events trigger
  5. Affects ending conditions

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 661-663
- 100+ crimes = social breakdown
- Triggers martial law
- Changes NPC behaviors dramatically

### Task 110: Implement crime trend analysis
**User Story:** As a player or security analyst, I want to see crime trends over time, so that I can identify patterns and predict future problems.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Time-based trend tracking
  2. Visual graphs/charts
  3. Pattern identification
  4. Prediction algorithms
  5. Accessible via terminals

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- 7-day rolling averages
- Heat maps for districts
- Correlation with assimilation

### Task 111: Create CrimeSecuritySerializer
**User Story:** As a developer, I want crime and security state to persist correctly, so that player's impact on station security continues across sessions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Serialize all crime data
  2. Save patrol states
  3. Security level persistence
  4. Evidence preservation
  5. Statistics continuity

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md lines 593-630
- Priority: 50 (medium)
- Compress crime history
- Version migration support

### Task 112: Implement crime history persistence
**User Story:** As a player, I want past crimes to remain in the world's history, so that investigation can span multiple play sessions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Crimes older than 7 days purged
  2. Significant crimes permanent
  3. Evidence state preserved
  4. Witness memories saved
  5. Efficient storage

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Only save crimes with impact
- Compress old crime data
- Quick lookup by ID

### Task 113: Build patrol state serialization
**User Story:** As a security patrol, I want my route progress and alert status to persist, so that patrols continue realistically after save/load.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Current waypoint saved
  2. Alert level preserved
  3. Schedule state maintained
  4. Detection history saved
  5. Patrol route cached

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Minimal data per patrol
- Reconstruct from schedule
- Handle missing NPCs gracefully

### Task 114: Create security level persistence
**User Story:** As station security, I want alert levels and security states to persist, so that security responses maintain continuity.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. District security levels saved
  2. Station alert status preserved
  3. Lockdown states maintained
  4. Response team positions
  5. Checkpoint states saved

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Global and per-district levels
- Timer states for lockdowns
- Active response tracking

### Task 115: Implement player security record tracking
**User Story:** As station security, I want to maintain records of player infractions, so that repeat offenders face escalating consequences.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Criminal record per player
  2. Infraction history
  3. Outstanding warrants
  4. Reputation with security
  5. Accessible by guards

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Affects guard interactions
- Can be cleared/expunged
- Influences ending possibilities

### Task 116: Implement detection network propagation
**User Story:** As an assimilated NPC, I want to share information about detected threats with my network, so that the collective can coordinate responses.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Detection info spreads through assimilated network
  2. Information degrades with distance/time
  3. Leaders propagate info more efficiently
  4. Network connections affect spread speed
  5. Player can disrupt propagation

**Implementation Notes:**
- Reference: docs/design/detection_game_over_system_design.md
- Use graph traversal for network spread
- Information quality decreases with each hop
- Leaders act as signal boosters

### Task 117: Create coalition-based escape routes
**User Story:** As a player, I want my coalition allies to provide escape options during pursuit, so that building alliances has survival benefits.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Safe houses provide escape destinations
  2. Coalition members offer temporary hideouts
  3. More allies means more escape options
  4. Trust level affects hideout availability
  5. Coalition can attempt rescue operations

**Implementation Notes:**
- Reference: docs/design/detection_game_over_system_design.md
- Integrate with CoalitionManager
- High-trust members provide better hideouts
- Calculate routes based on distance and risk

### Task 118: Build detection cooldown mechanics
**User Story:** As a player, I want detection levels to decrease over time when I avoid suspicious behavior, so that I can recover from mistakes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Detection decreases when out of sight
  2. Different cooldown rates per detection stage
  3. Some actions reset cooldown
  4. Safe areas accelerate cooldown
  5. Higher alert levels decay slower

**Implementation Notes:**
- Use timer-based decay system
- Safe houses provide bonus cooldown
- Changing districts helps lose heat
- Some NPCs have longer memories

### Task 119: Add environmental detection triggers
**User Story:** As a security system, I want to detect intruders through cameras and sensors, so that the station's automated defenses contribute to gameplay.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U1
- **Acceptance Criteria:**
  1. Security cameras detect players
  2. Motion sensors trigger alerts
  3. Restricted door access logged
  4. Environmental hazards increase detection
  5. Disguises affect sensor detection

**Implementation Notes:**
- Reference: docs/design/detection_game_over_system_design.md
- Create SecurityCamera nodes
- Different sensor types and ranges
- Integration with DisguiseManager

### Task 120: Implement bribery mechanics during detection
**User Story:** As a player, I want to attempt bribing assimilated NPCs during detection, so that I have desperate last-resort options.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, U3
- **Acceptance Criteria:**
  1. Can attempt bribes at certain detection stages
  2. Cost scales with detection severity
  3. Leaders cannot be bribed
  4. Success chance varies by NPC type
  5. Failed bribes worsen situation

**Implementation Notes:**
- Reference: docs/design/detection_game_over_system_design.md
- Only drones accept bribes (40% chance)
- Integrate with EconomyManager
- Escalating costs per detection stage

## Testing Criteria
- Assimilation spreads believably
- Coalition mechanics function properly
- Security responds appropriately
- Endings trigger correctly
- Detection network propagation works correctly
- Coalition escape routes calculate properly
- Detection cooldown mechanics function as designed
- Environmental triggers detect appropriately
- Bribery mechanics scale with detection severity
- Chase sequences integrate with detection system
- Hiding mechanics provide realistic escape options
- All systems affect world state
- Save/load preserves all states
- Performance with many active systems
- Emergent scenarios feel natural
- Event chains trigger and resolve correctly
- NPCs maintain consistent state machines
- Rumors propagate with appropriate distortion
- Evidence spawns and decays properly
- Reaction chains create logical consequences
- 100+ NPCs perform without frame drops
- Quantum NPCs transition smoothly
- Reputation affects NPC interactions
- Differential saves remain small and fast
- Emergent narratives feel coherent
- Leader/drone behaviors are distinct and appropriate
- Economic warfare reduces station value correctly
- Drone crimes trigger and affect districts
- Financial anomalies are detectable
- Speech pattern slips occur at correct frequencies
- Investigation mechanics reveal assimilation
- Coordinated crimes overwhelm security
- Behavioral degradation progresses naturally
- Assimilation serialization handles all data
- Version migration preserves save integrity
- Coalition intelligence network provides accurate information
- Surveillance assignments detect assimilation correctly
- Resource sharing mechanics work without exploits
- Heist phase system executes properly
- Skill checks provide appropriate challenge
- Infiltrator detection catches some but not all attempts
- Paranoia mechanics affect coalition effectiveness
- Trust building unlocks recruitment at correct thresholds
- Coalition HQ scene functions as hub
- All coalition UI interfaces are intuitive
- Coalition serialization compresses intelligence efficiently
- Economic benefits apply correctly to coalition members
- Coalition resistance factor slows assimilation appropriately
- Coalition strength affects ending availability
- Achievement tracking records coalition milestones
- Crime witnesses are detected and tracked correctly
- NPCs report crimes based on personality
- Player crime choices present appropriate options
- Evidence generates and decays properly
- Crime scenes can be investigated
- Security responds to bribery attempts appropriately
- Chase sequences function smoothly
- Crime statistics track all metrics accurately
- Economic impacts calculate correctly
- CrimeSecuritySerializer preserves all state
- Player security records persist across sessions

## Timeline
- Start date: After Iteration 11
- Target completion: 3 weeks (complex interactions)
- Critical for: Complete game experience

## Dependencies
- Iteration 11: Quest system (for coalition missions)
- Iteration 10: NPC relationships (for recruitment)
- Iteration 9: Detection system (for security)

## Code Links
- src/core/assimilation/assimilation_manager.gd (to be created)
- src/core/assimilation/assimilated_behaviors.gd (to be created)
- src/core/assimilation/drone_crime_events.gd (to be created)
- src/core/assimilation/assimilation_network.gd (to be created)
- src/core/serializers/assimilation_serializer.gd (to be created)
- src/core/coalition/coalition_manager.gd (to be created)
- src/core/security/security_manager.gd (to be created)
- src/core/endings/ending_manager.gd (to be created)
- docs/design/assimilation_system_design.md
- docs/design/coalition_resistance_system_design.md
- docs/design/crime_security_event_system_design.md
- docs/design/multiple_endings_system_design.md
- docs/design/living_world_event_system_mvp.md (from iteration 8)
- docs/design/living_world_event_system_full.md (extends MVP with advanced events)
- docs/design/modular_serialization_architecture.md (for serializer implementation)

## Notes
- This iteration creates the overarching narrative tension
- Balance is crucial - threat must feel real but not hopeless
- Player agency in determining outcome is key
- Systems create emergent storytelling opportunities
- Multiple endings encourage replay
- Living World Full adds complex event chains and emergent behaviors
- Assimilation System now fully implements the "economic horror" concept
- Two-tier hierarchy creates both subtle and obvious threats
- Financial investigation adds detective gameplay layer
- Leader/drone coordination enables strategic AI opponents
- Comprehensive serialization ensures save system compatibility
- Coalition System expanded from 5 to 30 tasks to fully implement design
- Intelligence network creates information warfare gameplay
- Resource sharing enables cooperative strategy
- Heist system provides Ocean's 11 style missions
- Infiltration mechanics add paranoia and trust elements
- Full UI suite supports complex coalition management