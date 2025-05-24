# Audio System Technical Implementation

**Status: 📋 DESIGN**  
**Created: May 23, 2025**

## Executive Summary

This document outlines the technical implementation approach for A Silent Refraction's diegetic audio system using Godot 3.5.2's built-in capabilities. The system creates an immersive soundscape where all audio originates from in-world sources, with proper spatial positioning, distance attenuation, and integration with the perspective scaling system.

## Implementation Strategy

The audio system will be implemented in two major phases:

1. **Iteration 3 MVP** (Foundational Groundwork) - See `audio_system_iteration3_mvp.md`
   - Core architecture (AudioManager singleton, basic components)
   - Basic diegetic audio with distance attenuation
   - Integration with perspective scaling system
   - Single district support (no transitions yet)

2. **Iteration 9 Full Implementation** (Complete System)
   - All features described in this document
   - District transitions and multi-district support
   - Advanced spatial audio with stereo panning
   - Environmental effects and audio zones
   - Production pipeline and content tools

## Godot 3.5.2 Audio Capabilities

### Built-in Audio Features

Godot 3.5.2 provides robust audio capabilities that align well with our diegetic audio requirements:

1. **AudioStreamPlayer2D**: Perfect for positional audio in 2D space
   - Automatic distance-based attenuation
   - Configurable max_distance and attenuation curves
   - Area-based audio masking capabilities

2. **Audio Buses**: Powerful mixing and effects system
   - Multiple buses for different audio categories
   - Real-time effects (reverb, delay, distortion, etc.)
   - Dynamic bus routing for environmental effects

3. **AudioStreamPlayer**: Non-positional audio for UI/system sounds
   - Good for PA announcements that should be heard everywhere

4. **Resource System**: Audio streams as resources
   - OGG Vorbis support (recommended for music/ambience)
   - WAV support (for short sound effects)
   - Seamless looping capabilities

### What We Need to Build

While Godot provides excellent foundations, we need to implement:

1. **Stereo Panning**: Godot 3.5.2's AudioStreamPlayer2D doesn't have built-in stereo panning
2. **Dynamic Audio Source Management**: System to track and update multiple audio sources
3. **District-based Audio Configuration**: Different audio profiles per area
4. **Integration with Perspective Scaling**: Volume adjustments based on visual scale

## Architecture Overview

```
AudioSystem
├── AudioManager (Singleton)
│   ├── Manages audio buses
│   ├── Handles district transitions
│   ├── Controls global audio state
│   └── Provides audio debugging
├── DiegeticAudioController (Component)
│   ├── Extends AudioStreamPlayer2D
│   ├── Implements stereo panning
│   ├── Integrates with perspective system
│   └── Handles dynamic volume/effects
├── DistrictAudioConfig (Resource)
│   ├── Ambient track definitions
│   ├── Music source configurations
│   ├── Environmental effect presets
│   └── Audio zone definitions
└── AudioZone (Area2D)
    ├── Defines audio influence areas
    ├── Applies environmental effects
    └── Triggers audio events
```

## Implementation Details

### 1. Audio Bus Configuration

First, we need to set up a comprehensive bus structure in Godot's Audio tab:

```
Master
├── Music
│   ├── Mall_Music
│   ├── Spaceport_Music
│   ├── Medical_Music
│   └── [Other District Music]
├── Ambience
│   ├── Mall_Ambience
│   ├── Spaceport_Ambience
│   ├── Engineering_Ambience
│   └── [Other District Ambience]
├── SFX
│   ├── Doors
│   ├── Machinery
│   ├── UI_Sounds
│   └── Environmental
└── Announcements
    └── PA_System
```

### 2. AudioManager (Singleton)

Located at: `src/core/audio/audio_manager.gd`

