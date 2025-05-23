extends "res://src/core/districts/base_district.gd"

# Camera System Test Scene - Comprehensive validation following proper base_district architecture
# Based on docs/design/camera_test_scene_design.md but updated to follow base_district pattern

signal test_completed(test_name, result)
signal visual_issue_detected(issue_type, details)

# Test modes as defined in design document
enum TestMode {
	MOVEMENT,
	COORDINATES,
	STATE,
	BOUNDS,
	SCALING
}

# Test environment backgrounds - all 8 backgrounds have been created
var test_backgrounds = {
	"spaceport": "res://src/assets/backgrounds/camera_test_background001.png",  # Spaceport Loading Dock
	"security": "res://src/assets/backgrounds/camera_test_background002.png",   # Security Brig Corridor
	"mall": "res://src/assets/backgrounds/camera_test_background003.png",       # Mall Atrium
	"trading": "res://src/assets/backgrounds/camera_test_background004.png",    # Trading Floor
	"engineering": "res://src/assets/backgrounds/camera_test_background005.png", # Engineering Deck
	"medical": "res://src/assets/backgrounds/camera_test_background006.png",    # Medical Bay
	"barracks": "res://src/assets/backgrounds/camera_test_background007.png",   # Barracks Common Area
	"tram": "res://src/assets/backgrounds/camera_test_background008.png"        # Station Tram Platform
}

# Test state
var current_mode = TestMode.MOVEMENT
var current_background = "spaceport"
var current_background_index = 1
var test_results = {}
var visual_validation_passed = true

# Camera state tracking
var camera_state_history = []
var signal_emission_log = []

# Performance tracking
var frame_times = []
var performance_baseline = {}

# UI references (will be created after district setup)
var ui
var control_panel
var output_display

func _ready():
	print("Camera System Test initializing...")
	
	# Setup district properties
	district_name = "Camera System Test"
	district_description = "Comprehensive camera system validation with 8 test backgrounds"
	
	# Configure camera system for proper base_district setup
	use_scrolling_camera = true
	initial_camera_view = "center"
	camera_follow_smoothing = 5.0
	camera_edge_margin = Vector2(150, 100)
	
	# Enable pixel-perfect rendering to prevent distortion
	OS.vsync_enabled = true
	get_viewport().usage = Viewport.USAGE_2D_NO_SAMPLING
	
	# Load initial background
	load_test_background(current_background)
	
	# Create minimal walkable area for testing
	create_test_walkable_area()
	
	# Call parent _ready to set up district, camera, and systems
	._ready()
	
	# Now camera exists and is properly configured by base_district
	if camera:
		# Connect to camera signals for monitoring
		if camera.has_signal("state_changed"):
			camera.connect("state_changed", self, "_on_camera_state_changed")
		if camera.has_signal("bounds_changed"):
			camera.connect("bounds_changed", self, "_on_camera_bounds_changed")
		if camera.has_signal("position_changed"):
			camera.connect("position_changed", self, "_on_camera_position_changed")
		
		print("[CameraTest] ScrollingCamera configured by base_district")
	
	# Set up player with navigation using inherited method
	setup_player_and_controller(Vector2(400, 300))
	
	# Initialize UI after everything else
	setup_test_ui()
	
	# Connect signals
	connect_signals()
	
	# Set up input processing for background switching
	set_process_input(true)
	
	# Log initial state
	log_output("Camera System Test ready - proper base_district architecture")
	log_output("Initial background: " + current_background)
	log_output("Initial mode: " + TestMode.keys()[current_mode])
	log_output("Use number keys 1-8 to switch backgrounds")

# Create a test walkable area
func create_test_walkable_area():
	var walkable_container = Node2D.new()
	walkable_container.name = "WalkableAreas"
	add_child(walkable_container)
	
	# Create a simple rectangular walkable area
	var walkable = Polygon2D.new()
	walkable.name = "TestWalkableArea"
	
	# Large walkable area that covers most backgrounds
	var points = PoolVector2Array([
		Vector2(100, 400),
		Vector2(4000, 400),
		Vector2(4000, 900),
		Vector2(100, 900)
	])
	
	walkable.polygon = points
	walkable.color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent
	walkable.add_to_group("walkable_area")
	walkable_container.add_child(walkable)

