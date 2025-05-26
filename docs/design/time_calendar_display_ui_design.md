# Time/Calendar Display UI Design Document

## Overview

The Time/Calendar Display UI provides players with constant awareness of the current time, day, and critical deadlines in "A Silent Refraction". This UI element integrates with all time-sensitive systems including quest deadlines, NPC schedules, rent payments, and the crucial assimilation evaluation date that determines the game's ending.

## Core Design Principles

### Always Visible
- Persistent UI element that's always on screen
- Non-intrusive placement that doesn't block gameplay
- Clear readability against all backgrounds
- Contextual expansion for detailed information

### Information Hierarchy
- Current time and day always visible
- Critical deadlines highlighted when approaching
- System integration indicators (fatigue, events, etc.)
- Quick access to expanded calendar view

## Primary Display

### Minimal Always-On Display
```
┌─────────────────────────┐
│ Day 12 | 14:30          │
│ [!] Rent due: 2 days    │
└─────────────────────────┘
```

### Expanded Hover Display
```
┌──────────────────────────────────────┐
│ Day 12 of 40 | 14:30 (Afternoon)    │
├──────────────────────────────────────┤
│ Station Status: 42% Assimilated      │
│ Evaluation Day: 30 (18 days)         │
│                                      │
│ Upcoming:                            │
│ • Day 14: Rent Due (450¢)           │
│ • Day 15: Marcus Report Due          │
│ • Day 16: Coalition Meeting          │
│                                      │
│ Today's Schedule:                    │
│ • 16:00: Shops close                 │
│ • 18:00: Tram reduced service        │
│ • 20:00: Can sleep                   │
└──────────────────────────────────────┘
```

## UI Components

### Time Display Component
```gdscript
class TimeDisplay extends PanelContainer:
    # Visual configuration
    const NORMAL_COLOR = Color(0.8, 0.8, 0.8)
    const WARNING_COLOR = Color(0.9, 0.7, 0.4)
    const CRITICAL_COLOR = Color(0.9, 0.4, 0.4)
    
    # References
    onready var day_label = $HBox/DayLabel
    onready var time_label = $HBox/TimeLabel
    onready var alert_icon = $HBox/AlertIcon
    onready var deadline_label = $VBox/DeadlineLabel
    
    func _ready():
        # Connect to all time-sensitive systems
        TimeManager.connect("time_changed", self, "_on_time_changed")
        TimeManager.connect("day_changed", self, "_on_day_changed")
        QuestManager.connect("deadline_approaching", self, "_on_deadline_approaching")
        EconomyManager.connect("rent_reminder", self, "_on_rent_reminder")
        AssimilationManager.connect("ratio_updated", self, "_on_assimilation_updated")
        FatigueSystem.connect("exhaustion_critical", self, "_on_exhaustion_critical")
    
    func _on_time_changed(new_time: Dictionary):
        time_label.text = "%02d:%02d" % [new_time.hour, new_time.minute]
        
        # Update time period indicator
        var period = TimeManager.get_time_period()
        time_label.hint_tooltip = period  # "Morning", "Afternoon", etc.
        
        # Check for time-sensitive warnings
        update_time_warnings()
```

### Calendar View Component
```gdscript
class CalendarView extends PopupPanel:
    const DAYS_TO_SHOW = 14  # Two weeks ahead
    
    onready var calendar_grid = $VBox/CalendarGrid
    onready var event_list = $VBox/EventList
    onready var assimilation_bar = $VBox/AssimilationStatus/ProgressBar
    
    func populate_calendar():
        var current_day = TimeManager.current_day
        var evaluation_day = MultipleEndingsManager.critical_evaluation_day
        
        for i in range(DAYS_TO_SHOW):
            var day = current_day + i
            var day_cell = create_day_cell(day)
            
            # Highlight special days
            if day == evaluation_day:
                day_cell.modulate = Color.red
                day_cell.hint_tooltip = "ENDING EVALUATION DAY"
            
            # Add events for this day
            var events = get_events_for_day(day)
            for event in events:
                day_cell.add_event_indicator(event)
            
            calendar_grid.add_child(day_cell)
    
    func get_events_for_day(day: int) -> Array:
        var events = []
        
        # Quest deadlines
        var quest_deadlines = QuestManager.get_deadlines_for_day(day)
        for quest in quest_deadlines:
            events.append({
                "type": "quest",
                "name": quest.name,
                "critical": quest.priority == "critical"
            })
        
        # Economic events
        if EconomyManager.is_rent_due_day(day):
            events.append({
                "type": "rent",
                "name": "Rent Due",
                "amount": EconomyManager.get_rent_amount(),
                "critical": true
            })
        
        # Coalition events
        var coalition_events = CoalitionManager.get_scheduled_events(day)
        events.extend(coalition_events)
        
        # NPC appointments
        var appointments = NPCScheduleManager.get_player_appointments(day)
        events.extend(appointments)
        
        return events
```

