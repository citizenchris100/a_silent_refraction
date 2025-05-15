extends Node

class_name DebugManager

# Debug components
var coordinate_picker
var polygon_visualizer
var debug_console
var debug_overlay

# Reference to the scene's camera
var camera

# Tracking states
var full_view_mode = false
var original_camera_position = Vector2()
var original_camera_zoom = Vector2()

# Debug tool visibility toggles
var coordinate_picker_visible = false
var polygon_visualizer_visible = false
var console_visible = false
var overlay_visible = false

# Polygon data
var current_polygon = PoolVector2Array()
var polygons = []

signal debug_key_pressed(key)
signal polygon_created(polygon)
signal coordinate_selected(position)

func _init():
    print("Debug Manager initialized")

func _ready():
    set_process_input(true)
    print("Debug Manager ready")
    
    # Auto-initialize console to ensure backtick always works
    create_debug_console()
    print("Debug console auto-initialized - press backtick (`) to open")

func setup_camera(scene_camera):
    camera = scene_camera
    if camera:
        print("Camera connected to Debug Manager")
    else:
        push_error("Failed to connect camera to Debug Manager")

func _input(event):
    if event is InputEventKey and event.pressed:
        emit_signal("debug_key_pressed", event.scancode)
        
        # Check for input actions first (added for better reliability)
        if event.is_action_pressed("toggle_coordinate_picker"):
            toggle_coordinate_picker()
            get_tree().set_input_as_handled()
            
        elif event.is_action_pressed("toggle_polygon_visualizer"):
            toggle_polygon_visualizer()
            get_tree().set_input_as_handled()
            
        elif event.is_action_pressed("toggle_debug_console"):
            # Don't handle here, let the console handle it
            pass
            
        elif event.is_action_pressed("toggle_debug_overlay"):
            toggle_debug_overlay()
            get_tree().set_input_as_handled()
            
        elif event.is_action_pressed("toggle_full_view"):
            toggle_full_view()
            get_tree().set_input_as_handled()
            
        # Fallback to key code checks for backwards compatibility
        # F1: Toggle coordinate picker
        elif event.scancode == KEY_F1:
            toggle_coordinate_picker()
            
        # F2: Toggle polygon visualizer
        elif event.scancode == KEY_F2:
            toggle_polygon_visualizer()
            
        # F3: Toggle debug console
        elif event.scancode == KEY_F3:
            toggle_debug_console()
            
        # F4: Toggle debug overlay
        elif event.scancode == KEY_F4:
            toggle_debug_overlay()
            
        # V: Toggle full view mode (zoomed out to see entire background)
        elif event.scancode == KEY_V:
            toggle_full_view()
            
        # C: Complete current polygon and start a new one
        elif event.scancode == KEY_C and polygon_visualizer_visible:
            complete_polygon()
            
        # X: Clear all polygons
        elif event.scancode == KEY_X and polygon_visualizer_visible:
            clear_polygons()
            
        # S: Save polygons to file
        elif event.scancode == KEY_S and polygon_visualizer_visible and Input.is_key_pressed(KEY_CONTROL):
            save_polygons()

# Create and add individual debug components
func create_coordinate_picker():
    if coordinate_picker == null:
        var CoordinatePicker = load("res://src/core/debug/coordinate_picker.gd")
        if CoordinatePicker:
            # Create a Node2D with the script
            var node = Node2D.new()
            node.set_script(CoordinatePicker)
            node.name = "CoordinatePicker"
            coordinate_picker = node
            add_child(coordinate_picker)
            
            # Check if the signal exists before connecting
            if coordinate_picker.has_signal("coordinate_selected"):
                coordinate_picker.connect("coordinate_selected", self, "_on_coordinate_selected")
            else:
                print("Note: coordinate_selected signal not found - this is expected if the CoordinatePicker hasn't declared it")
                
            print("Coordinate Picker created")
        else:
            push_error("Failed to load coordinate_picker.gd script")

