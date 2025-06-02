# Iteration 8: Districts and Living World MVP

## Epic Description
**Phase**: 1 - MVP Foundation  
**Cohesive Goal**: "I can explore districts with living NPCs and complete the Intro Quest"

As a player, I want to explore multiple unique districts populated with NPCs who follow daily routines, creating a living world where I can complete my first major objective - the Intro Quest that validates all MVP systems work together.

## Goals
- Implement District Template System for efficient district creation
- Create Spaceport District (starting area)
- Create Engineering District (for Intro Quest)
- Implement Living World Event System MVP
- Add SCUMM Hover Text System
- Complete Time Calendar Display UI
- Validate Phase 1 with playable Intro Quest

## Requirements

### Business Requirements
- **B1:** Complete Phase 1 MVP with explorable districts and living world
  - **Rationale:** Validates all core systems work together before expanding to full features
  - **Success Metric:** Intro Quest is fully playable from start to finish

- **B2:** Establish district template system for efficient content creation
  - **Rationale:** Reusable templates accelerate development of remaining districts
  - **Success Metric:** New districts can be created in under 1 week using templates

- **B3:** Create believable living world
  - **Rationale:** NPCs with routines increase immersion and gameplay opportunities
  - **Success Metric:** Players report the station feels alive

### User Requirements
- **U1:** As a player, I want to explore multiple districts with unique content
  - **User Value:** Variety keeps gameplay fresh and interesting
  - **Acceptance Criteria:** Each district has distinct visuals, NPCs, and activities

- **U2:** As a player, I want hover text to identify interactive objects
  - **User Value:** Clear interaction affordances reduce frustration
  - **Acceptance Criteria:** SCUMM-style hover text appears for all interactive elements

- **U3:** As a player, I want to complete the Intro Quest
  - **User Value:** Clear initial goal provides direction
  - **Acceptance Criteria:** Intro Quest playable from start to finish

- **U4:** As a player, I want NPCs to have daily routines
  - **User Value:** Predictable NPC behavior enables planning
  - **Acceptance Criteria:** NPCs move between locations based on time

### Technical Requirements
- **T1:** Create reusable district template architecture
  - **Rationale:** Standardization reduces development time and bugs
  - **Constraints:** Must support different visual perspectives

- **T2:** Implement efficient NPC scheduling system
  - **Rationale:** Many NPCs with routines could impact performance
  - **Constraints:** Must handle 20+ NPCs per district smoothly

- **T3:** Design event system for dynamic world events
  - **Rationale:** Living world needs unpredictable elements
  - **Constraints:** Events must be serializable

## Tasks

### District Template System
- [ ] Task 1: Create BaseDistrict template class
- [ ] Task 2: Implement district configuration system
- [ ] Task 3: Create district transition system
- [ ] Task 4: Add district-specific walkable areas
- [ ] Task 5: Implement district lighting/atmosphere

### Spaceport District
- [ ] Task 6: Create Spaceport scene from template
- [ ] Task 7: Design Docked Ship area
- [ ] Task 8: Create Main Floor layout
- [ ] Task 9: Add Ship Stewardess NPC
- [ ] Task 10: Implement arrival sequence

### Engineering District
- [ ] Task 11: Create Engineering scene from template
- [ ] Task 12: Design Science Deck layout
- [ ] Task 13: Add Science Lead 01 NPC
- [ ] Task 14: Create quest-related interactive objects
- [ ] Task 15: Implement district-specific mechanics

### Living World System MVP
- [ ] Task 16: Create EventManager singleton with SimpleEventScheduler
- [ ] Task 17: Implement NPCScheduleManager with daily routines
- [ ] Task 18: Add event generation for 4 types (Assimilation, Security, Economic, Social)
- [ ] Task 19: Create event notification integration
- [ ] Task 20: Implement event serialization
- [ ] Task 21: Create EventDiscovery system for missed events
- [ ] Task 22: Implement schedule JSON format for 5 key NPCs
- [ ] Task 23: Create Concierge NPC with full routine
- [ ] Task 24: Create Security Chief NPC with full routine
- [ ] Task 25: Create Bank Teller NPC with full routine
- [ ] Task 26: Integrate event system with District spawning
- [ ] Task 27: Integrate contextual dialog based on recent events

### UI Enhancements
- [ ] Task 28: Implement SCUMM hover text system
- [ ] Task 29: Create hover text configuration
- [ ] Task 30: Complete time/calendar UI display
- [ ] Task 31: Add district name displays
- [ ] Task 32: Polish UI integration

### Tram Transportation System (MVP)
- [ ] Task 33: Create TramManager singleton for district travel
- [ ] Task 34: Implement simple fixed-cost travel between districts
- [ ] Task 35: Build basic tram station UI
- [ ] Task 36: Add travel confirmation and payment
- [ ] Task 37: Integrate tram with time advancement

### Intro Quest Implementation
- [ ] Task 38: Create quest flow from ship to engineering
- [ ] Task 39: Implement all quest dialogs
- [ ] Task 40: Add quest items and interactions
- [ ] Task 41: Create quest completion validation
- [ ] Task 42: Full playtest and polish