func load_test_background(bg_name):
	if not bg_name in test_backgrounds:
		log_output("ERROR: Unknown background: " + bg_name)
		return
	
	var bg_path = test_backgrounds[bg_name]
	
	# Remove existing background if any
	var existing_bg = get_node_or_null("Background")
	if existing_bg:
		existing_bg.queue_free()
		yield(get_tree(), "idle_frame")
	
	# Create new background sprite
	var background = Sprite.new()
	background.name = "Background"  # MUST be named "Background" for base_district compatibility
	background.texture = load(bg_path)
	
	if not background.texture:
		log_output("ERROR: Failed to load background texture: " + bg_path)
		return
	
	background.centered = false
	add_child(background)
	
	# Update background_size for camera bounds
	background_size = background.texture.get_size()
	
	# Let camera recalculate optimal zoom for new background
	if camera and camera.has_method("calculate_optimal_zoom"):
		camera.calculate_optimal_zoom()
	
	log_output("Loaded background: " + bg_name + " (" + str(background_size) + ")")

# Setup comprehensive test UI
func setup_test_ui():
	ui = CanvasLayer.new()
	ui.name = "UI"
	ui.layer = 100
	add_child(ui)
	
	# Control panel with tabs for different test modes
	control_panel = TabContainer.new()
	control_panel.name = "ControlPanel"
	control_panel.anchor_right = 0.3
	control_panel.anchor_bottom = 1.0
	control_panel.margin_left = 10.0
	control_panel.margin_top = 10.0
	control_panel.margin_right = -10.0
	control_panel.margin_bottom = -10.0
	control_panel.tab_align = 0
	ui.add_child(control_panel)
	
	# Create panels for each test mode
	setup_movement_panel()
	setup_coordinate_panel()
	setup_state_panel()
	setup_bounds_panel()
	setup_scaling_panel()
	
	# Output display
	output_display = RichTextLabel.new()
	output_display.name = "OutputDisplay"
	output_display.anchor_left = 0.7
	output_display.anchor_right = 1.0
	output_display.anchor_bottom = 0.3
	output_display.margin_left = 10.0
	output_display.margin_top = 10.0
	output_display.margin_right = -10.0
	output_display.margin_bottom = -10.0
	output_display.bbcode_enabled = true
	output_display.scroll_following = true
	ui.add_child(output_display)

func setup_movement_panel():
	var panel = ScrollContainer.new()
	panel.name = "Movement"
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Movement controls
	var title = Label.new()
	title.text = "Camera Movement Controls"
	title.add_color_override("font_color", Color.yellow)
	vbox.add_child(title)
	
	# Player following toggle
	var follow_toggle = CheckBox.new()
	follow_toggle.name = "FollowToggle"
	follow_toggle.text = "Follow Player"
	follow_toggle.pressed = true
	follow_toggle.connect("toggled", self, "_on_follow_player_toggled")
	vbox.add_child(follow_toggle)
	
	# Transition type selection
	var transition_label = Label.new()
	transition_label.text = "Transition Type:"
	vbox.add_child(transition_label)
	
	var transition_option = OptionButton.new()
	transition_option.name = "TransitionOption"
	transition_option.add_item("Smooth")
	transition_option.add_item("Linear")  
	transition_option.add_item("Instant")
	transition_option.connect("item_selected", self, "_on_transition_type_changed")
	vbox.add_child(transition_option)
	
	# Speed adjustment slider
	var speed_label = Label.new()
	speed_label.text = "Movement Speed:"
	vbox.add_child(speed_label)
	
	var speed_slider = HSlider.new()
	speed_slider.name = "SpeedSlider"
	speed_slider.min_value = 0.1
	speed_slider.max_value = 10.0
	speed_slider.value = 5.0
	speed_slider.step = 0.1
	speed_slider.connect("value_changed", self, "_on_speed_changed")
	vbox.add_child(speed_slider)
	
	var speed_value_label = Label.new()
	speed_value_label.name = "SpeedValueLabel"
	speed_value_label.text = "5.0"
	vbox.add_child(speed_value_label)
	
	# Direct movement buttons
	var movement_label = Label.new()
	movement_label.text = "Direct Movement:"
	vbox.add_child(movement_label)
	
	var center_btn = Button.new()
	center_btn.text = "Center Camera"
	center_btn.connect("pressed", self, "_on_center_camera")
	vbox.add_child(center_btn)
	
	var left_btn = Button.new()
	left_btn.text = "Move to Left"
	left_btn.connect("pressed", self, "_on_move_left")
	vbox.add_child(left_btn)
	
	var right_btn = Button.new()
	right_btn.text = "Move to Right"
	right_btn.connect("pressed", self, "_on_move_right")
	vbox.add_child(right_btn)
	
	# Preset scenario buttons
	var scenario_label = Label.new()
	scenario_label.text = "Edge Case Scenarios:"
	vbox.add_child(scenario_label)
	
	var edge_left_btn = Button.new()
	edge_left_btn.text = "Test Left Edge"
	edge_left_btn.connect("pressed", self, "_on_test_left_edge")
	vbox.add_child(edge_left_btn)
	
	var edge_right_btn = Button.new()
	edge_right_btn.text = "Test Right Edge"
	edge_right_btn.connect("pressed", self, "_on_test_right_edge")
	vbox.add_child(edge_right_btn)
	
	var boundary_test_btn = Button.new()
	boundary_test_btn.text = "Test Boundary Violation"
	boundary_test_btn.connect("pressed", self, "_on_test_boundary_violation")
	vbox.add_child(boundary_test_btn)
	
	control_panel.add_child(panel)