func create_polygon_visualizer():
    if polygon_visualizer == null:
        var PolygonVisualizer = load("res://src/core/debug/polygon_visualizer.gd")
        if PolygonVisualizer:
            # Create a Node2D with the script
            var node = Node2D.new()
            node.set_script(PolygonVisualizer)
            node.name = "PolygonVisualizer"
            polygon_visualizer = node
            polygon_visualizer.target_group = "walkable_area"
            
            # Connect signals from polygon visualizer
            polygon_visualizer.connect("polygon_updated", self, "_on_polygon_updated")
            polygon_visualizer.connect("polygon_completed", self, "_on_polygon_completed")
            
            add_child(polygon_visualizer)
            print("Polygon Visualizer created")
        else:
            push_error("Failed to load polygon_visualizer.gd script")

func create_debug_console():
    print("[DEBUG MANAGER] Attempting to create debug console")
    if debug_console == null:
        var DebugConsole = load("res://src/core/debug/debug_console.gd")
        if DebugConsole:
            print("[DEBUG MANAGER] DebugConsole script loaded successfully")
            debug_console = DebugConsole.new()
            debug_console.name = "DebugConsole"
            # Add to root instead of as child of manager since it's a CanvasLayer
            get_tree().get_root().add_child(debug_console)
            print("[DEBUG MANAGER] Debug Console created and added to root level")
            
            # Check if the debug console was actually added
            var console_node = get_tree().get_root().get_node_or_null("DebugConsole")
            if console_node:
                print("[DEBUG MANAGER] Successfully found debug console in scene tree")
            else:
                push_error("[DEBUG MANAGER] Failed to find debug console in scene tree after adding")
        else:
            push_error("[DEBUG MANAGER] Failed to load debug_console.gd script")

func create_debug_overlay():
    if debug_overlay == null:
        var DebugOverlay = load("res://src/core/debug/debug_overlay.gd")
        debug_overlay = DebugOverlay.new()
        # Add to root instead of as child of manager since it's a CanvasLayer
        get_tree().get_root().add_child(debug_overlay)
        print("Debug Overlay created at root level")

# Toggle visibility functions
func toggle_coordinate_picker():
    coordinate_picker_visible = !coordinate_picker_visible
    if coordinate_picker_visible:
        if coordinate_picker == null:
            create_coordinate_picker()
        coordinate_picker.visible = true
    elif coordinate_picker != null:
        coordinate_picker.visible = false
    print("Coordinate Picker visibility: ", coordinate_picker_visible)

func toggle_polygon_visualizer():
    polygon_visualizer_visible = !polygon_visualizer_visible
    if polygon_visualizer_visible:
        if polygon_visualizer == null:
            create_polygon_visualizer()
        polygon_visualizer.visible = true
    elif polygon_visualizer != null:
        polygon_visualizer.visible = false
    print("Polygon Visualizer visibility: ", polygon_visualizer_visible)

func toggle_debug_console():
    console_visible = !console_visible
    if console_visible:
        if debug_console == null:
            create_debug_console()
        debug_console.visible = true
    elif debug_console != null:
        debug_console.visible = false
    print("Debug Console visibility: ", console_visible)

func toggle_debug_overlay():
    overlay_visible = !overlay_visible
    if overlay_visible:
        if debug_overlay == null:
            create_debug_overlay()
        debug_overlay.visible = true
    elif debug_overlay != null:
        debug_overlay.visible = false
    print("Debug Overlay visibility: ", overlay_visible)

