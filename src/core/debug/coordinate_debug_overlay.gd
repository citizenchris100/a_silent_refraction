extends CanvasLayer

# CoordinateDebugOverlay: A debug overlay showing coordinate system information
# This overlay displays real-time information about coordinate spaces, transformations,
# and view modes to help developers understand the coordinate system.

# Configuration
export var font_color: Color = Color(1, 1, 0)
export var background_color: Color = Color(0, 0, 0, 0.7)
export var border_color: Color = Color(0.5, 0.5, 0.5, 0.8)
export var show_marker_crosses: bool = true
export var marker_size: int = 20
export var example_coordinates: bool = true

# UI elements
var panel: PanelContainer
var info_container: VBoxContainer
var labels: Dictionary = {}
var markers: Dictionary = {}
var coordinate_example_nodes: Array = []

# Coordinate reference points 
var center_screen_pos: Vector2
var mouse_screen_pos: Vector2 = Vector2.ZERO
var mouse_world_pos: Vector2 = Vector2.ZERO

# References to key game objects
var coordinate_manager = null
var current_camera = null

func _ready():
	# Set layer to ensure overlay appears on top
	layer = 100
	
	# Get reference to coordinate manager
	coordinate_manager = CoordinateManager

	# Setup UI elements
	_setup_ui()
	
	# Set up coordinate example markers if enabled
	if example_coordinates:
		_setup_coordinate_examples()
	
	# Find camera
	_find_camera()
	
	# Show initial values
	_update_all_labels()
	print("Coordinate Debug Overlay initialized")

func _process(_delta):
	if not visible:
		return
		
	# Update mouse position
	mouse_screen_pos = get_viewport().get_mouse_position()
	
	# Update mouse world position
	if coordinate_manager != null:
		mouse_world_pos = coordinate_manager.screen_to_world(mouse_screen_pos)
		
	# Update all UI elements
	_update_all_labels()
	_update_markers()
	
	# Check if camera reference is still valid
	if current_camera == null or not is_instance_valid(current_camera):
		_find_camera()

func _find_camera():
	# Try to find the current camera
	if coordinate_manager != null:
		current_camera = coordinate_manager._get_current_camera()
	
	if current_camera == null:
		# Fallback: Find any camera in the scene
		var viewport_camera = get_viewport().get_camera()
		if viewport_camera != null:
			current_camera = viewport_camera
			
	if current_camera == null:
		push_warning("CoordinateDebugOverlay: Could not find a camera")
	else:
		print("CoordinateDebugOverlay: Found camera: " + current_camera.name)

func _setup_ui():
	# Create main panel with margins
	var margin_container = MarginContainer.new()
	margin_container.name = "MarginContainer"
	margin_container.margin_left = 10
	margin_container.margin_top = 10
	margin_container.margin_right = 10
	margin_container.margin_bottom = 10
	add_child(margin_container)
	
	# Create panel container with background
	panel = PanelContainer.new()
	panel.name = "DebugPanel"
	
	# Create a custom style for the panel
	var style = StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	panel.add_stylebox_override("panel", style)
	
	margin_container.add_child(panel)
	
	# Create a VBox for all info
	info_container = VBoxContainer.new()
	info_container.name = "InfoContainer"
	panel.add_child(info_container)
	
	# Add header
	var header = Label.new()
	header.name = "Header"
	header.text = "COORDINATE SYSTEM DEBUG"
	header.align = Label.ALIGN_CENTER
	header.add_color_override("font_color", font_color)
	info_container.add_child(header)
	
	# Add separator
	var separator = HSeparator.new()
	info_container.add_child(separator)
	
	# Add sections
	_add_section("View Mode Information", "view_mode")
	_add_section("Mouse Position", "mouse")
	_add_section("Coordinate Spaces", "spaces")
	_add_section("Camera Information", "camera")
	
	# Set the size
	panel.rect_min_size = Vector2(350, 0)

func _add_section(title, section_id):
	# Add section header
	var header = Label.new()
	header.name = section_id + "_header"
	header.text = title
	header.add_color_override("font_color", Color(1, 0.8, 0.2))
	info_container.add_child(header)
	
	# Create grid container for the content
	var grid = GridContainer.new()
	grid.name = section_id + "_grid"
	grid.columns = 2
	info_container.add_child(grid)
	
	# Add specific labels based on section
	match section_id:
		"view_mode":
			_add_label_pair(grid, "Current Mode:", "current_mode")
			_add_label_pair(grid, "Toggle Key:", "toggle_key")
			
		"mouse":
			_add_label_pair(grid, "Screen Position:", "mouse_screen")
			_add_label_pair(grid, "World Position:", "mouse_world")
			
		"spaces":
			_add_label_pair(grid, "Screen Space:", "screen_space_desc")
			_add_label_pair(grid, "World Space:", "world_space_desc")
			_add_label_pair(grid, "Local Space:", "local_space_desc")
			
		"camera":
			_add_label_pair(grid, "Camera Position:", "camera_pos")
			_add_label_pair(grid, "Camera Zoom:", "camera_zoom")
	
	# Add a small spacer
	var spacer = Control.new()
	spacer.rect_min_size = Vector2(0, 5)
	info_container.add_child(spacer)

