# Iteration 18: District Population Part 1

## Epic Description
As a content creator, I want to fully populate the Spaceport, Security, Medical, and Mall districts with all NPCs, quests, and district-specific events to bring these areas to life.

## Cohesive Goal
**"The first four districts feel alive with unique characters and stories"**

## Overview
This iteration implements the first half of Phase 3.2, focusing on populating four key districts. Each district receives its full complement of NPCs (15-30 each), job quests, district-specific events, and ambient activity to create living, breathing environments.

## Goals
- Implement 85 NPCs across four districts
- Create job quest systems for each district
- Add district-specific random events
- Establish ambient crowds and activity
- Complete environmental storytelling
- Polish district atmospheres

## Requirements

### Business Requirements
- Each district feels unique and purposeful
- NPCs create believable communities
- Job systems provide gameplay variety
- Events create dynamic experiences

### User Requirements
- Meet diverse, memorable characters
- Find meaningful work in each district
- Experience unexpected events
- Feel districts are alive and active
- Discover environmental stories

### Technical Requirements
- Performance with 85+ active NPCs
- Event system handles district events
- Job system integrates smoothly
- Crowd system for ambient NPCs
- Memory management for assets

## Tasks

### Asset Creation for Districts
- [ ] Task 1: Create Spaceport NPC sprite batch (20 NPCs)
- [ ] Task 2: Create Security NPC sprite batch (20 NPCs)
- [ ] Task 3: Create Medical NPC sprite batch (15 NPCs)
- [ ] Task 4: Create Mall NPC sprite batch (30 NPCs)
- [ ] Task 5: Design district-specific interactive objects
- [ ] Task 6: Produce additional district audio assets
- [ ] Task 7: Create job-specific item sprites

### District Population Tasks
- [ ] Task 8: Spaceport District Population
- [ ] Task 9: Security District Population
- [ ] Task 10: Medical District Population
- [ ] Task 11: Mall District Population
- [ ] Task 12: District Event Implementation
- [ ] Task 13: Ambient Crowd Systems
- [ ] Task 14: Environmental Storytelling

### Job Implementation Tasks
- [ ] Task 15: Dock Worker Job Implementation
- [ ] Task 16: Medical Courier Job Implementation
- [ ] Task 17: Retail Clerk Job Implementation

### Perspective Validation Task
- [ ] Task 18: Validate perspective configurations for new districts

### Automation Scripts
- [ ] Task 19: Create setup_multi_perspective.sh automation script
- [ ] Task 20: Create generate_perspective_sprites.sh script

### Trust Building Activities
- [ ] Task 21: Add district-specific trust-building activities
- [ ] Task 22: Create shared meal and social interaction opportunities
- [ ] Task 23: Implement location-based relationship events

## User Stories

### Task 1: Create Spaceport NPC sprite batch (20 NPCs)

**User Story:** As a solo developer, I want to create all 20 Spaceport NPC sprites with their animations in a batch, so that the district can be populated efficiently with visually distinct characters.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (believable communities), Technical Requirements (85+ NPCs)
- **Acceptance Criteria:**
  1. 5 dock workers with coveralls and tools
  2. 5 travelers with luggage and varied attire  
  3. 5 ship crew members in uniforms
  4. 5 officials (customs, security, admin)
  5. Gender mix approximately 12M/8F
  6. All standard animations (walk, idle, talk)
  7. Consistent with retro-futuristic aesthetic

**Implementation Notes:**
- Use base template from Iteration 17
- Dock workers need grease stains, tool belts
- Travelers should have variety (business, tourist, etc.)
- Ship crews in matching uniform sets
- Consider 1950s fashion influences

### Task 2: Create Security NPC sprite batch (20 NPCs)

**User Story:** As a solo developer, I want to create all 20 Security district NPC sprites including officers and prisoners, so that the law enforcement area feels properly staffed and active.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (believable communities), Technical Requirements (85+ NPCs)
- **Acceptance Criteria:**
  1. 7 uniformed security officers
  2. 5 detectives in suits/formal wear
  3. 5 prisoners in station jumpsuits
  4. 3 administrative staff
  5. Authority visual hierarchy clear
  6. Prisoner rotation variety
  7. Equipment visible (badges, cuffs)

