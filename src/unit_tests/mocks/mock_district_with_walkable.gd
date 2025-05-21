extends Node2D

# Mock District for testing - provides reliable properties without runtime script compilation
# Includes walkable_areas property for camera-walkable integration tests

var background_scale_factor = 2.0
var district_name = "Test District"
var background_size = Vector2(1000, 600)
var walkable_areas = []

func setup_mock(scale_factor: float = 2.0, name: String = "Test District"):
    background_scale_factor = scale_factor
    district_name = name

func add_walkable_area(area: Polygon2D):
    walkable_areas.append(area)
    
func get_camera():
    for child in get_children():
        if child is Camera2D:
            return child
    return null
    
func is_position_walkable(position):
    for area in walkable_areas:
        if area and "polygon" in area and Geometry.is_point_in_polygon(position, area.polygon):
            return true
    return false

func screen_to_world_coords(screen_pos):
    var camera = get_camera()
    if camera and camera.has_method("screen_to_world"):
        return camera.screen_to_world(screen_pos)
    return screen_pos
    
func world_to_screen_coords(world_pos):
    var camera = get_camera()
    if camera and camera.has_method("world_to_screen"):
        return camera.world_to_screen(world_pos)
    return world_pos