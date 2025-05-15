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
    
    # Enable scrolling camera with right-side view
    use_scrolling_camera = true
    camera_follow_smoothing = 4.0
    camera_edge_margin = Vector2(150, 100)
    initial_camera_view = "right"  # Start with the right side of the background visible
    camera_easing_type = "SINE"    # Default to sine easing for smooth movement
    
    # Important: Use Vector2.ZERO to let the camera system decide position based on view setting
    camera_initial_position = Vector2.ZERO
    
    # Configure auto-scaling to fill viewport height
    auto_adjust_camera_zoom = true
    fill_viewport_height = true
    
    # Load background texture if specified
    load_background()

    # Call parent _ready() to set up the district
    ._ready()

    # Setup walkable area for testing
    setup_walkable_area()
    
    # Wait for camera to be created then configure additional camera properties
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    
    # Add debug tools using the new debug manager
    print("[CAMERA TEST] About to initialize debug tools")
    var DebugManager = load("res://src/core/debug/debug_manager.gd")
    if DebugManager:
        print("[CAMERA TEST] DebugManager script loaded successfully")
        var debug_manager = DebugManager.add_to_scene(self, camera)
        
        if debug_manager:
            print("[CAMERA TEST] Debug manager added to scene successfully")
            # Toggle coordinate picker on by default for easy testing
            debug_manager.toggle_coordinate_picker()
            print("[CAMERA TEST] Coordinate picker enabled")
            print("[CAMERA TEST] Press backtick key (`) to open debug console")
        else:
            push_error("[CAMERA TEST] Failed to add debug manager to scene")

    # Debug message
    print("Scrolling camera test district initialized - using new DebugManager")
    print("Showing RIGHT side of background with FILLED viewport height")
    print("CONTROLS:")
    print("- Click to move player")
    print("- Press 'E' to cycle through different easing functions")
    print("- Press 'V' to toggle between partial view and full background view")
    print("- Press 'Z' to cycle zoom levels (1.0, 0.75, 0.5)")
    print("- Press 'ESC' to exit test")
    print("\nCurrent easing function: " + camera_easing_type)

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
            background_sprite.centered = false  # Important: Don't center the sprite horizontally
            
            # Center the background vertically to fill the screen height
            var viewport_size = get_viewport_rect().size
            var bg_height = background_texture.get_size().y * background_scale.y
            var y_offset = (viewport_size.y - bg_height) / 2
            
            # Only apply vertical centering if background is smaller than viewport
            if bg_height < viewport_size.y:
                background_sprite.position = Vector2(0, y_offset)  # Center vertically
                print("Vertically centering background: y_offset = " + str(y_offset))
            else:
                background_sprite.position = Vector2(0, 0)  # Align to top if larger than viewport
                print("Background taller than viewport, no vertical centering needed")
            background_sprite.scale = background_scale
            
            print("Loaded custom background: " + background_texture_path)
            
            # Set background size based on texture
            background_size = background_texture.get_size() * background_scale
            print("Background size: " + str(background_size))
            
            # Get screen size to check if background is wide enough
            var screen_size = get_viewport_rect().size
            var width_ratio = background_size.x / screen_size.x
            print("Background/screen width ratio: " + str(width_ratio))
            
            if width_ratio < 1.5:
                print("WARNING: Background image may not be wide enough for proper scrolling.")
                print("For best results, use an image at least 1.5x screen width.")
                print("Current image is only " + str(width_ratio) + "x screen width.")
            else:
                print("Background is " + str(width_ratio) + "x screen width - sufficient for scrolling effect.")
            
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

