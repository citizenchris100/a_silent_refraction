#!/bin/bash

# implement_canonical_framework.sh
# This script implements the canonical framework for A Silent Refraction

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}A Silent Refraction - Canonical Framework Implementation${NC}"
echo ""

# Create directories if they don't exist
mkdir -p src/characters/npc
mkdir -p src/core/dialog
mkdir -p src/core/game
mkdir -p src/test
mkdir -p src/ui/dialog

# Step 1: Create canonical base_npc.gd
echo -e "${GREEN}Creating canonical base_npc.gd...${NC}"
cat > src/characters/npc/base_npc.gd << 'EOL'
extends Node2D
class_name BaseNPC

# NPC Properties
export var npc_name = "Unknown NPC"
export var description = "An unknown person"
export var is_assimilated = false

# Visual components
var visual_sprite
var label

# State Machine
enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}
var current_state = State.IDLE

# Suspicion System
var suspicion_level = 0.0  # 0.0 to 1.0
var suspicion_threshold = 0.8

# Dialog System
var dialog_tree = {}
var current_dialog_node = "root"

# Signals
signal state_changed(old_state, new_state)
signal suspicion_changed(old_level, new_level)
signal dialog_started(npc)
signal dialog_ended(npc)

func _ready():
    # Add to groups
    add_to_group("npc")
    add_to_group("interactive_object")
    
    # Setup visual representation
    _setup_visual()
    
    # Initialize dialog tree
    initialize_dialog()
    
    # Initialize state machine
    _change_state(State.IDLE)
    
    # Enable input processing
    set_process_input(true)

# Input handling for direct NPC interaction
func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        if _is_point_in_clickable_area(event.position):
            var game_manager = _find_game_manager()
            if game_manager:
                game_manager.handle_npc_click(self)

# Check if a point is within the NPC's clickable area
func _is_point_in_clickable_area(point):
    if visual_sprite and visual_sprite is Control:
        var rect_global_pos = visual_sprite.rect_position + global_position
        var rect_size = visual_sprite.rect_size
        return Rect2(rect_global_pos, rect_size).has_point(point)
    return false

# Set up visual representation
func _setup_visual():
    # Create visual sprite if not present
    if has_node("Visual"):
        visual_sprite = get_node("Visual")
    else:
        visual_sprite = ColorRect.new()
        visual_sprite.name = "Visual"
        visual_sprite.rect_size = Vector2(32, 48)
        visual_sprite.rect_position = Vector2(-16, -48)
        visual_sprite.color = Color(0.7, 0.7, 0.7)  # Default gray
        add_child(visual_sprite)
    
    # Create label if not present
    if has_node("Label"):
        label = get_node("Label")
    else:
        label = Label.new()
        label.name = "Label"
        label.text = npc_name
        label.rect_position = Vector2(-40, -60)
        add_child(label)
        
    # Create clickable area if not present
    if not has_node("ClickableArea"):
        var area = Area2D.new()
        area.name = "ClickableArea"
        
        var collision = CollisionShape2D.new()
        collision.name = "CollisionShape"
        
        var shape = RectangleShape2D.new()
        shape.extents = Vector2(16, 24)  # Half of visual size
        
        collision.shape = shape
        collision.position = Vector2(0, -24)
        
        area.add_child(collision)
        area.connect("input_event", self, "_on_ClickableArea_input_event")
        
        add_child(area)

# Input event handler for clickable area
func _on_ClickableArea_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        var game_manager = _find_game_manager()
        if game_manager:
            game_manager.handle_npc_click(self)

# Find game manager in scene tree
func _find_game_manager():
    var root = get_tree().get_root()
    for child in root.get_children():
        if child.has_method("handle_npc_click"):
            return child
        
        # Try checking children too
        for grandchild in child.get_children():
            if grandchild.has_method("handle_npc_click"):
                return grandchild
    
    return null

