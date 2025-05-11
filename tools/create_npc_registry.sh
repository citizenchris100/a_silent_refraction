#!/bin/bash

# A Silent Refraction NPC Registry and Placeholder Generator
# This script creates and manages an NPC registry with:
# - Persistent NPC data in JSON format
# - Placeholder sprite generation
# - GDScript utility class for gameplay integration
# - Support for assimilation status tracking

# Check if jq is installed (needed for JSON processing)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it with: sudo apt-get install jq"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it with: sudo apt-get install imagemagick"
    exit 1
fi

# Create NPC data directory if it doesn't exist
mkdir -p "src/assets/characters/npcs"
mkdir -p "src/data"

# NPC registry file
NPC_REGISTRY="src/data/npc_registry.json"

# Initialize or load NPC registry
if [ ! -f "$NPC_REGISTRY" ]; then
    echo "{\"npcs\": []}" > "$NPC_REGISTRY"
    echo "Created new NPC registry at $NPC_REGISTRY"
else
    echo "Loading existing NPC registry from $NPC_REGISTRY"
fi

# Function to add a new NPC to the registry
add_npc_to_registry() {
    local id=$1
    local name=$2
    local type=$3
    local location=$4
    local assimilated=${5:-false}
    
    # Check if NPC already exists
    if jq -e ".npcs[] | select(.id == \"$id\")" "$NPC_REGISTRY" > /dev/null; then
        echo "NPC with ID '$id' already exists. Updating..."
        # Update existing NPC
        jq --arg id "$id" \
           --arg name "$name" \
           --arg type "$type" \
           --arg location "$location" \
           --argjson assimilated "$assimilated" \
           '.npcs = [.npcs[] | if .id == $id then {id: $id, name: $name, type: $type, location: $location, assimilated: $assimilated, suspicious_level: .suspicious_level, known_assimilated: .known_assimilated} else . end]' \
           "$NPC_REGISTRY" > "$NPC_REGISTRY.tmp"
    else
        echo "Adding new NPC: $name ($type) in $location"
        # Add new NPC
        jq --arg id "$id" \
           --arg name "$name" \
           --arg type "$type" \
           --arg location "$location" \
           --argjson assimilated "$assimilated" \
           '.npcs += [{id: $id, name: $name, type: $type, location: $location, assimilated: $assimilated, suspicious_level: 0.0, known_assimilated: false}]' \
           "$NPC_REGISTRY" > "$NPC_REGISTRY.tmp"
    fi
    
    mv "$NPC_REGISTRY.tmp" "$NPC_REGISTRY"
}

# Function to generate NPC placeholder sprites
generate_npc_placeholder() {
    local type=$1
    local id=$2
    local output_dir="src/assets/characters/npcs/$id"
    
    mkdir -p "$output_dir"
    
    # Define colors based on NPC type
    case $type in
        security_officer)
            BODY_COLOR="#223366"  # Dark blue uniform
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#AA0000"  # Red badge/accent
            ;;
        concierge)
            BODY_COLOR="#552200"  # Brown suit
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#FFCC00"  # Gold accents
            ;;
        dock_worker)
            BODY_COLOR="#555555"  # Gray/brown work clothes
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#FFAA00"  # Safety orange
            ;;
        bank_teller)
            BODY_COLOR="#003322"  # Dark green suit
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#FFFFFF"  # White collar
            ;;
        generic_male)
            BODY_COLOR="#333333"  # Dark casual clothes
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#666666"  # Gray details
            ;;
        generic_female)
            BODY_COLOR="#663366"  # Purple casual clothes
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#CC6699"  # Pink details
            ;;
        ship_captain)
            BODY_COLOR="#222222"  # Dark uniform
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#CCCCCC"  # Silver decorations
            ;;
        flight_attendant)
            BODY_COLOR="#0033AA"  # Blue uniform
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#FFFFFF"  # White accent
            ;;
        engineer)
            BODY_COLOR="#993300"  # Orange-brown jumpsuit
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#FFCC00"  # Yellow safety
            ;;
        scientist)
            BODY_COLOR="#FFFFFF"  # White lab coat
            HEAD_COLOR="#FFD0B0"  # Skin tone
            DETAIL_COLOR="#00AAFF"  # Blue accent
            ;;
        *)
            BODY_COLOR="#444444"  # Default gray
            HEAD_COLOR="#FFD0B0"  # Default skin tone
            DETAIL_COLOR="#888888"  # Default detail
            ;;
    esac
    
    # Generate normal state
    convert -size 32x64 canvas:transparent \
        -fill "$BODY_COLOR" -draw "rectangle 4,16 28,60" \
        -fill "$HEAD_COLOR" -draw "circle 16,9 16,16" \
        -fill "$DETAIL_COLOR" -draw "rectangle 12,28 20,36" \
        "$output_dir/normal.png"
    
    # Generate suspicious state
    convert -size 32x64 canvas:transparent \
        -fill "$BODY_COLOR" -draw "rectangle 4,16 28,60" \
        -fill "$HEAD_COLOR" -draw "circle 16,9 16,16" \
        -fill "$DETAIL_COLOR" -draw "rectangle 12,28 20,36" \
        -fill "#000000" -draw "point 12,8 point 20,8" \
        -fill "#FF0000" -draw "rectangle 12,20 20,22" \
        "$output_dir/suspicious.png"
    
    # Generate hostile state
    convert -size 32x64 canvas:transparent \
        -fill "$BODY_COLOR" -draw "rectangle 4,16 28,60" \
        -fill "$HEAD_COLOR" -draw "circle 16,9 16,16" \
        -fill "$DETAIL_COLOR" -draw "rectangle 12,28 20,36" \
        -fill "#000000" -draw "point 12,8 point 20,8" \
        -fill "#FF0000" -draw "rectangle 10,20 22,22" \
        -fill "#FF0000" -draw "rectangle 14,30 18,48" \
        "$output_dir/hostile.png"
    
    # Generate assimilated state (subtle green tint)
    convert "$output_dir/normal.png" \
        -fill "#AAFFAA" -colorize 20% \
        "$output_dir/assimilated.png"
    
    echo "Created placeholder sprites for $id ($type) in $output_dir"
}

