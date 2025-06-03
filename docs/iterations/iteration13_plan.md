# Iteration 13: Complete Diegetic Audio System

## Epic Description
**Phase**: 2 - Full Systems  
**Cohesive Goal**: "I am immersed in a world where every sound has a source"

As a player, I want to experience a fully diegetic audio environment where all sounds originate from visible sources in the game world, with proper spatial positioning, distance attenuation, and integration with the perspective system, creating an immersive soundscape that reinforces the corporate banality and creeping dread of the space station.

## Goals
- Complete spatial audio implementation with stereo panning
- Implement full district audio system with transitions
- Create PA announcement system and audio zones
- Add audio-gameplay integration features
- Optimize performance with audio LOD system
- Establish audio content production pipeline

## Requirements

### Business Requirements
- **B1:** Create purely diegetic audio that enhances immersion
  - **Rationale:** In-world audio sources increase believability and atmosphere
  - **Success Metric:** All sounds have identifiable sources in the game world

- **B2:** Implement district-specific audio identities
  - **Rationale:** Unique soundscapes help distinguish areas and build atmosphere
  - **Success Metric:** Players can identify districts by their audio environment

- **B3:** Establish efficient audio content pipeline
  - **Rationale:** Streamlined workflow enables rapid content creation
  - **Success Metric:** New audio sources added in <15 minutes

### User Requirements
- **U1:** As a player, I want to locate sounds in the game world
  - **User Value:** Spatial audio aids navigation and creates immersion
  - **Acceptance Criteria:** Can identify sound direction and distance accurately

- **U2:** As a player, I want audio that reinforces the visual perspective
  - **User Value:** Audio-visual coherence enhances believability
  - **Acceptance Criteria:** Sounds scale appropriately with perspective changes

- **U3:** As a player, I want atmospheric audio that builds tension
  - **User Value:** Audio contributes to emotional experience
  - **Acceptance Criteria:** Silence and sound create appropriate mood

### Technical Requirements
- **T1:** Implement custom 2D stereo panning
  - **Rationale:** Godot 3.5.2 lacks built-in 2D panning
  - **Constraints:** Must work efficiently with 20+ sources

- **T2:** Create resource-based audio configuration
  - **Rationale:** Districts need flexible audio setups
  - **Constraints:** Must support hot-reloading for testing

- **T3:** Design performance-optimized audio system
  - **Rationale:** Many simultaneous sources impact performance
  - **Constraints:** Maintain 60 FPS with full audio

## Tasks

### Spatial Audio Completion (Phase 2)
- [ ] Task 1: Implement custom stereo panning system
- [ ] Task 2: Create distance attenuation curves
- [ ] Task 3: Add high-frequency rolloff for distance
- [ ] Task 4: Build visual debug overlay for audio ranges
- [ ] Task 5: Implement audio source priority system

### District Audio System (Phase 3)
- [ ] Task 6: Create DistrictAudioConfig resource class
- [ ] Task 7: Implement AudioSourceDefinition resources
- [ ] Task 8: Build district audio transition system
- [ ] Task 9: Create audio source spawning system
- [ ] Task 10: Design district-specific audio configurations

### PA System and Audio Zones
- [ ] Task 11: Implement PA announcement system
- [ ] Task 12: Create AudioZone area system
- [ ] Task 13: Add environmental reverb effects
- [ ] Task 14: Build audio event scheduling
- [ ] Task 15: Create announcement content system

### Audio-Gameplay Integration (Phase 4)
- [ ] Task 16: Connect audio to perspective scaling
- [ ] Task 17: Implement interactive audio objects
- [ ] Task 18: Create audio-based investigation clues
- [ ] Task 19: Add dynamic ambience system
- [ ] Task 20: Build tension through audio design

### Performance and Polish (Phase 5)
- [ ] Task 21: Implement audio LOD system
- [ ] Task 22: Create audio source pooling
- [ ] Task 23: Add audio occlusion system
- [ ] Task 24: Implement audio settings and saves
- [ ] Task 25: Build content production pipeline

