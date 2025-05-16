extends Camera2D

# Easing types enum for camera movement
enum EasingType {
    LINEAR,          # Linear interpolation (no easing)
    EASE_IN,         # Acceleration from zero velocity
    EASE_OUT,        # Deceleration to zero velocity
    EASE_IN_OUT,     # Acceleration until halfway, then deceleration
    EXPONENTIAL,     # Exponential ease-out (more aggressive at start)
    SINE,            # Sine wave-based easing (smooth)
    ELASTIC,         # Overshoot and settle (bouncy)
    CUBIC,           # Cubic easing (smooth acceleration/deceleration)
    QUAD             # Quadratic easing (gentler than cubic)
}
# ScrollingCamera: Handles camera movement for larger-than-screen backgrounds

# Camera properties
export var follow_player: bool = true
export var follow_smoothing: float = 5.0
export var edge_margin: Vector2 = Vector2(150, 100) # Distance from edge that triggers scrolling
export var bounds_enabled: bool = true
export var initial_position: Vector2 = Vector2.ZERO # Initial camera position (if Vector2.ZERO, will be centered)
export var initial_view: String = "right" # Which part to show initially: "left", "right", "center"
export(EasingType) var easing_type: int = EasingType.SINE # Type of easing to use for camera movement

# Variables
var target_player: Node2D = null
var screen_size: Vector2
var camera_bounds: Rect2
export var auto_adjust_zoom: bool = true # Whether to automatically adjust zoom to fill viewport
export var fill_viewport_height: bool = true # Whether to automatically adjust zoom to fill viewport height
export var min_zoom: float = 0.5 # Minimum zoom level (lower value = more zoomed in)
export var max_zoom: float = 1.5 # Maximum zoom level (higher value = more zoomed out)

# Debug settings
export var debug_draw: bool = false  # Disable debug drawing by default
export var debug_camera_positioning: bool = true  # Enable camera position debug logs
export var debug_background_scaling: bool = true  # Enable background scaling debug logs
var debug_font: Font
var debug_overlay: CanvasLayer = null
var debug_markers = {}  # Store debug visual markers

# Store target positions for debugging
var debug_right_edge_position: Vector2 = Vector2.ZERO
var debug_calculated_position: Vector2 = Vector2.ZERO

# Enhanced debug logging function
func debug_log(category, message, step = ""):
    var step_prefix = "[Step " + str(step) + "] " if step != "" else ""
    if category == "camera" and debug_camera_positioning:
        print("[CAMERA DEBUG] " + step_prefix + message)
    elif category == "scaling" and debug_background_scaling:
        print("[SCALING DEBUG] " + step_prefix + message)
    elif category == "overlay":
        print("[OVERLAY DEBUG] " + step_prefix + message)
    elif category == "trace":
        print("[TRACE] " + step_prefix + message)

# Create a visual debug marker
func create_debug_marker(position, color = Color(1, 0, 0, 0.7), size = 10, name = "marker"):
    if not debug_overlay:
        setup_debug_overlay()
    
    # Create a unique name for the marker
    var marker_name = name + "_" + str(debug_markers.size())
    
    # Create the marker
    var marker = ColorRect.new()
    marker.color = color
    marker.rect_size = Vector2(size, size)
    marker.rect_position = world_to_screen(position) - Vector2(size/2, size/2)
    marker.name = marker_name
    
    debug_overlay.add_child(marker)
    debug_markers[marker_name] = marker
    
    debug_log("overlay", "Created marker '" + marker_name + "' at position " + str(position))
    return marker

# Set up the debug overlay canvas layer
func setup_debug_overlay():
    if debug_overlay:
        return
        
    debug_overlay = CanvasLayer.new()
    debug_overlay.name = "CameraDebugOverlay"
    debug_overlay.layer = 100  # Show on top
    add_child(debug_overlay)
    
    # Add overlay title label
    var title = Label.new()
    title.text = "Camera Debug Overlay"
    title.name = "OverlayTitle"
    title.rect_position = Vector2(10, 10)
    title.add_color_override("font_color", Color(1, 1, 0))
    
    # Add background for better visibility
    var bg = ColorRect.new()
    bg.color = Color(0, 0, 0, 0.5)
    bg.rect_position = Vector2(5, 5)
    bg.rect_size = Vector2(200, 30)
    
    debug_overlay.add_child(bg)
    debug_overlay.add_child(title)
    
    debug_log("overlay", "Created debug overlay")

