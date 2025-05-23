# Iteration 3: Navigation Refactoring and Multi-Perspective Character System

## Goals
- Implement improved point-and-click navigation system
- Create multi-perspective character system
- Enhance camera system with proper coordinate transformations
- Implement robust walkable area integration
- Develop comprehensive test cases for both systems

## Requirements

### Business Requirements
- **B1:** Create a more responsive and predictable navigation system
  - **Rationale:** Intuitive, smooth navigation is essential for the point-and-click genre
  - **Success Metric:** Player movement feels natural with minimal user frustration

- **B2:** Support multiple visual perspectives across different game districts
  - **Rationale:** Visual variety enhances player engagement and world-building
  - **Success Metric:** Seamless character movement and interaction across different perspective types

- **B3:** Maintain consistent visual quality and gameplay mechanics across all perspectives
  - **Rationale:** Consistent quality ensures a cohesive player experience
  - **Success Metric:** Players report similar levels of satisfaction across all district perspectives

### User Requirements
- **U1:** As a player, I want navigation to feel smooth and responsive
  - **User Value:** Reduces frustration and enhances immersion
  - **Acceptance Criteria:** Character movement follows clicks with appropriate pathfinding and obstacle avoidance

- **U2:** As a player, I want my character to appear correctly in different game areas
  - **User Value:** Maintains visual immersion and aesthetic quality
  - **Acceptance Criteria:** Character sprite adapts correctly to each perspective type (isometric, side-scrolling, top-down)

- **U3:** As a player, I want consistent gameplay mechanics regardless of visual perspective
  - **User Value:** Reduces cognitive load when moving between areas
  - **Acceptance Criteria:** Core interactions work identically across all perspective types

### Technical Requirements
- **T1:** Maintain architectural principles while refactoring
  - **Rationale:** Code quality and maintainability must be preserved
  - **Constraints:** Changes must follow established patterns and coupling guidelines

- **T2:** Implement flexible, configuration-driven system for perspectives
  - **Rationale:** Facilitate easy addition of new perspectives and characters
  - **Constraints:** Performance must remain optimal with multiple perspectives

- **T3:** All camera system enhancements must preserve background scaling visual correctness and pass both unit tests and visual validation using camera-system test scene
  - **Rationale:** Phase 1 implementation broke background scaling by prioritizing architectural purity over visual correctness
  - **Constraints:** Visual display requirements take precedence over internal architectural elegance

## Tasks

### Point-and-Click Navigation Refactoring
- [x] Task 1: Enhance scrolling camera system with improved coordinate conversions *(REQUIRES VISUAL FIXES)*
  - **Status:** Phase 1 complete but broke background scaling - needs hybrid solution for visual correctness
- [x] Task 2: Implement state signaling and synchronization for camera
- [x] Task 3: Create test scene for validating camera system improvements
- [ ] Task 4: Enhance player controller for consistent physics behavior
- [ ] Task 5: Implement proper pathfinding with Navigation2D
- [ ] Task 6: Create test scene for player movement validation
- [ ] Task 7: Enhance walkable area system with improved polygon algorithms
- [ ] Task 8: Implement click detection and validation refinements
- [ ] Task 9: Create test scene for walkable area validation
- [ ] Task 10: Enhance system communication through signals
- [ ] Task 11: Implement comprehensive debug tools and visualizations
- [ ] Task 12: Create integration test for full navigation system

### Multi-Perspective Character System
- [ ] Task 13: Create directory structure and base files for the multi-perspective system
- [ ] Task 14: Define perspective types enum and configuration templates
- [ ] Task 15: Extend district base class to support perspective information
- [ ] Task 16: Implement character controller class with animation support
- [ ] Task 17: Create test character with basic animations
- [ ] Task 18: Test animation transitions within a perspective
- [ ] Task 19: Implement movement controller with direction support
- [ ] Task 20: Connect movement controller to point-and-click navigation
- [ ] Task 21: Test character movement in a single perspective
- [ ] Task 22: Create test districts with different perspective types
- [ ] Task 23: Implement perspective switching in character controller
- [ ] Task 24: Create test for transitions between different perspective districts

### Documentation and Review
- [ ] Task 25: Create comprehensive documentation for both systems
- [ ] Task 26: Perform code review and optimization
- [ ] Task 27: Update existing documentation to reflect new systems

### Sprite Perspective Scaling System
- [ ] Task 28: Create simple POC test sprites for perspective scaling validation
- [ ] Task 29: Implement basic sprite perspective scaling system
- [ ] Task 30: Create sprite scaling test scene for validation

### Audio System MVP Foundation
- [ ] Task 31: Create audio system directory structure and core architecture
- [ ] Task 32: Implement basic AudioManager singleton
- [ ] Task 33: Create simplified DiegeticAudioController component
- [ ] Task 34: Implement diegetic audio scaling system for perspective immersion
- [ ] Task 35: Integrate audio with perspective scaling system
- [ ] Task 36: Create audio foundation test scene and verify integration

### Foreground Occlusion MVP
- [ ] Task 37: Create ForegroundOcclusionManager singleton for Y-position based sprite layering
- [ ] Task 38: Implement basic foreground element loading in base_district.gd
- [ ] Task 39: Extend district JSON configuration for foreground elements
- [ ] Task 40: Create test foreground sprites for camera test backgrounds
- [ ] Task 41: Build foreground occlusion test scene with debug visualization

## Testing Criteria
- Camera system properly handles coordinate conversions
- Player movement is smooth with proper acceleration/deceleration
- Pathfinding correctly navigates around obstacles
- Walkable areas are properly respected with accurate boundaries
- Characters display correctly in each perspective
- Animation transitions are smooth in all perspectives
- Character movement adapts correctly to each perspective type
- Performance remains optimal across all test cases
- All debug tools work properly
- Sprites scale appropriately based on Y-position
- Audio sources scale volume based on distance and perspective
- Stereo panning creates spatial audio effect
- Diegetic audio enhances environmental immersion
- AudioManager singleton properly tracks player position
- DiegeticAudioController components update efficiently
- Audio integrates seamlessly with perspective scaling
- Test scene validates all audio MVP functionality
- Foreground elements correctly occlude player based on Y-position
- Foreground system integrates cleanly with existing coordinate system
- No performance impact from foreground occlusion updates
- Debug visualization clearly shows occlusion thresholds

## Timeline
- Start date: 2025-05-18
- Target completion: 2025-06-01

## Dependencies
- Iteration 1 (Basic Environment and Navigation)
- Iteration 2 (NPC Framework and Suspicion System)

## Code Links
- No links yet

## Notes
This iteration implements the plans in the following design documents:
- docs/design/point_and_click_navigation_refactoring_plan.md
- docs/design/multi_perspective_character_system_plan.md
- docs/design/sprite_perspective_scaling_plan.md
- docs/design/foreground_occlusion_mvp_plan.md