# Configure camera for testing different views
func configure_camera():
    if camera:
        # Fix zoom to ensure camera shows the scene correctly
        camera.zoom = Vector2(1, 1)
        camera.current = true
        
        # Force update of camera bounds
        yield(get_tree(), "idle_frame")
        camera.update_bounds()
        
        # Position player based on walkable area
        var player = get_node_or_null("Player")
        if player and walkable_areas.size() > 0:
            var walkable_area = walkable_areas[0]
            var player_pos = Vector2.ZERO
            
            # Calculate the center of the walkable area for player positioning
            if walkable_area.polygon.size() > 0:
                var min_x = INF
                var max_x = -INF
                var min_y = INF
                var max_y = -INF
                
                # Find bounds of walkable area
                for point in walkable_area.polygon:
                    min_x = min(min_x, point.x)
                    max_x = max(max_x, point.x)
                    min_y = min(min_y, point.y)
                    max_y = max(max_y, point.y)
                
                # Place player in center of walkable area
                player_pos = Vector2(
                    min_x + (max_x - min_x) / 2,
                    min_y + (max_y - min_y) / 2
                )
            else:
                # Default to position based on initial view setting
                match initial_camera_view:
                    "left":
                        # Position player on the left side of the background
                        player_pos = Vector2(background_size.x * 0.25, background_size.y * 0.75)
                    "right":
                        # Position player on the right side of the background
                        player_pos = Vector2(background_size.x * 0.75, background_size.y * 0.75)
                    _:
                        # Default to center
                        player_pos = Vector2(background_size.x / 2, background_size.y * 0.75)
            
            # Apply position
            player.position = player_pos
            print("Player positioned at: " + str(player_pos))
        
        # Ensure we have enough frames to set everything up properly
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        
        # Check if the camera has followed our initial position request
        print("\nVerifying camera position before forced update:")
        print("- Expected position: " + str(camera_initial_position))
        print("- Current position: " + str(camera.global_position))
        
        # Force immediate update of camera position to our desired value
        camera.force_update_scroll()
        
        # Double-check camera position after update
        print("Camera position after forced update: " + str(camera.global_position))
        
        print("Camera configured with initial view: " + initial_camera_view)
        print("Camera position: " + str(camera.global_position))
        print("Camera zoom: " + str(camera.zoom))
    else:
        print("WARNING: No camera found to configure")

# Setup the walkable area based on background
func setup_walkable_area():
    # Check if we already have a walkable area
    var existing_area = get_node_or_null("WalkableArea")
    if existing_area:
        # Creating a more precise walkable area from the logged coordinates
        # Using only the floor section visible in debug017.png
        # Instead of a full polygon, create a tight rectangle around the visible floor
        # Reduced width to better match floor width in screenshots (debug17.png)
        var floor_y_min = 450   # Top of visible floor
        var floor_y_max = 475   # Bottom of visible floor
        var points = PoolVector2Array([
            Vector2(1400, floor_y_min),            # Top-left
            Vector2(2400, floor_y_min),            # Top-right
            Vector2(2400, floor_y_max),            # Bottom-right
            Vector2(1400, floor_y_max)             # Bottom-left
        ])
        
        # Extensive debug information to understand coordinate system
        print("\n========== WALKABLE AREA SETUP ==========")
        print("Background size: " + str(background_size))
        print("Screen size: " + str(get_viewport_rect().size))
        print("Using walkable area coordinates: " + str(points))
        print("These coordinates were captured using the coordinate picker during camera testing")
        
        # Additional detailed debugging
        print("Walkable area details:")
        print("- X range: " + str(points[0].x) + " to " + str(points[1].x) + " (width: " + str(points[1].x - points[0].x) + ")")
        print("- Y range: " + str(points[0].y) + " to " + str(points[2].y) + " (height: " + str(points[2].y - points[0].y) + ")")
        print("- Key points: Top-left: " + str(points[0]) + ", Top-right: " + str(points[1]) + 
              ", Bottom-right: " + str(points[2]) + ", Bottom-left: " + str(points[3]))
        
        # Camera debugging information
        if camera:
            print("Camera settings:")
            print("- Initial camera position: " + str(camera_initial_position))
            print("- Initial camera view: " + str(initial_camera_view))
            print("- Camera position: " + str(camera.global_position))
            print("- Camera zoom: " + str(camera.zoom))
        
        # Check if we're using zoomed-out view for the scene setup
        if show_full_view and camera:
            print("Using coordinates captured in full view mode")
            print("Current camera zoom: " + str(camera.zoom))
            
            # These coordinates were captured in full view (zoomed out)
            # We don't need to convert them - the camera's screen_to_world function
            # will handle the correct conversion when interacting with them
            print("The coordinates are already in world space and will work correctly")
        
        # Save original polygon for debugging
        # Create a manually copied array since PoolVector2Array doesn't have duplicate()
        var polygon_copy = []
        for point in existing_area.polygon:
            polygon_copy.append(Vector2(point.x, point.y))
            
        if "original_polygon" in existing_area:
            existing_area.original_polygon = polygon_copy
        else:
            existing_area.set_meta("original_polygon", polygon_copy)
        
        # Apply new polygon
        existing_area.polygon = points
        walkable_areas.clear()  # Ensure we don't add duplicates
        walkable_areas.append(existing_area)
        
        # Validate walkable area
        var total_area = 0
        for i in range(existing_area.polygon.size()):
            var j = (i + 1) % existing_area.polygon.size()
            total_area += existing_area.polygon[i].x * existing_area.polygon[j].y
            total_area -= existing_area.polygon[j].x * existing_area.polygon[i].y
        total_area = abs(total_area) / 2
        
        print("Walkable area size (polygon area): " + str(total_area) + " square pixels")
        # Calculate the actual width and height of the area
        var min_x = INF
        var max_x = -INF
        var min_y = INF
        var max_y = -INF
        
        for point in points:
            min_x = min(min_x, point.x)
            max_x = max(max_x, point.x)
            min_y = min(min_y, point.y)
            max_y = max(max_y, point.y)
            
        var width = max_x - min_x
        var height = max_y - min_y
        
        print("Width: " + str(width) + ", Height: " + str(height))
        print("Updated walkable area with corrected coordinates")
        print("========== WALKABLE AREA SETUP COMPLETE ==========\n")
    else:
        # Create a new walkable area
        var polygon = Polygon2D.new()
        polygon.name = "WalkableArea"
        polygon.color = Color(0, 1, 0, 0.1)  # Semi-transparent green
        
        # Create a more precise walkable area from the logged coordinates
        # Using only the floor section visible in debug017.png
        # Reduced width to better match floor width in screenshots (debug17.png)
        var floor_y_min = 450   # Top of visible floor
        var floor_y_max = 475   # Bottom of visible floor
        var points = PoolVector2Array([
            Vector2(1400, floor_y_min),            # Top-left
            Vector2(2400, floor_y_min),            # Top-right
            Vector2(2400, floor_y_max),            # Bottom-right
            Vector2(1400, floor_y_max)             # Bottom-left
        ])
        
        polygon.polygon = points
        polygon.add_to_group("walkable_area")
        
        add_child(polygon)
        walkable_areas.append(polygon)
        
        # Extensive debug information
        print("\n========== WALKABLE AREA CREATION ==========")
        print("Created walkable area with the following coordinates:")
        print("- X range: " + str(points[0].x) + " to " + str(points[1].x) + " (width: " + str(points[1].x - points[0].x) + ")")
        print("- Y range: " + str(points[0].y) + " to " + str(points[2].y) + " (height: " + str(points[2].y - points[0].y) + ")")
        print("- Points: " + str(points))
        print("- Walkable area parent: " + str(get_path()))
        print("- Full path to walkable area: " + str(polygon.get_path()))
        print("========== WALKABLE AREA CREATION COMPLETE ==========\n")
    
    # Update camera bounds
    if camera:
        print("Forcing camera bounds update with the corrected walkable area")
        camera.update_bounds()
        # Force an immediate update of camera position
        yield(get_tree(), "idle_frame")  # Wait a frame for bounds to update
        camera.force_update_scroll()

