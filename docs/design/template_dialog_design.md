# Template Dialog Design Document

## Overview

The Template Dialog system provides reusable patterns for creating consistent, personality-driven conversations throughout A Silent Refraction. This document covers both MVP (simple hard-coded) and Full (procedurally generated) implementations, with a focus on the innovative guideline-driven procedural generation system.

## Design Philosophy

- **Personality-Driven**: Dialog reflects NPC personality parameters
- **Context-Aware**: Responses adapt to time, location, and game state
- **Procedural Generation**: Minimize hand-written dialog through smart templates
- **Suspicion Integration**: Every conversation can affect suspicion levels
- **Reusable Patterns**: Common conversation structures that work across all NPCs

## MVP Implementation (Phase 1)

### Core Requirements

The MVP Template Dialog demonstrates basic conversation functionality for the Intro Quest:

1. **Simple Structure**: Greeting → Topics → Goodbye
2. **Basic Branching**: 2-3 conversation topics
3. **State Tracking**: Remember if player has talked before
4. **Hard-Coded Content**: No procedural generation yet
5. **Suspicion Hooks**: Basic framework for suspicion changes

### Technical Specification

```gdscript
# template_dialog_mvp.gd
extends Resource

class_name TemplateDialogMVP

# Basic dialog tree structure
export var dialog_tree: Dictionary = {
    "root": {
        "text": "Hello there. Can I help you?",
        "options": [
            {"text": "Tell me about this place", "next": "about_location"},
            {"text": "Who are you?", "next": "about_self"},
            {"text": "Goodbye", "next": "end"}
        ]
    },
    "about_location": {
        "text": "It's a space station. We trade goods here.",
        "options": [
            {"text": "Interesting...", "next": "root"}
        ]
    },
    "about_self": {
        "text": "I work here. Been here for years.",
        "options": [
            {"text": "I see...", "next": "root"}
        ]
    },
    "end": {
        "text": "See you around.",
        "end_dialog": true
    }
}

# Basic state tracking
var has_greeted: bool = false
var topics_discussed: Array = []

func get_entry_node() -> String:
    if has_greeted:
        return "root"
    else:
        has_greeted = true
        return "greeting"

func get_node_text(node_id: String) -> String:
    if dialog_tree.has(node_id):
        return dialog_tree[node_id].text
    return "..."

func get_node_options(node_id: String) -> Array:
    if dialog_tree.has(node_id) and dialog_tree[node_id].has("options"):
        return dialog_tree[node_id].options
    return []

func process_option_selection(node_id: String, option_index: int) -> Dictionary:
    # Track what topics have been discussed
    if not node_id in topics_discussed:
        topics_discussed.append(node_id)
    
    var node = dialog_tree[node_id]
    if node.has("options") and option_index < node.options.size():
        var option = node.options[option_index]
        return {
            "next_node": option.get("next", "root"),
            "suspicion_change": option.get("suspicion_change", 0.0),
            "end_dialog": option.get("end_dialog", false)
        }
    
    return {"next_node": "root", "suspicion_change": 0.0, "end_dialog": false}
```

### MVP Dialog Patterns

```gdscript
# Common dialog patterns for MVP
const MVP_DIALOG_PATTERNS = {
    "greeting_first_time": {
        "text": "Hello, I don't think we've met. I'm {NPC_NAME}.",
        "options": [
            {"text": "Nice to meet you", "next": "root"},
            {"text": "Hi", "next": "root"}
        ]
    },
    "greeting_return": {
        "text": "Oh, hello again.",
        "options": [
            {"text": "Hello", "next": "root"}
        ]
    },
    "goodbye_friendly": {
        "text": "Take care!",
        "end_dialog": true
    },
    "goodbye_neutral": {
        "text": "See you.",
        "end_dialog": true
    },
    "topic_work": {
        "text": "I {WORK_VERB} here in the {LOCATION}. It's {WORK_OPINION}.",
        "options": [
            {"text": "Sounds {WORK_RESPONSE}", "next": "root"}
        ]
    }
}
```

### MVP Testing Data

