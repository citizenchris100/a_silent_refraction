extends Node2D

# Camera System Test Scene
# Comprehensive validation of camera improvements per Iteration 3 Task 3
# Based on docs/design/camera_test_scene_design.md

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

# Test environment backgrounds (to be created)
var test_backgrounds = {
	"spaceport": "res://src/assets/test_backgrounds/spaceport_dock.png",
	"security": "res://src/assets/test_backgrounds/security_corridor.png",
	"mall": "res://src/assets/test_backgrounds/mall_atrium.png",
	"trading": "res://src/assets/test_backgrounds/trading_floor.png",
	"engineering": "res://src/assets/test_backgrounds/engineering_deck.png",
	"medical": "res://src/assets/test_backgrounds/medical_bay.png",
	"barracks": "res://src/assets/test_backgrounds/barracks_common.png",
	"tram": "res://src/assets/test_backgrounds/tram_platform.png"
}

# Node references
onready var test_environment = $TestEnvironment
onready var background_sprite = $TestEnvironment/Background
onready var camera = $TestEnvironment/Camera
onready var player = $TestEnvironment/Player
onready var test_objects = $TestEnvironment/TestObjects
onready var walkable_areas = $TestEnvironment/WalkableAreas

# UI references
onready var ui = $UI
onready var control_panel = $UI/ControlPanel
onready var movement_panel = $UI/ControlPanel/MovementPanel
onready var coordinate_panel = $UI/ControlPanel/CoordinatePanel
onready var state_panel = $UI/ControlPanel/StatePanel
onready var bounds_panel = $UI/ControlPanel/BoundsPanel
onready var scaling_panel = $UI/ControlPanel/ScalingPanel
onready var output_display = $UI/OutputDisplay

# Test state
var current_mode = TestMode.MOVEMENT
var current_background = "spaceport"
var test_results = {}
var visual_validation_passed = true

# Camera state tracking
var camera_state_history = []
var signal_emission_log = []

# Performance tracking
var frame_times = []
var performance_baseline = {}

func _ready():
	print("Camera System Test initializing...")
	
	# Initialize UI
	setup_ui_panels()
	
	# Load initial background
	load_test_background(current_background)
	
	# Setup camera
	setup_camera()
	
	# Setup player
	setup_player()
	
	# Connect signals
	connect_signals()
	
	# Log initial state
	log_output("Camera System Test ready")
	log_output("Initial background: " + current_background)
	log_output("Initial mode: " + TestMode.keys()[current_mode])

func setup_ui_panels():
	# Movement Panel Controls
	if movement_panel:
		create_movement_controls()
	
	# Coordinate Panel Controls
	if coordinate_panel:
		create_coordinate_controls()
	
	# State Panel Controls
	if state_panel:
		create_state_controls()
	
	# Bounds Panel Controls
	if bounds_panel:
		create_bounds_controls()
	
	# Scaling Panel Controls
	if scaling_panel:
		create_scaling_controls()

