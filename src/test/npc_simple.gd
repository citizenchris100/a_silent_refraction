extends Node2D

# References
var current_npc = null
var current_verb = "Look at"

func _ready():
    print("Simple NPC Test Scene - Starting up")
    
    # Create a simple background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create a simple player
    var player = Node2D.new()
    player.set_name("Player")
    player.add_to_group("player")
    
    # Add a visual representation for the player
    var player_visual = ColorRect.new()
    player_visual.rect_size = Vector2(32, 48)
    player_visual.rect_position = Vector2(-16, -48)
    player_visual.color = Color(0.2, 0.6, 0.8)  # Blue for player
    player.add_child(player_visual)
    
    # Set player position
    player.position = Vector2(512, 500)
    add_child(player)
    
    # Create UI
    _setup_ui()
    
    # Create NPCs with clickable areas
    _create_npcs()

# Set up UI elements
func _setup_ui():
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create verb buttons
    var verb_panel = Panel.new()
    verb_panel.name = "VerbPanel"
    verb_panel.rect_position = Vector2(10, 10)
    verb_panel.rect_size = Vector2(150, 180)
    canvas_layer.add_child(verb_panel)
    
    var verb_container = VBoxContainer.new()
    verb_container.name = "VerbContainer"
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
    canvas_layer.add_child(status_label)
    
    # Create dialog panel (hidden initially)
    var dialog_panel = Panel.new()
    dialog_panel.name = "DialogPanel"
    dialog_panel.rect_position = Vector2(200, 150)
    dialog_panel.rect_size = Vector2(600, 300)
    dialog_panel.visible = false
    canvas_layer.add_child(dialog_panel)
    
    # Add dialog text
    var dialog_label = Label.new()
    dialog_label.name = "DialogText"
    dialog_label.rect_position = Vector2(20, 20)
    dialog_label.rect_size = Vector2(560, 80)
    dialog_label.autowrap = true
    dialog_panel.add_child(dialog_label)
    
    # Add dialog options container
    var option_container = VBoxContainer.new()
    option_container.name = "OptionContainer"
    option_container.rect_position = Vector2(20, 120)
    option_container.rect_size = Vector2(560, 160)
    dialog_panel.add_child(option_container)

# Create NPCs
func _create_npcs():
    # Create Concierge
    var concierge = _create_npc("Concierge", Vector2(300, 350), Color(0.2, 0.8, 0.2), false)
    
    # Create Security Officer
    var officer = _create_npc("Security Officer", Vector2(700, 350), Color(0.8, 0.2, 0.2), true)

# Helper to create an NPC with clickable area
func _create_npc(npc_name, position, color, is_assimilated):
    var npc = Node2D.new()
    npc.position = position
    
    # Add visual for NPC
    var npc_visual = ColorRect.new()
    npc_visual.rect_size = Vector2(40, 60)
    npc_visual.rect_position = Vector2(-20, -60)
    npc_visual.color = color
    npc.add_child(npc_visual)
    
    # Add label for NPC
    var npc_label = Label.new()
    npc_label.text = npc_name
    npc_label.rect_position = Vector2(-40, -80)
    npc.add_child(npc_label)
    
    # Add data to NPC
    npc.set_meta("npc_name", npc_name)
    npc.set_meta("is_assimilated", is_assimilated)
    npc.set_meta("dialog_tree", _get_dialog_tree_for_npc(npc_name, is_assimilated))
    npc.set_meta("current_dialog", "root")
    
    # Add clickable area
    var area = Area2D.new()
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.extents = Vector2(20, 30)
    collision.shape = shape
    collision.position = Vector2(0, -30)
    area.add_child(collision)
    area.connect("input_event", self, "_on_npc_clicked", [npc])
    npc.add_child(area)
    
    add_child(npc)
    return npc

