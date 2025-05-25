# Template Interactive Object Design Document

## Overview

The Template Interactive Object system provides the foundational patterns for all interactable items in A Silent Refraction. From simple examinable objects to complex multi-state machines, this template ensures consistent behavior across all game objects while supporting the SCUMM-style verb interaction system.

## Design Philosophy

- **Verb-Driven**: All interactions through the classic verb interface
- **State Persistence**: Objects remember their state across sessions
- **Contextual Responses**: Different responses based on game state
- **Combinatorial Logic**: Objects can interact with inventory items
- **Environmental Storytelling**: Objects reveal narrative through examination

## MVP Implementation (Phase 1)

### Core Requirements

The MVP Template Interactive Object supports basic interactions needed for the Intro Quest:

1. **Basic Verbs**: LOOK, TAKE, USE
2. **Simple States**: Taken/not taken, open/closed
3. **Text Responses**: Examination and interaction feedback
4. **Group Membership**: Proper registration for interaction system
5. **Visual Representation**: Static sprite with interaction area

### Technical Specification

```gdscript
# template_interactive_object_mvp.gd
extends Node2D

class_name TemplateInteractiveObjectMVP

# Basic object properties
export var object_name: String = "Object"
export var object_id: String = "template_object"
export var takeable: bool = false
export var useable: bool = true

# Interaction responses
export var examine_text: String = "It's an object."
export var take_text: String = "You can't take that."
export var use_text: String = "Nothing happens."

# State management
var is_taken: bool = false
var is_active: bool = true

# Visual properties
export var sprite_texture: Texture
export var interaction_area: Rect2 = Rect2(0, 0, 64, 64)

signal interaction_completed(verb: String, result: String)
signal object_taken(object_id: String)
signal state_changed(new_state: Dictionary)

func _ready():
    # Add to interaction group
    add_to_group("interactive_object")
    
    # Set up visuals
    if sprite_texture:
        var sprite = Sprite.new()
        sprite.texture = sprite_texture
        sprite.centered = false
        add_child(sprite)
    
    # Set up interaction area
    var area = Area2D.new()
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.extents = interaction_area.size / 2
    collision.shape = shape
    collision.position = interaction_area.position + interaction_area.size / 2
    area.add_child(collision)
    add_child(area)
    
    # Connect for mouse detection
    area.connect("mouse_entered", self, "_on_mouse_entered")
    area.connect("mouse_exited", self, "_on_mouse_exited")

func interact(verb: String, item = null) -> void:
    if not is_active:
        emit_signal("interaction_completed", verb, "You can't do that right now.")
        return
    
    match verb:
        "look":
            _handle_look()
        "take":
            _handle_take()
        "use":
            _handle_use(item)
        _:
            _handle_default_verb(verb)

func _handle_look():
    emit_signal("interaction_completed", "look", examine_text)

func _handle_take():
    if takeable and not is_taken:
        is_taken = true
        visible = false
        emit_signal("object_taken", object_id)
        emit_signal("interaction_completed", "take", "You take the " + object_name + ".")
        emit_signal("state_changed", get_state())
    else:
        emit_signal("interaction_completed", "take", take_text)

func _handle_use(item = null):
    if item:
        # Handle item combination
        var response = _get_item_combination_response(item)
        emit_signal("interaction_completed", "use", response)
    else:
        emit_signal("interaction_completed", "use", use_text)

func _handle_default_verb(verb: String):
    emit_signal("interaction_completed", verb, 
        "You can't " + verb + " the " + object_name + ".")

func _get_item_combination_response(item: String) -> String:
    # Override in child classes for specific combinations
    return "That doesn't work."

# State management
func get_state() -> Dictionary:
    return {
        "is_taken": is_taken,
        "is_active": is_active
    }

func set_state(state: Dictionary):
    is_taken = state.get("is_taken", false)
    is_active = state.get("is_active", true)
    visible = not is_taken

# Mouse interaction
func _on_mouse_entered():
    # Highlight or show name
    pass

func _on_mouse_exited():
    # Remove highlight
    pass
```

