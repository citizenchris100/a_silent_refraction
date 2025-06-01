extends Node

signal object_clicked(object, position)
signal click_detected(position, screen_position)

var player
var current_district
var block_clicks_until = 0  # Time until which clicks should be blocked
var click_feedback_system = null
var click_priority_system = null

# Click validation constants
const MIN_SCREEN_X = 0
const MIN_SCREEN_Y = 0

func _ready():
    # Add to input_manager group for easy finding
    add_to_group("input_manager")
    
    # Wait a frame to make sure all nodes are initialized
    yield(get_tree(), "idle_frame")
    
    # Find the player
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
    else:
        push_error("No player found in the scene!")
    
    # Find the current district
    var districts = get_tree().get_nodes_in_group("district")
    if districts.size() > 0:
        current_district = districts[0]
    else:
        push_error("No district found in the scene!")
    
    # Initialize click systems
    _initialize_click_systems()

func _process(delta):
    # Update the click block timer
    if block_clicks_until > 0 and OS.get_ticks_msec() > block_clicks_until:
        block_clicks_until = 0

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            # Skip processing if clicks are blocked
            if block_clicks_until > 0 and OS.get_ticks_msec() < block_clicks_until:
                return

            # Skip processing if the click was on a UI element
            if _is_click_on_ui(event.position):
                return

            # Skip clicks while player is in dialog - use explicit flag
            var dialog_manager = _find_dialog_manager()
            if dialog_manager and dialog_manager.dialog_panel and dialog_manager.dialog_panel.visible:
                return  # IMPORTANT: Return immediately if dialog is active

            # Only process clicks if no dialog is active
            _handle_click(event.position)
            # Emit click_detected signal for other systems
            emit_signal("click_detected", event.position, event.position)

# Check if a point is on a UI element
func _is_click_on_ui(position):
    # Get the UI CanvasLayer
    var ui_layer = _find_ui_layer()
    if not ui_layer:
        return false
    
    # Check all controls in the UI layer
    for control in _get_all_controls(ui_layer):
        if _is_point_in_control(control, position):
            return true
    
    return false

# Find the UI CanvasLayer
func _find_ui_layer():
    var root = get_tree().get_root()
    for node in root.get_children():
        if node.has_node("UI"):
            return node.get_node("UI")
    return null

# Find dialog manager in scene tree
func _find_dialog_manager():
    var root = get_tree().get_root()
    for child in root.get_children():
        for grandchild in child.get_children():
            if grandchild.get_class() == "Node" and grandchild.get_script() and grandchild.get_script().get_path().ends_with("dialog_manager.gd"):
                return grandchild
    return null

# Block clicks for a specified duration in milliseconds
func block_clicks(duration_ms):
    block_clicks_until = OS.get_ticks_msec() + duration_ms

# Get all Control nodes in a parent
func _get_all_controls(parent):
    var controls = []
    for child in parent.get_children():
        if child is Control:
            controls.append(child)
        
        # Also include all nested controls
        if child.get_child_count() > 0:
            controls += _get_all_controls(child)
    
    return controls

# Check if a point is within a Control node
func _is_point_in_control(control, point):
    # Skip invisible controls
    if not control.visible:
        return false
    
    # Convert point to control's coordinate system
    var local_point = control.get_global_transform().affine_inverse().xform(point)
    
    # Check if point is inside control's rect
    return Rect2(Vector2(), control.rect_size).has_point(local_point)

func _handle_click(screen_position):
    # Validate click position first
    if not validate_click_position(screen_position):
        if click_feedback_system:
            click_feedback_system.show_click_feedback(screen_position, click_feedback_system.FeedbackType.INVALID)
        return
    
    # Convert to world coordinates with tolerance
    var world_position = _screen_to_world_with_tolerance(screen_position)
    
    # Use priority system if available
    if click_priority_system:
        click_priority_system.process_click({
            "screen_position": screen_position,
            "world_position": world_position,
            "player": player,
            "district": current_district
        })
    else:
        # Fallback to original behavior
        _handle_click_legacy(world_position, screen_position)

func _handle_click_legacy(world_position, screen_position):
    # Check if clicking on an interactive object
    var interactive_objects = get_tree().get_nodes_in_group("interactive_object")
    var clicked_on_object = false
    
    for obj in interactive_objects:
        # Simple rectangular hit detection, can be improved
        if obj.get_node_or_null("Sprite") != null:
            var sprite = obj.get_node("Sprite")
            var rect = Rect2(
                obj.global_position + sprite.rect_position,
                sprite.rect_size
            )
            if rect.has_point(world_position):
                emit_signal("object_clicked", obj, world_position)
                clicked_on_object = true
                if click_feedback_system:
                    click_feedback_system.show_click_feedback(world_position, click_feedback_system.FeedbackType.VALID)
                break
    
    # If not clicking on an object, check if clicking in walkable area
    if not clicked_on_object and current_district:
        if current_district.is_position_walkable(world_position):
            # Emit object_clicked with null object for movement
            emit_signal("object_clicked", null, world_position)
            if click_feedback_system:
                click_feedback_system.show_click_feedback(world_position, click_feedback_system.FeedbackType.VALID)
        else:
            print("Clicked outside walkable area")
            # Find closest valid point
            var adjusted_position = _find_closest_valid_point(world_position)
            if adjusted_position:
                # Emit object_clicked with null object for adjusted movement
                emit_signal("object_clicked", null, adjusted_position)
                if click_feedback_system:
                    click_feedback_system.show_adjusted_click_feedback(world_position, adjusted_position)
            else:
                if click_feedback_system:
                    click_feedback_system.show_click_feedback(world_position, click_feedback_system.FeedbackType.INVALID)