# Handle state changes
func _change_state(new_state):
    var old_state = current_state
    current_state = new_state
    
    # Handle exit from previous state
    match old_state:
        State.TALKING:
            _on_exit_talking_state()
    
    # Handle entry to new state
    match new_state:
        State.IDLE:
            _on_enter_idle_state()
        State.INTERACTING:
            _on_enter_interacting_state()
        State.TALKING:
            _on_enter_talking_state()
        State.SUSPICIOUS:
            _on_enter_suspicious_state()
        State.HOSTILE:
            _on_enter_hostile_state()
        State.FOLLOWING:
            _on_enter_following_state()
    
    emit_signal("state_changed", old_state, new_state)

# State entry handlers
func _on_enter_idle_state():
    pass

func _on_enter_interacting_state():
    pass

func _on_enter_talking_state():
    start_dialog()

func _on_enter_suspicious_state():
    become_suspicious()

func _on_enter_hostile_state():
    pass

func _on_enter_following_state():
    pass

# State exit handlers
func _on_exit_talking_state():
    end_dialog()

# Process function based on current state
func _process(delta):
    match current_state:
        State.IDLE:
            _process_idle_state(delta)
        State.INTERACTING:
            _process_interacting_state(delta)
        State.TALKING:
            _process_talking_state(delta)
        State.SUSPICIOUS:
            _process_suspicious_state(delta)
        State.HOSTILE:
            _process_hostile_state(delta)
        State.FOLLOWING:
            _process_following_state(delta)

# State processing functions
func _process_idle_state(delta):
    pass

func _process_interacting_state(delta):
    pass

func _process_talking_state(delta):
    pass

func _process_suspicious_state(delta):
    pass

func _process_hostile_state(delta):
    pass

func _process_following_state(delta):
    pass

# Initialize dialog tree - should be overridden by child classes
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

# Handle interactions with this NPC
func interact(verb, item = null):
    # Switch to interacting state if not already talking
    if current_state != State.TALKING:
        _change_state(State.INTERACTING)
    
    match verb:
        "Look at":
            return "You see " + npc_name + ". " + description
        "Talk to":
            _change_state(State.TALKING)
            return "You begin talking to " + npc_name
        "Use", "Pick up", "Push", "Pull", "Give":
            change_suspicion(0.1)
            return npc_name + " doesn't appreciate that."
        _:
            return "You can't " + verb + " " + npc_name

# Start dialog with this NPC
func start_dialog():
    current_dialog_node = "root"
    
    # Find dialog manager through game manager
    var game_manager = _find_game_manager()
    if game_manager and game_manager.has_node("DialogManager"):
        var dialog_manager = game_manager.get_node("DialogManager")
        if dialog_manager and dialog_manager.has_method("show_dialog"):
            dialog_manager.show_dialog(self)
            emit_signal("dialog_started", self)

# End dialog with this NPC
func end_dialog():
    emit_signal("dialog_ended", self)
    
    # Return to idle state if currently talking
    if current_state == State.TALKING:
        _change_state(State.IDLE)

# Get current dialog node
func get_current_dialog():
    if current_dialog_node in dialog_tree:
        return dialog_tree[current_dialog_node]
    return null

# Choose dialog option
func choose_dialog_option(option_index):
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # Apply suspicion change if specified
        if "suspicion_change" in option:
            change_suspicion(option.suspicion_change)
        
        # Move to next dialog node
        current_dialog_node = option.next
        
        # Check if dialog has ended
        if current_dialog_node == "exit" or not dialog_tree.has(current_dialog_node) or dialog_tree[current_dialog_node].options.size() == 0:
            end_dialog()
            return null
        
        return get_current_dialog()
    
    return null

# Change suspicion level
func change_suspicion(amount):
    var old_level = suspicion_level
    suspicion_level = clamp(suspicion_level + amount, 0.0, 1.0)
    
    # Check if NPC is now suspicious
    if suspicion_level >= suspicion_threshold and old_level < suspicion_threshold:
        _change_state(State.SUSPICIOUS)
    
    emit_signal("suspicion_changed", old_level, suspicion_level)

# Called when NPC becomes suspicious - override in child classes
func become_suspicious():
    # Default implementation
    print(npc_name + " has become suspicious!")

