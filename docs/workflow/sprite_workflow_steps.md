# Simplified Sprite Creation Guide

## Overview
This guide breaks down the sprite creation process into simple, manageable steps. Don't worry - you'll be creating game sprites in no time!

## What You'll Need
- **Midjourney** account (for creating character art)
- **RunwayML** account (for animating characters)
- **Command line** access (Terminal on Mac/Linux, Command Prompt on Windows)
- **Basic image editor** (optional, for touch-ups)

## Step-by-Step Process

### Step 1: Create Your Character (Midjourney)

1. **Log into Midjourney** on Discord

2. **Use this simple prompt template:**
   ```
   full body character, pixel art style, 32-bit video game sprite, 
   front-facing T-pose, white background, [YOUR CHARACTER DESCRIPTION]
   --ar 1:2 --v 6
   ```

3. **Example for a generic NPC:**
   ```
   full body character, pixel art style, 32-bit video game sprite, 
   front-facing T-pose, white background, office worker in business casual, 
   friendly face, holding clipboard --ar 1:2 --v 6
   ```

4. **Download the best result** - save it as `character_base.png`

### Step 2: Animate Your Character (RunwayML)

1. **Upload your character image** to RunwayML

2. **For a walking animation, use this prompt:**
   ```
   character walking cycle, side view, steady pace, looping animation, 
   white background
   ```

3. **Settings to use:**
   - Duration: 3-4 seconds
   - Style consistency: High
   - Motion amount: Low-Medium

4. **Download the video** as `character_walk.mp4`

### Step 3: Process Your Animation (Command Line)

1. **Navigate to your project folder** in the terminal:
   ```bash
   cd /path/to/your/project
   ```

2. **Run the sprite processing script:**
   ```bash
   ./master_sprite_pipeline.sh my_character walk character_walk.mp4
   ```

3. **Wait for processing** (usually takes 1-2 minutes)

4. **Find your results in these folders:**
   - `sprite_sheets/` - Your final sprite sheet
   - `sprite_sheets/my_character_walk_preview.png` - A preview at 2x size
   - `qa/` - Quality check images

### Step 4: Check Your Work

1. **Open the preview file** (`my_character_walk_preview.png`) to see your animation frames

2. **Look for these qualities:**
   - Character is centered in each frame
   - Background is transparent
   - Animation loops smoothly
   - Colors look good

3. **If something looks wrong:**
   - Check the `qa/bg_removal_comparison.png` to see if background removal worked
   - Look at `qa/analysis.txt` for technical details

### Step 5: Import to Godot

1. **Copy your sprite sheet** to your Godot project's asset folder

2. **The import settings are already created** - Godot will recognize the file

3. **Use an AnimatedSprite node** in Godot to display your character

## Common Animation Types

### Walk Cycle
```
character walking cycle, side view, steady pace, looping animation, 
white background
```

### Idle (Standing) Animation
```
character idle breathing animation, subtle movement, standing in place, 
white background
```

### Talk Animation
```
character talking animation, subtle hand gestures, facing camera, 
white background
```

## Tips for Success

### Character Creation Tips
- Keep descriptions simple and clear
- Always use white or transparent backgrounds
- T-pose (arms out) works best for base images
- Save multiple variations if unsure

### Animation Tips
- Longer videos (4-5 seconds) give more frames to choose from
- Keep movements subtle and natural
- Side view works best for walk cycles
- Front view works best for talking

### Processing Tips
- Always run from the correct directory
- Check the preview before using in your game
- Keep your original files as backups
- Process one animation type at a time

## Quick Troubleshooting

### "Command not found" error
Make the script executable first:
```bash
chmod +x master_sprite_pipeline.sh
```

### Background not fully removed
The script tries multiple methods automatically. Check the `qa/` folder to see which worked best.

### Animation looks choppy
This usually means not enough frames. Try generating a longer video in RunwayML.

### Colors look wrong
The script automatically adjusts colors for a retro game look. This is normal!

## File Organization

After processing, you'll have:
```
your_project/
├── sprite_sheets/
│   ├── my_character_walk.png          (your sprite sheet)
│   ├── my_character_walk_preview.png  (2x preview)
│   └── my_character_walk.png.import   (Godot settings)
├── qa/
│   ├── bg_removal_comparison.png      (quality check)
│   └── analysis.txt                   (technical info)
└── processed/                         (individual frames)
```

## Next Steps

Once you've created your first sprite:

1. **Try different animation types** (idle, run, talk)
2. **Create multiple characters** using the same process
3. **Experiment with character designs** in Midjourney
4. **Build a library** of reusable characters

## Remember

- This process gets easier with practice
- Each character only needs to be created once
- You can reuse animations for similar characters
- Start simple and add complexity as you learn

Good luck with your sprite creation!