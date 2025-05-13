# Animated Background System - Comprehensive Guide

This document provides comprehensive documentation for using the animated background system in A Silent Refraction.

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [JSON Configuration Format](#json-configuration-format)
4. [Setting Up Animated Backgrounds](#setting-up-animated-backgrounds)
5. [Animated Element Types](#animated-element-types)
6. [Adding Elements to a District](#adding-elements-to-a-district)
7. [Creating Custom Animations](#creating-custom-animations)
8. [Controlling Elements Through Code](#controlling-elements-through-code)
9. [Properties Reference](#properties-reference)
10. [Advanced Usage](#advanced-usage)
11. [Optimization and Performance](#optimization-and-performance)
12. [Adding New Element Types](#adding-new-element-types)
13. [Class Registration](#class-registration)
14. [Troubleshooting](#troubleshooting)
15. [Examples](#examples)

## Overview

The animated background system allows you to add dynamic, interactive elements to your game's backgrounds, such as:
- Blinking lights and computer screens
- Opening/closing doors
- Moving machinery (conveyor belts, fans, etc.)
- Steam vents and water effects
- Security cameras and surveillance equipment
- Weather effects (rain, snow, fog)
- Environmental storytelling elements

These elements enhance the atmosphere of your game while providing visual feedback for player interactions and game state changes.

## Architecture

The animated background system consists of the following components:

1. **AnimatedBackgroundManager** (`src/core/districts/animated_background_manager.gd`)
   - Core class that manages all animated elements
   - Loads element definitions from JSON configuration
   - Creates and manages element instances
   - Provides API for controlling elements

2. **BaseDistrict Integration** (`src/core/districts/base_district.gd`)
   - Automatically initializes the animation manager
   - Provides helper methods for accessing and controlling elements
   - Handles element lifecycle during district transitions

3. **JSON Configuration** (e.g. `src/districts/shipping/animated_elements_config.json`)
   - Defines which elements appear in a district
   - Specifies element positions, properties, and states
   - Allows for content-driven animation without code changes

## JSON Configuration Format

The configuration file uses the following hierarchical format:

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

### Configuration Fields

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `type` | String | The type of animated element | Yes |
| `id` | String | Unique identifier for this element | Yes |
| `position` | Object | X/Y coordinates for placement | Yes |
| `properties` | Object | Element-specific properties | No |
| `states` | Object | Different animation states | No |
| `initial_state` | String | Starting state name | No |

## Setting Up Animated Backgrounds

### 1. Enable in Your District

To use animated backgrounds in a district, set the config path in your district's `_ready()` function:

```gdscript
# In your district script (e.g., shipping_district.gd)
func _ready():
    district_name = "Shipping District"
    district_description = "The station's dock area where ships arrive with cargo and passengers."
    animated_elements_config = "animated_elements_config.json"
    
    # Call parent _ready
    ._ready()
```

### 2. Create the Configuration File

Create a JSON configuration file in your district's folder:
- Default path: `src/districts/[district_name]/animated_elements_config.json`
- Alternative: Specify a different path in the `animated_elements_config` property

### 3. Register New Classes

If you've created custom animated element types, you need to register them with Godot:

```bash
# Register new custom classes with Godot
./a_silent_refraction.sh register-classes
```

This will open the Godot editor to scan and register your classes, then automatically close when complete.

## Animated Element Types

The system includes these standard element types:

| Type | Description | Properties |
|------|-------------|------------|
| `computer_terminal` | Screen cycling through displays | `frame_delay`, `frame_sequence` |
| `steam_vent` | Floor vent releasing steam | `frequency`, `intensity` |
| `warning_light` | Blinking warning light | `color`, `pattern` |
| `sliding_door` | Door that can open/close | `state` (open/closed), `speed` |
| `water_puddle` | Water with subtle ripples | `size`, `ripple_speed` |
| `flickering_light` | Light with random flicker | `flicker_intensity`, `color` |
| `conveyor_belt` | Moving cargo belt | `direction`, `speed` |
| `ventilation_fan` | Spinning fan | `speed`, `rotation_direction` |
| `hologram_display` | Projection with effects | `color`, `opacity`, `pulse_rate` |
| `security_camera` | Surveillance camera | `pan_angle`, `rotation_speed` |

## Adding Elements to a District

### Method 1: Using Configuration Files (Recommended)

Create a JSON file at `src/districts/[district_name]/animated_elements_config.json`:

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

### Method 2: Adding Elements via Code

You can also add elements programmatically:

```gdscript
# In your district script
func setup_custom_elements():
    # Add a computer terminal
    add_animated_element("computer_terminal", "main_console", Vector2(150, 350))
    
    # Add a warning light with custom properties
    var properties = {"frame_sequence": [0, 1, 0, 2, 0, 0, 0, 1, 0, 2]}
    add_animated_element("warning_light", "security", Vector2(600, 120), properties)
```

## Creating Custom Animations

### 1. Prepare Animation Frames

Create individual PNG frames for your animation and place them in a structured location:

```
src/assets/animations/
  computer_terminals/
    boot_sequence/
      frame001.png
      frame002.png
      frame003.png
    error_state/
      error001.png
      error002.png
  warning_lights/
    red_alert/
      frame001.png
      frame002.png
```

### 2. Reference Frames in Configuration

In your JSON configuration, reference the frame paths:

```json
{
  "elements": [
    {
      "type": "computer_terminal",
      "id": "main_terminal",
      "position": {"x": 200, "y": 150},
      "states": {
        "boot": {
          "frames": [
            "res://src/assets/animations/computer_terminals/boot_sequence/frame001.png",
            "res://src/assets/animations/computer_terminals/boot_sequence/frame002.png",
            "res://src/assets/animations/computer_terminals/boot_sequence/frame003.png"
          ],
          "speed": 0.5,
          "loop": false
        },
        "error": {
          "frames": [
            "res://src/assets/animations/computer_terminals/error_state/error001.png",
            "res://src/assets/animations/computer_terminals/error_state/error002.png"
          ],
          "speed": 0.2,
          "loop": true
        }
      },
      "initial_state": "boot"
    }
  ]
}
```

### 3. Import Assets

After adding new animation frames, import them:

```bash
./a_silent_refraction.sh import
```

## Controlling Elements Through Code

### Getting and Controlling Elements

```gdscript
# Get a reference to a specific element
var terminal = get_animated_element("computer_terminal", "main_console")
if terminal:
    # Control properties directly
    if terminal.has_method("set_property"):
        terminal.set_property("state", "error")  # Switch to error state
        terminal.set_property("speed_scale", 2.0)  # Run animation faster
        
    # Or use specific API methods if available
    if terminal.has_method("change_state"):
        terminal.change_state("error")

# Toggle all elements of a specific type
toggle_animated_elements("warning_light", true)  # Turn on all warning lights
toggle_animated_elements("computer_terminal", false)  # Turn off all computers
```

### Connecting to Game Events

You can tie animations to game events in your district script:

```gdscript
# In your district script
func on_security_breach():
    # Activate alarms
    toggle_animated_elements("warning_light", true)
    toggle_animated_elements("security_camera", true)
    
    # Lock doors
    var main_door = get_animated_element("sliding_door", "main_entrance")
    if main_door and main_door.has_method("set_property"):
        main_door.set_property("state", "closed")
```

## Properties Reference

### Common Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `visible` | bool | Whether the element is visible | true |
| `scale` | Vector2 | Scale factor for the element | (1, 1) |
| `rotation` | float | Rotation in degrees | 0 |
| `z_index` | int | Drawing order | 0 |
| `state` | string | Current state name | "default" |

### Type-Specific Properties

#### Computer Terminal
- `frame_delay` (float): Time between frame changes
- `frame_sequence` (array): Custom sequence of frame indices

#### Warning Light
- `color` (Color): Light color
- `pattern` (array): Blinking pattern (e.g., [1, 0, 1, 0, 1, 1, 0])

#### Sliding Door
- `state` (string): "open" or "closed"
- `transition_time` (float): Time for open/close animation

#### Ventilation Fan
- `speed` (float): Rotation speed
- `direction` (int): 1 for clockwise, -1 for counter-clockwise

## Advanced Usage

### Event-Based Animation Control

You can connect animation changes to game events:

```gdscript
# In your game_manager.gd or similar file
func on_power_failure():
    # Get the current district
    var district = get_current_district()
    if district:
        # Turn off all lights
        district.toggle_animated_elements("flickering_light", false)
        district.toggle_animated_elements("computer_terminal", false)
        
        # Start emergency lights
        district.toggle_animated_elements("warning_light", true)
```

### Dynamic Weather Effects

You can use animated elements for weather:

```gdscript
# Create a weather manager script
func set_weather(district, weather_type):
    match weather_type:
        "rain":
            district.toggle_animated_elements("rain_drop", true)
            district.toggle_animated_elements("window_splatter", true)
        "clear":
            district.toggle_animated_elements("rain_drop", false)
            district.toggle_animated_elements("window_splatter", false)
```

## Optimization and Performance

### Element Instancing

By default, each animated element is created as an instance in the scene tree. For performance optimization:

1. **Limit the number of elements** in a single scene (ideally under 20-30)
2. **Disable off-screen elements** when not visible:
   ```gdscript
   func _process(delta):
       # Check if player is far from this area
       if player.position.distance_to(Vector2(800, 600)) > 500:
           toggle_animated_elements("ventilation_fan", false)
       else:
           toggle_animated_elements("ventilation_fan", true)
   ```

3. **Use sprite sheets** for complex animations to reduce texture switches

### Spatial Partitioning

For complex scenes with many animated elements, implement spatial partitioning:

```gdscript
# Example: Simple grid-based culling
var grid_size = 500  # Size of each grid cell
var active_cells = []  # Cells currently being updated

func update_active_cells(player_position):
    var cell_x = floor(player_position.x / grid_size)
    var cell_y = floor(player_position.y / grid_size)
    
    # Define active area (3x3 cells around player)
    var new_active_cells = []
    for x in range(cell_x-1, cell_x+2):
        for y in range(cell_y-1, cell_y+2):
            new_active_cells.append(Vector2(x, y))
    
    # Disable elements in cells that are no longer active
    for cell in active_cells:
        if not cell in new_active_cells:
            disable_elements_in_cell(cell)
    
    # Enable elements in newly active cells
    for cell in new_active_cells:
        if not cell in active_cells:
            enable_elements_in_cell(cell)
    
    active_cells = new_active_cells
```

## Adding New Element Types

To create a new animated element type:

### 1. Create a New Element Script

Create a script in `src/core/districts/element_types/` (create this directory if needed):

```gdscript
# src/core/districts/element_types/rain_effect.gd
extends Node2D

var properties = {}
var is_playing = true
var particles

func _ready():
    # Create particle system
    particles = Particles2D.new()
    particles.amount = 300
    particles.process_material = ParticlesMaterial.new()
    particles.process_material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
    particles.process_material.emission_box_extents = Vector3(500, 1, 1)
    particles.process_material.gravity = Vector3(100, 980, 0)
    add_child(particles)
    
    # Apply initial properties
    set_properties(properties)

func set_properties(new_properties):
    properties = new_properties
    
    # Apply properties to particle system
    if "intensity" in properties:
        particles.amount = int(properties.intensity * 300)
    
    if "speed" in properties:
        particles.process_material.gravity.y = 980 * properties.speed

func set_property(property, value):
    properties[property] = value
    
    match property:
        "enabled":
            is_playing = value
            particles.emitting = value
        "intensity":
            particles.amount = int(value * 300)
        "speed":
            particles.process_material.gravity.y = 980 * value

func get_property(property):
    return properties.get(property, null)
```

### 2. Register with the AnimatedBackgroundManager

Modify the animation manager to support your new type:

```gdscript
# In src/core/districts/animated_background_manager.gd
# Add your new element type to support custom creation

func create_element_node(type, id, position, properties):
    var element
    
    # Handle custom element types
    match type:
        "rain_effect":
            # Load the custom script
            var RainEffectScript = load("res://src/core/districts/element_types/rain_effect.gd")
            element = RainEffectScript.new()
        _:
            # Default to animated sprite for standard types
            element = AnimatedSprite.new()
            # Set up default placeholder animation
            create_placeholder_animation(element, type, properties)
    
    element.name = type + "_" + id
    element.position = position
    
    # Apply properties
    if element.has_method("set_properties"):
        element.set_properties(properties)
    
    return element
```

### 3. Register New Classes

After creating new scripts with `class_name` declarations, register them:

```bash
./a_silent_refraction.sh register-classes
```

## Class Registration

When adding new classes with the `class_name` keyword, you must register them with Godot:

```bash
# Register new classes with Godot editor
./a_silent_refraction.sh register-classes
```

### What This Does

1. Opens the Godot editor to scan your project
2. Automatically registers classes with `class_name` declarations
3. Updates the project.godot file with class references
4. Closes the editor when complete

### When to Register Classes

Register classes whenever you:
- Add a new script that uses `class_name`
- Change the name in an existing `class_name` declaration
- Move a script that uses `class_name` to a different location

## Troubleshooting

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `AnimatedBackgroundManager isn't declared in the current scope` | Class not registered | Run `./a_silent_refraction.sh register-classes` |
| `No loader found for resource` | Asset path incorrect or not imported | Check path and run `./a_silent_refraction.sh import` |
| `Failed loading resource` | Missing .stex file | Run `./a_silent_refraction.sh import` |
| `Division By Zero in operator '%'` | Empty frames array | Add frames or add fallback logic |

### Problems and Solutions

#### Elements Don't Appear

1. Check console for error messages
2. Verify the JSON configuration format is correct
3. Ensure paths to animation frames are correct
4. Confirm that assets have been imported (`./a_silent_refraction.sh import`)
5. Verify the element's position is within view

#### Animation Doesn't Play

1. Check if the element has the `playing` property set to true
2. Verify that animation frames exist and are correctly referenced
3. Check if the animation speed is too slow or too fast

#### Class Registration Issues

If you get errors about classes not being recognized:

1. Run `./a_silent_refraction.sh register-classes`
2. If errors persist, check your script for syntax errors
3. Ensure your class inherits from the correct base class

## Examples

### Example 1: Security System

Create a security system with cameras and warning lights:

```json
{
  "elements": [
    {
      "type": "security_camera",
      "id": "entrance_cam",
      "position": {"x": 400, "y": 100},
      "properties": {
        "pan_angle": 45,
        "rotation_speed": 0.5
      }
    },
    {
      "type": "warning_light",
      "id": "entrance_alarm",
      "position": {"x": 450, "y": 80},
      "properties": {
        "color": "#ff0000",
        "enabled": false
      }
    }
  ]
}
```

Control them from your district script:

```gdscript
func trigger_security_alarm():
    # Enable warning lights
    toggle_animated_elements("warning_light", true)
    
    # Make cameras focus on entrance
    var entrance_cam = get_animated_element("security_camera", "entrance_cam")
    if entrance_cam and entrance_cam.has_method("set_property"):
        entrance_cam.set_property("pan_angle", 0)
        entrance_cam.set_property("rotation_speed", 0)  # Stop rotating
```

### Example 2: Computer Terminal Interaction

Create an interactive computer terminal:

```json
{
  "elements": [
    {
      "type": "computer_terminal",
      "id": "main_computer",
      "position": {"x": 300, "y": 250},
      "states": {
        "idle": {
          "frames": ["res://src/assets/animations/computer/idle001.png", 
                    "res://src/assets/animations/computer/idle002.png"],
          "speed": 0.2,
          "loop": true
        },
        "access_granted": {
          "frames": ["res://src/assets/animations/computer/access001.png",
                    "res://src/assets/animations/computer/access002.png",
                    "res://src/assets/animations/computer/access003.png"],
          "speed": 0.5,
          "loop": false
        }
      },
      "initial_state": "idle"
    }
  ]
}
```

Connect to the interaction system:

```gdscript
# In your district script
func _ready():
    district_name = "Security Room"
    animated_elements_config = "animated_elements_config.json"
    ._ready()
    
    # Set up the computer as an interactive object
    var computer_obj = InteractiveObject.new()
    computer_obj.set_name("MainComputer")
    computer_obj.position = Vector2(300, 250)
    add_child(computer_obj)
    
    # Connect to the interaction signal
    computer_obj.connect("interact", self, "_on_computer_interact")

func _on_computer_interact(verb, item):
    var computer = get_animated_element("computer_terminal", "main_computer")
    
    if verb == "use":
        if GameManager.has_keycard:
            # Show access granted animation
            if computer and computer.has_method("set_property"):
                computer.set_property("state", "access_granted")
            # Trigger game event
            GameManager.unlock_security_door()
        else:
            # Show access denied feedback
            GameManager.show_message("Access denied. Keycard required.")
```

---

With this comprehensive documentation, you should be able to fully leverage the animated background system in your game. For additional support or feature requests, please refer to the project's issue tracker or contact the development team.