# Multi-Perspective System Quick Reference

## Quick Setup

### 1. Add to Character Scene
```gdscript
# In character scene tree:
Player (Node2D)
├── AnimatedSprite
├── CollisionShape2D
└── PerspectiveController (Node)  # Add this
```

### 2. Initialize in Character Script
```gdscript
extends Node2D

onready var perspective_controller = $PerspectiveController

func _ready():
    # Attach controller
    perspective_controller.attach_to_character(self)
    
    # Set initial perspective
    perspective_controller.set_perspective(PerspectiveType.ISOMETRIC)
```

### 3. Add to District
```gdscript
extends "res://src/core/districts/base_district.gd"

export var perspective_type: int = PerspectiveType.ISOMETRIC
```

## Common Tasks

### Change Perspective
```gdscript
# Simple change
perspective_controller.set_perspective(PerspectiveType.SIDE_SCROLLING)

# With signal handling
perspective_controller.connect("perspective_changed", self, "_on_perspective_changed")

func _on_perspective_changed(old_type, new_type):
    print("Switched from %s to %s" % [
        PerspectiveType.get_perspective_name(old_type),
        PerspectiveType.get_perspective_name(new_type)
    ])
```

### Handle Movement
```gdscript
func _on_player_clicked(world_position):
    # Get movement direction for current perspective
    var move_vector = world_position - global_position
    var direction = perspective_controller.convert_movement_to_direction(move_vector)
    
    # Play appropriate animation
    perspective_controller.play_animation("walk", direction)
```

### Get Current Settings
```gdscript
# Get configuration
var config = perspective_controller.get_current_configuration()
print("Movement speed multiplier: ", config.movement_speed_multiplier)
print("Supports diagonal movement: ", config.supports_diagonal_movement)

# Get valid directions
var directions = PerspectiveType.get_valid_directions(perspective_controller.current_perspective)
print("Valid directions: ", directions)
```

## Perspective Types Reference

| Type | Value | Directions | Count | Diagonal | Prefix |
|------|-------|------------|-------|----------|---------|
| ISOMETRIC | 0 | N, NE, E, SE, S, SW, W, NW | 8 | Yes | iso_ |
| SIDE_SCROLLING | 1 | left, right | 2 | No | side_ |
| TOP_DOWN | 2 | N, E, S, W | 4 | No | top_ |

## Animation Naming

Format: `[prefix][state]_[direction]`

### Examples by Perspective

**Isometric:**
- `iso_idle_south`
- `iso_walk_northeast`
- `iso_run_west`

**Side Scrolling:**
- `side_idle_left`
- `side_walk_right`
- `side_jump_left`

**Top Down:**
- `top_idle_north`
- `top_walk_east`
- `top_run_south`

## Direction Conversion Examples

### Isometric (8-way)
```
Vector2(1, 0)    → "east"
Vector2(1, 1)    → "southeast"
Vector2(0, 1)    → "south"
Vector2(-1, 1)   → "southwest"
Vector2(-1, 0)   → "west"
Vector2(-1, -1)  → "northwest"
Vector2(0, -1)   → "north"
Vector2(1, -1)   → "northeast"
```

### Side Scrolling (2-way)
```
Vector2(1, 0)    → "right"
Vector2(-1, 0)   → "left"
Vector2(0, 1)    → "right" (default)
Vector2(0, -1)   → "right" (default)
```

### Top Down (4-way)
```
Vector2(1, 0)    → "east"
Vector2(-1, 0)   → "west"
Vector2(0, 1)    → "south"
Vector2(0, -1)   → "north"
Vector2(1, 1)    → "east" or "south" (dominant axis)
```

## Troubleshooting

### Problem: Animation not playing
```gdscript
# Check if animation exists
var anim_name = perspective_controller.get_perspective_animation_name("walk", "south")
if animated_sprite.frames.has_animation(anim_name):
    print("Animation exists: ", anim_name)
else:
    print("Missing animation: ", anim_name)
    print("Available animations: ", animated_sprite.frames.get_animation_names())
```

### Problem: Wrong direction conversion
```gdscript
# Debug direction conversion
var vector = target_pos - global_position
print("Movement vector: ", vector)
print("Current perspective: ", PerspectiveType.get_perspective_name(
    perspective_controller.current_perspective))
print("Converted direction: ", perspective_controller.convert_movement_to_direction(vector))
```

### Problem: Perspective not changing
```gdscript
# Verify perspective change
print("Before: ", perspective_controller.current_perspective)
perspective_controller.set_perspective(PerspectiveType.TOP_DOWN)
print("After: ", perspective_controller.current_perspective)

# Check if signal is emitted
perspective_controller.connect("perspective_changed", self, "_debug_perspective_change")
func _debug_perspective_change(old, new):
    print("Signal emitted: %d -> %d" % [old, new])
```

## Best Practices

### DO:
- ✅ Cache perspective controller reference with `onready`
- ✅ Connect signals in `_ready()` function
- ✅ Use constants from PerspectiveType, not magic numbers
- ✅ Follow animation naming convention strictly
- ✅ Test animations in all perspectives during development

### DON'T:
- ❌ Hard-code perspective values (use PerspectiveType constants)
- ❌ Assume animation exists (check or provide fallback)
- ❌ Mix perspective logic in character movement code
- ❌ Create new controller for each perspective change
- ❌ Forget to disconnect signals when removing characters

## Integration Checklist

- [ ] Character has PerspectiveController node
- [ ] Controller attached in _ready()
- [ ] AnimatedSprite has perspective-specific animations
- [ ] District has perspective_type property
- [ ] District change triggers perspective update
- [ ] Movement code uses perspective controller
- [ ] Animation names follow convention
- [ ] Fallback animations exist
- [ ] Save/load includes perspective state

## Performance Tips

1. **Preload configurations** - They're cached automatically
2. **Reuse controllers** - Don't create new ones
3. **Batch perspective changes** - Avoid rapid switching
4. **Use animation fallbacks** - Reduces memory usage
5. **Profile in different perspectives** - Performance may vary

## Testing Commands

```bash
# Run unit tests
./tools/run_unit_tests.sh perspective_type_test
./tools/run_unit_tests.sh character_perspective_controller_test

# Run component tests
./tools/run_component_tests.sh perspective_district_component_test

# Run all perspective tests
./tools/run_unit_tests.sh perspective_type_test character_perspective_controller_test && ./tools/run_component_tests.sh perspective_district_component_test
```