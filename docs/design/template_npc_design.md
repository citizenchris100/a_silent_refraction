# Template NPC Design Document

## Overview

The Template NPC serves as the canonical implementation pattern for all Non-Player Characters in A Silent Refraction. This document defines both the MVP (Minimal Viable Product) and Full implementations, ensuring systematic and efficient NPC creation throughout development. This template is fully aligned with the BaseNPC system architecture documented in `docs/systems/base_npc_system.md`.

## Design Philosophy

- **Reusability**: One template, hundreds of NPCs
- **Modularity**: Clear separation between behavior and content
- **Extensibility**: MVP foundation supports full features without rework
- **Data-Driven**: Personality and behavior defined by parameters, not code
- **BaseNPC Compliance**: Follows established system patterns and conventions

## MVP Implementation (Phase 1)

### Core Requirements

The MVP Template NPC must demonstrate basic functionality sufficient for the Intro Quest:

1. **State Management**: Simple two-state system (IDLE, TALKING)
2. **Basic Interaction**: Respond to player interaction
3. **Simple Dialog**: Greeting and 1-2 conversation topics
4. **Visual Representation**: Static sprite with correct positioning
5. **Group Membership**: Proper group assignment for interaction system

### Technical Specification

```gdscript
# template_npc_mvp.gd
extends "res://src/characters/npc/base_npc.gd"

# Identity properties (aligned with BaseNPC)
export var npc_name: String = "Template NPC"
export var npc_id: String = "template_npc"
export var description: String = "A station resident."

# Visual components
var visual_sprite: Sprite
var sprite_frames: Dictionary = {
    "idle": "res://src/assets/characters/template_npc/idle.png",
    "talking": "res://src/assets/characters/template_npc/talking.png"
}

# Dialog properties
export var initial_greeting: String = "Hello there."
export var dialog_topics: Dictionary = {
    "station": "It's a nice station. I work here.",
    "self": "I'm just a regular person doing my job."
}

# State tracking
var has_greeted: bool = false

func _ready():
    # Add to required groups (BaseNPC requirement)
    add_to_group("npc")
    add_to_group("interactive_object")
    
    # Set up visual sprite
    visual_sprite = Sprite.new()
    visual_sprite.texture = load(sprite_frames.idle)
    add_child(visual_sprite)
    
    # Call parent ready - REQUIRED
    ._ready()
    
    # Set initial state
    _change_state(State.IDLE)

# State handler functions following BaseNPC pattern
func _on_enter_idle_state():
    if visual_sprite and sprite_frames.has("idle"):
        visual_sprite.texture = load(sprite_frames.idle)

func _on_exit_idle_state():
    pass

func _process_idle_state(delta):
    # MVP doesn't need idle processing
    pass

func _on_enter_talking_state():
    if visual_sprite and sprite_frames.has("talking"):
        visual_sprite.texture = load(sprite_frames.talking)

func _on_exit_talking_state():
    pass

func _process_talking_state(delta):
    # MVP doesn't need talking processing
    pass

# Interaction handling (BaseNPC compatible)
func interact(verb: String, item = null) -> void:
    match verb:
        "talk":
            if current_state != State.TALKING:
                _change_state(State.TALKING)
                _handle_talk_interaction()
        "look":
            emit_signal("interaction_finished", "look", description)
        _:
            emit_signal("interaction_finished", verb, 
                "You can't " + verb + " " + npc_name + ".")

func _handle_talk_interaction():
    if not has_greeted:
        emit_signal("dialog_started", initial_greeting, [])
        has_greeted = true
    else:
        var options = []
        for topic in dialog_topics:
            options.append({"text": "Ask about " + topic, "action": topic})
        options.append({"text": "Goodbye", "action": "end"})
        emit_signal("dialog_started", "What would you like to know?", options)

func handle_dialog_choice(choice: String):
    if choice == "end":
        _change_state(State.IDLE)
        emit_signal("dialog_ended")
    elif choice in dialog_topics:
        emit_signal("dialog_started", dialog_topics[choice], 
            [{"text": "I see...", "action": "end"}])
```

