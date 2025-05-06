extends Node2D

func _ready():
    print("NPC Test Scene (DEBUG) - Starting up")
    
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
    
    # Add movement capability to player
    var player_script = load("res://src/characters/player/player.gd")
    player.set_script(player_script)
    
    # Set player position
    player.position = Vector2(512, 500)
    add_child(player)
    
    # Create UI Canvas Layer
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "UI"
    add_child(canvas_layer)
    
    # Create Interaction Text with more detail
    var interaction_text = Label.new()
    interaction_text.name = "InteractionText"
    interaction_text.rect_position = Vector2(20, 500)
    interaction_text.rect_size = Vector2(984, 30)
    interaction_text.text = "Click on an NPC to interact. DEBUG MODE ACTIVE."
    canvas_layer.add_child(interaction_text)
    
    # Create Verb UI with direct debug interactions
    var verb_container = VBoxContainer.new()
    verb_container.name = "VerbUI"
    verb_container.rect_position = Vector2(20, 20)
    verb_container.rect_size = Vector2(100, 300)
    canvas_layer.add_child(verb_container)
    
    # Add verb buttons manually for testing
    var verbs = ["Look at", "Talk to", "Use", "Pick up"]
    for verb in verbs:
        var button = Button.new()
        button.text = verb
        button.connect("pressed", self, "_on_verb_selected", [verb])
        verb_container.add_child(button)
    
    # Create dialog UI panel that's always visible for testing
    var dialog_panel = Panel.new()
    dialog_panel.name = "DialogUI"
    dialog_panel.rect_size = Vector2(600, 200)
    dialog_panel.rect_position = Vector2(212, 350)
    canvas_layer.add_child(dialog_panel)
    
    # Add dialog text
    var dialog_label = Label.new()
    dialog_label.name = "DialogLabel"
    dialog_label.rect_position = Vector2(20, 20)
    dialog_label.rect_size = Vector2(560, 60)
    dialog_label.text = "Dialog will appear here."
    dialog_panel.add_child(dialog_label)
    
    # Add dialog option buttons container
    var option_container = VBoxContainer.new()
    option_container.name = "OptionContainer"
    option_container.rect_position = Vector2(20, 90)
    option_container.rect_size = Vector2(560, 100)
    dialog_panel.add_child(option_container)
    
    # Add test options
    var test_button = Button.new()
    test_button.text = "Test Dialog Option"
    test_button.connect("pressed", self, "_on_test_option")
    option_container.add_child(test_button)
    
    # Create NPCs with extra debugging
    _create_npcs()
    
    # Create direct access variables
    self.current_verb = "Look at"
    self.current_npc = null
    
    # Add a direct interaction button
    var debug_button = Button.new()
    debug_button.text = "Test All Connections"
    debug_button.rect_position = Vector2(20, 560)
    debug_button.rect_size = Vector2(200, 30)
    debug_button.connect("pressed", self, "_debug_test_all")
    canvas_layer.add_child(debug_button)
    
    print("DEBUG: Scene setup complete")

# Create NPCs for testing with extra debug info
func _create_npcs():
    # Create Concierge with extra debugging
    var concierge = Node2D.new()
    concierge.set_script(load("res://src/characters/npc/concierge.gd"))
    concierge.position = Vector2(200, 400)
    concierge.connect("dialog_started", self, "_on_npc_dialog_started")
    concierge.connect("dialog_ended", self, "_on_npc_dialog_ended")
    
    # Add visual for concierge
    var concierge_visual = ColorRect.new()
    concierge_visual.rect_size = Vector2(32, 48)
    concierge_visual.rect_position = Vector2(-16, -48)
    concierge_visual.color = Color(0.2, 0.8, 0.2)  # Green for concierge
    concierge.add_child(concierge_visual)
    
    # Add label for concierge
    var concierge_label = Label.new()
    concierge_label.text = "Concierge\n(click me)"
    concierge_label.rect_position = Vector2(-40, -70)
    concierge.add_child(concierge_label)
    
    # Add collision shape for easier clicking
    var concierge_area = Area2D.new()
    concierge_area.connect("input_event", self, "_on_npc_input_event", [concierge])
    
    var concierge_collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.extents = Vector2(32, 48)
    concierge_collision.shape = shape
    concierge_collision.position = Vector2(0, -24)
    concierge_area.add_child(concierge_collision)
    concierge.add_child(concierge_area)
    
    add_child(concierge)
    print("DEBUG: Concierge NPC created")
    
    # Create Security Officer with direct interaction
    var security_officer = Node2D.new()
    security_officer.set_script(load("res://src/characters/npc/security_officer.gd"))
    security_officer.position = Vector2(600, 400)
    security_officer.connect("dialog_started", self, "_on_npc_dialog_started")
    security_officer.connect("dialog_ended", self, "_on_npc_dialog_ended")
    
    # Add visual for security officer
    var officer_visual = ColorRect.new()
    officer_visual.rect_size = Vector2(32, 48)
    officer_visual.rect_position = Vector2(-16, -48)
    officer_visual.color = Color(0.8, 0.2, 0.2)  # Red for security
    security_officer.add_child(officer_visual)
    
    # Add label for security officer
    var officer_label = Label.new()
    officer_label.text = "Security Officer\n(click me)"
    officer_label.rect_position = Vector2(-50, -70)
    security_officer.add_child(officer_label)
    
    # Add collision shape for easier clicking
    var officer_area = Area2D.new()
    officer_area.connect("input_event", self, "_on_npc_input_event", [security_officer])
    
    var officer_collision = CollisionShape2D.new()
    var officer_shape = RectangleShape2D.new()
    officer_shape.extents = Vector2(32, 48)
    officer_collision.shape = officer_shape
    officer_collision.position = Vector2(0, -24)
    officer_area.add_child(officer_collision)
    security_officer.add_child(officer_area)
    
    add_child(security_officer)
    print("DEBUG: Security Officer NPC created")