func _ready():
    # Setup camera properties
    current = true # Make this the active camera
    smoothing_enabled = true
    smoothing_speed = follow_smoothing
    
    # Get screen size
    screen_size = get_viewport_rect().size
    debug_log("trace", "Camera initialized with screen size: " + str(screen_size))
    
    # Set up debug overlay if debug is enabled
    if debug_draw:
        setup_debug_overlay()
    
    # Find player
    yield(get_tree(), "idle_frame") # Wait for scene to be ready
    _find_player()
    
    # Set initial camera bounds based on parent district (if applicable)
    _setup_camera_bounds()
    
    # Set initial camera position
    _set_initial_camera_position()
    
    # Set up debug font if debug_draw is enabled
    if debug_draw:
        # Try to load a proper font or use Labels instead
        # Fix for the font rendering errors
        debug_font = DynamicFont.new()
        var font_path = "res://src/assets/fonts/Consolas.ttf"
        var default_font = "res://default_env.tres"
        
        # Try to load the specific font
        var specific_font = File.new()
        if specific_font.file_exists(font_path):
            debug_font.font_data = load(font_path)
            debug_log("overlay", "Loaded specific font for debug overlay")
        else:
            # If specific font doesn't exist, avoid null reference by using fallback
            debug_log("overlay", "Specific font not found, using alternative debug method")
            # We'll handle font rendering with labels instead
            _setup_debug_labels()

func _process(delta):
    if !target_player:
        return
        
    if follow_player:
        _handle_camera_movement(delta)
    
    # Only draw debug in editor or debug builds
    if OS.is_debug_build():
        if debug_draw:
            # Update visual debug elements
            update_debug_markers()
            update()
        
        # If using UI labels instead of direct font rendering
        _update_debug_labels()

# Update positions of all debug markers
func update_debug_markers():
    if not debug_overlay:
        return
        
    # Update each marker position
    for marker_name in debug_markers:
        var marker = debug_markers[marker_name]
        if marker_name.begins_with("rightedge"):
            # Update right edge marker position
            marker.rect_position = world_to_screen(debug_right_edge_position) - Vector2(marker.rect_size.x/2, marker.rect_size.y/2)
        elif marker_name.begins_with("calculated"):
            # Update calculated position marker
            marker.rect_position = world_to_screen(debug_calculated_position) - Vector2(marker.rect_size.x/2, marker.rect_size.y/2)

func _find_player():
    # Try to find player in the scene
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        target_player = players[0]
        print("Camera found player: " + target_player.name)
    else:
        print("WARNING: ScrollingCamera could not find a player node")

func _setup_camera_bounds():
    # If parent is a district, use its walkable area to determine bounds
    if get_parent() is BaseDistrict:
        var district = get_parent() as BaseDistrict
        # Calculate bounds from walkable areas
        camera_bounds = _calculate_district_bounds(district)
        print("Camera bounds set from district: ", camera_bounds)
    else:
        # Default bounds to screen size
        camera_bounds = Rect2(0, 0, screen_size.x, screen_size.y)
        print("Using default camera bounds based on screen size")

func _calculate_district_bounds(district) -> Rect2:
    # Create a Rect2 that encompasses all walkable areas
    var result_bounds = Rect2(0, 0, 0, 0)
    var first_point = true
    var all_points = []  # Store all points for verification
    
    print("\n========== DISTRICT BOUNDS CALCULATION STARTED ==========")
    print("Background dimensions: " + str(district.background_size) if "background_size" in district else "Unknown")
    print("Screen size: " + str(screen_size))
    print("Current camera zoom: " + str(zoom))
    print("Number of walkable areas: " + str(district.walkable_areas.size()))
    
    # Go through all walkable areas
    for area in district.walkable_areas:
        if area.polygon.size() == 0:
            print("WARNING: Empty polygon in walkable area")
            continue
            
        print("Processing walkable area: " + area.name + " with " + str(area.polygon.size()) + " points")
        print("Area transform: " + str(area.transform))
        
        # Process each point in the polygon
        for i in range(area.polygon.size()):
            var point = area.polygon[i]
            # Store local point for reference
            all_points.append({"local": point, "index": i})
            
            # Convert to global coordinates
            var global_point = area.to_global(point)
            all_points[all_points.size()-1]["global"] = global_point
            
            # Debug output for coordinate conversion
            print("Point " + str(i) + " - Local: " + str(point) + ", Global: " + str(global_point))
            
            if first_point:
                # Initialize bounds with first point
                result_bounds = Rect2(global_point, Vector2.ZERO)
                first_point = false
            else:
                # Expand bounds to include this point
                # Test if expand is working properly
                var prev_bounds = result_bounds
                result_bounds = result_bounds.expand(global_point)
                
                # Verify expand actually worked
                if prev_bounds == result_bounds:
                    # This is actually normal for rectangular polygons where the first point already defined the min/max
                    # We'll use a print instead of push_error to avoid scaring users, and still handle it correctly
                    print("Note: Rect2.expand() did not change bounds for point " + str(global_point) + 
                          " - this is normal for some polygon arrangements")
                    # Manually expand bounds if needed
                    result_bounds = Rect2(
                        min(result_bounds.position.x, global_point.x),
                        min(result_bounds.position.y, global_point.y),
                        max(result_bounds.end.x, global_point.x) - min(result_bounds.position.x, global_point.x),
                        max(result_bounds.end.y, global_point.y) - min(result_bounds.position.y, global_point.y)
                    )
    
    # If no walkable areas were found or bounds calculation failed, use a default area
    if first_point:
        print("WARNING: No valid walkable areas found, using default bounds")
        if "background_size" in district and district.background_size != Vector2.ZERO:
            # Default to background size if available
            result_bounds = Rect2(Vector2.ZERO, district.background_size)
        else:
            # Otherwise use screen size
            result_bounds = Rect2(0, 0, screen_size.x, screen_size.y)
    
    print("Raw calculated bounds: " + str(result_bounds))
    
    # SAFETY CHECKS AND CORRECTIONS
    
    # Check 1: Very small height (normal for floor walkable areas)
    if result_bounds.size.y < 100:
        # Log the info message - small heights are expected for floor walkable areas
        print("INFO: Walkable area height is " + str(result_bounds.size.y) + " pixels")
        print("This is normal for floor-based walkable areas")
        
        # Expand the height slightly for better camera behavior
        # Add some pixels above and below the walkable area for better visibility
        var center_y = result_bounds.position.y + result_bounds.size.y / 2
        var expanded_height = 200 # Enough to show some space above and below the floor
        result_bounds.position.y = center_y - expanded_height / 2
        result_bounds.size.y = expanded_height
        print("Adjusting camera height bounds to " + str(expanded_height) + " pixels for better visibility")
        print("This preserves the exact floor walkable area while improving camera view")
    
    # Check 2: Very small width (indicates possible calculation error)
    if result_bounds.size.x < 100:
        push_error("WARNING: Suspicious bounds width detected: " + str(result_bounds.size.x))
        
        # Similar correction as for height
        var center_x = result_bounds.position.x + result_bounds.size.x / 2
        result_bounds.position.x = center_x - 100
        result_bounds.size.x = 200
        print("Enforced minimum bounds width")
    
    # Check 3: Consider background size but don't automatically expand
    if "background_size" in district and district.background_size != Vector2.ZERO:
        var bg_size = district.background_size
        
        # If walkable area is significantly smaller than background, log a warning
        # but respect the custom walkable area coordinates
        if result_bounds.size.x < bg_size.x * 0.5 or result_bounds.size.y < bg_size.y * 0.5:
            print("NOTE: Walkable area is much smaller than background.")
            print("This is often intentional for floor-based walkable areas.")
            print("Using the exact walkable area as specified in the coordinates.")
    
    print("Final corrected bounds: " + str(result_bounds))
    print("========== DISTRICT BOUNDS CALCULATION COMPLETED ==========\n")
    
    return result_bounds