func toggle_full_view():
    print("[DEBUG MANAGER] Toggling full view mode")
    if camera == null:
        push_error("[DEBUG MANAGER] Camera not connected to Debug Manager")
        return
        
    full_view_mode = !full_view_mode
    
    if full_view_mode:
        print("[DEBUG MANAGER] Enabling full view mode")
        # Store original camera state
        original_camera_position = camera.global_position
        original_camera_zoom = camera.zoom
        
        # Get camera properties to preserve
        var original_smoothing_enabled = false
        var original_bounds_enabled = false
        
        if "smoothing_enabled" in camera:
            original_smoothing_enabled = camera.smoothing_enabled
            camera.smoothing_enabled = false
        
        if "bounds_enabled" in camera:
            original_bounds_enabled = camera.bounds_enabled
            camera.bounds_enabled = false
        
        # Calculate new zoom to show entire background
        var viewport_size = Vector2(1024, 600) # Default fallback
        if get_tree() and get_tree().get_root():
            viewport_size = get_tree().get_root().get_viewport().size
        
        var background = get_background_size()
        
        if background == Vector2.ZERO:
            push_error("[DEBUG MANAGER] Could not get background size")
            return
            
        print("[DEBUG MANAGER] Background size: ", background)
        print("[DEBUG MANAGER] Viewport size: ", viewport_size)
        
        # Calculate zoom level needed to see the entire background
        var zoom_x = viewport_size.x / background.x
        var zoom_y = viewport_size.y / background.y
        var new_zoom = min(zoom_x, zoom_y) * 0.95  # 5% margin
        
        # In Godot, smaller zoom values zoom in (show less), larger values zoom out (show more)
        # Here we're reversing the calculation to make it work as expected
        var zoom_value = 1.0 / new_zoom if new_zoom > 0 else 3.0
        
        # Don't allow extreme zoom values
        zoom_value = clamp(zoom_value, 0.1, 10.0)
        
        # Log state before changing
        print("[DEBUG MANAGER] Before full view: camera position=", camera.global_position, ", zoom=", camera.zoom)
        print("[DEBUG MANAGER] Calculated zoom value: ", zoom_value)
        
        # Apply full view - set position first
        camera.global_position = Vector2(background.x / 2, background.y / 2)
        
        # Apply zoom with error handling
        if zoom_value > 0:
            camera.zoom = Vector2(zoom_value, zoom_value)
        else:
            camera.zoom = Vector2(3.0, 3.0)  # Fallback value
        
        # Force transform update to apply changes immediately
        if camera.has_method("force_update_transform"):
            camera.force_update_transform()
        elif camera.has_method("force_update_scroll"):
            camera.force_update_scroll()
        
        # Restore properties but keep bounds disabled for full view
        if "smoothing_enabled" in camera:
            camera.smoothing_enabled = original_smoothing_enabled
            
        # Log final state
        print("[DEBUG MANAGER] Full view mode enabled")
        print("[DEBUG MANAGER] New camera position: ", camera.global_position)
        print("[DEBUG MANAGER] New camera zoom: ", camera.zoom)
    else:
        print("[DEBUG MANAGER] Disabling full view mode")
        # Log before restoring
        print("[DEBUG MANAGER] Restoring original camera state:")
        print("[DEBUG MANAGER] Position: ", original_camera_position)
        print("[DEBUG MANAGER] Zoom: ", original_camera_zoom)
        
        # Restore original camera state
        camera.global_position = original_camera_position
        camera.zoom = original_camera_zoom
        
        # Force update to apply changes immediately
        if camera.has_method("force_update_transform"):
            camera.force_update_transform()
        elif camera.has_method("force_update_scroll"):
            camera.force_update_scroll()
        
        # Restore bounds if camera has this property
        if "bounds_enabled" in camera:
            camera.bounds_enabled = true
            
        print("[DEBUG MANAGER] Full view mode disabled")
        print("[DEBUG MANAGER] Camera restored to: position=", camera.global_position, ", zoom=", camera.zoom)

# Polygon management
func add_point_to_polygon(point):
    if polygon_visualizer == null:
        create_polygon_visualizer()
    current_polygon.append(point)
    polygon_visualizer.update_current_polygon(current_polygon)
    print("Added point to polygon: ", point)

