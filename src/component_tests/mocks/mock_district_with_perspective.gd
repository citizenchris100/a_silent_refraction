extends Node2D
# Mock District with Perspective: Mock for testing perspective integration

signal perspective_changed(new_perspective)

var district_name = "Mock Perspective District"
var perspective_type = preload("res://src/core/perspective/perspective_type.gd").ISOMETRIC
var perspective_configuration = null

func _ready():
    # Initialize with default configuration
    var ConfigClass = preload("res://src/core/perspective/perspective_configuration.gd")
    perspective_configuration = ConfigClass.create_isometric_config()

func get_perspective_configuration():
    if perspective_configuration == null:
        var ConfigClass = preload("res://src/core/perspective/perspective_configuration.gd")
        # Return configuration based on current perspective type
        match perspective_type:
            preload("res://src/core/perspective/perspective_type.gd").ISOMETRIC:
                perspective_configuration = ConfigClass.create_isometric_config()
            preload("res://src/core/perspective/perspective_type.gd").SIDE_SCROLLING:
                perspective_configuration = ConfigClass.create_side_scrolling_config()
            preload("res://src/core/perspective/perspective_type.gd").TOP_DOWN:
                perspective_configuration = ConfigClass.create_top_down_config()
            _:
                perspective_configuration = ConfigClass.create_isometric_config()
    
    return perspective_configuration

func set_perspective_type(type):
    var old_type = perspective_type
    perspective_type = type
    perspective_configuration = null  # Force regeneration
    if old_type != type:
        emit_signal("perspective_changed", type)

func is_position_walkable(position):
    # Always walkable for testing
    return true