func setup_coordinate_panel():
	var panel = ScrollContainer.new()
	panel.name = "Coordinates"
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Coordinate Transformation Testing"
	title.add_color_override("font_color", Color.yellow)
	vbox.add_child(title)
	
	# Real-time coordinate display
	var coord_label = Label.new()
	coord_label.text = "Real-time Coordinates:"
	vbox.add_child(coord_label)
	
	var mouse_pos_label = Label.new()
	mouse_pos_label.name = "MousePosLabel"
	mouse_pos_label.text = "Mouse Screen: (0, 0)"
	vbox.add_child(mouse_pos_label)
	
	var mouse_world_label = Label.new()
	mouse_world_label.name = "MouseWorldLabel"
	mouse_world_label.text = "Mouse World: (0, 0)"
	vbox.add_child(mouse_world_label)
	
	var camera_pos_label = Label.new()
	camera_pos_label.name = "CameraPosLabel"
	camera_pos_label.text = "Camera: (0, 0)"
	vbox.add_child(camera_pos_label)
	
	var player_pos_label = Label.new()
	player_pos_label.name = "PlayerPosLabel"
	player_pos_label.text = "Player: (0, 0)"
	vbox.add_child(player_pos_label)
	
	# Click position tracking
	var click_tracking_toggle = CheckBox.new()
	click_tracking_toggle.name = "ClickTrackingToggle"
	click_tracking_toggle.text = "Track Click Positions"
	click_tracking_toggle.connect("toggled", self, "_on_click_tracking_toggled")
	vbox.add_child(click_tracking_toggle)
	
	# Zoom level controls
	var zoom_label = Label.new()
	zoom_label.text = "Zoom Level Controls:"
	vbox.add_child(zoom_label)
	
	var zoom_in_btn = Button.new()
	zoom_in_btn.text = "Zoom In (2x)"
	zoom_in_btn.connect("pressed", self, "_on_zoom_in")
	vbox.add_child(zoom_in_btn)
	
	var zoom_out_btn = Button.new()
	zoom_out_btn.text = "Zoom Out (0.5x)"
	zoom_out_btn.connect("pressed", self, "_on_zoom_out")
	vbox.add_child(zoom_out_btn)
	
	var zoom_reset_btn = Button.new()
	zoom_reset_btn.text = "Reset Zoom (1x)"
	zoom_reset_btn.connect("pressed", self, "_on_zoom_reset")
	vbox.add_child(zoom_reset_btn)
	
	var current_zoom_label = Label.new()
	current_zoom_label.name = "CurrentZoomLabel"
	current_zoom_label.text = "Current Zoom: 1.0x"
	vbox.add_child(current_zoom_label)
	
	# Visual grid overlay toggle
	var grid_toggle = CheckBox.new()
	grid_toggle.name = "GridToggle"
	grid_toggle.text = "Show Coordinate Grid"
	grid_toggle.connect("toggled", self, "_on_grid_overlay_toggled")
	vbox.add_child(grid_toggle)
	
	# Transformation validation
	var validation_label = Label.new()
	validation_label.text = "Transformation Validation:"
	vbox.add_child(validation_label)
	
	var validate_btn = Button.new()
	validate_btn.text = "Validate Transformations"
	validate_btn.connect("pressed", self, "_on_validate_transformations")
	vbox.add_child(validate_btn)
	
	var validation_result_label = Label.new()
	validation_result_label.name = "ValidationResultLabel"
	validation_result_label.text = "Status: Not Tested"
	vbox.add_child(validation_result_label)
	
	control_panel.add_child(panel)

