# Multiple Endings System Design

## Overview

The Multiple Endings System implements two distinct narrative conclusions based on the assimilation ratio by a critical date. Players either successfully contain the assimilation and fight to keep control of the station, or fail to stem the tide and must escape. Both paths lead to unique final quests that test everything the player has learned, culminating in text-only endings that reflect their journey.

## Core Concepts

### Ending Philosophy
- **Binary outcome**: Control the station or escape it
- **Ratio-driven**: Assimilation percentage on critical date determines path
- **Final challenge**: Each path has a unique concluding quest
- **Text epilogue**: Simple text endings, no cinematics
- **Permanent consequences**: No reloading to try other ending

### Critical Decision Point
- **Evaluation date**: Configurable "Day X" when ratio is checked
- **Clear threshold**: Specific assimilation percentage triggers each path
- **No middle ground**: Must commit to one ending or the other
- **Time pressure**: Daily assimilation continues during final quest

## System Architecture

### Core Components

#### 1. Ending Manager (Singleton)
```gdscript
# src/core/systems/ending_manager.gd
extends Node

signal ending_triggered(ending_type)
signal final_quest_started(quest_id)
signal ending_achieved(ending_data)

# Configuration
export var critical_evaluation_day: int = 30  # Day when ratio is checked
export var control_threshold: float = 0.65    # % unassimilated needed for control
export var escape_threshold: float = 0.35     # % unassimilated triggers escape

# State tracking
var ending_path: String = ""  # "control" or "escape"
var final_quest_active: bool = false
var ending_data: Dictionary = {}

func _ready():
    TimeManager.connect("day_changed", self, "_check_ending_trigger")

func _check_ending_trigger(current_day: int):
    if current_day != critical_evaluation_day:
        return
    
    if ending_path != "":  # Already determined
        return
    
    # Calculate current ratio
    var ratio_data = AssimilationManager.get_station_ratio()
    var unassimilated_percentage = ratio_data.unassimilated_percentage
    
    # Store data for ending
    ending_data = {
        "evaluation_day": current_day,
        "total_npcs": ratio_data.total_npcs,
        "assimilated": ratio_data.assimilated_count,
        "unassimilated": ratio_data.unassimilated_count,
        "coalition_size": CoalitionManager.members.size(),
        "leaders_identified": AssimilationManager.identified_leaders.size(),
        "districts_secured": DistrictManager.get_secured_districts().size()
    }
    
    # Determine ending path
    if unassimilated_percentage >= control_threshold:
        _trigger_control_path()
    else:
        _trigger_escape_path()

func _trigger_control_path():
    ending_path = "control"
    emit_signal("ending_triggered", "control")
    
    # Start control ending quest
    var quest = QuestManager.create_quest({
        "id": "final_control_station",
        "name": "Save the Station", 
        "description": "The coalition controls the station, but Aether Corp wants to buy it out from under you. Stop the sale and secure your future.",
        "objectives": [
            "Gather evidence of Aether Corp's involvement",
            "Rally coalition for legal battle",
            "Infiltrate corporate meeting",
            "Sabotage the sale documents",
            "Expose the conspiracy publicly"
        ],
        "time_limit": 7  # 7 days to complete
    })
    
    final_quest_active = true
    emit_signal("final_quest_started", "final_control_station")
    
    # Continue assimilation during quest
    AssimilationManager.set_spread_rate(0.5)  # Slower but still spreading

func _trigger_escape_path():
    ending_path = "escape"
    emit_signal("ending_triggered", "escape")
    
    # Start escape ending quest  
    var quest = QuestManager.create_quest({
        "id": "final_escape_station",
        "name": "Abandon Ship",
        "description": "The assimilation has won. Gather survivors and escape before it's too late.",
        "objectives": [
            "Identify remaining unassimilated",
            "Secure transportation",
            "Gather essential supplies",
            "Create distraction for assimilated",
            "Reach the escape vessel"
        ],
        "time_limit": 3  # Only 3 days to escape
    })
    
    final_quest_active = true
    emit_signal("final_quest_started", "final_escape_station")
    
    # Accelerate assimilation during escape
    AssimilationManager.set_spread_rate(2.0)  # Double speed

func complete_ending(success: bool):
    if not final_quest_active:
        return
    
    final_quest_active = false
    
    # Generate appropriate ending text
    var ending_text = _generate_ending_text(ending_path, success)
    
    # Calculate final statistics
    var final_stats = _calculate_final_statistics()
    
    ending_data["success"] = success
    ending_data["final_stats"] = final_stats
    ending_data["ending_text"] = ending_text
    
    emit_signal("ending_achieved", ending_data)
    
    # Show ending
    EndingDisplay.show_ending(ending_data)
```

