extends Node2D
class_name BaseNPC

# NPC Properties
export var npc_name = "Unknown NPC"
export var description = "An unknown person"
export var is_assimilated = false
export var npc_id = ""  # Identifier matching the NPC registry

# Visual components
var visual_sprite
var sprite_frames = {}  # Used to store loaded sprite textures
var label

# State Machine
enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}
var current_state = State.IDLE

# Suspicion System
var suspicion_level = 0.0  # 0.0 to 1.0
var suspicion_threshold = 0.8  # Main threshold for becoming suspicious
# Additional thresholds for gradual reactions
var low_suspicion_threshold = 0.3
var medium_suspicion_threshold = 0.5
var high_suspicion_threshold = 0.8
var critical_suspicion_threshold = 0.9
var suspicion_decay_rate = 0.05
var suspicion_decay_enabled = true
var current_suspicion_tier = "none"  # none, low, medium, high, critical

# Dialog System
var dialog_tree = {}
var current_dialog_node = "root"

# Observation System
var known_assimilated = false  # Player knows this NPC is assimilated
var observation_time = 0.0  # Tracks how long player has observed this NPC
var observation_threshold = 5.0  # Time needed for detection

# Signals
signal state_changed(old_state, new_state)
signal suspicion_changed(old_level, new_level)
signal dialog_started(npc)
signal dialog_ended(npc)
signal observed(success)  # Emitted when observation completes

func _ready():
    # Add to groups
    add_to_group("npc")
    add_to_group("interactive_object")

    # Load data from NPC registry if available
    if npc_id != "":
        _load_from_registry()

    # Setup visual representation
    _setup_visual()

    # Initialize dialog tree
    initialize_dialog()

    # Initialize state machine
    _change_state(State.IDLE)

    # Enable input processing
    set_process_input(true)

# Load NPC data from registry
func _load_from_registry():
    var npc_data = _find_npc_data_manager()
    if npc_data:
        var npc = npc_data.get_npc(npc_id)
        if npc:
            # Update properties from registry
            is_assimilated = npc.assimilated
            if "name" in npc:
                npc_name = npc.name
            if "suspicious_level" in npc:
                suspicion_level = npc.suspicious_level
            if "known_assimilated" in npc:
                known_assimilated = npc.known_assimilated

# Input handling for direct NPC interaction
func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        if _is_point_in_clickable_area(event.position):
            var game_manager = _find_game_manager()
            if game_manager:
                game_manager.handle_npc_click(self)

# Check if a point is within the NPC's clickable area
func _is_point_in_clickable_area(point):
    if visual_sprite and visual_sprite is Control:
        var rect_global_pos = visual_sprite.rect_position + global_position
        var rect_size = visual_sprite.rect_size
        return Rect2(rect_global_pos, rect_size).has_point(point)
    return false

# Set up visual representation
func _setup_visual():
    # Create sprite if not present
    if has_node("Visual") and get_node("Visual") is Sprite:
        visual_sprite = get_node("Visual")
    else:
        # First, check if we need to remove an existing ColorRect
        if has_node("Visual"):
            get_node("Visual").queue_free()

        # Now create a proper Sprite node
        visual_sprite = Sprite.new()
        visual_sprite.name = "Visual"
        # Center the sprite
        visual_sprite.centered = true
        # Position it above the NPC's origin point
        visual_sprite.position = Vector2(0, -32)

        add_child(visual_sprite)

    # Load sprite textures if we have an NPC ID
    if npc_id != "":
        _load_sprite_textures()
    else:
        # Fall back to colored rectangle if no sprite available
        visual_sprite.texture = _create_placeholder_texture()

    # Create label if not present
    if has_node("Label"):
        label = get_node("Label")
    else:
        label = Label.new()
        label.name = "Label"
        label.text = npc_name
        label.rect_position = Vector2(-40, -60)
        add_child(label)

    # Create clickable area if not present
    if not has_node("ClickableArea"):
        var area = Area2D.new()
        area.name = "ClickableArea"

        var collision = CollisionShape2D.new()
        collision.name = "CollisionShape"

        var shape = RectangleShape2D.new()
        shape.extents = Vector2(16, 24)  # Half of visual size

        collision.shape = shape
        collision.position = Vector2(0, -24)

        area.add_child(collision)
        area.connect("input_event", self, "_on_ClickableArea_input_event")

        add_child(area)

    # Update appearance based on initial state
    update_appearance()