These systems provide the foundation for all future gameplay elements and will be extended in subsequent iterations.

### Task 1: Enhance scrolling camera system with improved coordinate conversions

**User Story:** As a player, I want the game camera to track my character smoothly and accurately with proper visual display (no grey bars or visual artifacts), so that I can focus on gameplay rather than managing my view of the action.

**Status History:**
- **⏳ PENDING** (05/22/25)
- **✅ COMPLETE** (05/22/25)
**Status History:**
- **✅ COMPLETE** (05/22/25)
**Status History:**
- **✅ COMPLETE** (05/22/25)
**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Camera follows player character smoothly without jerky movements
  2. Screen-to-world and world-to-screen coordinate conversions work accurately at all zoom levels
  3. Camera maintains proper boundaries based on the current district
  4. Edge case handling prevents camera from showing areas outside the playable space
  5. Camera movement uses appropriate easing for natural feel

**Implementation Notes:**
- Refine coordinate handling in scrolling_camera.gd
- Add validation methods to ensure coordinates are always valid
- Update camera targeting to prevent edge cases
- Maintain alignment with signal-based architectural pattern

**Enhancement Plan:**

1. **Coordinate Transformation Improvements:**
   - Enhance screen_to_world and world_to_screen methods to handle edge cases
   - Add validation for NaN values during transformations
   - Improve handling of edge cases near screen boundaries
   - Enhance zoom-specific transformations for consistent behavior

2. **Camera State Management Addition:**
   - Implement formal state system (IDLE, MOVING, FOLLOWING_PLAYER)
   - Prevent conflicting camera movement commands
   - Improve synchronization with player movement
   - Implement clear entry/exit conditions for each state

3. **Signal-Based Communication Enhancement:**
   - Add camera_move_started signal when camera begins movement
   - Add camera_move_completed signal when movement finishes
   - Add view_bounds_changed signal when boundaries update
   - Support established signal-based architecture

4. **Coordinate Validation Methods:**
   - Add validate_coordinates method for viewport validation
   - Implement is_point_in_view to check visibility
   - Add ensure_valid_target for movement validation

5. **Improve CoordinateManager Integration:**
   - Enhance integration with the singleton
   - Add helper methods for direct utilization
   - Ensure consistent coordinate handling
   - Maintain proper separation of concerns

6. **Testing Strategy:**
   - Create test cases for all conversion scenarios
   - Implement visual debugging helpers
   - Test at different zoom levels and positions
   - Verify edge case handling

7. **Documentation Updates:**
   - Update system documentation
   - Document new methods, signals, and states
   - Provide usage examples for proper implementation

### Task 2: Implement state signaling and synchronization for camera

**User Story:** As a player, I want the camera to correctly synchronize with my character's movement and game events, so that I always have a clear view of relevant gameplay elements without jarring transitions.


**Status History:**
- **⏳ PENDING** (05/22/25)
- **✅ COMPLETE** (05/22/25)
**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Camera emits signals when it starts and completes movement
  2. Camera tracks its current state (IDLE, MOVING, FOLLOWING_PLAYER)
  3. Other systems can connect to camera signals to coordinate their behavior
  4. Camera state transitions are clearly defined and predictable
  5. Status signals include relevant data like target positions and bounds
  6. UI elements can synchronize animations with camera movements
  7. Player interactions remain responsive during camera transitions

**Implementation Notes:**
- Add signal definitions to ScrollingCamera class
- Implement state tracking variables and enum definitions
- Create state transition methods with signal emission
- Add documentation for signal usage
- Ensure signal emission follows architectural principles
- Create helper methods for common signal connection patterns

**Implementation Plan:**

1. **Camera State Listener System:**
   - Create methods to simplify signal connection management (`connect_state_listener`, `disconnect_listener`)
   - Implement auto-disconnection of signals when objects are freed
   - Add a listener registry to track active connections

2. **Enhanced Signal Data:**
   - Expand signal parameters to include more context (old position, transition type, duration)
   - Add optional debug mode with extended signal information
   - Implement signal batching for performance optimization

3. **State Query Methods:**
   - Add methods to query camera state (`is_idle()`, `is_moving()`, `is_following_player()`)
   - Implement transition progress tracking (`get_movement_progress()`)
   - Create boundary query methods (`is_at_boundary()`, `get_current_bounds()`)

4. **UI Element Synchronization:**
   - Create registration system for UI elements to respond to camera events
   - Add synchronization methods that UI can connect to
   - Implement progress notification for UI animations

5. **Transition Event System:**
   - Create event points during transitions (25%, 50%, 75% complete)
   - Add methods to register callbacks at specific transition points
   - Implement event handling for transition start/mid/complete

6. **Debug Visualization:**
   - Add visual indicators for camera state changes
   - Create debug overlay showing signal emissions
   - Implement visual transition markers

7. **Signal Usage Documentation:**
   - Create comprehensive doc comments for all signals
   - Add example code for common signal connections
   - Document best practices for signal handling

8. **Integration Example:**
   - Create example UI manager showing how to connect to camera signals
   - Implement camera state indicator that responds to signals
   - Add sample code for synchronizing UI animations with camera movements

**Integration Strategy:**
- Maintain backward compatibility with existing code
- Use method chaining pattern for fluent API design
- Prioritize minimal coupling between components
- Follow established signal-based communication patterns
- Include performance optimizations for many connected objects

### Task 3: Create test scene for validating camera system improvements

**User Story:** As a developer, I want a dedicated test scene for the camera system, so that I can verify its functionality and easily detect regressions during development.


**Status History:**
- **✅ COMPLETE** (05/23/25)
**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Test scene includes various camera movement scenarios
  2. Scene provides visual feedback for coordinate transformations
  3. Controls allow testing different camera views and movements
  4. Debug visualization shows camera states and signals
  5. Test scene can verify all camera enhancements

**Implementation Notes:**
- Create a dedicated scene file for camera testing
- Implement test controls for triggering different camera behaviors
- Add visual indicators for coordinate transformations
- Include debug overlay for state and signal monitoring
- Document test procedures for consistent verification

### Task 4: Enhance player controller for consistent physics behavior

**User Story:** As a player, I want my character to move naturally with smooth acceleration and deceleration, so that navigation feels responsive and realistic.

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Character accelerates smoothly when starting movement
  2. Character decelerates naturally when approaching destination
  3. Movement state transitions are visually apparent and logical
  4. Character does not "stick" to boundaries or obstacles
  5. Character movement aligns with animation states

**Implementation Notes:**
- Implement state machine for clearer movement states (IDLE, ACCELERATING, MOVING, DECELERATING, ARRIVED)
- Refine physics constants for natural movement
- Connect movement states to animation system
- Use signals to communicate state changes to other systems

### Task 5: Implement proper pathfinding with Navigation2D