### MVP Object Examples

```gdscript
# Example: Simple Door
extends TemplateInteractiveObjectMVP

func _ready():
    object_name = "Door"
    object_id = "exit_door"
    takeable = false
    examine_text = "A sturdy door leading to the tram station."
    use_text = "You open the door and go through."
    ._ready()

func _handle_use(item = null):
    if item == "keycard":
        emit_signal("interaction_completed", "use", 
            "You swipe the keycard. The door unlocks with a beep.")
        # Trigger scene transition
        get_tree().call_group("game_manager", "change_scene", "tram_station")
    else:
        ._handle_use(item)

# Example: Takeable Item
extends TemplateInteractiveObjectMVP

func _ready():
    object_name = "Keycard"
    object_id = "security_keycard"
    takeable = true
    examine_text = "A security keycard. Level 2 clearance."
    take_text = "You pocket the keycard."
    ._ready()

# Example: Information Terminal
extends TemplateInteractiveObjectMVP

var has_been_read: bool = false

func _ready():
    object_name = "Terminal"
    object_id = "info_terminal"
    takeable = false
    examine_text = "A public information terminal."
    use_text = "Loading information..."
    ._ready()

func _handle_use(item = null):
    if not has_been_read:
        emit_signal("interaction_completed", "use", 
            "STATION NOTICE: All personnel must report suspicious behavior to security.")
        has_been_read = true
    else:
        emit_signal("interaction_completed", "use", 
            "You've already read the current notices.")
```

### MVP Data Structure

```json
{
    "object_id": "template_object_mvp",
    "display_name": "Generic Object",
    "type": "static",
    "properties": {
        "takeable": false,
        "useable": true,
        "visible": true
    },
    "interactions": {
        "look": "It's a generic object.",
        "take": "You can't take that.",
        "use": "Nothing happens."
    },
    "states": {
        "default": {
            "visible": true,
            "active": true
        }
    }
}
```

## Full Implementation (Phase 2)

### Extended Requirements

The Full Template Interactive Object adds complex state machines and environmental integration:

1. **All Verbs**: Support for complete SCUMM verb set
2. **Complex States**: Multi-state machines with transitions
3. **Animation Support**: State-based sprite animations
4. **Sound Integration**: Interaction sounds and ambient audio
5. **Environmental Effects**: Particle systems, lighting changes
6. **Puzzle Integration**: Complex item combinations and sequences

### Technical Specification