# Create a placeholder texture when no sprite is available
func _create_placeholder_texture():
    var image = Image.new()
    image.create(32, 64, false, Image.FORMAT_RGBA8)

    # Fill with gray color
    for x in range(32):
        for y in range(64):
            image.set_pixel(x, y, Color(0.5, 0.5, 0.5, 1.0))

    var texture = ImageTexture.new()
    texture.create_from_image(image)
    return texture

# Load sprite textures from file system
func _load_sprite_textures():
    if npc_id == "":
        return

    # Base path for NPC sprites
    var base_path = "res://assets/characters/npcs/" + npc_id + "/"

    # List of states to load
    var states = ["normal", "suspicious", "hostile", "assimilated"]

    # Load each sprite
    for state in states:
        var tex_path = base_path + state + ".png"
        var dir = Directory.new()

        # Check if the file exists in the filesystem
        if dir.file_exists(tex_path):
            var texture = load(tex_path)
            if texture:
                sprite_frames[state] = texture
        else:
            print("Warning: Could not find texture for NPC " + npc_id + " state: " + state)

# Input event handler for clickable area
func _on_ClickableArea_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        var game_manager = _find_game_manager()
        if game_manager:
            game_manager.handle_npc_click(self)

# Find game manager in scene tree
func _find_game_manager():
    var root = get_tree().get_root()
    for child in root.get_children():
        if child.has_method("handle_npc_click"):
            return child

        # Try checking children too
        for grandchild in child.get_children():
            if grandchild.has_method("handle_npc_click"):
                return grandchild

    return null

# Find dialog manager in scene tree
func _find_dialog_manager():
    # First try to get it from the game manager
    var game_manager = _find_game_manager()
    if game_manager and game_manager.has_node("DialogManager"):
        return game_manager.get_node("DialogManager")

    # If not found through game manager, search the scene tree
    var root = get_tree().get_root()
    for child in root.get_children():
        for grandchild in child.get_children():
            if grandchild.get_class() == "Node" and grandchild.get_script() and grandchild.get_script().get_path().ends_with("dialog_manager.gd"):
                return grandchild

    return null

# Handle state changes
func _change_state(new_state):
    var old_state = current_state
    current_state = new_state
    
    # Handle exit from previous state
    match old_state:
        State.TALKING:
            _on_exit_talking_state()
    
    # Handle entry to new state
    match new_state:
        State.IDLE:
            _on_enter_idle_state()
        State.INTERACTING:
            _on_enter_interacting_state()
        State.TALKING:
            _on_enter_talking_state()
        State.SUSPICIOUS:
            _on_enter_suspicious_state()
        State.HOSTILE:
            _on_enter_hostile_state()
        State.FOLLOWING:
            _on_enter_following_state()
    
    # Update visual appearance
    update_appearance()
    
    emit_signal("state_changed", old_state, new_state)

# State entry handlers
func _on_enter_idle_state():
    suspicion_decay_enabled = true

func _on_enter_interacting_state():
    suspicion_decay_enabled = false

func _on_enter_talking_state():
    suspicion_decay_enabled = false
    start_dialog()

func _on_enter_suspicious_state():
    suspicion_decay_enabled = false
    become_suspicious()

func _on_enter_hostile_state():
    suspicion_decay_enabled = false

func _on_enter_following_state():
    suspicion_decay_enabled = true

# State exit handlers
func _on_exit_talking_state():
    end_dialog()
    suspicion_decay_enabled = true

# Process function based on current state
func _process(delta):
    match current_state:
        State.IDLE:
            _process_idle_state(delta)
        State.INTERACTING:
            _process_interacting_state(delta)
            # Also process observation when interacting
            process_observation(delta)
        State.TALKING:
            _process_talking_state(delta)
        State.SUSPICIOUS:
            _process_suspicious_state(delta)
        State.HOSTILE:
            _process_hostile_state(delta)
        State.FOLLOWING:
            _process_following_state(delta)

    # Process suspicion decay
    if suspicion_decay_enabled and suspicion_level > 0:
        change_suspicion(-suspicion_decay_rate * delta)