#### 2. Control Path Quest System
```gdscript
# src/quests/final_quests/control_station_quest.gd
extends Quest

class_name ControlStationQuest

var evidence_gathered: Array = []
var coalition_support: float = 0.0
var sale_sabotaged: bool = false

func _init():
    quest_id = "final_control_station"
    time_limit_days = 7
    
    objectives = [
        {
            "id": "gather_evidence",
            "description": "Find proof of Aether Corp's conspiracy",
            "required_items": ["aether_contract", "assimilation_data", "financial_records"],
            "locations": ["corporate_offices", "bank_vault", "security_archives"]
        },
        {
            "id": "rally_coalition",
            "description": "Get 80% coalition support for legal action",
            "required_support": 0.8,
            "actions": ["speech", "individual_convincing", "promise_positions"]
        },
        {
            "id": "infiltrate_meeting",
            "description": "Get into the corporate buyout meeting",
            "solutions": [
                {"method": "disguise", "item": "executive_suit"},
                {"method": "hack", "target": "meeting_roster"},
                {"method": "coalition_distraction", "members_needed": 10}
            ]
        },
        {
            "id": "sabotage_sale",
            "description": "Prevent the sale from completing",
            "approaches": [
                {"method": "legal", "requirement": "lawyer_coalition_member"},
                {"method": "technical", "requirement": "hack_financial_systems"},
                {"method": "social", "requirement": "blackmail_executive"}
            ]
        },
        {
            "id": "expose_conspiracy",
            "description": "Make the truth public",
            "channels": ["station_broadcast", "emergency_beacon", "media_leak"],
            "impact": "permanent_record"
        }
    ]

func check_objective_completion(objective_id: String) -> bool:
    match objective_id:
        "gather_evidence":
            return evidence_gathered.size() >= 3
        "rally_coalition":
            return coalition_support >= 0.8
        "infiltrate_meeting":
            return PlayerState.in_meeting_room
        "sabotage_sale":
            return sale_sabotaged
        "expose_conspiracy":
            return BroadcastSystem.conspiracy_exposed
    
    return false

func handle_failure_state():
    # If time runs out or objectives fail
    if TimeManager.current_day > start_day + time_limit_days:
        # Station is sold, but some escape
        EndingManager.complete_ending(false)
    elif CoalitionManager.members.size() < 5:
        # Not enough support to fight
        EndingManager.complete_ending(false)
```

#### 3. Escape Path Quest System
```gdscript
# src/quests/final_quests/escape_station_quest.gd
extends Quest

class_name EscapeStationQuest

var survivors_gathered: Array = []
var transport_secured: bool = false
var supplies_collected: Dictionary = {}
var distraction_active: bool = false

func _init():
    quest_id = "final_escape_station"
    time_limit_days = 3
    
    objectives = [
        {
            "id": "gather_survivors",
            "description": "Find and verify unassimilated survivors",
            "min_survivors": 5,
            "max_survivors": 20,  # Based on how well player did
            "verification_needed": true  # Can't trust everyone
        },
        {
            "id": "secure_transport",
            "description": "Get access to an escape vessel",
            "options": [
                {"vessel": "cargo_shuttle", "capacity": 10, "difficulty": "medium"},
                {"vessel": "emergency_pod", "capacity": 5, "difficulty": "easy"},
                {"vessel": "hijacked_transport", "capacity": 20, "difficulty": "hard"}
            ]
        },
        {
            "id": "gather_supplies",
            "description": "Collect essentials for journey",
            "required": ["food_supplies", "water_supplies", "medical_kit"],
            "optional": ["navigation_data", "fuel_reserves", "weapons"]
        },
        {
            "id": "create_distraction",
            "description": "Divert assimilated attention",
            "methods": [
                {"type": "explosion", "location": "opposite_district"},
                {"type": "false_trail", "requirement": "hacking_skills"},
                {"type": "sacrifice", "volunteer": "coalition_member"}
            ]
        },
        {
            "id": "reach_vessel",
            "description": "Get all survivors to the escape vessel",
            "challenges": ["avoid_patrols", "locked_passages", "final_confrontation"]
        }
    ]

func update_assimilation_pressure():
    # During escape, assimilation accelerates
    for survivor in survivors_gathered:
        if randf() < 0.1 * (TimeManager.current_day - quest_start_day):
            # Survivor revealed as assimilated!
            _handle_infiltrator(survivor)
            survivors_gathered.erase(survivor)

func _handle_infiltrator(npc_id: String):
    # Dramatic reveal during escape
    UI.show_urgent_message("%s was assimilated all along!" % NPCRegistry.get_npc(npc_id).name)
    
    # May compromise escape route
    if randf() < 0.3:
        distraction_active = false
        UI.show_urgent_message("The assimilated know our plan!")
```

