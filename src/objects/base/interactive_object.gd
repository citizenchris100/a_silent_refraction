extends Node2D

export var object_name = "Object"
export var description = "An unknown object."

# Interaction responses
var responses = {
    "Look at": "You see OBJECT_NAME.",
    "Use": "You can't use that.",
    "Talk to": "OBJECT_NAME doesn't respond.",
    "Pick up": "You can't pick that up.",
    "Push": "That won't budge.",
    "Pull": "You can't pull that.",
    "Open": "That doesn't open.",
    "Close": "That's not something you can close.",
    "Give": "You can't give that to anyone."
}

func _ready():
    # Replace placeholders in responses
    for verb in responses.keys():
        responses[verb] = responses[verb].replace("OBJECT_NAME", object_name)
    
    # Add to interactive objects group
    add_to_group("interactive_object")

# Handle interaction with this object
func interact(verb):
    if verb in responses:
        return responses[verb]
    else:
        return "You can't " + verb + " " + object_name
