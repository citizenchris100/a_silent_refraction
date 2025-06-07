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

4. **Download the video** to the `runway_downloads` folder:
   - Save as something descriptive like `character_walk.mp4`
   - Keep your downloads organized in `runway_downloads/`
   - You can even create subfolders by character: `runway_downloads/dock_worker/`

### Step 3: Process Your Animation (Command Line)

1. **Navigate to your project folder** in the terminal:
   ```bash
   cd /path/to/your/project
   ```

2. **Choose your visual style:**
   
   Before running the script, decide which retro game console style you want:
   
   - **Neo Geo** (default): Creates tall, arcade-fighter style sprites with bold colors and clean edges. Think Street Fighter or King of Fighters - characters look crisp and powerful.
   
   - **Saturn**: Makes sprites with smoother color gradients and softer edges. Characters look more detailed and realistic, like in story-driven RPGs.
   
   - **32X**: Produces compact sprites with sharper contrast. Great for action games where characters need to be clearly visible against busy backgrounds.

3. **Run the sprite processing script:**
   
   For **Neo Geo style** (or just use default):
   ```bash
   ./tools/master_sprite_pipeline.sh my_character walk runway_downloads/character_walk.mp4
   ```
   
   For **Saturn style** (smoother, more colors):
   ```bash
   ./tools/master_sprite_pipeline.sh my_character walk runway_downloads/character_walk.mp4 saturn
   ```
   
   For **32X style** (sharper, more compact):
   ```bash
   ./tools/master_sprite_pipeline.sh my_character walk runway_downloads/character_walk.mp4 32x
   ```
   
   **Tip:** If you organized by character subfolder:
   ```bash
   ./tools/master_sprite_pipeline.sh dock_worker walk runway_downloads/dock_worker/front_walk.mp4
   ```

4. **Wait for processing** (usually takes 1-2 minutes)

5. **Find your results in these folders:**
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

## Visual Style Comparison

### Quick Guide: Which Style Should I Choose?

**Neo Geo Style**
- **Looks like:** Street Fighter, King of Fighters, Metal Slug
- **Best for:** Fighting games, action games, arcade-style games
- **Character appearance:** Tall and imposing, bold colors, clear outlines
- **Technical:** 64x128 pixels, great for characters that need to look powerful

**Saturn Style**
- **Looks like:** Guardian Heroes, Panzer Dragoon Saga, RPGs
- **Best for:** Story games, RPGs, games with detailed characters
- **Character appearance:** More realistic proportions, subtle shading, smoother colors
- **Technical:** 80x120 pixels, allows for more color variety

**32X Style**
- **Looks like:** Virtua Fighter, Knuckles Chaotix, action platformers
- **Best for:** Fast action games, platformers, games with busy backgrounds
- **Character appearance:** Compact and clear, high contrast, easy to see
- **Technical:** 64x96 pixels, perfect for standard game characters

**Not sure?** Start with Neo Geo (the default) - it's the most versatile!

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
chmod +x tools/master_sprite_pipeline.sh
```

### Background not fully removed
The script tries multiple methods automatically. Check the `qa/` folder to see which worked best.

### Animation looks choppy
This usually means not enough frames. Try generating a longer video in RunwayML.

### Colors look wrong
The script automatically adjusts colors for a retro game look. This is normal!

## File Organization

Your project structure:
```
your_project/
├── runway_downloads/              (your Runway videos)
│   ├── character_walk.mp4
│   └── dock_worker/              (optional: organize by character)
│       ├── front_walk.mp4
│       ├── back_walk.mp4
│       └── side_walk.mp4
├── sprite_sheets/                 (created after processing)
│   ├── my_character_walk.png     (your sprite sheet)
│   ├── my_character_walk_preview.png  (2x preview)
│   └── my_character_walk.png.import   (Godot settings)
├── qa/                           (quality check files)
│   ├── bg_removal_comparison.png
│   └── analysis.txt
├── processed/                    (individual frames)
└── tools/
    └── master_sprite_pipeline.sh (the processing script)
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