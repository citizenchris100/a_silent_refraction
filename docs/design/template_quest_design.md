# Template Quest Design Document

## Overview

The Template Quest system provides reusable patterns for creating all quest types in A Silent Refraction. This Phase 2 system supports complex multi-part quests, branching narratives, and deep integration with the game's time management and suspicion mechanics. The template approach ensures consistent quest behavior while enabling diverse narrative experiences.

## Design Philosophy

- **Modular Structure**: Quests composed of reusable parts and objectives
- **State Persistence**: Full save/load support for complex quest states
- **Branching Support**: Multiple paths through quests based on player choices
- **Time Integration**: Quests advance time and respond to temporal events
- **Failure States**: Quests can fail, not just succeed
- **Dynamic Objectives**: Quest goals can change based on player actions

## Core Quest Architecture

### Quest Data Model

```gdscript
# QuestTemplate.gd
extends Resource

class_name QuestTemplate

# Quest identification
export var quest_id: String = "template_quest"
export var display_name: String = "Template Quest"
export var quest_type: String = "side"  # main, side, district, investigation

# Quest structure
export var parts: Array = []  # Array of QuestPart
export var current_part_index: int = 0
export var quest_state: String = "inactive"  # inactive, active, completed, failed

# Quest configuration
export var quest_config: Dictionary = {
    "progression_type": "linear",  # linear, branching, parallel
    "time_sensitive": false,
    "can_fail": true,
    "auto_track": false,
    "priority": 0
}

# Prerequisites and conditions
export var prerequisites: Dictionary = {
    "completed_quests": [],
    "has_items": [],
    "min_day": -1,
    "max_day": -1,
    "npc_states": {},  # {npc_id: required_state}
    "flags": []
}

# Rewards and consequences
export var rewards: Dictionary = {
    "credits": 0,
    "items": [],
    "unlock_quests": [],
    "set_flags": [],
    "relationship_changes": {},  # {npc_id: change_amount}
    "time_advance": 0
}

# Tracking data
var started_day: int = -1
var started_hour: int = -1
var completion_time: float = 0.0
var choices_made: Dictionary = {}
var objectives_completed: Array = []

# Signals
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, update_type: String)
signal quest_completed(quest_id: String, outcome: String)
signal quest_failed(quest_id: String, reason: String)
signal objective_completed(quest_id: String, objective_id: String)
```

### Quest Part Structure

```gdscript
# QuestPart.gd
extends Resource

class_name QuestPart

# Part identification
export var part_id: String = "part_1"
export var display_name: String = "Part One"
export var description: String = "Quest part description"

# Objectives
export var objectives: Array = []  # Array of QuestObjective
export var objective_mode: String = "all"  # all, any, sequential

# Part flow control
export var next_parts: Dictionary = {
    "default": "next_part_id",
    "success": "success_part_id",
    "failure": "failure_part_id",
    "branch_a": "branch_a_part_id",
    "branch_b": "branch_b_part_id"
}

# Part-specific configuration
export var time_limit: int = -1  # Hours, -1 = no limit
export var auto_fail_conditions: Array = []  # Conditions that fail this part

# Rewards for completing this part
export var part_rewards: Dictionary = {
    "credits": 0,
    "items": [],
    "flags": []
}

# Consequences for this part
export var part_consequences: Dictionary = {
    "npcs_affected": [],  # NPCs that might be assimilated
    "suspicion_increase": 0.0,
    "time_advance": 1  # Hours
}

var is_active: bool = false
var is_completed: bool = false
var started_at: float = 0.0
```

### Quest Objective System

```gdscript
# QuestObjective.gd
extends Resource

class_name QuestObjective

# Objective identification
export var objective_id: String = "objective_1"
export var display_text: String = "Complete the objective"
export var objective_type: String = "standard"  # standard, optional, hidden

# Objective requirements
export var requirements: Dictionary = {
    "type": "simple",  # simple, counter, collection, location, interaction
    "target": "",  # What needs to be done
    "count": 1,  # For counter type
    "items": [],  # For collection type
    "location": "",  # For location type
    "npc": "",  # For interaction type
}

# Objective state
var is_completed: bool = false
var is_revealed: bool = true  # Hidden objectives start as false
var progress: int = 0  # For counter objectives

# Tracking
var completion_method: String = ""  # How it was completed
var completion_time: float = 0.0

func check_completion(context: Dictionary) -> bool:
    match requirements.type:
        "simple":
            return context.get(requirements.target, false)
        
        "counter":
            return progress >= requirements.count
        
        "collection":
            for item in requirements.items:
                if not context.inventory.has(item):
                    return false
            return true
        
        "location":
            return context.current_location == requirements.location
        
        "interaction":
            return context.get("last_npc_talked") == requirements.npc
    
    return false

func update_progress(amount: int = 1):
    if requirements.type == "counter":
        progress = min(progress + amount, requirements.count)
        return progress >= requirements.count
    return false
```

