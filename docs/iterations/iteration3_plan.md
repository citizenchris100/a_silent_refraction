# Iteration 3: Game Districts, Time Management, Save System, Title Screen, and Asset Expansion

## Goals
- Implement multiple station districts with transitions
- Create tram system for inter-district travel
- Create detailed time management system (Persona-style)
- Develop day/night cycle and time progression
- Implement configurable daily NPC assimilation system
- Implement single-slot save system
- Create title screen and main menu functionality
- Implement character gender selection feature
- Develop game state management system
- Create basic limited inventory system
- Develop assets for Security District and Barracks
- Rename and expand Shipping District to Spaceport
- Integrate with Animation Framework (from Iteration 3.5)

## Tasks
- [ ] Task 1: Create Security District scene with main floor
  - Implement basic walkable areas and collision detection
  - Add essential interactive objects
  - Connect to existing systems
- [ ] Task 2: Create Barracks District scene with main floor
  - Implement basic walkable areas and collision detection
  - Add essential interactive objects
  - Connect to existing systems
- [ ] Task 3: Rename Shipping to Spaceport and implement expanded structure
  - Update all code references from Shipping to Spaceport
  - Modify district scene structure to accommodate new sub-locations
  - Update walkable areas for expanded layout
- [ ] Task 4: Create Spaceport Terminal sub-location
  - Design terminal background with appropriate airport-like elements
  - Implement waiting area with seating
  - Add flight information displays
  - Create terminal desk check-in area
- [ ] Task 5: Create Traveler NPCs for Spaceport Terminal
  - Design Traveler 01 sprite (all states)
  - Design Traveler 02 sprite (all states)
  - Design Traveler 03 sprite (all states)
  - Design Traveler 04 sprite (all states)
  - Implement traveler NPC behaviors
- [ ] Task 6: Redesign Loading Dock (formerly Main Floor)
  - Update environment art to match new spatial relationship
  - Add cargo management visual elements
  - Create conveyor system visuals
  - Connect with Docked Ships areas
- [ ] Task 7: Design 3 tram station template layouts
  - Create visual designs for small, medium, and large station types
  - Define common elements across all stations
  - Include variations for district-specific theming
- [ ] Task 8: Implement tram station scene templates
  - Build modular station scenes that can be instanced
  - Create adaptable station signage and district identifiers
  - Establish consistent navigation points in all stations
- [ ] Task 9: Create tram arrival/departure animations
  - Design visual effects for tram arrival/departure
  - Implement sound effects for station announcements
  - Add ambient station sounds
- [ ] Task 10: Develop district transition system
  - Create UI for selecting destination districts
  - Implement time advancement during travel
  - Design transition screens/animations between districts
- [ ] Task 11: Implement tram stations in each district
  - Position tram stations at appropriate locations in each district
  - Connect walkable areas to station entrances
  - Add district-specific visual elements to base templates
- [ ] Task 12: Develop in-game clock and calendar system
  - Create UI displays for time and date
  - Implement time tracking mechanics
  - Add day/night cycle effects on gameplay
- [ ] Task 13: Create time progression through player actions
  - Define time costs for different actions
  - Implement tram travel time costs
  - Create consistency in time progression
- [ ] Task 14: Implement day cycle with sleep mechanics
  - Create sleep interaction in player's room
  - Design day transition visuals
  - Implement effects of day changes on NPCs and environment
- [ ] Task 15: Design and implement time UI indicators
  - Create clock and calendar UI elements
  - Add visual indicators for day/night status
  - Implement time-sensitive warning indicators
- [ ] Task 16: Create system for random NPC assimilation over time
  - Implement daily assimilation chance calculations
  - Create assimilation event triggers
  - Design notification system for significant changes
- [ ] Task 17: Implement configurable assimilation manager with parameters:
  - Base daily assimilation rate
  - Daily increase rate
  - Maximum daily assimilations
  - Proximity weighting for assimilation spread
  - Protected NPCs list
- [ ] Task 18: Add time-based events and triggers
  - Create scheduled NPC behaviors
  - Implement timed quest opportunities
  - Design emergency/special events
