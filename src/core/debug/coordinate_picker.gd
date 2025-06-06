extends Node2D

# Coordinate Picker - Debug Tool
# Shows exact coordinates when clicking on the screen and tracks click history
# Modified to use Godot UI controls rather than direct font rendering
# Enhanced to handle district coordinate transformations

# Preload the CoordinateSystem class
var CoordinateSystem = preload("res://src/core/coordinate_system.gd")

# Add signal for integration with debug manager
signal coordinate_selected(position)

# Display settings
export var max_history = 10
export var show_grid = false
export var grid_size = 100

# Color coding for different view modes
const GAME_VIEW_COLOR = Color(0, 0.8, 0, 0.8)  # Green for game view
const WORLD_VIEW_COLOR = Color(1, 0.5, 0, 0.8)  # Orange for world view

# Internal variables
var coordinate_history = []
var mouse_position = Vector2()
var copying = false
var coord_labels = []
var current_label
var district = null  # Reference to the district we're in (if any)
var cached_debug_manager = null  # Cached reference to debug manager

func _ready():
	# Set up UI for coordinate display
	setup_ui()
	
	# Ensure this node processes input
	set_process_input(true)
	set_process(true)
	
	# Try to find the parent district
	_find_district()
	
	# Update the CoordinateManager with the current district
	if district:
		CoordinateManager.set_current_district(district)
	
	print("Coordinate Picker Debug Tool Activated")
	print("Click to capture coordinates. Press C to copy last coordinates.")
	if district:
		print("District-aware mode active: Using " + district.district_name)
		print("Background scale factor: " + str(district.background_scale_factor))
	
func _find_district():
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
		print("No district found, coordinate transformations will not be applied")
	
# Check if a position is inside a walkable area
func is_inside_walkable_area(position: Vector2) -> bool:
	if district == null:
		print("WARNING: Cannot check walkable area - no district found")
		return false
		
	# Check if the district has walkable areas defined
	if not district.has("walkable_areas") or district.walkable_areas.size() == 0:
		print("WARNING: District has no walkable areas defined")
		return false
		
	# Check each walkable area to see if the point is inside
	for area in district.walkable_areas:
		if area.polygon.size() == 0:
			continue
			
		# Convert position to local coordinates for the walkable area
		var local_pos = area.to_local(position)
		
		# Check if the point is inside the polygon
		if Geometry.is_point_in_polygon(local_pos, area.polygon):
			print("Coordinate is inside walkable area: " + area.name)
			return true
			
	# Not inside any walkable area
	print("WARNING: Coordinate is outside all walkable areas")
	return false
func setup_ui():
	# Create control node to hold all labels
	var control = Control.new()
	control.name = "CoordinateLabels"
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(control)
	
	# Create label for current mouse position
	current_label = Label.new()
	current_label.name = "CurrentPosition"
	current_label.add_color_override("font_color", Color(1, 1, 0))
	control.add_child(current_label)
	
	# Create "copied" notification label
	var copied_label = Label.new()
	copied_label.name = "CopiedNotification"
	copied_label.text = "Coordinates copied to clipboard!"
	copied_label.add_color_override("font_color", Color(0, 1, 0))
	copied_label.rect_position = Vector2(10, 40)
	copied_label.visible = false
	control.add_child(copied_label)
	
	# Create labels for history items
	for i in range(max_history):
		var label = Label.new()
		label.name = "History" + str(i)
		label.add_color_override("font_color", Color(1, 1, 0, 1.0 - (i / float(max_history))))
		label.visible = false
		control.add_child(label)
		coord_labels.append(label)

