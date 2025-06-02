# Iteration 21: Dialog and Narrative

## Epic Description
As a content creator, I want to implement all dialog trees, environmental storytelling, and narrative elements to bring characters to life and create an immersive story experience.

## Cohesive Goal
**"Every conversation matters and every detail tells a story"**

## Overview
This iteration implements Phase 3.4, adding the complete narrative layer including all NPC dialog trees, environmental storytelling, dynamic dialog variations, ending-specific narrative content, and the thousands of lines of text that bring the game world to life. This is where characters gain their unique voices and personalities.

## Goals
- Write ~10,000 lines of character dialog
- Create gender-specific dialog variations
- Implement trust and suspicion responses
- Add environmental storytelling throughout
- Create dynamic time-based dialog
- Write ending-specific narrative content
- Polish all narrative elements

## Requirements

### Business Requirements
- **B1:** Professional quality writing throughout
  - **Rationale:** Writing quality directly impacts player engagement
  - **Success Metric:** Player feedback indicates memorable characters
- **B2:** Consistent character voices
  - **Rationale:** Character consistency maintains immersion
  - **Success Metric:** Each character has distinct speech patterns
- **B3:** Engaging noir atmosphere
  - **Rationale:** Genre consistency creates cohesive experience
  - **Success Metric:** Reviews praise atmospheric writing
- **B4:** Efficient localization support
  - **Rationale:** Future translation needs preparation
  - **Success Metric:** Text easily extractable for translation

### User Requirements
- **U1:** Memorable character interactions
  - **User Value:** Characters feel like real people
  - **Acceptance Criteria:** Unique dialog per character
- **U2:** Dialog reflects my choices
  - **User Value:** Player agency matters
  - **Acceptance Criteria:** Choices affect conversations
- **U3:** Environmental details reward exploration
  - **User Value:** Discovery enhances immersion
  - **Acceptance Criteria:** Hidden stories throughout world
- **U4:** Conversations feel natural
  - **User Value:** Believable interactions
  - **Acceptance Criteria:** Contextual awareness in dialog
- **U5:** Story unfolds organically
  - **User Value:** Narrative progression feels earned
  - **Acceptance Criteria:** Information revealed appropriately

### Technical Requirements
- **T1:** Dialog system handles variations
  - **Rationale:** Complex branching required
  - **Constraints:** Must support nested conditions
- **T2:** Performance with large text database
  - **Rationale:** 10,000+ lines need efficient loading
  - **Constraints:** Memory usage optimization required
- **T3:** Dynamic text generation
  - **Rationale:** Contextual dialog needs templates
  - **Constraints:** Variable substitution system needed
- **T4:** Localization framework ready
  - **Rationale:** Future translation support
  - **Constraints:** Text key system required
- **T5:** Text search capabilities
  - **Rationale:** Development efficiency
  - **Constraints:** Fast searching across all text

## Tasks

### Character Dialog
- [ ] Task 1: Implement core dialog trees for 150 NPCs
- [ ] Task 2: Create gender-specific dialog variations
- [ ] Task 3: Implement trust-based dialog branches
- [ ] Task 4: Create suspicion response system
- [ ] Task 5: Write coalition recruitment dialog

### Environmental Narrative
- [ ] Task 6: Write environmental storytelling content
- [ ] Task 7: Create dynamic time-based dialog
- [ ] Task 8: Implement investigation-related dialog

### Ending-Specific Content
- [ ] Task 9: Write Day 30 evaluation dialog
- [ ] Task 10: Create control path narrative content
- [ ] Task 11: Create escape path narrative content
- [ ] Task 12: Write ending text variations

### Polish and Integration
- [ ] Task 13: Perform narrative polish pass
- [ ] Task 14: Integrate all dialog with systems
- [ ] Task 15: Test narrative flow and consistency

## User Stories

### Task 1: Implement core dialog trees for 150 NPCs

**User Story:** As a player, I want each NPC to have a unique voice and personality that comes through in their dialog, so that the station feels populated by distinct individuals.

