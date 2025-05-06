extends Node

var dialog_ui
var active_npc = null

func _ready():
    # Create dialog UI
    dialog_ui = load("res://src/ui/dialog/dialog_ui_fixed.gd").new()
    dialog_ui.name = "DialogUI"
    add_child(dialog_ui)
    dialog_ui.connect("option_selected", self, "_on_dialog_option_selected")
    
    # Move UI to canvas layer for proper rendering
    var canvas = CanvasLayer.new()
    canvas.name = "DialogCanvas"
    add_child(canvas)
    remove_child(dialog_ui)
    canvas.add_child(dialog_ui)
    
    # Connect to NPCs
    _connect_to_npcs()

# Connect to all NPCs in the scene
func _connect_to_npcs():
    # Wait a frame to make sure all NPCs are initialized
    yield(get_tree(), "idle_frame")
    
    # Find and connect to all NPCs
    for npc in get_tree().get_nodes_in_group("npc"):
        if not npc.is_connected("dialog_started", self, "_on_dialog_started"):
            npc.connect("dialog_started", self, "_on_dialog_started")
        
        if not npc.is_connected("dialog_ended", self, "_on_dialog_ended"):
            npc.connect("dialog_ended", self, "_on_dialog_ended")

# Handle dialog start
func _on_dialog_started(npc):
    active_npc = npc
    dialog_ui.show_dialog(npc)

# Handle dialog end
func _on_dialog_ended(npc):
    active_npc = null
    dialog_ui.hide_dialog()

# Handle dialog option selection
func _on_dialog_option_selected(option_index):
    if active_npc:
        var dialog = active_npc.choose_dialog_option(option_index)
        
        if dialog:
            # Update dialog UI
            dialog_ui.show_dialog(active_npc)
