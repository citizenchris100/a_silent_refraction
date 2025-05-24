# Time Management System - Full Implementation
**Target: Future Iteration - Complete Time Management System**

## Overview

The Time Management System full implementation builds upon the MVP foundation to create a sophisticated temporal framework that drives both gameplay tension and narrative branching. This system adds deadline management, time-based narrative consequences, advanced fatigue mechanics, and complex scheduling conflicts that force players to make increasingly difficult choices about their priorities.

## Design Goals

1. **Escalating Pressure**: Time becomes increasingly scarce as the story progresses
2. **Narrative Integration**: Time choices directly affect story outcomes
3. **Complex Trade-offs**: Multi-layered scheduling conflicts create tough decisions
4. **Player Mastery**: Experienced players can optimize time usage through knowledge
5. **Emergent Strategies**: Multiple valid approaches to time management
6. **Emotional Investment**: Time pressure creates genuine stakes and tension

## Enhanced Components

### 1. Advanced Deadline System

```gdscript
# src/core/systems/deadline_manager.gd
extends Node

class_name DeadlineManager

signal deadline_approaching(deadline_id, hours_remaining)
signal deadline_missed(deadline_id, consequences)
signal deadline_completed(deadline_id)

class Deadline:
    var id: String
    var description: String
    var due_time: float  # Absolute game time
    var warning_thresholds: Array = [1440, 720, 360, 120]  # Minutes before
    var consequences: Dictionary = {}
    var prerequisites: Array = []  # Other deadlines that must complete first
    var conflicts_with: Array = []  # Deadlines that can't both be met
    var priority: int = 0  # Higher = more important
    var is_hidden: bool = false  # Player doesn't know about it yet
    var completion_time_required: int = 0  # Minutes needed to complete

var active_deadlines: Dictionary = {}  # {id: Deadline}
var completed_deadlines: Array = []
var missed_deadlines: Array = []

func add_deadline(deadline: Deadline):
    """Add a new deadline to track"""
    active_deadlines[deadline.id] = deadline
    
    # Check for conflicts
    for other_id in active_deadlines:
        if other_id != deadline.id:
            check_deadline_conflict(deadline.id, other_id)

func check_deadline_conflict(id1: String, id2: String):
    """Determine if two deadlines conflict"""
    var d1 = active_deadlines[id1]
    var d2 = active_deadlines[id2]
    
    # Time overlap check
    var time_needed = d1.completion_time_required + d2.completion_time_required
    var time_available = min(d1.due_time, d2.due_time) - GameClock.current_time
    
    if time_needed > time_available:
        d1.conflicts_with.append(id2)
        d2.conflicts_with.append(id1)
        emit_signal("deadline_conflict_detected", id1, id2)

func evaluate_deadline_chains():
    """Analyze cascading effects of missing deadlines"""
    var impact_analysis = {}
    
    for deadline_id in active_deadlines:
        var deadline = active_deadlines[deadline_id]
        impact_analysis[deadline_id] = {
            "direct_consequences": deadline.consequences,
            "cascade_effects": calculate_cascade_effects(deadline_id),
            "affected_npcs": get_affected_npcs(deadline.consequences),
            "story_branches_closed": get_closed_branches(deadline_id)
        }
    
    return impact_analysis
```

### 2. Complex Fatigue System

```gdscript
# src/core/systems/fatigue_system.gd
extends Node

class_name FatigueSystem

signal fatigue_level_changed(new_level)
signal fatigue_effect_applied(effect_type, severity)
signal collapse_imminent()

enum FatigueLevel {
    RESTED,      # 0-20%
    ALERT,       # 20-40%
    TIRED,       # 40-60%
    EXHAUSTED,   # 60-80%
    CRITICAL     # 80-100%
}

var fatigue_value: float = 0.0  # 0-100
var fatigue_multiplier: float = 1.0  # Increases with consecutive all-nighters
var stimulant_resistance: float = 0.0  # Builds up with use

# Fatigue effects on gameplay
var fatigue_effects = {
    FatigueLevel.TIRED: {
        "movement_speed": 0.9,
        "dialog_options": -1,  # Fewer dialog choices
        "investigation_penalty": 0.15,  # Miss clues
        "time_cost_multiplier": 1.1  # Everything takes longer
    },
    FatigueLevel.EXHAUSTED: {
        "movement_speed": 0.75,
        "dialog_options": -2,
        "investigation_penalty": 0.3,
        "time_cost_multiplier": 1.25,
        "random_microsleeps": true  # Brief blackouts
    },
    FatigueLevel.CRITICAL: {
        "movement_speed": 0.5,
        "dialog_options": -3,
        "investigation_penalty": 0.5,
        "time_cost_multiplier": 1.5,
        "hallucinations": true,  # See things that aren't there
        "force_sleep_chance": 0.1  # Per action
    }
}

func accumulate_fatigue(delta_time: float):
    """Increase fatigue based on time awake"""
    var hours_awake = (GameClock.current_time - last_sleep_time) / 60.0
    
    # Exponential fatigue accumulation
    var base_rate = 0.5  # Fatigue per hour
    var rate = base_rate * pow(1.1, max(0, hours_awake - 16))
    
    fatigue_value += rate * delta_time * fatigue_multiplier
    fatigue_value = clamp(fatigue_value, 0, 100)
    
    check_fatigue_effects()

func use_stimulant(stimulant_type: String):
    """Temporarily reduce fatigue with diminishing returns"""
    var effectiveness = 1.0 - stimulant_resistance
    
    match stimulant_type:
        "coffee":
            fatigue_value -= 15 * effectiveness
            stimulant_resistance += 0.1
        "energy_drink":
            fatigue_value -= 25 * effectiveness
            stimulant_resistance += 0.15
        "medication":
            fatigue_value -= 40 * effectiveness
            stimulant_resistance += 0.25
            # Risk of side effects
            if randf() < stimulant_resistance:
                apply_stimulant_side_effect()
    
    fatigue_value = max(0, fatigue_value)
```

