# Standard Background Dimensions

This document defines the standard background dimensions and camera behavior for different view types in A Silent Refraction. Adhering to these standards ensures consistent camera behavior and optimal performance across all game scenes.

## Background Categories

The game uses four primary background types, each with specific dimensions and camera behavior patterns:

### 1. Wide 2D Scrolling

Used for side-scrolling areas with significant horizontal movement, such as corridors, hallways, and large rooms that extend beyond the screen width.

**Specifications:**
- **Width:** 2448 pixels (based on test_background.png)
- **Height:** 496 pixels
- **Aspect Ratio:** ~5:1
- **Example:** Shipping district corridors, station hallways

**Camera Behavior:**
- Camera scrolls horizontally as the player moves
- Supports different initial views (left, center, right)
- Follows player with smooth margins from screen edges
- World view shows the entire background at once

**Implementation Notes:**
- Background sprite should use `centered = false`
- Walkable area should define the floor region
- Scroll boundaries calculated from background dimensions
- Use camera's edge_margin property to control when scrolling begins

### 2. Close Isometric (No Scrolling)

Used for self-contained isometric rooms that fit entirely on one screen with no need for camera movement.

**Specifications:**
- **Width:** [To be determined]
- **Height:** [To be determined]
- **Aspect Ratio:** [To be determined]
- **Example:** Small offices, individual rooms, compact areas

**Camera Behavior:**
- Camera remains fixed at center position
- No scrolling required
- World view is identical to game view (no scaling needed)

**Implementation Notes:**
- Background sprite should use `centered = true`
- Camera should be positioned at the center of the scene
- No edge scrolling required
- Set camera's `follow_player = false`

### 3. Far Isometric (With Scrolling)

Used for larger isometric areas that require camera movement to see the entire space.

**Specifications:**
- **Width:** [To be determined]
- **Height:** [To be determined]
- **Aspect Ratio:** [To be determined]
- **Example:** Large halls, open areas, multi-room sections

**Camera Behavior:**
- Camera follows player with smooth scrolling
- Supports different initial views (corners, center)
- Maintains isometric perspective during movement
- World view shows the entire background

**Implementation Notes:**
- Background sprite should use `centered = true`
- Walkable area defines bounds for player movement
- Camera boundaries calculated from background dimensions
- Consider adaptive margins based on room dimensions

### 4. Top-Down Map (No Scrolling)

Used for map-style top-down views that show an entire area at once without scrolling.

**Specifications:**
- **Width:** [To be determined]
- **Height:** [To be determined]
- **Aspect Ratio:** [To be determined]
- **Example:** Station maps, area overviews, tactical views

**Camera Behavior:**
- Fixed camera position, no movement
- Shows the entire area at once
- World view is identical to game view

**Implementation Notes:**
- Set camera's `follow_player = false`
- Use fixed zoom level appropriate for the view
- Position camera at the center of the background
- Interaction may be limited to selection/observation rather than navigation

## Implementation Guidelines

### Camera Settings

For all background types, use these base camera settings:

```gdscript
# Base camera settings
var camera = ScrollingCamera.new()
camera.current = true
camera.smoothing_enabled = true
camera.smoothing_speed = 5.0
camera.bounds_enabled = true
camera.debug_draw = false # Set to true during development
```

For each background type, apply the specific settings:

#### Wide 2D Scrolling

```gdscript
camera.follow_player = true
camera.edge_margin = Vector2(150, 100)
camera.initial_view = "center" # Or "left" or "right"
```

#### Close Isometric

```gdscript
camera.follow_player = false
camera.initial_position = Vector2(center_x, center_y)
```

#### Far Isometric

```gdscript
camera.follow_player = true
camera.edge_margin = Vector2(200, 150) # Larger margins for isometric
camera.initial_view = "center"
```

#### Top-Down Map

```gdscript
camera.follow_player = false
camera.initial_position = Vector2(center_x, center_y)
```

## Art Pipeline Considerations

When creating new backgrounds:

1. **Maintain aspect ratios** consistent with the specified dimensions
2. **Optimize textures** to minimize memory usage
3. **Design with camera behavior in mind** (scrolling areas, visible boundaries)
4. **Create walkable areas** that match the visible floor regions
5. **Test in both game view and world view** to ensure proper display

## Future Expansion

As the game develops, additional background types may be added. When proposing new types, specify:

1. The purpose and visual style
2. Exact dimensions and aspect ratio
3. Expected camera behavior
4. Examples of where it will be used

## Default Test Backgrounds

Each background type has a default test image for validation:

1. Wide 2D Scrolling: `src/assets/backgrounds/test_background.png`
2. Close Isometric: [To be created]
3. Far Isometric: [To be created]
4. Top-Down Map: [To be created]

These test images should be used when verifying camera behavior for each background type.