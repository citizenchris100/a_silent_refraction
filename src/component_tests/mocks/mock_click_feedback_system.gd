extends Node2D
# Mock Click Feedback System for component testing
# This mock defines the expected behavior of the visual feedback system

signal feedback_created(feedback_data)
signal feedback_removed(feedback_data)

# Feedback types
enum FeedbackType {
	VALID,    # Green - successful click
	INVALID,  # Red - invalid click location
	ADJUSTED  # Yellow - click was adjusted
}

# Active feedback markers
var active_feedbacks = []
var adjustment_lines = []

# Visual constants (matching component test)
const FEEDBACK_DURATION = 0.5
const VALID_COLOR = Color(0, 1, 0, 0.6)
const INVALID_COLOR = Color(1, 0, 0, 0.6)
const ADJUSTED_COLOR = Color(1, 1, 0, 0.6)

class FeedbackMarker:
	var position: Vector2
	var color: Color
	var type: int
	var creation_time: float
	var node: Node2D
	
	func _init(pos: Vector2, col: Color, t: int):
		position = pos
		color = col
		type = t
		creation_time = OS.get_ticks_msec() / 1000.0

func _ready():
	set_process(true)

func _process(delta):
	# Update feedback fade and cleanup
	var current_time = OS.get_ticks_msec() / 1000.0
	var to_remove = []
	
	for i in range(active_feedbacks.size() - 1, -1, -1):
		var feedback = active_feedbacks[i]
		var elapsed = current_time - feedback.creation_time
		
		if elapsed >= FEEDBACK_DURATION:
			to_remove.append(i)
		else:
			# Update fade
			var fade_progress = elapsed / FEEDBACK_DURATION
			var alpha = lerp(feedback.color.a, 0.0, fade_progress)
			feedback.color.a = alpha
			if feedback.node:
				feedback.node.modulate.a = alpha
	
	# Remove expired feedbacks
	for idx in to_remove:
		remove_feedback(idx)

func show_click_feedback(position: Vector2, type: int):
	var color = VALID_COLOR
	match type:
		FeedbackType.INVALID:
			color = INVALID_COLOR
		FeedbackType.ADJUSTED:
			color = ADJUSTED_COLOR
	
	var feedback = FeedbackMarker.new(position, color, type)
	
	# Create visual node
	var marker_node = create_feedback_node(feedback)
	feedback.node = marker_node
	add_child(marker_node)
	
	active_feedbacks.append(feedback)
	
	emit_signal("feedback_created", {
		"position": position,
		"type": type,
		"color": color
	})

func show_adjusted_click_feedback(original_pos: Vector2, adjusted_pos: Vector2):
	# Show yellow marker at original position
	show_click_feedback(original_pos, FeedbackType.ADJUSTED)
	
	# Show green marker at adjusted position
	show_click_feedback(adjusted_pos, FeedbackType.VALID)
	
	# Create adjustment line
	create_adjustment_line(original_pos, adjusted_pos)

func create_feedback_node(feedback: FeedbackMarker) -> Node2D:
	# Create a simple colored circle as feedback
	var node = Node2D.new()
	node.position = feedback.position
	
	# For this mock, we'll just track the node
	# Real implementation would draw a circle or use a sprite
	
	return node

func create_adjustment_line(from: Vector2, to: Vector2):
	adjustment_lines.append({
		"from": from,
		"to": to,
		"creation_time": OS.get_ticks_msec() / 1000.0
	})

func has_adjustment_line(from: Vector2, to: Vector2) -> bool:
	for line in adjustment_lines:
		if line.from == from and line.to == to:
			return true
	return false

func get_active_feedbacks() -> Array:
	return active_feedbacks

func clear_all_feedback():
	# Remove all feedback nodes
	for feedback in active_feedbacks:
		if feedback.node:
			feedback.node.queue_free()
	
	active_feedbacks.clear()
	adjustment_lines.clear()

func remove_feedback(index: int):
	if index < 0 or index >= active_feedbacks.size():
		return
		
	var feedback = active_feedbacks[index]
	
	emit_signal("feedback_removed", {
		"position": feedback.position,
		"type": feedback.type
	})
	
	if feedback.node:
		feedback.node.queue_free()
	
	active_feedbacks.remove(index)

func _on_click_processed(click_data):
	# Show feedback based on processed click
	if click_data and click_data.has("position"):
		var feedback_type = FeedbackType.VALID
		if click_data.has("adjusted") and click_data.adjusted:
			feedback_type = FeedbackType.ADJUSTED
		
		show_click_feedback(click_data.position, feedback_type)