### 3. Time-Based Narrative Branching

```gdscript
# src/core/systems/temporal_narrative_manager.gd
extends Node

class_name TemporalNarrativeManager

class TimeBranch:
    var id: String
    var trigger_conditions: Dictionary = {
        "min_day": 0,
        "max_day": -1,  # -1 = no limit
        "time_window": Vector2(),  # (start_hour, end_hour)
        "required_events": [],
        "excluded_events": []
    }
    var narrative_changes: Dictionary = {}
    var closes_branches: Array = []  # Other branches that become unavailable
    var opens_branches: Array = []  # New branches that become available

var narrative_branches: Dictionary = {}
var active_branch_path: Array = []  # History of taken branches
var locked_out_content: Array = []  # Content no longer accessible

func check_branch_availability(branch_id: String) -> bool:
    """Determine if a narrative branch is still available"""
    var branch = narrative_branches[branch_id]
    var conditions = branch.trigger_conditions
    
    # Check day limits
    if conditions.min_day > 0 and GameClock.current_day < conditions.min_day:
        return false
    
    if conditions.max_day > 0 and GameClock.current_day > conditions.max_day:
        locked_out_content.append(branch_id)
        return false
    
    # Check time window
    if conditions.time_window != Vector2():
        var current_hour = GameClock.current_time / 60.0
        if current_hour < conditions.time_window.x or current_hour > conditions.time_window.y:
            return false
    
    # Check event prerequisites
    for required_event in conditions.required_events:
        if not EventScheduler.has_event_occurred(required_event):
            return false
    
    # Check excluded events
    for excluded_event in conditions.excluded_events:
        if EventScheduler.has_event_occurred(excluded_event):
            locked_out_content.append(branch_id)
            return false
    
    return true

func activate_branch(branch_id: String):
    """Activate a narrative branch and apply its consequences"""
    var branch = narrative_branches[branch_id]
    active_branch_path.append(branch_id)
    
    # Apply narrative changes
    apply_narrative_changes(branch.narrative_changes)
    
    # Close conflicting branches
    for closed_branch in branch.closes_branches:
        locked_out_content.append(closed_branch)
    
    # Open new branches
    for opened_branch in branch.opens_branches:
        unlock_branch(opened_branch)
```

### 4. Scheduling Conflict System

