# Animated Background Elements

This document explains how to use the animated background system in A Silent Refraction.

**Note**: For a more comprehensive guide with advanced usage, examples, and troubleshooting, see the [Animated Backgrounds (Comprehensive Guide)](animated_backgrounds_comprehensive.md).

## Overview

The animated background system allows you to add dynamic elements to your district backgrounds, such as:
- Blinking lights
- Computer terminals with changing screens
- Opening/closing doors
- Moving objects (fans, machinery, etc.)
- Weather effects (rain, snow)
- And more!

These elements are loaded from JSON configuration files and can be controlled via game code.

## Setup

1. Each district can have an `animated_elements_config.json` file in its directory
2. The base district class will automatically load this file if it exists
3. Alternatively, you can specify a custom path using the `animated_elements_config` property

```gdscript
func _ready():
    # Set a custom path for animated elements config
    animated_elements_config = "animated_elements_config.json"

    # Call the parent _ready to initialize
    ._ready()
```

## JSON Configuration Format

The configuration file uses the following format:

```json
{
  "elements": [
    {
      "type": "element_type",
      "id": "unique_element_id",
      "position": {
        "x": 100,
        "y": 200
      },
      "properties": {
        "property1": "value1",
        "property2": "value2"
      },
      "states": {
        "default": {
          "frames": ["path/to/frame1.png", "path/to/frame2.png"],
          "speed": 0.5,
          "loop": true
        },
        "alternate": {
          "frames": ["path/to/alt_frame1.png", "path/to/alt_frame2.png"],
          "speed": 0.3,
          "loop": true
        }
      },
      "initial_state": "default"
    }
  ]
}
```

## Available Element Types

The system includes the following animated element types:

1. **Computer Terminal** - A computer screen that cycles through different displays
2. **Steam Vent** - A floor vent that periodically releases steam
3. **Warning Light** - A blinking warning light with red/orange patterns
4. **Sliding Door** - A door that can open and close
5. **Water Puddle** - A water puddle with subtle ripple animations
6. **Flickering Light** - A ceiling light with random flicker patterns
7. **Conveyor Belt** - A moving conveyor belt for cargo
8. **Ventilation Fan** - A spinning fan with adjustable speed
9. **Hologram Display** - A projection with pulsing effects
10. **Security Camera** - A surveillance camera that pans back and forth

## Adding Elements to a District

### Method 1: Using Configuration Files (Recommended)

1. Create a JSON configuration file at `src/districts/[district_name]/animated_elements_config.json`
2. Define elements in the following format:

```json
{
  "elements": [
    {
      "type": "computer_terminal",
      "id": "main_console",
      "position": {
        "x": 150,
        "y": 350
      },
      "properties": {
        "frame_delay": 0.3
      }
    },
    {
      "type": "warning_light",
      "id": "security",
      "position": {
        "x": 600,
        "y": 120
      }
    }
  ]
}
```

The animated background system will automatically load this file and create the elements.

### Method 2: Adding Elements via Code

You can add elements at runtime with code like this:

```gdscript
# In your district script:
func setup_animated_elements():
    # Add a computer terminal
    add_animated_element("computer_terminal", "main_console", Vector2(150, 350))

    # Add a warning light with custom properties
    var properties = {"frame_sequence": [0, 1, 0, 2, 0, 0, 0, 1, 0, 2]}
    add_animated_element("warning_light", "security", Vector2(600, 120), properties)
```

## Creating Animation Assets

1. **Sprite Animation Frames**:
   - Create individual PNG frames for your animation
   - Place them in the appropriate asset folder (e.g., `res://assets/animations/computer_screen/`)
   - Reference the paths in your JSON config

2. **Light Sources**:
   - Define color, radius, and intensity properties
   - Create optional texture for the light shape

3. **Particle Effects**:
   - Define emitter properties like rate, direction, etc.
   - Create particle textures

## Controlling Elements via Code

You can control elements through code using the district's API:

```gdscript
# Get reference to a specific element
var door = get_animated_element("sliding_door", "main_entrance")
if door and door.has_method("set_property"):
    # Control element properties
    door.set_property("state", "open")

# Toggle all elements of a specific type
toggle_animated_elements("warning_light", true)  # Turn on all warning lights
toggle_animated_elements("computer_terminal", false)  # Turn off all computer terminals
```

## Element Properties

Different element types support different properties:

### Common Properties
- `visible` (bool): Whether the element is visible
- `scale` (Vector2): Scale factor for the element
- `rotation` (float): Rotation in degrees
- `z_index` (int): Drawing order
- `state` (string): Current state name

### Type-Specific Properties

#### Sprite Animated
- `speed_scale` (float): Animation speed multiplier
- `playing` (bool): Whether animation is playing

#### Light Source
- `color` (Color): Light color
- `energy` (float): Light intensity
- `radius` (float): Light radius

#### Particle Effect
- `emitting` (bool): Whether particles are being emitted
- `amount` (int): Number of particles
- `lifetime` (float): Particle lifetime

## Adding to the Shipping District Scene

1. Create custom animations for your elements
2. Configure them in `src/districts/shipping/animated_elements_config.json`
3. Add `animated_elements_config = "animated_elements_config.json"` to your district's `_ready()` function
4. When the district loads, elements will be automatically added according to the configuration

## Creating New Element Types

To create a new type of animated element:

1. Extend the `AnimatedBackgroundManager` class
2. Add handler methods for your new element type
3. Register the new type in the manager's initialization

## Performance Considerations

- Each animated element uses resources for sprite loading and animation updates
- Be mindful of how many elements you add to a scene
- Consider disabling animations for elements that are off-screen
- For complex scenes, use a quadtree or other spatial partitioning to only update visible elements

## Troubleshooting

If you encounter issues with the animation system, check the following:

### Common Error Messages

- `No loader found for resource`: This means Godot can't find a loader for the resource. Usually indicates the file isn't in the expected location or hasn't been imported.

- `Failed loading resource`: The resource file exists but couldn't be loaded. This often happens when the .import file exists but the corresponding .stex file doesn't.

- `Unable to open file: res://.import/...`: The .import file points to a .stex resource that doesn't exist because the editor hasn't processed it yet.

- `Division By Zero in operator '%'`: Occurs when an animation script tries to cycle through frames but the frames array is empty (frames.size() == 0).

### Solutions

1. **Check Resource Paths**: Ensure paths to resources are correct.

2. **Check Path Consistency**: Ensure all scripts use the same path format, either `res://src/assets/...` or `res://assets/...`.

3. **Verify Asset Existence**: Make sure the animation frames actually exist at the expected paths.

4. **Implement Fallback Rendering**: In scripts, add fallback logic to prevent errors when frames can't be loaded:
   ```gdscript
   func _process(delta):
       # Only animate if we have frames
       if frames.size() > 0:
           # Animation code
       else:
           # Handle missing frames gracefully
   ```

