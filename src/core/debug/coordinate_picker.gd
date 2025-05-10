extends Node2D

# Coordinate Picker - Debug Tool
# Shows exact coordinates when clicking on the screen and tracks click history

# Display settings
export var font_size = 14
export var max_history = 10
export var show_grid = false
export var grid_size = 100

# Internal variables
var coordinate_history = []
var font
var mouse_position = Vector2()
var copying = false

func _ready():
	# Create dynamic font for coordinate display
	font = DynamicFont.new()
	font.font_data = load("res://default_font.tres")
	font.size = font_size
	
	# Ensure this node processes input
	set_process_input(true)
	set_process(true)
	
	print("Coordinate Picker Debug Tool Activated")
	print("Click to capture coordinates. Press C to copy last coordinates.")

func _process(_delta):
	# Track mouse position
	mouse_position = get_viewport().get_mouse_position()
	
	# Force redraw to update coordinate display
	update()

func _input(event):
	# Handle mouse clicks to capture coordinates
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var click_pos = get_viewport().get_mouse_position()
		
		# Add to history with timestamp
		var timestamp = OS.get_time()
		var time_text = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
		coordinate_history.push_front({"position": click_pos, "time": time_text})
		
		# Limit history size
		if coordinate_history.size() > max_history:
			coordinate_history.pop_back()
		
		# Log the coordinates for easy copy/paste
		print("Coordinates captured: Vector2(%d, %d)" % [click_pos.x, click_pos.y])
		
	# Copy last coordinates to clipboard with C key
	if event is InputEventKey and event.pressed and event.scancode == KEY_C:
		if coordinate_history.size() > 0:
			var text = "Vector2(%d, %d)" % [coordinate_history[0].position.x, coordinate_history[0].position.y]
			OS.set_clipboard(text)
			copying = true
			print("Copied to clipboard: " + text)
			yield(get_tree().create_timer(0.5), "timeout")
			copying = false

func _draw():
	# Draw current mouse coordinates
	var coord_text = "(%d, %d)" % [mouse_position.x, mouse_position.y]
	draw_string(font, mouse_position + Vector2(10, -10), coord_text, Color(1, 1, 0))
	
	# Draw coordinate history
	for i in range(coordinate_history.size()):
		var item = coordinate_history[i]
		var pos = item.position
		var alpha = 1.0 - (i / float(max_history))
		
		# Draw crosshair
		draw_line(Vector2(pos.x - 5, pos.y), Vector2(pos.x + 5, pos.y), Color(1, 0, 0, alpha), 1)
		draw_line(Vector2(pos.x, pos.y - 5), Vector2(pos.x, pos.y + 5), Color(1, 0, 0, alpha), 1)
		
		# Draw text
		var text = "(%d, %d) - %s" % [pos.x, pos.y, item.time]
		draw_string(font, pos + Vector2(10, 10), text, Color(1, 1, 0, alpha))
	
	# Draw helper text if copying
	if copying:
		draw_string(font, Vector2(10, 30), "Coordinates copied to clipboard!", Color(0, 1, 0))
	
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