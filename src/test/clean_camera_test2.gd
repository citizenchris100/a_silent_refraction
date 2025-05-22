extends "res://src/core/districts/base_district.gd"

# Clean Camera Test 2 - Template for new districts with enhanced camera system
# This template provides a minimal starter setup with a default walkable area
# that allows the scene to launch for proper coordinate capture.
# 
# USAGE:
# 1. Launch this scene
# 2. Press Alt+W to enter World View mode
# 3. Capture coordinates for your actual walkable area
# 4. Replace the square walkable area with your captured coordinates

export var background_path = "res://src/assets/backgrounds/test_background.png"
var coordinate_display
var transition_test_running = false

func _ready():
	# Setup district properties
	district_name = "District Template"
	district_description = "A template for districts with the enhanced camera system"
	
	# Configure the camera system for Wide 2D Scrolling type
	use_scrolling_camera = true
	initial_camera_view = "left"  # Start with left view for this template
	
	# Setup background - following the guidelines from background_dimensions.md
	var background = Sprite.new()
	background.name = "Background"
	background.texture = load(background_path)
	background.centered = false  # Required for Wide 2D Scrolling type
	
	# Let the camera system handle background scaling - don't pre-scale here
	var viewport_size = get_viewport().get_size()
	var texture_size = background.texture.get_size()
	
	print("Background dimensions: Width=" + str(texture_size.x) + ", Height=" + str(texture_size.y))
	print("Viewport dimensions: Width=" + str(viewport_size.x) + ", Height=" + str(viewport_size.y))
	print("Camera system will handle background scaling automatically")
	
	# Add background without scaling - let camera system handle it
	add_child(background)
	
	# Store the original background size - camera system will update this
	background_size = texture_size
	print("Original background size: " + str(background_size))
	
	# Create walkable area
	create_walkable_area()
	
	# Call parent _ready to set up district and camera
	._ready()
	
	# Configure camera with proper edge margins per background_dimensions.md
	if camera:
		camera.edge_margin = Vector2(150, 100)  # Standard for Wide 2D Scrolling
		print("Camera edge margins set to: " + str(camera.edge_margin))
	
	# Setup standard player and navigation controller from main game system
	# Using Vector2.ZERO will make it use the default position in the walkable square
	setup_player_and_controller(Vector2.ZERO)
	
	# Add simple UI
	add_test_ui()
	
	# Setup input handler for ESC to exit
	set_process_input(true)
	
	print("District Template initialized - use Alt+W to capture coordinates")

# Setup player character with the standard point-and-click navigation system
func setup_player_and_controller(start_position):
	# Default player position to within our walkable area if not specified
	if start_position == Vector2.ZERO:
		# TEMPLATE STEP 4: Position player within the walkable area
		# This world view coordinate will be transformed by the same mechanism as the walkable area
		var world_view_player_pos = Vector2(4396, 877)  # User-selected position from coordinate capture
		
		# Transform to game view coordinates using the CoordinateManager
		var game_view_player_pos = CoordinateManager.transform_view_mode_coordinates(
			world_view_player_pos,
			CoordinateManager.ViewMode.WORLD_VIEW,
			CoordinateManager.ViewMode.GAME_VIEW
		)
		
		start_position = game_view_player_pos
		print("Using player start position: " + str(world_view_player_pos) + " (WORLD_VIEW) -> " + str(game_view_player_pos) + " (GAME_VIEW)")
	
	# 1. Add the player character from the standard player scene
	var player_scene = load("res://src/characters/player/player.tscn")
	if player_scene:
		var player = player_scene.instance()
		player.position = start_position
		add_child(player)
		print("Added standard player character at position", start_position)
		
		# Make the camera follow the player
		if camera:
			camera.follow_player = true
			camera.target_player = player
			print("Camera set to follow player")
		
		# 2. Add the player controller to handle point-and-click navigation
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

