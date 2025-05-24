# Time Management System - MVP Design
**Target: Iteration 5 - Game Districts and Time Management**

## Overview

The Time Management System MVP establishes time as both a strategic resource and a world driver. Inspired by Persona 3's day planning mechanics and classic adventure game pacing, this system creates meaningful choices about how players spend their limited time investigating the assimilation threat. The MVP provides the foundation for time-based gameplay while integrating seamlessly with the Living World Event System.

## Design Goals

1. **Strategic Resource**: Make time a precious commodity that must be carefully allocated
2. **Clear Feedback**: Players always understand current time and cost of actions
3. **Meaningful Choices**: Different time allocation strategies lead to different outcomes
4. **World Integration**: Time progression triggers Living World events
5. **Save Integration**: Time provides natural save points through sleep mechanics

## Save/Load Integration

Time is fundamental to all game systems and must be serialized with the highest priority. Following the modular serialization architecture defined in `docs/design/modular_serialization_architecture.md`, the Time Management System implements its own TimeSerializer that ensures time state is always loaded first, before any time-dependent systems.

### Key Serialization Points

The TimeSerializer handles:
- **GameClock State**: Current time and day (loaded first to establish temporal context)
- **DayCycleController**: Last sleep day and exhaustion tracking
- **Time Cost Modifiers**: Any active modifiers affecting action costs
- **Forced Awake Status**: Whether player is being kept awake by events

### Implementation Approach

```gdscript
# src/core/serializers/time_serializer.gd
extends BaseSerializer

func _ready():
    # Register with high priority - time loads before events
    SaveManager.register_serializer("time", self, 10)

func serialize() -> Dictionary:
    return {
        "current_time": GameClock.current_time,
        "current_day": GameClock.current_day,
        "last_sleep_day": DayCycleController.last_sleep_day,
        "exhaustion_level": DayCycleController.exhaustion_level,
        "sleep_location": DayCycleController.sleep_location,
        "time_cost_modifiers": TimeCostManager.get_active_modifiers()
    }

func deserialize(data: Dictionary) -> void:
    # Restore time first - critical for all other systems
    GameClock.current_time = data.current_time
    GameClock.current_day = data.current_day
    
    # Restore sleep/exhaustion state
    DayCycleController.last_sleep_day = data.last_sleep_day
    DayCycleController.exhaustion_level = data.exhaustion_level
    
    # Apply any saved modifiers
    if "time_cost_modifiers" in data:
        TimeCostManager.restore_modifiers(data.time_cost_modifiers)
```

The high priority (10) ensures time is restored before the event system (priority 20) or NPC systems, preventing temporal inconsistencies during load.

## Core Components

### 1. Game Clock System

```gdscript
# src/core/systems/game_clock.gd
extends Node

class_name GameClock

signal time_advanced(old_time, new_time)
signal hour_changed(current_hour)
signal day_changed(current_day)
signal period_changed(period) # Morning, Afternoon, Evening, Night

var current_time: float = 480.0  # Minutes since midnight (8:00 AM start)
var current_day: int = 1
var game_speed: float = 0.0  # Time only advances through actions

const MINUTES_PER_DAY = 1440
const PERIOD_BOUNDARIES = {
    "morning": 360,    # 6:00 AM
    "afternoon": 720,  # 12:00 PM
    "evening": 1080,   # 6:00 PM
    "night": 1320      # 10:00 PM
}

func advance_time(minutes: int):
    """Advance game time by specified minutes"""
    var old_time = current_time
    current_time += minutes
    
    # Handle day rollover
    if current_time >= MINUTES_PER_DAY:
        current_time -= MINUTES_PER_DAY
        current_day += 1
        emit_signal("day_changed", current_day)
    
    emit_signal("time_advanced", old_time, current_time)
    check_period_change()

func get_formatted_time() -> String:
    """Return time as HH:MM format"""
    var hours = int(current_time / 60)
    var minutes = int(current_time) % 60
    return "%02d:%02d" % [hours, minutes]

func get_current_period() -> String:
    """Return current time period"""
    if current_time < PERIOD_BOUNDARIES.morning:
        return "night"
    elif current_time < PERIOD_BOUNDARIES.afternoon:
        return "morning"
    elif current_time < PERIOD_BOUNDARIES.evening:
        return "afternoon"
    elif current_time < PERIOD_BOUNDARIES.night:
        return "evening"
    else:
        return "night"
```

### 2. Time Cost Manager