# Helper method to convert screen coordinates to world coordinates
# This ensures proper conversion regardless of zoom level
func screen_to_world(screen_pos: Vector2) -> Vector2:
    return global_position + ((screen_pos - get_viewport_rect().size/2) * zoom)

# Helper method to convert world coordinates to screen coordinates
# This ensures proper conversion regardless of zoom level
func world_to_screen(world_pos: Vector2) -> Vector2:
    return (world_pos - global_position) / zoom + get_viewport_rect().size/2

func _handle_camera_movement(delta):
    # Get player's position
    var player_pos = target_player.global_position
    
    # Get current camera view rect in world space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    
    # Calculate the area within the view that doesn't trigger scrolling
    var inner_margin = Rect2(
        current_view.position + edge_margin,
        current_view.size - (edge_margin * 2)
    )
    
    # Check if player is outside the inner margin area
    var needs_scroll = !inner_margin.has_point(player_pos)
    
    if needs_scroll:
        # Calculate intelligent target position based on player position relative to inner margin
        var target_pos = global_position
        
        # Determine which edge(s) the player is approaching/crossing
        var player_relative_to_inner = Vector2.ZERO
        
        # X-axis: Check if player is to the left or right of inner margin
        if player_pos.x < inner_margin.position.x:
            # Player is to the left of inner margin
            player_relative_to_inner.x = -1
        elif player_pos.x > inner_margin.position.x + inner_margin.size.x:
            # Player is to the right of inner margin
            player_relative_to_inner.x = 1
            
        # Y-axis: Check if player is above or below inner margin
        if player_pos.y < inner_margin.position.y:
            # Player is above inner margin
            player_relative_to_inner.y = -1
        elif player_pos.y > inner_margin.position.y + inner_margin.size.y:
            # Player is below inner margin
            player_relative_to_inner.y = 1
            
        # Calculate how much to adjust camera position to keep player in view
        if player_relative_to_inner.x != 0 or player_relative_to_inner.y != 0:
            # Option 1: Direct approach - move camera to center on player
            # This is a simple approach that always works but can feel jerky
            target_pos = player_pos
            
            # Option 2: More gradual approach - move camera just enough to bring player back within margins
            # This creates a more natural, controlled scrolling effect
            if player_relative_to_inner.x != 0:
                var margin_x = inner_margin.position.x if player_relative_to_inner.x < 0 else inner_margin.position.x + inner_margin.size.x
                var diff_x = player_pos.x - margin_x
                # Add an extra buffer to prevent oscillation
                diff_x += 5 * player_relative_to_inner.x
                target_pos.x = global_position.x + diff_x
                
            if player_relative_to_inner.y != 0:
                var margin_y = inner_margin.position.y if player_relative_to_inner.y < 0 else inner_margin.position.y + inner_margin.size.y
                var diff_y = player_pos.y - margin_y
                # Add an extra buffer to prevent oscillation
                diff_y += 5 * player_relative_to_inner.y
                target_pos.y = global_position.y + diff_y
        
        # Remember original target position before clamping
        var original_target_pos = target_pos
        
        # Apply bounds if enabled
        if bounds_enabled:
            # Ensure camera stays within bounds
            target_pos.x = clamp(
                target_pos.x,
                camera_bounds.position.x + camera_half_size.x,
                camera_bounds.position.x + camera_bounds.size.x - camera_half_size.x
            )
            target_pos.y = clamp(
                target_pos.y,
                camera_bounds.position.y + camera_half_size.y,
                camera_bounds.position.y + camera_bounds.size.y - camera_half_size.y
            )
        
        # Safety check for NaN values
        if is_nan(target_pos.x) or is_nan(target_pos.y):
            push_error("Camera target position contains NaN values!")
            target_pos = player_pos
        
        # Smoothly move camera with selected easing function
        var weight = follow_smoothing * delta
        global_position = _apply_easing(global_position, target_pos, weight)
        
        # Only call _ensure_player_visible if our target wasn't significantly clamped
        # This avoids camera oscillation when player is at the edges of bounds
        if original_target_pos.distance_to(target_pos) <= 10:
            _ensure_player_visible()