```gdscript
# template_interactive_object_full.gd
extends Node2D

class_name TemplateInteractiveObjectFull

# Object identification
export var object_id: String = "template_object"
export var display_name: String = "Object"
export var object_type: String = "generic"  # generic, door, container, machine, etc.

# State machine
export var states: Dictionary = {}  # State definitions
export var initial_state: String = "default"
var current_state: String
var state_data: Dictionary = {}

# Interaction configuration
export var supported_verbs: Array = ["look", "use", "take"]
export var interaction_responses: Dictionary = {}
export var item_combinations: Dictionary = {}

# Visual configuration
export var state_sprites: Dictionary = {}  # {state_name: sprite_path}
export var use_animations: bool = false
export var animation_frames: Dictionary = {}

# Audio configuration
export var interaction_sounds: Dictionary = {}
export var ambient_sound: AudioStream
export var sound_radius: float = 300.0

# Environmental effects
export var particle_effects: Dictionary = {}
export var light_states: Dictionary = {}

# Components
var sprite: Sprite
var animation_player: AnimationPlayer
var audio_player: AudioStreamPlayer2D
var particle_system: CPUParticles2D
var light: Light2D
var interaction_area: Area2D

# Signals
signal interaction_started(verb: String, item: String)
signal interaction_completed(verb: String, result: String)
signal state_changed(old_state: String, new_state: String)
signal puzzle_event(event_type: String, data: Dictionary)

func _ready():
    # Initialize state
    current_state = initial_state
    
    # Set up components
    _setup_visuals()
    _setup_audio()
    _setup_interaction_area()
    _setup_environmental_effects()
    
    # Register with systems
    add_to_group("interactive_object")
    add_to_group("saveable")
    
    # Apply initial state
    _apply_state(current_state)

func _setup_visuals():
    # Sprite setup
    sprite = Sprite.new()
    sprite.centered = false
    add_child(sprite)
    
    # Animation setup
    if use_animations:
        animation_player = AnimationPlayer.new()
        add_child(animation_player)
        _create_animations()

func _setup_audio():
    audio_player = AudioStreamPlayer2D.new()
    audio_player.max_distance = sound_radius
    audio_player.attenuation = 2.0
    add_child(audio_player)
    
    # Ambient sound
    if ambient_sound:
        var ambient_player = AudioStreamPlayer2D.new()
        ambient_player.stream = ambient_sound
        ambient_player.max_distance = sound_radius * 1.5
        ambient_player.autoplay = true
        add_child(ambient_player)

func _setup_interaction_area():
    interaction_area = Area2D.new()
    var collision = CollisionShape2D.new()
    
    # Dynamic shape based on sprite
    if sprite.texture:
        var shape = RectangleShape2D.new()
        shape.extents = sprite.texture.get_size() / 2
        collision.shape = shape
        collision.position = sprite.texture.get_size() / 2
    
    interaction_area.add_child(collision)
    add_child(interaction_area)
    
    # Mouse detection
    interaction_area.connect("mouse_entered", self, "_on_mouse_entered")
    interaction_area.connect("mouse_exited", self, "_on_mouse_exited")
    interaction_area.connect("input_event", self, "_on_input_event")

func _setup_environmental_effects():
    # Particle system
    if particle_effects.size() > 0:
        particle_system = CPUParticles2D.new()
        add_child(particle_system)
    
    # Lighting
    if light_states.size() > 0:
        light = Light2D.new()
        light.texture = preload("res://src/assets/lights/object_light.png")
        add_child(light)

# Main interaction handler
func interact(verb: String, item = null) -> void:
    emit_signal("interaction_started", verb, item if item else "")
    
    # Check if verb is supported
    if not verb in supported_verbs:
        emit_signal("interaction_completed", verb, 
            "You can't " + verb + " the " + display_name + ".")
        return
    
    # Get state-specific response
    var response = _get_interaction_response(verb, item)
    
    # Play interaction sound
    _play_interaction_sound(verb)
    
    # Process state changes
    _process_interaction_state_change(verb, item)
    
    # Emit completion
    emit_signal("interaction_completed", verb, response)

func _get_interaction_response(verb: String, item = null) -> String:
    var state_responses = interaction_responses.get(current_state, {})
    
    # Check for item combination first
    if item and item_combinations.has(current_state):
        var state_combinations = item_combinations[current_state]
        if state_combinations.has(item):
            return state_combinations[item].get("response", "That doesn't work.")
    
    # Get verb response for current state
    if state_responses.has(verb):
        var response_data = state_responses[verb]
        if response_data is String:
            return response_data
        elif response_data is Dictionary:
            # Dynamic response based on conditions
            return _evaluate_conditional_response(response_data)
    
    # Default responses
    return _get_default_response(verb, item)

func _process_interaction_state_change(verb: String, item = null):
    var state_def = states.get(current_state, {})
    
    # Check for item combination state change
    if item and item_combinations.has(current_state):
        var state_combinations = item_combinations[current_state]
        if state_combinations.has(item):
            var combination = state_combinations[item]
            if combination.has("next_state"):
                change_state(combination.next_state)
                if combination.has("puzzle_event"):
                    emit_signal("puzzle_event", combination.puzzle_event, 
                        {"object": object_id, "item": item})
            return
    
    # Check for verb-triggered state change
    if state_def.has("transitions"):
        var transitions = state_def.transitions
        if transitions.has(verb):
            var new_state = transitions[verb]
            if _evaluate_transition_condition(new_state):
                change_state(new_state)

func change_state(new_state: String):
    if not states.has(new_state):
        push_error("Invalid state: " + new_state)
        return
    
    var old_state = current_state
    current_state = new_state
    
    _apply_state(new_state)
    emit_signal("state_changed", old_state, new_state)

func _apply_state(state_name: String):
    var state_def = states.get(state_name, {})
    
    # Update visuals
    if state_sprites.has(state_name):
        sprite.texture = load(state_sprites[state_name])
    
    # Update animation
    if use_animations and animation_frames.has(state_name):
        _play_state_animation(state_name)
    
    # Update particles
    if particle_effects.has(state_name):
        _apply_particle_effect(particle_effects[state_name])
    
    # Update lighting
    if light_states.has(state_name):
        _apply_light_state(light_states[state_name])
    
    # Update collision
    if state_def.has("collision_enabled"):
        interaction_area.set_deferred("monitoring", state_def.collision_enabled)

# Complex state machine example
func _create_state_machine_example():
    states = {
        "closed": {
            "transitions": {
                "use": "open",
                "open": "open"
            },
            "collision_enabled": true
        },
        "open": {
            "transitions": {
                "use": "closed",
                "close": "closed"
            },
            "collision_enabled": true
        },
        "broken": {
            "transitions": {},
            "collision_enabled": false
        },
        "locked": {
            "transitions": {
                "use_with_key": "closed"
            },
            "collision_enabled": true
        }
    }
    
    interaction_responses = {
        "closed": {
            "look": "A sturdy metal door. Currently closed.",
            "use": "You open the door.",
            "open": "You open the door."
        },
        "open": {
            "look": "The door is open, revealing a passage beyond.",
            "use": "You close the door.",
            "close": "You close the door."
        },
        "broken": {
            "look": "The door has been damaged beyond repair.",
            "use": "The broken door won't budge."
        },
        "locked": {
            "look": "The door is locked. There's a keycard reader beside it.",
            "use": "The door is locked. You need a keycard."
        }
    }
    
    item_combinations = {
        "locked": {
            "keycard": {
                "response": "You swipe the keycard. The lock disengages with a click.",
                "next_state": "closed",
                "puzzle_event": "door_unlocked"
            },
            "crowbar": {
                "response": "You try to pry open the door, but it's too sturdy.",
                "next_state": "locked"
            }
        }
    }

# Conditional response evaluation
func _evaluate_conditional_response(response_data: Dictionary) -> String:
    if response_data.has("condition"):
        var condition = response_data.condition
        
        match condition.type:
            "time_based":
                var hour = TimeManager.current_hour
                if hour >= condition.min_hour and hour <= condition.max_hour:
                    return response_data.true_response
                else:
                    return response_data.false_response
            
            "state_based":
                if state_data.get(condition.variable, false):
                    return response_data.true_response
                else:
                    return response_data.false_response
            
            "random":
                if randf() < condition.chance:
                    return response_data.responses[0]
                else:
                    return response_data.responses[1]
    
    return response_data.get("default", "...")

# Audio management
func _play_interaction_sound(verb: String):
    if interaction_sounds.has(verb):
        audio_player.stream = load(interaction_sounds[verb])
        audio_player.play()
    elif interaction_sounds.has("default"):
        audio_player.stream = load(interaction_sounds.default)
        audio_player.play()

# Particle effects
func _apply_particle_effect(effect_data: Dictionary):
    if not particle_system:
        return
    
    particle_system.emitting = effect_data.get("active", true)
    particle_system.amount = effect_data.get("amount", 50)
    particle_system.lifetime = effect_data.get("lifetime", 1.0)
    particle_system.direction = effect_data.get("direction", Vector2.UP)
    particle_system.initial_velocity = effect_data.get("velocity", 100)
    
    if effect_data.has("color"):
        particle_system.color = effect_data.color

# Lighting effects
func _apply_light_state(light_data: Dictionary):
    if not light:
        return
    
    light.enabled = light_data.get("enabled", true)
    light.energy = light_data.get("energy", 1.0)
    light.color = light_data.get("color", Color.white)
    
    if light_data.has("flicker"):
        _start_light_flicker(light_data.flicker)

# Save/Load functionality
func get_save_data() -> Dictionary:
    return {
        "object_id": object_id,
        "current_state": current_state,
        "state_data": state_data,
        "position": position
    }

func load_save_data(data: Dictionary):
    current_state = data.get("current_state", initial_state)
    state_data = data.get("state_data", {})
    position = data.get("position", position)
    _apply_state(current_state)

# Debugging
func _get_debug_info() -> String:
    return """Object: %s (ID: %s)
    State: %s
    Type: %s
    Supported Verbs: %s
    State Data: %s""" % [
        display_name, object_id, current_state, 
        object_type, supported_verbs, state_data
    ]
```

