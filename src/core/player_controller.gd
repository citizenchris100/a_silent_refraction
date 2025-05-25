extends Node

# Reference to the player node
var player

# This script connects player movement to input events
func _ready():
    # Wait for the scene to be ready
    yield(get_tree(), "idle_frame")
    
    # Find the player node
    player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
    
    if not player:
        push_error("Player node not found!")
        return
    
    print("Player controller initialized")

func _input(event):
    if not player:
        return
        
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            # Convert screen coordinates to world coordinates using CoordinateManager
            var world_pos = CoordinateManager.screen_to_world(event.position)
            
            # Command player to move to the world position
            player.move_to(world_pos)
            print("Player moving to: ", world_pos)