**Design Reference:** `docs/design/template_npc_design.md`, `docs/design/dialog_manager_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, B2, U1, T1
- **Acceptance Criteria:**
  1. 150 NPC base dialog trees implemented
  2. 50-100 lines per character average
  3. Personality consistency maintained
  4. Appropriate vocabulary per character
  5. Emotional range demonstrated
  6. Natural conversation flow
  7. Faction-appropriate speech patterns
  8. Job-related dialog included

**Implementation Notes:**
- Use character personality sheets as reference
- Include profession-specific terminology
- Vary sentence structure per character
- Some NPCs more verbose than others
- Hidden assimilated should have subtle tells

### Task 2: Create gender-specific dialog variations

**User Story:** As a player, I want NPCs to address and interact with me in ways that respect my chosen gender identity, so that I feel properly represented in the game world.

**Design Reference:** `docs/design/gender_system_design.md`, `docs/design/dialog_manager_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U2, T1
- **Acceptance Criteria:**
  1. Pronoun variations throughout (he/she/they)
  2. Gender-specific reactions from NPCs
  3. Romance dialog branches per gender
  4. Professional addresses vary appropriately
  5. Natural integration without calling attention
  6. Respectful handling of all options
  7. Workplace harassment reflects gender
  8. Some NPCs have gender preferences

**Implementation Notes:**
- Use dialog variable system for pronouns
- Create templates for common phrases
- Test all paths for each gender
- Ensure no default assumptions
- Reference gender system design

### Task 3: Implement trust-based dialog branches

**User Story:** As a player, I want NPCs to open up and share secrets as they learn to trust me through my actions, so that building relationships feels meaningful.

**Design Reference:** `docs/design/trust_relationship_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2, T1
- **Acceptance Criteria:**
  1. 3-5 trust levels per NPC defined
  2. Progressive information revelations
  3. Secret information behind trust gates
  4. Personal story unlocks at high trust
  5. Trust-building dialog options
  6. Betrayal consequences in dialog
  7. Coalition recruitment requires trust
  8. Assimilation hints at max trust

**Implementation Notes:**
- Trust thresholds: 0, 25, 50, 75, 100
- Some info only at 90+ trust
- Betrayal can lock dialog permanently
- Track trust-revealing moments
- High trust reveals assimilation clues

### Task 4: Create suspicion response system

**User Story:** As a player, I want NPCs to react differently when they're suspicious, creating tension in conversations and making me consider my words carefully.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2, T1
- **Acceptance Criteria:**
  1. 5 suspicion level response sets
  2. Increasingly evasive dialog
  3. Confrontation scenarios trigger
  4. De-escalation paths available
  5. Investigation blocks at high suspicion
  6. Hostile reactions possible
  7. Security called at maximum
  8. Different reactions per personality

**Implementation Notes:**
- Suspicion levels: 0-20, 21-40, 41-60, 61-80, 81-100
- Some NPCs more paranoid than others
- Military NPCs quicker to suspicion
- Civilians more trusting generally
- Assimilated NPCs may fake suspicion

### Task 5: Write coalition recruitment dialog

**User Story:** As a player, I want to carefully convince NPCs to join the resistance through persuasive conversations, so that building my coalition feels earned.

**Design Reference:** `docs/design/coalition_resistance_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Unique recruitment pitch per NPC
  2. Objection handling dialog trees
  3. Trust requirements clearly communicated
  4. Risk discussions included
  5. Commitment ceremony dialog
  6. Faction-specific concerns addressed
  7. Benefits clearly explained
  8. Consequences understood

**Implementation Notes:**
- Minimum 75 trust for recruitment
- Some NPCs have special requirements
- Military want security guarantees
- Civilians want protection promises
- Criminals want profit assurances

### Task 6: Write environmental storytelling content

**User Story:** As a player, I want to discover story details through item descriptions, notes, and environmental clues, so that exploration rewards me with lore and backstory.

**Design Reference:** `docs/design/investigation_clue_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B3, U3, T1
- **Acceptance Criteria:**
  1. 500+ item descriptions written
  2. 100+ location descriptions complete
  3. Personal notes/journals placed
  4. Computer terminal messages
  5. Environmental clue descriptions
  6. Lore consistency maintained
  7. Assimilation hints scattered
  8. Station history revealed

**Implementation Notes:**
- Each district needs 50+ descriptions
- Include mundane and significant items
- Hide major clues in subtle places
- Personal effects tell mini-stories
- Terminal logs reveal timeline

### Task 7: Create dynamic time-based dialog

**User Story:** As a player, I want conversations to acknowledge the time and current events, making the world feel responsive to the passage of time.

**Design Reference:** `docs/design/time_management_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U4, T3
- **Acceptance Criteria:**
  1. Morning/evening greetings vary
  2. Schedule awareness in dialog
  3. Event reactions included
  4. Urgency variations for deadlines
  5. Deadline mentions when relevant
  6. Contextual awareness demonstrated
  7. Fatigue reflected in speech
  8. Day count references included