func complete_polygon():
    if current_polygon.size() >= 3:
        polygons.append(current_polygon)
        emit_signal("polygon_created", current_polygon)
        print("Polygon completed with ", current_polygon.size(), " points")
        current_polygon = PoolVector2Array()
        polygon_visualizer.update_polygons(polygons)
    else:
        print("Need at least 3 points to create a polygon")

func clear_polygons():
    current_polygon = PoolVector2Array()
    polygons.clear()
    if polygon_visualizer != null:
        polygon_visualizer.update_current_polygon(current_polygon)
        polygon_visualizer.update_polygons(polygons)
    print("All polygons cleared")

func save_polygons():
    # Save polygons to both clipboard and file
    print("Saving polygons...")
    
    if polygons.size() == 0:
        push_warning("No polygons to save")
        return
    
    # Format polygons for easy code integration
    var polygons_text = ""
    for i in range(polygons.size()):
        var polygon = polygons[i]
        polygons_text += "var polygon_" + str(i) + " = PoolVector2Array([\n"
        
        for j in range(polygon.size()):
            var point = polygon[j]
            polygons_text += "\tVector2(" + str(int(point.x)) + ", " + str(int(point.y)) + ")"
            if j < polygon.size() - 1:
                polygons_text += ",\n"
            else:
                polygons_text += "\n"
                
        polygons_text += "])\n\n"
    
    # Add typical walkable area usage code
    if polygons.size() == 1:
        # Simple case - likely creating a walkable area
        polygons_text += "# Usage example for walkable area:\n"
        polygons_text += "var walkable_area = Polygon2D.new()\n"
        polygons_text += "walkable_area.name = \"WalkableArea\"\n"
        polygons_text += "walkable_area.color = Color(0, 1, 0, 0.1)  # Semi-transparent green\n"
        polygons_text += "walkable_area.polygon = polygon_0\n"
        polygons_text += "walkable_area.add_to_group(\"walkable_area\")\n"
        polygons_text += "add_child(walkable_area)\n"
    
    # Copy to clipboard
    OS.set_clipboard(polygons_text)
    print("Polygon data copied to clipboard")
    
    # Save to file in user directory
    var dir = Directory.new()
    if !dir.dir_exists("user://logs"):
        dir.make_dir("user://logs")
    
    var file = File.new()
    var file_path = "user://logs/polygons_" + get_timestamp() + ".gd"
    file.open(file_path, File.WRITE)
    file.store_string(polygons_text)
    file.close()
    
    print("Polygon data saved to file: " + file_path)
    print("Full path: ~/.local/share/godot/app_userdata/A Silent Refraction/logs/" + file_path.get_file())
    
    # Create visual notification
    var notification = Label.new()
    notification.text = "Polygons saved to clipboard and file"
    notification.add_color_override("font_color", Color(0, 1, 0))
    
    # Get viewport size safely
    var viewport_size = Vector2(1024, 600)
    if get_tree() and get_tree().get_root() and get_tree().get_root().get_viewport():
        viewport_size = get_tree().get_root().get_viewport().size
    
    notification.rect_position = Vector2(viewport_size.x/2 - 150, 100)
    get_tree().get_root().add_child(notification)
    
    # Remove notification after a few seconds
    yield(get_tree().create_timer(3.0), "timeout")
    if is_instance_valid(notification):
        notification.queue_free()

# Helper function to get timestamp for filenames
func get_timestamp():
    var datetime = OS.get_datetime()
    return "%04d%02d%02d_%02d%02d%02d" % [
        datetime.year, datetime.month, datetime.day,
        datetime.hour, datetime.minute, datetime.second
    ]

