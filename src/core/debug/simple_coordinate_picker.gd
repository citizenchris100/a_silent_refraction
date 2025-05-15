extends Node2D

# Simple Coordinate Picker - For capturing coordinates without UI clutter
# Focused on capturing walkable area coordinates

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
var show_full_view = false
var original_camera_zoom = Vector2(1, 1)
var original_camera_position = Vector2.ZERO

func _ready():
	# Set up UI for coordinate display
	setup_ui()
	
	# Ensure this node processes input
	set_process_input(true)
	set_process(true)
	
	print("Simple Coordinate Picker Activated")
	print("Click to capture coordinates. Press C to copy last coordinates.")
	print("Press V to toggle full background view")

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
	
	# Add a help text label
	var help_label = Label.new()
	help_label.name = "HelpLabel"
	help_label.rect_position = Vector2(10, 70)
	help_label.text = "Controls:\nV - Toggle full background view\nC - Copy last coordinates\nClick - Capture coordinates"
	help_label.add_color_override("font_color", Color(1, 1, 1))
	
	# Create a background for better visibility
	var bg = ColorRect.new()
	bg.name = "HelpBackground"
	bg.color = Color(0, 0, 0, 0.5)
	bg.rect_position = Vector2(5, 65)
	bg.rect_size = Vector2(300, 100)
	
	control.add_child(bg)
	control.add_child(help_label)

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
			coord_labels[i].text = "(%d, %d)" % [pos.x, pos.y]
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
	# Handle V key for toggling full view mode
	if event is InputEventKey and event.pressed and event.scancode == KEY_V:
		toggle_full_view()
	
	# Handle mouse clicks to capture coordinates
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var click_pos = get_viewport().get_mouse_position()
		
		# Get camera to convert to world coordinates if we have a zoomed camera
		var camera = get_viewport().get_camera()
		var world_pos = click_pos
		
		if camera:
			# Use the camera's screen_to_world method if available
			if camera.has_method("screen_to_world"):
				world_pos = camera.screen_to_world(click_pos)
			else:
				# Fallback to standard formula
				world_pos = camera.get_global_position() + ((click_pos - get_viewport_rect().size/2) * camera.zoom)
		
		# Add to history with timestamp
		var timestamp = OS.get_time()
		var time_text = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
		coordinate_history.push_front({"position": world_pos, "time": time_text})
		
		# Limit history size
		if coordinate_history.size() > max_history:
			coordinate_history.pop_back()
		
		# Output coordinates to console
		print("\n################################################################")
		print("COORDINATE: Vector2(%d, %d)" % [world_pos.x, world_pos.y])
		print("MODE: %s view" % ("FULL BACKGROUND" if show_full_view else "NORMAL"))
		print("################################################################\n")
		
		# Log coordinates to file
		var dir = Directory.new()
		if !dir.dir_exists("user://logs"):
			dir.make_dir("user://logs")
			
		var file = File.new()
		var log_path = "user://logs/coordinates.log"
		
		if file.file_exists(log_path):
			file.open(log_path, File.READ_WRITE)
			file.seek_end()
		else:
			file.open(log_path, File.WRITE)
		
		file.store_line(time_text + ": COORDINATE: Vector2(%d, %d) - %s VIEW" % [world_pos.x, world_pos.y, "FULL" if show_full_view else "NORMAL"])
		file.close()
		
		# Show a notification on screen
		var notification = Label.new()
		notification.text = "Vector2(%d, %d)" % [world_pos.x, world_pos.y]
		notification.add_color_override("font_color", Color(1, 0.5, 0, 1))
		notification.rect_position = click_pos + Vector2(30, -30)
		get_tree().get_root().add_child(notification)
		
		# Remove notification after 5 seconds
		yield(get_tree().create_timer(5.0), "timeout")
		if is_instance_valid(notification):
			notification.queue_free()
	
	# Copy last coordinates to clipboard with C key
	if event is InputEventKey and event.pressed and event.scancode == KEY_C:
		if coordinate_history.size() > 0:
			var text = "Vector2(%d, %d)," % [coordinate_history[0].position.x, coordinate_history[0].position.y]
			OS.set_clipboard(text)
			copying = true
			
			print("\nCOPIED TO CLIPBOARD: " + text)
			
			var notification = Label.new()
			notification.text = "COPIED: " + text
			notification.add_color_override("font_color", Color(0, 1, 0, 1))
			notification.rect_position = Vector2(get_viewport_rect().size.x/2 - 150, 100)
			get_tree().get_root().add_child(notification)
			
			yield(get_tree().create_timer(1.0), "timeout")
			copying = false
			
			yield(get_tree().create_timer(4.0), "timeout")
			if is_instance_valid(notification):
				notification.queue_free()