func _process(_delta):
	# Track mouse position
	mouse_position = get_viewport().get_mouse_position()
	
	# Update current position label
	if current_label:
		current_label.rect_position = mouse_position + Vector2(10, -15)
		current_label.text = "(%d, %d)" % [mouse_position.x, mouse_position.y]
	
	# Update history labels
	for i in range(coordinate_history.size()):
		if i < coord_labels.size():
			var item = coordinate_history[i]
			var pos = item.position
			
			coord_labels[i].rect_position = pos + Vector2(10, 10)
			
			# Add view mode indicator to the label text
			var view_mode_text = "Game View"
			var label_color = GAME_VIEW_COLOR
			
			if "view_mode" in item and item.view_mode == CoordinateSystem.ViewMode.WORLD_VIEW:
				view_mode_text = "World View"
				label_color = WORLD_VIEW_COLOR
				
			coord_labels[i].text = "(%d, %d) - %s [%s]" % [pos.x, pos.y, item.time, view_mode_text]
			coord_labels[i].add_color_override("font_color", label_color)
			coord_labels[i].visible = true
	
	# Hide unused labels
	for i in range(coordinate_history.size(), coord_labels.size()):
		coord_labels[i].visible = false
	
	# Show/hide copied notification
	var copied_label = get_node_or_null("CoordinateLabels/CopiedNotification")
	if copied_label:
		copied_label.visible = copying
	
	# Update persistent visual markers for each coordinate
	update_persistent_markers()
	
	# Force redraw for grid and crosshairs
	update()

