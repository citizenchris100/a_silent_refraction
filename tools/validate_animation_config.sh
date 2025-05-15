#!/bin/bash
# validate_animation_config.sh
# Validates JSON format and animation paths in district animation configurations

# Constants
BASE_DIR="$(dirname "$0")/.."
CONFIG_FILENAME="animated_elements_config.json"

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <district_name>"
    echo "       $0 --all"
    echo "Example: $0 shipping"
    exit 1
fi

# Function to validate a single config file
validate_config() {
    local district_name="$1"
    local config_path="${BASE_DIR}/src/districts/${district_name}/${CONFIG_FILENAME}"
    
    echo "Validating animation config for district: $district_name"
    
    # Check if config file exists
    if [ ! -f "$config_path" ]; then
        echo "ERROR: Animation config file not found: $config_path"
        echo "Use './tools/create_animation_config.sh $district_name' to create it"
        return 1
    fi
    
    # Validate JSON format
    if ! jq empty "$config_path" 2>/dev/null; then
        echo "ERROR: Invalid JSON format in $config_path"
        return 1
    fi
    
    echo "✓ JSON format is valid"
    
    # Validate background path
    local bg_path=$(jq -r '.background' "$config_path")
    local real_bg_path="${BASE_DIR}/${bg_path#res://}"
    
    if [ ! -f "$real_bg_path" ]; then
        echo "WARNING: Background image not found: $real_bg_path"
    else
        echo "✓ Background image exists: $bg_path"
    fi
    
    # Validate animated elements
    local element_count=$(jq '.animated_elements | length' "$config_path")
    echo "Found $element_count animated elements to validate"
    
    for i in $(seq 0 $((element_count-1))); do
        local element_name=$(jq -r ".animated_elements[$i].name" "$config_path")
        local frames_path=$(jq -r ".animated_elements[$i].frames_path" "$config_path")
        local frame_count=$(jq -r ".animated_elements[$i].frame_count" "$config_path")
        
        echo "  Checking element: $element_name"
        
        if [ "$frames_path" == "null" ]; then
            echo "  WARNING: frames_path is not specified for $element_name"
            continue
        fi
        
        local real_frames_path="${BASE_DIR}/${frames_path#res://}"
        local dir_path=$(dirname "$real_frames_path")
        local base_name=$(basename "$real_frames_path")
        
        # Check if directory exists
        if [ ! -d "$dir_path" ]; then
            echo "  WARNING: Frames directory not found: $dir_path"
            continue
        fi
        
        # Check if frames exist
        local found_frames=0
        for j in $(seq 1 $frame_count); do
            if [ -f "${dir_path}/${base_name}${j}.png" ]; then
                found_frames=$((found_frames+1))
            fi
        done
        
        if [ $found_frames -eq $frame_count ]; then
            echo "  ✓ All $frame_count frames found for $element_name"
        else
            echo "  WARNING: Only $found_frames/$frame_count frames found for $element_name"
            echo "  Expected pattern: ${dir_path}/${base_name}N.png (where N is 1-$frame_count)"
        fi
    done
    
    # Validate shader effects
    local shader_count=$(jq '.shader_effects | length' "$config_path")
    echo "Found $shader_count shader effects to validate"
    
    for i in $(seq 0 $((shader_count-1))); do
        local shader_name=$(jq -r ".shader_effects[$i].name" "$config_path")
        local shader_type=$(jq -r ".shader_effects[$i].type" "$config_path")
        
        echo "  Checking shader: $shader_name"
        
        # Check if shader type is valid
        case "$shader_type" in
            heat_distortion|crt_screen|hologram)
                echo "  ✓ Valid shader type: $shader_type"
                ;;
            *)
                echo "  WARNING: Unknown shader type: $shader_type"
                echo "  Supported types: heat_distortion, crt_screen, hologram"
                ;;
        esac
        
        # Check if shader file exists
        local shader_file="${BASE_DIR}/src/shaders/${shader_type}.shader"
        if [ ! -f "$shader_file" ]; then
            echo "  WARNING: Shader file not found: $shader_file"
        else
            echo "  ✓ Shader file exists: $shader_file"
        fi
    done
    
    echo "Validation complete for $district_name"
    return 0
}

# Main execution
if [ "$1" == "--all" ]; then
    # Validate all districts
    success=true
    for district_dir in "${BASE_DIR}/src/districts"/*; do
        if [ -d "$district_dir" ]; then
            district_name=$(basename "$district_dir")
            if ! validate_config "$district_name"; then
                success=false
            fi
            echo ""
        fi
    done
    
    if $success; then
        echo "All animation configs validated successfully"
        exit 0
    else
        echo "Validation failed for one or more districts"
        exit 1
    fi
else
    # Validate single district
    district_name="$1"
    if validate_config "$district_name"; then
        exit 0
    else
        exit 1
    fi
fi

# Make script executable
chmod +x "$0"