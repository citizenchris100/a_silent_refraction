# Iteration 2: NPC Framework, Suspicion System, and Initial Asset Creation

## Goals
- Implement basic NPCs with interactive capabilities
- Create the suspicion system as a core gameplay mechanic
- Apply visual style guide to one area as a prototype
- Develop placeholder art generation for NPCs
- Create initial set of game assets for core gameplay areas
- Implement assimilation detection mechanics

## Tasks
- [x] Task 1: Create base NPC class with state machine
- [x] Task 2: Implement NPC dialog system
- [x] Task 3: Create suspicion meter UI element
- [x] Task 4: Implement suspicion tracking system
- [x] Task 5: Script NPC reactions based on suspicion levels
- [x] Task 6: Apply visual style guide to Shipping District
- [x] Task 7: Create bash script for generating NPC placeholders
- [x] Task 8: Implement observation mechanics for detecting assimilated NPCs
- [x] Task 9: Create script for generating animated background elements
- [ ] Task 10: Design Shipping District main floor background with animated elements
- [ ] Task 11: Create Docked Ship USCSS Theseus background (player starting location)
- [ ] Task 12: Create Player character sprites (front, side, back views)
- [ ] Task 13: Create assimilated variant of Player character sprites
- [ ] Task 14: Create Security Officer sprites (standard, suspicious, hostile states)
- [ ] Task 15: Create assimilated variants of Security Officer sprites
- [ ] Task 16: Design NPC sprite template with state transitions
- [ ] Task 17: Create Bank Teller sprites (initial quest NPC)
- [ ] Task 18: Create assimilated variant of Bank Teller sprites
- [ ] Task 19: Create Player's room (Room 306) background
- [ ] Task 20: Perform in-game integration testing of all Iteration 2 features

## Testing Criteria
- NPCs can be interacted with using the verb system
- Suspicion level changes based on player actions
- Visual style matches the style guide specifications
- Observation mechanics work correctly
- Background elements properly display animated components
- NPC sprites correctly transition between states based on suspicion level
- Assimilated NPC variants show subtle but detectable differences
- Player can successfully identify assimilated NPCs through observation

## Timeline
- Start date: 2025-05-07
- Target completion: 2025-06-04 (extended by 2 weeks to account for expanded asset creation)

## Dependencies
- Iteration 1 (Basic Environment and Navigation)

## Code Links
- tools/create_npc_registry.sh - NPC registry and placeholder generation

## Notes
This iteration has been expanded to include essential asset creation tasks. These assets will focus on the areas needed for the initial game experience, including the player starting location, key NPCs involved in early quests, and the player's home base. The animated background system will serve as a foundation for all future location designs.

The assimilation detection mechanics are a core gameplay element that allows players to identify which NPCs have been assimilated. This system includes visual cues in NPC sprites, behavioral tells in dialog, and an observation verb in the SCUMM interface that allows players to study NPCs for signs of assimilation.