# Iteration 17: Core Content Foundation

## Epic Description
As a content creator, I want to implement the foundational content including all district backgrounds, core NPCs, the main story quest line, and the complete multiple endings system, establishing the playable skeleton of the complete game.

## Cohesive Goal
**"The full game world exists and the main story can be played end-to-end with multiple endings"**

## Overview
This iteration implements Phase 3.1 from the content roadmap, creating the core foundation of all game content. This includes all seven district backgrounds, the 50 most essential NPCs, the complete main story quest line from start to multiple endings, and the full ending determination system based on assimilation ratios.

## Goals
- Implement all 7 district backgrounds with navigation
- Create 50 core NPCs essential for main story
- Implement complete main story quest line
- Implement complete multiple endings system with Day 30 evaluation
- Create control path and escape path final quests
- Set up district transitions via tram system
- Configure all diegetic audio sources
- Enable full game playthrough to all endings

## Requirements

### Business Requirements
- **B1:** Playable game from start to any ending
  - **Rationale:** Complete narrative experience is essential for player satisfaction
  - **Success Metric:** All ending paths achievable through gameplay
- **B2:** All locations accessible and functional
  - **Rationale:** Complete world enables full exploration
  - **Success Metric:** All 7 districts explorable without blockers
- **B3:** Core cast brings story to life
  - **Rationale:** Characters drive narrative engagement
  - **Success Metric:** 50 NPCs with distinct personalities implemented
- **B4:** Main narrative arc compelling and complete
  - **Rationale:** Story quality determines player retention
  - **Success Metric:** Playtesters report emotional investment in outcomes

### User Requirements
- **U1:** Explore all districts of the space station
  - **User Value:** Discovery and world-building satisfaction
  - **Acceptance Criteria:** All 7 districts accessible via tram
- **U2:** Meet essential characters for the story
  - **User Value:** Character relationships drive engagement
  - **Acceptance Criteria:** 50 unique NPCs with dialog and schedules
- **U3:** Complete main quest line with choices
  - **User Value:** Player agency affects story outcome
  - **Acceptance Criteria:** Multiple paths through main story
- **U4:** Experience different endings based on decisions
  - **User Value:** Replayability and consequence for actions
  - **Acceptance Criteria:** Control and escape endings both achievable
- **U5:** Navigate seamlessly between areas
  - **User Value:** Immersive exploration without friction
  - **Acceptance Criteria:** Smooth transitions via tram system

### Technical Requirements
- **T1:** All districts properly configured
  - **Rationale:** Foundation for all gameplay
  - **Constraints:** Must support perspective changes
- **T2:** NPCs integrated with all systems
  - **Rationale:** Characters must behave consistently
  - **Constraints:** Schedule, dialog, trust systems must integrate
- **T3:** Quest progression saves correctly
  - **Rationale:** Progress must persist
  - **Constraints:** Serialization of quest states
- **T4:** Performance stable with core content
  - **Rationale:** Smooth gameplay required
  - **Constraints:** 60 FPS with 50+ NPCs
- **T5:** Tram system fully functional
  - **Rationale:** District connectivity essential
  - **Constraints:** Loading optimization required
- **T6:** Ending system integrates with all game systems
  - **Rationale:** Endings must reflect player's full journey
  - **Constraints:** Must track assimilation, coalition, and time data

## Tasks

### Asset Creation Prerequisites
- [ ] Task 1: Create base character template and animation rig
- [ ] Task 2: Design UI element sprites (verbs, inventory, dialog)
- [ ] Task 3: Create common inventory item sprites (keycards, tools, etc.)
- [ ] Task 4: Design all 7 district background art assets
- [ ] Task 5: Create 50 core NPC sprite assets with animations
- [ ] Task 6: Design interactive object sprites for all districts
- [ ] Task 7: Produce district ambient audio loops and sound effects
- [ ] Task 8: Create system UI sounds and feedback audio

### District Implementation
- [ ] Task 9: Implement all 7 district backgrounds
- [ ] Task 10: Configure walkable areas and navigation
- [ ] Task 11: Place interactive objects throughout districts
- [ ] Task 12: Create district foreground occlusion content
- [ ] Task 13: Configure district audio atmosphere
- [ ] Task 14: Set up tram system integration

### NPC and Story Implementation
- [ ] Task 15: Implement 50 core story NPCs
- [ ] Task 16: Create main story quest progression
- [ ] Task 17: Implement investigation quest chains
- [ ] Task 18: Build coalition formation quests