### Testing Infrastructure
- [ ] Task 43: Set up ARM build validation in CI/CD
- [ ] Task 44: Create remote Raspberry Pi testing infrastructure
- [ ] Task 45: Implement platform parity testing

### Morning Report Validation
- [ ] Task 46: Validate morning report integration with all systems during Intro Quest

### Environmental Observation Infrastructure
- [ ] Task 47: Create observable environmental details per district
- [ ] Task 48: Implement crime scene observation mechanics
- [ ] Task 49: Add atmospheric observation (sounds, smells, temperature)
- [ ] Task 50: Create hidden object discovery system

## User Stories

### Task 1: Create BaseDistrict template class
**User Story:** As a developer, I want a standardized district template, so that creating new districts is efficient and consistent.

**BaseDistrict Migration Phase 1a-1c:** This task enhances BaseDistrict with core identity features, spawn points, and visual theming.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. BaseDistrict class extends Node2D
  2. Handles walkable areas automatically
  3. Manages NPC spawning and scheduling
  4. Provides district entry/exit hooks
  5. Integrates with save system
  6. **Phase 1a:** District ID system and formalized spawn points
  7. **Phase 1b:** District connection management system
  8. **Phase 1c:** Visual theme/color palette enforcement

**Implementation Notes:**
- Reference: docs/design/template_district_design.md
- Use composition over inheritance where possible
- Districts register themselves with DistrictManager
- Support for different camera perspectives per district
- **Phase 1a:** Add to base_district.gd:
  ```gdscript
  export var district_id: String = ""
  var spawn_points: Dictionary = {}
  func add_spawn_point(name: String, position: Vector2)
  func get_spawn_point(name: String) -> Vector2
  ```
- **Phase 1b:** Add connection system:
  ```gdscript
  var connections: Dictionary = {}  # {exit_name: {target_district, entry_point}}
  signal district_exit_triggered(target_district, entry_point)
  ```
- **Phase 1c:** Add visual theming:
  ```gdscript
  export var color_theme: String = "industrial"
  const COLOR_THEMES = {...}  # Canonical palette subsets

### Task 16: Create EventManager singleton with SimpleEventScheduler
**User Story:** As a developer, I want a centralized event management system with scheduling capabilities, so that the living world can trigger events at specific times and conditions.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. EventManager exists as autoload singleton
  2. Contains SimpleEventScheduler for time-based events
  3. Supports scheduled and immediate events
  4. Emits signals for event triggers
  5. Integrates with serialization system

**Implementation Notes:**
- Implement SimpleEventScheduler as inner class or component
- Support event_data structure from design doc
- Maximum 100 scheduled events in queue
- Reference: docs/design/living_world_event_system_mvp.md

### Task 17: Implement NPCScheduleManager with daily routines
**User Story:** As a player, I want NPCs to follow believable daily routines, so that the world feels alive and I can plan my interactions.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U4, T2
- **Acceptance Criteria:**
  1. NPCScheduleManager tracks all NPC routines
  2. Loads schedules from JSON files
  3. Provides location queries by time
  4. Handles schedule interruptions
  5. Integrates with district spawning

**Implementation Notes:**
- Reference NPC Schedule Format in design doc
- Support routine variations (+/- time)
- Performance: lazy load full schedules
- Reference: docs/design/living_world_event_system_mvp.md

### Task 5: Implement district lighting/atmosphere with perspective adjustments
**User Story:** As a player, I want each district to have unique atmospheric qualities that adapt to the visual perspective, so that different areas of the station feel distinct and memorable regardless of camera angle.

**BaseDistrict Migration Phase 3b & 4a:** This task implements environmental states and audio source management for atmospheric district experiences.

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md` lines 136-151

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1, T1
- **Acceptance Criteria:**
  1. Districts have configurable lighting moods
  2. Ambient sounds create atmosphere
  3. Environmental states affect visuals
  4. Particle effects enhance immersion
  5. Performance remains smooth
  6. **Phase 3b:** Environmental state system (normal/suspicious/infested)
  7. **Phase 4a:** Diegetic audio source management
  8. **Phase 4b:** LOD system for complex districts
  9. **Enhanced:** Perspective-specific visual adjustments (depth fog, lighting angles)
  10. **Enhanced:** Camera configuration per perspective type

**Implementation Notes:**
- Use Light2D nodes for dynamic lighting
- Position AudioStreamPlayer2D for spatial sound
- **Phase 3b:** Add environmental states:
  ```gdscript
  export var environmental_state: String = "normal"
  var environmental_states: Dictionary = {}
  func set_environmental_state(state: String)
  func show_assimilation_progress(level: float)
  ```
- **Phase 4a:** Add audio management:
  ```gdscript
  var ambient_sounds: Array = []
  func _initialize_audio_sources()
  func add_ambient_sound(position: Vector2, sound_path: String)
  ```
