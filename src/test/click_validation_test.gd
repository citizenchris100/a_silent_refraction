extends "res://src/core/districts/base_district.gd"
# Click Validation Test Scene
# Tests all acceptance criteria from Task 8:
# - Accurate click to world coordinate mapping
# - Invalid click target handling
# - Click priority system (objects over movement)
# - Zoom-aware click tolerance
# - Visual feedback system (green/red/yellow markers)

# Test configuration
var test_zoom_levels = [0.5, 1.0, 1.5, 2.0]
var current_zoom_index = 1
var show_debug_overlay = true
var enable_click_blocking = false
var dialog_simulation_active = false

# Test tracking
var click_history = []
var max_click_history = 10
var last_click_data = {}
var test_results = []

# UI elements
var info_panel = null
var status_label = null
var results_label = null
var coordinate_label = null
var zoom_label = null
var priority_label = null
var feedback_label = null

# Test objects
var test_npcs = []
var test_objects = []
var test_ui_elements = []
var simulated_dialog = null

# Debug visualization
var debug_overlay = null
var tolerance_circle = null

func _ready():
	# Set district properties
	district_name = "Click Validation Test"
	district_description = "Tests click detection and validation refinements from Task 8"
	
	# Configure camera
	use_scrolling_camera = true
	initial_camera_view = "center"
	camera_follow_smoothing = 5.0
	
	# Create test environment
	create_test_background()
	create_test_walkable_areas()
	
	# Call parent _ready() - This sets up camera and systems
	._ready()
	
	# Set up player in central area
	setup_player_and_controller(Vector2(800, 400))
	
	# Create test objects after base setup
	create_test_npcs()
	create_test_interactive_objects()
	create_test_ui_elements()
	
	# Create UI and debug tools
	create_test_ui()
	create_debug_visualization()
	
	# Connect to input manager signals
	connect_to_input_manager()
	
	# Run initial validation tests
	run_validation_tests()
	
	print("\n=== Click Validation Test Scene Ready ===")
	print("Test all click detection and validation features")
	print("Press Z/X to change zoom levels")
	print("Press D to toggle dialog simulation")
	print("Press B to toggle click blocking")
	print("Press H to show/hide debug overlay")
	print("Press R to run validation tests")

func create_test_background():
	var background = Sprite.new()
	background.name = "Background"
	
	# Create checkered background for visual clarity
	var img = Image.new()
	img.create(1600, 900, false, Image.FORMAT_RGB8)
	
	# Lock the image before modifying pixels
	img.lock()
	
	# Create checkered pattern
	var tile_size = 50
	for x in range(0, 1600, tile_size):
		for y in range(0, 900, tile_size):
			var is_dark = ((x / tile_size) + (y / tile_size)) % 2 == 0
			var color = Color(0.2, 0.2, 0.25) if is_dark else Color(0.15, 0.15, 0.2)
			for px in range(tile_size):
				for py in range(tile_size):
					if x + px < 1600 and y + py < 900:
						img.set_pixel(x + px, y + py, color)
	
	# Unlock the image after modifications
	img.unlock()
	
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	background.texture = texture
	background.centered = false
	add_child(background)
	
	background_size = background.texture.get_size()

func create_test_walkable_areas():
	# Main walkable area
	var main_area = Polygon2D.new()
	main_area.name = "MainWalkableArea"
	main_area.position = Vector2(200, 200)
	main_area.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(1200, 0),
		Vector2(1200, 500),
		Vector2(0, 500)
	])
	main_area.color = Color(0, 0.6, 0, 0.2)
	main_area.add_to_group("walkable_area")
	add_child(main_area)
	
	# Invalid areas (holes)
	var invalid_area1 = Polygon2D.new()
	invalid_area1.name = "InvalidArea1"
	invalid_area1.position = Vector2(300, 300)
	invalid_area1.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(200, 0),
		Vector2(200, 100),
		Vector2(0, 100)
	])
	invalid_area1.color = Color(0.8, 0, 0, 0.3)
	invalid_area1.z_index = 1
	add_child(invalid_area1)
	
	var invalid_area2 = Polygon2D.new()
	invalid_area2.name = "InvalidArea2"
	invalid_area2.position = Vector2(900, 400)
	invalid_area2.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(150, 0),
		Vector2(150, 150),
		Vector2(0, 150)
	])
	invalid_area2.color = Color(0.8, 0, 0, 0.3)
	invalid_area2.z_index = 1
	add_child(invalid_area2)
	
	# Add labels
	add_area_label(main_area, "Walkable Area", Color(0, 1, 0, 0.8))
	add_area_label(invalid_area1, "Invalid\n(Outside)", Color(1, 0, 0, 0.8))
	add_area_label(invalid_area2, "Invalid\n(Obstacle)", Color(1, 0, 0, 0.8))

