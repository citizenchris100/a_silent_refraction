extends Control

signal option_selected(option_index)

var current_npc = null
var dialog_label
var option_container

func _ready():
    # Create dialog UI elements
    _create_dialog_ui()
    
    # Hide initially
    visible = false

func _create_dialog_ui():
    # Create a panel background
    var panel = Panel.new()
    panel.rect_size = Vector2(600, 200)
    panel.rect_position = Vector2(
        (get_viewport_rect().size.x - 600) / 2,
        get_viewport_rect().size.y - 250
    )
    add_child(panel)
    
    # Create dialog text label
    dialog_label = Label.new()
    dialog_label.rect_position = Vector2(20, 20)
    dialog_label.rect_size = Vector2(560, 60)
    dialog_label.align = Label.ALIGN_LEFT
    dialog_label.valign = Label.VALIGN_TOP
    dialog_label.autowrap = true
    panel.add_child(dialog_label)
    
    # Create option container
    option_container = VBoxContainer.new()
    option_container.rect_position = Vector2(20, 90)
    option_container.rect_size = Vector2(560, 100)
    panel.add_child(option_container)

# Show dialog with NPC
func show_dialog(npc):
    current_npc = npc
    
    # Clear previous dialog options
    for child in option_container.get_children():
        child.queue_free()
    
    # Get current dialog
    var dialog = npc.get_current_dialog()
    if dialog:
        # Set dialog text
        dialog_label.text = dialog.text
        
        # Create dialog options
        for i in range(dialog.options.size()):
            var option = dialog.options[i]
            
            # Create option button
            var button = Button.new()
            button.text = option.text
            button.connect("pressed", self, "_on_option_button_pressed", [i])
            option_container.add_child(button)
    
    # Show dialog UI
    visible = true

# Hide dialog UI
func hide_dialog():
    current_npc = null
    visible = false

# Handle option button press
func _on_option_button_pressed(option_index):
    if current_npc:
        # Choose option
        var dialog = current_npc.choose_dialog_option(option_index)
        
        if dialog:
            # Update dialog UI
            show_dialog(current_npc)
        else:
            # Dialog ended
            hide_dialog()