# Get assimilation status
func is_assimilated():
    return is_assimilated

# Update NPC appearance based on state
func update_appearance():
    if visual_sprite and visual_sprite is ColorRect:
        # Update color based on state
        match current_state:
            State.IDLE:
                if is_assimilated:
                    visual_sprite.color = Color(0.8, 0.2, 0.2)  # Red for assimilated
                else:
                    visual_sprite.color = Color(0.2, 0.8, 0.2)  # Green for unassimilated
            State.SUSPICIOUS:
                visual_sprite.color = Color(0.8, 0.8, 0.2)  # Yellow for suspicious
            State.HOSTILE:
                visual_sprite.color = Color(0.8, 0.2, 0.2)  # Red for hostile
            State.FOLLOWING:
                visual_sprite.color = Color(0.2, 0.2, 0.8)  # Blue for following
EOL

# Step 2: Create canonical dialog_manager.gd
echo -e "${GREEN}Creating canonical dialog_manager.gd...${NC}"
cat > src/core/dialog/dialog_manager.gd << 'EOL'
extends Node

# UI components
var dialog_panel
var dialog_text
var dialog_options
var current_npc = null

# Signals
signal dialog_started(npc)
signal dialog_ended(npc)
signal option_selected(option_index)

func _ready():
    # Create dialog UI
    _create_dialog_ui()
    
    # Connect to NPCs in the scene
    yield(get_tree(), "idle_frame")
    _connect_to_npcs()

# Create dialog UI components
func _create_dialog_ui():
    # Create canvas layer for UI
    var canvas = CanvasLayer.new()
    canvas.name = "DialogCanvas"
    canvas.layer = 10  # Make sure it's on top
    add_child(canvas)
    
    # Create dialog panel
    dialog_panel = Panel.new()
    dialog_panel.rect_position = Vector2(212, 150)
    dialog_panel.rect_size = Vector2(600, 300)
    dialog_panel.visible = false
    canvas.add_child(dialog_panel)
    
    # Create dialog text
    dialog_text = Label.new()
    dialog_text.rect_position = Vector2(20, 20)
    dialog_text.rect_size = Vector2(560, 100)
    dialog_text.autowrap = true
    dialog_panel.add_child(dialog_text)
    
    # Create dialog options container
    dialog_options = VBoxContainer.new()
    dialog_options.rect_position = Vector2(20, 130)
    dialog_options.rect_size = Vector2(560, 150)
    dialog_panel.add_child(dialog_options)

# Connect to all NPCs in the scene
func _connect_to_npcs():
    for npc in get_tree().get_nodes_in_group("npc"):
        if not npc.is_connected("dialog_started", self, "_on_dialog_started"):
            npc.connect("dialog_started", self, "_on_dialog_started")
        
        if not npc.is_connected("dialog_ended", self, "_on_dialog_ended"):
            npc.connect("dialog_ended", self, "_on_dialog_ended")

# Show dialog with an NPC
func show_dialog(npc):
    current_npc = npc
    
    # Clear previous options
    for child in dialog_options.get_children():
        child.queue_free()
    
    # Get current dialog
    var dialog = npc.get_current_dialog()
    if dialog:
        # Set dialog text
        dialog_text.text = dialog.text
        
        # Create dialog options
        for i in range(dialog.options.size()):
            var option = dialog.options[i]
            var button = Button.new()
            button.text = option.text
            button.connect("pressed", self, "_on_dialog_option_selected", [i])
            dialog_options.add_child(button)
        
        # Show dialog panel
        dialog_panel.visible = true
        emit_signal("dialog_started", npc)
    else:
        end_dialog()

# End the current dialog
func end_dialog():
    dialog_panel.visible = false
    var old_npc = current_npc
    current_npc = null
    
    if old_npc:
        emit_signal("dialog_ended", old_npc)

# Handle dialog started signal
func _on_dialog_started(npc):
    show_dialog(npc)