### Multiple Endings System
- [ ] Task 19: Create EndingManager singleton
- [ ] Task 20: Implement critical evaluation day system
- [ ] Task 21: Build assimilation ratio calculation
- [ ] Task 22: Create control path final quest
- [ ] Task 23: Create escape path final quest
- [ ] Task 24: Implement ending determination logic
- [ ] Task 25: Build ending display UI
- [ ] Task 26: Create ending serialization system
- [ ] Task 27: Integrate with existing game systems
- [ ] Task 28: Add evaluation countdown warnings
- [ ] Task 29: Implement faction-specific ending variations
- [ ] Task 30: Create partial success states

### Testing and Polish
- [ ] Task 31: Test critical path to all endings
- [ ] Task 32: Performance optimization pass
- [ ] Task 33: Bug fixing and polish

### Trust and Relationship UI Systems
- [ ] Task 34: Create RelationshipManager singleton system
- [ ] Task 35: Implement relationship UI components (HUD, journal, trust breakdown)
- [ ] Task 36: Add relationship milestone and opportunity system

## User Stories

### Task 1: Create base character template and animation rig

**User Story:** As a solo developer, I want a reusable character template with standard animations and proportions, so that I can efficiently create 150 unique NPCs while maintaining visual consistency.

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md`, `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, T2
- **Acceptance Criteria:**
  1. Base character proportions defined (64x64 sprite size)
  2. Animation frames standardized (8-frame walk, 4-frame idle, 2-frame talk)
  3. Gender variant templates created
  4. Pivot points and sizing consistent
  5. Reusable template files created
  6. Layer organization for easy customization
  7. Export settings documented

**Implementation Notes:**
- Use consistent pivot point at character feet
- Create male and female base templates
- Include all 8 directional walk cycles
- Set up animation naming conventions
- Consider 1950s noir aesthetic in proportions

### Task 2: Design UI element sprites (verbs, inventory, dialog)

**User Story:** As a player, I want clear, readable UI elements that match the retro-noir aesthetic, so that the interface feels integrated with the game world.

**Design Reference:** `docs/design/verb_ui_design.md`, `docs/design/dialog_manager_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1
- **Acceptance Criteria:**
  1. 9 verb button sprites created (Look, Talk, Use, etc.)
  2. Inventory slot graphics designed
  3. Dialog UI elements (boxes, arrows, portraits)
  4. Button states (normal, hover, pressed)
  5. Consistent color palette and style
  6. Readable at 320x240 and scaled resolutions
  7. SCUMM-style aesthetic achieved

**Implementation Notes:**
- Reference classic SCUMM games for verb layout
- Use art deco inspired borders
- Ensure high contrast for readability
- Include disabled states for verbs

### Task 3: Create common inventory item sprites (keycards, tools, etc.)

**User Story:** As a player, I want inventory items to be visually distinct and immediately recognizable, so that I can quickly identify what I'm carrying.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1
- **Acceptance Criteria:**
  1. Universal keycard designs (5 security levels)
  2. Common tools (screwdriver, wrench, etc.)
  3. Investigation items (notebook, magnifying glass)
  4. Key story items placeholder art
  5. Consistent 32x32 item size
  6. Clear silhouettes for recognition
  7. Item state variations (used/unused)

**Implementation Notes:**
- Use color coding for keycard security levels
- Ensure items read well at small size
- Consider inventory UI constraints
- Include sparkle/highlight for important items

### Task 4: Design all 7 district background art assets

**User Story:** As a player, I want each district to have a unique visual identity that immediately communicates its purpose and atmosphere, so that navigation feels intuitive and exploration rewarding.

**Design Reference:** `docs/design/template_district_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1, T1
- **Acceptance Criteria:**
  1. Spaceport - retro-futuristic docking bays
  2. Security - authoritarian offices and brig
  3. Medical - sterile hospital environments  
  4. Mall - busy commercial center
  5. Trading Floor - corporate financial hub
  6. Barracks - utilitarian living quarters
  7. Engineering - industrial machinery spaces
  8. All at 320x240 base resolution
  9. Foreground elements separated for occlusion

**Implementation Notes:**
- Maintain consistent perspective across districts
- Use limited color palettes per district
- Include ambient animation opportunities
- Design with walkable areas in mind
- Reference 1950s architectural styles

### Task 5: Create 50 core NPC sprite assets with animations

