extends Node2D

# Mock District for testing - provides reliable properties without runtime script compilation

var background_scale_factor = 1.0
var district_name = "Mock District"

func setup_mock(scale_factor: float, name: String):
	background_scale_factor = scale_factor
	district_name = name

func get_camera():
	# Return null - tests should provide their own camera
	return null