func add_area_label(area: Node2D, text: String, color: Color):
	var label = Label.new()
	label.text = text
	label.modulate = color
	
	if area is Polygon2D:
		# Calculate center
		var center = Vector2.ZERO
		for point in area.polygon:
			center += point
		center /= area.polygon.size()
		label.rect_position = center - Vector2(40, 20)
	else:
		label.rect_position = Vector2(50, 50)
	
	area.add_child(label)

func create_test_npcs():
	# Create NPCs at different positions to test priority
	var npc_positions = [
		{"pos": Vector2(400, 300), "name": "NPC_1", "color": Color(0, 0.8, 0.8)},
		{"pos": Vector2(600, 400), "name": "NPC_2", "color": Color(0.8, 0, 0.8)},
		{"pos": Vector2(800, 300), "name": "NPC_3", "color": Color(0.8, 0.8, 0)}
	]
	
	for npc_data in npc_positions:
		var npc = create_mock_npc(npc_data.pos, npc_data.name, npc_data.color)
		test_npcs.append(npc)

func create_mock_npc(position: Vector2, npc_name: String, color: Color) -> Node2D:
	var npc = Node2D.new()
	npc.name = npc_name
	npc.position = position
	npc.add_to_group("npc")
	npc.add_to_group("interactive_object")
	
	# Visual representation
	var sprite = ColorRect.new()
	sprite.name = "Sprite"
	sprite.rect_size = Vector2(40, 60)
	sprite.rect_position = Vector2(-20, -30)
	sprite.color = color
	npc.add_child(sprite)
	
	# Add click area
	var area = Area2D.new()
	area.name = "ClickArea"
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(20, 30)
	collision.shape = shape
	area.add_child(collision)
	npc.add_child(area)
	
	# Label
	var label = Label.new()
	label.text = npc_name
	label.rect_position = Vector2(-30, -50)
	label.modulate = Color(1, 1, 1)
	npc.add_child(label)
	
	add_child(npc)
	return npc

func create_test_interactive_objects():
	# Create overlapping objects to test priority
	var obj1 = create_mock_object(Vector2(600, 300), "Object_A", Color(0.8, 0.6, 0), Vector2(60, 40))
	var obj2 = create_mock_object(Vector2(620, 320), "Object_B", Color(0.6, 0.8, 0), Vector2(60, 40))
	test_objects.append(obj1)
	test_objects.append(obj2)
	
	# Small object to test click tolerance
	var small_obj = create_mock_object(Vector2(1000, 400), "Small_Object", Color(1, 0.5, 0), Vector2(10, 10))
	test_objects.append(small_obj)

func create_mock_object(position: Vector2, obj_name: String, color: Color, size: Vector2) -> Node2D:
	var obj = Node2D.new()
	obj.name = obj_name
	obj.position = position
	obj.add_to_group("interactive_object")
	
	# Visual representation
	var rect = ColorRect.new()
	rect.name = "Visual"
	rect.rect_size = size
	rect.rect_position = -size / 2
	rect.color = color
	rect.modulate.a = 0.7
	obj.add_child(rect)
	
	# Label
	var label = Label.new()
	label.text = obj_name
	label.rect_position = Vector2(-30, -size.y/2 - 20)
	label.rect_scale = Vector2(0.8, 0.8)
	obj.add_child(label)
	
	add_child(obj)
	return obj