# Ensure the player character is visible after camera movement
func _ensure_player_visible():
    if !target_player:
        return
        
    # Get current camera view rect in world space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    
    # Check if player is within the view
    var player_pos = target_player.global_position
    if !current_view.has_point(player_pos):
        print("Player outside camera view - adjusting camera position")
        
        # Calculate how far outside the view the player is
        var distance_outside = Vector2()
        
        # X distance outside view
        if player_pos.x < current_view.position.x:
            distance_outside.x = player_pos.x - current_view.position.x
        elif player_pos.x > current_view.position.x + current_view.size.x:
            distance_outside.x = player_pos.x - (current_view.position.x + current_view.size.x)
        
        # Y distance outside view
        if player_pos.y < current_view.position.y:
            distance_outside.y = player_pos.y - current_view.position.y
        elif player_pos.y > current_view.position.y + current_view.size.y:
            distance_outside.y = player_pos.y - (current_view.position.y + current_view.size.y)
        
        # Adjust camera position to include player, with a small margin
        var margin = 20  # Extra pixels to add as buffer
        var new_camera_pos = global_position
        
        if distance_outside.x != 0:
            new_camera_pos.x += distance_outside.x + (margin * sign(distance_outside.x))
        
        if distance_outside.y != 0:
            new_camera_pos.y += distance_outside.y + (margin * sign(distance_outside.y))
        
        # Apply bounds if enabled
        if bounds_enabled:
            new_camera_pos.x = clamp(
                new_camera_pos.x,
                camera_bounds.position.x + camera_half_size.x,
                camera_bounds.position.x + camera_bounds.size.x - camera_half_size.x
            )
            new_camera_pos.y = clamp(
                new_camera_pos.y,
                camera_bounds.position.y + camera_half_size.y,
                camera_bounds.position.y + camera_bounds.size.y - camera_half_size.y
            )
        
        # Safety check for NaN values
        if is_nan(new_camera_pos.x) or is_nan(new_camera_pos.y):
            push_error("Camera position contains NaN values! Falling back to player position.")
            new_camera_pos = player_pos
            
        # Apply the position immediately to avoid oscillation
        var original_smoothing = smoothing_enabled
        smoothing_enabled = false
        global_position = new_camera_pos
        smoothing_enabled = original_smoothing
        
        # Verify player is now within view after adjustment
        var updated_view = Rect2(
            global_position - camera_half_size,
            camera_half_size * 2
        )
        
        if !updated_view.has_point(player_pos):
            push_error("Player still outside camera view after adjustment!")
            # Last resort: center directly on player
            global_position = player_pos
        
        print("Camera repositioned to: " + str(global_position) + " to keep player in view")

# Update camera bounds when the district changes
func update_bounds():
    if get_parent() is BaseDistrict:
        camera_bounds = _calculate_district_bounds(get_parent())

# Force camera to update its position and bounds immediately
func force_update_scroll():
    # Skip animation and set camera position directly
    update_bounds()
    
    # Reset smoothing temporarily to make the transition immediate
    var original_smoothing = smoothing_enabled
    var original_bounds_enabled = bounds_enabled
    smoothing_enabled = false
    
    # If we have an explicit initial position, respect it
    if initial_position != Vector2.ZERO:
        # Temporarily disable bounds to ensure position is honored exactly
        bounds_enabled = false
        global_position = initial_position
        print("Respecting explicit initial camera position: " + str(initial_position))
    
    # Process one frame to update camera
    force_update_transform()
    
    # Restore original settings
    smoothing_enabled = original_smoothing
    bounds_enabled = original_bounds_enabled
    
    print("Camera scroll position forcibly updated at: " + str(global_position))

