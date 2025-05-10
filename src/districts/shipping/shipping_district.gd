extends "res://src/core/districts/base_district.gd"

func _ready():
	district_name = "Shipping District"
	district_description = "The station's dock area where ships arrive with cargo and passengers."
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
