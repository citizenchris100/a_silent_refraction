# Iteration 19: District Population Part 2

## Epic Description
As a content creator, I want to complete district population by fully implementing the Trading Floor, Barracks, and Engineering districts with all NPCs, quests, and unique features.

## Cohesive Goal
**"The final three districts showcase unique gameplay and complete the station"**

## Overview
This iteration completes Phase 3.2 by populating the remaining three districts. These areas feature unique gameplay elements: the Trading Floor with its financial minigame, the Barracks with player housing and neighbors, and Engineering with restricted areas and technical challenges.

## Goals
- Implement 65 NPCs across three districts
- Create specialized gameplay for each district
- Add unique district features and mechanics
- Complete residential and technical areas
- Integrate trading minigame
- Finalize restricted area access

## Requirements

### Business Requirements
- Each district offers unique gameplay
- Trading minigame adds strategic depth
- Player housing creates personal connection
- Engineering provides end-game challenges

### User Requirements
- Experience financial trading gameplay
- Customize personal living space
- Build relationships with neighbors
- Access restricted technical areas
- Solve engineering puzzles

### Technical Requirements
- Trading minigame integration
- Housing customization system
- Neighbor interaction mechanics
- Security clearance progression
- Technical puzzle framework

## Tasks

### Asset Creation for Final Districts
- [ ] Task 1: Create Trading Floor NPC sprite batch (25 NPCs)
- [ ] Task 2: Create Barracks NPC sprite batch (25 NPCs)
- [ ] Task 3: Create Engineering NPC sprite batch (15 NPCs)
- [ ] Task 4: Design district-specific interactive objects
- [ ] Task 5: Create financial and technical item sprites
- [ ] Task 6: Produce final district audio assets

### District Population
- [ ] Task 7: Trading Floor District Population
- [ ] Task 8: Trading Minigame Integration
- [ ] Task 9: Black Market Integration
- [ ] Task 10: Barracks District Population
- [ ] Task 11: Player Housing Implementation
- [ ] Task 12: Engineering District Population
- [ ] Task 13: Restricted Area Implementation
- [ ] Task 14: District Integration Testing

### District Access Control Implementation
- [ ] Task 15: Implement Engineering biometric locks for high-security areas
- [ ] Task 16: Create maintenance tunnel access network in Engineering
- [ ] Task 17: Add security checkpoint NPCs with access verification dialog
- [ ] Task 18: Implement borrowed keycard quest mechanics

### Job Implementation Tasks
- [ ] Task 19: Janitor Job Implementation

### Advanced District Features
- [ ] Task 20: Advanced District Audio Systems

## User Stories

### Task 1: Create Trading Floor NPC sprite batch (25 NPCs)

**User Story:** As a solo developer, I want to create all 25 Trading Floor NPC sprites to represent the financial elite and corporate culture, so that the district feels like a high-stakes business environment.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (unique gameplay), Technical Requirements (65 NPCs)
- **Acceptance Criteria:**
  1. 10 traders in business attire with suspenders
  2. 8 executives in high-end suits
  3. 7 clerks and support staff
  4. 1950s Wall Street aesthetic
  5. Visible stress/intensity in animations
  6. Some showing drone-like efficiency
  7. Status symbols visible (watches, pins)

**Implementation Notes:**
- Reference Mad Men era business fashion
- Traders need frantic energy in poses
- Executives show authority/arrogance
- Include power dynamics in visual hierarchy
- Some NPCs corrupted by greed (assimilation metaphor)

### Task 2: Create Barracks NPC sprite batch (25 NPCs)

**User Story:** As a solo developer, I want to create all 25 Barracks NPC sprites to populate the residential area with diverse neighbors and staff, so that the living quarters feel like a real community.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (personal connection), User Requirements (neighbor relationships)
- **Acceptance Criteria:**
  1. 15 diverse residents (various ages/professions)
  2. 5 maintenance staff in work uniforms
  3. 5 service staff (concierge, security, etc.)
  4. Casual/home attire for residents
  5. Mix of military and civilian backgrounds
  6. Neighborly body language
  7. Personal touches in appearance

**Implementation Notes:**
- Show variety in economic status
- Some in robes/casual wear
- Include elderly and young adults
- Military veterans visible
- Create "lived-in" feel