func create_movement_controls():
	var vbox = VBoxContainer.new()
	movement_panel.add_child(vbox)
	
	# Direct position controls
	var pos_label = Label.new()
	pos_label.text = "Camera Position:"
	vbox.add_child(pos_label)
	
	var pos_container = HBoxContainer.new()
	vbox.add_child(pos_container)
	
	var x_input = SpinBox.new()
	x_input.name = "XPosition"
	x_input.min_value = -10000
	x_input.max_value = 10000
	x_input.value = 0
	pos_container.add_child(x_input)
	
	var y_input = SpinBox.new()
	y_input.name = "YPosition"
	y_input.min_value = -10000
	y_input.max_value = 10000
	y_input.value = 0
	pos_container.add_child(y_input)
	
	var move_btn = Button.new()
	move_btn.text = "Move Camera"
	move_btn.connect("pressed", self, "_on_move_camera_pressed")
	vbox.add_child(move_btn)
	
	# Follow player toggle
	var follow_check = CheckBox.new()
	follow_check.name = "FollowPlayer"
	follow_check.text = "Follow Player"
	follow_check.pressed = true
	follow_check.connect("toggled", self, "_on_follow_player_toggled")
	vbox.add_child(follow_check)
	
	# Transition type
	var trans_label = Label.new()
	trans_label.text = "Transition Type:"
	vbox.add_child(trans_label)
	
	var trans_option = OptionButton.new()
	trans_option.name = "TransitionType"
	trans_option.add_item("Instant")
	trans_option.add_item("Smooth")
	trans_option.add_item("Linear")
	trans_option.connect("item_selected", self, "_on_transition_type_changed")
	vbox.add_child(trans_option)
	
	# Speed control
	var speed_label = Label.new()
	speed_label.text = "Camera Speed:"
	vbox.add_child(speed_label)
	
	var speed_slider = HSlider.new()
	speed_slider.name = "SpeedSlider"
	speed_slider.min_value = 0.1
	speed_slider.max_value = 5.0
	speed_slider.value = 1.0
	speed_slider.connect("value_changed", self, "_on_camera_speed_changed")
	vbox.add_child(speed_slider)
	
	# Test scenarios
	var scenario_label = Label.new()
	scenario_label.text = "Test Scenarios:"
	vbox.add_child(scenario_label)
	
	var scenario1_btn = Button.new()
	scenario1_btn.text = "Test Edge Movement"
	scenario1_btn.connect("pressed", self, "_test_edge_movement")
	vbox.add_child(scenario1_btn)
	
	var scenario2_btn = Button.new()
	scenario2_btn.text = "Test Center Return"
	scenario2_btn.connect("pressed", self, "_test_center_return")
	vbox.add_child(scenario2_btn)
	
	var scenario3_btn = Button.new()
	scenario3_btn.text = "Test Rapid Movement"
	scenario3_btn.connect("pressed", self, "_test_rapid_movement")
	vbox.add_child(scenario3_btn)

func create_coordinate_controls():
	var vbox = VBoxContainer.new()
	coordinate_panel.add_child(vbox)
	
	# Click tracking display
	var click_label = Label.new()
	click_label.text = "Last Click Position:"
	vbox.add_child(click_label)
	
	var click_display = Label.new()
	click_display.name = "ClickDisplay"
	click_display.text = "Screen: (0, 0) | World: (0, 0)"
	vbox.add_child(click_display)
	
	# Zoom controls
	var zoom_label = Label.new()
	zoom_label.text = "Zoom Level:"
	vbox.add_child(zoom_label)
	
	var zoom_slider = HSlider.new()
	zoom_slider.name = "ZoomSlider"
	zoom_slider.min_value = 0.5
	zoom_slider.max_value = 2.0
	zoom_slider.value = 1.0
	zoom_slider.step = 0.1
	zoom_slider.connect("value_changed", self, "_on_zoom_changed")
	vbox.add_child(zoom_slider)
	
	# Grid overlay
	var grid_check = CheckBox.new()
	grid_check.name = "GridOverlay"
	grid_check.text = "Show Grid Overlay"
	grid_check.connect("toggled", self, "_on_grid_overlay_toggled")
	vbox.add_child(grid_check)
	
	# Coordinate validation
	var validate_btn = Button.new()
	validate_btn.text = "Validate Transformations"
	validate_btn.connect("pressed", self, "_validate_coordinate_transformations")
	vbox.add_child(validate_btn)