### Audio Observation Features
- [ ] Task 26: Implement eavesdropping mechanics with audio cues
- [ ] Task 27: Create directional audio amplifier equipment
- [ ] Task 28: Add sound-based environmental observation
- [ ] Task 29: Implement conversation observation from distance

## User Stories

### Task 1: Implement custom stereo panning system
**User Story:** As a player, I want to hear sounds coming from the left or right based on their position relative to my character, so that I can locate audio sources spatially even without visual cues.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Sounds pan left/right based on horizontal position
  2. Panning is smooth and natural
  3. No audio artifacts or stuttering
  4. Works with all audio sources
  5. Configurable pan strength

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 4: Spatial Audio
- Use AudioBusLayout with custom script
- Apply pan values: left = -1.0, center = 0.0, right = 1.0
- Update pan based on relative position to camera/player
- Account for camera perspective changes

### Task 2: Create distance attenuation curves
**User Story:** As a player, I want sounds to fade naturally as I move away from their sources, so that the audio environment feels realistic and spatial.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Multiple curve types available
  2. Smooth volume falloff
  3. Configurable per source
  4. No abrupt cutoffs
  5. Performance efficient

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 4: Spatial Audio
- Curve types: Linear, Inverse, Exponential, Logarithmic
- Use AudioStreamPlayer.volume_db for smooth attenuation
- Max distance defines 0 volume point
- Custom curves via script for special cases

### Task 3: Add high-frequency rolloff for distance
**User Story:** As a player, I want distant sounds to lose their high frequencies naturally, so that audio behaves like real-world physics where treble attenuates first.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. High frequencies attenuate with distance
  2. Effect is subtle and natural
  3. Configurable per audio source
  4. No audio artifacts
  5. Performance optimized

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 4: Spatial Audio
- Use AudioEffectLowPassFilter on audio buses
- Cutoff frequency decreases with distance
- Formula: cutoff = base_freq * (1 - distance_ratio * rolloff_factor)
- Apply to district audio buses dynamically

### Task 4: Build visual debug overlay for audio ranges
**User Story:** As a developer, I want to visualize audio source ranges and attenuation, so that I can debug spatial audio issues and optimize placement.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Shows audio source positions and ranges
  2. Visualizes attenuation curves
  3. Color codes by audio type
  4. Toggle on/off for performance
  5. Clear visual representation

**Implementation Notes:**
- Create AudioDebugOverlay scene
- Use draw functions to show circles for ranges
- Color coding: Ambient (blue), SFX (red), Music (green), PA (yellow)
- Show current volume levels as circle opacity
- Debug menu integration

### Task 5: Implement audio source priority system
**User Story:** As a game designer, I want to prioritize important audio sources, so that critical sounds always play even when many sources compete for attention.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Priority levels affect audio processing
  2. High priority sounds never get culled
  3. Priority affects LOD calculations
  4. Configurable per audio type
  5. Performance impact minimized

**Implementation Notes:**
- Priority levels: Critical (4), High (3), Normal (2), Low (1), Background (0)
- Critical: Never culled, always full quality
- High: Reduced culling distance, better LOD
- Normal: Standard processing
- Low/Background: First to be optimized
- Use in AudioSourceDefinition resources

### Task 6: Create DistrictAudioConfig resource class
**User Story:** As a developer, I want a data-driven way to configure audio for each district, so that district-specific soundscapes can be easily created and modified.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Resource class extends Resource
  2. Configurable audio source lists
  3. Ambient sound definitions
  4. PA announcement settings
  5. Audio zone configurations

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 5: District Audio System
- Export variables for easy editing in Godot
- Support inheritance for base configurations
- Include validation for audio file paths
- Connect to district loading system

### Task 7: Implement AudioSourceDefinition resources
**User Story:** As a content creator, I want reusable audio source configurations, so that I can easily place consistent audio sources throughout the game world.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, T2
- **Acceptance Criteria:**
  1. Resource-based audio source configs
  2. Reusable across districts
  3. Easy to modify and update
  4. Supports all audio parameters
  5. Validation and error checking

**Implementation Notes:**
- Extend Resource class
- Properties: audio_stream, volume, pitch, attenuation_curve, priority
- Spatial properties: max_distance, rolloff_factor
- Behavioral: loop, autoplay, random_variations
- Integration with district spawning system