# Handle dialog ended signal
func _on_dialog_ended(npc):
    if current_npc == npc:
        end_dialog()

# Handle dialog option selection
func _on_dialog_option_selected(option_index):
    if current_npc:
        emit_signal("option_selected", option_index)
        var dialog = current_npc.choose_dialog_option(option_index)
        
        if dialog:
            # Update dialog
            show_dialog(current_npc)
EOL

# Step 3: Create canonical game_manager.gd
echo -e "${GREEN}Creating canonical game_manager.gd...${NC}"
cat > src/core/game/game_manager.gd << 'EOL'
extends Node

# References to UI and game systems
var verb_ui
var interaction_text
var dialog_manager
var player

# Current state
var current_verb = "Look at"
var current_object = null

func _ready():
    print("Game Manager initializing...")
    
    # Create dialog manager
    dialog_manager = load("res://src/core/dialog/dialog_manager.gd").new()
    dialog_manager.name = "DialogManager"
    add_child(dialog_manager)
    
    # Wait a frame to make sure all nodes are loaded
    yield(get_tree(), "idle_frame")
    
    # Find the verb UI and interaction text
    if get_parent().has_node("UI/VerbUI"):
        verb_ui = get_parent().get_node("UI/VerbUI")
        verb_ui.connect("verb_selected", self, "_on_verb_selected")
    else:
        print("VerbUI not found")
    
    if get_parent().has_node("UI/InteractionText"):
        interaction_text = get_parent().get_node("UI/InteractionText")
    else:
        print("InteractionText not found")
    
    # Find player
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
    else:
        print("Player not found")
    
    print("Game Manager initialized")

# Handle verb selection
func _on_verb_selected(verb):
    current_verb = verb
    if interaction_text:
        interaction_text.text = current_verb + "..."
    print("Verb selected: " + verb)

# Handle NPC clicks
func handle_npc_click(npc):
    current_object = npc
    
    # Show interaction result
    if npc.has_method("interact"):
        var response = npc.interact(current_verb)
        if interaction_text:
            interaction_text.text = response
    else:
        print("NPC doesn't have interact method!")
    
    # Move player to npc if needed
    if player and current_verb != "Look at":
        # Calculate a position near the NPC
        var direction = (player.global_position - npc.global_position).normalized()
        var target_pos = npc.global_position + direction * 50
        
        # Move the player if they have the move_to method
        if player.has_method("move_to"):
            player.move_to(target_pos)
EOL

# Step 4: Create the verb_ui.gd implementation
echo -e "${GREEN}Creating canonical verb_ui.gd...${NC}"
cat > src/ui/verb_ui/verb_ui.gd << 'EOL'
extends Control

signal verb_selected(verb)

# Available verbs
var verbs = ["Look at", "Talk to", "Use", "Pick up", "Push", "Pull", "Open", "Close", "Give"]
var current_verb = "Look at"

func _ready():
    # Create the verb buttons
    _create_verb_buttons()

func _create_verb_buttons():
    var button_size = Vector2(100, 30)
    var margin = Vector2(10, 5)
    var columns = 3
    
    for i in range(verbs.size()):
        var verb = verbs[i]
        
        # Calculate position
        var row = i / columns
        var col = i % columns
        var pos = Vector2(
            margin.x + col * (button_size.x + margin.x),
            margin.y + row * (button_size.y + margin.y)
        )
        
        # Create button
        var button = Button.new()
        button.text = verb
        button.rect_position = pos
        button.rect_min_size = button_size
        button.connect("pressed", self, "_on_verb_button_pressed", [verb])
        add_child(button)

func _on_verb_button_pressed(verb):
    current_verb = verb
    emit_signal("verb_selected", verb)
EOL

# Step 5: Create main test scene
echo -e "${GREEN}Creating main test scene (npc_system_test.gd)...${NC}"
cat > src/test/npc_system_test.gd << 'EOL'
extends Node2D

