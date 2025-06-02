# Iteration 16: Advanced Visual Systems

## Epic Description
As a developer, I want to implement advanced visual systems that create depth, atmosphere, and polish, ensuring the game's visual presentation matches its sophisticated gameplay systems.

## Cohesive Goal
**"The game world feels deep, atmospheric, and visually polished"**

## Overview
This new iteration focuses on advanced visual features that enhance immersion and atmosphere. These systems create visual depth through perspective scaling, foreground occlusion, and atmospheric effects that make the space station feel like a real, lived-in environment.

## Goals
- Implement sprite perspective scaling for depth perception
- Create foreground occlusion system for layered environments
- Add holographic and heat distortion shader effects
- Implement CRT screen effects for terminals
- Polish animation systems for smooth movement
- Create atmospheric visual effects

## Requirements

### Business Requirements
- Visual quality that stands out in the adventure game market
- Performance-efficient visual effects
- Consistent art style across all visual systems
- Support for multiple display resolutions

### User Requirements
- Characters scale naturally with distance
- Foreground objects create believable depth
- Visual effects enhance sci-fi atmosphere
- Smooth, polished animations
- Clear visual feedback for interactions

### Technical Requirements
- Efficient sprite scaling algorithms
- Layered rendering system for occlusion
- Optimized shader implementation
- Animation state machine polish
- Resolution-independent rendering

## Tasks

### Visual Systems
- [ ] Task 1: Sprite Perspective Scaling System
- [ ] Task 2: Foreground Occlusion System
- [ ] Task 3: Holographic Shader Effects
- [ ] Task 4: Heat Distortion Effects
- [ ] Task 5: CRT Screen Effects
- [ ] Task 6: Animation System Polish
- [ ] Task 7: Atmospheric Visual Effects
- [ ] Task 8: Advanced Occlusion Features

### Performance Optimization
- [ ] Task 9: Rendering Pipeline Optimizations
- [ ] Task 10: Platform-Specific Rendering Optimizations

### Debug Save Tools
- [ ] Task 11: Create debug save commands (force_save, corrupt_save, analyze_save)
- [ ] Task 12: Implement save file analyzer tool
- [ ] Task 13: Add save performance profiler
- [ ] Task 14: Create save state inspector UI

## User Stories

### 1. Sprite Perspective Scaling System
**Priority:** High  
**Estimated Hours:** 16

**Description:**  
Implement dynamic sprite scaling based on Y-position to create convincing depth perception in 2D environments.

**User Story:**  
*As a player, I want characters and objects to appear smaller when they're further away, so that the 2D world feels three-dimensional and believable.*

**Design Reference:** `docs/design/sprite_perspective_scaling_plan.md`, `docs/design/sprite_perspective_scaling_full_plan.md`

**Acceptance Criteria:**
- [ ] Smooth scaling based on Y-position
- [ ] Configurable scaling curves per scene
- [ ] Proper sprite sorting for depth
- [ ] Integration with movement system
- [ ] Performance optimized for multiple sprites
- [ ] **Enhanced:** Implement ScalingZoneManager for zone-based scaling
- [ ] **Enhanced:** Create DistrictPerspectiveConfig resource system
- [ ] **Enhanced:** PerspectiveController component for all scalable entities
- [ ] **Enhanced:** Integration with multi-perspective character system

**Dependencies:**
- Player controller (Iteration 2)
- NPC system (Iteration 2)
- District system (Iteration 8)

**Implementation Notes:**
- Reference: docs/design/sprite_perspective_scaling_full_plan.md lines 107-242 (Zone-based System)
- Implement core components: ScalingZoneManager, ZoneDetector, PerspectiveController
- Create district-specific configuration resources
- Ensure smooth transitions between zones

### 2. Foreground Occlusion System
**Priority:** High  
**Estimated Hours:** 20

**Description:**  
Create system for foreground objects to properly occlude characters and create layered depth.

**User Story:**  
*As a player, I want to walk behind foreground objects naturally, so that the environment feels layered and three-dimensional.*

