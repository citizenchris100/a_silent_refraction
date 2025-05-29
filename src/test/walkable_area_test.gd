extends "res://src/core/districts/base_district.gd"
# Walkable Area Enhancement Test Scene
# Tests all acceptance criteria from Task 7:
# - Multiple walkable areas with priority/layering
# - Point-in-polygon checks for complex shapes
# - Navigation path validation against walkable boundaries
# - Closest valid point finding when clicking outside walkable areas

# Grid configuration for visual reference
const GRID_SIZE = 50
const GRID_COLS = 30
const GRID_ROWS = 20
const GRID_COLOR = Color(1, 1, 1, 0.1)

# Test configuration
var show_grid = true
var show_walkable_bounds = true
var show_click_feedback = true
var show_path_validation = true

# UI elements
var info_label = null
var status_label = null
var test_results_label = null
var coordinate_label = null

# Visual feedback
var click_marker = null
var closest_point_line = null
var path_validation_line = null

# Test tracking
var last_click_world = Vector2.ZERO
var last_click_walkable = false
var last_closest_point = Vector2.ZERO
var current_test_results = []

func _ready():
	# Set district properties
	district_name = "Walkable Area Enhancement Test"
	district_description = "Tests multiple areas, path validation, and closest point finding"
	
	# Configure camera
	use_scrolling_camera = true
	initial_camera_view = "center"
	
	# Create background
	create_test_background()
	
	# Create multiple walkable areas with different configurations
	create_multiple_walkable_areas()
	
	# Call parent _ready() - This sets up camera and systems
	._ready()
	
	# Set up player
	setup_player_and_controller(Vector2(750, 500))  # Start in central area
	
	# Create UI
	create_test_ui()
	
	# Create visual helpers
	create_grid_overlay()
	create_visual_feedback_nodes()
	
	# Enable Navigation2D
	setup_navigation()
	
	# Run initial tests
	run_acceptance_tests()
	
	print("Walkable Area Enhancement Test Ready")
	print("Click anywhere to test movement and walkable area features")
	print("Areas: Island (left), Central (middle), Platforms (right)")
	print("All areas are connected by bridges - you can walk between them!")

func create_test_background():
	var background = Sprite.new()
	background.name = "Background"
	
	# Create background texture
	var img = Image.new()
	img.create(GRID_COLS * GRID_SIZE, GRID_ROWS * GRID_SIZE, false, Image.FORMAT_RGB8)
	img.fill(Color(0.15, 0.15, 0.2))  # Dark blue background
	
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	background.texture = texture
	background.centered = false
	add_child(background)
	
	background_size = background.texture.get_size()

func create_multiple_walkable_areas():
	# Clear any existing walkable areas
	walkable_areas.clear()
	
	# Area 1: Island area (left side) - Complex polygon shape
	var island_area = create_island_walkable_area()
	add_child(island_area)
	
	# Area 2: Central area - Large rectangular area
	var central_area = create_central_walkable_area()
	add_child(central_area)
	
	# Area 3: Platform areas (right side) - Multiple disconnected platforms
	create_platform_walkable_areas()
	
	# Area 4: Bridge area - Connects island to central
	var bridge_area = create_bridge_walkable_area()
	add_child(bridge_area)
	
	# Area 5: Platform bridges - Connect central to platforms
	create_platform_bridges()
	
	# Area 6: Designer priority area (overlapping with central)
	var designer_area = create_designer_priority_area()
	add_child(designer_area)

func create_island_walkable_area() -> Polygon2D:
	var area = Polygon2D.new()
	area.name = "IslandArea"
	area.position = Vector2(100, 200)
	
	# Create complex island shape
	area.polygon = PoolVector2Array([
		Vector2(0, 100),      # Left middle
		Vector2(50, 50),      # Top left
		Vector2(150, 0),      # Top
		Vector2(250, 50),     # Top right
		Vector2(300, 150),    # Right middle
		Vector2(280, 250),    # Bottom right
		Vector2(200, 300),    # Bottom
		Vector2(100, 320),    # Bottom left
		Vector2(20, 280),     # Left bottom
		Vector2(-20, 200)     # Left indent
	])
	
	area.color = Color(0, 0.8, 0, 0.2)  # Green
	area.add_to_group("walkable_area")
	
	# Add label
	add_area_label(area, "Island\n(Complex Shape)")
	
	return area

