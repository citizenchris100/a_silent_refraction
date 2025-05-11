extends Node2D

# Basic animation test with detailed debugging

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.25

func _ready():
    print("Test animation starting")
    
    # Create a simple CanvasItem to display the frames
    var sprite = Sprite.new()
    sprite.position = Vector2(400, 300)
    add_child(sprite)
    
    # Try loading with different path formats for debugging
    var paths_to_try = [
        "res://src/assets/backgrounds/animated_elements/computer_terminal_shipping_main/frame_0.png",
        "res://assets/backgrounds/animated_elements/computer_terminal_shipping_main/frame_0.png",
        "res://src/assets/backgrounds/shipping/main_floor_base.png",
        "res://assets/backgrounds/shipping/main_floor_base.png",
        "res://src/assets/backgrounds/shipping_district_bg.png",
        "res://src/assets/backgrounds/debug/debug018.png"
    ]
    
    # Try each path to see which ones work
    for path in paths_to_try:
        var test_texture = load(path)
        if test_texture:
            print("SUCCESS: Path works: " + path)
            frames.append(test_texture)
            # If we found a working path, set the sprite texture to it
            sprite.texture = test_texture
        else:
            print("FAIL: Path doesn't work: " + path)
    
    # Print project details
    print("Project path: " + ProjectSettings.globalize_path("res://"))
    
    # List some directories to see if they exist
    list_dir("res://")
    list_dir("res://src/")
    list_dir("res://assets/")
    list_dir("res://src/assets/")
    
    print("Test animation setup complete")

# Helper function to list directory contents for debugging
func list_dir(path):
    var dir = Directory.new()
    if dir.open(path) == OK:
        print("Contents of " + path + ":")
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        while file_name != "":
            print("  " + file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
    else:
        print("Could not open directory: " + path)