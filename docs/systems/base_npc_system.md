# Base NPC System Technical Reference

## Overview

This document provides a comprehensive technical reference for the NPC state machine and base behavior system in A Silent Refraction. The BaseNPC class serves as the foundation for all non-player characters, managing their state, appearance, interactions, and integration with other game systems.

## System Architecture

The NPC system is built around a central BaseNPC class with these key components:

1. **State Machine**: Controls NPC behavior states and transitions
2. **Suspicion System**: Tracks player interactions and NPC wariness
3. **Appearance Manager**: Handles visual representation based on state
4. **Interaction System**: Processes player verbs and actions 
5. **Observation System**: Allows player to detect assimilation status
6. **Dialog Integration**: Connects to the dialog system (see npc_dialog_system.md)

## BaseNPC Class Structure

### Properties

#### Identity Properties:
- `npc_name`: Display name of the NPC
- `description`: Short description shown with "Look at" verb
- `npc_id`: Unique identifier matching asset folder and registry
- `is_assimilated`: Whether NPC has been assimilated by aliens

#### Visual Components:
- `visual_sprite`: Sprite node showing NPC appearance
- `sprite_frames`: Dictionary of textures for different states
- `label`: Text label showing NPC name above sprite

#### State Machine:
- `current_state`: Current state from State enum
- State handler methods for each state

#### Suspicion System:
- `suspicion_level`: Float from 0.0 to 1.0
- Various threshold values for different suspicion tiers
- `suspicion_decay_rate`: How quickly suspicion falls over time
- `current_suspicion_tier`: Text label for current tier ("none" to "critical")

#### Observation System:
- `known_assimilated`: Whether player has discovered assimilation
- `observation_time`: Tracks observation duration
- `observation_threshold`: Time needed for detection

## State Machine

The BaseNPC implements a comprehensive state machine with these states:

```gdscript
enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}
```

### State Functions

For each state, the BaseNPC implements four types of functions:

1. **Entry functions**: `_on_enter_[state]_state()`
2. **Exit functions**: `_on_exit_[state]_state()`
3. **Process functions**: `_process_[state]_state(delta)`
4. **State transition**: `_change_state(new_state)`

### State Descriptions

#### IDLE
- Default state when not engaged
- Suspicion slowly decays over time
- Appearance based on suspicion tier and assimilation status
- NPC is ready for player interaction

#### INTERACTING
- Entered when player uses verbs other than "Talk to"
- Used for "Observe" functionality
- Suspicion decay is disabled
- Returns to IDLE when interaction completes

#### TALKING
- Entered when player uses "Talk to" verb
- Activates dialog system
- Suspicion decay is disabled
- Returns to IDLE when dialog ends

#### SUSPICIOUS
- Entered when suspicion reaches high threshold (0.8)
- NPC is wary of player
- Dialog options change to reflect suspicion
- Can progress to HOSTILE if suspicion increases further

#### HOSTILE
- Entered when suspicion reaches critical threshold (0.9)
- NPC may attack player or alert others
- Dialog options limited or impossible
- May trigger game over states

#### FOLLOWING
- Special state when NPC follows the player
- Custom path-finding behavior
- Suspicion decay is enabled but at a different rate
- Used for escort missions or specific quest stages

## State Transitions

State transitions occur through the `_change_state(new_state)` method, which:

1. Stores previous state
2. Updates current state
3. Calls exit function for previous state
4. Calls entry function for new state
5. Updates visual appearance
6. Emits state_changed signal

Common transitions include:
- IDLE → TALKING: Player selects "Talk to" verb
- TALKING → IDLE: Dialog ends
- IDLE → INTERACTING: Player selects non-dialog verb
- INTERACTING → IDLE: Interaction completes
- Any state → SUSPICIOUS: Suspicion reaches high threshold
- SUSPICIOUS → HOSTILE: Suspicion reaches critical threshold

## Suspicion System

The suspicion system tracks player interactions and NPC wariness:

### Suspicion Levels and Thresholds:
- Range: 0.0 to 1.0 (stored in `suspicion_level`)
- Thresholds:
  - `low_suspicion_threshold`: 0.3
  - `medium_suspicion_threshold`: 0.5
  - `high_suspicion_threshold`: 0.8 (triggers SUSPICIOUS state)
  - `critical_suspicion_threshold`: 0.9 (triggers HOSTILE state)

### Suspicion Tiers:
- "none" (< 0.3)
- "low" (0.3 - 0.5)
- "medium" (0.5 - 0.8)
- "high" (0.8 - 0.9)
- "critical" (> 0.9)

### Suspicion Management:
- `change_suspicion(amount)`: Changes suspicion level and triggers state changes
- `update_suspicion_tier()`: Updates the current tier based on level
- `react_to_suspicion_change(old_tier, new_tier)`: Handles responses to tier changes
- `suspicion_decay_enabled`: Whether suspicion should automatically decay
- `suspicion_decay_rate`: Speed of suspicion decay per second

### Actions Affecting Suspicion:
- Inappropriate verbs (e.g., "Push", "Use"): +0.1
- Certain dialog options: Variable amounts
- Continued observation: Small increase
- Talking about sensitive topics: Larger increase

