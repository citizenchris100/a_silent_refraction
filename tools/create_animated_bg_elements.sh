#!/bin/bash

# A Silent Refraction - Animated Background Elements Generator
# This script creates animated sprites for background elements in the game
# These can be used as overlays on static backgrounds to add life to scenes

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

# Create directories if they don't exist
mkdir -p "src/assets/backgrounds/animated_elements"

# Usage information
usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list                  List available animated element types"
    echo "  generate <type> <id>  Generate animated element of specified type"
    echo "  generate-all          Generate all available animated elements"
    echo ""
    echo "Available types:"
    echo "  - computer_terminal   (Blinking computer screen)"
    echo "  - steam_vent          (Periodically releasing steam)"
    echo "  - warning_light       (Blinking warning light)"
    echo "  - sliding_door        (Door that can open/close)"
    echo "  - water_puddle        (Shimmering water puddle)"
    echo "  - flickering_light    (Light with random flicker effect)"
    echo "  - conveyor_belt       (Moving conveyor belt)"
    echo "  - ventilation_fan     (Spinning ventilation fan)"
    echo "  - hologram_display    (Glowing holographic projector)"
    echo "  - security_camera     (Moving security camera)"
    echo ""
    echo "Example:"
    echo "  $0 generate computer_terminal main_bridge"
    echo "  $0 generate-all"
}

# Function to generate a computer terminal with blinking screen
generate_computer_terminal() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/computer_terminal_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating computer terminal animation frames..."
    
    # Base terminal frame
    convert -size 64x48 \
        canvas:${PALETTE["black"]} \
        -fill ${PALETTE["d_brown"]} -draw "rectangle 2,2 62,46" \
        -fill ${PALETTE["black"]} -draw "rectangle 6,6 58,30" \
        "$output_dir/base.png"

    # Generate 10 frames with different screen contents
    for i in {0..9}; do
        cp "$output_dir/base.png" "$output_dir/frame_${i}.png"

        # Add random content to screen based on frame number
        case $((i % 5)) in
            0) # Main screen with text
                convert "$output_dir/frame_${i}.png" \
                    -fill ${PALETTE["b_gray"]} -draw "rectangle 8,8 56,28" \
                    -pointsize 6 -fill ${PALETTE["p_yellow"]} -gravity center -annotate 0 "SYSTEM\nONLINE" \
                    "$output_dir/frame_${i}.png"
                ;;
            1) # Processing screen
                convert "$output_dir/frame_${i}.png" \
                    -fill ${PALETTE["b_gray"]} -draw "rectangle 8,8 56,28" \
                    -pointsize 6 -fill ${PALETTE["p_yellow"]} -gravity center -annotate 0 "PROCESSING\n..." \
                    "$output_dir/frame_${i}.png"
                ;;
            2) # Data screen
                convert "$output_dir/frame_${i}.png" \
                    -fill ${PALETTE["b_gray"]} -draw "rectangle 8,8 56,28" \
                    -pointsize 5 -fill ${PALETTE["p_yellow"]} -gravity center -annotate 0 "0x550A72F1\n0x982BC341\n0x33098761" \
                    "$output_dir/frame_${i}.png"
                ;;
            3) # Warning screen
                convert "$output_dir/frame_${i}.png" \
                    -fill ${PALETTE["r_pink"]} -draw "rectangle 8,8 56,28" \
                    -pointsize 6 -fill ${PALETTE["p_yellow"]} -gravity center -annotate 0 "WARNING\nSYSTEM ERROR" \
                    "$output_dir/frame_${i}.png"
                ;;
            4) # Login screen
                convert "$output_dir/frame_${i}.png" \
                    -fill ${PALETTE["m_purple"]} -draw "rectangle 8,8 56,28" \
                    -pointsize 6 -fill ${PALETTE["p_yellow"]} -gravity center -annotate 0 "LOGIN:\n*******" \
                    "$output_dir/frame_${i}.png"
                ;;
        esac

        # Add keyboard/control panel
        convert "$output_dir/frame_${i}.png" \
            -fill ${PALETTE["m_brown"]} -draw "rectangle 10,32 54,44" \
            -fill ${PALETTE["p_gray"]} -draw "rectangle 12,34 20,38" \
            -fill ${PALETTE["p_gray"]} -draw "rectangle 22,34 30,38" \
            -fill ${PALETTE["p_gray"]} -draw "rectangle 32,34 40,38" \
            -fill ${PALETTE["p_gray"]} -draw "rectangle 42,34 50,38" \
            -fill ${PALETTE["p_gray"]} -draw "circle 45,41 47,41" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif
    convert -delay 25 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript animation frames implementation
    cat > "$output_dir/computer_terminal.gd" << EOL
