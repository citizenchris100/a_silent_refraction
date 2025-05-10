extends Node2D

# Polygon Visualizer - Debug Tool
# Visualizes polygon vertices and allows easier editing of walkable areas

# Display settings
export var vertex_size = 6
export var label_font_size = 12
export var line_width = 2
export var vertex_color = Color(0, 1, 0.5, 0.8)
export var line_color = Color(0, 0.8, 0.3, 0.5)
export var target_group = "walkable_area"

# Editing modes
enum EditMode {VIEW, MOVE, ADD, DELETE, DRAG_ALL}
var current_mode = EditMode.VIEW

# Internal variables
var polygons = []
var selected_polygon = null
var selected_point_index = -1
var font
var dragging = false
var drag_offset = Vector2()
var new_point_position = Vector2()
var showing_mode_help = false
var undo_stack = []
var redo_stack = []

func _ready():
	# Create dynamic font for labels
	font = DynamicFont.new()
	font.font_data = load("res://default_font.tres")
	font.size = label_font_size

	# Find all polygon nodes in the target group
	find_polygons()

	# Setup processing
	set_process_input(true)
	set_process(true)

	print("Polygon Visualizer Debug Tool Activated")
	print("- Mode 1 (Default): View/Select - Click vertices to select")
	print("- Mode 2: Move - Click and drag vertices to move them")
	print("- Mode 3: Add - Click to add new vertices between existing ones")
	print("- Mode 4: Delete - Click vertices to delete them")
	print("- Mode 5: Drag All - Click and drag to move entire polygon")
	print("- Press 1-5 to switch modes")
	print("- Press H to toggle help")
	print("- Press P to print/copy current polygon coordinates")
	print("- Press Z to undo, Y to redo")
	print("- Press S to save changes to scene file (not implemented yet)")

func find_polygons():
	polygons = []
	# Find all nodes in the target group
	var nodes = get_tree().get_nodes_in_group(target_group)

	for node in nodes:
		if node is Polygon2D and node.has_method("get_polygon"):
			polygons.append(node)
			print("Found polygon: " + node.name)

func _process(_delta):
	# Update new point position in ADD mode
	if current_mode == EditMode.ADD and selected_polygon != null:
		var mouse_pos = get_viewport().get_mouse_position()
		new_point_position = selected_polygon.get_global_transform().affine_inverse().xform(mouse_pos)

	# Force redraw to update visuals
	update()

func _draw():
	# Draw all polygons
	for poly in polygons:
		var points = poly.polygon
		var global_transform = poly.global_transform

		# Draw outline connections
		for i in range(points.size()):
			var start = global_transform.xform(points[i])
			var end = global_transform.xform(points[(i + 1) % points.size()])
			draw_line(start, end, line_color, line_width)

		# Draw vertices
		for i in range(points.size()):
			var pos = global_transform.xform(points[i])

			# Highlight selected point
			var color = vertex_color
			if poly == selected_polygon and i == selected_point_index:
				color = Color(1, 0, 0, 1)

			# Draw vertex
			draw_circle(pos, vertex_size, color)

			# Draw index label
			var label = str(i) + ": (" + str(int(points[i].x)) + "," + str(int(points[i].y)) + ")"
			draw_string(font, pos + Vector2(vertex_size + 2, 0), label, Color(1, 1, 0))

		# Draw new point in ADD mode
		if current_mode == EditMode.ADD and poly == selected_polygon and selected_point_index != -1:
			var next_idx = (selected_point_index + 1) % points.size()
			var p1 = global_transform.xform(points[selected_point_index])
			var p2 = global_transform.xform(points[next_idx])
			var new_pos = global_transform.xform(new_point_position)

			# Draw insert position
			draw_circle(new_pos, vertex_size, Color(1, 0.5, 0, 0.8))
			draw_line(p1, new_pos, Color(1, 0.5, 0, 0.5), line_width)
			draw_line(new_pos, p2, Color(1, 0.5, 0, 0.5), line_width)

			# Draw label
			var label = "New: (" + str(int(new_point_position.x)) + "," + str(int(new_point_position.y)) + ")"
			draw_string(font, new_pos + Vector2(vertex_size + 2, 0), label, Color(1, 0.5, 0))

	# Draw current mode text
	var mode_text = "Current Mode: "
	match current_mode:
		EditMode.VIEW: mode_text += "View/Select (1)"
		EditMode.MOVE: mode_text += "Move Vertex (2)"
		EditMode.ADD: mode_text += "Add Vertex (3)"
		EditMode.DELETE: mode_text += "Delete Vertex (4)"
		EditMode.DRAG_ALL: mode_text += "Drag All (5)"

	draw_string(font, Vector2(20, 20), mode_text, Color(1, 1, 1))

	# Draw shortcut help when requested
	if showing_mode_help:
		var help_text = [
			"Polygon Editor Controls:",
			"1: View/Select Mode - Click vertices to select",
			"2: Move Mode - Click and drag vertices",
			"3: Add Mode - Add vertices between points",
			"4: Delete Mode - Delete selected vertices",
			"5: Drag All Mode - Move entire polygon",
			"P: Print/copy polygon data",
			"Z: Undo, Y: Redo",
			"H: Toggle this help"
		]

		# Draw background
		var y_pos = 50
		var height = help_text.size() * 20 + 10
		draw_rect(Rect2(10, y_pos - 5, 350, height), Color(0, 0, 0, 0.7))

		# Draw help text
		for i in range(help_text.size()):
			draw_string(font, Vector2(20, y_pos + i * 20), help_text[i], Color(1, 0.8, 0.2))

