extends "res://src/core/districts/base_district.gd"

# Clean Camera Test - A fresh test for verifying camera functionality
# This test follows architectural principles and demonstrates proper walkable area usage

export var background_path = "res://src/assets/backgrounds/test_background.png"

func _ready():
	# Setup district properties
	district_name = "Clean Camera Test"
	district_description = "A fresh test for the camera system following architectural principles"
	
	# Configure the camera system
	use_scrolling_camera = true
	initial_camera_view = "right"  # Show the right side of the background
	
	# Setup background
	var background = Sprite.new()
	background.name = "Background"
	background.texture = load(background_path)
	background.centered = false
	add_child(background)
	
	# Create walkable area
	create_walkable_area()
	
	# Call parent _ready to set up district and camera
	._ready()
	
	# Add simple UI
	add_test_ui()
	
	# Setup input handler for ESC to exit
	set_process_input(true)
	
	print("Clean Camera Test initialized")

# Create a walkable area with designer-selected coordinates
func create_walkable_area():
	# Create a fresh walkable area with the designer-selected coordinates
	var walkable = Polygon2D.new()
	walkable.name = "WalkableArea"
	walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green
	walkable.visible = false  # Make it invisible by default for testing
	
	# Define walkable area - thin band along the bottom of the screen
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
	
	walkable.polygon = designer_selected_points
	
	# Add to designer_walkable_area group to distinguish from debug walkable areas
	walkable.add_to_group("designer_walkable_area")
	walkable.add_to_group("walkable_area")
	
	add_child(walkable)
	print("Created walkable area for camera test")

# Override the setup_scrolling_camera method to disable debug drawing
func setup_scrolling_camera():
	# Call parent method to set up the camera
	.setup_scrolling_camera()
	
	# Disable debug drawing on the camera
	if camera:
		camera.debug_draw = false
		print("Camera debug visualization disabled")

# Add a simple UI with test information
func add_test_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	var label = Label.new()
	label.name = "InfoLabel"
	label.rect_position = Vector2(10, 10)
	label.text = "Clean Camera Test - Right View\nPress ESC to exit"
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