### Task 3: Create Engineering NPC sprite batch (15 NPCs)

**User Story:** As a solo developer, I want to create all 15 Engineering NPC sprites with technical gear and professional attire, so that the district feels like the station's technical heart.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (end-game challenges), Technical Requirements (restricted areas)
- **Acceptance Criteria:**
  1. 7 engineers with tool belts and gear
  2. 5 technicians in coveralls
  3. 3 scientists in lab coats
  4. Safety equipment visible (helmets, goggles)
  5. Technical competence in posture
  6. Some showing exhaustion
  7. Access badges prominently displayed

**Implementation Notes:**
- Practical work attire focus
- Tools as character accessories
- Oil stains and wear on clothes
- Higher security badges visible
- Mix of theoretical and hands-on workers

### Task 4: Design district-specific interactive objects

**User Story:** As a player, I want each final district to have unique interactive objects that support their specialized gameplay, so that interaction matches the district theme.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (specialized gameplay), User Requirements (district-specific features)
- **Acceptance Criteria:**
  1. Trading Floor: terminals, tickers, vault doors
  2. Barracks: personal items, doors, mailboxes
  3. Engineering: control panels, machinery, tools
  4. Consistent interaction highlighting
  5. State changes for important objects
  6. Clear visual feedback
  7. Quest-specific variations

**Implementation Notes:**
- Trading terminals need screen graphics
- Personal items tell neighbor stories
- Engineering panels show system status
- Some objects hide clues

### Task 5: Create financial and technical item sprites

**User Story:** As a player, I want specialized items from these districts to be visually distinct and functional, so that finding them feels rewarding and purposeful.

**Design Reference:** `docs/design/template_interactive_object_design.md`, `docs/design/economy_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (trading minigame), User Requirements (engineering puzzles)
- **Acceptance Criteria:**
  1. Financial: stock certificates, ledgers, stamps
  2. Technical: circuit boards, tools, manuals
  3. Black market: forged items, contraband
  4. Housing: decorations, personal effects
  5. Clear item purposes
  6. 32x32 consistent sizing
  7. Rarity visual indicators

**Implementation Notes:**
- Financial items hint at corruption
- Technical items enable access
- Black market items look illicit
- Personal items build character

### Task 6: Produce final district audio assets

**User Story:** As a player, I want the final three districts to have distinctive soundscapes that reinforce their unique purposes, so that audio navigation remains intuitive.

**Design Reference:** `docs/design/audio_system_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (district atmosphere), User Requirements (audio feedback)
- **Acceptance Criteria:**
  1. Trading Floor: ticker tape, phones, shouting
  2. Barracks: domestic sounds, HVAC, footsteps
  3. Engineering: machinery, alarms, ventilation
  4. Positional audio placement
  5. Event-triggered sounds
  6. Ambient loops per district
  7. Normalized audio levels

**Implementation Notes:**
- Trading Floor needs frenetic energy
- Barracks should feel quieter, homey
- Engineering has industrial drone
- Include warning klaxons for events

### Task 7: Trading Floor District Population
**User Story:** As a player, I want the Trading Floor to feel like a high-stakes financial center with corporate intrigue and market dynamics, so that I can experience the station's economic elite.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (unique gameplay), User Requirements (financial trading)
- **Acceptance Criteria:**
  1. 25 NPCs with financial roles
  2. Trading desk job quests (3)
  3. Corporate espionage quests (2)
  4. Market event system
  5. Executive interactions
  6. Trading floor ambience

**Implementation Notes:**
- Reference: docs/design/template_district_design.md
- Integrate with trading minigame from Iteration 11
- NPCs should reflect 1950s corporate culture

### Task 8: Trading Minigame Integration
**Priority:** High  
**Estimated Hours:** 16

**Description:**  
Fully integrate the trading floor minigame with NPCs, market events, and progression.

**User Story:**  
*As a player, I want to engage in financial trading that affects my resources and relationships with corporate NPCs.*

**Acceptance Criteria:**
- [ ] Minigame accessible from terminals
- [ ] Market influenced by events
- [ ] NPC traders participate
- [ ] Profit/loss affects economy
- [ ] Insider information quests
- [ ] Achievement tracking

**Dependencies:**
- Trading minigame design (Iteration 11)
- Economy system (Iteration 7)
- Terminal UI (Iteration 3)