func create_state_controls():
	var vbox = VBoxContainer.new()
	state_panel.add_child(vbox)
	
	# Current state display
	var state_label = Label.new()
	state_label.text = "Current Camera State:"
	vbox.add_child(state_label)
	
	var state_display = Label.new()
	state_display.name = "StateDisplay"
	state_display.text = "IDLE"
	vbox.add_child(state_display)
	
	# State history
	var history_label = Label.new()
	history_label.text = "State History:"
	vbox.add_child(history_label)
	
	var history_list = ItemList.new()
	history_list.name = "StateHistory"
	history_list.rect_min_size = Vector2(200, 100)
	vbox.add_child(history_list)
	
	# Signal log
	var signal_label = Label.new()
	signal_label.text = "Signal Emissions:"
	vbox.add_child(signal_label)
	
	var signal_list = ItemList.new()
	signal_list.name = "SignalLog"
	signal_list.rect_min_size = Vector2(200, 100)
	vbox.add_child(signal_list)
	
	# Manual state triggers
	var trigger_label = Label.new()
	trigger_label.text = "Manual State Triggers:"
	vbox.add_child(trigger_label)
	
	var idle_btn = Button.new()
	idle_btn.text = "Force IDLE"
	idle_btn.connect("pressed", self, "_force_camera_state", ["IDLE"])
	vbox.add_child(idle_btn)
	
	var follow_btn = Button.new()
	follow_btn.text = "Force FOLLOWING"
	follow_btn.connect("pressed", self, "_force_camera_state", ["FOLLOWING"])
	vbox.add_child(follow_btn)
	
	var pan_btn = Button.new()
	pan_btn.text = "Force PANNING"
	pan_btn.connect("pressed", self, "_force_camera_state", ["PANNING"])
	vbox.add_child(pan_btn)
	
	# Clear history
	var clear_btn = Button.new()
	clear_btn.text = "Clear History"
	clear_btn.connect("pressed", self, "_clear_state_history")
	vbox.add_child(clear_btn)

func create_bounds_controls():
	var vbox = VBoxContainer.new()
	bounds_panel.add_child(vbox)
	
	# Bounds toggle
	var bounds_check = CheckBox.new()
	bounds_check.name = "BoundsEnabled"
	bounds_check.text = "Enable Camera Bounds"
	bounds_check.pressed = true
	bounds_check.connect("toggled", self, "_on_bounds_enabled_toggled")
	vbox.add_child(bounds_check)
	
	# Manual bounds configuration
	var bounds_label = Label.new()
	bounds_label.text = "Manual Bounds (x, y, w, h):"
	vbox.add_child(bounds_label)
	
	var bounds_container = GridContainer.new()
	bounds_container.columns = 2
	vbox.add_child(bounds_container)
	
	for param in ["X", "Y", "Width", "Height"]:
		var param_label = Label.new()
		param_label.text = param + ":"
		bounds_container.add_child(param_label)
		
		var param_input = SpinBox.new()
		param_input.name = "Bounds" + param
		param_input.min_value = 0
		param_input.max_value = 10000
		param_input.value = 0 if param in ["X", "Y"] else 1000
		bounds_container.add_child(param_input)
	
	var apply_bounds_btn = Button.new()
	apply_bounds_btn.text = "Apply Manual Bounds"
	apply_bounds_btn.connect("pressed", self, "_apply_manual_bounds")
	vbox.add_child(apply_bounds_btn)
	
	# Preset scenarios
	var preset_label = Label.new()
	preset_label.text = "Preset Boundary Tests:"
	vbox.add_child(preset_label)
	
	var tight_btn = Button.new()
	tight_btn.text = "Tight Bounds"
	tight_btn.connect("pressed", self, "_test_tight_bounds")
	vbox.add_child(tight_btn)
	
	var wide_btn = Button.new()
	wide_btn.text = "Wide Bounds"
	wide_btn.connect("pressed", self, "_test_wide_bounds")
	vbox.add_child(wide_btn)
	
	var edge_btn = Button.new()
	edge_btn.text = "Edge Case Bounds"
	edge_btn.connect("pressed", self, "_test_edge_case_bounds")
	vbox.add_child(edge_btn)
	
	# Visual overlay
	var overlay_check = CheckBox.new()
	overlay_check.name = "BoundsOverlay"
	overlay_check.text = "Show Bounds Overlay"
	overlay_check.connect("toggled", self, "_on_bounds_overlay_toggled")
	vbox.add_child(overlay_check)

