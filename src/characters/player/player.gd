extends Node2D

# Movement states for state machine
enum MovementState {
	IDLE,
	ACCELERATING,
	MOVING,
	DECELERATING,
	ARRIVED
}

# Exported movement parameters
export var movement_speed = 200
export var acceleration = 800
export var deceleration = 1200

# Movement variables
var target_position = Vector2()
var velocity = Vector2()
var is_moving = false
var current_district = null

# State machine
var current_movement_state = MovementState.IDLE

# Signals
signal movement_state_changed(new_state)

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
        _set_movement_state(MovementState.ACCELERATING)
        print("Moving to: " + str(pos))
    else:
        print("Cannot move to: " + str(pos) + " - not in walkable area")

func _physics_process(delta):
    if is_moving:
        _handle_movement(delta)

func _process(delta):
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
        _set_movement_state(MovementState.ARRIVED)
        # After a brief moment, return to IDLE
        yield(get_tree().create_timer(0.1), "timeout")
        if not is_moving:  # Still not moving
            _set_movement_state(MovementState.IDLE)
        return
    
    # Apply acceleration toward target
    direction = direction.normalized()
    
    # Calculate desired velocity
    var desired_velocity = direction * movement_speed
    
    # Update movement state based on velocity and distance
    _update_movement_state(distance)
    
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
            sprite.scale.x = -1
        elif velocity.x > 0:
            sprite.scale.x = 1

func _set_movement_state(new_state):
    if current_movement_state != new_state:
        current_movement_state = new_state
        emit_signal("movement_state_changed", new_state)

func _update_movement_state(distance_to_target):
    # Determine current state based on velocity and distance
    var speed = velocity.length()
    
    if current_movement_state == MovementState.ACCELERATING:
        # Check if we've reached cruising speed
        if speed >= movement_speed * 0.95:
            _set_movement_state(MovementState.MOVING)
    elif current_movement_state == MovementState.MOVING:
        # Check if we need to start decelerating
        var stopping_distance = (speed * speed) / (2 * deceleration)
        if distance_to_target <= stopping_distance * 1.2:
            _set_movement_state(MovementState.DECELERATING)
    elif current_movement_state == MovementState.DECELERATING:
        # We stay in this state until arrival
        pass