### Complex Object Examples

```gdscript
# Example: Multi-state Machine with Environmental Effects
extends TemplateInteractiveObjectFull

func _ready():
    object_id = "industrial_processor"
    display_name = "Industrial Processor"
    object_type = "machine"
    
    # Define states
    states = {
        "running": {
            "transitions": {
                "use": "stopped",
                "sabotage": "broken"
            }
        },
        "stopped": {
            "transitions": {
                "use": "running",
                "repair": "running"
            }
        },
        "broken": {
            "transitions": {
                "repair": "stopped"
            }
        },
        "assimilated": {
            "transitions": {}
        }
    }
    
    # State-specific responses
    interaction_responses = {
        "running": {
            "look": "The machine hums steadily, processing materials.",
            "use": "You shut down the processor.",
            "listen": "A steady mechanical rhythm fills the air."
        },
        "stopped": {
            "look": "The processor is idle and quiet.",
            "use": "You start up the processor.",
            "listen": "The machine is silent."
        },
        "broken": {
            "look": "Sparks fly from damaged components. It's completely broken.",
            "use": "The machine is too damaged to operate.",
            "listen": "Electrical crackling and grinding noises."
        },
        "assimilated": {
            "look": {
                "condition": {"type": "random", "chance": 0.5},
                "responses": [
                    "Strange organic matter grows on the machine's surface.",
                    "The machine pulses with an unnatural rhythm."
                ]
            },
            "use": "You recoil from the slimy surface.",
            "listen": "An unsettling organic squelching mixed with mechanical sounds."
        }
    }
    
    # Environmental effects per state
    particle_effects = {
        "running": {
            "active": true,
            "amount": 20,
            "lifetime": 2.0,
            "direction": Vector2.UP,
            "velocity": 50
        },
        "broken": {
            "active": true,
            "amount": 50,
            "lifetime": 0.5,
            "direction": Vector2(randf() * 2 - 1, -1),
            "velocity": 200,
            "color": Color(1, 0.8, 0)  # Sparks
        },
        "assimilated": {
            "active": true,
            "amount": 10,
            "lifetime": 3.0,
            "direction": Vector2.DOWN,
            "velocity": 20,
            "color": Color(0.6, 1, 0.6)  # Green goo drips
        }
    }
    
    # Sound effects
    interaction_sounds = {
        "use": "res://src/assets/audio/effects/button_press.ogg",
        "repair": "res://src/assets/audio/effects/repair_tool.ogg"
    }
    
    # Ambient sounds per state
    state_ambient_sounds = {
        "running": "res://src/assets/audio/ambient/machine_running.ogg",
        "broken": "res://src/assets/audio/ambient/electrical_sparking.ogg",
        "assimilated": "res://src/assets/audio/ambient/organic_machine.ogg"
    }
    
    ._ready()

# Example: Puzzle Container
extends TemplateInteractiveObjectFull

var combination: Array = [3, 7, 1, 9]
var entered_digits: Array = []

func _ready():
    object_id = "puzzle_safe"
    display_name = "Electronic Safe"
    object_type = "container"
    
    states = {
        "locked": {
            "transitions": {}  # Only opens via correct combination
        },
        "open": {
            "transitions": {
                "close": "locked"
            }
        }
    }
    
    # Custom interaction handling for number pad
    supported_verbs = ["look", "use", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    interaction_responses = {
        "locked": {
            "look": "A high-tech safe with a digital keypad. It requires a 4-digit code.",
            "use": "Enter the combination using the number pad."
        },
        "open": {
            "look": "The safe is open, revealing its contents.",
            "use": "You close the safe. It locks automatically."
        }
    }
    
    ._ready()

func interact(verb: String, item = null) -> void:
    # Handle number input
    if verb.is_valid_integer() and current_state == "locked":
        _handle_digit_input(verb.to_int())
        return
    
    .interact(verb, item)

func _handle_digit_input(digit: int):
    entered_digits.append(digit)
    
    if entered_digits.size() < 4:
        emit_signal("interaction_completed", str(digit), 
            "You press %d. %d digits entered." % [digit, entered_digits.size()])
    else:
        # Check combination
        if _check_combination():
            change_state("open")
            emit_signal("interaction_completed", str(digit), 
                "The safe beeps and opens with a click!")
            emit_signal("puzzle_event", "safe_opened", {"object": object_id})
        else:
            entered_digits.clear()
            emit_signal("interaction_completed", str(digit), 
                "BZZT! Incorrect combination. Try again.")
```