# Calculate the optimal zoom level to ensure the background fills the viewport
func calculate_optimal_zoom():
    print("\n===== CALCULATING OPTIMAL ZOOM =====")
    # Get the district (parent) which has background information
    var district = get_parent()
    
    # Try to find a background node to get actual size
    var background_node = district.get_node_or_null("Background") if district else null
    var bg_texture_size = Vector2.ZERO
    
    if background_node and background_node is Sprite and background_node.texture:
        # Get unscaled texture size first
        bg_texture_size = background_node.texture.get_size()
        print("Found background sprite with texture size: " + str(bg_texture_size))
        
        # Apply any existing scale to get effective size
        var bg_scale = background_node.scale
        var effective_bg_size = Vector2(bg_texture_size.x * bg_scale.x, bg_texture_size.y * bg_scale.y)
        print("Current background scale: " + str(bg_scale))
        print("Effective background size with current scale: " + str(effective_bg_size))
        
        # Calculate proper scale to fill viewport height exactly
        var height_scale = screen_size.y / bg_texture_size.y
        print("Scale needed to fill viewport height: " + str(height_scale))
        
        # Apply the scale to the background
        background_node.scale = Vector2(height_scale, height_scale)
        print("Applied new scale to background: " + str(background_node.scale))
        
        # Center the background vertically - CRITICAL for proper display
        if background_node.centered == false:
            # For non-centered sprites, we need to calculate precise y position for vertical centering
            # This ensures no gray bars at top or bottom
            var viewport_height = screen_size.y
            var scaled_height = bg_texture_size.y * height_scale
            
            # Position y=0 would align to top, we need to offset to center it
            # When scaled_height == viewport_height, this will be 0
            var y_offset = 0
            if scaled_height != viewport_height:
                y_offset = (viewport_height - scaled_height) / 2
            
            background_node.position.y = y_offset
            print("[SCALING DEBUG] Background vertical positioning applied:")
            print("[SCALING DEBUG] - Viewport height: " + str(viewport_height))
            print("[SCALING DEBUG] - Scaled background height: " + str(scaled_height))
            print("[SCALING DEBUG] - Applied y_offset: " + str(y_offset))
        
        # Get the new effective size
        effective_bg_size = Vector2(bg_texture_size.x * height_scale, bg_texture_size.y * height_scale)
        print("New effective background size: " + str(effective_bg_size))
        
        # Keep standard zoom at 1.0 since we're scaling the background instead
        zoom = Vector2(1.0, 1.0)
        print("Camera zoom left at 1.0 (since we're scaling the background)")
        
        # Update district's background_size property if it exists
        if district is BaseDistrict and "background_size" in district:
            district.background_size = effective_bg_size
            print("Updated district.background_size to " + str(effective_bg_size))
        
        # Update camera bounds if needed
        if bounds_enabled and district is BaseDistrict:
            camera_bounds = Rect2(0, 0, effective_bg_size.x, effective_bg_size.y)
            print("Updated camera bounds to match scaled background: " + str(camera_bounds))
            
        # Store scaled size in the district if possible
        if district and "background_size" in district:
            district.background_size = effective_bg_size
    
    # Use district background_size as fallback
    elif district is BaseDistrict and "background_size" in district and district.background_size != Vector2.ZERO:
        var bg_size = district.background_size
        print("Using district background_size: " + str(bg_size))
        
        # Calculate zoom based on height ratio
        var height_ratio = bg_size.y / screen_size.y
        var zoom_value = height_ratio
        
        # Clamp zoom level to reasonable bounds
        zoom_value = clamp(zoom_value, min_zoom, max_zoom)
        
        # Apply the zoom
        zoom = Vector2(zoom_value, zoom_value)
        print("Applied zoom to camera: " + str(zoom))
    else:
        print("Could not find background information - camera zoom unchanged")
    
    print("===== ZOOM CALCULATION COMPLETE =====\n")
    return zoom