**Design Reference:** `docs/design/foreground_occlusion_mvp_plan.md`, `docs/design/foreground_occlusion_full_plan.md`, `docs/design/sprite_perspective_scaling_full_plan.md`

**Acceptance Criteria:**
- [ ] Dynamic occlusion based on Y-position
- [ ] Smooth transitions at occlusion boundaries
- [ ] Support for complex occlusion shapes
- [ ] Editor tools for occlusion setup
- [ ] Minimal performance impact
- [ ] **Enhanced:** Integration with sprite perspective scaling for depth consistency
- [ ] **Enhanced:** Foreground objects scale appropriately with perspective zones
- [ ] **Enhanced:** Occlusion respects ScalingZoneManager boundaries

**Dependencies:**
- Sprite scaling system (this iteration)
- District system (Iteration 8)
- Camera system (Iteration 1)

**Implementation Notes:**
- Reference: docs/design/sprite_perspective_scaling_full_plan.md lines 1036-1050 (Foreground Integration)
- Ensure foreground occlusion layers work with perspective scaling
- Apply consistent scaling to foreground elements
- Maintain proper depth sorting with scaled sprites

### 3. Holographic Shader Effects
**Priority:** Medium  
**Estimated Hours:** 12

**Description:**  
Implement holographic shader for UI elements, NPCs, and environmental objects to enhance sci-fi atmosphere.

**User Story:**  
*As a player, I want holographic displays and characters to shimmer and distort realistically, so that the futuristic setting feels authentic.*

**Design Reference:** `src/shaders/hologram.shader` (listed in Links to Relevant Code)

**Acceptance Criteria:**
- [ ] Scanline and glitch effects
- [ ] Color aberration and transparency
- [ ] Animated distortion patterns
- [ ] Configurable intensity levels
- [ ] Performance-efficient implementation

**Dependencies:**
- UI system (Iteration 3)
- NPC system (Iteration 2)

### 4. Heat Distortion Effects
**Priority:** Medium  
**Estimated Hours:** 10

**Description:**  
Create heat distortion shader for environmental effects like engines, vents, and atmospheric processors.

**User Story:**  
*As a player, I want to see heat shimmer from hot surfaces, so that the environment feels more realistic and alive.*

**Design Reference:** `src/shaders/heat_distortion.shader` (listed in Links to Relevant Code)

**Acceptance Criteria:**
- [ ] Realistic heat wave distortion
- [ ] Configurable intensity and speed
- [ ] Proper layering with sprites
- [ ] Animated distortion patterns
- [ ] Low performance overhead

**Dependencies:**
- Shader system setup
- District environments (Iteration 8)

### 5. CRT Screen Effects
**Priority:** Medium  
**Estimated Hours:** 8

**Description:**  
Implement CRT monitor shader effects for computer terminals and displays throughout the station.

**User Story:**  
*As a player, I want computer screens to have authentic CRT effects, so that the retro-futuristic aesthetic is consistent.*

**Design Reference:** `src/shaders/crt_screen.shader` (listed in Links to Relevant Code)

**Acceptance Criteria:**
- [ ] Scanlines and phosphor glow
- [ ] Screen curvature distortion
- [ ] Chromatic aberration
- [ ] Flicker and noise options
- [ ] Adjustable effect intensity

**Dependencies:**
- UI system (Iteration 3)
- Interactive objects (Iteration 2)

### 6. Animation System Polish
**Priority:** High  
**Estimated Hours:** 12

**Description:**  
Polish and optimize animation systems for smooth character movement and transitions.