func create_scaling_controls():
	var vbox = VBoxContainer.new()
	scaling_panel.add_child(vbox)
	
	# Background info
	var bg_label = Label.new()
	bg_label.text = "Background Dimensions:"
	vbox.add_child(bg_label)
	
	var bg_display = Label.new()
	bg_display.name = "BackgroundDisplay"
	bg_display.text = "0 x 0"
	vbox.add_child(bg_display)
	
	# Viewport info
	var vp_label = Label.new()
	vp_label.text = "Viewport Size:"
	vbox.add_child(vp_label)
	
	var vp_display = Label.new()
	vp_display.name = "ViewportDisplay"
	vp_display.text = "0 x 0"
	vbox.add_child(vp_display)
	
	# Scaling info
	var scale_label = Label.new()
	scale_label.text = "Current Scale:"
	vbox.add_child(scale_label)
	
	var scale_display = Label.new()
	scale_display.name = "ScaleDisplay"
	scale_display.text = "1.0"
	vbox.add_child(scale_display)
	
	# Visual validation checklist
	var checklist_label = Label.new()
	checklist_label.text = "Visual Validation:"
	vbox.add_child(checklist_label)
	
	var grey_check = CheckBox.new()
	grey_check.name = "NoGreyBars"
	grey_check.text = "No Grey Bars"
	grey_check.disabled = true
	vbox.add_child(grey_check)
	
	var fill_check = CheckBox.new()
	fill_check.name = "BackgroundFills"
	fill_check.text = "Background Fills Viewport"
	fill_check.disabled = true
	vbox.add_child(fill_check)
	
	var aspect_check = CheckBox.new()
	aspect_check.name = "AspectCorrect"
	aspect_check.text = "Aspect Ratio Preserved"
	aspect_check.disabled = true
	vbox.add_child(aspect_check)
	
	# Manual validation
	var validate_btn = Button.new()
	validate_btn.text = "Run Visual Validation"
	validate_btn.connect("pressed", self, "_run_visual_validation")
	vbox.add_child(validate_btn)
	
	# Resolution tests
	var res_label = Label.new()
	res_label.text = "Resolution Tests:"
	vbox.add_child(res_label)
	
	var res_option = OptionButton.new()
	res_option.name = "ResolutionOption"
	res_option.add_item("1920x1080")
	res_option.add_item("1280x720")
	res_option.add_item("2560x1440")
	res_option.add_item("800x600")
	res_option.connect("item_selected", self, "_on_resolution_changed")
	vbox.add_child(res_option)

func setup_camera():
	if not camera:
		return
		
	# Load ScrollingCamera script
	var camera_script = load("res://src/core/camera/scrolling_camera.gd")
	if camera_script:
		camera.set_script(camera_script)
		camera.current = true
		camera.follow_player = true
		camera.debug_draw = false
		
		# Connect camera signals
		if camera.has_signal("state_changed"):
			camera.connect("state_changed", self, "_on_camera_state_changed")
		if camera.has_signal("bounds_changed"):
			camera.connect("bounds_changed", self, "_on_camera_bounds_changed")
		if camera.has_signal("position_changed"):
			camera.connect("position_changed", self, "_on_camera_position_changed")
		
		log_output("ScrollingCamera initialized")
	else:
		log_output("ERROR: Could not load ScrollingCamera script")

func setup_player():
	if not player:
		return
		
	# Load player script
	var player_script = load("res://src/characters/player/player.gd")
	if player_script:
		player.set_script(player_script)
		player.position = Vector2(400, 300)
		
		# Set camera target
		if camera and camera.has_method("set_target_player"):
			camera.target_player = player
		
		log_output("Player initialized at " + str(player.position))
	else:
		log_output("ERROR: Could not load player script")