- [ ] Task 19: Implement player bedroom as save point location
  - Create bedroom save interaction
  - Design save confirmation UI
  - Implement auto-save on sleep
- [ ] Task 20: Create single-slot save system with confirmation UI
  - Develop save data structure
  - Implement save/load mechanics
  - Create save state visualization
- [ ] Task 21: Create basic inventory system with size limitations
  - Design inventory UI
  - Implement item management
  - Add size/weight restrictions
- [ ] Task 22: Design Security District main floor background
  - Create consistent visual theme
  - Add appropriate details and objects
  - Implement any animated elements
- [ ] Task 23: Create Brig background with visible cell layout
  - Design cell block visuals
  - Add interactive cell doors
  - Implement security station elements
- [ ] Task 24: Design Barracks main floor with concierge desk
  - Create residential area visuals
  - Implement concierge station
  - Add appropriate detailed elements
- [ ] Task 25: Create Concierge and Porter sprites
  - Design all character states (normal, suspicious, hostile, assimilated)
  - Implement state transitions
  - Add interaction animations
- [ ] Task 26: Design interactive cell door objects
  - Create locked/unlocked visuals
  - Implement interaction mechanics
  - Add appropriate sound effects
- [ ] Task 27: Develop asset metadata system to manage sprite states
  - Create data structure for managing visual states
  - Implement state transition system
  - Add metadata integration with game systems
- [ ] Task 28: Create Shipping Office background with animated elements
  - Rename to Spaceport Office
  - Design office environment
  - Add appropriate details and objects
  - Implement animated background elements
- [ ] Task 29: Create Dock Worker sprites (3 variations)
  - Design all character states for each variation
  - Ensure visual consistency
  - Implement state transitions
- [ ] Task 30: Design interactive room door objects
  - Create room number visualization
  - Implement locked/unlocked mechanics
  - Add room entry interactions
- [ ] Task 31: Create title screen scene with background art
  - Design and implement main menu background artwork
  - Create title text/logo display
  - Add ambient animation elements
- [ ] Task 32: Implement main menu UI
  - Design "New Game" button
  - Design "Load Game" button
  - Add "Options" button
  - Add "Credits" button
  - Add "Quit" button
- [ ] Task 33: Create game state manager
  - Implement scene transition management
  - Create persistent data handling between scenes
  - Add initialization sequence management
- [ ] Task 34: Develop new game initialization process
  - Create player data initialization
  - Implement starting location setup
  - Add initial dialog/tutorial trigger
- [ ] Task 35: Implement game loading system
  - Create save file selection UI
  - Develop data loading and validation
  - Add load error handling
- [ ] Task 36: Add options menu functionality
  - Implement audio settings
  - Add display/resolution options
  - Create control remapping capability
  - Develop accessibility options
- [ ] Task 37: Create character selection screen
  - Design UI layout with male/female options
  - Create character preview graphics
  - Implement selection confirmation
- [ ] Task 38: Develop player data structure with gender attribute
  - Modify player data to include gender selection
  - Ensure this is saved/loaded with game data
- [ ] Task 39: Create female player character sprites
  - Design female character sprites matching existing male poses/states
  - Ensure consistent style between character variants
- [ ] Task 40: Implement sprite loading based on gender selection
  - Modify player character code to load appropriate sprites
  - Add fallback handling for compatibility
- [ ] Task 41: Implement Spaceport Terminal background animations
  - Create flight departure/arrival board animations
  - Implement passenger flow animations
  - Add security checkpoint animations
  - Design baggage claim animations
  - Add ticket counter interaction animations
- [ ] Task 42: Implement Loading Dock background animations
  - Create cargo loading/unloading conveyor systems
  - Add worker activity background animations
  - Design electronic manifest display updates
  - Implement warning lights for restricted areas
  - Create crane and lifting equipment animations
- [ ] Task 43: Create Docked Ship area animations
  - Design engine power-up/down sequences
  - Implement airlock opening/closing mechanisms
  - Create ship status displays with lockdown information
  - Add landing gear compression/extension animations
  - Implement cabin lighting systems
