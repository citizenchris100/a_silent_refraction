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

# Navigation2D variables
var navigation_path = []
var navigation_node = null
var current_path_index = 0

# Signals
signal movement_state_changed(new_state)

func _ready():
    target_position = position
    add_to_group("player")
    
    # Find the current district
    yield(get_tree(), "idle_frame")
    _find_current_district()
    
    # Find navigation node if available
    navigation_node = _find_navigation_node()

func _find_current_district():
    var districts = get_tree().get_nodes_in_group("district")
    if districts.size() > 0:
        current_district = districts[0]
        print("Player linked to district: " + current_district.district_name)
    else:
        print("WARNING: No district found for the player")

func _find_navigation_node():
    # Look for Navigation2D node in parent hierarchy
    var parent = get_parent()
    while parent:
        if parent.has_node("Navigation2D"):
            return parent.get_node("Navigation2D")
        # Also check if parent itself is Navigation2D
        if parent is Navigation2D:
            return parent
        parent = parent.get_parent()
    return null

func move_to(pos):
    # Alias for move_to_position for compatibility
    move_to_position(pos)

func move_to_position(pos):
    # Check if position is within a walkable area
    if current_district and current_district.is_position_walkable(pos):
        target_position = pos
        
        # Try to use Navigation2D if available
        if navigation_node:
            navigation_path = navigation_node.get_simple_path(global_position, pos)
            current_path_index = 0
            
            # Skip the first point if it's very close to current position
            if navigation_path.size() > 1 and global_position.distance_to(navigation_path[0]) < 5:
                current_path_index = 1
        else:
            # Fallback to direct movement
            navigation_path = []
        
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
    var current_target = target_position
    
    # DEBUG: Track state at start of frame
    var debug_initial_index = current_path_index
    var debug_path_size = navigation_path.size()
    
    # If we have a navigation path, follow it
    if navigation_path.size() > 0 and current_path_index < navigation_path.size():
        current_target = navigation_path[current_path_index]
        
        # Check if we've reached the current path point
        if global_position.distance_to(current_target) < 10:
            print("[NAV DEBUG] Reached waypoint %d at position %s" % [current_path_index, global_position])
            current_path_index += 1
            print("[NAV DEBUG] Incremented index to %d (path size: %d)" % [current_path_index, navigation_path.size()])
            if current_path_index >= navigation_path.size():
                # We've reached the end of the path
                print("[NAV DEBUG] Exhausted waypoints, targeting final destination: %s" % target_position)
                current_target = target_position
    elif navigation_path.size() > 0 and current_path_index >= navigation_path.size():
        # This branch handles when we've already exhausted waypoints in a previous frame
        print("[NAV DEBUG] Already exhausted waypoints (index=%d, size=%d), continuing to target" % [current_path_index, navigation_path.size()])
        current_target = target_position
    else:
        # DEBUG: See if we ever hit a case where we have a path but aren't handling it
        if navigation_path.size() > 0:
            print("[NAV DEBUG WARNING] Have path but no handling! index=%d, size=%d" % [current_path_index, navigation_path.size()])
    
    # IMPORTANT: Calculate direction and distance AFTER updating current_target
    var direction = current_target - global_position
    var distance = direction.length()
    
    # Only check for arrival at final destination when we're not following waypoints
    # or when we've passed all waypoints and are heading to the final target
    var heading_to_final_target = (navigation_path.size() == 0 or 
                                   current_path_index >= navigation_path.size())
    
    # When checking for final arrival, use distance to actual target_position, not current_target
    var distance_to_final = global_position.distance_to(target_position)
    
    if distance_to_final < 5 and heading_to_final_target:
        print("[NAV DEBUG] ARRIVAL: distance_to_final=%f, resetting navigation state" % distance_to_final)
        # We've reached the final destination
        global_position = target_position
        velocity = Vector2.ZERO
        is_moving = false
        # Clear navigation state BEFORE resetting index to prevent test from seeing intermediate state
        var had_path = navigation_path.size() > 0
        navigation_path = []
        if had_path:
            # Only reset index if we actually had a path
            print("[NAV DEBUG] Resetting path index from %d to 0" % current_path_index)
            current_path_index = 0
        _set_movement_state(MovementState.ARRIVED)
        # After a brief moment, return to IDLE
        yield(get_tree().create_timer(0.1), "timeout")
        if not is_moving:  # Still not moving
            _set_movement_state(MovementState.IDLE)
        return
    else:
        # DEBUG: Log why we didn't arrive
        if not heading_to_final_target:
            print("[NAV DEBUG] Not heading to final target yet (index=%d, size=%d)" % [current_path_index, navigation_path.size()])
        elif distance_to_final >= 5:
            print("[NAV DEBUG] Too far from final target: %f pixels" % distance_to_final)
    
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
    global_position += velocity * delta
    
    # Check if we're about to leave walkable area and correct if needed
    if current_district:
        global_position = _adjust_position_to_stay_in_bounds(global_position)

func _adjust_position_to_stay_in_bounds(pos):
    # This is a simple implementation that just checks the current position
    # A more advanced implementation would predict collisions before they happen
    if current_district and !current_district.is_position_walkable(pos):
        # Reset to previous position but DON'T stop movement entirely
        # The player should continue trying to reach their target via navigation
        print("[NAV DEBUG] Position %s not walkable, adjusting but continuing navigation" % pos)
        return global_position - velocity.normalized() * 5
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
    
    # Check if we're on the final segment of our path
    var is_final_segment = navigation_path.size() == 0 or (current_path_index >= navigation_path.size() - 1)
    
    if current_movement_state == MovementState.ACCELERATING:
        # Check if we've reached cruising speed
        if speed >= movement_speed * 0.95:
            _set_movement_state(MovementState.MOVING)
    elif current_movement_state == MovementState.MOVING:
        # Only decelerate if this is the final segment
        if is_final_segment:
            var stopping_distance = (speed * speed) / (2 * deceleration)
            if distance_to_target <= stopping_distance * 1.2:
                _set_movement_state(MovementState.DECELERATING)
    elif current_movement_state == MovementState.DECELERATING:
        # Check if we need to re-accelerate (e.g., overshot or new waypoint)
        var stopping_distance = (speed * speed) / (2 * deceleration)
        if distance_to_target > stopping_distance * 2.0:
            # We're too far from target to be decelerating, re-accelerate
            _set_movement_state(MovementState.ACCELERATING)

# Navigation2D support methods for testing
func request_navigation_path(target_pos):
    # Request a navigation path without starting movement
    if navigation_node:
        navigation_path = navigation_node.get_simple_path(global_position, target_pos)
        current_path_index = 0
        
        # Skip the first point if it's very close to current position
        if navigation_path.size() > 1 and global_position.distance_to(navigation_path[0]) < 5:
            current_path_index = 1

func has_navigation_path():
    return navigation_path.size() > 0

func get_navigation_path():
    return navigation_path

func get_current_path():
    return navigation_path

func has_path():
    return has_navigation_path()

func stop_movement():
    is_moving = false
    navigation_path = []
    current_path_index = 0
    _set_movement_state(MovementState.DECELERATING)

func get_state():
    match current_movement_state:
        MovementState.IDLE:
            return "IDLE"
        MovementState.ACCELERATING:
            return "ACCELERATING"
        MovementState.MOVING:
            return "MOVING"
        MovementState.DECELERATING:
            return "DECELERATING"
        MovementState.ARRIVED:
            return "ARRIVED"
    return "UNKNOWN"

func get_target_position():
    return target_position
