extends "res://src/core/districts/base_district.gd"
# Movement Grid Test Scene
# A grid-based test environment for validating player movement, pathfinding, and navigation

# Grid configuration
const GRID_SIZE = 50  # Size of each grid cell in pixels
const GRID_COLS = 20  # Number of columns
const GRID_ROWS = 15  # Number of rows
const GRID_COLOR = Color(1, 1, 1, 0.2)  # White, semi-transparent
const GRID_LABEL_COLOR = Color(1, 1, 1, 0.5)

# Test configuration
var show_grid = true
var show_coordinates = true
var show_path = true
var show_metrics = true

# Movement tracking
var last_click_grid = ""
var current_path_points = []
var path_line = null

# UI elements
var info_label = null
var metrics_label = null
var coordinate_label = null

func _ready():
	# Set district properties
	district_name = "Movement Grid Test"
	district_description = "Grid-based test scene for movement validation"
	
	# Configure camera
	use_scrolling_camera = true
	initial_camera_view = "center"
	
	# Create background
	create_grid_background()
	
	# Create walkable areas with gaps
	create_test_walkable_areas()
	
	# Call parent _ready() - This sets up camera and systems
	._ready()
	
	# Set up player at grid position
	setup_player_and_controller(grid_to_world("J8"))  # Start at center
	
	# Add test UI
	create_test_ui()
	
	# Create visual elements
	create_grid_overlay()
	create_path_visualization()
	
	# Enable Navigation2D if available
	setup_navigation()
	
	print("Movement Grid Test Scene Ready")
	print("Click anywhere to test movement. Press ESC to exit.")
	print("Grid coordinates will be shown for easy communication.")

func create_grid_background():
	var background = Sprite.new()
	background.name = "Background"
	
	# Create a simple colored background texture
	var img = Image.new()
	img.create(GRID_COLS * GRID_SIZE, GRID_ROWS * GRID_SIZE, false, Image.FORMAT_RGB8)
	img.fill(Color(0.2, 0.2, 0.3))  # Dark blue-gray
	
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	background.texture = texture
	background.centered = false
	add_child(background)
	
	background_size = background.texture.get_size()

func create_test_walkable_areas():
	# Create multiple walkable areas that exclude obstacle regions
	# This is more reliable than trying to create holes in polygons
	
	# Define obstacle regions first (in grid coordinates)
	var obstacles = [
		{"name": "Vertical Wall", "start": "E5", "end": "F10"},
		{"name": "Horizontal Wall", "start": "H3", "end": "M4"},
		{"name": "L-Shape", "center": "K8", "type": "L"},
		{"name": "Small Square", "start": "P12", "end": "Q13"}
	]
	
	# Create walkable areas as separate regions
	# Area 1: Left side (A1 to D15) - before vertical wall
	create_walkable_region("LeftArea", "A1", "D15", Color(0, 1, 0, 0.15))
	
	# Area 2: Top middle (G1 to T2) - above horizontal wall
	create_walkable_region("TopMiddle", "G1", "T2", Color(0, 1, 0, 0.15))
	
	# Area 3: Bottom section (A11 to T15) - below most obstacles
	create_walkable_region("BottomArea", "A11", "T15", Color(0, 1, 0, 0.15))
	
	# Area 4: Middle left (G5 to J10) - between vertical and L-shape
	create_walkable_region("MiddleLeft", "G5", "J10", Color(0, 1, 0, 0.15))
	
	# Area 5: Middle right (M5 to O10) - right of L-shape
	create_walkable_region("MiddleRight", "M5", "O10", Color(0, 1, 0, 0.15))
	
	# Area 6: Top right corner (N1 to T2) 
	create_walkable_region("TopRight", "N1", "T10", Color(0, 1, 0, 0.15))
	
	# Area 7: Bottom left corner (A11 to J15)
	# Already covered by BottomArea
	
	# Create visual obstacle markers
	create_obstacle_visuals()

func create_walkable_region(name: String, start_grid: String, end_grid: String, color: Color):
	var area = Polygon2D.new()
	area.name = name
	
	var start_pos = grid_to_world(start_grid)
	var end_pos = grid_to_world(end_grid)
	
	# Adjust to cell corners instead of centers
	start_pos -= Vector2(GRID_SIZE/2, GRID_SIZE/2)
	end_pos += Vector2(GRID_SIZE/2, GRID_SIZE/2)
	
	# Create rectangle polygon
	area.polygon = PoolVector2Array([
		Vector2(start_pos.x, start_pos.y),
		Vector2(end_pos.x, start_pos.y),
		Vector2(end_pos.x, end_pos.y),
		Vector2(start_pos.x, end_pos.y)
	])
	
	area.color = color
	area.add_to_group("walkable_area")
	add_child(area)