# Computer Terminal Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.25  # seconds between frames

func _ready():
    # Load all animation frames
    for i in range(10):
        var texture = load("res://assets/backgrounds/animated_elements/computer_terminal_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    animation_timer += delta
    if animation_timer >= frame_delay:
        animation_timer -= frame_delay
        current_frame = (current_frame + 1) % frames.size()
        texture = frames[current_frame]
EOL
    
    echo "Created computer terminal animation at $output_dir"
}

# Function to generate a steam vent
generate_steam_vent() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/steam_vent_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating steam vent animation frames..."
    
    # Base vent frame
    convert -size 48x96 canvas:transparent \
        -fill "#333333" -draw "rectangle 16,88 32,96" \
        -fill "#222222" -draw "rectangle 18,86 30,88" \
        "$output_dir/base.png"
    
    # Generate 12 frames of steam
    for i in {0..11}; do
        cp "$output_dir/base.png" "$output_dir/frame_${i}.png"
        
        # Factor to determine how much steam to show
        local factor
        if [ $i -lt 6 ]; then
            # Steam increasing (0-5)
            factor=$i
        else
            # Steam decreasing (6-11)
            factor=$((11 - i))
        fi
        
        # Draw steam cloud based on factor
        convert "$output_dir/frame_${i}.png" \
            -fill "rgba(255,255,255,$((30 + factor * 35)))" \
            -draw "ellipse 24,$((86 - factor * 8)) $((5 + factor * 3)),$((5 + factor * 2)) 0,360" \
            -draw "ellipse $((19 - factor)),$((78 - factor * 8)) $((4 + factor * 2)),$((4 + factor * 2)) 0,360" \
            -draw "ellipse $((29 + factor)),$((78 - factor * 8)) $((4 + factor * 2)),$((4 + factor * 2)) 0,360" \
            -draw "ellipse 24,$((70 - factor * 8)) $((6 + factor * 4)),$((4 + factor * 4)) 0,360" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif
    convert -delay 10 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript animation implementation
    cat > "$output_dir/steam_vent.gd" << EOL
# Steam Vent Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.1  # seconds between frames
var cycle_pause = 3.0  # seconds between steam releases
var cycle_timer = 0.0
var is_steaming = false

func _ready():
    # Load all animation frames
    for i in range(12):
        var texture = load("res://assets/backgrounds/animated_elements/steam_vent_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    if is_steaming:
        animation_timer += delta
        if animation_timer >= frame_delay:
            animation_timer -= frame_delay
            current_frame += 1
            
            if current_frame >= frames.size():
                current_frame = 0
                is_steaming = false
                cycle_timer = 0.0
            
            texture = frames[current_frame]
    else:
        cycle_timer += delta
        if cycle_timer >= cycle_pause:
            is_steaming = true
            animation_timer = 0.0
EOL
    
    echo "Created steam vent animation at $output_dir"
}

# Function to generate a warning light
generate_warning_light() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/warning_light_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating warning light animation frames..."
    
    # Base frame - off state
    convert -size 32x32 canvas:transparent \
        -fill "#333333" -draw "rectangle 12,12 20,32" \
        -fill "#222222" -draw "circle 16,12 16,8" \
        "$output_dir/frame_0.png"
    
    # On state (orange)
    convert -size 32x32 canvas:transparent \
        -fill "#333333" -draw "rectangle 12,12 20,32" \
        -fill "#FF8800" -draw "circle 16,12 16,8" \
        -fill "rgba(255,136,0,30)" -draw "circle 16,12 25,6" \
        "$output_dir/frame_1.png"
    
    # On state (red)
    convert -size 32x32 canvas:transparent \
        -fill "#333333" -draw "rectangle 12,12 20,32" \
        -fill "#FF0000" -draw "circle 16,12 16,8" \
        -fill "rgba(255,0,0,30)" -draw "circle 16,12 25,6" \
        "$output_dir/frame_2.png"
    
    # Create animated .gif
    convert -delay 50 "$output_dir/frame_0.png" \
            -delay 10 "$output_dir/frame_1.png" \
            -delay 10 "$output_dir/frame_0.png" \
            -delay 10 "$output_dir/frame_2.png" \
            -loop 0 "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/warning_light.gd" << EOL