- **Phase 4b:** LOD system for performance:
  ```gdscript
  export var use_lod_system: bool = true
  var lod_distances: Dictionary = {}
  func _initialize_lod_system()
  func _update_lod_states()
  ```
- **Enhanced:** Add perspective-aware atmosphere:
  ```gdscript
  func apply_perspective_atmosphere():
      match perspective_type:
          "ISOMETRIC":
              # Adjust lighting angle for isometric depth
          "SIDE_SCROLLING":
              # Apply parallax-friendly lighting
          "TOP_DOWN":
              # Even lighting distribution
  ```

### Task 28: Implement comprehensive SCUMM hover text system
**User Story:** As a player, I want rich, context-sensitive hover text that provides dynamic information about objects, NPCs, and the environment, so that I can understand the game world and make informed decisions using the classic adventure game interface.

**Design Reference:** `docs/design/scumm_hover_text_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, B3, U1, U2
- **Acceptance Criteria:**
  1. **Core System:** Text appears at bottom of screen above verb UI with classic SCUMM formatting
  2. **Object State Reflection:** Shows dynamic object states (locked/open doors, powered terminals, empty containers)
  3. **Environmental Context:** Displays distance warnings, exit descriptions, and travel costs for locations
  4. **Time-Sensitive Descriptions:** Shows shop hours, NPC availability, and schedule-based information
  5. **Verb Integration:** Properly formats "Verb Object" combinations with correct prepositions
  6. **Color Coding:** Uses color themes for different interaction states and object types
  7. **Performance Optimization:** Implements caching strategies and efficient mouse detection
  8. **Visual Styling:** Consistent monospace font, outlines, and positioning system

**Implementation Notes:**
- Reference: docs/design/scumm_hover_text_system_design.md (Core System, Object State Reflection, Environmental Context sections)
- Implement HoverTextManager singleton with modular components:
  ```gdscript
  # Core components
  class_name HoverTextManager extends Node
  var object_state_handler: ObjectStateHandler
  var environmental_handler: EnvironmentalHandler  
  var time_sensitive_handler: TimeSensitiveHandler
  var performance_cache: HoverTextCache
  ```
- **Object State Integration:** Connect to interactive object state machines for dynamic descriptions
- **Environmental Integration:** Interface with district system for location-based descriptions
- **Time Integration:** Connect to TimeManager and NPCScheduleManager for schedule awareness
- **Performance:** Implement static/dynamic description caching with frame-based updates
- **Visual System:** Use HoverTextStyle class for consistent theming and color management

### Task 38: Create quest flow from ship to engineering
**User Story:** As a player, I want to experience a complete quest from beginning to end, so that I understand the game's objectives and mechanics.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Quest starts automatically on game begin
  2. Clear objectives provided at each step
  3. Uses all core game systems
  4. Completable in 15-20 minutes
  5. Provides satisfying conclusion

**Implementation Notes:**
- Quest flow: Ship arrival → Get assignment → Travel to Engineering → Solve problem → Return and report
- Tests: Dialog, navigation, inventory, time management
- Must work with all character genders
- Reference: Intro Quest requirements from phased_development_approach.md

### Task 33: Create TramManager singleton for district travel
**User Story:** As a player, I need a way to travel between districts, so that I can explore the station and complete quests.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (MVP section)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U1, T1
- **Acceptance Criteria:**
  1. TramManager singleton manages all district travel
  2. Tracks current player district
  3. Provides travel functionality between any two districts
  4. Enforces tram as only travel method
  5. Simple, reliable implementation

**Implementation Notes:**
- MVP: No complex routing, just direct travel
- Fixed costs and times for Phase 1
- Reference MVP section of tram design doc

### Task 34: Implement simple fixed-cost travel between districts
**User Story:** As a player, I want predictable travel costs and times, so that I can plan my movements without complex calculations.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (MVP section)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Fixed cost: 10 credits for any trip
  2. Fixed time: 30 minutes for any trip
  3. Cannot travel without sufficient credits
  4. Clear feedback on insufficient funds
  5. No distance calculations in MVP

**Implementation Notes:**
- MVP: All trips cost the same
- Simplifies balancing and testing
- Full distance-based pricing in Phase 2

### Task 35: Build basic tram station UI
**User Story:** As a player, I want a simple interface to select my destination, so that I can travel between districts easily.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (MVP section)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U1, U2
- **Acceptance Criteria:**
  1. List of all districts (except current)
  2. Shows fixed cost (10 credits)
  3. Shows fixed time (30 minutes)
  4. Disabled if insufficient funds
  5. Simple, functional design

**Implementation Notes:**
- MVP: No route visualization
- No fancy animations
- Focus on functionality

### Task 36: Add travel confirmation and payment
**User Story:** As a player, I want to confirm my travel choice before spending credits, so that I don't waste money accidentally.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (MVP section)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Confirmation dialog shows cost and destination
  2. Can cancel before payment
  3. Credits deducted on confirmation
  4. Immediate district transition
  5. Update economy display

**Implementation Notes:**
- MVP: Simple fade to black transition
- No transit screen animation
- Instant travel after payment

### Task 37: Integrate tram with time advancement
**User Story:** As a developer, I want tram travel to advance game time, so that movement has a time cost.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (MVP section)

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1, T3
- **Acceptance Criteria:**
  1. Advances time by 30 minutes per trip
  2. Integrates with TimeManager
  3. Updates all time-dependent systems
  4. Works with save/load
  5. No complex time calculations

**Implementation Notes:**
- MVP: Fixed time advancement
- Connect to TimeManager.advance_time(0.5)
- Ensure NPCs update appropriately

### Task 43: Set up ARM build validation in CI/CD
**User Story:** As a developer, I want automated ARM builds in our CI/CD pipeline, so that we catch platform-specific issues early and ensure the game compiles correctly for Raspberry Pi 5.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Continuous Integration Enhancements
- **Acceptance Criteria:**
  1. ARM64 cross-compilation in CI pipeline
  2. Automated build on every commit
  3. Build artifacts stored for testing
  4. Build failure notifications
  5. Parallel builds for x86 and ARM

**Implementation Notes:**
- Use Docker with ARM toolchain
- Cache dependencies for faster builds
- Store last 10 successful ARM builds
- Add ARM build status to README

### Task 44: Create remote Raspberry Pi testing infrastructure
**User Story:** As a developer, I want SSH-accessible Raspberry Pi devices for testing, so that I can validate performance and functionality on actual hardware without physical access.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Developer Hardware Access
- **Acceptance Criteria:**
  1. 2+ Raspberry Pi 5 units accessible via SSH
  2. Automated deployment scripts
  3. Remote performance monitoring
  4. VNC access for visual testing
  5. Shared access management system

**Implementation Notes:**
- Set up reverse SSH tunnels for access
- Create deployment script: deploy_to_pi.sh
- Install performance monitoring tools
- Document access procedures

### Task 45: Implement platform parity testing
**User Story:** As a developer, I want automated tests that verify feature parity between x86 and ARM builds, so that players have the same experience regardless of platform.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Platform Parity Tests
- **Acceptance Criteria:**
  1. Automated test suite runs on both platforms
  2. Performance benchmarks compared
  3. Save file compatibility verified
  4. Feature availability checked
  5. Regression detection between platforms

**Implementation Notes:**
- Create platform_parity_test.gd
- Run nightly on both architectures
- Generate comparison reports
- Flag any platform-specific failures

### Task 2: Implement district configuration system with perspective support
**User Story:** As a developer, I want districts to be configurable through data files including perspective type, so that I can easily adjust district properties and visual style without code changes.

**Design Reference:** `docs/design/template_district_design.md`, `docs/design/multi_perspective_character_system_plan.md` lines 89-94

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, T1
- **Acceptance Criteria:**
  1. Districts load configuration from .tres files
  2. Configuration includes walkable areas
  3. Spawn points defined in config
  4. NPC lists specified per district
  5. Hot-reload support in editor
  6. **Enhanced:** Perspective type (ISOMETRIC, SIDE_SCROLLING, TOP_DOWN) in config
  7. **Enhanced:** Perspective-specific parameters (scaling curves, camera settings)

**Implementation Notes:**
- Use Godot resource system
- Reference template_district_design.md
- Include example configuration
- **Enhanced:** Add to district config:
  ```gdscript
  export var perspective_type: String = "ISOMETRIC"
  export var perspective_params: Dictionary = {
    "scale_min": 0.5,
    "scale_max": 1.0,
    "camera_zoom": 1.0
  }
  ```

### Task 3: Create district transition system
**User Story:** As a player, I want smooth transitions between districts, so that movement feels seamless and immersive.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1, T1
- **Acceptance Criteria:**
  1. Fade out/in transitions
  2. Loading screen if needed
  3. Player spawns at correct entry point
  4. State preserved during transitions
  5. Time advances appropriately

**Implementation Notes:**
- Connect to TramManager for travel
- Handle direct walkable transitions
- Preserve player state and inventory

### Task 4: Add district-specific walkable areas
**User Story:** As a player, I want to navigate naturally through each district, so that movement feels realistic within the space station environment.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1, T1
- **Acceptance Criteria:**
  1. Navigation2D polygons per district
  2. Visual debug mode for testing
  3. Smooth pathfinding
  4. Obstacles properly excluded
  5. Works with click movement

**Implementation Notes:**
- Use Navigation2D nodes
- Support complex polygon shapes
- Test with multiple NPCs

### Task 18: Add event generation for 4 types (Assimilation, Security, Economic, Social)
**User Story:** As a player, I want different types of events to occur in the station, so that the world feels dynamic and unpredictable.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U4, T3
- **Acceptance Criteria:**
  1. Assimilation events (2-3 per game)
  2. Security events (1-2 per game)
  3. Economic events (1-2 per game)
  4. Social events (2-3 per game)
  5. Events leave appropriate clues

**Implementation Notes:**
- Reference Event Types in MVP section
- Each type has unique consequences
- Some events are discoverable later
- Reference: docs/design/living_world_event_system_mvp.md

### Task 19: Create event notification integration
**User Story:** As a player, I want to be notified of important world events through contextual notifications like news broadcasts and emergency alerts, so that I stay informed about the changing station environment.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`, `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T3
- **Acceptance Criteria:**
  1. Events trigger notifications when appropriate
  2. Distance-based notification filtering
  3. Priority levels respected
  4. Integrates with PromptNotificationSystem
  5. Some events silent until discovered
  6. Special notification types for news broadcasts
  7. Emergency alert system for critical events
  8. Station-wide announcements for major occurrences
  9. Tutorial messages for first-time experiences

**Implementation Notes:**
- Connect to notification system from I5
- Only notify if player can perceive event
- News broadcasts use STORY notification type
- Emergency alerts use CRITICAL type and clear queue
- Station announcements reach all players
- Tutorial messages check GameSettings.tutorials_enabled
- Reference: docs/design/prompt_notification_system_design.md (Special Use Cases section)

### Task 20: Implement event serialization
**User Story:** As a player, I want events to persist across save/load cycles, so that the world state remains consistent.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Scheduled events saved
  2. Event history preserved
  3. Event consequences persist
  4. Integrates with modular serialization
  5. Handles version migration

**Implementation Notes:**
- Follow modular serialization pattern
- Reference: docs/design/modular_serialization_architecture.md
- Compress event history
- Priority: 20 (high)

### Task 21: Create EventDiscovery system for missed events
**User Story:** As a player, I want to learn about events I missed through clues and dialog, so that the world continues to evolve even when I'm not present.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U4
- **Acceptance Criteria:**
  1. Track witnessed vs discovered events
  2. Place clues in world after events
  3. NPCs reference recent events
  4. Discovery through investigation
  5. Discovery affects player knowledge

**Implementation Notes:**
- Reference EventDiscovery class in design
- Clues decay over time (some permanent)
- Connect to investigation system later
- Reference: docs/design/living_world_event_system_mvp.md

### Task 22: Implement schedule JSON format for 5 key NPCs
**User Story:** As a developer, I want NPC schedules defined in data files, so that I can easily create and modify NPC routines without code changes.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T2
- **Acceptance Criteria:**
  1. JSON schema matches design doc
  2. Schedules for 5 key NPCs
  3. Time variations supported
  4. Activity types defined
  5. Validates on load

**Implementation Notes:**
- Reference NPC Schedule Format section
- Create schedules for: Concierge, Security Chief, Bank Teller, Scientist Lead, Dock Foreman
- Include example for others to follow
- Reference: docs/design/living_world_event_system_mvp.md

### Task 23: Create Concierge NPC with full routine
**User Story:** As a player, I want the Concierge to follow a daily routine, so that I can find them predictably when I need assistance.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` & `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U4
- **Acceptance Criteria:**
  1. Morning desk preparation (06:00-08:00)
  2. Working at desk (08:00-18:00)
  3. Lunch break (12:00-13:00)
  4. Personal time in quarters (18:00-19:00)
  5. Personality: helpful, organized

**Implementation Notes:**
- Central hub character in Barracks
- High lawfulness, low suspicion
- Uses template NPC structure
- Reference: docs/design/template_npc_design.md

### Task 24: Create Security Chief NPC with full routine
**User Story:** As a player, I want the Security Chief to patrol and work on a schedule, so that I can plan my activities around security presence.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` & `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U4
- **Acceptance Criteria:**
  1. Morning briefing (06:00-07:00)
  2. Patrol rounds (07:00-12:00, 14:00-18:00)
  3. Office work (12:00-14:00)
  4. Evening report (18:00-19:00)
  5. Personality: vigilant, suspicious

**Implementation Notes:**
- Key to security events
- High suspicion, high lawfulness
- Patrol route varies by day
- Reference: docs/design/template_npc_design.md

### Task 25: Create Bank Teller NPC with full routine
**User Story:** As a player, I want the Bank Teller to maintain regular hours, so that I know when banking services are available.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` & `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U4
- **Acceptance Criteria:**
  1. Open bank (08:00-09:00)
  2. Customer service (09:00-17:00)
  3. Lunch break (13:00-14:00)
  4. Close bank (17:00-18:00)
  5. Personality: professional, detail-oriented

**Implementation Notes:**
- Important for economy quests
- Medium suspicion, high greed
- Handles player transactions
- Reference: docs/design/template_npc_design.md

### Task 26: Integrate event system with District spawning
**User Story:** As a developer, I want NPCs to spawn in districts based on their schedules, so that the world population changes realistically with time.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, T1, T2
- **Acceptance Criteria:**
  1. Districts query NPCScheduleManager on load
  2. Spawn appropriate NPCs for current time
  3. Handle NPCs entering/leaving districts
  4. Despawn NPCs when leaving district
  5. Performance optimized

**Implementation Notes:**
- Reference District System Integration section
- Only spawn visible NPCs
- Handle district transitions smoothly
- Reference: docs/design/living_world_event_system_mvp.md

### Task 27: Integrate contextual dialog based on recent events
**User Story:** As a player, I want NPCs to reference recent events in dialog, so that conversations feel dynamic and responsive to the world state.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B3, U4
- **Acceptance Criteria:**
  1. NPCs aware of recent events
  2. Dialog options change based on events
  3. Knowledge spreads realistically
  4. Some NPCs more informed than others
  5. Player can learn through dialog

**Implementation Notes:**
- Reference Dialog System Integration section
- Track which NPCs know which events
- Add event-specific dialog branches
- Reference: docs/design/living_world_event_system_mvp.md

### Task 46: Validate morning report integration with all systems during Intro Quest
**User Story:** As a developer, I want to validate that morning reports properly integrate with all game systems, so that players receive comprehensive overnight updates throughout their journey.

**Design Reference:** `docs/design/morning_report_manager_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Sleep triggers morning report display
  2. Events from multiple systems appear
  3. Priority sorting works correctly
  4. No duplicate or missing events
  5. Performance remains smooth

