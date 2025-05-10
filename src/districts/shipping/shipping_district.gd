extends "res://src/core/districts/base_district.gd"

func _ready():
	district_name = "Shipping District"
	district_description = "The station's dock area where ships arrive with cargo and passengers."
	# Call parent _ready instead of using super
	._ready()

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
