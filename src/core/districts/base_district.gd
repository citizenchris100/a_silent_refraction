extends Node2D
class_name BaseDistrict

# Preload the CoordinateSystem class
var CoordinateSystem = preload("res://src/core/coordinate_system.gd")

# District properties
export var district_name = "Unknown District"
export var district_description = "A district on the station"
export var animated_elements_config = ""  # Path to JSON config for animated elements
export var background_size = Vector2(3000, 1500)  # Default background size for camera bounds and calculations
export var background_scale_factor = 1.0  # Scale factor for coordinate transformations between views

# Camera properties
export var use_scrolling_camera = false  # Whether this district uses scrolling camera
export var camera_follow_smoothing = 5.0  # Camera smoothing factor
export var camera_edge_margin = Vector2(150, 100)  # Distance from edge to trigger scrolling
export(String, "left", "right", "center") var initial_camera_view = "right"  # Initial camera view position
export var camera_initial_position = Vector2.ZERO  # Custom initial position (overrides initial_camera_view if not zero)
export(String, "LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD") var camera_easing_type = "SINE"  # Easing type for camera movement

# Areas where the player can walk
var walkable_areas = []

# Interactive objects in this district
var interactive_objects = []

# Animated background elements manager
var animated_bg_manager = null

# Other components
var camera = null

# Signals
signal district_entered(district_name)
signal district_exited(district_name)

func _ready():
    # Initialize the district
    print(district_name + " loaded")

    # Add to district group
    add_to_group("district")
    
    # Register this district with the CoordinateManager
    CoordinateManager.set_current_district(self)
    print("Registered district with CoordinateManager")

    # Clear active walkable areas before searching
    walkable_areas.clear()

    # First, handle any "designer_walkable_area" marked walkable areas
    # These take precedence over generic walkable_area groups
    var designer_areas_found = false
    
    for child in get_children():
        if child.is_in_group("designer_walkable_area"):
            # This is a specially marked walkable area from the designer
            walkable_areas.append(child)
            designer_areas_found = true
            print("Using designer-marked walkable area: " + child.name)
            
    # If no designer walkable areas were found, fall back to regular walkable areas
    if not designer_areas_found:
        for child in get_children():
            if child.is_in_group("walkable_area") and !child.is_in_group("debug_walkable_area"):
                walkable_areas.append(child)
                print("Using standard walkable area: " + child.name)
                
    # Find interactive objects
    for child in get_children():
        if child.is_in_group("interactive_object"):
            interactive_objects.append(child)
            
        # Check if we already have a camera as a child
        if child is Camera2D:
            camera = child
            print("Found existing camera in district")

    # Initialize animated background elements
    initialize_animated_elements()

    # Setup scrolling camera if enabled
    if use_scrolling_camera:
        setup_scrolling_camera()

    # Emit signal
    emit_signal("district_entered", district_name)

# Initialize the animated background elements
func initialize_animated_elements():
    # Create the manager
    animated_bg_manager = AnimatedBackgroundManager.new(self)

    # If a config path is provided, load from it
    if animated_elements_config != "":
        var config_path = animated_elements_config

        # If not an absolute path, assume it's relative to the district
        if not config_path.begins_with("res://"):
            var script_path = get_script().get_path().get_base_dir()
            config_path = script_path + "/" + config_path

        # Load the animated elements
        animated_bg_manager.load_from_config(config_path)
    else:
        # Check if we have a default config file in the district folder
        var script_path = get_script().get_path().get_base_dir()
        var default_config = script_path + "/animated_elements_config.json"

        var file = File.new()
        if file.file_exists(default_config):
            animated_bg_manager.load_from_config(default_config)

# Add an animated element at runtime
func add_animated_element(type, id, position, properties = {}):
    if animated_bg_manager:
        return animated_bg_manager.add_element(type, id, position, properties)
    return null

# Get a specific animated element
func get_animated_element(type, id):
    if animated_bg_manager:
        return animated_bg_manager.get_element(type, id)
    return null

# Toggle all elements of a specific type
func toggle_animated_elements(type, enabled):
    if animated_bg_manager:
        animated_bg_manager.toggle_elements_by_type(type, enabled)