# Handle clicking on NPCs
func _on_npc_input_event(viewport, event, shape_idx, npc):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        print("DEBUG: Clicked on NPC: " + npc.npc_name)
        self.current_npc = npc
        
        # Update interaction text
        var interaction_text = get_node("UI/InteractionText")
        interaction_text.text = "Selected: " + npc.npc_name + " | Verb: " + self.current_verb
        
        # If Talk to is selected, start dialog
        if self.current_verb == "Talk to":
            print("DEBUG: Starting dialog with " + npc.npc_name)
            npc.start_dialog()
            _update_dialog_ui(npc)

# Handle verb selection
func _on_verb_selected(verb):
    print("DEBUG: Selected verb: " + verb)
    self.current_verb = verb
    
    # Update interaction text
    var interaction_text = get_node("UI/InteractionText")
    if self.current_npc:
        interaction_text.text = "Selected: " + self.current_npc.npc_name + " | Verb: " + verb
    else:
        interaction_text.text = "Selected verb: " + verb + " (click an NPC)"

# Dialog started signal handler
func _on_npc_dialog_started(npc):
    print("DEBUG: Dialog started with " + npc.npc_name)
    self.current_npc = npc
    _update_dialog_ui(npc)

# Dialog ended signal handler
func _on_npc_dialog_ended(npc):
    print("DEBUG: Dialog ended with " + npc.npc_name)
    
    # Clear dialog UI
    var dialog_label = get_node("UI/DialogUI/DialogLabel")
    dialog_label.text = "Dialog ended."
    
    # Clear options
    var option_container = get_node("UI/DialogUI/OptionContainer")
    for child in option_container.get_children():
        child.queue_free()

# Update dialog UI
func _update_dialog_ui(npc):
    print("DEBUG: Updating dialog UI for " + npc.npc_name)
    
    # Get current dialog
    var dialog = npc.get_current_dialog()
    if dialog:
        # Set dialog text
        var dialog_label = get_node("UI/DialogUI/DialogLabel")
        dialog_label.text = dialog.text
        print("DEBUG: Dialog text: " + dialog.text)
        
        # Clear previous options
        var option_container = get_node("UI/DialogUI/OptionContainer")
        for child in option_container.get_children():
            child.queue_free()
        
        # Create new dialog options
        for i in range(dialog.options.size()):
            var option = dialog.options[i]
            
            # Create option button
            var button = Button.new()
            button.text = option.text
            button.connect("pressed", self, "_on_dialog_option_selected", [i])
            option_container.add_child(button)
            
            print("DEBUG: Added option: " + option.text)
    else:
        print("DEBUG: No dialog found for " + npc.npc_name)

# Handle dialog option selection
func _on_dialog_option_selected(option_index):
    print("DEBUG: Selected option index: " + str(option_index))
    
    if self.current_npc:
        # Choose option
        var next_dialog = self.current_npc.choose_dialog_option(option_index)
        
        if next_dialog:
            # Update dialog UI
            _update_dialog_ui(self.current_npc)
        else:
            # Dialog ended
            print("DEBUG: Dialog ended after option selection")
            
            # Clear dialog UI
            var dialog_label = get_node("UI/DialogUI/DialogLabel")
            dialog_label.text = "Dialog ended."
            
            # Clear options
            var option_container = get_node("UI/DialogUI/OptionContainer")
            for child in option_container.get_children():
                child.queue_free()

# Test option for debugging
func _on_test_option():
    print("DEBUG: Test option selected")
    
    # Get interaction text
    var interaction_text = get_node("UI/InteractionText")
    interaction_text.text = "Test option selected"

# Debug test all connections
func _debug_test_all():
    print("DEBUG: Testing all connections")
    
    # Find all NPCs
    var npcs = []
    for child in get_children():
        if child.is_in_group("npc") or child.has_method("is_assimilated"):
            npcs.append(child)
    
    print("DEBUG: Found " + str(npcs.size()) + " NPCs")
    
    # Test NPC methods
    if npcs.size() > 0:
        var test_npc = npcs[0]
        print("DEBUG: Testing with NPC: " + test_npc.npc_name)
        
        # Test interaction
        var interact_result = test_npc.interact("Talk to")
        print("DEBUG: Interact result: " + interact_result)
        
        # Test dialog
        test_npc.start_dialog()
        var dialog = test_npc.get_current_dialog()
        if dialog:
            print("DEBUG: Dialog text: " + dialog.text)
            print("DEBUG: Dialog options: " + str(dialog.options.size()))
        else:
            print("DEBUG: No dialog returned")
    else:
        print("DEBUG: No NPCs found for testing")