func _set_initial_camera_position():
    print("\n===== CAMERA INITIAL POSITION SETUP =====")
    print("Current camera position: " + str(global_position))
    print("Initial position setting: " + str(initial_position))
    print("Initial view setting: " + str(initial_view))
    print("Screen size: " + str(screen_size))
    
    # First calculate and apply optimal zoom if enabled
    if auto_adjust_zoom:
        calculate_optimal_zoom()
    
    if camera_bounds.size == Vector2.ZERO:
        # If bounds aren't set yet, create reasonable default bounds
        print("WARNING: Camera bounds are zero size. Creating default bounds.")
        var district = get_parent()
        if district is BaseDistrict and "background_size" in district and district.background_size != Vector2.ZERO:
            camera_bounds = Rect2(0, 0, district.background_size.x, district.background_size.y)
            print("Created default bounds from district background size: " + str(camera_bounds))
        else:
            # Use screen size as fallback
            camera_bounds = Rect2(0, 0, get_viewport_rect().size.x, get_viewport_rect().size.y)
            print("Created default bounds from screen size: " + str(camera_bounds))
    
    # If an explicit initial position is set, use that
    if initial_position != Vector2.ZERO:
        print("Using explicit initial position: " + str(initial_position))
        global_position = initial_position
        print("Camera positioned at custom initial position: " + str(initial_position))
        print("Final camera position after setting: " + str(global_position))
        print("===== CAMERA INITIAL POSITION SETUP COMPLETE =====\n")
        return
    
    # Otherwise, use the initial_view setting to determine position
    var camera_half_size = screen_size / 2 / zoom
    var new_position = Vector2.ZERO
    
    print("Camera half size (screen size / 2 / zoom): " + str(camera_half_size))
    print("Camera bounds: " + str(camera_bounds))
    
    # Ensure we're only showing a portion of the background based on the view ratio
    # First check if the background is wide enough to scroll (at least 1.5x screen width)
    var scroll_enabled = camera_bounds.size.x >= screen_size.x * 1.5
    print("Background wide enough for scrolling: " + str(scroll_enabled))
    print("Background width: " + str(camera_bounds.size.x) + ", Min width for scrolling: " + str(screen_size.x * 1.5))
    
    match initial_view.to_lower():
        "left":
            print("Using LEFT initial view setting")
            if scroll_enabled:
                # Position camera to show only the left portion of the background
                # We want to show the leftmost portion of the background
                # We need to position the camera so that the left edge of the screen aligns with the left edge of the background
                # Calculate by adding half the screen width to the left edge of the bounds
                var screen_half_width = get_viewport_rect().size.x / 2 / zoom.x
                var left_side_position = camera_bounds.position.x + screen_half_width
                print("Left side position calculation: Left edge " + str(camera_bounds.position.x) + 
                      " + half screen width " + str(screen_half_width) + " = " + str(left_side_position))
                new_position = Vector2(
                    left_side_position,
                    camera_bounds.position.y + camera_bounds.size.y / 2
                )
                print("Positioning camera at left portion: " + str(new_position))
            else:
                # If background isn't wide enough, center it
                new_position = Vector2(
                    camera_bounds.position.x + camera_bounds.size.x / 2,
                    camera_bounds.position.y + camera_bounds.size.y / 2
                )
                print("Warning: Background not wide enough for scrolling - centering instead: " + str(new_position))
            
        "right":
            print("Using RIGHT initial view setting")
            if scroll_enabled:
                # Position camera to show the rightmost portion of the background
                # First try to find the actual background sprite to get accurate dimensions
                var district = get_parent()
                var background_node = district.get_node_or_null("Background") if district else null
                var full_bg_width = 0
                var effective_height = 0
                
                if background_node and background_node is Sprite and background_node.texture:
                    # Calculate the effective width and height with the current scale
                    var bg_texture_size = background_node.texture.get_size()
                    var scale = background_node.scale
                    full_bg_width = bg_texture_size.x * scale.x
                    effective_height = bg_texture_size.y * scale.y
                    print("Using scaled background dimensions: " + str(full_bg_width) + "x" + str(effective_height))
                elif district is BaseDistrict and "background_size" in district and district.background_size != Vector2.ZERO:
                    # Use district background_size as fallback
                    full_bg_width = district.background_size.x
                    effective_height = district.background_size.y
                    print("Using district background_size: " + str(full_bg_width) + "x" + str(effective_height))
                else:
                    # Fallback to camera bounds if full background size not available
                    full_bg_width = camera_bounds.position.x + camera_bounds.size.x
                    effective_height = camera_bounds.position.y + camera_bounds.size.y
                    print("Using camera bounds: " + str(full_bg_width) + "x" + str(effective_height))
                
                # Calculate position accounting for zoom and screen width
                var viewport_size = get_viewport_rect().size
                var screen_half_width = viewport_size.x / 2 / zoom.x
                
                debug_log("camera", "Step 1: Calculating right side position", "RIGHT_VIEW")
                
                # Position camera to show the extreme right edge of the background
                # Subtract half screen width from total background width to show right edge
                var right_side_position = full_bg_width - screen_half_width
                
                # Ensure vertical center positioning
                var center_y = effective_height / 2
                
                debug_log("camera", "Right side position calculation:", "RIGHT_VIEW")
                debug_log("camera", "- Full background width: " + str(full_bg_width), "RIGHT_VIEW")
                debug_log("camera", "- Viewport size: " + str(viewport_size), "RIGHT_VIEW")
                debug_log("camera", "- Half screen width (adjusted for zoom): " + str(screen_half_width), "RIGHT_VIEW")
                debug_log("camera", "- Vertical center: " + str(center_y), "RIGHT_VIEW")
                debug_log("camera", "- Calculated horizontal position: " + str(right_side_position), "RIGHT_VIEW")
                
                # Store the target position for debugging (before any adjustments)
                debug_right_edge_position = Vector2(right_side_position, center_y)
                
                # Create visual debug marker at right edge position if debugging is enabled
                if debug_draw and OS.is_debug_build():
                    create_debug_marker(debug_right_edge_position, Color(1, 0, 0, 0.8), 20, "rightedge")
                    debug_log("overlay", "Created right edge position marker at " + str(debug_right_edge_position), "RIGHT_VIEW")
                
                # Create final camera position
                new_position = Vector2(right_side_position, center_y)
                debug_log("camera", "Step 2: Initial camera position for RIGHT view: " + str(new_position), "RIGHT_VIEW")
                
                # Apply a small adjustment if needed to ensure extreme right edge is visible
                # We add a tiny buffer of 5 pixels to avoid any rounding issues
                if background_node and right_side_position + screen_half_width < full_bg_width:
                    var adjustment = full_bg_width - (right_side_position + screen_half_width) + 5
                    new_position.x += adjustment
                    debug_log("camera", "Step 3: Applied adjustment of " + str(adjustment) + " pixels to show extreme right edge", "RIGHT_VIEW")
                    debug_log("camera", "Step 3: Adjusted final position: " + str(new_position), "RIGHT_VIEW")
                
                # Store the calculated position for debugging (after adjustments)
                debug_calculated_position = new_position
                
                # Create visual debug marker for calculated position
                if debug_draw and OS.is_debug_build():
                    create_debug_marker(debug_calculated_position, Color(0, 1, 0, 0.8), 20, "calculated")
                    debug_log("overlay", "Created calculated position marker at " + str(debug_calculated_position), "RIGHT_VIEW")
            else:
                # If background isn't wide enough, center it
                new_position = Vector2(
                    camera_bounds.position.x + camera_bounds.size.x / 2,
                    camera_bounds.position.y + camera_bounds.size.y / 2
                )
                print("Centering camera on walkable area: " + str(new_position))
            
        "center", _:
            print("Using CENTER initial view setting")
            # Default to center of the background
            new_position = Vector2(
                camera_bounds.position.x + camera_bounds.size.x / 2,
                camera_bounds.position.y + camera_bounds.size.y / 2
            )
            print("Positioning camera at center: " + str(new_position))
    
    # Apply the position
    print("Setting camera position to: " + str(new_position))
    global_position = new_position
    print("Camera position after setting: " + str(global_position))
    
    # Safety check: Make sure camera isn't too far from reasonable bounds
    var district = get_parent()
    print("[CAMERA DEBUG] Checking camera position against walkable area center")
    if district is BaseDistrict and district.walkable_areas.size() > 0:
        var walkable_area = district.walkable_areas[0]
        if walkable_area and walkable_area.polygon.size() > 0:
            # Calculate center of walkable area
            var center = Vector2.ZERO
            print("[CAMERA DEBUG] Walkable area polygon points: " + str(walkable_area.polygon))
            for point in walkable_area.polygon:
                center += point
            center /= walkable_area.polygon.size()
            center = walkable_area.to_global(center)
            print("[CAMERA DEBUG] Calculated walkable area center: " + str(center))
            
            # Check if camera is too far from walkable area center
            var distance = global_position.distance_to(center)
            print("[CAMERA DEBUG] Distance from camera to walkable center: " + str(distance))
            
            # IMPORTANT: Don't override camera position for edge views
            # This prevents the safety check from interfering with showing edges
            if distance > 1000 and initial_view != "right" and initial_view != "left":
                print("[CAMERA DEBUG] WARNING: Camera positioned too far from walkable area center.")
                print("[CAMERA DEBUG] Camera: " + str(global_position) + ", Walkable center: " + str(center))
                print("[CAMERA DEBUG] Adjusting camera to use walkable area center")
                global_position = center
                print("[CAMERA DEBUG] Camera position adjusted to: " + str(global_position))
            elif initial_view == "right" or initial_view == "left":
                print("[CAMERA DEBUG] Maintaining edge view position despite distance from walkable area")
                print("[CAMERA DEBUG] Current camera position: " + str(global_position))
    
    # Calculate and print view ratio for debugging
    var view_width = screen_size.x / zoom.x
    var view_ratio = view_width / camera_bounds.size.x * 100
    print("Camera positioned for initial view: " + initial_view + " at " + str(global_position))
    print("View ratio: " + str(round(view_ratio)) + "% of background is visible (" + 
          str(view_width) + " pixels of " + str(camera_bounds.size.x) + " pixels)")
    print("===== CAMERA INITIAL POSITION SETUP COMPLETE =====\n")