# Check if a position is in a walkable area
func is_position_walkable(position):
    for area in walkable_areas:
        # Transform position to area's local space
        var local_pos = area.to_local(position)
        
        # Check if the point is in the polygon
        var polygon = area.polygon
        if Geometry.is_point_in_polygon(local_pos, polygon):
            return true
    return false

# Check if an entire path is within walkable areas
func is_path_valid(path_points: Array) -> bool:
    if path_points.empty():
        return true
        
    for point in path_points:
        if not is_position_walkable(point):
            return false
    return true

# Find the closest walkable point to a given position
func get_closest_walkable_point(position: Vector2) -> Vector2:
    # If the position is already walkable, return it
    if is_position_walkable(position):
        return position
    
    var closest_point = position
    var min_distance = INF
    
    # Check all walkable areas
    for area in walkable_areas:
        if area.polygon.size() < 3:
            continue
            
        # Find the closest point on the polygon edges
        for i in range(area.polygon.size()):
            var p1 = area.to_global(area.polygon[i])
            var p2 = area.to_global(area.polygon[(i + 1) % area.polygon.size()])
            
            # Find closest point on this edge
            var edge_closest = _get_closest_point_on_segment(position, p1, p2)
            var distance = position.distance_to(edge_closest)
            
            if distance < min_distance:
                min_distance = distance
                closest_point = edge_closest
    
    return closest_point

# Helper function to find the closest point on a line segment
func _get_closest_point_on_segment(point: Vector2, segment_start: Vector2, segment_end: Vector2) -> Vector2:
    var segment = segment_end - segment_start
    var segment_length_squared = segment.length_squared()
    
    # Handle degenerate case where segment is a point
    if segment_length_squared == 0:
        return segment_start
    
    # Calculate projection of point onto the line
    var t = clamp((point - segment_start).dot(segment) / segment_length_squared, 0.0, 1.0)
    
    # Return the closest point on the segment
    return segment_start + segment * t

# Debug function to test walkable boundaries
func test_walkable_boundaries():
    var screen_size = get_viewport_rect().size
    var test_points = []
    var results = []

    # Create a grid of test points
    for x in range(0, int(screen_size.x), 50):
        for y in range(0, int(screen_size.y), 50):
            var point = Vector2(x, y)
            test_points.append(point)
            results.append(is_position_walkable(point))

    # Output results to a debug visualization node
    var debug_node = Node2D.new()
    debug_node.name = "WalkableBoundaryTest"
    add_child(debug_node)

    for i in range(test_points.size()):
        var point = test_points[i]
        var is_walkable = results[i]

        # Only show markers for walkable areas to reduce visual clutter
        if is_walkable:
            var marker = ColorRect.new()
            marker.rect_size = Vector2(5, 5)
            marker.rect_position = point - Vector2(2.5, 2.5)
            marker.color = Color(0.2, 0.8, 0.3, 0.3)  # More transparent green
            debug_node.add_child(marker)

    print("Created walkable boundary test with " + str(test_points.size()) + " points")
    return {"walkable": results.count(true), "unwalkable": results.count(false)}

# Set up the scrolling camera for this district
func setup_scrolling_camera():
    # If we already have a camera, configure it
    if camera != null:
        # Update camera settings
        camera.follow_smoothing = camera_follow_smoothing
        camera.edge_margin = camera_edge_margin
        
        # Set initial view settings
        if "initial_view" in camera:
            camera.initial_view = initial_camera_view
        
        if "initial_position" in camera and camera_initial_position != Vector2.ZERO:
            camera.initial_position = camera_initial_position
            
        # Set easing type
        if "easing_type" in camera:
            # Match the string with the EasingType enum value in the camera
            var easing_types = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
            var index = easing_types.find(camera_easing_type)
            if index != -1:
                camera.easing_type = index
        
        camera.update_bounds()
        print("Updated existing camera in " + district_name)
        return

    # Otherwise, create a new scrolling camera
    var camera_script = load("res://src/core/camera/scrolling_camera.gd")
    if camera_script:
        camera = Camera2D.new()
        camera.name = "ScrollingCamera"
        camera.set_script(camera_script)
        camera.follow_smoothing = camera_follow_smoothing
        camera.edge_margin = camera_edge_margin
        
        # Set initial view settings
        if camera_initial_position != Vector2.ZERO:
            camera.initial_position = camera_initial_position
        else:
            camera.initial_view = initial_camera_view
            
        # Set easing type
        var easing_types = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
        var index = easing_types.find(camera_easing_type)
        if index != -1:
            camera.easing_type = index

        # In development/debug builds, enable debug drawing
        if OS.is_debug_build():
            camera.debug_draw = true

        add_child(camera)
        print("Added scrolling camera to " + district_name + " with initial view: " + initial_camera_view)
    else:
        push_error("Failed to load ScrollingCamera scene!")

