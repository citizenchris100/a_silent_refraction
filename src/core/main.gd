extends Node2D

# Reference to managers
var game_manager
var input_manager
var suspicion_manager

func _ready():
	print("A Silent Refraction - Starting up")
	
	# Create managers in the correct order
	call_deferred("_create_managers")
	
	# Load the shipping district
	var shipping_district = load("res://src/districts/shipping/shipping_district.tscn").instance()
	add_child(shipping_district)
	
	# Add the player character
	var player = load("res://src/characters/player/player.tscn").instance()
	add_child(player)
	player.position = Vector2(500, 700)  # Starting position within the walkable area
	
	# Add some NPCs for testing if they don't already exist
	_add_test_npcs()
	
	# Main initialization completed
	print("Main scene loaded")

# Create all necessary managers
func _create_managers():
	# Check if managers already exist
	if has_node("InputManager") and has_node("SuspicionManager") and has_node("GameManager"):
		return
	
	# Create input manager first (needed by other systems)
	if not has_node("InputManager"):
		var input_manager_script = load("res://src/core/input/input_manager.gd")
		input_manager = input_manager_script.new()
		input_manager.name = "InputManager"
		add_child(input_manager)
	
	# Create suspicion manager
	if not has_node("SuspicionManager"):
		var suspicion_manager_script = load("res://src/core/suspicion/suspicion_manager.gd")
		suspicion_manager = suspicion_manager_script.new()
		suspicion_manager.name = "SuspicionManager"
		add_child(suspicion_manager)
	
	# Create game manager
	if not has_node("GameManager"):
		var game_manager_script = load("res://src/core/game/game_manager.gd")
		game_manager = game_manager_script.new()
		game_manager.name = "GameManager"
		add_child(game_manager)
	
	# Add global suspicion meter to UI
	call_deferred("_add_global_suspicion_meter")
	
	print("Managers created")

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
		concierge.position = Vector2(300, 700)  # Updated position to be in the walkable area
		add_child(concierge)
		print("Added Concierge NPC")
	
	# Try to load the Security Officer NPC
	var security_script = load("res://src/characters/npc/security_officer.gd")
	if security_script:
		var security = Node2D.new()
		security.set_script(security_script)
		security.name = "SecurityOfficer"
		security.position = Vector2(700, 700)  # Updated position to be in the walkable area
		add_child(security)
		print("Added Security Officer NPC")

# Add the global suspicion meter to UI
func _add_global_suspicion_meter():
	# Make sure UI layer exists
	var ui_layer = null
	if has_node("UI"):
		ui_layer = get_node("UI")
	else:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "UI"
		add_child(ui_layer)
	
	# Add global suspicion meter
	var global_meter_scene = load("res://src/ui/suspicion_meter/global_suspicion_meter.tscn")
	if global_meter_scene:
		var global_meter = global_meter_scene.instance()
		ui_layer.add_child(global_meter)
		print("Added global suspicion meter")