```json
{
    "test_npc_dialog": {
        "npc_id": "test_worker",
        "dialog_tree": {
            "greeting": {
                "text": "Hey there, stranger.",
                "options": [
                    {"text": "Hello", "next": "root"}
                ]
            },
            "root": {
                "text": "What can I do for you?",
                "options": [
                    {"text": "How's work?", "next": "work_topic"},
                    {"text": "Seen anything strange?", "next": "suspicious_topic", "suspicion_change": 0.1},
                    {"text": "Goodbye", "next": "end"}
                ]
            },
            "work_topic": {
                "text": "Same old, same old. Loading cargo all day.",
                "options": [
                    {"text": "Must be tiring", "next": "root"},
                    {"text": "Any interesting shipments?", "next": "suspicious_topic", "suspicion_change": 0.15}
                ]
            },
            "suspicious_topic": {
                "text": "Strange? No, nothing strange. Why do you ask?",
                "suspicion_trigger": true,
                "options": [
                    {"text": "Just curious", "next": "root", "suspicion_change": 0.05},
                    {"text": "No reason", "next": "root"}
                ]
            }
        }
    }
}
```

## Full Implementation (Phase 2)

### Extended Requirements

The Full Template Dialog system introduces procedural generation and complex conversation mechanics:

1. **Guideline-Driven Generation**: Create dialog from personality and context
2. **Dynamic Topic Selection**: Topics based on NPC role, location, and events
3. **Emotion and Tone**: Personality affects word choice and phrasing
4. **Suspicion Escalation**: Progressive responses based on suspicion level
5. **Memory Integration**: Reference previous conversations
6. **Contextual Awareness**: Time, location, and event-sensitive responses

### Procedural Dialog Generation System

```gdscript
# template_dialog_full.gd
extends Resource

class_name TemplateDialogFull

# Dialog generation engine
var generator: DialogGenerator
var personality: NPCPersonality
var memory: NPCMemory
var context: DialogContext

func _init(npc_data: Dictionary):
    personality = NPCPersonality.new(npc_data.personality)
    memory = NPCMemory.new(npc_data.npc_id)
    generator = DialogGenerator.new()

# Main generation entry point
func generate_dialog_tree(context: DialogContext) -> Dictionary:
    self.context = context
    
    var tree = {}
    
    # Generate entry node based on context
    tree["entry"] = _generate_entry_node()
    
    # Generate root menu
    tree["root"] = _generate_root_menu()
    
    # Generate topic nodes
    var topics = _select_available_topics()
    for topic in topics:
        tree[topic.id] = _generate_topic_node(topic)
    
    # Generate exit nodes
    tree["end"] = _generate_exit_node()
    
    return tree

func _generate_entry_node() -> Dictionary:
    var greeting_type = _determine_greeting_type()
    var template = DialogTemplates.get_greeting_template(greeting_type, personality)
    
    return {
        "text": generator.fill_template(template, context),
        "options": [
            {"text": _generate_greeting_response(), "next": "root"}
        ]
    }

func _determine_greeting_type() -> String:
    if memory.times_talked == 0:
        return "first_meeting"
    elif context.time_since_last_talk < 3600:  # Less than an hour
        return "recent_meeting"
    elif personality.friendliness > 0.7:
        return "friendly_return"
    else:
        return "neutral_return"

func _generate_root_menu() -> Dictionary:
    var options = []
    
    # Generate contextual topics
    var topics = _select_available_topics()
    for topic in topics:
        var option_text = _generate_topic_option_text(topic)
        options.append({
            "text": option_text,
            "next": topic.id,
            "suspicion_change": topic.suspicion_risk
        })
    
    # Always add goodbye
    options.append({
        "text": _generate_goodbye_option(),
        "next": "end"
    })
    
    return {
        "text": _generate_menu_prompt(),
        "options": options
    }

func _select_available_topics() -> Array:
    var topics = []
    
    # Job-related topics (always available)
    if personality.job_focus > 0.5:
        topics.append({
            "id": "work_topic",
            "category": "work",
            "suspicion_risk": 0.0
        })
    
    # Location-specific topics
    topics.append({
        "id": "location_topic",
        "category": "location",
        "suspicion_risk": 0.0
    })
    
    # Time-sensitive topics
    if context.is_meal_time:
        topics.append({
            "id": "meal_topic",
            "category": "social",
            "suspicion_risk": 0.0
        })
    
    # Investigation topics (risky)
    if memory.times_talked > 1:
        topics.append({
            "id": "strange_topic",
            "category": "investigation",
            "suspicion_risk": 0.15
        })
    
    # Event-based topics
    for event in context.recent_events:
        topics.append({
            "id": "event_" + event.id,
            "category": "event",
            "suspicion_risk": event.sensitivity
        })
    
    return topics

func _generate_topic_node(topic: Dictionary) -> Dictionary:
    var template = DialogTemplates.get_topic_template(topic.category, personality)
    var response_text = generator.fill_template(template, context, topic)
    
    # Generate follow-up options
    var options = _generate_follow_up_options(topic)
    
    return {
        "text": response_text,
        "options": options,
        "topic_id": topic.id
    }
```