**User Story:** As a player, I want my character to intelligently navigate around obstacles, so that I don't have to micromanage movement through complex environments.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Character finds optimal paths around obstacles
  2. Pathfinding accounts for walkable area boundaries
  3. Path smoothing eliminates unnatural zigzag movement
  4. Dynamic obstacles are handled appropriately
  5. Pathfinding performance remains good in complex environments

**Implementation Notes:**
- Integrate Godot's Navigation2D system for path generation
- Implement path smoothing algorithm for natural movement
- Create NavigationObstacle2D instances for dynamic obstacles
- Ensure paths respect walkable area boundaries
- Optimize for performance in complex scenes

### Task 6: Create test scene for player movement validation

**User Story:** As a developer, I want a test scene for player movement, so that I can verify movement physics, pathfinding, and obstacle avoidance work correctly.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Test scene includes different movement scenarios
  2. Complex obstacle configurations can be tested
  3. Visual feedback shows pathfinding results
  4. Movement metrics (speed, acceleration) are displayed
  5. All movement states can be tested and verified

**Implementation Notes:**
- Create a dedicated scene for movement testing
- Include various obstacle configurations
- Add visual path display for debugging
- Include movement parameter controls for testing
- Add monitoring tools for physics values

### Task 7: Enhance walkable area system with improved polygon algorithms

**User Story:** As a player, I want clear boundaries for where my character can walk, so that I don't experience frustration from attempting to navigate to inaccessible areas.

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Walkable areas are clearly defined with precise boundaries
  2. Multiple walkable areas can be defined with priority/layering
  3. Point-in-polygon checks are efficient for complex shapes
  4. Navigation paths are validated against walkable boundaries
  5. Closest valid point is found when clicking outside walkable area

**Implementation Notes:**
- Improve is_point_in_polygon algorithm efficiency
- Add support for multiple walkable area polygons
- Implement path validation to ensure all points are within walkable areas
- Create methods to find closest valid point when target is outside boundary

### Task 8: Implement click detection and validation refinements

**User Story:** As a player, I want accurate click detection for character movement and object interaction, so that the game correctly interprets my intentions even in visually complex scenes.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Clicks are accurately mapped to world coordinates
  2. Invalid click targets are identified and handled gracefully
  3. Click targets prioritize interactable objects over movement
  4. Click validation accounts for perspective and zoom
  5. Visual feedback indicates valid and invalid click targets

**Implementation Notes:**
- Refine the input_manager.gd click handling
- Add tolerance for click position validation
- Implement priority system for overlapping clickable areas
- Create visual feedback system for click validation
- Ensure cross-system coordination for click handling

### Task 9: Create test scene for walkable area validation

**User Story:** As a developer, I want a test scene for walkable areas, so that I can verify polygon algorithms, boundary detection, and multi-area functionality work correctly.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Test scene includes simple and complex walkable area shapes
  2. Multiple overlapping walkable areas can be tested
  3. Visual feedback shows point-in-polygon results
  4. Boundary detection is visually represented
  5. Path validation against walkable areas can be verified

**Implementation Notes:**
- Create a dedicated scene for walkable area testing
- Include various walkable area configurations
- Add visual feedback for validation results
- Implement testing tools for point-in-polygon checks
- Add controls to toggle between test cases

### Task 10: Enhance system communication through signals

**User Story:** As a developer, I want robust signal-based communication between navigation systems, so that components remain decoupled while still coordinating their behavior effectively.

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Systems communicate state changes through signals
  2. Signal documentation clearly explains usage patterns
  3. Signal connections are properly cleaned up when scenes change
  4. Signals include appropriate data for receiving systems
  5. Signal usage maintains architectural separation of concerns

**Implementation Notes:**
- Define a comprehensive set of navigation-related signals
- Document signal connections and expected behaviors
- Implement proper signal connection cleanup
- Ensure signals maintain component independence
- Create usage examples for common signal patterns

### Task 11: Implement comprehensive debug tools and visualizations

**User Story:** As a developer, I want robust debug tools for the navigation system, so that I can quickly identify and resolve issues during development.

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Visualizations show camera boundaries and movement states
  2. Walkable area validation can be visually verified
  3. Pathfinding and navigation results are visually represented
  4. Coordinate transformations can be visually debugged
  5. Debug tools can be toggled on/off without affecting gameplay
  6. Console output displays click and character destination coordinates

**Implementation Notes:**
- Create visual overlays for camera boundaries
- Implement path visualization for navigation debugging
- Add coordinate transformation visualization
- Create walkable area validation visual tools
- Implement runtime toggle controls for debug features
- Add console logging system for navigation coordinates:
  - Log click position in world coordinates when player clicks to move
  - Log final destination position where character actually moves to
  - Display coordinate differences if final position differs from clicked position
  - Include context info like "Adjusted due to walkable area boundary" or "Path modified due to obstacle"
  - Format output to be easily readable in debug console
  - Implement toggleable verbosity levels (minimal, standard, verbose) for coordinate logging

### Task 12: Create integration test for full navigation system

**User Story:** As a developer, I want comprehensive integration tests for the navigation system, so that I can verify all components work together correctly and prevent regressions.

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Test covers camera, pathfinding, and walkable area integration
  2. All major navigation features can be tested in a single scene
  3. Automated verification procedures are documented
  4. Edge cases and common scenarios are represented
  5. Test results are clear and actionable

**Implementation Notes:**
- Create a comprehensive test scene for all navigation components
- Implement automated test procedures where possible
- Document manual testing steps for complex scenarios
- Include edge cases like boundary conditions
- Ensure test can identify regressions in any navigation component

### Task 13: Create directory structure and base files for the multi-perspective system

**User Story:** As a developer, I want a well-organized foundation for the multi-perspective character system, so that we can build and extend it systematically with minimal refactoring.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. Directory structure follows project conventions
  2. Base classes and interfaces are defined
  3. Documentation clearly explains system organization
  4. Configuration templates are created for all necessary components
  5. Integration points with existing systems are identified and documented

**Implementation Notes:**
- Follow established project directory structures
- Create base abstract classes with clear interfaces
- Document dependencies and extension points
- Prepare configuration templates for both district and character perspectives

### Task 14: Define perspective types enum and configuration templates

**User Story:** As a developer, I want a clear definition of perspective types with configuration templates, so that I can easily create and maintain consistent visual perspectives across the game.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. Perspective types are defined in a central, reusable enum
  2. Configuration templates exist for each perspective type
  3. Templates include all necessary parameters for proper rendering
  4. Documentation explains each perspective type's requirements
  5. Template structure allows easy addition of new perspective types

**Implementation Notes:**
- Create enum for perspective types (ISOMETRIC, SIDE_SCROLLING, TOP_DOWN)
- Implement configuration templates in JSON or GDScript
- Include perspective-specific parameters in templates
- Document requirements for sprites in each perspective
- Design for extensibility to accommodate future perspective types

