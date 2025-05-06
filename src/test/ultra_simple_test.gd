extends Node2D

# Global variables
var current_verb = "Look at"
var dialog_visible = false
var dialog_panel
var dialog_text
var dialog_options
var current_npc = null
var current_dialog_node = "root"

# NPC Data (kept simple for testing)
var npc_data = {
    "Concierge": {
        "position": Vector2(300, 400),
        "color": Color(0.2, 0.8, 0.2),
        "assimilated": false,
        "dialog": {
            "root": {
                "text": "Welcome to the Barracks. How may I assist you today?",
                "options": [
                    {"text": "What's happening on the station?", "next": "station_info"},
                    {"text": "Nothing, thanks.", "next": "exit"}
                ]
            },
            "station_info": {
                "text": "The station is currently on lockdown. No ships in or out until further notice.",
                "options": [
                    {"text": "Why is that?", "next": "lockdown_reason"},
                    {"text": "Thanks for the info.", "next": "exit"}
                ]
            },
            "lockdown_reason": {
                "text": "Security says it's just a drill, but I've noticed some strange behavior lately...",
                "options": [
                    {"text": "Strange how?", "next": "strange_behavior"},
                    {"text": "I should go.", "next": "exit"}
                ]
            },
            "strange_behavior": {
                "text": "People acting differently. Like they're not themselves. Mentioning 'assimilation'...",
                "options": [
                    {"text": "That's concerning.", "next": "exit"}
                ]
            },
            "exit": {
                "text": "Have a good day.",
                "options": []
            }
        }
    },
    "Security Officer": {
        "position": Vector2(700, 400),
        "color": Color(0.8, 0.2, 0.2),
        "assimilated": true,
        "dialog": {
            "root": {
                "text": "Halt. This area is under security lockdown. State your business.",
                "options": [
                    {"text": "I'm just passing through.", "next": "passing"},
                    {"text": "What's going on with the lockdown?", "next": "lockdown_info"},
                    {"text": "I'll go elsewhere.", "next": "exit"}
                ]
            },
            "passing": {
                "text": "No one is 'just passing through' during a lockdown. What's your real purpose here?",
                "options": [
                    {"text": "I'm looking for my room.", "next": "room"},
                    {"text": "None of your business.", "next": "hostile"}
                ]
            },
            "lockdown_info": {
                "text": "Standard security protocol. There's been a potential breach in station security.",
                "options": [
                    {"text": "What kind of breach?", "next": "breach"},
                    {"text": "I understand.", "next": "exit"}
                ]
            },
            "breach": {
                "text": "That's classified information. Your interest in security matters is noted.",
                "options": [
                    {"text": "Just curious.", "next": "exit"}
                ]
            },
            "room": {
                "text": "Which room is yours?",
                "options": [
                    {"text": "Room 306.", "next": "exit"}
                ]
            },
            "hostile": {
                "text": "Hostility towards security personnel is a violation. Final warning: state your business.",
                "options": [
                    {"text": "I'm looking for my room.", "next": "room"},
                    {"text": "Still none of your business.", "next": "game_over"}
                ]
            },
            "game_over": {
                "text": "You've been identified as a threat. Guards, seize this person!",
                "options": [
                    {"text": "...", "next": "exit"}
                ]
            },
            "exit": {
                "text": "Move along, citizen.",
                "options": []
            }
        }
    }
}

func _ready():
    print("Ultra-Simple Test Scene - Starting")
    
    # Create scene elements
    _create_scene()
    
    # Connect input handling
    set_process_input(true)

