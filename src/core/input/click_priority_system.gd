extends Node
# Click Priority System - Manages click handling priority for overlapping interactive elements
# Ensures that interactive objects take precedence over movement commands

signal click_processed(click_data)
signal click_rejected(reason)

# Priority levels (higher number = higher priority)
enum Priority {
	MOVEMENT = 0,
	BACKGROUND_OBJECT = 10,
	INTERACTIVE_OBJECT = 20,
	UI_ELEMENT = 30,
	DIALOG = 40
}

# Click target types
enum TargetType {
	NONE,
	MOVEMENT,
	OBJECT,
	UI
}

var click_feedback_system = null

func _ready():
	# Find click feedback system if it exists
	yield(get_tree(), "idle_frame")
	var feedback_nodes = get_tree().get_nodes_in_group("click_feedback")
	if feedback_nodes.size() > 0:
		click_feedback_system = feedback_nodes[0]

func process_click(click_data: Dictionary):
	"""Main entry point for processing clicks with priority"""
	
	# Extract data
	var screen_position = click_data.get("screen_position", Vector2())
	var world_position = click_data.get("world_position", Vector2())
	var player = click_data.get("player", null)
	var district = click_data.get("district", null)
	
	# Find all potential click targets
	var targets = _find_click_targets(world_position, screen_position)
	
	# Sort targets by priority
	targets.sort_custom(self, "_sort_by_priority")
	
	# Process the highest priority target
	if targets.size() > 0:
		var target = targets[0]
		_process_target(target, click_data)
	else:
		# No targets found, treat as movement attempt
		_process_movement(world_position, player, district)

func _find_click_targets(world_position: Vector2, screen_position: Vector2) -> Array:
	"""Find all clickable targets at the given position"""
	var targets = []
	
	# Check UI elements first (highest priority)
	if _is_position_on_ui(screen_position):
		targets.append({
			"type": TargetType.UI,
			"priority": Priority.UI_ELEMENT,
			"position": screen_position
		})
		return targets  # UI blocks everything else
	
	# Check for dialog
	if _is_dialog_active():
		targets.append({
			"type": TargetType.UI,
			"priority": Priority.DIALOG,
			"position": screen_position
		})
		return targets  # Dialog blocks everything else
	
	# Check interactive objects
	var interactive_objects = get_tree().get_nodes_in_group("interactive_object")
	for obj in interactive_objects:
		if _is_position_on_object(world_position, obj):
			targets.append({
				"type": TargetType.OBJECT,
				"priority": Priority.INTERACTIVE_OBJECT,
				"object": obj,
				"position": world_position
			})
	
	# Movement is always an option if position is walkable
	var district = _get_current_district()
	if district and district.is_position_walkable(world_position):
		targets.append({
			"type": TargetType.MOVEMENT,
			"priority": Priority.MOVEMENT,
			"position": world_position
		})
	
	return targets

func _sort_by_priority(a: Dictionary, b: Dictionary) -> bool:
	"""Sort function for priority comparison"""
	return a.priority > b.priority

func _process_target(target: Dictionary, original_click_data: Dictionary):
	"""Process the selected target based on its type"""
	var result = original_click_data.duplicate()
	result["handled"] = true
	result["target_type"] = target.type
	
	match target.type:
		TargetType.UI:
			result["action"] = "ui_interaction"
			emit_signal("click_rejected", "UI element clicked")
			
		TargetType.OBJECT:
			result["action"] = "object_interaction"
			result["object"] = target.object
			result["position"] = target.position
			emit_signal("click_processed", result)
			
		TargetType.MOVEMENT:
			result["action"] = "movement"
			result["position"] = target.position
			emit_signal("click_processed", result)
			
		_:
			result["handled"] = false
			emit_signal("click_processed", result)

func _process_movement(world_position: Vector2, player, district):
	"""Process movement when no higher priority targets exist"""
	var result = {
		"handled": true,
		"action": "movement",
		"world_position": world_position,
		"target_type": TargetType.MOVEMENT
	}
	
	if district and not district.is_position_walkable(world_position):
		# Try to find adjusted position
		var adjusted = _find_closest_walkable_point(world_position, district)
		if adjusted != world_position:
			result["adjusted_position"] = adjusted
			result["original_position"] = world_position
	
	emit_signal("click_processed", result)

func _is_position_on_object(world_position: Vector2, object: Node2D) -> bool:
	"""Check if position intersects with an interactive object"""
	if not object or not is_instance_valid(object):
		return false
	
	# Check for Sprite child
	var sprite = object.get_node_or_null("Sprite")
	if sprite:
		var rect = Rect2(
			object.global_position + sprite.offset - sprite.texture.get_size() / 2,
			sprite.texture.get_size()
		)
		return rect.has_point(world_position)
	
	# Fallback to collision shape if available
	var area = object.get_node_or_null("Area2D")
	if area:
		for child in area.get_children():
			if child is CollisionShape2D:
				# Simple circle check for now
				var shape = child.shape
				if shape is CircleShape2D:
					var distance = world_position.distance_to(object.global_position)
					return distance <= shape.radius
	
	# Default proximity check
	return world_position.distance_to(object.global_position) < 32

func _is_position_on_ui(screen_position: Vector2) -> bool:
	"""Check if screen position is over a UI element"""
	# This should match InputManager's implementation
	var input_manager = _get_input_manager()
	if input_manager and input_manager.has_method("is_click_on_ui"):
		return input_manager.is_click_on_ui(screen_position)
	return false

func _is_dialog_active() -> bool:
	"""Check if a dialog is currently active"""
	var input_manager = _get_input_manager()
	if input_manager and input_manager.has_method("should_block_click_for_dialog"):
		return input_manager.should_block_click_for_dialog()
	return false

func _get_current_district():
	"""Get the current active district"""
	var districts = get_tree().get_nodes_in_group("district")
	if districts.size() > 0:
		return districts[0]
	return null

func _get_input_manager():
	"""Get the InputManager instance"""
	var managers = get_tree().get_nodes_in_group("input_manager")
	if managers.size() > 0:
		return managers[0]
	return null

func _find_closest_walkable_point(position: Vector2, district) -> Vector2:
	"""Find the closest walkable point to the given position"""
	if not district or not district.has_method("is_position_walkable"):
		return position
	
	# Simple radial search
	var search_radius = 50.0
	var search_steps = 16
	var angle_step = TAU / search_steps
	
	for radius in range(10, int(search_radius) + 1, 10):
		for i in range(search_steps):
			var angle = i * angle_step
			var test_pos = position + Vector2(cos(angle), sin(angle)) * radius
			if district.is_position_walkable(test_pos):
				return test_pos
	
	return position

func _on_click_detected(position: Vector2, screen_position: Vector2):
	"""Handle click detection from InputManager"""
	# This would be connected to InputManager's click_detected signal
	var player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	var district = _get_current_district()
	
	process_click({
		"screen_position": screen_position,
		"world_position": position,
		"player": player,
		"district": district
	})