## Quest Manager System

```gdscript
# QuestManager.gd
extends Node

class_name QuestManager

# Active quest tracking
var active_quests: Dictionary = {}  # {quest_id: QuestTemplate}
var completed_quests: Array = []
var failed_quests: Array = []

# Quest registry
var quest_registry: Dictionary = {}  # All available quest templates

# Current tracking
var tracked_quest: String = ""
var quest_log_open: bool = false

# Event connections
var _event_connections: Array = []

# Signals
signal quest_available(quest_id: String)
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, message: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String, reason: String)

func _ready():
    # Load all quest templates
    _load_quest_templates()
    
    # Connect to game events
    _connect_to_events()
    
    # Connect to time system
    TimeManager.connect("hour_changed", self, "_on_hour_changed")
    TimeManager.connect("day_changed", self, "_on_day_changed")

func start_quest(quest_id: String) -> bool:
    if not quest_registry.has(quest_id):
        push_error("Unknown quest: " + quest_id)
        return false
    
    if active_quests.has(quest_id):
        push_warning("Quest already active: " + quest_id)
        return false
    
    var quest_template = quest_registry[quest_id].duplicate(true)
    
    # Check prerequisites
    if not _check_prerequisites(quest_template):
        return false
    
    # Initialize quest
    quest_template.quest_state = "active"
    quest_template.started_day = TimeManager.current_day
    quest_template.started_hour = TimeManager.current_hour
    
    # Activate first part
    if quest_template.parts.size() > 0:
        quest_template.parts[0].is_active = true
    
    active_quests[quest_id] = quest_template
    
    # Connect quest signals
    quest_template.connect("quest_updated", self, "_on_quest_updated")
    quest_template.connect("objective_completed", self, "_on_objective_completed")
    
    emit_signal("quest_started", quest_id)
    
    # Auto-track if configured
    if quest_template.quest_config.auto_track:
        tracked_quest = quest_id
    
    return true

func update_quest_progress(quest_id: String, objective_id: String, context: Dictionary = {}):
    if not active_quests.has(quest_id):
        return
    
    var quest = active_quests[quest_id]
    var current_part = quest.parts[quest.current_part_index]
    
    # Find and update objective
    for objective in current_part.objectives:
        if objective.objective_id == objective_id:
            if objective.check_completion(context):
                _complete_objective(quest, current_part, objective)
                break

func _complete_objective(quest: QuestTemplate, part: QuestPart, objective: QuestObjective):
    objective.is_completed = true
    objective.completion_time = OS.get_ticks_msec() / 1000.0
    
    quest.objectives_completed.append(objective.objective_id)
    emit_signal("quest_updated", quest.quest_id, 
        "Objective completed: " + objective.display_text)
    
    # Check if part is complete
    if _is_part_complete(part):
        _complete_part(quest, part)

func _is_part_complete(part: QuestPart) -> bool:
    match part.objective_mode:
        "all":
            for obj in part.objectives:
                if obj.objective_type != "optional" and not obj.is_completed:
                    return false
            return true
        
        "any":
            for obj in part.objectives:
                if obj.is_completed:
                    return true
            return false
        
        "sequential":
            for obj in part.objectives:
                if not obj.is_completed:
                    return obj == part.objectives[0]  # Only first incomplete
            return true
    
    return false

func _complete_part(quest: QuestTemplate, part: QuestPart):
    part.is_completed = true
    
    # Apply part rewards
    _apply_rewards(part.part_rewards)
    
    # Apply consequences
    _apply_consequences(part.part_consequences)
    
    # Determine next part
    var next_part_key = _determine_next_part(quest, part)
    
    if next_part_key == "complete":
        _complete_quest(quest, "success")
    elif next_part_key == "failed":
        _fail_quest(quest, "Part failed")
    else:
        _advance_to_part(quest, next_part_key)

func _determine_next_part(quest: QuestTemplate, completed_part: QuestPart) -> String:
    # Check for branch conditions
    if quest.choices_made.has(completed_part.part_id):
        var choice = quest.choices_made[completed_part.part_id]
        if completed_part.next_parts.has(choice):
            return completed_part.next_parts[choice]
    
    # Check success/failure
    if completed_part.next_parts.has("success"):
        return completed_part.next_parts.success
    
    # Default progression
    return completed_part.next_parts.get("default", "complete")
```