**Implementation Notes:**
- Officers need authority presence
- Detectives more noir aesthetic
- Prisoners diverse backgrounds
- Some officers corrupted (subtle hints)
- Include female officers/detectives

### Task 3: Create Medical NPC sprite batch (15 NPCs)

**User Story:** As a solo developer, I want to create all 15 Medical district NPC sprites with appropriate medical attire, so that the hospital environment feels authentic and professional.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (believable communities), Technical Requirements (85+ NPCs)
- **Acceptance Criteria:**
  1. 5 doctors in white coats
  2. 5 nurses in period-appropriate uniforms
  3. 5 patients in hospital gowns
  4. Medical equipment accessories
  5. Clear role identification
  6. Some showing fatigue/stress
  7. Sterile color palette

**Implementation Notes:**
- 1950s medical fashion references
- Stethoscopes, clipboards as props
- Patients show various conditions
- Some staff show assimilation signs
- Gender balance in medical roles

### Task 4: Create Mall NPC sprite batch (30 NPCs)

**User Story:** As a solo developer, I want to create all 30 Mall district NPC sprites representing the commercial diversity, so that the shopping area feels bustling and varied.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (believable communities), Technical Requirements (85+ NPCs)
- **Acceptance Criteria:**
  1. 10 shopkeepers with store-appropriate attire
  2. 10 diverse customers/shoppers
  3. 10 mall workers (janitors, security, food court)
  4. Wide variety of ages and styles
  5. Shopping bags and packages
  6. Consumer culture aesthetic
  7. Some robotic/drone behaviors

**Implementation Notes:**
- Each shopkeeper unique to store type
- Customers span all demographics
- 1950s consumer fashion
- Some showing assimilated shopping patterns
- Highest NPC count needs optimization

### Task 5: Design district-specific interactive objects

**User Story:** As a player, I want each district to have unique interactive objects that support both gameplay and atmosphere, so that exploration reveals district-appropriate interactions.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (district uniqueness), User Requirements (environmental stories)
- **Acceptance Criteria:**
  1. Spaceport: cargo crates, terminals, airlocks
  2. Security: evidence lockers, cells, terminals
  3. Medical: beds, equipment, medicine cabinets
  4. Mall: shop displays, kiosks, benches
  5. Consistent interaction highlighting
  6. Multiple states where appropriate
  7. Clear hotspot definition

**Implementation Notes:**
- 5-8 unique objects per district
- Reuse base objects with variations
- Include quest-specific objects
- Consider investigation opportunities

### Task 6: Produce additional district audio assets

**User Story:** As a player, I want each district to have rich, layered audio that includes both ambience and specific sound effects, so that the soundscape feels complete and immersive.

**Design Reference:** `docs/design/audio_system_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (district uniqueness), User Requirements (alive districts)
- **Acceptance Criteria:**
  1. Spaceport: ship engines, cargo movement, PA
  2. Security: cell doors, radio chatter, alarms
  3. Medical: monitor beeps, PA calls, equipment
  4. Mall: cash registers, crowd murmur, muzak
  5. Positional audio sources defined
  6. Event-triggered sounds ready
  7. Seamless integration with base ambience

**Implementation Notes:**
- Build on ambience from Iteration 17
- Focus on diegetic sources
- Each district needs 10-15 SFX
- Keep file sizes optimized

### Task 7: Create job-specific item sprites

**User Story:** As a player working various jobs, I want job-specific items and tools to be visually distinct, so that my work activities feel authentic and grounded.

**Design Reference:** `docs/design/job_work_quest_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (job variety), User Requirements (meaningful work)
- **Acceptance Criteria:**
  1. Dock worker: cargo scanner, manifest pad
  2. Medical courier: medical supplies, cooler
  3. Retail clerk: price gun, security tag remover
  4. Universal work items: ID badge, timecard
  5. Clear item purpose from visuals
  6. Consistent 32x32 size
  7. Inventory-ready sprites

