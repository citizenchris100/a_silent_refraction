extends Node

# Reference to the player node
var player

func _ready():
    # Wait a moment to ensure the player node exists in the tree
    yield(get_tree().create_timer(0.5), "timeout")
    player = get_tree().get_nodes_in_group("player")[0]

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            # Move player to clicked position
            if player:
                player.move_to(get_global_mouse_position())
