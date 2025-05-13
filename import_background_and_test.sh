#!/bin/bash

# Simple script to import a background image for the scrolling camera test

# Default scale
SCALE_X=1
SCALE_Y=1

# Show help
function show_help {
    echo "Usage: $0 /path/to/your/background.png [scale_x scale_y]"
    echo ""
    echo "This script will:"
    echo "1. Copy your background image to the project's asset directory"
    echo "2. Import the asset into Godot"
    echo "3. Run the scrolling camera test with your background"
    echo ""
    echo "Optional parameters:"
    echo "  scale_x scale_y - Scale factors for the background (default: 1 1)"
    echo ""
    echo "Example:"
    echo "  $0 ~/Downloads/my_wide_background.png 2 1"
    echo ""
    exit 1
}

# Check input
if [ -z "$1" ]; then
    show_help
fi

# Get the input file
INPUT_FILE=$1

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File $INPUT_FILE does not exist."
    exit 1
fi

# Get optional scale parameters
if [ ! -z "$2" ] && [ ! -z "$3" ]; then
    SCALE_X=$2
    SCALE_Y=$3
fi

# Get filename without path
FILENAME=$(basename "$INPUT_FILE")

# Create the destination directory if it doesn't exist
mkdir -p "src/assets/backgrounds/test"

# Copy the image to the assets directory
DEST_PATH="src/assets/backgrounds/test/$FILENAME"
cp "$INPUT_FILE" "$DEST_PATH"
echo "Copied $INPUT_FILE to $DEST_PATH"

# Import the asset
echo "Importing asset into Godot..."
./a_silent_refraction.sh import

# Create a temporary test scene with the background
cat > "src/test/temp_scrolling_camera_test.tscn" << EOL
[gd_scene load_steps=3 format=2]

[ext_resource path="res://src/test/scrolling_camera_test.gd" type="Script" id=1]
[ext_resource path="res://src/characters/player/player.tscn" type="PackedScene" id=2]

[node name="ScrollingCameraTest" type="Node2D"]
script = ExtResource( 1 )
use_scrolling_camera = true
background_texture_path = "res://$DEST_PATH"
background_scale = Vector2( $SCALE_X, $SCALE_Y )

[node name="Background" type="Sprite" parent="."]
centered = false

[node name="Player" parent="." instance=ExtResource( 2 )]
position = Vector2( 512, 300 )

[node name="WalkableArea" type="Polygon2D" parent="."]
color = Color( 0, 1, 0, 0.101961 )
polygon = PoolVector2Array( )

[node name="Instructions" type="Label" parent="."]
margin_left = 20.0
margin_top = 20.0
margin_right = 532.0
margin_bottom = 137.0
text = "Scrolling Camera Test Scene

- Background: $FILENAME (Scale: ${SCALE_X}x${SCALE_Y})
- Click anywhere to move the player
- When the player approaches the edge of the screen, the camera will follow
- The green area shows the walkable bounds
- Try moving to the far edges of the background

Press ESC to exit"
__meta__ = {
"_edit_use_anchors_": false
}
EOL

# Run the test
echo "Running scrolling camera test with your background..."
$GODOT_CMD --path $(pwd) "res://src/test/temp_scrolling_camera_test.tscn"