# Testing variables
var zoom_level = 1.0
var show_full_view = false

# Key handler for test controls
func _input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ESCAPE:
            # Return to main game scene
            get_tree().change_scene("res://src/core/main.tscn")
            print("Exiting scrolling camera test")
        
        # E key to cycle through easing functions
        elif event.scancode == KEY_E:
            if camera:
                # Get all easing types
                var easing_types = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
                
                # Find the index of current easing type
                var current_index = easing_types.find(camera_easing_type)
                
                # Move to the next easing type
                var next_index = (current_index + 1) % easing_types.size()
                camera_easing_type = easing_types[next_index]
                
                # Update the camera
                var easing_index = next_index
                if "easing_type" in camera:
                    camera.easing_type = easing_index
                
                print("Camera easing type changed to: " + camera_easing_type)
                
        # V key to toggle between showing part of the background and the full background
        elif event.scancode == KEY_V:
            show_full_view = !show_full_view
            
            if camera:
                if show_full_view:
                    print("Current zoom: " + str(camera.zoom))
                    print("Attempting to show full background...")
                    print("Background size: " + str(background_size))
                    print("Viewport size: " + str(get_viewport_rect().size))
                    
                    # COMPLETELY DIFFERENT APPROACH
                    # In Godot, HIGHER zoom values = zoomed OUT (can see more)
                    # So to see the full background, we need to INCREASE zoom value
                    
                    # Calculate the appropriate zoom value based on background size
                    var viewport_size = get_viewport_rect().size
                    var zoom_x = viewport_size.x / background_size.x
                    var zoom_y = viewport_size.y / background_size.y
                    
                    # Use the smaller value to ensure the entire background fits, with a margin
                    var zoom_value = min(zoom_x, zoom_y) * 0.95  # 95% to add a small margin
                    
                    # Ensure zoom isn't too extreme in either direction
                    zoom_value = clamp(zoom_value, 1.5, 3.0)  # Keep zoom between 1.5 and 3.0
                    
                    print("Using large zoom value: " + str(zoom_value) + " to see entire background")
                    
                    # Set camera properties
                    camera.zoom = Vector2(zoom_value, zoom_value)
                    
                    # Center camera on background
                    camera.global_position = Vector2(
                        background_size.x / 2,
                        background_size.y / 2
                    )
                    
                    # Disable camera smoothing and bounds temporarily
                    var orig_smoothing = camera.smoothing_enabled
                    var orig_bounds_enabled = camera.bounds_enabled
                    camera.smoothing_enabled = false
                    camera.bounds_enabled = false
                    
                    # Force immediate position update
                    camera.global_position = Vector2(
                        background_size.x / 2,
                        background_size.y / 2
                    )
                    camera.force_update_transform()
                    
                    print("Camera positioned at: " + str(camera.global_position))
                    print("Final zoom value: " + str(camera.zoom))
                    print("Now showing full background view")
                    
                    # Restore camera settings (but keep bounds disabled for full view)
                    camera.smoothing_enabled = orig_smoothing
                else:
                    # Reset to normal view (zoomed in, showing only part of background)
                    camera.zoom = Vector2(1, 1)
                    print("Resetting to normal view (partial background)")
                    
                    # Re-initialize camera position for this zoom level
                    camera._set_initial_camera_position()
                    
        # Z key to toggle zoom levels for testing
        elif event.scancode == KEY_Z:
            if camera:
                # Cycle through zoom levels: 1.0, 0.75, 0.5
                zoom_level = zoom_level - 0.25
                if zoom_level < 0.5:
                    zoom_level = 1.0
                
                # Apply zoom
                camera.zoom = Vector2(zoom_level, zoom_level)
                print("Camera zoom set to: " + str(zoom_level))

