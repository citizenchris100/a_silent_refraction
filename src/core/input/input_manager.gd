extends Node

signal object_clicked(object, position)

var player
var current_district
var block_clicks_until = 0  # Time until which clicks should be blocked

func _ready():
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

            # Skip clicks while player is in dialog
            var dialog_active = false
            var dialog_manager = _find_dialog_manager()
            if dialog_manager and dialog_manager.dialog_panel and dialog_manager.dialog_panel.visible:
                dialog_active = true

            if not dialog_active:
                _handle_click(event.position)

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

func _handle_click(position):
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
            if rect.has_point(position):
                emit_signal("object_clicked", obj, position)
                clicked_on_object = true
                break
    
    # If not clicking on an object, check if clicking in walkable area
    if not clicked_on_object and current_district and player:
        if current_district.is_position_walkable(position):
            player.move_to(position)
        else:
            print("Clicked outside walkable area")
