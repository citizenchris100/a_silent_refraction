extends Node2D

# Reference to managers
var game_manager
var input_manager

func _ready():
    print("A Silent Refraction - Starting up")
    
    # Create managers in the correct order
    _create_managers()
    
    # Load the shipping district
    var shipping_district = load("res://src/districts/shipping/shipping_district.tscn").instance()
    add_child(shipping_district)
    
    # Add the player character
    var player = load("res://src/characters/player/player.tscn").instance()
    add_child(player)
    player.position = Vector2(400, 300)  # Starting position
    
    # Add some NPCs for testing if they don't already exist
    _add_test_npcs()
    
    print("Main scene fully loaded - all systems integrated")

# Create all necessary managers
func _create_managers():
    # Create input manager first (needed by other systems)
    input_manager = load("res://src/core/input/input_manager.gd").new()
    input_manager.name = "InputManager"
    add_child(input_manager)
    
    # Create game manager
    game_manager = load("res://src/core/game/game_manager.gd").new()
    game_manager.name = "GameManager"
    add_child(game_manager)

# Add test NPCs if we need them for testing
func _add_test_npcs():
    # Only add NPCs if we don't already have any
    var existing_npcs = get_tree().get_nodes_in_group("npc")
    if existing_npcs.size() > 0:
        print("NPCs already exist in the scene, not adding test NPCs")
        return
    
    print("Adding test NPCs to the scene")
    
    # Try to load the Concierge NPC
    var concierge_script = load("res://src/characters/npc/concierge.gd")
    if concierge_script:
        var concierge = Node2D.new()
        concierge.set_script(concierge_script)
        concierge.name = "Concierge"
        concierge.position = Vector2(300, 350)
        add_child(concierge)
        print("Added Concierge NPC")
    
    # Try to load the Security Officer NPC
    var security_script = load("res://src/characters/npc/security_officer.gd")
    if security_script:
        var security = Node2D.new()
        security.set_script(security_script)
        security.name = "SecurityOfficer"
        security.position = Vector2(700, 350)
        add_child(security)
        print("Added Security Officer NPC")