### Task 15: Extend district base class to support perspective information

**User Story:** As a developer, I want the district system to include perspective information, so that districts can properly communicate their visual style to character controllers.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. BaseDistrict class includes perspective type property
  2. Districts can specify custom perspective parameters
  3. Perspective information is accessible to all relevant systems
  4. Changes to perspective type trigger appropriate signals
  5. System degrades gracefully if perspective information is missing

**Implementation Notes:**
- Add perspective_type property to BaseDistrict class
- Implement get_perspective_params() method
- Add signals for perspective_changed events
- Ensure backward compatibility with existing districts
- Document district perspective configuration

### Task 16: Implement character controller class with animation support

**User Story:** As a player, I want my character's appearance to adapt correctly to different visual perspectives, so that the game maintains visual consistency and immersion.

**Requirements:**
- **Linked to:** B2, B3, U2, T2
- **Acceptance Criteria:**
  1. Character sprites load correctly for each perspective
  2. Animation states (idle, walk, etc.) work in all perspectives
  3. Direction handling adapts to perspective requirements (8-way for isometric, etc.)
  4. Animation transitions are smooth and visually consistent
  5. System integrates with existing animation framework

**Implementation Notes:**
- Extend existing animation system with perspective support
- Implement perspective-specific sprite loading
- Create direction mapping system for each perspective type
- Ensure compatibility with existing animation state machines

### Task 17: Create test character with basic animations

**User Story:** As a developer, I want a test character with basic animations for each perspective, so that I can validate the multi-perspective character system's functionality.

**Requirements:**
- **Linked to:** B2, B3, U2
- **Acceptance Criteria:**
  1. Test character includes sprites for each perspective type
  2. Basic animations (idle, walk) work in all perspectives
  3. Test character can be easily used in different test scenes
  4. Character demonstrates proper perspective transitions
  5. Animation states reflect movement and interaction appropriately

**Implementation Notes:**
- Create test character scene with multi-perspective support
- Implement basic animation sets for each perspective
- Ensure proper integration with animation controller
- Test character in different perspective environments
- Document test character usage for validation

### Task 18: Test animation transitions within a perspective

**User Story:** As a developer, I want to validate animation transitions within each perspective, so that characters animate smoothly during gameplay actions.

**Requirements:**
- **Linked to:** B2, B3, U2
- **Acceptance Criteria:**
  1. Animation transitions are smooth within each perspective
  2. State changes trigger appropriate animation changes
  3. Test scene allows triggering all animation states
  4. Transition timing is appropriate for gameplay feel
  5. Animations maintain visual quality during transitions

**Implementation Notes:**
- Create test scene focused on animation transitions
- Implement controls to trigger different animation states
- Add visual feedback for state transitions
- Test transition timing and visual quality
- Document test procedures for animation validation

### Task 19: Implement movement controller with direction support

**User Story:** As a player, I want my character to move correctly regardless of the visual perspective, so that gameplay feels consistent throughout the game.

**Requirements:**
- **Linked to:** B2, B3, U2, U3, T2
- **Acceptance Criteria:**
  1. Character movement vectors are correctly converted to visual directions
  2. Pathfinding works appropriately in each perspective
  3. Movement speed and physics are consistent across perspectives
  4. Direction changes are visually appropriate for each perspective
  5. Integration with point-and-click navigation is seamless

**Implementation Notes:**
- Create perspective-specific direction conversion methods
- Integrate with refactored navigation system
- Implement direction-to-animation mapping for each perspective
- Ensure consistent movement physics regardless of visual representation

### Task 20: Connect movement controller to point-and-click navigation

**User Story:** As a developer, I want the multi-perspective movement controller to integrate with the point-and-click navigation system, so that players experience consistent controls across all game areas.

**Requirements:**
- **Linked to:** B1, B2, B3, U1, U3
- **Acceptance Criteria:**
  1. Point-and-click input works in all perspective types
  2. Navigation paths adapt to current perspective
  3. Movement controller responds appropriately to navigation commands
  4. Direction changes are visually consistent with perspective
  5. Integration maintains separation of concerns in architecture

**Implementation Notes:**
- Connect movement controller to navigation input events
- Implement perspective-specific path interpretation
- Ensure smooth handoff between navigation and movement systems
- Test integration in different perspective environments
- Document interaction between navigation and movement systems

### Task 21: Test character movement in a single perspective

**User Story:** As a developer, I want comprehensive testing of character movement within each perspective type, so that I can verify movement mechanics work correctly before moving to multi-perspective scenarios.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Test scene exists for each perspective type
  2. Character movement is fluid and responsive in each perspective
  3. Direction handling is appropriate for the perspective
  4. Movement adapts to perspective-specific requirements
  5. Edge cases like boundaries and obstacles are tested

**Implementation Notes:**
- Create test scene for each perspective type
- Include common movement scenarios in each test
- Test direction handling specific to each perspective
- Verify boundary and obstacle interaction
- Document perspective-specific movement behavior

### Task 22: Create test districts with different perspective types

**User Story:** As a developer, I want test districts with different perspective types, so that I can verify the multi-perspective system works correctly across district transitions.

**Requirements:**
- **Linked to:** B2, B3
- **Acceptance Criteria:**
  1. Test districts exist for each perspective type
  2. Districts include proper perspective configuration
  3. Test environment allows for switching between districts
  4. Districts demonstrate consistent visual styling
  5. Districts include properly configured walkable areas

**Implementation Notes:**
- Create test districts for each perspective type
  - Isometric district
  - Side-scrolling district
  - Top-down district
- Configure proper perspective parameters
- Implement inter-district transition points
- Document district configuration and testing

### Task 23: Implement perspective switching in character controller

**User Story:** As a developer, I want the character controller to handle perspective switching seamlessly, so that characters maintain appropriate behavior when moving between different districts.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Character detects perspective changes when entering new districts
  2. Sprite and animation transitions are handled gracefully
  3. Movement behavior adapts to new perspective
  4. Character maintains logical position during transitions
  5. Perspective switching is robust against race conditions

**Implementation Notes:**
- Implement perspective detection in character controller
- Create smooth transition between perspective-specific sprites
- Develop coordinate transformation for district transitions
- Handle edge cases in perspective switching
- Document perspective switching behavior and requirements

### Task 24: Create test for transitions between different perspective districts

**User Story:** As a developer, I want comprehensive tests for character transitions between perspective types, so that I can verify the multi-perspective system functions correctly in real gameplay scenarios.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Test covers transitions between all perspective combinations
  2. Character maintains appropriate appearance during transitions
  3. Movement and controls remain consistent across transitions
  4. Position and direction are properly preserved during transitions
  5. Test identifies potential issues in perspective switching

