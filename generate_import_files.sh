#!/bin/bash

# This script generates .import files for animation frames based on 
# an existing valid import file

ELEMENT_DIR="src/assets/backgrounds/animated_elements/computer_terminal_shipping_main"
TEMPLATE_IMPORT="src/assets/backgrounds/shipping_district_bg.png.import"

# Check if template import file exists
if [ ! -f "$TEMPLATE_IMPORT" ]; then
    echo "Template import file not found: $TEMPLATE_IMPORT"
    exit 1
fi

# Create import files for each frame
echo "Generating import files for animation frames..."
for i in {0..4}; do
    FRAME="$ELEMENT_DIR/frame_$i.png"
    IMPORT_FILE="$FRAME.import"
    
    # Check if frame exists
    if [ ! -f "$FRAME" ]; then
        echo "Frame not found: $FRAME"
        continue
    fi
    
    # Create an MD5 hash of the frame path for the stex filename
    FRAME_PATH="res://src/assets/backgrounds/animated_elements/computer_terminal_shipping_main/frame_$i.png"
    HASH=$(echo -n "$FRAME_PATH" | md5sum | cut -d' ' -f1)
    
    # Copy template and modify paths
    cp "$TEMPLATE_IMPORT" "$IMPORT_FILE"
    
    # Update the paths in the import file
    sed -i "s|path=\"res://\.import/shipping_district_bg\.png-e86c72cb96950cf53d47e4e5a70d499e\.stex\"|path=\"res://\.import/frame_$i\.png-$HASH\.stex\"|g" "$IMPORT_FILE"
    sed -i "s|source_file=\"res://src/assets/backgrounds/shipping_district_bg\.png\"|source_file=\"$FRAME_PATH\"|g" "$IMPORT_FILE"
    sed -i "s|dest_files=\[ \"res://\.import/shipping_district_bg\.png-e86c72cb96950cf53d47e4e5a70d499e\.stex\" \]|dest_files=\[ \"res://\.import/frame_$i\.png-$HASH\.stex\" \]|g" "$IMPORT_FILE"
    
    echo "  Created import file for frame_$i.png"
done

echo "Import files generated successfully!"