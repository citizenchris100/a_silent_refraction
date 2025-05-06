extends Node2D

func _ready():
    print("NPC Fixed Test Scene - Starting up")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Verb UI
    var verb_container = VBoxContainer.new()
    verb_container.name = "VerbUI"
    verb_container.rect_position = Vector2(20, 20)
    verb_container.rect_size = Vector2(150, 180)
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
    interaction_text.rect_position = Vector2(20, 570)
    interaction_text.rect_size = Vector2(984, 30)
    interaction_text.text = "Click on an NPC to interact."
    canvas_layer.add_child(interaction_text)
    
    # Create NPCs
    _create_npcs()
    
    # Create player (needed for movement)
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
    
    # Create game manager
    var game_manager = Node.new()
    game_manager.name = "GameManager"
    game_manager.set_script(load("res://src/core/game/game_manager_fixed.gd"))
    add_child(game_manager)

# Create NPCs
func _create_npcs():
    # Create Concierge NPC
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/base_npc_fixed.gd"))
    concierge.position = Vector2(300, 400)
    
    # Add visual for concierge
    var concierge_visual = ColorRect.new()
    concierge_visual.rect_size = Vector2(32, 48)
    concierge_visual.rect_position = Vector2(-16, -48)
    concierge_visual.color = Color(0.2, 0.8, 0.2)  # Green for concierge
    concierge.add_child(concierge_visual)
    
    # Add label for concierge
    var concierge_label = Label.new()
    concierge_label.text = "Concierge"
    concierge_label.rect_position = Vector2(-30, -60)
    concierge.add_child(concierge_label)
    
    # Set properties
    concierge.npc_name = "Concierge"
    concierge.description = "The concierge of the Barracks, dressed in a neat uniform."
    
    add_child(concierge)
    
    # Create Security Officer
    var officer = Node2D.new()
    officer.set_script(load("res://src/characters/npc/base_npc_fixed.gd"))
    officer.position = Vector2(700, 400)
    
    # Add visual for security officer
    var officer_visual = ColorRect.new()
    officer_visual.rect_size = Vector2(32, 48)
    officer_visual.rect_position = Vector2(-16, -48)
    officer_visual.color = Color(0.8, 0.2, 0.2)  # Red for security
    officer.add_child(officer_visual)
    
    # Add label for security officer
    var officer_label = Label.new()
    officer_label.text = "Security Officer"
    officer_label.rect_position = Vector2(-40, -60)
    officer.add_child(officer_label)
    
    # Set properties
    officer.npc_name = "Security Officer"
    officer.description = "A stern-looking security officer in a uniform."
    officer.is_assimilated = true
    
    add_child(officer)

# Handle verb selection
func _on_verb_selected(verb):
    # Find the game manager
    var game_manager = get_node("GameManager")
    if game_manager:
        game_manager._on_verb_selected(verb)
