extends Node2D

# Main game controller

func _ready():
    print("Game initialized")
    
    # Add the player controller
    var player_controller = load("res://src/core/player_controller.gd").new()
    add_child(player_controller)
