# Scrolling Camera System Documentation

## Overview

The Scrolling Camera System enables players to explore backgrounds larger than the screen boundaries in A Silent Refraction. This feature is a core requirement for creating immersive, spacious environments that players can navigate through using point-and-click interactions.

This document provides a comprehensive understanding of the system, its current implementation status, planned enhancements, and how it integrates with the game's architecture.

## Requirements (Iteration 2, Task 6)

### Technical Requirement T2
> **T2:** Implement a scrolling background system that enables environments larger than the game window
> - **Rationale:** Point-and-click adventures require expansive environments to explore, which necessitates a system for handling backgrounds larger than the visible screen area
> - **Constraints:** Must maintain performance with large image files and integrate seamlessly with walkable area and navigation systems

### User Story
> **As a player,** I want to explore scrolling backgrounds in the Shipping District that extend beyond the screen boundaries, **so that** I can experience larger, more immersive environments that feel like real spaces rather than confined screens.

### Acceptance Criteria
1. Background image loads properly and extends beyond screen boundaries
2. Scene can designate starting position (left, middle, right) within the background
3. Walkable areas are properly defined across the entire background
4. Camera smoothly scrolls to follow player when approaching screen boundaries
5. Player movement remains consistent across screen transitions
6. Visual style follows the game's aesthetic guidelines

## Current Implementation

### Core Components

1. **ScrollingCamera (src/core/camera/scrolling_camera.gd)**
   - Extends Camera2D to handle larger-than-screen backgrounds
   - Provides smooth scrolling when player approaches screen edges
   - Offers various easing functions for camera movement
   - Supports different initial camera positions (left, center, right)
   - Includes comprehensive debug visualization capabilities

2. **BaseDistrict (src/core/districts/base_district.gd)**
   - Contains properties for configuring the scrolling camera:
     - `use_scrolling_camera`: Flag to enable/disable scrolling camera
     - `camera_follow_smoothing`: Camera smoothing factor for movement
     - `camera_edge_margin`: Distance from screen edge that triggers scrolling
     - `initial_camera_view`: Starting position ("left", "right", "center")
     - `camera_initial_position`: Optional explicit starting position
     - `camera_easing_type`: Easing function for camera movement
   - Manages walkable areas that define player movement boundaries
   - Provides methods to set up and configure scrolling camera

3. **ScrollingCameraTest (src/test/scrolling_camera_test.gd)**
   - Test scene that demonstrates the scrolling camera system
   - Shows how to set up a district with scrolling camera
   - Provides interactive testing of camera features (easing, zoom, view)

### Key Features

1. **Automatic Background Scaling**
   - Automatically scales background to fill viewport height
   - Preserves aspect ratio while ensuring screen coverage
   - Handles large backgrounds efficiently

2. **Intelligent Boundary Management**
   - Uses walkable area polygons to define camera movement boundaries
   - Prevents camera from showing empty/non-game areas
   - Accommodates different background dimensions

3. **Smooth Movement**
   - Multiple easing functions for camera movement:
     - LINEAR, EASE_IN, EASE_OUT, EASE_IN_OUT, EXPONENTIAL, SINE, ELASTIC, CUBIC, QUAD
   - Configurable smoothing factor
   - Handles edge cases to prevent stuttering or visual artifacts

4. **Flexible Initial Positioning**
   - Supports three standard positions: left, center, right
   - Allows custom initial position when needed
   - Uses logical positioning based on background dimensions

5. **Debug Capabilities**
   - Visual representation of camera boundaries
   - Real-time display of camera and player positions
   - Coordinate picking for walkable area definition

## Integration With Shipping District

The Shipping District currently requires implementation of the scrolling camera system with the following specifications:

1. **Background Configuration**
   - Background image extends beyond screen boundaries (approx. 3000x1500px)
   - Walkable areas defined across the broader environment
   - Visual style matches the game's aesthetic guidelines

2. **Camera Setup**
   - Initial position shows the right side of the district (docking area)
   - Smooth scrolling based on player movement
   - Boundaries properly constrained to walkable areas

