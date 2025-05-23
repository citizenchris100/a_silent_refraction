# Audio System - Iteration 3 MVP (Foundational Groundwork)

**Status: 📋 DESIGN**  
**Target: Iteration 3, Task 31**  
**Created: May 23, 2025**

## Overview

This document defines the minimal viable audio foundation to be implemented in Iteration 3. This is NOT throwaway work - every component built here will be part of the final audio system. We're implementing the core architecture and basic functionality that can be extended in later iterations.

## Scope for Iteration 3

### What We'll Build

1. **Core Audio Architecture**
   - AudioManager singleton (basic version)
   - Audio bus hierarchy setup
   - File/directory structure

2. **Basic Diegetic Audio Component**
   - DiegeticAudioController (simplified)
   - Distance-based volume attenuation
   - Integration with perspective scaling system

3. **Single District Audio**
   - Basic audio setup for current test scenes
   - No district transitions (not available yet)
   - Simple ambient loops and position-based sounds

4. **Integration with Existing Systems**
   - Connect to perspective scaling (Task 29-30)
   - Basic debug visualization
   - Player position tracking for audio

### What We'll Defer

- District audio transitions (wait for Iteration 4)
- Complex spatial panning
- PA announcement system
- Audio zones and environmental effects
- Production audio pipeline
- Interactive audio objects

## Implementation Plan for Iteration 3

### Phase 1: Core Structure (1-2 days)

**1. Directory Structure**
```
src/
├── core/
│   └── audio/
│       ├── audio_manager.gd
│       └── diegetic_audio_controller.gd
└── assets/
    └── audio/
        ├── test/
        │   ├── ambience/
        │   └── music/
        └── placeholder/
```

**2. Basic AudioManager Singleton**
```gdscript
# src/core/audio/audio_manager.gd
extends Node

static var instance = null

# Basic configuration
var listener_position = Vector2.ZERO
var listener_scale = 1.0

func _ready():
    if instance == null:
        instance = self
    else:
        queue_free()

func update_listener(position: Vector2, scale: float = 1.0):
    listener_position = position
    listener_scale = scale
    
    # Update all audio sources
    var sources = get_tree().get_nodes_in_group("diegetic_audio")
    for source in sources:
        if source.has_method("update_for_listener"):
            source.update_for_listener(position, scale)
```

**3. Audio Bus Setup**
```
Master
├── Music
├── Ambience
└── SFX
```

### Phase 2: Basic Diegetic Audio (1-2 days)

**1. Simplified DiegeticAudioController**
```gdscript
# src/core/audio/diegetic_audio_controller.gd
extends AudioStreamPlayer2D
class_name DiegeticAudioController

export var base_volume_db = 0.0
export var min_distance = 100.0
export var max_distance = 1000.0

# Perspective integration
export var scale_affects_volume = true

func _ready():
    add_to_group("diegetic_audio")
    
    # Configure AudioStreamPlayer2D
    max_distance = max_distance
    attenuation = AudioStreamPlayer2D.ATTENUATION_INVERSE_DISTANCE
    
    if stream and autoplay:
        play()

func update_for_listener(listener_pos: Vector2, listener_scale: float = 1.0):
    var distance = global_position.distance_to(listener_pos)
    
    # Basic distance attenuation
    if distance > max_distance * 1.5 and playing:
        stop()
    elif distance <= max_distance and not playing and stream:
        play()
    
    # Simple scale influence
    if scale_affects_volume:
        var scale_factor = lerp(0.5, 1.0, listener_scale)
        volume_db = base_volume_db * scale_factor
```

### Phase 3: Test Scene Integration (1 day)

**1. Audio Test Scene**
- Create `src/test/audio_foundation_test.tscn`
- Place 3-4 DiegeticAudioController nodes
- Test with camera movement
- Verify perspective scaling integration

**2. Integration Points**
- Modify player controller to update AudioManager
- Add audio debug info to existing debug overlay
- Test with sprite scaling scenes

### Phase 4: Basic Content (1 day)

**1. Placeholder Audio**
- 2-3 ambient loops (machinery, crowd, office)
- 1-2 music loops (generic muzak)
- Document format requirements

**2. Basic Testing**
- Verify audio plays and stops correctly
- Test distance attenuation
- Confirm perspective scaling affects volume
- Performance validation

## Architecture Alignment

This MVP implementation:
- ✅ Follows the singleton pattern for AudioManager
- ✅ Uses component-based design for audio sources
- ✅ Integrates with existing systems (perspective, camera)
- ✅ Maintains separation of concerns
- ✅ Is fully extensible for future phases

## Success Criteria for Iteration 3

1. AudioManager singleton functional and integrated
2. Basic diegetic audio sources working with distance attenuation
3. Audio responds to perspective scaling
4. Test scene demonstrates spatial audio
5. Foundation ready for future expansion

## Future Expansion Plan

### Iteration 4 Extension (+2-3 days)
When districts are implemented:
- Add district audio configuration
- Implement audio transitions
- Create per-district audio buses

### Iteration 5: Full Audio System (5-7 days)
Complete implementation including:
- Stereo panning
- Environmental effects
- PA announcements
- Audio zones
- Interactive audio objects
- Production pipeline

This ensures we build a solid foundation in Iteration 3 without overcommitting, while keeping everything aligned with the comprehensive plan.