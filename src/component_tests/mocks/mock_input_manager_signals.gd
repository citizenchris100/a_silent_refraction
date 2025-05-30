extends Node
# Mock InputManager with signal support for component testing

signal click_detected(click_data)

func _ready():
	pass

func simulate_click(position: Vector2):
	var click_data = {
		"position": position,
		"is_ui_click": false,
		"timestamp": OS.get_ticks_msec()
	}
	emit_signal("click_detected", click_data)

func simulate_click_with_data(data: Dictionary):
	emit_signal("click_detected", data)