**Implementation Notes:**
- Match aesthetic to job locations
- Some items reveal clues when examined
- Include worn/used appearance
- Color coding for job types

### Task 8: Spaceport District Population
**User Story:** As a player, I want the Spaceport to feel like a busy hub of interstellar travel with workers, travelers, and unique characters, so that the district feels alive and provides job opportunities.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (district uniqueness), User Requirements (meaningful work)
- **Acceptance Criteria:**
  1. 20 unique NPCs with personalities
  2. Loading dock job quests (3)
  3. Customs inspection quests (2)
  4. Ship arrival/departure events
  5. Ambient traveler crowds
  6. Environmental storytelling elements

**Implementation Notes:**
- Reference: docs/design/template_district_design.md
- NPCs should follow docs/design/template_npc_design.md
- Integrate with job system from Iteration 11
- Coordinate with Dock Worker job implementation (Task 8)

### Task 9: Security District Population
**User Story:** As a player, I want the Security district to feel like an active law enforcement center with ongoing investigations and prisoner management, so that I can engage with the justice system and uncover corruption.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (district uniqueness), User Requirements (unexpected events)
- **Acceptance Criteria:**
  1. 20 NPCs including prisoner rotation
  2. Investigation assistance quests (3)
  3. Prisoner interview quests (2)
  4. Crime/security breach events
  5. Brig population system
  6. Evidence room interactions

**Implementation Notes:**
- Reference: docs/design/crime_security_event_system_design.md
- Integrate with investigation system from Iteration 15
- Security patrol job already implemented in Iteration 11 (First Quest)

### Task 10: Medical District Population
**User Story:** As a player, I want the Medical district to feel like a functioning hospital with staff, patients, and ongoing medical situations, so that I can witness the assimilation's impact on healthcare.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (believable communities), User Requirements (environmental stories)
- **Acceptance Criteria:**
  1. 15 NPCs with medical roles
  2. Patient care quests (3)
  3. Research assistance quests (2)
  4. Medical emergency events
  5. Patient rotation system
  6. Lab mystery elements

**Implementation Notes:**
- Reference: docs/design/template_district_design.md
- Coordinate with Medical Courier job implementation (Task 9)
- Emergency events should hint at assimilation spread

### Task 11: Mall District Population
**User Story:** As a player, I want the Mall to feel like a bustling commerce center with diverse shops, crowds, and social interactions, so that I can observe society's facade of normalcy.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (job gameplay variety), User Requirements (alive districts)
- **Acceptance Criteria:**
  1. 30 NPCs (shopkeepers, customers, workers)
  2. Retail job quests (4)
  3. Service job quests (2)
  4. Shopping events and sales
  5. Dynamic customer crowds
  6. Shop inventory systems

**Implementation Notes:**
- Reference: docs/design/economy_system_design.md (Shop System)
- Coordinate with Retail Clerk job implementation (Task 10)
- Largest NPC population requires performance optimization

### Task 12: District Event Implementation
**User Story:** As a player, I want each district to have unique events that make the world feel alive and unpredictable, so that repeated visits reveal new situations and opportunities.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (dynamic experiences), User Requirements (unexpected events)
- **Acceptance Criteria:**
  1. Spaceport: arrivals, departures, cargo incidents
  2. Security: arrests, escapes, investigations
  3. Medical: emergencies, outbreaks, breakthroughs
  4. Mall: sales, thefts, social gatherings
  5. Event scheduling system
  6. Player involvement options

**Implementation Notes:**
- Reference: docs/design/living_world_event_system_design.md
- Events should create job opportunities and investigation leads
- Some events reveal assimilation progress

### Task 13: Ambient Crowd Systems
**User Story:** As a developer, I want to implement lightweight crowd NPCs that add life without full interaction complexity, so that busy areas feel populated without impacting performance.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Technical Requirements (performance with 85+ NPCs), User Requirements (alive districts)
- **Acceptance Criteria:**
  1. Lightweight crowd NPCs
  2. Path-based movement
  3. Time-based density
  4. Performance optimization
  5. Visual variety