**Implementation Notes:**
- Create comprehensive test scene with multiple district transitions
- Implement visual feedback for transition events
- Test all perspective combination transitions
- Verify position and state preservation during transitions
- Document test procedures for perspective transitions

### Task 25: Create comprehensive documentation for both systems

**User Story:** As a developer, I want clear documentation for both the navigation and multi-perspective systems, so that I can understand, maintain, and extend these systems effectively.

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Architecture and design decisions are clearly documented
  2. API references include all public methods and properties
  3. Usage examples cover common scenarios
  4. Integration patterns with other systems are explained
  5. Diagrams illustrate component relationships and data flow
  6. Testing approaches and validation methods are described

**Implementation Notes:**
- Create separate documentation files for each major component
- Include code examples for common usage patterns
- Document signal connections and communication patterns
- Create diagrams showing system architecture
- Include troubleshooting section for common issues

### Task 26: Perform code review and optimization

**User Story:** As a developer, I want a thorough code review and optimization pass for both systems, so that the code remains maintainable and performs well in all scenarios.

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. All code passes established quality standards
  2. Performance is optimized for complex scenes
  3. Memory usage is appropriate for the functionality
  4. Code follows architectural principles consistently
  5. Technical debt is identified and addressed

**Implementation Notes:**
- Perform comprehensive code review of navigation system
- Review multi-perspective character system implementation
- Identify and resolve performance bottlenecks
- Run profiling tests for memory and CPU usage
- Document optimization strategies and decisions

### Task 27: Update existing documentation to reflect new systems

**User Story:** As a developer, I want all existing documentation updated to reflect the new navigation and multi-perspective systems, so that documentation remains accurate and comprehensive.

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Architecture documentation reflects new systems
  2. Existing tutorials and guides incorporate new functionality
  3. API references are updated to include new methods and properties
  4. Integration examples show how to use new systems with existing code
  5. Documentation maintains consistent style and quality

**Implementation Notes:**
- Update architecture.md with new system information
- Revise existing navigation documentation
- Add multi-perspective system to relevant docs
- Update code examples to use new functionality
- Ensure cross-referencing between related documentation

**User Story:** As a player, I want the camera to correctly synchronize with my character's movement and game events, so that I always have a clear view of relevant gameplay elements without jarring transitions.

**Requirements:**
- **Linked to:** B1, U1, T1
- **Acceptance Criteria:**
  1. Camera emits signals when it starts and completes movement
  2. Camera tracks its current state (IDLE, MOVING, FOLLOWING_PLAYER)
  3. Other systems can connect to camera signals to coordinate their behavior
  4. Camera state transitions are clearly defined and predictable
  5. Status signals include relevant data like target positions and bounds
  6. UI elements can synchronize animations with camera movements
  7. Player interactions remain responsive during camera transitions

**Implementation Notes:**
- Add signal definitions to ScrollingCamera class
- Implement state tracking variables and enum definitions
- Create state transition methods with signal emission
- Add documentation for signal usage
- Ensure signal emission follows architectural principles
- Create helper methods for common signal connection patterns

### Task 3: Create test scene for validating camera system improvements

**User Story:** As a developer, I want a dedicated test scene for the camera system, so that I can verify its functionality and easily detect regressions during development.

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Test scene includes various camera movement scenarios
  2. Scene provides visual feedback for coordinate transformations
  3. Controls allow testing different camera views and movements
  4. Debug visualization shows camera states and signals
  5. Test scene can verify all camera enhancements

**Implementation Notes:**
- Create a dedicated scene file for camera testing
- Implement test controls for triggering different camera behaviors
- Add visual indicators for coordinate transformations
- Include debug overlay for state and signal monitoring
- Document test procedures for consistent verification

**Design Documentation:**
- See `docs/design/camera_test_scene_design.md` for comprehensive design specifications
- Includes practical test backgrounds using in-game environments
- Details UI panel architecture for different testing modes
- Provides visual validation procedures for preventing regressions

### Task 5: Implement proper pathfinding with Navigation2D

**User Story:** As a player, I want my character to intelligently navigate around obstacles, so that I don't have to micromanage movement through complex environments.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Character finds optimal paths around obstacles
  2. Pathfinding accounts for walkable area boundaries
  3. Path smoothing eliminates unnatural zigzag movement
  4. Dynamic obstacles are handled appropriately
  5. Pathfinding performance remains good in complex environments

**Implementation Notes:**
- Integrate Godot's Navigation2D system for path generation
- Implement path smoothing algorithm for natural movement
- Create NavigationObstacle2D instances for dynamic obstacles
- Ensure paths respect walkable area boundaries
- Optimize for performance in complex scenes

### Task 6: Create test scene for player movement validation

**User Story:** As a developer, I want a test scene for player movement, so that I can verify movement physics, pathfinding, and obstacle avoidance work correctly.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Test scene includes different movement scenarios
  2. Complex obstacle configurations can be tested
  3. Visual feedback shows pathfinding results
  4. Movement metrics (speed, acceleration) are displayed
  5. All movement states can be tested and verified

**Implementation Notes:**
- Create a dedicated scene for movement testing
- Include various obstacle configurations
- Add visual path display for debugging
- Include movement parameter controls for testing
- Add monitoring tools for physics values

### Task 8: Implement click detection and validation refinements

**User Story:** As a player, I want accurate click detection for character movement and object interaction, so that the game correctly interprets my intentions even in visually complex scenes.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Clicks are accurately mapped to world coordinates
  2. Invalid click targets are identified and handled gracefully
  3. Click targets prioritize interactable objects over movement
  4. Click validation accounts for perspective and zoom
  5. Visual feedback indicates valid and invalid click targets

**Implementation Notes:**
- Refine the input_manager.gd click handling
- Add tolerance for click position validation
- Implement priority system for overlapping clickable areas
- Create visual feedback system for click validation
- Ensure cross-system coordination for click handling

### Task 9: Create test scene for walkable area validation

**User Story:** As a developer, I want a test scene for walkable areas, so that I can verify polygon algorithms, boundary detection, and multi-area functionality work correctly.

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Test scene includes simple and complex walkable area shapes
  2. Multiple overlapping walkable areas can be tested
  3. Visual feedback shows point-in-polygon results
  4. Boundary detection is visually represented
  5. Path validation against walkable areas can be verified

**Implementation Notes:**
- Create a dedicated scene for walkable area testing
- Include various walkable area configurations
- Add visual feedback for validation results
- Implement testing tools for point-in-polygon checks
- Add controls to toggle between test cases

### Task 10: Enhance system communication through signals

**User Story:** As a developer, I want robust signal-based communication between navigation systems, so that components remain decoupled while still coordinating their behavior effectively.

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Systems communicate state changes through signals
  2. Signal documentation clearly explains usage patterns
  3. Signal connections are properly cleaned up when scenes change
  4. Signals include appropriate data for receiving systems
  5. Signal usage maintains architectural separation of concerns