# Warning Light Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_sequence = [0, 1, 0, 2]  # Pattern: off, orange, off, red
var sequence_position = 0
var frame_delays = [0.5, 0.1, 0.1, 0.1]  # Different timing for each frame

func _ready():
    # Load all animation frames
    for i in range(3):
        var texture = load("res://assets/backgrounds/animated_elements/warning_light_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    animation_timer += delta
    if animation_timer >= frame_delays[sequence_position]:
        animation_timer -= frame_delays[sequence_position]
        sequence_position = (sequence_position + 1) % frame_sequence.size()
        current_frame = frame_sequence[sequence_position]
        texture = frames[current_frame]
EOL
    
    echo "Created warning light animation at $output_dir"
}

# Function to generate a sliding door
generate_sliding_door() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/sliding_door_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating sliding door animation frames..."
    
    # Generate 6 frames of door opening/closing
    for i in {0..5}; do
        # Door frame
        convert -size 64x96 canvas:transparent \
            -fill "#555555" -draw "rectangle 0,0 64,8" \
            -fill "#555555" -draw "rectangle 0,0 8,96" \
            -fill "#555555" -draw "rectangle 56,0 64,96" \
            -fill "#555555" -draw "rectangle 0,88 64,96" \
            "$output_dir/frame_${i}.png"
        
        # Door position based on frame
        local left_pos=$((8 + i * 8))
        local right_pos=$((56 - i * 8))
        
        # Door panels
        convert "$output_dir/frame_${i}.png" \
            -fill "#777777" -draw "rectangle 8,8 ${left_pos},88" \
            -fill "#777777" -draw "rectangle ${right_pos},8 56,88" \
            "$output_dir/frame_${i}.png"
    done
    
    # Copy frames in reverse for closing animation (skip first and last to avoid duplicates)
    for i in {4..1}; do
        cp "$output_dir/frame_${i}.png" "$output_dir/frame_$((10-i)).png"
    done
    
    # Create animated .gif
    convert -delay 10 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/sliding_door.gd" << EOL
# Sliding Door Animated Element
extends Sprite

var frames = []
var current_frame = 0
var is_open = false
var is_animating = false
var animation_timer = 0.0
var frame_delay = 0.1

signal door_opened
signal door_closed

func _ready():
    # Load all animation frames
    for i in range(10):
        var texture = load("res://assets/backgrounds/animated_elements/sliding_door_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    if is_animating:
        animation_timer += delta
        if animation_timer >= frame_delay:
            animation_timer -= frame_delay
            
            if is_open:
                # Opening animation
                current_frame += 1
                if current_frame >= 5:
                    current_frame = 5
                    is_animating = false
                    emit_signal("door_opened")
            else:
                # Closing animation
                current_frame -= 1
                if current_frame <= 0:
                    current_frame = 0
                    is_animating = false
                    emit_signal("door_closed")
            
            texture = frames[current_frame]

# Call this to open the door
func open():
    if not is_open:
        is_open = true
        is_animating = true

# Call this to close the door
func close():
    if is_open:
        is_open = false
        is_animating = true

# Toggle door state
func toggle():
    if is_open:
        close()
    else:
        open()
EOL
    
    echo "Created sliding door animation at $output_dir"
}

