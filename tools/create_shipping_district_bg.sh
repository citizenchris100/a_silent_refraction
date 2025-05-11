#!/bin/bash

# A Silent Refraction - Shipping District Background Creator
# This script creates the main floor background for the Shipping District
# with predefined positions for animated elements

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it with: sudo apt-get install imagemagick"
    exit 1
fi

# Define canonical color palette
declare -A PALETTE
PALETTE["black"]="#212225"       # Dark Black - Deep shadows and outlines 
PALETTE["d_purple"]="#29272c"    # Dark Purple - Space and darkness
PALETTE["d_brown"]="#3c3537"     # Dark Brown - Industrial tones
PALETTE["m_brown"]="#494543"     # Medium Brown - Wood and aged materials
PALETTE["tan"]="#58504b"         # Tan Brown - Natural surfaces
PALETTE["g_gray"]="#5e6259"      # Green-Gray - Utilitarian surfaces
PALETTE["p_gray"]="#726b73"      # Purple-Gray - Cold metal and shadows
PALETTE["r_pink"]="#907577"      # Rusty Pink - Oxidized metal
PALETTE["b_gray"]="#7b8e95"      # Blue Gray - Technical surfaces
PALETTE["m_purple"]="#b18da1"    # Muted Purple - Accent highlights
PALETTE["w_tan"]="#c2a783"       # Warm Tan - Warm light sources
PALETTE["p_green"]="#a9c2a4"     # Pale Green - Alien presence
PALETTE["l_gray"]="#cec6c0"      # Light Gray - Light surfaces
PALETTE["w_cream"]="#e4d2c6"     # Warm Cream - Skin tones, warm light
PALETTE["p_yellow"]="#f3e9c4"    # Pale Yellow - Bright highlights
PALETTE["p_pink"]="#fbede4"      # Pale Pink - Brightest elements

# Set dimensions
WIDTH=1024
HEIGHT=600

# Set output directories
OUTPUT_DIR="src/assets/backgrounds/shipping"
mkdir -p "$OUTPUT_DIR"

# Create config directory for animated elements
CONFIG_DIR="src/districts/shipping"
mkdir -p "$CONFIG_DIR"

echo "Generating Shipping District background..."

# Create base background
convert -size ${WIDTH}x${HEIGHT} canvas:${PALETTE["d_purple"]} \
    "$OUTPUT_DIR/main_floor_base.png"

# Add floor
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["m_brown"]} -draw "rectangle 0,300 $WIDTH,$HEIGHT" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add ceiling structure
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["d_brown"]} -draw "rectangle 0,0 $WIDTH,70" \
    -fill ${PALETTE["d_brown"]} -draw "polygon 150,70 200,100 824,100 874,70" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add support columns
for x in 150 300 450 600 750 874; do
    convert "$OUTPUT_DIR/main_floor_base.png" \
        -fill ${PALETTE["d_brown"]} -draw "rectangle $x,70 $((x+20)),300" \
        "$OUTPUT_DIR/main_floor_base.png"
done

# Add floor details - loading area
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["tan"]} -draw "rectangle 200,400 824,500" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add floor markings
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 210,450 250,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 270,450 310,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 330,450 370,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 390,450 430,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 450,450 490,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 510,450 550,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 570,450 610,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 630,450 670,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 690,450 730,455" \
    -fill ${PALETTE["p_yellow"]} -draw "rectangle 750,450 790,455" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add control station enclosure - left side
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["m_brown"]} -draw "rectangle 50,150 150,280" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add window to control station
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["b_gray"]} -draw "rectangle 70,180 130,240" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add office area - right side
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["m_brown"]} -draw "rectangle 874,150 974,280" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add door to office area
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["g_gray"]} -draw "rectangle 900,220 940,280" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add ship docking area - top right
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["d_brown"]} -draw "rectangle 700,10 800,50" \
    -fill ${PALETTE["p_gray"]} -draw "rectangle 720,20 780,40" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add wall details
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["r_pink"]} -draw "circle 250,50 260,60" \
    -fill ${PALETTE["r_pink"]} -draw "circle 400,50 410,60" \
    -fill ${PALETTE["r_pink"]} -draw "circle 550,50 560,60" \
    -fill ${PALETTE["r_pink"]} -draw "circle 700,50 710,60" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add door to next area - bottom
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["p_gray"]} -draw "rectangle 450,550 550,600" \
    -fill ${PALETTE["m_brown"]} -draw "rectangle 460,560 540,600" \
    "$OUTPUT_DIR/main_floor_base.png"

# Add crates
draw_crate() {
    local x=$1
    local y=$2
    local size=$3

    convert "$OUTPUT_DIR/main_floor_base.png" \
        -fill ${PALETTE["w_tan"]} -draw "rectangle $x,$y $((x+size)),$((y+size))" \
        -fill ${PALETTE["m_brown"]} -draw "rectangle $((x+5)),$((y+5)) $((x+size-5)),$((y+size-5))" \
        "$OUTPUT_DIR/main_floor_base.png"
}