**Implementation Notes:**
- Reference: docs/design/morning_report_manager_design.md (integration requirements)
- Test during Intro Quest playthrough
- Verify all systems report events
- Check serialization works
- Validate UI display

### Task 6: Create Spaceport scene from template
**User Story:** As a player, I want to start my journey in the Spaceport, so that I have a clear entry point into the game world.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Uses BaseDistrict template
  2. Docked Ship sub-area included
  3. Main Floor area included
  4. Proper lighting atmosphere
  5. Navigation mesh complete

**Implementation Notes:**
- First district player sees
- Industrial atmosphere
- Reference: docs/design/template_district_design.md

### Task 7: Design Docked Ship area
**User Story:** As a player, I want to explore the ship I arrived on, so that I understand how I got to the station.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Ship interior layout
  2. Airlock transition
  3. Stewardess spawn point
  4. Interactive elements
  5. One-way exit design

**Implementation Notes:**
- Small area, tutorial space
- Cannot return after leaving
- Atmospheric introduction

### Task 8: Create Main Floor layout
**User Story:** As a player, I want to explore the Spaceport main area, so that I can access transportation and meet NPCs.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. Tram station access
  2. Information kiosks
  3. Waiting areas
  4. Clear navigation paths
  5. District transitions marked

**Implementation Notes:**
- Hub area for travel
- Multiple exit points
- Clear signage