```gdscript
extends Node

# Singleton pattern
static var instance = null

# Audio configuration
const MUSIC_FADE_TIME = 2.0
const AMBIENCE_FADE_TIME = 3.0
const MAX_AUDIO_SOURCES = 32

# Current audio state
var current_district_config: DistrictAudioConfig = null
var active_music_sources = []
var active_ambience_sources = []
var listener_position = Vector2.ZERO
var listener_scale = 1.0

# Audio buses
var music_buses = {}
var ambience_buses = {}

func _ready():
    if instance == null:
        instance = self
        _initialize_buses()
    else:
        queue_free()

func _initialize_buses():
    # Cache bus indices for performance
    music_buses = {
        "mall": AudioServer.get_bus_index("Mall_Music"),
        "spaceport": AudioServer.get_bus_index("Spaceport_Music"),
        "medical": AudioServer.get_bus_index("Medical_Music"),
        # Add other districts
    }
    
    ambience_buses = {
        "mall": AudioServer.get_bus_index("Mall_Ambience"),
        "spaceport": AudioServer.get_bus_index("Spaceport_Ambience"),
        "engineering": AudioServer.get_bus_index("Engineering_Ambience"),
        # Add other districts
    }

func set_district_audio(config: DistrictAudioConfig):
    if current_district_config:
        _fade_out_district(current_district_config)
    
    current_district_config = config
    _fade_in_district(config)

func update_listener(position: Vector2, scale: float = 1.0):
    listener_position = position
    listener_scale = scale
    
    # Update all active audio sources
    var all_sources = get_tree().get_nodes_in_group("diegetic_audio")
    for source in all_sources:
        if source.has_method("update_for_listener"):
            source.update_for_listener(position, scale)

func _fade_out_district(config: DistrictAudioConfig):
    # Fade out music
    for source in active_music_sources:
        _fade_audio_source(source, 0.0, MUSIC_FADE_TIME)
    
    # Fade out ambience
    for source in active_ambience_sources:
        _fade_audio_source(source, 0.0, AMBIENCE_FADE_TIME)

func _fade_in_district(config: DistrictAudioConfig):
    # Clear previous sources after fade
    yield(get_tree().create_timer(max(MUSIC_FADE_TIME, AMBIENCE_FADE_TIME)), "timeout")
    _clear_audio_sources()
    
    # Create new audio sources from config
    _create_district_audio_sources(config)

func _fade_audio_source(source: AudioStreamPlayer2D, target_volume: float, duration: float):
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(source, "volume_db", 
        source.volume_db, linear2db(target_volume), duration,
        Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_all_completed")
    tween.queue_free()
```

### 3. DiegeticAudioController (Enhanced)

Located at: `src/core/audio/diegetic_audio_controller.gd`

