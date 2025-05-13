#!/bin/bash
# Script to process animation frames for A Silent Refraction
# This script converts images to match the game's pixel art style

# Default parameters
SIZE="32x32"
STYLE="neo_geo"
OUTPUT_DIR=""

# Display help
function show_help {
    echo "Usage: $0 <input_directory> [--output <output_directory>] [--size <WxH>] [--style <style>]"
    echo ""
    echo "Process animation frames for A Silent Refraction"
    echo ""
    echo "Options:"
    echo "  <input_directory>              Directory containing animation frames"
    echo "  --output, -o <directory>       Output directory (default: input directory)"
    echo "  --size, -s <WxH>               Target size in pixels (default: 32x32)"
    echo "  --style, -t <style>            Art style to apply (default: neo_geo)"
    echo "                                 Styles: neo_geo, sierra, pixel_perfect, retro_dithered"
    echo "  --help, -h                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 ./raw_frames/ --size 64x64 --style neo_geo"
    echo "  $0 ./input/ --output ./processed/ --style sierra"
    exit 1
}

# Check for ImageMagick
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is required but not installed."
    echo "Please install ImageMagick with: sudo apt-get install imagemagick"
    exit 1
fi

# Parse arguments
INPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            ;;
        --size|-s)
            SIZE="$2"
            shift 2
            ;;
        --style|-t)
            STYLE="$2"
            shift 2
            ;;
        --output|-o)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            if [[ -z "$INPUT_DIR" ]]; then
                INPUT_DIR="$1"
                shift
            else
                echo "Error: Unknown argument $1"
                show_help
            fi
            ;;
    esac
done

# Check input directory
if [[ -z "$INPUT_DIR" ]]; then
    echo "Error: Input directory is required."
    show_help
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist."
    exit 1
fi

# Set output directory to input directory if not specified
if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$INPUT_DIR/processed"
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Get style parameters
function get_style_params {
    case $1 in
        neo_geo)
            # Neo Geo style: Vibrant colors, clean outlines, limited dithering
            echo "-posterize 32 -brightness-contrast 10x20 -modulate 120,130,100"
            ;;
        sierra)
            # Sierra-style: More dithering, VGA-like color palette
            echo "-posterize 16 -dither FloydSteinberg -brightness-contrast 5x15 -modulate 110,120,100"
            ;;
        pixel_perfect)
            # Perfectly clean pixel art, no dithering
            echo "-posterize 24 -brightness-contrast 15x25 -modulate 125,140,100 +dither"
            ;;
        retro_dithered)
            # Heavy dithering like early PC games
            echo "-posterize 8 -dither FloydSteinberg -brightness-contrast 5x25 -modulate 100,110,100"
            ;;
        *)
            echo "Warning: Unknown style '$1', using default (neo_geo)"
            echo "-posterize 32 -brightness-contrast 10x20 -modulate 120,130,100"
            ;;
    esac
}

STYLE_PARAMS=$(get_style_params "$STYLE")

# Process all image files
echo "Processing animation frames from '$INPUT_DIR' to '$OUTPUT_DIR'..."
echo "Using style: $STYLE, size: $SIZE"

# Count images
IMAGE_COUNT=$(find "$INPUT_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | wc -l)
echo "Found $IMAGE_COUNT images to process."

# Process images
CURRENT=0
find "$INPUT_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort | while read -r img; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$img")
    echo "[$CURRENT/$IMAGE_COUNT] Processing '$filename'..."
    
    # Create output filename
    extension="${filename##*.}"
    filename_base="${filename%.*}"
    output_file="$OUTPUT_DIR/${filename_base}.png"
    
    # Process the image
    convert "$img" -resize "$SIZE" $STYLE_PARAMS -filter point -strip "$output_file"
    
    echo "  → Saved to '$output_file'"
done

echo "Processing complete! $IMAGE_COUNT frames processed."
echo "Output directory: $OUTPUT_DIR"