### Task 9: Add Ship Stewardess NPC
**User Story:** As a player, I want to meet the Ship Stewardess, so that I receive my initial orientation to the station.

**Design Reference:** `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Greets player on arrival
  2. Provides initial quest
  3. Uses template NPC structure
  4. Tutorial dialog included
  5. Personality: helpful, tired

**Implementation Notes:**
- First NPC player meets
- Simple behavior state
- Reference: docs/design/template_npc_design.md

### Task 10: Implement arrival sequence
**User Story:** As a player, I want a scripted arrival sequence, so that my entry to the game world feels cinematic and engaging.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Camera pans on entry
  2. Stewardess approaches
  3. Dialog auto-triggers
  4. Movement initially limited
  5. Smooth transition to gameplay

**Implementation Notes:**
- One-time sequence
- Sets narrative tone
- Must handle skip option

### Task 11: Create Engineering scene from template
**User Story:** As a player, I want to visit the Engineering district, so that I can complete the intro quest objectives.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Uses BaseDistrict template
  2. Science Deck sub-area
  3. Technical atmosphere
  4. Quest locations marked
  5. Proper NPC spawn points

**Implementation Notes:**
- Key location for intro quest
- More complex than Spaceport
- Reference: docs/design/template_district_design.md

### Task 12: Design Science Deck layout
**User Story:** As a player, I want to explore the Science Deck, so that I can interact with research equipment and complete objectives.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1, U3
- **Acceptance Criteria:**
  1. Laboratory areas
  2. Office spaces
  3. Equipment rooms
  4. Clear pathfinding
  5. Interactive objects placed

**Implementation Notes:**
- Scientific equipment visible
- Clean, sterile atmosphere
- Multiple room types

### Task 13: Add Science Lead 01 NPC
**User Story:** As a player, I want to meet the Science Lead, so that I can receive and complete my first real assignment.

**Design Reference:** `docs/design/template_npc_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Quest giver for intro
  2. Professional personality
  3. Clear dialog options
  4. Problem explanation
  5. Reward handling

