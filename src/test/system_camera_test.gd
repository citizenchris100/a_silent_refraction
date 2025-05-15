extends "res://src/core/districts/base_district.gd"

# A test scene that uses our improved camera system
export var background_path = "res://src/assets/backgrounds/test_background.png"

func _ready():
    # Set up district properties for scrolling camera
    district_name = "System Camera Test District"
    use_scrolling_camera = true  # Use our improved scrolling camera system
    initial_camera_view = "right"  # Important: Show the right side of the background
    # Camera properties will be set when it's created
    
    # Set up the background - our camera system will handle scaling and positioning
    var background = Sprite.new()
    background.name = "Background"
    background.texture = load(background_path)
    background.centered = false
    add_child(background)
    
    # Record original background size for reference
    var bg_width = background.texture.get_size().x
    var bg_height = background.texture.get_size().y
    print("Original background size: " + str(Vector2(bg_width, bg_height)))
    
    # Most district scenes would have a background_size property
    # Let's add it if it doesn't exist in this extended class
    if not "background_size" in self:
        self.set("background_size", Vector2(bg_width, bg_height))
    else:
        background_size = Vector2(bg_width, bg_height)
    print("Setting district background_size to: " + str(Vector2(bg_width, bg_height)))
    
    # Create a walkable area covering the full width of the background for testing
    var walkable = Polygon2D.new()
    walkable.name = "WalkableArea"
    walkable.color = Color(0, 1, 0, 0.1)  # Very transparent green
    
    # Define a walkable area spanning the entire width
    var floor_y = bg_height * 0.8  # Position near the bottom for the floor
    
    var points = PoolVector2Array([
        Vector2(0, floor_y - 10),                # Top-left (left edge)
        Vector2(bg_width, floor_y - 10),         # Top-right (right edge)
        Vector2(bg_width, floor_y + 10),         # Bottom-right
        Vector2(0, floor_y + 10)                 # Bottom-left
    ])
    walkable.polygon = points
    walkable.add_to_group("walkable_area")
    add_child(walkable)
    walkable_areas.append(walkable)
    
    print("Created full-width walkable area at y: " + str(floor_y))
    
    # Call parent _ready to set up district and camera
    ._ready()
    
    # Add some basic UI
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    canvas_layer.layer = 100
    add_child(canvas_layer)
    
    var label = Label.new()
    label.name = "InfoLabel"
    label.rect_position = Vector2(10, 10)
    label.text = "System Camera Test\nPress ESC to exit"
    label.add_color_override("font_color", Color(1, 1, 0))
    
    var bg = ColorRect.new()
    bg.name = "LabelBackground"
    bg.color = Color(0, 0, 0, 0.5)
    bg.rect_position = Vector2(5, 5)
    bg.rect_size = Vector2(200, 60)
    
    canvas_layer.add_child(bg)
    canvas_layer.add_child(label)
    
    # Setup input handling
    set_process_input(true)
    set_process(true)
    
    print("System camera test initialized")

func _process(delta):
    # Update display
    var label = get_node_or_null("UI/InfoLabel")
    if label and camera:
        var background_node = get_node_or_null("Background")
        var scale_info = ""
        if background_node:
            scale_info = "\nBackground Scale: " + str(background_node.scale)
            
        label.text = "Camera: " + str(camera.global_position) + "\n"
        label.text += "Zoom: " + str(camera.zoom) + scale_info + "\n"
        label.text += "Press ESC to exit"
        
        # Adjust background size for text
        var bg = get_node_or_null("UI/LabelBackground")
        if bg:
            bg.rect_size = Vector2(label.rect_size.x + 20, label.rect_size.y + 10)

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
        get_tree().quit()