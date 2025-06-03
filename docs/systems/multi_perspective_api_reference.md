# Multi-Perspective System API Reference

## PerspectiveType

**Location:** `src/core/perspective/perspective_type.gd`  
**Type:** Static utility class (extends Object)

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `ISOMETRIC` | 0 | Isometric perspective with 8-directional movement |
| `SIDE_SCROLLING` | 1 | Side-scrolling perspective with 2-directional movement |
| `TOP_DOWN` | 2 | Top-down perspective with 4-directional movement |

### Static Methods

#### `get_perspective_name(type: int) -> String`
Returns the string name for a perspective type.

**Parameters:**
- `type`: Perspective type constant

**Returns:** String name ("isometric", "side_scrolling", "top_down", or "unknown")

**Example:**
```gdscript
var name = PerspectiveType.get_perspective_name(PerspectiveType.ISOMETRIC)
# Returns: "isometric"
```

#### `get_perspective_from_string(name: String) -> int`
Converts a string name to a perspective type constant.

**Parameters:**
- `name`: String name of perspective (case-insensitive)

**Returns:** Perspective type constant (defaults to ISOMETRIC if unknown)

**Example:**
```gdscript
var type = PerspectiveType.get_perspective_from_string("side_scrolling")
# Returns: 1 (SIDE_SCROLLING)
```

#### `get_valid_directions(type: int) -> Array`
Returns an array of valid direction strings for a perspective type.

**Parameters:**
- `type`: Perspective type constant

**Returns:** Array of direction strings

**Example:**
```gdscript
var dirs = PerspectiveType.get_valid_directions(PerspectiveType.TOP_DOWN)
# Returns: ["north", "east", "south", "west"]
```

#### `get_direction_count(type: int) -> int`
Returns the number of valid directions for a perspective type.

**Parameters:**
- `type`: Perspective type constant

**Returns:** Integer count of directions

**Example:**
```gdscript
var count = PerspectiveType.get_direction_count(PerspectiveType.ISOMETRIC)
# Returns: 8
```

#### `is_valid_direction(type: int, direction: String) -> bool`
Checks if a direction is valid for a given perspective type.

**Parameters:**
- `type`: Perspective type constant
- `direction`: Direction string to check

**Returns:** true if direction is valid, false otherwise

**Example:**
```gdscript
var valid = PerspectiveType.is_valid_direction(PerspectiveType.SIDE_SCROLLING, "north")
# Returns: false
```

#### `vector_to_direction(type: int, vector: Vector2) -> String`
Converts a movement vector to a direction string based on perspective type.

**Parameters:**
- `type`: Perspective type constant
- `vector`: Movement vector

**Returns:** Direction string (empty string if vector is too small)

**Example:**
```gdscript
var dir = PerspectiveType.vector_to_direction(PerspectiveType.ISOMETRIC, Vector2(1, 1))
# Returns: "southeast"
```

---

## PerspectiveConfiguration

**Location:** `src/core/perspective/perspective_configuration.gd`  
**Type:** Resource class

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `perspective_type` | int | 0 | The perspective type constant |
| `direction_count` | int | 8 | Number of valid movement directions |
| `movement_speed_multiplier` | float | 1.0 | Speed adjustment factor |
| `sprite_scale` | Vector2 | (1.0, 1.0) | Visual scale adjustment |
| `supports_diagonal_movement` | bool | true | Whether diagonal movement is allowed |
| `camera_zoom_level` | float | 1.0 | Recommended camera zoom |
| `y_sort_enabled` | bool | true | Whether to use Y-sorting for depth |
| `animation_prefix` | String | "iso_" | Prefix for animation names |

### Methods

#### `is_valid() -> bool`
Validates the configuration values.

**Returns:** true if configuration is valid, false otherwise

**Validation checks:**
- direction_count > 0
- movement_speed_multiplier > 0
- sprite_scale.x > 0 and sprite_scale.y > 0

#### `to_dict() -> Dictionary`
Converts the configuration to a dictionary for serialization.

**Returns:** Dictionary containing all configuration properties

**Example:**
```gdscript
var config = PerspectiveConfiguration.create_isometric_config()
var data = config.to_dict()
# Returns: {"perspective_type": "isometric", "direction_count": 8, ...}
```

### Static Methods

#### `create_isometric_config() -> PerspectiveConfiguration`
Creates a pre-configured isometric perspective configuration.

**Returns:** PerspectiveConfiguration instance with isometric settings

#### `create_side_scrolling_config() -> PerspectiveConfiguration`
Creates a pre-configured side-scrolling perspective configuration.

**Returns:** PerspectiveConfiguration instance with side-scrolling settings

#### `create_top_down_config() -> PerspectiveConfiguration`
Creates a pre-configured top-down perspective configuration.

**Returns:** PerspectiveConfiguration instance with top-down settings

#### `from_dict(data: Dictionary) -> PerspectiveConfiguration`
Creates a configuration from a dictionary (e.g., loaded from JSON).

**Parameters:**
- `data`: Dictionary containing configuration properties

**Returns:** PerspectiveConfiguration instance

**Example:**
```gdscript
var data = {"perspective_type": "top_down", "direction_count": 4}
var config = PerspectiveConfiguration.from_dict(data)
```

---

## CharacterPerspectiveController

**Location:** `src/characters/perspective/character_perspective_controller.gd`  
**Type:** Node class

### Signals

#### `perspective_changed(old_perspective: int, new_perspective: int)`
Emitted when the perspective changes.

