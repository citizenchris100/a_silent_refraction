#!/bin/bash

# This script creates a simple placeholder player sprite using ImageMagick

echo "Creating placeholder player sprite..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it with: sudo apt-get install imagemagick"
    exit 1
fi

# Create a simple player sprite
convert -size 32x64 \
    canvas:transparent \
    -fill "#5588FF" \
    -draw "rectangle 4,4 28,60" \
    -fill white \
    -draw "circle 16,16 16,20" \
    assets/images/characters/player.png

echo "Placeholder player sprite created at assets/images/characters/player.png"
