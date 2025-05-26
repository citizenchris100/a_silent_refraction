# Main Menu/Start Game/Load Game UI Design

## Overview

The Main Menu system provides a minimalist entry point into A Silent Refraction with a simple title screen offering only Start Game or Load Game options. The system handles save file checking, gender selection, and the opening prologue sequence with scrolling text. The design emphasizes simplicity and atmosphere while managing the single-slot save system.

## Core Concepts

### Menu Philosophy
- **Minimal choices**: Only Start Game / Load Game on title screen
- **Clear save warning**: Explicit prompt when overwriting existing save
- **Seamless flow**: Direct path from title to gameplay
- **Atmospheric prologue**: Scrolling text sets the tone
- **No save UI**: Single slot means no selection needed

### Flow Structure
1. **Launch** → Title Screen (Start Game / Load Game)
2. **Start Game** → Check Save → [Warning if exists] → Gender Selection → Prologue → Game Start
3. **Load Game** → Direct Load → Resume at Last Location

## System Architecture

### Core Components

#### 1. Title Screen Manager
```gdscript
# src/ui/title_screen/title_screen_manager.gd
extends Control

signal start_game_selected()
signal load_game_selected()
signal quit_to_desktop()

# UI References
onready var title_label = $TitleContainer/TitleLabel
onready var start_button = $ButtonContainer/StartGameButton
onready var load_button = $ButtonContainer/LoadGameButton
onready var version_label = $VersionLabel

# State
var save_exists: bool = false
var transitioning: bool = false

func _ready():
    # Check save status
    _check_save_availability()
    
    # Set title
    title_label.text = "A SILENT REFRACTION"
    version_label.text = "v" + ProjectSettings.get_setting("application/config/version")
    
    # Connect buttons
    start_button.connect("pressed", self, "_on_start_game_pressed")
    load_button.connect("pressed", self, "_on_load_game_pressed")
    
    # Apply visual style
    _apply_title_screen_aesthetics()
    
    # Start ambient atmosphere
    _initialize_title_atmosphere()

func _check_save_availability():
    save_exists = SaveManager.has_save_file()
    
    # Update load button availability
    load_button.disabled = not save_exists
    
    if not save_exists:
        load_button.modulate = Color(0.5, 0.5, 0.5)  # Grayed out
        load_button.text = "Load Game (No Save)"
    else:
        load_button.modulate = Color.white
        load_button.text = "Load Game"

func _on_start_game_pressed():
    if transitioning:
        return
    
    transitioning = true
    
    if save_exists:
        # Show overwrite warning
        _show_save_overwrite_warning()
    else:
        # Proceed directly to gender selection
        _proceed_to_gender_selection()

func _show_save_overwrite_warning():
    # Create simple warning dialog
    var warning_dialog = ConfirmationDialog.new()
    warning_dialog.dialog_text = "Starting a new game will permanently delete your existing save.\n\nAre you sure you want to continue?"
    warning_dialog.get_ok().text = "Yes, Start New Game"
    warning_dialog.get_cancel().text = "No, Return to Menu"
    
    warning_dialog.connect("confirmed", self, "_on_overwrite_confirmed")
    warning_dialog.connect("custom_action", self, "_on_overwrite_cancelled")
    warning_dialog.connect("popup_hide", self, "_on_overwrite_cancelled")
    
    add_child(warning_dialog)
    warning_dialog.popup_centered(Vector2(400, 200))

func _on_overwrite_confirmed():
    # Delete existing save
    SaveManager.delete_save()
    
    # Proceed to gender selection
    _proceed_to_gender_selection()

func _on_overwrite_cancelled():
    transitioning = false

func _proceed_to_gender_selection():
    # Fade out title screen
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback(self, "_load_gender_selection")

func _load_gender_selection():
    get_tree().change_scene("res://src/ui/character_selection/gender_selection.tscn")

func _on_load_game_pressed():
    if transitioning or not save_exists:
        return
    
    transitioning = true
    
    # No UI needed - just load directly
    _load_saved_game()

func _load_saved_game():
    # Show simple loading indicator
    var loading_overlay = ColorRect.new()
    loading_overlay.color = Color.black
    loading_overlay.modulate.a = 0.0
    loading_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    loading_overlay.anchor_right = 1.0
    loading_overlay.anchor_bottom = 1.0
    add_child(loading_overlay)
    
    var loading_text = Label.new()
    loading_text.text = "Loading..."
    loading_text.add_color_override("font_color", Color.white)
    loading_text.anchor_left = 0.5
    loading_text.anchor_top = 0.5
    loading_text.anchor_right = 0.5
    loading_text.anchor_bottom = 0.5
    loading_text.margin_left = -50
    loading_text.margin_top = -10
    loading_text.margin_right = 50
    loading_text.margin_bottom = 10
    loading_overlay.add_child(loading_text)
    
    # Fade in loading overlay
    var tween = create_tween()
    tween.tween_property(loading_overlay, "modulate:a", 1.0, 0.3)
    tween.tween_callback(self, "_perform_load")

func _perform_load():
    # Load save and jump directly to game
    if SaveManager.load_game():
        get_tree().change_scene("res://src/core/main.tscn")
    else:
        # Load failed
        _show_load_error()
```

