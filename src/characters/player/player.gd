extends Node2D

export var movement_speed = 200
export var acceleration = 800
export var deceleration = 1200

var target_position = Vector2()
var velocity = Vector2()
var is_moving = false
var current_district = null

func _ready():
    target_position = position
    add_to_group("player")
    
    # Find the current district
    yield(get_tree(), "idle_frame")
    _find_current_district()

func _find_current_district():
    var districts = get_tree().get_nodes_in_group("district")
    if districts.size() > 0:
        current_district = districts[0]
        print("Player linked to district: " + current_district.district_name)
    else:
        print("WARNING: No district found for the player")

func move_to(pos):
    # Check if position is within a walkable area
    if current_district and current_district.is_position_walkable(pos):
        target_position = pos
        is_moving = true
        print("Moving to: " + str(pos))
    else:
        print("Cannot move to: " + str(pos) + " - not in walkable area")

func _process(delta):
    if is_moving:
        _handle_movement(delta)
        
    # Update any visual indicators (like facing direction)
    _update_visuals()

func _handle_movement(delta):
    var direction = target_position - position
    var distance = direction.length()
    
    if distance < 5:
        # We've reached the destination
        position = target_position
        velocity = Vector2.ZERO
        is_moving = false
        return
    
    # Apply acceleration toward target
    direction = direction.normalized()
    
    # Calculate desired velocity
    var desired_velocity = direction * movement_speed
    
    # Apply acceleration or deceleration based on whether we're moving toward target or slowing down
    if velocity.dot(direction) > 0:
        velocity = velocity.move_toward(desired_velocity, acceleration * delta)
    else:
        velocity = velocity.move_toward(desired_velocity, deceleration * delta)
    
    # Apply movement with delta time
    position += velocity * delta
    
    # Check if we're about to leave walkable area and correct if needed
    if current_district:
        position = _adjust_position_to_stay_in_bounds(position)

func _adjust_position_to_stay_in_bounds(pos):
    # This is a simple implementation that just checks the current position
    # A more advanced implementation would predict collisions before they happen
    if current_district and !current_district.is_position_walkable(pos):
        # Reset to previous position and stop movement
        is_moving = false
        return position - velocity.normalized() * 5
    return pos

func _update_visuals():
    # Update the player's visual appearance based on movement
    # This could include changing animations, facing direction, etc.
    if has_node("Sprite") and velocity != Vector2.ZERO:
        var sprite = get_node("Sprite")
        
        # If moving left or right, flip the sprite accordingly
        if velocity.x < 0:
            sprite.rect_scale.x = -1
        elif velocity.x > 0:
            sprite.rect_scale.x = 1
