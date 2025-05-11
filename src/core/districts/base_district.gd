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
        # Check if the point is in the polygon
        var polygon = area.polygon
        if Geometry.is_point_in_polygon(position, polygon):
            return true
    return false

# Debug function to test walkable boundaries
func test_walkable_boundaries():
    var screen_size = get_viewport_rect().size
    var test_points = []
    var results = []

    # Create a grid of test points
    for x in range(0, int(screen_size.x), 50):
        for y in range(0, int(screen_size.y), 50):
            var point = Vector2(x, y)
            test_points.append(point)
            results.append(is_position_walkable(point))

    # Output results to a debug visualization node
    var debug_node = Node2D.new()
    debug_node.name = "WalkableBoundaryTest"
    add_child(debug_node)

    for i in range(test_points.size()):
        var point = test_points[i]
        var is_walkable = results[i]

        # Only show markers for walkable areas to reduce visual clutter
        if is_walkable:
            var marker = ColorRect.new()
            marker.rect_size = Vector2(5, 5)
            marker.rect_position = point - Vector2(2.5, 2.5)
            marker.color = Color(0.2, 0.8, 0.3, 0.3)  # More transparent green
            debug_node.add_child(marker)

    print("Created walkable boundary test with " + str(test_points.size()) + " points")
    return {"walkable": results.count(true), "unwalkable": results.count(false)}

# Exit this district
func exit_district():
    emit_signal("district_exited", district_name)

# This method will be implemented in a future iteration
func register_locations():
    return {}
