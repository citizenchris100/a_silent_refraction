extends Node2D
# Simple tolerance circle visualization

func _draw():
	var radius = get_meta("radius", 10.0) if has_meta("radius") else 10.0
	
	# Draw outer circle
	draw_circle(Vector2.ZERO, radius, Color(1, 1, 0, 0.3))
	
	# Draw border
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1, 1, 0, 0.8), 2.0)
	
	# Draw center dot
	draw_circle(Vector2.ZERO, 2, Color(1, 1, 0, 0.8))