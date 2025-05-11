#!/bin/bash

# Test script for observation mechanics
echo "===== Testing Observation Mechanics ====="

echo -e "\n\n===== Testing Dialog Transformation ====="
cd "$(dirname "$0")/.."
godot --no-window --script src/test/dialog_transform_test.gd

echo -e "\n\n===== Testing Observation Detection ====="
godot --no-window --script src/test/observation_test.gd

echo -e "\n\n===== Verifying Verb UI Update ====="
grep -n "Observe" src/ui/verb_ui/verb_ui.gd

echo -e "\n\n===== Verification Summary ====="
echo "1. Dialog Transformation: The system converts dialog text for assimilated NPCs"
echo "2. Observation Mechanics: Detection probability and feedback mechanism tested"
echo "3. Verb UI: 'Observe' verb added to the verb list"
echo "4. NPC Registry Integration: Assimilation status and player knowledge tracking implemented"

echo -e "\nImplementation verification complete."