func create_central_walkable_area() -> Polygon2D:
	var area = Polygon2D.new()
	area.name = "CentralArea"
	area.position = Vector2(600, 300)
	
	# Create large rectangular area
	area.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(400, 0),
		Vector2(400, 400),
		Vector2(0, 400)
	])
	
	area.color = Color(0, 0.6, 0.8, 0.2)  # Blue
	area.add_to_group("walkable_area")
	
	# Add label
	add_area_label(area, "Central Area\n(Main)")
	
	return area

func create_platform_walkable_areas():
	# Platform 1
	var platform1 = Polygon2D.new()
	platform1.name = "Platform1"
	platform1.position = Vector2(1200, 200)
	platform1.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(150, 0),
		Vector2(150, 100),
		Vector2(0, 100)
	])
	platform1.color = Color(0.8, 0.8, 0, 0.2)  # Yellow
	platform1.add_to_group("walkable_area")
	add_child(platform1)
	add_area_label(platform1, "Platform 1")
	
	# Platform 2
	var platform2 = Polygon2D.new()
	platform2.name = "Platform2"
	platform2.position = Vector2(1200, 400)
	platform2.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(150, 0),
		Vector2(150, 100),
		Vector2(0, 100)
	])
	platform2.color = Color(0.8, 0.8, 0, 0.2)  # Yellow
	platform2.add_to_group("walkable_area")
	add_child(platform2)
	add_area_label(platform2, "Platform 2")
	
	# Platform 3
	var platform3 = Polygon2D.new()
	platform3.name = "Platform3"
	platform3.position = Vector2(1200, 600)
	platform3.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(150, 0),
		Vector2(150, 100),
		Vector2(0, 100)
	])
	platform3.color = Color(0.8, 0.8, 0, 0.2)  # Yellow
	platform3.add_to_group("walkable_area")
	add_child(platform3)
	add_area_label(platform3, "Platform 3")

func create_bridge_walkable_area() -> Polygon2D:
	var area = Polygon2D.new()
	area.name = "BridgeArea"
	area.position = Vector2(350, 250)  # Position to connect island to central
	
	# Create bridge that actually connects the island (ends at ~400,350) to central (starts at 600,300)
	area.polygon = PoolVector2Array([
		Vector2(0, 50),      # Start near island
		Vector2(50, 50),     # Widen slightly
		Vector2(250, 50),    # Continue to central
		Vector2(250, 100),   # Bottom edge
		Vector2(0, 100)      # Back to start
	])
	
	area.color = Color(0.8, 0.4, 0.8, 0.2)  # Purple
	area.add_to_group("walkable_area")
	
	# Add label
	add_area_label(area, "Bridge\n(Island to Central)")
	
	return area

func create_platform_bridges():
	# Bridge from central to platform 1
	var bridge1 = Polygon2D.new()
	bridge1.name = "PlatformBridge1"
	bridge1.position = Vector2(1000, 225)
	bridge1.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(200, 0),
		Vector2(200, 50),
		Vector2(0, 50)
	])
	bridge1.color = Color(0.6, 0.8, 0.6, 0.2)  # Light green
	bridge1.add_to_group("walkable_area")
	add_child(bridge1)
	
	# Bridge from central to platform 2
	var bridge2 = Polygon2D.new()
	bridge2.name = "PlatformBridge2"
	bridge2.position = Vector2(1000, 425)
	bridge2.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(200, 0),
		Vector2(200, 50),
		Vector2(0, 50)
	])
	bridge2.color = Color(0.6, 0.8, 0.6, 0.2)  # Light green
	bridge2.add_to_group("walkable_area")
	add_child(bridge2)
	
	# Bridge from central to platform 3
	var bridge3 = Polygon2D.new()
	bridge3.name = "PlatformBridge3"
	bridge3.position = Vector2(1000, 625)
	bridge3.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(200, 0),
		Vector2(200, 50),
		Vector2(0, 50)
	])
	bridge3.color = Color(0.6, 0.8, 0.6, 0.2)  # Light green
	bridge3.add_to_group("walkable_area")
	add_child(bridge3)

