extends Node2D

# Simple test scene for debug console/tools
var camera

func _ready():
    print("==== DEBUG CONSOLE TEST SCENE ====")
    
    # Create a basic camera
    camera = Camera2D.new()
    camera.name = "DebugCamera"
    camera.current = true
    camera.position = Vector2(512, 300)
    add_child(camera)
    print("Camera added to scene")
    
    # Create debug manager and debug console
    var DebugManager = load("res://src/core/debug/debug_manager.gd")
    if DebugManager:
        print("DebugManager script loaded successfully")
        # Use the static method to add manager to scene
        var debug_manager = DebugManager.add_to_scene(self, camera)
        if debug_manager:
            print("Debug manager added to scene")
            
            # Create debug console directly (debug_manager.create_debug_console is called in _ready)
            print("Debug console should be auto-initialized")
            print("Press backtick (`) to toggle console")
        else:
            push_error("Failed to add debug manager to scene")
    else:
        push_error("Failed to load debug manager script")
    
    # Create a simple background
    var background = ColorRect.new()
    background.name = "Background"
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.2, 0.2, 0.3)
    background.rect_position = Vector2(0, 0)
    add_child(background)
    background.show_behind_parent = true
    
    # Add instructions
    var label = Label.new()
    label.name = "Instructions"
    label.text = "Debug Console Test Scene\n\nPress backtick (`) to toggle console\nPress ESC to exit"
    label.rect_position = Vector2(400, 100)
    add_child(label)
    
    # Set up input handling
    set_process_input(true)
    print("Debug console test scene initialized")

func _input(event):
    # Handle ESC to exit
    if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
        print("ESC pressed, exiting test")
        get_tree().change_scene("res://src/core/main.tscn")
    
    # Log key presses for debug
    if event is InputEventKey and event.pressed:
        print("Key pressed: " + str(event.scancode) + " (backtick is 96)")