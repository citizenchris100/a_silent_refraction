extends Node2D

# Reference to the interaction manager
var interaction_manager

func _ready():
    print("A Silent Refraction - Starting up")
    
    # Create interaction manager
    var InteractionManager = load("res://src/core/interaction/interaction_manager.gd")
    interaction_manager = InteractionManager.new()
    add_child(interaction_manager)
    
    # Load the shipping district
    var shipping_district = load("res://src/districts/shipping/shipping_district.tscn").instance()
    add_child(shipping_district)
    
    # Add the player character
    var player = load("res://src/characters/player/player.tscn").instance()
    add_child(player)
    player.position = Vector2(400, 300)  # Starting position
    
    # Connect the verb UI to the interaction manager if it exists
    if has_node("CanvasLayer/VerbUI"):
        var verb_ui = $CanvasLayer/VerbUI
        verb_ui.connect("verb_selected", self, "_on_verb_selected")

# Handle verb selection
func _on_verb_selected(verb):
    interaction_manager.current_verb = verb
    print("Selected verb: " + verb)