#### 2. Gender Selection Implementation
```gdscript
# src/ui/character_selection/gender_selection_screen.gd
extends Control

signal gender_selected(gender)

enum Gender { MALE, FEMALE }

# UI References
onready var male_option = $GenderContainer/MaleOption
onready var female_option = $GenderContainer/FemaleOption
onready var select_button = $SelectButton

# State
var selected_gender: int = -1
var transitioning: bool = false

func _ready():
    # Set up options
    _setup_gender_options()
    
    # Initially no selection
    select_button.disabled = true
    
    # Connect interactions
    male_option.connect("pressed", self, "_on_gender_selected", [Gender.MALE])
    female_option.connect("pressed", self, "_on_gender_selected", [Gender.FEMALE])
    select_button.connect("pressed", self, "_on_selection_confirmed")

func _setup_gender_options():
    # Simple text or basic portraits
    male_option.text = "Play as Alex (Male)"
    female_option.text = "Play as Alex (Female)"
    
    # Style buttons
    for option in [male_option, female_option]:
        option.toggle_mode = true  # Radio button behavior

func _on_gender_selected(gender: int):
    selected_gender = gender
    
    # Update visual selection
    if gender == Gender.MALE:
        male_option.pressed = true
        female_option.pressed = false
    else:
        female_option.pressed = true
        male_option.pressed = false
    
    # Enable confirmation
    select_button.disabled = false

func _on_selection_confirmed():
    if transitioning or selected_gender == -1:
        return
    
    transitioning = true
    
    # Store selection
    GameData.player_gender = selected_gender
    
    # Proceed to prologue
    _start_prologue_sequence()

func _start_prologue_sequence():
    # Fade to black
    var fade_overlay = ColorRect.new()
    fade_overlay.color = Color.black
    fade_overlay.modulate.a = 0.0
    fade_overlay.anchor_right = 1.0
    fade_overlay.anchor_bottom = 1.0
    add_child(fade_overlay)
    
    var tween = create_tween()
    tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
    tween.tween_callback(self, "_load_prologue")

func _load_prologue():
    get_tree().change_scene("res://src/ui/prologue/prologue_screen.tscn")
```