**Implementation Notes:**
- Key NPC for intro quest
- Uses full NPC template
- Reference: docs/design/template_npc_design.md

### Task 14: Create quest-related interactive objects
**User Story:** As a player, I want to interact with quest objects, so that I can solve problems and progress through the game.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Broken equipment object
  2. Repair interface
  3. Clear interaction prompts
  4. State changes on fix
  5. Quest update triggers

**Implementation Notes:**
- Tests inventory system
- Simple puzzle mechanic
- Reference: docs/design/template_interactive_object_design.md

### Task 15: Implement district-specific mechanics
**User Story:** As a player, I want each district to have unique gameplay elements, so that exploration reveals new mechanics and challenges.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. Engineering: equipment interaction
  2. Spaceport: travel hub
  3. Unique atmosphere each
  4. District-specific sounds
  5. Themed color palettes

**Implementation Notes:**
- Makes districts memorable
- Supports gameplay variety
- Reference: docs/design/template_district_design.md

### Task 29: Create comprehensive hover text configuration and accessibility system
**User Story:** As a player, I want fully configurable hover text with accessibility features, so that the interface works well for my specific needs and preferences.

**Design Reference:** `docs/design/scumm_hover_text_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. **Configuration System:** Font size, color themes, position adjustments, and fade timing options
  2. **Accessibility Features:** High contrast mode, screen reader support, and larger font options
  3. **Debug Features:** Development overlay with object IDs, state information, and performance metrics
  4. **Dynamic Updates:** Real-time configuration changes without restart
  5. **Serialization:** Save user preferences and restore on game load
  6. **Performance Monitoring:** Built-in performance tracking for hover text system

**Implementation Notes:**
- Reference: docs/design/scumm_hover_text_system_design.md (Accessibility Features, Debug Features, Visual Design sections)
- Implement HoverTextSettings resource with configuration options:
  ```gdscript
  # Configuration system
  class_name HoverTextSettings extends Resource
  export var font_size: int = 14
  export var high_contrast_mode: bool = false
  export var screen_reader_enabled: bool = false
  export var debug_mode_enabled: bool = false
  export var color_theme: String = "default"
  ```
- **Accessibility Integration:** Connect to GameSettings for accessibility options and screen reader API
- **Debug System:** Implement HoverDebugMode for development information overlay
- **Performance Tracking:** Add hover text performance monitoring and optimization suggestions
- **Settings Integration:** Full integration with game settings menu and user preferences

### Task 30: Complete time/calendar UI display
**User Story:** As a player, I want to see the current time and date clearly, so that I can plan my activities effectively.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Shows current time/date
  2. Indicates time of day
  3. Expandable calendar view
  4. Event indicators
  5. Clean visual design

**Implementation Notes:**
- Builds on I5 time system
- Must be always visible
- Reference: docs/design/time_calendar_display_ui_design.md

### Task 31: Add district name displays
**User Story:** As a player, I want to see which district I'm in, so that I can orient myself within the station.

**Design Reference:** `docs/design/template_district_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U1
- **Acceptance Criteria:**
  1. District name on entry
  2. Fade in/out animation
  3. Consistent positioning
  4. Readable font/size
  5. Respects UI scale

