#!/bin/bash

# a_silent_refraction.sh - Game management script
# Usage: ./a_silent_refraction.sh [command]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Constants
PROJECT_ROOT=$(pwd)
GODOT_CMD="godot"
MAIN_SCENE="res://src/core/main.tscn"
TEST_SCENE="res://src/test/npc_system_test.tscn"

# Function to display help
function show_help {
    echo -e "${BLUE}A Silent Refraction - Game Management Script${NC}"
    echo ""
    echo "Usage: ./a_silent_refraction.sh [command]"
    echo ""
    echo "Commands:"
    echo "  run         - Run the main game"
    echo "  test        - Run the NPC test scene"
    echo "  clean       - Clean up redundant files"
    echo "  build       - Build the game for distribution"
    echo "  check       - Check project for errors"
    echo "  new-npc     - Create a new NPC script"
    echo "  new-district - Create a new district"
    echo "  help        - Show this help message"
    echo ""
}

# Function to run the game
function run_game {
    echo -e "${GREEN}Running A Silent Refraction main game...${NC}"
    $GODOT_CMD --path $PROJECT_ROOT $MAIN_SCENE
}

# Function to run the test scene
function run_test {
    echo -e "${GREEN}Running NPC test scene...${NC}"
    $GODOT_CMD --path $PROJECT_ROOT $TEST_SCENE
}

# Function to clean up redundant files
function clean_project {
    echo -e "${YELLOW}Cleaning up redundant files...${NC}"
    
    # Remove redundant files
    echo "Removing redundant test scenes..."
    for file in $(find src/test -name "*.tscn" -not -name "npc_system_test.tscn"); do
        rm "$file"
        rm "${file%.tscn}.gd" 2>/dev/null || true
    done
    
    # Remove redundant NPC implementations
    echo "Removing redundant NPC implementations..."
    find src/characters/npc -name "base_npc_*.gd" -delete
    find src/characters/npc -name "integration_*.gd" -delete
    
    # Remove redundant dialog managers
    echo "Removing redundant dialog managers..."
    find src/core/dialog -name "dialog_manager_*.gd" -delete
    find src/core/dialog -name "integration_*.gd" -delete
    
    # Remove redundant game managers
    echo "Removing redundant game managers..."
    find src/core/game -name "game_manager_*.gd" -delete
    
    echo -e "${GREEN}Cleanup complete.${NC}"
}

# Function to check the project for errors
function check_project {
    echo -e "${BLUE}Checking project for errors...${NC}"
    $GODOT_CMD --path $PROJECT_ROOT --check-only
}

# Function to build the game
function build_game {
    echo -e "${BLUE}Building game for distribution...${NC}"
    
    mkdir -p build
    
    # Build for Linux
    echo "Building for Linux..."
    $GODOT_CMD --path $PROJECT_ROOT --export "Linux/X11" build/a_silent_refraction_linux.x86_64
    
    # Build for Windows
    echo "Building for Windows..."
    $GODOT_CMD --path $PROJECT_ROOT --export "Windows Desktop" build/a_silent_refraction_windows.exe
    
    echo -e "${GREEN}Build complete. Files are in the build/ directory.${NC}"
}

# Function to create a new NPC
function create_new_npc {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: No NPC name provided.${NC}"
        echo "Usage: ./a_silent_refraction.sh new-npc <npc_name>"
        exit 1
    fi
    
    npc_name=$1
    npc_script="src/characters/npc/${npc_name}.gd"
    
    if [ -f "$npc_script" ]; then
        echo -e "${RED}Error: NPC script $npc_script already exists.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Creating new NPC: $npc_name${NC}"
    
    # Create the NPC script
    cat > "$npc_script" << NPCEOF
extends "res://src/characters/npc/base_npc.gd"

func _ready():
    npc_name = "${npc_name}"
    description = "A person on the station."
    is_assimilated = false
    
    # Call parent _ready
    ._ready()
    
    # Set visual color (customize as needed)
    if visual_sprite is ColorRect:
        visual_sprite.color = Color(0.5, 0.5, 0.5)  # Default gray

# Override dialog initialization
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Hello there.",
            "options": [
                {"text": "Hello.", "next": "greeting"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "greeting": {
            "text": "How can I help you?",
            "options": [
                {"text": "Just looking around.", "next": "looking"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "looking": {
            "text": "Feel free to look around.",
            "options": [
                {"text": "Thanks.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Goodbye.",
            "options": []
        }
    }

# Override become_suspicious if needed
func become_suspicious():
    # Custom suspicion behavior
    print("${npc_name} has become suspicious!")
NPCEOF
    
    echo -e "${GREEN}NPC script created: $npc_script${NC}"
    echo "You can now edit the script to customize the NPC's behavior."
}

# Function to create a new district
function create_new_district {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: No district name provided.${NC}"
        echo "Usage: ./a_silent_refraction.sh new-district <district_name>"
        exit 1
    fi
    
    district_name=$1
    district_folder="src/districts/${district_name}"
    
    if [ -d "$district_folder" ]; then
        echo -e "${RED}Error: District folder $district_folder already exists.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Creating new district: $district_name${NC}"
    
    # Create the district folder
    mkdir -p "$district_folder"
    
    # Create the district script
    cat > "$district_folder/${district_name}_district.gd" << DISTEOF
extends "res://src/core/districts/base_district.gd"

func _ready():
    district_name = "${district_name} District"
    district_description = "A district on the station."
    
    # Call parent _ready
    ._ready()

# Register locations within this district
func register_locations():
    var locations = {
        "main_area": {
            "name": "Main Area",
            "description": "The main area of the ${district_name} District."
        }
    }
    return locations
DISTEOF
    
    # Create the district scene
    cat > "$district_folder/${district_name}_district.tscn" << TSCNEOF
[gd_scene load_steps=3 format=2]

[ext_resource path="res://$district_folder/${district_name}_district.gd" type="Script" id=1]
[ext_resource path="res://src/core/districts/walkable_area.gd" type="Script" id=2]

[node name="${district_name}District" type="Node2D"]
script = ExtResource( 1 )

[node name="Background" type="ColorRect" parent="."]
margin_right = 1024.0
margin_bottom = 600.0
color = Color( 0.12549, 0.180392, 0.294118, 1 )

[node name="WalkableArea" type="Polygon2D" parent="."]
polygon = PoolVector2Array( 100, 300, 900, 300, 900, 550, 100, 550 )
script = ExtResource( 2 )

[node name="DistrictLabel" type="Label" parent="."]
margin_left = 20.0
margin_top = 20.0
margin_right = 228.0
margin_bottom = 50.0
text = "${district_name} District"
TSCNEOF
    
    echo -e "${GREEN}District created: $district_folder${NC}"
    echo "Files created:"
    echo "  - $district_folder/${district_name}_district.gd"
    echo "  - $district_folder/${district_name}_district.tscn"
    echo "You can now edit these files to customize the district."
}

# Main function to process commands
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    run)
        run_game
        ;;
    test)
        run_test
        ;;
    clean)
        clean_project
        ;;
    build)
        build_game
        ;;
    check)
        check_project
        ;;
    new-npc)
        create_new_npc "$2"
        ;;
    new-district)
        create_new_district "$2"
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac

exit 0