#### 3. Prologue Scrolling Text System
```gdscript
# src/ui/prologue/prologue_screen.gd
extends Control

signal prologue_complete()

# Configuration
const SCROLL_SPEED = 30.0  # Pixels per second
const LINE_HEIGHT = 24
const FADE_DISTANCE = 100  # Distance from top where text fades

# UI References
onready var text_container = $ScrollContainer/TextContainer
onready var skip_label = $SkipLabel

# Prologue content
var prologue_text = [
    "The year is 2157.",
    "",
    "Humanity has expanded beyond Earth,",
    "establishing trade stations at the edges of known space.",
    "",
    "You are Alex, a courier for Aether Corp,",
    "tasked with a simple delivery to Station Omega-7.",
    "",
    "The package contains what you're told",
    "are 'biological research samples.'",
    "",
    "You don't ask questions.",
    "You just deliver.",
    "",
    "But this time, the questions will find you.",
    "",
    "This time, the delivery will change everything.",
    "",
    "This time...",
    "",
    "The silence will be broken."
]

# State
var scroll_position: float = 0.0
var can_skip: bool = false
var skip_timer: float = 0.0
var completed: bool = false

func _ready():
    # Set up text
    _create_scrolling_text()
    
    # Hide skip initially
    skip_label.modulate.a = 0.0
    skip_label.text = "Press SPACE to skip"
    
    # Start scrolling
    set_process(true)

func _create_scrolling_text():
    # Create labels for each line
    var y_position = get_viewport_rect().size.y + 100  # Start below screen
    
    for line in prologue_text:
        var label = Label.new()
        label.text = line
        label.add_font_override("font", preload("res://assets/fonts/prologue_font.tres"))
        label.modulate = Color(0.8, 0.8, 1.0)  # Slight blue tint like Blade Runner
        label.align = Label.ALIGN_CENTER
        label.rect_position.y = y_position
        label.rect_size.x = get_viewport_rect().size.x
        
        text_container.add_child(label)
        y_position += LINE_HEIGHT

func _process(delta):
    if completed:
        return
    
    # Scroll text upward
    scroll_position += SCROLL_SPEED * delta
    
    # Update all labels
    var viewport_height = get_viewport_rect().size.y
    var all_above_screen = true
    
    for child in text_container.get_children():
        if not child is Label:
            continue
        
        var label = child as Label
        var y_pos = label.rect_position.y - scroll_position
        
        # Apply position
        label.rect_position.y = y_pos
        
        # Apply fade based on distance from top
        if y_pos < FADE_DISTANCE:
            label.modulate.a = max(0.0, y_pos / FADE_DISTANCE) * 0.8
        else:
            label.modulate.a = 0.8
        
        # Check if any text still visible
        if y_pos > -LINE_HEIGHT:
            all_above_screen = false
    
    # Show skip option after 2 seconds
    skip_timer += delta
    if skip_timer > 2.0 and not can_skip:
        can_skip = true
        var tween = create_tween()
        tween.tween_property(skip_label, "modulate:a", 1.0, 0.5)
    
    # Check for completion
    if all_above_screen and not completed:
        _complete_prologue()

func _input(event):
    if event.is_action_pressed("ui_select") and can_skip and not completed:
        _complete_prologue()

func _complete_prologue():
    completed = true
    set_process(false)
    
    # Fade to black
    var fade_overlay = ColorRect.new()
    fade_overlay.color = Color.black
    fade_overlay.modulate.a = 0.0
    fade_overlay.anchor_right = 1.0
    fade_overlay.anchor_bottom = 1.0
    add_child(fade_overlay)
    
    var tween = create_tween()
    tween.tween_property(fade_overlay, "modulate:a", 1.0, 2.0)
    tween.tween_callback(self, "_start_game")

func _start_game():
    # Initialize game systems
    _initialize_new_game()
    
    # Load main game scene
    get_tree().change_scene("res://src/core/main.tscn")

func _initialize_new_game():
    # Set initial game state
    GameData.new_game = true
    
    # Initialize time
    TimeManager.initialize()
    TimeManager.set_time(8, 0)  # 8:00 AM
    TimeManager.current_day = 1
    
    # Set player starting position
    PlayerData.current_district = "spaceport"
    PlayerData.current_location = "docked_ship_1"
    
    # Initial items
    InventoryManager.add_item("courier_bag", 1)
    InventoryManager.add_item("delivery_manifest", 1)
    InventoryManager.add_item("mysterious_package", 1)
    
    # Starting credits
    EconomyManager.player_credits = 100
    
    # Initialize assimilation (patient zero already turned)
    AssimilationManager.initialize()
    AssimilationManager.assimilate_npc("patient_zero", "leader")
    
    # Create initial save
    SaveManager.save_game()
```