func _create_scene():
    # Create background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create player
    var player = ColorRect.new()
    player.name = "Player"
    player.rect_size = Vector2(30, 50)
    player.rect_position = Vector2(500, 500)
    player.color = Color(0.2, 0.6, 0.8)
    add_child(player)
    
    # Create UI elements on canvas layer
    var canvas = CanvasLayer.new()
    add_child(canvas)
    
    # Create verb buttons
    var verb_panel = Panel.new()
    verb_panel.rect_position = Vector2(10, 10)
    verb_panel.rect_size = Vector2(150, 180)
    canvas.add_child(verb_panel)
    
    var verb_container = VBoxContainer.new()
    verb_container.rect_position = Vector2(10, 10)
    verb_container.rect_size = Vector2(130, 160)
    verb_panel.add_child(verb_container)
    
    var verbs = ["Look at", "Talk to", "Use", "Pick up"]
    for verb in verbs:
        var button = Button.new()
        button.text = verb
        button.connect("pressed", self, "_on_verb_selected", [verb])
        verb_container.add_child(button)
    
    # Create status label
    var status_label = Label.new()
    status_label.name = "StatusLabel"
    status_label.rect_position = Vector2(10, 570)
    status_label.rect_size = Vector2(1000, 20)
    status_label.text = "Select a verb and click on an NPC."
    canvas.add_child(status_label)
    
    # Create dialog panel (hidden initially)
    dialog_panel = Panel.new()
    dialog_panel.rect_position = Vector2(200, 200)
    dialog_panel.rect_size = Vector2(600, 300)
    dialog_panel.visible = false
    canvas.add_child(dialog_panel)
    
    # Add dialog text
    dialog_text = Label.new()
    dialog_text.rect_position = Vector2(20, 20)
    dialog_text.rect_size = Vector2(560, 100)
    dialog_text.autowrap = true
    dialog_panel.add_child(dialog_text)
    
    # Add dialog options container
    dialog_options = VBoxContainer.new()
    dialog_options.rect_position = Vector2(20, 130)
    dialog_options.rect_size = Vector2(560, 150)
    dialog_panel.add_child(dialog_options)
    
    # Create NPCs
    for npc_name in npc_data.keys():
        _create_npc(npc_name, npc_data[npc_name].position, npc_data[npc_name].color)

func _create_npc(npc_name, position, color):
    var npc = ColorRect.new()
    npc.name = npc_name
    npc.rect_size = Vector2(40, 60)
    npc.rect_position = position - Vector2(20, 60) # Center the rect
    npc.color = color
    
    # Add label
    var label = Label.new()
    label.text = npc_name
    label.rect_position = Vector2(-30, -20)
    label.rect_size = Vector2(100, 20)
    npc.add_child(label)
    
    add_child(npc)

func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        if not dialog_visible:
            # Check if we clicked on an NPC
            for npc_name in npc_data.keys():
                var npc = get_node(npc_name)
                if npc and _is_point_in_rect(event.position, npc.rect_position, npc.rect_size):
                    _handle_npc_click(npc_name)
                    return

func _is_point_in_rect(point, rect_pos, rect_size):
    return (point.x >= rect_pos.x and point.x <= rect_pos.x + rect_size.x and
            point.y >= rect_pos.y and point.y <= rect_pos.y + rect_size.y)

func _handle_npc_click(npc_name):
    print("Clicked on: " + npc_name)
    
    # Update status label
    get_node("StatusLabel").text = current_verb + " " + npc_name
    
    # If Talk to is selected, start dialog
    if current_verb == "Talk to":
        _start_dialog(npc_name)

func _on_verb_selected(verb):
    current_verb = verb
    print("Selected verb: " + verb)
    get_node("StatusLabel").text = verb + " (click on an NPC)"

func _start_dialog(npc_name):
    current_npc = npc_name
    current_dialog_node = "root"
    _update_dialog()
    
    # Show dialog panel
    dialog_panel.visible = true
    dialog_visible = true

func _update_dialog():
    # Clear previous options
    for child in dialog_options.get_children():
        child.queue_free()
    
    # Get current dialog node
    var dialog = npc_data[current_npc].dialog[current_dialog_node]
    
    # Set dialog text
    dialog_text.text = dialog.text
    
    # Create dialog options
    for i in range(dialog.options.size()):
        var option = dialog.options[i]
        var button = Button.new()
        button.text = option.text
        button.connect("pressed", self, "_on_dialog_option_selected", [i])
        dialog_options.add_child(button)
    
    # If no options, add a close button
    if dialog.options.size() == 0:
        var close_button = Button.new()
        close_button.text = "Close"
        close_button.connect("pressed", self, "_close_dialog")
        dialog_options.add_child(close_button)

func _on_dialog_option_selected(option_index):
    # Get current dialog
    var dialog = npc_data[current_npc].dialog[current_dialog_node]
    var option = dialog.options[option_index]
    
    # Move to next dialog node
    current_dialog_node = option.next
    
    # Check if dialog should end
    if current_dialog_node == "exit" or npc_data[current_npc].dialog[current_dialog_node].options.size() == 0:
        _close_dialog()
    else:
        _update_dialog()

func _close_dialog():
    dialog_panel.visible = false
    dialog_visible = false
    current_npc = null
    get_node("StatusLabel").text = "Dialog ended. Select a verb and click on an NPC."
