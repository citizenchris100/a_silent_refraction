extends Node
# CharacterPerspectiveController: Manages character sprite appearance based on perspective

class_name CharacterPerspectiveController

# Signals
signal perspective_changed(old_perspective, new_perspective)
signal animation_changed(animation_name)

# Properties
var current_perspective: int = 0  # Default to ISOMETRIC
var character_node: Node2D = null
var perspective_configs: Dictionary = {}
var animated_sprite: AnimatedSprite = null
var current_direction: String = "south"
var current_animation_state: String = "idle"

func _ready():
    name = "PerspectiveController"
    # Load default configurations
    _load_default_configs()

func _load_default_configs():
    var ConfigClass = load("res://src/core/perspective/perspective_configuration.gd")
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    
    perspective_configs[PerspectiveTypeRef.ISOMETRIC] = ConfigClass.create_isometric_config()
    perspective_configs[PerspectiveTypeRef.SIDE_SCROLLING] = ConfigClass.create_side_scrolling_config()
    perspective_configs[PerspectiveTypeRef.TOP_DOWN] = ConfigClass.create_top_down_config()

# Attach this controller to a character
func attach_to_character(character: Node2D):
    if character_node:
        push_warning("Controller already attached to a character")
        return
    
    character_node = character
    character.add_child(self)
    
    # Look for AnimatedSprite in character
    for child in character.get_children():
        if child is AnimatedSprite:
            animated_sprite = child
            break

# Set the current perspective
func set_perspective(type: int):
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    
    # Validate perspective type
    if type < 0 or type > PerspectiveTypeRef.TOP_DOWN:
        push_warning("Invalid perspective type: %d" % type)
        return
    
    if type == current_perspective:
        return
    
    var old_perspective = current_perspective
    current_perspective = type
    
    # Update animation if we have a sprite
    if animated_sprite:
        _update_animation()
    
    emit_signal("perspective_changed", old_perspective, current_perspective)

# Get the current perspective configuration
func get_current_configuration():
    if current_perspective in perspective_configs:
        return perspective_configs[current_perspective]
    
    # Return default if not found
    var ConfigClass = load("res://src/core/perspective/perspective_configuration.gd")
    return ConfigClass.create_isometric_config()

# Convert movement vector to direction string for current perspective
func convert_movement_to_direction(vector: Vector2) -> String:
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    var direction = PerspectiveTypeRef.vector_to_direction(current_perspective, vector)
    
    if direction != "":
        current_direction = direction
    
    return direction

# Get animation prefix for a perspective type
func get_animation_prefix(type: int) -> String:
    if type in perspective_configs:
        return perspective_configs[type].animation_prefix
    
    # Default prefixes
    var PerspectiveTypeRef = load("res://src/core/perspective/perspective_type.gd")
    match type:
        PerspectiveTypeRef.ISOMETRIC:
            return "iso_"
        PerspectiveTypeRef.SIDE_SCROLLING:
            return "side_"
        PerspectiveTypeRef.TOP_DOWN:
            return "top_"
        _:
            return ""

# Get the full animation name for current perspective
func get_perspective_animation_name(state: String, direction: String) -> String:
    var prefix = get_animation_prefix(current_perspective)
    return "%s%s_%s" % [prefix, state, direction]

# Get fallback animation name (without perspective prefix)
func get_fallback_animation(full_name: String) -> String:
    # Remove any known prefixes
    var prefixes = ["iso_", "side_", "top_"]
    for prefix in prefixes:
        if full_name.begins_with(prefix):
            var base_name = full_name.substr(prefix.length())
            # Extract just the state part (before direction)
            var parts = base_name.split("_")
            if parts.size() > 0:
                return parts[0]
    
    # Return the full name if no prefix found
    return full_name

# Update character animation based on current state
func play_animation(state: String, direction: String = ""):
    current_animation_state = state
    
    if direction != "":
        current_direction = direction
    
    if animated_sprite:
        _update_animation()

# Internal animation update
func _update_animation():
    if not animated_sprite:
        return
    
    var anim_name = get_perspective_animation_name(current_animation_state, current_direction)
    
    # Try to play the perspective-specific animation
    if animated_sprite.frames and animated_sprite.frames.has_animation(anim_name):
        animated_sprite.play(anim_name)
        emit_signal("animation_changed", anim_name)
    else:
        # Try fallback animation
        var fallback = get_fallback_animation(anim_name)
        if animated_sprite.frames and animated_sprite.frames.has_animation(fallback):
            animated_sprite.play(fallback)
            emit_signal("animation_changed", fallback)
        else:
            push_warning("No animation found: %s or fallback: %s" % [anim_name, fallback])

# Update configuration for a specific perspective
func set_perspective_config(type: int, config):
    perspective_configs[type] = config

# Check if controller has a specific perspective configured
func has_perspective(type: int) -> bool:
    return type in perspective_configs