### Task 9: Black Market Integration
**User Story:** As a player, I want to access black market goods and services, so that I can obtain restricted items at the risk of increased suspicion.

**Design Reference:** `docs/design/economy_system_design.md` (Black Market - Medium Priority)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (unique gameplay), User Requirements (restricted area access)
- **Acceptance Criteria:**
  1. Hidden shop locations established
  2. Black market NPCs configured
  3. Illegal item inventory created
  4. Reputation system for access
  5. Integration with suspicion system
  6. Higher prices but unique items

**Implementation Notes:**
- Access requires coalition connections or discovered passwords
- Items include: forged credentials, restricted tools, banned substances
- Prices 2-3x normal shop prices

### Task 10: Barracks District Population
**Priority:** High  
**Estimated Hours:** 24

**Description:**  
Populate Barracks with 25 residential NPCs including neighbors, maintenance staff, and concierge.

**User Story:**  
*As a player, I want the Barracks to feel like a living community where I have a home and relationships with neighbors.*

**Acceptance Criteria:**
- [ ] 25 residential NPCs
- [ ] Neighbor relationship quests (4)
- [ ] Maintenance job quests (2)
- [ ] Community events
- [ ] Player room established
- [ ] Neighbor interaction system

**Dependencies:**
- Relationship system (Iteration 10)
- Housing system (new)
- Personal storage (Iteration 7)

### Task 11: Player Housing Implementation
**Priority:** High  
**Estimated Hours:** 16

**Description:**  
Implement player room customization and personal space mechanics in the Barracks.

**User Story:**  
*As a player, I want my own room that I can customize and use as a personal base of operations.*

**Acceptance Criteria:**
- [ ] Player room location
- [ ] Furniture placement system
- [ ] Personal storage access
- [ ] Decoration options
- [ ] Sleep/save point
- [ ] Private space mechanics

**Dependencies:**
- Save system (Iteration 7)
- Inventory system (Iteration 7)
- Object placement (new)

### Task 12: Engineering District Population
**Priority:** High  
**Estimated Hours:** 18

**Description:**  
Populate Engineering with 15 NPCs including engineers, technicians, and scientists.

**User Story:**  
*As a player, I want Engineering to feel like the technical heart of the station with restricted areas and complex systems.*

**Acceptance Criteria:**
- [ ] 15 technical NPCs
- [ ] Maintenance job quests (3)
- [ ] System repair quests (2)
- [ ] Equipment failure events
- [ ] Restricted area guards
- [ ] Technical dialog depth

**Dependencies:**
- Access control (Iteration 9)
- Technical systems (Iteration 15)
- Security clearance (Iteration 9)

### 6. Restricted Area Implementation
**Priority:** Medium  
**Estimated Hours:** 12

**Description:**  
Create restricted areas in Engineering with progressive access and hidden secrets.

**User Story:**  
*As a player, I want to work towards accessing restricted areas that contain important clues and advanced technology.*

**Acceptance Criteria:**
- [ ] Multi-tier access zones
- [ ] Security clearance progression
- [ ] Hidden areas and secrets
- [ ] Environmental hazards
- [ ] Technical puzzles
- [ ] Endgame content areas

**Dependencies:**
- Access control (Iteration 9)
- Puzzle system (Iteration 15)
- Investigation mechanics (Iteration 15)

### Task 13: Restricted Area Implementation

**User Story:** As a player, I want Engineering to have clearly marked restricted areas that require special clearance or skills to access, so that progression feels earned.