### Integration Systems

#### Save System Integration
```gdscript
# Minimal save handling - no UI needed
class SaveIntegration:
    static func handle_load_game():
        # Direct load with no selection UI
        var result = SaveManager.load_game()
        
        if result.success:
            # Jump straight to game
            SceneManager.load_scene("main")
        else:
            # Show error and return to title
            show_error("Failed to load save: " + result.error)
            return_to_title()
    
    static func handle_new_game_with_save():
        # Simple confirmation dialog
        var dialog = preload("res://src/ui/dialogs/confirm_overwrite.tscn").instance()
        dialog.message = "Starting a new game will permanently delete your save."
        dialog.connect("confirmed", self, "delete_and_start")
        dialog.connect("cancelled", self, "return_to_title")
        
    static func delete_and_start():
        SaveManager.delete_save()
        proceed_to_gender_selection()
```

## UI Components

### Title Screen Layout
```gdscript
# Minimalist design
func _setup_title_layout():
    # Center everything
    var center_container = CenterContainer.new()
    center_container.anchor_right = 1.0
    center_container.anchor_bottom = 1.0
    
    var vbox = VBoxContainer.new()
    vbox.add_constant_override("separation", 50)
    
    # Title
    var title = Label.new()
    title.text = "A SILENT REFRACTION"
    title.add_font_override("font", title_font)
    title.modulate = Color(0.8, 0.8, 1.0)
    vbox.add_child(title)
    
    # Buttons
    var button_container = VBoxContainer.new()
    button_container.add_constant_override("separation", 20)
    
    # Start Game button
    var start_btn = Button.new()
    start_btn.text = "Start Game"
    start_btn.rect_min_size = Vector2(200, 40)
    button_container.add_child(start_btn)
    
    # Load Game button  
    var load_btn = Button.new()
    load_btn.text = "Load Game"
    load_btn.rect_min_size = Vector2(200, 40)
    button_container.add_child(load_btn)
    
    vbox.add_child(button_container)
    center_container.add_child(vbox)
```

### Atmospheric Effects
```gdscript
# Simple atmosphere for title screen
func _apply_title_atmosphere():
    # CRT shader effect
    var crt_shader = preload("res://shaders/crt_effect.shader")
    var shader_material = ShaderMaterial.new()
    shader_material.shader = crt_shader
    material = shader_material
    
    # Subtle ambient sound
    AudioManager.play_ambient("station_distant_hum.ogg", -20)  # Quiet
    
    # Optional: Slow fade-in on start
    modulate.a = 0.0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 2.0)
```

## Flow Diagrams

### Start Game Flow
```
Title Screen
    ↓
[Start Game Pressed]
    ↓
Check for Save File
    ↓
    ├─[Save Exists]─→ Show Warning Dialog
    │                      ↓
    │                 [Cancel]→ Return to Title
    │                      ↓
    │                 [Confirm]→ Delete Save
    │                      ↓
    └─[No Save]──────────→ Gender Selection
                               ↓
                          [Select Gender]
                               ↓
                          Prologue Text
                               ↓
                          Initialize Game
                               ↓
                          Start Game
```

### Load Game Flow
```
Title Screen
    ↓
[Load Game Pressed]
    ↓
Load Save File
    ↓
    ├─[Success]→ Start Game at Saved Position
    │
    └─[Failed]→ Show Error → Return to Title
```

## Testing Considerations

1. **Save Detection**
   - Correctly identifies save existence
   - Warning dialog appears when needed
   - Load button properly disabled

2. **Flow Testing**
   - All paths work correctly
   - No way to accidentally delete save
   - Gender selection required for new game

3. **Prologue System**
   - Text scrolls smoothly
   - Skip function works after delay
   - Properly transitions to game

4. **Error Handling**
   - Corrupted save handled gracefully
   - Missing files don't crash
   - Clear error messages

This streamlined system provides exactly what's needed: a simple entry point with clear save handling, gender selection, and an atmospheric prologue that sets the tone before gameplay begins.