**User Story:**  
*As a player, I want character animations to be smooth and responsive, so that movement feels natural and polished.*

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md`, `docs/design/sprite_perspective_scaling_full_plan.md`

**Acceptance Criteria:**
- [ ] Smooth animation blending
- [ ] Proper animation priorities
- [ ] Idle animation variations
- [ ] Context-sensitive animations
- [ ] Animation event system
- [ ] **Enhanced:** Animation speed adjusts based on sprite scale
- [ ] **Enhanced:** Smooth transitions during scale changes
- [ ] **Enhanced:** Walk animation sync with movement speed scaling

**Dependencies:**
- Player controller (Iteration 2)
- NPC system (Iteration 2)
- Animation config system (Iteration 3)

**Implementation Notes:**
- Reference: docs/design/sprite_perspective_scaling_full_plan.md lines 701-720 (Movement Speed Scaling)
- Animation playback speed should match movement speed adjustments
- Ensure smooth visual transitions during scale changes
- Prevent animation glitches when crossing zone boundaries

### 7. Atmospheric Visual Effects
**Priority:** Low  
**Estimated Hours:** 8

**Description:**  
Add particle effects and atmospheric elements like dust, steam, and lighting effects.

**User Story:**  
*As a player, I want to see atmospheric effects like floating dust and steam, so that the space station feels lived-in and authentic.*

**Acceptance Criteria:**
- [ ] Particle system for dust/debris
- [ ] Steam and vapor effects
- [ ] Dynamic lighting effects
- [ ] Performance-efficient rendering
- [ ] Configurable density levels

**Dependencies:**
- District system (Iteration 8)
- Performance optimization (Iteration 15)

### 8. Advanced Occlusion Features
**Priority:** Medium  
**Estimated Hours:** 16

**Description:**  
Implement advanced foreground occlusion features including animated elements, spatial indexing, and performance optimizations.

**User Story:**  
*As a player, I want rich, animated foreground elements that create a dynamic, layered environment with smooth performance.*

**Design Reference:** `docs/design/foreground_occlusion_full_plan.md`

**Acceptance Criteria:**
- [ ] Animated foreground elements with state machines
- [ ] QuadTree spatial indexing for performance
- [ ] Advanced occlusion effects (heat distortion through occluders)
- [ ] Performance LOD system for occlusion
- [ ] Integration with all perspective types

**Dependencies:**
- Basic occlusion system (Iteration 14)
- Animation system (Iteration 3)
- Performance baseline (Iteration 15)

### 9. Rendering Pipeline Optimizations
**Priority:** High  
**Estimated Hours:** 10

**Description:**  
Implement advanced rendering optimizations beyond basic sprite batching to ensure smooth performance.

**User Story:**  
*As a player, I want consistent frame rates even in visually complex scenes, so that gameplay remains smooth and responsive.*

**Design Reference:** `docs/design/performance_optimization_plan.md` lines 104-115

**Acceptance Criteria:**
- [ ] Advanced draw call batching beyond basic sprite batching
- [ ] Light2D optimization strategies
- [ ] Static element conversion to single textures
- [ ] VisibilityEnabler2D implementation for all applicable nodes
- [ ] Measurable performance improvements

**Implementation Notes:**
- Reference: docs/design/performance_optimization_plan.md - Section 4: Rendering Optimization
- Extend draw call batching to UI and effects
- Minimize or avoid Light2D usage (not authentic to era)
- Convert static backgrounds and UI to single textures
- Implement visibility culling for off-screen elements
- Profile and document performance gains

**Dependencies:**
- Basic sprite batching (Iteration 14)
- Visual systems (this iteration)

### 10. Platform-Specific Rendering Optimizations
**Priority:** Medium  
**Estimated Hours:** 8

**Description:**  
Implement platform-specific optimizations to ensure optimal performance across Windows and Linux systems.

**User Story:**  
*As a player on any supported platform, I want the game to take advantage of my system's capabilities, so that I get the best possible performance.*

**Design Reference:** `docs/design/performance_optimization_plan.md` lines 221-235

**Acceptance Criteria:**
- [ ] Windows GPU scheduling enablement
- [ ] Linux X11/Wayland compatibility testing
- [ ] Resolution scaling optimization
- [ ] Platform-specific render settings
- [ ] Verified performance on both platforms

**Implementation Notes:**
- Reference: docs/design/performance_optimization_plan.md - Platform-Specific Optimizations
- Enable GPU scheduling on Windows for better performance
- Test with both X11 and Wayland on Linux
- Implement resolution-aware rendering optimizations
- Create platform detection and auto-configuration
- Document platform-specific settings

**Dependencies:**
- Core rendering system
- Quality settings (Iteration 14)

### 11. Create debug save commands (force_save, corrupt_save, analyze_save)
**Priority:** Medium  
**Estimated Hours:** 8

**Description:**  
Implement debug console commands for testing and analyzing the save system during development.

**User Story:**  
*As a developer, I want debug commands to test save system edge cases, so that I can verify save functionality works correctly in all scenarios.*

**Design Reference:** `docs/design/save_system_design.md`

**Acceptance Criteria:**
- [ ] force_save command bypasses sleep requirement
- [ ] corrupt_save command tests corruption handling
- [ ] analyze_save command shows save file metrics
- [ ] Commands only available in debug builds
- [ ] Clear error messages for invalid usage

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 487-517 (debug features)
- Only available when OS.is_debug_build() returns true
- Register commands with Console system
- Implement DebugSaveCommands static class
- Include safety checks to prevent production exposure

### 12. Implement save file analyzer tool
**Priority:** Medium  
**Estimated Hours:** 12

**Description:**  
Create a comprehensive tool for analyzing save file structure, performance, and integrity.

**User Story:**  
*As a developer, I want detailed save file analysis, so that I can debug save issues and optimize save performance.*

**Design Reference:** `docs/design/save_system_design.md`

**Acceptance Criteria:**
- [ ] Shows save file size and compression metrics
- [ ] Displays module breakdown and sizes
- [ ] Analyzes save/load performance
- [ ] Validates save file integrity
- [ ] Exports debug-friendly save data

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 503-517 (save analytics)
- Implement analyze_current_save() method
- Include file size, module count, compression ratio
- Track largest modules and performance metrics
- Generate detailed analysis reports

### 13. Add save performance profiler
**Priority:** Medium  
**Estimated Hours:** 10

**Description:**  
Implement performance profiling for save/load operations to ensure target metrics are met.

**User Story:**  
*As a developer, I want save performance profiling, so that I can ensure save operations meet performance targets and optimize bottlenecks.*

**Design Reference:** `docs/design/save_system_design.md`

**Acceptance Criteria:**
- [ ] Measures save/load times per module
- [ ] Tracks compression performance
- [ ] Identifies performance bottlenecks
- [ ] Generates performance reports
- [ ] Warns when targets are missed

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 522-548 (performance monitoring)
- Use OS.get_ticks_msec() for precise timing
- Track per-module save/load times
- Include in measure_save_performance() method
- Generate warnings for performance regressions

### 14. Create save state inspector UI
**Priority:** Low  
**Estimated Hours:** 16

**Description:**  
Create a visual interface for inspecting save state during development and debugging.

**User Story:**  
*As a developer, I want a visual save state inspector, so that I can debug save-related issues through an intuitive interface.*

**Design Reference:** `docs/design/save_system_design.md`

**Acceptance Criteria:**
- [ ] Visual display of save file structure
- [ ] Real-time save state monitoring
- [ ] Module-by-module inspection
- [ ] Save validation results display
- [ ] Export functionality for debugging

**Implementation Notes:**
- Reference: docs/design/save_system_design.md (debug features)
- Create debug UI panel for save inspection
- Show save file hierarchy and module data
- Include real-time save state updates
- Provide export options for debugging

## Testing Criteria
- Sprite scaling creates convincing depth illusion
- Occlusion system handles all edge cases smoothly
- Shader effects render correctly on target hardware
- Animation transitions are seamless
- Visual effects maintain 60 FPS performance
- All systems integrate without visual artifacts
- Effects scale properly at different resolutions
- Debug save commands function correctly in debug builds
- Save file analyzer provides accurate metrics
- Performance profiler identifies bottlenecks correctly
- Save state inspector displays save data accurately
- Debug tools are not accessible in production builds
- **Enhanced:** Zone-based scaling system provides smooth transitions
- **Enhanced:** Movement speed scaling feels natural with perspective
- **Enhanced:** Audio attenuation reinforces depth perception
- **Enhanced:** LOD system improves performance with 50+ sprites
- **Enhanced:** Editor tools enable efficient zone creation
- **Enhanced:** Multi-perspective integration works seamlessly
- **Enhanced:** Performance dashboard accurately tracks metrics
- **Enhanced:** Serialization preserves all perspective states

## Timeline
- **Estimated Duration:** 6-7 weeks
- **Total Hours:** 264 (86 + 46 for debug tools + 132 for perspective enhancements)
- **Critical Path:** Sprite scaling and occlusion are foundational
- **Debug Tools:** Can be developed in parallel with visual systems
- **Perspective Tasks Breakdown:**
  - Zone-based scaling system: 20 hours
  - District configurations: 8 hours
  - Movement & audio scaling: 16 hours
  - LOD system: 12 hours
  - Editor tools: 16 hours
  - Advanced visual features: 20 hours
  - Intelligent zone generation: 16 hours
  - Performance monitoring: 8 hours
  - Multi-perspective integration: 12 hours
  - Testing suite: 16 hours

## Definition of Done
- [ ] All visual systems implemented and polished
- [ ] Performance targets maintained (60 FPS)
- [ ] Visual effects enhance rather than distract
- [ ] Comprehensive visual testing completed
- [ ] Shader fallbacks for older hardware
- [ ] Documentation for content creators
- [ ] Code reviewed and approved
- [ ] Debug save tools implemented and tested
- [ ] Save system performance profiling complete
- [ ] Debug tools properly secured from production builds
- [ ] **Enhanced:** Zone-based scaling fully functional in all districts
- [ ] **Enhanced:** Movement and audio scaling create believable depth
- [ ] **Enhanced:** LOD system provides measurable performance gains
- [ ] **Enhanced:** Editor tools documented and tested
- [ ] **Enhanced:** All perspective features integrate with existing systems
- [ ] **Enhanced:** Performance metrics meet or exceed targets
- [ ] **Enhanced:** Comprehensive test coverage for perspective system

## Dependencies
- Core game systems (Iterations 1-3)
- District system (Iteration 8)
- Performance baseline (Iteration 15)

## Risks and Mitigations
- **Risk:** Shader compatibility issues
  - **Mitigation:** Test on minimum spec hardware, provide fallbacks
- **Risk:** Performance impact of visual effects
  - **Mitigation:** Continuous profiling, quality settings
- **Risk:** Visual style inconsistency
  - **Mitigation:** Clear art direction guidelines

### Task 15: Implement comprehensive object state hover text system
**User Story:** As a player, I want hover text to dynamically reflect the current state of all interactive objects (doors, containers, terminals, evidence), so that I can understand the world state at a glance and make informed interaction decisions.

**Design Reference:** `docs/design/scumm_hover_text_system_design.md`, `docs/design/template_interactive_object_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. **Door States:** Show "locked door", "open door", "jammed door" based on state
  2. **Container States:** Display "empty container", "locked chest", "searched drawer"
  3. **Terminal States:** Show "active terminal", "powered-down terminal", "corrupted database"
  4. **Evidence States:** Indicate "analyzed evidence", "unexamined clue", "contaminated sample"
  5. **Ownership Display:** Show "belongs to [NPC]" when ownership is known
  6. **Quest Integration:** Highlight quest-relevant states in hover text
  7. **State Persistence:** Object states persist and reflect in hover text after save/load
  8. **Performance:** Efficient state caching for frequently viewed objects