```gdscript
extends AudioStreamPlayer2D
class_name DiegeticAudioController

# Audio configuration
export var base_volume_db = 0.0
export var audio_type = "music"  # music, ambience, sfx
export var loop_seamlessly = true
export var randomize_start_position = false

# Spatial configuration
export var min_distance = 100.0
export var max_distance = 1000.0
export var attenuation_curve: Curve

# Stereo panning (since Godot 3.5 doesn't have it built-in)
export var enable_stereo_panning = true
export var pan_width = 800.0  # Pixels from center for full pan

# Perspective integration
export var scale_affects_volume = true
export var scale_volume_curve: Curve

# Internal state
var target_volume_db = 0.0
var current_pan = 0.0
var audio_bus_index = -1

func _ready():
    add_to_group("diegetic_audio")
    
    # Set up audio bus based on type and district
    _setup_audio_bus()
    
    # Configure AudioStreamPlayer2D settings
    max_distance = max_distance
    attenuation = AudioStreamPlayer2D.ATTENUATION_INVERSE_DISTANCE
    
    # Start playing if configured
    if stream and autoplay:
        if randomize_start_position:
            seek(randf() * stream.get_length())
        play()

func _setup_audio_bus():
    var district_name = _get_current_district_name()
    var bus_name = district_name + "_" + audio_type.capitalize()
    
    audio_bus_index = AudioServer.get_bus_index(bus_name)
    if audio_bus_index >= 0:
        bus = bus_name
    else:
        push_warning("Audio bus not found: " + bus_name)

func update_for_listener(listener_pos: Vector2, listener_scale: float = 1.0):
    # Calculate distance-based volume
    var distance = global_position.distance_to(listener_pos)
    var distance_factor = _calculate_distance_factor(distance)
    
    # Apply perspective scaling if enabled
    if scale_affects_volume and scale_volume_curve:
        var scale_factor = scale_volume_curve.interpolate(listener_scale)
        distance_factor *= scale_factor
    
    # Calculate final volume
    target_volume_db = base_volume_db + linear2db(distance_factor)
    volume_db = target_volume_db
    
    # Calculate and apply stereo panning
    if enable_stereo_panning:
        _apply_stereo_panning(listener_pos)
    
    # Stop distant sounds to save performance
    if distance > max_distance * 1.5 and playing:
        stop()
    elif distance <= max_distance and not playing and stream:
        play()

func _calculate_distance_factor(distance: float) -> float:
    if distance <= min_distance:
        return 1.0
    elif distance >= max_distance:
        return 0.0
    
    # Normalize distance to 0-1 range
    var normalized = (distance - min_distance) / (max_distance - min_distance)
    
    # Apply custom curve or default inverse
    if attenuation_curve:
        return attenuation_curve.interpolate(1.0 - normalized)
    else:
        return 1.0 - normalized

func _apply_stereo_panning(listener_pos: Vector2):
    # Calculate horizontal offset from listener
    var offset_x = global_position.x - listener_pos.x
    
    # Normalize to -1 to 1 range
    current_pan = clamp(offset_x / pan_width, -1.0, 1.0)
    
    # Apply panning using audio bus effects
    if audio_bus_index >= 0:
        # Get or create panner effect on bus
        var panner = _get_or_create_panner_effect()
        if panner:
            panner.pan = current_pan

func _get_or_create_panner_effect() -> AudioEffectPanner:
    # Check if panner already exists on bus
    var effect_count = AudioServer.get_bus_effect_count(audio_bus_index)
    
    for i in range(effect_count):
        var effect = AudioServer.get_bus_effect(audio_bus_index, i)
        if effect is AudioEffectPanner:
            return effect
    
    # Create new panner effect
    var panner = AudioEffectPanner.new()
    AudioServer.add_bus_effect(audio_bus_index, panner)
    return panner

func _get_current_district_name() -> String:
    # Find parent district node
    var parent = get_parent()
    while parent:
        if parent.has_method("get_district_name"):
            return parent.get_district_name().to_lower()
        parent = parent.get_parent()
    
    return "default"
```

### 4. DistrictAudioConfig (Resource)

Located at: `src/core/audio/district_audio_config.gd`

```gdscript
extends Resource
class_name DistrictAudioConfig

# Music configuration
export var music_sources = []  # Array of AudioSourceDefinition
export var music_volume_base = 0.0
export var music_reverb_amount = 0.0

# Ambience configuration  
export var ambience_sources = []  # Array of AudioSourceDefinition
export var ambience_volume_base = -6.0
export var ambience_low_pass_cutoff = 5000.0

# Environmental effects
export var enable_reverb = true
export var reverb_room_size = 0.8
export var reverb_damping = 0.5
export var reverb_wet = 0.3

# Audio zones
export var audio_zones = []  # Array of AudioZoneDefinition

# Transition settings
export var fade_in_time = 2.0
export var fade_out_time = 3.0

# Special audio events
export var pa_announcements = []  # Array of announcement audio streams
export var pa_announcement_interval = Vector2(120, 300)  # Random interval in seconds
```

### 5. AudioSourceDefinition (Resource)

Located at: `src/core/audio/audio_source_definition.gd`

