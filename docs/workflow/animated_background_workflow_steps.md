# Simplified Animated Background Guide

## Overview
This guide shows you how to create animated background elements (like blinking lights, moving fans, or flickering screens) for your game. Think of these as the little details that make your game world feel alive!

## What You'll Need
- **Midjourney** account (for creating the base images)
- **RunwayML** account (for animating them)
- **Command line** access
- **A text editor** (for editing configuration files)

## Quick Examples of Animated Backgrounds
- Blinking computer lights
- Rotating security cameras
- Spinning ventilation fans
- Flickering neon signs
- Steam vents puffing
- Sliding doors opening/closing

## Step-by-Step Process

### Step 1: Plan Your Animation

1. **Decide what you want to animate**
   - What is it? (e.g., "security camera")
   - Where will it go? (e.g., "shipping district entrance")
   - What will it do? (e.g., "pan left and right")

2. **Think about states** (if needed)
   - Normal state: Camera panning slowly
   - Alert state: Camera panning quickly
   - Disabled state: Camera drooping down

### Step 2: Create Your Base Image (Midjourney)

1. **Use this simple template:**
   ```
   [your element] in retro pixel art style, 16-bit graphics, 
   [view angle], limited color palette, [size] sprite --ar 1:1
   ```

2. **Examples:**
   
   **Security Camera:**
   ```
   security camera, retro pixel art style, 16-bit graphics, side view,
   industrial space station aesthetic, 32x32 sprite --ar 1:1
   ```
   
   **Blinking Light:**
   ```
   emergency warning light, retro pixel art style, 16-bit graphics, 
   front view, red beacon, 32x32 sprite --ar 1:1
   ```
   
   **Ventilation Fan:**
   ```
   industrial ventilation fan, retro pixel art style, 16-bit graphics, 
   front view, metal grille with spinning blades, 64x64 sprite --ar 1:1
   ```

3. **Download your favorite result**

### Step 3: Create Animation Frames (RunwayML)

1. **Upload your base image** to RunwayML

2. **Use these animation prompts:**
   
   **For rotating/panning:**
   ```
   Create smooth rotation animation, consistent pixel art style, 
   maintain exact sprite dimensions, mechanical movement
   ```
   
   **For blinking/flashing:**
   ```
   Create flashing light sequence, consistent pixel art style,
   dramatic on/off illumination, maintain sprite dimensions
   ```
   
   **For spinning (fans, etc):**
   ```
   Generate seamless looping animation of fan spinning, 
   consistent pixel art style, clean mechanical rotation
   ```

3. **Settings:**
   - Duration: 3-4 seconds
   - Frame rate: 12fps
   - Keep style consistency HIGH

4. **Download the video**

### Step 4: Process Your Animation

1. **Extract frames from the video:**
   ```bash
   # Navigate to your project
   cd /path/to/your/project
   
   # Extract frames
   ffmpeg -i your_animation.mp4 -vf fps=12 frames/frame_%04d.png
   ```

2. **Apply the retro game style:**
   ```bash
   # Process all frames for 32-bit style
   ./tools/optimize_32bit_animated_bg.sh frames/ processed_frames/ neogeo
   ```

3. **Your processed frames** will be in `processed_frames/`

### Step 5: Set Up in Your Game

1. **Organize your files:**
   ```
   src/assets/backgrounds/animated_elements/
   └── shipping/
       └── security_camera/
           ├── frame_0001.png
           ├── frame_0002.png
           ├── frame_0003.png
           └── frame_0004.png
   ```

2. **Create a configuration file** (`shipping_animations.json`):
   ```json
   {
     "district": "shipping",
     "animated_elements": [
       {
         "name": "security_camera_entrance",
         "type": "sprite_sequence",
         "position": {"x": 450, "y": 120},
         "frames_path": "res://src/assets/backgrounds/animated_elements/shipping/security_camera",
         "frame_count": 4,
         "animation_speed": 0.5,
         "loop": true,
         "autoplay": true
       }
     ]
   }
   ```

3. **Import to Godot:**
   ```bash
   ./a_silent_refraction.sh import
   ```

## Simple Animation Recipes

### Blinking Light
```json
{
  "name": "warning_light",
  "type": "sprite_sequence",
  "position": {"x": 200, "y": 100},
  "frames_path": "res://path/to/light_frames",
  "frame_count": 2,
  "animation_speed": 2.0,
  "loop": true
}
```

### Rotating Fan
```json
{
  "name": "ceiling_fan",
  "type": "sprite_sequence",
  "position": {"x": 300, "y": 50},
  "frames_path": "res://path/to/fan_frames",
  "frame_count": 8,
  "animation_speed": 1.0,
  "loop": true
}
```

### Opening Door
```json
{
  "name": "sliding_door",
  "type": "sprite_sequence",
  "position": {"x": 500, "y": 200},
  "frames_path": "res://path/to/door_frames",
  "frame_count": 6,
  "animation_speed": 0.5,
  "loop": false,
  "autoplay": false
}
```

## Tips for Success

### Creating Good Base Images
- Keep them simple and clear
- Use consistent lighting
- Make sure moving parts are visible
- Use the same perspective as your game

### Animation Tips
- Start with 4-8 frames (plenty for most animations)
- Looping animations need smooth transitions
- Test with different speeds to find what looks best
- Less is more - subtle animations often work better

### Common Animation Types
1. **Cyclic** (loops forever): fans, lights, steam
2. **Back-and-forth**: security cameras, pendulums
3. **One-shot**: doors opening, explosions
4. **State-based**: different speeds or patterns based on game events

## Quick Troubleshooting

### Animation looks choppy
- Try more frames (8-12 instead of 4)
- Slow down the animation speed
- Make sure frames loop smoothly

### Colors look wrong after processing
- This is normal! The script converts to retro game colors
- Try different style options: `neogeo`, `saturn`, or `32x`

### Animation not showing in game
- Check file paths in your JSON config
- Make sure frame count matches actual files
- Verify the import worked: `./a_silent_refraction.sh import`

### Animation playing too fast/slow
- Adjust `animation_speed` in the JSON (higher = faster)
- Normal range is 0.5 to 2.0

## Adding Particle Effects (Bonus!)

For things like dust or steam, you can use Godot's built-in particles:

```json
{
  "type": "particle_effect",
  "id": "room_dust",
  "position": {"x": 400, "y": 300},
  "properties": {
    "particle_type": "dust",
    "amount": 15,
    "lifetime": 8.0,
    "area_width": 300,
    "area_height": 100
  }
}
```

## Testing Your Animations

1. **Test in the editor:**
   ```bash
   ./a_silent_refraction.sh debug-district shipping
   ```

2. **Check that:**
   - Animation plays smoothly
   - Position is correct
   - Speed feels right
   - It loops properly (if it should)

## Next Steps

Once you've created your first animated background:

1. **Try different types** (lights, fans, screens)
2. **Experiment with states** (normal vs alert modes)
3. **Combine multiple animations** in one scene
4. **Add particle effects** for atmosphere

## Remember

- Start simple - even a blinking light adds life to a scene
- You can always add more frames later
- Test early and often
- Small details make a big difference!

Good luck bringing your game world to life!