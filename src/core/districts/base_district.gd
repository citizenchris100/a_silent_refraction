extends Node2D
class_name BaseDistrict

# District properties
export var district_name = "Unknown District"
export var district_description = "A district on the station"

# Areas where the player can walk
var walkable_areas = []

# Interactive objects in this district
var interactive_objects = []

# Signals
signal district_entered(district_name)
signal district_exited(district_name)

func _ready():
    # Initialize the district
    print(district_name + " loaded")
    
    # Add to district group
    add_to_group("district")
    
    # Find walkable areas and interactive objects
    for child in get_children():
        if child.is_in_group("walkable_area"):
            walkable_areas.append(child)
        if child.is_in_group("interactive_object"):
            interactive_objects.append(child)
    
    # Emit signal
    emit_signal("district_entered", district_name)

# Check if a position is in a walkable area
func is_position_walkable(position):
    for area in walkable_areas:
        if area.contains_point(position):
            return true
    return false

# Exit this district
func exit_district():
    emit_signal("district_exited", district_name)
