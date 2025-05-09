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
        
        if not npc.is_connected("suspicion_changed", self, "_on_suspicion_changed"):
            npc.connect("suspicion_changed", self, "_on_suspicion_changed", [npc])
        
        print("Connected dialog system to NPC: " + npc.npc_name)

# Show dialog with an NPC
func show_dialog(npc):
    if not npc:
        print("Error: Trying to show dialog with null NPC")
        return

    current_npc = npc

    # Clear previous options
    for child in dialog_options.get_children():
        child.queue_free()

    # Check if NPC has the get_current_dialog method
    if not npc.has_method("get_current_dialog"):
        print("Error: NPC does not have get_current_dialog method")
        end_dialog()
        return

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
        print("No dialog found for NPC: " + npc.name)
        end_dialog()

# End the current dialog
func end_dialog():
    dialog_panel.visible = false

    var old_npc = current_npc
    current_npc = null

    # Block clicks for a short period after dialog ends to prevent accidental movement
    var input_manager = _find_input_manager()
    if input_manager and input_manager.has_method("block_clicks"):
        input_manager.block_clicks(500)  # Block clicks for 500ms

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
    if current_npc and is_instance_valid(current_npc):
        emit_signal("option_selected", option_index)
        # Store a reference to the NPC to handle null case
        var npc = current_npc
        var dialog = npc.choose_dialog_option(option_index)

        # Check if NPC is still valid (could be freed during choose_dialog_option)
        if is_instance_valid(npc) and npc.has_method("get_current_dialog"):
            if dialog:
                # Update dialog
                show_dialog(npc)
            else:
                # Dialog ended
                end_dialog()
        else:
            # NPC became invalid
            end_dialog()
    else:
        # No current NPC
        end_dialog()

# Handle suspicion changed signal - no individual meter to update
func _on_suspicion_changed(old_level, new_level, npc):
    pass

# Find the input manager in the scene tree
func _find_input_manager():
    var root = get_tree().get_root()
    for child in root.get_children():
        for grandchild in child.get_children():
            if grandchild.get_class() == "Node" and grandchild.get_script() and grandchild.get_script().get_path().ends_with("input_manager.gd"):
                return grandchild
    return null