func _input(event):
	# Handle mouse clicks to capture coordinates
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var click_pos = get_viewport().get_mouse_position()
		
		# Get camera to convert to world coordinates if we have a zoomed camera
		var camera = get_viewport().get_camera()
		var world_pos = click_pos
		
		if camera:
			# Check if we are in full view mode (often set by the debug manager)
			var is_in_full_view = false
			var debug_manager = null
			
			# Look for debug manager in the scene
			var parent = get_parent()
			while parent:
				if parent.get_name() == "DebugManager":
					debug_manager = parent
					break
				parent = parent.get_parent()
			
			# Check if we're in full view mode via debug manager
			if debug_manager:
				is_in_full_view = CoordinateSystem.get_current_view_mode(debug_manager) == CoordinateSystem.ViewMode.WORLD_VIEW
				print("Debug manager found, full view mode: " + str(is_in_full_view))
			
			# Use CoordinateSystem for coordinate transformation
			world_pos = CoordinateSystem.screen_to_world(click_pos, camera)
			print("Using CoordinateSystem.screen_to_world for coordinate conversion")
			
			# Get information about current camera status
			var parent_scene = get_tree().get_current_scene()
			
			# Check if we're in a scene with full view mode property
			if parent_scene.has_method("_process") and "show_full_view" in parent_scene:
				is_in_full_view = is_in_full_view || parent_scene.show_full_view
				print("Camera test scene detected, full view mode: " + str(is_in_full_view))
			
			# If we're in full view mode, provide better notifications
			if is_in_full_view:
				print("⚠️ IMPORTANT ⚠️ Capturing coordinates in full view mode!")
				print("⚠️ IMPORTANT ⚠️ These are raw world coordinates that should work in all view modes")
				
				# Create a more visible notification about full view mode
				var notification = Label.new()
				notification.name = "FullViewWarning"
				notification.text = "⚠️ Full View Mode Active ⚠️\nCapturing actual world coordinates"
				notification.add_color_override("font_color", Color(1, 0.7, 0))
				notification.add_color_override("font_color_shadow", Color(0, 0, 0))
				notification.add_constant_override("shadow_offset_x", 1)
				notification.add_constant_override("shadow_offset_y", 1)
				
				# Add a background for the notification
				var panel = Panel.new()
				panel.name = "WarningPanel"
				var style = StyleBoxFlat.new()
				style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
				style.set_border_width_all(2)
				style.border_color = Color(1, 0.7, 0)
				panel.add_stylebox_override("panel", style)
				
				# Add to scene
				var canvas_layer = CanvasLayer.new()
				canvas_layer.name = "WarningLayer"
				canvas_layer.layer = 100
				get_tree().get_root().add_child(canvas_layer)
				canvas_layer.add_child(panel)
				panel.add_child(notification)
				
				# Size and position
				notification.rect_size = Vector2(400, 60)
				panel.rect_position = Vector2(get_viewport_rect().size.x/2 - 200, 10)
				panel.rect_size = Vector2(400, 60)
				
				# Set up auto-removal
				var timer = Timer.new()
				timer.name = "RemovalTimer"
				timer.wait_time = 5.0
				timer.one_shot = true
				canvas_layer.add_child(timer)
				timer.connect("timeout", canvas_layer, "queue_free")
				timer.start()
			
			# Debug output to verify conversion
			print("Click position (screen): " + str(click_pos))
			print("Camera position: " + str(camera.get_global_position()))
			print("Camera zoom: " + str(camera.zoom))
			print("Viewport size: " + str(get_viewport_rect().size))
			print("Initial world position: " + str(world_pos))
		
		# Apply district coordinate transformation if we're in a district
		var screen_pos = world_pos
		var final_world_pos = world_pos
		if district:
			# Check the current view mode for proper transformation
			# First, try finding any active DebugManager in the scene
			var view_mode = CoordinateSystem.ViewMode.GAME_VIEW
			var found_debug_manager = null
			
			# Search for DebugManager at the root level (more reliable)
			var scene_root = get_tree().get_root()
			found_debug_manager = scene_root.get_node_or_null("DebugManager")
			
			# If not found at root, try searching up from our parent
			if found_debug_manager == null:
				var parent = get_parent()
				while parent != null:
					if parent.get_name() == "DebugManager":
						found_debug_manager = parent
						break
					parent = parent.get_parent()
			
			# Get view mode from debug manager if available
			if found_debug_manager != null:
				print("Found debug manager: " + found_debug_manager.get_name())
				view_mode = CoordinateSystem.get_current_view_mode(found_debug_manager)
			else:
				print("No debug manager found - defaulting to Game View mode")
				
				# Without a debug manager, try to detect full view mode by checking camera zoom
				if district.has_method("get_camera") and district.get_camera() != null:
					var district_camera = district.get_camera()
					if district_camera.zoom.x > 2.0:  # If zoomed out significantly, it's likely full view mode
						print("Detected World View via camera zoom level: " + str(district_camera.zoom))
						view_mode = CoordinateSystem.ViewMode.WORLD_VIEW
			
			print("Current view mode: " + ("WORLD_VIEW" if view_mode == CoordinateSystem.ViewMode.WORLD_VIEW else "GAME_VIEW"))
			
			# Convert from screen space to world space using appropriate transformation
			if view_mode == CoordinateSystem.ViewMode.WORLD_VIEW:
				# In World View mode, we need to convert the coordinates
				print("World View active - converting coordinates using CoordinateSystem")
				
				# First check if we can apply the transformation directly
				if district.has_method("screen_to_world_coords"):
					# Get the base screen_to_world transformation
					var base_world_pos = district.screen_to_world_coords(world_pos)
					print("Base transformation: " + str(world_pos) + " → " + str(base_world_pos))
					
					# Apply World View transformation
					final_world_pos = CoordinateSystem.world_view_to_game_view(base_world_pos, district)
					print("Final transformation: " + str(base_world_pos) + " → " + str(final_world_pos))
				else:
					# Direct transformation using CoordinateSystem
					final_world_pos = CoordinateSystem.world_view_to_game_view(world_pos, district)
					print("Direct transformation: " + str(world_pos) + " → " + str(final_world_pos))
			else:
				# In regular Game View mode, use the district's normal transformation
				print("Game View active - using regular coordinate transformation")
				if district.has_method("screen_to_world_coords"):
					final_world_pos = district.screen_to_world_coords(world_pos)
					print("Transformed via district: " + str(world_pos) + " → " + str(final_world_pos))
				else:
					final_world_pos = world_pos
					print("WARNING: District lacks screen_to_world_coords method, using untransformed coordinates")
			
			print("District found. Applying coordinate transformation:")
			print("Background scale factor: " + str(district.background_scale_factor))
			print("Original position: " + str(screen_pos))
			print("Transformed position: " + str(final_world_pos))
		
		# Add to history with timestamp
		var timestamp = OS.get_time()
		var time_text = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
		
		# Determine current view mode
		var current_view_mode = _get_current_view_mode()
		
		coordinate_history.push_front({
			"position": final_world_pos, 
			"time": time_text,
			"view_mode": current_view_mode
		})
		
		# Emit signal for debug manager integration
		emit_signal("coordinate_selected", final_world_pos)
		
		# Limit history size
		if coordinate_history.size() > max_history:
			coordinate_history.pop_back()
		
		# CRITICAL: Create a very visible message that's more likely to show in console
		var separator = "##################################################################"
		var coord_message = "COORDINATE: Vector2(%d, %d)" % [final_world_pos.x, final_world_pos.y]
		
		# If we applied district transformation, show both screen space and world space coordinates
		if district and district.background_scale_factor != 1.0:
			var screen_message = "SCREEN SPACE: Vector2(%d, %d)" % [screen_pos.x, screen_pos.y]
			var world_message = "WORLD SPACE: Vector2(%d, %d)" % [final_world_pos.x, final_world_pos.y]
			var scale_message = "SCALE FACTOR: " + str(district.background_scale_factor)
			
			print("\n" + separator + "\n")
			print("CLICKED AT TIME: " + time_text)
			print(screen_message + " ➡️ " + world_message)
			print(scale_message)
			print(separator + "\n")
			
			# Use print instead of push_error to avoid marking coordinates as errors
			print("IMPORTANT: " + separator)
			print("IMPORTANT: " + world_message)
			print("IMPORTANT: " + screen_message)
			print("IMPORTANT: " + scale_message)
			print("IMPORTANT: " + separator)
		else:
			# Create a visual log to the game output - this will be harder to miss
			print("\n" + separator + "\n")
			print("CLICKED AT TIME: " + time_text)
			print(coord_message)
			print(separator + "\n")
			
			# Use print instead of push_error to avoid marking coordinates as errors
			print("IMPORTANT: " + separator)
			print("IMPORTANT: " + coord_message)
			print("IMPORTANT: " + separator)
		
		# Create a log file for coordinates as a backup method
		var dir = Directory.new()
		if !dir.dir_exists("user://logs"):
			dir.make_dir("user://logs")
			
		# Fixed file handling to properly append to the log
		var file = File.new()
		var log_path = "user://logs/coordinates.log"
		
		# Check if file exists first
		if file.file_exists(log_path):
			# Open in append mode
			file.open(log_path, File.READ_WRITE)
			file.seek_end()
		else:
			# Create new file
			file.open(log_path, File.WRITE)
		
		# Add the coordinate entry with timestamp, including transformation info if available
		if district and district.background_scale_factor != 1.0:
			var screen_message = "SCREEN SPACE: Vector2(%d, %d)" % [screen_pos.x, screen_pos.y]
			var world_message = "WORLD SPACE: Vector2(%d, %d)" % [final_world_pos.x, final_world_pos.y]
			var scale_message = "SCALE FACTOR: " + str(district.background_scale_factor)
			file.store_line(time_text + ": " + screen_message + " ➡️ " + world_message + " (" + scale_message + ")")
		else:
			file.store_line(time_text + ": " + coord_message)
		file.close()
		
		# Print confirmation of logging
		print("Coordinate saved to log file: ~/.local/share/godot/app_userdata/A Silent Refraction/logs/coordinates.log")
		
		# Add a much more visible notification panel
		var panel = Panel.new()
		panel.name = "CoordinateNotification"
		
		# Style the panel to make it stand out
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0.8)
		style.set_border_width_all(3)
		
		# Use different border color based on view mode
		var current_mode = _get_current_view_mode()
		if current_mode == CoordinateSystem.ViewMode.WORLD_VIEW:
			style.border_color = WORLD_VIEW_COLOR  # Orange for world view
		else:
			style.border_color = GAME_VIEW_COLOR  # Green for game view
		panel.add_stylebox_override("panel", style)
		
		# Create label with larger text - show both coordinates if transformed
		var notification = Label.new()
		
		# Determine view mode for this capture
		var view_mode = _get_current_view_mode()
		var view_mode_text = "Game View"
		if view_mode == CoordinateSystem.ViewMode.WORLD_VIEW:
			view_mode_text = "World View"
		
		if district and district.background_scale_factor != 1.0:
			notification.text = "COORDINATE CAPTURED (%s):\n" % [view_mode_text] + \
				"WORLD: Vector2(%d, %d)\n" % [final_world_pos.x, final_world_pos.y] + \
				"SCREEN: Vector2(%d, %d)" % [screen_pos.x, screen_pos.y]
		else:
			notification.text = "COORDINATE CAPTURED (%s):\n" % [view_mode_text] + coord_message
		
		# Color code based on view mode
		var label_color = GAME_VIEW_COLOR if view_mode == CoordinateSystem.ViewMode.GAME_VIEW else WORLD_VIEW_COLOR
		notification.add_color_override("font_color", label_color)
		notification.align = Label.ALIGN_CENTER
		notification.valign = Label.VALIGN_CENTER
		notification.rect_min_size = Vector2(280, 60)
		
		# Add to scene hierarchy using CanvasLayer for guaranteed visibility
		var notification_layer = CanvasLayer.new()
		notification_layer.name = "CoordinateNotificationLayer"
		notification_layer.layer = 128  # Very high layer to ensure visibility
		get_tree().get_root().add_child(notification_layer)
		notification_layer.add_child(panel)
		panel.add_child(notification)
		
		# Position at the top center of the screen where it's easy to see
		panel.rect_position = Vector2(get_viewport_rect().size.x/2 - 150, 50)
		panel.rect_size = Vector2(300, 100)
		
		# Make it really visible with a growing/shrinking animation
		var tween = Tween.new()
		panel.add_child(tween)
		
		# Initial pulse to grab attention
		tween.interpolate_property(panel, "rect_scale", 
			Vector2(0.5, 0.5), Vector2(1.2, 1.2), 
			0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		tween.start()
		
		# After initial pulse, set to normal size
		yield(tween, "tween_completed")
		tween.interpolate_property(panel, "rect_scale", 
			Vector2(1.2, 1.2), Vector2(1, 1), 
			0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		
		# Remove notification after a few seconds
		yield(get_tree().create_timer(5.0), "timeout")
		if is_instance_valid(notification_layer):
			notification_layer.queue_free()
			
	# Copy last coordinates to clipboard with C key
	if event is InputEventKey and event.pressed and event.scancode == KEY_C:
		if coordinate_history.size() > 0:
			# Format for easy pasting into polygon definitions
			var coords = coordinate_history[0].position
			var text = "Vector2(%d, %d)," % [coords.x, coords.y]
			OS.set_clipboard(text)
			copying = true
			
			# Use the same high-visibility logging methods as click handling
			var separator = "##################################################################"
			print("\n" + separator + "\n")
			print("COPIED TO CLIPBOARD: " + text)
			print(separator + "\n")
			
			# Use print instead of push_error
			print("IMPORTANT: COPIED: " + text)
			
			# For district-aware mode, also show what these coordinates correspond to in screen space
			if district and district.background_scale_factor != 1.0:
				# Get the current view mode
				var view_mode = CoordinateSystem.ViewMode.GAME_VIEW
				
				# Try to find debug manager if it exists
				var parent = get_parent()
				var found_debug_manager = null
				while parent:
					if parent.get_name() == "DebugManager":
						found_debug_manager = parent
						break
					parent = parent.get_parent()
					
				# Get view mode from debug manager if available
				if found_debug_manager:
					view_mode = CoordinateSystem.get_current_view_mode(found_debug_manager)
				
				# Show appropriate conversion based on view mode
				if view_mode == CoordinateSystem.ViewMode.WORLD_VIEW:
					var game_view_coords = CoordinateSystem.world_view_to_game_view(coords, district)
					var game_text = "Vector2(%d, %d)," % [game_view_coords.x, game_view_coords.y]
					print("CORRESPONDS TO GAME VIEW: " + game_text)
				else:
					var screen_coords = district.world_to_screen_coords(coords)
					var screen_text = "Vector2(%d, %d)," % [screen_coords.x, screen_coords.y]
					print("CORRESPONDS TO SCREEN SPACE: " + screen_text)
					
				print("SCALE FACTOR: " + str(district.background_scale_factor))
			
			# Also append to the log file - properly handling append mode
			var file = File.new()
			var log_path = "user://logs/coordinates.log"
			
			# Check if file exists first
			if file.file_exists(log_path):
				# Open in append mode
				file.open(log_path, File.READ_WRITE)
				file.seek_end()
			else:
				# Create new file
				file.open(log_path, File.WRITE)
				
			# Add the copied entry
			file.store_line("COPIED: " + text)
			if district and district.background_scale_factor != 1.0:
				var screen_coords = district.world_to_screen_coords(coords)
				var screen_text = "Vector2(%d, %d)," % [screen_coords.x, screen_coords.y]
				file.store_line("SCREEN SPACE: " + screen_text)
			file.close()
			
			# Print confirmation
			print("Copied coordinate saved to log file")
			
			# Update the notification label
			var copied_label = get_node_or_null("CoordinateLabels/CopiedNotification")
			if copied_label:
				copied_label.text = "Copied: " + text
				copied_label.visible = true
				
			# Also create a more visible temporary notification
			var notification = Label.new()
			notification.text = "COPIED: " + text
			notification.add_color_override("font_color", Color(0, 1, 0, 1))
			notification.rect_position = Vector2(get_viewport_rect().size.x/2 - 150, 100)
			get_tree().get_root().add_child(notification)
			
			yield(get_tree().create_timer(1.0), "timeout")
			copying = false
			
			# Remove notification after a few seconds
			yield(get_tree().create_timer(4.0), "timeout")
			if is_instance_valid(notification):
				notification.queue_free()

func _draw():
	# Only draw the crosshairs and grid here - text is handled by Labels
	
	# Draw coordinate history crosshairs
	for i in range(coordinate_history.size()):
		var item = coordinate_history[i]
		var pos = item.position
		var alpha = 1.0 - (i / float(max_history) * 0.7)  # Keep minimum alpha higher
		
		# Enhance visibility with larger markers and brighter colors
		var size = 15 - i  # Size decreases with age of point but starts larger
		var circle_size = 12 - i  # Larger circles
		var outer_circle_size = 20 - i  # Add outer circle for better visibility
		
		# Draw outer glow first (in bright orange)
		draw_circle(pos, outer_circle_size, Color(1, 0.5, 0, alpha * 0.3))
		
		# Use a bright orange marker that's more visible in all scenes
		var marker_color = Color(1, 0.5, 0, alpha)
		
		# Thicker lines for better visibility
		draw_line(Vector2(pos.x - size, pos.y), Vector2(pos.x + size, pos.y), marker_color, 3)
		draw_line(Vector2(pos.x, pos.y - size), Vector2(pos.x, pos.y + size), marker_color, 3)
		
		# Add a solid circle with border for clarity
		draw_circle(pos, circle_size, Color(1, 0.8, 0, alpha * 0.7))  # Inner fill
		
		# Use draw_arc for border instead of draw_circle with too many parameters
		draw_arc(pos, circle_size, 0, TAU, 32, marker_color, 2)  # Border using arc
		
		# Draw connecting lines between points if we have more than one point
		if i < coordinate_history.size() - 1:
			var next_item = coordinate_history[i + 1]
			var next_pos = next_item.position
			draw_line(pos, next_pos, Color(1, 0.7, 0, alpha * 0.6), 1, true)  # Dashed line
	
	# Draw reference grid if enabled
	if show_grid:
		var viewport_size = get_viewport_rect().size
		var color = Color(0.2, 0.2, 0.2, 0.3)
		
		# Draw vertical lines
		for x in range(0, int(viewport_size.x), grid_size):
			draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), color, 1)
		
		# Draw horizontal lines
		for y in range(0, int(viewport_size.y), grid_size):
			draw_line(Vector2(0, y), Vector2(viewport_size.x, y), color, 1)
			