**Design Reference:** `docs/design/district_access_control_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (end-game challenges), Technical Requirements (security clearance)
- **Acceptance Criteria:**
  1. Define restricted zones in Engineering
  2. Place access control mechanisms
  3. Configure clearance requirements
  4. Add visual security indicators
  5. Implement override options
  6. Create consequence system
  7. Test all access paths

**Implementation Notes:**
- Core reactor area highest security
- Life support systems restricted
- Maintenance areas medium security
- Use existing access control classes
- Some areas require puzzle solving

### Task 14: District Integration Testing
**Priority:** Critical  
**Estimated Hours:** 16

**Description:**  
Test all seven populated districts together ensuring smooth transitions and consistent experience.

**User Story:**  
*As a developer, I want to verify that all districts work together seamlessly with proper performance and no conflicts.*

**Acceptance Criteria:**
- [ ] All districts accessible
- [ ] 150 NPCs function together
- [ ] Quest systems integrated
- [ ] Events don't conflict
- [ ] Performance acceptable
- [ ] Save/load works everywhere

**Dependencies:**
- All previous district work
- Performance optimization (Iteration 15)

### Task 15: Implement Engineering biometric locks for high-security areas
**User Story:** As a player, I want Engineering's critical areas to require biometric authentication, so that accessing the station's core systems feels appropriately challenging.

**Design Reference:** `docs/design/district_access_control_system_design.md` (Biometric Security)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (end-game challenges), Technical Requirements (security clearance)
- **Acceptance Criteria:**
  1. Place biometric scanners at key locations
  2. Configure authorized personnel lists
  3. Implement bypass challenges
  4. Add visual security indicators
  5. Create failure consequences

**Implementation Notes:**
- Use BiometricLock class from Iteration 15
- Engineering personnel only (15 authorized)
- Bypass methods: hacking, borrowed credentials, system override

### Task 16: Create maintenance tunnel access network in Engineering
**Priority:** Medium  
**Estimated Hours:** 10

**Description:**  
Build the maintenance tunnel network throughout Engineering providing alternative access routes.

**User Story:**  
*As a player with maintenance knowledge, I want to navigate Engineering through service tunnels, so that I can avoid security or reach restricted areas.*

**Acceptance Criteria:**
- [ ] Map tunnel network layout
- [ ] Connect to key areas
- [ ] Add environmental hazards
- [ ] Implement tool requirements
- [ ] Create discovery mechanics

**Dependencies:**
- Maintenance access system (Iteration 15, Task 46)
- Engineering layout complete

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Use MaintenanceAccess class from Iteration 15
- Include environmental hazards (steam, electrical)
- Tool requirements: screwdriver, flashlight

### Task 17: Add security checkpoint NPCs with access verification dialog
**Priority:** High  
**Estimated Hours:** 8

**Description:**  
Place security checkpoint guards who verify credentials through dialog interactions.

**User Story:**  
*As a player, I want to interact with checkpoint guards who check my credentials, so that gaining access feels like a social challenge.*

**Acceptance Criteria:**
- [ ] Place checkpoint guard NPCs
- [ ] Create verification dialog trees
- [ ] Implement credential checking
- [ ] Add persuasion options
- [ ] Include failure responses

**Dependencies:**
- Security checkpoint system (Iteration 9)
- Dialog system (Iteration 4)

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Integrate with existing guard NPC templates
- Use dialog conditions for credential checks
- Different responses based on clearance level

### Task 18: Implement borrowed keycard quest mechanics
**Priority:** Medium  
**Estimated Hours:** 6

**Description:**  
Create quests where NPCs lend keycards with time limits and consequences for not returning them.

**User Story:**  
*As a player, I want to borrow keycards from trusting NPCs for temporary access, so that social relationships provide tangible benefits.*

**Acceptance Criteria:**
- [ ] Create borrowing dialog options
- [ ] Implement time tracking
- [ ] Add return reminders
- [ ] Create trust consequences
- [ ] Handle lost borrowed items

**Dependencies:**
- Access trading system (Iteration 15, Task 45)
- Trust system (Iteration 10)

**Implementation Notes:**
- Reference: docs/design/district_access_control_system_design.md
- Use access trading mechanics from Iteration 15
- Time limits: 2-8 hours based on trust level
- Trust penalty for not returning: -20 points

### Task 19: Janitor Job Implementation
**User Story:** As a player, I want to work as a janitor performing cleaning and maintenance duties, so that I can gain universal station access while appearing invisible to most NPCs.

**Design Reference:** `docs/design/job_work_quest_system_design.md` (Barracks - Janitor, lines 457-563)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (job gameplay variety), User Requirements (meaningful work)
- **Acceptance Criteria:**
  1. Supervisor Jones NPC as quest giver
  2. Intro quest: "Mop and Bucket Brigade"
  3. 3 shift variants: Routine Cleaning, Deep Clean, Emergency Cleanup
  4. Master keycard access reward
  5. Environmental discovery mechanics
  6. Assimilation evidence cleanup events
  7. "Invisible" status during work

**Implementation Notes:**
- Most important job for investigation - provides universal access
- Gender neutral difficulty - janitors are ignored equally
- Deep Clean variant provides access to all restricted areas
- Base pay: 35 credits per 3-hour shift

### Task 20: Advanced District Audio Systems
**User Story:** As a player, I want each district to have rich, layered audio with complex diegetic sources and environmental audio zones, so that the soundscape creates immersive atmosphere and audio-based navigation cues.

**Design Reference:** `docs/design/template_district_design.md` lines 419-446, `docs/design/audio_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (district atmosphere), User Requirements (immersive audio)
- **Acceptance Criteria:**
  1. Diegetic music sources placed throughout districts
  2. Complex audio zone management systems
  3. Environmental audio storytelling elements
  4. Advanced spatial audio positioning
  5. Audio cue system for narrative elements
  6. Performance optimization for multiple audio sources
  7. Dynamic audio mixing based on context
  8. Integration with time-based audio changes