**Implementation Notes:**
- Reference: docs/design/scumm_hover_text_system_design.md lines 91-125 (Object State Reflection)
- Reference: docs/design/template_interactive_object_design.md (state machine system)
- Implement ObjectStateHandler for hover text system:
  ```gdscript
  func get_object_hover_text(obj: InteractiveObject) -> String:
      var description = obj.display_name
      
      # State-based descriptions
      match obj.type:
          "door":
              if obj.is_locked:
                  description = "locked " + description
              elif obj.is_open:
                  description = "open " + description
                  
          "container":
              if obj.is_empty:
                  description = "empty " + description
              elif obj.requires_key:
                  description = "locked " + description
                  
          "terminal":
              if obj.is_active:
                  description = "active " + description
              else:
                  description = "powered-down " + description
                  
          "evidence":
              if PuzzleManager.is_evidence_analyzed(obj.id):
                  description += " (analyzed)"
      
      # Ownership information
      if obj.has_owner and NPCTrustManager.knows_owner(obj.id):
          description += " (belongs to " + obj.owner_name + ")"
      
      return description
  ```
- **State Categories:** Support all interactive object types from template system
- **Dynamic Updates:** Hook into object state change events for real-time hover updates
- **Quest Awareness:** Check QuestManager for object relevance to active quests
- **Investigation Integration:** Connect to investigation system for evidence states
- **Ownership Tracking:** Interface with NPCTrustManager for ownership knowledge
- **Performance Optimization:** Cache static states, update only on state changes

