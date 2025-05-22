extends Node
# Mock Signal Listener for testing camera signal connections

signal test_signal_received(signal_data)

func _on_camera_state_changed(new_state, old_state, transition_reason):
	emit_signal("test_signal_received", {
		"type": "state_changed",
		"new_state": new_state,
		"old_state": old_state,
		"transition_reason": transition_reason
	})

func _on_camera_move_started(target_position, old_position, move_duration, transition_type):
	emit_signal("test_signal_received", {
		"type": "move_started",
		"target_position": target_position,
		"old_position": old_position,
		"move_duration": move_duration,
		"transition_type": transition_type
	})

func _on_camera_move_completed(final_position, initial_position, actual_duration):
	emit_signal("test_signal_received", {
		"type": "move_completed",
		"final_position": final_position,
		"initial_position": initial_position,
		"actual_duration": actual_duration
	})

func _on_view_bounds_changed(new_bounds, old_bounds, is_district_change):
	emit_signal("test_signal_received", {
		"type": "view_bounds_changed",
		"new_bounds": new_bounds,
		"old_bounds": old_bounds,
		"is_district_change": is_district_change
	})