# Generate GDScript file for NPC data access
generate_npc_data_script() {
    local script_path="src/data/npc_data.gd"
    
    cat > "$script_path" <<EOL
# NPC Data Manager
# Auto-generated by create_npc_registry.sh
extends Node

# NPC registry
var npc_registry = {}

# Load NPC data on ready
func _ready():
    load_npc_data()

# Load NPC data from JSON file
func load_npc_data():
    var file = File.new()
    if file.file_exists("res://data/npc_registry.json"):
        file.open("res://data/npc_registry.json", File.READ)
        var text = file.get_as_text()
        var result = JSON.parse(text)
        file.close()
        if result.error == OK:
            npc_registry = result.result
        else:
            print("Error parsing NPC registry JSON: ", result.error_string)
    else:
        print("NPC registry file not found")

# Save NPC data to JSON file
func save_npc_data():
    var file = File.new()
    file.open("res://data/npc_registry.json", File.WRITE)
    file.store_string(JSON.print(npc_registry, "  "))
    file.close()

# Get an NPC by ID
func get_npc(id):
    for npc in npc_registry.npcs:
        if npc.id == id:
            return npc
    return null

# Set NPC assimilation status
func set_assimilated(id, assimilated):
    var npc = get_npc(id)
    if npc != null:
        npc.assimilated = assimilated
        save_npc_data()
        return true
    return false

# Set NPC suspicious level
func set_suspicious_level(id, level):
    var npc = get_npc(id)
    if npc != null:
        npc.suspicious_level = clamp(level, 0.0, 1.0)
        save_npc_data()
        return true
    return false

# Mark NPC as known assimilated
func set_known_assimilated(id, known):
    var npc = get_npc(id)
    if npc != null:
        npc.known_assimilated = known
        save_npc_data()
        return true
    return false

# Get all assimilated NPCs
func get_assimilated_npcs():
    var result = []
    for npc in npc_registry.npcs:
        if npc.assimilated:
            result.append(npc)
    return result

# Get all known assimilated NPCs
func get_known_assimilated_npcs():
    var result = []
    for npc in npc_registry.npcs:
        if npc.known_assimilated:
            result.append(npc)
    return result

# Get NPCs by location
func get_npcs_by_location(location):
    var result = []
    for npc in npc_registry.npcs:
        if npc.location == location:
            result.append(npc)
    return result

# Get count of assimilated NPCs
func get_assimilated_count():
    var count = 0
    for npc in npc_registry.npcs:
        if npc.assimilated:
            count += 1
    return count

# Get count of known assimilated NPCs
func get_known_assimilated_count():
    var count = 0
    for npc in npc_registry.npcs:
        if npc.known_assimilated:
            count += 1
    return count
EOL

    echo "Generated NPC data script at $script_path"
}

