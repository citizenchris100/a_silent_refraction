extends "res://src/core/districts/base_district.gd"

# Test scene for the scrolling camera system
export var background_texture_path = "res://src/assets/backgrounds/test_background.png"
export var background_scale = Vector2(1, 1)

# Background settings
var background_texture = null
var background_sprite = null
var background_size = Vector2(3000, 1500)  # Default size if no background is provided

func _ready():
    # Setup basic district properties
    district_name = "Camera Test District"
    district_description = "A test area for the scrolling camera system"
    use_scrolling_camera = true
    camera_follow_smoothing = 4.0
    camera_edge_margin = Vector2(150, 100)

    # Load background texture if specified
    load_background()

    # Call parent _ready() to set up the district
    ._ready()

    # Setup walkable area for testing
    setup_walkable_area()
    
    # Wait for camera to be created then configure it
    yield(get_tree(), "idle_frame")
    configure_camera()

    # Debug message
    print("Scrolling camera test district initialized")
    print("Try clicking near the edges of the screen to test camera scrolling")

    # Create a key handler for ESC to exit test
    set_process_input(true)
    
    # Enable continuous updates for debug purposes
    set_process(true)

func _process(delta):
    # Update the debug visualization
    update()

func load_background():
    # Get the sprite node
    background_sprite = get_node("Background")
    
    # If a texture path is specified, try to load it
    if background_texture_path != "":
        background_texture = load(background_texture_path)
        if background_texture:
            # Configure the sprite properly
            background_sprite.texture = background_texture
            background_sprite.centered = false  # Important: Don't center the sprite
            background_sprite.position = Vector2(0, 0)  # Position at top-left corner
            background_sprite.scale = background_scale
            
            print("Loaded custom background: " + background_texture_path)
            
            # Set background size based on texture
            background_size = background_texture.get_size() * background_scale
            print("Background size: " + str(background_size))
            
            # Debug output for troubleshooting
            print("Background position: " + str(background_sprite.position))
            print("Background centered: " + str(background_sprite.centered))
        else:
            print("Failed to load background texture from: " + background_texture_path)
            # Try to use a default texture
            load_default_background()
    else:
        # No custom texture specified, use default
        load_default_background()

func load_default_background():
    # Just create a colored rectangle background
    print("Creating default colored rectangle background")
    
    # Create a colored rectangle as background
    var rect = ColorRect.new()
    rect.name = "ColorBackground"
    rect.color = Color(0.2, 0.2, 0.3)
    rect.rect_size = background_size
    add_child(rect)
    
    # Make sure background sprite is hidden if it exists
    if background_sprite:
        background_sprite.visible = false
        
    print("Created color rectangle background of size: " + str(background_size))

# Configure camera to center on background
func configure_camera():
    if camera:
        # Initial position should be centered on the background
        var bg_center = Vector2(background_size.x / 2, background_size.y / 2)
        
        # Explicitly set camera position (try both ways)
        camera.global_position = bg_center
        camera.position = bg_center
        camera.current = true
        
        # Fix zoom to ensure camera shows the scene correctly
        camera.zoom = Vector2(1, 1)
        
        # Position player in a reasonable place
        var player = get_node_or_null("Player")
        if player:
            player.position = bg_center
        
        print("Camera positioned at center of background: " + str(bg_center))
    else:
        print("WARNING: No camera found to configure")

# Setup the walkable area based on background
func setup_walkable_area():
    # Check if we already have a walkable area
    var existing_area = get_node_or_null("WalkableArea")
    if existing_area:
        # Update the existing walkable area to match background size
        var points = PoolVector2Array([
            Vector2(0, 0),                       # Top-left
            Vector2(background_size.x, 0),       # Top-right
            Vector2(background_size.x, background_size.y), # Bottom-right
            Vector2(0, background_size.y)        # Bottom-left
        ])
        existing_area.polygon = points
        walkable_areas.clear()  # Ensure we don't add duplicates
        walkable_areas.append(existing_area)
        print("Updated existing walkable area to match background size: " + str(background_size))
    else:
        # Create a new walkable area
        var polygon = Polygon2D.new()
        polygon.name = "WalkableArea"
        polygon.color = Color(0, 1, 0, 0.1)  # Semi-transparent green
        
        # Create polygon points matching background size
        var points = PoolVector2Array([
            Vector2(0, 0),                        # Top-left
            Vector2(background_size.x, 0),        # Top-right
            Vector2(background_size.x, background_size.y),  # Bottom-right
            Vector2(0, background_size.y)         # Bottom-left
        ])
        
        polygon.polygon = points
        polygon.add_to_group("walkable_area")
        
        add_child(polygon)
        walkable_areas.append(polygon)
        
        print("Created walkable area with size: " + str(background_size))
    
    # Update camera bounds
    if camera:
        camera.update_bounds()

# ESC key handler to exit test
func _input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ESCAPE:
            # Return to main game scene
            get_tree().change_scene("res://src/core/main.tscn")
            print("Exiting scrolling camera test")

# Add some visual elements to show the bounds
func _draw():
    # Draw bounds of the walkable area
    for area in walkable_areas:
        var points = area.polygon

        # Draw the boundary lines (white)
        for i in range(points.size()):
            var start = area.to_global(points[i])
            var end = area.to_global(points[(i + 1) % points.size()])
            draw_line(start, end, Color(1, 1, 1, 0.5), 2.0)

        # Draw labels at vertices
        var font = DynamicFont.new()
        font.size = 14
        for i in range(points.size()):
            var pos = area.to_global(points[i])
            draw_string(font, pos + Vector2(5, 5), str(i), Color(1, 1, 1))

    # Draw screen boundaries for reference
    var screen_size = get_viewport_rect().size
    var screen_rect = Rect2(Vector2.ZERO, screen_size)
    draw_rect(screen_rect, Color(1, 0, 0, 0.3), false, 3.0)

    # Draw center marker
    var center = screen_size / 2
    draw_circle(center, 5, Color(1, 0, 0))
    draw_line(center - Vector2(10, 0), center + Vector2(10, 0), Color(1, 0, 0), 2)
    draw_line(center - Vector2(0, 10), center + Vector2(0, 10), Color(1, 0, 0), 2)
    
    # Draw debug info text in a more reliable way
    var debug_text = ""
    debug_text += "CAMERA DEBUG INFO:\n"
    if background_sprite:
        debug_text += "Background position: " + str(background_sprite.position) + "\n"
        debug_text += "Background scale: " + str(background_sprite.scale) + "\n"
        debug_text += "Background size: " + str(background_size) + "\n"
        debug_text += "Background visible: " + str(background_sprite.visible) + "\n"
        debug_text += "Background texture: " + str(background_sprite.texture != null) + "\n"
        debug_text += "Background centered: " + str(background_sprite.centered) + "\n"

    if camera:
        debug_text += "Camera position: " + str(camera.global_position) + "\n"
        debug_text += "Camera zoom: " + str(camera.zoom) + "\n"
        debug_text += "Camera current: " + str(camera.current) + "\n"

    # Instead of trying to draw text directly, print to console
    print("Debug information: ")
    print(debug_text)

    # Draw a debug label that won't have font issues
    var label = get_node_or_null("DebugLabel")
    if not label:
        # Create a new debug label if it doesn't exist
        label = Label.new()
        label.name = "DebugLabel"
        label.rect_position = Vector2(10, 10)
        label.add_color_override("font_color", Color(1, 1, 0))
        add_child(label)

    # Update the label text
    if label:
        label.text = debug_text