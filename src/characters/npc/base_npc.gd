extends Node2D
class_name BaseNPC

# NPC Properties
export var npc_name = "Unknown NPC"
export var description = "An unknown person"
export var is_assimilated = false

# Visual components
var visual_sprite
var label

# State Machine
enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}
var current_state = State.IDLE

# Suspicion System
var suspicion_level = 0.0  # 0.0 to 1.0
var suspicion_threshold = 0.8

# Dialog System
var dialog_tree = {}
var current_dialog_node = "root"

# Signals
signal state_changed(old_state, new_state)
signal suspicion_changed(old_level, new_level)
signal dialog_started(npc)
signal dialog_ended(npc)

func _ready():
    # Add to groups
    add_to_group("npc")
    add_to_group("interactive_object")
    
    # Setup visual representation
    _setup_visual()
    
    # Initialize dialog tree
    initialize_dialog()
    
    # Initialize state machine
    _change_state(State.IDLE)
    
    # Enable input processing
    set_process_input(true)

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
    # Create visual sprite if not present
    if has_node("Visual"):
        visual_sprite = get_node("Visual")
    else:
        visual_sprite = ColorRect.new()
        visual_sprite.name = "Visual"
        visual_sprite.rect_size = Vector2(32, 48)
        visual_sprite.rect_position = Vector2(-16, -48)
        visual_sprite.color = Color(0.7, 0.7, 0.7)  # Default gray
        add_child(visual_sprite)
    
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
    
    emit_signal("state_changed", old_state, new_state)

# State entry handlers
func _on_enter_idle_state():
    pass

func _on_enter_interacting_state():
    pass

func _on_enter_talking_state():
    start_dialog()

func _on_enter_suspicious_state():
    become_suspicious()

func _on_enter_hostile_state():
    pass

func _on_enter_following_state():
    pass

# State exit handlers
func _on_exit_talking_state():
    end_dialog()

# Process function based on current state
func _process(delta):
    match current_state:
        State.IDLE:
            _process_idle_state(delta)
        State.INTERACTING:
            _process_interacting_state(delta)
        State.TALKING:
            _process_talking_state(delta)
        State.SUSPICIOUS:
            _process_suspicious_state(delta)
        State.HOSTILE:
            _process_hostile_state(delta)
        State.FOLLOWING:
            _process_following_state(delta)

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
    # Special case for talking
    if verb == "Talk to":
        _change_state(State.TALKING)
        return "You begin talking to " + npc_name
    # Switch to interacting state if not already talking
    if current_state != State.TALKING:
        _change_state(State.INTERACTING)
    
    match verb:
        "Look at":
            return "You see " + npc_name + ". " + description
        "Talk to":
            _change_state(State.TALKING)
            return "You begin talking to " + npc_name
        "Use", "Pick up", "Push", "Pull", "Give":
            change_suspicion(0.1)
            return npc_name + " doesn't appreciate that."
        _:
            return "You can't " + verb + " " + npc_name

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
        return dialog_tree[current_dialog_node]
    return null

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
    
    # Check if NPC is now suspicious
    if suspicion_level >= suspicion_threshold and old_level < suspicion_threshold:
        _change_state(State.SUSPICIOUS)
    
    emit_signal("suspicion_changed", old_level, suspicion_level)

# Called when NPC becomes suspicious - override in child classes
func become_suspicious():
    # Default implementation
    print(npc_name + " has become suspicious!")

# Get assimilation status
func is_assimilated():
    return is_assimilated

# Update NPC appearance based on state
func update_appearance():
    if visual_sprite and visual_sprite is ColorRect:
        # Update color based on state
        match current_state:
            State.IDLE:
                if is_assimilated:
                    visual_sprite.color = Color(0.8, 0.2, 0.2)  # Red for assimilated
                else:
                    visual_sprite.color = Color(0.2, 0.8, 0.2)  # Green for unassimilated
            State.SUSPICIOUS:
                visual_sprite.color = Color(0.8, 0.8, 0.2)  # Yellow for suspicious
            State.HOSTILE:
                visual_sprite.color = Color(0.8, 0.2, 0.2)  # Red for hostile
            State.FOLLOWING:
                visual_sprite.color = Color(0.2, 0.2, 0.8)  # Blue for following
