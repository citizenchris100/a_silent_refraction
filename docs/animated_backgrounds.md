# Animated Background Elements

This document explains how to use the animated background elements system in A Silent Refraction.

## Overview

The animated background system allows you to add interactive, animated elements to your district backgrounds. These elements can be controlled through code and can respond to player actions and game events.


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

### Method 1: Using Configuration Files

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

## Controlling Elements

You can control elements through code using the district's API:

```gdscript
# Get reference to a specific element
var door = get_animated_element("sliding_door", "main_entrance")
if door:
    # Call element-specific methods
    door.open()  # Opens the door
    
# Toggle all elements of a specific type
toggle_animated_elements("warning_light", true)  # Turn on all warning lights
toggle_animated_elements("computer_terminal", false)  # Turn off all computer terminals
```

Each element type has its own properties and methods for control:

- **Sliding Door**: `open()`, `close()`, `toggle()`
- **Ventilation Fan**: `start()`, `stop()`, `set_speed(factor)`
- **Conveyor Belt**: `start()`, `stop()`, `reverse()`
- **Hologram Display**: `turn_on()`, `turn_off()`
- **Security Camera**: `enable()`, `disable()`, `set_fixed_position(position)`, `resume_patrol()`

## Generating New Elements

Use the generation script to create new animated elements:

```bash
# List available element types
./tools/create_animated_bg_elements.sh list

# Generate a specific element
./tools/create_animated_bg_elements.sh generate computer_terminal bridge_console

# Generate all predefined elements
./tools/create_animated_bg_elements.sh generate-all
```

The script will create:
- PNG frame sequences for each animation state
- A preview animated GIF
- GDScript files that handle the animation logic
- All necessary directories

## Customizing Elements

After generating elements, you can customize them:

1. Edit individual PNG frames in your preferred image editor
2. Adjust animation timing in the GDScript file
3. Add new control methods to the GDScript class

## Adding to the Shipping District Scene

1. Generate the desired elements using the script
2. Create/update the configuration file at `src/districts/shipping/animated_elements_config.json`
3. Make sure the BaseDistrict class is properly handling the animated background manager
4. When the district loads, elements will be automatically added according to the configuration

## Creating New Element Types

To create a new type of animated element:

1. Edit the `create_animated_bg_elements.sh` script
2. Add a new generator function for your element type
3. Register it in the main case statement
4. Update the usage information

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

