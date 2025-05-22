class_name BoundsCalculator
extends Reference

# BoundsCalculator: A service for calculating camera bounds from walkable areas
# This class decouples the camera system from direct walkable area manipulation
# By creating a buffer layer between these systems, we reduce coupling and improve maintainability

# Helper method to safely get polygon data from a walkable area
# This uses the interface-based approach to reduce coupling
static func get_polygon_from_area(area) -> PoolVector2Array:
	var polygon = null
	
	# First try to use the interface method if available
	if area.has_method("get_polygon"):
		polygon = area.get_polygon()
		print("Using get_polygon() interface method")
	# Fall back to direct property access for backward compatibility
	elif "polygon" in area:
		polygon = area.polygon
		print("Using direct polygon property (legacy mode)")
	else:
		print("ERROR: Walkable area doesn't implement get_polygon() method or have polygon property")
		return PoolVector2Array() # Return empty array to handle gracefully
		
	return polygon

# Calculate camera bounds from walkable areas
static func calculate_bounds_from_walkable_areas(walkable_areas: Array) -> Rect2:
	var result_bounds = Rect2(0, 0, 0, 0)
	var first_point = true
	var all_points = []  # Store all points for verification
	
	print("\n========== BOUNDS CALCULATION STARTED ==========")
	print("Number of walkable areas: " + str(walkable_areas.size()))
	
	# Go through all walkable areas
	for area in walkable_areas:
		var polygon = get_polygon_from_area(area)
		
		if polygon.size() == 0:
			print("WARNING: Empty polygon in walkable area")
			continue
			
		print("Processing walkable area: " + area.name + " with " + str(polygon.size()) + " points")
		print("Area transform: " + str(area.transform))
		
		# Process each point in the polygon
		for i in range(polygon.size()):
			var point = polygon[i]
			# Store local point for reference
			all_points.append({"local": point, "index": i})
			
			# Convert to global coordinates
			var global_point = area.to_global(point)
			all_points[all_points.size()-1]["global"] = global_point
			
			# Debug output for coordinate conversion
			print("Point " + str(i) + " - Local: " + str(point) + ", Global: " + str(global_point))
			
			if first_point:
				# Initialize bounds with first point
				result_bounds = Rect2(global_point, Vector2.ZERO)
				first_point = false
			else:
				# Expand bounds to include this point
				# Test if expand is working properly
				var prev_bounds = result_bounds
				result_bounds = result_bounds.expand(global_point)
				
				# Verify expand actually worked
				if prev_bounds == result_bounds:
					# This is actually normal for rectangular polygons where the first point already defined the min/max
					print("Note: Rect2.expand() did not change bounds for point " + str(global_point) + 
						  " - this is normal for some polygon arrangements")
					# Manually expand bounds if needed
					result_bounds = Rect2(
						min(result_bounds.position.x, global_point.x),
						min(result_bounds.position.y, global_point.y),
						max(result_bounds.end.x, global_point.x) - min(result_bounds.position.x, global_point.x),
						max(result_bounds.end.y, global_point.y) - min(result_bounds.position.y, global_point.y)
					)
	
	# If no walkable areas were found or bounds calculation failed, use a default area
	if first_point:
		print("WARNING: No valid walkable areas found, using default bounds")
		result_bounds = Rect2(0, 0, 800, 600)  # Default to a reasonable size
	
	print("Raw calculated bounds: " + str(result_bounds))
	
	# Add a small margin to ensure edge points are properly contained
	# This is necessary because Rect2.has_point() excludes right and bottom edges
	var margin = 1.0  # 1 pixel margin
	result_bounds = result_bounds.grow(margin)
	print("Bounds after margin adjustment: " + str(result_bounds))
	
	# Apply safety checks and corrections
	result_bounds = apply_safety_corrections(result_bounds, null, Vector2.ZERO)
	
	print("Final corrected bounds: " + str(result_bounds))
	print("========== BOUNDS CALCULATION COMPLETED ==========\n")
	
	return result_bounds

