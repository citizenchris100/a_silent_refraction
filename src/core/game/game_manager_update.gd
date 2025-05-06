extends "res://src/core/game/game_manager.gd"

var dialog_manager

func _ready():
    print("Game Manager initializing...")
    
    # Create input manager
    input_manager = load("res://src/core/input/input_manager.gd").new()
    add_child(input_manager)
    input_manager.connect("object_clicked", self, "_on_object_clicked")
    
    # Create dialog manager
    dialog_manager = load("res://src/core/dialog/dialog_manager.gd").new()
    add_child(dialog_manager)
    
    # Wait a frame to make sure nodes are ready
    yield(get_tree(), "idle_frame")
    
    # Find the verb UI and interaction text
    if get_parent().has_node("UI/VerbUI"):
        verb_ui = get_parent().get_node("UI/VerbUI")
        verb_ui.connect("verb_selected", self, "_on_verb_selected")
    else:
        print("VerbUI not found")
    
    if get_parent().has_node("UI/InteractionText"):
        interaction_text = get_parent().get_node("UI/InteractionText")
    else:
        print("InteractionText not found")
    
    # Find player and district
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
    else:
        print("Player not found")
    
    var districts = get_tree().get_nodes_in_group("district")
    if districts.size() > 0:
        current_district = districts[0]
    else:
        print("District not found")
    
    print("Game Manager initialized")