**Implementation Notes:**
- Define a comprehensive set of navigation-related signals
- Document signal connections and expected behaviors
- Implement proper signal connection cleanup
- Ensure signals maintain component independence
- Create usage examples for common signal patterns

### Task 11: Implement comprehensive debug tools and visualizations

**User Story:** As a developer, I want robust debug tools for the navigation system, so that I can quickly identify and resolve issues during development.

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Visualizations show camera boundaries and movement states
  2. Walkable area validation can be visually verified
  3. Pathfinding and navigation results are visually represented
  4. Coordinate transformations can be visually debugged
  5. Debug tools can be toggled on/off without affecting gameplay
  6. Console output displays click and character destination coordinates

**Implementation Notes:**
- Create visual overlays for camera boundaries
- Implement path visualization for navigation debugging
- Add coordinate transformation visualization
- Create walkable area validation visual tools
- Implement runtime toggle controls for debug features
- Add console logging system for navigation coordinates:
  - Log click position in world coordinates when player clicks to move
  - Log final destination position where character actually moves to
  - Display coordinate differences if final position differs from clicked position
  - Include context info like "Adjusted due to walkable area boundary" or "Path modified due to obstacle"
  - Format output to be easily readable in debug console
  - Implement toggleable verbosity levels (minimal, standard, verbose) for coordinate logging

### Task 12: Create integration test for full navigation system

**User Story:** As a developer, I want comprehensive integration tests for the navigation system, so that I can verify all components work together correctly and prevent regressions.

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Test covers camera, pathfinding, and walkable area integration
  2. All major navigation features can be tested in a single scene
  3. Automated verification procedures are documented
  4. Edge cases and common scenarios are represented
  5. Test results are clear and actionable

**Implementation Notes:**
- Create a comprehensive test scene for all navigation components
- Implement automated test procedures where possible
- Document manual testing steps for complex scenarios
- Include edge cases like boundary conditions
- Ensure test can identify regressions in any navigation component

### Task 14: Define perspective types enum and configuration templates

**User Story:** As a developer, I want a clear definition of perspective types with configuration templates, so that I can easily create and maintain consistent visual perspectives across the game.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. Perspective types are defined in a central, reusable enum
  2. Configuration templates exist for each perspective type
  3. Templates include all necessary parameters for proper rendering
  4. Documentation explains each perspective type's requirements
  5. Template structure allows easy addition of new perspective types

**Implementation Notes:**
- Create enum for perspective types (ISOMETRIC, SIDE_SCROLLING, TOP_DOWN)
- Implement configuration templates in JSON or GDScript
- Include perspective-specific parameters in templates
- Document requirements for sprites in each perspective
- Design for extensibility to accommodate future perspective types

### Task 15: Extend district base class to support perspective information

**User Story:** As a developer, I want the district system to include perspective information, so that districts can properly communicate their visual style to character controllers.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. BaseDistrict class includes perspective type property
  2. Districts can specify custom perspective parameters
  3. Perspective information is accessible to all relevant systems
  4. Changes to perspective type trigger appropriate signals
  5. System degrades gracefully if perspective information is missing

**Implementation Notes:**
- Add perspective_type property to BaseDistrict class
- Implement get_perspective_params() method
- Add signals for perspective_changed events
- Ensure backward compatibility with existing districts
- Document district perspective configuration

### Task 17: Create test character with basic animations

**User Story:** As a developer, I want a test character with basic animations for each perspective, so that I can validate the multi-perspective character system's functionality.

**Requirements:**
- **Linked to:** B2, B3, U2
- **Acceptance Criteria:**
  1. Test character includes sprites for each perspective type
  2. Basic animations (idle, walk) work in all perspectives
  3. Test character can be easily used in different test scenes
  4. Character demonstrates proper perspective transitions
  5. Animation states reflect movement and interaction appropriately

**Implementation Notes:**
- Create test character scene with multi-perspective support
- Implement basic animation sets for each perspective
- Ensure proper integration with animation controller
- Test character in different perspective environments
- Document test character usage for validation

### Task 18: Test animation transitions within a perspective

**User Story:** As a developer, I want to validate animation transitions within each perspective, so that characters animate smoothly during gameplay actions.

**Requirements:**
- **Linked to:** B2, B3, U2
- **Acceptance Criteria:**
  1. Animation transitions are smooth within each perspective
  2. State changes trigger appropriate animation changes
  3. Test scene allows triggering all animation states
  4. Transition timing is appropriate for gameplay feel
  5. Animations maintain visual quality during transitions

**Implementation Notes:**
- Create test scene focused on animation transitions
- Implement controls to trigger different animation states
- Add visual feedback for state transitions
- Test transition timing and visual quality
- Document test procedures for animation validation

### Task 20: Connect movement controller to point-and-click navigation

**User Story:** As a developer, I want the multi-perspective movement controller to integrate with the point-and-click navigation system, so that players experience consistent controls across all game areas.

**Requirements:**
- **Linked to:** B1, B2, B3, U1, U3
- **Acceptance Criteria:**
  1. Point-and-click input works in all perspective types
  2. Navigation paths adapt to current perspective
  3. Movement controller responds appropriately to navigation commands
  4. Direction changes are visually consistent with perspective
  5. Integration maintains separation of concerns in architecture

**Implementation Notes:**
- Connect movement controller to navigation input events
- Implement perspective-specific path interpretation
- Ensure smooth handoff between navigation and movement systems
- Test integration in different perspective environments
- Document interaction between navigation and movement systems

### Task 21: Test character movement in a single perspective

**User Story:** As a developer, I want comprehensive testing of character movement within each perspective type, so that I can verify movement mechanics work correctly before moving to multi-perspective scenarios.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Test scene exists for each perspective type
  2. Character movement is fluid and responsive in each perspective
  3. Direction handling is appropriate for the perspective
  4. Movement adapts to perspective-specific requirements
  5. Edge cases like boundaries and obstacles are tested

**Implementation Notes:**
- Create test scene for each perspective type
- Include common movement scenarios in each test
- Test direction handling specific to each perspective
- Verify boundary and obstacle interaction
- Document perspective-specific movement behavior

### Task 22: Create test districts with different perspective types

**User Story:** As a developer, I want test districts with different perspective types, so that I can verify the multi-perspective system works correctly across district transitions.

**Requirements:**
- **Linked to:** B2, B3
- **Acceptance Criteria:**
  1. Test districts exist for each perspective type
  2. Districts include proper perspective configuration
  3. Test environment allows for switching between districts
  4. Districts demonstrate consistent visual styling
  5. Districts include properly configured walkable areas

**Implementation Notes:**
- Create test districts for each perspective type
  - Isometric district
  - Side-scrolling district
  - Top-down district
- Configure proper perspective parameters
- Implement inter-district transition points
- Document district configuration and testing