### Task 8: Build district audio transition system
**User Story:** As a player, I want smooth audio transitions when moving between districts, so that the soundscape changes feel natural and immersive.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Smooth crossfades between district audio
  2. Ambient sounds transition naturally
  3. No abrupt audio changes
  4. Configurable transition timing
  5. Handles overlapping audio zones

**Implementation Notes:**
- Use Tween nodes for volume crossfades
- Transition duration: 2-3 seconds typical
- Overlap zones near district boundaries
- Priority system for overlapping ambiences
- Integration with DistrictManager signals

### Task 9: Create audio source spawning system
**User Story:** As a developer, I want audio sources to spawn automatically based on district configuration, so that soundscapes are created without manual placement.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, T2
- **Acceptance Criteria:**
  1. Spawns sources from DistrictAudioConfig
  2. Positions sources based on rules
  3. Handles source lifecycle management
  4. Performance optimized spawning
  5. Runtime configuration updates

**Implementation Notes:**
- Connect to district loading events
- Spawn based on AudioSourceDefinition resources
- Positioning rules: fixed, random_in_area, along_path
- Pool audio players for performance
- Clean up when leaving district

### Task 10: Design district-specific audio configurations
**User Story:** As a player, I want each district to have its own unique soundscape, so that different areas of the station feel distinct and atmospheric.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Each district has unique audio identity
  2. Sounds reflect district purpose/theme
  3. Ambient levels create appropriate mood
  4. Audio supports narrative themes
  5. Consistent quality across districts

**Implementation Notes:**
- Spaceport: Ship engines, cargo movement, announcements
- Engineering: Machinery hum, computer beeps, ventilation
- Residential: Quiet conversations, domestic sounds, HVAC
- Commercial: Crowd noise, transaction sounds, advertisements
- Administrative: Office ambience, quiet efficiency, formal announcements

### Task 11: Implement PA announcement system
**User Story:** As station management, I want PA announcements to play throughout the station, so that information and atmosphere are conveyed to both NPCs and the player.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Scheduled announcements play automatically
  2. Emergency announcements can interrupt
  3. Announcements have proper audio processing
  4. Different zones can have different announcements
  5. NPCs react to announcements appropriately

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 6: PA System
- Audio processing: EQ, compression, slight distortion
- Connect to TimeManager for scheduling
- Priority system for emergency vs routine
- Integration with district audio zones

### Task 12: Create AudioZone area system
**User Story:** As a developer, I want to define audio zones within districts, so that different areas can have localized audio effects and announcements.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Area2D-based audio zone definition
  2. Zone-specific audio effects
  3. Smooth transitions between zones
  4. Hierarchical zone system
  5. Performance optimized

**Implementation Notes:**
- Extend Area2D for zone detection
- Zone types: Reverb, EQ, Volume, PA
- Overlap handling with priority system
- Connect to player position tracking
- AudioBus routing for zone effects

### Task 13: Add environmental reverb effects
**User Story:** As a player, I want sounds to have appropriate reverb based on the environment, so that small rooms sound intimate and large spaces feel expansive.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Reverb matches environment size
  2. Different reverb types for different spaces
  3. Smooth transitions between reverb zones
  4. Performance optimized
  5. Configurable per AudioZone

**Implementation Notes:**
- Use AudioEffectReverb on zone-specific buses
- Presets: Small Room, Large Room, Hall, Hangar, Outdoor
- Parameters: room_size, dampening, dry/wet mix
- Apply via AudioZone system
- Real-time parameter interpolation

### Task 14: Build audio event scheduling
**User Story:** As a game designer, I want to schedule audio events to occur at specific times, so that the station feels alive with timed activities and announcements.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Schedule events by time of day
  2. Support recurring events
  3. Emergency override capability
  4. Zone-specific scheduling
  5. Integration with game events

**Implementation Notes:**
- Connect to TimeManager for scheduling
- Event types: PA announcements, shift changes, maintenance
- Schedule format: time, frequency, zones, audio_source
- Priority system for emergency overrides
- Save/load scheduled events state