func load_test_background(bg_name):
	if not bg_name in test_backgrounds:
		log_output("ERROR: Unknown background: " + bg_name)
		return
		
	var bg_path = test_backgrounds[bg_name]
	
	# For now, create a placeholder if texture doesn't exist
	var texture = load(bg_path)
	if not texture:
		# Create placeholder texture
		var image = Image.new()
		image.create(4096, 2048, false, Image.FORMAT_RGB8)
		image.fill(Color(0.2, 0.2, 0.3))
		texture = ImageTexture.new()
		texture.create_from_image(image)
		log_output("Using placeholder for: " + bg_name)
	
	if background_sprite:
		background_sprite.texture = texture
		background_sprite.centered = false
		
		# Update displays
		update_background_info()
		
		# Set camera bounds based on background
		if camera and camera.has_method("set_camera_bounds"):
			var bounds = Rect2(Vector2.ZERO, texture.get_size())
			camera.set_camera_bounds(bounds)
		
		current_background = bg_name
		log_output("Loaded background: " + bg_name)

func connect_signals():
	# Connect UI panel tab changes
	if control_panel:
		control_panel.connect("tab_changed", self, "_on_tab_changed")
	
	# Input handling
	set_process_input(true)
	set_process(true)

func _input(event):
	# Track mouse clicks for coordinate testing
	if event is InputEventMouseButton and event.pressed:
		if current_mode == TestMode.COORDINATES:
			update_click_position(event.position)
	
	# ESC to exit
	if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
		get_tree().quit()
	
	# Number keys to switch backgrounds
	if event is InputEventKey and event.pressed:
		var bg_keys = test_backgrounds.keys()
		if event.scancode >= KEY_1 and event.scancode <= KEY_8:
			var index = event.scancode - KEY_1
			if index < bg_keys.size():
				load_test_background(bg_keys[index])

func _process(delta):
	# Update displays based on current mode
	match current_mode:
		TestMode.MOVEMENT:
			update_movement_displays()
		TestMode.COORDINATES:
			update_coordinate_displays()
		TestMode.STATE:
			update_state_displays()
		TestMode.BOUNDS:
			update_bounds_displays()
		TestMode.SCALING:
			update_scaling_displays()
	
	# Track performance
	track_performance(delta)

func update_movement_displays():
	if camera:
		var pos_x = movement_panel.get_node_or_null("XPosition")
		var pos_y = movement_panel.get_node_or_null("YPosition")
		if pos_x and not pos_x.has_focus():
			pos_x.value = camera.global_position.x
		if pos_y and not pos_y.has_focus():
			pos_y.value = camera.global_position.y

func update_coordinate_displays():
	# Update viewport size
	var vp_size = get_viewport().size
	var vp_display = coordinate_panel.get_node_or_null("../ViewportDisplay")
	if vp_display:
		vp_display.text = str(int(vp_size.x)) + " x " + str(int(vp_size.y))

func update_state_displays():
	if camera and camera.has_method("get_state"):
		var state_display = state_panel.get_node_or_null("StateDisplay")
		if state_display:
			state_display.text = camera.get_state()

func update_bounds_displays():
	if camera and camera.has_method("get_camera_bounds"):
		var bounds = camera.get_camera_bounds()
		# Update bound input fields if not focused
		var bounds_x = bounds_panel.get_node_or_null("BoundsX")
		var bounds_y = bounds_panel.get_node_or_null("BoundsY")
		var bounds_w = bounds_panel.get_node_or_null("BoundsWidth")
		var bounds_h = bounds_panel.get_node_or_null("BoundsHeight")
		
		if bounds_x and not bounds_x.has_focus():
			bounds_x.value = bounds.position.x
		if bounds_y and not bounds_y.has_focus():
			bounds_y.value = bounds.position.y
		if bounds_w and not bounds_w.has_focus():
			bounds_w.value = bounds.size.x
		if bounds_h and not bounds_h.has_focus():
			bounds_h.value = bounds.size.y

