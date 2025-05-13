extends "res://src/core/districts/base_district.gd"

func _ready():
	district_name = "Shipping District"
	district_description = "The station's dock area where ships arrive with cargo and passengers."
	animated_elements_config = "animated_elements_config.json"

	# Call parent _ready instead of using super
	._ready()

	# Debug label disabled for clearer screenshots
	# var debug_label = Label.new()
	# debug_label.name = "DebugLabel"
	# debug_label.text = "Walkable area: y=" + str(get_node("WalkableArea").polygon[0].y) + " to " + str(get_node("WalkableArea").polygon[2].y)
	# debug_label.rect_position = Vector2(20, 50)
	# debug_label.add_color_override("font_color", Color(1, 0, 0))
	# add_child(debug_label)

# Register locations within this district
func register_locations():
	var locations = {
		"landing_bay": {
			"name": "Landing Bay",
			"description": "The main area where ships dock and unload cargo."
		},

		"customs": {
			"name": "Customs Office",
			"description": "Where cargo and passengers are processed upon arrival."
		},

		"storage": {
			"name": "Cargo Storage",
			"description": "Large warehouses storing goods waiting for distribution."
		}
	}
	return locations

# Example of controlling animated elements
func toggle_security_system(enabled):
	toggle_animated_elements("security_camera", enabled)
	toggle_animated_elements("warning_light", enabled)

	# You can also directly control specific elements
	var door = get_animated_element("sliding_door", "main_door")
	if door and door.has_method("set_property"):
		if enabled:
			door.set_property("state", "closed")
		else:
			door.set_property("state", "open")

	return enabled
