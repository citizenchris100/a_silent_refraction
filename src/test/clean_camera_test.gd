extends "res://src/core/districts/base_district.gd"

# Clean Camera Test - A fresh test for verifying camera functionality
# This test follows architectural principles and demonstrates proper walkable area usage

export var background_path = "res://src/assets/backgrounds/test_background.png"

# Debug settings
export var add_coordinate_picker = true
export var show_debug_info = true
export var debug_camera_position = true
export(String, "left", "right", "center") var test_camera_view = "right"  # Right view is our primary test case
var coordinate_picker = null

func _ready():
	# Setup district properties
	district_name = "Clean Camera Test"
	district_description = "A fresh test for the camera system following architectural principles"
	
	# Configure the camera system
	use_scrolling_camera = true
	initial_camera_view = test_camera_view  # Use the selected camera view for testing
	
	print("Camera view setting: " + initial_camera_view) # DEBUG: Check initial setting
	
	# Setup background
	var background = Sprite.new()
	background.name = "Background"
	background.texture = load(background_path)
	background.centered = false
	add_child(background)
	
	# Create walkable area
	create_walkable_area()
	
	# Add player character
	add_player_character()
	
	# Call parent _ready to set up district and camera
	._ready()
	
	# Add simple UI
	add_test_ui()
	
	# Setup input handler for ESC to exit
	set_process_input(true)
	
	# Add coordinate picker if enabled
	if add_coordinate_picker:
		add_coordinate_picker_tool()
	
	# Add camera debug visualization if enabled
	if debug_camera_position and camera:
		camera.debug_draw = true
		camera.debug_camera_positioning = true
		print("Enabled camera debug visualization")
	
	print("Clean Camera Test initialized")
	print("Background scale factor: " + str(background_scale_factor))
	
	# DEBUG: Print camera position
	if camera:
		print("Final camera position: " + str(camera.global_position))
		print("Viewport size: " + str(get_viewport_rect().size))
		if "background_size" in self:
			print("Background size: " + str(background_size))

# Create a walkable area with designer-selected coordinates
func create_walkable_area():
	# Create a fresh walkable area with the designer-selected coordinates
	var walkable = Polygon2D.new()
	walkable.name = "WalkableArea"
	walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green
	walkable.visible = true  # Make it visible for testing
	
	# Define walkable area using SCREEN SPACE coordinates
	# These coordinates would be what you'd capture directly in-game
	var screen_space_points = PoolVector2Array([
		Vector2(38, 590),       # Left edge
		Vector2(173, 598),
		Vector2(234, 589),
		Vector2(555, 576),
		Vector2(973, 574),
		Vector2(1095, 586),
		Vector2(1382, 582),
		Vector2(1385, 611),     # Right edge
		Vector2(36, 612)        # Bottom-left corner
	])
	
	# DEBUG: Print original coordinates and expected transformed coordinates
	print("\n==== WALKABLE AREA COORDINATES DEBUG ====")
	print("Screen space coordinates (original):")
	for i in range(screen_space_points.size()):
		var point = screen_space_points[i]
		print("Point " + str(i) + ": " + str(point))
	
	# Transform to world space for testing (assuming scale factor ~1.92)
	var transform_scale = 1.919355  # This is expected scale factor
	var world_space_points = PoolVector2Array()
	
	for point in screen_space_points:
		# Apply scale to transform from screen space to world space
		var world_point = Vector2(point.x * transform_scale, point.y)
		world_space_points.append(world_point)
	
	print("\nWorld space coordinates (transformed with scale " + str(transform_scale) + "):")
	for i in range(world_space_points.size()):
		var point = world_space_points[i]
		print("Point " + str(i) + ": " + str(point))
	
	# IMPORTANT: Use world space coordinates to match the camera system expectations
	# This ensures proper alignment with the camera bounds and positioning
	var final_points = world_space_points  # Using transformed world coords for proper camera operation
	
	print("\nACTUAL coordinates being used in walkable area:")
	for i in range(final_points.size()):
		var point = final_points[i]
		print("Point " + str(i) + ": " + str(point))
	print("==== END WALKABLE AREA COORDINATES DEBUG ====\n")
	
	walkable.polygon = final_points
	
	# Add to designer_walkable_area group to distinguish from debug walkable areas
	walkable.add_to_group("designer_walkable_area")
	walkable.add_to_group("walkable_area")
	
	add_child(walkable)
	print("Created walkable area for camera test using consistent coordinates")

# Add a simple player character to test camera following
func add_player_character():
	# Create a simple player sprite
	var player = Sprite.new()
	player.name = "Player"
	
	# Set a default position in the walkable area - use screen space coordinates for consistency
	var screen_pos = Vector2(800, 585) # Middle of walkable area in screen space
	
	# DEBUG: Print player position in both coordinate spaces
	print("\n==== PLAYER POSITION DEBUG ====")
	print("Screen space position: " + str(screen_pos))
	
	# Calculate equivalent world position with expected scale
	var transform_scale = 1.919355  # This is expected scale factor
	var world_pos = Vector2(screen_pos.x * transform_scale, screen_pos.y)
	print("World space position: " + str(world_pos))
	
	# IMPORTANT: Use world space coordinates to match camera expectations
	var final_pos = world_pos  # Using world coordinates for proper camera following
	print("ACTUAL position being used: " + str(final_pos))
	print("==== END PLAYER POSITION DEBUG ====\n")
	
	player.position = final_pos
	
	# Make it visible with a colored rectangle
	var player_rect = ColorRect.new()
	player_rect.rect_size = Vector2(20, 40)
	player_rect.rect_position = Vector2(-10, -40) # Center the rect
	player_rect.color = Color(0, 0.5, 1) # Blue color
	player.add_child(player_rect)
	
	# Add to player group for camera to follow
	player.add_to_group("player")
	
	# Add click-to-move functionality for testing
	player.set_script(load("res://src/characters/player/player.gd"))
	
	add_child(player)
	print("Added player character for camera to follow")

