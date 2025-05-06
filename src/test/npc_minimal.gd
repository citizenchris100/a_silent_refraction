extends Node2D

var dialog_visible = false
var current_npc = null

func _ready():
    print("Minimal NPC Test - Starting")
    
    # Create background
    var background = ColorRect.new()
    background.rect_size = Vector2(1024, 600)
    background.color = Color(0.1, 0.1, 0.2)
    add_child(background)
    
    # Create status label
    var status = Label.new()
    status.name = "Status"
    status.rect_position = Vector2(10, 10)
    status.rect_size = Vector2(1000, 30)
    status.text = "Click on an NPC to talk to them"
    add_child(status)
    
    # Create two NPCs
    _create_npc("Concierge", Vector2(300, 300), Color.green)
    _create_npc("Security Officer", Vector2(700, 300), Color.red)
    
    # Create dialog UI
    _create_dialog_ui()

func _create_npc(npc_name, position, color):
    var npc = ColorRect.new()
    npc.name = npc_name
    npc.rect_position = position - Vector2(20, 60) # Center the rect
    npc.rect_size = Vector2(40, 60)
    npc.color = color
    
    # Add name label
    var label = Label.new()
    label.text = npc_name
    label.rect_position = Vector2(0, -20)
    label.rect_size = Vector2(100, 20)
    label.align = Label.ALIGN_CENTER
    label.rect_position.x = -30 # Center the label
    npc.add_child(label)
    
    # Store dialog data
    if npc_name == "Concierge":
        npc.set_meta("dialog", [
            "Welcome to the Barracks. How may I assist you today?",
            "The station is currently on lockdown due to security protocols.",
            "Please be careful who you trust. Not everyone is what they seem."
        ])
    else:
        npc.set_meta("dialog", [
            "Halt. This area is under security lockdown. State your business.",
            "We've implemented stricter measures for station-wide safety.",
            "Move along, citizen. No loitering in this area."
        ])
    
    add_child(npc)
    return npc

func _create_dialog_ui():
    # Dialog panel
    var panel = Panel.new()
    panel.name = "DialogPanel"
    panel.rect_position = Vector2(200, 200)
    panel.rect_size = Vector2(600, 200)
    panel.visible = false
    add_child(panel)
    
    # Dialog text
    var text = Label.new()
    text.name = "DialogText"
    text.rect_position = Vector2(20, 20)
    text.rect_size = Vector2(560, 100)
    text.align = Label.ALIGN_CENTER
    text.valign = Label.VALIGN_CENTER
    text.autowrap = true
    panel.add_child(text)
    
    # Close button
    var button = Button.new()
    button.name = "CloseButton"
    button.text = "Close"
    button.rect_position = Vector2(250, 150)
    button.rect_size = Vector2(100, 30)
    button.connect("pressed", self, "_on_close_dialog")
    panel.add_child(button)
    
    # Next button
    var next_button = Button.new()
    next_button.name = "NextButton"
    next_button.text = "Next"
    next_button.rect_position = Vector2(370, 150)
    next_button.rect_size = Vector2(100, 30)
    next_button.connect("pressed", self, "_on_next_dialog")
    panel.add_child(next_button)

func _input(event):
    # Only process mouse clicks when dialog is not visible
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and not dialog_visible:
        # Check if clicked on an NPC
        var click_pos = event.position
        
        for child in get_children():
            if child is ColorRect and child.name != "Background":
                if Rect2(child.rect_position, child.rect_size).has_point(click_pos):
                    _show_dialog(child)
                    break

func _show_dialog(npc):
    # Update status
    get_node("Status").text = "Talking to " + npc.name
    
    # Show dialog panel
    var panel = get_node("DialogPanel")
    panel.visible = true
    dialog_visible = true
    
    # Set current NPC
    current_npc = npc
    
    # Set dialog index
    current_npc.set_meta("current_dialog_index", 0)
    
    # Update dialog text
    var dialog_texts = current_npc.get_meta("dialog")
    get_node("DialogPanel/DialogText").text = dialog_texts[0]

func _on_close_dialog():
    # Hide dialog panel
    get_node("DialogPanel").visible = false
    dialog_visible = false
    
    # Update status
    get_node("Status").text = "Click on an NPC to talk to them"

func _on_next_dialog():
    if current_npc:
        var dialog_texts = current_npc.get_meta("dialog")
        var current_index = current_npc.get_meta("current_dialog_index")
        
        # Move to next dialog
        current_index += 1
        
        # Check if end of dialog
        if current_index >= dialog_texts.size():
            _on_close_dialog()
            return
        
        # Update dialog index
        current_npc.set_meta("current_dialog_index", current_index)
        
        # Update dialog text
        get_node("DialogPanel/DialogText").text = dialog_texts[current_index]