# Function to generate a water puddle
generate_water_puddle() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/water_puddle_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating water puddle animation frames..."
    
    # Generate 8 frames of shimmering water
    for i in {0..7}; do
        convert -size 64x32 canvas:transparent \
            "$output_dir/frame_${i}.png"
        
        # Draw base puddle shape
        convert "$output_dir/frame_${i}.png" \
            -fill "rgba(0,80,180,50)" -draw "ellipse 32,16 30,12 0,360" \
            "$output_dir/frame_${i}.png"
        
        # Add ripple effects based on frame number
        local angle=$((i * 45))
        local ripple_x=$(( 32 + 5 * $(bc -l <<< "scale=0; c=${angle}; x=10*c(${angle}*0.0174533); scale=0; x/1") ))
        local ripple_y=$(( 16 + 3 * $(bc -l <<< "scale=0; s=${angle}; y=10*s(${angle}*0.0174533); scale=0; y/1") ))
        
        convert "$output_dir/frame_${i}.png" \
            -fill "rgba(80,150,230,70)" -draw "ellipse ${ripple_x},${ripple_y} 4,2 0,360" \
            "$output_dir/frame_${i}.png"
        
        # Second ripple in different location
        local angle2=$(( (i * 45 + 180) % 360 ))
        local ripple_x2=$(( 32 + 8 * $(bc -l <<< "scale=0; c=${angle2}; x=10*c(${angle2}*0.0174533); scale=0; x/1") ))
        local ripple_y2=$(( 16 + 4 * $(bc -l <<< "scale=0; s=${angle2}; y=10*s(${angle2}*0.0174533); scale=0; y/1") ))
        
        convert "$output_dir/frame_${i}.png" \
            -fill "rgba(80,150,230,70)" -draw "ellipse ${ripple_x2},${ripple_y2} 3,2 0,360" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif
    convert -delay 20 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/water_puddle.gd" << EOL
# Water Puddle Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.2

func _ready():
    # Load all animation frames
    for i in range(8):
        var texture = load("res://assets/backgrounds/animated_elements/water_puddle_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    animation_timer += delta
    if animation_timer >= frame_delay:
        animation_timer -= frame_delay
        current_frame = (current_frame + 1) % frames.size()
        texture = frames[current_frame]
EOL
    
    echo "Created water puddle animation at $output_dir"
}

# Function to generate a flickering light
generate_flickering_light() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/flickering_light_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating flickering light animation frames..."
    
    # Base light fixture
    convert -size 64x64 canvas:transparent \
        -fill "#444444" -draw "rectangle 16,0 48,10" \
        "$output_dir/base.png"
    
    # Generate 5 frames of light with different intensities
    for i in {0..4}; do
        cp "$output_dir/base.png" "$output_dir/frame_${i}.png"
        
        # Light intensity based on frame
        local intensity
        case $i in
            0) intensity=80 ;; # Dim
            1) intensity=160 ;; # Medium
            2) intensity=255 ;; # Bright
            3) intensity=160 ;; # Medium
            4) intensity=30 ;; # Almost off
        esac
        
        # Draw light with glow
        convert "$output_dir/frame_${i}.png" \
            -fill "rgba(255,255,${intensity},255)" -draw "rectangle 20,10 44,12" \
            -fill "rgba(255,255,${intensity},30)" -draw "ellipse 32,25 25,15 0,360" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif with random pattern
    convert -delay 30 "$output_dir/frame_2.png" \
            -delay 3 "$output_dir/frame_1.png" \
            -delay 30 "$output_dir/frame_2.png" \
            -delay 3 "$output_dir/frame_3.png" \
            -delay 40 "$output_dir/frame_2.png" \
            -delay 5 "$output_dir/frame_4.png" \
            -delay 2 "$output_dir/frame_0.png" \
            -delay 3 "$output_dir/frame_1.png" \
            -delay 30 "$output_dir/frame_2.png" \
            -loop 0 "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/flickering_light.gd" << EOL
# Flickering Light Animated Element
extends Sprite

var frames = []
var current_frame = 2  # Start with normal brightness
var animation_timer = 0.0
var stable_timer = 0.0
var next_flicker = 3.0  # Time until next flicker
var is_flickering = false
var flicker_sequence = []
var flicker_position = 0

func _ready():
    # Load all animation frames
    for i in range(5):
        var texture = load("res://assets/backgrounds/animated_elements/flickering_light_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[current_frame]
    
    # Randomize for varied flickering
    randomize()

func _process(delta):
    if is_flickering:
        animation_timer += delta
        if animation_timer >= 0.05:  # Fast frame changes during flicker
            animation_timer -= 0.05
            flicker_position += 1
            
            if flicker_position >= flicker_sequence.size():
                is_flickering = false
                current_frame = 2  # Return to normal brightness
                stable_timer = 0.0
                next_flicker = rand_range(2.0, 8.0)  # Random time until next flicker
            else:
                current_frame = flicker_sequence[flicker_position]
            
            texture = frames[current_frame]
    else:
        stable_timer += delta
        if stable_timer >= next_flicker:
            start_flicker()

func start_flicker():
    is_flickering = true
    flicker_position = 0
    flicker_sequence = generate_flicker_sequence()
    current_frame = flicker_sequence[0]
    texture = frames[current_frame]
    animation_timer = 0.0

func generate_flicker_sequence():
    # Generate a random flickering pattern
    var sequence = []
    var flicker_length = randi() % 10 + 5  # 5-15 frames of flicker
    
    for i in range(flicker_length):
        var frame
        var r = randf()
        
        if r < 0.1:
            frame = 0  # Dim (rare)
        elif r < 0.3:
            frame = 4  # Almost off (uncommon)
        elif r < 0.5:
            frame = 1  # Medium dim
        elif r < 0.7:
            frame = 3  # Medium bright
        else:
            frame = 2  # Normal brightness (most common)
        
        sequence.append(frame)
    
    return sequence
EOL
    
    echo "Created flickering light animation at $output_dir"
}