### Guideline-Driven Generation Engine

```gdscript
# DialogGenerator.gd
class_name DialogGenerator
extends Reference

# Template filling with personality modulation
func fill_template(template: String, context: DialogContext, data: Dictionary = {}) -> String:
    var result = template
    
    # Replace variables
    result = _replace_variables(result, context, data)
    
    # Apply personality transforms
    result = _apply_personality_modulation(result, context.personality)
    
    # Apply emotional state
    result = _apply_emotional_coloring(result, context.emotional_state)
    
    # Apply assimilation effects if needed
    if context.is_assimilated:
        result = _apply_assimilation_transform(result)
    
    return result

func _replace_variables(text: String, context: DialogContext, data: Dictionary) -> String:
    var replacements = {
        "{TIME_OF_DAY}": _get_time_greeting(context.current_hour),
        "{PLAYER_TITLE}": _get_player_title(context.personality.formality),
        "{LOCATION}": context.current_location.display_name,
        "{NPC_NAME}": context.npc_name,
        "{NPC_ROLE}": context.npc_role,
        "{WORK_VERB}": _get_work_verb(context.npc_role),
        "{WORK_OPINION}": _get_work_opinion(context.personality.job_satisfaction)
    }
    
    # Add custom data replacements
    for key in data:
        replacements["{" + key.to_upper() + "}"] = str(data[key])
    
    # Perform replacements
    for key in replacements:
        text = text.replace(key, replacements[key])
    
    return text

func _apply_personality_modulation(text: String, personality: NPCPersonality) -> String:
    # Formality adjustments
    if personality.formality < 0.3:
        text = _make_casual(text)
    elif personality.formality > 0.7:
        text = _make_formal(text)
    
    # Verbosity adjustments
    if personality.verbosity > 0.7:
        text = _add_elaboration(text)
    elif personality.verbosity < 0.3:
        text = _make_terse(text)
    
    # Add speech patterns
    text = _add_speech_patterns(text, personality)
    
    return text

# Personality-based text transformations
func _make_casual(text: String) -> String:
    var casual_replacements = {
        "Hello": "Hey",
        "Goodbye": "See ya",
        "Yes": "Yeah",
        "No": "Nah",
        "Thank you": "Thanks",
        "I am": "I'm",
        "It is": "It's",
        "Cannot": "Can't"
    }
    
    for formal in casual_replacements:
        text = text.replace(formal, casual_replacements[formal])
    
    return text

func _make_formal(text: String) -> String:
    var formal_replacements = {
        "Hey": "Greetings",
        "Hi": "Hello",
        "Yeah": "Yes",
        "Nah": "No",
        "Thanks": "Thank you",
        "I'm": "I am",
        "It's": "It is",
        "Can't": "Cannot"
    }
    
    for casual in formal_replacements:
        text = text.replace(casual, formal_replacements[casual])
    
    return text

func _add_elaboration(text: String) -> String:
    # Add filler phrases for verbose NPCs
    var elaborations = [
        " You see,",
        " If you know what I mean,",
        " To be honest,",
        " Actually,",
        " Well,"
    ]
    
    # Insert elaboration at sentence boundaries
    var sentences = text.split(".")
    if sentences.size() > 1:
        var insert_pos = randi() % (sentences.size() - 1)
        sentences[insert_pos] += elaborations[randi() % elaborations.size()]
    
    return sentences.join(".")

func _make_terse(text: String) -> String:
    # Remove filler words for terse NPCs
    var fillers = ["Well, ", "Actually, ", "You see, ", "I think ", "Maybe "]
    
    for filler in fillers:
        text = text.replace(filler, "")
    
    # Shorten sentences
    if text.length() > 50:
        var sentences = text.split(".")
        if sentences.size() > 2:
            # Keep only first and last sentence
            text = sentences[0] + ". " + sentences[-1] + "."
    
    return text
```