**Implementation Notes:**
- Reference: docs/design/template_npc_design.md (Ambient NPCs section)
- Target 60 FPS with full crowds
- Use LOD and culling aggressively

### Task 14: Environmental Storytelling
**User Story:** As a player, I want to discover stories through environmental details, so that exploration reveals the station's history and hidden narratives.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** User Requirements (environmental stories), Business Requirements (district uniqueness)
- **Acceptance Criteria:**
  1. Personal items and notes
  2. Visual story elements
  3. District history hints
  4. Character backstory clues
  5. Mystery breadcrumbs

**Implementation Notes:**
- Reference: docs/design/investigation_clue_system_design.md
- Environmental clues should support main narrative
- Each district needs 5-10 environmental stories

### Task 15: Dock Worker Job Implementation
**User Story:** As a player, I want to work as a dock worker loading and unloading cargo, so that I can earn credits while discovering clues about mysterious shipments.

**Design Reference:** `docs/design/job_work_quest_system_design.md` (Spaceport - Dock Worker, lines 88-187)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (job gameplay variety), User Requirements (meaningful work)
- **Acceptance Criteria:**
  1. Foreman Chen NPC as quest giver
  2. Intro quest: "New Hire Orientation"
  3. 3 shift variants: Standard Cargo, Rush Delivery, Night Shift
  4. Cargo loading mini-game mechanics
  5. Performance evaluation system
  6. Mysterious shipment clue opportunities
  7. Gender-based difficulty modifiers

**Implementation Notes:**
- Physical labor job - male characters have 10% easier time
- Female characters face 15% harder difficulty and harassment events
- Night shift variant provides best investigation opportunities
- Base pay: 40 credits per 4-hour shift

### Task 16: Medical Courier Job Implementation
**User Story:** As a player, I want to work as a medical courier delivering critical supplies, so that I can access restricted medical areas and discover contamination clues.

**Design Reference:** `docs/design/job_work_quest_system_design.md` (Medical - Supply Courier, lines 266-354)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (job gameplay variety), User Requirements (meaningful work)
- **Acceptance Criteria:**
  1. Nurse Patel NPC as quest giver
  2. Intro quest: "Emergency Supplies"
  3. 3 shift variants: Routine Delivery, Biohazard Transport, Blood Drive
  4. Time-critical delivery mechanics
  5. Medical access badge rewards
  6. Contamination/assimilation clues
  7. Gender dynamics in medical setting

**Implementation Notes:**
- Caregiving role - female characters have 5% easier time
- Male characters face 5% harder difficulty (suspicion)
- Biohazard transport variant has 15% chance of sample leak
- Base pay: 60 credits per 3-hour shift

### Task 17: Retail Clerk Job Implementation
**User Story:** As a player, I want to work as a retail clerk serving customers and preventing theft, so that I can observe drone behavior patterns and build mall connections.

**Design Reference:** `docs/design/job_work_quest_system_design.md` (Mall - Retail Clerk, lines 356-455)

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Business Requirements (job gameplay variety), User Requirements (meaningful work)
- **Acceptance Criteria:**
  1. Manager Kim NPC as quest giver
  2. Intro quest: "Sales Training"
  3. 3 shift variants: Sales Floor, Loss Prevention, Overnight Inventory
  4. Customer service interaction system
  5. Shoplifter detection mechanics
  6. Drone customer behavior clues
  7. Gender-specific customer interactions

**Implementation Notes:**
- Service role - female characters expected (normal difficulty)
- Male characters face 10% harder difficulty (customer skepticism)
- Female characters face more harassment events
- Base pay: 35 credits per 4-hour shift

