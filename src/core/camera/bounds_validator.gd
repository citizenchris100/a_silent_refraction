class_name BoundsValidator
extends Reference

# BoundsValidator: Interface for camera bounds validation
#
# This class defines the interface for validating camera positions against 
# scene boundaries. It's designed to decouple bounds validation logic from
# camera movement, allowing for better testing and more flexibility.

# Validates a target position against camera bounds
# Returns the adjusted position that respects bounds
func validate_position(position: Vector2, camera_half_size: Vector2) -> Vector2:
    # Base implementation just returns the original position
    # This is a pure virtual method that should be overridden
    push_error("BoundsValidator.validate_position called on base class")
    return position

# Optional method to update the bounds
func set_bounds(new_bounds: Rect2) -> void:
    # Override in implementations that need to store bounds
    pass
    
# Optional method to enable/disable bounds checking
func set_bounds_enabled(enabled: bool) -> void:
    # Override in implementations that support toggling
    pass