func create_designer_priority_area() -> Polygon2D:
	var area = Polygon2D.new()
	area.name = "DesignerPriorityArea"
	area.position = Vector2(700, 400)
	
	# Overlaps with central area
	area.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(200, 0),
		Vector2(200, 200),
		Vector2(0, 200)
	])
	
	area.color = Color(1, 0.6, 0, 0.3)  # Orange
	# Don't add designer tag during initial creation - we'll test priority later
	area.add_to_group("walkable_area")
	
	# Add label
	add_area_label(area, "Designer\nPriority Area\n(Overlapping)")
	
	return area

func add_area_label(area: Polygon2D, text: String):
	var label = Label.new()
	label.text = text
	label.modulate = Color(1, 1, 1, 0.8)
	
	# Calculate center of polygon
	var center = Vector2.ZERO
	for point in area.polygon:
		center += point
	center /= area.polygon.size()
	
	label.rect_position = center - Vector2(50, 20)
	area.add_child(label)

func create_grid_overlay():
	if not show_grid:
		return
		
	var grid_overlay = Node2D.new()
	grid_overlay.name = "GridOverlay"
	grid_overlay.z_index = 1
	add_child(grid_overlay)
	
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

func create_visual_feedback_nodes():
	# Click marker
	click_marker = ColorRect.new()
	click_marker.rect_size = Vector2(10, 10)
	click_marker.rect_position = Vector2(-5, -5)
	click_marker.color = Color(1, 0, 0)
	click_marker.visible = false
	add_child(click_marker)
	
	# Closest point line
	closest_point_line = Line2D.new()
	closest_point_line.width = 2
	closest_point_line.default_color = Color(1, 1, 0, 0.8)
	closest_point_line.add_point(Vector2.ZERO)
	closest_point_line.add_point(Vector2.ZERO)
	closest_point_line.visible = false
	add_child(closest_point_line)
	
	# Path validation line
	path_validation_line = Line2D.new()
	path_validation_line.width = 3
	path_validation_line.default_color = Color(0, 1, 0, 0.6)
	path_validation_line.z_index = 5
	add_child(path_validation_line)

func create_test_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UI"
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	# Main info panel
	var panel = Panel.new()
	panel.rect_position = Vector2(10, 10)
	panel.rect_size = Vector2(350, 200)
	canvas_layer.add_child(panel)
	
	# Info label
	info_label = RichTextLabel.new()
	info_label.rect_position = Vector2(10, 10)
	info_label.rect_size = Vector2(330, 80)
	info_label.bbcode_enabled = true
	info_label.bbcode_text = "[color=yellow]Walkable Area Enhancement Test[/color]\n" + \
		"Click anywhere to test movement\n" + \
		"Multiple areas, path validation, closest point"
	panel.add_child(info_label)
	
	# Status label
	status_label = Label.new()
	status_label.rect_position = Vector2(10, 100)
	status_label.rect_size = Vector2(330, 90)
	status_label.text = "Ready to test..."
	panel.add_child(status_label)
	
	# Test results panel
	var results_panel = Panel.new()
	results_panel.rect_position = Vector2(10, 220)
	results_panel.rect_size = Vector2(350, 300)
	canvas_layer.add_child(results_panel)
	
	# Test results label
	test_results_label = RichTextLabel.new()
	test_results_label.rect_position = Vector2(10, 10)
	test_results_label.rect_size = Vector2(330, 280)
	test_results_label.bbcode_enabled = true
	test_results_label.bbcode_text = "[color=white]Acceptance Criteria Results:[/color]\n"
	results_panel.add_child(test_results_label)
	
	# Coordinate label
	coordinate_label = Label.new()
	coordinate_label.rect_position = Vector2(10, 530)
	coordinate_label.modulate = Color(1, 1, 0)
	canvas_layer.add_child(coordinate_label)

func setup_navigation():
	# Create Navigation2D for path validation testing
	var navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	add_child(navigation)
	
	# Add navigation polygons for each walkable area
	for area in get_children():
		if area.is_in_group("walkable_area") and area is Polygon2D:
			var nav_instance = NavigationPolygonInstance.new()
			var nav_poly = NavigationPolygon.new()
			
			# Transform polygon to global coordinates
			var global_points = PoolVector2Array()
			for point in area.polygon:
				global_points.append(area.to_global(point))
			
			nav_poly.add_outline(global_points)
			nav_poly.make_polygons_from_outlines()
			nav_instance.navpoly = nav_poly
			navigation.add_child(nav_instance)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.scancode == KEY_R:
			run_acceptance_tests()
		elif event.scancode == KEY_G:
			show_grid = !show_grid
			get_node("GridOverlay").visible = show_grid
	
	# Handle mouse clicks for testing
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		handle_test_click(event.position)
	
	# Update coordinate display
	if event is InputEventMouseMotion:
		update_coordinate_display(event.position)

