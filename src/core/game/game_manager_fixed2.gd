extends Node

# References
var verb_ui
var input_manager
var current_district
var player
var interaction_text
var dialog_manager

# Current interaction state
var current_verb = "Look at"
var current_object = null

func _ready():
    print("Game Manager initializing...")
    
    # Create dialog manager
    dialog_manager = load("res://src/core/dialog/dialog_manager_debug.gd").new()
    dialog_manager.name = "DialogManager"
    add_child(dialog_manager)
    
    # Wait a frame to make sure nodes are ready
    yield(get_tree(), "idle_frame")
    
    # Find the verb UI and interaction text
    if get_parent().has_node("UI/VerbUI"):
        verb_ui = get_parent().get_node("UI/VerbUI")
        verb_ui.connect("verb_selected", self, "_on_verb_selected")
        print("Found VerbUI and connected signal")
    else:
        print("VerbUI not found")
    
    if get_parent().has_node("UI/InteractionText"):
        interaction_text = get_parent().get_node("UI/InteractionText")
        print("Found InteractionText")
    else:
        print("InteractionText not found")
    
    # Find player and district
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
        print("Found player: " + player.name)
    else:
        print("Player not found")
    
    var districts = get_tree().get_nodes_in_group("district")
    if districts.size() > 0:
        current_district = districts[0]
        print("Found district: " + current_district.name)
    else:
        print("District not found")
    
    print("Game Manager initialized")

# Handle verb selection
func _on_verb_selected(verb):
    current_verb = verb
    print("Selected verb: " + verb)
    if interaction_text:
        interaction_text.text = current_verb + "..."
    print("Verb selected: " + verb)

# Handle NPC clicks
func handle_npc_click(npc):
    print("Game Manager: handle_npc_click called for " + npc.npc_name)
    current_object = npc
    
    print("Interacting with: " + npc.npc_name + " using verb: " + current_verb)
    
    # Show interaction result
    if npc.has_method("interact"):
        var response = npc.interact(current_verb)
        print("Interaction response: " + response)
        if interaction_text:
            interaction_text.text = response
    else:
        print("NPC doesn't have interact method!")
    
    # Move player to npc if needed
    if player and current_verb != "Look at":
        var target_pos = npc.global_position
        print("Moving player to: " + str(target_pos))
        
        # Check if player has move_to method
        if player.has_method("move_to"):
            player.move_to(target_pos)
        else:
            print("Player doesn't have move_to method!")