### Task 23: Implement perspective switching in character controller

**User Story:** As a developer, I want the character controller to handle perspective switching seamlessly, so that characters maintain appropriate behavior when moving between different districts.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Character detects perspective changes when entering new districts
  2. Sprite and animation transitions are handled gracefully
  3. Movement behavior adapts to new perspective
  4. Character maintains logical position during transitions
  5. Perspective switching is robust against race conditions

**Implementation Notes:**
- Implement perspective detection in character controller
- Create smooth transition between perspective-specific sprites
- Develop coordinate transformation for district transitions
- Handle edge cases in perspective switching
- Document perspective switching behavior and requirements

### Task 24: Create test for transitions between different perspective districts

**User Story:** As a developer, I want comprehensive tests for character transitions between perspective types, so that I can verify the multi-perspective system functions correctly in real gameplay scenarios.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Test covers transitions between all perspective combinations
  2. Character maintains appropriate appearance during transitions
  3. Movement and controls remain consistent across transitions
  4. Position and direction are properly preserved during transitions
  5. Test identifies potential issues in perspective switching

**Implementation Notes:**
- Create comprehensive test scene with multiple district transitions
- Implement visual feedback for transition events
- Test all perspective combination transitions
- Verify position and state preservation during transitions
- Document test procedures for perspective transitions

### Task 26: Perform code review and optimization

**User Story:** As a developer, I want a thorough code review and optimization pass for both systems, so that the code remains maintainable and performs well in all scenarios.

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. All code passes established quality standards
  2. Performance is optimized for complex scenes
  3. Memory usage is appropriate for the functionality
  4. Code follows architectural principles consistently
  5. Technical debt is identified and addressed

**Implementation Notes:**
- Perform comprehensive code review of navigation system
- Review multi-perspective character system implementation
- Identify and resolve performance bottlenecks
- Run profiling tests for memory and CPU usage
- Document optimization strategies and decisions

### Task 27: Update existing documentation to reflect new systems

**User Story:** As a developer, I want all existing documentation updated to reflect the new navigation and multi-perspective systems, so that documentation remains accurate and comprehensive.

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Architecture documentation reflects new systems
  2. Existing tutorials and guides incorporate new functionality
  3. API references are updated to include new methods and properties
  4. Integration examples show how to use new systems with existing code
  5. Documentation maintains consistent style and quality

**Implementation Notes:**
- Update architecture.md with new system information
- Revise existing navigation documentation
- Add multi-perspective system to relevant docs
- Update code examples to use new functionality
- Ensure cross-referencing between related documentation


### Task 28: Create simple POC test sprites for perspective scaling validation

**User Story:** As a developer, I want simple geometric test sprites at multiple scales, so that I can validate the perspective scaling system without complex art assets.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. Test sprites created as simple colored shapes (squares/rectangles)
  2. Multiple sizes available (32x32, 48x48, 64x64, 96x96) for scale testing
  3. Each sprite includes directional indicator (arrow) for rotation validation
  4. Distinct colors used for easy visual tracking during tests
  5. Sprites generated via script for reproducibility

**Implementation Notes:**
- Create generate_poc_sprites.sh script using ImageMagick
- Generate sprites in standard sizes with arrow indicators
- Use high-contrast colors from the canonical palette
- Store in src/assets/test_sprites/ directory
- Document sprite generation process for future reference

### Task 29: Implement basic sprite perspective scaling system

**User Story:** As a developer, I want sprites to scale based on Y-position in perspective backgrounds, so that depth illusion is maintained in scenes with visual perspective.

**Requirements:**
- **Linked to:** B2, B3, U2, T2
- **Acceptance Criteria:**
  1. Sprites scale smaller when positioned higher in scene (further away)
  2. Scaling transitions smoothly as sprites move vertically
  3. Movement speed adjusts proportionally with sprite scale
  4. Z-index properly sorts sprites by depth (Y-position)
  5. System integrates cleanly with existing coordinate and camera systems

**Implementation Notes:**
- Implement simplified Y-position based scaling for initial POC
- Create PerspectiveController component attachable to any Node2D
- Add scaling configuration to district/scene settings
- Ensure compatibility with both GAME_VIEW and WORLD_VIEW modes
- Follow architectural principles with minimal coupling

### Task 30: Create sprite scaling test scene for validation

**User Story:** As a developer, I want a dedicated test scene for sprite scaling, so that I can validate perspective effects work correctly with different backgrounds and movement patterns.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. Test scene allows loading different camera test backgrounds
  2. Multiple test sprites can be placed and moved interactively
  3. Debug overlay shows current scale, z-index, and speed values
  4. Controls allow toggling scaling on/off for comparison
  5. Scene validates scaling with all 8 camera test backgrounds

**Implementation Notes:**
- Create dedicated test scene src/test/sprite_scaling_test.tscn
- Include UI controls for background switching
- Add debug visualization for scaling zones/gradients
- Implement movement controls for testing dynamic scaling
- Document test procedures for validation


### Task 31: Create audio system directory structure and core architecture

**User Story:** As a developer, I want to establish the foundational audio system architecture and file structure, so that all future audio development builds on a solid, well-organized base.

**Requirements:**
- **Linked to:** B2, B3, T2
- **Acceptance Criteria:**
  1. Directory structure created at src/core/audio/ with proper organization
  2. Asset directories established at src/assets/audio/ with subdirectories
  3. Basic audio bus hierarchy configured in Godot project settings
  4. Architecture follows singleton and component patterns from docs/design/audio_system_iteration3_mvp.md
  5. All structures align with the full implementation plan in docs/design/audio_system_technical_implementation.md

**Implementation Notes:**
- Create directories: src/core/audio/, src/assets/audio/test/, src/assets/audio/placeholder/
- Set up basic bus structure: Master -> Music, Ambience, SFX
- Follow architectural principles from existing systems
- Reference: docs/design/audio_system_iteration3_mvp.md - Phase 1

### Task 32: Implement basic AudioManager singleton

**User Story:** As a developer, I want a central AudioManager singleton that tracks the player's position and manages all diegetic audio sources, so that audio can respond dynamically to player movement.

**Requirements:**
- **Linked to:** B2, B3, T1, T2
- **Acceptance Criteria:**
  1. AudioManager singleton implemented following existing singleton patterns
  2. Tracks listener position and scale from player updates
  3. Updates all registered diegetic audio sources efficiently
  4. Integrates cleanly with existing game systems
  5. Provides foundation for future district audio features

**Implementation Notes:**
- Implement src/core/audio/audio_manager.gd as described in docs/design/audio_system_iteration3_mvp.md
- Follow singleton pattern from CoordinateManager
- Keep implementation simple but extensible
- Add to autoload in project settings

### Task 33: Create simplified DiegeticAudioController component

**User Story:** As a developer, I want a reusable audio component that automatically adjusts volume based on distance from the player, so that we can easily add spatial audio to any game object.

