extends Node2D

# Coordinate Picker - Debug Tool
# Shows exact coordinates when clicking on the screen and tracks click history
# Modified to use Godot UI controls rather than direct font rendering

# Add signal for integration with debug manager
signal coordinate_selected(position)

# Display settings
export var max_history = 10
export var show_grid = false
export var grid_size = 100

# Internal variables
var coordinate_history = []
var mouse_position = Vector2()
var copying = false
var coord_labels = []
var current_label

func _ready():
	# Set up UI for coordinate display
	setup_ui()
	
	# Ensure this node processes input
	set_process_input(true)
	set_process(true)
	
	print("Coordinate Picker Debug Tool Activated")
	print("Click to capture coordinates. Press C to copy last coordinates.")
	
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
			coord_labels[i].text = "(%d, %d) - %s" % [pos.x, pos.y, item.time]
			coord_labels[i].visible = true
	
	# Hide unused labels
	for i in range(coordinate_history.size(), coord_labels.size()):
		coord_labels[i].visible = false
	
	# Show/hide copied notification
	var copied_label = get_node_or_null("CoordinateLabels/CopiedNotification")
	if copied_label:
		copied_label.visible = copying
	
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
			# Use the camera's screen_to_world method if available (new helper method)
			if camera.has_method("screen_to_world"):
				world_pos = camera.screen_to_world(click_pos)
				print("Using camera's screen_to_world method for precise coordinate conversion")
			else:
				# Fallback to standard formula if our helper isn't available
				world_pos = camera.get_global_position() + ((click_pos - get_viewport_rect().size/2) * camera.zoom)
				print("Using standard coordinate conversion formula")
			
			# Get information about current camera status
			var is_showing_full_view = false
			var parent_scene = get_tree().get_current_scene()
			
			# Check if we're in the camera test scene with full view mode
			if parent_scene.has_method("_process") and "show_full_view" in parent_scene:
				is_showing_full_view = parent_scene.show_full_view
				print("Camera test scene detected, full view mode: " + str(is_showing_full_view))
				
				if is_showing_full_view:
					push_error("WARNING: Capturing coordinates in full view mode!")
					push_error("These coordinates may not work correctly in normal zoom")
			
			# Debug output to verify conversion
			print("Click position (screen): " + str(click_pos))
			print("Camera position: " + str(camera.get_global_position()))
			print("Camera zoom: " + str(camera.zoom))
			print("Viewport size: " + str(get_viewport_rect().size))
			print("Converted world position: " + str(world_pos))
		
		# Add to history with timestamp
		var timestamp = OS.get_time()
		var time_text = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
		coordinate_history.push_front({"position": world_pos, "time": time_text})
		
		# Emit signal for debug manager integration
		emit_signal("coordinate_selected", world_pos)
		
		# Limit history size
		if coordinate_history.size() > max_history:
			coordinate_history.pop_back()
		
		# CRITICAL: Create a very visible message that's more likely to show in console
		var separator = "##################################################################"
		var coord_message = "COORDINATE: Vector2(%d, %d)" % [world_pos.x, world_pos.y]
		
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
		
		# Add the coordinate entry with timestamp
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
		style.border_color = Color(1, 0.5, 0, 1)
		panel.add_stylebox_override("panel", style)
		
		# Create label with larger text
		var notification = Label.new()
		notification.text = "COORDINATE CAPTURED:\n" + coord_message
		notification.add_color_override("font_color", Color(1, 1, 0, 1))
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
			var text = "Vector2(%d, %d)," % [coordinate_history[0].position.x, coordinate_history[0].position.y]
			OS.set_clipboard(text)
			copying = true
			
			# Use the same high-visibility logging methods as click handling
			var separator = "##################################################################"
			print("\n" + separator + "\n")
			print("COPIED TO CLIPBOARD: " + text)
			print(separator + "\n")
			
			# Use print instead of push_error
			print("IMPORTANT: COPIED: " + text)
			
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
		var alpha = 1.0 - (i / float(max_history))
		
		# Draw much more visible crosshair
		var size = 10 - i  # Size decreases with age of point
		var circle_size = 8 - i
		
		# Thicker lines for better visibility
		draw_line(Vector2(pos.x - size, pos.y), Vector2(pos.x + size, pos.y), Color(1, 0, 0, alpha), 2)
		draw_line(Vector2(pos.x, pos.y - size), Vector2(pos.x, pos.y + size), Color(1, 0, 0, alpha), 2)
		
		# Add a circle to make it even more visible
		draw_circle(pos, circle_size, Color(1, 1, 0, alpha * 0.5))
	
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