## Assimilation System

The assimilation mechanic represents NPCs being taken over by aliens:

### Properties:
- `is_assimilated`: Boolean indicating assimilation status
- `known_assimilated`: Whether player has discovered this status

### Visual Changes:
- Assimilated NPCs use special textures or tinting
- Subtle green tint as fallback if texture unavailable
- Changes are subtle, requiring careful observation

### Gameplay Impact:
- Affects dialog text through transformation system
- Changes NPC behavior patterns
- Quest-critical for game progression
- Tracked in NPC registry for persistence

## Observation System

The observation system allows players to detect assimilation:

### Mechanism:
1. Player selects "Observe" verb on an NPC
2. NPC enters INTERACTING state
3. `observation_time` increments during observation
4. Detection probability increases with time
5. When `observation_threshold` is reached, detection is attempted
6. Success depends on probability and randomness
7. Results shown to player and saved to registry

### Detection Factors:
- Base probability from observation duration
- Enhanced probability if previously spoken with NPC
- Random element to maintain uncertainty
- Different detection details chosen randomly

## Interaction System

The interaction system processes player verbs:

### Implemented Verbs:
- "Look at": Shows description
- "Talk to": Enters TALKING state and starts dialog
- "Observe": Begins observation process
- "Use", "Pick up", "Push", "Pull", "Give": Increases suspicion

### Handling Process:
1. GameManager receives verb and NPC click
2. Calls NPC's `interact(verb, item = null)` method
3. NPC processes verb and updates state
4. Returns text result for UI display
5. May start dialog or observation process

## Visual Management

The BaseNPC handles its own visual representation:

### Setup:
- `_setup_visual()`: Creates sprite and label if not present
- `_load_sprite_textures()`: Loads textures from filesystem
- `_create_placeholder_texture()`: Fallback placeholder

### Update:
- `update_appearance()`: Updates based on state and suspicion
- `_use_fallback_appearance()`: Uses colored rectangles when textures unavailable

### Asset Structure:
- NPC textures stored in `/assets/characters/npcs/[npc_id]/`
- Standard states: normal, suspicious, hostile, assimilated

## NPC Registry Integration

NPCs connect to the NPC registry for data persistence:

### Registry Functions:
- `_load_from_registry()`: Loads NPC data at initialization
- `_find_npc_data_manager()`: Locates registry in scene tree

### Persistent Properties:
- Assimilation status
- Known assimilation status
- Suspicion level
- Custom properties for specific NPCs

## Input Handling

NPCs handle their own input detection:

### Methods:
- `_input(event)`: Processes mouse clicks
- `_is_point_in_clickable_area(point)`: Checks if click hits NPC
- `_on_ClickableArea_input_event()`: Area2D collision detection

### Process:
1. NPC detects click in its area
2. Finds GameManager in scene tree
3. Calls GameManager's `handle_npc_click(self)` method
4. GameManager processes verb and NPC

## Creating Custom NPCs

To create a new NPC with custom behavior:

1. Extend the BaseNPC class:
```gdscript
extends BaseNPC
class_name SecurityOfficer
```

2. Override `_ready()` to set properties:
```gdscript
func _ready():
    npc_name = "Security Officer"
    description = "A stern-looking security officer"
    ._ready() # Call parent ready
```

3. Override state process functions for custom behavior:
```gdscript
func _process_suspicious_state(delta):
    # Custom suspicious behavior
    if suspicion_level > 0.85 and is_assimilated:
        # Call for backup
        call_for_backup()
```

4. Override `initialize_dialog()` for custom dialog tree:
```gdscript
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Halt! Identification, please.",
            "options": [
                {"text": "I work here.", "next": "id_check", "suspicion_change": 0.1},
                {"text": "Sorry, I'll go.", "next": "exit", "suspicion_change": -0.1}
            ]
        },
        # ...more nodes
    }
```

5. Add custom methods as needed:
```gdscript
func call_for_backup():
    # Custom implementation
    emit_signal("backup_called", global_position)
    _change_state(State.HOSTILE)
```

## Testing NPCs

### Test Scenes:
- `./a_silent_refraction.sh test` - Loads npc_system_test.tscn
- `./a_silent_refraction.sh dialog` - Tests dialog integration

### Testing Process:
1. Test all verbs on the NPC
2. Test state transitions, especially suspicion-triggered ones
3. Test observation with assimilated and non-assimilated NPCs
4. Test dialog integration
5. Test custom behaviors for specific NPC types

## Debugging Tips

- Check console for state change messages
- Verify NPC is in both "npc" and "interactive_object" groups
- Check sprite paths match NPC ID structure
- Verify initialization of all required properties
- Test individual state functions in isolation
- Add debug visualization for suspicion level

## Future Enhancements

Planned improvements to the NPC system:

1. **Movement System**: Add pathfinding and navigation
2. **Animation Controller**: Add support for frame-based animations
3. **Behavior Tree**: Replace simple state machine with behavior trees
4. **Interaction Memory**: Track previous interactions across game sessions
5. **Group Behavior**: Allow NPCs to communicate and coordinate
6. **Time-based Behavior**: Change behaviors based on game time/events