# Animation System Documentation

This document explains the animation system for A Silent Refraction, including how to create animated background elements, configure them, and use the animation tools effectively.

## Overview

The animation system allows for dynamic animated elements in district backgrounds. These can include:

- Sprite sequence animations (e.g., flickering lights, moving machinery)
- Shader-based effects (e.g., heat distortion, CRT screens, holograms)
- Interactive animated elements that respond to player actions

## Animation Configuration

Each district can have animated elements defined in a JSON configuration file located at:
```
src/districts/<district_name>/animated_elements_config.json
```

### Configuration Structure

The configuration file has the following structure:

```json
{
    "district": "district_name",
    "background": "res://path/to/background.png",
    "animated_elements": [
        {
            "name": "element_name",
            "type": "sprite_sequence",
            "position": {"x": 100, "y": 100},
            "frames_path": "res://path/to/frames/prefix",
            "frame_count": 4,
            "animation_speed": 5.0,
            "loop": true,
            "autoplay": true,
            "scale": {"x": 1.0, "y": 1.0},
            "z_index": 0
        }
    ],
    "shader_effects": [
        {
            "name": "effect_name",
            "type": "heat_distortion",
            "position": {"x": 200, "y": 150},
            "size": {"width": 100, "height": 100},
            "intensity": 0.5,
            "speed": 1.0,
            "z_index": 1
        }
    ],
    "interactive_zones": [
        {
            "name": "zone_name",
            "position": {"x": 300, "y": 200},
            "size": {"width": 50, "height": 50},
            "hover_animation": "pulse",
            "click_action": "animate",
            "target_element": "element_name"
        }
    ]
}
```

### Element Types

#### Sprite Sequence Animation

A series of sprites played in sequence to create animation:

```json
{
    "name": "light_flicker",
    "type": "sprite_sequence",
    "position": {"x": 100, "y": 100},
    "frames_path": "res://src/assets/backgrounds/animated_elements/shipping/light",
    "frame_count": 4,
    "animation_speed": 5.0,
    "loop": true,
    "autoplay": true,
    "scale": {"x": 1.0, "y": 1.0},
    "z_index": 0
}
```

The frames should be named like: `light1.png`, `light2.png`, etc.

#### Shader Effect

Custom shader effects applied to a region:

```json
{
    "name": "window_heat",
    "type": "heat_distortion",
    "position": {"x": 200, "y": 150},
    "size": {"width": 100, "height": 100},
    "intensity": 0.5,
    "speed": 1.0,
    "z_index": 1
}
```

Available shader types:
- `heat_distortion` - Creates a wavy heat distortion effect
- `crt_screen` - Simulates an old CRT display with scanlines
- `hologram` - Creates a holographic projection effect

#### Interactive Zone

Regions that can be interacted with by the player:

```json
{
    "name": "control_panel",
    "position": {"x": 300, "y": 200},
    "size": {"width": 50, "height": 50},
    "hover_animation": "pulse",
    "click_action": "animate",
    "target_element": "control_lights"
}
```

Available actions:
- `animate` - Starts/stops an animation
- `toggle` - Toggles between states
- `trigger` - Triggers a one-shot animation

## Animation Tools

### Create Animation Config

Creates a template configuration file for a district:

```bash
./tools/create_animation_config.sh <district_name>
```

Example:
```bash
./tools/create_animation_config.sh shipping
```

This will create:
- A template JSON configuration file
- Required directories for animation assets if they don't exist

### Validate Animation Config

Validates the configuration file and checks for missing assets:

```bash
./tools/validate_animation_config.sh <district_name>
# or
./tools/validate_animation_config.sh --all
```

The validator checks:
- JSON format validity
- Existence of background image
- Existence of animation frame files
- Validity of shader types

### Update Animation Paths

Updates paths in configuration files when assets are reorganized:

```bash
./tools/update_animation_paths.sh [options]
```

Options:
- `--district <name>` - Update a specific district
- `--all` - Update all districts
- `--old-path <path>` - Path pattern to replace
- `--new-path <path>` - New path to use
- `--dry-run` - Show changes without applying them