### Full Data Structure

```json
{
    "object_id": "template_object_full",
    "display_name": "Complex Machine",
    "type": "machine",
    "properties": {
        "initial_state": "inactive",
        "supported_verbs": ["look", "use", "repair", "sabotage"],
        "requires_power": true
    },
    "states": {
        "inactive": {
            "sprite": "machine_off.png",
            "transitions": {
                "use": {"condition": "has_power", "next": "active"},
                "repair": {"condition": "is_broken", "next": "inactive"}
            }
        },
        "active": {
            "sprite": "machine_on.png",
            "animation": "running",
            "particles": "steam",
            "ambient_sound": "machine_hum.ogg",
            "transitions": {
                "use": {"next": "inactive"},
                "sabotage": {"next": "broken"}
            }
        },
        "broken": {
            "sprite": "machine_broken.png",
            "particles": "sparks",
            "ambient_sound": "electrical_buzz.ogg",
            "transitions": {
                "repair": {"condition": "has_repair_skill", "next": "inactive"}
            }
        }
    },
    "interactions": {
        "inactive": {
            "look": "The machine sits idle, waiting to be activated.",
            "use": {"condition": "has_power", 
                    "true": "You flip the switch. The machine whirs to life.",
                    "false": "Nothing happens. The machine needs power."}
        },
        "active": {
            "look": "The machine operates smoothly, producing a steady hum.",
            "use": "You power down the machine."
        },
        "broken": {
            "look": "Smoke rises from the damaged machinery.",
            "repair": {"condition": "has_repair_skill",
                      "true": "You expertly repair the damaged components.",
                      "false": "You lack the skill to fix this."}
        }
    },
    "item_combinations": {
        "broken": {
            "wrench": {
                "response": "You tighten some loose bolts, but more work is needed.",
                "state_change": false
            },
            "repair_kit": {
                "response": "Using the repair kit, you fix the machine.",
                "state_change": "inactive",
                "consumes_item": true
            }
        }
    },
    "environmental_effects": {
        "active": {
            "particles": {
                "type": "steam",
                "rate": 20,
                "direction": "up"
            },
            "lighting": {
                "color": "#7b8e95",
                "energy": 0.8,
                "flicker": false
            }
        },
        "broken": {
            "particles": {
                "type": "sparks",
                "rate": 50,
                "direction": "random"
            },
            "lighting": {
                "color": "#907577",
                "energy": 1.2,
                "flicker": true
            }
        }
    }
}
```

