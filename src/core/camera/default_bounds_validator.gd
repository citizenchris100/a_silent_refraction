class_name DefaultBoundsValidator
extends "res://src/core/camera/bounds_validator.gd"

# DefaultBoundsValidator: Standard implementation of bounds validation
#
# This class contains the standard bounds validation logic extracted from
# the ScrollingCamera. It ensures that camera positions respect the defined
# boundaries of the game world.

# Configuration
var bounds_enabled: bool = true
var camera_bounds: Rect2

# Initialize with default or provided bounds
func _init(initial_bounds: Rect2 = Rect2(0, 0, 1024, 768)):
    camera_bounds = initial_bounds

# Implementation of validate_position from BoundsValidator interface
func validate_position(position: Vector2, camera_half_size: Vector2) -> Vector2:
    # If bounds checking is disabled or bounds are invalid, return original position
    if not bounds_enabled or camera_bounds.size == Vector2.ZERO:
        return position
        
    var validated_pos = position
    
    # Calculate bounds limits
    var min_x = camera_bounds.position.x + camera_half_size.x
    var max_x = camera_bounds.position.x + camera_bounds.size.x - camera_half_size.x
    var min_y = camera_bounds.position.y + camera_half_size.y
    var max_y = camera_bounds.position.y + camera_bounds.size.y - camera_half_size.y
    
    # Handle case where camera is larger than bounds (min > max)
    if min_x > max_x:
        # Center horizontally in the available area
        var center_x = camera_bounds.position.x + (camera_bounds.size.x / 2)
        min_x = center_x
        max_x = center_x
        print("WARNING: Camera width exceeds bounds width. Centering camera horizontally.")
    
    if min_y > max_y:
        # Center vertically in the available area
        var center_y = camera_bounds.position.y + (camera_bounds.size.y / 2)
        min_y = center_y
        max_y = center_y
        print("WARNING: Camera height exceeds bounds height. Centering camera vertically.")
    
    # Clamp position to bounds
    validated_pos.x = clamp(validated_pos.x, min_x, max_x)
    validated_pos.y = clamp(validated_pos.y, min_y, max_y)
    
    # Log if position was adjusted (for debugging)
    if validated_pos != position:
        print("Position adjusted by bounds: " + str(position) + " -> " + str(validated_pos))
    
    return validated_pos

# Set new bounds rectangle
func set_bounds(new_bounds: Rect2) -> void:
    camera_bounds = new_bounds

# Enable or disable bounds checking
func set_bounds_enabled(enabled: bool) -> void:
    bounds_enabled = enabled