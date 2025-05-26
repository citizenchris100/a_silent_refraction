# Morning Report Manager Design Document

## Overview

The Morning Report Manager consolidates all overnight event reporting into a single, unified system. Previously, both the Sleep System and Save System had their own morning report implementations, leading to redundancy and potential conflicts. This manager centralizes the collection, prioritization, and display of overnight events that occur while the player sleeps.

## Core Responsibilities

1. **Event Collection**: Gather overnight events from all game systems
2. **Prioritization**: Order events by importance and relevance
3. **Formatting**: Create consistent, readable report format
4. **Display**: Use PromptNotificationSystem for unified presentation
5. **Serialization**: Track which reports have been shown

## System Architecture

### Core Component

```gdscript
# src/core/systems/morning_report_manager.gd
extends Node

class_name MorningReportManager

signal report_shown(day: int, events: Array)
signal event_acknowledged(event_type: String)

# Event priorities (lower = higher priority)
enum EventPriority {
    CRITICAL = 0,      # Game-changing events
    HIGH = 10,         # Important events
    MEDIUM = 20,       # Notable events
    LOW = 30,          # Minor events
    INFO = 40          # Informational only
}

# Event categories for grouping
enum EventCategory {
    ASSIMILATION,      # NPCs assimilated
    COALITION,         # Coalition activities
    ECONOMY,           # Economic changes
    QUEST,             # Quest updates
    PERSONAL,          # Player-specific events
    STATION            # Station-wide events
}

var overnight_events: Array = []
var report_history: Dictionary = {}  # {day: [events]}

static var instance = null

func _ready():
    if instance == null:
        instance = self
    else:
        queue_free()
```

### Event Data Structure

```gdscript
class OvernightEvent:
    var id: String = ""
    var category: int = EventCategory.STATION
    var priority: int = EventPriority.MEDIUM
    var message: String = ""
    var details: Dictionary = {}  # System-specific data
    var source_system: String = ""
    var timestamp: float = 0.0
    
    func format_for_display() -> String:
        return message  # Can be overridden for complex formatting
```

## Integration Points

### 1. Assimilation System

```gdscript
# Called by AssimilationManager.process_overnight_spread()
func report_assimilation_spread(new_infections: int, total_percentage: float, critical_npcs: Array):
    var event = OvernightEvent.new()
    event.id = "assimilation_spread_%d" % TimeManager.current_day
    event.category = EventCategory.ASSIMILATION
    event.priority = EventPriority.CRITICAL if critical_npcs.size() > 0 else EventPriority.HIGH
    
    if critical_npcs.size() > 0:
        event.message = "%d NPCs were assimilated (%d%% total)\nCritical loss: %s" % [
            new_infections, 
            int(total_percentage * 100),
            critical_npcs[0].name
        ]
    else:
        event.message = "%d NPCs were assimilated (%d%% total)" % [
            new_infections, 
            int(total_percentage * 100)
        ]
    
    event.details = {
        "new_infections": new_infections,
        "total_percentage": total_percentage,
        "critical_npcs": critical_npcs
    }
    event.source_system = "AssimilationManager"
    
    add_overnight_event(event)
```

### 2. Coalition System

```gdscript
# Called by CoalitionManager.process_overnight_actions()
func report_coalition_activities(completed_missions: Array, failed_missions: Array):
    for mission in completed_missions:
        var event = OvernightEvent.new()
        event.id = "coalition_success_%s" % mission.id
        event.category = EventCategory.COALITION
        event.priority = EventPriority.HIGH
        event.message = "Coalition: %s completed successfully" % mission.name
        event.details = {"mission": mission, "success": true}
        event.source_system = "CoalitionManager"
        add_overnight_event(event)
    
    for mission in failed_missions:
        var event = OvernightEvent.new()
        event.id = "coalition_failure_%s" % mission.id
        event.category = EventCategory.COALITION
        event.priority = EventPriority.CRITICAL
        event.message = "Coalition: %s failed!" % mission.name
        event.details = {"mission": mission, "success": false}
        event.source_system = "CoalitionManager"
        add_overnight_event(event)
```

### 3. Economy System

