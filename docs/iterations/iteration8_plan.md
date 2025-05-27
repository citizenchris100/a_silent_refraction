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
- [ ] Task 16: Create EventManager singleton
- [ ] Task 17: Implement NPC daily schedule system
- [ ] Task 18: Add random event generation
- [ ] Task 19: Create event notification integration
- [ ] Task 20: Implement event serialization

### UI Enhancements
- [ ] Task 21: Implement SCUMM hover text system
- [ ] Task 22: Create hover text configuration
- [ ] Task 23: Complete time/calendar UI display
- [ ] Task 24: Add district name displays
- [ ] Task 25: Polish UI integration

### Tram Transportation System (MVP)
- [ ] Task 26: Create TramManager singleton for district travel
- [ ] Task 27: Implement simple fixed-cost travel between districts
- [ ] Task 28: Build basic tram station UI
- [ ] Task 29: Add travel confirmation and payment
- [ ] Task 30: Integrate tram with time advancement

### Intro Quest Implementation
- [ ] Task 31: Create quest flow from ship to engineering
- [ ] Task 32: Implement all quest dialogs
- [ ] Task 33: Add quest items and interactions
- [ ] Task 34: Create quest completion validation
- [ ] Task 35: Full playtest and polish

## User Stories

### Task 1: Create BaseDistrict template class
**User Story:** As a developer, I want a standardized district template, so that creating new districts is efficient and consistent.

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

**Implementation Notes:**
- Reference: docs/design/template_district_design.md
- Use composition over inheritance where possible
- Districts register themselves with DistrictManager
- Support for different camera perspectives per district

### Task 17: Implement NPC daily schedule system
**User Story:** As a player, I want NPCs to follow believable daily routines, so that the world feels alive and I can plan my interactions.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** U4, T2
- **Acceptance Criteria:**
  1. NPCs have configurable daily schedules
  2. Schedules include location, activity, and duration
  3. NPCs path between locations automatically
  4. Interruptions handled gracefully
  5. Schedules persist through save/load

**Implementation Notes:**
- Schedule format: [{time: "08:00", location: "cafeteria", activity: "eating"}]
- Use Navigation2D for pathfinding
- Reference: docs/design/living_world_event_system_mvp.md
- Consider performance with many NPCs

### Task 21: Implement SCUMM hover text system
**User Story:** As a player, I want to see object names when I hover over them, so that I know what I can interact with in the classic adventure game style.

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Text appears at bottom of screen on hover
  2. Shows object name in readable font
  3. Updates instantly as mouse moves
  4. Works with all interactive objects
  5. Respects UI scaling settings

**Implementation Notes:**
- Reference: docs/design/scumm_hover_text_system_design.md
- Use Label with outline for readability
- Consider color coding by object type
- Must work with verb UI system

### Task 31: Create quest flow from ship to engineering
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

### Task 26: Create TramManager singleton for district travel
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

### Task 27: Implement simple fixed-cost travel between districts
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

### Task 28: Build basic tram station UI
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

### Task 29: Add travel confirmation and payment
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

### Task 30: Integrate tram with time advancement
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

## Testing Criteria
- Districts load and transition smoothly
- NPCs follow schedules correctly
- Events trigger at appropriate times
- Hover text works for all objects
- Time display updates properly
- Intro Quest completable without bugs
- All systems integrate correctly
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