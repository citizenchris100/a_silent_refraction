# Click Feedback System Documentation

## Overview

The Click Feedback System provides immediate visual feedback for all mouse clicks in A Silent Refraction. It helps players understand where they clicked, whether the click was valid, and if any adjustments were made to their input. This system significantly improves the user experience by making the game's responses to input clear and predictable.

## Visual Feedback Types

### 🟢 Valid Click (Green)
- **Color**: `Color(0, 1, 0, 0.6)` - Green with 60% opacity
- **Meaning**: Click was valid and will be processed as intended
- **Common cases**: 
  - Clicking on walkable areas
  - Clicking on interactive objects
  - Clicking on NPCs

### 🔴 Invalid Click (Red)
- **Color**: `Color(1, 0, 0, 0.6)` - Red with 60% opacity
- **Meaning**: Click was invalid and no action will be taken
- **Common cases**:
  - Clicking outside walkable areas
  - Clicking on blocked areas
  - Clicking outside game bounds

### 🟡 Adjusted Click (Yellow)
- **Color**: `Color(1, 1, 0, 0.6)` - Yellow with 60% opacity
- **Meaning**: Click was adjusted to the nearest valid position
- **Shows**: Both original click position (yellow) and adjusted position (green)
- **Includes**: Line connecting original to adjusted position

## Architecture

### Core Class

```gdscript
extends Node2D
class_name ClickFeedbackSystem

# Feedback types enum
enum FeedbackType {
    VALID,    # Green - successful click
    INVALID,  # Red - invalid click location
    ADJUSTED  # Yellow - click was adjusted
}
```

### Visual Components

1. **Feedback Markers**
   - Circular indicators at click position
   - Size: 16 pixel diameter
   - Fade animation over 0.5 seconds
   - Z-index: 100 (renders on top)

2. **Adjustment Lines**
   - Connect original click to adjusted position
   - Include arrow head pointing to final position
   - Same fade duration as markers
   - Line width: 2 pixels

## Key Methods

### show_click_feedback(position: Vector2, type: int)

Displays a single feedback marker at the specified position.

```gdscript
# Example usage
feedback_system.show_click_feedback(click_pos, FeedbackType.VALID)
```

### show_adjusted_click_feedback(original_pos: Vector2, adjusted_pos: Vector2)

Shows feedback for an adjusted click with:
- Yellow marker at original position
- Green marker at adjusted position
- Connecting line with arrow

```gdscript
# Example usage
feedback_system.show_adjusted_click_feedback(invalid_pos, closest_valid_pos)
```

### clear_all_feedback()

Immediately removes all active feedback markers and lines.

```gdscript
# Clear all visual feedback
feedback_system.clear_all_feedback()
```

## Animation System

### Fade Animation
- **Duration**: 0.5 seconds
- **Easing**: Linear fade from full opacity to transparent
- **Automatic cleanup**: Markers are freed when fully faded

### Timing
```gdscript
const FEEDBACK_DURATION = 0.5  # seconds

# Fade calculation in _process
var fade_progress = elapsed_time / FEEDBACK_DURATION
var alpha = lerp(initial_alpha, 0.0, fade_progress)
```

## Integration with InputManager

The ClickFeedbackSystem is automatically created and managed by InputManager:

```gdscript
# In InputManager initialization
if ResourceLoader.exists("res://src/ui/click_feedback/click_feedback_system.gd"):
    var ClickFeedbackSystem = load("res://src/ui/click_feedback/click_feedback_system.gd")
    click_feedback_system = ClickFeedbackSystem.new()
    get_parent().add_child(click_feedback_system)
```

### Automatic Feedback

InputManager automatically shows feedback for:
- Valid movement clicks (green)
- Invalid area clicks (red)
- Adjusted positions (yellow + green + line)
- Interactive object clicks (green)

## Performance Considerations

### Marker Pooling
- Active markers tracked in array
- Automatic cleanup when faded
- No pooling currently implemented (markers are lightweight)

### Update Frequency
- Only updates when active markers exist
- `_draw()` called only when needed
- Efficient fade calculations

### Memory Management
```gdscript
# Automatic cleanup in _process
if elapsed >= FEEDBACK_DURATION:
    remove_feedback(index)
    feedback.node.queue_free()
```

## Customization Options

### Colors
```gdscript
# Modify feedback colors
const VALID_COLOR = Color(0, 1, 0, 0.6)      # Green
const INVALID_COLOR = Color(1, 0, 0, 0.6)    # Red
const ADJUSTED_COLOR = Color(1, 1, 0, 0.6)   # Yellow
```

### Timing
```gdscript
# Adjust feedback duration
const FEEDBACK_DURATION = 0.5  # seconds
const MARKER_SIZE = 16         # pixels
const LINE_WIDTH = 2           # pixels
```

## Visual Examples

### Valid Click Feedback
```
     [Green Circle]
     ↓
   Player moves here
```

### Invalid Click Feedback
```
     [Red Circle]
     ↓
   No action taken
```

### Adjusted Click Feedback
```
[Yellow Circle] ----→ [Green Circle]
Original click        Adjusted position
                     ↓
                   Player moves here
```

## Debug Features

### Active Feedback Tracking
```gdscript
# Get all active feedback markers
var active = feedback_system.get_active_feedbacks()
print("Active markers: ", active.size())
```

### Adjustment Line Validation
```gdscript
# Check if adjustment line exists
if feedback_system.has_adjustment_line(from_pos, to_pos):
    print("Adjustment line active")
```

## Best Practices

1. **Don't create feedback manually** - Let InputManager handle it
2. **Trust the color coding** - Players learn the meaning quickly
3. **Keep duration short** - 0.5 seconds is enough to notice
4. **Maintain consistency** - Always use the same colors
5. **Clear on scene change** - Call `clear_all_feedback()` when changing scenes

## Troubleshooting

### No Feedback Visible
- Check if ClickFeedbackSystem is instantiated
- Verify z_index is high enough (default: 100)
- Ensure InputManager has reference to feedback system

### Feedback Not Fading
- Check if `_process()` is running
- Verify `set_process(true)` in `_ready()`
- Look for errors in fade calculation

### Performance Issues
- Check number of active markers
- Verify cleanup is working
- Consider reducing `FEEDBACK_DURATION`

## Future Enhancements

- Particle effects for feedback
- Sound effects integration
- Customizable marker shapes
- Theme system for different feedback styles
- Accessibility options (size, contrast)