# Input Manager System Documentation

## Overview

The InputManager is the centralized click handling system for A Silent Refraction. It validates all mouse clicks, provides visual feedback, prioritizes overlapping clickable elements, and routes valid clicks to appropriate handlers. This system ensures consistent and predictable click behavior throughout the game.

## Architecture

### Core Components

1. **InputManager** (`src/core/input/input_manager.gd`)
   - Central click processor and validator
   - Manages click blocking and dialog states
   - Coordinates with feedback and priority systems
   - Routes validated clicks to appropriate handlers

2. **ClickFeedbackSystem** (`src/ui/click_feedback/click_feedback_system.gd`)
   - Provides visual indicators for clicks
   - Shows different states (valid, invalid, adjusted)
   - Manages fade animations and cleanup

3. **ClickPrioritySystem** (`src/core/input/click_priority_system.gd`)
   - Resolves conflicts between overlapping clickables
   - Enforces priority hierarchy
   - Handles special cases (UI, dialogs, etc.)

## Click Processing Pipeline

```
User Click → InputManager Validation → Priority Check → Visual Feedback → Route to Handler
```

### Detailed Flow

1. **Click Detection**
   - User clicks on screen
   - InputManager's `_input()` captures the event
   - Initial validation checks for click blocking

2. **Validation Phase**
   - `validate_click_position()` checks screen bounds
   - Checks for NaN/infinity values
   - Verifies click isn't on UI elements
   - Checks dialog blocking state

3. **Coordinate Transformation**
   - Screen coordinates converted to world coordinates
   - Click tolerance applied for easier interaction
   - Perspective adjustments made if needed

4. **Priority Resolution**
   - ClickPrioritySystem evaluates all potential targets
   - Determines highest priority target
   - Returns appropriate action

5. **Visual Feedback**
   - ClickFeedbackSystem displays appropriate marker:
     - 🟢 Green: Valid click
     - 🔴 Red: Invalid click
     - 🟡 Yellow: Adjusted click

6. **Action Routing**
   - Valid clicks routed to appropriate handler
   - Signals emitted for connected systems
   - Handler executes the action

## Signals

### InputManager Signals

```gdscript
signal object_clicked(object, position)
signal click_detected(position, screen_position)
```

### Usage Example

```gdscript
# Connect to click events
func _ready():
    var input_manager = get_node("/root/GameManager/InputManager")
    input_manager.connect("object_clicked", self, "_on_object_clicked")
    input_manager.connect("click_detected", self, "_on_click_detected")

func _on_object_clicked(object, position):
    print("Clicked on: ", object.name, " at ", position)

func _on_click_detected(position, screen_position):
    print("Click detected at world: ", position)
```

## Click Validation Methods

### validate_click_position(screen_position: Vector2) -> bool

Validates that a click position is within valid screen bounds.

```gdscript
# Checks performed:
- Within viewport bounds (0 to viewport_size)
- Not NaN or infinity
- Not blocked by current state
```

### is_click_on_ui(position: Vector2) -> bool

Checks if the click position intersects with any UI elements.

### should_block_click_for_dialog() -> bool

Determines if clicks should be blocked due to active dialog.

### block_clicks(duration_ms: int)

Temporarily blocks all clicks for the specified duration (in milliseconds).

## Click Tolerance System

The InputManager implements click tolerance to make interaction easier:

```gdscript
# Base tolerance
var base_tolerance = 10.0

# Adjusted for zoom
if zoom.x > 1.0:  # Zoomed out
    base_tolerance = base_tolerance / zoom.x
    
# Clamped to reasonable bounds
base_tolerance = clamp(base_tolerance, 5.0, 20.0)
```

## Priority Levels

The ClickPrioritySystem uses these priority levels:

```gdscript
enum Priority {
    MOVEMENT = 0,        # Lowest - background movement
    BACKGROUND_OBJECT = 10,
    INTERACTIVE_OBJECT = 20,  # NPCs, items
    UI_ELEMENT = 30,
    DIALOG = 40          # Highest - blocks everything
}
```

## Integration with Other Systems

### GameManager
- GameManager creates InputManager on initialization
- Connects to `object_clicked` signal
- Routes clicks to appropriate verb handlers

### CoordinateManager
- InputManager uses CoordinateManager for coordinate transformations
- Handles screen-to-world conversions
- Applies perspective transformations

### Districts and Walkable Areas
- InputManager queries districts for walkable validation
- Finds closest valid point for invalid clicks
- Shows appropriate visual feedback

### NPCs and Interactive Objects
- NPCs automatically integrate with priority system
- Click feedback shown on all interactions
- Priority ensures NPCs are clicked over background

## Configuration

### Click Blocking
```gdscript
# Block clicks for 500ms
input_manager.block_clicks(500)

# Check if clicks are blocked
if input_manager.is_click_blocked():
    return
```

### Custom Tolerance
```gdscript
# Apply custom tolerance for specific scenarios
var adjusted_pos = input_manager.apply_click_tolerance(world_pos, 15.0)
```

## Best Practices

1. **Always use InputManager for clicks** - Don't handle input directly in objects
2. **Connect through GameManager** - Let GameManager coordinate between systems
3. **Trust the validation** - InputManager ensures clicks are valid
4. **Use appropriate priorities** - Set correct priority levels for custom objects
5. **Provide visual feedback** - Always show feedback for user actions

## Testing

The InputManager is extensively tested through:
- Unit tests for validation methods
- Component tests for system integration
- Subsystem tests for full pipeline validation

See the testing documentation for details on test coverage.

## Common Issues and Solutions

### Click Not Registering
- Check if clicks are blocked (`is_click_blocked()`)
- Verify dialog isn't active (`should_block_click_for_dialog()`)
- Ensure click is within valid bounds

### Wrong Object Selected
- Review priority levels
- Check overlapping clickable areas
- Verify object is in correct group

### No Visual Feedback
- Ensure ClickFeedbackSystem is initialized
- Check if feedback system is connected
- Verify feedback nodes aren't being cleared prematurely

## Future Enhancements

- Configurable click tolerance per object type
- Custom feedback animations
- Click-and-hold detection
- Multi-click gesture support
- Touch input adaptation