extends Node2D

func _ready():
    print("NPC System Test - Starting up")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create UI
    _create_ui()
    
    # Create player
    _create_player()
    
    # Create NPCs
    _create_npcs()
    
    # Create game manager
    var game_manager = load("res://src/core/game/game_manager.gd").new()
    game_manager.name = "GameManager"
    add_child(game_manager)
    
    print("NPC System Test - Ready")

func _create_ui():
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Verb UI
    var verb_ui = load("res://src/ui/verb_ui/verb_ui.gd").new()
    verb_ui.name = "VerbUI"
    verb_ui.rect_position = Vector2(20, 20)
    verb_ui.rect_size = Vector2(350, 160)
    canvas_layer.add_child(verb_ui)
    
    # Create Interaction Text
    var interaction_text = Label.new()
    interaction_text.name = "InteractionText"
    interaction_text.rect_position = Vector2(10, 570)
    interaction_text.rect_size = Vector2(1000, 20)
    interaction_text.text = "Select a verb and click on an NPC."
    canvas_layer.add_child(interaction_text)

func _create_player():
    var player = Node2D.new()
    player.name = "Player"
    player.add_to_group("player")
    
    # Add a visual representation for the player
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)  # Blue for player
    player.add_child(player_visual)
    
    # Add simple movement script
    player.set_script(GDScript.new())
    player.get_script().source_code = """
extends Node2D

export var movement_speed = 200
var target_position = Vector2()
var is_moving = false

func _ready():
    target_position = position
    
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
"""
    player.get_script().reload()
    
    # Set player position
    player.position = Vector2(512, 500)
    add_child(player)

func _create_npcs():
    # Create Concierge
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/base_npc.gd"))
    concierge.position = Vector2(300, 400)
    concierge.npc_name = "Concierge"
    concierge.description = "The concierge of the Barracks, dressed in a neat uniform."
    concierge.is_assimilated = false
    add_child(concierge)
    
    # Create Security Officer
    var security = Node2D.new()
    security.set_script(load("res://src/characters/npc/base_npc.gd"))
    security.position = Vector2(700, 400)
    security.npc_name = "Security Officer"
    security.description = "A stern-looking security officer in a uniform."
    security.is_assimilated = true
    add_child(security)
