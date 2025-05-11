extends Control

signal verb_selected(verb)

# Available verbs
var verbs = ["Look at", "Talk to", "Observe", "Use", "Pick up", "Push", "Pull", "Open", "Close", "Give"]
var current_verb = "Look at"

func _ready():
    # Create the verb buttons
    _create_verb_buttons()

func _create_verb_buttons():
    var button_size = Vector2(100, 30)
    var margin = Vector2(10, 5)
    var columns = 3
    
    for i in range(verbs.size()):
        var verb = verbs[i]
        
        # Calculate position
        var row = i / columns
        var col = i % columns
        var pos = Vector2(
            margin.x + col * (button_size.x + margin.x),
            margin.y + row * (button_size.y + margin.y)
        )
        
        # Create button
        var button = Button.new()
        button.text = verb
        button.rect_position = pos
        button.rect_min_size = button_size
        button.connect("pressed", self, "_on_verb_button_pressed", [verb])
        add_child(button)

func _on_verb_button_pressed(verb):
    current_verb = verb
    emit_signal("verb_selected", verb)