## System Integration

### Time Management System
```gdscript
func integrate_time_system():
    # Real-time updates
    TimeManager.connect("minute_passed", self, "_on_minute_passed")
    
    # Time-based UI changes
    func _on_minute_passed():
        # Update display
        refresh_time_display()
        
        # Check for hourly alerts
        if TimeManager.current_minute == 0:
            check_hourly_alerts()
        
        # Fatigue indicator
        if FatigueSystem.get_exhaustion() > 0.8:
            add_status_indicator("exhausted", Color.orange)
```

### Quest System Integration
```gdscript
func show_quest_deadlines():
    var urgent_quests = QuestManager.get_quests_by_urgency()
    var display_items = []
    
    for quest in urgent_quests:
        if quest.time_limit > 0:
            var days_left = quest.time_limit - TimeManager.current_day
            
            if days_left <= 3:  # Show if 3 days or less
                display_items.append({
                    "text": "%s: %d days" % [quest.name, days_left],
                    "color": get_urgency_color(days_left),
                    "icon": "quest_deadline"
                })
    
    deadline_container.set_items(display_items)
```

### Economy System Integration
```gdscript
func track_economic_deadlines():
    # Rent tracking
    var rent_status = EconomyManager.get_rent_status()
    if rent_status.due_in_days <= 7:
        add_economic_warning("Rent due", rent_status.due_in_days, rent_status.amount)
    
    # Market events
    var market_schedule = EconomyManager.get_market_schedule()
    for event in market_schedule:
        if event.day - TimeManager.current_day <= 3:
            add_economic_event(event)
```

### Assimilation System Integration
```gdscript
func display_assimilation_countdown():
    var evaluation_day = MultipleEndingsManager.critical_evaluation_day
    var current_day = TimeManager.current_day
    var days_remaining = evaluation_day - current_day
    
    # Always show this critical information
    var ratio = AssimilationManager.get_station_ratio()
    assimilation_indicator.text = "Station: %d%% [Day %d]" % [ratio * 100, evaluation_day]
    
    # Color coding based on ending trajectory
    if ratio < 0.35:
        assimilation_indicator.modulate = Color.green  # Escape ending
    elif ratio >= 0.65:
        assimilation_indicator.modulate = Color.blue   # Control ending
    else:
        assimilation_indicator.modulate = Color.yellow # Undecided
    
    # Critical warning as evaluation approaches
    if days_remaining <= 5:
        flash_critical_warning("Evaluation in %d days!" % days_remaining)
```

### NPC Schedule Integration
```gdscript
func show_npc_availability():
    # Show when important NPCs are available
    var tracked_npcs = QuestManager.get_npcs_with_active_quests()
    
    for npc_id in tracked_npcs:
        var schedule = NPCScheduleManager.get_schedule(npc_id)
        var next_available = schedule.get_next_available_time()
        
        if next_available.day == TimeManager.current_day:
            add_schedule_note("%s available at %s" % [
                NPCRegistry.get_npc_name(npc_id),
                format_time(next_available.time)
            ])
```

### Coalition System Integration
```gdscript
func track_coalition_timing():
    # Time-sensitive coalition operations
    var active_ops = CoalitionManager.get_active_operations()
    
    for op in active_ops:
        if op.has_time_window:
            var time_remaining = op.calculate_time_remaining()
            if time_remaining < 120:  # Less than 2 hours
                add_urgent_coalition_alert(op)
        
        # Show infiltration risk periods
        if op.type == "infiltration" and DisguiseManager.is_disguised():
            show_shift_timer(op.shift_end_time)
```

