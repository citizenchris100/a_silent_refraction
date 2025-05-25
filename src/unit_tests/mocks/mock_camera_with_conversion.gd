extends Camera2D
# Mock camera that provides coordinate conversion

func screen_to_world(screen_pos: Vector2) -> Vector2:
	# Simple conversion: add camera position to screen position
	return screen_pos + global_position - get_viewport_rect().size / 2