**Implementation Notes:**
- Brief display on transition
- Can be toggled in UI
- Reference: docs/design/template_district_design.md

### Task 32: Polish UI integration
**User Story:** As a player, I want all UI elements to work together seamlessly, so that the interface feels cohesive and professional.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1
- **Acceptance Criteria:**
  1. Consistent visual style
  2. No overlapping elements
  3. Proper layering
  4. Smooth transitions
  5. Responsive scaling

**Implementation Notes:**
- Final polish pass
- Test all resolutions
- Ensure accessibility

### Task 39: Implement all quest dialogs
**User Story:** As a player, I want meaningful conversations during the intro quest, so that I understand the story and objectives.

**Design Reference:** `docs/design/template_dialog_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Stewardess introduction
  2. Science Lead briefing
  3. Success/failure responses
  4. Context-sensitive options
  5. Clear objective communication

**Implementation Notes:**
- Write engaging dialog
- Test all branches
- Reference: docs/design/template_dialog_design.md

### Task 40: Add quest items and interactions
**User Story:** As a player, I want to collect and use items for the quest, so that I experience the core gameplay loop.

**Design Reference:** `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U3
- **Acceptance Criteria:**
  1. Repair tool pickup
  2. Broken equipment fix
  3. Evidence collection
  4. Inventory integration
  5. Clear feedback

**Implementation Notes:**
- Tests all item systems
- Simple but complete
- Reference: docs/design/template_interactive_object_design.md

### Task 41: Create quest completion validation
**User Story:** As a developer, I want to validate the intro quest is completable, so that players have a smooth first experience.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. All paths tested
  2. Objectives clear
  3. Rewards granted
  4. No soft locks
  5. 15-20 minute duration

**Implementation Notes:**
- Automated test preferred
- Multiple playtests required
- Document any issues

### Task 42: Full playtest and polish
**User Story:** As a player, I want a polished intro experience, so that my first impression of the game is positive.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. No critical bugs
  2. Smooth flow
  3. Clear objectives
  4. Balanced difficulty
  5. Engaging narrative

**Implementation Notes:**
- Multiple testers needed
- Fresh eyes important
- Polish based on feedback

