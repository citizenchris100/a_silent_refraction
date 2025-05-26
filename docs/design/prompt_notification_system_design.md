# Prompt/Notification System Design Document

## Overview

The Prompt/Notification System provides a centralized modal dialog interface for conveying information to the player throughout A Silent Refraction. This system pauses game time while displaying important messages, ensuring players don't miss critical information while maintaining the game's deliberate pacing.

## Core Requirements

### Functional Requirements
1. **Modal Dialog Display**
   - Display text-based messages in a centered modal window
   - Include a single "OK" button for acknowledgment
   - Support multi-line text with proper formatting
   - Handle text overflow with scrolling if needed

2. **Game State Management**
   - Pause game time while modal is displayed
   - Block all player input except modal interaction
   - Resume normal gameplay after acknowledgment
   - Maintain proper state across save/load

3. **Queue Management**
   - Queue multiple prompts if triggered simultaneously
   - Display prompts in priority order
   - Prevent duplicate prompts in queue

### Design Pillars Alignment
- **Design Pillar 1** (Observation): Critical information is never missed
- **Design Pillar 5** (Death): Clear warnings about dangerous situations
- **Design Pillar 7** (Time): Respects player attention during time-critical moments

## System Architecture

### Component Structure

```gdscript
# src/core/systems/prompt_notification_system.gd
extends Node

class_name PromptNotificationSystem

signal prompt_shown(prompt_type: String, message: String)
signal prompt_dismissed(prompt_type: String)
signal queue_cleared()

# Prompt types
enum PromptType {
    INFO,        # General information
    WARNING,     # Important warnings
    CRITICAL,    # Game-critical alerts
    CONFIRM,     # Action confirmations
    STORY        # Narrative moments
}

# Priority levels (lower = higher priority)
const PRIORITY_CRITICAL = 0
const PRIORITY_WARNING = 10
const PRIORITY_STORY = 20
const PRIORITY_CONFIRM = 30
const PRIORITY_INFO = 40

var prompt_queue: Array = []
var current_prompt = null
var is_showing_prompt: bool = false

# UI references
var prompt_ui: Control
var message_label: RichTextLabel
var ok_button: Button
```

### Data Structures

```gdscript
# Prompt data structure
class PromptData:
    var id: String = ""
    var type: int = PromptType.INFO
    var priority: int = PRIORITY_INFO
    var message: String = ""
    var title: String = ""
    var shown_count: int = 0
    var timestamp: float = 0.0
    var context: Dictionary = {}  # Additional data for specific systems
```

## Integration with Other Systems

### Save System Integration
```gdscript
# Sleep morning report
PromptNotificationSystem.show_prompt(
    "sleep_morning_report",
    PromptType.INFO,
    "You wake up at %s.\n\nYour game has been saved." % wake_time,
    "Good Morning"
)

# Save error handling
PromptNotificationSystem.show_critical(
    "save_error",
    "Failed to save game!\n\nError: %s\n\nWould you like to retry?" % error_msg,
    "Save Error"
)
```

### Sleep System Integration
```gdscript
# Forced return warnings
PromptNotificationSystem.show_warning(
    "sleep_warning_30min",
    "It's 11:30 PM. You should return to your barracks soon.\n\nThe tram stops running at midnight.",
    "Time Warning"
)

# Security confrontation
PromptNotificationSystem.show_critical(
    "mall_squat_caught",
    "Security has found you sleeping in the mall!\n\n'What are you doing here?'",
    "Caught!"
)
```

### Economy System Integration
```gdscript
# Purchase confirmations
PromptNotificationSystem.show_confirm(
    "purchase_confirm",
    "Purchase %s for %d credits?\n\nYour balance: %d credits" % [item_name, price, current_credits],
    "Confirm Purchase"
)

# Job completion
PromptNotificationSystem.show_info(
    "job_complete",
    "Job completed!\n\nEarned: %d credits\nNew balance: %d credits" % [payment, new_balance],
    "Payment Received"
)
```

### Detection System Integration
```gdscript
# Lockdown announcement
PromptNotificationSystem.show_critical(
    "station_lockdown",
    "ATTENTION ALL PERSONNEL\n\nStation lockdown in effect.\nRemain in your quarters.\nSecurity teams are investigating.",
    "Emergency Alert"
)

# Game over warning
PromptNotificationSystem.show_critical(
    "detection_final_warning",
    "Security is closing in!\n\nFind a safe house immediately!",
    "RUN!"
)
```

### Barracks System Integration
```gdscript
# Rent warning
PromptNotificationSystem.show_warning(
    "rent_due_warning",
    "Rent payment due in 2 days.\n\nAmount due: 450 credits\nCurrent balance: %d credits" % current_credits,
    "Rent Notice"
)

# Eviction notice
PromptNotificationSystem.show_critical(
    "eviction_notice",
    "EVICTION NOTICE\n\nYou have been evicted from the barracks.\nCollect your belongings from storage.\nFind alternative accommodation.",
    "Evicted"
)
```

## API Design

### Core Methods