### Task 18: Validate perspective configurations for new districts
**User Story:** As a developer, I want to ensure that Medical Bay and Market Square districts have appropriate perspective settings with full sprite scaling integration, so that characters display correctly and the depth perception system works seamlessly in all game areas.

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md` lines 136-151, `docs/design/sprite_perspective_scaling_full_plan.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (memory management), Business Requirements (district uniqueness)
- **Acceptance Criteria:**
  1. Medical Bay perspective type configured (likely ISOMETRIC)
  2. Market Square perspective type configured (likely ISOMETRIC or TOP_DOWN)
  3. Character sprites load correctly in each district
  4. Perspective transitions work from/to these districts
  5. Audio scaling adjusts appropriately
  6. Performance remains optimal with perspective changes
  7. **Enhanced:** District-specific DistrictPerspectiveConfig resources created
  8. **Enhanced:** Scaling zones properly defined for each new district
  9. **Enhanced:** Movement speed scaling calibrated for district layouts
  10. **Enhanced:** LOD thresholds optimized for district NPC density
  11. **Enhanced:** Foreground occlusion layers work with perspective scaling
  12. **Enhanced:** Zone transitions tested at district boundaries

**Implementation Notes:**
- Test with both male and female Alex sprites
- Verify perspective parameters in district JSON
- Check camera settings match perspective type
- Validate foreground occlusion works correctly
- Test memory usage during perspective transitions
- **Enhanced:** Create Medical Bay config with tighter scaling for clinical feel
- **Enhanced:** Create Market Square config with varied zones for open/crowded areas
- **Enhanced:** Test with 30+ NPCs in Mall district for performance
- **Enhanced:** Verify scaling zone boundaries align with walkable areas
- **Enhanced:** Test perspective + scaling transitions between connected districts
- **Enhanced:** Profile performance with full perspective system active

## Testing Criteria
- All 85 NPCs function without conflicts
- Job quests complete properly
- Events trigger appropriately
- Performance remains stable
- Districts feel uniquely populated
- Crowd systems don't impact gameplay
- Environmental stories discoverable
- Dock Worker shifts advance time correctly
- Medical Courier deliveries respect time limits
- Retail Clerk customer interactions work
- Gender modifiers apply correctly to all jobs
- Job performance evaluations calculate properly
- Workplace clues discoverable during shifts
- Job payments integrate with economy
- Perspective configurations work in all districts
- Character sprites display correctly per perspective
- setup_multi_perspective.sh creates all required infrastructure
- generate_perspective_sprites.sh processes sprites correctly
- **Enhanced:** Sprite scaling creates proper depth illusion in all new districts
- **Enhanced:** Zone transitions maintain smooth scaling between districts
- **Enhanced:** Movement speed adjustments feel natural in populated areas
- **Enhanced:** Audio attenuation properly reflects sprite distances
- **Enhanced:** LOD system maintains 60 FPS with 85+ NPCs
- **Enhanced:** District boundaries handle perspective + scaling transitions

### Task 19: Create setup_multi_perspective.sh automation script
**User Story:** As a developer, I want an automated script to set up the multi-perspective character system infrastructure, so that new team members or fresh installations can quickly configure the system correctly.

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md` lines 117-123

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (performance), Business Requirements (district uniqueness)
- **Acceptance Criteria:**
  1. Script creates all required directory structures
  2. Generates configuration templates for each perspective type
  3. Sets up default perspective parameters
  4. Creates example character configurations
  5. Validates setup completion
  6. Provides clear error messages

**Implementation Notes:**
- Shell script to automate setup process
- Create directories: src/characters/perspectives/
- Generate template JSON configs for ISOMETRIC, SIDE_SCROLLING, TOP_DOWN
- Include validation checks for dependencies
- Document usage in script header

### Task 20: Create generate_perspective_sprites.sh script
**User Story:** As a content creator, I want an automated script to generate character sprites for all perspective types, so that creating multi-perspective NPCs is efficient and consistent.

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md` lines 124-135

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (performance with 85+ NPCs), Business Requirements (believable communities)
- **Acceptance Criteria:**
  1. Script processes source sprites into perspective variants
  2. Supports batch processing for multiple characters
  3. Maintains consistent art style across perspectives
  4. Generates proper directory structure
  5. Creates animation configuration files
  6. Optimizes sprites for performance

**Implementation Notes:**
- Wrapper around sprite_workflow.md processing
- Input: base character sprites
- Output: organized perspective-specific sprite sheets
- Support for the 85 NPCs being created in this iteration
- Integration with existing sprite pipeline tools