**User Story:** As a player, I want the main story NPCs to be visually memorable and distinct, so that I can form emotional connections and easily identify important characters.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U2, T2
- **Acceptance Criteria:**
  1. 50 unique character designs based on templates
  2. Mix of genders, ages, and professions
  3. All standard animations implemented
  4. Distinctive silhouettes and color schemes
  5. Story-relevant visual details
  6. Assimilation visual indicators ready
  7. Consistent with 1950s aesthetic

**Implementation Notes:**
- Prioritize main quest givers
- Include faction leaders
- Design with personality in mind
- Some NPCs need multiple states
- Reference character background documents

### Task 6: Design interactive object sprites for all districts

**User Story:** As a player, I want interactive objects to stand out subtly from the background while maintaining visual cohesion, so that I can identify opportunities without breaking immersion.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1, T1
- **Acceptance Criteria:**
  1. 5-10 unique objects per district
  2. Consistent interaction highlighting
  3. Multiple states where needed (open/closed)
  4. Appropriate to district themes
  5. Clear interaction hotspots
  6. Readable at game resolution
  7. Animation frames for active objects

**Implementation Notes:**
- Terminals, doors, containers primary
- Include flavor objects for atmosphere
- Design hover/highlight states
- Consider perspective scaling needs

### Task 7: Produce district ambient audio loops and sound effects

**User Story:** As a player, I want each district to have a unique soundscape that reinforces its purpose and atmosphere, so that audio enhances the sense of place.

**Design Reference:** `docs/design/audio_system_design.md`, `docs/design/phase3_content_implementation_roadmap.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1, T1
- **Acceptance Criteria:**
  1. Unique 2-3 minute ambient loop per district
  2. Seamless looping without pops/clicks
  3. District-appropriate sound palette
  4. Diegetic sound sources identified
  5. Day/night variations where appropriate
  6. Proper audio format (OGG Vorbis)
  7. Normalized volume levels

**Implementation Notes:**
- Spaceport: engines, announcements
- Medical: monitors, ventilation
- Mall: crowd murmur, muzak
- Engineering: machinery, computers
- Keep ambience subtle, not overwhelming

### Task 8: Create system UI sounds and feedback audio

**User Story:** As a player, I want clear audio feedback for my actions and UI interactions, so that the game feels responsive and polished.

**Design Reference:** `docs/design/audio_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1
- **Acceptance Criteria:**
  1. UI click/hover sounds
  2. Inventory interaction sounds
  3. Dialog advance sounds
  4. Notification alerts
  5. Success/failure feedback
  6. Consistent volume levels
  7. Non-intrusive design

**Implementation Notes:**
- Keep UI sounds subtle
- Use consistent audio palette
- Consider frequency ranges
- Test with repeated use
- Ensure no listener fatigue

### Task 9: Implement all 7 district backgrounds

**User Story:** As a player, I want to explore all seven unique districts of the space station, each with its own distinct atmosphere and purpose, so that the world feels complete and varied.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1, T1
- **Acceptance Criteria:**
  1. Spaceport - bustling import/export hub atmosphere
  2. Security - authoritarian control center aesthetic
  3. Medical - sterile hospital environment
  4. Mall - vibrant commerce center
  5. Trading Floor - corporate financial hub
  6. Barracks - military residential quarters
  7. Engineering - industrial maintenance area
  8. All backgrounds properly scaled for gameplay
  9. Perspective-appropriate artwork implemented

**Implementation Notes:**
- Use established art templates for consistency
- Each district needs 2048x1536 base resolution
- Consider perspective requirements per district
- Implement proper scaling for different screen sizes

### Task 10: Configure walkable areas and navigation

**User Story:** As a player, I want to move naturally through each district without getting stuck or accessing unintended areas, so that exploration feels smooth and intuitive.

**Design Reference:** `docs/design/navigation_pathfinding_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U5, T1
- **Acceptance Criteria:**
  1. Walkable polygons defined for all districts
  2. Proper collision boundaries set
  3. Smooth pathfinding configured
  4. District entry/exit points marked
  5. Vertical depth layers configured
  6. No navigation dead zones
  7. Proper obstacle avoidance

**Implementation Notes:**
- Use NavigationPolygonInstance for each district
- Test with various screen resolutions
- Ensure tram station connections work
- Account for perspective changes affecting navigation

### Task 11: Place interactive objects throughout districts

**User Story:** As a player, I want each district to feel alive with objects I can examine, use, or interact with to learn more about the world, so that exploration is rewarding.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B4, U1, T1
- **Acceptance Criteria:**
  1. 5-10 interactive objects per district minimum
  2. Consistent interaction patterns across objects
  3. Environmental storytelling through object descriptions
  4. Proper verb responses for all objects
  5. Save state persistence for object states
  6. Visual feedback for interactable items

**Implementation Notes:**
- Reference interactive object template
- Include both functional and flavor objects
- Some objects should hint at assimilation threat
- Ensure proper z-ordering for click detection

### Task 12: Create district foreground occlusion content

**User Story:** As a player, I want to walk behind foreground objects in each district, creating a sense of depth and immersion in the environment.

**Design Reference:** `docs/design/foreground_occlusion_mvp_plan.md`, `docs/design/foreground_occlusion_full_plan.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1, T1
- **Acceptance Criteria:**
  1. Extract foreground elements from each district background
  2. Create occlusion zones for major objects
  3. Configure per-perspective rules where needed
  4. Test character occlusion in all districts
  5. Optimize performance with many zones
  6. Visual depth enhancement achieved

