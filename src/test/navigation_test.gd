extends Node2D

func _ready():
    print("Navigation Test - Starting")
    
    # Create a background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create a district
    var district = Node2D.new()
    district.set_script(load("res://src/core/districts/base_district.gd"))
    district.district_name = "Test District"
    add_child(district)
    
    # Create a walkable area
    var walkable_area = Polygon2D.new()
    walkable_area.set_script(load("res://src/core/districts/walkable_area.gd"))
    walkable_area.polygon = PoolVector2Array([
        Vector2(100, 100),
        Vector2(900, 100),
        Vector2(900, 500),
        Vector2(100, 500)
    ])
    district.add_child(walkable_area)
    
    # Create a player
    var player = load("res://src/characters/player/player.tscn").instance()
    player.position = Vector2(500, 300)
    add_child(player)
    
    # Create input manager
    var input_manager = load("res://src/core/input/input_manager.gd").new()
    add_child(input_manager)
    
    # Add test objects
    _add_test_objects()
    
    # Add UI for instructions
    _add_test_ui()
    
    # Test walkable boundaries
    yield(get_tree(), "idle_frame")
    var test_results = district.test_walkable_boundaries()
    print("Walkable area test: " + str(test_results))

func _add_test_objects():
    # Add some test objects to click on
    var positions = [
        Vector2(200, 200),
        Vector2(400, 300),
        Vector2(700, 250)
    ]
    
    for i in range(positions.size()):
        var obj = load("res://src/objects/base/interactive_object.tscn").instance()
        obj.position = positions[i]
        obj.object_name = "Test Object " + str(i + 1)
        add_child(obj)

func _add_test_ui():
    var canvas_layer = CanvasLayer.new()
    add_child(canvas_layer)
    
    var instructions = Label.new()
    instructions.text = "Navigation Test\n" + \
                       "- Click to move the player\n" + \
                       "- Player will only move within the green area\n" + \
                       "- Click on objects to interact"
    instructions.rect_position = Vector2(20, 20)
    canvas_layer.add_child(instructions)