func setup_state_panel():
	var panel = ScrollContainer.new()
	panel.name = "State"
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Camera State Monitoring"
	vbox.add_child(title)
	
	var current_state_label = Label.new()
	current_state_label.name = "CurrentStateLabel"
	current_state_label.text = "State: UNKNOWN"
	vbox.add_child(current_state_label)
	
	var history_label = Label.new()
	history_label.name = "HistoryLabel"
	history_label.text = "History: Empty"
	vbox.add_child(history_label)
	
	var clear_btn = Button.new()
	clear_btn.text = "Clear History"
	clear_btn.connect("pressed", self, "_on_clear_history")
	vbox.add_child(clear_btn)
	
	control_panel.add_child(panel)

func setup_bounds_panel():
	var panel = ScrollContainer.new()
	panel.name = "Bounds"
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Camera Bounds Testing"
	vbox.add_child(title)
	
	var bounds_label = Label.new()
	bounds_label.name = "BoundsLabel"
	bounds_label.text = "Bounds: Not Set"
	vbox.add_child(bounds_label)
	
	var debug_toggle = CheckBox.new()
	debug_toggle.text = "Show Debug Bounds"
	debug_toggle.connect("toggled", self, "_on_debug_bounds_toggled")
	vbox.add_child(debug_toggle)
	
	control_panel.add_child(panel)

func setup_scaling_panel():
	var panel = ScrollContainer.new()
	panel.name = "Scaling"
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Background Scaling Validation"
	vbox.add_child(title)
	
	var bg_size_label = Label.new()
	bg_size_label.name = "BgSizeLabel"
	bg_size_label.text = "Background: (0, 0)"
	vbox.add_child(bg_size_label)
	
	var viewport_size_label = Label.new()
	viewport_size_label.name = "ViewportSizeLabel"
	viewport_size_label.text = "Viewport: (0, 0)"
	vbox.add_child(viewport_size_label)
	
	var scale_label = Label.new()
	scale_label.name = "ScaleLabel"
	scale_label.text = "Scale: (1.0, 1.0)"
	vbox.add_child(scale_label)
	
	var recalc_btn = Button.new()
	recalc_btn.text = "Recalculate Zoom"
	recalc_btn.connect("pressed", self, "_on_recalculate_zoom")
	vbox.add_child(recalc_btn)
	
	control_panel.add_child(panel)

func connect_signals():
	connect("test_completed", self, "_on_test_completed")
	connect("visual_issue_detected", self, "_on_visual_issue_detected")

func log_output(message):
	if output_display:
		output_display.append_bbcode("[color=lime]" + message + "[/color]\n")

# Input handling for background switching
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.scancode >= KEY_1 and event.scancode <= KEY_8:
			var bg_index = event.scancode - KEY_1 + 1
			switch_background(bg_index)

func switch_background(index):
	var bg_names = ["spaceport", "security", "mall", "trading", "engineering", "medical", "barracks", "tram"]
	if index >= 1 and index <= bg_names.size():
		current_background = bg_names[index - 1]
		current_background_index = index
		load_test_background(current_background)
		log_output("Switched to background " + str(index) + ": " + current_background)

