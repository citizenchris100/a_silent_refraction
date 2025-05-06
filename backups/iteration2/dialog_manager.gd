extends Node

var dialog_ui
var active_npc = null

func _ready():
    # Find dialog UI
    yield(get_tree(), "idle_frame")
    
    if get_tree().root.has_node("Game/UI/DialogUI"):
        dialog_ui = get_tree().root.get_node("Game/UI/DialogUI")
        dialog_ui.connect("option_selected", self, "_on_dialog_option_selected")
    else:
        push_error("DialogUI not found!")
    
    # Connect to NPCs
    for npc in get_tree().get_nodes_in_group("npc"):
        npc.connect("dialog_started", self, "_on_dialog_started")
        npc.connect("dialog_ended", self, "_on_dialog_ended")

# Handle dialog start
func _on_dialog_started(npc):
    active_npc = npc
    if dialog_ui:
        dialog_ui.show_dialog(npc)

# Handle dialog end
func _on_dialog_ended(npc):
    active_npc = null
    if dialog_ui:
        dialog_ui.hide_dialog()

# Handle dialog option selection
func _on_dialog_option_selected(option_index):
    if active_npc:
        active_npc.choose_dialog_option(option_index)