### Task 16: Implement Zone-Based Scaling System
**User Story:** As a developer, I want a sophisticated zone-based scaling system that provides precise control over perspective effects in different areas of each district, so that we can create believable depth illusions tailored to each environment.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 107-242

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (visual quality), Technical Requirements (efficient sprite scaling)
- **Acceptance Criteria:**
  1. ScalingZoneManager singleton manages all scaling zones
  2. Zone definitions support polygon shapes with arbitrary vertices
  3. Smooth transitions between zones with configurable blend distances
  4. Priority system for overlapping zones
  5. Runtime zone modification support for dynamic environments
  6. Visual debugging tools to see zone boundaries
  7. Performance optimized for 10+ zones per district
  8. Integration with district loading system

**Implementation Notes:**
- Create ScalingZoneManager as autoload singleton
- Implement zone detection using Area2D nodes
- Support smooth interpolation between zone parameters
- Cache zone lookups for performance
- Provide editor tools for zone creation
- Test with complex overlapping scenarios

### Task 17: Create District Perspective Configuration Resources
**User Story:** As a level designer, I want to configure perspective settings for each district through resource files, so that each area can have unique depth characteristics that enhance its atmosphere.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 244-326

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (district uniqueness), Technical Requirements (configurable scaling)
- **Acceptance Criteria:**
  1. DistrictPerspectiveConfig custom resource type
  2. Global scaling parameters per district
  3. Multiple scaling zone definitions
  4. Audio distance attenuation curves
  5. Movement speed adjustment settings
  6. Foreground occlusion integration parameters
  7. Export/import functionality for configs
  8. Validation to prevent invalid configurations