### Task 15: Create announcement content system
**User Story:** As a player, I want to hear varied PA announcements that reflect station life, so that the environment feels lived-in and authentic.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Variety of announcement types
  2. Context-appropriate content
  3. Dynamic announcement generation
  4. Appropriate frequency/timing
  5. Integration with game state

**Implementation Notes:**
- Announcement categories: Safety, Schedule, Maintenance, Emergency
- Template system for dynamic content
- Time-based announcements: shift changes, meal times
- Event-driven: security alerts, system maintenance
- Voice processing for PA effect

### Task 16: Connect audio to perspective scaling
**User Story:** As a player, I want audio to scale appropriately when the camera perspective changes, so that the audio matches the visual scale and maintains immersion.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U2, T1
- **Acceptance Criteria:**
  1. Audio volume scales with visual perspective
  2. Transitions are smooth during perspective changes
  3. Audio remains audible at all scales
  4. No audio artifacts during scaling
  5. Performance remains stable

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 4: Spatial Audio + Perspective Integration
- Connect to CameraManager perspective change signals
- Scale volume based on perspective: isometric (1.0), side-scrolling (0.8), top-down (0.6)
- Smooth transitions with Tween nodes
- Account for both camera zoom and perspective type

### Task 17: Implement interactive audio objects
**User Story:** As a player, I want to interact with audio-producing objects in the environment, so that I can control sounds and discover audio-based clues.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Clickable audio sources in world
  2. Audio responds to player interaction
  3. State changes affect audio output
  4. Integration with verb system
  5. Visual feedback for interactive sources

**Implementation Notes:**
- Extend InteractiveObject for audio sources
- Interactions: Turn On/Off, Adjust Volume, Change Channel
- State persistence across save/load
- Audio sources: Radios, PA speakers, machinery
- Visual indicators for interactive audio objects

### Task 18: Create audio-based investigation clues
**User Story:** As a player, I want to discover clues through careful listening, so that audio becomes part of the investigation gameplay.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Hidden audio contains investigation clues
  2. Listening skill affects clue discovery
  3. Audio clues integrate with investigation system
  4. Subtle audio changes indicate secrets
  5. Equipment can enhance audio detection

**Implementation Notes:**
- Integration with ObservationManager
- Audio clue types: Overheard conversations, machinery sounds, hidden recordings
- Skill-based detection: higher skill reveals more details
- Equipment bonuses: directional microphone
- Connect to investigation clue system

### Task 19: Add dynamic ambience system
**User Story:** As a player, I want the ambient soundscape to change based on events and time, so that the audio reflects the current state of the station.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B2, U3
- **Acceptance Criteria:**
  1. Ambience changes with game events
  2. Time of day affects ambient sounds
  3. Station condition influences audio
  4. Smooth transitions between states
  5. Performance remains stable

**Implementation Notes:**
- Connect to EventManager for state changes
- Ambience states: Normal, Alert, Emergency, Night
- Gradual transitions using crossfades
- Layered ambience system for complexity
- Integration with global game state

### Task 20: Build tension through audio design
**User Story:** As a player, I want audio to build tension and atmosphere, so that the creeping dread of the station is reinforced through sound.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Audio creates psychological tension
  2. Silence used effectively
  3. Subtle audio cues build unease
  4. Audio reflects story themes
  5. Player emotional response enhanced

**Implementation Notes:**
- Tension techniques: Silence, low frequencies, unexpected sounds
- Subliminal audio: barely audible whispers, mechanical irregularities
- Dynamic range: Quiet moments followed by sharp sounds
- Integration with story beats and discovery moments
- Audio reflects corporate banality becoming sinister

### Task 21: Implement audio LOD system
**User Story:** As a developer, I want audio to automatically optimize based on distance and importance, so that performance remains smooth with many audio sources.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Distant sounds automatically reduce quality
  2. Unimportant sounds can be culled
  3. Performance improves with many sources
  4. Quality transitions are imperceptible
  5. Important sounds always play

