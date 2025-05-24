# Iteration 5: Game Districts and Time Management
**Updated to include Living World Event System MVP**

## Goals
- Implement multiple station districts with transitions
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- **NEW:** Implement Living World Event System MVP for scheduled events and NPC routines
- Implement random NPC assimilation tied to scheduled events
- Implement single-slot save system
- Create basic limited inventory system

## Requirements

### Business Requirements
- **B1:** Create a sense of progression and urgency through time management
  - **Rationale:** Time-based gameplay creates strategic choices and replay value
  - **Success Metric:** Players report making meaningful time allocation decisions in test sessions

- **B2:** Expand game world with multiple distinct areas
  - **Rationale:** Diverse environments increase perceived game size and exploration value
  - **Success Metric:** Each district has unique visual identity and gameplay purpose

- **B3:** Make the station feel alive with NPCs following schedules
  - **Rationale:** Living world increases immersion and creates emergent gameplay
  - **Success Metric:** Players report feeling the world continues without them

### User Requirements
- **U1:** As a player, I want to manage my time to prioritize activities
  - **User Value:** Creates strategic decision-making and consequences
  - **Acceptance Criteria:** Different actions consume varying amounts of in-game time

- **U2:** As a player, I want to explore distinct areas of the station
  - **User Value:** Provides variety and discovery
  - **Acceptance Criteria:** Each district has unique visuals, NPCs, and activities

- **U3:** As a player, I want to discover events I missed through investigation
  - **User Value:** Rewards exploration and attention to detail
  - **Acceptance Criteria:** Clues and dialog reveal information about past events

### Technical Requirements
- **T1:** Implement robust scene transition system
  - **Rationale:** District loading and transitions must be seamless
  - **Constraints:** Must preserve game state across transitions

- **T2:** Create event scheduling architecture that scales
  - **Rationale:** Foundation for full living world implementation
  - **Constraints:** Must maintain 60 FPS with event processing

## Tasks
- [ ] Task 1: Create at least one additional district besides Shipping
- [ ] Task 2: Create bash script for generating NPC placeholders
- [ ] Task 3: Implement district transitions via tram system
- [ ] Task 4: Develop in-game clock and calendar system
- [ ] Task 5: Create time progression through player actions
- [ ] Task 6: Create SimpleEventScheduler for managing time-based events
- [ ] Task 7: Implement NPCScheduleManager for basic NPC routines
- [ ] Task 8: Create EventDiscovery system for learning about missed events
- [ ] Task 9: Implement day cycle with sleep mechanics
- [ ] Task 10: Design and implement time UI indicators
- [ ] Task 11: Convert random assimilation to scheduled event system
- [ ] Task 12: Add scheduled story events (security sweeps, meetings)
- [ ] Task 13: Create NPC schedule data files for 5-10 key NPCs
- [ ] Task 14: Implement contextual dialog based on recent events
- [ ] Task 15: Implement player bedroom as save point location
- [ ] Task 16: Create single-slot save system with event state persistence
- [ ] Task 17: Create basic inventory system with size limitations

## Testing Criteria
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs follow daily schedules and appear in correct locations at correct times
- Events trigger at scheduled times whether player witnesses them or not
- Player can discover missed events through clues and NPC dialog
- Assimilation events leave evidence in the world
- Save system preserves complete event history and NPC states
- Player has limited inventory space
- NPC placeholder script successfully creates properly structured directories and registry entries
- Performance maintains 60 FPS with event system active

## Timeline
- Start date: 2025-06-15
- Target completion: 2025-07-06 (extended by 1 week for Living World MVP)

## Dependencies
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- Iteration 4 (Dialog and Verb UI System Refactoring)

## Code Links
- Time Management System MVP Design: docs/design/time_management_system_mvp.md
- Living World Event System MVP Design: docs/design/living_world_event_system_mvp.md
- GameClock: src/core/systems/game_clock.gd (to be created)
- TimeCostManager: src/core/systems/time_cost_manager.gd (to be created)
- DayCycleController: src/core/systems/day_cycle_controller.gd (to be created)
- SimpleEventScheduler: src/core/systems/simple_event_scheduler.gd (to be created)
- NPCScheduleManager: src/core/systems/npc_schedule_manager.gd (to be created)
- EventDiscovery: src/core/systems/event_discovery.gd (to be created)
- TimeDisplay: src/ui/time_display/time_display.gd (to be created)
- NPC Schedules: src/data/schedules/npc_schedules.json (to be created)
- Scheduled Events: src/data/events/scheduled_events.json (to be created)