### MVP Data Structure

```json
{
    "npc_id": "template_npc_mvp",
    "display_name": "Template NPC",
    "role": "Station Resident",
    "location": "test_district",
    "personality": {
        "friendliness": 0.7
    },
    "dialog": {
        "greeting": "Hello there.",
        "topics": {
            "station": "It's a nice station. I work here.",
            "self": "I'm just a regular person doing my job."
        }
    }
}
```

### MVP Testing Checklist

- [ ] NPC appears in correct location
- [ ] Player can interact with TALK verb
- [ ] Greeting displays on first interaction
- [ ] Topic menu appears on subsequent talks
- [ ] Dialog choices work correctly
- [ ] State transitions properly between IDLE and TALKING
- [ ] NPC responds to LOOK verb
- [ ] Groups are properly assigned

## Full Implementation (Phase 2)

### Extended Requirements

The Full Template NPC expands to support all game systems:

1. **Complete State Machine**: IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING
2. **Schedule System**: Movement between locations based on time
3. **Suspicion Mechanics**: Track and escalate player suspicion with tiers
4. **Assimilation System**: Can be assimilated with behavioral changes
5. **Observation System**: Player can detect assimilation through observation
6. **Procedural Dialog**: Context-aware, personality-driven responses
7. **Quest Integration**: Can give, participate in, and react to quests
8. **Memory System**: Remember previous interactions

### Technical Specification