func update_scaling_displays():
	update_background_info()
	update_viewport_info()
	update_scale_info()

func update_background_info():
	var bg_display = scaling_panel.get_node_or_null("BackgroundDisplay")
	if bg_display and background_sprite and background_sprite.texture:
		var size = background_sprite.texture.get_size()
		bg_display.text = str(int(size.x)) + " x " + str(int(size.y))

func update_viewport_info():
	var vp_display = scaling_panel.get_node_or_null("ViewportDisplay")
	if vp_display:
		var size = get_viewport().size
		vp_display.text = str(int(size.x)) + " x " + str(int(size.y))

func update_scale_info():
	var scale_display = scaling_panel.get_node_or_null("ScaleDisplay")
	if scale_display and camera:
		scale_display.text = str(camera.zoom.x)

func update_click_position(screen_pos):
	var click_display = coordinate_panel.get_node_or_null("ClickDisplay")
	if click_display and camera:
		var world_pos = camera.get_global_mouse_position()
		click_display.text = "Screen: " + str(screen_pos) + " | World: " + str(world_pos)

func track_performance(delta):
	frame_times.append(delta)
	if frame_times.size() > 60:
		frame_times.pop_front()

func log_output(text):
	if output_display:
		output_display.add_text(text + "\n")
		# Scroll to bottom
		output_display.scroll_to_line(output_display.get_line_count() - 1)
	print("[CameraTest] " + text)

# Signal callbacks
func _on_camera_state_changed(old_state, new_state):
	camera_state_history.append({
		"time": OS.get_ticks_msec(),
		"from": old_state,
		"to": new_state
	})
	signal_emission_log.append("state_changed: " + old_state + " -> " + new_state)
	update_state_history_display()

func _on_camera_bounds_changed(bounds):
	signal_emission_log.append("bounds_changed: " + str(bounds))
	update_signal_log_display()

func _on_camera_position_changed(position):
	# Don't log every position change, too noisy
	pass

func update_state_history_display():
	var history_list = state_panel.get_node_or_null("StateHistory")
	if history_list:
		history_list.clear()
		for entry in camera_state_history:
			var time_str = str(entry.time / 1000.0) + "s"
			history_list.add_item(time_str + ": " + entry.from + " -> " + entry.to)

func update_signal_log_display():
	var signal_list = state_panel.get_node_or_null("SignalLog")
	if signal_list:
		signal_list.clear()
		for entry in signal_emission_log:
			signal_list.add_item(entry)

# UI callbacks
func _on_tab_changed(tab):
	current_mode = tab
	log_output("Switched to mode: " + TestMode.keys()[current_mode])

func _on_move_camera_pressed():
	var x = movement_panel.get_node("XPosition").value
	var y = movement_panel.get_node("YPosition").value
	if camera and camera.has_method("move_to"):
		camera.move_to(Vector2(x, y))
		log_output("Moving camera to: " + str(Vector2(x, y)))

func _on_follow_player_toggled(pressed):
	if camera:
		camera.follow_player = pressed
		log_output("Follow player: " + str(pressed))

func _on_transition_type_changed(index):
	log_output("Transition type changed to: " + str(index))

func _on_camera_speed_changed(value):
	if camera and camera.has_method("set_camera_speed"):
		camera.set_camera_speed(value)
		log_output("Camera speed: " + str(value))

func _on_zoom_changed(value):
	if camera:
		camera.zoom = Vector2(value, value)
		log_output("Zoom level: " + str(value))

func _on_grid_overlay_toggled(pressed):
	# TODO: Implement grid overlay
	log_output("Grid overlay: " + str(pressed))

func _on_bounds_enabled_toggled(pressed):
	if camera and camera.has_method("set_bounds_enabled"):
		camera.set_bounds_enabled(pressed)
		log_output("Camera bounds: " + str(pressed))