# Function to generate a conveyor belt
generate_conveyor_belt() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/conveyor_belt_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating conveyor belt animation frames..."
    
    # Generate 8 frames of moving conveyor belt
    for i in {0..7}; do
        convert -size 128x32 canvas:transparent \
            -fill "#333333" -draw "rectangle 0,8 128,24" \
            "$output_dir/frame_${i}.png"
        
        # Draw the belt pattern with offset based on frame
        local offset=$((i * 4))
        
        for j in {0..32}; do
            local x=$(( (j * 4 + offset) % 128 ))
            convert "$output_dir/frame_${i}.png" \
                -fill "#555555" -draw "rectangle ${x},10 $((x+2)),22" \
                "$output_dir/frame_${i}.png"
        done
        
        # Add side rollers
        convert "$output_dir/frame_${i}.png" \
            -fill "#777777" -draw "circle 8,16 8,24" \
            -fill "#777777" -draw "circle 32,16 32,24" \
            -fill "#777777" -draw "circle 56,16 56,24" \
            -fill "#777777" -draw "circle 80,16 80,24" \
            -fill "#777777" -draw "circle 104,16 104,24" \
            -fill "#777777" -draw "circle 124,16 124,24" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif
    convert -delay 10 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/conveyor_belt.gd" << EOL
# Conveyor Belt Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.1
var is_moving = true
var direction = 1  # 1 = forward, -1 = reverse

func _ready():
    # Load all animation frames
    for i in range(8):
        var texture = load("res://assets/backgrounds/animated_elements/conveyor_belt_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    if is_moving:
        animation_timer += delta
        if animation_timer >= frame_delay:
            animation_timer -= frame_delay
            
            if direction == 1:
                current_frame = (current_frame + 1) % frames.size()
            else:
                current_frame = (current_frame - 1 + frames.size()) % frames.size()
            
            texture = frames[current_frame]

# Call to stop the conveyor
func stop():
    is_moving = false

# Call to start the conveyor
func start():
    is_moving = true

# Call to change direction
func reverse():
    direction *= -1
EOL
    
    echo "Created conveyor belt animation at $output_dir"
}

# Function to generate a ventilation fan
generate_ventilation_fan() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/ventilation_fan_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating ventilation fan animation frames..."
    
    # Generate 8 frames of spinning fan
    for i in {0..7}; do
        # Fan housing
        convert -size 64x64 canvas:transparent \
            -fill "#333333" -draw "circle 32,32 32,8" \
            -fill "#222222" -draw "circle 32,32 28,8" \
            "$output_dir/frame_${i}.png"
        
        # Fan blades at different angles
        local angle=$((i * 45))
        
        for j in {0..3}; do
            local blade_angle=$(( angle + j * 90 ))
            local x1=$(( 32 + 25 * $(bc -l <<< "scale=0; c=${blade_angle}; x=10*c(${blade_angle}*0.0174533); scale=0; x/1") / 10 ))
            local y1=$(( 32 + 25 * $(bc -l <<< "scale=0; s=${blade_angle}; y=10*s(${blade_angle}*0.0174533); scale=0; y/1") / 10 ))
            
            local blade_angle2=$(( blade_angle + 30 ))
            local x2=$(( 32 + 10 * $(bc -l <<< "scale=0; c=${blade_angle2}; x=10*c(${blade_angle2}*0.0174533); scale=0; x/1") / 10 ))
            local y2=$(( 32 + 10 * $(bc -l <<< "scale=0; s=${blade_angle2}; y=10*s(${blade_angle2}*0.0174533); scale=0; y/1") / 10 ))
            
            local blade_angle3=$(( blade_angle - 30 ))
            local x3=$(( 32 + 10 * $(bc -l <<< "scale=0; c=${blade_angle3}; x=10*c(${blade_angle3}*0.0174533); scale=0; x/1") / 10 ))
            local y3=$(( 32 + 10 * $(bc -l <<< "scale=0; s=${blade_angle3}; y=10*s(${blade_angle3}*0.0174533); scale=0; y/1") / 10 ))
            
            convert "$output_dir/frame_${i}.png" \
                -fill "#AAAAAA" -draw "polygon 32,32 ${x2},${y2} ${x1},${y1} ${x3},${y3}" \
                "$output_dir/frame_${i}.png"
        done
        
        # Center hub
        convert "$output_dir/frame_${i}.png" \
            -fill "#555555" -draw "circle 32,32 32,26" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif
    convert -delay 8 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/ventilation_fan.gd" << EOL