```gdscript
# template_npc_full.gd
extends "res://src/characters/npc/base_npc.gd"

# Note: State enum is inherited from BaseNPC
# enum State {IDLE, INTERACTING, TALKING, SUSPICIOUS, HOSTILE, FOLLOWING}

# Identity properties (aligned with BaseNPC)
export var npc_name: String = "Template Character"
export var npc_id: String = "template_npc_full"
export var description: String = "A station employee going about their business."
export var is_assimilated: bool = false

# Visual components
var visual_sprite: Sprite
var sprite_frames: Dictionary = {
    "idle": "res://src/assets/characters/{npc_id}/idle.png",
    "talking": "res://src/assets/characters/{npc_id}/talking.png",
    "suspicious": "res://src/assets/characters/{npc_id}/suspicious.png",
    "hostile": "res://src/assets/characters/{npc_id}/hostile.png",
    "assimilated_idle": "res://src/assets/characters/{npc_id}/assimilated_idle.png"
}

# Suspicion properties (inherited from BaseNPC)
# var suspicion_level: float = 0.0
# var low_suspicion_threshold: float = 0.3
# var medium_suspicion_threshold: float = 0.5
# var high_suspicion_threshold: float = 0.8
# var critical_suspicion_threshold: float = 0.9
# var suspicion_decay_rate: float = 0.05
# var suspicion_decay_enabled: bool = true
# var current_suspicion_tier: String = "none"

# Observation system (inherited from BaseNPC)
# var known_assimilated: bool = false
# var observation_time: float = 0.0
# var observation_threshold: float = 3.0

# Personality parameters (0.0 to 1.0)
export var personality: Dictionary = {
    "formality": 0.5,
    "suspicion": 0.3,
    "friendliness": 0.7,
    "verbosity": 0.5,
    "job_focus": 0.8,
    "loyalty": 0.6,
    "curiosity": 0.4
}

# Memory system
var interaction_memory: Dictionary = {
    "times_talked": 0,
    "topics_discussed": [],
    "given_quests": [],
    "player_reputation": 0.0,
    "last_interaction_day": -1
}

# Schedule system
var schedule: Array = []
var current_schedule_index: int = 0
var schedule_override: Dictionary = {}

# Dialog generation
var dialog_generator: DialogGenerator

func _ready():
    # Initialize systems
    dialog_generator = DialogGenerator.new()
    dialog_generator.personality = personality
    
    # Load schedule from data
    _load_schedule()
    
    # Set up state machine
    _initialize_state_machine()
    
    # Connect to time system
    TimeManager.connect("hour_changed", self, "_on_hour_changed")
    TimeManager.connect("day_changed", self, "_on_day_changed")
    
    # Call parent
    ._ready()

func interact(verb: String, item = null) -> void:
    # Update memory
    interaction_memory.last_interaction_day = TimeManager.current_day
    
    match verb:
        "talk":
            if current_state != State.TALKING:
                _change_state(State.TALKING)
                _handle_talk_interaction()
        "look":
            emit_signal("interaction_finished", "look", description)
        "observe":
            if current_state != State.INTERACTING:
                _change_state(State.INTERACTING)
                _handle_observe_interaction()
        "give":
            _handle_give_interaction(item)
        _:
            _handle_default_interaction(verb)

func _handle_talk_interaction():
    if current_state == State.HOSTILE:
        emit_signal("interaction_finished", "talk", 
            dialog_generator.generate_hostile_response())
        return
    
    interaction_memory.times_talked += 1
    
    # Generate contextual dialog
    var dialog_context = {
        "time_of_day": TimeManager.get_time_period(),
        "location": get_current_district(),
        "player_reputation": interaction_memory.player_reputation,
        "is_assimilated": is_assimilated,
        "suspicion_level": suspicion_level,
        "current_events": EventManager.get_active_events()
    }
    
    var response = dialog_generator.generate_dialog(dialog_context, interaction_memory)
    var options = _generate_dialog_options(dialog_context)
    
    emit_signal("dialog_started", response, options)

func _handle_observe_interaction():
    # Observation system implementation (aligned with BaseNPC)
    emit_signal("interaction_started", "observe")
    
    # Player is observing - increase suspicion slightly
    change_suspicion(0.02)
    
    # Show initial observation message
    var observe_text = "You carefully observe " + npc_name + "..."
    emit_signal("interaction_finished", "observe", observe_text)

# State handler methods following BaseNPC pattern
func _on_enter_idle_state():
    suspicion_decay_enabled = true
    _update_visual_appearance()

func _on_exit_idle_state():
    pass

func _process_idle_state(delta):
    # Handle suspicion decay in idle state
    if suspicion_decay_enabled and suspicion_level > 0:
        change_suspicion(-suspicion_decay_rate * delta)

func _on_enter_interacting_state():
    suspicion_decay_enabled = false
    observation_time = 0.0

func _on_exit_interacting_state():
    # Check if observation was successful
    if observation_time >= observation_threshold:
        _attempt_assimilation_detection()

func _process_interacting_state(delta):
    # Process observation
    observation_time += delta
    
    # Periodic observation updates
    if int(observation_time) > int(observation_time - delta):
        var messages = [
            "You notice their movement patterns...",
            "You study their facial expressions...",
            "You listen to their speech patterns..."
        ]
        emit_signal("interaction_update", messages[min(int(observation_time) - 1, messages.size() - 1)])

func _on_enter_talking_state():
    suspicion_decay_enabled = false
    _update_visual_appearance()

func _on_exit_talking_state():
    pass

func _process_talking_state(delta):
    # Dialog system handles talking state
    pass

func _on_enter_suspicious_state():
    suspicion_decay_enabled = true
    _update_visual_appearance()
    emit_signal("npc_became_suspicious", npc_id)

func _on_exit_suspicious_state():
    pass

func _process_suspicious_state(delta):
    # Slower suspicion decay when suspicious
    if suspicion_decay_enabled and suspicion_level > 0:
        change_suspicion(-suspicion_decay_rate * 0.5 * delta)

func _on_enter_hostile_state():
    suspicion_decay_enabled = false
    _update_visual_appearance()
    emit_signal("npc_became_hostile", npc_id)
    _alert_nearby_security()

func _on_exit_hostile_state():
    pass

func _process_hostile_state(delta):
    # Hostile NPCs may call for help or attack
    pass

func _on_enter_following_state():
    suspicion_decay_enabled = true
    # Set up following behavior
    pass

func _on_exit_following_state():
    # Clean up following behavior
    pass

func _process_following_state(delta):
    # Update position to follow player
    # This would be implemented based on pathfinding
    pass

func _update_schedule():
    var current_hour = TimeManager.current_hour
    
    # Check for overrides (events, assimilation, etc)
    if schedule_override.has(current_hour):
        _move_to_location(schedule_override[current_hour])
        return
    
    # Follow normal schedule
    for entry in schedule:
        if current_hour >= entry.start_hour and current_hour < entry.end_hour:
            if entry.location != get_current_location():
                _move_to_location(entry.location)
            current_state = entry.activity_state
            break

# Observation detection system (aligned with BaseNPC)
func _attempt_assimilation_detection():
    if not is_assimilated:
        emit_signal("interaction_finished", "observe", 
            npc_name + " seems normal. Nothing suspicious detected.")
        return
    
    # Calculate detection probability
    var base_probability = 0.4
    if interaction_memory.times_talked > 0:
        base_probability += 0.2  # Better chance if talked before
    
    if randf() < base_probability:
        # Successful detection
        known_assimilated = true
        var detection_messages = [
            "Their speech patterns seem... off. Collective pronouns slip in.",
            "You notice a subtle green tint to their skin.",
            "Their movements are too synchronized, too perfect.",
            "Something in their eyes... a distant, shared consciousness."
        ]
        var message = detection_messages[randi() % detection_messages.size()]
        emit_signal("interaction_finished", "observe", 
            "[color=yellow]" + message + "[/color]\n" + npc_name + " has been assimilated!")
        emit_signal("assimilation_detected", npc_id)
    else:
        # Failed detection
        emit_signal("interaction_finished", "observe", 
            "You can't quite tell... something might be off, but you're not sure.")

func _update_visual_appearance():
    if not visual_sprite:
        return
    
    var sprite_key = "idle"
    
    # Determine sprite based on state and conditions
    match current_state:
        State.IDLE:
            if is_assimilated and sprite_frames.has("assimilated_idle"):
                sprite_key = "assimilated_idle"
            else:
                sprite_key = "idle"
        State.TALKING:
            sprite_key = "talking"
        State.SUSPICIOUS:
            sprite_key = "suspicious" if sprite_frames.has("suspicious") else "idle"
        State.HOSTILE:
            sprite_key = "hostile" if sprite_frames.has("hostile") else "suspicious"
    
    if sprite_frames.has(sprite_key):
        visual_sprite.texture = load(sprite_frames[sprite_key].replace("{npc_id}", npc_id))
    
    # Apply assimilation tint if needed
    if is_assimilated and not sprite_frames.has("assimilated_idle"):
        visual_sprite.modulate = Color(0.8, 1.0, 0.8)  # Subtle green tint

func handle_assimilation():
    is_assimilated = true
    
    # Modify personality
    personality.friendliness *= 0.7
    personality.suspicion *= 1.5
    personality.loyalty = 0.0  # No loyalty to humans
    
    # Change dialog patterns
    dialog_generator.set_assimilated_mode(true)
    
    # Update visual appearance
    _update_visual_appearance()
    
    # Modify schedule to be more suspicious
    _generate_assimilated_schedule()
    
    emit_signal("npc_assimilated", npc_id)

# Advanced dialog generation
func _generate_dialog_options(context: Dictionary) -> Array:
    var options = []
    
    # Generate topics based on context and personality
    if context.time_of_day == "morning" and personality.friendliness > 0.6:
        options.append({"text": "Good morning! How are you?", 
                       "action": "friendly_greeting",
                       "suspicion_change": -0.05})
    
    # Job-related topics
    if personality.job_focus > 0.7:
        options.append({"text": "Ask about their work", 
                       "action": "work_topic",
                       "suspicion_change": 0.0})
    
    # Investigation options (risky)
    if interaction_memory.times_talked > 2:
        options.append({"text": "Have you noticed anything strange?", 
                       "action": "investigate",
                       "suspicion_change": 0.15})
    
    # Quest-related options
    for quest_id in QuestManager.get_active_quests():
        var quest_option = _generate_quest_option(quest_id)
        if quest_option:
            options.append(quest_option)
    
    # Always have goodbye
    options.append({"text": "Goodbye", "action": "end"})
    
    return options
```