# Set up UI labels for debug info (alternative to font rendering)
func _setup_debug_labels():
    # Create a canvas layer that stays relative to the camera view
    var canvas = CanvasLayer.new()
    canvas.name = "DebugCanvas"
    canvas.layer = 100  # Make sure it's on top
    add_child(canvas)
    
    # Create a control container for all labels
    var container = Control.new()
    container.name = "DebugLabels"
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(container)
    
    # Create background panel for better readability
    var panel = ColorRect.new()
    panel.name = "DebugBackground"
    panel.color = Color(0, 0, 0, 0.5)
    panel.rect_position = Vector2(10, 10)
    panel.rect_size = Vector2(300, 100)
    container.add_child(panel)
    
    # Create labels for debug info
    var labels = [
        {"name": "CameraPos", "text": "Camera: ", "position": Vector2(15, 15)},
        {"name": "PlayerPos", "text": "Player: ", "position": Vector2(15, 35)},
        {"name": "EasingType", "text": "Easing: ", "position": Vector2(15, 55)},
        {"name": "ViewRatio", "text": "View: ", "position": Vector2(15, 75)}
    ]
    
    for label_info in labels:
        var label = Label.new()
        label.name = label_info.name
        label.text = label_info.text
        label.rect_position = label_info.position
        label.add_color_override("font_color", Color(1, 1, 0))
        container.add_child(label)
    
    # Create a container for the inner margin visualization
    var margin_vis = ColorRect.new()
    margin_vis.name = "MarginVisualization"
    margin_vis.color = Color(0, 1, 0, 0.2)
    margin_vis.rect_position = edge_margin
    margin_vis.rect_size = get_viewport_rect().size - (edge_margin * 2)
    container.add_child(margin_vis)
    
    print("Set up UI-based debug display as alternative to font rendering")