### Dialog Templates Library

```gdscript
# DialogTemplates.gd
class_name DialogTemplates
extends Reference

# Greeting templates by type and personality
const GREETING_TEMPLATES = {
    "first_meeting": {
        "formal_friendly": [
            "Good {TIME_OF_DAY}, {PLAYER_TITLE}. I don't believe we've been introduced. I am {NPC_NAME}, {NPC_ROLE}.",
            "Welcome to {LOCATION}. I am {NPC_NAME}. How may I assist you today?"
        ],
        "casual_friendly": [
            "Hey there! Haven't seen you around before. I'm {NPC_NAME}.",
            "Oh, a new face! Welcome to {LOCATION}. I'm {NPC_NAME}."
        ],
        "formal_neutral": [
            "{PLAYER_TITLE}. I am {NPC_NAME}, {NPC_ROLE} here at {LOCATION}.",
            "Yes? I am {NPC_NAME}. What is your business here?"
        ],
        "casual_suspicious": [
            "Who are you? Don't think I've seen you before.",
            "Yeah? You new here or something?"
        ]
    },
    "return_greeting": {
        "friendly": [
            "Oh, {PLAYER_TITLE}! Good to see you again.",
            "Back again? How can I help you today?"
        ],
        "neutral": [
            "Oh, it's you. What do you need?",
            "{PLAYER_TITLE}. What brings you back?"
        ],
        "suspicious": [
            "You again. What do you want now?",
            "Why do you keep coming around asking questions?"
        ]
    }
}

# Topic response templates
const TOPIC_TEMPLATES = {
    "work": {
        "satisfied": [
            "I {WORK_VERB} here in {LOCATION}. It's honest work and I enjoy it.",
            "The job keeps me busy. Can't complain really."
        ],
        "neutral": [
            "It's work. {WORK_VERB} all day. Pays the bills.",
            "Same thing every day. {WORK_VERB} from morning to night."
        ],
        "dissatisfied": [
            "I {WORK_VERB} here. It's... not what I planned to do with my life.",
            "The work? It's tedious. But what choice do I have?"
        ]
    },
    "location": {
        "positive": [
            "{LOCATION} is a good place. I've been here {TIME_WORKED} and I like it.",
            "This is a nice part of the station. Good people work here."
        ],
        "neutral": [
            "{LOCATION}? It's alright. Nothing special.",
            "It's just another part of the station. Does its job."
        ],
        "negative": [
            "This place has seen better days, if you ask me.",
            "{LOCATION} isn't what it used to be. Things have... changed."
        ]
    },
    "investigation": {
        "deflect": [
            "Strange? No, nothing strange. Why do you ask?",
            "I don't know what you mean. Everything's normal here."
        ],
        "suspicious_response": [
            "That's an odd question. What exactly are you looking for?",
            "Why are you asking me these questions? Who sent you?"
        ],
        "nervous": [
            "I... I haven't noticed anything. I just do my job.",
            "Look, I don't want any trouble. I mind my own business."
        ]
    }
}

# Suspicion level responses
const SUSPICION_RESPONSES = {
    "low": {
        "question": "Is there something specific you wanted to know?",
        "statement": "I'm happy to help if I can."
    },
    "medium": {
        "question": "Why all these questions?",
        "statement": "You're asking a lot of questions..."
    },
    "high": {
        "question": "What are you really after?",
        "statement": "I don't like where this is going."
    },
    "critical": {
        "question": "Are you security? What's this about?",
        "statement": "I think we're done here."
    }
}

static func get_greeting_template(greeting_type: String, personality: NPCPersonality) -> String:
    var personality_key = _get_personality_key(personality)
    
    if GREETING_TEMPLATES.has(greeting_type):
        var type_templates = GREETING_TEMPLATES[greeting_type]
        if type_templates.has(personality_key):
            var templates = type_templates[personality_key]
            return templates[randi() % templates.size()]
    
    # Fallback
    return "Hello."

static func _get_personality_key(personality: NPCPersonality) -> String:
    var formality = "formal" if personality.formality > 0.5 else "casual"
    var friendliness = ""
    
    if personality.friendliness > 0.6:
        friendliness = "_friendly"
    elif personality.friendliness < 0.4:
        friendliness = "_suspicious"
    else:
        friendliness = "_neutral"
    
    return formality + friendliness
```