## Quest Types and Templates

### Linear Quest Template

```gdscript
# LinearQuestTemplate.gd
extends QuestTemplate

func _init():
    quest_id = "linear_quest_template"
    display_name = "Linear Quest Example"
    quest_type = "side"
    
    quest_config = {
        "progression_type": "linear",
        "time_sensitive": false,
        "can_fail": false,
        "auto_track": true,
        "priority": 1
    }
    
    # Create linear parts
    var part1 = QuestPart.new()
    part1.part_id = "gather_info"
    part1.display_name = "Gather Information"
    part1.description = "Talk to NPCs to gather information"
    
    var obj1 = QuestObjective.new()
    obj1.objective_id = "talk_to_worker"
    obj1.display_text = "Talk to the dock worker"
    obj1.requirements = {
        "type": "interaction",
        "npc": "dock_worker_1"
    }
    part1.objectives.append(obj1)
    
    part1.next_parts = {"default": "investigate"}
    parts.append(part1)
    
    var part2 = QuestPart.new()
    part2.part_id = "investigate"
    part2.display_name = "Investigate the Cargo"
    part2.description = "Examine the suspicious cargo"
    
    var obj2 = QuestObjective.new()
    obj2.objective_id = "examine_crate"
    obj2.display_text = "Examine the marked crate"
    obj2.requirements = {
        "type": "simple",
        "target": "crate_examined"
    }
    part2.objectives.append(obj2)
    
    part2.next_parts = {"default": "complete"}
    parts.append(part2)
```

### Branching Quest Template

```gdscript
# BranchingQuestTemplate.gd
extends QuestTemplate

func _init():
    quest_id = "branching_quest_template"
    display_name = "The Choice"
    quest_type = "main"
    
    quest_config = {
        "progression_type": "branching",
        "time_sensitive": true,
        "can_fail": true,
        "auto_track": true,
        "priority": 3
    }
    
    # Part 1: Initial investigation
    var part1 = QuestPart.new()
    part1.part_id = "discover"
    part1.display_name = "Discovery"
    part1.objectives = [create_objective("find_evidence", "Find evidence of conspiracy")]
    part1.next_parts = {"default": "choice"}
    parts.append(part1)
    
    # Part 2: The choice
    var part2 = QuestPart.new()
    part2.part_id = "choice"
    part2.display_name = "The Decision"
    part2.objectives = [create_objective("make_choice", "Decide who to trust")]
    part2.next_parts = {
        "trust_security": "security_branch",
        "trust_resistance": "resistance_branch",
        "trust_nobody": "solo_branch"
    }
    parts.append(part2)
    
    # Branch A: Trust Security
    var branch_a = QuestPart.new()
    branch_a.part_id = "security_branch"
    branch_a.display_name = "Official Channels"
    branch_a.objectives = [
        create_objective("report_findings", "Report to Security Chief"),
        create_objective("assist_investigation", "Help with official investigation")
    ]
    branch_a.part_consequences = {
        "suspicion_increase": -0.3,  # Reduces suspicion
        "npcs_affected": ["resistance_members"],  # They get arrested
    }
    parts.append(branch_a)
    
    # Branch B: Trust Resistance
    var branch_b = QuestPart.new()
    branch_b.part_id = "resistance_branch"
    branch_b.display_name = "Underground Movement"
    branch_b.objectives = [
        create_objective("share_intel", "Share findings with resistance"),
        create_objective("sabotage_security", "Sabotage security systems")
    ]
    branch_b.part_consequences = {
        "suspicion_increase": 0.5,  # Increases suspicion
        "flags": ["joined_resistance"]
    }
    parts.append(branch_b)
```