- [ ] Task 44: Develop Spaceport Office animated elements
  - Create computer terminals with shipping data visualizations
  - Implement tracking system displays with ship positions
  - Add schedule boards with arrival/departure updates
  - Design security camera feeds of dock areas
  - Create communication systems for ship coordination
- [ ] Task 45: Perform in-game integration testing of all Iteration 3 features
  - Test district travel via tram system
  - Verify time progression and day cycle
  - Test assimilation over time
  - Validate save/load functionality
  - Confirm character gender selection works correctly
  - Verify all animated background elements function properly
  - Test Spaceport Terminal and Loading Dock functionality

## Testing Criteria
- Player can travel between at least three districts (Spaceport, Security, Barracks)
- Tram stations function with appropriate visuals and animations
- Time advances consistently through specific actions (tram travel, conversations, etc.)
- Tram travel costs appropriate amount of time
- Day advances when player sleeps
- NPCs change status (assimilated/not) over time based on configured parameters
- Assimilation spreads in a logical pattern with spatial proximity influencing selection
- Story-critical NPCs remain protected from random assimilation
- Player can save game by returning to their room
- Player has limited inventory space
- All locations needed for early quests have proper backgrounds and assets
- NPCs relevant to these locations are properly represented visually
- Title screen displays correctly with all UI elements functional
- Character gender selection works and affects in-game appearance
- Player's gender choice persists across save/load operations
- New game starts properly with correct initialization
- Saved games can be loaded from the title screen
- Game options can be configured from the settings menu
- Game state persists correctly during scene transitions
- Spaceport Terminal and Loading Dock areas function properly with animated elements
- Airport-specific animations play correctly (flight boards, baggage claim, etc.)
- Shipping-specific animations function properly (cargo systems, cranes, etc.)
- Ship docking/undocking sequences play at appropriate times
- Traveler NPCs exhibit appropriate behaviors
- Office terminals display contextually relevant information
- Animation performance remains within acceptable parameters

## Timeline
- Start date: 2025-05-28
- Target completion: 2025-08-02 (9-10 weeks)
  - Extended by 5-6 weeks to account for district creation, tram system, title screen, character selection, game state management, Spaceport expansion, and background animation implementation

## Dependencies
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework, Suspicion System, and Initial Asset Creation)
- Iteration 3.5 (Animation Framework and Core Systems) - partial dependency for animation tasks

## Code Links
- No links yet

## Notes
This iteration has been expanded to include multiple districts (Spaceport, Security, and Barracks) connected by a tram system. The tram system will feature three reusable station templates that will be adapted for each district, providing a consistent yet varied travel experience while optimizing development resources.

The Shipping district has been expanded and renamed to Spaceport, with a clear division between passenger terminal and cargo operations. This better reflects the dual purpose of the area as both a commercial travel hub and cargo management center, adding more depth to the game environment and creating more opportunities for interesting interactions.

The time management system will be a core game mechanic, allowing for the simulation of NPC assimilation over time and creating tension as the player races against the spread of the alien presence. Time will advance through various player actions, with tram travel between districts being a significant time investment.

The NPC assimilation system will provide a configurable framework to fine-tune game difficulty and pacing. By adjusting parameters like the daily assimilation rate, we can create a sense of urgency without overwhelming the player. The proximity weighting ensures that assimilation spreads realistically through the station, while the protected NPCs list ensures that story-critical characters remain available for key interactions regardless of how long the player takes to complete objectives.

The title screen and game state management features added to this iteration will provide a proper entry point to the game and handle transitions between the main menu and gameplay. This creates a more polished user experience and establishes the foundation for the save/load system. The options menu will allow players to customize their experience according to their preferences and accessibility needs.

The character gender selection feature enhances player immersion by allowing customization of the player character. This choice will be stored in the player data structure and will affect which sprites are loaded throughout the game. It also provides greater inclusivity for players by offering gender representation options.

The background animation tasks will leverage the Animation Framework from Iteration 3.5 to create a dynamic, responsive environment. The Spaceport district will serve as the first fully animated location, with rich interactive elements that respond to game events and player actions. These animations will enhance immersion and provide important visual feedback about the game world state.