```gdscript
# Called by EconomyManager.process_overnight_economy()
func report_economic_events(rent_due: bool, market_changes: Dictionary, theft: Dictionary):
    if rent_due:
        var event = OvernightEvent.new()
        event.id = "rent_due_%d" % TimeManager.current_day
        event.category = EventCategory.ECONOMY
        event.priority = EventPriority.HIGH
        event.message = "Your rent is due today (450 credits)"
        event.details = {"amount": 450, "days_until_eviction": 3}
        event.source_system = "EconomyManager"
        add_overnight_event(event)
    
    if market_changes.size() > 0:
        var event = OvernightEvent.new()
        event.id = "market_change_%d" % TimeManager.current_day
        event.category = EventCategory.ECONOMY
        event.priority = EventPriority.MEDIUM
        event.message = "Market prices have shifted due to %s" % market_changes.reason
        event.details = market_changes
        event.source_system = "EconomyManager"
        add_overnight_event(event)
    
    if theft.occurred:
        var event = OvernightEvent.new()
        event.id = "theft_%d" % TimeManager.current_day
        event.category = EventCategory.PERSONAL
        event.priority = EventPriority.HIGH
        event.message = "Your %s was stolen while you slept!" % theft.item_name
        event.details = theft
        event.source_system = "EconomyManager"
        add_overnight_event(event)
```

### 4. Quest System

```gdscript
# Called by QuestManager during overnight processing
func report_quest_updates(expired_quests: Array, progressed_quests: Array, new_quests: Array):
    for quest in expired_quests:
        var event = OvernightEvent.new()
        event.id = "quest_expired_%s" % quest.id
        event.category = EventCategory.QUEST
        event.priority = EventPriority.HIGH
        event.message = "Quest failed: %s (deadline passed)" % quest.name
        event.details = {"quest": quest}
        event.source_system = "QuestManager"
        add_overnight_event(event)
    
    for quest in new_quests:
        var event = OvernightEvent.new()
        event.id = "quest_new_%s" % quest.id
        event.category = EventCategory.QUEST
        event.priority = EventPriority.MEDIUM
        event.message = "New opportunity: %s" % quest.name
        event.details = {"quest": quest}
        event.source_system = "QuestManager"
        add_overnight_event(event)
```

### 5. Detection System

```gdscript
# Called by DetectionManager.apply_overnight_decay()
func report_detection_changes(heat_reduced: bool, new_suspicion_level: float):
    if heat_reduced:
        var event = OvernightEvent.new()
        event.id = "heat_decay_%d" % TimeManager.current_day
        event.category = EventCategory.PERSONAL
        event.priority = EventPriority.LOW
        event.message = "Security interest in you has decreased"
        event.details = {"new_level": new_suspicion_level}
        event.source_system = "DetectionManager"
        add_overnight_event(event)
```

## Report Generation and Display

### Event Collection and Sorting

```gdscript
func prepare_morning_report() -> void:
    # Sort events by priority, then by category
    overnight_events.sort_custom(self, "_sort_events")
    
    # Group events by category for better readability
    var grouped_events = {}
    for event in overnight_events:
        if not event.category in grouped_events:
            grouped_events[event.category] = []
        grouped_events[event.category].append(event)
    
    # Store in history
    report_history[TimeManager.current_day] = overnight_events.duplicate()

func _sort_events(a: OvernightEvent, b: OvernightEvent) -> bool:
    if a.priority != b.priority:
        return a.priority < b.priority
    return a.category < b.category
```

### Report Formatting

```gdscript
func show_morning_report() -> void:
    if overnight_events.size() == 0:
        # No events - just show basic wake message
        PromptNotificationSystem.show_info(
            "morning_report_empty",
            "You wake up at %s.\n\nNothing significant happened overnight.\n\nYour game has been saved." % [
                TimeManager.get_time_string()
            ],
            "Day %d - Morning" % TimeManager.current_day
        )
        return
    
    # Build report message
    var report_lines = []
    report_lines.append("You wake up at %s." % TimeManager.get_time_string())
    report_lines.append("")
    report_lines.append("While you slept:")
    
    # Add critical events first
    var has_critical = false
    for event in overnight_events:
        if event.priority == EventPriority.CRITICAL:
            report_lines.append("⚠ " + event.format_for_display())
            has_critical = true
    
    if has_critical:
        report_lines.append("")  # Space after critical events
    
    # Add other events
    var event_count = 0
    var max_events = 8  # Limit to prevent UI overflow
    
    for event in overnight_events:
        if event.priority != EventPriority.CRITICAL:
            if event_count < max_events:
                report_lines.append("• " + event.format_for_display())
                event_count += 1
    
    if overnight_events.size() > max_events + (1 if has_critical else 0):
        report_lines.append("• ... and %d more events" % (overnight_events.size() - max_events))
    
    report_lines.append("")
    report_lines.append("Your game has been saved.")
    
    # Show using notification system
    PromptNotificationSystem.show_info(
        "morning_report_full",
        report_lines.join("\n"),
        "Day %d - Morning Report" % TimeManager.current_day
    )
    
    # Emit signal for other systems
    emit_signal("report_shown", TimeManager.current_day, overnight_events)
    
    # Clear events for next night
    overnight_events.clear()
```

