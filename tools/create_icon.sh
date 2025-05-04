#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it with: sudo apt-get install imagemagick"
    exit 1
fi

# Create a simple icon
convert -size 64x64 \
    canvas:darkblue \
    -fill white \
    -pointsize 24 \
    -gravity center \
    -annotate 0 "ASR" \
    icon.png

echo "Created icon.png"