**Implementation Notes:**
- Reference: docs/design/audio_system_technical_implementation.md - Section 8: Performance Optimization
- LOD levels: High (full quality), Medium (reduced), Low (mono), Culled
- Distance thresholds: <10m (High), 10-25m (Medium), 25-50m (Low), >50m (Culled)
- Priority system overrides distance-based LOD
- Use AudioStreamPlayer.stream switching for quality levels

### Task 22: Create audio source pooling
**User Story:** As a developer, I want efficient audio source management, so that performance remains stable with many simultaneous audio sources.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Reuses AudioStreamPlayer nodes efficiently
  2. Reduces memory allocation
  3. Handles dynamic source creation
  4. Pool sizing based on needs
  5. Performance monitoring tools

**Implementation Notes:**
- Object pool pattern for AudioStreamPlayer nodes
- Pool categories: SFX (20), Ambience (10), Music (5)
- Automatic pool sizing based on usage
- Return to pool when audio finishes
- Debug tools for pool utilization

### Task 23: Add audio occlusion system
**User Story:** As a player, I want sounds to be muffled when blocked by walls or objects, so that audio behaves realistically in the environment.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Audio attenuates through walls
  2. Occlusion feels natural
  3. Performance impact minimized
  4. Different materials affect occlusion
  5. Real-time occlusion calculation

**Implementation Notes:**
- Raycast-based occlusion detection
- Material-based attenuation factors
- Low-pass filtering for muffled effect
- LOD system for distant sources
- Occlusion cache for performance

### Task 24: Implement audio settings and saves
**User Story:** As a player, I want to adjust audio settings to my preference and have them persist, so that I can customize my audio experience.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3
- **Acceptance Criteria:**
  1. Master, Music, SFX, Ambience volume controls
  2. Settings persist across sessions
  3. Real-time audio adjustment
  4. Reset to defaults option
  5. Integration with options menu

**Implementation Notes:**
- Master, Music, SFX, Ambience volumes
- Save to user settings
- Reference: docs/design/audio_system_technical_implementation.md - Section 7: Save/Load Integration
- Apply to audio buses
- Include in options menu

### Task 25: Build content production pipeline
**User Story:** As a content creator, I want streamlined tools for processing and importing audio assets with performance optimization, so that I can maintain consistent audio quality and quickly add new sounds to the game while meeting the performance targets of the optimization plan.

**Design Reference:** `docs/design/performance_optimization_plan.md` lines 37-41, 647-654

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** B3, T3
- **Acceptance Criteria:**
  1. Automated audio conversion scripts with performance-optimized settings
  2. Consistent naming conventions
  3. Import presets for different audio types
  4. Documentation for audio requirements
  5. Batch processing capabilities
  6. **Enhanced:** OGG Vorbis compression for music (128 kbps, 44.1 kHz sample rate)
  7. **Enhanced:** WAV format optimization for short SFX
  8. **Enhanced:** Streaming configuration for music tracks > 1 minute
  9. **Enhanced:** Audio quality validation against performance targets

**Implementation Notes:**
- Create process_game_audio.sh script
- Reference: docs/design/audio_system_technical_implementation.md - Audio Asset Pipeline
- Reference: docs/design/performance_optimization_plan.md - Section 1: Asset Optimization (Audio)
- Support conversions:
  - Music/Ambience: WAV → OGG Vorbis (128 kbps, 44.1 kHz)
  - SFX: Keep as WAV for short sounds
  - PA: Apply EQ and compression
  - **Enhanced:** Enable streaming for music tracks > 1 minute
  - **Enhanced:** Validate file sizes meet performance targets
- Include validation and error reporting
- **Enhanced:** Memory usage validation for audio assets
- **Enhanced:** Automated import preset application

### Task 26: Implement eavesdropping mechanics with audio cues
**User Story:** As a player, I want to overhear conversations from a distance using audio cues, so that I can gather information without being directly involved in conversations.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 36-43, 127-130

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. EAVESDROPPING observation type implementation
  2. Conversation audio range detection and attenuation
  3. Partial conversation text revealed based on distance and audio skill
  4. Risk calculation for being caught eavesdropping
  5. Integration with dialog system for overheard conversations
  6. Audio positioning indicates conversation source direction

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (EAVESDROPPING observation type)
- 10-second minimum observation duration for conversations
- Audio range depends on conversation volume and environment noise
- Skill progression improves comprehension at distance
- Being caught eavesdropping generates significant suspicion