```gdscript
# src/core/systems/schedule_conflict_manager.gd
extends Node

class_name ScheduleConflictManager

signal conflict_created(conflict_data)
signal conflict_resolved(conflict_id, resolution)

class ScheduleConflict:
    var id: String
    var conflicting_activities: Array = []  # Activities that overlap
    var time_slot: Vector2  # (start_time, end_time)
    var resolution_options: Array = []
    var auto_resolve_priority: String = ""  # Which activity wins if player doesn't choose
    var consequences: Dictionary = {}  # Per activity choice

func create_conflict(activities: Array) -> ScheduleConflict:
    """Create a scheduling conflict from overlapping activities"""
    var conflict = ScheduleConflict.new()
    conflict.id = generate_conflict_id()
    conflict.conflicting_activities = activities
    
    # Calculate overlap window
    var latest_start = 0
    var earliest_end = 9999
    
    for activity in activities:
        latest_start = max(latest_start, activity.start_time)
        earliest_end = min(earliest_end, activity.end_time)
    
    conflict.time_slot = Vector2(latest_start, earliest_end)
    
    # Generate resolution options
    conflict.resolution_options = generate_resolution_options(activities)
    
    emit_signal("conflict_created", conflict)
    return conflict

func generate_resolution_options(activities: Array) -> Array:
    """Create player choices for resolving conflicts"""
    var options = []
    
    # Option 1: Choose one activity
    for activity in activities:
        options.append({
            "type": "choose_single",
            "activity": activity,
            "description": "Focus on " + activity.name,
            "consequences": calculate_skip_consequences(activities, activity)
        })
    
    # Option 2: Try to do both (rushed)
    if activities.size() == 2:
        options.append({
            "type": "rush_both",
            "description": "Try to do both quickly",
            "time_modifier": 0.7,  # Each takes 70% time
            "success_modifier": 0.6,  # 60% effectiveness
            "fatigue_cost": 1.5  # Extra tiring
        })
    
    # Option 3: Delegate (if applicable)
    for activity in activities:
        if activity.can_delegate:
            options.append({
                "type": "delegate",
                "activity": activity,
                "delegate_to": find_delegate_candidate(activity),
                "relationship_cost": -10,
                "effectiveness": 0.8
            })
    
    return options
```

### 5. Advanced Time UI

```gdscript
# src/ui/time_display/advanced_time_display.gd
extends Control

class_name AdvancedTimeDisplay

# Enhanced UI components
onready var timeline_view = $TimelinePanel/TimelineView
onready var deadline_tracker = $DeadlinePanel/DeadlineList
onready var schedule_preview = $SchedulePanel/DaySchedule
onready var fatigue_meter = $StatusPanel/FatigueMeter
onready var time_pressure_indicator = $StatusPanel/PressureGauge

func _ready():
    # Connect to all time systems
    GameClock.connect("time_advanced", self, "_on_time_advanced")
    DeadlineManager.connect("deadline_approaching", self, "_on_deadline_approaching")
    FatigueSystem.connect("fatigue_level_changed", self, "_on_fatigue_changed")
    ScheduleConflictManager.connect("conflict_created", self, "_on_conflict_created")

func update_timeline_view():
    """Show visual timeline of upcoming events and deadlines"""
    timeline_view.clear()
    
    var hours_to_show = 24
    var events = SimpleEventScheduler.get_upcoming_events(hours_to_show)
    var deadlines = DeadlineManager.get_upcoming_deadlines(hours_to_show)
    
    # Plot events and deadlines on timeline
    for event in events:
        var marker = create_event_marker(event)
        timeline_view.add_child(marker)
    
    for deadline in deadlines:
        var marker = create_deadline_marker(deadline)
        timeline_view.add_child(marker)
    
    # Show conflicts
    var conflicts = ScheduleConflictManager.get_pending_conflicts()
    for conflict in conflicts:
        highlight_conflict_zone(conflict.time_slot)

func show_deadline_warning(deadline_id: String, hours_remaining: int):
    """Display urgent deadline warning"""
    var warning = preload("res://src/ui/warnings/deadline_warning.tscn").instance()
    warning.setup(deadline_id, hours_remaining)
    add_child(warning)
    
    # Pulse effect for urgency
    if hours_remaining <= 2:
        warning.modulate = Color(1, 0.3, 0.3)
        create_pulse_animation(warning)

func update_fatigue_display(fatigue_level: int):
    """Show fatigue effects on UI"""
    fatigue_meter.value = FatigueSystem.fatigue_value
    
    # Visual effects based on fatigue
    match fatigue_level:
        FatigueLevel.TIRED:
            add_slight_blur()
        FatigueLevel.EXHAUSTED:
            add_heavy_blur()
            add_occasional_blink()
        FatigueLevel.CRITICAL:
            add_distortion_effect()
            add_microsleep_blackouts()
```

## Advanced Features

### Dynamic Time Costs

Actions have variable time costs based on context:

```gdscript
func calculate_contextual_time_cost(base_action: String, context: Dictionary) -> int:
    var base_cost = TimeCostManager.get_action_cost(base_action)
    var final_cost = base_cost
    
    # Fatigue modifier
    var fatigue_mult = FatigueSystem.get_time_cost_multiplier()
    final_cost *= fatigue_mult
    
    # Relationship modifier (friendly NPCs talk longer)
    if "npc" in context:
        var relationship = NPCManager.get_relationship(context.npc)
        if relationship > 0.7:
            final_cost *= 1.2  # Good friends chat longer
        elif relationship < 0.3:
            final_cost *= 0.8  # Hostile interactions are brief
    
    # Urgency modifier
    if "urgent" in context and context.urgent:
        final_cost *= 0.7  # Rushed actions
    
    # Location modifier (some places are slower)
    if "location" in context:
        match context.location:
            "bureaucracy":
                final_cost *= 1.5  # Red tape
            "emergency":
                final_cost *= 0.5  # Crisis mode
    
    return int(final_cost)
```