# State processing functions
func _process_idle_state(delta):
    pass

func _process_interacting_state(delta):
    pass

func _process_talking_state(delta):
    pass

func _process_suspicious_state(delta):
    pass

func _process_hostile_state(delta):
    pass

func _process_following_state(delta):
    pass

# Initialize dialog tree - should be overridden by child classes
func initialize_dialog():
    dialog_tree = {
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
                {"text": "Just looking around.", "next": "looking"},
                {"text": "Goodbye.", "next": "exit"}
            ]
        },
        "looking": {
            "text": "Feel free to look around.",
            "options": [
                {"text": "Thanks.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Goodbye.",
            "options": []
        }
    }

# Handle interactions with this NPC
func interact(verb, item = null):
    # Special case for talking
    if verb == "Talk to":
        _change_state(State.TALKING)
        return "You begin talking to " + npc_name

    # Implement the Observe verb for detecting assimilated NPCs
    if verb == "Observe":
        start_observation()
        return "You begin carefully observing " + npc_name + "..."

    # Switch to interacting state if not already talking or observing
    if current_state != State.TALKING:
        _change_state(State.INTERACTING)

    match verb:
        "Look at":
            return "You see " + npc_name + ". " + description
        "Talk to":
            _change_state(State.TALKING)
            return "You begin talking to " + npc_name
        "Observe":
            start_observation()
            return "You begin carefully observing " + npc_name + "..."
        "Use", "Pick up", "Push", "Pull", "Give":
            change_suspicion(0.1)
            return npc_name + " doesn't appreciate that."
        _:
            return "You can't " + verb + " " + npc_name

# Start observing the NPC for signs of assimilation
func start_observation():
    # Reset observation time
    observation_time = 0.0

    # Set interaction state
    _change_state(State.INTERACTING)

    # Enable observation processing
    set_process(true)

# Process observation over time
func process_observation(delta):
    # Only process if in interacting state
    if current_state != State.INTERACTING:
        return
        
    # Increment observation time
    observation_time += delta
    
    # Base detection probability on observation time
    var detection_probability = min(observation_time / observation_threshold, 1.0)
    
    # Enhanced probability if player has previously spoken with this NPC
    # (more likely to notice speech pattern changes if you have talked before)
    if current_dialog_node != "root" and current_dialog_node != "exit":
        detection_probability *= 1.2
    
    # If player has observed long enough, they might detect assimilation
    if observation_time >= observation_threshold:
        complete_observation(detection_probability)

# Complete the observation process
func complete_observation(detection_probability = 1.0):
    var success = false
    var detection_detail = ""

    # Base detection on NPC's actual assimilation status and detection probability
    if is_assimilated:
        # Use detection probability to determine success
        # Adding some randomness but weighted heavily by detection_probability
        if randf() < detection_probability * 0.8 + 0.1:
            # Player has successfully identified an assimilated NPC
            known_assimilated = true
            success = true

            # Different details based on what clues were detected
            var clue_roll = randf()
            if clue_roll < 0.4:
                detection_detail = "Their speech patterns seem oddly formal and they occasionally refer to themselves as 'we'."
            elif clue_roll < 0.7:
                detection_detail = "You notice a subtle greenish tint to their skin tone."
            else:
                detection_detail = "They hesitate unnaturally when asked about personal memories."

            # Update the NPC registry data
            var npc_data = _find_npc_data_manager()
            if npc_data and npc_data.has_method("set_known_assimilated"):
                npc_data.set_known_assimilated(npc_id, true)

    # Emit signal with result
    emit_signal("observed", success)

    # Return to idle state
    _change_state(State.IDLE)

    # Generate observation result text
    var result_text = ""
    if success:
        result_text = "You notice subtle signs that " + npc_name + " has been assimilated! " + detection_detail
    else:
        if is_assimilated:
            # They are assimilated but player failed to detect it
            result_text = "You don't notice anything unusual about " + npc_name + ", but something feels off..."
        else:
            # Not assimilated, correctly identified as normal
            result_text = "You don't notice anything unusual about " + npc_name + "."

    # Find game manager to display the result
    var game_manager = _find_game_manager()
    if game_manager and game_manager.has_method("display_message"):
        game_manager.display_message(result_text)
    else:
        print(result_text)

# Find NPC data manager in scene tree
func _find_npc_data_manager():
    # Search for a singleton or autoload named NpcData
    if get_tree().get_root().has_node("/root/NpcData"):
        return get_tree().get_root().get_node("/root/NpcData")

    # If not found as autoload, search the scene tree
    var root = get_tree().get_root()
    for child in root.get_children():
        if child.get_script() and child.get_script().get_path().ends_with("npc_data.gd"):
            return child

    return null

# Start dialog with this NPC
func start_dialog():
    current_dialog_node = "root"
    
    # Find dialog manager through game manager
    var game_manager = _find_game_manager()
    if game_manager and game_manager.has_node("DialogManager"):
        var dialog_manager = game_manager.get_node("DialogManager")
        if dialog_manager and dialog_manager.has_method("show_dialog"):
            dialog_manager.show_dialog(self)
            emit_signal("dialog_started", self)

# End dialog with this NPC
func end_dialog():
    emit_signal("dialog_ended", self)
    
    # Return to idle state if currently talking
    if current_state == State.TALKING:
        _change_state(State.IDLE)

# Get current dialog node
func get_current_dialog():
    if current_dialog_node in dialog_tree:
        # Create a copy of the dialog to avoid modifying the original
        var dialog = dialog_tree[current_dialog_node].duplicate(true)

        # Transform dialog text if NPC is assimilated
        if is_assimilated and "text" in dialog:
            dialog.text = transform_dialog_for_assimilation(dialog.text)

        # Also transform option texts if NPC is assimilated
        if is_assimilated and "options" in dialog:
            for option in dialog.options:
                if "text" in option:
                    option.text = transform_dialog_for_assimilation(option.text)

        return dialog
    return null

# Transform dialog text for assimilated NPCs
func transform_dialog_for_assimilation(original_text):
    var transformed_text = original_text

    # 1. Replace casual contractions with formal speech
    transformed_text = transformed_text.replace("don't", "do not")
    transformed_text = transformed_text.replace("can't", "cannot")
    transformed_text = transformed_text.replace("won't", "will not")
    transformed_text = transformed_text.replace("I'm", "I am")
    transformed_text = transformed_text.replace("you're", "you are")
    transformed_text = transformed_text.replace("we're", "we are")
    transformed_text = transformed_text.replace("they're", "they are")
    transformed_text = transformed_text.replace("isn't", "is not")
    transformed_text = transformed_text.replace("aren't", "are not")
    transformed_text = transformed_text.replace("wasn't", "was not")
    transformed_text = transformed_text.replace("weren't", "were not")
    transformed_text = transformed_text.replace("I'll", "I will")
    transformed_text = transformed_text.replace("you'll", "you will")
    transformed_text = transformed_text.replace("we'll", "we will")
    transformed_text = transformed_text.replace("they'll", "they will")

    # 2. Add subtle collective references
    transformed_text = transformed_text.replace("I think", "we believe")
    transformed_text = transformed_text.replace("I believe", "we believe")
    transformed_text = transformed_text.replace("in my opinion", "in our assessment")
    transformed_text = transformed_text.replace("my opinion", "our assessment")
    transformed_text = transformed_text.replace("I feel", "we feel")
    transformed_text = transformed_text.replace("I know", "we know")
    transformed_text = transformed_text.replace("I want", "we want")
    transformed_text = transformed_text.replace("I need", "we need")

    # 3. Add slight formal/technical terminology
    transformed_text = transformed_text.replace(" good ", " optimal ")
    transformed_text = transformed_text.replace(" bad ", " non-optimal ")
    transformed_text = transformed_text.replace(" great ", " superior ")
    transformed_text = transformed_text.replace(" terrible ", " highly inefficient ")
    transformed_text = transformed_text.replace(" people ", " individuals ")
    transformed_text = transformed_text.replace(" person ", " individual ")
    transformed_text = transformed_text.replace(" everyone ", " all individuals ")
    transformed_text = transformed_text.replace(" place ", " location ")
    transformed_text = transformed_text.replace(" help ", " assist ")
    transformed_text = transformed_text.replace(" look ", " observe ")
    transformed_text = transformed_text.replace(" see ", " observe ")
    transformed_text = transformed_text.replace(" understand ", " comprehend ")
    transformed_text = transformed_text.replace(" know ", " are aware of ")

    # 4. Add occasional mild glitches or repetitions (with seed based on NPC name for consistency)
    seed(npc_name.hash())

    # Occasional word repetition
    if randf() < 0.3:  # 30% chance
        var words = transformed_text.split(" ")
        if words.size() > 4:
            var random_index = randi() % (words.size() - 3) + 2
            words.insert(random_index, words[random_index-1])  # Repeat a word
            transformed_text = PoolStringArray(words).join(" ")

    # Occasional unusual pauses
    if randf() < 0.25:  # 25% chance
        var words = transformed_text.split(" ")
        if words.size() > 3:
            var random_index = randi() % (words.size() - 2) + 1
            words[random_index] = words[random_index] + "... "  # Add pause
            transformed_text = PoolStringArray(words).join(" ")

    # Reset random seed
    randomize()

    return transformed_text

# Choose dialog option
func choose_dialog_option(option_index):
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # Apply suspicion change if specified
        if "suspicion_change" in option:
            change_suspicion(option.suspicion_change)
        
        # Move to next dialog node
        current_dialog_node = option.next
        
        # Check if dialog has ended
        if current_dialog_node == "exit" or not dialog_tree.has(current_dialog_node) or dialog_tree[current_dialog_node].options.size() == 0:
            end_dialog()
            return null
        
        return get_current_dialog()
    
    return null

# Change suspicion level
func change_suspicion(amount):
    var old_level = suspicion_level
    suspicion_level = clamp(suspicion_level + amount, 0.0, 1.0)

    # Update suspicion tier
    var old_tier = current_suspicion_tier
    update_suspicion_tier()

    # Check thresholds for state changes
    if suspicion_level >= high_suspicion_threshold and old_level < high_suspicion_threshold:
        _change_state(State.SUSPICIOUS)
    elif suspicion_level >= critical_suspicion_threshold and old_level < critical_suspicion_threshold:
        _change_state(State.HOSTILE)

    # React to tier changes if talking or interacting
    if current_state == State.TALKING or current_state == State.INTERACTING:
        if old_tier != current_suspicion_tier:
            react_to_suspicion_change(old_tier, current_suspicion_tier)

    emit_signal("suspicion_changed", old_level, suspicion_level)

# Update the suspicion tier based on current level
func update_suspicion_tier():
    var old_tier = current_suspicion_tier

    if suspicion_level >= critical_suspicion_threshold:
        current_suspicion_tier = "critical"
    elif suspicion_level >= high_suspicion_threshold:
        current_suspicion_tier = "high"
    elif suspicion_level >= medium_suspicion_threshold:
        current_suspicion_tier = "medium"
    elif suspicion_level >= low_suspicion_threshold:
        current_suspicion_tier = "low"
    else:
        current_suspicion_tier = "none"

    return old_tier != current_suspicion_tier

# React to changes in suspicion tier
func react_to_suspicion_change(old_tier, new_tier):
    # Default implementation
    print(npc_name + " suspicion changed from " + old_tier + " to " + new_tier)

    # If in dialog, potentially modify dialog options based on suspicion
    if current_state == State.TALKING:
        update_dialog_for_suspicion()

        # Update the dialog UI if it's currently shown
        var dialog_manager = _find_dialog_manager()
        if dialog_manager and dialog_manager.current_npc == self:
            # Use a small delay to ensure dialog tree is updated first
            yield(get_tree().create_timer(0.1), "timeout")
            dialog_manager.show_dialog(self)

# Called when NPC becomes suspicious - override in child classes
func become_suspicious():
    # Default implementation
    print(npc_name + " has become highly suspicious!")

    # Update dialog options for suspicion
    update_dialog_for_suspicion()

    # If currently in dialog, update the dialog UI (with safety checks)
    if current_state == State.TALKING:
        var dialog_manager = _find_dialog_manager()
        if dialog_manager and is_instance_valid(dialog_manager):
            # Use a small delay to ensure dialog tree is updated first
            yield(get_tree().create_timer(0.1), "timeout")
            if is_instance_valid(dialog_manager) and dialog_manager.has_method("show_dialog"):
                dialog_manager.show_dialog(self)

# Update dialog options based on current suspicion level
func update_dialog_for_suspicion():
    # This is a template method to be overridden by child classes
    # It should modify the dialog tree based on suspicion level
    pass

# Get assimilation status
func is_assimilated():
    return is_assimilated

# Update NPC appearance based on state and suspicion
func update_appearance():
    if not visual_sprite:
        return

    # Determine which sprite to use based on state and assimilation
    var sprite_state = "normal"  # Default state

    # Choose state based on NPC state machine
    match current_state:
        State.IDLE, State.INTERACTING, State.TALKING, State.FOLLOWING:
            sprite_state = "normal"
        State.SUSPICIOUS:
            sprite_state = "suspicious"
        State.HOSTILE:
            sprite_state = "hostile"

    # If the NPC is assimilated, use the assimilated sprite variant
    # Note: This is a subtle visual change that the player needs to observe carefully
    if is_assimilated:
        # If we have a proper assimilated sprite
        if "assimilated" in sprite_frames:
            visual_sprite.texture = sprite_frames["assimilated"]
        # Otherwise fall back to making the normal sprite slightly greenish
        elif sprite_state in sprite_frames:
            visual_sprite.texture = sprite_frames[sprite_state]
            visual_sprite.modulate = Color(0.9, 1.1, 0.9, 1.0)  # Subtle green tint
        else:
            # Fallback to colored rectangle if no sprites available
            _use_fallback_appearance()
    else:
        # Not assimilated - use normal state sprites
        if sprite_state in sprite_frames:
            visual_sprite.texture = sprite_frames[sprite_state]
            visual_sprite.modulate = Color(1, 1, 1, 1)  # Normal coloring
        else:
            # Fallback to colored rectangle if no sprites available
            _use_fallback_appearance()

# Fallback to simple colored rectangles if sprites are unavailable
func _use_fallback_appearance():
    if visual_sprite:
        # Create a simple colored rectangle texture
        visual_sprite.texture = _create_placeholder_texture()

        # Color based on state and assimilation
        match current_state:
            State.IDLE:
                if is_assimilated:
                    visual_sprite.modulate = Color(0.9, 1.1, 0.9, 1.0)  # Subtle green for assimilated
                else:
                    # Subtle color variations based on suspicion tier
                    match current_suspicion_tier:
                        "none":
                            visual_sprite.modulate = Color(1, 1, 1, 1)  # Normal
                        "low":
                            visual_sprite.modulate = Color(1, 1, 0.9, 1)  # Slightly yellower
                        "medium":
                            visual_sprite.modulate = Color(1, 0.95, 0.8, 1)  # More yellow
                        "high", "critical":
                            visual_sprite.modulate = Color(1, 0.9, 0.7, 1)  # Even more yellow
            State.SUSPICIOUS:
                visual_sprite.modulate = Color(1, 0.9, 0.6, 1)  # Yellow for suspicious
            State.HOSTILE:
                visual_sprite.modulate = Color(1.1, 0.9, 0.9, 1)  # Reddish for hostile
            State.FOLLOWING:
                visual_sprite.modulate = Color(0.9, 0.9, 1.1, 1)  # Bluish for following
            State.TALKING:
                # Use suspicion tier to determine color when talking
                match current_suspicion_tier:
                    "none":
                        visual_sprite.modulate = Color(1, 1, 1, 1)  # Normal
                    "low":
                        visual_sprite.modulate = Color(1, 1, 0.9, 1)  # Slightly yellower
                    "medium":
                        visual_sprite.modulate = Color(1, 0.95, 0.8, 1)  # More yellow
                    "high":
                        visual_sprite.modulate = Color(1, 0.9, 0.7, 1)  # Orange tint
                    "critical":
                        visual_sprite.modulate = Color(1.1, 0.9, 0.9, 1)  # Red tint