func _add_label_pair(parent, key_text, value_id):
	# Add key label
	var key_label = Label.new()
	key_label.name = value_id + "_key"
	key_label.text = key_text
	key_label.add_color_override("font_color", Color(0.8, 0.8, 1.0))
	parent.add_child(key_label)
	
	# Add value label
	var value_label = Label.new()
	value_label.name = value_id + "_value"
	value_label.text = "..."
	value_label.add_color_override("font_color", font_color)
	parent.add_child(value_label)
	
	# Store reference to the value label
	labels[value_id] = value_label

func _update_all_labels():
	# Update view mode information
	if coordinate_manager != null:
		var view_mode = coordinate_manager.get_view_mode()
		var mode_text = "Game View"
		var color = Color(0, 1, 0)  # Green for game view
		
		if view_mode == CoordinateManager.ViewMode.WORLD_VIEW:
			mode_text = "World View"
			color = Color(1, 0.5, 0)  # Orange for world view
			
		_update_label("current_mode", mode_text, color)
	else:
		_update_label("current_mode", "Unknown (CoordinateManager not found)")
		
	_update_label("toggle_key", "Alt+W")
	
	# Update mouse position
	_update_label("mouse_screen", str(mouse_screen_pos))
	_update_label("mouse_world", str(mouse_world_pos))
	
	# Update coordinate spaces descriptions
	_update_label("screen_space_desc", "UI coordinates (viewport relative)")
	_update_label("world_space_desc", "Global game coordinates")
	_update_label("local_space_desc", "Relative to parent node")
	
	# Update camera information
	if current_camera != null and is_instance_valid(current_camera):
		_update_label("camera_pos", str(current_camera.global_position))
		_update_label("camera_zoom", str(current_camera.zoom))
	else:
		_update_label("camera_pos", "No camera found")
		_update_label("camera_zoom", "N/A")

func _update_label(label_id, text, color = null):
	if label_id in labels:
		labels[label_id].text = str(text)
		
		if color != null:
			labels[label_id].add_color_override("font_color", color)

func _setup_coordinate_examples():
	# Create example coordinate markers
	center_screen_pos = get_viewport().size / 2
	
	# Add screen center marker
	_add_coordinate_marker(
		"screen_center",
		center_screen_pos,
		Color(0, 1, 0, 0.7),
		"Screen Center",
		true
	)
	
	# Add world origin marker (0,0)
	var world_origin_screen_pos = Vector2.ZERO
	if coordinate_manager != null:
		world_origin_screen_pos = coordinate_manager.world_to_screen(Vector2.ZERO)
	
	_add_coordinate_marker(
		"world_origin",
		world_origin_screen_pos,
		Color(1, 0, 0, 0.7),
		"World Origin (0,0)",
		true
	)
	
	# Add coordinate axes
	_add_coordinate_axes()

func _add_coordinate_marker(id, position, color, label_text, show_cross = false):
	# Create a Control node for positioning
	var marker_control = Control.new()
	marker_control.name = id + "_marker"
	marker_control.rect_position = position - Vector2(marker_size/2, marker_size/2)
	add_child(marker_control)
	
	# Create the marker (circle)
	var marker = ColorRect.new()
	marker.name = "Circle"
	marker.rect_size = Vector2(marker_size, marker_size)
	marker.color = color
	marker_control.add_child(marker)
	
	# Add cross lines if requested
	if show_cross and show_marker_crosses:
		var h_line = ColorRect.new()
		h_line.name = "HLine"
		h_line.rect_size = Vector2(marker_size, 2)
		h_line.rect_position = Vector2(0, marker_size/2 - 1)
		h_line.color = Color(1, 1, 1, 0.8)
		marker_control.add_child(h_line)
		
		var v_line = ColorRect.new()
		v_line.name = "VLine"
		v_line.rect_size = Vector2(2, marker_size)
		v_line.rect_position = Vector2(marker_size/2 - 1, 0)
		v_line.color = Color(1, 1, 1, 0.8)
		marker_control.add_child(v_line)
	
	# Add label
	var text = Label.new()
	text.name = "Label"
	text.text = label_text
	text.rect_position = Vector2(marker_size + 5, 0)
	text.add_color_override("font_color", color)
	marker_control.add_child(text)
	
	# Store marker reference
	markers[id] = marker_control
	coordinate_example_nodes.append(marker_control)