### Task 47: Create observable environmental details per district
**User Story:** As a player, I want to observe environmental details that tell stories about what happened in each district, so that careful observation reveals the history and current state of different areas.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 262-426

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U1, T1
- **Acceptance Criteria:**
  1. Each district has observable environmental details (damage, biological traces, disturbances)
  2. Observable details support different visibility conditions and skill levels
  3. Environmental storytelling through observable elements
  4. Integration with district template system for easy content creation
  5. Observable details register with ObservationManager automatically

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (EnvironmentalObservation lines 262-426)
- Categories: DAMAGE, BIOLOGICAL, TRACES, DISTURBANCES, HIDDEN_OBJECTS, ATMOSPHERIC
- Each district template includes observable_details configuration
- Some details only visible under specific conditions (time, equipment, events)
- Support for dynamic observable details that change based on world events

### Task 48: Implement crime scene observation mechanics
**User Story:** As a player, I want to investigate crime scenes through detailed observation, so that I can piece together what happened and gather evidence.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 370-425

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U4, T1
- **Acceptance Criteria:**
  1. Crime scenes generate specific observable details based on crime type
  2. Blood trails, scuff marks, and evidence can be discovered through observation
  3. Crime scene observations link to clue discovery system
  4. Some crime evidence requires specific observation skills or equipment
  5. Crime scenes degrade over time, affecting observable detail availability

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (Crime Scene Observations lines 370-401)
- Crime types: assault (blood trails, struggle marks), theft (lock picking signs), vandalism (symbolic damage)
- Integration with future crime system and assimilation events
- Observable details have base_visibility ratings affecting discovery chance
- Time-sensitive observations that fade or change

### Task 49: Add atmospheric observation (sounds, smells, temperature)
**User Story:** As a player, I want to notice atmospheric changes like strange sounds or smells, so that my senses help me detect threats and understand the environment.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 274-281, 402-425

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U1, T1
- **Acceptance Criteria:**
  1. Atmospheric observations include sounds, smells, and temperature changes
  2. Assimilation events leave atmospheric traces (metallic taste, thick air)
  3. Different districts have unique atmospheric signatures
  4. Atmospheric changes indicate recent events or hidden dangers
  5. Some atmospheric details only detectable by skilled observers

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (ATMOSPHERIC observation type)
- Examples: "The air feels oddly thick here, with a faint metallic taste"
- District-specific atmospherics: engineering (machine sounds), spaceport (fuel smell)
- Assimilation residue: greenish coating on vents, strange atmospheric pressure
- Integration with audio system for atmospheric sound cues

### Task 50: Create hidden object discovery system
**User Story:** As a player, I want to discover hidden objects and compartments through careful observation, so that thorough investigation is rewarded with valuable finds.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 274-281 (HIDDEN_OBJECTS)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Hidden objects and compartments discoverable through observation
  2. Discovery requires specific observation skills or conditions
  3. Hidden objects contain valuable items, clues, or story elements
  4. Visual hints available for observant players
  5. Discovery tracked in investigation progress

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (HIDDEN_OBJECTS category)
- Examples: hidden panels, secret compartments, concealed items
- Some require UV light or special equipment to reveal
- Higher observation skill increases discovery chance
- Integration with inventory system for hidden item rewards
- Environmental storytelling through hidden object placement

## Testing Criteria
- Districts load and transition smoothly
- NPCs follow schedules correctly
- Events trigger at appropriate times
- Hover text works for all objects
- Time display updates properly
- Intro Quest completable without bugs
- All systems integrate correctly
- Morning reports show events from all systems
- Performance remains smooth with full districts

## Timeline
- Start date: After Iteration 7 completion
- Target completion: 2-3 weeks
- Critical for: Phase 1 validation before Phase 2

## Dependencies
- All previous iterations (1-7) must be complete
- Particularly: Save system (I7), Time system (I5), NPCs (I2)

## Code Links
- src/districts/base_district.gd (to be created)
- src/districts/spaceport/ (to be created)
- src/districts/engineering/ (to be created)
- src/core/events/event_manager.gd (to be created)
- src/ui/hover_text/hover_text_display.gd (to be created)
- docs/design/template_district_design.md
- docs/design/living_world_event_system_mvp.md
- docs/design/scumm_hover_text_system_design.md
- docs/design/time_calendar_display_ui_design.md

## Notes
- This iteration validates all Phase 1 systems work together
- Intro Quest is critical - it's our "vertical slice"
- District templates save massive time in Phase 3
- Living world events start simple, expand in Phase 2
- After this iteration, we move to Phase 2 Full Systems!

### Design Documents Implemented
- docs/design/template_district_design.md
- docs/design/base_district_system.md
- docs/design/living_world_event_system_mvp.md
- docs/design/scumm_hover_text_system_design.md
- docs/design/time_calendar_display_ui_design.md
- docs/design/tram_transportation_system_design.md

### Template References
- All districts MUST follow docs/design/template_district_design.md
- NPCs in districts should follow docs/design/template_npc_design.md
- Interactive objects follow docs/design/template_interactive_object_design.md
- Integration patterns from docs/design/template_integration_standards.md