### Data Structures

#### Ending Configuration
```gdscript
# src/resources/ending_config.gd
extends Resource

class_name EndingConfig

# Timing
export var critical_evaluation_day: int = 30
export var warning_days_before: int = 5  # Warn player evaluation is coming

# Thresholds  
export var control_threshold: float = 0.65  # 65% unassimilated for control
export var escape_threshold: float = 0.35   # Below 35% must escape

# Difficulty modifiers
export var assimilation_rate_modifier: float = 1.0
export var coalition_effectiveness: float = 1.0

# Final quest parameters
export var control_quest_days: int = 7
export var escape_quest_days: int = 3
export var min_survivors_for_escape: int = 5
export var max_survivors_possible: int = 25
```

### Integration Systems

#### Assimilation System Integration
```gdscript
# Extension to AssimilationManager for ending support
func get_station_ratio() -> Dictionary:
    var total = NPCRegistry.get_all_npcs().size()
    var assimilated = assimilated_npcs.size()
    var unassimilated = total - assimilated
    
    return {
        "total_npcs": total,
        "assimilated_count": assimilated,
        "unassimilated_count": unassimilated,
        "assimilated_percentage": float(assimilated) / float(total),
        "unassimilated_percentage": float(unassimilated) / float(total),
        "leaders_count": leader_npcs.size(),
        "drones_count": drone_npcs.size()
    }

func get_ending_factors() -> Dictionary:
    # Factors that affect ending difficulty
    return {
        "spread_rate": current_spread_rate,
        "leader_influence": leader_npcs.size() * 2.0,
        "drone_chaos": drone_npcs.size() * 1.0,
        "economic_damage": get_economic_corruption_factor(),
        "coalition_resistance": CoalitionManager.get_resistance_factor()
    }

# Accelerated spread during escape
func set_ending_spread_rate(multiplier: float):
    current_spread_rate *= multiplier
    
    # More aggressive assimilation
    for npc_id in get_vulnerable_npcs():
        if randf() < 0.2 * multiplier:  # Higher chance
            assimilate_npc(npc_id, "panic_spread")
```

#### Coalition System Integration
```gdscript
# Coalition support during endings
func get_ending_support() -> Dictionary:
    var support = {
        "member_count": members.size(),
        "trust_average": _calculate_average_trust(),
        "resources": shared_credits + (shared_items.size() * 100),
        "safe_havens": safe_houses.size(),
        "combat_ready": _count_combat_capable()
    }
    
    # Control path benefits
    if EndingManager.ending_path == "control":
        support["legal_expertise"] = _count_members_with_skill("legal")
        support["political_influence"] = _count_members_with_skill("politics")
        support["media_access"] = _count_members_with_skill("journalism")
    
    # Escape path benefits  
    elif EndingManager.ending_path == "escape":
        support["pilots"] = _count_members_with_skill("piloting")
        support["survival_experts"] = _count_members_with_skill("survival")
        support["distraction_volunteers"] = _count_willing_sacrifices()
    
    return support
```

#### Time Management Integration
```gdscript
# Countdown to evaluation
func get_days_until_evaluation() -> int:
    return EndingManager.critical_evaluation_day - current_day

func show_evaluation_warnings():
    var days_left = get_days_until_evaluation()
    
    if days_left == 5:
        UI.show_important_message("5 days until critical evaluation. The station's fate will be decided.")
    elif days_left == 3:
        UI.show_urgent_message("3 days! Current ratio: %d%% unassimilated" % (AssimilationManager.get_station_ratio().unassimilated_percentage * 100))
    elif days_left == 1:
        UI.show_critical_message("TOMORROW the station's fate is sealed! Prepare for the consequences.")
    elif days_left == 0:
        UI.show_critical_message("TODAY IS THE DAY. The die is cast.")
```

## MVP Implementation

### Basic Features

1. **Simple Ratio Check**
   - Day 30 evaluation
   - 65% unassimilated = control path
   - Below 35% = escape path
   - Clear UI warnings

2. **Basic Final Quests**
   - Control: Stop the sale (3 objectives)
   - Escape: Get to ship (3 objectives)
   - Time limits enforced

3. **Text Endings**
   - Success/failure variants
   - Basic statistics shown
   - Simple epilogue text

### MVP Ending Examples