# Ventilation Fan Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.08  # Default speed
var is_spinning = true
var speed_factor = 1.0  # 1.0 = normal speed

func _ready():
    # Load all animation frames
    for i in range(8):
        var texture = load("res://assets/backgrounds/animated_elements/ventilation_fan_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    if is_spinning:
        animation_timer += delta * speed_factor
        if animation_timer >= frame_delay:
            animation_timer -= frame_delay
            current_frame = (current_frame + 1) % frames.size()
            texture = frames[current_frame]

# Call to stop the fan
func stop():
    is_spinning = false

# Call to start the fan
func start():
    is_spinning = true

# Call to change speed
func set_speed(factor):
    speed_factor = clamp(factor, 0.1, 3.0)
EOL
    
    echo "Created ventilation fan animation at $output_dir"
}

# Function to generate a hologram display
generate_hologram_display() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/hologram_display_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating hologram display animation frames..."
    
    # Base projector
    convert -size 64x64 canvas:transparent \
        -fill "#333333" -draw "rectangle 24,48 40,64" \
        -fill "#222222" -draw "rectangle 28,44 36,48" \
        "$output_dir/base.png"
    
    # Generate 10 frames of hologram
    for i in {0..9}; do
        cp "$output_dir/base.png" "$output_dir/frame_${i}.png"
        
        # Calculate pulse effect based on frame
        local alpha
        if [ $i -lt 5 ]; then
            alpha=$((40 + i * 10))
        else
            alpha=$((90 - (i - 5) * 10))
        fi
        
        # Draw hologram with pulsing effect
        local size_factor=$((10 + i % 3))
        
        convert "$output_dir/frame_${i}.png" \
            -fill "rgba(0,255,255,${alpha})" -draw "ellipse 32,$((44 - i % 4)) $((20 + size_factor)),10 0,360" \
            -fill "rgba(0,200,255,${alpha})" -draw "ellipse 32,30 15,8 0,360" \
            -fill "rgba(100,200,255,${alpha})" -draw "ellipse 32,20 10,5 0,360" \
            -fill "rgba(80,150,255,${alpha})" -draw "line 32,44 32,8" \
            "$output_dir/frame_${i}.png"
        
        # Add some random data points
        for j in {1..6}; do
            local x=$((24 + (i * 3 + j * 2) % 16))
            local y=$((15 + (i + j * 4) % 20))
            
            convert "$output_dir/frame_${i}.png" \
                -fill "rgba(150,255,255,${alpha})" -draw "circle ${x},${y} $((x+1)),$((y+1))" \
                "$output_dir/frame_${i}.png"
        done
    done
    
    # Create animated .gif
    convert -delay 15 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/hologram_display.gd" << EOL
# Hologram Display Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.15
var is_active = true

func _ready():
    # Load all animation frames
    for i in range(10):
        var texture = load("res://assets/backgrounds/animated_elements/hologram_display_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    if is_active:
        animation_timer += delta
        if animation_timer >= frame_delay:
            animation_timer -= frame_delay
            current_frame = (current_frame + 1) % frames.size()
            texture = frames[current_frame]

# Call to turn off the hologram
func turn_off():
    is_active = false
    texture = load("res://assets/backgrounds/animated_elements/hologram_display_${id}/base.png")

# Call to turn on the hologram
func turn_on():
    is_active = true
EOL
    
    echo "Created hologram display animation at $output_dir"
}

