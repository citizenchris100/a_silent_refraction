extends Resource
# PerspectiveConfiguration: Configuration data for different perspective types

class_name PerspectiveConfiguration

# Configuration properties
export var perspective_type: int = 0  # Default to ISOMETRIC
export var direction_count: int = 8
export var movement_speed_multiplier: float = 1.0
export var sprite_scale: Vector2 = Vector2(1.0, 1.0)
export var supports_diagonal_movement: bool = true
export var camera_zoom_level: float = 1.0
export var y_sort_enabled: bool = true
export var animation_prefix: String = "iso_"

# Validate configuration
func is_valid() -> bool:
    if direction_count <= 0:
        return false
    if movement_speed_multiplier <= 0:
        return false
    if sprite_scale.x <= 0 or sprite_scale.y <= 0:
        return false
    return true

# Create isometric configuration
static func create_isometric_config():
    var config = load("res://src/core/perspective/perspective_configuration.gd").new()
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    config.perspective_type = PerspectiveTypeRef.ISOMETRIC
    config.direction_count = 8
    config.movement_speed_multiplier = 1.0
    config.sprite_scale = Vector2(1.0, 1.0)
    config.supports_diagonal_movement = true
    config.camera_zoom_level = 1.0
    config.y_sort_enabled = true
    config.animation_prefix = "iso_"
    return config

# Create side scrolling configuration
static func create_side_scrolling_config():
    var config = load("res://src/core/perspective/perspective_configuration.gd").new()
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    config.perspective_type = PerspectiveTypeRef.SIDE_SCROLLING
    config.direction_count = 2
    config.movement_speed_multiplier = 1.2
    config.sprite_scale = Vector2(1.0, 1.0)
    config.supports_diagonal_movement = false
    config.camera_zoom_level = 1.0
    config.y_sort_enabled = false
    config.animation_prefix = "side_"
    return config

# Create top down configuration
static func create_top_down_config():
    var config = load("res://src/core/perspective/perspective_configuration.gd").new()
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    config.perspective_type = PerspectiveTypeRef.TOP_DOWN
    config.direction_count = 4
    config.movement_speed_multiplier = 1.0
    config.sprite_scale = Vector2(0.8, 0.8)
    config.supports_diagonal_movement = false
    config.camera_zoom_level = 0.8
    config.y_sort_enabled = true
    config.animation_prefix = "top_"
    return config

# Get configuration from dictionary (for loading from JSON)
static func from_dict(data: Dictionary):
    var config = load("res://src/core/perspective/perspective_configuration.gd").new()
    
    if data.has("perspective_type"):
        var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
        config.perspective_type = PerspectiveTypeRef.get_perspective_from_string(data.perspective_type)
    
    if data.has("direction_count"):
        config.direction_count = int(data.direction_count)
    
    if data.has("movement_speed_multiplier"):
        config.movement_speed_multiplier = float(data.movement_speed_multiplier)
    
    if data.has("sprite_scale"):
        if typeof(data.sprite_scale) == TYPE_ARRAY and data.sprite_scale.size() >= 2:
            config.sprite_scale = Vector2(float(data.sprite_scale[0]), float(data.sprite_scale[1]))
        elif typeof(data.sprite_scale) == TYPE_REAL:
            config.sprite_scale = Vector2(float(data.sprite_scale), float(data.sprite_scale))
    
    if data.has("supports_diagonal_movement"):
        config.supports_diagonal_movement = bool(data.supports_diagonal_movement)
    
    if data.has("camera_zoom_level"):
        config.camera_zoom_level = float(data.camera_zoom_level)
    
    if data.has("y_sort_enabled"):
        config.y_sort_enabled = bool(data.y_sort_enabled)
    
    if data.has("animation_prefix"):
        config.animation_prefix = str(data.animation_prefix)
    
    return config

# Convert to dictionary (for saving to JSON)
func to_dict() -> Dictionary:
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    return {
        "perspective_type": PerspectiveTypeRef.get_perspective_name(perspective_type),
        "direction_count": direction_count,
        "movement_speed_multiplier": movement_speed_multiplier,
        "sprite_scale": [sprite_scale.x, sprite_scale.y],
        "supports_diagonal_movement": supports_diagonal_movement,
        "camera_zoom_level": camera_zoom_level,
        "y_sort_enabled": y_sort_enabled,
        "animation_prefix": animation_prefix
    }