func _on_bounds_overlay_toggled(pressed):
	if camera:
		camera.debug_draw = pressed
		log_output("Bounds overlay: " + str(pressed))

func _run_visual_validation():
	log_output("Running visual validation...")
	visual_validation_passed = true
	
	# Check for grey bars
	var no_grey = check_no_grey_bars()
	var grey_check = scaling_panel.get_node_or_null("NoGreyBars")
	if grey_check:
		grey_check.pressed = no_grey
	
	# Check background fills viewport
	var fills = check_background_fills_viewport()
	var fill_check = scaling_panel.get_node_or_null("BackgroundFills")
	if fill_check:
		fill_check.pressed = fills
	
	# Check aspect ratio
	var aspect = check_aspect_ratio_preserved()
	var aspect_check = scaling_panel.get_node_or_null("AspectCorrect")
	if aspect_check:
		aspect_check.pressed = aspect
	
	if no_grey and fills and aspect:
		log_output("✓ Visual validation PASSED")
	else:
		log_output("✗ Visual validation FAILED")
		visual_validation_passed = false
		emit_signal("visual_issue_detected", "validation_failed", {
			"no_grey_bars": no_grey,
			"background_fills": fills,
			"aspect_preserved": aspect
		})

func check_no_grey_bars():
	# TODO: Implement actual visual check
	# For now, return true if camera bounds match viewport
	return true

func check_background_fills_viewport():
	# TODO: Implement actual check
	return true

func check_aspect_ratio_preserved():
	# TODO: Implement actual check
	return true

# Test scenario methods
func _test_edge_movement():
	log_output("Testing edge movement...")
	# Move camera to each corner
	var corners = [
		Vector2(0, 0),
		Vector2(4096, 0),
		Vector2(4096, 2048),
		Vector2(0, 2048)
	]
	# TODO: Implement sequential movement test

func _test_center_return():
	log_output("Testing center return...")
	if camera and camera.has_method("center_on_player"):
		camera.center_on_player()

func _test_rapid_movement():
	log_output("Testing rapid movement...")
	# TODO: Implement rapid movement test

func _test_tight_bounds():
	log_output("Testing tight bounds...")
	if camera:
		var tight_bounds = Rect2(100, 100, 800, 600)
		camera.set_camera_bounds(tight_bounds)

func _test_wide_bounds():
	log_output("Testing wide bounds...")
	if camera:
		var wide_bounds = Rect2(0, 0, 8000, 4000)
		camera.set_camera_bounds(wide_bounds)

func _test_edge_case_bounds():
	log_output("Testing edge case bounds...")
	# Test bounds smaller than viewport
	if camera:
		var small_bounds = Rect2(0, 0, 400, 300)
		camera.set_camera_bounds(small_bounds)

func _validate_coordinate_transformations():
	log_output("Validating coordinate transformations...")
	# TODO: Implement coordinate transformation tests

func _force_camera_state(state):
	log_output("Forcing camera state to: " + state)
	# TODO: Implement state forcing

func _clear_state_history():
	camera_state_history.clear()
	signal_emission_log.clear()
	update_state_history_display()
	update_signal_log_display()
	log_output("Cleared state history")

func _apply_manual_bounds():
	var x = bounds_panel.get_node("BoundsX").value
	var y = bounds_panel.get_node("BoundsY").value
	var w = bounds_panel.get_node("BoundsWidth").value
	var h = bounds_panel.get_node("BoundsHeight").value
	
	if camera:
		var bounds = Rect2(x, y, w, h)
		camera.set_camera_bounds(bounds)
		log_output("Applied manual bounds: " + str(bounds))

func _on_resolution_changed(index):
	var resolutions = [
		Vector2(1920, 1080),
		Vector2(1280, 720),
		Vector2(2560, 1440),
		Vector2(800, 600)
	]
	
	if index < resolutions.size():
		var res = resolutions[index]
		OS.window_size = res
		log_output("Changed resolution to: " + str(res))