### Full Data Structure

```json
{
    "npc_id": "template_npc_full",
    "display_name": "Jordan Smith",
    "role": "Dock Worker",
    "department": "shipping",
    "location": "spaceport_loading_dock",
    "personality": {
        "formality": 0.3,
        "suspicion": 0.4,
        "friendliness": 0.6,
        "verbosity": 0.5,
        "job_focus": 0.9,
        "loyalty": 0.7,
        "curiosity": 0.3
    },
    "schedule": [
        {
            "start_hour": 6,
            "end_hour": 8,
            "location": "barracks_room_103",
            "activity": "morning_routine"
        },
        {
            "start_hour": 8,
            "end_hour": 17,
            "location": "spaceport_loading_dock",
            "activity": "working"
        },
        {
            "start_hour": 17,
            "end_hour": 19,
            "location": "mall_bar",
            "activity": "relaxing"
        },
        {
            "start_hour": 19,
            "end_hour": 22,
            "location": "barracks_room_103",
            "activity": "evening_routine"
        }
    ],
    "dialog_templates": {
        "greetings": {
            "morning": ["Morning. Early shift today.", "Hey, you're up early."],
            "afternoon": ["Afternoon. Busy day at the docks.", "Oh, hey there."],
            "evening": ["Evening. Just got off work.", "Long day..."]
        },
        "work_responses": [
            "Loading cargo all day. Same as always.",
            "New shipment came in. Lots of heavy lifting.",
            "Boss is riding us hard about efficiency."
        ],
        "suspicion_responses": [
            "Why are you asking so many questions?",
            "That's none of your business.",
            "I think you should leave."
        ]
    },
    "quest_participation": {
        "can_give_quests": true,
        "quest_ids": ["dock_worker_help", "suspicious_cargo"],
        "quest_role": {
            "missing_manifest": "information_source",
            "union_organization": "potential_member"
        }
    },
    "assimilation_behavior": {
        "resistance": 0.7,
        "spread_rate": 0.3,
        "target_priority": ["coworkers", "friends", "strangers"]
    }
}
```

