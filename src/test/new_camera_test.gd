extends "res://src/core/districts/base_district.gd"

# New Camera Test - A clean test for verifying camera functionality
# This test verifies camera functionality without excess code complexity

export var background_path = "res://src/assets/backgrounds/test_background.png"

func _ready():
	# Setup district properties
	district_name = "New Camera Test"
	district_description = "A clean test for the camera system"
	
	# Configure the camera system
	use_scrolling_camera = true
	initial_camera_view = "right"  # Show the right side of the background
	
	# Setup background
	var background = Sprite.new()
	background.name = "Background"
	background.texture = load(background_path)
	background.centered = false
	add_child(background)
	
	# Create full-width walkable area
	var floor_y = background.texture.get_size().y * 0.8  # Position near bottom
	create_walkable_area(floor_y)
	
	# Call parent _ready to set up district and camera
	._ready()
	
	# Add simple UI
	add_test_ui()
	
	# Setup input handler for ESC to exit
	set_process_input(true)
	
	print("New Camera Test initialized")

# Create a walkable area using coordinates selected by the designer
func create_walkable_area(floor_y):
	# Get any existing walkable areas first and remove them 
	var existing_walkable_areas = get_tree().get_nodes_in_group("walkable_area")
	for area in existing_walkable_areas:
		if area.get_parent() == self or area.is_in_group("debug_walkable_area"):
			area.remove_from_group("walkable_area")
			if area.is_in_group("debug_walkable_area"):
				# Just remove from walkable_area group, don't delete the debug marker
				print("Removed a debug walkable area from visualization")
			else:
				# Remove old walkable areas that we control
				area.queue_free()
				print("Removed existing walkable area: " + area.name)
	
	# Create a fresh walkable area with the designer-selected coordinates
	var walkable = Polygon2D.new()
	walkable.name = "DesignerWalkableArea"
	walkable.color = Color(0, 1, 0, 0.35)  # Highly visible green for testing
	
	# Using the coordinates captured during testing
	var designer_selected_points = PoolVector2Array([
		Vector2(15, 861),       # Left edge
		Vector2(491, 889),
		Vector2(671, 865),
		Vector2(1644, 812),
		Vector2(3193, 819),
		Vector2(3669, 865),
		Vector2(4672, 844),
		Vector2(4683, 941),     # Right edge
		Vector2(11, 930)        # Bottom-left corner
	])
	
	# Clear our walkable areas array and start fresh
	walkable_areas.clear()
	
	walkable.polygon = designer_selected_points
	walkable.add_to_group("walkable_area")
	walkable.add_to_group("designer_walkable_area") # Special group to identify our areas
	add_child(walkable)
	walkable_areas.append(walkable)
	
	print("Created walkable area with designer-selected coordinates")
	
	# Force a refresh of any debug visualizations
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	update()

# Add a simple UI with test information
func add_test_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var label = Label.new()
	label.name = "InfoLabel"
	label.rect_position = Vector2(10, 10)
	label.text = "New Camera Test - Right View\nPress ESC to exit"
	label.add_color_override("font_color", Color(1, 1, 0))
	
	var bg = ColorRect.new()
	bg.name = "LabelBackground"
	bg.color = Color(0, 0, 0, 0.5)
	bg.rect_position = Vector2(5, 5)
	bg.rect_size = Vector2(250, 60)
	
	canvas_layer.add_child(bg)
	canvas_layer.add_child(label)

# Handle input
func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().quit()