**Parameters:**
- `old_perspective`: Previous perspective type constant
- `new_perspective`: New perspective type constant

#### `animation_changed(animation_name: String)`
Emitted when an animation is played.

**Parameters:**
- `animation_name`: Name of the animation being played

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `current_perspective` | int | 0 | Current perspective type |
| `character_node` | Node2D | null | Reference to the character this controls |
| `perspective_configs` | Dictionary | {} | Cached perspective configurations |
| `animated_sprite` | AnimatedSprite | null | Reference to character's AnimatedSprite |
| `current_direction` | String | "south" | Current facing direction |
| `current_animation_state` | String | "idle" | Current animation state |

### Methods

#### `attach_to_character(character: Node2D)`
Attaches the controller to a character node.

**Parameters:**
- `character`: The character Node2D to control

**Note:** Automatically searches for AnimatedSprite child in the character.

**Example:**
```gdscript
var controller = CharacterPerspectiveController.new()
controller.attach_to_character($Player)
```

#### `set_perspective(type: int)`
Changes the current perspective type.

**Parameters:**
- `type`: Perspective type constant

**Emits:** `perspective_changed` signal if perspective actually changes

**Example:**
```gdscript
controller.set_perspective(PerspectiveType.SIDE_SCROLLING)
```

#### `get_current_configuration() -> PerspectiveConfiguration`
Returns the configuration for the current perspective.

**Returns:** PerspectiveConfiguration instance

**Example:**
```gdscript
var config = controller.get_current_configuration()
var speed = config.movement_speed_multiplier
```

#### `convert_movement_to_direction(vector: Vector2) -> String`
Converts a movement vector to a direction string based on current perspective.

**Parameters:**
- `vector`: Movement vector

**Returns:** Direction string appropriate for current perspective

**Example:**
```gdscript
var direction = controller.convert_movement_to_direction(Vector2(1, 0))
# Returns: "east" (isometric), "right" (side-scrolling), or "east" (top-down)
```

#### `get_animation_prefix(type: int) -> String`
Returns the animation prefix for a perspective type.

**Parameters:**
- `type`: Perspective type constant

**Returns:** Animation prefix string

**Example:**
```gdscript
var prefix = controller.get_animation_prefix(PerspectiveType.ISOMETRIC)
# Returns: "iso_"
```

#### `get_perspective_animation_name(state: String, direction: String) -> String`
Builds a complete animation name for the current perspective.

**Parameters:**
- `state`: Animation state (e.g., "walk", "idle")
- `direction`: Direction string

**Returns:** Complete animation name

**Example:**
```gdscript
var anim = controller.get_perspective_animation_name("walk", "south")
# Returns: "iso_walk_south" (if current perspective is isometric)
```

#### `get_fallback_animation(full_name: String) -> String`
Extracts the base animation state from a full animation name.

**Parameters:**
- `full_name`: Full animation name with prefix and direction

**Returns:** Base animation state

**Example:**
```gdscript
var fallback = controller.get_fallback_animation("iso_walk_south")
# Returns: "walk"
```

#### `play_animation(state: String, direction: String = "")`
Plays an animation for the current perspective.

**Parameters:**
- `state`: Animation state to play
- `direction`: Direction (optional, uses current if not provided)

**Emits:** `animation_changed` signal

**Example:**
```gdscript
controller.play_animation("walk", "north")
# or
controller.play_animation("idle")  # uses current direction
```

#### `set_perspective_config(type: int, config: PerspectiveConfiguration)`
Sets a custom configuration for a specific perspective.

**Parameters:**
- `type`: Perspective type constant
- `config`: PerspectiveConfiguration instance

**Example:**
```gdscript
var custom_config = PerspectiveConfiguration.new()
custom_config.movement_speed_multiplier = 2.0
controller.set_perspective_config(PerspectiveType.TOP_DOWN, custom_config)
```

#### `has_perspective(type: int) -> bool`
Checks if a perspective type has a configuration.

**Parameters:**
- `type`: Perspective type constant

**Returns:** true if perspective is configured, false otherwise

**Example:**
```gdscript
if controller.has_perspective(PerspectiveType.FIRST_PERSON):
    print("First person perspective is available")
```

---

## Usage Patterns

### Basic Character Setup
```gdscript
extends Node2D

onready var perspective_controller = $PerspectiveController
onready var animated_sprite = $AnimatedSprite

func _ready():
    perspective_controller.attach_to_character(self)
    perspective_controller.connect("perspective_changed", self, "_on_perspective_changed")
    perspective_controller.connect("animation_changed", self, "_on_animation_changed")

func _on_perspective_changed(old_type, new_type):
    # Handle perspective change
    var config = perspective_controller.get_current_configuration()
    # Adjust character properties based on config

func _on_animation_changed(anim_name):
    # Track animation changes if needed
    pass
```

### Movement Handling
```gdscript
func move_to_position(target_pos: Vector2):
    var movement = target_pos - global_position
    var direction = perspective_controller.convert_movement_to_direction(movement)
    
    # Start movement
    perspective_controller.play_animation("walk", direction)
    
    # Apply movement with perspective multiplier
    var config = perspective_controller.get_current_configuration()
    velocity = movement.normalized() * base_speed * config.movement_speed_multiplier
```

### District Integration
```gdscript
# In district script
signal perspective_changed(type)

export var perspective_type: int = PerspectiveType.ISOMETRIC

func _on_player_entered():
    emit_signal("perspective_changed", perspective_type)

# In player script
func _on_district_perspective_changed(type):
    perspective_controller.set_perspective(type)
```