### Procedural Dialog Generation

```gdscript
class DialogGenerator:
    var personality: Dictionary
    var is_assimilated: bool = false
    
    func generate_dialog(context: Dictionary, memory: Dictionary) -> String:
        # Select base template based on context
        var template_category = _get_template_category(context, memory)
        var base_template = _select_template(template_category)
        
        # Apply personality modifiers
        var modified_text = _apply_personality(base_template)
        
        # Substitute context variables
        var final_text = _substitute_variables(modified_text, context)
        
        # Add verbal tics or patterns
        if is_assimilated:
            final_text = _add_assimilation_tells(final_text)
        
        return final_text
    
    func _get_template_category(context: Dictionary, memory: Dictionary) -> String:
        # Determine appropriate response category
        if memory.times_talked == 0:
            return "first_meeting"
        elif context.suspicion_level > 0.5:
            return "suspicious"
        elif context.time_of_day == "morning":
            return "morning_greeting"
        else:
            return "general_response"
    
    func _apply_personality(template: String) -> String:
        var result = template
        
        # Formality adjustments
        if personality.formality < 0.3:
            result = _make_casual(result)
        elif personality.formality > 0.7:
            result = _make_formal(result)
        
        # Verbosity adjustments
        if personality.verbosity > 0.7:
            result = _add_elaboration(result)
        elif personality.verbosity < 0.3:
            result = _make_terse(result)
        
        return result
```

### Memory and Relationship System