# Setup player character with the standard point-and-click navigation system
# This method implements the DRY principle by providing reusable player setup for all districts
func setup_player_and_controller(start_position = Vector2.ZERO):
    # Default player position if not specified
    if start_position == Vector2.ZERO:
        start_position = Vector2(400, 300)
    
    # Add the player character from the standard player scene
    var player_scene = load("res://src/characters/player/player.tscn")
    if player_scene:
        var player = player_scene.instance()
        player.position = start_position
        add_child(player)
        print("Added standard player character at position " + str(start_position))
        
        # Make the camera follow the player
        if camera:
            camera.follow_player = true
            camera.target_player = player
            print("Camera set to follow player")
        
        # Add the player controller to handle point-and-click navigation
        var controller_scene = load("res://src/core/player_controller.gd")
        if controller_scene:
            var controller = Node.new()
            controller.name = "PlayerController"
            controller.set_script(controller_scene)
            add_child(controller)
            print("Added standard player controller for point-and-click navigation")
        else:
            print("WARNING: Could not load player controller script")
    else:
        print("WARNING: Could not load player scene")

# Exit this district
func exit_district():
    # Clean up animated elements
    if animated_bg_manager:
        animated_bg_manager._on_district_exited()

    emit_signal("district_exited", district_name)

# This method will be implemented in a future iteration
func register_locations():
    return {}

# Convert screen coordinates to world coordinates
# This transforms screen space coordinates (like mouse position) to world coordinates
func screen_to_world_coords(screen_pos: Vector2) -> Vector2:
    # Validate input
    if screen_pos == null:
        print("WARNING: screen_to_world_coords received null position")
        return Vector2.ZERO
    
    # Ensure CoordinateManager is using this district
    CoordinateManager.set_current_district(self)
    
    # Use CoordinateManager to transform coordinates
    var world_pos = CoordinateManager.transform_coordinates(
        screen_pos, 
        CoordinateManager.CoordinateSpace.SCREEN_SPACE, 
        CoordinateManager.CoordinateSpace.WORLD_SPACE
    )
    
    # Print debug info
    print("BaseDistrict.screen_to_world_coords: " + str(screen_pos) + " → " + str(world_pos))
    print("Used CoordinateManager for transformation")
    
    return world_pos

# Convert world coordinates to screen coordinates
# This transforms world coordinates to screen space (e.g., for UI positioning)
func world_to_screen_coords(world_pos: Vector2) -> Vector2:
    # Validate input
    if world_pos == null:
        print("WARNING: world_to_screen_coords received null position")
        return Vector2.ZERO
    
    # Ensure CoordinateManager is using this district
    CoordinateManager.set_current_district(self)
    
    # Use CoordinateManager to transform coordinates
    var screen_pos = CoordinateManager.transform_coordinates(
        world_pos, 
        CoordinateManager.CoordinateSpace.WORLD_SPACE, 
        CoordinateManager.CoordinateSpace.SCREEN_SPACE
    )
    
    # Print debug info
    print("BaseDistrict.world_to_screen_coords: " + str(world_pos) + " → " + str(screen_pos))
    print("Used CoordinateManager for transformation")
    
    return screen_pos

# Get the camera in this district
func get_camera() -> Camera2D:
    # Check if we already have a camera reference
    if camera != null:
        return camera
        
    # Find any camera in the district
    for child in get_children():
        if child is Camera2D:
            camera = child
            return camera
    return null
