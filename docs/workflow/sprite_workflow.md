# Sprite Creation Workflow

This document outlines the comprehensive process for creating 32-bit era game sprites for A Silent Refraction, using Midjourney character images, RunwayML animation, and advanced processing with ImageMagick.

## Table of Contents

1. [Midjourney Character Creation](#midjourney-character-creation)
2. [RunwayML Animation Generation](#runwayml-animation-generation)
3. [Master Processing Pipeline](#master-processing-pipeline)
4. [32-bit Era Styling](#32-bit-era-styling)
5. [Batch Processing](#batch-processing)
6. [Utility Scripts](#utility-scripts)
7. [Directory Structure](#directory-structure)
8. [Troubleshooting](#troubleshooting)
9. [Quick Start Guide](#quick-start-guide)

## Midjourney Character Creation

### Optimal Prompts for 32-bit Era Sprites

#### Base Template
```
full body character, pixel art style, 32-bit video game sprite, 
clean lines, limited color palette, front-facing neutral T-pose, 
transparent background, no shadows, centered, high contrast, 
arcade game character design, neo geo style
```

#### Character-Specific Prompts

**Player Character (Alex - The Courier)**
```
full body character, pixel art style, 32-bit video game sprite, 
clean lines, limited color palette, front-facing neutral T-pose, 
transparent background, space courier in utility jumpsuit, confident pose, 
brown hair, practical outfit, tool belt, communication device, 
style of metal slug character --ar 1:2 --v 6
```

**Concierge NPC**
```
full body character, pixel art style, 32-bit video game sprite, 
clean lines, limited color palette, front-facing neutral T-pose, 
transparent background, hotel concierge in neat uniform, professional appearance, 
middle-aged man, friendly expression, holding clipboard, 
bowtie, formal vest, style of king of fighters --ar 1:2 --v 6
```

**Security Officer**
```
full body character, pixel art style, 32-bit video game sprite, 
clean lines, limited color palette, front-facing neutral T-pose, 
transparent background, space station security guard, tactical uniform, 
stern expression, utility belt, badge visible, professional stance, 
armored vest, style of final fight character --ar 1:2 --v 6
```

**Bank Teller**
```
full body character, pixel art style, 32-bit video game sprite, 
clean lines, limited color palette, front-facing neutral T-pose, 
transparent background, professional bank teller, business attire, 
glasses, holding documents, conservative appearance, 
name tag, style of street fighter character --ar 1:2 --v 6
```

### Midjourney Tips

* Use `--ar 1:2` for tall sprites
* Add transparent background or white background
* Include 32-bit style or specific game references
* Reference classic arcade games for style consistency

## RunwayML Animation Generation

### Optimal Animation Prompts

#### Walk Cycle
```
character walking cycle, side view, steady pace, looping animation, 
arcade game style movement, clear distinct steps, arms swinging naturally, 
minimal vertical bobbing, consistent speed, white background
```

#### Run Cycle
```
character running fast, side profile, dynamic sprint animation, 
leaning forward, exaggerated arm movement, arcade game run cycle, 
clear footsteps, white studio background, looping motion
```

#### Idle Animation
```
character idle breathing animation, subtle movement, standing in place, 
gentle sway, blinking, small breathing motion, video game idle pose, 
minimal movement, clean white background
```

#### Talk Animation
```
character talking animation, mouth moving, hand gestures, 
conversational body language, facing camera, expressive movement, 
simple background, video game dialog animation
```

#### Interact Animation
```
character reaching forward animation, pressing button gesture, 
using object motion, extending arm, arcade game interaction, 
simple movement, white background
```

### RunwayML Settings

* Duration: 3-4 seconds
* Style consistency: High
* Motion amount: Low-Medium
* Output format: MP4

## Master Processing Pipeline

### Complete Processing Pipeline

```bash
#!/bin/bash
# master_sprite_pipeline.sh

# Complete character sprite sheet workflow
# Usage: ./master_sprite_pipeline.sh character_name animation_type video_file

CHARACTER_NAME="${1:-character}"
ANIMATION_TYPE="${2:-walk}"
VIDEO_FILE="${3:-runway_output.mp4}"

# Configuration
SPRITE_WIDTH=64
SPRITE_HEIGHT=96
COLORS=256
FPS=12

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create directory structure
create_directories() {
    echo -e "${GREEN}Creating directory structure...${NC}"
    mkdir -p {raw_frames,bg_removed,processed,sprite_sheets,qa}
}

# Extract frames from RunwayML video
extract_frames() {
    echo -e "${GREEN}Extracting frames from video...${NC}"
    ffmpeg -i "$VIDEO_FILE" \
        -vf fps=$FPS \
        raw_frames/frame_%04d.png
}

# Background removal with multiple methods
remove_backgrounds() {
    echo -e "${GREEN}Removing backgrounds...${NC}"
    
    for frame in raw_frames/*.png; do
        filename=$(basename "$frame")
        
        # Method 1: AI-powered removal (if rembg is installed)
        if command -v rembg &> /dev/null; then
            echo "Using AI background removal for $filename"
            rembg i -a -ae 15 "$frame" "bg_removed/ai_$filename"
        fi
        
        # Method 2: ImageMagick color-based removal
        echo "Using color-based removal for $filename"
        convert "$frame" \
            -fuzz 15% \
            -transparent white \
            -fuzz 15% \
            -transparent "#F8F8F8" \
            -fuzz 10% \
            -transparent "#F0F0F0" \
            "bg_removed/color_$filename"
        
        # Method 3: Smart edge detection
        echo "Using edge detection for $filename"
        convert "$frame" \
            -alpha extract \
            -morphology EdgeOut Diamond:2 \
            -threshold 50% \
            -morphology Close Diamond:1 \
            -negate \
            mask_temp.png
        
        convert "$frame" mask_temp.png \
            -compose CopyOpacity \
            -composite \
            "bg_removed/edge_$filename"
        
        # Choose best result (AI > color > edge)
        if [ -f "bg_removed/ai_$filename" ]; then
            cp "bg_removed/ai_$filename" "bg_removed/$filename"
        elif [ -f "bg_removed/color_$filename" ]; then
            cp "bg_removed/color_$filename" "bg_removed/$filename"
        else
            cp "bg_removed/edge_$filename" "bg_removed/$filename"
        fi
    done
    
    rm -f mask_temp.png
}

# Apply 32-bit era styling
apply_32bit_style() {
    echo -e "${GREEN}Applying 32-bit era styling...${NC}"
    
    for frame in bg_removed/*.png; do
        filename=$(basename "$frame")
        
        # Skip method-specific files
        if [[ $filename == ai_* ]] || [[ $filename == color_* ]] || [[ $filename == edge_* ]]; then
            continue
        fi
        
        # 32-bit processing
        convert "$frame" \
            -resize ${SPRITE_WIDTH}x${SPRITE_HEIGHT}! \
            -filter Lanczos \
            -background transparent \
            -gravity center \
            -extent ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
            \( +clone -alpha extract \
                -morphology EdgeOut Diamond:1.5 \
                -threshold 50% \
                -negate -transparent white \
                -fill black -opaque white \) \
            -compose DstOver -composite \
            -modulate 105,110,100 \
            -unsharp 0x1+0.5+0 \
            -colors $COLORS \
            -dither FloydSteinberg \
            +dither \
            "processed/$filename"
    done
}

# Pixelate sprites for authentic look
pixelate_sprites() {
    echo -e "${GREEN}Applying pixelation effects...${NC}"
    
    for frame in processed/*.png; do
        filename=$(basename "$frame")
        
        # Create pixelated version with controlled downsampling and upsampling
        convert "$frame" \
            -filter point \
            -resize 75% \
            -filter point \
            -resize 133.33% \
            -background transparent \
            -gravity center \
            -extent ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
            "processed/pixel_$filename"
            
        # Apply proper 32-bit style pixel art with limited palette
        convert "processed/pixel_$filename" \
            -filter point \
            -quantize RGB \
            -colors $COLORS \
            -dither None \
            -posterize 6 \
            -fill transparent \
            -opaque "rgb(0,0,0)" \
            -morphology Dilate Diamond:1 \
            -density 72 \
            -units PixelsPerInch \
            "processed/$filename"
            
        # Clean up temp file
        rm "processed/pixel_$filename"
    done
}

# Create sprite sheet
create_sprite_sheet() {
    echo -e "${GREEN}Creating sprite sheet...${NC}"
    
    # Count frames
    frame_count=$(ls processed/frame_*.png 2>/dev/null | wc -l)
    
    if [ $frame_count -eq 0 ]; then
        echo -e "${YELLOW}No frames found!${NC}"
        return 1
    fi
    
    # Calculate grid
    cols=8
    rows=$(( (frame_count + cols - 1) / cols ))
    
    # Create sprite sheet
    montage processed/frame_*.png \
        -tile ${cols}x${rows} \
        -geometry +0+0 \
        -background transparent \
        "sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}.png"
    
    # Create preview at 2x scale
    convert "sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}.png" \
        -filter point \
        -resize 200% \
        "sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}_preview.png"
        
    # Optimize for pixel art
    optimize_pixel_art
}

# Optimize pixel art
optimize_pixel_art() {
    local sprite_sheet="sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}.png"
    
    echo -e "${GREEN}Optimizing pixel art aesthetics...${NC}"
    
    # Force image to use point sampling for proper pixel art rendering
    convert "$sprite_sheet" \
        -filter point \
        -define png:format=png8 \
        -define png:compression-filter=2 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        -depth 8 \
        -background transparent \
        -strip \
        "$sprite_sheet.temp.png"
        
    # Apply pixel art specific cleanup
    convert "$sprite_sheet.temp.png" \
        -colorspace RGB \
        +antialias \
        -filter point \
        -resize 100% \
        "$sprite_sheet"
        
    # Remove temp file
    rm "$sprite_sheet.temp.png"
}

# Quality assurance check
quality_check() {
    echo -e "${GREEN}Running quality check...${NC}"
    
    # Create QA comparison sheet
    montage bg_removed/frame_00*.png \
        -tile 4x1 \
        -geometry 128x128+5+5 \
        -background checkerboard \
        -label '%f' \
        qa/bg_removal_comparison.png
    
    # Create processed preview
    montage processed/frame_00*.png \
        -tile 4x2 \
        -geometry +2+2 \
        -background gray50 \
        qa/processed_preview.png
    
    # Frame analysis
    echo "Frame Analysis:" > qa/analysis.txt
    for frame in processed/*.png; do
        dimensions=$(identify -format "%wx%h" "$frame")
        colors=$(identify -format "%k" "$frame")
        echo "$(basename $frame): $dimensions, $colors colors" >> qa/analysis.txt
    done
}

# Generate Godot import files
generate_godot_imports() {
    echo -e "${GREEN}Generating Godot import files...${NC}"
    
    cat > "sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}.png.import" << EOF
[remap]
importer="texture"
type="StreamTexture"
path="res://.import/${CHARACTER_NAME}_${ANIMATION_TYPE}.png-$(uuidgen).stex"

[params]
compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=false
svg/scale=1.0
EOF
}

# Main execution
main() {
    echo -e "${GREEN}Starting sprite sheet pipeline for $CHARACTER_NAME - $ANIMATION_TYPE${NC}"
    
    create_directories
    extract_frames
    remove_backgrounds
    apply_32bit_style
    pixelate_sprites
    create_sprite_sheet
    quality_check
    generate_godot_imports
    
    echo -e "${GREEN}Pipeline complete!${NC}"
    echo "Sprite sheet: sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}.png"
    echo "Preview: sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}_preview.png"
    echo "QA files in: qa/"
}

# Run the pipeline
main
```

## 32-bit Era Styling

### 32-bit Era Sprite Characteristics

The Neo Geo/Saturn era sprites had:
- Higher color counts (256-512 colors per sprite)
- Larger sprite sizes (64x96 to 128x256 pixels)
- Smooth gradients and shading
- Clean outlines
- Minimal dithering
- Professional pixel art with anti-aliasing

### Platform-Specific Variations

#### Neo Geo Style Pipeline

```bash
#!/bin/bash
# neo_geo_style_sprites.sh

# Neo Geo had specific constraints
NEO_GEO_WIDTH=64
NEO_GEO_HEIGHT=128   # Often used tall sprites
NEO_GEO_COLORS=256   # Per sprite limit

process_neo_geo_style() {
    local input=$1
    local output=$2
    
    # Neo Geo style processing
    convert "$input" \
        -resize ${NEO_GEO_WIDTH}x${NEO_GEO_HEIGHT}! \
        -background transparent \
        -gravity center \
        -extent ${NEO_GEO_WIDTH}x${NEO_GEO_HEIGHT} \
        \( +clone -alpha extract \
            -morphology EdgeOut Diamond:1 \
            -negate -transparent white \
            -fill black -opaque white \) \
        -compose DstOver -composite \
        -posterize 32 \
        -colors $NEO_GEO_COLORS \
        "$output"
}
```

#### Saturn/32X Style Pipeline

```bash
#!/bin/bash
# saturn_style_sprites.sh

# Saturn had different capabilities
SATURN_WIDTH=80
SATURN_HEIGHT=120
SATURN_COLORS=512

process_saturn_style() {
    local input=$1
    local output=$2
    
    # Saturn allowed more colors and smoother gradients
    convert "$input" \
        -resize ${SATURN_WIDTH}x${SATURN_HEIGHT}! \
        -modulate 110,120,100 \
        -unsharp 0x1+0.5+0 \
        -colors $SATURN_COLORS \
        -ordered-dither o4x4,16 \
        "$output"
}
```

### Complete 32-bit Era Pipeline with Platform Selection

```bash
#!/bin/bash
# complete_32bit_era_pipeline.sh

VIDEO_FILE="$1"
CHARACTER_NAME="${2:-character}"
STYLE="${3:-neogeo}" # neogeo, saturn, or 32x

# Style-specific settings
case $STYLE in
    "neogeo")
        WIDTH=64
        HEIGHT=128
        COLORS=256
        FPS=12
        ;;
    "saturn")
        WIDTH=80
        HEIGHT=120
        COLORS=512
        FPS=15
        ;;
    "32x")
        WIDTH=64
        HEIGHT=96
        COLORS=256
        FPS=12
        ;;
esac

# Create directories
mkdir -p raw_frames processed_frames sprite_sheets

# Extract frames
echo "Extracting frames at ${FPS}fps..."
ffmpeg -i "$VIDEO_FILE" \
    -vf fps=$FPS \
    raw_frames/frame_%04d.png

# Process frames with 32-bit era style
echo "Processing with $STYLE style..."
for frame in raw_frames/*.png; do
    filename=$(basename "$frame")
    
    # Core processing
    convert "$frame" \
        -resize ${WIDTH}x${HEIGHT}! \
        -background transparent \
        -gravity center \
        \( +clone -alpha extract \
            -morphology EdgeOut Diamond:1.5 \
            -negate -transparent white \
            -fill '#000000' -opaque white \) \
        -compose DstOver -composite \
        -modulate 105,110,100 \
        -unsharp 0x1+0.5+0 \
        -colors $COLORS \
        -dither FloydSteinberg \
        "processed_frames/$filename"
done

# Create sprite sheet
frames_count=$(ls processed_frames/*.png | wc -l)
cols=8
rows=$(( (frames_count + cols - 1) / cols ))

montage processed_frames/*.png \
    -tile ${cols}x${rows} \
    -geometry +2+2 \
    -background transparent \
    "sprite_sheets/${CHARACTER_NAME}_${STYLE}_sheet.png"

# Create comparison sheet
convert "sprite_sheets/${CHARACTER_NAME}_${STYLE}_sheet.png" \
    -filter point \
    -resize 200% \
    "sprite_sheets/${CHARACTER_NAME}_${STYLE}_preview.png"

echo "Created sprite sheet: sprite_sheets/${CHARACTER_NAME}_${STYLE}_sheet.png"
echo "Preview at 2x scale: sprite_sheets/${CHARACTER_NAME}_${STYLE}_preview.png"
```

## Batch Processing

### Process Multiple Characters

```bash
#!/bin/bash
# batch_process_characters.sh

# Process all characters and animations

CHARACTERS=("alex" "concierge" "security_officer" "bank_teller")
ANIMATIONS=("walk" "run" "idle" "talk" "interact")

for character in "${CHARACTERS[@]}"; do
    for animation in "${ANIMATIONS[@]}"; do
        video_file="runway_${character}_${animation}.mp4"
        
        if [ -f "$video_file" ]; then
            echo "Processing $character - $animation"
            ./master_sprite_pipeline.sh "$character" "$animation" "$video_file"
        else
            echo "Skipping $character - $animation (video not found)"
        fi
    done
done

# Create master sprite sheet overview
montage sprite_sheets/*_preview.png \
    -tile 4x5 \
    -geometry 256x192+10+10 \
    -background gray25 \
    -label '%f' \
    all_sprites_overview.png

echo "All characters processed!"
echo "View overview: all_sprites_overview.png"
```

### Style Comparison Script

```bash
#!/bin/bash
# compare_era_styles.sh

INPUT_FRAME="test_frame.png"

# Create samples of different era styles
for style in "scumm" "neogeo" "saturn" "playstation"; do
    case $style in
        "scumm")
            size="32x48"
            colors="32"
            ;;
        "neogeo")
            size="64x128"
            colors="256"
            ;;
        "saturn")
            size="80x120"
            colors="512"
            ;;
        "playstation")
            size="64x96"
            colors="256"
            ;;
    esac
    
    convert "$INPUT_FRAME" \
        -resize $size! \
        -colors $colors \
        -label "$style ${size} ${colors}c" \
        "compare_${style}.png"
done

# Create comparison sheet
montage compare_*.png \
    -tile 4x1 \
    -geometry +10+10 \
    -background white \
    -pointsize 20 \
    era_comparison.png

echo "View era_comparison.png to see the differences"
```

## Utility Scripts

### Common Fixes and Adjustments

```bash
#!/bin/bash
# sprite_utilities.sh

# Fix alignment issues
fix_sprite_alignment() {
    local sprite_sheet=$1
    
    convert "$sprite_sheet" \
        -crop 64x96 \
        +repage \
        -background transparent \
        -gravity center \
        -extent 64x96 \
        +append \
        "${sprite_sheet%.png}_aligned.png"
}

# Adjust contrast for better definition
enhance_sprite_contrast() {
    local sprite_sheet=$1
    
    convert "$sprite_sheet" \
        -level 10%,90% \
        -contrast \
        -modulate 100,120,100 \
        "${sprite_sheet%.png}_enhanced.png"
}

# Remove stray pixels
clean_sprite_edges() {
    local sprite_sheet=$1
    
    convert "$sprite_sheet" \
        -morphology Open Diamond:1 \
        -morphology Close Diamond:1 \
        "${sprite_sheet%.png}_cleaned.png"
}

# Verify sprite sheet dimensions
verify_sprite_sheet() {
    local sprite_sheet=$1
    
    identify -format "Dimensions: %wx%h\nFrames: %n\n" "$sprite_sheet"
}
```

### Sprite Scaling Effects

```bash
#!/bin/bash
# create_scaling_effects.sh

# Add sprite scaling effects (common in fighting games)
create_scaling_effect() {
    local input=$1
    local output_prefix=$2
    local scale_frames=5
    local width=64
    local height=96
    
    for ((i=1; i<=$scale_frames; i++)); do
        scale_factor=$(echo "scale=2; 0.6 + ($i * 0.1)" | bc)
        
        convert "$input" \
            -resize ${scale_factor}x${scale_factor}% \
            -gravity center \
            -background transparent \
            -extent ${width}x${height} \
            "${output_prefix}_scale_${i}.png"
    done
}

# Usage
create_scaling_effect "character_base.png" "character"
```

## Directory Structure

```
sprite_project/
├── raw_frames/          # Extracted video frames
├── bg_removed/          # Background removed versions
│   ├── ai_*            # AI method results
│   ├── color_*         # Color-based results
│   └── edge_*          # Edge detection results
├── processed/           # 32-bit styled frames
├── sprite_sheets/       # Final sprite sheets
│   ├── *.png           # Sprite sheets
│   ├── *_preview.png   # 2x previews
│   └── *.png.import    # Godot import files
├── qa/                  # Quality check files
│   ├── bg_removal_comparison.png
│   ├── processed_preview.png
│   └── analysis.txt
└── scripts/             # Pipeline scripts
    ├── master_sprite_pipeline.sh
    ├── batch_process_characters.sh
    ├── sprite_utilities.sh
    ├── neo_geo_style_sprites.sh
    ├── saturn_style_sprites.sh
    └── compare_era_styles.sh
```

## Troubleshooting

### Common Issues and Solutions

#### Background Not Fully Removed

```bash
# Increase fuzz tolerance
convert input.png -fuzz 25% -transparent white output.png

# Use multiple passes
convert input.png \
    -fuzz 20% -transparent white \
    -fuzz 20% -transparent "#F0F0F0" \
    -fuzz 15% -transparent "#E0E0E0" \
    output.png
```

#### Frames Not Aligned

```bash
# Auto-align to center
for frame in *.png; do
    convert "$frame" \
        -trim +repage \
        -gravity center \
        -extent 64x96 \
        -background transparent \
        "aligned_$frame"
done
```

#### Colors Too Dull

```bash
# Enhance vibrancy
convert sprite_sheet.png \
    -modulate 100,120,100 \
    -contrast \
    enhanced_sprite_sheet.png
```

#### Sprite Sheet Grid Issues

```bash
# Verify frame count and dimensions
identify sprite_sheet.png
```

## Quick Start Guide

### Step 1: Create Character in Midjourney

* Use the provided prompts
* Download the generated character image
* Save as character_base.png

### Step 2: Animate in RunwayML

* Upload character image
* Use animation prompts
* Generate 3-4 second video
* Download as runway_output.mp4

### Step 3: Process with Pipeline

```bash
# Make scripts executable
chmod +x master_sprite_pipeline.sh

# Run pipeline with default style
./master_sprite_pipeline.sh alex walk runway_alex_walk.mp4

# Or with specific platform style
./complete_32bit_era_pipeline.sh runway_alex_walk.mp4 alex neogeo
```

### Step 4: Review Results

* Check sprite_sheets/alex_walk_preview.png
* Review qa/analysis.txt for frame consistency
* View qa/bg_removal_comparison.png for quality

### Step 5: Import to Godot

* Copy sprite sheets to your Godot project
* Import settings are auto-generated
* Use AnimatedSprite node in Godot

## Best Practices

* Always use consistent backgrounds in RunwayML (preferably white)
* Generate longer videos (4-5 seconds) and select best frames
* Review QA files before using sprite sheets
* Keep original files for future reprocessing
* Test animations in Godot early and often
* Consider platform-specific styling for consistent character aesthetics
* Ensure sprites for the same character use consistent dimensions and styling

## Additional Resources

* [ImageMagick Documentation](https://imagemagick.org/script/command-line-processing.php)
* [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
* [Godot AnimatedSprite Guide](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)