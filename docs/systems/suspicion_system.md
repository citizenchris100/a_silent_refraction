# Suspicion System Technical Reference

## Overview

The suspicion system in A Silent Refraction is a core gameplay mechanic that creates tension and drives player decision-making. It represents how wary NPCs are of the player and impacts gameplay through dialog options, NPC behavior, and potential game over conditions. This document provides a comprehensive technical reference for the current implementation and future development directions.

## Current Architecture

The suspicion system is built around two main components:

1. **Individual NPC Suspicion** (implemented in `BaseNPC` class)
   - Tracks suspicion level per NPC (0.0 to 1.0)
   - Manages suspicion thresholds and state transitions
   - Handles suspicion decay over time

2. **Global Suspicion** (implemented in `SuspicionManager` and `GlobalSuspicionMeter`)
   - Calculates weighted average of all NPC suspicion levels
   - Provides station-wide alert level
   - Visualizes suspicion through UI

## Individual NPC Suspicion

### Properties

Individual NPCs track suspicion with these main properties:

```gdscript
var suspicion_level = 0.0  # Current suspicion (0.0 to 1.0)
var suspicion_threshold = 0.8  # Main threshold for becoming suspicious
var low_suspicion_threshold = 0.3
var medium_suspicion_threshold = 0.5
var high_suspicion_threshold = 0.8
var critical_suspicion_threshold = 0.9
var suspicion_decay_rate = 0.05  # Decay per second
var suspicion_decay_enabled = true
var current_suspicion_tier = "none"  # none, low, medium, high, critical
```

### Suspicion Tiers

NPCs move through different suspicion tiers:

1. **None** (< 0.3): NPC is not suspicious of player
2. **Low** (0.3 - 0.5): NPC is mildly wary but behaves normally
3. **Medium** (0.5 - 0.8): NPC shows signs of suspicion in dialog
4. **High** (0.8 - 0.9): NPC enters SUSPICIOUS state and behaves differently
5. **Critical** (> 0.9): NPC enters HOSTILE state, potentially triggering game over

### State Integration

Suspicion directly affects the NPC state machine:

```gdscript
enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}
```

- When suspicion reaches the high threshold (0.8), NPC transitions to SUSPICIOUS state
- When suspicion reaches the critical threshold (0.9), NPC transitions to HOSTILE state
- State changes modify dialog options and NPC behavior

### Suspicion Management

Functions managing suspicion include:

- `change_suspicion(amount)`: Modifies suspicion level and may trigger state changes
- `update_suspicion_tier()`: Updates the current tier based on suspicion level
- `react_to_suspicion_change(old_tier, new_tier)`: Handles responses to tier changes

### Current Implementation Limitations

1. All NPCs use the same thresholds, not accounting for character personality
2. Limited visual indicators of suspicious behavior beyond dialog
3. No relationship between suspicion and NPC's assimilation status
4. Simple time-based decay rather than context-aware decay

## Global Suspicion System

### SuspicionManager Implementation

The `SuspicionManager` handles station-wide suspicion:

```gdscript
var global_suspicion_level = 0.0
var npc_suspicion_weights = {}
var tracked_npcs = {}
```

Key functions:

- `track_npc(npc)`: Adds an NPC to tracking
- `set_npc_weight(npc, weight)`: Sets importance of NPC in global calculation
- `calculate_global_suspicion()`: Computes weighted average
- `set_global_suspicion(value)`: Updates value and emits signal

### GlobalSuspicionMeter Implementation

The UI representation of global suspicion:

```gdscript
var suspicion_level = 0.0
var meter_fill  # Visual representation
```

Features:

- Color-coded visual feedback (green, yellow, red)
- Optional percentage display
- Customizable label

### Current Implementation Limitations

1. No direct gameplay consequences for global suspicion levels
2. All NPCs have equal weight by default
3. Limited integration with security systems
4. No district-specific suspicion levels

## Future Development Direction

Based on the Game Design Document and Iteration Plans, the suspicion system will evolve in these directions:

### Iteration 2 Tasks (In Progress)

1. **Full Suspicion Tracking System** (Task 4)
   - Complete weighted global suspicion
   - Add persistence between scenes
   - Integrate with save/load system

2. **Enhanced NPC Reactions** (Task 5)
   - Script more detailed suspicion-based behaviors
   - Add suspicious dialog variations
   - Implement reporting behavior for hostile NPCs

3. **Observation Mechanics** (Task 8)
   - Allow player to detect assimilated NPCs through observation
   - Tie observation success to suspicion levels
   - Balance risk/reward of observation attempts

### Iteration 3 Integrations

1. **Time-Based Suspicion Evolution**
   - Suspicion decreases overnight
   - Persistent suspicion for key story NPCs
   - Time-based reporting of suspicious activity

2. **District-Based Suspicion**
   - Security districts have higher surveillance
   - Different suspicion thresholds per district
   - Suspicion spreading between NPCs in the same area

### Iteration 4 Enhancements

1. **Investigation Impact**
   - Finding evidence affects suspicion
   - Using evidence in dialog creates suspicion
   - Tracking known assimilated NPCs

### Iteration 5 Advancements

1. **Trust/Mistrust Mechanics**
   - Recruited NPCs have trust level counterbalancing suspicion
   - Failed recruitment increases suspicion station-wide
   - Coalition strength affects global suspicion level

## Technical Implementation Roadmap

### Phase 1: Complete Current System

1. Implement remaining Iteration 2 suspicion tasks
2. Add visual cues for suspicious NPCs
3. Create appropriate reactions in conversation
4. Balance suspicion generation rates

### Phase 2: Enhanced Individual Suspicion

1. Add NPC personality factors affecting suspicion
2. Implement memory of suspicious actions
3. Create special dialog paths for suspicious NPCs
4. Add suspicion "cooldown" rather than linear decay

### Phase 3: Environmental Factors

1. Add security cameras that increase suspicion
2. Create "safe zones" with lower suspicion generation
3. Add time-of-day factors affecting suspicion
4. Implement district security levels

### Phase 4: Advanced Global Mechanics

1. Create security response teams at high suspicion
2. Implement lockdowns at critical suspicion
3. Add faction-based suspicion spreading
4. Create suspicion dynamics between assimilated and unassimilated NPCs

## Gameplay Design Principles

The suspicion system adheres to these core principles:

1. **Tension with Fairness**: The system creates tension without feeling arbitrary
2. **Observable Feedback**: Players receive clear feedback on suspicious actions
3. **Strategic Choices**: Players make meaningful decisions to manage suspicion
4. **Recovery Possibility**: High suspicion can be reduced through gameplay
5. **Consistent Logic**: Suspicion follows a consistent and learnable logic

## Testing Guidelines

When testing the suspicion system, verify:

1. Suspicion increases correctly based on player actions
2. Visual feedback accurately represents suspicion levels
3. NPC behavior changes appropriately at threshold points
4. Global suspicion calculation properly weighs all NPCs
5. Suspicion decay works as expected during idle periods
6. Dialog options change based on suspicion tiers

## Documentation Update Plans

This document will be updated as the suspicion system evolves through iterations to maintain a comprehensive technical reference. Each major feature implementation will be documented here for future iterations.

## Integration with Other Systems

The suspicion system integrates with:

1. **Dialog System**: Suspicion affects available dialog options
2. **NPC State Machine**: Suspicion triggers state transitions
3. **Global Alert**: Station-wide response to player actions
4. **Assimilation Detection**: Risk/reward of identifying assimilated NPCs
5. **Quest System**: Missions affected by suspicion level