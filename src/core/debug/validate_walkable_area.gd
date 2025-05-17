extends Node2D

# ValidateWalkableArea: A debug tool for validating walkable area coordinates
# This tool provides visualization and verification of walkable areas to ensure proper setup

var district = null  # Reference to the district containing walkable areas
var result_label = null  # UI label for displaying results
var points_to_validate = []  # Points to validate
var visualization = null  # Node for visualization elements

# Signals
signal validation_completed(result)

func _ready():
	# Find the district
	find_district()
	
	# Set up UI
	setup_ui()
	
	print("Walkable Area Validator initialized")
	print("Ready to validate coordinates against walkable areas")

# Find the district containing walkable areas
func find_district():
	# Try to find a BaseDistrict in the scene hierarchy
	var parent = get_parent()
	while parent:
		if parent is BaseDistrict:
			district = parent
			print("Found district: " + district.district_name)
			
			# Update the CoordinateManager with the current district
			CoordinateManager.set_current_district(district)
			return
		parent = parent.get_parent()
	
	# If not found as a parent, try to find in the current scene
	var current_scene = get_tree().get_current_scene()
	if current_scene is BaseDistrict:
		district = current_scene
		print("Found district as current scene: " + district.district_name)
		
		# Update the CoordinateManager with the current district
		CoordinateManager.set_current_district(district)
	else:
		print("ERROR: No district found, validation cannot be performed")

# Set up UI elements
func setup_ui():
	# Create a canvas layer for UI
	var canvas = CanvasLayer.new()
	canvas.name = "ValidatorUI"
	canvas.layer = 100  # On top of other elements
	add_child(canvas)
	
	# Create panel for results
	var panel = Panel.new()
	panel.name = "ResultsPanel"
	panel.rect_position = Vector2(10, 10)
	panel.rect_size = Vector2(400, 100)
	canvas.add_child(panel)
	
	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.border_width_all = 2
	style.border_color = Color(0.7, 0.7, 0, 1)
	panel.add_stylebox_override("panel", style)
	
	# Create label for results
	result_label = Label.new()
	result_label.name = "ResultLabel"
	result_label.rect_position = Vector2(10, 10)
	result_label.rect_size = Vector2(380, 80)
	result_label.text = "Ready to validate coordinates.\nClick to add points or use validate() method."
	result_label.autowrap = true
	panel.add_child(result_label)
	
	# Create visualization node
	visualization = Node2D.new()
	visualization.name = "Visualization"
	add_child(visualization)

# Clear all visualization elements
func clear_visualization():
	for child in visualization.get_children():
		child.queue_free()

# Display walkable areas for reference
func display_walkable_areas():
	if !district:
		print("ERROR: Cannot display walkable areas - no district found")
		return
	
	if district.walkable_areas.size() == 0:
		print("WARNING: District has no walkable areas defined")
		return
	
	# Clear previous visualization
	clear_visualization()
	
	# Display each walkable area
	for i in range(district.walkable_areas.size()):
		var area = district.walkable_areas[i]
		if area.polygon.size() == 0:
			continue
		
		# Create polygon visualization
		var poly = Polygon2D.new()
		poly.name = "WalkableArea" + str(i)
		poly.polygon = area.polygon
		poly.color = Color(0, 1, 0, 0.2)  # Transparent green
		poly.global_transform = area.global_transform
		visualization.add_child(poly)
		
		# Add outline
		var outline = Line2D.new()
		outline.name = "Outline" + str(i)
		outline.points = area.polygon
		outline.add_point(area.polygon[0])  # Close the loop
		outline.width = 2.0
		outline.default_color = Color(0, 1, 0, 0.7)
		poly.add_child(outline)
		
		# Add labels for vertices
		for j in range(area.polygon.size()):
			var label = Label.new()
			label.name = "VertexLabel" + str(j)
			label.text = str(j) + ": " + str(area.polygon[j])
			label.rect_position = area.polygon[j] - Vector2(50, 15)
			label.rect_size = Vector2(100, 30)
			label.add_color_override("font_color", Color(1, 1, 0))
			poly.add_child(label)
	
	print("Displayed " + str(district.walkable_areas.size()) + " walkable areas")

# Validate a list of coordinates against walkable areas
func validate(coordinates):
	if !district:
		update_result("ERROR: Cannot validate - no district found", false)
		return false
	
	if district.walkable_areas.size() == 0:
		update_result("WARNING: District has no walkable areas defined", false)
		return false
	
	# Store the coordinates to validate
	points_to_validate = coordinates
	
	# Transform coordinates based on current view mode
	var view_mode = CoordinateManager.get_view_mode()
	var transformed_coords = []
	
	for point in points_to_validate:
		var transformed_point = point
		
		# If we're in world view, convert to game view for validation
		if view_mode == CoordinateManager.ViewMode.WORLD_VIEW:
			transformed_point = CoordinateManager.transform_view_mode_coordinates(
				point, 
				CoordinateManager.ViewMode.WORLD_VIEW, 
				CoordinateManager.ViewMode.GAME_VIEW
			)
		
		transformed_coords.append(transformed_point)
	
	# Track validation results
	var valid_points = []
	var invalid_points = []
	
	# Check each point against walkable areas
	for i in range(transformed_coords.size()):
		var point = transformed_coords[i]
		var original_point = points_to_validate[i]
		var is_valid = is_point_in_any_walkable_area(point)
		
		if is_valid:
			valid_points.append({"index": i, "original": original_point, "transformed": point})
		else:
			invalid_points.append({"index": i, "original": original_point, "transformed": point})
	
	# Display validation results
	visualize_validation_results(valid_points, invalid_points)
	
	# Update result label
	var result_text = "Validation Results:\n"
	result_text += str(valid_points.size()) + " points inside walkable areas\n"
	result_text += str(invalid_points.size()) + " points outside walkable areas"
	
	# If in world view, add note about coordinate transformation
	if view_mode == CoordinateManager.ViewMode.WORLD_VIEW:
		result_text += "\nNote: Coordinates were transformed from World View to Game View for validation"
	
	update_result(result_text, valid_points.size() == points_to_validate.size())
	
	# Emit validation completed signal
	emit_signal("validation_completed", {
		"valid_points": valid_points,
		"invalid_points": invalid_points,
		"all_valid": valid_points.size() == points_to_validate.size()
	})
	
	return valid_points.size() == points_to_validate.size()