### Investigation Quest Template

```gdscript
# InvestigationQuestTemplate.gd
extends QuestTemplate

func _init():
    quest_id = "investigation_template"
    display_name = "The Missing Scientist"
    quest_type = "investigation"
    
    # Non-linear investigation with multiple clue paths
    quest_config = {
        "progression_type": "parallel",  # Can pursue clues in any order
        "time_sensitive": true,
        "can_fail": true,
        "auto_track": false,
        "priority": 2
    }
    
    # Part 1: Gather Clues (parallel objectives)
    var investigate_part = QuestPart.new()
    investigate_part.part_id = "gather_clues"
    investigate_part.display_name = "Investigation"
    investigate_part.objective_mode = "any"  # Complete any 3 of 5 clues
    
    # Multiple investigation paths
    investigate_part.objectives = [
        create_investigation_objective("interview_colleagues", "Interview colleagues", "doc_worker_2"),
        create_investigation_objective("check_quarters", "Search scientist's quarters", "room_403"),
        create_investigation_objective("hack_terminal", "Access personnel records", "security_terminal"),
        create_investigation_objective("bribe_guard", "Bribe security for info", "security_guard_1"),
        create_investigation_objective("analyze_schedule", "Analyze work schedules", "schedule_board")
    ]
    
    # Different paths lead to different conclusions
    investigate_part.next_parts = {
        "found_3_clues": "confrontation",
        "found_all_clues": "perfect_solution",
        "time_expired": "trail_cold"
    }
    
    investigate_part.time_limit = 48  # 48 game hours
    parts.append(investigate_part)

func create_investigation_objective(id: String, text: String, target: String) -> QuestObjective:
    var obj = QuestObjective.new()
    obj.objective_id = id
    obj.display_text = text
    obj.objective_type = "standard"
    obj.requirements = {
        "type": "interaction",
        "target": target,
        "reveals_clue": true
    }
    return obj
```

### Time-Sensitive Quest Template

```gdscript
# TimeSensitiveQuestTemplate.gd
extends QuestTemplate

func _init():
    quest_id = "time_sensitive_template"
    display_name = "Race Against Time"
    quest_type = "district"
    
    quest_config = {
        "progression_type": "linear",
        "time_sensitive": true,
        "can_fail": true,
        "auto_track": true,
        "priority": 4
    }
    
    prerequisites = {
        "min_day": 3,  # Only available after day 3
        "max_day": 7,  # Must complete by day 7
        "flags": ["discovered_threat"]
    }
    
    # Part with strict time limit
    var urgent_part = QuestPart.new()
    urgent_part.part_id = "prevent_disaster"
    urgent_part.display_name = "Stop the Contamination"
    urgent_part.description = "Prevent the life support contamination"
    urgent_part.time_limit = 12  # 12 hours to complete
    
    urgent_part.auto_fail_conditions = [
        {"type": "time", "hours": 12},
        {"type": "npc_state", "npc": "engineer_03", "state": "assimilated"},
        {"type": "location_state", "location": "life_support", "state": "compromised"}
    ]
    
    parts.append(urgent_part)
```

## Quest UI Integration

```gdscript
# QuestLogUI.gd
extends Control

class_name QuestLogUI

onready var quest_list = $QuestList
onready var quest_details = $QuestDetails
onready var objective_list = $QuestDetails/Objectives

var current_quest: QuestTemplate

func _ready():
    QuestManager.connect("quest_updated", self, "_on_quest_updated")
    refresh_quest_list()

func refresh_quest_list():
    quest_list.clear()
    
    # Add active quests
    for quest_id in QuestManager.active_quests:
        var quest = QuestManager.active_quests[quest_id]
        var item = quest_list.add_item(quest.display_name)
        item.set_metadata(0, quest_id)
        
        # Visual indicators
        if quest_id == QuestManager.tracked_quest:
            item.set_custom_color(0, Color.yellow)
        
        if quest.quest_config.time_sensitive:
            item.set_suffix(0, " ⏰")

func display_quest_details(quest_id: String):
    var quest = QuestManager.active_quests.get(quest_id)
    if not quest:
        return
    
    current_quest = quest
    
    # Display quest info
    $QuestDetails/Title.text = quest.display_name
    $QuestDetails/Description.text = _get_current_description(quest)
    
    # Display objectives
    objective_list.clear()
    var current_part = quest.parts[quest.current_part_index]
    
    for obj in current_part.objectives:
        if obj.is_revealed:
            var obj_item = objective_list.add_item(obj.display_text)
            
            if obj.is_completed:
                obj_item.set_custom_color(0, Color.green)
                obj_item.set_prefix(0, "✓ ")
            else:
                obj_item.set_prefix(0, "○ ")
            
            if obj.objective_type == "optional":
                obj_item.set_suffix(0, " (Optional)")

func _get_current_description(quest: QuestTemplate) -> String:
    var desc = quest.parts[quest.current_part_index].description
    
    # Add time pressure info
    if quest.quest_config.time_sensitive:
        var time_left = _calculate_time_remaining(quest)
        desc += "\n\n[color=yellow]Time Remaining: %d hours[/color]" % time_left
    
    return desc
```