```gdscript
# Control Success
"The station remains under coalition control. Aether Corp's conspiracy has been exposed, 
and their attempt to purchase the station has failed. The assimilation threat remains 
contained at {assimilation_percent}%. You saved {survivor_count} souls. 
The station's future remains uncertain, but it remains in human hands."

# Control Failure  
"Despite your efforts, Aether Corp completes the purchase. The new corporate owners 
care nothing for the assimilation threat. Within weeks, the station falls completely 
under alien control. You tried to save {survivor_count} souls, but in the end, 
the station was lost to greed and horror."

# Escape Success
"Your ragtag group of {survivor_count} survivors reaches the escape vessel. As you 
flee the station, you watch it recede into darkness, knowing {assimilated_count} 
souls remain trapped within. The authorities must be warned. Perhaps others can 
succeed where you failed."

# Escape Failure
"The escape attempt fails. One by one, your group of survivors falls to the 
assimilated. In the end, you join them in the collective consciousness. The last 
human thoughts fade from the station. Aether Corp's experiment is complete."
```

## Full Implementation

### Advanced Features

#### 1. Dynamic Evaluation Date
```gdscript
# Adjust evaluation based on player performance
func calculate_dynamic_evaluation_day() -> int:
    var base_day = 30
    var modifiers = 0
    
    # Good performance delays evaluation
    if CoalitionManager.members.size() > 15:
        modifiers += 3  # 3 extra days
    
    # Identifying leaders buys time
    modifiers += AssimilationManager.identified_leaders.size()
    
    # High global suspicion accelerates it
    if SuspicionManager.global_suspicion_level > 0.7:
        modifiers -= 5  # 5 fewer days
    
    # Completing major quests affects timing
    if QuestManager.is_complete("secure_medical_district"):
        modifiers += 2
    
    return clamp(base_day + modifiers, 20, 40)
```

#### 2. Multiple Evaluation Points
```gdscript
# Not just one check, but trending
var evaluation_points = [
    {"day": 20, "weight": 0.2},
    {"day": 25, "weight": 0.3},
    {"day": 30, "weight": 0.5}
]

func calculate_trending_ratio() -> float:
    var weighted_ratio = 0.0
    
    for point in evaluation_points:
        var historical_ratio = get_historical_ratio(point.day)
        weighted_ratio += historical_ratio * point.weight
    
    return weighted_ratio
```

#### 3. Faction-Specific Endings
```gdscript
# Different text based on coalition composition
func generate_contextual_ending(base_ending: String) -> String:
    var context = []
    
    # Military coalition
    if _coalition_dominated_by("military"):
        context.append("The military coalition maintains strict order.")
    
    # Civilian coalition
    elif _coalition_dominated_by("civilian"):
        context.append("The civilian government struggles but persists.")
    
    # Criminal coalition
    elif _coalition_dominated_by("criminal"):
        context.append("The underworld now rules the station's remains.")
    
    # Mixed coalition
    else:
        context.append("An unlikely alliance of survivors bands together.")
    
    return base_ending + "\n\n" + context.join(" ")
```

#### 4. Partial Success States
```gdscript
# Not binary success/failure
func calculate_ending_success_degree() -> float:
    var success_factors = []
    
    if ending_path == "control":
        success_factors.append(objectives_completed / total_objectives)
        success_factors.append(coalition_survival_rate)
        success_factors.append(1.0 - economic_damage)
        success_factors.append(evidence_gathered / total_evidence)
    else:  # escape
        success_factors.append(survivors_escaped / survivors_attempted)
        success_factors.append(supplies_gathered / supplies_needed)
        success_factors.append(1.0 - casualties_during_escape)
        success_factors.append(distraction_effectiveness)
    
    return average(success_factors)
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/ending_serializer.gd
extends BaseSerializer

class_name EndingSerializer

func _ready():
    # Self-register with high priority (critical story state)
    SaveManager.register_serializer("ending", self, 25)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "ending_path": EndingManager.ending_path,
        "evaluation_day": EndingManager.critical_evaluation_day,
        "final_quest_active": EndingManager.final_quest_active,
        "ending_data": EndingManager.ending_data,
        "historical_ratios": _serialize_historical_ratios(),
        "quest_progress": _serialize_final_quest_progress()
    }

func deserialize(data: Dictionary) -> void:
    EndingManager.ending_path = data.get("ending_path", "")
    EndingManager.critical_evaluation_day = data.get("evaluation_day", 30)
    EndingManager.final_quest_active = data.get("final_quest_active", false)
    EndingManager.ending_data = data.get("ending_data", {})
    
    _deserialize_historical_ratios(data.get("historical_ratios", {}))
    _deserialize_final_quest_progress(data.get("quest_progress", {}))
    
    # Resume final quest if active
    if EndingManager.final_quest_active:
        var quest_id = "final_" + EndingManager.ending_path + "_station"
        QuestManager.resume_quest(quest_id)
```

