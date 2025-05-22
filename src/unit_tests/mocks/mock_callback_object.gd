extends Node
# Mock Callback Object for testing camera transition callbacks

signal callback_invoked(callback_data)

func _on_transition_point(point, position, progress):
	emit_signal("callback_invoked", {
		"type": "transition_point",
		"point": point,
		"position": position,
		"progress": progress
	})