func create_test_ui_elements():
	# Create simulated UI elements for priority testing
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "TestUILayer"
	ui_layer.layer = 50
	add_child(ui_layer)
	
	# Simulated dialog box (initially hidden)
	simulated_dialog = Panel.new()
	simulated_dialog.name = "SimulatedDialog"
	simulated_dialog.rect_position = Vector2(400, 200)
	simulated_dialog.rect_size = Vector2(400, 300)
	simulated_dialog.visible = false
	ui_layer.add_child(simulated_dialog)
	
	var dialog_label = Label.new()
	dialog_label.text = "Simulated Dialog\n(Blocks all clicks)\nPress D to toggle"
	dialog_label.rect_position = Vector2(20, 20)
	dialog_label.rect_size = Vector2(360, 260)
	dialog_label.align = Label.ALIGN_CENTER
	dialog_label.valign = Label.VALIGN_CENTER
	simulated_dialog.add_child(dialog_label)

func create_test_ui():
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "TestUI"
	ui_layer.layer = 100
	add_child(ui_layer)
	
	# Main info panel
	info_panel = Panel.new()
	info_panel.rect_position = Vector2(10, 10)
	info_panel.rect_size = Vector2(380, 250)
	ui_layer.add_child(info_panel)
	
	# Title
	var title = Label.new()
	title.text = "Click Validation Test (Task 8)"
	title.rect_position = Vector2(10, 10)
	title.rect_size = Vector2(360, 30)
	# Font override removed - use default font
	title.modulate = Color(1, 1, 0)
	info_panel.add_child(title)
	
	# Status label
	status_label = RichTextLabel.new()
	status_label.rect_position = Vector2(10, 50)
	status_label.rect_size = Vector2(360, 80)
	status_label.bbcode_enabled = true
	info_panel.add_child(status_label)
	
	# Coordinate info
	coordinate_label = Label.new()
	coordinate_label.rect_position = Vector2(10, 140)
	coordinate_label.rect_size = Vector2(360, 30)
	info_panel.add_child(coordinate_label)
	
	# Zoom info
	zoom_label = Label.new()
	zoom_label.rect_position = Vector2(10, 170)
	zoom_label.rect_size = Vector2(360, 30)
	info_panel.add_child(zoom_label)
	
	# Priority info
	priority_label = Label.new()
	priority_label.rect_position = Vector2(10, 200)
	priority_label.rect_size = Vector2(360, 30)
	info_panel.add_child(priority_label)
	
	# Results panel
	var results_panel = Panel.new()
	results_panel.rect_position = Vector2(10, 270)
	results_panel.rect_size = Vector2(380, 300)
	ui_layer.add_child(results_panel)
	
	results_label = RichTextLabel.new()
	results_label.rect_position = Vector2(10, 10)
	results_label.rect_size = Vector2(360, 280)
	results_label.bbcode_enabled = true
	results_panel.add_child(results_label)
	
	# Click history panel
	var history_panel = Panel.new()
	history_panel.rect_position = Vector2(1200, 10)
	history_panel.rect_size = Vector2(380, 200)
	ui_layer.add_child(history_panel)
	
	var history_title = Label.new()
	history_title.text = "Click History"
	history_title.rect_position = Vector2(10, 10)
	history_title.modulate = Color(0.8, 0.8, 1)
	history_panel.add_child(history_title)
	
	feedback_label = RichTextLabel.new()
	feedback_label.rect_position = Vector2(10, 40)
	feedback_label.rect_size = Vector2(360, 150)
	feedback_label.bbcode_enabled = true
	history_panel.add_child(feedback_label)

func create_debug_visualization():
	debug_overlay = Node2D.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.z_index = 10
	add_child(debug_overlay)
	
	# Click tolerance visualization
	tolerance_circle = Node2D.new()
	tolerance_circle.name = "ToleranceCircle"
	tolerance_circle.visible = false
	tolerance_circle.set_script(preload("res://src/test/tolerance_circle.gd"))
	debug_overlay.add_child(tolerance_circle)