# Function to generate a security camera
generate_security_camera() {
    local id=$1
    local output_dir="src/assets/backgrounds/animated_elements/security_camera_${id}"
    
    mkdir -p "$output_dir"
    
    echo "Generating security camera animation frames..."
    
    # Generate 12 frames of panning camera
    for i in {0..11}; do
        # Set camera angle based on frame
        local angle
        if [ $i -lt 6 ]; then
            # Camera panning left to right (0-5)
            angle=$((i * 10))
        else
            # Camera panning right to left (6-11)
            angle=$(((11 - i) * 10))
        fi
        
        # Camera mount
        convert -size 32x32 canvas:transparent \
            -fill "#333333" -draw "rectangle 12,22 20,32" \
            "$output_dir/frame_${i}.png"
        
        # Camera body at the current angle
        local cam_x=$(( 16 + 5 * $(bc -l <<< "scale=0; c=${angle}; x=10*c(${angle}*0.0174533); scale=0; x/1") / 10 ))
        local cam_y=$(( 20 - 3 * $(bc -l <<< "scale=0; s=${angle}; y=10*s(${angle}*0.0174533); scale=0; y/1") / 10 ))
        
        convert "$output_dir/frame_${i}.png" \
            -fill "#444444" -draw "rectangle $((cam_x-6)),$((cam_y-3)) $((cam_x+6)),$((cam_y+3))" \
            "$output_dir/frame_${i}.png"
        
        # Camera lens
        convert "$output_dir/frame_${i}.png" \
            -fill "#000000" -draw "circle $((cam_x+4)),$((cam_y)) $((cam_x+4)),$((cam_y+2))" \
            "$output_dir/frame_${i}.png"
        
        # Status LED
        convert "$output_dir/frame_${i}.png" \
            -fill "#FF0000" -draw "circle $((cam_x-4)),$((cam_y-2)) $((cam_x-4)),$((cam_y-1))" \
            "$output_dir/frame_${i}.png"
    done
    
    # Create animated .gif
    convert -delay 20 -loop 0 "$output_dir/frame_"*.png "$output_dir/animation.gif"
    
    # Create GDScript implementation
    cat > "$output_dir/security_camera.gd" << EOL
# Security Camera Animated Element
extends Sprite

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.2
var is_active = true
var direction = 1  # 1 = normal patrol, -1 = reverse, 0 = fixed position
var fixed_position = 0

func _ready():
    # Load all animation frames
    for i in range(12):
        var texture = load("res://assets/backgrounds/animated_elements/security_camera_${id}/frame_%d.png" % i)
        if texture:
            frames.append(texture)
    
    if frames.size() > 0:
        texture = frames[0]

func _process(delta):
    if is_active and direction != 0:
        animation_timer += delta
        if animation_timer >= frame_delay:
            animation_timer -= frame_delay
            
            current_frame = current_frame + direction
            
            # Handle wrapping around the frame sequence
            if current_frame >= frames.size():
                current_frame = 0
            elif current_frame < 0:
                current_frame = frames.size() - 1
            
            texture = frames[current_frame]
    elif direction == 0 and is_active:
        # Fixed position
        current_frame = fixed_position
        texture = frames[current_frame]

# Call to disable the camera
func disable():
    is_active = false

# Call to enable the camera
func enable():
    is_active = true

# Call to set a fixed position
func set_fixed_position(position):
    fixed_position = clamp(position, 0, frames.size() - 1)
    direction = 0
    current_frame = fixed_position
    texture = frames[current_frame]

# Call to resume patrol
func resume_patrol():
    direction = 1
EOL
    
    echo "Created security camera animation at $output_dir"
}

# Function to generate all animation types
generate_all() {
    echo "Generating all animated background elements..."
    
    # Computer terminals
    generate_computer_terminal "shipping_main"
    generate_computer_terminal "security_desk"
    generate_computer_terminal "barracks_console"
    
    # Steam vents
    generate_steam_vent "engineering"
    generate_steam_vent "maintenance"
    
    # Warning lights
    generate_warning_light "security"
    generate_warning_light "airlock"
    
    # Sliding doors
    generate_sliding_door "standard"
    generate_sliding_door "security"
    
    # Water puddles
    generate_water_puddle "maintenance"
    generate_water_puddle "engineering"
    
    # Flickering lights
    generate_flickering_light "hallway"
    generate_flickering_light "maintenance"
    
    # Conveyor belts
    generate_conveyor_belt "shipping"
    generate_conveyor_belt "cargo"
    
    # Ventilation fans
    generate_ventilation_fan "standard"
    generate_ventilation_fan "large"
    
    # Hologram displays
    generate_hologram_display "info_kiosk"
    generate_hologram_display "security_scan"
    
    # Security cameras
    generate_security_camera "hallway"
    generate_security_camera "security_office"
    
    echo "All animated background elements generated successfully!"
}