```gdscript
# Show a prompt with full control
func show_prompt(id: String, type: int, message: String, title: String = "", priority: int = -1) -> void:
    var prompt = PromptData.new()
    prompt.id = id
    prompt.type = type
    prompt.message = message
    prompt.title = title if title else _get_default_title(type)
    prompt.priority = priority if priority >= 0 else _get_default_priority(type)
    prompt.timestamp = Time.get_ticks_msec() / 1000.0
    
    _queue_prompt(prompt)

# Convenience methods
func show_info(id: String, message: String, title: String = "") -> void:
    show_prompt(id, PromptType.INFO, message, title)

func show_warning(id: String, message: String, title: String = "") -> void:
    show_prompt(id, PromptType.WARNING, message, title)

func show_critical(id: String, message: String, title: String = "") -> void:
    show_prompt(id, PromptType.CRITICAL, message, title)

func show_confirm(id: String, message: String, title: String = "") -> void:
    show_prompt(id, PromptType.CONFIRM, message, title)

func show_story(id: String, message: String, title: String = "") -> void:
    show_prompt(id, PromptType.STORY, message, title)

# Clear all prompts of a specific type
func clear_prompts_by_type(type: int) -> void:
    prompt_queue = prompt_queue.filter(func(p): return p.type != type)

# Check if a specific prompt has been shown
func has_shown_prompt(id: String) -> bool:
    return SaveData.shown_prompts.has(id)
```

## UI Specifications

### Visual Design
```
┌─────────────────────────────────────┐
│ [Title]                             │
├─────────────────────────────────────┤
│                                     │
│    [Message Text]                   │
│    Multiple lines supported         │
│    With proper word wrapping        │
│                                     │
├─────────────────────────────────────┤
│              [ OK ]                 │
└─────────────────────────────────────┘
```

### Style by Type
- **INFO**: Blue header, standard text
- **WARNING**: Yellow header, warning icon
- **CRITICAL**: Red header, alert icon, pulsing border
- **CONFIRM**: Green header, checkmark icon
- **STORY**: Purple header, narrative styling

## Serialization

### Serializer Implementation
```gdscript
# src/core/serializers/prompt_notification_serializer.gd
extends BaseSerializer

class_name PromptNotificationSerializer

func get_serializer_id() -> String:
    return "prompt_notifications"

func _ready():
    # Self-register with low priority (UI system)
    SaveManager.register_serializer("prompt_notifications", self, 80)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "shown_prompts": PromptNotificationSystem.get_shown_prompt_ids(),
        "queued_prompts": _serialize_queue(),
        "statistics": {
            "total_shown": PromptNotificationSystem.total_prompts_shown,
            "by_type": PromptNotificationSystem.prompts_by_type
        }
    }

func deserialize(data: Dictionary) -> void:
    # Restore shown prompt history
    if "shown_prompts" in data:
        PromptNotificationSystem.set_shown_prompts(data.shown_prompts)
    
    # Don't restore queue - let systems re-trigger if needed
    
    # Restore statistics
    if "statistics" in data:
        PromptNotificationSystem.total_prompts_shown = data.statistics.total_shown
        PromptNotificationSystem.prompts_by_type = data.statistics.by_type
```

## Special Use Cases

### News Broadcasts
```gdscript
func broadcast_news(headline: String, content: String) -> void:
    show_story(
        "news_" + str(Time.get_ticks_msec()),
        "STATION NEWS NETWORK\n\n%s\n\n%s" % [headline, content],
        "Breaking News"
    )
```

### Emergency Alerts
```gdscript
func emergency_alert(message: String) -> void:
    # Clear all other prompts
    prompt_queue.clear()
    
    # Show immediately with special formatting
    show_critical(
        "emergency_" + str(Time.get_ticks_msec()),
        "⚠ EMERGENCY ⚠\n\n%s" % message,
        "STATION ALERT"
    )
```

### Tutorial Messages
```gdscript
func show_tutorial(topic: String, message: String) -> void:
    if not GameSettings.tutorials_enabled:
        return
    
    var id = "tutorial_" + topic
    if has_shown_prompt(id) and not GameSettings.repeat_tutorials:
        return
    
    show_info(id, message, "Tutorial: " + topic)
```

## Performance Considerations

1. **Queue Management**
   - Maximum queue size: 20 prompts
   - Automatic deduplication by ID
   - Priority-based ordering

2. **Memory Usage**
   - Shown prompt history limited to 1000 entries
   - Old entries pruned on save

3. **Text Rendering**
   - BBCode support for rich text
   - Efficient word wrapping
   - Maximum message length: 2000 characters

## Testing Scenarios

1. **Queue Stress Test**
   - Trigger 50+ prompts simultaneously
   - Verify priority ordering
   - Check deduplication

2. **Save/Load Test**
   - Show prompts, save, load
   - Verify history preserved
   - Check queue not restored

3. **Integration Test**
   - Trigger prompts from all systems
   - Verify game pause behavior
   - Test during various game states

## Future Considerations

1. **Audio Integration**
   - Different sounds per prompt type
   - Text-to-speech for accessibility

2. **Visual Effects**
   - Screen shake for critical alerts
   - Fade effects for story moments

3. **Multi-Button Support**
   - Yes/No prompts for choices
   - Multiple option selection

4. **Localization Ready**
   - String keys instead of hardcoded text
   - RTL language support

## Implementation Priority

This system should be implemented early (Iteration 3-4) as many other systems depend on it:
- Save System needs it for confirmations
- Sleep System needs it for warnings
- Detection System needs it for alerts
- Economy System needs it for transactions
- All systems benefit from centralized notifications