**Implementation Notes:**
- Reference: docs/design/template_district_design.md lines 419-446 (Advanced Audio Features)
- Implement advanced audio zone system:
  ```gdscript
  func _initialize_audio_sources()
  func add_ambient_sound(position: Vector2, sound_path: String)
  func _setup_diegetic_music_sources()
  func _create_environmental_audio_zones()
  ```
- **Audio Zone Types:** ambient, music, narrative, environmental
- **Diegetic Sources:** PA systems, radios, machinery, conversations
- **Environmental Audio:** ventilation, electrical hum, distant machinery
- **Narrative Audio:** hidden recordings, overheard conversations, clues
- **Dynamic Mixing:** Context-sensitive audio priority and mixing
- **Performance:** Audio LOD system with maximum 8 concurrent streams

## Testing Criteria
- All 65 NPCs function properly
- Trading minigame fully integrated
- Black market shops function with reputation gates
- Illegal items integrate with suspicion system
- Player housing saves correctly
- Restricted areas properly gated
- Engineering biometric locks function correctly
- Maintenance tunnel network accessible
- Security checkpoint dialogs work properly
- Borrowed keycard mechanics track correctly
- Performance with 150 total NPCs
- All districts feel complete
- Unique mechanics work smoothly
- Janitor master keycard provides universal access
- Janitor shifts grant "invisible" status
- Environmental cleanup reveals clues
- All job quests complete full cycles
- Advanced audio systems create immersive soundscapes
- Diegetic music sources function correctly
- Audio zones provide proper spatial positioning
- Environmental audio storytelling works as intended

## Timeline
- **Estimated Duration:** 8-9 weeks (including asset creation)
- **Total Hours:** 252 (126 + 16 for janitor job + 12 for advanced audio + 98 for asset creation)
- **Critical Path:** Asset creation → District population → Integration testing
- **Asset Creation Breakdown:**
  - 65 NPCs × 1.5 hours average = 97.5 hours
  - Interactive objects: 4 hours
  - Items and audio: 6 hours

## Definition of Done
- [ ] 65 NPC sprites created for final districts
- [ ] District-specific objects designed
- [ ] Financial and technical items created
- [ ] Final audio assets produced
- [ ] All 7 districts fully populated
- [ ] 150 total NPCs implemented
- [ ] Trading minigame integrated
- [ ] Player housing functional
- [ ] Restricted areas working
- [ ] All job quests complete
- [ ] Full integration tested

## Dependencies
- District Population Part 1 (Iteration 18)
- All Phase 2 systems complete
- Core content foundation (Iteration 17)

## Risks and Mitigations
- **Risk:** 150 NPCs impact performance severely
  - **Mitigation:** Aggressive optimization, NPC pooling
- **Risk:** Trading minigame too complex
  - **Mitigation:** Tutorial integration, difficulty options
- **Risk:** Housing system scope creep
  - **Mitigation:** Fixed customization options

## Links to Relevant Code
- data/npcs/trading_floor/
- data/npcs/barracks/
- data/npcs/engineering/
- src/content/trading/minigame/
- src/content/housing/
- src/content/restricted_areas/
- data/quests/jobs/trading/
- data/quests/jobs/barracks/
- data/quests/jobs/engineering/