**Implementation Notes:**
- Extend Resource class for DistrictPerspectiveConfig
- Include default presets for common scenarios
- Support hot-reloading during development
- Create example configs for each district type
- Document all configuration parameters

### Task 18: Implement Movement Speed Scaling
**User Story:** As a player, I want my character to move slower when they appear smaller (further away) and faster when larger (closer), so that movement feels natural and maintains the depth illusion.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 701-720

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (visual quality), User Requirements (natural movement)
- **Acceptance Criteria:**
  1. Movement speed scales proportionally with sprite scale
  2. Configurable speed scaling curves
  3. Smooth speed transitions when crossing zones
  4. NPCs and player both affected
  5. Animation speed syncs with movement speed
  6. No jarring speed changes
  7. Override options for special cases
  8. Performance impact < 1% CPU

**Implementation Notes:**
- Modify player and NPC movement controllers
- Use PerspectiveController to get current scale
- Apply scale factor to movement vectors
- Ensure pathfinding accounts for speed changes
- Test with various movement patterns

### Task 19: Add Audio Distance Attenuation
**User Story:** As a player, I want sounds from distant objects to be quieter and sounds from nearby objects to be louder, so that audio reinforces the visual depth perception.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 723-768

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (consistent art style), User Requirements (audio feedback)
- **Acceptance Criteria:**
  1. Audio volume scales with sprite distance
  2. Configurable attenuation curves
  3. Support for 2D and 3D audio sources
  4. Dialog volume maintains clarity
  5. Ambient sounds properly positioned
  6. Smooth audio transitions
  7. Per-sound-type attenuation settings
  8. Integration with existing audio system