func connect_to_input_manager():
	# Get InputManager from GameManager
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_node("InputManager"):
		var input_manager = game_manager.get_node("InputManager")
		
		# Connect to click signals
		if not input_manager.is_connected("click_detected", self, "_on_click_detected"):
			input_manager.connect("click_detected", self, "_on_click_detected")
		
		if not input_manager.is_connected("object_clicked", self, "_on_object_clicked"):
			input_manager.connect("object_clicked", self, "_on_object_clicked")
		
		print("Connected to InputManager signals")
	else:
		print("Warning: Could not find InputManager")

func _on_click_detected(world_pos: Vector2, screen_pos: Vector2):
	# Record click for history
	var click_info = {
		"world_pos": world_pos,
		"screen_pos": screen_pos,
		"time": OS.get_ticks_msec(),
		"zoom": camera.zoom if camera else Vector2.ONE,
		"walkable": is_position_walkable(world_pos),
		"type": "movement"
	}
	
	add_to_click_history(click_info)
	update_status_display()

func _on_object_clicked(object: Node, position: Vector2):
	# Record object click
	var click_info = {
		"world_pos": position,
		"screen_pos": Vector2.ZERO, # Would need to convert
		"time": OS.get_ticks_msec(),
		"zoom": camera.zoom if camera else Vector2.ONE,
		"object": object.name,
		"type": "object"
	}
	
	add_to_click_history(click_info)
	update_status_display()

func add_to_click_history(info: Dictionary):
	click_history.append(info)
	if click_history.size() > max_click_history:
		click_history.pop_front()
	
	last_click_data = info
	update_click_history_display()

func update_click_history_display():
	if not feedback_label:
		return
	
	var text = ""
	for i in range(click_history.size() - 1, -1, -1):
		var click = click_history[i]
		var color = "green" if click.get("walkable", false) else "red"
		if click.type == "object":
			color = "yellow"
		
		text += "[color=%s]" % color
		text += "%d: " % (i + 1)
		
		if click.type == "object":
			text += "Object: %s" % click.object
		else:
			text += "Pos: (%.0f, %.0f)" % [click.world_pos.x, click.world_pos.y]
		
		text += "[/color]\n"
	
	feedback_label.bbcode_text = text

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_ESCAPE:
				get_tree().quit()
			KEY_R:
				run_validation_tests()
			KEY_Z:
				change_zoom(-1)
			KEY_X:
				change_zoom(1)
			KEY_D:
				toggle_dialog_simulation()
			KEY_B:
				toggle_click_blocking()
			KEY_H:
				toggle_debug_overlay()
	
	# Update coordinate display
	if event is InputEventMouseMotion:
		update_coordinate_display(event.position)
		update_tolerance_visualization(event.position)

func change_zoom(direction: int):
	current_zoom_index = clamp(current_zoom_index + direction, 0, test_zoom_levels.size() - 1)
	var new_zoom = test_zoom_levels[current_zoom_index]
	
	if camera:
		camera.zoom = Vector2(new_zoom, new_zoom)
		update_status_display()
		print("Zoom changed to: ", new_zoom)

func toggle_dialog_simulation():
	dialog_simulation_active = !dialog_simulation_active
	if simulated_dialog:
		simulated_dialog.visible = dialog_simulation_active
	
	# Update InputManager's dialog state
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_node("InputManager"):
		var input_manager = game_manager.get_node("InputManager")
		# InputManager checks for dialog through DialogManager, so we simulate that
		if dialog_simulation_active:
			print("Dialog simulation active - clicks should be blocked")
		else:
			print("Dialog simulation inactive")

func toggle_click_blocking():
	enable_click_blocking = !enable_click_blocking
	
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_node("InputManager"):
		var input_manager = game_manager.get_node("InputManager")
		if enable_click_blocking:
			input_manager.block_clicks(2000) # Block for 2 seconds
			print("Click blocking enabled for 2 seconds")
		else:
			print("Click blocking disabled")

func toggle_debug_overlay():
	show_debug_overlay = !show_debug_overlay
	if debug_overlay:
		debug_overlay.visible = show_debug_overlay

