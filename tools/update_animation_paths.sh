#!/bin/bash
# update_animation_paths.sh
# Updates paths in animation configs when assets move

# Constants
BASE_DIR="$(dirname "$0")/.."
CONFIG_FILENAME="animated_elements_config.json"

# Help function
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --district <name>   Update paths for a specific district"
    echo "  --all               Update paths for all districts"
    echo "  --old-path <path>   Path pattern to replace (e.g. 'old_district')"
    echo "  --new-path <path>   New path to use (e.g. 'new_district')"
    echo "  --dry-run           Show changes without applying them"
    echo "  --help              Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --district shipping --old-path 'shipping/old' --new-path 'shipping/new'"
    echo "  $0 --all --old-path 'animated_elements' --new-path 'animations'"
}

# Check arguments
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

# Parse arguments
DISTRICT=""
OLD_PATH=""
NEW_PATH=""
DRY_RUN=false
ALL_DISTRICTS=false

while [ $# -gt 0 ]; do
    case "$1" in
        --district)
            DISTRICT="$2"
            shift 2
            ;;
        --all)
            ALL_DISTRICTS=true
            shift
            ;;
        --old-path)
            OLD_PATH="$2"
            shift 2
            ;;
        --new-path)
            NEW_PATH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$OLD_PATH" ] || [ -z "$NEW_PATH" ]; then
    echo "ERROR: Both --old-path and --new-path must be specified"
    exit 1
fi

if [ "$ALL_DISTRICTS" = false ] && [ -z "$DISTRICT" ]; then
    echo "ERROR: Either --district or --all must be specified"
    exit 1
fi

# Function to update paths in a single config file
update_config() {
    local district_name="$1"
    local config_path="${BASE_DIR}/src/districts/${district_name}/${CONFIG_FILENAME}"
    
    echo "Processing district: $district_name"
    
    # Check if config file exists
    if [ ! -f "$config_path" ]; then
        echo "WARNING: Animation config file not found: $config_path"
        return 1
    fi
    
    # Create backup
    cp "$config_path" "${config_path}.backup"
    
    # Count replacements
    local bg_replaced=false
    local elements_replaced=0
    
    # Update background path
    local bg_path=$(jq -r '.background' "$config_path")
    if [[ "$bg_path" == *"$OLD_PATH"* ]]; then
        local new_bg_path="${bg_path//$OLD_PATH/$NEW_PATH}"
        if [ "$DRY_RUN" = true ]; then
            echo "Would replace background path:"
            echo "  From: $bg_path"
            echo "  To:   $new_bg_path"
        else
            # Use temporary file for complex jq operations
            jq --arg new_path "$new_bg_path" '.background = $new_path' "$config_path" > "${config_path}.tmp"
            mv "${config_path}.tmp" "$config_path"
            bg_replaced=true
        fi
    fi
    
    # Update animated elements frames paths
    local element_count=$(jq '.animated_elements | length' "$config_path")
    
    for i in $(seq 0 $((element_count-1))); do
        local frames_path=$(jq -r ".animated_elements[$i].frames_path" "$config_path")
        if [[ "$frames_path" == *"$OLD_PATH"* ]]; then
            local new_frames_path="${frames_path//$OLD_PATH/$NEW_PATH}"
            if [ "$DRY_RUN" = true ]; then
                echo "Would replace frames path:"
                echo "  From: $frames_path"
                echo "  To:   $new_frames_path"
            else
                jq --arg index "$i" --arg new_path "$new_frames_path" \
                   '.animated_elements[$index | tonumber].frames_path = $new_path' "$config_path" > "${config_path}.tmp"
                mv "${config_path}.tmp" "$config_path"
                elements_replaced=$((elements_replaced+1))
            fi
        fi
    done
    
    # Report results
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run completed for $district_name"
    else
        if [ "$bg_replaced" = true ] || [ $elements_replaced -gt 0 ]; then
            echo "Updated $district_name config:"
            if [ "$bg_replaced" = true ]; then
                echo "- Background path updated"
            fi
            if [ $elements_replaced -gt 0 ]; then
                echo "- $elements_replaced element paths updated"
            fi
            echo "Backup saved to: ${config_path}.backup"
        else
            echo "No paths matched for replacement in $district_name"
            rm "${config_path}.backup" # Remove backup if no changes
        fi
    fi
}

# Main execution
if [ "$ALL_DISTRICTS" = true ]; then
    # Update all districts
    echo "Updating paths in all districts"
    echo "  Replace: '$OLD_PATH' with '$NEW_PATH'"
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] No changes will be applied"
    fi
    
    for district_dir in "${BASE_DIR}/src/districts"/*; do
        if [ -d "$district_dir" ]; then
            district_name=$(basename "$district_dir")
            update_config "$district_name"
        fi
    done
else
    # Update single district
    echo "Updating paths in district: $DISTRICT"
    echo "  Replace: '$OLD_PATH' with '$NEW_PATH'"
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] No changes will be applied"
    fi
    
    update_config "$DISTRICT"
fi

echo "Path update operation completed"

# Make script executable
chmod +x "$0"