func _add_coordinate_axes():
	# Create axes container
	var axes = Control.new()
	axes.name = "CoordinateAxes"
	axes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(axes)
	
	# Get world origin in screen coordinates
	var origin_screen_pos = Vector2.ZERO
	if coordinate_manager != null:
		origin_screen_pos = coordinate_manager.world_to_screen(Vector2.ZERO)
	
	# Create X axis (horizontal, red)
	var x_axis = ColorRect.new()
	x_axis.name = "XAxis"
	x_axis.rect_size = Vector2(200, 2)
	x_axis.rect_position = origin_screen_pos
	x_axis.color = Color(1, 0.2, 0.2, 0.7)
	axes.add_child(x_axis)
	
	# Create Y axis (vertical, green)
	var y_axis = ColorRect.new()
	y_axis.name = "YAxis"
	y_axis.rect_size = Vector2(2, 200)
	y_axis.rect_position = origin_screen_pos
	y_axis.color = Color(0.2, 1, 0.2, 0.7)
	axes.add_child(y_axis)
	
	# Add axis labels
	var x_label = Label.new()
	x_label.name = "XLabel"
	x_label.text = "X"
	x_label.rect_position = origin_screen_pos + Vector2(210, -10)
	x_label.add_color_override("font_color", Color(1, 0.2, 0.2))
	axes.add_child(x_label)
	
	var y_label = Label.new()
	y_label.name = "YLabel"
	y_label.text = "Y"
	y_label.rect_position = origin_screen_pos + Vector2(-10, -210)
	y_label.add_color_override("font_color", Color(0.2, 1, 0.2))
	axes.add_child(y_label)
	
	# Store reference
	coordinate_example_nodes.append(axes)

func _update_markers():
	# Only update if the coordinate manager and camera are available
	if coordinate_manager == null or current_camera == null:
		return
	
	# Update world origin marker position
	if "world_origin" in markers:
		var world_origin_screen_pos = coordinate_manager.world_to_screen(Vector2.ZERO)
		var marker = markers["world_origin"]
		marker.rect_position = world_origin_screen_pos - Vector2(marker_size/2, marker_size/2)
	
	# Update axes
	var axes = get_node_or_null("CoordinateAxes")
	if axes != null:
		var origin_screen_pos = coordinate_manager.world_to_screen(Vector2.ZERO)
		
		var x_axis = axes.get_node_or_null("XAxis")
		if x_axis != null:
			x_axis.rect_position = origin_screen_pos - Vector2(0, 1)  # Center line vertically
			
		var y_axis = axes.get_node_or_null("YAxis")
		if y_axis != null:
			y_axis.rect_position = origin_screen_pos - Vector2(1, 0)  # Center line horizontally
			
		var x_label = axes.get_node_or_null("XLabel")
		if x_label != null:
			x_label.rect_position = origin_screen_pos + Vector2(210, -10)
			
		var y_label = axes.get_node_or_null("YLabel")
		if y_label != null:
			y_label.rect_position = origin_screen_pos + Vector2(-10, -210)

# Add a visual marker for a specific location (can be called externally)
func add_marker(position, space, label = "", color = Color(1, 1, 0, 0.7)):
	# Convert position to screen space if needed
	var screen_position = position
	if space == CoordinateManager.CoordinateSpace.WORLD_SPACE and coordinate_manager != null:
		screen_position = coordinate_manager.world_to_screen(position)
	
	var marker_id = "custom_" + str(markers.size())
	_add_coordinate_marker(
		marker_id,
		screen_position,
		color,
		label if label != "" else "Marker " + str(markers.size()),
		true
	)
	
	return marker_id

# Remove a marker by ID
func remove_marker(marker_id):
	if marker_id in markers:
		markers[marker_id].queue_free()
		markers.erase(marker_id)

# Clear all custom markers
func clear_markers():
	for marker_id in markers.keys():
		if marker_id.begins_with("custom_"):
			markers[marker_id].queue_free()
			markers.erase(marker_id)

# Toggle visibility of coordinate examples
func toggle_coordinate_examples(show):
	for node in coordinate_example_nodes:
		if is_instance_valid(node):
			node.visible = show