### Task 27: Create directional audio amplifier equipment
**User Story:** As a player, I want specialized equipment that enhances my ability to hear distant conversations and sounds, so that I can gather audio intelligence from a safer distance.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 895-899

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U3, T1
- **Acceptance Criteria:**
  1. Directional microphone equipment item
  2. +0.4 observation bonus for audio-based observations
  3. 2x range multiplier for eavesdropping
  4. Reveals conversations, whispers, and mechanical sounds
  5. Visual UI indicator when audio amplifier is active
  6. Equipment integrates with spatial audio system

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (Audio Amplifier equipment lines 895-899)
- Equipment name: "Directional Microphone"
- Allows eavesdropping on conversations from greater distance
- Visual feedback shows amplified audio ranges
- Integration with existing equipment system

### Task 28: Add sound-based environmental observation
**User Story:** As a player, I want to detect environmental changes and hidden activities through audio cues, so that my hearing helps me discover things I cannot see.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 274-281 (ATMOSPHERIC)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Environmental audio observations include mechanical sounds, ventilation changes
  2. Hidden machinery or activity detectable through sound
  3. Audio-based clues about recent events (footsteps, equipment use)
  4. Integration with atmospheric observation system
  5. Sound observations logged and contribute to investigation

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (ATMOSPHERIC observation category)
- Examples: unusual ventilation sounds, machinery malfunction audio, distant activities
- Integration with district audio systems for environmental context
- Audio observations complement visual environmental observations
- Some sounds only audible with audio amplifier equipment

### Task 29: Implement conversation observation from distance
**User Story:** As a player, I want to observe NPCs having conversations from a safe distance, so that I can learn about their relationships and plans without directly interacting.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 36-43 (EAVESDROPPING)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U2, T1
- **Acceptance Criteria:**
  1. Long-range conversation observation (beyond normal interaction range)
  2. Visual observation of conversation participants and body language
  3. Partial audio eavesdropping depending on distance and equipment
  4. Risk management - closer observation provides more detail but higher detection risk
  5. Information gathered contributes to NPC relationship understanding

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (conversation observation mechanics)
- Combines visual observation of NPCs with audio eavesdropping
- Distance affects both visual and audio information quality
- Integration with NPC relationship and dialog systems
- Conversation topics revealed through observation contribute to clue discovery
## Testing Criteria
- Stereo panning accurately represents position
- District transitions are smooth and seamless
- PA announcements have appropriate processing
- Audio zones apply effects correctly
- Perspective scaling feels natural
- Performance maintains 60 FPS with many sources
- Audio LOD transitions are imperceptible
- Save/load preserves audio preferences
- Content pipeline produces consistent results

## Timeline
- Start date: After Iteration 12
- Target completion: 20-25 days (matching original estimate)
- Critical for: Complete atmospheric experience

## Dependencies
- Iteration 3 (Audio MVP foundation)
- Iteration 4 (District system)
- Iteration 9 (Core gameplay systems)
- All systems that generate audio events

## Code Links
- src/core/audio/audio_manager.gd (extend from Iteration 3)
- src/core/audio/diegetic_audio_controller.gd (extend from Iteration 3)
- src/core/audio/district_audio_config.gd (to be created)
- src/core/audio/audio_source_definition.gd (to be created)
- src/core/audio/audio_zone.gd (to be created)
- src/core/serializers/audio_serializer.gd (to be created)
- tools/process_game_audio.sh (to be created)
- docs/design/audio_system_technical_implementation.md
- docs/design/audio_system_iteration3_mvp.md

### Suspicion System Audio Integration
- [ ] Task 30: Create suspicion level audio cues
- [ ] Task 31: Implement investigation phase sound effects
- [ ] Task 32: Add district alert level ambient sounds
- [ ] Task 33: Create suspicion network propagation audio feedback
- [ ] Task 34: Implement performance optimization for time display
- [ ] Task 35: Create advanced accessibility features for time display
- [ ] Task 36: Develop debug and developer tools for time display