**Implementation Notes:**
- Use automated extraction tools from Iteration 15
- Focus on major architectural elements
- Test with both Alex character models
- Performance target: <5% FPS impact

### Task 13: Configure district audio atmosphere

**User Story:** As a player, I want each district to have unique ambient sounds that reinforce its purpose and atmosphere, so that audio enhances immersion.

**Design Reference:** `docs/design/audio_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1, T1
- **Acceptance Criteria:**
  1. Unique ambient loops per district
  2. Diegetic music sources placed appropriately
  3. Environmental sound effects positioned
  4. Audio zones properly configured
  5. Volume falloff settings tuned
  6. Smooth audio transitions between districts

**Implementation Notes:**
- Reference audio system design for implementation
- Use 3D audio for positioned sources
- Ensure loops are seamless
- Consider perspective impact on audio

### Task 14: Set up tram system integration

**User Story:** As a player, I want to use the tram system to travel between districts while experiencing the journey, so that travel feels integrated into the world.

**Design Reference:** `docs/design/tram_transportation_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U5, T5
- **Acceptance Criteria:**
  1. Tram stations placed in each district
  2. Transition sequences implemented
  3. Schedule system integrated
  4. Access control validation working
  5. Loading optimization complete
  6. Travel time passes appropriately

**Implementation Notes:**
- Reference tram system from Iteration 15
- Each district needs designated station area
- Loading should happen during transition
- Time should advance based on distance

### Task 15: Implement 50 core story NPCs

**User Story:** As a player, I want to meet the key characters who drive the main story, each with distinct personalities and roles, so that the narrative feels character-driven.

**Design Reference:** `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U2, T2
- **Acceptance Criteria:**
  1. 50 unique character sprites and animations
  2. Initial dialog trees for all NPCs
  3. Daily schedules configured per character
  4. Trust relationships initialized
  5. Home districts assigned appropriately
  6. Personality traits defined
  7. Assimilation states configured

**Implementation Notes:**
- Focus on story-critical NPCs first
- Use NPC template for consistency
- Include mix of potential allies and threats
- Some NPCs should be secretly assimilated

### Task 16: Create main story quest progression

**User Story:** As a player, I want to experience the full narrative arc from discovering the assimilation threat to choosing how to resolve it, so that my journey feels complete and meaningful.

**Design Reference:** `docs/design/template_quest_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B4, U3, T3
- **Acceptance Criteria:**
  1. Intro quest (awakening sequence) implemented
  2. Investigation progression with clue discovery
  3. Coalition building path with key allies
  4. Climactic confrontation prepared
  5. Branching points that affect ending
  6. Save points at key story moments
  7. Quest interconnections configured

**Implementation Notes:**
- Main quest should guide but not railroad
- Include optional paths for different playstyles
- Connect to investigation and coalition systems
- Build toward Day 30 evaluation

### Task 17: Implement investigation quest chains

**User Story:** As a player, I want to uncover the assimilation conspiracy through investigation and deduction, so that I feel like a detective solving a mystery.

**Design Reference:** `docs/design/investigation_clue_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B4, U3, T3
- **Acceptance Criteria:**
  1. Multiple investigation threads implemented
  2. Clue discovery mechanics working
  3. Evidence combination system functional
  4. Red herrings and false leads included
  5. Deduction affects available options
  6. Investigation impacts ending path

**Implementation Notes:**
- Connect to ClueManager from Iteration 15
- Include environmental and dialog clues
- Some clues only available with high trust
- Investigation success affects coalition strength

### Task 18: Build coalition formation quests

**User Story:** As a player, I want to build a resistance coalition by recruiting allies and earning trust, so that I'm not alone in fighting the threat.

**Design Reference:** `docs/design/coalition_resistance_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B4, U3, T3
- **Acceptance Criteria:**
  1. Recruitment missions for key allies
  2. Trust-building side quests
  3. Coalition strength affects options
  4. Betrayal possibilities included
  5. Coalition size impacts ending
  6. Resource sharing mechanics

