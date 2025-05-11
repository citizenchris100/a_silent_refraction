#!/bin/bash

# This script fixes the animation frame paths in all animation element scripts
# Find all GD files in the animation elements directory
find src/assets/backgrounds/animated_elements -name "*.gd" | while read -r file; do
    echo "Fixing paths in $file"
    
    # Replace "res://assets/backgrounds" with "res://src/assets/backgrounds"
    sed -i 's|res://assets/backgrounds|res://src/assets/backgrounds|g' "$file"
    
    # Print the result
    echo "Updated file:"
    grep -n "load(" "$file"
    echo ""
done

echo "All animation element scripts updated."