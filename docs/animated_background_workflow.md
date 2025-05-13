# Animated Background Workflow

This document outlines the canonical workflow for creating and implementing animated background elements in A Silent Refraction.

## Table of Contents
1. [Overview](#overview)
2. [Pre-Production](#pre-production)
3. [Asset Creation](#asset-creation)
   - [Midjourney Prompt Guide](#midjourney-prompt-guide)
   - [RunwayML Animation Tips](#runwayml-animation-tips)
   - [ImageMagick Processing](#imagemagick-processing)
4. [Implementation](#implementation)
5. [Native Godot Effects](#native-godot-effects)
   - [Particle Systems](#particle-systems)
   - [AnimationPlayer](#animationplayer)
   - [Light2D Nodes](#light2d-nodes)
   - [CanvasModulate](#canvasmodulate)
   - [Shader Effects](#shader-effects)
   - [Plugin Options](#plugin-options)
   - [Effect Composition](#effect-composition)
6. [Testing and Refinement](#testing-and-refinement)
7. [Integration with Game Events](#integration-with-game-events)
8. [Optimization](#optimization)
9. [Command Reference](#command-reference)

## Overview

The animated background workflow is a structured process that takes animated elements from concept to implementation. It combines AI-assisted asset generation, configuration-driven implementation, and integration with game systems to create dynamic, responsive game environments.

### Core Principles

1. **Modular Design**: Each animated element is self-contained and reusable
2. **Configuration-Driven**: Element behavior is defined in JSON, minimizing code changes
3. **Performance-Conscious**: Elements are optimized to minimize performance impact
4. **Event-Responsive**: Elements respond to game events and player actions
5. **Visually Consistent**: Elements match the game's established art style

## Pre-Production

### 1. Element Planning

Start by planning which elements you need and how they'll enhance the environment:

1. **Identify Locations**: Determine which district and specific scene will contain the element
2. **Define Purpose**: Decide if the element is:
   - Ambient (purely visual, like a blinking light)
   - Interactive (responds to player actions)
   - Narrative (conveys story information)
   - Functional (affects gameplay, like a door)

2. **Create Element Specification**:
   
```
Element: Security Camera
Type: security_camera
Location: Shipping District - Main Floor
Purpose: Ambient + Narrative (shows security state)
States:
  - normal: Regular panning motion
  - alert: Rapid scanning motion
  - disabled: Drooping, non-functional
Trigger Events:
  - alarm activation -> alert state
  - power failure -> disabled state
```

### 2. Storyboarding (For Complex Animations)

For complex animated sequences like the tram system:

1. Create a sequence diagram showing each step of the animation
2. Define key frames and transition points
3. Identify any player interaction points
4. Note which game events trigger state changes

Example: Tram Arrival Sequence
```
1. Announcement light begins flashing
2. Status display changes to "Arriving"
3. Tram appears from tunnel (sliding animation)
4. Tram slows to stop at platform
5. Door status light changes from red to green
6. Doors open with sliding animation
7. Interior lights brighten
8. "Enter" prompt appears if player is nearby
```

## Asset Creation

### 1. Background Element Design

For each animated element, create design reference:

1. **Reference Gathering**:
   - Collect examples that match the desired art style
   - Identify key visual characteristics

### Midjourney Prompt Guide

For background element generation, use these prompt patterns to achieve consistent, game-ready assets:

#### Base Prompt Template

```
[element name] in retro pixel art style, [bit depth] graphics, 90s adventure game, [view angle], 
[aesthetic reference], limited color palette, [element context], [size] sprite --ar [aspect ratio]
```

#### Element Type-Specific Prompts

##### Electronic Elements (Computers, Terminals, Screens)

```
computer terminal with glowing screen, retro pixel art style, 16-bit graphics, isometric view,
neo-geo aesthetic, cyberpunk station, blinking lights, 64x64 sprite --ar 1:1
```

```
security console with multiple displays, retro pixel art style, 16-bit graphics, front view, 
90s adventure game, Alien (1979) industrial aesthetic, limited color palette, control room, 
128x64 sprite --ar 2:1
```

##### Mechanical Elements (Doors, Vents, Machinery)

```
sliding security door, retro pixel art style, 32-bit graphics, side view, Total Recall (1990) 
aesthetic, metallic texture, space station, hydraulic mechanism, 64x128 sprite --ar 1:2
```

```
industrial ventilation fan, retro pixel art style, 16-bit graphics, front view, Blade Runner 
aesthetic, metal grille with spinning blades, steampunk influenced, 64x64 sprite --ar 1:1
```

##### Environmental Elements (Steam, Water, Weather)

```
steam vent on metal floor, retro pixel art style, 16-bit graphics, top-down view, Alien (1979) 
aesthetic, industrial pipes, periodic bursts, with animation frames, 64x64 sprite --ar 1:1
```

```
water puddle with subtle ripples, retro pixel art style, 16-bit graphics, top-down view, 
cyberpunk aesthetic, reflective surface, maintenance area, 64x64 sprite --ar 1:1
```

##### Lighting Elements (Lamps, Warning Lights, Signs)

```
emergency warning light, retro pixel art style, 16-bit graphics, side view, Alien (1979) 
aesthetic, red flashing beacon, industrial mounting, 32x32 sprite --ar 1:1
```

```
neon sign for "Bar", retro pixel art style, 16-bit graphics, front view, Blade Runner aesthetic, 
glowing tubes, flickering effect, cyberpunk district, 128x32 sprite --ar 4:1
```

#### Animation Key Frame Prompts

For generating animation sequences, use these prompt patterns to create consistent key frames:

##### Numbered Frame Sequence

```
[element] frame [X] of [total], [specific pose/state], retro pixel art style, 16-bit graphics, 
[view angle], consistent lighting and perspective, [aesthetic reference], 
[size] sprite --ar [aspect ratio]
```

Examples:

```
security camera, frame 1 of 4, pointing left, retro pixel art style, 16-bit graphics, side view, 
consistent lighting and perspective, industrial space station aesthetic, 32x32 sprite --ar 1:1
```

```
security camera, frame 2 of 4, pointing center-left, retro pixel art style, 16-bit graphics, 
side view, consistent lighting and perspective, industrial space station aesthetic, 
32x32 sprite --ar 1:1
```

##### State-Based Frame Sequence

```
[element] in [state] state, [specific detail], retro pixel art style, 16-bit graphics, 
[view angle], [aesthetic reference], animation ready, [size] sprite --ar [aspect ratio]
```

Examples:

```
sliding door in closed state, security lock engaged, retro pixel art style, 16-bit graphics, 
front view, Total Recall aesthetic, animation ready, 64x128 sprite --ar 1:2
```

```
sliding door in half-open state, security lock disengaged, retro pixel art style, 16-bit graphics, 
front view, Total Recall aesthetic, animation ready, 64x128 sprite --ar 1:2
```

```
sliding door in fully open state, retracted into wall, retro pixel art style, 16-bit graphics, 
front view, Total Recall aesthetic, animation ready, 64x128 sprite --ar 1:2
```

#### Multi-Frame Generation Tips

For generating a series of related frames in one prompt, try:

```
4-frame animation sequence of [element] [action], retro pixel art style, 16-bit graphics, 
[view angle], [aesthetic reference], sprite sheet layout, [size] sprites --ar 4:1
```

Example:

```
4-frame animation sequence of ventilation fan spinning, retro pixel art style, 16-bit graphics, 
front view, Alien (1979) aesthetic, sprite sheet layout, 32x32 sprites --ar 4:1
```

#### Style Variants

Adjust these parameters to match different art styles:

- **Neo Geo Style**: `neo-geo aesthetic, vibrant colors, smooth pixels, 32-bit era graphics`
- **Sierra-Style**: `sierra adventure game, dithered shadows, 256 color palette, VGA graphics`
- **Sci-Fi Industrial**: `Alien (1979) inspired, industrial greebles, metallic textures, dark tones`
- **Cyberpunk**: `Blade Runner aesthetic, neon accents, high contrast, atmospheric lighting`

### RunwayML Animation Tips

RunwayML is excellent for refining animations, especially for smooth transitions between key frames. Here are specific tips for different animation types:

#### Basic Setup

1. In RunwayML, use the **Gen-2** or **Video-to-Video** feature
2. Upload your key frames from Midjourney
3. Use these prompts to generate intermediate frames

#### Motion Animations (Camera Panning, Door Movement)

```
Create smooth interpolation of security camera panning from left to right, consistent pixel art style, 
maintain perfect 16-bit retro game aesthetic, no style changes between frames, mechanical movement, 
60fps animation
```

```
Generate intermediate frames for sliding door animation sequence, consistent pixel art style, 
smooth mechanical motion, maintain exact pixel dimensions and perspective, 90s video game quality, 
32-bit graphics fidelity
```

#### Cyclic Animations (Fans, Pumps, Blinking)

```
Generate seamless looping animation of ventilation fan spinning, perfectly consistent pixel art style, 
maintain exact sprite dimensions, clean mechanical rotation, 16-bit retro game quality
```

```
Create fluid looping animation of computer screen cycling through displays, maintain consistent 
pixel art style, subtle electronic glow effects, no style drift, perfect loop transition from 
last frame to first
```

#### Environmental Effects (Steam, Water, Particles)

```
Interpolate frames of steam vent emission, fluffy pixel art style steam cloud, gradual dissipation, 
maintain consistent artistic style, soft particle movement, 16-bit era game quality
```

```
Generate smooth water ripple animation sequence, subtle pixel art style water movement, consistent 
lighting and reflection, maintain exact color palette, gentle undulation, perfect for background element
```

#### Lighting Effects (Flashing, Glowing, Pulsing)

```
Create smooth warning light flashing sequence, consistent pixel art style, maintain exact sprite 
dimensions, dramatic red light illumination and falloff, no style changes, 90s game aesthetic
```

```
Generate holographic display animation, subtle pulsing glow effect, consistent pixel art style, 
bluish electronic light emission, maintain perfect sprite dimensions, 16-bit game quality
```

#### Key RunwayML Settings

- **Frame Rate**: 12fps for most background animations (matches classic adventure games)
- **Consistency**: Set "Maintain style consistency" to maximum
- **Steps**: 20-30 for smoother transitions
- **CFG Scale**: 7-10 for balanced results
- **Frame Count**: For most elements, generate 8-12 frames total

#### Troubleshooting Common RunwayML Issues

1. **Style Drift**: If frames start changing art style, use "Maintain consistency between frames" option and specify "exact same pixel art style" in your prompt
2. **Dimension Changes**: If sprite dimensions change, specify exact dimensions in your prompt and use "maintain exact sprite dimensions"
3. **Unwanted Elements**: If extra details appear, use negative prompts like "no additional details, no background changes, no style evolution"
4. **Stuttering**: If animation stutters, try increasing frame count and adding "smooth motion" to your prompt

### ImageMagick Processing

Once you have your animation frames, process them to match the game's style:

1. **Downscaling and Pixel Art Conversion**:
   ```bash
   # Process animation frames using ImageMagick
   ./tools/process_animation_frames.sh src/assets/animations/security_camera/ --size 32x32 --style neo_geo
   ```

2. **Create Animation States**:
   Organize frames into state-specific directories:
   ```
   src/assets/animations/
     security_camera/
       normal/
         frame001.png
         frame002.png
         ...
       alert/
         frame001.png
         frame002.png
         ...
       disabled/
         frame001.png
   ```

3. **Import to Godot**:
   ```bash
   # Import all new animation assets into the project
   ./a_silent_refraction.sh import
   ```

## Implementation

### 1. JSON Configuration

Create or update the district's animation configuration file:

1. **Add Element Definition**:
   ```bash
   # Open the district's animation config file
   nano src/districts/shipping/animated_elements_config.json
   ```

2. **Add JSON Configuration**:
   ```json
   {
     "elements": [
       {
         "type": "security_camera",
         "id": "main_entrance",
         "position": {
           "x": 450,
           "y": 120
         },
         "properties": {
           "scan_angle": 45,
           "scan_speed": 0.5
         },
         "states": {
           "normal": {
             "frames": [
               "res://src/assets/animations/security_camera/normal/frame001.png",
               "res://src/assets/animations/security_camera/normal/frame002.png",
               "res://src/assets/animations/security_camera/normal/frame003.png",
               "res://src/assets/animations/security_camera/normal/frame004.png"
             ],
             "speed": 0.5,
             "loop": true
           },
           "alert": {
             "frames": [
               "res://src/assets/animations/security_camera/alert/frame001.png",
               "res://src/assets/animations/security_camera/alert/frame002.png",
               "res://src/assets/animations/security_camera/alert/frame003.png",
               "res://src/assets/animations/security_camera/alert/frame004.png"
             ],
             "speed": 1.0,
             "loop": true
           }
         },
         "initial_state": "normal"
       }
     ]
   }
   ```

### 2. Custom Element Types (If Required)

If the element needs custom functionality beyond standard animations:

1. **Create Element Script**:
   ```bash
   # Create a new element type script
   nano src/core/districts/element_types/security_camera.gd
   ```

2. **Implement Custom Logic**:
   ```gdscript
   extends Node2D
   class_name SecurityCamera

   var properties = {}
   var current_state = "normal"
   var animation_player
   var detection_area

   func _ready():
       # Create animation player
       animation_player = AnimationPlayer.new()
       add_child(animation_player)
       
       # Create detection area
       detection_area = Area2D.new()
       var collision_shape = CollisionShape2D.new()
       var shape = ConvexPolygonShape2D.new()
       collision_shape.shape = shape
       detection_area.add_child(collision_shape)
       add_child(detection_area)
       
       # Apply initial properties
       set_properties(properties)
       
       # Connect signals
       detection_area.connect("body_entered", self, "_on_body_entered")

   func set_properties(new_properties):
       properties = new_properties
       
       # Apply properties to components
       if "scan_angle" in properties:
           update_detection_area(properties.scan_angle)
       
       if "scan_speed" in properties:
           if animation_player.has_animation("scan"):
               animation_player.set_speed_scale(properties.scan_speed)

   func _on_body_entered(body):
       if body.is_in_group("player") and current_state == "normal":
           # Notify game manager of player detection
           var game_manager = get_node("/root/GameManager")
           if game_manager:
               game_manager.on_camera_detected_player(self)
   ```

3. **Register New Class**:
   ```bash
   # Register the new class with Godot
   ./a_silent_refraction.sh register-classes
   ```

### 3. Integration with District

Ensure the district is set up to use the animation system:

1. **Update District Script**:
   ```gdscript
   # In shipping_district.gd
   func _ready():
       district_name = "Shipping District"
       district_description = "The station's dock area where ships arrive with cargo and passengers."
       animated_elements_config = "animated_elements_config.json"

       # Call parent _ready
       ._ready()

       # Add event connections for animations
       if animated_bg_manager:
           connect_animation_events()

   func connect_animation_events():
       # Connect game events to animation state changes
       GameManager.connect("security_alert_changed", self, "_on_security_alert_changed")

   func _on_security_alert_changed(is_alert):
       # Change all security cameras to appropriate state
       var cameras = animated_bg_manager.get_elements_by_type("security_camera")
       for camera in cameras:
           if camera.has_method("set_property"):
               camera.set_property("state", "alert" if is_alert else "normal")
   ```

## Native Godot Effects

While sprite-based animations provide a consistent look and feel aligned with the retro aesthetic, Godot's built-in effects can complement these with dynamic elements. These effects are particularly useful for atmospheric elements, subtle movements, and lighting variations.

### Particle Systems

[CPUParticles2D](https://docs.godotengine.org/en/3.5/classes/class_cpuparticles2d.html) nodes are perfect for creating atmospheric effects that enhance the environment:

#### Ideal Uses:
- **Dust Particles**: Floating in the air to add depth to a scene
- **Steam/Smoke**: Emerging from vents or machinery
- **Sparks**: Brief flashes from electrical equipment
- **Fog/Mist**: Light atmospheric layers

#### Implementation Example:
```gdscript
# Create dust particles for a room
var dust_particles = CPUParticles2D.new()
dust_particles.name = "DustParticles"
dust_particles.amount = 15
dust_particles.lifetime = 8.0
dust_particles.explosiveness = 0.0
dust_particles.randomness = 0.8
dust_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
dust_particles.emission_box_extents = Vector2(300, 100)
dust_particles.direction = Vector2(0.1, -0.05)
dust_particles.spread = 20
dust_particles.gravity = Vector2(0, 0)
dust_particles.initial_velocity = 5
dust_particles.scale_amount = 1.5
dust_particles.color = Color(1, 1, 1, 0.1)
add_child(dust_particles)
```

#### JSON Configuration Integration:
```json
{
  "elements": [
    {
      "type": "particle_effect",
      "id": "room_dust",
      "position": {
        "x": 400,
        "y": 300
      },
      "properties": {
        "particle_type": "dust",
        "amount": 15,
        "lifetime": 8.0,
        "area_width": 300,
        "area_height": 100,
        "color": "#FFFFFF20"
      }
    }
  ]
}
```

### AnimationPlayer

The [AnimationPlayer](https://docs.godotengine.org/en/3.5/classes/class_animationplayer.html) node can create cyclical environmental animations that bring static elements to life:

#### Ideal Uses:
- **Flickering Lights**: Subtle color/intensity changes
- **Pulsing Signs**: Neon or holographic elements
- **Machinery Vibrations**: Small position offsets
- **Animated Shadows**: Suggesting off-screen movement

#### Implementation Example:
```gdscript
# Create flickering light effect
var light_node = Light2D.new()
light_node.name = "FlickeringLight"
light_node.position = Vector2(200, 150)
light_node.texture = preload("res://src/assets/light_texture.png")
light_node.color = Color(0.9, 0.8, 0.7)
light_node.energy = 1.0
add_child(light_node)

var anim = AnimationPlayer.new()
anim.name = "LightAnimations"
add_child(anim)

# Create flickering animation
var animation = Animation.new()
var track_index = animation.add_track(Animation.TYPE_VALUE)
animation.track_set_path(track_index, "FlickeringLight:energy")
animation.length = 2.0

# Add keyframes for flickering
animation.track_insert_key(track_index, 0.0, 1.0)
animation.track_insert_key(track_index, 0.2, 0.8)
animation.track_insert_key(track_index, 0.3, 0.9)
animation.track_insert_key(track_index, 0.5, 0.7)
animation.track_insert_key(track_index, 0.6, 0.9)
animation.track_insert_key(track_index, 1.0, 1.0)
animation.track_insert_key(track_index, 1.5, 0.9)
animation.track_insert_key(track_index, 1.7, 0.7)
animation.track_insert_key(track_index, 2.0, 1.0)
animation.loop = true

anim.add_animation("flicker", animation)
anim.play("flicker")
```

#### JSON Configuration Integration:
```json
{
  "elements": [
    {
      "type": "animated_light",
      "id": "ceiling_flicker",
      "position": {
        "x": 200,
        "y": 150
      },
      "properties": {
        "animation_type": "flicker",
        "color": "#E5CCB3",
        "radius": 150,
        "intensity_min": 0.7,
        "intensity_max": 1.0,
        "period": 2.0
      }
    }
  ]
}
```

### Light2D Nodes

Godot's [Light2D](https://docs.godotengine.org/en/3.5/classes/class_light2d.html) system adds dynamic lighting to create atmosphere and depth:

#### Ideal Uses:
- **Dynamic Light Sources**: Warning lights, flashlights
- **Light Masks**: For dramatic shadows
- **Colored Lighting**: Mood-enhancing tints
- **Light Occlusion**: Realistic shadow casting

#### Implementation Example:
```gdscript
# Create rotating warning light
var warning_light = Light2D.new()
warning_light.name = "WarningLight"
warning_light.position = Vector2(300, 200)
warning_light.texture = preload("res://src/assets/warning_light_texture.png")
warning_light.color = Color(1, 0.2, 0.2)  # Red warning light
warning_light.energy = 1.2
warning_light.mode = Light2D.MODE_ADD
warning_light.range_layer_min = -1
warning_light.range_layer_max = 1
add_child(warning_light)

# Rotation animation
var tween = Tween.new()
add_child(tween)
tween.interpolate_property(
    warning_light, "rotation",
    0, 2 * PI, 4.0,
    Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
)
tween.repeat = true
tween.start()
```

#### JSON Configuration Integration:
```json
{
  "elements": [
    {
      "type": "warning_light",
      "id": "emergency_beacon",
      "position": {
        "x": 300,
        "y": 200
      },
      "properties": {
        "color": "#FF3333",
        "energy": 1.2,
        "rotation_speed": 4.0,
        "mode": "add"
      }
    }
  ]
}
```

### CanvasModulate

The [CanvasModulate](https://docs.godotengine.org/en/3.5/classes/class_canvasmodulate.html) node allows global color adjustments for atmospheric effects:

#### Ideal Uses:
- **Time of Day**: Color tinting for day/night cycles
- **Emergency Mode**: Red tint during alerts
- **Power Fluctuations**: Global dimming/brightening
- **Special Areas**: Distinct atmospheric zones

#### Implementation Example:
```gdscript
# Create ambient lighting control
var canvas_modulate = CanvasModulate.new()
canvas_modulate.name = "AmbientLighting"
canvas_modulate.color = Color(0.9, 0.9, 1.0)  # Slight cool tint
add_child(canvas_modulate)

# Function to change global lighting
func set_emergency_lighting(emergency_active):
    var tween = Tween.new()
    add_child(tween)

    var target_color = Color(1.0, 0.5, 0.5) if emergency_active else Color(0.9, 0.9, 1.0)

    tween.interpolate_property(
        $AmbientLighting, "color",
        $AmbientLighting.color, target_color, 1.0,
        Tween.TRANS_SINE, Tween.EASE_IN_OUT
    )
    tween.start()
```

#### District Integration:
```gdscript
# In shipping_district.gd
func _on_security_alert_changed(is_alert):
    # Change all security cameras to appropriate state
    var cameras = animated_bg_manager.get_elements_by_type("security_camera")
    for camera in cameras:
        if camera.has_method("set_property"):
            camera.set_property("state", "alert" if is_alert else "normal")

    # Change global lighting to emergency mode
    set_emergency_lighting(is_alert)
```

### Shader Effects

Custom [shaders](https://docs.godotengine.org/en/3.5/tutorials/shaders/shader_reference/shading_language.html) create specialized visual effects:

#### Ideal Uses:
- **Heat Distortion**: Near machinery or hot surfaces
- **Holographic Displays**: Scan lines and glitches
- **Water Caustics**: Light patterns on surfaces
- **Electronic Interference**: Screen static/distortion

#### Implementation Example:
```gdscript
# Create holographic display
var hologram = Sprite.new()
hologram.name = "HolographicDisplay"
hologram.position = Vector2(250, 300)
hologram.texture = preload("res://src/assets/hologram_base.png")
add_child(hologram)

# Apply holographic shader
var shader_material = ShaderMaterial.new()
shader_material.shader = preload("res://src/shaders/hologram.shader")
shader_material.set_shader_param("scan_line_intensity", 0.2)
shader_material.set_shader_param("color", Color(0, 0.8, 1.0, 0.8))
shader_material.set_shader_param("flicker_intensity", 0.03)
shader_material.set_shader_param("time_scale", 1.0)
hologram.material = shader_material
```

Example hologram shader (`hologram.shader`):
```glsl
shader_type canvas_item;

uniform float scan_line_intensity : hint_range(0.0, 1.0) = 0.2;
uniform vec4 color : hint_color = vec4(0.0, 0.8, 1.0, 0.8);
uniform float flicker_intensity : hint_range(0.0, 0.1) = 0.03;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

void fragment() {
    // Base texture
    vec4 base_color = texture(TEXTURE, UV);

    // Scan lines
    float scan_line = sin(UV.y * 100.0 + TIME * time_scale) * 0.5 + 0.5;
    scan_line = pow(scan_line, 10.0) * scan_line_intensity;

    // Flicker effect
    float flicker = sin(TIME * 10.0 * time_scale) * 0.5 + 0.5;
    flicker = pow(flicker, 16.0) * flicker_intensity;

    // Edge glow
    float edge = (1.0 - base_color.a) * 0.1;

    // Final color
    COLOR = base_color;
    COLOR.rgb = mix(COLOR.rgb, color.rgb, 0.8);
    COLOR.rgb += vec3(scan_line);
    COLOR.rgb += vec3(flicker);
    COLOR.rgb += vec3(edge);
    COLOR.a = base_color.a;
}
```

#### JSON Configuration Integration:
```json
{
  "elements": [
    {
      "type": "holographic_display",
      "id": "security_hologram",
      "position": {
        "x": 250,
        "y": 300
      },
      "properties": {
        "base_texture": "res://src/assets/hologram_base.png",
        "color": "#00CCFF",
        "scan_line_intensity": 0.2,
        "flicker_intensity": 0.03
      }
    }
  ]
}
```

### Plugin Options

Several Godot plugins can enhance your background animations:

#### 1. SmartShape2D
- Perfect for dynamic cables, pipes, or wires
- Can be animated to sway or pulse
- Easily creates curved surfaces

#### 2. Advanced Particle System Plugins
- Particle Designer for visual editing
- Particle collision support
- More complex particle behaviors

#### 3. Better Shader Collection
- Pre-made shaders for common effects
- Water, fire, and smoke effects
- CRT and VHS distortion effects

### Effect Composition

Combining multiple techniques creates the most compelling environments:

#### Example: Atmospheric Server Room
```gdscript
extends Node2D

func _ready():
    # 1. Add base animated sprites (pre-rendered)
    var server_lights = animated_bg_manager.add_element(
        "blinking_light", "server_status", Vector2(300, 200))

    # 2. Add particle effects for atmosphere
    var dust = _create_dust_particles()
    add_child(dust)

    # 3. Add dynamic lighting
    var main_light = _create_flickering_light()
    add_child(main_light)

    # 4. Add shader effect for screens
    var monitor = _create_monitor_with_shader()
    add_child(monitor)

    # 5. Setup global ambient lighting
    var ambient = CanvasModulate.new()
    ambient.color = Color(0.8, 0.85, 1.0)  # Slight blue tint
    add_child(ambient)

func _create_dust_particles():
    var particles = CPUParticles2D.new()
    particles.amount = 15
    particles.lifetime = 10.0
    particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
    particles.emission_box_extents = Vector2(400, 150)
    particles.gravity = Vector2(0, -1)
    particles.initial_velocity = 5
    particles.scale_amount = 1.0
    particles.color = Color(1, 1, 1, 0.1)
    return particles

func _create_flickering_light():
    var light = Light2D.new()
    light.texture = preload("res://src/assets/light_texture.png")
    light.position = Vector2(250, 150)
    light.color = Color(0.9, 0.95, 1.0)
    light.energy = 0.8

    # Add random flickering
    var timer = Timer.new()
    timer.wait_time = 0.1
    timer.autostart = true
    light.add_child(timer)
    timer.connect("timeout", self, "_on_light_flicker", [light])

    return light

func _on_light_flicker(light):
    # Random subtle energy changes
    light.energy = rand_range(0.75, 0.85)

func _create_monitor_with_shader():
    var monitor = Sprite.new()
    monitor.texture = preload("res://src/assets/monitor_screen.png")
    monitor.position = Vector2(350, 200)

    # Apply CRT shader
    var material = ShaderMaterial.new()
    material.shader = preload("res://src/shaders/crt_screen.shader")
    material.set_shader_param("distortion", 0.1)
    material.set_shader_param("scanline_intensity", 0.2)
    monitor.material = material

    return monitor
```

## Testing and Refinement

### 1. In-Editor Testing

Test the animation in the Godot editor:

1. **Open the District Scene**:
   ```bash
   # Run the district in debug mode
   ./a_silent_refraction.sh debug-district shipping
   ```

2. **Verify Animation Playback**:
   - Check animation playback speed and smoothness
   - Verify the element appears at the correct position
   - Test all states by using the debug console

3. **Adjust as Needed**:
   - Modify frame timing or position
   - Adjust properties like scan angle or speed
   - Update or add frames if needed

### 2. Integration Testing

Test the animation with game systems:

1. **Test Event Triggers**:
   - Trigger relevant game events
   - Verify animation state changes appropriately
   - Test player interaction if applicable

2. **Test Performance**:
   - Monitor FPS with multiple animations active
   - Check memory usage
   - Test on lower-end target hardware if possible

## Integration with Game Events

### 1. Define Event-Animation Mappings

Create clear mappings between game events and animation states:

1. **Update Game Manager**:
   ```gdscript
   # In game_manager.gd
   signal security_alert_changed(is_alert)
   
   var security_alert_level = 0
   
   func set_security_alert(level):
       security_alert_level = level
       emit_signal("security_alert_changed", level > 0)
   ```

2. **Create Animation Response Functions**:
   ```gdscript
   # In shipping_district.gd
   func on_power_failure():
       # Disable all electronic elements
       toggle_animated_elements("computer_terminal", false)
       toggle_animated_elements("security_camera", false)
       
       # Enable emergency lights
       toggle_animated_elements("emergency_light", true)
   
   func on_tram_arrival():
       # Start tram arrival sequence
       var tram = get_animated_element("tram_system", "main_station")
       if tram and tram.has_method("set_property"):
           tram.set_property("state", "arriving")
   ```

### 2. Connect Animation Events

Set up animations to trigger game events:

```gdscript
# In shipping_district.gd
func _ready():
    # Other setup code...
    
    # Connect animation signals
    animated_bg_manager.connect("element_state_changed", self, "_on_element_state_changed")

func _on_element_state_changed(element_id, property):
    if element_id == "security_camera_main_entrance" and property == "state":
        var camera = get_animated_element("security_camera", "main_entrance")
        if camera.get_property("state") == "alert":
            GameManager.log_security_event("Camera activated in Shipping District")
```

## Optimization

### 1. Performance Monitoring

Add tools to monitor animation performance:

```gdscript
# In animated_background_manager.gd
var performance_stats = {
    "active_elements": 0,
    "total_frames": 0,
    "update_time": 0
}

func _process(delta):
    var start_time = OS.get_ticks_msec()
    
    # Process animations
    
    var end_time = OS.get_ticks_msec()
    performance_stats.update_time = end_time - start_time
    performance_stats.active_elements = get_active_element_count()
```

### 2. Distance-Based Culling

Implement animation culling based on player distance:

```gdscript
# In animated_background_manager.gd
func update_animation_visibility(player_position):
    for element_key in elements.keys():
        var element = elements[element_key]
        var distance = player_position.distance_to(element.position)
        
        # Only process animations near the player
        if distance < 800:
            element.visible = true
            if element.has_method("set_property"):
                element.set_property("playing", true)
        else:
            element.visible = false
            if element.has_method("set_property"):
                element.set_property("playing", false)
```

### 3. Batch Processing

Implement batch processing for similar animations:

```gdscript
# In animated_background_manager.gd
func process_elements_by_type(type, delta):
    var type_elements = get_elements_by_type(type)
    
    # Process all elements of this type at once
    for element in type_elements:
        # Common processing code
```

## Command Reference

### Animation Asset Pipeline

```bash
# Generate animation frames from Midjourney output
./tools/process_animation_frames.sh <input_directory> <output_directory> --size 32x32 --style neo_geo

# Import animation assets into Godot
./a_silent_refraction.sh import

# Register new animation element classes
./a_silent_refraction.sh register-classes

# Test animations in a specific district
./a_silent_refraction.sh debug-district <district_name>
```

### Animation Configuration

```bash
# Generate a template animation configuration for a district
./tools/create_animation_config.sh <district_name>

# Validate animation configuration file
./tools/validate_animation_config.sh <config_file_path>

# Update animation paths after moving assets
./tools/update_animation_paths.sh <district_name> <old_path> <new_path>
```

### Animation Testing

```bash
# Run animation tests
./a_silent_refraction.sh test animations

# Run performance tests for animations
./tools/test_animation_performance.sh <district_name>

# Generate animation preview for all elements
./tools/preview_animations.sh <district_name>
```

---

This workflow provides a standardized approach to creating animated background elements for A Silent Refraction, ensuring consistency, quality, and performance throughout the development process.