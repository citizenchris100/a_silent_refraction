# Iteration 3: Game Districts and Time Management

## Goals
- Implement multiple station districts with transitions
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- Implement random NPC assimilation tied to time
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

### User Requirements
- **U1:** As a player, I want to manage my time to prioritize activities
  - **User Value:** Creates strategic decision-making and consequences
  - **Acceptance Criteria:** Different actions consume varying amounts of in-game time

- **U2:** As a player, I want to explore distinct areas of the station
  - **User Value:** Provides variety and discovery
  - **Acceptance Criteria:** Each district has unique visuals, NPCs, and activities

### Technical Requirements (Optional)
- **T1:** Implement robust scene transition system
  - **Rationale:** District loading and transitions must be seamless
  - **Constraints:** Must preserve game state across transitions

## Tasks
- [ ] Task 1: Create at least one additional district besides Shipping
- [ ] Task 2: Create bash script for generating NPC placeholders
- [ ] Task 3: Implement district transitions via tram system
- [ ] Task 4: Develop in-game clock and calendar system
- [ ] Task 5: Create time progression through player actions
- [ ] Task 6: Implement day cycle with sleep mechanics
- [ ] Task 7: Design and implement time UI indicators
- [ ] Task 8: Create system for random NPC assimilation over time
- [ ] Task 9: Add time-based events and triggers
- [ ] Task 10: Implement player bedroom as save point location
- [ ] Task 11: Create single-slot save system with confirmation UI
- [ ] Task 12: Create basic inventory system with size limitations

## Testing Criteria
- Player can travel between at least two districts
- Time advances through specific actions (tram travel, conversations, etc.)
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time
- Player can save game by returning to their room
- Player has limited inventory space
- NPC placeholder script successfully creates properly structured directories and registry entries
- Multiple NPCs can be easily added across different districts using the script

## Timeline
- Start date: 2025-05-16
- Target completion: 2025-05-30

## Dependencies
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)

## Code Links
- No links yet

## Notes
Add any additional notes or considerations here.

### Task 2: Create bash script for generating NPC placeholders

**User Story:** As a developer, I want a bash script that manages the NPC registry and creates appropriate directory structures for NPC sprites, so that I can easily add new characters to the game with proper integration into the existing systems without manual configuration.

**Requirements:**
- **Linked to:** B2, B5
- **Acceptance Criteria:**
  1. Script creates proper directory structures for each NPC's sprite states (normal, suspicious, hostile, assimilated)
  2. NPCs are registered in the NPC registry system with default values (not assimilated, normal suspicion level)
  3. NPCs are properly categorized by district/location in the registry
  4. New NPCs can be added with a single command specifying their designation/name and location
  5. Script handles the backend integration with the JSON registry and GDScript access layer
  6. Registry tracks both assimilation status and suspicion level as separate properties
  7. Script prepares the structure for the four different sprite states without placing actual assets

**Implementation Notes:**
- Default NPCs should be initialized in a normal (not assimilated) state with normal suspicion
- Maintain clear separation between assimilation status and suspicion level in the registry
- Ensure the directory structure aligns with the game's asset loading expectations
- Use JSON for data persistence and create a GDScript interface for game access