# Update debug UI labels (called from _process)
func _update_debug_labels():
    var canvas = get_node_or_null("DebugCanvas")
    if !canvas:
        return
        
    var container = canvas.get_node_or_null("DebugLabels")
    if !container:
        return
    
    # Update camera position label
    var cam_label = container.get_node_or_null("CameraPos")
    if cam_label:
        cam_label.text = "Camera: " + str(global_position)
    
    # Update player position label
    var player_label = container.get_node_or_null("PlayerPos")
    if player_label and target_player:
        player_label.text = "Player: " + str(target_player.global_position)
    
    # Update easing type label
    var easing_label = container.get_node_or_null("EasingType")
    if easing_label:
        var easing_names = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
        easing_label.text = "Easing: " + easing_names[easing_type]
    
    # Update view ratio label
    var ratio_label = container.get_node_or_null("ViewRatio")
    if ratio_label:
        var view_width = screen_size.x / zoom.x
        var view_ratio = view_width / camera_bounds.size.x * 100
        ratio_label.text = "View: " + str(round(view_ratio)) + "% visible"
    
    # Update margin visualization
    var margin_vis = container.get_node_or_null("MarginVisualization")
    if margin_vis:
        margin_vis.rect_position = edge_margin
        margin_vis.rect_size = get_viewport_rect().size - (edge_margin * 2)

# For debugging - draw the camera bounds and margins
func _draw():
    if !debug_draw:
        return
        
    # Get current camera view in global space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        Vector2.ZERO - camera_half_size,
        camera_half_size * 2
    )
    
    # Draw camera edges
    draw_rect(current_view, Color(1, 1, 1, 0.3), false)
    
    # Draw scroll trigger area
    var inner_margin = Rect2(
        current_view.position + edge_margin,
        current_view.size - (edge_margin * 2)
    )
    draw_rect(inner_margin, Color(0, 1, 0, 0.3), false)
    
    # Draw text only if we have a valid font
    if debug_font and debug_font.get_height() > 0:
        var text = "Camera Position: " + str(global_position)
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 20), text, Color(1, 1, 0))
        
        if target_player:
            text = "Player Position: " + str(target_player.global_position)
            draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 40), text, Color(1, 1, 0))
            
        # Add easing type to debug display
        var easing_names = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
        text = "Easing: " + easing_names[easing_type]
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 60), text, Color(1, 1, 0))
        
        # Add view ratio information
        var view_width = screen_size.x / zoom.x
        var view_ratio = view_width / camera_bounds.size.x * 100
        text = "View ratio: " + str(round(view_ratio)) + "% visible"
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 80), text, Color(1, 1, 0))
    else:
        # If font rendering fails, we'll use UI labels instead (set up in _setup_debug_labels)
        _update_debug_labels()

# Apply the selected easing function to interpolate between start and end positions
func _apply_easing(start_pos: Vector2, end_pos: Vector2, weight: float) -> Vector2:
    # Clamp weight to [0, 1] range
    weight = clamp(weight, 0, 1)
    
    # Apply the selected easing based on the enum
    match easing_type:
        EasingType.LINEAR:
            return start_pos.linear_interpolate(end_pos, weight)
            
        EasingType.EASE_IN:
            # Quadratic ease in: t²
            var factor = weight * weight
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.EASE_OUT:
            # Quadratic ease out: 1-(1-t)²
            var factor = 1.0 - (1.0 - weight) * (1.0 - weight)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.EASE_IN_OUT:
            # Quadratic ease in/out
            var factor = 2 * weight * weight if weight < 0.5 else 1 - pow(-2 * weight + 2, 2) / 2
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.EXPONENTIAL:
            # Exponential ease out
            var factor = 1 - pow(2, -10 * weight)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.SINE:
            # Sine-based easing (smooth)
            var factor = sin(weight * PI/2)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.ELASTIC:
            # Elastic easing (bouncy)
            var c4 = (2 * PI) / 3
            var factor = 0.0
            
            if weight == 0:
                factor = 0
            elif weight == 1:
                factor = 1
            else:
                factor = pow(2, -10 * weight) * sin((weight * 10 - 0.75) * c4) + 1
                
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.CUBIC:
            # Cubic ease out
            var factor = 1 - pow(1 - weight, 3)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.QUAD:
            # Quadratic ease out (same as EASE_OUT but listed separately for clarity)
            var factor = 1 - pow(1 - weight, 2)
            return start_pos.linear_interpolate(end_pos, factor)
            
        _:  # Default to linear if unknown type
            return start_pos.linear_interpolate(end_pos, weight)