```gdscript
extends Resource
class_name AudioSourceDefinition

# Audio stream
export var stream: AudioStream
export var volume_offset = 0.0

# Positioning
export var position = Vector2.ZERO
export var position_randomness = 0.0

# Spatial properties
export var min_distance = 100.0
export var max_distance = 1000.0
export var enable_panning = true

# Playback properties
export var loop = true
export var autoplay = true
export var randomize_start = false

# Visual representation (for debugging)
export var source_name = "Audio Source"
export var source_color = Color.white
```

### 6. Implementation for Mixing Music and Ambience

The two-track approach (music + ambience) you mentioned is implemented through:

1. **Separate Audio Buses**: Music and ambience use different buses with independent volume controls and effects chains

2. **Layer Management**: The AudioManager maintains separate arrays for music and ambience sources

3. **Dynamic Mixing**: Volume relationships can be adjusted based on game state

Example district audio setup:

```gdscript
# res://src/districts/mall/mall_audio_config.tres
[gd_resource type="Resource" script_class="DistrictAudioConfig"]

[sub_resource type="Resource" id=1]
script = ExtResource("audio_source_definition.gd")
stream = ExtResource("mall_muzak_loop.ogg")
position = Vector2(400, 300)
min_distance = 200.0
max_distance = 1200.0
source_name = "Mall Speaker 1"

[sub_resource type="Resource" id=2]
script = ExtResource("audio_source_definition.gd")
stream = ExtResource("crowd_chatter_loop.ogg")
volume_offset = -12.0
position = Vector2(600, 400)
min_distance = 150.0
max_distance = 800.0
source_name = "Crowd Ambience"

[resource]
music_sources = [SubResource(1)]
ambience_sources = [SubResource(2)]
music_volume_base = -6.0
ambience_volume_base = -12.0
enable_reverb = true
reverb_room_size = 0.9
reverb_wet = 0.4
```

### 7. Spatial Audio Implementation Details

For proper spatial audio without external dependencies:

```gdscript
# Enhanced spatial calculations in DiegeticAudioController

func calculate_3d_position_from_2d(pos_2d: Vector2, listener_pos: Vector2) -> Vector3:
    # Convert 2D position to pseudo-3D for audio calculations
    var relative_pos = pos_2d - listener_pos
    
    # X remains the same (left/right)
    # Y in 2D becomes Z in 3D (front/back)
    # Y in 3D is always 0 (height)
    return Vector3(relative_pos.x, 0, relative_pos.y)

func apply_distance_effects(distance: float):
    # Beyond basic attenuation, add:
    
    # 1. High-frequency rolloff for distant sounds
    if audio_bus_index >= 0:
        var eq = _get_or_create_eq_effect()
        if eq and distance > min_distance:
            var rolloff_factor = (distance - min_distance) / (max_distance - min_distance)
            eq.set_band_gain_db(2, -20 * rolloff_factor)  # High frequencies
    
    # 2. Subtle delay for very distant sounds
    if distance > max_distance * 0.7:
        var delay = _get_or_create_delay_effect()
        if delay:
            delay.tap1_active = true
            delay.tap1_delay_ms = 50 * (distance / max_distance)
            delay.tap1_level_db = -12
```

### 8. Performance Optimization

```gdscript
# Audio LOD system in AudioManager

var audio_update_timer = 0.0
const AUDIO_UPDATE_INTERVAL = 0.1  # Update audio 10 times per second

func _process(delta):
    audio_update_timer += delta
    if audio_update_timer >= AUDIO_UPDATE_INTERVAL:
        audio_update_timer = 0.0
        _update_audio_sources()

func _update_audio_sources():
    # Sort sources by distance for LOD
    var sources_by_distance = []
    
    for source in get_tree().get_nodes_in_group("diegetic_audio"):
        var dist = source.global_position.distance_to(listener_position)
        sources_by_distance.append({"source": source, "distance": dist})
    
    sources_by_distance.sort_custom(self, "_sort_by_distance")
    
    # Update only nearest sources frequently
    var updated = 0
    for item in sources_by_distance:
        if updated < 10:  # Update nearest 10 sources
            item.source.update_for_listener(listener_position, listener_scale)
            updated += 1
        elif updated < 20 and Engine.get_frames_drawn() % 3 == 0:
            # Update next 10 sources every 3rd frame
            item.source.update_for_listener(listener_position, listener_scale)
            updated += 1
        # Distant sources update rarely
```