# ===== NEW CLICK VALIDATION METHODS =====

func _initialize_click_systems():
    """Initialize click feedback and priority systems"""
    # Check if systems exist and instantiate them
    if ResourceLoader.exists("res://src/ui/click_feedback/click_feedback_system.gd"):
        var ClickFeedbackSystem = load("res://src/ui/click_feedback/click_feedback_system.gd")
        click_feedback_system = ClickFeedbackSystem.new()
        get_parent().add_child(click_feedback_system)
    
    if ResourceLoader.exists("res://src/core/input/click_priority_system.gd"):
        var ClickPrioritySystem = load("res://src/core/input/click_priority_system.gd")
        click_priority_system = ClickPrioritySystem.new()
        get_parent().add_child(click_priority_system)
        # Connect priority system signals
        if click_priority_system.has_signal("click_processed"):
            click_priority_system.connect("click_processed", self, "_on_priority_click_processed")

func validate_click_position(screen_position: Vector2) -> bool:
    """Validate that a click position is within valid screen bounds"""
    var viewport_size = get_viewport().size
    
    # Check basic bounds
    if screen_position.x < MIN_SCREEN_X or screen_position.y < MIN_SCREEN_Y:
        return false
    if screen_position.x > viewport_size.x or screen_position.y > viewport_size.y:
        return false
    
    # Check for NaN or infinity
    if is_nan(screen_position.x) or is_nan(screen_position.y):
        return false
    if is_inf(screen_position.x) or is_inf(screen_position.y):
        return false
    
    return true

func is_click_on_ui(position: Vector2) -> bool:
    """Public method matching the mock's interface"""
    return _is_click_on_ui(position)

func should_block_click_for_dialog() -> bool:
    """Check if clicks should be blocked due to dialog"""
    var dialog_manager = _find_dialog_manager()
    return dialog_manager and dialog_manager.dialog_panel and dialog_manager.dialog_panel.visible

func is_click_blocked() -> bool:
    """Check if clicks are currently blocked"""
    return block_clicks_until > 0 and OS.get_ticks_msec() < block_clicks_until

func _screen_to_world_with_tolerance(screen_position: Vector2) -> Vector2:
    """Convert screen position to world position with click tolerance"""
    # Get base world position
    var world_position = CoordinateManager.screen_to_world(screen_position)
    
    # Apply tolerance if available
    if has_method("apply_click_tolerance"):
        world_position = apply_click_tolerance(world_position, screen_position)
    
    return world_position

func apply_click_tolerance(world_position: Vector2, screen_position: Vector2) -> Vector2:
    """Apply click tolerance for easier interaction"""
    # Base tolerance value
    var base_tolerance = 10.0
    
    # Adjust tolerance based on zoom if camera exists
    # Note: get_camera_2d() doesn't exist in Godot 3.5.2, use camera group instead
    var cameras = get_tree().get_nodes_in_group("camera")
    if cameras.size() > 0:
        var camera = cameras[0]
        if camera and camera.has_method("get_zoom"):
            var zoom = camera.get_zoom()
            # Inverse relationship - higher zoom means smaller tolerance
            base_tolerance = base_tolerance / zoom.x
    
    # Clamp tolerance to reasonable bounds
    base_tolerance = clamp(base_tolerance, 5.0, 20.0)
    
    # For now, just return the original position
    # In a full implementation, we'd search for valid targets within tolerance
    return world_position

func adjust_for_perspective(world_position: Vector2, perspective_type: String = "default") -> Vector2:
    """Adjust click position based on perspective type"""
    # This would be implemented based on the perspective system
    # For now, just return the original position
    return world_position

func _find_closest_valid_point(invalid_position: Vector2) -> Vector2:
    """Find the closest valid walkable point to an invalid click"""
    if not current_district:
        return invalid_position
    
    # Simple implementation - could be optimized
    var search_radius = 50.0
    var search_steps = 16
    var angle_step = TAU / search_steps
    
    # Search in expanding circles
    for radius in range(10, int(search_radius) + 1, 10):
        for i in range(search_steps):
            var angle = i * angle_step
            var test_pos = invalid_position + Vector2(cos(angle), sin(angle)) * radius
            if current_district.is_position_walkable(test_pos):
                return test_pos
    
    return invalid_position

func _on_priority_click_processed(click_data):
    """Handle processed clicks from priority system"""
    if click_data.has("handled") and click_data.handled:
        # Priority system handled it
        if click_data.has("action"):
            if click_data.action == "object_interaction":
                emit_signal("object_clicked", click_data.object, click_data.position)
            elif click_data.action == "movement":
                # Use adjusted position if available, otherwise use original position
                var move_position = click_data.get("adjusted_position", click_data.get("position", click_data.get("world_position")))
                emit_signal("object_clicked", null, move_position)
    else:
        # Not handled by priority system, use legacy handling
        _handle_click_legacy(click_data.world_position, click_data.screen_position)