### Contextual Dialog System

```gdscript
# DialogContext.gd
class_name DialogContext
extends Reference

# Current context for dialog generation
var npc_id: String
var npc_name: String
var npc_role: String
var personality: NPCPersonality
var current_location: District
var current_hour: int
var current_day: int
var player_reputation: float
var is_assimilated: bool
var suspicion_level: float
var emotional_state: String
var recent_events: Array
var time_since_last_talk: float

func _init():
    recent_events = EventManager.get_recent_events(3600)  # Last hour
    current_hour = TimeManager.current_hour
    current_day = TimeManager.current_day

# Computed properties
func get is_meal_time() -> bool:
    return current_hour in [7, 8, 12, 13, 18, 19]

func get is_work_time() -> bool:
    return current_hour >= 8 and current_hour <= 17

func get time_period() -> String:
    if current_hour < 6:
        return "night"
    elif current_hour < 12:
        return "morning"
    elif current_hour < 18:
        return "afternoon"
    else:
        return "evening"

func get stress_level() -> float:
    var stress = 0.0
    
    # Base stress from personality
    stress += (1.0 - personality.confidence) * 0.3
    
    # Suspicion adds stress
    stress += suspicion_level * 0.5
    
    # Recent events can add stress
    for event in recent_events:
        if event.is_negative:
            stress += 0.1
    
    return clamp(stress, 0.0, 1.0)
```

### Memory and Relationship Integration

```gdscript
# NPCMemory.gd (Dialog-specific extensions)
extends Reference

class_name NPCMemory

var npc_id: String
var conversation_history: Array = []
var topics_discussed: Dictionary = {}
var player_choices: Dictionary = {}
var relationship_score: float = 0.0

func remember_conversation(dialog_node: String, player_choice: int):
    var memory = {
        "node": dialog_node,
        "choice": player_choice,
        "day": TimeManager.current_day,
        "hour": TimeManager.current_hour
    }
    
    conversation_history.append(memory)
    
    # Track topic frequency
    if not topics_discussed.has(dialog_node):
        topics_discussed[dialog_node] = 0
    topics_discussed[dialog_node] += 1

func get_conversation_summary() -> String:
    if conversation_history.size() == 0:
        return "first_conversation"
    
    var last_conv = conversation_history[-1]
    var days_since = TimeManager.current_day - last_conv.day
    
    if days_since == 0:
        return "talked_today"
    elif days_since == 1:
        return "talked_yesterday"
    else:
        return "talked_days_ago"

func adjust_relationship(amount: float):
    relationship_score = clamp(relationship_score + amount, -1.0, 1.0)

func get_relationship_level() -> String:
    if relationship_score > 0.7:
        return "friendly"
    elif relationship_score > 0.3:
        return "positive"
    elif relationship_score < -0.7:
        return "hostile"
    elif relationship_score < -0.3:
        return "negative"
    else:
        return "neutral"
```

### Assimilation Effects on Dialog

