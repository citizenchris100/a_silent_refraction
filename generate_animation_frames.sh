#!/bin/bash

# This script generates animation frames for a specific element
# by creating smaller versions of the shipping_district_bg.png
# that Godot can properly import and use

OUTPUT_DIR="src/assets/backgrounds/animated_elements/computer_terminal_shipping_main"
SOURCE_IMG="src/assets/backgrounds/shipping_district_bg.png"

# Check if source image exists
if [ ! -f "$SOURCE_IMG" ]; then
    echo "Source image not found: $SOURCE_IMG"
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Create 5 different colored versions of the image
echo "Generating animation frames for computer_terminal_shipping_main..."
for i in {0..4}; do
    # Create a small version of the image with different tints
    case $i in
        0) convert "$SOURCE_IMG" -resize 64x64 "$OUTPUT_DIR/frame_$i.png" ;;
        1) convert "$SOURCE_IMG" -resize 64x64 -fill blue -colorize 20% "$OUTPUT_DIR/frame_$i.png" ;;
        2) convert "$SOURCE_IMG" -resize 64x64 -fill green -colorize 20% "$OUTPUT_DIR/frame_$i.png" ;;
        3) convert "$SOURCE_IMG" -resize 64x64 -fill red -colorize 20% "$OUTPUT_DIR/frame_$i.png" ;;
        4) convert "$SOURCE_IMG" -resize 64x64 -fill yellow -colorize 20% "$OUTPUT_DIR/frame_$i.png" ;;
    esac
    echo "  Created frame_$i.png"
done

echo "Animation frames generated successfully!"