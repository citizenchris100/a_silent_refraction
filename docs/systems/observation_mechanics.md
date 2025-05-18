# Observation Mechanics for Detecting Assimilated NPCs

This document describes the observation mechanics implemented in A Silent Refraction to allow players to detect assimilated NPCs.

## Overview

The observation system is a core gameplay mechanic that allows players to study NPCs for signs of assimilation. This adds depth to the investigation elements of the game and creates tension as players must carefully observe NPCs to determine who has been assimilated.

## Implementation Details

### 1. Visual Cues

- Assimilated NPCs have a subtle visual difference (slightly greenish tint)
- This visual difference is designed to be noticeable but not immediately obvious
- The player needs to carefully observe NPCs to detect these differences

### 2. Behavioral Tells: Speech Patterns

- Assimilated NPCs speak differently from unassimilated ones
- Changes include:
  - Replacement of contractions with formal speech ("don't" → "do not")
  - Use of collective pronouns ("I think" → "we believe")
  - Formal/technical terminology ("good" → "optimal")
  - Occasional word repetition or unusual pauses
- This creates subtle "tells" that observant players can detect during dialog

### 3. Observation Verb

- A new "Observe" verb has been added to the SCUMM-style interface
- When the player selects "Observe" and clicks on an NPC, they begin studying the NPC
- The observation takes time (5 seconds by default) to complete
- This creates tension and requires player commitment

### 4. Detection System

- When observation completes, the player is informed if they detected signs of assimilation
- Success depends on:
  - Time spent observing
  - Previous dialog interactions (improves chance to notice speech pattern changes)
  - Randomness factor to create uncertainty
- If successful, the NPC is marked as "known assimilated"
- The system provides specific details about what clues were detected
- Even failed observations of assimilated NPCs may give a hint that "something feels off"

### 5. NPC Registry Integration

- The NPC registry tracks both the actual assimilation status and the player's knowledge
- The "assimilated" flag tracks the NPC's true state
- The "known_assimilated" flag tracks whether the player has detected this

## Usage in Gameplay

1. Player selects the "Observe" verb from the verb UI
2. Player clicks on an NPC they wish to observe
3. A message appears: "You begin carefully observing [NPC name]..."
4. After 5 seconds, the observation completes
5. The result is displayed with specific details if successful:
   - Success: "You notice subtle signs that [NPC name] has been assimilated! Their speech patterns seem oddly formal and they occasionally refer to themselves as 'we'."
   - Failed but assimilated: "You don't notice anything unusual about [NPC name], but something feels off..."
   - Not assimilated: "You don't notice anything unusual about [NPC name]."
6. If successful, this NPC is marked as "known assimilated" in the player's records

## Integration with Other Systems

### Dialog System

- Assimilated NPCs use transformed dialog with subtle differences:
  - Replace contractions ("don't" → "do not")
  - Use "we" instead of "I" in many contexts
  - Use more formal, technical language
  - May have speech glitches like repeated words or unusual pauses
- Dialog helps players determine who might be assimilated without using the Observe verb
- Previous dialog interactions improve observation success chance

### Suspicion System

- Observing an NPC too often can increase their suspicion level
- Assimilated NPCs may become suspicious more quickly when observed

### NPC Registry and Sprite Loading

- The NPC's appearance is loaded based on their assimilation status
- Sprites are loaded from the appropriate folders based on NPC state
- The registry tracks which NPCs the player has positively identified as assimilated

## Technical Implementation

The observation mechanics are primarily implemented in the following files:

- `src/characters/npc/base_npc.gd`: 
  - Core observation mechanics
  - Dialog transformation system for assimilated NPCs
  - Detection probability calculation
  - Specific feedback about detected clues
- `src/ui/verb_ui/verb_ui.gd`: Added "Observe" to the available verbs
- `src/data/npc_data.gd`: NPC registry integration for tracking known assimilated NPCs