# Debug functionality has been migrated to the DebugManager
# These functions were previously used for setting up debug tools
# Now debug tools are instantiated in _ready() using DebugManager.add_to_scene()
#
# Function keys (F1-F4) can be used to toggle different debug tools:
# F1: Toggle coordinate picker
# F2: Toggle polygon visualizer
# F3: Toggle debug console
# F4: Toggle debug overlay
# V:  Toggle full view mode
#
# Debug tools can also be controlled through the console with the "debug" command:
# debug on/off - Enable/disable debug manager
# debug status - Show status of all debug tools
# debug coordinates/polygon/etc. - Toggle specific tools

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

        # Draw vertex markers (but not labels, which use font)
        for i in range(points.size()):
            var pos = area.to_global(points[i])
            # Draw a circle at each vertex instead of text
            draw_circle(pos, 5, Color(1, 1, 0, 0.8))

    # Draw screen boundaries for reference
    var screen_size = get_viewport_rect().size
    var screen_rect = Rect2(Vector2.ZERO, screen_size)
    draw_rect(screen_rect, Color(1, 0, 0, 0.3), false, 3.0)

    # Draw center marker
    var center = screen_size / 2
    draw_circle(center, 5, Color(1, 0, 0))
    draw_line(center - Vector2(10, 0), center + Vector2(10, 0), Color(1, 0, 0), 2)
    draw_line(center - Vector2(0, 10), center + Vector2(0, 10), Color(1, 0, 0), 2)
    
    # Collect debug information
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
        debug_text += "Camera easing: " + camera_easing_type + "\n"
        debug_text += "\nControls:\n"
        debug_text += "- Click to move player\n"
        debug_text += "- Press 'E' to change easing function\n"
        debug_text += "- Press 'V' to toggle full/partial background view\n"
        debug_text += "- Press 'Z' to cycle zoom levels\n"
        debug_text += "- Press 'ESC' to exit test\n"
        
        # Add current view state
        debug_text += "\nCurrent view: " + ("Full background" if show_full_view else "Partial (scrollable) view") + "\n"
        debug_text += "Current zoom: " + str(zoom_level) + "x\n"

    # Print to console for debugging
    print("Debug information: ")
    print(debug_text)

    # Use UI Label for text display to avoid font issues
    var label = get_node_or_null("DebugLabel")
    if not label:
        # Create a new debug label if it doesn't exist
        label = Label.new()
        label.name = "DebugLabel"
        label.rect_position = Vector2(10, 10)
        label.add_color_override("font_color", Color(1, 1, 0))
        # Add a background to make text more readable
        var bg = ColorRect.new()
        bg.name = "DebugBackground"
        bg.color = Color(0, 0, 0, 0.5)
        bg.rect_position = Vector2(5, 5)
        bg.rect_size = Vector2(500, 400) # Will resize as needed
        add_child(bg)
        add_child(label)
        label.raise() # Ensure label is on top of background

    # Update the label text
    if label:
        label.text = debug_text
        
        # Also adjust background size to match text
        var bg = get_node_or_null("DebugBackground")
        if bg:
            # Make background slightly larger than the text
            bg.rect_size = Vector2(label.rect_size.x + 20, label.rect_size.y + 20)