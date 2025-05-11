extends Node2D

func _ready():
	# Manually place animated elements for testing
	var animated_bg = $AnimatedBackground
	
	# Computer terminal
	animated_bg.add_element("computer_terminal", "shipping_main", Vector2(100, 200), {"frame_delay": 0.3})
	
	# Warning light
	animated_bg.add_element("warning_light", "security", Vector2(500, 85))
	
	# Conveyor belt
	animated_bg.add_element("conveyor_belt", "shipping", Vector2(512, 450), {"is_moving": true})
	
	# Steam vent
	animated_bg.add_element("steam_vent", "maintenance", Vector2(350, 550), {"cycle_pause": 5.0})
	
	# Ventilation fan
	animated_bg.add_element("ventilation_fan", "standard", Vector2(100, 100), {"speed_factor": 0.5})
	
	# Sliding door
	animated_bg.add_element("sliding_door", "standard", Vector2(500, 550))
	
	# Security camera
	animated_bg.add_element("security_camera", "shipping_main", Vector2(230, 100))
	
	# Flickering light
	animated_bg.add_element("flickering_light", "hallway", Vector2(650, 50))
	
	print("Added animated elements manually")