# Check if a point is in any walkable area
func is_point_in_any_walkable_area(point):
	for area in district.walkable_areas:
		if area.polygon.size() == 0:
			continue
		
		# Convert point to local coordinates
		var local_point = area.to_local(point)
		
		# Check if the point is in the polygon
		if Geometry.is_point_in_polygon(local_point, area.polygon):
			return true
	
	return false

# Visualize validation results with color-coded points
func visualize_validation_results(valid_points, invalid_points):
	# Clear previous visualization
	clear_visualization()
	
	# Show walkable areas as reference
	display_walkable_areas()
	
	# Draw valid points (green)
	for point_data in valid_points:
		var point = point_data.transformed
		
		# Draw a green circle for valid points
		var circle = ColorRect.new()
		circle.name = "ValidPoint" + str(point_data.index)
		circle.rect_size = Vector2(10, 10)
		circle.rect_position = point - Vector2(5, 5)
		circle.color = Color(0, 1, 0, 0.7)
		visualization.add_child(circle)
		
		# Add label with original coordinates
		var label = Label.new()
		label.name = "ValidLabel" + str(point_data.index)
		label.text = "Point " + str(point_data.index) + "\n" + str(point_data.original)
		label.rect_position = point + Vector2(10, -15)
		label.add_color_override("font_color", Color(0, 1, 0))
		visualization.add_child(label)
	
	# Draw invalid points (red)
	for point_data in invalid_points:
		var point = point_data.transformed
		
		# Draw a red circle for invalid points
		var circle = ColorRect.new()
		circle.name = "InvalidPoint" + str(point_data.index)
		circle.rect_size = Vector2(10, 10)
		circle.rect_position = point - Vector2(5, 5)
		circle.color = Color(1, 0, 0, 0.7)
		visualization.add_child(circle)
		
		# Add label with original coordinates
		var label = Label.new()
		label.name = "InvalidLabel" + str(point_data.index)
		label.text = "Point " + str(point_data.index) + " (INVALID)\n" + str(point_data.original)
		label.rect_position = point + Vector2(10, -15)
		label.add_color_override("font_color", Color(1, 0, 0))
		visualization.add_child(label)
		
		# Draw connecting line to closest walkable area
		draw_line_to_closest_walkable_area(point, point_data.index)

# Draw a line from an invalid point to the closest walkable area edge
func draw_line_to_closest_walkable_area(point, index):
	var closest_dist = INF
	var closest_point = null
	var closest_area = null
	
	# Find the closest point on any walkable area
	for area in district.walkable_areas:
		if area.polygon.size() < 3:
			continue
		
		var local_point = area.to_local(point)
		
		# Check each edge of the polygon
		for i in range(area.polygon.size()):
			var p1 = area.polygon[i]
			var p2 = area.polygon[(i + 1) % area.polygon.size()]
			
			# Find closest point on line segment
			var closest = get_closest_point_on_line_segment(local_point, p1, p2)
			var dist = local_point.distance_to(closest)
			
			if dist < closest_dist:
				closest_dist = dist
				closest_point = closest
				closest_area = area
	
	if closest_point and closest_area:
		# Convert the closest point to global coordinates
		var global_closest = closest_area.to_global(closest_point)
		
		# Draw a line from the invalid point to the closest point
		var line = Line2D.new()
		line.name = "ClosestLine" + str(index)
		line.points = [point, global_closest]
		line.width = 2.0
		line.default_color = Color(1, 0.5, 0, 0.7)
		visualization.add_child(line)
		
		# Add a label showing the distance
		var label = Label.new()
		label.name = "DistanceLabel" + str(index)
		label.text = "Distance: " + str(int(point.distance_to(global_closest))) + " px"
		label.rect_position = (point + global_closest) / 2 + Vector2(5, -15)
		label.add_color_override("font_color", Color(1, 0.5, 0))
		visualization.add_child(label)

# Get the closest point on a line segment to a target point
func get_closest_point_on_line_segment(p, v, w):
	var l2 = v.distance_squared_to(w)
	if l2 == 0:
		return v
	
	var t = max(0, min(1, (p - v).dot(w - v) / l2))
	var projection = v + t * (w - v)
	return projection

# Update the result label with the validation result
func update_result(text, success):
	if result_label:
		result_label.text = text
		result_label.add_color_override("font_color", Color(0, 1, 0) if success else Color(1, 0.5, 0))