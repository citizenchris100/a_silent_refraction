extends Node2D

# Mock District for Navigation Testing
# Handles global coordinates directly for simpler test setup

var district_name = "Navigation Test District"
var walkable_areas = []

func _ready():
    # Automatically find walkable areas in children
    for child in get_children():
        if child.is_in_group("walkable_area"):
            walkable_areas.append(child)

func add_walkable_area(area):
    walkable_areas.append(area)

func is_position_walkable(global_position):
    # This mock expects the polygon to be in global coordinates
    # which matches how we set it up in the test
    for area in walkable_areas:
        if area and area.polygon != null and area.polygon.size() > 0:
            if Geometry.is_point_in_polygon(global_position, area.polygon):
                return true
    return false

func get_closest_walkable_point(pos):
    # Simple implementation - just return the position if walkable
    # or a nearby walkable point
    if is_position_walkable(pos):
        return pos
    
    # Find closest point on any walkable area
    var closest_point = pos
    var min_distance = INF
    
    for area in walkable_areas:
        if area and area.polygon != null and area.polygon.size() > 0:
            # Check each edge of the polygon
            for i in range(area.polygon.size()):
                var p1 = area.polygon[i]
                var p2 = area.polygon[(i + 1) % area.polygon.size()]
                
                # Find closest point on this edge
                var edge_closest = Geometry.get_closest_point_to_segment_2d(pos, p1, p2)
                var dist = pos.distance_to(edge_closest)
                
                if dist < min_distance:
                    min_distance = dist
                    closest_point = edge_closest
    
    return closest_point