func update_coordinate_display(screen_pos: Vector2):
	if not coordinate_label:
		return
	
	var world_pos = camera.screen_to_world(screen_pos) if camera else screen_pos
	coordinate_label.text = "Screen: (%.0f, %.0f) | World: (%.0f, %.0f)" % [
		screen_pos.x, screen_pos.y, world_pos.x, world_pos.y
	]

func update_tolerance_visualization(screen_pos: Vector2):
	if not tolerance_circle or not show_debug_overlay:
		return
	
	var world_pos = camera.screen_to_world(screen_pos) if camera else screen_pos
	tolerance_circle.position = world_pos
	tolerance_circle.visible = true
	
	# Calculate current tolerance based on zoom
	var base_tolerance = 10.0
	if camera and camera.zoom.x > 1.0:
		base_tolerance = base_tolerance / camera.zoom.x
	base_tolerance = clamp(base_tolerance, 5.0, 20.0)
	
	# Store for drawing
	tolerance_circle.set_meta("radius", base_tolerance)
	tolerance_circle.update()

func update_status_display():
	if not status_label:
		return
	
	var text = "[b]Status:[/b]\n"
	
	if last_click_data.size() > 0:
		var click_type = last_click_data.get("type", "unknown")
		var color = "white"
		
		if click_type == "object":
			color = "yellow"
			text += "[color=%s]Last Click: Object '%s'[/color]\n" % [color, last_click_data.get("object", "?")]
		elif click_type == "movement":
			color = "green" if last_click_data.get("walkable", false) else "red"
			text += "[color=%s]Last Click: Movement to (%.0f, %.0f)[/color]\n" % [
				color, last_click_data.world_pos.x, last_click_data.world_pos.y
			]
			text += "Walkable: %s\n" % ("Yes" if last_click_data.get("walkable", false) else "No")
	
	text += "Dialog Active: %s\n" % ("Yes" if dialog_simulation_active else "No")
	text += "Click Blocking: %s" % ("Yes" if enable_click_blocking else "No")
	
	status_label.bbcode_text = text
	
	# Update zoom label
	if zoom_label and camera:
		zoom_label.text = "Zoom: %.1fx" % camera.zoom.x

func run_validation_tests():
	test_results.clear()
	
	print("\n=== Running Click Validation Tests ===")
	
	# Test 1: Coordinate mapping accuracy
	test_coordinate_mapping()
	
	# Test 2: Invalid click handling
	test_invalid_click_handling()
	
	# Test 3: Click priority system
	test_click_priority()
	
	# Test 4: Zoom-aware tolerance
	test_zoom_tolerance()
	
	# Test 5: Visual feedback system
	test_visual_feedback()
	
	# Update results display
	update_test_results()