## Quest Event System

```gdscript
# QuestEventHandler.gd
extends Node

# Handles quest-triggering events throughout the game

func _ready():
    # Connect to various game systems
    get_tree().connect("node_added", self, "_on_node_added")
    
    # Dialog events
    DialogManager.connect("dialog_completed", self, "_on_dialog_completed")
    
    # Location events
    LocationManager.connect("location_entered", self, "_on_location_entered")
    
    # Item events
    InventoryManager.connect("item_acquired", self, "_on_item_acquired")
    InventoryManager.connect("item_used", self, "_on_item_used")
    
    # Time events
    TimeManager.connect("hour_changed", self, "_check_time_triggers")

func _on_dialog_completed(npc_id: String, dialog_node: String):
    # Check if this completes any objectives
    var context = {
        "last_npc_talked": npc_id,
        "dialog_node": dialog_node
    }
    
    for quest_id in QuestManager.active_quests:
        QuestManager.update_quest_progress(quest_id, "talk_to_" + npc_id, context)
    
    # Check if this triggers new quests
    _check_quest_triggers({
        "type": "dialog",
        "npc": npc_id,
        "node": dialog_node
    })

func _on_location_entered(location_id: String):
    var context = {
        "current_location": location_id
    }
    
    # Update location-based objectives
    for quest_id in QuestManager.active_quests:
        var quest = QuestManager.active_quests[quest_id]
        var current_part = quest.parts[quest.current_part_index]
        
        for obj in current_part.objectives:
            if obj.requirements.type == "location":
                QuestManager.update_quest_progress(quest_id, obj.objective_id, context)

func _check_quest_triggers(trigger_data: Dictionary):
    # Check all inactive quests for trigger conditions
    for quest_id in QuestManager.quest_registry:
        if not QuestManager.active_quests.has(quest_id):
            var quest_template = QuestManager.quest_registry[quest_id]
            
            if _matches_trigger(quest_template, trigger_data):
                QuestManager.start_quest(quest_id)
```

## Save System Integration

```gdscript
# QuestSerializer.gd
extends BaseSerializer

class_name QuestSerializer

func serialize() -> Dictionary:
    var data = {
        "active_quests": {},
        "completed_quests": QuestManager.completed_quests.duplicate(),
        "failed_quests": QuestManager.failed_quests.duplicate(),
        "tracked_quest": QuestManager.tracked_quest
    }
    
    # Serialize active quests
    for quest_id in QuestManager.active_quests:
        var quest = QuestManager.active_quests[quest_id]
        data.active_quests[quest_id] = _serialize_quest(quest)
    
    return data

func _serialize_quest(quest: QuestTemplate) -> Dictionary:
    return {
        "current_part_index": quest.current_part_index,
        "quest_state": quest.quest_state,
        "started_day": quest.started_day,
        "started_hour": quest.started_hour,
        "choices_made": quest.choices_made,
        "objectives_completed": quest.objectives_completed,
        "parts_state": _serialize_parts(quest.parts)
    }

func _serialize_parts(parts: Array) -> Array:
    var parts_data = []
    
    for part in parts:
        parts_data.append({
            "is_active": part.is_active,
            "is_completed": part.is_completed,
            "objectives_state": _serialize_objectives(part.objectives)
        })
    
    return parts_data

func deserialize(data: Dictionary) -> void:
    QuestManager.completed_quests = data.get("completed_quests", [])
    QuestManager.failed_quests = data.get("failed_quests", [])
    QuestManager.tracked_quest = data.get("tracked_quest", "")
    
    # Restore active quests
    for quest_id in data.get("active_quests", {}):
        if QuestManager.quest_registry.has(quest_id):
            _restore_quest(quest_id, data.active_quests[quest_id])
```

