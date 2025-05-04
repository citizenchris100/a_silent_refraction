extends Node

# References to game systems
var verb_ui
var input_manager
var current_district
var player
var interaction_text

# Current interaction state
var current_verb = "Look at"
var current_object = null

func _ready():
    print("Game Manager initializing...")
    
    # Create input manager
    input_manager = load("res://src/core/input/input_manager.gd").new()
    add_child(input_manager)
    input_manager.connect("object_clicked", self, "_on_object_clicked")
    
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

# Handle verb selection
func _on_verb_selected(verb):
    current_verb = verb
    update_interaction_text()

# Handle object clicks
func _on_object_clicked(object, _position):
    current_object = object
    
    # Show interaction result
    if object.has_method("interact"):
        var response = object.interact(current_verb)
        if interaction_text:
            interaction_text.text = response
    else:
        print("Object doesn't have interact method")
    
    # Move player to object if needed
    if player and current_verb != "Look at":
        # Calculate a position near the object
        var object_pos = object.global_position
        var dir = (player.global_position - object_pos).normalized()
        var target_pos = object_pos + dir * 50
        
        # Ensure target is in walkable area
        if current_district and current_district.has_method("is_position_walkable"):
            if current_district.is_position_walkable(target_pos):
                player.move_to(target_pos)
            else:
                # Find closest walkable position
                var closest_pos = object_pos
                for i in range(8):
                    var angle = i * PI / 4
                    var test_pos = object_pos + Vector2(cos(angle), sin(angle)) * 50
                    if current_district.is_position_walkable(test_pos):
                        closest_pos = test_pos
                        break
                
                player.move_to(closest_pos)
        else:
            player.move_to(object_pos)

# Update the interaction text based on current verb/object
func update_interaction_text():
    if interaction_text:
        if current_object and current_object.has_method("interact"):
            interaction_text.text = current_object.interact(current_verb)
        else:
            interaction_text.text = current_verb + "..."