# Helper functions
func get_background_size():
    # Try multiple methods to determine background size
    
    # Method 1: Check if parent provides a background size method
    var parent = get_parent()
    if parent.has_method("get_background_size"):
        var size = parent.get_background_size()
        print("Using parent's get_background_size() method: ", size)
        return size
        
    # Method 2: Check for a background_size property on parent
    if "background_size" in parent:
        var size = parent.background_size
        print("Using parent's background_size property: ", size)
        return size
    
    # Method 3: Look for a Background node that is a Sprite
    var background = parent.get_node_or_null("Background")
    if background and background is Sprite and background.texture:
        var size = background.texture.get_size() * background.scale
        print("Found Background sprite with size: ", size)
        return size
        
    # Method 4: Search for any sprite in the scene with "background" in the name
    var sprites = get_tree().get_nodes_in_group("sprite")
    for sprite in sprites:
        if sprite is Sprite and sprite.texture and ("background" in sprite.name.to_lower() or "bg" in sprite.name.to_lower()):
            var size = sprite.texture.get_size() * sprite.scale
            print("Found sprite with 'background' in name: ", sprite.name, " with size: ", size)
            return size
            
    # Method 5: Look for a ColorRect named Background
    var color_rect = parent.get_node_or_null("ColorBackground")
    if color_rect and color_rect is ColorRect:
        var size = color_rect.rect_size
        print("Found ColorRect background with size: ", size)
        return size
    
    # Method 6: Try to get walkable area size and extrapolate
    var walkable_areas = get_tree().get_nodes_in_group("walkable_area")
    if walkable_areas.size() > 0:
        var area = walkable_areas[0]
        var bounds = get_polygon_bounds(area.polygon)
        var extrapolated_size = Vector2(bounds.size.x * 1.2, bounds.size.y * 1.2)
        print("Extrapolated size from walkable area: ", extrapolated_size)
        return extrapolated_size
    
    # Fallback: use viewport size with some margin
    # Use get_tree() to get the viewport safely
    var viewport_size = Vector2(1024, 600) # Default fallback
    
    if get_tree() and get_tree().get_root():
        viewport_size = get_tree().get_root().get_viewport().size
    
    var fallback_size = viewport_size * 1.5
    print("Using fallback size (viewport * 1.5): ", fallback_size)
    return fallback_size

# Helper method to get bounds of a polygon
func get_polygon_bounds(polygon):
    if polygon.size() == 0:
        return Rect2(0, 0, 100, 100)
        
    var min_x = INF
    var min_y = INF
    var max_x = -INF
    var max_y = -INF
    
    for point in polygon:
        min_x = min(min_x, point.x)
        max_x = max(max_x, point.x)
        min_y = min(min_y, point.y)
        max_y = max(max_y, point.y)
    
    return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

# Signal handlers
func _on_coordinate_selected(position):
    emit_signal("coordinate_selected", position)
    print("Coordinate selected: ", position)
    
    # If polygon visualizer is active, add point to current polygon
    if polygon_visualizer_visible:
        add_point_to_polygon(position)

# Handle signals from polygon visualizer
func _on_polygon_updated(polygon):
    # Update our current polygon when the visualizer changes it
    current_polygon = polygon
    print("Polygon updated, now has ", polygon.size(), " points")
    
func _on_polygon_completed(polygon):
    # Add completed polygon to our collection
    polygons.append(polygon)
    print("Polygon completed with ", polygon.size(), " points")
    emit_signal("polygon_created", polygon)
    
    # Reset current polygon
    current_polygon = PoolVector2Array()

# Static method to add debug manager to a scene
static func add_to_scene(scene, camera_node):
    # Check if debug manager already exists in scene
    var existing_manager = scene.get_node_or_null("DebugManager")
    if existing_manager:
        print("Debug Manager already exists in scene")
        return existing_manager
        
    # Create new debug manager
    var debug_manager = Node.new()
    debug_manager.set_script(load("res://src/core/debug/debug_manager.gd"))
    debug_manager.name = "DebugManager"  # Set name explicitly for easier reference
    scene.add_child(debug_manager)
    debug_manager.call("setup_camera", camera_node)
    
    print("Debug Manager added to scene - press backtick (`) to open console")
    return debug_manager