extends Node2D

func _ready():
    print("Integration Test Scene - Starting up")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create player
    var player = Node2D.new()
    player.name = "Player"
    player.add_to_group("player")
    
    # Add visual
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)  # Blue for player
    player.add_child(player_visual)
    
    # Add movement script
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
    
    # Create UI
    _create_ui()
    
    # Create NPCs
    _create_npcs()
    
    # Create managers
    _create_managers()

func _create_ui():
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Verb UI
    var verb_panel = Panel.new()
    verb_panel.rect_position = Vector2(10, 10)
    verb_panel.rect_size = Vector2(150, 180)
    canvas_layer.add_child(verb_panel)
    
    var verb_container = VBoxContainer.new()
    verb_container.name = "VerbUI"
    verb_container.rect_position = Vector2(10, 10)
    verb_container.rect_size = Vector2(130, 160)
    verb_panel.add_child(verb_container)
    
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

func _create_npcs():
    # Create Concierge
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/integration_concierge.gd"))
    concierge.position = Vector2(300, 400)
    add_child(concierge)
    
    # Create Security Officer
    var security = Node2D.new()
    security.set_script(load("res://src/characters/npc/integration_security.gd"))
    security.position = Vector2(700, 400)
    add_child(security)

func _create_managers():
    # Create game manager
    var game_manager = Node.new()
    game_manager.name = "GameManager"
    
    # Create simple game manager script
    game_manager.set_script(GDScript.new())
    game_manager.get_script().source_code = """
extends Node

# References
var interaction_text
var current_verb = "Look at"
var current_object = null
var dialog_manager

func _ready():
    print("Game Manager starting")
    
    # Find interaction text
    interaction_text = get_parent().get_node("UI/InteractionText")
    
    # Create dialog manager
    dialog_manager = load("res://src/core/dialog/integration_dialog_manager.gd").new()
    dialog_manager.name = "DialogManager"
    add_child(dialog_manager)

# Handle verb selection
func _on_verb_selected(verb):
    current_verb = verb
    if interaction_text:
        interaction_text.text = "Selected: " + verb + " (click on an NPC)"
    print("Selected verb: " + verb)

# Handle object clicks
func _on_object_clicked(object, position):
    current_object = object
    
    print("Clicked on object: " + object.name)
    
    # Show interaction result
    if object.has_method("interact"):
        var response = object.interact(current_verb)
        if interaction_text:
            interaction_text.text = response
    
    # Move player to object if needed
    var player = get_parent().get_node("Player")
    if player and current_verb != "Look at":
        player.move_to(position)
"""
    game_manager.get_script().reload()
    
    add_child(game_manager)

# Handle verb selection
func _on_verb_selected(verb):
    var game_manager = get_node("GameManager")
    if game_manager:
        game_manager._on_verb_selected(verb)
    
    print("Selected verb in main scene: " + verb)
