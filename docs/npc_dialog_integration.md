# NPC and Dialog System Integration

## Overview

This document outlines the NPC interaction and dialog system implemented in Iteration 2 of A Silent Refraction.

## Core Components

### 1. Base NPC Class (src/characters/npc/base_npc.gd)

The foundation of the NPC system with the following features:
- Input detection for clicking on NPCs
- Dialog tree management
- Suspicion tracking system
- Visual representation handling

### 2. Dialog Manager (src/core/dialog/dialog_manager.gd)

Manages the dialog UI and interaction flow with:
- Dialog panel creation and display
- Option handling and navigation
- Connection to NPCs for dialog signals

### 3. Game Manager (src/core/game/game_manager.gd)

Coordinates game elements:
- Manages verb selection
- Handles NPC clicks
- Controls player movement to NPCs
- Connects NPCs with dialog system

### 4. Example NPCs

- **Concierge** (src/characters/npc/concierge.gd): Unassimilated NPC with package quest
- **Security Officer** (src/characters/npc/security_officer.gd): Assimilated NPC with game over conditions

## Interaction Flow

1. Player selects a verb from the UI
2. Player clicks on an NPC
3. The game manager receives the click and calls the NPC's interact method
4. If "Talk to" was selected, the NPC starts a dialog
5. The dialog manager shows the dialog panel with text and options
6. The player selects dialog options, affecting suspicion and progressing the conversation
7. The dialog ends when reaching an end node or selecting "exit"

## Integration Notes

- The dialog UI is created dynamically at runtime
- NPCs find the dialog manager through the game manager
- Direct input detection is used for reliability
- Suspicion system is ready for expansion

## Next Steps

1. **Inventory Integration**: Connect package quest to inventory system
2. **Walkable Areas**: Improve player movement and pathing
3. **More NPCs**: Add NPCs for other districts
4. **Quest System**: Track quest progress and states
5. **Visual Improvements**: Replace placeholder graphics with pixel art

## Testing

The NPC interaction system can be tested by:
1. Selecting "Talk to" and clicking on an NPC
2. Navigating through dialog options
3. Testing suspicion changes with different dialog choices
4. Testing package exchange between NPCs