**Implementation Notes:**
- Connect to CoalitionManager system
- High trust required for recruitment
- Some NPCs have conflicting loyalties
- Coalition strength affects ending success

### Task 19: Create EndingManager singleton

**User Story:** As a developer, I want a centralized system to manage ending determination and execution, so that all ending logic is consistent and maintainable.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 26-146

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T6
- **Acceptance Criteria:**
  1. Singleton autoload created
  2. Configuration for evaluation day (default: 30)
  3. Threshold settings (65% control, 35% escape)
  4. State tracking for ending path
  5. Signal system for ending events
  6. Integration points for other systems

**Implementation Notes:**
- Implement as autoload singleton
- Make thresholds configurable for balance
- Emit signals for UI updates
- Track historical ratio data

### Task 20: Implement critical evaluation day system

**User Story:** As a player, I want the game to evaluate my progress on a specific day and determine my path forward, so that my actions throughout the game have meaningful consequences.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 46-75

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T6
- **Acceptance Criteria:**
  1. Day 30 triggers evaluation automatically
  2. Evaluation checks assimilation ratio
  3. Path locked after evaluation
  4. Clear UI notification of result
  5. Save point created before evaluation
  6. No manual override possible

**Implementation Notes:**
- Hook into TimeManager day change
- Prevent save scumming around evaluation
- Make evaluation day visible in UI
- Consider dynamic evaluation date in future

### Task 21: Build assimilation ratio calculation

**User Story:** As a developer, I want accurate tracking of station-wide assimilation percentages, so that the ending evaluation reflects the true game state.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 333-366

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T6
- **Acceptance Criteria:**
  1. Accurate count of all NPCs
  2. Track assimilated vs unassimilated
  3. Real-time ratio updates
  4. Leader/drone categorization
  5. Coalition member tracking
  6. District breakdown available

**Implementation Notes:**
- Integrate with AssimilationManager
- Account for NPC deaths/disappearances
- Leaders count more in some calculations
- Display ratio in UI leading to Day 30

### Task 22: Create control path final quest

**User Story:** As a player who has kept assimilation under control, I want to fight to maintain station independence from corporate takeover, so that my success in containing the threat matters.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 148-225

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T3
- **Acceptance Criteria:**
  1. "Save the Station" quest activates at 65%+ unassimilated
  2. Multiple objectives to stop corporate sale
  3. 7-day time limit implemented
  4. Coalition resources affect options
  5. Multiple solution paths available
  6. Success/failure states defined

**Implementation Notes:**
- Quest ID: "final_control_station"
- Include legal, technical, and social solutions
- Coalition strength affects difficulty
- Assimilation continues during quest

### Task 23: Create escape path final quest

**User Story:** As a player who failed to contain the assimilation, I want to organize an escape for the remaining survivors, so that some hope remains even in defeat.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 227-298

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T3
- **Acceptance Criteria:**
  1. "Abandon Ship" quest activates below 35% unassimilated
  2. Gather survivors with verification
  3. 3-day urgent time limit
  4. Secure transportation options
  5. Resource collection required
  6. Betrayal possibilities included

**Implementation Notes:**
- Quest ID: "final_escape_station"
- Accelerated assimilation during escape
- Some "survivors" may be infiltrators
- Capacity limits on escape vessels

### Task 24: Implement ending determination logic

**User Story:** As a developer, I want clear logic that determines which ending path activates based on game state, so that the system reliably delivers appropriate conclusions.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 50-75

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T6
- **Acceptance Criteria:**
  1. Clear threshold check (65%/35%)
  2. Unambiguous path selection
  3. Ending data properly stored
  4. Coalition size recorded
  5. Key statistics captured
  6. Path cannot be changed after selection

**Implementation Notes:**
- No middle ground - must be control or escape
- Store comprehensive stats for ending
- Consider faction influence on ending
- Lock in path immediately

### Task 25: Build ending display UI

**User Story:** As a player, I want to see my ending presented clearly with statistics about my journey, so that I understand the consequences of my choices.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 628-666

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4
- **Acceptance Criteria:**
  1. Clean text-based ending display
  2. Statistics summary shown
  3. Ending text reflects choices
  4. No cinematics required
  5. Return to main menu option
  6. Achievement integration