# Camera signal handlers
func _on_camera_state_changed(old_state, new_state):
	var entry = {
		"timestamp": OS.get_system_time_secs(),
		"old_state": old_state,
		"new_state": new_state
	}
	camera_state_history.append(entry)
	log_output("Camera state: " + str(old_state) + " -> " + str(new_state))

func _on_camera_bounds_changed(new_bounds):
	log_output("Camera bounds changed: " + str(new_bounds))

func _on_camera_position_changed(new_position):
	# Only log significant position changes to avoid spam
	pass

func _on_test_completed(test_name, result):
	test_results[test_name] = result
	log_output("Test completed: " + test_name + " = " + str(result))

func _on_visual_issue_detected(issue_type, details):
	visual_validation_passed = false
	log_output("VISUAL ISSUE: " + issue_type + " - " + details)

# Button handlers
func _on_center_camera():
	if camera and camera.has_method("move_to_position"):
		var center_pos = Vector2(background_size.x / 2, background_size.y / 2)
		camera.move_to_position(center_pos)
		log_output("Moving camera to center: " + str(center_pos))

func _on_move_left():
	if camera and camera.has_method("move_to_position"):
		var left_pos = Vector2(background_size.x * 0.2, background_size.y / 2)
		camera.move_to_position(left_pos)
		log_output("Moving camera to left: " + str(left_pos))

func _on_move_right():
	if camera and camera.has_method("move_to_position"):
		var right_pos = Vector2(background_size.x * 0.8, background_size.y / 2)
		camera.move_to_position(right_pos)
		log_output("Moving camera to right: " + str(right_pos))

func _on_clear_history():
	camera_state_history.clear()
	signal_emission_log.clear()
	log_output("Cleared camera history")

func _on_debug_bounds_toggled(enabled):
	if camera and "debug_draw" in camera:
		camera.debug_draw = enabled
		log_output("Debug bounds: " + str(enabled))

func _on_recalculate_zoom():
	if camera and camera.has_method("calculate_optimal_zoom"):
		camera.calculate_optimal_zoom()
		log_output("Recalculated optimal zoom")

# Additional button handlers for comprehensive test controls
func _on_follow_player_toggled(enabled):
	if camera and "follow_player" in camera:
		camera.follow_player = enabled
		log_output("Follow player: " + str(enabled))

func _on_transition_type_changed(index):
	var types = ["Smooth", "Linear", "Instant"]
	log_output("Transition type changed to: " + types[index])

func _on_speed_changed(value):
	if camera and "follow_smoothing" in camera:
		camera.follow_smoothing = value
	var speed_label = ui.get_node_or_null("ControlPanel/Movement/VBoxContainer/SpeedValueLabel")
	if speed_label:
		speed_label.text = str(value)
	log_output("Movement speed: " + str(value))

func _on_test_left_edge():
	if camera:
		var edge_pos = Vector2(0, background_size.y / 2)
		camera.move_to_position(edge_pos)
		log_output("Testing left edge: " + str(edge_pos))

func _on_test_right_edge():
	if camera:
		var edge_pos = Vector2(background_size.x, background_size.y / 2)
		camera.move_to_position(edge_pos)
		log_output("Testing right edge: " + str(edge_pos))

func _on_test_boundary_violation():
	if camera:
		var violation_pos = Vector2(-500, -500)
		camera.move_to_position(violation_pos)
		log_output("Testing boundary violation: " + str(violation_pos))

func _on_click_tracking_toggled(enabled):
	log_output("Click tracking: " + str(enabled))

func _on_zoom_in():
	if camera:
		camera.zoom = camera.zoom * 0.5
		log_output("Zoomed in: " + str(camera.zoom))

func _on_zoom_out():
	if camera:
		camera.zoom = camera.zoom * 2.0
		log_output("Zoomed out: " + str(camera.zoom))

func _on_zoom_reset():
	if camera:
		camera.zoom = Vector2(1.0, 1.0)
		log_output("Reset zoom: " + str(camera.zoom))

func _on_grid_overlay_toggled(enabled):
	log_output("Grid overlay: " + str(enabled))

func _on_validate_transformations():
	log_output("Running transformation validation...")
	# Add transformation validation logic here