**Implementation Notes:**
- Reference: hardware_validation_plan.md confirms 2D audio only
- Extend AudioStreamPlayer2D with perspective awareness
- Create custom attenuation curves per sound type
- Ensure dialog remains audible at all distances
- Test with multiple simultaneous audio sources

### Task 20: Implement Perspective-Aware LOD System
**User Story:** As a developer, I want a Level of Detail system that reduces visual complexity for distant objects, so that we maintain performance while having many scaled sprites on screen.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 771-812

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (performance optimization), Business Requirements (60 FPS)
- **Acceptance Criteria:**
  1. Three LOD levels: Near (full), Medium (reduced), Far (minimal)
  2. Automatic LOD switching based on scale
  3. Smooth visual transitions between LODs
  4. Animation frame reduction for distant sprites
  5. Shadow/effect culling for far objects
  6. Configurable LOD thresholds
  7. Performance monitoring integration
  8. < 20% performance gain with 50+ sprites

**Implementation Notes:**
- Implement in PerspectiveController component
- Use scale thresholds: Near > 0.7, Medium 0.3-0.7, Far < 0.3
- Reduce animation frames for distant objects
- Cull particle effects and shadows at distance
- Monitor performance improvements

### Task 21: Create Editor Tools for Perspective System
**User Story:** As a developer, I want visual editor tools for creating and testing perspective zones, so that level designers can efficiently set up proper depth perception in each district.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 1180-1234

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (efficient development), Technical Requirements (editor tools)
- **Acceptance Criteria:**
  1. Visual zone editor with polygon drawing
  2. Real-time preview of scaling effects
  3. Zone overlap visualization
  4. Scale gradient overlay display
  5. Import/export zone configurations
  6. Undo/redo support
  7. Preset zone templates
  8. Integration with Godot editor

**Implementation Notes:**
- Create custom EditorPlugin
- Use Godot's polygon editing tools
- Provide visual feedback with overlays
- Support keyboard shortcuts
- Include comprehensive tooltips

### Task 22: Implement Advanced Visual Features
**User Story:** As a player, I want advanced visual effects like sprite deformation and dynamic shadows that enhance the depth illusion, so that the game world feels more immersive and three-dimensional.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 815-923

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (visual quality), User Requirements (immersion)
- **Acceptance Criteria:**
  1. Subtle sprite deformation at extreme scales
  2. Dynamic shadow scaling and positioning
  3. Depth-based color grading
  4. Atmospheric haze for distant objects
  5. Perspective-correct sprite rotation
  6. All effects togglable for performance
  7. Smooth transitions for all effects
  8. Consistent visual style maintained

**Implementation Notes:**
- Implement vertex deformation for extreme perspectives
- Use shaders for atmospheric effects
- Keep effects subtle to maintain art style
- Provide quality settings for each effect
- Test on minimum spec hardware

### Task 23: Create Intelligent Zone Generation System
**User Story:** As a developer, I want an automated system that can generate appropriate scaling zones based on district layout analysis, so that we can quickly prototype and refine perspective settings.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 926-1033

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (efficient development), Technical Requirements (automation)
- **Acceptance Criteria:**
  1. Analyzes walkable areas to suggest zones
  2. Identifies natural depth boundaries
  3. Generates initial zone configurations
  4. Suggests appropriate scaling parameters
  5. Handles corridors vs open areas
  6. Export results for manual refinement
  7. Learns from designer adjustments
  8. Batch processing for all districts

**Implementation Notes:**
- Use navigation mesh analysis
- Detect natural boundaries (walls, doors)
- Generate zones based on spatial patterns
- Provide confidence scores for suggestions
- Allow manual override of all parameters