**Implementation Notes:**
- Simple but effective presentation
- Show key statistics clearly
- Text variations based on success degree
- Terminal/newspaper aesthetic

### Task 26: Create ending serialization system

**User Story:** As a player, I want my ending choice and progress to save properly, so that I can complete the final quest across multiple sessions.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 559-594

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, T3, T6
- **Acceptance Criteria:**
  1. EndingSerializer implements BaseSerializer
  2. Ending path saved correctly
  3. Final quest progress persists
  4. Historical ratios stored
  5. Version migration supported
  6. Corruption handling implemented

**Implementation Notes:**
- Register with SaveManager at priority 25
- Save minimal but complete state
- Handle missing ending data gracefully
- Support save during final quest

### Task 27: Integrate with existing game systems

**User Story:** As a developer, I want the ending system to properly integrate with all existing systems, so that endings reflect the complete game state.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 333-412

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, T6
- **Acceptance Criteria:**
  1. AssimilationManager integration complete
  2. CoalitionManager affects endings
  3. TimeManager triggers evaluation
  4. QuestManager handles final quests
  5. NPCRegistry provides accurate counts
  6. SaveManager preserves ending state

**Implementation Notes:**
- Extensive integration testing required
- Each system must provide ending data
- No circular dependencies
- Clean API for system queries

### Task 28: Add evaluation countdown warnings

**User Story:** As a player, I want clear warnings as the evaluation day approaches and helpful tutorial messages for new gameplay elements, so that I can prepare for the consequences and understand new mechanics as they're introduced.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 400-412, `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4
- **Acceptance Criteria:**
  1. Warnings at 5, 3, 1, and 0 days
  2. Increasing urgency in messaging
  3. Current ratio shown in warnings
  4. UI prominence increases
  5. Audio cues for final warnings
  6. Cannot be disabled
  7. Tutorial messages for first-time mechanics
  8. Tutorial respects GameSettings.tutorials_enabled
  9. Tutorials use INFO notification type

**Implementation Notes:**
- Use notification system for all warnings
- Color coding: green->yellow->red
- Show exact numbers in later warnings
- Integrate with morning reports
- Tutorial messages use show_tutorial() method
- Track shown tutorials to avoid repetition
- Reference: docs/design/prompt_notification_system_design.md (Tutorial Messages)

### Task 29: Implement faction-specific ending variations

**User Story:** As a player, I want my coalition composition to affect ending details, so that the type of allies I gathered influences the outcome.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 519-532

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4
- **Acceptance Criteria:**
  1. Detect coalition faction balance
  2. Military/civilian/criminal variations
  3. Text changes based on dominance
  4. Faction-specific success factors
  5. Mixed coalition recognized
  6. Affects both control and escape

**Implementation Notes:**
- Check coalition member backgrounds
- Need 60% for faction dominance
- Mixed creates unique text
- Some factions better for certain endings

### Task 30: Create partial success states

**User Story:** As a player, I want degrees of success within each ending path, so that my performance during the final quest affects the ultimate outcome.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 535-551

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4
- **Acceptance Criteria:**
  1. Success calculated on multiple factors
  2. Not just binary pass/fail
  3. Objectives completed percentage
  4. Coalition survival rate
  5. Time efficiency considered
  6. Reflected in ending text

**Implementation Notes:**
- Calculate success degree 0.0-1.0
- Different factors per ending type
- Affects ending text tone
- May unlock special achievements

### Task 31: Test critical path to all endings

**User Story:** As a developer, I want to verify all ending paths are achievable through normal gameplay, so that players can reach any ending through their choices.

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, B4
- **Acceptance Criteria:**
  1. Control path achievable
  2. Escape path achievable
  3. All quest objectives completable
  4. No blocking bugs found
  5. Save/load works throughout
  6. Performance acceptable

**Implementation Notes:**
- Create test save files at key points
- Document optimal paths
- Test edge cases
- Verify with different play styles

### Task 32: Performance optimization pass

**User Story:** As a developer, I want to ensure the game maintains 60 FPS with all content loaded, so that players have a smooth experience throughout.

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, T4
- **Acceptance Criteria:**
  1. 60 FPS with 50+ NPCs
  2. Scene transitions under 5 seconds
  3. Memory usage stable
  4. No frame drops during endings
  5. LOD systems working
  6. Culling properly configured

**Implementation Notes:**
- Profile all districts with full NPCs
- Optimize sprite rendering
- Implement aggressive culling
- Consider dynamic LOD for NPCs