### Task 21: Add district-specific trust-building activities
**User Story:** As a player, I want each district to offer unique opportunities to build trust with NPCs through activities that match the district's theme, so that relationship building feels integrated with the world.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Trust Building Mechanics)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (district uniqueness), User Requirements (memorable characters)
- **Acceptance Criteria:**
  1. Spaceport: Help with cargo, share travel stories
  2. Security: Assist investigations, vouch for NPCs
  3. Medical: Comfort patients, donate to research
  4. Mall: Shop together, recommend products
  5. Each activity grants appropriate trust dimensions
  6. Activities respect NPC schedules and routines
  7. Visual feedback when activities available

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (TRUST_ACTIONS)
- Spaceport cargo help: +10 professional, +5 personal
- Security investigation: +15 professional, +5 ideological
- Medical comfort: +15 emotional, +10 personal
- Mall shopping: +8 personal, +5 emotional

### Task 22: Create shared meal and social interaction opportunities
**User Story:** As a player, I want to share meals and have social moments with NPCs during their break times, so that relationships can develop naturally through everyday interactions.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Special Occasions)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** User Requirements (meaningful relationships)
- **Acceptance Criteria:**
  1. Meal times at 12:00-13:00 and 18:00-19:00
  2. NPCs available based on schedules
  3. Cafeteria areas in each district
  4. First meal together: +8 emotional, +5 personal
  5. Birthday celebrations when applicable
  6. Group meals with multiple NPCs
  7. Dialog reflects shared meal history

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (check_relationship_opportunities)
- Track has_shared_meal flag per NPC
- Group meals enable NPC introductions
- Birthday bonus: +15 personal, +10 emotional

### Task 23: Implement location-based relationship events
**User Story:** As a player, I want spontaneous relationship-building opportunities to emerge based on where I am and who's nearby, so that the world feels reactive to my presence.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Context-Sensitive Actions)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** User Requirements (unexpected events)
- **Acceptance Criteria:**
  1. NPCs in distress trigger help opportunities
  2. Workplace interactions during job shifts
  3. Random encounters in district spaces
  4. Coalition members share intel discretely
  5. Context determines available actions
  6. 10-20% chance per area visit
  7. Events reflect current game state

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (get_available_trust_actions)
- Distress events: +15 emotional, +10 personal
- Workplace help: +10 professional
- Intel sharing requires trust > 60
- More events as assimilation spreads

## Timeline
- **Estimated Duration:** 8-9 weeks (including asset creation)
- **Total Hours:** 310 (120 + 50 for job implementations + 5 for automation scripts + 135 for asset creation)
- **Critical Path:** Asset creation → NPCs implementation → Quest assignment
- **Asset Creation Breakdown:**
  - 85 NPCs × 1.5 hours average = 127.5 hours
  - Interactive objects: 5 hours
  - Audio assets: 5 hours
  - Job items: 2.5 hours

## Definition of Done
- [ ] 85 NPC sprites created with animations
- [ ] District-specific interactive objects designed
- [ ] Additional audio assets produced
- [ ] Job-specific items created
- [ ] 85 NPCs implemented across 4 districts
- [ ] All job quests functional
- [ ] District events triggering properly
- [ ] Ambient crowds working
- [ ] Environmental stories placed
- [ ] Performance optimized
- [ ] Districts feel alive and unique
- [ ] Perspective configurations validated
- [ ] Automation scripts created and tested

## Dependencies
- Core content foundation (Iteration 17)
- All Phase 2 systems
- Performance baseline established

## Risks and Mitigations
- **Risk:** NPC count impacts performance
  - **Mitigation:** LOD systems, culling, crowd optimization
- **Risk:** Quest complexity causes bugs
  - **Mitigation:** Incremental testing, clear quest templates
- **Risk:** District identity not distinct
  - **Mitigation:** Strong art direction, unique events

## Links to Relevant Code
- data/npcs/spaceport/
- data/npcs/security/
- data/npcs/medical/
- data/npcs/mall/
- data/quests/jobs/
- data/events/districts/
- src/content/crowds/
- src/content/environmental/