## User Stories

### Task 1: Create at least one additional district besides Shipping
**User Story:** As a player, I want to explore different areas of the station, so that I can discover new characters, items, and story elements.

### Task 2: Create bash script for generating NPC placeholders
**User Story:** As a developer, I want a bash script that manages the NPC registry and creates appropriate directory structures for NPC sprites, so that I can easily add new characters to the game with proper integration into the existing systems without manual configuration.

### Task 3: Implement district transitions via tram system
**User Story:** As a player, I want to travel between districts using the tram system, so that I can explore the station while experiencing time passing during travel.
**Reference:** See docs/design/time_management_system_mvp.md Section "Time Cost Manager" - Travel actions

### Task 4: Develop in-game clock and calendar system
**User Story:** As a player, I want to see the current time and day, so that I can plan my activities and understand when events might occur.
**Reference:** See docs/design/time_management_system_mvp.md Section "Game Clock System"

### Task 5: Create time progression through player actions
**User Story:** As a player, I want my actions to consume time, so that I must make strategic choices about how to spend my limited time.
**Reference:** See docs/design/time_management_system_mvp.md Section "Time Cost Manager"

### Task 6: Create SimpleEventScheduler for managing time-based events
**User Story:** As a developer, I want a system that triggers events at specific times, so that the world feels alive and dynamic even when the player isn't present.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "Core Components"

### Task 7: Implement NPCScheduleManager for basic NPC routines
**User Story:** As a player, I want NPCs to follow daily routines, so that the station feels like a real place with people living their lives.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "NPC Schedule Manager"

### Task 8: Create EventDiscovery system for learning about missed events
**User Story:** As a player, I want to discover clues about events I missed, so that I can piece together what happened while I was elsewhere.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "Event Discovery System"

### Task 9: Implement day cycle with sleep mechanics
**User Story:** As a player, I want to rest and advance to the next day, so that I can manage my time and see how the station changes overnight.
**Reference:** See docs/design/time_management_system_mvp.md Section "Day Cycle Controller"

### Task 10: Design and implement time UI indicators
**User Story:** As a player, I want clear visual indicators of time passing, so that I can make informed decisions about my activities.
**Reference:** See docs/design/time_management_system_mvp.md Section "Time UI System"

### Task 11: Convert random assimilation to scheduled event system
**User Story:** As a player, I want assimilation to happen at specific times and places, so that I might witness or investigate these events.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "Event Types in MVP"

### Task 12: Add scheduled story events (security sweeps, meetings)
**User Story:** As a player, I want major story events to occur at specific times, so that I must choose which events to witness or investigate.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "Event Types in MVP"

### Task 13: Create NPC schedule data files for 5-10 key NPCs
**User Story:** As a player, I want important NPCs to have detailed daily routines, so that I can learn their patterns and plan my interactions.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "5-10 Key NPCs with Full Routines"

### Task 14: Implement contextual dialog based on recent events
**User Story:** As a player, I want NPCs to reference recent events in dialog, so that the world feels reactive and interconnected.
**Reference:** See docs/design/living_world_event_system_mvp.md Section "Dialog System Integration"

### Task 15: Implement player bedroom as save point location
**User Story:** As a player, I want a personal space where I can save my progress, so that I have a safe location to plan my next moves.

### Task 16: Create single-slot save system with event state persistence
**User Story:** As a player, I want to save my game including all event history, so that I can continue my unique playthrough later.

### Task 17: Create basic inventory system with size limitations
**User Story:** As a player, I want to collect and carry items with limited space, so that I must make choices about what to keep.

## Notes
- Time Management System MVP provides the core temporal framework for the entire game
- Living World Event System MVP provides foundation for Iteration 12 full implementation
- These two systems work together: Time Manager handles player resource allocation, Event System handles world simulation
- Focus on making 5-10 NPCs feel truly alive rather than many shallow NPCs
- Event discovery through clues and dialog is key to making missed events meaningful
- Performance testing critical with event system running continuously
- Time costs should feel intuitive - players should be able to estimate action costs without constantly checking