### Task 24: Implement Performance Monitoring Dashboard
**User Story:** As a developer, I want a real-time dashboard showing perspective system performance metrics, so that I can optimize scaling zones and ensure smooth gameplay.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 1105-1177

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (performance), Business Requirements (60 FPS)
- **Acceptance Criteria:**
  1. Real-time FPS with perspective system active
  2. Zone calculation time per frame
  3. Number of scaled entities
  4. Memory usage for perspective data
  5. LOD distribution visualization
  6. Performance history graphs
  7. Export performance reports
  8. Warning system for performance issues

**Implementation Notes:**
- Create debug UI overlay
- Track key metrics per frame
- Use circular buffers for history
- Color-code performance warnings
- Include in debug builds only

### Task 25: Add Multi-Perspective Integration
**User Story:** As a player, I want sprite scaling to work correctly with different camera perspectives (isometric, side-scrolling, top-down), so that each view maintains proper depth perception.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md`, `docs/design/multi_perspective_character_system_plan.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Business Requirements (visual consistency), Technical Requirements (multi-perspective)
- **Acceptance Criteria:**
  1. Scaling system detects current perspective type
  2. Adjusts scaling algorithms per perspective
  3. Smooth transitions during perspective changes
  4. Maintains visual consistency across views
  5. Per-perspective zone configurations
  6. Testing for all three perspective types
  7. No visual artifacts during transitions
  8. Performance maintained across all modes

**Implementation Notes:**
- Integrate with MultiPerspectiveCharacter system
- Create perspective-specific scaling algorithms
- Test thoroughly during perspective transitions
- Ensure no z-fighting or sorting issues
- Document perspective-specific considerations

### Task 26: Implement Serialization for Perspective System
**User Story:** As a player, I want the perspective scaling system state to save and load correctly, so that the visual experience remains consistent across game sessions.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 1237-1265

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (save system), Business Requirements (persistence)
- **Acceptance Criteria:**
  1. Current zone states save correctly
  2. Entity scale values persist
  3. LOD states maintained
  4. Zone modifications saved
  5. Performance optimized saves
  6. Version migration support
  7. Minimal save file impact
  8. Fast loading times maintained

**Implementation Notes:**
- Extend modular serialization system
- Save only dynamic state changes
- Use differential saves for zones
- Compress perspective data
- Test with complex zone setups

### Task 27: Create Comprehensive Testing Suite
**User Story:** As a developer, I want automated tests that verify all aspects of the perspective scaling system, so that we can confidently make changes without breaking functionality.

**Design Reference:** `docs/design/sprite_perspective_scaling_full_plan.md` lines 1268-1310

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** Technical Requirements (testing), Business Requirements (quality)
- **Acceptance Criteria:**
  1. Unit tests for all core components
  2. Integration tests for system interactions
  3. Performance benchmarks
  4. Visual regression tests
  5. Zone boundary edge cases
  6. Multi-perspective scenarios
  7. Save/load verification
  8. 90%+ code coverage

**Implementation Notes:**
- Use Godot testing framework
- Create visual diff tools
- Automate performance benchmarks
- Test edge cases thoroughly
- Document all test scenarios

## Links to Relevant Code
- src/core/visual/perspective_scaler.gd
- src/core/visual/occlusion_manager.gd
- src/core/visual/scaling_zone_manager.gd (to be created)
- src/core/visual/perspective_controller.gd (to be created)
- src/resources/district_perspective_config.gd (to be created)
- src/core/visual/perspective_lod_system.gd (to be created)
- src/tools/perspective_zone_editor.gd (to be created)
- src/shaders/hologram.shader
- src/shaders/heat_distortion.shader
- src/shaders/crt_screen.shader
- src/core/animation/animation_polish.gd
- src/core/visual/atmosphere_effects.gd
- docs/design/sprite_perspective_scaling_plan.md
- docs/design/sprite_perspective_scaling_full_plan.md
- docs/design/foreground_occlusion_mvp_plan.md