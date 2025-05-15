extends Node2D

# A direct camera test that works without relying on complex systems
export var background_path = "res://src/assets/backgrounds/test_background.png"

var background
var camera

func _ready():
    # Set up the background
    background = Sprite.new()
    background.name = "Background"
    background.texture = load(background_path)
    background.centered = false
    add_child(background)
    
    # Store original background size
    var bg_width = background.texture.get_size().x
    var bg_height = background.texture.get_size().y
    print("Original background size: " + str(Vector2(bg_width, bg_height)))
    
    # Calculate proper scale to fill viewport height
    var viewport_size = get_viewport_rect().size
    var scale_factor = viewport_size.y / bg_height
    background.scale = Vector2(scale_factor, scale_factor)
    
    # Effective size after scaling
    var effective_width = bg_width * scale_factor
    var effective_height = bg_height * scale_factor
    print("Viewport size: " + str(viewport_size))
    print("Scale factor: " + str(scale_factor))
    print("Effective background size after scaling: " + str(Vector2(effective_width, effective_height)))
    
    # Create a simple camera
    camera = Camera2D.new()
    camera.name = "Camera"
    camera.current = true
    
    # Position camera to show the right side of the background
    # The camera position should be the right edge minus half viewport width
    var right_edge_position = effective_width - (viewport_size.x / 2)
    var center_y = effective_height / 2
    camera.position = Vector2(right_edge_position, center_y)
    add_child(camera)
    
    print("Camera positioned at: " + str(camera.position))
    print("This should show the right portion of the background")
    
    # Create walkable area for visualization
    var walkable = Polygon2D.new()
    walkable.name = "WalkableArea"
    walkable.color = Color(0, 1, 0, 0.2)
    
    # Define walkable area on the visible floor (right side)
    var floor_y = 350 * scale_factor
    var floor_height = 25 * scale_factor
    var points = PoolVector2Array([
        Vector2(effective_width * 0.7, floor_y),
        Vector2(effective_width * 0.95, floor_y),
        Vector2(effective_width * 0.95, floor_y + floor_height),
        Vector2(effective_width * 0.7, floor_y + floor_height)
    ])
    walkable.polygon = points
    add_child(walkable)
    
    # Add UI
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    canvas_layer.layer = 100
    add_child(canvas_layer)
    
    var label = Label.new()
    label.name = "InfoLabel"
    label.rect_position = Vector2(10, 10)
    label.text = "Direct Camera Test\nPress ESC to exit"
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
    
    print("Direct camera test initialized")

func _process(delta):
    # Update display
    var label = get_node_or_null("UI/InfoLabel")
    if label and camera:
        label.text = "Camera: " + str(camera.global_position) + "\n"
        label.text += "Zoom: " + str(camera.zoom) + "\n"
        label.text += "Press ESC to exit"
        
        # Adjust background size for text
        var bg = get_node_or_null("UI/LabelBackground")
        if bg:
            bg.rect_size = Vector2(label.rect_size.x + 20, label.rect_size.y + 10)

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
        get_tree().quit()