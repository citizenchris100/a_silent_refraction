extends Node2D

var game_manager

func _ready():
    print("FIXED TEST 2 STARTING")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create UI
    _create_ui()
    
    # Create player
    _create_player()
    
    # Create NPCs with the fixed implementation
    _create_npcs()
    
    # Create game manager with the fixed implementation
    game_manager = load("res://src/core/game/game_manager_fixed2.gd").new()
    game_manager.name = "GameManager"
    add_child(game_manager)
    
    print("FIXED TEST 2 SETUP COMPLETE")

func _create_ui():
    print("Creating UI...")
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
    
    print("UI created")

func _create_player():
    print("Creating player...")
    var player = Node2D.new()
    player.name = "Player"
    player.add_to_group("player")
    
    # Add a visual representation for the player
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)  # Blue for player
    player.add_child(player_visual)
    
    # Add proper movement script
    var script = GDScript.new()
    script.source_code = """
extends Node2D

export var movement_speed = 200
var target_position = Vector2()
var is_moving = false

func _ready():
    target_position = position
    print("Player ready with movement script")
    
func move_to(position):
    print("Player move_to called with: " + str(position))
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
    script.reload()
    player.set_script(script)
    
    # Set player position
    player.position = Vector2(512, 500)
    add_child(player)
    
    print("Player created with movement script")

func _create_npcs():
    print("Creating NPCs with fixed implementation...")
    # Create Concierge
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/base_npc_fixed2.gd"))
    concierge.position = Vector2(300, 400)
    concierge.npc_name = "Concierge"
    concierge.description = "The concierge of the Barracks, dressed in a neat uniform."
    concierge.is_assimilated = false
    add_child(concierge)
    
    # Set color after adding to scene
    yield(get_tree(), "idle_frame")
    if concierge.has_node("Visual") and concierge.get_node("Visual") is ColorRect:
        concierge.get_node("Visual").color = Color(0.2, 0.8, 0.2)  # Green
    
    # Create Security Officer
    var security = Node2D.new()
    security.set_script(load("res://src/characters/npc/base_npc_fixed2.gd"))
    security.position = Vector2(700, 400)
    security.npc_name = "Security Officer"
    security.description = "A stern-looking security officer in a uniform."
    security.is_assimilated = true
    add_child(security)
    
    # Set color after adding to scene
    yield(get_tree(), "idle_frame")
    if security.has_node("Visual") and security.get_node("Visual") is ColorRect:
        security.get_node("Visual").color = Color(0.8, 0.2, 0.2)  # Red
    
    print("NPCs created with fixed implementation")

# Handle verb selection
func _on_verb_selected(verb):
    print("Main scene: verb selected: " + verb)
    if game_manager:
        game_manager._on_verb_selected(verb)
    else:
        print("No game manager found!")
