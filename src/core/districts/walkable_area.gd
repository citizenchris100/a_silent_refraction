extends Polygon2D

func _ready():
    # Add to walkable area group
    add_to_group("walkable_area")
    
    # Make semi-transparent for debugging
    color = Color(0.2, 0.6, 0.2, 0.2)

# Check if a point is inside this area
func contains_point(point):
    var poly = polygon
    var inside = false
    var j = poly.size() - 1
    
    # Standard point-in-polygon algorithm
    for i in range(poly.size()):
        if ((poly[i].y > point.y) != (poly[j].y > point.y)) and \
           (point.x < poly[i].x + (poly[j].x - poly[i].x) * (point.y - poly[i].y) / (poly[j].y - poly[i].y)):
            inside = !inside
        j = i
    
    return inside
