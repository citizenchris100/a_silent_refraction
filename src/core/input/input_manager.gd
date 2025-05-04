extends Node

signal object_clicked(object, position)

var player
var current_district

func _ready():
    # Wait a frame to make sure all nodes are initialized
    yield(get_tree(), "idle_frame")
    
    # Find the player
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
    
    # Find the current district
    var districts = get_tree().get_nodes_in_group("district")
    if districts.size() > 0:
        current_district = districts[0]

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            _handle_click(event.position)

func _handle_click(position):
    # Check if clicking on an interactive object
    var interactive_objects = get_tree().get_nodes_in_group("interactive_object")
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
                return
    
    # If not clicking on an object, check if clicking in walkable area
    if current_district and player:
        if current_district.is_position_walkable(position):
            player.move_to(position)
