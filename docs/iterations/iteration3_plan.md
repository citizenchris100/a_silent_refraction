# Iteration 3: Game Districts, Time Management, Save System, and Asset Expansion

## Goals
- Implement multiple station districts with transitions
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- Implement configurable daily NPC assimilation system
- Implement single-slot save system
- Create basic limited inventory system
- Develop assets for Security District and Barracks

## Tasks
- [ ] Task 1: Create at least one additional district besides Shipping
- [ ] Task 2: Implement district transitions via tram system
- [ ] Task 3: Develop in-game clock and calendar system
- [ ] Task 4: Create time progression through player actions
- [ ] Task 5: Implement day cycle with sleep mechanics
- [ ] Task 6: Design and implement time UI indicators
- [ ] Task 7: Create system for random NPC assimilation over time
- [ ] Task 8: Implement configurable assimilation manager with parameters:
  - Base daily assimilation rate
  - Daily increase rate
  - Maximum daily assimilations
  - Proximity weighting for assimilation spread
  - Protected NPCs list
- [ ] Task 9: Add time-based events and triggers
- [ ] Task 10: Implement player bedroom as save point location
- [ ] Task 11: Create single-slot save system with confirmation UI
- [ ] Task 12: Create basic inventory system with size limitations
- [ ] Task 13: Design Security District main floor background
- [ ] Task 14: Create Brig background with visible cell layout
- [ ] Task 15: Design Barracks main floor with concierge desk
- [ ] Task 16: Create Concierge and Porter sprites
- [ ] Task 17: Design interactive cell door objects
- [ ] Task 18: Develop asset metadata system to manage sprite states
- [ ] Task 19: Create Shipping Office background with animated elements
- [ ] Task 20: Create Dock Worker sprites (3 variations)
- [ ] Task 21: Design interactive room door objects
- [ ] Task 22: Perform in-game integration testing of all Iteration 3 features

## Testing Criteria
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time based on configured parameters
- Assimilation spreads in a logical pattern with spatial proximity influencing selection
- Story-critical NPCs remain protected from random assimilation
- Player can save game by returning to their room
- Player has limited inventory space
- All locations needed for early quests have proper backgrounds and assets
- NPCs relevant to these locations are properly represented visually

## Timeline
- Start date: 2025-05-28
- Target completion: 2025-06-21 (4 weeks)

## Dependencies
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework, Suspicion System, and Initial Asset Creation)

## Code Links
- No links yet

## Notes
This iteration has been expanded to include assets for the Security District and Barracks, which are crucial for the first quest storyline. The time management system will be a core game mechanic, allowing for the simulation of NPC assimilation over time and creating tension as the player races against the spread of the alien presence.

The NPC assimilation system will provide a configurable framework to fine-tune game difficulty and pacing. By adjusting parameters like the daily assimilation rate, we can create a sense of urgency without overwhelming the player. The proximity weighting ensures that assimilation spreads realistically through the station, while the protected NPCs list ensures that story-critical characters remain available for key interactions regardless of how long the player takes to complete objectives.