func save_state():
	if selected_polygon != null:
		var state = {"polygon": selected_polygon, "points": selected_polygon.polygon.duplicate()}
		undo_stack.push_back(state)
		redo_stack.clear()

func undo():
	if undo_stack.size() > 0:
		var state = undo_stack.pop_back()
		var current_state = {"polygon": state.polygon, "points": state.polygon.polygon.duplicate()}
		redo_stack.push_back(current_state)
		state.polygon.polygon = state.points
		print("Undo performed")

func redo():
	if redo_stack.size() > 0:
		var state = redo_stack.pop_back()
		var current_state = {"polygon": state.polygon, "points": state.polygon.polygon.duplicate()}
		undo_stack.push_back(current_state)
		state.polygon.polygon = state.points
		print("Redo performed")

func _input(event):
	# Change modes with number keys
	if event is InputEventKey and event.pressed:
		if event.scancode >= KEY_1 and event.scancode <= KEY_5:
			current_mode = event.scancode - KEY_1
			print("Switched to mode: " + str(current_mode))
			return

		# Toggle help with H
		if event.scancode == KEY_H:
			showing_mode_help = !showing_mode_help
			return

		# Undo with Z
		if event.scancode == KEY_Z:
			undo()
			return

		# Redo with Y
		if event.scancode == KEY_Y:
			redo()
			return

	# Handle mouse clicks and drags based on current mode
	if event is InputEventMouseButton:
		var click_pos = get_viewport().get_mouse_position()

		# Left mouse button press
		if event.button_index == BUTTON_LEFT and event.pressed:
			# Find closest vertex in all modes
			var min_dist = 20.0  # Max selection distance for vertex
			var old_selected_polygon = selected_polygon
			var old_selected_point = selected_point_index
			selected_polygon = null
			selected_point_index = -1

			for poly in polygons:
				var points = poly.polygon
				var global_transform = poly.global_transform

				for i in range(points.size()):
					var pos = global_transform.xform(points[i])
					var dist = click_pos.distance_to(pos)

					if dist < min_dist:
						min_dist = dist
						selected_polygon = poly
						selected_point_index = i

			# Mode-specific actions
			match current_mode:
				EditMode.VIEW:
					# Just select, no action needed
					pass

				EditMode.MOVE:
					if selected_polygon != null and selected_point_index != -1:
						save_state()
						dragging = true
						var global_point = selected_polygon.get_global_transform().xform(
							selected_polygon.polygon[selected_point_index]
						)
						drag_offset = global_point - click_pos

				EditMode.ADD:
					if selected_polygon != null and selected_point_index != -1:
						# New vertex will be added after selection on mouse release
						# Just select for now
						pass

				EditMode.DELETE:
					if selected_polygon != null and selected_point_index != -1:
						# Make sure we have at least 4 points (minimum for a valid polygon)
						if selected_polygon.polygon.size() > 3:
							save_state()
							var points = selected_polygon.polygon
							points.remove(selected_point_index)
							selected_polygon.polygon = points
							print("Deleted vertex at index " + str(selected_point_index))
							selected_point_index = -1
						else:
							print("Cannot delete vertex: minimum of 3 vertices required")

				EditMode.DRAG_ALL:
					if selected_polygon != null:
						save_state()
						dragging = true
						# We don't need a specific vertex, just drag the whole polygon
						drag_offset = Vector2()

		# Left mouse button release
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			# Handle mode-specific releases
			if current_mode == EditMode.ADD and selected_polygon != null and selected_point_index != -1:
				save_state()
				var points = selected_polygon.polygon
				var new_index = (selected_point_index + 1) % points.size()
				points.insert(new_index, new_point_position)
				selected_polygon.polygon = points
				selected_point_index = new_index
				print("Added new vertex at index " + str(new_index))

			# End dragging
			dragging = false

	# Handle mouse motion for dragging
	if event is InputEventMouseMotion and dragging:
		var mouse_pos = get_viewport().get_mouse_position()

		match current_mode:
			EditMode.MOVE:
				if selected_polygon != null and selected_point_index != -1:
					var points = selected_polygon.polygon
					var global_pos = mouse_pos + drag_offset
					var local_pos = selected_polygon.get_global_transform().affine_inverse().xform(global_pos)
					points[selected_point_index] = local_pos
					selected_polygon.polygon = points

			EditMode.DRAG_ALL:
				if selected_polygon != null:
					var delta = event.relative
					var points = selected_polygon.polygon
					for i in range(points.size()):
						points[i] += selected_polygon.get_global_transform().affine_inverse().basis_xform(delta)
					selected_polygon.polygon = points

	# Print polygon coordinates when pressing P
	if event is InputEventKey and event.pressed and event.scancode == KEY_P:
		if selected_polygon != null:
			var points = selected_polygon.polygon
			print("\nCurrent polygon points for " + selected_polygon.name + ":")
			print("polygon = PoolVector2Array(")

			for i in range(points.size()):
				var point = points[i]
				if i < points.size() - 1:
					print("\t" + str(int(point.x)) + ", " + str(int(point.y)) + ",")
				else:
					print("\t" + str(int(point.x)) + ", " + str(int(point.y)))

			print(")")

			# Copy to clipboard
			var text = "polygon = PoolVector2Array(\n"
			for i in range(points.size()):
				var point = points[i]
				if i < points.size() - 1:
					text += "\t" + str(int(point.x)) + ", " + str(int(point.y)) + ",\n"
				else:
					text += "\t" + str(int(point.x)) + ", " + str(int(point.y)) + "\n"
			text += ")"

			OS.set_clipboard(text)
			print("Polygon data copied to clipboard")