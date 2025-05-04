extends Node2D

export var movement_speed = 200
var target_position = Vector2()
var is_moving = false

func _ready():
    target_position = position
    # Add to player group
    add_to_group("player")

func move_to(position):
    target_position = position
    is_moving = true

func _process(delta):
    if is_moving:
        var direction = target_position - position
        if direction.length() > 5:  # If not very close yet
            position += direction.normalized() * movement_speed * delta
        else:
            # Reached the target
            position = target_position
            is_moving = false