### Detection System Integration
```gdscript
func display_detection_timers():
    var detection_state = DetectionManager.get_current_state()
    
    if detection_state != DetectionState.NONE:
        # Show countdown to next escalation
        var escalation_time = DetectionManager.get_escalation_timer()
        add_detection_warning(detection_state, escalation_time)
        
        # Flash during pursuit
        if detection_state == DetectionState.PURSUING:
            start_critical_flash()
```

## Visual Design

### Positioning and Layout
```gdscript
func setup_display_position():
    # Top-right corner by default
    anchor_left = 1.0
    anchor_right = 1.0
    anchor_top = 0.0
    anchor_bottom = 0.0
    
    # Offset from edges
    margin_left = -200
    margin_right = -10
    margin_top = 10
    margin_bottom = 60
    
    # Allow player to reposition in settings
    if Settings.has_custom_time_position():
        apply_custom_position(Settings.time_display_position)
```

### Visual States
```gdscript
const DisplayStates = {
    "normal": {
        "bg_color": Color(0.1, 0.1, 0.1, 0.8),
        "text_color": Color(0.8, 0.8, 0.8),
        "border_color": Color(0.3, 0.3, 0.3)
    },
    "warning": {
        "bg_color": Color(0.3, 0.2, 0.1, 0.9),
        "text_color": Color(0.9, 0.7, 0.4),
        "border_color": Color(0.9, 0.7, 0.4)
    },
    "critical": {
        "bg_color": Color(0.3, 0.1, 0.1, 0.9),
        "text_color": Color(0.9, 0.4, 0.4),
        "border_color": Color(0.9, 0.4, 0.4),
        "flash": true
    }
}
```

### Contextual Information
```gdscript
func show_contextual_info():
    var context = get_current_context()
    
    # Shopping hours
    if context.in_shop_district:
        var shop_hours = DistrictManager.get_shop_hours()
        if TimeManager.current_hour >= shop_hours.close - 1:
            add_context_warning("Shops close at %d:00" % shop_hours.close)
    
    # Tram schedule
    if context.near_tram_station:
        var next_tram = TramSystem.get_next_departure()
        add_context_info("Next tram: %s" % format_time(next_tram))
    
    # Sleep availability
    if TimeManager.current_hour >= 20:
        add_context_info("You can sleep now")
    elif FatigueSystem.get_exhaustion() > 0.9:
        add_context_warning("Exhausted - find somewhere to rest")
```

## Expanded Calendar Features

### Monthly View
```gdscript
class MonthlyCalendar extends Control:
    func draw_month_view():
        var current_day = TimeManager.current_day
        var days_in_game = 40  # Total game days
        
        # Draw grid
        for day in range(1, days_in_game + 1):
            var cell = create_calendar_cell(day)
            
            # Current day highlight
            if day == current_day:
                cell.highlight_current()
            
            # Past days are grayed out
            elif day < current_day:
                cell.modulate = Color(0.5, 0.5, 0.5)
            
            # Special day markers
            if day == 30:  # Default evaluation day
                cell.mark_as_critical("EVALUATION")
            
            # Add event indicators
            add_day_events(cell, day)
            
            month_grid.add_child(cell)
```

### Event Details Panel
```gdscript
func show_event_details(event: Dictionary):
    var details = EventDetailsPanel.instance()
    
    details.set_title(event.name)
    details.set_time("Day %d, %s" % [event.day, event.time])
    
    # Event-specific information
    match event.type:
        "quest_deadline":
            details.add_info("Quest: " + event.quest_name)
            details.add_rewards(event.rewards)
            details.add_consequences(event.failure_consequences)
            
        "rent_due":
            details.add_cost(event.amount)
            details.add_warning("Failure to pay will result in eviction")
            
        "coalition_meeting":
            details.add_participants(event.members)
            details.add_location(event.safe_house)
            details.add_risk_level(event.infiltration_risk)
            
        "assimilation_event":
            details.add_critical_warning("Projected spread: +%d%%" % event.spread_estimate)
    
    details.popup()
```

## Modular Serialization