func _ready():
    print("NPC System Test - Starting up")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create UI
    _create_ui()
    
    # Create player
    _create_player()
    
    # Create NPCs
    _create_npcs()
    
    # Create game manager
    var game_manager = load("res://src/core/game/game_manager.gd").new()
    game_manager.name = "GameManager"
    add_child(game_manager)
    
    print("NPC System Test - Ready")

func _create_ui():
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Verb UI
    var verb_ui = load("res://src/ui/verb_ui/verb_ui.gd").new()
    verb_ui.name = "VerbUI"
    verb_ui.rect_position = Vector2(20, 20)
    verb_ui.rect_size = Vector2(350, 160)
    canvas_layer.add_child(verb_ui)
    
    # Create Interaction Text
    var interaction_text = Label.new()
    interaction_text.name = "InteractionText"
    interaction_text.rect_position = Vector2(10, 570)
    interaction_text.rect_size = Vector2(1000, 20)
    interaction_text.text = "Select a verb and click on an NPC."
    canvas_layer.add_child(interaction_text)

func _create_player():
    var player = Node2D.new()
    player.name = "Player"
    player.add_to_group("player")
    
    # Add a visual representation for the player
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)  # Blue for player
    player.add_child(player_visual)
    
    # Add simple movement script
    player.set_script(GDScript.new())
    player.get_script().source_code = """
extends Node2D

export var movement_speed = 200
var target_position = Vector2()
var is_moving = false

func _ready():
    target_position = position
    
func move_to(position):
    target_position = position
    is_moving = true

func _process(delta):
    if is_moving:
        var direction = target_position - position
        if direction.length() > 5:  # If not very close yet
            position += direction.normalized() * movement_speed * delta
        else:
            # Reached the target
            position = target_position
            is_moving = false
"""
    player.get_script().reload()
    
    # Set player position
    player.position = Vector2(512, 500)
    add_child(player)

func _create_npcs():
    # Create Concierge
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/base_npc.gd"))
    concierge.position = Vector2(300, 400)
    concierge.npc_name = "Concierge"
    concierge.description = "The concierge of the Barracks, dressed in a neat uniform."
    concierge.is_assimilated = false
    add_child(concierge)
    
    # Create Security Officer
    var security = Node2D.new()
    security.set_script(load("res://src/characters/npc/base_npc.gd"))
    security.position = Vector2(700, 400)
    security.npc_name = "Security Officer"
    security.description = "A stern-looking security officer in a uniform."
    security.is_assimilated = true
    add_child(security)
EOL

# Step 6: Create the scene file
echo -e "${GREEN}Creating npc_system_test.tscn scene file...${NC}"
cat > src/test/npc_system_test.tscn << 'EOL'
[gd_scene load_steps=2 format=2]

[ext_resource path="res://src/test/npc_system_test.gd" type="Script" id=1]

[node name="NPCSystemTest" type="Node2D"]
script = ExtResource( 1 )
EOL

# Step 7: Create the game management script
echo -e "${GREEN}Creating a_silent_refraction.sh management script...${NC}"
cat > a_silent_refraction.sh << 'EOL'
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
EOL

# Make scripts executable
chmod +x a_silent_refraction.sh

echo ""
echo -e "${GREEN}Implementation complete!${NC}"
echo ""
echo "The following files have been created or updated:"
echo "  - src/characters/npc/base_npc.gd"
echo "  - src/core/dialog/dialog_manager.gd"
echo "  - src/core/game/game_manager.gd"
echo "  - src/ui/verb_ui/verb_ui.gd"
echo "  - src/test/npc_system_test.gd and .tscn"
echo "  - a_silent_refraction.sh"
echo ""
echo "You can now run the NPC system test with:"
echo "  ./a_silent_refraction.sh test"
echo ""
echo "To clean up redundant files, run:"
echo "  ./a_silent_refraction.sh clean"
echo ""
echo "To create new NPCs, run:"
echo "  ./a_silent_refraction.sh new-npc <npc_name>"
echo ""
echo "To create new districts, run:"
echo "  ./a_silent_refraction.sh new-district <district_name>"
echo ""
echo "Use './a_silent_refraction.sh help' for more information."