## Audio Asset Pipeline

### Recommended Audio Formats

1. **Music/Ambience Loops**: 
   - Format: OGG Vorbis
   - Quality: 128-192 kbps
   - Channels: Stereo (will be mixed to mono positionally)
   - Sample Rate: 44.1 kHz

2. **Sound Effects**:
   - Format: WAV for short sounds, OGG for longer
   - Quality: 16-bit, 44.1 kHz
   - Channels: Mono (for positional audio)

3. **PA Announcements**:
   - Format: OGG Vorbis
   - Quality: 96-128 kbps (can be lower quality for "radio" effect)
   - Processing: Pre-apply compression and EQ for PA sound

### Audio Processing Script

```bash
#!/bin/bash
# process_game_audio.sh

# Convert and optimize audio for the game

# Function to process music/ambience
process_loop() {
    input="$1"
    output="$2"
    
    ffmpeg -i "$input" \
        -c:a libvorbis -q:a 6 \
        -ar 44100 \
        -ac 2 \
        -metadata LOOPSTART=0 \
        -metadata LOOPLENGTH=-1 \
        "$output"
}

# Function to process PA announcements
process_pa() {
    input="$1"
    output="$2"
    
    # Apply compression, EQ, and slight distortion for PA effect
    ffmpeg -i "$input" \
        -af "highpass=f=400,lowpass=f=3000,acompressor=threshold=0.5:ratio=4:attack=5:release=50" \
        -c:a libvorbis -q:a 4 \
        -ar 44100 \
        -ac 1 \
        "$output"
}

# Example usage
process_loop "raw_audio/mall_music.wav" "game_audio/mall_muzak_loop.ogg"
process_pa "raw_audio/lockdown_announcement.wav" "game_audio/pa_lockdown.ogg"
```

## Testing and Debug Tools

### Audio Debug Overlay

```gdscript
# src/core/debug/audio_debug_overlay.gd
extends Control

var debug_enabled = false

func _ready():
    if OS.is_debug_build():
        debug_enabled = true

func _draw():
    if not debug_enabled:
        return
    
    # Draw audio source positions and ranges
    var sources = get_tree().get_nodes_in_group("diegetic_audio")
    for source in sources:
        var screen_pos = get_viewport().canvas_transform * source.global_position
        
        # Draw range circles
        draw_circle(screen_pos, source.min_distance * get_viewport().canvas_transform.get_scale().x, 
                   Color(0, 1, 0, 0.2))
        draw_circle(screen_pos, source.max_distance * get_viewport().canvas_transform.get_scale().x, 
                   Color(1, 1, 0, 0.1))
        
        # Draw source info
        draw_string(get_font("default"), screen_pos + Vector2(10, -10),
                   "%s\nVol: %.1f dB\nPan: %.2f" % [source.source_name, source.volume_db, source.current_pan],
                   Color.white)
```

## Phased Implementation Plan

**Note**: This plan describes the full implementation to be completed in Iteration 9. For the Iteration 3 MVP implementation, see `audio_system_iteration3_mvp.md`.

### Phase 1: Foundation and Basic Audio (3-4 days) 
*[Partially completed in Iteration 3 MVP]*

**Objective**: Establish core audio infrastructure and basic playback

**MVP vs Full Implementation:**
- ✅ **MVP (Iteration 3)**: Basic AudioManager, simple bus hierarchy, basic DiegeticAudioController
- ⏳ **Full (Iteration 9)**: Complete bus structure, district switching, fade functionality, unit tests

**Tasks**:
1. **Day 1: Audio Bus Setup**
   - ✅ *[MVP]* Create basic audio bus hierarchy (Music, Ambience, SFX)
   - ⏳ *[Full]* Expand to district-specific buses
   - ⏳ *[Full]* Configure detailed effects chains
   - ⏳ *[Full]* Document complete bus routing structure