# Get dialog tree based on NPC type
func _get_dialog_tree_for_npc(npc_name, is_assimilated):
    if npc_name == "Concierge":
        return {
            "root": {
                "text": "Welcome to the Barracks. How may I assist you today?",
                "options": [
                    {"text": "I'm just checking in.", "next": "checkin"},
                    {"text": "What's happening on the station?", "next": "station_info"},
                    {"text": "Nothing, thanks.", "next": "exit"}
                ]
            },
            "checkin": {
                "text": "Ah yes, Mr. Alex. Your room is 306 on the third floor. Is there anything else?",
                "options": [
                    {"text": "Could you tell me about the station?", "next": "station_info"},
                    {"text": "No, that's all.", "next": "exit"}
                ]
            },
            "station_info": {
                "text": "The station is currently on lockdown. No ships in or out until further notice. Security says it's just a routine drill, but...",
                "options": [
                    {"text": "But what?", "next": "suspicious"},
                    {"text": "I'm sure it's nothing.", "next": "agree"},
                    {"text": "Thanks for the info.", "next": "exit"}
                ]
            },
            "suspicious": {
                "text": "Well... I've noticed some strange behavior from several station personnel lately. They seem... different. Like they're not themselves.",
                "options": [
                    {"text": "How so?", "next": "explain_suspicions"},
                    {"text": "You're being paranoid.", "next": "paranoid"},
                    {"text": "I see.", "next": "exit"}
                ]
            },
            "explain_suspicions": {
                "text": "They move differently. Speak differently. And they all seem to be working together on something. I've overheard some of them mentioning 'assimilation'.",
                "options": [
                    {"text": "That sounds concerning.", "next": "package"},
                    {"text": "I'm sure there's a reasonable explanation.", "next": "agree"},
                    {"text": "Interesting. I need to go.", "next": "exit"}
                ]
            },
            "package": {
                "text": "Listen, could you do me a favor? I have a package that needs to be delivered to the Bank Teller in the Trading Floor district. I can't leave my post.",
                "options": [
                    {"text": "I'll deliver it for you.", "next": "give_package"},
                    {"text": "Why can't you use the normal delivery service?", "next": "delivery_service"},
                    {"text": "Sorry, I can't help.", "next": "exit"}
                ]
            },
            "give_package": {
                "text": "Thank you! Here's the package. Please take it to the Bank Teller as soon as possible. It's important.",
                "options": [
                    {"text": "I'll head there now.", "next": "exit"}
                ]
            },
            "delivery_service": {
                "text": "I don't trust the regular channels right now. Something strange is happening, and I need someone I can trust.",
                "options": [
                    {"text": "Alright, I'll take it.", "next": "give_package"},
                    {"text": "Sorry, I can't help.", "next": "exit"}
                ]
            },
            "agree": {
                "text": "Yes, you're probably right. Sorry to bother you with my concerns.",
                "options": [
                    {"text": "No problem.", "next": "exit"}
                ]
            },
            "paranoid": {
                "text": "Perhaps you're right. I should focus on my duties.",
                "options": [
                    {"text": "Good idea.", "next": "exit"}
                ]
            },
            "exit": {
                "text": "Have a pleasant stay on the station.",
                "options": []
            }
        }
    elif npc_name == "Security Officer":
        return {
            "root": {
                "text": "Halt. This area is under security lockdown. State your business.",
                "options": [
                    {"text": "I'm just passing through.", "next": "passing"},
                    {"text": "What's going on with the lockdown?", "next": "lockdown_info"},
                    {"text": "I'll go elsewhere.", "next": "exit"}
                ]
            },
            "passing": {
                "text": "No one is 'just passing through' during a security lockdown. What's your real purpose here?",
                "options": [
                    {"text": "I'm delivering something to the Bank Teller.", "next": "bank_teller"},
                    {"text": "I'm looking for my room.", "next": "room"},
                    {"text": "None of your business.", "next": "hostile"}
                ]
            },
            "lockdown_info": {
                "text": "Standard security protocol. There's been a potential breach in station security. Nothing for law-abiding citizens to worry about.",
                "options": [
                    {"text": "What kind of breach?", "next": "breach"},
                    {"text": "How long will it last?", "next": "duration"},
                    {"text": "I understand.", "next": "exit"}
                ]
            },
            "bank_teller": {
                "text": "The Bank Teller? What are you delivering?",
                "options": [
                    {"text": "A package from the Concierge.", "next": "concierge_package"},
                    {"text": "Just some documents.", "next": "documents"},
                    {"text": "That's confidential.", "next": "confidential"}
                ]
            },
            "breach": {
                "text": "That's classified information. Your interest in security matters is noted.",
                "options": [
                    {"text": "Just curious.", "next": "curious"},
                    {"text": "Sorry for asking.", "next": "exit"}
                ]
            },
            "hostile": {
                "text": "Hostility towards security personnel is a Class 3 violation. Final warning: state your business.",
                "options": [
                    {"text": "I'm delivering something to the Bank Teller.", "next": "bank_teller"},
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
    else:
        # Default dialog for other NPCs
        return {
            "root": {
                "text": "Hello there.",
                "options": [
                    {"text": "Hello.", "next": "greeting"},
                    {"text": "Goodbye.", "next": "exit"}
                ]
            },
            "greeting": {
                "text": "How can I help you?",
                "options": [
                    {"text": "Just looking around.", "next": "exit"}
                ]
            },
            "exit": {
                "text": "Goodbye.",
                "options": []
            }
        }

# Handle NPC clicks
func _on_npc_clicked(viewport, event, shape_idx, npc):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        current_npc = npc
        
        # Get status label
        var status_label = get_node("UI/StatusLabel")
        
        # Handle interaction based on current verb
        if current_verb == "Look at":
            status_label.text = "You see " + npc.get_meta("npc_name") + "."
        elif current_verb == "Talk to":
            _start_dialog(npc)
        elif current_verb == "Use":
            status_label.text = "You can't use " + npc.get_meta("npc_name") + "."
        elif current_verb == "Pick up":
            status_label.text = "You can't pick up " + npc.get_meta("npc_name") + "."

# Handle verb selection
func _on_verb_selected(verb):
    current_verb = verb
    
    # Update status label
    var status_label = get_node("UI/StatusLabel")
    status_label.text = "Selected: " + verb + " (click on an NPC)"

# Start dialog with an NPC
func _start_dialog(npc):
    # Reset dialog to root
    npc.set_meta("current_dialog", "root")
    
    # Show dialog
    _update_dialog(npc)

# Update dialog UI
func _update_dialog(npc):
    var dialog_panel = get_node("UI/DialogPanel")
    var dialog_text = get_node("UI/DialogPanel/DialogText")
    var option_container = get_node("UI/DialogPanel/OptionContainer")
    
    # Get current dialog node
    var current = npc.get_meta("current_dialog")
    var dialog_tree = npc.get_meta("dialog_tree")
    
    # Clear previous options
    for child in option_container.get_children():
        child.queue_free()
    
    # If valid dialog node exists
    if dialog_tree.has(current):
        var dialog = dialog_tree[current]
        
        # Set dialog text
        dialog_text.text = dialog.text
        
        # Create option buttons
        for i in range(dialog.options.size()):
            var option = dialog.options[i]
            var button = Button.new()
            button.text = option.text
            button.connect("pressed", self, "_on_dialog_option_selected", [npc, i])
            option_container.add_child(button)
        
        # Show dialog panel
        dialog_panel.visible = true
    else:
        dialog_panel.visible = false

# Handle dialog option selection
func _on_dialog_option_selected(npc, option_index):
    # Get current dialog node
    var current = npc.get_meta("current_dialog")
    var dialog_tree = npc.get_meta("dialog_tree")
    
    # Get selected option
    var dialog = dialog_tree[current]
    var option = dialog.options[option_index]
    
    # Move to next dialog node
    npc.set_meta("current_dialog", option.next)
    
    # If next node is "exit" or has no options, close dialog
    if option.next == "exit" or dialog_tree[option.next].options.size() == 0:
        var dialog_panel = get_node("UI/DialogPanel")
        dialog_panel.visible = false
        
        # Update status
        var status_label = get_node("UI/StatusLabel")
        status_label.text = "Dialog ended with " + npc.get_meta("npc_name") + "."
    else:
        # Otherwise, update dialog
        _update_dialog(npc)