**Requirements:**
- **Linked to:** B2, B3, U2
- **Acceptance Criteria:**
  1. DiegeticAudioController extends AudioStreamPlayer2D
  2. Implements distance-based volume attenuation
  3. Integrates with perspective scaling for volume adjustment
  4. Automatically registers/unregisters with AudioManager
  5. Performance-optimized for multiple simultaneous sources

**Implementation Notes:**
- Create src/core/audio/diegetic_audio_controller.gd per docs/design/audio_system_iteration3_mvp.md
- Use Godot's built-in attenuation as base
- Add perspective scale influence as multiplier
- Include min/max distance configuration
- Optimize for ~10-20 simultaneous sources

### Task 34: Implement diegetic audio scaling system for perspective immersion

**User Story:** As a player, I want environmental sounds to naturally fade and pan based on my position and distance, so that the game world feels spatially realistic and immersive.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Audio sources in game world scale volume based on distance from player
  2. Volume scaling considers both distance and perspective scale
  3. Stereo panning reflects horizontal position relative to player
  4. Distant audio sources stop playing for performance optimization
  5. Audio ranges are visually indicated in debug/editor mode

**Implementation Notes:**
- Create DiegeticAudioSource component extending AudioStreamPlayer2D
- Integrate with PerspectiveController to update audio based on player position
- Support custom falloff curves for different audio types
- Add min/max distance parameters for audio range
- Consider perspective scale as secondary factor in volume calculation
- Implement audio source grouping for efficient updates
- Test with various ambient sounds (machinery, crowds, computers, etc.)

### Task 35: Integrate audio with perspective scaling system

**User Story:** As a player, I want audio volume to reflect not just distance but also the visual perspective scale, so that sounds feel naturally integrated with the visual depth of the scene.

**Requirements:**
- **Linked to:** B2, B3, U2, U3
- **Acceptance Criteria:**
  1. Audio volume scales with both distance AND visual perspective scale
  2. Integration works seamlessly with Task 29's perspective system
  3. Audio maintains proper volume relationships at different scales
  4. Player's current scale affects how they hear the environment
  5. Debug visualization shows audio influence of perspective

**Implementation Notes:**
- Modify DiegeticAudioController to read perspective scale
- Connect with PerspectiveController from Task 29
- Use scale as secondary factor (not primary) in volume calculation
- Test with different perspective backgrounds
- Reference: docs/design/sprite_perspective_scaling_plan.md - Audio Requirements

### Task 36: Create audio foundation test scene and verify integration

**User Story:** As a developer, I want a comprehensive test scene for the audio MVP, so that I can verify all audio systems work correctly and establish a testing baseline for future development.

**Requirements:**
- **Linked to:** B2, B3, T1
- **Acceptance Criteria:**
  1. Test scene includes multiple DiegeticAudioController instances
  2. Integrates with existing camera test backgrounds
  3. UI controls for testing audio parameters
  4. Debug overlay shows audio source states
  5. Performance metrics displayed for optimization

**Implementation Notes:**
- Create src/test/audio_foundation_test.tscn
- Place 3-4 audio sources at different positions
- Include controls for volume, distance parameters
- Test with player movement and perspective changes
- Document testing procedures for future use
- Reference: docs/design/audio_system_iteration3_mvp.md - Phase 3

### Task 37: Create ForegroundOcclusionManager singleton for Y-position based sprite layering

**User Story:** As a player, I want to see my character naturally pass behind objects in the environment, so that the game world feels more three-dimensional and immersive.

**Requirements:**
- **Linked to:** B2, U2, T2
- **Acceptance Criteria:**
  1. Singleton manager tracks player position and foreground elements
  2. Z-index updates based on Y-position comparison
  3. Smooth transitions when crossing occlusion thresholds
  4. Minimal performance impact (< 0.1ms per frame)
  5. Clean integration with existing coordinate system

**Implementation Notes:**
- Create src/core/rendering/foreground_occlusion_manager.gd
- Use simple Y-position comparison for MVP
- Update only when player Y changes significantly
- Leverage existing coordinate transformations
- Reference: docs/design/foreground_occlusion_mvp_plan.md

### Task 38: Implement basic foreground element loading in base_district.gd

**User Story:** As a developer, I want districts to automatically load and manage foreground elements, so that adding visual depth to new areas is straightforward and consistent.

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Districts load foreground elements from JSON configuration
  2. Elements are properly positioned and initialized
  3. Registration with ForegroundOcclusionManager works correctly
  4. Unloading/cleanup happens on district exit
  5. Error handling for missing assets

**Implementation Notes:**
- Extend base_district.gd with load_foreground_elements()
- Create ForegroundLayer node structure
- Register elements with occlusion manager
- Follow existing animated_elements pattern
- Reference: docs/design/foreground_occlusion_mvp_plan.md - District Integration

### Task 39: Extend district JSON configuration for foreground elements

**User Story:** As a developer, I want a simple configuration format for foreground elements, so that I can quickly add occlusion objects without writing code.

**Requirements:**
- **Linked to:** T2
- **Acceptance Criteria:**
  1. JSON schema supports foreground_elements array
  2. Each element has sprite_path, position, and occlusion_y
  3. Configuration validates on load
  4. Clear error messages for invalid configurations
  5. Documentation includes examples

**Implementation Notes:**
- Extend existing district JSON format
- Add foreground_elements section
- Support position and occlusion_y properties
- Create validation helper functions
- Update district configuration documentation

### Task 40: Create test foreground sprites for camera test backgrounds

**User Story:** As a developer, I want test foreground sprites for the camera test backgrounds, so that I can validate the occlusion system works correctly in various scenarios.

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Extract 2-3 foreground elements from each test background
  2. Apply consistent 32-bit styling
  3. Transparent backgrounds with clean edges
  4. Appropriate occlusion Y-values set
  5. Test various object sizes and shapes

**Implementation Notes:**
- Use ImageMagick to extract elements
- Apply existing 32-bit processing pipeline
- Create foreground/ subdirectory for each background
- Document extraction process
- Reference: Trading floor annotated example

### Task 41: Build foreground occlusion test scene with debug visualization

**User Story:** As a developer, I want a dedicated test scene for the foreground occlusion system, so that I can verify correct behavior and debug issues efficiently.

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Test scene includes multiple foreground elements
  2. Debug overlay shows Y-thresholds and Z-indices
  3. Player movement controls for testing
  4. Performance metrics displayed
  5. Easy to add new test cases

**Implementation Notes:**
- Create src/test/foreground_occlusion_test.tscn
- Include debug visualization toggles
- Show occlusion thresholds as horizontal lines
- Display current Z-indices for all elements
- Test with camera test backgrounds
- Reference: docs/design/foreground_occlusion_mvp_plan.md - Testing Strategy