Example:
```bash
./tools/update_animation_paths.sh --district shipping --old-path "old_folder" --new-path "new_folder"
```

## Workflow for Creating Animated Elements

1. **Create the district** if it doesn't exist yet:
   ```bash
   ./a_silent_refraction.sh new-district <district_name>
   ```

2. **Create a template animation config**:
   ```bash
   ./tools/create_animation_config.sh <district_name>
   ```

3. **Prepare animation assets**:
   - Create frame-by-frame animations and save them in the `src/assets/backgrounds/animated_elements/<district_name>/` directory
   - Name frames sequentially, e.g., `element1.png`, `element2.png`, etc.

4. **Edit the configuration file** to define your animations:
   - Set correct paths, positions, and parameters
   - Add all animated elements, shader effects, and interactive zones

5. **Validate your configuration**:
   ```bash
   ./tools/validate_animation_config.sh <district_name>
   ```

6. **Test the animations**:
   ```bash
   ./run_animation_test.sh <district_name>
   ```

7. **Integrate with gameplay** by using the `AnimatedBackgroundManager` in your district script:
   ```gdscript
   extends BaseDistrict
   
   func _ready():
       # Load animations from config
       animated_background_manager.load_from_config()
       
       # Connect signals for interactive elements if needed
       animated_background_manager.connect("element_clicked", self, "_on_animated_element_clicked")
       
       # Call parent _ready() AFTER setup
       ._ready()
   
   func _on_animated_element_clicked(element_name):
       # Handle interaction with animated elements
       match element_name:
           "control_panel":
               # Do something when control panel is clicked
               pass
   ```

## Cyan Window Technique

For creating animated windows with transparent elements, use the cyan keying technique:

1. Create animation frames with cyan (RGB: 0, 255, 255) as the "transparent" color
2. In your configuration, enable the "cyan_keying" option:
   ```json
   {
       "name": "window_animation",
       "type": "sprite_sequence",
       "frames_path": "res://src/assets/backgrounds/animated_elements/shipping/window",
       "frame_count": 8,
       "cyan_keying": true,
       "animation_speed": 5.0
   }
   ```

3. The system will automatically replace cyan pixels with transparent ones

## Advanced Features

### State-Based Animations

You can define state-dependent animations that change based on game state:

```json
{
    "name": "security_camera",
    "type": "sprite_sequence",
    "states": {
        "active": {
            "frames_path": "res://src/assets/backgrounds/animated_elements/security/active",
            "frame_count": 4
        },
        "disabled": {
            "frames_path": "res://src/assets/backgrounds/animated_elements/security/disabled",
            "frame_count": 2
        }
    },
    "default_state": "active"
}
```

To change states from code:
```gdscript
animated_background_manager.set_element_state("security_camera", "disabled")
```

### Composite Animations

For more complex animations combining multiple layers:

```json
{
    "name": "radar_display",
    "type": "composite",
    "layers": [
        {
            "name": "base",
            "type": "sprite_sequence",
            "frames_path": "res://src/assets/backgrounds/animated_elements/radar/base",
            "frame_count": 1,
            "z_index": 0
        },
        {
            "name": "sweep",
            "type": "sprite_sequence",
            "frames_path": "res://src/assets/backgrounds/animated_elements/radar/sweep",
            "frame_count": 8,
            "z_index": 1
        },
        {
            "name": "overlay",
            "type": "shader_effect",
            "shader_type": "crt_screen",
            "z_index": 2
        }
    ]
}
```

## Troubleshooting

### Common Issues

1. **Missing frames**: Frame filenames must follow exactly the pattern specified in `frames_path` plus the frame number. Check that all frames exist and are numbered correctly.

2. **Path issues**: Always use `res://` paths in the configuration, not absolute paths.

3. **Shader errors**: Make sure the shader file exists in `src/shaders/` and is properly formatted.

4. **Performance concerns**: Reduce the number of simultaneous animations or shader effects if performance drops.

### Error Handling

The animation system includes robust error handling to prevent crashes:

- If a frame is missing, the system will skip it and log an error
- If a shader can't be loaded, a fallback will be used
- If a configuration is invalid, default values will be used where possible

Check the console output for warnings and errors when testing animations.