func create_obstacle_visuals():
	# Visual obstacles (not walkable)
	# Obstacle 1: Vertical wall from E5 to E10
	var obstacle1 = create_obstacle_area("E5", "F10", Color(1, 0, 0, 0.3))
	add_child(obstacle1)
	
	# Obstacle 2: Horizontal wall from H3 to M4
	var obstacle2 = create_obstacle_area("H3", "M4", Color(1, 0, 0, 0.3))
	add_child(obstacle2)
	
	# Obstacle 3: L-shaped obstacle
	var obstacle3 = create_l_shaped_obstacle("K8", Color(1, 0, 0, 0.3))
	add_child(obstacle3)
	
	# Obstacle 4: Small square obstacle at P12
	var obstacle4 = create_obstacle_area("P12", "Q13", Color(1, 0, 0, 0.3))
	add_child(obstacle4)

func create_obstacle_area(start_grid: String, end_grid: String, color: Color) -> Polygon2D:
	var start_pos = grid_to_world(start_grid)
	var end_pos = grid_to_world(end_grid)
	
	var obstacle = Polygon2D.new()
	obstacle.name = "Obstacle_" + start_grid + "_" + end_grid
	
	# Ensure proper rectangle
	var min_x = min(start_pos.x, end_pos.x)
	var max_x = max(start_pos.x, end_pos.x)
	var min_y = min(start_pos.y, end_pos.y)
	var max_y = max(start_pos.y, end_pos.y)
	
	obstacle.polygon = PoolVector2Array([
		Vector2(min_x, min_y),
		Vector2(max_x, min_y),
		Vector2(max_x, max_y),
		Vector2(min_x, max_y)
	])
	
	obstacle.color = color
	obstacle.add_to_group("obstacle_area")
	
	return obstacle

func create_l_shaped_obstacle(center_grid: String, color: Color) -> Polygon2D:
	var center = grid_to_world(center_grid)
	var size = GRID_SIZE
	
	var obstacle = Polygon2D.new()
	obstacle.name = "LShape_" + center_grid
	
	# Create L-shape
	obstacle.polygon = PoolVector2Array([
		center,
		Vector2(center.x + size * 2, center.y),
		Vector2(center.x + size * 2, center.y + size),
		Vector2(center.x + size, center.y + size),
		Vector2(center.x + size, center.y + size * 2),
		Vector2(center.x, center.y + size * 2)
	])
	
	obstacle.color = color
	obstacle.add_to_group("obstacle_area")
	
	return obstacle

func create_grid_overlay():
	var grid_overlay = Node2D.new()
	grid_overlay.name = "GridOverlay"
	grid_overlay.z_index = 10
	add_child(grid_overlay)
	
	# Store for updating visibility
	set_meta("grid_overlay", grid_overlay)
	
	if not show_grid:
		return
	
	# Draw grid lines
	for col in range(GRID_COLS + 1):
		var line = Line2D.new()
		line.add_point(Vector2(col * GRID_SIZE, 0))
		line.add_point(Vector2(col * GRID_SIZE, GRID_ROWS * GRID_SIZE))
		line.width = 1
		line.default_color = GRID_COLOR
		grid_overlay.add_child(line)
	
	for row in range(GRID_ROWS + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, row * GRID_SIZE))
		line.add_point(Vector2(GRID_COLS * GRID_SIZE, row * GRID_SIZE))
		line.width = 1
		line.default_color = GRID_COLOR
		grid_overlay.add_child(line)
	
	# Add coordinate labels
	if show_coordinates:
		add_grid_labels(grid_overlay)

func add_grid_labels(parent):
	# Add column labels (A-T)
	for col in range(GRID_COLS):
		var label = Label.new()
		label.text = char(65 + col)  # A, B, C, etc.
		label.rect_position = Vector2(col * GRID_SIZE + GRID_SIZE/2 - 10, 5)
		label.modulate = GRID_LABEL_COLOR
		parent.add_child(label)
	
	# Add row labels (1-15)
	for row in range(GRID_ROWS):
		var label = Label.new()
		label.text = str(row + 1)
		label.rect_position = Vector2(5, row * GRID_SIZE + GRID_SIZE/2 - 10)
		label.modulate = GRID_LABEL_COLOR
		parent.add_child(label)

func create_path_visualization():
	path_line = Line2D.new()
	path_line.name = "PathVisualization"
	path_line.width = 3
	path_line.default_color = Color(1, 1, 0, 0.8)  # Yellow
	path_line.z_index = 5
	add_child(path_line)

func create_test_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	# Info panel
	var panel = Panel.new()
	panel.rect_position = Vector2(10, 10)
	panel.rect_size = Vector2(300, 150)
	canvas_layer.add_child(panel)
	
	# Info label
	info_label = RichTextLabel.new()
	info_label.rect_position = Vector2(10, 10)
	info_label.rect_size = Vector2(280, 60)
	info_label.bbcode_enabled = true
	info_label.bbcode_text = "[color=white]Movement Grid Test[/color]\nClick to move. ESC to exit."
	panel.add_child(info_label)
	
	# Metrics label
	metrics_label = Label.new()
	metrics_label.rect_position = Vector2(10, 80)
	metrics_label.rect_size = Vector2(280, 60)
	metrics_label.text = "State: IDLE\nSpeed: 0\nPosition: J8"
	panel.add_child(metrics_label)
	
	# Coordinate display
	coordinate_label = Label.new()
	coordinate_label.rect_position = Vector2(10, 170)
	coordinate_label.rect_size = Vector2(200, 30)
	coordinate_label.modulate = Color(1, 1, 0)
	canvas_layer.add_child(coordinate_label)

