#!/bin/bash

echo "Running NPC System Integration Test..."

# Check if Godot executable is available
if ! command -v godot &> /dev/null; then
    echo "Error: Godot executable not found in PATH"
    echo "Please make sure Godot is installed and available in your PATH"
    exit 1
fi

# Run the test scene
godot --path . src/test/npc_system_test.tscn