### Tram System Audio Integration
- [ ] Task 37: Create tram system audio integration
- [ ] Task 38: Implement assimilation-affected tram audio

### Task 30: Create suspicion level audio cues
**User Story:** As a player, I want to hear audio cues that indicate rising suspicion levels, so that I can react to threats even when focused on other UI elements.

**Design Reference:** `docs/design/suspicion_system_full_design.md`, `docs/design/audio_system_technical_implementation.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Distinct audio cues for each suspicion tier (none, low, medium, high, critical)
  2. Layered audio that builds intensity with suspicion level
  3. Spatial audio positioning for suspicious NPCs
  4. Audio cues integrate with diegetic audio system
  5. Volume scales with proximity to suspicious NPCs

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md (UI Components)
- Reference: docs/design/audio_system_technical_implementation.md (environmental audio)
- **Audio Cue Design:**
  - Low suspicion: subtle tension drones, barely perceptible
  - Medium: increased heartbeat effects, more prominent tension
  - High: sharp audio stingers, urgent musical cues
  - Critical: intense alarm-like sounds, maximum tension
- Use 3D audio positioning for individual NPC suspicion
- Layer multiple suspicion sources for cumulative effect
- Integrate with AudioZone system for district-wide ambience

### Task 31: Implement investigation phase sound effects
**User Story:** As a player, I want audio feedback during investigation events, so that formal investigations feel distinct and threatening.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Audio cues for investigation start/end events
  2. Ambient sound changes during active investigations
  3. Investigator footsteps and movement sounds
  4. Evidence discovery sound effects
  5. Different audio for investigation conclusions (guilty/innocent/inconclusive)

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 282-516 (Investigation System)
- **Investigation Audio Events:**
  - investigation_started: ominous musical sting
  - questioning phase: muffled interrogation sounds
  - evidence_gathering: rustling papers, typing sounds
  - investigation_concluded: resolution chord (major/minor based on outcome)
- Use DiegeticAudioController for realistic spatial audio
- Investigator NPCs have enhanced footstep audio
- Evidence discovery plays satisfying "clue found" audio

### Task 32: Add district alert level ambient sounds
**User Story:** As a player, I want each district's ambient audio to reflect the current security alert level, so that I can hear the station's tension level.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Alert levels 0-5 each have distinct ambient audio profiles
  2. District ambience changes smoothly with alert level transitions
  3. PA system announcements reflect current alert status
  4. Security equipment sounds increase with higher alert levels
  5. Civilian chatter becomes more nervous at higher alerts

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 645-692 (Security Alert Effects)
- **Alert Level Audio:**
  - Level 0 (Green): normal background ambience
  - Level 1 (Blue): subtle tension in background music
  - Level 2 (Yellow): increased security chatter, more frequent announcements
  - Level 3 (Orange): alarm tones, urgent PA announcements
  - Level 4 (Red): klaxons, evacuation sounds
  - Level 5 (Black): emergency sirens, lockdown audio
- Use DistrictAudioConfig to apply alert-specific audio mixes
- PA announcements become more frequent and urgent
- Security radio chatter increases with alert level

### Task 33: Create suspicion network propagation audio feedback
**User Story:** As a player, I want audio cues when suspicion spreads through NPC networks, so that I can hear gossip and information traveling between characters.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Audio cues for suspicion network formation and propagation
  2. Whisper sounds when NPCs share suspicion information
  3. Audio indicates direction and intensity of information flow
  4. Network propagation creates subtle environmental tension
  5. Group suspicion events have coordinated audio responses

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 152-198 (Network Propagation)
- **Network Audio Events:**
  - suspicion_network_formed: subtle connection sound
  - information spreading: layered whisper effects between NPCs
  - network propagation: audio "ping" traveling through social connections
  - group coordination: synchronized audio cues from multiple NPCs
- Use 3D audio to indicate direction of information flow
- Whisper audio positioned between communicating NPCs
- Network events create brief environmental tension spikes

### Task 34: Implement performance optimization for time display
**User Story:** As a developer, I want optimized performance for the time display system, so that constant time updates don't impact game performance and the system scales efficiently.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Update throttling implementation with configurable intervals
  2. Lazy loading for calendar data and event information
  3. Performance monitoring and metrics collection
  4. Memory efficient event storage and retrieval
  5. Frame-based update scheduling for smooth performance

**Implementation Notes:**
- Reference: docs/design/time_calendar_display_ui_design.md lines 487-516
- Update throttling: configurable update intervals (default 1 second)
- Lazy loading: only load calendar data when requested
- Performance metrics: track update times and memory usage
- Frame scheduling: distribute updates across multiple frames

### Task 35: Create advanced accessibility features for time display
**User Story:** As a player with accessibility needs, I want advanced accessibility features for the time display, so that I can use the interface comfortably regardless of my visual or motor capabilities.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1
- **Acceptance Criteria:**
  1. High visibility mode with enhanced contrast and larger fonts
  2. Screen reader support with comprehensive audio descriptions
  3. Keyboard navigation for all time display functions
  4. Configurable font sizes and color schemes
  5. Alternative input methods for time display interaction

**Implementation Notes:**
- Reference: docs/design/time_calendar_display_ui_design.md lines 449-482
- High visibility: 1.5x font scaling, high contrast colors, thick borders
- Screen reader: comprehensive text descriptions of all time information
- Keyboard navigation: full keyboard support for calendar expansion
- Accessibility text includes critical deadline information

### Task 36: Develop debug and developer tools for time display
**User Story:** As a developer, I want comprehensive debug tools for the time display system, so that I can diagnose issues and optimize performance during development.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Time manipulation debug tools for testing
  2. Event schedule viewer and editor
  3. Performance metrics display and analysis
  4. Time validation tools and consistency checks
  5. Debug overlay with real-time information

**Implementation Notes:**
- Reference: docs/design/time_calendar_display_ui_design.md lines 519-534
- Debug overlay: real-time performance metrics and system state
- Time manipulation: set time, advance time, schedule test events
- Event viewer: visual timeline of all scheduled events
- Validation tools: check for time inconsistencies and conflicts

### Task 37: Create tram system audio integration
**User Story:** As a player, I want to hear immersive tram station sounds and announcements, so that the transportation system feels like a real part of the living station.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (UI Components), `docs/design/audio_system_technical_implementation.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B2, U1
- **Acceptance Criteria:**
  1. Station announcement system with arrival/departure messages
  2. Tram arrival and departure sound effects
  3. Audio cues for transit events (delays, disruptions)
  4. Integration with dynamic audio based on corruption levels
  5. Ambient station sounds (crowds, machinery)