2. **Day 2: Core Singleton Implementation**
   - ✅ *[MVP]* Implement basic AudioManager singleton
   - ⏳ *[Full]* Add district audio switching
   - ⏳ *[Full]* Implement fade in/out functionality
   - ⏳ *[Full]* Write unit tests for audio transitions

3. **Day 3-4: Basic Audio Source Controller**
   - ✅ *[MVP]* Create basic DiegeticAudioController with distance attenuation
   - ⏳ *[Full]* Add advanced spatial features
   - ✅ *[MVP]* Implement basic looping and volume control
   - ✅ *[MVP]* Test with placeholder audio files

**Deliverables**:
- Working audio bus system
- AudioManager singleton with basic functionality
- Simple audio playback in test scene
- Unit tests for core functionality

### Phase 2: Spatial Audio and 2D Positioning (4-5 days)

**Objective**: Implement distance-based attenuation and basic spatial audio

**Tasks**:
1. **Day 1-2: Distance Attenuation**
   - Implement distance calculations in DiegeticAudioController
   - Add attenuation curves support
   - Create visual debug tools for audio ranges
   - Test with multiple audio sources

2. **Day 3: Stereo Panning Implementation**
   - Add AudioEffectPanner to appropriate buses
   - Implement horizontal position-based panning
   - Create panning curve system
   - Test stereo field with moving player

3. **Day 4-5: Integration Testing**
   - Test spatial audio with player movement
   - Verify multiple simultaneous sources
   - Performance profiling with various source counts
   - Bug fixes and optimization

**Deliverables**:
- Fully spatial audio system
- Working stereo panning
- Debug visualization tools
- Performance benchmarks

### Phase 3: District Audio System (3-4 days)

**Objective**: Create district-specific audio configurations and transitions

**Tasks**:
1. **Day 1: Resource System Setup**
   - Create DistrictAudioConfig resource class
   - Create AudioSourceDefinition resource class
   - Design resource inspector interfaces
   - Create example configurations

2. **Day 2-3: District Integration**
   - Modify BaseDistrict to support audio configs
   - Implement smooth district audio transitions
   - Create audio source spawning system
   - Test with multiple districts

3. **Day 4: Content Creation Tools**
   - Create audio configuration templates
   - Build district audio preset library
   - Document audio setup workflow
   - Create batch audio processing scripts

**Deliverables**:
- Complete district audio system
- Configuration resources for each district
- Smooth audio transitions between areas
- Content creation documentation

### Phase 4: Audio-Gameplay Integration (4-5 days)

**Objective**: Integrate audio with game mechanics and perspective system

**Tasks**:
1. **Day 1-2: Perspective Scaling Integration**
   - Connect audio volume to visual perspective scale
   - Implement scale-based frequency filtering
   - Test with perspective scaling system
   - Tune audio-visual correlation

2. **Day 3: Interactive Audio Elements**
   - Implement player-controlled audio sources (radios, etc.)
   - Create audio-based puzzle framework
   - Add audio interaction to verb system
   - Test interactive audio gameplay

3. **Day 4-5: Suspicion and Atmosphere**
   - Create assimilation-based audio distortion
   - Implement dynamic ambience system
   - Add silence as gameplay element
   - Create tension through audio design

**Deliverables**:
- Perspective-aware audio system
- Interactive audio objects
- Atmosphere control system
- Audio-based gameplay mechanics

### Phase 5: Polish and Optimization (3-4 days)

**Objective**: Optimize performance and polish audio experience

**Tasks**:
1. **Day 1: Performance Optimization**
   - Implement audio LOD system
   - Add source pooling for efficiency
   - Optimize update frequencies
   - Profile on target hardware

2. **Day 2: Effects and Polish**
   - Implement environmental reverb zones
   - Add dynamic range compression
   - Create audio ducking system
   - Polish transition timings

