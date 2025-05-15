#!/bin/bash
# create_animation_config.sh
# Generates template JSON configurations for animated backgrounds in districts

# Constants
TEMPLATE_DIR="$(dirname "$0")/../templates"
CONFIG_FILENAME="animated_elements_config.json"

# Check if district name was provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <district_name>"
    echo "Example: $0 shipping"
    exit 1
fi

DISTRICT_NAME="$1"
DISTRICT_DIR="$(dirname "$0")/../src/districts/${DISTRICT_NAME}"
CONFIG_PATH="${DISTRICT_DIR}/${CONFIG_FILENAME}"

# Check if district directory exists
if [ ! -d "$DISTRICT_DIR" ]; then
    echo "ERROR: District directory does not exist: $DISTRICT_DIR"
    echo "Create the district first using './a_silent_refraction.sh new-district $DISTRICT_NAME'"
    exit 1
fi

# Check if config file already exists
if [ -f "$CONFIG_PATH" ]; then
    echo "Animation config file already exists: $CONFIG_PATH"
    read -p "Overwrite? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "Operation cancelled"
        exit 0
    fi
fi

# Create template JSON configuration
cat > "$CONFIG_PATH" << EOL
{
    "district": "${DISTRICT_NAME}",
    "background": "res://src/assets/backgrounds/${DISTRICT_NAME}/${DISTRICT_NAME}_district_bg.png",
    "animated_elements": [
        {
            "name": "example_element",
            "type": "sprite_sequence",
            "position": {"x": 100, "y": 100},
            "frames_path": "res://src/assets/backgrounds/animated_elements/${DISTRICT_NAME}/example",
            "frame_count": 4,
            "animation_speed": 5.0,
            "loop": true,
            "autoplay": true,
            "scale": {"x": 1.0, "y": 1.0},
            "z_index": 0
        }
    ],
    "shader_effects": [
        {
            "name": "example_effect",
            "type": "heat_distortion",
            "position": {"x": 200, "y": 150},
            "size": {"width": 100, "height": 100},
            "intensity": 0.5,
            "speed": 1.0,
            "z_index": 1
        }
    ],
    "interactive_zones": [
        {
            "name": "example_interactive_zone",
            "position": {"x": 300, "y": 200},
            "size": {"width": 50, "height": 50},
            "hover_animation": "pulse",
            "click_action": "animate",
            "target_element": "example_element"
        }
    ]
}
EOL

echo "Created animation config template at: $CONFIG_PATH"
echo "Edit this file to configure animated elements for the $DISTRICT_NAME district"
echo "Usage:"
echo "1. Add your background image to src/assets/backgrounds/$DISTRICT_NAME/"
echo "2. Add animation frames to src/assets/backgrounds/animated_elements/$DISTRICT_NAME/"
echo "3. Configure animation properties in the config file"
echo "4. Test with './run_animation_test.sh $DISTRICT_NAME'"

# Create necessary directories if they don't exist
mkdir -p "$(dirname "$0")/../src/assets/backgrounds/${DISTRICT_NAME}"
mkdir -p "$(dirname "$0")/../src/assets/backgrounds/animated_elements/${DISTRICT_NAME}"

# Make script executable
chmod +x "$0"