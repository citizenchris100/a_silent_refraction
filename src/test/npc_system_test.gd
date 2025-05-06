extends Node2D

func _ready():
    print("NPC System Integration Test - Starting")
    
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
    
    print("NPC System Integration Test - Ready")

func _create_ui():
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Verb UI
    var verb_container = VBoxContainer.new()
    verb_container.name = "VerbUI"
    verb_container.rect_position = Vector2(20, 20)
    verb_container.rect_size = Vector2(130, 160)
    canvas_layer.add_child(verb_container)
    
    # Add verb buttons
    var verbs = ["Look at", "Talk to", "Use", "Pick up"]
    for verb in verbs:
        var button = Button.new()
        button.text = verb
        button.connect("pressed", self, "_on_verb_selected", [verb])
        verb_container.add_child(button)
    
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
    var concierge = load("res://src/characters/npc/concierge.gd").new()
    concierge.position = Vector2(300, 400)
    add_child(concierge)
    
    # Create Security Officer
    var security = load("res://src/characters/npc/security_officer.gd").new()
    security.position = Vector2(700, 400)
    add_child(security)

# Handle verb selection
func _on_verb_selected(verb):
    var game_manager = get_node("GameManager")
    if game_manager:
        game_manager._on_verb_selected(verb)