```gdscript
# AssimilationDialogEffects.gd
class_name AssimilationDialogEffects
extends Reference

# Transform dialog for assimilated NPCs
static func apply_assimilation_transform(text: String, assimilation_level: float) -> String:
    if assimilation_level < 0.3:
        # Subtle changes
        return _apply_subtle_changes(text)
    elif assimilation_level < 0.7:
        # Moderate changes
        return _apply_moderate_changes(text)
    else:
        # Severe changes
        return _apply_severe_changes(text)

static func _apply_subtle_changes(text: String) -> String:
    # Occasional odd word choice
    var replacements = {
        "I feel": "We sense",
        "I think": "We believe",
        "my": "our"
    }
    
    # Only replace sometimes
    for original in replacements:
        if randf() < 0.3:  # 30% chance
            text = text.replace(original, replacements[original])
    
    return text

static func _apply_moderate_changes(text: String) -> String:
    # More frequent collective speech
    text = text.replace("I ", "We ")
    text = text.replace("my ", "our ")
    text = text.replace("me", "us")
    
    # Add unsettling pauses
    text = text.replace(". ", "... ")
    
    return text

static func _apply_severe_changes(text: String) -> String:
    # Heavy collective consciousness
    text = _apply_moderate_changes(text)
    
    # Add creepy additions
    var additions = [
        " The collective grows.",
        " Join us.",
        " Resistance is... unwise.",
        " We are one."
    ]
    
    # Add to end of some sentences
    var sentences = text.split(".")
    if sentences.size() > 0 and randf() < 0.5:
        var insert_pos = randi() % sentences.size()
        sentences[insert_pos] += additions[randi() % additions.size()]
    
    return sentences.join(".")
```

## Implementation Guidelines

### MVP Phase Guidelines

1. **Hard-Code First**: Write specific dialog for test NPCs
2. **Identify Patterns**: Note common structures across NPCs
3. **Test Thoroughly**: Ensure basic conversation flow works
4. **Document Patterns**: Create template from successful dialogs
5. **Keep It Simple**: Focus on core conversation mechanics

### Full Phase Guidelines

1. **Template Everything**: Convert patterns to reusable templates
2. **Personality Matters**: Let personality drive generation
3. **Context is King**: Use all available context for relevance
4. **Test Generation**: Verify generated dialog sounds natural
5. **Performance**: Cache generated dialog when possible

## Testing Strategy

### MVP Testing
```gdscript
func test_mvp_dialog_flow():
    var dialog = TemplateDialogMVP.new()
    
    # Test initial greeting
    assert(dialog.get_entry_node() == "greeting")
    assert(dialog.has_greeted == false)
    
    # Test topic selection
    var options = dialog.get_node_options("root")
    assert(options.size() >= 3)  # At least 3 options
    
    # Test topic tracking
    dialog.process_option_selection("root", 0)
    assert(dialog.topics_discussed.has("root"))
```

### Full Testing
```gdscript
func test_procedural_generation():
    var npc_data = {
        "personality": {
            "formality": 0.8,
            "friendliness": 0.6,
            "verbosity": 0.4
        }
    }
    
    var dialog = TemplateDialogFull.new(npc_data)
    var context = DialogContext.new()
    
    # Generate and validate
    var tree = dialog.generate_dialog_tree(context)
    assert(tree.has("entry"))
    assert(tree.has("root"))
    
    # Test personality influence
    var entry_text = tree.entry.text
    assert("Good" in entry_text)  # Formal greeting
    assert(not "Hey" in entry_text)  # Not casual
```

## Performance Considerations

- **Generation Caching**: Cache generated dialog for 1 game hour
- **Template Preloading**: Load all templates at startup
- **Lazy Generation**: Only generate dialog nodes as needed
- **Memory Limits**: Cap conversation history at 50 entries

## Integration Points

- **NPCSystem**: Provides personality and state data
- **TimeManager**: Supplies temporal context
- **EventManager**: Provides recent events for topics
- **SuspicionSystem**: Tracks dialog-triggered suspicion
- **SaveManager**: Persists conversation history
- **AudioManager**: Could trigger dialog-appropriate ambient sounds

## Future Enhancements

- **Emotion System**: More nuanced emotional states
- **Dialog Minigames**: Persuasion/interrogation mechanics
- **Group Conversations**: Multi-NPC discussions
- **Dynamic Interruptions**: NPCs react to world events mid-conversation
- **Voice Synthesis**: Procedural voice generation matching personality