# Apply safety checks and corrections to the calculated bounds
static func apply_safety_corrections(bounds: Rect2, district = null, viewport_size = Vector2.ZERO) -> Rect2:
	var corrected_bounds = bounds
	
	# SAFETY CHECKS AND CORRECTIONS
	
	# Check 1: Very small height (normal for floor walkable areas)
	var needs_height_expansion = false
	var target_height = 200  # Default minimum height
	var use_viewport_aware_expansion = false
	
	# If viewport size is provided, calculate viewport-aware target height
	if viewport_size != Vector2.ZERO:
		var viewport_based_minimum = viewport_size.y * 0.3  # At least 30% of viewport height
		target_height = max(target_height, viewport_based_minimum)
		use_viewport_aware_expansion = true
		print("Viewport-aware height calculation: " + str(viewport_size.y) + " * 0.3 = " + str(viewport_based_minimum))
	
	# Apply different expansion logic based on whether we have viewport context
	var should_expand = false
	if use_viewport_aware_expansion:
		# With viewport context, expand more aggressively for better visual results
		should_expand = corrected_bounds.size.y < target_height
	else:
		# Without viewport context, only expand very small heights (original logic)
		should_expand = corrected_bounds.size.y < 100
		target_height = 200  # Use original conservative target
	
	if should_expand:
		needs_height_expansion = true
		# Log the info message - small heights are expected for floor walkable areas
		print("INFO: Walkable area height is " + str(corrected_bounds.size.y) + " pixels")
		print("This is normal for floor-based walkable areas")
		
		# Expand the height for better camera behavior
		# Add space above and below the walkable area for better visibility
		var center_y = corrected_bounds.position.y + corrected_bounds.size.y / 2
		var expanded_height = target_height
		corrected_bounds.position.y = center_y - expanded_height / 2
		corrected_bounds.size.y = expanded_height
		print("Adjusting camera height bounds to " + str(expanded_height) + " pixels for better visibility")
		if viewport_size != Vector2.ZERO:
			var ratio = expanded_height / viewport_size.y
			print("Height-to-viewport ratio: " + str(ratio) + " (" + str(ratio * 100) + "%)")
		print("This preserves the exact floor walkable area while improving camera view")
	
	# Check 2: Very small width (indicates possible calculation error)
	if corrected_bounds.size.x < 100:
		push_error("WARNING: Suspicious bounds width detected: " + str(corrected_bounds.size.x))
		
		# Similar correction as for height
		var center_x = corrected_bounds.position.x + corrected_bounds.size.x / 2
		corrected_bounds.position.x = center_x - 100
		corrected_bounds.size.x = 200
		print("Enforced minimum bounds width")
	
	# Check 3: Consider background size but don't automatically expand
	if district != null and "background_size" in district and district.background_size != Vector2.ZERO:
		var bg_size = district.background_size
		
		# If walkable area is significantly smaller than background, log a warning
		# but respect the custom walkable area coordinates
		if corrected_bounds.size.x < bg_size.x * 0.5 or corrected_bounds.size.y < bg_size.y * 0.5:
			print("NOTE: Walkable area is much smaller than background.")
			print("This is often intentional for floor-based walkable areas.")
			print("Using the exact walkable area as specified in the coordinates.")
			
	return corrected_bounds

# Create a visualization of the calculated bounds for debugging
static func create_bounds_visualization(bounds: Rect2, parent_node):
	if not OS.is_debug_build():
		return null
	
	# Clean up any existing bounds visualizations to prevent memory leaks
	# Use a more thorough approach that handles nodes scheduled for deletion
	var children_to_remove = []
	for child in parent_node.get_children():
		if child.name == "BoundsVisualization":
			children_to_remove.append(child)
	
	# Remove all existing visualizations immediately
	for child in children_to_remove:
		parent_node.remove_child(child)
		child.queue_free()  # Still queue_free for proper cleanup, but remove from tree immediately
		
	var visualization = Node2D.new()
	visualization.name = "BoundsVisualization"
	parent_node.add_child(visualization)
	
	# Create a polygon that represents the bounds
	var rect = Polygon2D.new()
	rect.name = "BoundsRect"
	rect.color = Color(1, 0, 0, 0.2)  # Semi-transparent red
	rect.polygon = PoolVector2Array([
		Vector2(bounds.position.x, bounds.position.y),
		Vector2(bounds.position.x + bounds.size.x, bounds.position.y),
		Vector2(bounds.position.x + bounds.size.x, bounds.position.y + bounds.size.y),
		Vector2(bounds.position.x, bounds.position.y + bounds.size.y)
	])
	visualization.add_child(rect)
	
	# Create a label with bounds info
	var label = Label.new()
	label.name = "BoundsInfo"
	label.text = "Bounds: " + str(bounds)
	label.rect_position = Vector2(bounds.position.x, bounds.position.y - 30)
	label.add_color_override("font_color", Color(1, 0, 0))
	visualization.add_child(label)
	
	print("Created bounds visualization")
	return visualization