```gdscript
# src/core/systems/time_cost_manager.gd
extends Node

class_name TimeCostManager

# Base time costs for actions
const TIME_COSTS = {
    # Movement
    "district_travel": 30,      # Tram between districts
    "local_movement": 5,        # Moving between rooms
    
    # Interactions
    "quick_dialog": 5,          # Simple yes/no
    "conversation": 15,         # Standard NPC conversation
    "deep_conversation": 30,    # Important story conversations
    
    # Activities
    "investigate_object": 10,   # Examining items
    "investigate_area": 30,     # Thorough search
    "work_shift": 240,         # 4-hour work shift
    "meal": 30,                # Eating at restaurant
    "shopping": 20,            # Buying items
    
    # Special
    "wait": 15,                # Minimum wait increment
    "sleep": 480               # 8 hours sleep
}

func get_action_cost(action_type: String, modifiers: Dictionary = {}) -> int:
    """Get time cost for an action with optional modifiers"""
    if not action_type in TIME_COSTS:
        push_warning("Unknown action type: " + action_type)
        return 5  # Default minimal cost
    
    var base_cost = TIME_COSTS[action_type]
    
    # Apply modifiers (e.g., rushed conversation, thorough investigation)
    if "multiplier" in modifiers:
        base_cost *= modifiers.multiplier
    
    if "additional" in modifiers:
        base_cost += modifiers.additional
    
    return int(base_cost)

func can_afford_action(action_type: String, time_until_deadline: int) -> bool:
    """Check if player has enough time for an action"""
    return get_action_cost(action_type) <= time_until_deadline
```

### 3. Day Cycle Controller

```gdscript
# src/core/systems/day_cycle_controller.gd
extends Node

class_name DayCycleController

signal sleep_initiated()
signal wake_up(new_day)
signal missed_sleep_warning()

var sleep_location: String = ""
var last_sleep_day: int = 0
var exhaustion_level: int = 0

func initiate_sleep(location: String = "player_bedroom"):
    """Begin sleep sequence"""
    sleep_location = location
    emit_signal("sleep_initiated")
    
    # Fade out, advance time, trigger events
    yield(get_tree().create_timer(1.0), "timeout")
    
    # Calculate sleep duration based on time
    var clock = GameClock
    var sleep_start = clock.current_time
    var sleep_duration = calculate_sleep_duration(sleep_start)
    
    # Advance to next morning
    clock.advance_time(sleep_duration)
    last_sleep_day = clock.current_day
    exhaustion_level = 0
    
    # Trigger overnight events
    SimpleEventScheduler.process_overnight_events()
    
    emit_signal("wake_up", clock.current_day)

func calculate_sleep_duration(sleep_time: float) -> int:
    """Calculate how long player sleeps based on when they go to bed"""
    var wake_time = 420  # 7:00 AM
    
    if sleep_time < wake_time:
        # Already past midnight
        return wake_time - sleep_time
    else:
        # Need to sleep through midnight
        return (1440 - sleep_time) + wake_time

func check_exhaustion():
    """Check if player has been awake too long"""
    var days_without_sleep = GameClock.current_day - last_sleep_day
    
    if days_without_sleep >= 2:
        exhaustion_level = days_without_sleep - 1
        if exhaustion_level >= 3:
            # Force sleep at nearest location
            force_emergency_sleep()
        else:
            emit_signal("missed_sleep_warning")
```

### 4. Time UI System

```gdscript
# src/ui/time_display/time_display.gd
extends Control

class_name TimeDisplay

onready var clock_label = $Panel/ClockLabel
onready var day_label = $Panel/DayLabel
onready var period_icon = $Panel/PeriodIcon
onready var cost_preview = $Panel/CostPreview

var period_icons = {
    "morning": preload("res://src/assets/ui/icons/sun_rise.png"),
    "afternoon": preload("res://src/assets/ui/icons/sun_high.png"),
    "evening": preload("res://src/assets/ui/icons/sun_set.png"),
    "night": preload("res://src/assets/ui/icons/moon.png")
}

func _ready():
    GameClock.connect("time_advanced", self, "_on_time_advanced")
    GameClock.connect("day_changed", self, "_on_day_changed")
    GameClock.connect("period_changed", self, "_on_period_changed")
    
    update_display()

func update_display():
    """Update all time UI elements"""
    clock_label.text = GameClock.get_formatted_time()
    day_label.text = "Day %d" % GameClock.current_day
    period_icon.texture = period_icons[GameClock.get_current_period()]

func preview_time_cost(action_type: String):
    """Show preview of time cost for hovering action"""
    var cost = TimeCostManager.get_action_cost(action_type)
    var new_time = GameClock.current_time + cost
    
    # Show what time it will be after action
    var hours = int(new_time / 60) % 24
    var minutes = int(new_time) % 60
    
    cost_preview.text = "→ %02d:%02d (+%d min)" % [hours, minutes, cost]
    cost_preview.show()

func hide_time_cost_preview():
    cost_preview.hide()
```