# Add initial NPCs to registry based on game design document
add_npcs() {
    echo "Adding NPCs from Security District..."
    add_npc_to_registry "security_officer_01" "Officer Jenkins" "security_officer" "security_main" "false"
    add_npc_to_registry "security_officer_02" "Officer Rodriguez" "security_officer" "security_brig" "false"
    add_npc_to_registry "security_officer_03" "Officer Chen" "security_officer" "security_brig" "true"
    add_npc_to_registry "security_officer_04" "Officer Wilson" "security_officer" "security_patrol" "false"
    add_npc_to_registry "security_officer_05" "Officer Martinez" "security_officer" "security_patrol" "false"
    add_npc_to_registry "security_officer_06" "Officer Taylor" "security_officer" "security_patrol" "false"
    add_npc_to_registry "office_clerk_security" "Clerk Adams" "generic_female" "security_main" "false"
    add_npc_to_registry "detective_01" "Detective Sharma" "security_officer" "security_investigative" "false"
    add_npc_to_registry "detective_02" "Detective Lee" "security_officer" "security_investigative" "true"
    add_npc_to_registry "security_admin_01" "Administrator Garcia" "generic_male" "security_admin" "false"
    
    echo "Adding NPCs from Shipping District..."
    add_npc_to_registry "dock_worker_01" "Worker Smith" "dock_worker" "shipping_main" "false"
    add_npc_to_registry "dock_worker_02" "Worker Jones" "dock_worker" "shipping_main" "true"
    add_npc_to_registry "dock_worker_03" "Worker Garcia" "dock_worker" "shipping_main" "false"
    add_npc_to_registry "dock_foreman" "Foreman Harris" "dock_worker" "shipping_main" "false"
    add_npc_to_registry "dock_manager" "Manager Phillips" "generic_male" "shipping_office" "true"
    add_npc_to_registry "dock_secretary" "Secretary Chen" "generic_female" "shipping_office" "false"
    add_npc_to_registry "ship_captain_theseus" "Captain Reynolds" "ship_captain" "ship_theseus" "false"
    add_npc_to_registry "flight_attendant_01" "Attendant Torres" "flight_attendant" "ship_theseus" "false"
    add_npc_to_registry "flight_attendant_02" "Attendant Kim" "flight_attendant" "ship_theseus" "false"
    
    echo "Adding NPCs from Barracks..."
    add_npc_to_registry "concierge" "Henry Davis" "concierge" "barracks_main" "false"
    add_npc_to_registry "porter_01" "Porter Wilson" "generic_male" "barracks_main" "false"
    add_npc_to_registry "porter_02" "Porter Chang" "generic_male" "barracks_main" "false"
    add_npc_to_registry "resident_01" "Sarah Kim" "generic_female" "barracks_floor01_room103" "true"
    add_npc_to_registry "resident_02" "David Miller" "generic_male" "barracks_floor05_room508" "false"
    add_npc_to_registry "resident_03" "Jennifer Wu" "generic_female" "barracks_floor05_room508" "false"
    add_npc_to_registry "resident_04" "Robert Singh" "generic_male" "barracks_floor06_room601" "true"
    add_npc_to_registry "resident_05" "Emily Johnson" "generic_female" "barracks_floor09_room915" "false"
    add_npc_to_registry "resident_06" "Thomas Brown" "generic_male" "barracks_floor09_room915" "false"
    add_npc_to_registry "resident_07" "Rebecca Wilson" "generic_female" "barracks_floor12_room1211" "true"
    
    echo "Adding NPCs from Trading Floor..."
    add_npc_to_registry "bank_teller" "Teller Morgan" "bank_teller" "trading_bank" "false"
    add_npc_to_registry "bank_manager" "Manager Blackwell" "generic_male" "trading_bank" "true"
    add_npc_to_registry "broker_01" "Broker Williams" "generic_male" "trading_main" "false"
    add_npc_to_registry "broker_02" "Broker Thompson" "generic_female" "trading_main" "false"
    add_npc_to_registry "broker_03" "Broker Jackson" "generic_male" "trading_main" "true"
    add_npc_to_registry "office_worker_01" "Worker Davis" "generic_female" "trading_regulatory" "false"
    add_npc_to_registry "office_manager" "Manager Roberts" "generic_male" "trading_regulatory" "false"
    
    echo "Added initial NPCs to registry"
}

# Main execution
echo "===== NPC Registry and Placeholder Generator ====="
add_npcs

# Generate placeholders for all NPCs in registry
echo "Generating NPC placeholders..."
jq -r '.npcs[] | [.id, .type] | @tsv' "$NPC_REGISTRY" | while IFS=$'\t' read -r id type; do
    generate_npc_placeholder "$type" "$id"
done

# Generate GDScript for accessing NPC data
generate_npc_data_script

echo "===== NPC Registry Generation Complete ====="
echo "NPC registry file: $NPC_REGISTRY"
echo "Placeholder sprites: src/assets/characters/npcs/"
echo "GDScript data access: src/data/npc_data.gd"

# Display registry statistics
TOTAL_NPCS=$(jq '.npcs | length' "$NPC_REGISTRY")
ASSIMILATED_NPCS=$(jq '[.npcs[] | select(.assimilated == true)] | length' "$NPC_REGISTRY")
echo "Registry Statistics:"
echo "- Total NPCs: $TOTAL_NPCS"
echo "- Initially Assimilated: $ASSIMILATED_NPCS ($(echo "scale=1; $ASSIMILATED_NPCS * 100 / $TOTAL_NPCS" | bc)%)"
echo "- NPCs by Type:"
jq -r '.npcs | group_by(.type) | map({type: .[0].type, count: length}) | sort_by(.count) | reverse | .[] | "\(.count) \(.type)"' "$NPC_REGISTRY" | \
    while read -r count type; do
        echo "  - $type: $count"
    done