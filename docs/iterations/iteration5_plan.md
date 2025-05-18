# Iteration 5: Investigation Mechanics and Inventory

## Goals
- Implement investigation mechanics
- Create quest log system for tracking progress
- Develop advanced inventory system for collecting evidence
- Add system for logging known assimilated NPCs
- Implement overflow storage in player's room

## Requirements

### Business Requirements
- **B1:** Implement core investigation mechanics that drive main storyline
  - **Rationale:** Investigation is the primary gameplay loop for narrative progression
  - **Success Metric:** Players can advance the story through evidence collection and analysis

### User Requirements
- **U1:** As a player, I want to collect and analyze evidence
  - **User Value:** Creates detective gameplay satisfaction
  - **Acceptance Criteria:** Evidence can be found, stored, examined, and combined to progress

### Technical Requirements (Optional)
- **T1:** Technical requirement placeholder
  - **Rationale:** Why this is technically important
  - **Constraints:** Any limitations to be aware of

## Tasks
- [ ] Task 1: Create quest data structure and manager
- [ ] Task 2: Implement quest log UI
- [ ] Task 3: Develop advanced inventory features including categorization
- [ ] Task 4: Create puzzles for accessing restricted areas
- [ ] Task 5: Implement clue discovery and collection system
- [ ] Task 6: Create assimilated NPC tracking log
- [ ] Task 7: Develop investigation progress tracking
- [ ] Task 8: Add quest state persistence
- [ ] Task 9: Implement overflow inventory storage in player's room
- [ ] Task 10: Create UI for transferring items between personal inventory and room storage
- [ ] Task 11: Implement observation mechanics for detecting assimilated NPCs

## Testing Criteria
- Quest log accurately tracks active and completed quests
- Player can collect and use items/evidence
- Puzzles can be solved to progress investigation
- Player can track which NPCs are known to be assimilated
- Player can store extra items in their room
- Inventory management creates meaningful gameplay decisions
- Observation mechanics allow players to detect assimilated NPCs
- Different observation intensities reveal appropriate information

## Timeline
- Start date: 2025-06-15
- Target completion: 2025-06-29

## Dependencies
- Iteration 2 (NPC Framework and Suspicion System)
- Iteration 3 (Navigation Refactoring and Multi-Perspective Character System)
- Iteration 4 (Game Districts and Time Management)

## Code Links
- No links yet

## Notes
Add any additional notes or considerations here.

### Task 11: Implement observation mechanics for detecting assimilated NPCs

**User Story:** As a player, I want to carefully observe NPCs for subtle clues that indicate they have been assimilated, so that I can identify threats and make informed decisions about whom to trust and recruit.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. NPCs exhibit different subtle behavioral cues based on assimilation status
  2. Assimilated NPCs have visual tells that are discoverable through careful observation
  3. Player can access a dedicated "observe" mode that enables closer inspection of NPCs
  4. Different observation levels reveal different levels of information (casual glance vs. intense scrutiny)
  5. Successful observation adds information to the assimilated NPC tracking log
  6. False positives are possible to create tension and uncertainty
  7. Observation mechanics integrate with the suspicion system (being caught observing raises suspicion)

**Implementation Notes:**
- Create a sliding scale of observation intensity with corresponding information reveals
- Design subtle visual cues that fit the game's aesthetic (slight color shifts, animation differences)
- Balance difficulty so observation feels like skilled detective work but not frustratingly obscure
- Link with existing suspicion and NPC state systems from Iteration 2