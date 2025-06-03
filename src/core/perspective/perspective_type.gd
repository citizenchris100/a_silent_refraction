extends Object
# PerspectiveType: Enum and utilities for different visual perspectives in the game

class_name PerspectiveType

# Perspective type constants
const ISOMETRIC = 0
const SIDE_SCROLLING = 1
const TOP_DOWN = 2

# Get human-readable name for a perspective type
static func get_perspective_name(type: int) -> String:
    match type:
        ISOMETRIC:
            return "isometric"
        SIDE_SCROLLING:
            return "side_scrolling"
        TOP_DOWN:
            return "top_down"
        _:
            return "unknown"

# Convert string to perspective type
static func get_perspective_from_string(name: String) -> int:
    match name.to_lower():
        "isometric":
            return ISOMETRIC
        "side_scrolling":
            return SIDE_SCROLLING
        "top_down":
            return TOP_DOWN
        _:
            push_warning("Unknown perspective type: %s, defaulting to ISOMETRIC" % name)
            return ISOMETRIC

# Get valid movement directions for a perspective type
static func get_valid_directions(type: int) -> Array:
    match type:
        ISOMETRIC:
            # 8-directional movement for isometric
            return ["north", "northeast", "east", "southeast", 
                    "south", "southwest", "west", "northwest"]
        SIDE_SCROLLING:
            # 2-directional movement for side scrolling
            return ["left", "right"]
        TOP_DOWN:
            # 4-directional movement for top down
            return ["north", "east", "south", "west"]
        _:
            return []

# Get animation direction count for a perspective
static func get_direction_count(type: int) -> int:
    return get_valid_directions(type).size()

# Check if a direction is valid for a perspective type
static func is_valid_direction(type: int, direction: String) -> bool:
    return direction in get_valid_directions(type)

# Convert a movement vector to a direction string for a perspective
static func vector_to_direction(type: int, vector: Vector2) -> String:
    if vector.length_squared() < 0.01:
        return ""
    
    match type:
        ISOMETRIC:
            return _vector_to_8way_direction(vector)
        SIDE_SCROLLING:
            return _vector_to_2way_direction(vector)
        TOP_DOWN:
            return _vector_to_4way_direction(vector)
        _:
            return ""

# Helper function for 8-way direction
static func _vector_to_8way_direction(vector: Vector2) -> String:
    var angle = vector.angle()
    # Convert to 0-360 range
    if angle < 0:
        angle += TAU
    
    # Divide into 8 segments (45 degrees each)
    var segment = int(round(angle / (TAU / 8))) % 8
    
    var directions = ["east", "southeast", "south", "southwest", 
                     "west", "northwest", "north", "northeast"]
    return directions[segment]

# Helper function for 2-way direction
static func _vector_to_2way_direction(vector: Vector2) -> String:
    if vector.x > 0:
        return "right"
    elif vector.x < 0:
        return "left"
    else:
        return "right"  # Default to right if no horizontal movement

# Helper function for 4-way direction
static func _vector_to_4way_direction(vector: Vector2) -> String:
    # Determine dominant axis
    if abs(vector.x) > abs(vector.y):
        # Horizontal movement is dominant
        if vector.x > 0:
            return "east"
        else:
            return "west"
    else:
        # Vertical movement is dominant
        if vector.y > 0:
            return "south"
        else:
            return "north"