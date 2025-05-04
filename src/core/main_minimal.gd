extends Node2D

func _ready():
    print("A Silent Refraction - Starting up (Minimal Version)")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create a simple player
    var player = Node2D.new()
    player.set_name("Player")
    
    # Add a visual representation for the player
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)
    player.add_child(player_visual)
    
    # Set player position
    player.position = Vector2(400, 300)
    add_child(player)
    
    # Create a walkable area
    var walkable_area = Polygon2D.new()
    walkable_area.set_name("WalkableArea")
    walkable_area.polygon = PoolVector2Array([
        Vector2(100, 300),
        Vector2(900, 300),
        Vector2(900, 550),
        Vector2(100, 550)
    ])
    walkable_area.color = Color(0.15, 0.15, 0.25)
    add_child(walkable_area)
    
    # Add a label
    var label = Label.new()
    label.text = "Shipping District"
    label.rect_position = Vector2(20, 20)
    add_child(label)
    
    # Set up movement
    set_process_input(true)
    
func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            var player = get_node("Player")
            player.position = event.position
