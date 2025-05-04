#!/bin/bash

# This script creates a simple placeholder background image using ImageMagick
# Install ImageMagick if not already installed: sudo apt-get install imagemagick

echo "Creating placeholder background for shipping district..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it with: sudo apt-get install imagemagick"
    exit 1
fi

# Create a simple colored background with text
convert -size 800x600 \
    canvas:navy \
    -fill white \
    -pointsize 36 \
    -gravity center \
    -annotate 0 "Shipping District\n(Placeholder)" \
    assets/images/backgrounds/shipping/landing_bay.png

echo "Placeholder background created at assets/images/backgrounds/shipping/landing_bay.png"