3. **Day 3-4: Testing and Bug Fixes**
   - Comprehensive audio testing
   - Fix edge cases and bugs
   - Balance audio levels across game
   - Create audio settings menu

**Deliverables**:
- Optimized audio system
- Polished audio experience
- Settings and configuration UI
- Performance documentation

### Phase 6: Content Production Pipeline (2-3 days)

**Objective**: Establish sustainable audio content workflow

**Tasks**:
1. **Day 1: Audio Asset Pipeline**
   - Create audio conversion scripts
   - Set up naming conventions
   - Build import automation
   - Document asset requirements

2. **Day 2-3: Audio Library Setup**
   - Organize placeholder audio library
   - Create audio style guide
   - Document replacement workflow
   - Build audio testing checklist

**Deliverables**:
- Complete audio pipeline
- Asset organization system
- Style and technical guidelines
- Testing procedures

## Implementation Milestones and Risk Mitigation

### Critical Milestones

1. **Milestone 1** (End of Phase 1): Basic audio playback functional
   - Risk: Audio latency issues
   - Mitigation: Early performance testing

2. **Milestone 2** (End of Phase 2): Spatial audio complete
   - Risk: Stereo panning complexity in Godot 3.5
   - Mitigation: Fallback to simplified panning if needed

3. **Milestone 3** (End of Phase 3): District system operational
   - Risk: Memory usage with multiple audio sources
   - Mitigation: Source pooling and LOD system

4. **Milestone 4** (End of Phase 4): Gameplay integration complete
   - Risk: Audio-visual synchronization issues
   - Mitigation: Tight integration with perspective system

### Testing Strategy

**Unit Tests** (throughout all phases):
- Audio bus configuration validation
- Distance calculation accuracy
- Fade timing verification
- Resource loading tests

**Integration Tests** (Phases 2-4):
- Multi-source spatial accuracy
- District transition smoothness
- Performance under load
- Memory leak detection

**Playtesting Focus** (Phases 4-5):
- Audio clarity and balance
- Spatial perception accuracy
- Atmospheric effectiveness
- Performance on min spec

## Resource Requirements

### Audio Assets Needed

**Phase 1-2** (Placeholder):
- 3-5 music loops (generic muzak style)
- 3-5 ambience loops (crowd, machinery, office)
- Basic UI sounds
- Test announcement clips

**Phase 3-4** (Prototype):
- District-specific music (1-2 per district)
- District ambience layers
- Interactive object sounds
- PA announcement set

**Phase 5-6** (Production):
- Full music library
- Complete ambience suite
- All SFX variations
- Voice acting for PA

### Technical Resources

- Godot 3.5.2 documentation
- Audio processing software (Audacity, etc.)
- Performance profiling tools
- Test hardware (min spec machine)

## Serialization and Save System Integration

Following the modular architecture from `docs/design/modular_serialization_architecture.md`, the audio system implements its own serializer to handle persistent audio state. This ensures audio settings and preferences survive save/load cycles without coupling to the core save system.

### Persistent Audio State

The AudioSerializer handles:
- **Volume Settings**: Master, music, SFX, and ambience levels per player preference
- **Mute States**: Which audio categories the player has disabled
- **Current Music/Ambience**: Active tracks per district (restart from beginning on load)
- **PA Announcement State**: Last announcement time and queue position
- **Audio Debug Settings**: Whether audio visualization is enabled

### Implementation