**Implementation Notes:**
- Time periods: morning, afternoon, evening, night
- Urgent dialog within 24h of deadlines
- NPCs mention being tired at night
- Reference recent events dynamically
- Day 25+ adds evaluation mentions

### Task 8: Implement investigation-related dialog

**User Story:** As a player, I want to question NPCs about clues and evidence I've found, so that investigation feels like real detective work.

**Design Reference:** `docs/design/investigation_clue_tracking_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U2, T1
- **Acceptance Criteria:**
  1. Clue-specific dialog options
  2. Evidence presentation mechanics
  3. Reaction variations per NPC
  4. Deduction confirmations possible
  5. False lead discussions
  6. Confrontation with evidence
  7. Information trading dialog
  8. Investigation progress reflected

**Implementation Notes:**
- Check ClueManager for available topics
- Some NPCs provide false information
- High trust reveals more context
- Evidence can break through lies
- Assimilated may misdirect deliberately

### Task 9: Write Day 30 evaluation dialog

**User Story:** As a player, I want NPCs to react to the approaching evaluation day with appropriate concern or confidence, so that the deadline feels meaningful.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 400-412

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U5, T1
- **Acceptance Criteria:**
  1. Day 25-30 special dialog
  2. Increasing urgency reflected
  3. Coalition confidence/worry shown
  4. Assimilated show subtle glee
  5. Ratio awareness demonstrated
  6. Control vs escape foreshadowing
  7. Player choices referenced
  8. Final preparations discussed

**Implementation Notes:**
- Progressive urgency: concern→worry→panic
- Coalition members offer final help
- Some NPCs make final confessions
- Hidden assimilated slip more
- Reference current ratio in dialog

### Task 10: Create control path narrative content

**User Story:** As a player on the control path, I want dialog and narrative that reflects my success in containing the threat and the corporate conspiracy I must stop.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 148-225

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U5, T1
- **Acceptance Criteria:**
  1. Corporate conspiracy dialog trees
  2. Legal battle preparations
  3. Coalition rally speeches
  4. Evidence gathering conversations
  5. Infiltration planning dialog
  6. Success celebration writing
  7. Failure commiseration text
  8. Faction-specific variations

**Implementation Notes:**
- Emphasize hope and determination
- Coalition strength affects options
- Multiple approaches need dialog
- Corporate villains need voice
- Victory should feel earned

### Task 11: Create escape path narrative content

**User Story:** As a player on the escape path, I want dialog and narrative that reflects the desperate situation and the hope of saving some survivors.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 227-298

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U5, T1
- **Acceptance Criteria:**
  1. Desperate evacuation dialog
  2. Survivor verification conversations
  3. Resource scavenging discussions
  4. Transportation negotiations
  5. Betrayal revelation scenes
  6. Farewell conversations written
  7. Sacrifice volunteer dialog
  8. Escape success/failure text

**Implementation Notes:**
- Emphasize desperation and fear
- Paranoia about infiltrators high
- Time pressure in every conversation
- Some refuse to leave
- Tearful goodbyes needed

### Task 12: Write ending text variations

**User Story:** As a player, I want the ending text to reflect my journey and choices throughout the game, so that the conclusion feels personalized.

**Design Reference:** `docs/design/multiple_endings_system_design.md` lines 436-459

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U5, T3
- **Acceptance Criteria:**
  1. Control success variations (5+)
  2. Control failure variations (3+)
  3. Escape success variations (5+)
  4. Escape failure variations (3+)
  5. Faction-specific modifications
  6. Coalition size reflected
  7. Key character fates mentioned
  8. Statistics woven into narrative

**Implementation Notes:**
- 200-300 words per ending
- Reference major choices
- Name specific NPCs when possible
- Vary tone based on success degree
- Leave some mystery for replay

### Task 13: Perform narrative polish pass

**User Story:** As a player, I want all text to be polished, error-free, and maintaining consistent noir atmosphere throughout the game.

**Design Reference:** Style guide (internal document)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, B3, U4
- **Acceptance Criteria:**
  1. Grammar/spelling check complete
  2. Tone consistency verified
  3. Character voice verification done
  4. Noir atmosphere maintained
  5. Pacing improvements made
  6. Clarity edits completed
  7. Fact checking finished
  8. Consistency check done

**Implementation Notes:**
- Use spell check tools
- Read aloud for flow
- Check character sheets for voice
- Verify timeline consistency
- Ensure no anachronisms

### Task 14: Integrate all dialog with systems

**User Story:** As a developer, I want all dialog properly integrated with game systems, so that text responds correctly to game state.

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1, T3, T4
- **Acceptance Criteria:**
  1. Variable substitution working
  2. Condition checks functional
  3. State tracking accurate
  4. Save/load preserves context
  5. Performance acceptable
  6. Memory usage optimized
  7. Localization keys set
  8. Search indexing complete

**Implementation Notes:**
- Test all condition branches
- Verify variable substitutions
- Profile memory usage
- Implement text caching
- Create debug visualization

### Task 15: Test narrative flow and consistency

**User Story:** As a developer, I want to verify the complete narrative experience flows properly from start to all endings.

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, B2, U5
- **Acceptance Criteria:**
  1. Full playthroughs completed
  2. All branches tested
  3. Information reveal pacing verified
  4. Character arcs complete
  5. Ending foreshadowing present
  6. No contradictions found
  7. Emotional beats land
  8. Player agency respected

**Implementation Notes:**
- Create narrative test plan
- Document all paths tested
- Note pacing issues
- Verify emotional progression
- Check for plot holes

## Testing Criteria
- All dialog trees function correctly
- Gender variations trigger appropriately
- Trust levels affect conversations properly
- Suspicion responses scale correctly
- Time-based dialog updates work
- Environmental text is accessible
- Investigation dialog integrates properly
- Ending-specific content triggers correctly
- No missing text or placeholders
- Character voices remain consistent
- Performance with full text database acceptable
- Localization framework functional

## Timeline
- **Estimated Duration:** 5-6 weeks (expanded from 4-5)
- **Total Hours:** 180 (expanded from 148)
- **Critical Path:** Dialog must be complete for final testing

## Definition of Done
- [ ] 10,000+ lines of dialog written
- [ ] All 150 NPCs have complete conversations
- [ ] Gender variations implemented throughout
- [ ] Trust/suspicion branches working correctly
- [ ] Environmental storytelling complete
- [ ] Dynamic time variations functional
- [ ] Ending-specific narrative content done
- [ ] Full narrative polish completed
- [ ] All text integrated with systems
- [ ] Complete narrative testing done

## Dependencies
- All NPCs implemented (Iterations 18-19)
- All quests designed (Iteration 20)
- Multiple endings system (Iteration 17)
- Dialog system infrastructure (Iteration 6)
- Character personality definitions
- Time management system (Iteration 5)
- Investigation system (Iteration 15)
- Trust/suspicion systems (Iterations 9-10)

## Risks and Mitigations
- **Risk:** Dialog inconsistency across writers
  - **Mitigation:** Style guide, character sheets, review process
- **Risk:** Text database performance
  - **Mitigation:** Efficient loading, caching strategies, profiling
- **Risk:** Localization complexity
  - **Mitigation:** Early framework setup, consistent text keys
- **Risk:** Narrative contradictions
  - **Mitigation:** Fact checking, timeline documentation
- **Risk:** Ending content scope creep
  - **Mitigation:** Clear variation limits, template use

## Links to Relevant Code
- data/dialog/npcs/
- data/dialog/gender_variations/
- data/dialog/trust_levels/
- data/dialog/suspicion/
- data/dialog/investigation/
- data/dialog/endings/
- data/dialog/evaluation_countdown/
- data/descriptions/items/
- data/descriptions/locations/
- data/dialog/coalition/
- data/narrative/style_guide.md
- data/narrative/character_sheets/
- docs/design/dialog_manager_design.md
- docs/design/multiple_endings_system_design.md