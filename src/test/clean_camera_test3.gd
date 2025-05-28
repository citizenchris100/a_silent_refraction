extends "res://src/core/districts/base_district.gd"

# Clean Camera Test 3 - Enhanced with Navigation2D
# Based on clean_camera_test2 but with proper Navigation2D setup
# This helps test if the navigation stuck bug is related to missing Navigation2D

export var background_path = "res://src/assets/backgrounds/test_background.png"
var coordinate_display
var transition_test_running = false

# Path visualization
var show_path = true
var path_line = null

func _ready():
	# Setup district properties
	district_name = "Clean Camera Test 3"
	district_description = "Enhanced camera test with Navigation2D support"
	
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
	
	# Create Navigation2D BEFORE walkable areas
	setup_navigation()
	
	# Create walkable area
	create_walkable_area()
	
	# Call parent _ready to set up district and camera
	._ready()
	
	# Configure camera with proper edge margins per background_dimensions.md
	if camera:
		camera.edge_margin = Vector2(150, 100)  # Standard for Wide 2D Scrolling
		print("Camera edge margins set to: " + str(camera.edge_margin))
	
	# Setup standard player and navigation controller from main game system
	# Transform the specific world view position this template uses
	var world_view_player_pos = Vector2(4396, 877)  # User-selected position from coordinate capture
	var game_view_player_pos = CoordinateManager.transform_view_mode_coordinates(
		world_view_player_pos,
		CoordinateManager.ViewMode.WORLD_VIEW,
		CoordinateManager.ViewMode.GAME_VIEW
	)
	print("Using player start position: " + str(world_view_player_pos) + " (WORLD_VIEW) -> " + str(game_view_player_pos) + " (GAME_VIEW)")
	setup_player_and_controller(game_view_player_pos)
	
	# Add simple UI
	add_test_ui()
	
	# Create path visualization
	create_path_visualization()
	
	# Setup input handler for ESC to exit
	set_process_input(true)
	
	print("Clean Camera Test 3 initialized - Navigation2D enabled")
	print("Use Alt+W to capture coordinates")
	print("Press P to toggle path visualization")

# Set up Navigation2D for pathfinding
func setup_navigation():
	# Create Navigation2D node
	var navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	add_child(navigation)
	print("Created Navigation2D node")

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
	
	# STEP 5: Create Navigation Polygon for pathfinding
	# Get reference to Navigation2D
	var navigation = get_node("Navigation2D")
	if navigation:
		var nav_polygon = NavigationPolygonInstance.new()
		var navpoly = NavigationPolygon.new()
		
		# Add the walkable area outline to the navigation polygon
		navpoly.add_outline(game_view_coords)
		navpoly.make_polygons_from_outlines()
		
		nav_polygon.navpoly = navpoly
		navigation.add_child(nav_polygon)
		print("Created NavigationPolygonInstance for pathfinding")
	else:
		print("WARNING: Navigation2D not found!")
	
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

# Create path visualization line
func create_path_visualization():
	path_line = Line2D.new()
	path_line.name = "PathVisualization"
	path_line.width = 3
	path_line.default_color = Color(1, 1, 0, 0.8)  # Yellow
	path_line.z_index = 5
	add_child(path_line)

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
	label.text = "Clean Camera Test 3 - With Navigation2D\nPress ESC to exit | P to toggle path\nAlt+W to toggle world view mode"
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
	debug_label.text = "ENHANCED CAMERA WITH NAVIGATION2D\nThis test includes proper Navigation2D setup for pathfinding\nPlayer should navigate around obstacles smoothly"
	debug_label.add_color_override("font_color", Color(0, 1, 0))
	
	var debug_bg = ColorRect.new()
	debug_bg.name = "DebugBackground"
	debug_bg.color = Color(0, 0, 0, 0.5)
	debug_bg.rect_position = Vector2(5, 95)
	debug_bg.rect_size = Vector2(450, 75)
	
	# Add navigation status label
	var nav_label = Label.new()
	nav_label.name = "NavigationLabel"
	nav_label.rect_position = Vector2(10, 180)
	nav_label.text = ""
	nav_label.add_color_override("font_color", Color(1, 0.5, 0))
	
	var nav_bg = ColorRect.new()
	nav_bg.name = "NavigationBackground"
	nav_bg.color = Color(0, 0, 0, 0.5)
	nav_bg.rect_position = Vector2(5, 175)
	nav_bg.rect_size = Vector2(450, 50)
	
	canvas_layer.add_child(bg)
	canvas_layer.add_child(label)
	canvas_layer.add_child(debug_bg)
	canvas_layer.add_child(debug_label)
	canvas_layer.add_child(nav_bg)
	canvas_layer.add_child(nav_label)

# Handle input
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.scancode == KEY_W and event.alt:
			print("WORLD VIEW MODE: Use this to capture walkable area coordinates")
			print("COORDINATE CAPTURE MODE ACTIVE")
			# The actual world view functionality would be implemented elsewhere
		elif event.scancode == KEY_P:
			toggle_path()

# Update navigation status display
func _process(_delta):
	var nav_label = get_node_or_null("UI/NavigationLabel")
	var player = get_node_or_null("Player")
	
	if nav_label and player:
		if player.has_method("get_navigation_path"):
			var path = player.get_navigation_path()
			if path.size() > 0:
				nav_label.text = "Navigation Path: %d waypoints (P to toggle)" % path.size()
			else:
				nav_label.text = "Navigation: Direct movement (no path)"
		else:
			nav_label.text = "Navigation: Player not found"
	
	# Update path visualization
	if show_path and player and player.has_method("get_navigation_path"):
		var path = player.get_navigation_path()
		if path.size() > 0:
			path_line.clear_points()
			# Add player's current position as first point
			path_line.add_point(player.global_position)
			# Add all navigation points
			for point in path:
				path_line.add_point(point)
		elif path_line.get_point_count() > 0:
			path_line.clear_points()

# Toggle path visualization
func toggle_path():
	show_path = !show_path
	path_line.visible = show_path
	print("Path visualization: " + ("ON" if show_path else "OFF"))