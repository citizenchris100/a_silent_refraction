# Multi-Perspective Character System

## Overview

The Multi-Perspective Character System allows characters in A Silent Refraction to adapt their appearance and movement behavior based on the visual perspective of each game district. This system supports three perspective types: isometric, side-scrolling, and top-down views.

## Architecture

### Core Components

#### 1. PerspectiveType (`src/core/perspective/perspective_type.gd`)

A static utility class that defines perspective constants and helper functions.

**Constants:**
- `ISOMETRIC` (0) - 8-directional isometric view
- `SIDE_SCROLLING` (1) - 2-directional side view
- `TOP_DOWN` (2) - 4-directional overhead view

**Key Methods:**
- `get_perspective_name(type)` - Returns string name for a perspective type
- `get_perspective_from_string(name)` - Converts string to perspective constant
- `get_valid_directions(type)` - Returns array of valid movement directions
- `vector_to_direction(type, vector)` - Converts movement vector to direction string

#### 2. PerspectiveConfiguration (`src/core/perspective/perspective_configuration.gd`)

A Resource class that stores configuration data for each perspective type.

**Properties:**
- `perspective_type` - The perspective type constant
- `direction_count` - Number of valid movement directions
- `movement_speed_multiplier` - Speed adjustment factor
- `sprite_scale` - Visual scale adjustment
- `supports_diagonal_movement` - Whether diagonal movement is allowed
- `camera_zoom_level` - Recommended camera zoom
- `y_sort_enabled` - Whether to use Y-sorting for depth
- `animation_prefix` - Prefix for animation names (e.g., "iso_", "side_")

**Factory Methods:**
- `create_isometric_config()` - Creates configuration for isometric view
- `create_side_scrolling_config()` - Creates configuration for side-scrolling view
- `create_top_down_config()` - Creates configuration for top-down view

#### 3. CharacterPerspectiveController (`src/characters/perspective/character_perspective_controller.gd`)

A Node that manages character appearance and behavior based on the current perspective.

**Signals:**
- `perspective_changed(old_perspective, new_perspective)` - Emitted when perspective changes
- `animation_changed(animation_name)` - Emitted when animation changes

**Key Methods:**
- `attach_to_character(character)` - Attaches controller to a character node
- `set_perspective(type)` - Changes the current perspective
- `get_current_configuration()` - Returns current perspective configuration
- `convert_movement_to_direction(vector)` - Converts movement to perspective-appropriate direction
- `play_animation(state, direction)` - Plays perspective-specific animation

### Integration Points

#### District Integration

Districts should extend their base class to include perspective information:

```gdscript
# In base_district.gd or district implementation
export var perspective_type: int = PerspectiveType.ISOMETRIC

func _ready():
    # Emit signal when district is entered
    emit_signal("perspective_changed", perspective_type)
```

#### Character Integration

Characters should have a PerspectiveController attached:

```gdscript
# In player.gd or character implementation
onready var perspective_controller = $PerspectiveController

func _ready():
    perspective_controller.attach_to_character(self)
    
    # Connect to district changes
    var game_manager = get_node("/root/GameManager")
    game_manager.connect("district_changed", self, "_on_district_changed")

func _on_district_changed(new_district):
    if new_district.has("perspective_type"):
        perspective_controller.set_perspective(new_district.perspective_type)
```

## Configuration Files

Configuration templates are stored in `src/data/perspective_configs/`:

### isometric_config.json
```json
{
    "perspective_type": "isometric",
    "direction_count": 8,
    "movement_speed_multiplier": 1.0,
    "sprite_scale": [1.0, 1.0],
    "supports_diagonal_movement": true,
    "camera_zoom_level": 1.0,
    "y_sort_enabled": true,
    "animation_prefix": "iso_",
    "valid_directions": [
        "north", "northeast", "east", "southeast",
        "south", "southwest", "west", "northwest"
    ]
}
```

### side_scrolling_config.json
```json
{
    "perspective_type": "side_scrolling",
    "direction_count": 2,
    "movement_speed_multiplier": 1.2,
    "sprite_scale": [1.0, 1.0],
    "supports_diagonal_movement": false,
    "camera_zoom_level": 1.0,
    "y_sort_enabled": false,
    "animation_prefix": "side_",
    "valid_directions": ["left", "right"]
}
```