## Sleep Quality Integration

The report can be modified based on sleep quality:

```gdscript
func modify_report_for_sleep_quality(location: String, quality: float) -> void:
    if quality < 0.5:
        # Poor sleep - add fatigue warning
        var event = OvernightEvent.new()
        event.id = "poor_sleep"
        event.category = EventCategory.PERSONAL
        event.priority = EventPriority.MEDIUM
        event.message = "You didn't sleep well. Fatigue recovery reduced."
        event.source_system = "SleepSystem"
        overnight_events.insert(0, event)  # Add at beginning
    
    if location == "mall_squat":
        # Squat sleeping - add risk warning
        var event = OvernightEvent.new()
        event.id = "squat_sleep_risk"
        event.category = EventCategory.PERSONAL
        event.priority = EventPriority.MEDIUM
        event.message = "Sleeping rough has increased security suspicion"
        event.source_system = "SleepSystem"
        add_overnight_event(event)
```

## Serialization

```gdscript
# src/core/serializers/morning_report_serializer.gd
extends BaseSerializer

class_name MorningReportSerializer

func get_serializer_id() -> String:
    return "morning_report"

func _ready():
    SaveManager.register_serializer("morning_report", self, 75)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "report_history": _compress_history(MorningReportManager.report_history),
        "shown_days": MorningReportManager.report_history.keys()
    }

func deserialize(data: Dictionary) -> void:
    if "report_history" in data:
        MorningReportManager.report_history = _decompress_history(data.report_history)

func _compress_history(history: Dictionary) -> Dictionary:
    # Only keep last 7 days of reports
    var compressed = {}
    var days = history.keys()
    days.sort()
    
    var start_idx = max(0, days.size() - 7)
    for i in range(start_idx, days.size()):
        var day = days[i]
        compressed[day] = _compress_events(history[day])
    
    return compressed

func _compress_events(events: Array) -> Array:
    # Store only essential data
    var compressed = []
    for event in events:
        compressed.append({
            "id": event.id,
            "cat": event.category,
            "pri": event.priority,
            "msg": event.message
        })
    return compressed
```

## API for Other Systems

```gdscript
# Add a single event
static func add_event(message: String, category: int, priority: int = EventPriority.MEDIUM) -> void:
    var event = OvernightEvent.new()
    event.message = message
    event.category = category
    event.priority = priority
    event.source_system = "Unknown"
    instance.add_overnight_event(event)

# Add multiple events at once
static func add_events(events: Array) -> void:
    for event in events:
        instance.add_overnight_event(event)

# Check if report was shown for a specific day
static func was_report_shown(day: int) -> bool:
    return instance.report_history.has(day)

# Get historical report for a day
static func get_report_for_day(day: int) -> Array:
    if instance.report_history.has(day):
        return instance.report_history[day]
    return []
```

## Integration Requirements

### Systems That Must Integrate

1. **Sleep System**: Call `show_morning_report()` after sleep completion
2. **Save System**: Remove its own morning report implementation
3. **Assimilation Manager**: Report spread events
4. **Coalition Manager**: Report overnight missions
5. **Economy Manager**: Report economic changes
6. **Quest Manager**: Report quest updates
7. **Detection Manager**: Report heat changes

### Migration Notes

When implementing this system:

1. Remove morning report code from `sleep_system_design.md`
2. Remove morning report code from `save_system_design.md`
3. Update both systems to call `MorningReportManager.show_morning_report()`
4. Ensure all overnight processing systems report their events
5. Test report prioritization and formatting

## Conclusion

The Morning Report Manager eliminates redundancy between the Sleep and Save systems while providing a centralized, extensible way to report overnight events. By using the PromptNotificationSystem for display, it maintains UI consistency while allowing each game system to contribute relevant information to the player's morning briefing.