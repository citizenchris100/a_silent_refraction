extends Node2D

func _ready():
    print("Dialog Test - Starting")
    
    # Create a background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create managers
    var game_manager = load("res://src/core/game/game_manager.gd").new()
    game_manager.name = "GameManager"
    add_child(game_manager)
    
    var input_manager = load("res://src/core/input/input_manager.gd").new()
    input_manager.name = "InputManager"
    add_child(input_manager)
    
    # Create UI
    _create_ui()
    
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
    
    # Create NPCs
    _create_npcs()

func _create_ui():
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create verb UI
    var verb_ui_scene = load("res://src/ui/verb_ui/verb_ui.tscn")
    if verb_ui_scene:
        var verb_ui = verb_ui_scene.instance()
        verb_ui.name = "VerbUI"
        verb_ui.anchor_top = 1.0
        verb_ui.anchor_bottom = 1.0
        verb_ui.margin_top = -120.0
        canvas_layer.add_child(verb_ui)
    
    # Create interaction text
    var interaction_text = Label.new()
    interaction_text.name = "InteractionText"
    interaction_text.text = "Dialog Test: Select 'Talk to' verb and click on an NPC."
    interaction_text.rect_position = Vector2(20, 20)
    interaction_text.rect_size = Vector2(600, 60)
    canvas_layer.add_child(interaction_text)
    
    # Create instructions
    var instructions = Label.new()
    instructions.text = "Dialog Test\n" + \
                        "- Select 'Talk to' verb\n" + \
                        "- Click on an NPC to start dialog\n" + \
                        "- Select dialog options\n" + \
                        "- Test different NPCs for different dialogs"
    instructions.rect_position = Vector2(20, 80)
    canvas_layer.add_child(instructions)

func _create_npcs():
    # Try to load the Concierge NPC
    var concierge_script = load("res://src/characters/npc/concierge.gd")
    if concierge_script:
        var concierge = Node2D.new()
        concierge.set_script(concierge_script)
        concierge.name = "Concierge"
        concierge.position = Vector2(300, 300)
        add_child(concierge)
        print("Added Concierge NPC")
    
    # Try to load the Security Officer NPC
    var security_script = load("res://src/characters/npc/security_officer.gd")
    if security_script:
        var security = Node2D.new()
        security.set_script(security_script)
        security.name = "SecurityOfficer"
        security.position = Vector2(700, 300)
        add_child(security)
        print("Added Security Officer NPC")
    
    # If we don't have specific NPCs, create generic ones
    if get_tree().get_nodes_in_group("npc").size() == 0:
        print("No specific NPCs found, creating generic ones")
        var base_npc_script = load("res://src/characters/npc/base_npc.gd")
        if base_npc_script:
            # Create Friendly NPC
            var friendly_npc = Node2D.new()
            friendly_npc.set_script(base_npc_script)
            friendly_npc.name = "FriendlyNPC"
            friendly_npc.position = Vector2(300, 300)
            add_child(friendly_npc)
            
            # Create Suspicious NPC
            var suspicious_npc = Node2D.new()
            suspicious_npc.set_script(base_npc_script)
            suspicious_npc.name = "SuspiciousNPC" 
            suspicious_npc.position = Vector2(700, 300)
            add_child(suspicious_npc)
            
            print("Created 2 generic NPCs for testing")