# Function to generate a composite scene implementation class
generate_animated_background_manager() {
    local output_file="src/core/background/animated_background_manager.gd"
    mkdir -p "$(dirname "$output_file")"
    
    echo "Generating animated background manager class..."
    
    cat > "$output_file" << EOL
# Animated Background Manager
# Handles loading and controlling animated elements in backgrounds
extends Node2D

# Dictionary of loaded animated elements
var animated_elements = {}

# Called when the node enters the scene tree
func _ready():
    pass

# Add an animated element to the scene
func add_element(type, id, position):
    var element_path = "res://assets/backgrounds/animated_elements/%s_%s/%s.gd" % [type, id, type]
    var element_script = load(element_path)
    
    if element_script:
        var element = Sprite.new()
        element.set_script(element_script)
        element.position = position
        add_child(element)
        
        # Store reference for later access
        var element_key = "%s_%s" % [type, id]
        animated_elements[element_key] = element
        
        return element
    else:
        print("Error: Could not load animated element: %s" % element_path)
        return null

# Get an element by its type and ID
func get_element(type, id):
    var element_key = "%s_%s" % [type, id]
    if animated_elements.has(element_key):
        return animated_elements[element_key]
    return null

# Add multiple elements from a configuration dictionary
func add_elements_from_config(config):
    for element_config in config:
        if element_config.has("type") and element_config.has("id") and element_config.has("position"):
            var element = add_element(
                element_config.type, 
                element_config.id, 
                Vector2(element_config.position.x, element_config.position.y)
            )
            
            # Apply any additional properties
            if element and element_config.has("properties"):
                for property_name in element_config.properties:
                    var property_value = element_config.properties[property_name]
                    if property_name in element:
                        element[property_name] = property_value
EOL
    
    echo "Generated animated background manager at $output_file"
}

# Main function to handle commands
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    command=$1
    shift

    case "$command" in
        list)
            echo "Available animated element types:"
            echo "  - computer_terminal   (Blinking computer screen)"
            echo "  - steam_vent          (Periodically releasing steam)"
            echo "  - warning_light       (Blinking warning light)"
            echo "  - sliding_door        (Door that can open/close)"
            echo "  - water_puddle        (Shimmering water puddle)"
            echo "  - flickering_light    (Light with random flicker effect)"
            echo "  - conveyor_belt       (Moving conveyor belt)"
            echo "  - ventilation_fan     (Spinning ventilation fan)"
            echo "  - hologram_display    (Glowing holographic projector)"
            echo "  - security_camera     (Moving security camera)"
            ;;
        generate)
            if [ $# -lt 2 ]; then
                echo "Error: Missing parameters. Usage: $0 generate <type> <id>"
                exit 1
            fi
            
            element_type=$1
            element_id=$2
            
            case "$element_type" in
                computer_terminal)
                    generate_computer_terminal "$element_id"
                    ;;
                steam_vent)
                    generate_steam_vent "$element_id"
                    ;;
                warning_light)
                    generate_warning_light "$element_id"
                    ;;
                sliding_door)
                    generate_sliding_door "$element_id"
                    ;;
                water_puddle)
                    generate_water_puddle "$element_id"
                    ;;
                flickering_light)
                    generate_flickering_light "$element_id"
                    ;;
                conveyor_belt)
                    generate_conveyor_belt "$element_id"
                    ;;
                ventilation_fan)
                    generate_ventilation_fan "$element_id"
                    ;;
                hologram_display)
                    generate_hologram_display "$element_id"
                    ;;
                security_camera)
                    generate_security_camera "$element_id"
                    ;;
                *)
                    echo "Error: Unknown element type: $element_type"
                    echo "Use 'list' command to see available types"
                    exit 1
                    ;;
            esac
            ;;
        generate-all)
            generate_all
            generate_animated_background_manager
            ;;
        *)
            echo "Error: Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"