## Implementation Guidelines

### MVP Phase Guidelines

1. **Start Simple**: Basic look/take/use functionality
2. **Text-Only Feedback**: No complex visuals or audio yet
3. **Binary States**: Simple on/off, taken/not taken
4. **Test Core Verbs**: Ensure verb system integration works
5. **Document Patterns**: Note common interaction types

### Full Phase Guidelines

1. **Rich States**: Complex state machines with conditions
2. **Environmental Integration**: Particles, sounds, lighting
3. **Puzzle Support**: Item combinations and sequences
4. **Performance**: Optimize for many objects per scene
5. **Save System**: Full state persistence

## Content Creation Workflow

### MVP Workflow
1. Extend template_interactive_object_mvp.gd
2. Set object properties and verb responses
3. Define sprite and interaction area
4. Test all supported verbs
5. Verify state changes work

### Full Workflow
1. Extend template_interactive_object_full.gd
2. Design state machine and transitions
3. Create state-specific sprites/animations
4. Define all verb responses per state
5. Add environmental effects
6. Configure item combinations
7. Test all state transitions
8. Verify save/load functionality

## Testing Strategy

### MVP Testing
```gdscript
func test_basic_interaction():
    var obj = TemplateInteractiveObjectMVP.new()
    
    # Test verb responses
    obj.interact("look")
    assert(obj.get_signal_connection_list("interaction_completed").size() > 0)
    
    # Test take functionality
    obj.takeable = true
    obj.interact("take")
    assert(obj.is_taken == true)
    assert(obj.visible == false)
```