**Implementation Notes:**
- Reference: docs/design/tram_transportation_system_design.md (Transit Screen)
- Create announcement variations for each district
- Layer ambient sounds based on time of day and crowd levels
- Implement audio ducking during announcements
- Add positional audio for approaching/departing trams

### Task 38: Implement assimilation-affected tram audio
**User Story:** As a player, I want tram audio to reflect the station's assimilation state, so that I can sense the spreading corruption through atmospheric changes.

**Design Reference:** `docs/design/tram_transportation_system_design.md` (Assimilation Integration)

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Distorted announcements at high corruption levels
  2. Eerie ambient sounds during infected travel
  3. Audio warnings for dangerous routes
  4. Glitched/corrupted announcement effects
  5. Unsettling mechanical sounds on affected trams

**Implementation Notes:**
- Reference: docs/design/tram_transportation_system_design.md (lines 417-442)
- Apply audio distortion based on district corruption percentage
- Create procedural glitch effects for announcements
- Add subtle wrongness to mechanical sounds
- Implement creepy whispers or breathing in highly infected areas
- Scale audio corruption with AssimilationManager.get_station_corruption_level()

## Notes
- This iteration completes the audio system designed in the technical implementation document
- Builds directly on the MVP foundation from Iteration 3
- Focuses on purely diegetic audio - no UI sounds or non-world audio
- Performance optimization is critical with many simultaneous sources
- The system should enhance the atmosphere of corporate banality and creeping dread
- Suspicion audio integration creates an adaptive soundscape that responds to player actions