extends Node

# UI components
var dialog_panel
var dialog_text
var dialog_options
var current_npc = null

# Signals
signal dialog_started(npc)
signal dialog_ended(npc)
signal option_selected(option_index)

func _ready():
    # Create dialog UI
    _create_dialog_ui()
    
    # Connect to NPCs in the scene
    yield(get_tree(), "idle_frame")
    _connect_to_npcs()

# Create dialog UI components
func _create_dialog_ui():
    # Create canvas layer for UI
    var canvas = CanvasLayer.new()
    canvas.name = "DialogCanvas"
    canvas.layer = 10  # Make sure it's on top
    add_child(canvas)
    
    # Create dialog panel
    dialog_panel = Panel.new()
    dialog_panel.rect_position = Vector2(212, 150)
    dialog_panel.rect_size = Vector2(600, 300)
    dialog_panel.visible = false
    canvas.add_child(dialog_panel)
    
    # Create dialog text
    dialog_text = Label.new()
    dialog_text.rect_position = Vector2(20, 20)
    dialog_text.rect_size = Vector2(560, 100)
    dialog_text.autowrap = true
    dialog_panel.add_child(dialog_text)
    
    # Create dialog options container
    dialog_options = VBoxContainer.new()
    dialog_options.rect_position = Vector2(20, 130)
    dialog_options.rect_size = Vector2(560, 150)
    dialog_panel.add_child(dialog_options)

# Connect to all NPCs in the scene
func _connect_to_npcs():
    for npc in get_tree().get_nodes_in_group("npc"):
        if not npc.is_connected("dialog_started", self, "_on_dialog_started"):
            npc.connect("dialog_started", self, "_on_dialog_started")
        
        if not npc.is_connected("dialog_ended", self, "_on_dialog_ended"):
            npc.connect("dialog_ended", self, "_on_dialog_ended")

# Show dialog with an NPC
func show_dialog(npc):
    current_npc = npc
    
    # Clear previous options
    for child in dialog_options.get_children():
        child.queue_free()
    
    # Get current dialog
    var dialog = npc.get_current_dialog()
    if dialog:
        # Set dialog text
        dialog_text.text = dialog.text
        
        # Create dialog options
        for i in range(dialog.options.size()):
            var option = dialog.options[i]
            var button = Button.new()
            button.text = option.text
            button.connect("pressed", self, "_on_dialog_option_selected", [i])
            dialog_options.add_child(button)
        
        # Show dialog panel
        dialog_panel.visible = true
        emit_signal("dialog_started", npc)
    else:
        end_dialog()

# End the current dialog
func end_dialog():
    dialog_panel.visible = false
    var old_npc = current_npc
    current_npc = null
    
    if old_npc:
        emit_signal("dialog_ended", old_npc)

# Handle dialog started signal
func _on_dialog_started(npc):
    show_dialog(npc)

# Handle dialog ended signal
func _on_dialog_ended(npc):
    if current_npc == npc:
        end_dialog()

# Handle dialog option selection
func _on_dialog_option_selected(option_index):
    if current_npc:
        emit_signal("option_selected", option_index)
        var dialog = current_npc.choose_dialog_option(option_index)
        
        if dialog:
            # Update dialog
            show_dialog(current_npc)
