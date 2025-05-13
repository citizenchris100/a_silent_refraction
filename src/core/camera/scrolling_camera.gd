extends Camera2D
# ScrollingCamera: Handles camera movement for larger-than-screen backgrounds

# Camera properties
export var follow_player: bool = true
export var follow_smoothing: float = 5.0
export var edge_margin: Vector2 = Vector2(150, 100) # Distance from edge that triggers scrolling
export var bounds_enabled: bool = true

# Variables
var target_player: Node2D = null
var screen_size: Vector2
var camera_bounds: Rect2

# Debug
export var debug_draw: bool = false
var debug_font: Font

func _ready():
    # Setup camera properties
    current = true # Make this the active camera
    smoothing_enabled = true
    smoothing_speed = follow_smoothing
    
    # Get screen size
    screen_size = get_viewport_rect().size
    
    # Find player
    yield(get_tree(), "idle_frame") # Wait for scene to be ready
    _find_player()
    
    # Set initial camera bounds based on parent district (if applicable)
    _setup_camera_bounds()
    
    # Set up debug font if debug_draw is enabled
    if debug_draw:
        debug_font = DynamicFont.new()
        debug_font.font_data = load("res://default_env.tres") # Use default font
        debug_font.size = 16

func _process(delta):
    if !target_player:
        return
        
    if follow_player:
        _handle_camera_movement(delta)
    
    # Only draw debug in editor or debug builds
    if debug_draw and OS.is_debug_build():
        update()

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
    
    # Go through all walkable areas
    for area in district.walkable_areas:
        if area.polygon.size() == 0:
            continue
            
        # Process each point in the polygon
        for point in area.polygon:
            # Convert to global coordinates
            var global_point = area.to_global(point)
            
            if first_point:
                # Initialize bounds with first point
                result_bounds = Rect2(global_point, Vector2.ZERO)
                first_point = false
            else:
                # Expand bounds to include this point
                result_bounds = result_bounds.expand(global_point)
    
    # If no walkable areas were found, use a default area
    if first_point:
        result_bounds = Rect2(0, 0, screen_size.x, screen_size.y)
    
    return result_bounds

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
        # Calculate target position
        var target_pos = player_pos
        
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
        
        # Smoothly move camera
        global_position = global_position.linear_interpolate(target_pos, follow_smoothing * delta)

# Update camera bounds when the district changes
func update_bounds():
    if get_parent() is BaseDistrict:
        camera_bounds = _calculate_district_bounds(get_parent())

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
    
    # Draw text
    var text = "Camera Position: " + str(global_position)
    draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 20), text, Color(1, 1, 0))
    
    if target_player:
        text = "Player Position: " + str(target_player.global_position)
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 40), text, Color(1, 1, 0))