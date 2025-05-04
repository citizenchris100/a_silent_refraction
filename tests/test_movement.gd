extends Node
# Save this as res://tests/test_movement.gd

func _ready():
    print("Starting movement test")
    
    # Set test mode to true to skip main menu
    if Engine.has_singleton("escoria"):
        escoria.globals_manager.set_global("test_mode", true)
        
        # Load the start room
        escoria.change_scene("res://game/rooms/start/start.tscn")
        escoria.connect("room_ready", _on_room_ready)
    else:
        print("Escoria framework not detected")

func _on_room_ready():
    print("Room loaded, player should be visible")
    
    # Create a simple walk area for testing
    _create_test_walk_area()
    
    # Setup input handling for movement testing
    set_process_input(true)

func _create_test_walk_area():
    # This would create a temporary walkable area for testing
    # In Escoria, this would typically be defined in the room scene
    var walkable_area = Area2D.new()
    walkable_area.name = "walkable_area"
    
    var collision_shape = CollisionPolygon2D.new()
    collision_shape.polygon = PackedVector2Array([
        Vector2(100, 700),
        Vector2(1820, 700),
        Vector2(1820, 900),
        Vector2(100, 900)
    ])
    
    walkable_area.add_child(collision_shape)
    add_child(walkable_area)
    
    # Register with Escoria (depends on Escoria's API)
    # This is a simplified example - the actual implementation depends on how
    # Escoria handles walkable areas

func _input(event):
    # Handle mouse clicks for movement testing
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if Engine.has_singleton("escoria"):
            # Use Escoria's command system to move the player
            escoria.do("walk", ["player", str(event.position.x), str(event.position.y)])
            print("Moving player to: " + str(event.position))