# Helper function to get the current view mode
func _get_current_view_mode():
	# Get debug manager
	var debug_manager = _find_debug_manager()
	if debug_manager:
		return CoordinateSystem.get_current_view_mode(debug_manager)
	else:
		return CoordinateSystem.ViewMode.GAME_VIEW  # Default to game view

# Helper function to find debug manager
func _find_debug_manager():
	# Use cached reference if available
	if cached_debug_manager != null:
		return cached_debug_manager
		
	# Try to find a DebugManager in the scene
	
	# First, search at the root level (most reliable)
	var scene_root = get_tree().get_root()
	var debug_manager = scene_root.get_node_or_null("DebugManager")
	if debug_manager:
		cached_debug_manager = debug_manager
		return debug_manager
		
	# Then, search through our parent hierarchy
	var parent = get_parent()
	while parent:
		if parent.name == "DebugManager":
			cached_debug_manager = parent
			return parent
		parent = parent.get_parent()
		
	# If not found, return null
	return null

# Function to update persistent visual markers for each coordinate point
func update_persistent_markers():
	# Make sure we have a parent node to work with
	var marker_parent = get_node_or_null("PersistentMarkers")
	if !marker_parent:
		marker_parent = Control.new()  # Changed to Control to hold UI elements
		marker_parent.name = "PersistentMarkers"
		marker_parent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(marker_parent)
	
	# Clear old markers
	for child in marker_parent.get_children():
		child.queue_free()
	
	# Create new markers for each coordinate
	for i in range(coordinate_history.size()):
		var item = coordinate_history[i]
		var pos = item.position
		
		# Create marker sprite - using a ColorRect since it's visible in all scenes
		var marker = ColorRect.new()
		marker.name = "Marker_" + str(i)
		marker.rect_size = Vector2(24, 24)  # Large enough to be easily visible
		marker.rect_position = pos - marker.rect_size / 2  # Center on the point
		
		# Color-code based on view mode
		var view_mode = CoordinateSystem.ViewMode.GAME_VIEW
		if "view_mode" in item:
			view_mode = item.view_mode
			
		# Set color based on view mode
		if view_mode == CoordinateSystem.ViewMode.WORLD_VIEW:
			marker.color = WORLD_VIEW_COLOR  # Orange for world view
		else:
			marker.color = GAME_VIEW_COLOR  # Green for game view
			
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker_parent.add_child(marker)
		
		# Add a border for better visibility
		var border = ColorRect.new()
		border.name = "Border"
		border.rect_size = Vector2(28, 28)
		border.rect_position = Vector2(-2, -2)  # Slightly larger than the marker
		border.color = Color(0, 0, 0, 0.5)  # Dark border
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.show_behind_parent = true
		marker.add_child(border)
		
		# Add number label
		var label = Label.new()
		label.name = "Number"
		label.text = str(i + 1)  # Display 1-indexed for user clarity
		label.rect_size = marker.rect_size
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.add_color_override("font_color", Color(0, 0, 0))  # Black text
		label.add_color_override("font_color_shadow", Color(1, 1, 1))  # White shadow
		label.add_constant_override("shadow_offset_x", 1)
		label.add_constant_override("shadow_offset_y", 1)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker.add_child(label)
		
		# Add some minimal animation to make it easier to spot
		var tween = Tween.new()
		tween.name = "Tween"
		marker.add_child(tween)
		
		# Pulse the marker slightly
		tween.interpolate_property(marker, "rect_scale", 
			Vector2(1, 1), Vector2(1.1, 1.1), 
			1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(marker, "rect_scale", 
			Vector2(1.1, 1.1), Vector2(1, 1), 
			1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.5)
		tween.start()
		
		# Simple animation loop
		tween.connect("tween_all_completed", tween, "start")