### Temporal Reputation System

How you manage time affects NPC relationships:

```gdscript
class TemporalReputation:
    var punctuality_score: float = 0.0  # -1.0 to 1.0
    var reliability_score: float = 0.0
    var promise_history: Array = []  # Kept/broken promises
    
    func record_appointment_result(npc_id: String, promised_time: float, actual_time: float):
        var punctuality = calculate_punctuality(promised_time, actual_time)
        
        # Update scores
        punctuality_score = lerp(punctuality_score, punctuality, 0.2)
        
        # NPC reaction
        if punctuality < -0.5:  # Very late
            NPCManager.modify_relationship(npc_id, -20)
            NPCManager.add_dialog_flag(npc_id, "player_unreliable")
        elif punctuality > 0.8:  # On time
            NPCManager.modify_relationship(npc_id, 5)
```

### Time-Gated Content

Some content only available during specific windows:

```json
{
  "time_gated_events": {
    "secret_meeting": {
      "available_days": [5, 10, 15],
      "time_window": [21, 23],
      "prerequisites": ["gained_trust"],
      "miss_consequences": {
        "story_branch": "coalition_without_player",
        "relationship_changes": {"resistance_leader": -30}
      }
    },
    "shift_supervisor_alone": {
      "daily_window": [2, 4],
      "location": "shipping_office",
      "opportunity": "investigate_suspicious_manifest"
    }
  }
}
```

### Predictive Time Planning

AI helps players plan their time:

```gdscript
func suggest_daily_schedule(priorities: Array) -> Dictionary:
    """Generate optimal schedule based on player priorities"""
    var schedule = {}
    var available_time = 960  # 16 waking hours
    
    # Account for fixed commitments
    var fixed_time = calculate_fixed_commitments()
    available_time -= fixed_time
    
    # Optimize remaining time
    var activities = prioritize_activities(priorities)
    
    for activity in activities:
        if activity.time_cost <= available_time:
            schedule[activity.time_slot] = activity
            available_time -= activity.time_cost
    
    # Warn about unachievable goals
    var unscheduled = get_unscheduled_priorities(priorities, schedule)
    if unscheduled.size() > 0:
        show_scheduling_warning(unscheduled)
    
    return schedule
```

## Balancing Framework

### Difficulty Scaling

Time pressure increases as game progresses:

1. **Days 1-3**: Tutorial pace, forgiving deadlines
2. **Days 4-7**: Moderate pressure, some conflicts
3. **Days 8-12**: High pressure, frequent conflicts
4. **Days 13+**: Extreme pressure, every choice matters

### Player Archetypes

Different time strategies for different playstyles:

1. **The Completionist**: Tries to do everything, often exhausted
2. **The Optimizer**: Min-maxes time usage, follows guides
3. **The Role-player**: Makes time choices based on character
4. **The Speedrunner**: Rushes critical path, ignores side content

## Performance Considerations

### Update Frequency

- Clock updates: Only on actions (not per frame)
- UI updates: Maximum 1Hz for smooth display
- Deadline checks: Every hour of game time
- Fatigue calculation: Every 15 minutes of game time

### Memory Management

```gdscript
func cleanup_temporal_data():
    """Remove old temporal data to prevent memory bloat"""
    # Remove expired deadlines older than 3 days
    var cutoff_time = GameClock.current_time - (3 * 1440)
    
    for deadline in missed_deadlines:
        if deadline.due_time < cutoff_time:
            missed_deadlines.erase(deadline)
    
    # Compress event history
    EventScheduler.compress_old_events(cutoff_time)
    
    # Archive old branch decisions
    if active_branch_path.size() > 50:
        archive_old_branches()
```

## Integration with Full Systems

### Living World Integration

Time drives the world simulation:
- NPCs follow complex schedules with variations
- Events cascade based on temporal proximity
- Rumors spread at realistic rates

### Investigation Integration

Time affects evidence:
- Physical evidence degrades over time
- Witness memories become less reliable
- Some clues only available at certain times

### Coalition Integration

Building coalition requires time investment:
- Regular meetings to maintain cohesion
- Time spent recruiting vs. investigating
- Coalition members have their own time needs

## Success Metrics

1. Players report time choices feel meaningful and impactful
2. Multiple playthroughs reveal different content based on time allocation
3. Time pressure creates memorable moments of tension
4. Players develop personal time management strategies
5. The system supports both casual and hardcore playstyles
6. Performance remains stable with complex time calculations