func handle_test_click(screen_pos: Vector2):
	# Convert to world position
	var world_pos = camera.screen_to_world(screen_pos) if camera else screen_pos
	last_click_world = world_pos
	
	# Test if position is walkable
	last_click_walkable = is_position_walkable(world_pos)
	
	# Get closest walkable point
	last_closest_point = get_closest_walkable_point(world_pos)
	
	# Update visual feedback
	update_click_feedback()
	
	# Update status
	update_status_display()
	
	# If player exists, test path validation
	var player = get_node_or_null("Player")
	if player and player.navigation_node:
		test_path_validation(player.global_position, world_pos)

func update_click_feedback():
	if not show_click_feedback:
		return
	
	# Show click marker
	click_marker.rect_position = last_click_world - Vector2(5, 5)
	click_marker.color = Color(0, 1, 0) if last_click_walkable else Color(1, 0, 0)
	click_marker.visible = true
	
	# Show closest point line if clicking outside
	if not last_click_walkable and last_closest_point != last_click_world:
		closest_point_line.set_point_position(0, last_click_world)
		closest_point_line.set_point_position(1, last_closest_point)
		closest_point_line.visible = true
	else:
		closest_point_line.visible = false

func update_status_display():
	if not status_label:
		return
	
	var status_text = "Last Click: (%.0f, %.0f)\n" % [last_click_world.x, last_click_world.y]
	status_text += "Is Walkable: %s\n" % ("YES" if last_click_walkable else "NO")
	
	if not last_click_walkable:
		var distance = last_click_world.distance_to(last_closest_point)
		status_text += "Closest Point: (%.0f, %.0f)\n" % [last_closest_point.x, last_closest_point.y]
		status_text += "Distance: %.1f pixels" % distance
	else:
		status_text += "Click is in walkable area"
	
	status_label.text = status_text

func update_coordinate_display(screen_pos: Vector2):
	if not coordinate_label:
		return
	
	var world_pos = camera.screen_to_world(screen_pos) if camera else screen_pos
	coordinate_label.text = "World: (%.0f, %.0f)" % [world_pos.x, world_pos.y]
	coordinate_label.rect_position = screen_pos + Vector2(20, -30)

func test_path_validation(from: Vector2, to: Vector2):
	if not show_path_validation:
		return
	
	# Generate a simple path for testing
	var test_path = [from, to]
	
	# Check if path is valid
	var path_valid = is_path_valid(test_path)
	
	# Visualize path
	path_validation_line.clear_points()
	for point in test_path:
		path_validation_line.add_point(point)
	
	# Color based on validity
	path_validation_line.default_color = Color(0, 1, 0, 0.6) if path_valid else Color(1, 0, 0, 0.6)

func run_acceptance_tests():
	current_test_results.clear()
	
	# Test 1: Multiple walkable areas defined with priority/layering
	test_multiple_areas()
	
	# Test 2: Point-in-polygon checks for complex shapes
	test_complex_polygon_checks()
	
	# Test 3: Navigation paths validated against boundaries
	test_path_validation_feature()
	
	# Test 4: Closest valid point when clicking outside
	test_closest_point_finding()
	
	# Update results display
	update_test_results_display()