### Full Testing
```gdscript
func test_state_machine():
    var obj = TemplateInteractiveObjectFull.new()
    
    # Test state transitions
    obj.current_state = "closed"
    obj.interact("use")
    assert(obj.current_state == "open")
    
    # Test conditional transitions
    obj.current_state = "locked"
    obj.interact("use", "wrong_key")
    assert(obj.current_state == "locked")
    
    obj.interact("use", "correct_key")
    assert(obj.current_state == "closed")
```

## Performance Considerations

- **Update Frequency**: Only update active effects when in view
- **Audio Range**: Limit ambient sound radius for performance
- **Particle Limits**: Cap particle counts based on quality settings
- **State Caching**: Cache complex state calculations
- **LOD System**: Reduce detail for distant objects

## Integration Points

- **VerbUI**: Receives verb selections for objects
- **InventorySystem**: Provides items for combinations
- **GameManager**: Handles scene transitions from doors
- **SaveManager**: Persists object states
- **AudioManager**: Manages positional audio
- **ParticleManager**: Optimizes particle effects
- **EventSystem**: Triggers puzzle and story events

## Common Object Types

### Doors
- States: locked, closed, open, broken
- Transitions via keys, keycards, puzzles

### Containers
- States: locked, closed, open, empty
- Can contain inventory items

### Machines
- States: off, running, broken, overloaded
- Often tied to puzzle mechanics

### Terminals
- States: off, login, active, error
- Provide information or control systems

### Switches/Buttons
- States: off, on, disabled
- Control other objects or systems

## Future Enhancements

- **Physics Integration**: Objects that can be pushed/pulled
- **Destruction System**: Breakable objects with debris
- **Crafting Support**: Combine objects to create new ones
- **AI Interaction**: NPCs can use objects too
- **Network State**: Synchronized object states in multiplayer