func setup_navigation():
	# Create Navigation2D node for pathfinding
	var navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	add_child(navigation)
	
	# Create separate navigation polygons for each walkable area
	# This matches our walkable area setup
	
	# Area 1: Left side
	add_nav_region(navigation, "A1", "D15")
	
	# Area 2: Top middle
	add_nav_region(navigation, "G1", "T2")
	
	# Area 3: Bottom section
	add_nav_region(navigation, "A11", "T15")
	
	# Area 4: Middle left
	add_nav_region(navigation, "G5", "J10")
	
	# Area 5: Middle right
	add_nav_region(navigation, "M5", "O10")
	
	# Area 6: Top right
	add_nav_region(navigation, "N1", "T10")

func add_nav_region(navigation: Navigation2D, start_grid: String, end_grid: String):
	var nav_polygon = NavigationPolygonInstance.new()
	var navpoly = NavigationPolygon.new()
	
	var start_pos = grid_to_world(start_grid)
	var end_pos = grid_to_world(end_grid)
	
	# Adjust to cell corners
	start_pos -= Vector2(GRID_SIZE/2, GRID_SIZE/2)
	end_pos += Vector2(GRID_SIZE/2, GRID_SIZE/2)
	
	# Create outline
	navpoly.add_outline(PoolVector2Array([
		Vector2(start_pos.x, start_pos.y),
		Vector2(end_pos.x, start_pos.y),
		Vector2(end_pos.x, end_pos.y),
		Vector2(start_pos.x, end_pos.y)
	]))
	
	navpoly.make_polygons_from_outlines()
	nav_polygon.navpoly = navpoly
	navigation.add_child(nav_polygon)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.scancode == KEY_G:
			toggle_grid()
		elif event.scancode == KEY_P:
			toggle_path()
		elif event.scancode == KEY_M:
			toggle_metrics()
	
	# Update coordinate display on mouse move
	if event is InputEventMouseMotion:
		update_coordinate_display(event.position)

func _process(_delta):
	# Get player reference from parent
	var current_player = get_node_or_null("Player")
	
	# Update metrics
	if metrics_label and current_player:
		var grid_pos = world_to_grid(current_player.position)
		metrics_label.text = "State: %s\nSpeed: %.1f\nPosition: %s" % [
			current_player.get_state() if current_player.has_method("get_state") else "?",
			current_player.velocity.length() if "velocity" in current_player else 0,
			grid_pos
		]
	
	# Update path visualization
	if show_path and current_player and current_player.has_method("get_navigation_path"):
		var path = current_player.get_navigation_path()
		if path.size() > 0:
			path_line.clear_points()
			for point in path:
				path_line.add_point(point)
		elif path_line.get_point_count() > 0:
			path_line.clear_points()

func toggle_grid():
	show_grid = !show_grid
	var overlay = get_meta("grid_overlay") if has_meta("grid_overlay") else null
	if overlay:
		overlay.visible = show_grid

func toggle_path():
	show_path = !show_path
	path_line.visible = show_path

func toggle_metrics():
	show_metrics = !show_metrics
	if metrics_label:
		metrics_label.visible = show_metrics

func update_coordinate_display(screen_pos):
	if not coordinate_label:
		return
	
	# Convert screen position to world position
	var world_pos = camera.screen_to_world(screen_pos) if camera else screen_pos
	var grid_pos = world_to_grid(world_pos)
	
	coordinate_label.text = "Grid: " + grid_pos
	coordinate_label.rect_position = screen_pos + Vector2(20, -30)

func handle_player_clicked(world_position: Vector2):
	.handle_player_clicked(world_position)  # Call parent implementation
	
	# Track click location
	last_click_grid = world_to_grid(world_position)
	
	if info_label:
		var current_player = get_node_or_null("Player")
		var from_grid = world_to_grid(current_player.position) if current_player else "?"
		info_label.bbcode_text = "[color=white]Movement Grid Test[/color]\n" + \
			"Moving from [color=yellow]%s[/color] to [color=yellow]%s[/color]" % [from_grid, last_click_grid]

# Grid conversion utilities
func grid_to_world(grid_coord: String) -> Vector2:
	# Convert "A1" style coordinate to world position
	if grid_coord.length() < 2:
		return Vector2.ZERO
	
	var col = grid_coord[0].to_ascii()[0] - 65  # A=0, B=1, etc.
	var row = int(grid_coord.substr(1)) - 1  # 1-based to 0-based
	
	return Vector2(
		col * GRID_SIZE + GRID_SIZE / 2,
		row * GRID_SIZE + GRID_SIZE / 2
	)

func world_to_grid(world_pos: Vector2) -> String:
	# Convert world position to "A1" style coordinate
	var col = int(world_pos.x / GRID_SIZE)
	var row = int(world_pos.y / GRID_SIZE)
	
	# Clamp to grid bounds
	col = clamp(col, 0, GRID_COLS - 1)
	row = clamp(row, 0, GRID_ROWS - 1)
	
	return char(65 + col) + str(row + 1)