func test_multiple_areas():
	var test_name = "Multiple Walkable Areas"
	var passed = true
	var details = ""
	
	# Count walkable areas
	var area_count = 0
	var designer_count = 0
	for child in get_children():
		if child.is_in_group("walkable_area"):
			area_count += 1
			if child.is_in_group("designer_walkable_area"):
				designer_count += 1
	
	if area_count < 4:
		passed = false
		details = "Expected at least 4 areas, found %d" % area_count
	else:
		details = "Found %d walkable areas, %d designer priority" % [area_count, designer_count]
	
	current_test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_complex_polygon_checks():
	var test_name = "Complex Polygon Checks"
	var passed = true
	var details = ""
	
	# Test points in island area (complex shape)
	var test_points = [
		{"pos": Vector2(250, 300), "expected": true, "desc": "Island center"},
		{"pos": Vector2(100, 200), "expected": false, "desc": "Island edge"},
		{"pos": Vector2(800, 500), "expected": true, "desc": "Central area"},
		{"pos": Vector2(1275, 250), "expected": true, "desc": "Platform 1"},
		{"pos": Vector2(1275, 350), "expected": false, "desc": "Between platforms"}
	]
	
	var failures = 0
	for test in test_points:
		var result = is_position_walkable(test.pos)
		if result != test.expected:
			failures += 1
			details += "%s failed, " % test.desc
	
	if failures > 0:
		passed = false
		details = "Failed %d/%d checks: %s" % [failures, test_points.size(), details]
	else:
		details = "All %d polygon checks passed" % test_points.size()
	
	current_test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_path_validation_feature():
	var test_name = "Path Validation"
	var passed = true
	var details = ""
	
	# Test various paths
	var test_paths = [
		{
			"path": [Vector2(250, 300), Vector2(500, 200)],
			"expected": false,
			"desc": "Island to gap (no direct path)"
		},
		{
			"path": [Vector2(400, 300), Vector2(600, 350)],
			"expected": true,
			"desc": "Along bridge from island to central"
		},
		{
			"path": [Vector2(800, 500), Vector2(900, 600)],
			"expected": true,
			"desc": "Within central area"
		},
		{
			"path": [Vector2(1100, 450), Vector2(1275, 450)],
			"expected": true,
			"desc": "Central to Platform 2 via bridge"
		}
	]
	
	var failures = 0
	for test in test_paths:
		var result = is_path_valid(test.path)
		if result != test.expected:
			failures += 1
			details += "%s failed, " % test.desc
	
	if failures > 0:
		passed = false
		details = "Failed %d/%d path validations" % [failures, test_paths.size()]
	else:
		details = "All %d path validations passed" % test_paths.size()
	
	current_test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func test_closest_point_finding():
	var test_name = "Closest Point Finding"
	var passed = true
	var details = ""
	
	# Test points outside walkable areas
	var test_cases = [
		{"pos": Vector2(50, 50), "desc": "Top left corner"},
		{"pos": Vector2(500, 300), "desc": "Gap between areas"},
		{"pos": Vector2(1400, 400), "desc": "Right of platforms"}
	]
	
	var failures = 0
	for test in test_cases:
		var closest = get_closest_walkable_point(test.pos)
		
		# Verify closest point is actually walkable
		if not is_position_walkable(closest):
			failures += 1
			details += "%s returned non-walkable point, " % test.desc
		
		# Verify it's different from input (since input is outside)
		if is_position_walkable(test.pos):
			failures += 1
			details += "%s test point was already walkable, " % test.desc
	
	if failures > 0:
		passed = false
		details = "Failed %d/%d closest point tests" % [failures, test_cases.size()]
	else:
		details = "All %d closest point tests passed" % test_cases.size()
	
	current_test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details
	})

func update_test_results_display():
	if not test_results_label:
		return
	
	var results_text = "[color=yellow]Acceptance Criteria Results:[/color]\n\n"
	
	for result in current_test_results:
		var color = "green" if result.passed else "red"
		var status = "PASS" if result.passed else "FAIL"
		results_text += "[color=%s]%s: %s[/color]\n" % [color, status, result.name]
		results_text += "  %s\n\n" % result.details
	
	# Summary
	var passed_count = 0
	for result in current_test_results:
		if result.passed:
			passed_count += 1
	
	var summary_color = "green" if passed_count == current_test_results.size() else "yellow"
	results_text += "\n[color=%s]Summary: %d/%d tests passed[/color]" % [
		summary_color, passed_count, current_test_results.size()
	]
	
	test_results_label.bbcode_text = results_text

func _process(_delta):
	# Update player navigation path visualization
	var player = get_node_or_null("Player")
	if player and player.has_method("get_navigation_path") and show_path_validation:
		var path = player.get_navigation_path()
		if path and path.size() > 1:
			path_validation_line.clear_points()
			for point in path:
				path_validation_line.add_point(point)
			
			# Validate the path
			var path_array = []
			for point in path:
				path_array.append(point)
			var valid = is_path_valid(path_array)
			path_validation_line.default_color = Color(0, 1, 0, 0.6) if valid else Color(1, 0, 0, 0.6)