# Draw various crates
draw_crate 200 320 60
draw_crate 280 350 80
draw_crate 400 330 50
draw_crate 600 350 70
draw_crate 700 320 90

# Add wall decorations - shipping company logo
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill ${PALETTE["b_gray"]} -draw "rectangle 450,120 550,160" \
    -fill ${PALETTE["p_yellow"]} -pointsize 20 -gravity center -annotate +0+100 "AETHER CORP" \
    "$OUTPUT_DIR/main_floor_base.png"

# Create config file for animated elements
cat > "$CONFIG_DIR/animated_elements_config.json" << EOL
{
  "elements": [
    {
      "type": "computer_terminal",
      "id": "shipping_main",
      "position": {
        "x": 100,
        "y": 200
      },
      "properties": {
        "frame_delay": 0.3
      }
    },
    {
      "type": "warning_light",
      "id": "security",
      "position": {
        "x": 500,
        "y": 85
      }
    },
    {
      "type": "conveyor_belt",
      "id": "shipping",
      "position": {
        "x": 512,
        "y": 450
      },
      "properties": {
        "is_moving": true,
        "direction": 1
      }
    },
    {
      "type": "steam_vent",
      "id": "maintenance",
      "position": {
        "x": 350,
        "y": 550
      },
      "properties": {
        "cycle_pause": 5.0
      }
    },
    {
      "type": "ventilation_fan",
      "id": "standard",
      "position": {
        "x": 100,
        "y": 100
      },
      "properties": {
        "speed_factor": 0.5
      }
    },
    {
      "type": "sliding_door",
      "id": "standard",
      "position": {
        "x": 500,
        "y": 550
      }
    },
    {
      "type": "security_camera",
      "id": "shipping_main",
      "position": {
        "x": 230,
        "y": 100
      }
    },
    {
      "type": "flickering_light",
      "id": "hallway",
      "position": {
        "x": 650,
        "y": 50
      }
    }
  ]
}
EOL

# Create walkable area definition
cat > "$CONFIG_DIR/walkable_area.gd" << EOL
extends Node2D

# Walkable area for Shipping District main floor
export var enabled = true

# Walkable area polygon
var polygon = PoolVector2Array(
    100, 300,
    924, 300,
    924, 550,
    550, 550,
    550, 500,
    200, 500,
    200, 550,
    100, 550
)

func _ready():
    # Add to walkable area group
    add_to_group("walkable_area")

# Check if a point is inside the walkable area
func contains_point(point):
    if not enabled:
        return false
        
    return Geometry.is_point_in_polygon(point, polygon)
EOL

# Create full background with static placeholder for animated elements
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill "rgba(255,0,0,0.2)" -draw "rectangle 100,200 164,248" \
    -fill "rgba(255,0,0,0.2)" -draw "circle 500,85 500,95" \
    -fill "rgba(255,0,0,0.2)" -draw "rectangle 448,434 576,466" \
    -fill "rgba(255,0,0,0.2)" -draw "rectangle 350,502 350,598" \
    -fill "rgba(255,0,0,0.2)" -draw "circle 100,100 100,132" \
    -fill "rgba(255,0,0,0.2)" -draw "rectangle 468,550 532,600" \
    -fill "rgba(255,0,0,0.2)" -draw "rectangle 214,84 246,116" \
    -fill "rgba(255,0,0,0.2)" -draw "rectangle 618,50 682,50" \
    "$OUTPUT_DIR/main_floor_with_placeholders.png"

# Create a combined version with walkable area highlighted
convert "$OUTPUT_DIR/main_floor_base.png" \
    -fill "rgba(0,255,0,0.2)" -draw "polygon 100,300 924,300 924,550 550,550 550,500 200,500 200,550 100,550" \
    "$OUTPUT_DIR/main_floor_debug.png"

echo "Generated Shipping District backgrounds at:"
echo "- $OUTPUT_DIR/main_floor_base.png (Clean background)"
echo "- $OUTPUT_DIR/main_floor_with_placeholders.png (With animation placeholders)"
echo "- $OUTPUT_DIR/main_floor_debug.png (With walkable area visualized)"
echo ""
echo "Created animation configuration at:"
echo "- $CONFIG_DIR/animated_elements_config.json"
echo ""
echo "Created walkable area definition at:"
echo "- $CONFIG_DIR/walkable_area.gd"

# Import the images into Godot automatically
echo "Creating Godot import files..."
for file in "$OUTPUT_DIR/main_floor_base.png" "$OUTPUT_DIR/main_floor_with_placeholders.png" "$OUTPUT_DIR/main_floor_debug.png"; do
    cat > "${file}.import" << EOL
[remap]

importer="texture"
type="StreamTexture"
path="res://.import/$(basename "$file"),res://assets/backgrounds/shipping/$(basename "$file")"
metadata={
"vram_texture": false
}

[deps]

source_file="res://assets/backgrounds/shipping/$(basename "$file")"
dest_files=[ "res://.import/$(basename "$file"),res://assets/backgrounds/shipping/$(basename "$file")" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=false
svg/scale=1.0
EOL
done

echo "Setup complete!"