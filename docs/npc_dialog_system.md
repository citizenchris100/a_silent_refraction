# NPC Dialog System Technical Reference

## Overview

This document provides a comprehensive technical reference for the NPC dialog and interaction system implemented in A Silent Refraction. It covers architecture, implementation details, and integration with other systems.

## System Architecture

The dialog system consists of three main components working together:

1. **BaseNPC** (`src/characters/npc/base_npc.gd`) - Manages dialog trees, NPC state, and suspicion
2. **DialogManager** (`src/core/dialog/dialog_manager.gd`) - Handles UI display and user input
3. **GameManager** (`src/core/game/game_manager.gd`) - Coordinates interactions and systems

### Communication Flow

```
Player Input → GameManager → BaseNPC → DialogManager → UI Display → Player Choice
     ↑                          ↓           ↑
     └───────←────────←─────────┴───────←───┘
```

## Dialog Tree Structure

Dialog trees are stored as dictionaries with the following format:

```gdscript
dialog_tree = {
    "node_id": {
        "text": "NPC dialog text goes here.",
        "options": [
            {
                "text": "Player response option 1",
                "next": "next_node_id",
                "suspicion_change": 0.1  # Optional
            },
            {
                "text": "Player response option 2",
                "next": "different_node_id"
            }
        ]
    },
    "next_node_id": {
        "text": "NPC's next response",
        "options": [...]
    },
    "exit": {
        "text": "Goodbye.",
        "options": []  # Empty options ends the dialog
    }
}
```

### Key Components:

- **node_id**: Unique identifier for each dialog state
- **text**: The NPC's dialog that will be displayed to the player
- **options**: Array of player response choices
- **next**: The next node_id to navigate to when this option is selected
- **suspicion_change**: Optional value that affects NPC's suspicion level

## NPC State Machine

The NPC state machine directly affects dialog behavior:

```
enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}
```

State transitions:
- `IDLE` → `TALKING`: Triggered by "Talk to" verb or click
- `TALKING` → `IDLE`: Occurs when dialog ends
- `IDLE/TALKING` → `SUSPICIOUS`: Occurs when suspicion reaches high threshold
- `SUSPICIOUS` → `HOSTILE`: Occurs when suspicion reaches critical threshold

## BaseNPC Dialog Functions

### Core Functions:

1. **initialize_dialog()** - Sets up the NPC's dialog tree. Override in child classes.
2. **start_dialog()** - Begins dialog with the NPC, starting at "root" node.
3. **end_dialog()** - Terminates dialog and emits signal.
4. **get_current_dialog()** - Returns the current dialog node data.
5. **choose_dialog_option(option_index)** - Processes player's choice and advances dialog.
6. **transform_dialog_for_assimilation(original_text)** - Modifies text if NPC is assimilated.
7. **update_dialog_for_suspicion()** - Updates dialog options based on suspicion level.

### Dialog-State Integration:

- Dialog is automatically started when entering TALKING state
- Dialog is automatically ended when exiting TALKING state
- Dialog options can trigger state changes via suspicion

## Suspicion System

The suspicion system tracks NPC wariness of the player:

### Suspicion Levels and Thresholds:
- Range: 0.0 to 1.0 (stored in `suspicion_level`)
- Thresholds:
  - low: 0.3
  - medium: 0.5
  - high: 0.8 (triggers SUSPICIOUS state)
  - critical: 0.9 (triggers HOSTILE state)

### Suspicion Tiers:
- "none" (< 0.3)
- "low" (0.3 - 0.5)
- "medium" (0.5 - 0.8)
- "high" (0.8 - 0.9)
- "critical" (> 0.9)

### Suspicion Integration with Dialog:
- Dialog options can specify `suspicion_change` values
- State changes can occur during conversation
- Available dialog options update through `update_dialog_for_suspicion()`
- Visual appearance changes with suspicion level

## Assimilation System

The assimilation mechanic represents NPCs being taken over by aliens:

### Properties:
- `is_assimilated`: Boolean indicating assimilation status
- `known_assimilated`: Whether player has discovered this status

### Text Transformation:
When an NPC is assimilated, their dialog undergoes these transformations:

1. **Formality changes**: Contractions expanded (don't → do not)
2. **Pronoun shifts**: I/my → we/our (subtle hive mind indicators)
3. **Vocabulary shifts**: Normal terms → technical/formal terms
4. **Speech anomalies**: Occasional word repetition, unusual pauses

### Observation Feature:
- Activated with "Observe" verb
- Requires watching NPC for `observation_threshold` seconds
- Detection probability increases with observation time
- Returns different detection details based on random factors
- Updates `known_assimilated` status in NPC registry

## Dialog Manager Implementation

The DialogManager handles UI presentation and user interaction:

### UI Components:
- `dialog_panel`: Container for dialog elements
- `dialog_text`: Label displaying NPC dialog
- `dialog_options`: Container for clickable option buttons

### Key Functions:
- `_create_dialog_ui()`: Dynamically creates UI elements
- `_connect_to_npcs()`: Connects to signals from all NPCs
- `show_dialog(npc)`: Displays dialog for a specific NPC
- `_on_dialog_option_selected(option_index)`: Handles player choices

## Interaction Flow

Complete interaction sequence:

1. Player selects "Talk to" verb from UI (or clicks NPC directly)
2. GameManager calls NPC's `interact()` method with "Talk to" verb
3. NPC changes to TALKING state, which calls `start_dialog()`
4. NPC emits `dialog_started` signal
5. DialogManager catches signal, calls `show_dialog(npc)`
6. DialogManager displays current dialog node content
7. Player clicks dialog option
8. DialogManager calls NPC's `choose_dialog_option(option_index)`
9. NPC processes choice, updates suspicion, and returns next dialog
10. Dialog continues until reaching "exit" node or empty options
11. NPC calls `end_dialog()` and emits `dialog_ended` signal
12. DialogManager hides UI and NPC returns to IDLE state

## Implementation Examples

### Basic Dialog Example:
```gdscript
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Hello there.",
            "options": [
                {"text": "Hello.", "next": "greeting"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "greeting": {
            "text": "How can I help you?",
            "options": [
                {"text": "Just looking around.", "next": "looking"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "looking": {
            "text": "Feel free to look around.",
            "options": [
                {"text": "Thanks.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Goodbye.",
            "options": []
        }
    }
```

### Suspicion-Affected Dialog:
```gdscript
func update_dialog_for_suspicion():
    # Modify dialog based on suspicion tier
    if current_suspicion_tier == "high" or current_suspicion_tier == "critical":
        # Replace standard greeting with suspicious version
        dialog_tree["root"]["text"] = "What do you want? You're acting strange."
        dialog_tree["root"]["options"] = [
            {"text": "Nothing, sorry.", "next": "exit", "suspicion_change": -0.1},
            {"text": "Just checking on you.", "next": "suspicious_check", "suspicion_change": 0.1}
        ]
        
        # Add new suspicious dialog nodes
        dialog_tree["suspicious_check"] = {
            "text": "I don't believe you. Are you working with them?",
            "options": [
                {"text": "With who?", "next": "exit", "suspicion_change": 0.2},
                {"text": "I'm just doing my job.", "next": "exit", "suspicion_change": -0.1}
            ]
        }
```

## Creating New NPCs

To create a new NPC with dialog:

1. Extend the BaseNPC class
2. Override initialize_dialog() with custom dialog tree
3. Override update_dialog_for_suspicion() for dynamic responses
4. Connect to relevant signals (dialog_started, dialog_ended)
5. Set up custom state behavior as needed

Example:
```gdscript
extends BaseNPC
class_name SecurityOfficer

func _ready():
    npc_name = "Security Officer"
    description = "A stern-looking security officer"
    ._ready() # Call parent ready

func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Halt! Identification, please.",
            "options": [
                {"text": "I work here.", "next": "id_check", "suspicion_change": 0.1},
                {"text": "Sorry, I'll go.", "next": "exit", "suspicion_change": -0.1}
            ]
        },
        "id_check": {
            "text": "I don't recognize you. What department?",
            "options": [
                {"text": "Administration.", "next": "admin_response"},
                {"text": "Engineering.", "next": "eng_response"}
            ]
        },
        # ...more dialog nodes
    }
```

## Example NPCs

The project includes several implemented NPCs:

- **Concierge** (`src/characters/npc/concierge.gd`): Unassimilated NPC with package quest
- **Security Officer** (`src/characters/npc/security_officer.gd`): Assimilated NPC with game over conditions
- **Bank Teller** (`src/characters/npc/bank_teller.gd`): NPC showcasing dialog system functionality

## Testing the Dialog System

Test scenes and commands:
- `./a_silent_refraction.sh dialog` - Opens dedicated dialog test scene
- `./a_silent_refraction.sh test` - Tests full NPC system with multiple characters

Test for:
1. Dialog navigation working correctly
2. Suspicion changes affecting dialog options
3. Assimilation text transformation 
4. Dialog starting/ending properly
5. UI displaying correctly

## Future Enhancements

Planned improvements:
1. **Inventory Integration**: Connect dialog options to inventory items
2. **Quest System**: Track dialog-based quest progress 
3. **Dialog Memory**: Track previous conversations across game sessions
4. **Dialog Conditions**: Allow for more complex dialog option requirements
5. **Voice/Sound Integration**: Add sound effects or voice indicators

## Debugging Tips

- NPCs print debug messages when connecting to the dialog system
- Check the console for "Connected dialog system to NPC: [name]" messages
- Verify NPCs are in both "npc" and "interactive_object" groups
- Check that NPCs have unique npc_id values matching their folder names
- Verify dialog trees contain all referenced node_ids
- Ensure all dialog options have valid "next" values