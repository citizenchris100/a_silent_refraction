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

# Create a walkable area spanning the full background width
func create_walkable_area(floor_y):
	var walkable = Polygon2D.new()
	walkable.name = "WalkableArea"
	walkable.color = Color(0, 1, 0, 0.1)  # Transparent green
	
	var bg_width = background_size.x
	
	var points = PoolVector2Array([
		Vector2(0, floor_y - 10),          # Top-left (left edge)
		Vector2(bg_width, floor_y - 10),   # Top-right (right edge)
		Vector2(bg_width, floor_y + 10),   # Bottom-right
		Vector2(0, floor_y + 10)           # Bottom-left
	])
	
	walkable.polygon = points
	walkable.add_to_group("walkable_area")
	add_child(walkable)
	walkable_areas.append(walkable)
	
	print("Created full-width walkable area at height: " + str(floor_y))

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