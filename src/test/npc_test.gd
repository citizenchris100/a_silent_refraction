extends Node2D

func _ready():
    print("NPC Test Scene - Starting up")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create a simple player
    var player = Node2D.new()
    player.set_name("Player")
    player.add_to_group("player")
    
    # Add a visual representation for the player
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)  # Blue for player
    player.add_child(player_visual)
    
    # Add movement capability to player
    var player_script = load("res://src/characters/player/player.gd")
    player.set_script(player_script)
    
    # Set player position
    player.position = Vector2(512, 500)
    add_child(player)
    
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Verb UI
    var verb_ui = Control.new()
    verb_ui.name = "VerbUI"
    verb_ui.set_script(load("res://src/ui/verb_ui/verb_ui.gd"))
    canvas_layer.add_child(verb_ui)
    
    # Create Interaction Text
    var interaction_text = Label.new()
    interaction_text.name = "InteractionText"
    interaction_text.rect_position = Vector2(20, 500)
    interaction_text.rect_size = Vector2(984, 30)
    interaction_text.text = "Click on an NPC to interact."
    canvas_layer.add_child(interaction_text)
    
    # Create Dialog UI
    var dialog_ui = Control.new()
    dialog_ui.name = "DialogUI"
    dialog_ui.set_script(load("res://src/ui/dialog/dialog_ui.gd"))
    canvas_layer.add_child(dialog_ui)
    
    # Create NPCs
    _create_npcs()
    
    # Create game manager
    var game_manager = Node.new()
    game_manager.name = "GameManager"
    game_manager.set_script(load("res://src/core/game/game_manager.gd"))
    add_child(game_manager)

# Create NPCs for testing
func _create_npcs():
    # Create Concierge
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/concierge.gd"))
    concierge.position = Vector2(200, 400)
    
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
    
    add_child(concierge)
    
    # Create Bank Teller
    var bank_teller = Node2D.new()
    bank_teller.set_script(load("res://src/characters/npc/bank_teller.gd"))
    bank_teller.position = Vector2(400, 400)
    
    # Add visual for bank teller
    var teller_visual = ColorRect.new()
    teller_visual.rect_size = Vector2(32, 48)
    teller_visual.rect_position = Vector2(-16, -48)
    teller_visual.color = Color(0.8, 0.8, 0.2)  # Yellow for bank teller
    bank_teller.add_child(teller_visual)
    
    # Add label for bank teller
    var teller_label = Label.new()
    teller_label.text = "Bank Teller"
    teller_label.rect_position = Vector2(-35, -60)
    bank_teller.add_child(teller_label)
    
    add_child(bank_teller)
    
    # Create Security Officer
    var security_officer = Node2D.new()
    security_officer.set_script(load("res://src/characters/npc/security_officer.gd"))
    security_officer.position = Vector2(600, 400)
    
    # Add visual for security officer
    var officer_visual = ColorRect.new()
    officer_visual.rect_size = Vector2(32, 48)
    officer_visual.rect_position = Vector2(-16, -48)
    officer_visual.color = Color(0.8, 0.2, 0.2)  # Red for security
    security_officer.add_child(officer_visual)
    
    # Add label for security officer
    var officer_label = Label.new()
    officer_label.text = "Security Officer"
    officer_label.rect_position = Vector2(-40, -60)
    security_officer.add_child(officer_label)
    
    add_child(security_officer)