### top_down_config.json
```json
{
    "perspective_type": "top_down",
    "direction_count": 4,
    "movement_speed_multiplier": 1.0,
    "sprite_scale": [0.8, 0.8],
    "supports_diagonal_movement": false,
    "camera_zoom_level": 0.8,
    "y_sort_enabled": true,
    "animation_prefix": "top_",
    "valid_directions": ["north", "east", "south", "west"]
}
```

## Animation Naming Convention

Animations should follow this naming pattern:
`[perspective_prefix][state]_[direction]`

Examples:
- `iso_walk_south` - Isometric walking south
- `side_idle_left` - Side-scrolling idle facing left
- `top_walk_north` - Top-down walking north

The system will automatically look for perspective-specific animations first, then fall back to generic animations if not found.

## Usage Examples

### Basic Setup

```gdscript
# Create a character with perspective support
var character = preload("res://src/characters/player/player.tscn").instance()
var controller = preload("res://src/characters/perspective/character_perspective_controller.gd").new()

# Attach controller to character
controller.attach_to_character(character)

# Set initial perspective
controller.set_perspective(PerspectiveType.ISOMETRIC)
```

### Handling Movement

```gdscript
# In player input handling
func _on_click_position(world_pos):
    var movement_vector = world_pos - global_position
    
    # Convert to perspective-appropriate direction
    var direction = perspective_controller.convert_movement_to_direction(movement_vector)
    
    # Play movement animation
    perspective_controller.play_animation("walk", direction)
```

### District Transitions

```gdscript
# When entering a new district
func _on_enter_district(district):
    if district.has("perspective_type"):
        perspective_controller.set_perspective(district.perspective_type)
        
        # Adjust camera if needed
        var config = perspective_controller.get_current_configuration()
        camera.zoom = Vector2.ONE * config.camera_zoom_level
```

## Testing

The system includes comprehensive test coverage:

### Unit Tests
- `perspective_type_test.gd` - Tests enum values and utility functions
- `character_perspective_controller_test.gd` - Tests controller functionality

### Component Tests
- `perspective_district_component_test.gd` - Tests integration between districts and perspective system

### Running Tests
```bash
# Run all perspective tests
./tools/run_unit_tests.sh perspective_type_test character_perspective_controller_test

# Run component tests
./tools/run_component_tests.sh perspective_district_component_test
```

## Extension Points

### Adding New Perspective Types

1. Add constant to `PerspectiveType`:
```gdscript
const FIRST_PERSON = 3
```

2. Update utility methods:
```gdscript
# In get_perspective_name()
FIRST_PERSON:
    return "first_person"

# In get_valid_directions()
FIRST_PERSON:
    return ["forward", "backward", "left", "right"]
```

3. Create configuration factory:
```gdscript
static func create_first_person_config():
    var config = load("res://src/core/perspective/perspective_configuration.gd").new()
    config.perspective_type = PerspectiveType.FIRST_PERSON
    # ... set other properties
    return config
```

### Custom Perspective Behaviors

Extend the CharacterPerspectiveController:

```gdscript
extends "res://src/characters/perspective/character_perspective_controller.gd"

func convert_movement_to_direction(vector: Vector2) -> String:
    if current_perspective == PerspectiveType.FIRST_PERSON:
        # Custom logic for first-person movement
        return custom_first_person_direction(vector)
    else:
        return .convert_movement_to_direction(vector)
```

## Performance Considerations

- Perspective configurations are cached in memory
- Animation lookups use dictionary access (O(1))
- Direction conversions use simple math operations
- No per-frame allocations in core functionality

## Save System Integration

The perspective state should be included in save data:

```gdscript
# In save game
save_data["player_perspective"] = perspective_controller.current_perspective

# In load game
perspective_controller.set_perspective(save_data.get("player_perspective", PerspectiveType.ISOMETRIC))
```

## Debugging

Enable debug output in the controller:

```gdscript
# In character_perspective_controller.gd
export var debug_mode = false

func set_perspective(type: int):
    if debug_mode:
        print("Changing perspective from %s to %s" % [
            PerspectiveType.get_perspective_name(current_perspective),
            PerspectiveType.get_perspective_name(type)
        ])
    # ... rest of method
```

## Common Issues

### Animation Not Found
- Ensure animation names follow the naming convention
- Check that AnimatedSprite has the required animations
- Verify the perspective prefix is correct

### Direction Conversion Issues
- Check that movement vectors are normalized if needed
- Ensure perspective type is set correctly
- Verify valid directions for the perspective type

### Signal Connection Errors
- Ensure controller is attached to character before connecting signals
- Check that district emits perspective_changed signal
- Verify signal parameters match expected signature