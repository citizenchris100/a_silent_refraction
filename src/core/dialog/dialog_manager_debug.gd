extends Node

var dialog_panel
var dialog_text
var dialog_options
var current_npc = null

func _ready():
    print("Dialog Manager initializing...")
    
    # Create dialog UI
    _create_dialog_ui()
    
    print("Dialog Manager ready")

func _create_dialog_ui():
    # Create canvas layer if needed
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
    
    print("Dialog UI created")

# Show dialog with an NPC
func show_dialog(npc):
    print("Dialog Manager: show_dialog called for " + npc.npc_name)
    current_npc = npc
    
    # Clear previous options
    for child in dialog_options.get_children():
        child.queue_free()
    
    # Get current dialog
    var dialog = npc.get_current_dialog()
    if dialog:
        print("Dialog found: " + dialog.text)
        # Set dialog text
        dialog_text.text = dialog.text
        
        # Create dialog options
        for i in range(dialog.options.size()):
            var option = dialog.options[i]
            var button = Button.new()
            button.text = option.text
            button.connect("pressed", self, "_on_dialog_option_selected", [i])
            dialog_options.add_child(button)
            print("Added option: " + option.text)
        
        # Show dialog panel
        dialog_panel.visible = true
        print("Dialog panel set to visible")
    else:
        print("No dialog found for NPC")
        end_dialog()

# Hide dialog panel
func end_dialog():
    print("Dialog Manager: end_dialog called")
    dialog_panel.visible = false
    current_npc = null
    print("Dialog ended")

# Handle dialog option selection
func _on_dialog_option_selected(option_index):
    print("Dialog option selected: " + str(option_index))
    if current_npc:
        var dialog = current_npc.choose_dialog_option(option_index)
        
        if dialog:
            # Update dialog
            print("Updating dialog with new node")
            show_dialog(current_npc)
        else:
            # Dialog ended
            print("Dialog ended after option selection")
            end_dialog()
    else:
        print("No current NPC when option selected")
