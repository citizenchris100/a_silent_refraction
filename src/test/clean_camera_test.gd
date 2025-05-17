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
	walkable.visible = true  # Make it visible for testing and verification
	
	# IMPORTANT: These coordinates define a walkable area spanning the entire floor width.
	# They are captured in World View coordinates and are critical for proper camera bounds.
	# DO NOT MODIFY these coordinates without understanding the coordinate system relationship
	# between World View and Game View modes. See docs/walkable_area_system.md for details.
	var designer_selected_points = PoolVector2Array([
		Vector2(1255, 215),    # Top-left
		Vector2(1223, 396),    # Bottom-left
		Vector2(3759, 396),    # Bottom-right
		Vector2(3731, 201)     # Top-right
	])
	
	walkable.polygon = designer_selected_points
	
	# Add to designer_walkable_area group to distinguish from debug walkable areas
	# This is important because the BaseDistrict class prioritizes designer_walkable_area 
	# over regular walkable_area groups when determining camera bounds
	walkable.add_to_group("designer_walkable_area")
	walkable.add_to_group("walkable_area")
	
	add_child(walkable)
	print("Created walkable area for camera test using coordinates selected during current session")

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
	label.text = "Clean Camera Test - Right View\nPress ESC to exit\nWalkable Area Visible (Green Polygon)"
	label.add_color_override("font_color", Color(1, 1, 0))
	
	var bg = ColorRect.new()
	bg.name = "LabelBackground"
	bg.color = Color(0, 0, 0, 0.5)
	bg.rect_position = Vector2(5, 5)
	bg.rect_size = Vector2(350, 75)
	
	# Add debugging instructions
	var debug_label = Label.new()
	debug_label.name = "DebugLabel"
	debug_label.rect_position = Vector2(10, 100)
	debug_label.text = "Testing fixed walkable area coordinates\nVerify green polygon spans full floor width"
	debug_label.add_color_override("font_color", Color(0, 1, 0))
	
	var debug_bg = ColorRect.new()
	debug_bg.name = "DebugBackground"
	debug_bg.color = Color(0, 0, 0, 0.5)
	debug_bg.rect_position = Vector2(5, 95)
	debug_bg.rect_size = Vector2(350, 55)
	
	canvas_layer.add_child(bg)
	canvas_layer.add_child(label)
	canvas_layer.add_child(debug_bg)
	canvas_layer.add_child(debug_label)

# Handle input
func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().quit()