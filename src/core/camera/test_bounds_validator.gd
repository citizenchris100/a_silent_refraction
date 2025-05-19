class_name TestBoundsValidator
extends "res://src/core/camera/bounds_validator.gd"

# TestBoundsValidator: Test-specific bounds validator implementation
#
# This validator is designed specifically for testing scenarios where
# we want to bypass bounds validation to test camera movement independently.
# It always returns the original position, allowing tests to position the 
# camera freely without bounds constraints.

# Configuration (not actually used, but included for interface completeness)
var bounds_enabled: bool = false
var camera_bounds: Rect2

func _init():
    # Initialize with empty bounds
    camera_bounds = Rect2(0, 0, 0, 0)
    bounds_enabled = false
    print("TestBoundsValidator initialized - bounds validation disabled for testing")

# Implementation of validate_position from BoundsValidator interface
# For testing, always return the original position without validation
func validate_position(position: Vector2, camera_half_size: Vector2) -> Vector2:
    print("[TEST] TestBoundsValidator bypassing bounds validation for: " + str(position))
    # Always return the original position unchanged
    return position

# These methods don't do anything in the test validator but are implemented
# for interface completeness
func set_bounds(new_bounds: Rect2) -> void:
    camera_bounds = new_bounds
    print("[TEST] Set bounds to: " + str(new_bounds) + " (ignored in test validator)")
    
func set_bounds_enabled(enabled: bool) -> void:
    bounds_enabled = enabled
    print("[TEST] Set bounds_enabled to: " + str(enabled) + " (ignored in test validator)")