func toggle_full_view():
	show_full_view = !show_full_view
	var camera = get_viewport().get_camera()
	
	if !camera:
		print("No camera found to toggle view!")
		return
		
	if show_full_view:
		# Save original camera state
		original_camera_zoom = camera.zoom
		original_camera_position = camera.global_position
		
		print("Switching to FULL BACKGROUND VIEW")
		print("Original zoom: " + str(original_camera_zoom))
		print("Original position: " + str(original_camera_position))
		
		# Calculate zoom to fit entire background
		var background_size = Vector2(3000, 1500)  # Default size
		
		# Try to find the actual background size from the parent
		var parent = get_parent()
		while parent and !("background_size" in parent):
			parent = parent.get_parent()
		
		if parent and "background_size" in parent:
			background_size = parent.background_size
			print("Using background size from parent: " + str(background_size))
		
		var viewport_size = get_viewport_rect().size
		var zoom_x = background_size.x / viewport_size.x
		var zoom_y = background_size.y / viewport_size.y
		
		# Use the larger value to ensure the entire background fits
		var zoom_value = max(zoom_x, zoom_y) * 1.1  # 110% to add a small margin
		
		# Ensure zoom isn't too extreme
		zoom_value = clamp(zoom_value, 1.0, 5.0)  # Higher values = more zoomed out
		
		print("Setting camera zoom to: " + str(zoom_value))
		
		# Set camera properties for full view
		camera.zoom = Vector2(zoom_value, zoom_value)
		
		# Center camera on background
		camera.global_position = Vector2(
			background_size.x / 2,
			background_size.y / 2
		)
		
		# Disable any bounds checking temporarily
		if "bounds_enabled" in camera:
			camera.bounds_enabled = false
			
		if "smoothing_enabled" in camera:
			camera.smoothing_enabled = false
		
		print("Camera positioned at: " + str(camera.global_position) + " with zoom: " + str(camera.zoom))
		print("Now showing FULL BACKGROUND view")
	else:
		# Restore original camera state
		print("Restoring normal view")
		print("Restoring zoom: " + str(original_camera_zoom))
		print("Restoring position: " + str(original_camera_position))
		
		camera.zoom = original_camera_zoom
		camera.global_position = original_camera_position
		
		# Re-enable bounds and smoothing
		if "bounds_enabled" in camera:
			camera.bounds_enabled = true
			
		if "smoothing_enabled" in camera:
			camera.smoothing_enabled = true
			
		# Force update camera's position calculation method
		if "update_bounds" in camera:
			camera.update_bounds()
			
		if "_set_initial_camera_position" in camera:
			camera._set_initial_camera_position()
			
		print("Camera restored to: " + str(camera.global_position) + " with zoom: " + str(camera.zoom))
		print("Returned to NORMAL view")
	
	# Update UI to show current mode
	var help_label = get_node_or_null("CoordinateLabels/HelpLabel")
	if help_label:
		help_label.text = "Controls:\nV - Toggle full background view (%s)\nC - Copy last coordinates\nClick - Capture coordinates" % ("ON" if show_full_view else "OFF")

func _draw():
	# Draw coordinate history crosshairs
	for i in range(coordinate_history.size()):
		var item = coordinate_history[i]
		var pos = item.position
		var alpha = 1.0 - (i / float(max_history))
		
		# Draw crosshair
		draw_line(Vector2(pos.x - 10, pos.y), Vector2(pos.x + 10, pos.y), Color(1, 0, 0, alpha), 2)
		draw_line(Vector2(pos.x, pos.y - 10), Vector2(pos.x, pos.y + 10), Color(1, 0, 0, alpha), 2)
		
		# Draw circle
		draw_circle(pos, 5, Color(1, 0, 0, alpha))
	
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