## Data Structures

### Time Configuration

```json
{
  "time_config": {
    "starting_time": 480,
    "starting_day": 1,
    "time_scales": {
      "normal": 1.0,
      "debug_fast": 10.0,
      "debug_slow": 0.1
    },
    "auto_save_on_sleep": true,
    "force_sleep_after_days": 3
  }
}
```

### Action Time Costs

```json
{
  "action_costs": {
    "travel": {
      "tram_ride": 30,
      "elevator": 5,
      "stairs": 10
    },
    "dialog": {
      "greeting": 2,
      "small_talk": 5,
      "normal_conversation": 15,
      "deep_conversation": 30,
      "interrogation": 45
    },
    "investigation": {
      "quick_look": 5,
      "examine_object": 10,
      "search_area": 30,
      "thorough_investigation": 60
    },
    "work": {
      "short_task": 60,
      "normal_shift": 240,
      "overtime": 360
    }
  }
}
```

## Integration with Other Systems

### Living World Event System Integration

```gdscript
# Time advances trigger event checks
func advance_time(minutes: int):
    var old_time = current_time
    current_time += minutes
    
    # Notify Living World system
    SimpleEventScheduler._on_time_advanced(current_time)
    NPCScheduleManager.update_npc_locations(current_time)
```

### Dialog System Integration

```gdscript
# Conversations consume time based on depth
func end_conversation(conversation_depth: String):
    var time_cost = TimeCostManager.get_action_cost(conversation_depth)
    GameClock.advance_time(time_cost)
    
    # Update NPC availability
    npc.last_conversation_time = GameClock.current_time
```

### Save System Integration

```gdscript
# Sleep provides natural save points
func save_game_state():
    var save_data = {
        "current_time": GameClock.current_time,
        "current_day": GameClock.current_day,
        "last_sleep_day": DayCycleController.last_sleep_day,
        "exhaustion_level": DayCycleController.exhaustion_level
    }
    SaveManager.save_time_data(save_data)
```

## Player Feedback Systems

### Time Cost Warnings

Before committing to actions, players see:
1. **Hover Preview**: Time cost appears when hovering over actions
2. **Confirmation Dialog**: For major time commitments (work shifts, sleep)
3. **Deadline Warnings**: Alert when approaching important timed events
4. **Exhaustion Indicators**: Visual cues when too tired

### Visual Time Indicators

1. **Clock Display**: Always visible, shows exact time
2. **Day Counter**: Current day number
3. **Period Icon**: Sun/moon position indicates rough time
4. **Time Flow Animation**: Brief animation when time advances

## Balancing Considerations

### Time Economy

Daily time budget (conscious hours):
- Wake at 7:00 AM (420 minutes)
- Sleep by 11:00 PM (1380 minutes)
- **Total: 960 minutes (16 hours) per day**

Typical daily activities:
- Travel: 60-120 minutes
- Conversations: 60-120 minutes  
- Investigation: 120-240 minutes
- Work (optional): 240 minutes
- Meals/breaks: 60 minutes

This leaves 3-6 hours for strategic choices.

### Pacing Guidelines

1. **Early Game**: Generous time, learn mechanics
2. **Mid Game**: Time pressure increases, meaningful trade-offs
3. **Late Game**: Every minute counts, maximum pressure

## MVP Scope Limitations

The MVP does **not** include:
- Real-time time progression
- Complex deadline management
- Time manipulation mechanics
- Seasonal changes
- Weather systems
- Complex fatigue mechanics

These features are reserved for full implementation.

## Testing Considerations

### Debug Commands

```gdscript
# Debug time controls
func _on_debug_command(command: String, params: Array):
    match command:
        "advance_time":
            GameClock.advance_time(int(params[0]))
        "set_time":
            GameClock.current_time = float(params[0])
        "set_day":
            GameClock.current_day = int(params[0])
        "force_sleep":
            DayCycleController.initiate_sleep()
        "toggle_exhaustion":
            DayCycleController.exhaustion_level = 3
```

### Balance Testing

Key metrics to monitor:
1. Average actions per day
2. Time spent in each activity category
3. Player sleep patterns
4. Missed event frequency

## Success Metrics

1. Players report feeling time pressure without frustration
2. Different time strategies lead to meaningfully different outcomes
3. Time costs feel intuitive and predictable
4. UI clearly communicates time state and costs
5. Integration with Living World events works seamlessly