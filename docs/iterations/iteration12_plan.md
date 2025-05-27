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

### Assimilation System
- [ ] Task 1: Create AssimilationManager singleton
- [ ] Task 2: Implement infection spread mechanics
- [ ] Task 3: Build assimilation detection methods
- [ ] Task 4: Create visual indicators for infected
- [ ] Task 5: Add assimilation event system

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

## Testing Criteria
- Assimilation spreads believably
- Coalition mechanics function properly
- Security responds appropriately
- Endings trigger correctly
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
- src/core/coalition/coalition_manager.gd (to be created)
- src/core/security/security_manager.gd (to be created)
- src/core/endings/ending_manager.gd (to be created)
- docs/design/assimilation_system_design.md
- docs/design/coalition_resistance_system_design.md
- docs/design/crime_security_event_system_design.md
- docs/design/multiple_endings_system_design.md
- docs/design/living_world_event_system_mvp.md (from iteration 8)
- docs/design/living_world_event_system_full.md (extends MVP with advanced events)

## Notes
- This iteration creates the overarching narrative tension
- Balance is crucial - threat must feel real but not hopeless
- Player agency in determining outcome is key
- Systems create emergent storytelling opportunities
- Multiple endings encourage replay
- Living World Full adds complex event chains and emergent behaviors