extends Node
# Mock UI Element for testing camera UI synchronization

signal callback_invoked(callback_data)

func sync_with_camera_movement(progress, from_pos, to_pos):
	emit_signal("callback_invoked", {
		"type": "sync_with_camera_movement",
		"progress": progress,
		"from_pos": from_pos,
		"to_pos": to_pos
	})

func on_camera_state_changed(new_state, old_state):
	emit_signal("callback_invoked", {
		"type": "on_camera_state_changed",
		"new_state": new_state,
		"old_state": old_state
	})

func on_camera_move_completed():
	emit_signal("callback_invoked", {
		"type": "on_camera_move_completed"
	})