### Task 33: Bug fixing and polish

**User Story:** As a developer, I want to fix all critical bugs and polish rough edges, so that the core game experience is smooth and professional.

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, B4
- **Acceptance Criteria:**
  1. No game-breaking bugs
  2. No progression blockers
  3. UI responds correctly
  4. Audio plays properly
  5. Visual glitches fixed
  6. Edge cases handled

**Implementation Notes:**
- Focus on critical path first
- Document known issues
- Create bug database
- Prioritize player-facing issues

### Task 34: Create RelationshipManager singleton system

**User Story:** As a game system, I need a centralized RelationshipManager to coordinate all multi-dimensional trust relationships, NPC connections, and faction standings, so that the social dynamics work consistently across all game systems.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (System Architecture - RelationshipManager)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, T2
- **Acceptance Criteria:**
  1. Singleton manages all player-NPC relationships
  2. Tracks multi-dimensional trust (personal, professional, emotional, ideological, fear)
  3. Manages NPC-to-NPC connection networks
  4. Handles faction-wide reputation systems
  5. Emits signals for trust changes and milestones
  6. Integrates with dialog, quest, and coalition systems
  7. Provides comprehensive relationship API
  8. Optimized for 150+ NPCs

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (Core Components)
- Implement as autoload singleton
- Use signals for system communication
- Cache frequently accessed relationships
- Lazy-load NPC connections

### Task 35: Implement relationship UI components (HUD, journal, trust breakdown)

**User Story:** As a player, I want clear visual feedback about my relationships with NPCs including trust levels, relationship types, and trust breakdown across dimensions, so that I can make informed social decisions.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (UI Components)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** U2, U3
- **Acceptance Criteria:**
  1. Relationship HUD shows when talking to NPCs
  2. Trust bar with color-coded relationship status
  3. Trust breakdown visible for trusted NPCs (>40 trust)
  4. Relationship journal tracks all NPC relationships
  5. Journal groups NPCs by relationship type
  6. Gender dynamics and barriers shown in tooltips
  7. Visual indicators for relationship milestones
  8. Quick reference for recent trust changes

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (Relationship Status Display)
- HUD appears contextually during conversations
- Journal accessible from main menu
- Use color coding: green (friend), yellow (neutral), red (hostile)
- Show trust barriers based on gender/profession

### Task 36: Add relationship milestone and opportunity system

**User Story:** As a player, I want to receive notifications about relationship milestones and special opportunities to maintain friendships, so that relationships feel dynamic and require active maintenance.

**Design Reference:** `docs/design/npc_trust_relationship_system_design.md` (Time-Based Decay & Special Occasions)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U2
- **Acceptance Criteria:**
  1. Milestone notifications at trust thresholds (30, 50, 70)
  2. Daily trust decay after 3 days without interaction
  3. Relationship maintenance opportunities (meals, birthdays)
  4. Special event notifications (NPC in distress)
  5. Trust decay warnings for neglected relationships
  6. Context-sensitive trust actions available
  7. Milestone rewards unlock new dialog/quests
  8. Visual/audio feedback for milestones

**Implementation Notes:**
- Reference: docs/design/npc_trust_relationship_system_design.md (check_relationship_opportunities)
- Integrate with TimeManager for daily checks
- Queue notifications to avoid overwhelming player
- Meal times: 12:00-13:00, 18:00-19:00
- Birthday tracking in NPC data

### Task 37: Implement hover text debug mode for development
**User Story:** As a developer, I want a debug overlay that shows detailed hover text information including object IDs, state data, and interaction flags, so that I can debug hover text issues and verify object states during development.