## UI Components

### Ratio Tracker
```gdscript
# src/ui/ending/ratio_tracker_ui.gd
extends Control

onready var ratio_bar = $RatioBar
onready var days_label = $DaysUntilEvaluation
onready var threshold_markers = $ThresholdMarkers

func _ready():
    # Show thresholds
    _add_threshold_marker(EndingManager.control_threshold, Color.green, "Control")
    _add_threshold_marker(EndingManager.escape_threshold, Color.red, "Escape")

func _process(delta):
    if not EndingManager.ending_path:  # Not yet determined
        var ratio = AssimilationManager.get_station_ratio()
        ratio_bar.value = ratio.unassimilated_percentage
        
        var days_left = EndingManager.critical_evaluation_day - TimeManager.current_day
        days_label.text = "Evaluation in %d days" % days_left
        
        # Color code based on current trajectory
        if ratio.unassimilated_percentage >= EndingManager.control_threshold:
            ratio_bar.modulate = Color.green
        elif ratio.unassimilated_percentage < EndingManager.escape_threshold:
            ratio_bar.modulate = Color.red
        else:
            ratio_bar.modulate = Color.yellow
```

### Ending Display
```gdscript
# src/ui/ending/ending_display.gd
extends Control

onready var ending_text = $EndingText
onready var statistics = $Statistics
onready var continue_button = $ContinueButton

func show_ending(ending_data: Dictionary):
    # Simple text display
    ending_text.text = ending_data.ending_text
    
    # Show key statistics
    statistics.text = _format_statistics(ending_data.final_stats)
    
    # No cinematics, just text
    show()
    
    yield(continue_button, "pressed")
    
    # Return to main menu
    get_tree().change_scene("res://src/ui/main_menu.tscn")

func _format_statistics(stats: Dictionary) -> String:
    var lines = [
        "=== FINAL STATISTICS ===",
        "Days Survived: %d" % stats.days_survived,
        "Coalition Size: %d" % stats.coalition_size,
        "NPCs Saved: %d/%d" % [stats.unassimilated, stats.total_npcs],
        "Leaders Exposed: %d" % stats.leaders_identified,
        "Districts Secured: %d/7" % stats.districts_secured,
        "Credits Earned: %d" % stats.total_credits,
        "Puzzles Solved: %d" % stats.puzzles_solved
    ]
    
    return lines.join("\n")
```

## Balance Considerations

### Evaluation Timing
- **Day 30**: Default evaluation gives enough time to build coalition
- **Warning period**: 5 days of increasingly urgent warnings
- **Dynamic adjustment**: ±10 days based on performance
- **No surprise**: Player always knows evaluation is coming

### Ratio Thresholds
- **65% Control**: Achievable with good play, not guaranteed
- **35% Escape**: Generous enough that total failure is rare
- **30% Buffer**: Between thresholds creates tension
- **Daily pressure**: ~2-3% assimilation per day baseline

### Final Quest Difficulty
- **Control path**: 7 days, complex objectives, political/legal focus
- **Escape path**: 3 days, urgent objectives, survival focus
- **Continuing threat**: Assimilation doesn't stop during final quest
- **Resource management**: Previous choices affect available options

## Testing Considerations

1. **Ratio Calculation**
   - Verify accurate NPC counting
   - Test threshold detection
   - Confirm evaluation triggers properly
   - Test dynamic evaluation adjustments

2. **Final Quests**
   - Both quests completable
   - Time limits enforced
   - Objectives track properly
   - Failure states work

3. **Ending Generation**
   - All ending variants accessible
   - Statistics calculate correctly
   - Text generates without errors
   - Save system handles ending state

4. **Integration Testing**
   - Assimilation continues during final quest
   - Coalition resources affect options
   - Time advances properly
   - All systems remain functional

## Template Compliance

### Quest Template Integration
Ending sequences follow `template_quest_design.md`:
- Each ending path is a complete quest with objectives
- Uses multi-part quest structure for complex endings
- Time-sensitive objectives create urgency
- Branching paths based on player choices
- Quest completion triggers ending cinematics

The ending quests leverage:
- Dynamic objectives based on game state
- Failure conditions that lead to bad endings
- Optional objectives that enhance ending quality
- Quest serialization for save/load during endings

This system creates meaningful endings based on player performance throughout the game, with the assimilation ratio driving a clear fork between fighting for control or accepting defeat and escaping.