```gdscript
class NPCMemory:
    var short_term: Array = []  # Recent interactions (last 24 hours)
    var long_term: Dictionary = {}  # Persistent memories
    var relationships: Dictionary = {}  # Other NPCs and player
    
    func remember_interaction(actor: String, action: String, outcome: String):
        var memory = {
            "actor": actor,
            "action": action,
            "outcome": outcome,
            "time": TimeManager.current_time,
            "location": LocationManager.current_location
        }
        
        short_term.append(memory)
        
        # Move to long-term if significant
        if _is_significant(memory):
            if not long_term.has(actor):
                long_term[actor] = []
            long_term[actor].append(memory)
    
    func get_relationship_status(actor: String) -> float:
        if not relationships.has(actor):
            return 0.0
        return relationships[actor]
    
    func modify_relationship(actor: String, change: float):
        if not relationships.has(actor):
            relationships[actor] = 0.0
        relationships[actor] = clamp(relationships[actor] + change, -1.0, 1.0)
```

### Testing Framework

```gdscript
# Full implementation testing
class TemplateNPCTest:
    var test_npc: TemplateNPC
    
    func run_all_tests():
        test_state_transitions()
        test_schedule_system()
        test_dialog_generation()
        test_suspicion_mechanics()
        test_assimilation_behavior()
        test_memory_system()
        test_quest_integration()
    
    func test_state_transitions():
        # Test all possible state transitions
        assert(test_npc.current_state == State.IDLE)
        test_npc.interact("talk")
        assert(test_npc.current_state == State.TALKING)
        
        # Test observation state
        test_npc._change_state(State.IDLE)
        test_npc.interact("observe")
        assert(test_npc.current_state == State.INTERACTING)
        
        # Test suspicion transitions
        test_npc.suspicion_level = 0.85
        test_npc.update_suspicion_tier()
        assert(test_npc.current_state == State.SUSPICIOUS)
    
    func test_observation_system():
        # Test observation mechanics
        test_npc.is_assimilated = true
        test_npc._change_state(State.INTERACTING)
        
        # Simulate observation time
        for i in range(4):
            test_npc._process_interacting_state(1.0)
        
        assert(test_npc.observation_time >= test_npc.observation_threshold)
        
        # Test detection
        test_npc._on_exit_interacting_state()
        # Detection is probabilistic, so we test the mechanism exists
        
    func test_schedule_system():
        # Test schedule following
        TimeManager.set_time(8, 0)
        test_npc._update_schedule()
        assert(test_npc.get_current_location() == "spaceport_loading_dock")
        # ... more schedule tests
```

## Implementation Guidelines

### MVP Phase Guidelines

1. **Keep It Simple**: Only implement what's needed for Intro Quest
2. **Hard-Code Content**: Don't build generation systems yet
3. **Test One Thing**: Each NPC tests one aspect thoroughly
4. **Document Patterns**: Note what works for full implementation

### Full Phase Guidelines

1. **Data-Driven Design**: Everything configurable via JSON
2. **Procedural First**: Generate content where possible
3. **Personality Matters**: Let personality drive behavior
4. **State Persistence**: Everything important must save
5. **Performance Conscious**: 150 NPCs must run smoothly

## Content Creation Workflow

### MVP Workflow
1. Copy template_npc_mvp.gd
2. Change name, role, and greeting
3. Add 1-2 specific dialog topics
4. Place in test scene
5. Verify all interactions work

### Full Workflow
1. Copy template_npc_full.gd
2. Define personality parameters
3. Create schedule in JSON
4. Define dialog templates for personality
5. Set up quest participation
6. Test all state transitions
7. Verify schedule behavior
8. Test assimilation mechanics

## Performance Considerations

- **Update Frequency**: NPCs only update when in player's district
- **Dialog Caching**: Generated dialog cached for 1 game hour
- **LOD System**: Distant NPCs use simplified behavior
- **Memory Limits**: Short-term memory capped at 20 entries

## Integration Points

- **DialogManager**: Handles UI display of generated dialog
- **QuestManager**: Tracks NPC involvement in quests
- **TimeManager**: Drives schedule updates
- **EventManager**: Notifies NPCs of world events
- **AssimilationManager**: Coordinates spread mechanics
- **SaveManager**: Persists NPC state between sessions

## Future Considerations

- **Emotion System**: More complex emotional states
- **Group Dynamics**: NPCs influence each other
- **Dynamic Personalities**: Personalities change over time
- **Advanced Memory**: Pattern recognition in player behavior
- **Procedural Backstories**: Generated life histories