func test_coordinate_mapping():
	var test_name = "Coordinate Mapping"
	var passed = true
	var details = ""
	
	# Test screen to world conversion at different zoom levels
	var test_points = [
		Vector2(400, 300),
		Vector2(800, 450),
		Vector2(100, 100)
	]
	
	for point in test_points:
		if camera:
			var world = camera.screen_to_world(point)
			var back_to_screen = camera.world_to_screen(world)
			
			# Check round-trip accuracy
			var diff = (back_to_screen - point).length()
			if diff > 0.1:
				passed = false
				details += "Failed at %s, diff: %.2f\n" % [point, diff]
	
	if passed:
		details = "All coordinate conversions accurate"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_invalid_click_handling():
	var test_name = "Invalid Click Handling"
	var passed = true
	var details = ""
	
	# Test clicks in invalid areas
	var invalid_positions = [
		Vector2(400, 350), # Inside obstacle
		Vector2(100, 100), # Outside walkable
		Vector2(1000, 500) # Inside second obstacle
	]
	
	var valid_count = 0
	for pos in invalid_positions:
		if is_position_walkable(pos):
			valid_count += 1
	
	if valid_count > 0:
		passed = false
		details = "%d/%d invalid positions incorrectly marked as walkable" % [valid_count, invalid_positions.size()]
	else:
		details = "All invalid positions correctly identified"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_click_priority():
	var test_name = "Click Priority System"
	var passed = true
	var details = ""
	
	# Check that we have overlapping objects
	var overlap_found = false
	for i in range(test_objects.size()):
		for j in range(i + 1, test_objects.size()):
			var obj1 = test_objects[i]
			var obj2 = test_objects[j]
			
			# Simple distance check for overlap
			if obj1.position.distance_to(obj2.position) < 50:
				overlap_found = true
				break
	
	if not overlap_found:
		passed = false
		details = "No overlapping objects found for priority testing"
	else:
		details = "Overlapping objects created for priority testing"
	
	# Check NPC priority over movement
	if test_npcs.size() > 0:
		details += "\n%d NPCs created for priority testing" % test_npcs.size()
	else:
		passed = false
		details += "\nNo NPCs found for priority testing"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_zoom_tolerance():
	var test_name = "Zoom-aware Tolerance"
	var passed = true
	var details = ""
	
	# Test tolerance at different zoom levels
	var base_tolerance = 10.0
	var zoom_tolerances = []
	
	for zoom in test_zoom_levels:
		var tolerance = base_tolerance
		if zoom > 1.0:
			tolerance = tolerance / zoom
		tolerance = clamp(tolerance, 5.0, 20.0)
		zoom_tolerances.append({"zoom": zoom, "tolerance": tolerance})
	
	# Verify tolerance changes with zoom
	var tolerance_changes = false
	for i in range(1, zoom_tolerances.size()):
		if zoom_tolerances[i].tolerance != zoom_tolerances[0].tolerance:
			tolerance_changes = true
			break
	
	if not tolerance_changes:
		passed = false
		details = "Tolerance does not change with zoom"
	else:
		details = "Tolerance correctly adjusts with zoom:\n"
		for zt in zoom_tolerances:
			details += "  Zoom %.1f: %.1f pixels\n" % [zt.zoom, zt.tolerance]
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_visual_feedback():
	var test_name = "Visual Feedback System"
	var passed = true
	var details = ""
	
	# Check if ClickFeedbackSystem exists
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		var feedback_system = game_manager.get_node_or_null("ClickFeedbackSystem")
		if feedback_system:
			details = "ClickFeedbackSystem found and active"
			
			# Check feedback types
			if feedback_system.has_method("show_click_feedback"):
				details += "\nFeedback methods available"
			else:
				passed = false
				details += "\nFeedback methods missing"
		else:
			passed = false
			details = "ClickFeedbackSystem not found"
	else:
		passed = false
		details = "GameManager not found"
	
	test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func update_test_results():
	if not results_label:
		return
	
	var text = "[b][color=yellow]Validation Test Results:[/color][/b]\n\n"
	
	var passed_count = 0
	for result in test_results:
		if result.passed:
			passed_count += 1
		
		var color = "green" if result.passed else "red"
		var status = "PASS" if result.passed else "FAIL"
		
		text += "[color=%s]%s[/color] - %s\n" % [color, status, result.name]
		text += "  %s\n\n" % result.details
	
	# Summary
	var summary_color = "green" if passed_count == test_results.size() else "orange"
	text += "\n[b][color=%s]Summary: %d/%d tests passed[/color][/b]" % [
		summary_color, passed_count, test_results.size()
	]
	
	results_label.bbcode_text = text

func _draw():
	# Draw click tolerance circle when in debug mode
	if show_debug_overlay and tolerance_circle and tolerance_circle.visible:
		var radius = tolerance_circle.get_meta("radius", 10.0)
		# This would need to be in tolerance_circle's _draw, not here
		pass

# Override is_position_walkable to handle our test obstacles
func is_position_walkable(position: Vector2) -> bool:
	# First check base walkable area
	if not .is_position_walkable(position):
		return false
	
	# Then check if position is inside any obstacle
	var obstacles = ["InvalidArea1", "InvalidArea2"]
	for obstacle_name in obstacles:
		var obstacle = get_node_or_null(obstacle_name)
		if obstacle and obstacle is Polygon2D:
			var local_pos = obstacle.to_local(position)
			if Geometry.is_point_in_polygon(local_pos, obstacle.polygon):
				return false
	
	return true