3. **Player Experience**
   - Player can move across the entire district with the camera following smoothly
   - Screen transitions feel natural and consistent
   - Walkable areas remain accurate regardless of camera position

## Implementation Tasks

To complete the scrolling camera implementation for the Shipping District:

1. **Update the shipping_district.gd script:**
   - Enable scrolling camera (`use_scrolling_camera = true`)
   - Configure camera parameters (smoothing, margins, initial view)
   - Ensure background_size is properly set based on actual background dimensions

2. **Adjust the shipping_district.tscn scene:**
   - Verify or update background sprite configuration
   - Ensure walkable areas are defined across the entire background
   - Test integration with interactive objects

3. **Create a wider background for the shipping district:**
   - Design a background image approximately 3000px wide
   - Follow visual style guidelines
   - Ensure proper import settings for optimal performance

4. **Testing:**
   - Verify the camera follows the player correctly
   - Ensure smooth scrolling with appropriate easing
   - Check walkable area boundaries across the entire background
   - Test different starting positions (left, center, right)
   - Ensure all interactive objects remain functional

## Technical Details

### Camera Movement Logic

The camera movement is handled through a series of steps:

1. **Edge Detection:** The system checks if the player approaches a defined margin from the screen edge
2. **Target Position Calculation:** If the player crosses the margin, a new camera position is calculated
3. **Bounds Clamping:** The target position is clamped to ensure the camera stays within defined boundaries
4. **Smooth Movement:** The camera position is interpolated using the selected easing function
5. **Safety Checks:** Additional checks ensure the player remains visible at all times

### Walkable Area Integration

Walkable areas are critical for proper camera operation:

1. Districts define polygons representing walkable areas
2. Camera calculates its boundaries based on these polygons
3. The system expands the bounds slightly to provide visual context
4. Camera movement is constrained within these calculated bounds

### Performance Considerations

For optimal performance with large backgrounds:

1. Use appropriate texture compression for background images
2. Consider splitting very large backgrounds into sections if needed
3. Memory optimization techniques should be applied for large assets
4. Ensure walkable areas are defined efficiently (not too many vertices)

## Debug & Testing Tools

The system includes several tools to help with debugging and testing:

1. **Debug Drawing:** Visual representation of camera boundaries, margins, and viewports
2. **Debug Console:** Commands to control camera properties at runtime
3. **Coordinate Picker:** Tool to help define walkable areas accurately
4. **Test Controls:** Keys to test different camera behaviors:
   - E: Cycle through easing functions
   - V: Toggle between partial view and full background view
   - Z: Cycle through zoom levels

## API Reference

### ScrollingCamera Properties

| Property | Type | Description |
|----------|------|-------------|
| `follow_player` | bool | Whether camera should follow the player |
| `follow_smoothing` | float | Smoothing factor for camera movement |
| `edge_margin` | Vector2 | Distance from edge that triggers scrolling |
| `bounds_enabled` | bool | Whether camera should respect boundaries |
| `initial_position` | Vector2 | Custom initial camera position |
| `initial_view` | String | Which part to show initially: "left", "right", "center" |
| `easing_type` | Enum | Type of easing to use for camera movement |
| `auto_adjust_zoom` | bool | Whether to automatically adjust zoom to fill viewport |

### BaseDistrict Methods

| Method | Description |
|--------|-------------|
| `setup_scrolling_camera()` | Sets up scrolling camera for the district |
| `update_bounds()` | Updates camera bounds based on walkable areas |
| `force_update_scroll()` | Force camera to update its position immediately |
| `calculate_optimal_zoom()` | Calculate optimal zoom level to ensure background fills viewport |

## Future Enhancements

Potential improvements for the scrolling camera system:

1. **Multi-layer parallax backgrounds** for depth perception
2. **Camera zones** that define special camera behaviors in specific areas
3. **Transition effects** when moving between districts
4. **Camera focusing** on important objects or events
5. **Screen edge interaction** for district transitions

## Conclusion

The Scrolling Camera System is a crucial component for creating immersive, expansive environments in A Silent Refraction. When properly implemented in the Shipping District, it will allow players to experience a more realistic and engaging game world that extends beyond the confines of a single screen.