#!/bin/bash
# This script opens the Godot editor to register new classes defined with class_name
# It then waits for the editor to be closed before continuing

GODOT_PATH=$(which godot)

# Display message
echo "Opening Godot Editor to register new classes..."
echo "Please wait for the editor to scan scripts, then save and close the editor."

# Open Godot editor in the background
$GODOT_PATH -e project.godot &

# Get the process ID of the Godot editor
GODOT_PID=$!

# Display instructions
echo "----------------------------------------"
echo "INSTRUCTIONS:"
echo "1. Wait for the editor to scan all scripts (bottom-right progress bar)"
echo "2. Click Project > Save to update project.godot file"
echo "3. Close the editor to continue"
echo "----------------------------------------"

# Wait for the Godot editor to be closed
wait $GODOT_PID

echo "Editor closed. New classes should now be registered."
echo "Continuing with the build process..."