**Design Reference:** `docs/design/scumm_hover_text_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. **Debug Toggle:** F12 key toggles debug hover mode in debug builds
  2. **Object Information:** Show instance ID, class name, and groups
  3. **State Display:** Current state machine state and available transitions
  4. **Interaction Flags:** Display all interaction flags and verb availability
  5. **NPC Data:** For NPCs, show state, assimilation status, and suspicion level
  6. **Performance Metrics:** Show hover text update frequency and cache hits
  7. **Visual Overlay:** Debug info appears alongside normal hover text
  8. **Production Safety:** Debug mode completely disabled in release builds

**Implementation Notes:**
- Reference: docs/design/scumm_hover_text_system_design.md lines 481-504 (Debug Features)
- Implement HoverDebugMode static class:
  ```gdscript
  class HoverDebugMode:
      static func show_debug_info(obj: Node) -> String:
          if not OS.is_debug_build():
              return ""
          
          var debug_info = []
          
          # Object ID
          debug_info.append("ID: " + str(obj.get_instance_id()))
          
          # Interaction flags
          if obj.has_method("get_interaction_flags"):
              debug_info.append("Flags: " + str(obj.get_interaction_flags()))
          
          # State info
          if obj is BaseNPC:
              debug_info.append("State: " + obj.current_state)
              debug_info.append("Assim: " + str(AssimilationManager.is_assimilated(obj.id)))
          
          return " [" + ", ".join(debug_info) + "]"
  ```
- **Toggle System:** Use InputMap for F12 debug toggle, save preference
- **Visual Design:** Debug text in different color (yellow/cyan) with monospace font
- **Performance Tracking:** Show cache hit rate and update frequency
- **NPC Debug Info:** Include personality values, trust levels, current activity
- **Object Debug Info:** Show all state variables, ownership, quest relevance
- **Integration:** Hook into existing HoverTextManager display pipeline
- **Safety:** Wrap all debug code in OS.is_debug_build() checks

## Testing Criteria
- All districts accessible and explorable
- Core NPCs have functional interactions
- Main story completable without blockers
- Each ending achievable through different paths
- Day 30 evaluation triggers correctly
- Assimilation ratios calculate accurately
- Control path quest functions properly
- Escape path quest functions properly
- Ending display shows correct content
- Save/load works throughout final quests
- Performance maintains 60 FPS baseline
- No critical bugs in core content
- RelationshipManager tracks all relationships correctly
- Multi-dimensional trust calculates properly
- Relationship UI displays accurate information
- Trust milestones trigger at correct thresholds
- Relationship decay functions as designed
- Trust opportunities appear contextually

## Timeline
- **Estimated Duration:** 10-12 weeks (expanded to include asset creation)
- **Total Hours:** 380 (expanded to include ~160 hours asset creation)
- **Critical Path:** Assets → Districts → NPCs → Quests → Endings

## Definition of Done
- [ ] Base character template and animation rig created
- [ ] All UI sprites designed and implemented
- [ ] Common inventory items created
- [ ] All 7 district backgrounds created with layers
- [ ] 50 core NPC sprites with animations complete
- [ ] Interactive object sprites for all districts done
- [ ] District audio ambience loops produced
- [ ] System UI sounds created
- [ ] All 7 districts implemented and polished
- [ ] 50 core NPCs placed and functional
- [ ] Main story playable start to finish
- [ ] Multiple endings system fully functional
- [ ] Day 30 evaluation working correctly
- [ ] Both ending paths completable
- [ ] All endings achievable through gameplay
- [ ] Audio atmosphere complete
- [ ] Tram travel working
- [ ] Full playthrough tested to all endings

## Dependencies
- All Phase 1 systems (Iterations 1-8)
- All Phase 2 systems (Iterations 9-15)
- Visual polish systems (Iteration 16)
- Serialization system for ending saves
- AssimilationManager for ratio tracking
- CoalitionManager for resistance mechanics
- TimeManager for day progression
- QuestManager for final quests

## Risks and Mitigations
- **Risk:** District implementation reveals system gaps
  - **Mitigation:** Document issues, implement workarounds, allocate buffer time
- **Risk:** NPC count affects performance
  - **Mitigation:** LOD system, culling optimization, performance profiling
- **Risk:** Quest bugs block progression
  - **Mitigation:** Multiple save points, debug commands, extensive testing
- **Risk:** Ending logic has edge cases
  - **Mitigation:** Comprehensive testing of threshold boundaries
- **Risk:** Integration complexity causes conflicts
  - **Mitigation:** Incremental integration with testing at each step

## Links to Relevant Code
- data/districts/*/district_config.json
- data/npcs/core/
- data/quests/main_story/
- data/quests/final_quests/
- src/content/districts/
- src/content/npcs/core/
- src/content/quests/main_story/
- src/core/systems/ending_manager.gd (to be created)
- src/quests/final_quests/control_station_quest.gd (to be created)
- src/quests/final_quests/escape_station_quest.gd (to be created)
- src/ui/ending/ending_display.gd (to be created)
- src/ui/ending/ratio_tracker_ui.gd (to be created)
- src/core/serializers/ending_serializer.gd (to be created)
- data/audio/districts/
- data/dialog/main_story/
- docs/design/multiple_endings_system_design.md
- docs/design/template_district_design.md
- docs/design/template_npc_design.md
- docs/design/template_quest_design.md