```gdscript
# UI state serializer for persistent display preferences
class TimeDisplaySerializer extends BaseSerializer:
    func get_serializer_id() -> String:
        return "time_display_ui"
    
    func get_version() -> int:
        return 1
    
    func serialize() -> Dictionary:
        var ui_manager = get_node("/root/Game/UI/TimeDisplay")
        if not ui_manager:
            return {}
        
        return {
            "position": ui_manager.rect_position,
            "expanded": ui_manager.is_expanded,
            "show_calendar": ui_manager.calendar_visible,
            "tracked_events": ui_manager.get_tracked_event_ids(),
            "display_mode": ui_manager.current_mode,
            "custom_alerts": ui_manager.custom_alerts
        }
    
    func deserialize(data: Dictionary) -> void:
        var ui_manager = get_node("/root/Game/UI/TimeDisplay")
        if not ui_manager:
            return
        
        ui_manager.rect_position = data.get("position", ui_manager.rect_position)
        ui_manager.is_expanded = data.get("expanded", false)
        ui_manager.calendar_visible = data.get("show_calendar", false)
        ui_manager.set_tracked_events(data.get("tracked_events", []))
        ui_manager.current_mode = data.get("display_mode", "minimal")
        ui_manager.custom_alerts = data.get("custom_alerts", [])
    
    func _ready():
        # Low priority - UI state
        SaveManager.register_serializer("time_display_ui", self, 80)
```

## Accessibility Features

### High Visibility Mode
```gdscript
func apply_high_visibility():
    # Larger font
    var font = time_label.get_font("font")
    font.size = Settings.ui_font_size * 1.5
    
    # High contrast colors
    modulate = Color.white
    self_modulate = Color.black
    
    # Thicker borders
    var border = StyleBoxFlat.new()
    border.border_width_all = 3
    border.border_color = Color.white
    add_stylebox_override("panel", border)
```

### Screen Reader Support
```gdscript
func get_accessibility_text() -> String:
    var text = "Day %d, %s" % [TimeManager.current_day, format_time_accessible()]
    
    # Add critical information
    if has_urgent_deadlines():
        text += ". Urgent: " + get_urgent_deadline_text()
    
    # Assimilation status
    var ratio = AssimilationManager.get_station_ratio()
    text += ". Station %d percent assimilated" % (ratio * 100)
    
    return text
```

## Performance Optimization

### Update Throttling
```gdscript
var update_timer: float = 0.0
const UPDATE_INTERVAL = 1.0  # Update every second

func _process(delta):
    update_timer += delta
    
    if update_timer >= UPDATE_INTERVAL:
        update_timer = 0.0
        refresh_display()
        
        # Less frequent updates
        if Engine.get_frames_drawn() % 60 == 0:  # Every 60 frames
            update_calendar_preview()
            check_long_term_events()
```

### Lazy Loading
```gdscript
func _on_calendar_requested():
    if not calendar_loaded:
        load_calendar_data()
        calendar_loaded = true
    
    show_calendar()

func _on_mouse_exited():
    # Don't immediately hide - user might be moving to calendar
    hide_timer.start(0.5)
```

## Debug Features

```gdscript
class TimeDebugCommands:
    static func register_commands():
        if not OS.is_debug_build():
            return
        
        Console.register_command("set_time", self, "_cmd_set_time",
            "Set current time (hour minute)")
        Console.register_command("set_day", self, "_cmd_set_day",
            "Set current day")
        Console.register_command("add_deadline", self, "_cmd_add_deadline",
            "Add test deadline (name day)")
        Console.register_command("show_all_events", self, "_cmd_show_all_events",
            "Display all scheduled events")
```

## Integration with Sleep System

When the Sleep System is implemented, the Time Display will:
- Show when player can sleep (after 20:00 or when exhausted)
- Display sleep location availability
- Warn about consequences of not sleeping
- Show overnight event previews

## Conclusion

The Time/Calendar Display UI serves as the player's constant companion for managing the complex web of time-sensitive systems in "A Silent Refraction". By providing both at-a-glance information and detailed calendar views, players can make informed decisions about their limited time. The deep integration with all game systems ensures players are never blindsided by deadlines, while the prominent assimilation countdown creates constant tension as they approach the critical evaluation day that determines their fate.