# Create a walkable area with designer-selected coordinates
func create_walkable_area():
	# TEMPLATE STEP 1: Define coordinates captured in WORLD_VIEW mode
	# These coordinates were captured using Alt+W (world view) and define the walkable floor area
	var world_view_coords = PoolVector2Array([
		Vector2(4684, 843),  # Right upper corner
		Vector2(3731, 864),  # Right middle-lower
		Vector2(3260, 822),  # Bottom middle-right
		Vector2(4396, 877),  # Bottom middle - newly added coordinate
		Vector2(693, 860),   # Bottom middle-left
		Vector2(523, 895),   # Bottom left
		Vector2(398, 895),   # Left corner
		Vector2(267, 870),   # Left middle
		Vector2(215, 822),   # Left lower
		Vector2(3, 850),     # Left edge
		Vector2(0, 947),     # Left bottom corner
		Vector2(4691, 943),  # Right corner
		Vector2(4677, 843),  # Right middle-upper
		Vector2(3707, 860)   # Right lower
	])
	
	# TEMPLATE STEP 2: Transform coordinates from WORLD_VIEW to GAME_VIEW using system architecture
	# This demonstrates the proper use of the CoordinateManager for view mode transformations
	var game_view_coords = CoordinateManager.transform_coordinate_array(
		world_view_coords,
		CoordinateManager.ViewMode.WORLD_VIEW,
		CoordinateManager.ViewMode.GAME_VIEW
	)
	
	# TEMPLATE STEP 3: Create the actual walkable area (invisible but functional)
	var walkable = Polygon2D.new()
	walkable.name = "WalkableArea"
	walkable.color = Color(1, 0, 0, 0.1)  # Red with very low opacity - functionality without visibility
	walkable.visible = true
	walkable.polygon = game_view_coords
	
	# Add to designer_walkable_area group for camera bounds calculation
	walkable.add_to_group("designer_walkable_area")
	walkable.add_to_group("walkable_area")
	
	# Add the critical CollisionPolygon2D component for the new camera system
	var area2d = Area2D.new()
	area2d.name = "Area2D"
	area2d.collision_layer = 2
	area2d.collision_mask = 0
	walkable.add_child(area2d)
	
	var collision = CollisionPolygon2D.new()
	collision.name = "CollisionPolygon2D"
	collision.polygon = game_view_coords
	area2d.add_child(collision)
	
	add_child(walkable)
	print("Created walkable area with " + str(game_view_coords.size()) + " points")
	
	# TEMPLATE STEP 4: Create visible yellow markers at each vertex for visual reference
	# This makes the walkable area visible to level designers without rendering issues
	var walkable_markers = Node2D.new()
	walkable_markers.name = "WalkableAreaMarkers"
	walkable_markers.z_index = 100  # Make sure markers appear above other elements
	add_child(walkable_markers)
	
	# Add a marker at each vertex of the walkable area
	for i in range(game_view_coords.size()):
		var marker = ColorRect.new()
		marker.name = "Marker_" + str(i)
		marker.rect_size = Vector2(10, 10)
		marker.rect_position = game_view_coords[i] - Vector2(5, 5)  # Center marker on point
		marker.color = Color(1, 1, 0, 0.9)  # Bright yellow with high opacity
		walkable_markers.add_child(marker)
		
	# Add connecting lines between markers to make the area more visible
	var lines_container = Node2D.new()
	lines_container.name = "ConnectingLines"
	walkable_markers.add_child(lines_container)
	
	# Line drawer - simplified to avoid script issues
	var line_node = Node2D.new()
	line_node.name = "LineDrawer"
	line_node.z_index = 100
	walkable_markers.add_child(line_node)
	
	return walkable

# Helper function to calculate polygon bounds (used for debugging)
func get_polygon_bounds(polygon):
	if polygon.size() == 0:
		return Rect2(0, 0, 0, 0)
		
	var min_x = polygon[0].x
	var min_y = polygon[0].y
	var max_x = polygon[0].x
	var max_y = polygon[0].y
	
	for i in range(1, polygon.size()):
		var point = polygon[i]
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)
		
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

# Override the setup_scrolling_camera method to disable debug drawing
func setup_scrolling_camera():
	# Call parent method to set up the camera
	.setup_scrolling_camera()
	
	# Disable debug drawing on the camera - we only want to see the walkable area
	if camera:
		camera.debug_draw = false
		print("Camera debug visualization disabled - only showing walkable area")

# Add a simple UI with test information
func add_test_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var label = Label.new()
	label.name = "InfoLabel"
	label.rect_position = Vector2(10, 10)
	label.text = "District Template - Enhanced Camera System\nPress ESC to exit\nAlt+W to toggle world view mode for coordinate debugging"
	label.add_color_override("font_color", Color(1, 1, 0))
	
	var bg = ColorRect.new()
	bg.name = "LabelBackground"
	bg.color = Color(0, 0, 0, 0.5)
	bg.rect_position = Vector2(5, 5)
	bg.rect_size = Vector2(450, 75)
	
	# Add template usage instructions
	var debug_label = Label.new()
	debug_label.name = "DebugLabel"
	debug_label.rect_position = Vector2(10, 100)
	debug_label.text = "ENHANCED CAMERA TEMPLATE WITH COORDINATE SYSTEM\nThis template demonstrates proper coordinate transformation between view modes\nAlt+W shows world view, walkable area is automatically transformed from WORLD_VIEW to GAME_VIEW"
	debug_label.add_color_override("font_color", Color(0, 1, 0))
	
	var debug_bg = ColorRect.new()
	debug_bg.name = "DebugBackground"
	debug_bg.color = Color(0, 0, 0, 0.5)
	debug_bg.rect_position = Vector2(5, 95)
	debug_bg.rect_size = Vector2(450, 75)
	
	canvas_layer.add_child(bg)
	canvas_layer.add_child(label)
	canvas_layer.add_child(debug_bg)
	canvas_layer.add_child(debug_label)

# Handle input
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.scancode == KEY_W and event.alt:
			print("WORLD VIEW MODE: Use this to capture walkable area coordinates")
			print("COORDINATE CAPTURE MODE ACTIVE")
			# The actual world view functionality would be implemented elsewhere
