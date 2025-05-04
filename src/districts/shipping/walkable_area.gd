extends CollisionPolygon2D

func _ready():
    # Initialize the walkable area
    add_to_group("walkable_area")

func get_global_rect():
    # Get the bounding rect in global coordinates
    var rect = Rect2()
    var points = polygon
    if points.size() > 0:
        rect.position = points[0]
        for point in points:
            rect = rect.expand(point)
    return Rect2(rect.position + global_position, rect.size)