```gdscript
# src/core/serializers/audio_serializer.gd
extends BaseSerializer

class_name AudioSerializer

func _ready():
    # Low priority - audio preferences can load after gameplay
    SaveManager.register_serializer("audio", self, 60)

func serialize() -> Dictionary:
    return {
        "volume_settings": {
            "master": AudioServer.get_bus_volume_db(0),
            "music": AudioManager.get_bus_group_volume("music"),
            "ambience": AudioManager.get_bus_group_volume("ambience"),
            "sfx": AudioManager.get_bus_group_volume("sfx"),
            "announcements": AudioManager.get_bus_group_volume("announcements")
        },
        "mute_states": AudioManager.get_mute_states(),
        "current_tracks": {
            "music": AudioManager.current_music_id,
            "ambience": AudioManager.current_ambience_id,
            "district": AudioManager.current_district_name
        },
        "pa_state": {
            "last_announcement_time": AudioManager.last_pa_time,
            "announcement_index": AudioManager.current_pa_index
        },
        "debug_enabled": AudioManager.debug_visualization_enabled
    }

func deserialize(data: Dictionary) -> void:
    # Restore volume settings
    if "volume_settings" in data:
        for bus_name in data.volume_settings:
            AudioManager.set_bus_volume(bus_name, data.volume_settings[bus_name])
    
    # Restore mute states
    if "mute_states" in data:
        AudioManager.restore_mute_states(data.mute_states)
    
    # Note: We don't restore track positions - audio restarts fresh
    # This prevents sync issues and provides consistent experience
    
    # Restore PA timing
    if "pa_state" in data:
        AudioManager.last_pa_time = data.pa_state.last_announcement_time
        AudioManager.current_pa_index = data.pa_state.announcement_index
    
    # Restore debug state
    if "debug_enabled" in data:
        AudioManager.debug_visualization_enabled = data.debug_enabled

func get_version() -> int:
    return 1

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    # Future: Handle audio system upgrades
    return data
```

### Design Decisions

1. **No Position Saving**: Audio tracks restart rather than resume from saved positions
   - Prevents synchronization issues with ambience/music
   - Simpler implementation with better reliability
   - Consistent experience on load

2. **Preference Persistence**: Player audio preferences always persist
   - Volume levels are critical for accessibility
   - Mute states must be respected across sessions

3. **Debug State**: Audio debug visualization persists for development
   - Helps developers maintain context across sessions
   - Can be stripped in release builds

This approach ensures the audio system integrates cleanly with saves while maintaining its independence and avoiding common audio state bugs.

## Success Criteria

The audio system will be considered successful when:

1. **Technical Success**:
   - All audio is purely diegetic with clear in-world sources
   - Spatial positioning feels natural and accurate
   - Performance maintains 60 FPS with 20+ audio sources
   - District transitions are smooth and atmospheric

2. **Design Success**:
   - Audio reinforces the corporate banality aesthetic
   - Silence and sound create appropriate tension
   - Players can identify audio source locations
   - Audio enhances rather than distracts from gameplay

3. **Implementation Success**:
   - System is maintainable and extensible
   - Content pipeline is efficient
   - Audio bugs are minimal
   - Team can easily add new audio content

## Implementation Timeline Summary

### Iteration 3 (Current) - MVP Foundation
- **Duration**: 3-4 days within Task 31
- **Scope**: Core architecture, basic diegetic audio, perspective integration
- **Deliverables**: Working foundation ready for extension

### Iteration 9 - Full Audio System
- **Duration**: 20-25 days total
- **Scope**: Complete implementation of all features in this document
- **Prerequisites**: District system from Iteration 4

This staged approach ensures:
1. Early audio integration enhances Iteration 3's immersion goals
2. No throwaway work - everything builds on the MVP foundation
3. Complex features wait until supporting systems (districts) exist
4. Testing and refinement happen throughout development

## Conclusion

This implementation leverages Godot 3.5.2's built-in audio capabilities while adding custom functionality for stereo panning, perspective integration, and dynamic audio management. The system is designed to be performant, maintainable, and provide the immersive diegetic audio experience that reinforces the game's atmosphere of corporate banality and creeping dread.

The two-track approach (music + ambience) provides a good balance between audio richness and performance, while the spatial audio system ensures sounds feel properly positioned in the game world. The architecture is modular and extensible, allowing for easy addition of new audio sources and effects as development progresses.

The phased implementation plan ensures steady progress with clear milestones and risk mitigation strategies, while maintaining focus on the core design pillar of purely diegetic audio that enhances the game's unique atmosphere.