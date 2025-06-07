#!/bin/bash
# master_sprite_pipeline.sh

# Complete character sprite sheet workflow
# Usage: ./tools/master_sprite_pipeline.sh character_name animation_type video_file [style]
# Style options: neogeo (default), saturn, 32x

CHARACTER_NAME="${1:-character}"
ANIMATION_TYPE="${2:-walk}"
VIDEO_FILE="${3:-runway_output.mp4}"
STYLE="${4:-neogeo}"

# Style-specific settings
case $STYLE in
    "neogeo")
        # Neo Geo - high detail sprites like fighting games
        SPRITE_WIDTH=96
        SPRITE_HEIGHT=144
        COLORS=256  # Full Neo Geo color range
        FPS=12
        POSTERIZE=0  # No posterization - preserve gradients
        ;;
    "saturn")
        # Saturn - smooth gradients and high color
        SPRITE_WIDTH=108
        SPRITE_HEIGHT=162
        COLORS=512  # Saturn's strength was colors
        FPS=15
        POSTERIZE=0  # No posterization
        ;;
    "32x")
        # 32X - balanced detail and performance
        SPRITE_WIDTH=80
        SPRITE_HEIGHT=120
        COLORS=256
        FPS=12
        POSTERIZE=0  # Preserve detail
        ;;
    *)
        echo "Unknown style: $STYLE. Using neogeo defaults."
        STYLE="neogeo"
        SPRITE_WIDTH=64
        SPRITE_HEIGHT=128
        COLORS=256
        FPS=12
        POSTERIZE=32
        ;;
esac

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
    echo -e "${GREEN}Applying 32-bit era styling ($STYLE)...${NC}"
    
    for frame in bg_removed/*.png; do
        filename=$(basename "$frame")
        
        # Skip method-specific files
        if [[ $filename == ai_* ]] || [[ $filename == color_* ]] || [[ $filename == edge_* ]]; then
            continue
        fi
        
        # Platform-specific processing
        case $STYLE in
            "neogeo")
                # Neo Geo style - high quality with preserved detail
                convert "$frame" \
                    -trim +repage \
                    -filter Lanczos \
                    -resize ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
                    -background transparent \
                    -gravity center \
                    -extent ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
                    -modulate 100,105,100 \
                    -unsharp 0x0.75+0.75+0.008 \
                    -colors $COLORS \
                    +dither \
                    "processed/$filename"
                ;;
            "saturn")
                # Saturn style - maximum color fidelity
                convert "$frame" \
                    -trim +repage \
                    -filter Lanczos \
                    -resize ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
                    -background transparent \
                    -gravity center \
                    -extent ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
                    -modulate 100,108,100 \
                    -unsharp 0x1+1+0.01 \
                    -colors $COLORS \
                    -ordered-dither o8x8 \
                    "processed/$filename"
                ;;
            "32x")
                # 32X style - sharp detail with good colors
                convert "$frame" \
                    -trim +repage \
                    -filter Lanczos \
                    -resize ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
                    -background transparent \
                    -gravity center \
                    -extent ${SPRITE_WIDTH}x${SPRITE_HEIGHT} \
                    -brightness-contrast 2x5 \
                    -unsharp 0x0.8+0.8+0.01 \
                    -colors $COLORS \
                    -dither FloydSteinberg \
                    "processed/$filename"
                ;;
        esac
    done
}

# Optional pixelation step - only if really needed
pixelate_sprites() {
    # Skip pixelation for 32-bit era sprites - they had smooth graphics!
    echo -e "${GREEN}Skipping pixelation - 32-bit era sprites were smooth!${NC}"
    return 0
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
    echo "Style: $STYLE"
    echo "Sprite sheet: sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}.png"
    echo "Preview: sprite_sheets/${CHARACTER_NAME}_${ANIMATION_TYPE}_preview.png"
    echo "QA files in: qa/"
}

# Run the pipeline
main