## Testing Framework

```gdscript
# QuestTestFramework.gd
extends "res://addons/gut/test.gd"

var test_quest: QuestTemplate
var quest_manager: QuestManager

func before_each():
    quest_manager = QuestManager.new()
    test_quest = preload("res://src/quests/templates/test_quest.gd").new()

func test_linear_progression():
    # Start quest
    assert_true(quest_manager.start_quest("test_linear_quest"))
    
    # Complete first objective
    quest_manager.update_quest_progress("test_linear_quest", "objective_1", 
        {"test_complete": true})
    
    # Verify progression
    var quest = quest_manager.active_quests["test_linear_quest"]
    assert_eq(quest.current_part_index, 1)

func test_branching_quest():
    # Start branching quest
    quest_manager.start_quest("test_branching_quest")
    
    # Make a choice
    var quest = quest_manager.active_quests["test_branching_quest"]
    quest.choices_made["choice_point"] = "path_a"
    
    # Complete choice objective
    quest_manager.update_quest_progress("test_branching_quest", "make_choice", {})
    
    # Verify correct branch
    assert_eq(quest.parts[quest.current_part_index].part_id, "path_a_part")

func test_time_sensitive_failure():
    # Start time-sensitive quest
    quest_manager.start_quest("test_timed_quest")
    
    # Advance time beyond limit
    TimeManager.advance_time(25)  # 25 hours
    
    # Verify quest failed
    assert_false(quest_manager.active_quests.has("test_timed_quest"))
    assert_true(quest_manager.failed_quests.has("test_timed_quest"))

func test_parallel_objectives():
    # Start quest with parallel objectives
    quest_manager.start_quest("test_parallel_quest")
    
    var quest = quest_manager.active_quests["test_parallel_quest"]
    var part = quest.parts[0]
    
    # Complete objectives in any order
    quest_manager.update_quest_progress("test_parallel_quest", "objective_3", {})
    quest_manager.update_quest_progress("test_parallel_quest", "objective_1", {})
    
    # Should not complete until enough objectives done
    assert_false(part.is_completed)
    
    quest_manager.update_quest_progress("test_parallel_quest", "objective_2", {})
    
    # Now should be complete (3 of 5 required)
    assert_true(part.is_completed)
```

## Performance Considerations

- **Quest Updates**: Only process active quest objectives
- **Event Filtering**: Pre-filter events by quest requirements
- **UI Updates**: Batch UI updates, refresh on demand
- **Save Data**: Compress quest state for smaller saves
- **Memory Management**: Unload completed quest data after delay

## Integration Points

- **NPCSystem**: Quests affect NPC states and dialog
- **DialogSystem**: Dialog choices influence quest progression
- **InventorySystem**: Item requirements and rewards
- **TimeManager**: Time-sensitive quests and deadlines
- **LocationManager**: Location-based objectives
- **SaveManager**: Full quest state persistence
- **EventSystem**: Quest triggers and consequences
- **SuspicionSystem**: Quest actions affect suspicion

## Content Guidelines

### Quest Writing Best Practices

1. **Clear Objectives**: Players should understand what to do
2. **Multiple Solutions**: Allow different approaches when possible
3. **Meaningful Choices**: Branches should have real consequences
4. **Time Pressure**: Use sparingly for dramatic effect
5. **Failure States**: Make failure interesting, not frustrating

### Quest Balance

- **Main Quests**: 8-12 objectives across 3-5 parts
- **Side Quests**: 3-6 objectives across 1-3 parts
- **Investigation**: Multiple parallel paths to solution
- **Time Limits**: Minimum 6 hours for critical quests

## Future Enhancements

- **Dynamic Quest Generation**: Procedural quest creation
- **Quest Chains**: Multi-quest story arcs
- **Faction Quests**: Mutually exclusive quest lines
- **Daily Quests**: Repeatable time-based objectives
- **Achievement Integration**: Special rewards for quest mastery