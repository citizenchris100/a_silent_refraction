extends Node
# Mock InputManager for unit testing click detection

var block_clicks_until = 0

# Validate if a click position is within valid screen bounds
func validate_click_position(position: Vector2) -> bool:
	# Handle edge cases first
	if is_inf(position.x) or is_inf(position.y):
		return false
	if is_nan(position.x) or is_nan(position.y):
		return false
	
	# Get viewport size
	var viewport_size = OS.get_window_size()
	
	# Check bounds
	if position.x < 0 or position.y < 0:
		return false
	if position.x > viewport_size.x or position.y > viewport_size.y:
		return false
	
	return true

# Check if a click position hits any UI element
func is_click_on_ui(position: Vector2, ui_layer: CanvasLayer) -> bool:
	if not ui_layer:
		return false
	
	# Check all controls in the UI layer
	for control in _get_all_controls(ui_layer):
		if _is_point_in_control(control, position):
			return true
	
	return false

# Get all Control nodes in a parent
func _get_all_controls(parent):
	var controls = []
	for child in parent.get_children():
		if child is Control:
			controls.append(child)
		
		# Also include all nested controls
		if child.get_child_count() > 0:
			controls += _get_all_controls(child)
	
	return controls

# Check if a point is within a Control node
func _is_point_in_control(control: Control, point: Vector2) -> bool:
	# Skip invisible controls
	if not control.visible:
		return false
	
	# Get the global rect of the control
	var global_rect = control.get_global_rect()
	
	# Check if point is inside control's rect
	return global_rect.has_point(point)

# Check if clicks should be blocked due to dialog
func should_block_click_for_dialog(dialog_manager) -> bool:
	if not dialog_manager:
		return false
	
	if not dialog_manager.has_node("dialog_panel"):
		return false
	
	var panel = dialog_manager.get_node("dialog_panel")
	return panel.visible

# Block clicks for a specified duration in milliseconds
func block_clicks(duration_ms: int):
	block_clicks_until = OS.get_ticks_msec() + duration_ms

# Check if clicks are currently blocked
func is_click_blocked() -> bool:
	if block_clicks_until == 0:
		return false
	
	return OS.get_ticks_msec() < block_clicks_until