# Override the setup_scrolling_camera method to disable debug drawing
func setup_scrolling_camera():
	# Call parent method to set up the camera
	.setup_scrolling_camera()
	
	# Disable debug drawing on the camera
	if camera:
		camera.debug_draw = false
		print("Camera debug visualization disabled")

# Add the coordinate picker tool
func add_coordinate_picker_tool():
	coordinate_picker = load("res://src/core/debug/coordinate_picker.gd").new()
	coordinate_picker.name = "CoordinatePicker"
	coordinate_picker.show_grid = true
	coordinate_picker.grid_size = 100
	add_child(coordinate_picker)
	print("Added district-aware coordinate picker")

# Add a simple UI with test information
func add_test_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var label = Label.new()
	label.name = "InfoLabel"
	label.rect_position = Vector2(10, 10)
	label.text = "Clean Camera Test - " + initial_camera_view.to_upper() + " VIEW\nControls:\n- ESC: Exit test\n- R/L/C: Right/Left/Center view\n- P: Place player at right edge\n- Click: Move player\n- Shift+Click: Capture coordinates"
	label.add_color_override("font_color", Color(1, 1, 0))
	
	var bg = ColorRect.new()
	bg.name = "LabelBackground"
	bg.color = Color(0, 0, 0, 0.5)
	bg.rect_position = Vector2(5, 5)
	bg.rect_size = Vector2(300, 160)
	
	canvas_layer.add_child(bg)
	canvas_layer.add_child(label)
	
	# Add right edge marker to visually confirm we're seeing the extreme right
	var right_marker = ColorRect.new()
	right_marker.name = "RightEdgeMarker"
	right_marker.color = Color(1, 0, 0, 0.8) # Bright red
	right_marker.rect_size = Vector2(10, 400)
	
	# Position at the rightmost edge of the background
	var bg_node = get_node("Background")
	if bg_node and bg_node is Sprite:
		var bg_size = bg_node.texture.get_size()
		var scale = bg_node.scale
		var right_edge = bg_size.x * scale.x
		right_marker.rect_position = Vector2(right_edge - 10, 100)
		canvas_layer.add_child(right_marker)
		
		# Add a label for the right edge marker
		var edge_label = Label.new()
		edge_label.name = "EdgeMarkerLabel"
		edge_label.rect_position = Vector2(right_edge - 200, 50)
		edge_label.text = "RIGHT EDGE MARKER →"
		edge_label.add_color_override("font_color", Color(1, 0, 0))
		canvas_layer.add_child(edge_label)
	
	# Add scale factor info if debug info is enabled
	if show_debug_info:
		var info_label = Label.new()
		info_label.name = "ScaleInfo"
		info_label.rect_position = Vector2(10, 180)
		info_label.text = "Background Scale: %.2f\nView: %s\nUsing world coordinates (transformed)" % [background_scale_factor, initial_camera_view.to_upper()]
		info_label.add_color_override("font_color", Color(0, 1, 0))
		
		var info_bg = ColorRect.new()
		info_bg.name = "InfoBackground"
		info_bg.color = Color(0, 0, 0, 0.5)
		info_bg.rect_position = Vector2(5, 175)
		info_bg.rect_size = Vector2(300, 70)
		
		canvas_layer.add_child(info_bg)
		canvas_layer.add_child(info_label)

# Update UI labels to match current camera view
func update_ui_labels():
	# Update main UI label
	var info_label = get_node_or_null("UI/InfoLabel")
	if info_label:
		info_label.text = "Clean Camera Test - " + initial_camera_view.to_upper() + " VIEW\nControls:\n- ESC: Exit test\n- R/L/C: Right/Left/Center view\n- P: Place player at right edge\n- Click: Move player\n- Shift+Click: Capture coordinates"
	
	# Update scale info label
	var scale_info = get_node_or_null("UI/ScaleInfo")
	if scale_info:
		scale_info.text = "Background Scale: %.2f\nView: %s\nUsing world coordinates (transformed)" % [background_scale_factor, initial_camera_view.to_upper()]

# Handle input
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_ESCAPE:
					# Exit the test
					get_tree().quit()
				
				KEY_R:
					# Reset test with right view
					initial_camera_view = "right"
					if camera:
						camera.initial_view = "right"
						camera.force_update_scroll()
						# Update UI labels
						update_ui_labels()
						print("Camera reset to RIGHT view")
				
				KEY_L:
					# Test left view
					initial_camera_view = "left"
					if camera:
						camera.initial_view = "left"
						camera.force_update_scroll()
						# Update UI labels
						update_ui_labels()
						print("Camera changed to LEFT view")
				
				KEY_C:
					# Test center view
					initial_camera_view = "center"
					if camera:
						camera.initial_view = "center"
						camera.force_update_scroll()
						# Update UI labels
						update_ui_labels()
						print("Camera changed to CENTER view")
				
				KEY_P:
					# Place player at right edge for testing
					var player = get_node_or_null("Player")
					if player and get_node_or_null("Background") is Sprite:
						var bg = get_node("Background")
						var bg_size = bg.texture.get_size()
						var scale = bg.scale
						var right_edge = bg_size.x * scale.x - 50  # 50 pixels from right edge
						player.position.x = right_edge
						print("Player moved to right edge position: " + str(player.position))
						
						# If testing with screen space, convert the position
						if player.has_method("screen_to_world_coords"):
							var world_pos = player.screen_to_world_coords(Vector2(right_edge, player.position.y))
							print("Equivalent world position: " + str(world_pos))