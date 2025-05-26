# Disguise/Clothing System Design

## Overview

The Disguise/Clothing System transforms identity into a gameplay mechanic where wearing specific uniforms grants access but also imposes role obligations. Like the First Quest demonstrates, putting on a security uniform doesn't just let you walk past guards - it means you must patrol, respond to crimes, and fulfill the duties of that role. This creates infiltration quests where maintaining cover is as important as gaining access.

## Core Concepts

### Disguise Philosophy
- **Role obligation**: Wearing a uniform means doing the job
- **Double-edged sword**: Access comes with responsibilities  
- **Performance requirements**: Must act the part convincingly
- **Consequences for failure**: Breaking character raises suspicion
- **Identity layers**: Clothes define how world perceives you

### Role Types
1. **Security** - Law enforcement duties
2. **Medical** - Healthcare responsibilities  
3. **Maintenance** - Technical access and tasks
4. **Corporate** - Business and administrative roles
5. **Service** - Customer-facing positions
6. **Civilian** - Default non-role status

## System Architecture

### Core Components

#### 1. Disguise Manager (Singleton)
```gdscript
# src/core/systems/disguise_manager.gd
extends Node

signal disguise_equipped(disguise_type)
signal disguise_removed()
signal role_obligation_triggered(obligation)
signal performance_evaluated(success, reason)
signal cover_blown(reason)

# Current disguise state
var current_disguise: String = "civilian"
var role_data: RoleData = null
var performance_score: float = 1.0  # How well maintaining cover
var time_in_role: float = 0.0

# Role expectations
var pending_obligations: Array = []
var completed_tasks: Array = []
var failed_tasks: Array = []

func equip_disguise(disguise_item: ItemData) -> bool:
    if not disguise_item.is_disguise:
        return false
    
    # Remove current disguise
    if current_disguise != "civilian":
        remove_disguise()
    
    # Apply new disguise
    current_disguise = disguise_item.disguise_type
    role_data = RoleRegistry.get_role_data(current_disguise)
    
    # Change player appearance
    PlayerAppearance.set_outfit(disguise_item.appearance_data)
    
    # Update NPC perceptions
    NPCPerception.player_role = current_disguise
    
    # Start role obligations
    _initialize_role_obligations()
    
    emit_signal("disguise_equipped", current_disguise)
    
    # Tutorial for new roles
    if not GameState.has_worn_role(current_disguise):
        _show_role_tutorial()
    
    return true

func _initialize_role_obligations():
    if not role_data:
        return
    
    # Immediate obligations (like reporting for duty)
    for obligation in role_data.immediate_obligations:
        pending_obligations.append(obligation)
        
        # Set timers for time-sensitive tasks
        if obligation.time_limit > 0:
            TimeManager.schedule_event(
                TimeManager.current_time + obligation.time_limit,
                self,
                "_on_obligation_timeout",
                obligation.id
            )
    
    # Recurring obligations (like patrol routes)
    for obligation in role_data.recurring_obligations:
        _schedule_recurring_obligation(obligation)

func check_role_performance(action: String, context: Dictionary) -> bool:
    if current_disguise == "civilian":
        return true  # No obligations
    
    # Check if action fits role
    var appropriate = _is_action_appropriate(action, context)
    
    if not appropriate:
        performance_score *= 0.9  # Degrade performance
        
        # NPCs might notice
        var witnesses = NPCManager.get_npcs_in_radius(player.position, 500)
        for npc in witnesses:
            if randf() < 0.3:  # 30% chance to notice
                npc.react_to_suspicious_behavior(current_disguise, action)
    
    # Check if fulfilling obligations
    for obligation in pending_obligations:
        if obligation.matches_action(action, context):
            _complete_obligation(obligation)
            return true
    
    return appropriate

func _is_action_appropriate(action: String, context: Dictionary) -> bool:
    # Check role-specific behaviors
    match current_disguise:
        "security":
            return _check_security_behavior(action, context)
        "medical":
            return _check_medical_behavior(action, context)
        "maintenance":
            return _check_maintenance_behavior(action, context)
        "corporate":
            return _check_corporate_behavior(action, context)
        _:
            return true

func _check_security_behavior(action: String, context: Dictionary) -> bool:
    var appropriate_actions = [
        "patrol", "check_id", "respond_to_crime", "write_report",
        "escort_visitor", "monitor_camera", "check_doors"
    ]
    
    var inappropriate_actions = [
        "steal", "vandalize", "access_restricted_without_cause",
        "ignore_crime", "abandon_post", "socialize_on_duty"
    ]
    
    if action in inappropriate_actions:
        return false
    
    # Context matters
    if action == "enter_store" and not context.get("pursuing_suspect", false):
        return true  # Can enter stores normally
    
    if action == "leave_district" and pending_obligations.size() > 0:
        UI.show_notification("Cannot leave - you have duties to complete")
        return false
    
    return true

func respond_to_role_event(event: RoleEvent):
    if current_disguise == "civilian":
        return
    
    # Check if this event requires response from current role
    if event.responding_roles.has(current_disguise):
        var obligation = RoleObligation.new()
        obligation.id = "respond_" + event.id
        obligation.description = event.get_description_for_role(current_disguise)
        obligation.location = event.location
        obligation.time_limit = event.response_time
        obligation.priority = event.priority
        
        pending_obligations.append(obligation)
        
        # High priority interrupts current task
        if event.priority == "urgent":
            UI.show_urgent_message(obligation.description)
            _show_obligation_marker(event.location)
```

#### 2. Role Obligation System
```gdscript
# src/core/systems/role_obligation_system.gd
extends Node

class_name RoleObligation

var id: String = ""
var description: String = ""
var location: String = ""  # Where to perform
var time_limit: float = 0.0  # Hours to complete
var priority: String = "normal"  # normal, high, urgent
var repeating: bool = false
var repeat_interval: float = 0.0

# Completion conditions
var required_actions: Array = []  # Actions that fulfill obligation
var required_location: String = ""
var required_duration: float = 0.0  # Time spent doing task
var special_conditions: Dictionary = {}

func matches_action(action: String, context: Dictionary) -> bool:
    # Check if action fulfills obligation
    if not action in required_actions:
        return false
    
    # Check location requirement
    if required_location != "" and context.get("location", "") != required_location:
        return false
    
    # Check special conditions
    for condition in special_conditions:
        if not _check_condition(condition, context):
            return false
    
    return true

# Example obligations by role
class SecurityObligations:
    static func get_patrol_obligation() -> RoleObligation:
        var ob = RoleObligation.new()
        ob.id = "security_patrol"
        ob.description = "Patrol assigned area"
        ob.required_actions = ["patrol", "walk_route"]
        ob.required_duration = 1.0  # 1 hour
        ob.repeating = true
        ob.repeat_interval = 4.0  # Every 4 hours
        return ob
    
    static func get_crime_response() -> RoleObligation:
        var ob = RoleObligation.new()
        ob.id = "respond_to_crime"
        ob.description = "Respond to reported incident"
        ob.required_actions = ["investigate", "arrest", "write_report"]
        ob.time_limit = 0.5  # 30 minutes to respond
        ob.priority = "urgent"
        return ob

class MedicalObligations:
    static func get_rounds_obligation() -> RoleObligation:
        var ob = RoleObligation.new()
        ob.id = "medical_rounds"
        ob.description = "Check on patients"
        ob.required_actions = ["check_patient", "update_chart"]
        ob.required_location = "medical_ward"
        ob.repeating = true
        ob.repeat_interval = 2.0
        return ob
```

#### 3. Role Performance Evaluation
```gdscript
# src/core/systems/role_performance.gd
extends Node

class_name RolePerformance

signal performance_threshold_crossed(new_level)
signal suspicious_behavior_noticed(npc_id, reason)

var performance_thresholds = {
    "excellent": 0.9,
    "good": 0.7,
    "adequate": 0.5,
    "poor": 0.3,
    "blown": 0.0
}

func evaluate_task_completion(task: RoleObligation, completion_time: float) -> float:
    var score = 1.0
    
    # Time penalty
    if task.time_limit > 0:
        var time_ratio = completion_time / task.time_limit
        if time_ratio > 1.0:
            score *= (2.0 - time_ratio)  # Degrades after deadline
    
    # Priority bonus
    match task.priority:
        "urgent":
            score *= 1.2 if completion_time < task.time_limit * 0.5 else 1.0
        "high":
            score *= 1.1 if completion_time < task.time_limit * 0.7 else 1.0
    
    return clamp(score, 0.0, 1.2)

func evaluate_behavior_consistency(action: String, role: String, witnesses: Array) -> void:
    var consistency_score = _calculate_action_consistency(action, role)
    
    if consistency_score < 0.5:  # Suspicious behavior
        for witness in witnesses:
            var notice_chance = (1.0 - consistency_score) * witness.alertness
            
            if randf() < notice_chance:
                emit_signal("suspicious_behavior_noticed", witness.id, action)
                
                # Witness reaction depends on their status
                if AssimilationManager.is_assimilated(witness.id):
                    # Assimilated are more likely to investigate
                    witness.investigate_suspicious_person(player)
                else:
                    # Unassimilated might just be confused
                    witness.increase_wariness(0.2)

func _calculate_action_consistency(action: String, role: String) -> float:
    # How well does action fit role expectations
    var role_actions = {
        "security": {
            "expected": ["patrol", "check_id", "arrest", "investigate"],
            "unusual": ["shop", "gamble", "loiter"],
            "forbidden": ["steal", "vandalize", "trespass"]
        },
        "medical": {
            "expected": ["examine", "treat", "document", "sanitize"],
            "unusual": ["patrol", "arrest", "heavy_lifting"],
            "forbidden": ["abandon_patient", "ignore_emergency"]
        },
        "maintenance": {
            "expected": ["repair", "inspect", "access_panels", "carry_tools"],
            "unusual": ["paperwork", "socialize", "shop"],
            "forbidden": ["ignore_hazard", "create_mess"]
        }
    }
    
    var actions = role_actions.get(role, {})
    
    if action in actions.get("expected", []):
        return 1.0
    elif action in actions.get("unusual", []):
        return 0.6
    elif action in actions.get("forbidden", []):
        return 0.0
    else:
        return 0.8  # Neutral actions
```

### Integration Systems

#### Quest Integration
```gdscript
# Infiltration quests built on disguise obligations
class InfiltrationQuest:
    var quest_id: String = ""
    var target_role: String = ""
    var required_tasks: Array = []  # Role obligations to complete
    var cover_story: String = ""
    var extraction_plan: String = ""
    
    func start_infiltration():
        # Player must acquire appropriate disguise
        if not InventoryManager.has_item(target_role + "_uniform"):
            QuestLog.add_objective("Acquire " + target_role + " uniform")
            return false
        
        # Equip disguise starts obligation chain
        DisguiseManager.equip_disguise_by_type(target_role)
        
        # Add infiltration-specific obligations
        for task in required_tasks:
            DisguiseManager.add_special_obligation(task)
        
        return true

# Example: Infiltrate Medical to access records
func create_medical_infiltration_quest():
    return {
        "id": "steal_medical_records",
        "target_role": "medical",
        "required_tasks": [
            {
                "id": "complete_rounds",
                "description": "Complete patient rounds to avoid suspicion",
                "required_actions": ["check_patient"],
                "minimum_count": 5
            },
            {
                "id": "access_records",
                "description": "Access restricted medical database",
                "required_location": "records_room",
                "time_window": {"start": 14, "end": 15}  # During shift change
            }
        ],
        "cover_story": "Temporary transfer from Medical Bay 2",
        "extraction": "Change back to civilian clothes in supply closet"
    }
```

#### NPC Perception Integration
```gdscript
# NPCs react based on role expectations
func get_npc_reaction(npc: BaseNPC, player_role: String) -> Dictionary:
    var reaction = {
        "trust_modifier": 0.0,
        "suspicion_modifier": 0.0,
        "dialog_branch": "",
        "behavior_change": ""
    }
    
    # Role relationships matter
    match npc.role:
        "security_chief":
            if player_role == "security":
                reaction.trust_modifier = 0.3
                reaction.dialog_branch = "fellow_officer"
            elif player_role == "maintenance":
                reaction.suspicion_modifier = 0.1
                reaction.dialog_branch = "verify_work_order"
        
        "doctor":
            if player_role == "medical":
                reaction.trust_modifier = 0.4
                reaction.dialog_branch = "colleague"
                reaction.behavior_change = "share_gossip"
            elif player_role == "security":
                reaction.dialog_branch = "official_business"
        
        "dock_worker":
            if player_role == "corporate":
                reaction.suspicion_modifier = 0.2
                reaction.dialog_branch = "management_distrust"
            elif player_role == "maintenance":
                reaction.trust_modifier = 0.2
                reaction.dialog_branch = "working_class_solidarity"
    
    # Assimilated might test you
    if AssimilationManager.is_assimilated(npc.id):
        if player_role != "civilian":
            reaction.behavior_change = "test_role_knowledge"
    
    return reaction
```

#### Detection Integration
```gdscript
# Wrong behavior in disguise triggers detection
func check_disguise_detection(action: String, context: Dictionary):
    var severity = 0.0
    
    match action:
        "failed_obligation":
            severity = 0.4
        "wrong_response":
            severity = 0.5
        "out_of_character":
            severity = 0.3
        "caught_changing":
            severity = 0.8
        "wrong_location":
            severity = 0.6
    
    # Witnesses matter
    var witnesses = context.get("witnesses", [])
    for witness_id in witnesses:
        if AssimilationManager.is_assimilated(witness_id):
            # Assimilated are more perceptive
            DetectionManager.trigger_detection(
                witness_id,
                "disguise_failure",
                severity * 1.5
            )
            break

# Can't just take off uniform anywhere
func attempt_disguise_removal(location: String) -> bool:
    if current_disguise == "civilian":
        return true
    
    # Need private location
    var private_locations = ["bathroom", "closet", "locker_room", "quarters"]
    if not location in private_locations:
        # Check for witnesses
        var witnesses = NPCManager.get_npcs_in_radius(player.position, 300)
        if witnesses.size() > 0:
            UI.show_notification("Can't change clothes here - too public!")
            return false
    
    # Security uniforms have trackers
    if current_disguise == "security":
        SecuritySystem.log_uniform_removal(player.position)
    
    return true
```

## MVP Implementation

### Basic Features

1. **Core Disguises**
   - Security uniform (patrol duties)
   - Medical scrubs (patient care)
   - Maintenance coveralls (repair tasks)
   - Civilian clothes (default)

2. **Simple Obligations**
   - One primary task per role
   - Clear success/failure
   - Time limits shown

3. **Basic Performance**
   - Binary pass/fail
   - Obvious inappropriate actions
   - Simple NPC reactions

### MVP Examples

```gdscript
# Security patrol obligation
{
    "role": "security",
    "obligation": "patrol_mall",
    "description": "Patrol the mall district for 1 hour",
    "tasks": [
        "Walk through all mall areas",
        "Respond to any crimes",
        "Check in at security booth"
    ],
    "failure": "Abandoning post raises suspicion"
}

# Medical rounds obligation  
{
    "role": "medical",
    "obligation": "patient_rounds",
    "description": "Check on patients in Ward A",
    "tasks": [
        "Visit 5 patient rooms",
        "Update charts",
        "Report to head nurse"
    ],
    "time_limit": 2.0,
    "failure": "Patients complain about neglect"
}

# Maintenance access benefit
{
    "role": "maintenance",
    "obligation": "routine_inspection",
    "description": "Inspect ventilation systems",
    "tasks": [
        "Check 3 vent grates",
        "File maintenance report"
    ],
    "benefit": "Access to restricted areas via vents"
}
```

## Full Implementation

### Advanced Features

#### 1. Role Knowledge Tests
```gdscript
# NPCs test your role knowledge
class RoleKnowledgeTest:
    var test_questions = {
        "security": [
            {
                "question": "What's the code for a disturbance?",
                "correct": ["10-53", "Code 53"],
                "response": "Right, 10-53. Stay alert."
            },
            {
                "question": "When's shift change?",
                "correct": ["0800", "8am", "oh-eight-hundred"],
                "response": "Yeah, 0800 hours. See you then."
            }
        ],
        "medical": [
            {
                "question": "What's the dosage for Meditrol?",
                "correct": ["5cc", "five cc", "5 milliliters"],
                "response": "Correct, 5cc standard dose."
            },
            {
                "question": "Who's the head of surgery?",
                "correct": ["Dr. Chen", "Doctor Chen", "Chen"],
                "response": "Right, Dr. Chen. Tough but fair."
            }
        ]
    }
    
    func test_player_knowledge(role: String, tester_npc: String):
        var questions = test_questions.get(role, [])
        if questions.empty():
            return
        
        var question = questions[randi() % questions.size()]
        
        # Show dialog options
        var options = _generate_answer_options(question)
        var answer = yield(DialogManager.show_options(options), "completed")
        
        if answer in question.correct:
            # Passed test
            DialogManager.show_npc_response(tester_npc, question.response)
            NPCManager.get_npc(tester_npc).trust_level += 10
        else:
            # Failed test
            DialogManager.show_npc_response(tester_npc, "You don't know? Suspicious...")
            DisguiseManager.performance_score *= 0.7
            SuspicionManager.increase_npc_suspicion(tester_npc, 20)
```

#### 2. Complex Role Obligations
```gdscript
# Multi-stage obligations with branching
class ComplexObligation:
    func create_security_investigation():
        return {
            "id": "investigate_theft",
            "role": "security",
            "stages": [
                {
                    "id": "respond_to_call",
                    "description": "Respond to theft report at Electronics Store",
                    "time_limit": 0.5,
                    "actions": ["arrive_at_scene", "talk_to_victim"]
                },
                {
                    "id": "gather_evidence",
                    "description": "Interview witnesses and check security footage",
                    "branches": {
                        "find_witness": {
                            "next": "pursue_suspect",
                            "performance": 1.2
                        },
                        "no_witness": {
                            "next": "file_report",
                            "performance": 0.8
                        }
                    }
                },
                {
                    "id": "pursue_suspect",
                    "description": "Chase down the thief",
                    "success_condition": "catch_or_identify",
                    "failure": "suspect_escapes"
                }
            ],
            "rewards": {
                "perfect": {"credits": 100, "trust": 20},
                "good": {"credits": 50, "trust": 10},
                "poor": {"credits": 20, "trust": -5}
            }
        }
```

#### 3. Disguise Combinations
```gdscript
# Layered disguises for complex infiltration
class DisguiseLayers:
    var outfit_layers = {
        "base": "",  # Underwear
        "inner": "", # Shirt/undershirt
        "outer": "", # Jacket/coat
        "full": ""   # Complete uniform
    }
    
    func can_quick_change(from: String, to: String) -> bool:
        # Some disguises can be worn under others
        var quick_changes = {
            "medical_scrubs": ["under_maintenance"],
            "civilian": ["under_corporate_coat"],
            "security_vest": ["over_civilian"]
        }
        
        return to in quick_changes.get(from, [])
    
    func perform_quick_change():
        # Instant change if prepared
        if outfit_layers.outer == "corporate_coat":
            current_disguise = "corporate"
            return true
        
        return false
```

#### 4. Role Reputation System
```gdscript
# Build reputation within roles
class RoleReputation:
    var reputations: Dictionary = {}  # role: reputation_value
    
    func modify_reputation(role: String, amount: int, reason: String):
        if not role in reputations:
            reputations[role] = 0
        
        reputations[role] += amount
        
        # Reputation affects future infiltrations
        if reputations[role] > 50:
            # Trusted - fewer obligations
            DisguiseManager.trusted_roles.append(role)
        elif reputations[role] < -20:
            # Blacklisted - can't use role
            DisguiseManager.blacklisted_roles.append(role)
        
        # NPCs remember you
        for npc in NPCRegistry.get_npcs_by_role(role):
            npc.remember_player_performance(role, reputations[role])
```

### Quest Integration Examples

#### The Perfect Heist Quest
```gdscript
{
    "id": "casino_heist",
    "name": "The Inside Job",
    "required_disguises": ["maintenance", "security", "corporate"],
    "stages": [
        {
            "disguise": "maintenance",
            "objective": "Disable security cameras",
            "obligations": [
                "Report for maintenance shift",
                "Fix 2 real problems to maintain cover",
                "Access camera control room during 'repair'"
            ]
        },
        {
            "disguise": "security", 
            "objective": "Clear patrol routes",
            "obligations": [
                "Take over specific patrol route",
                "Redirect other guards away from target",
                "Disable alarms from security station"
            ]
        },
        {
            "disguise": "corporate",
            "objective": "Access the vault",
            "obligations": [
                "Attend board meeting",
                "Present fake financial report",
                "Get vault access during 'audit'"
            ]
        }
    ]
}
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/disguise_serializer.gd
extends BaseSerializer

class_name DisguiseSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("disguise", self, 55)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "current_disguise": DisguiseManager.current_disguise,
        "performance_score": DisguiseManager.performance_score,
        "time_in_role": DisguiseManager.time_in_role,
        "pending_obligations": _serialize_obligations(DisguiseManager.pending_obligations),
        "completed_tasks": DisguiseManager.completed_tasks,
        "failed_tasks": DisguiseManager.failed_tasks,
        "role_reputations": RoleReputation.reputations,
        "trusted_roles": DisguiseManager.trusted_roles,
        "blacklisted_roles": DisguiseManager.blacklisted_roles,
        "disguise_inventory": _serialize_owned_disguises()
    }

func _serialize_obligations(obligations: Array) -> Array:
    var serialized = []
    for ob in obligations:
        serialized.append({
            "id": ob.id,
            "time_remaining": ob.time_limit - (TimeManager.current_time - ob.start_time),
            "progress": ob.progress,
            "attempts": ob.attempts
        })
    return serialized

func deserialize(data: Dictionary) -> void:
    DisguiseManager.current_disguise = data.get("current_disguise", "civilian")
    DisguiseManager.performance_score = data.get("performance_score", 1.0)
    DisguiseManager.time_in_role = data.get("time_in_role", 0.0)
    
    _deserialize_obligations(data.get("pending_obligations", []))
    DisguiseManager.completed_tasks = data.get("completed_tasks", [])
    DisguiseManager.failed_tasks = data.get("failed_tasks", [])
    
    RoleReputation.reputations = data.get("role_reputations", {})
    DisguiseManager.trusted_roles = data.get("trusted_roles", [])
    DisguiseManager.blacklisted_roles = data.get("blacklisted_roles", [])
    
    # Restore appearance
    if DisguiseManager.current_disguise != "civilian":
        PlayerAppearance.set_outfit(DisguiseManager.current_disguise)
```

## UI Components

### Role HUD
```gdscript
# src/ui/disguise/role_hud.gd
extends Control

onready var role_label = $RoleLabel
onready var obligation_list = $ObligationList
onready var performance_bar = $PerformanceBar
onready var timer = $ObligationTimer

func _ready():
    DisguiseManager.connect("disguise_equipped", self, "_on_disguise_changed")
    DisguiseManager.connect("obligation_added", self, "_refresh_obligations")

func _on_disguise_changed(disguise: String):
    if disguise == "civilian":
        hide()
    else:
        show()
        role_label.text = "Role: " + disguise.capitalize()
        _refresh_obligations()

func _refresh_obligations():
    obligation_list.clear()
    
    for obligation in DisguiseManager.pending_obligations:
        var item = ObligationItem.instance()
        item.setup(obligation)
        obligation_list.add_child(item)
        
        if obligation.time_limit > 0:
            item.show_timer(obligation.time_limit)

func _process(delta):
    if visible:
        performance_bar.value = DisguiseManager.performance_score * 100
        
        # Color code performance
        if performance_bar.value > 70:
            performance_bar.modulate = Color.green
        elif performance_bar.value > 40:
            performance_bar.modulate = Color.yellow  
        else:
            performance_bar.modulate = Color.red
```

### Quick Change Interface
```gdscript
# src/ui/disguise/quick_change_ui.gd
extends PopupPanel

onready var disguise_grid = $DisguiseGrid
onready var current_outfit = $CurrentOutfit
onready var privacy_warning = $PrivacyWarning

func show_change_options():
    var location_private = _check_location_privacy()
    
    if not location_private:
        privacy_warning.show()
        privacy_warning.text = "Warning: Changing here may blow your cover!"
    
    _populate_available_disguises()
    popup_centered()

func _populate_available_disguises():
    disguise_grid.clear()
    
    var disguises = InventoryManager.get_items_by_category("disguise")
    
    for disguise in disguises:
        var slot = DisguiseSlot.instance()
        slot.setup(disguise)
        slot.connect("selected", self, "_on_disguise_selected")
        
        # Show if blacklisted
        if disguise.disguise_type in DisguiseManager.blacklisted_roles:
            slot.show_blacklisted()
        
        disguise_grid.add_child(slot)
```

## Balance Considerations

### Obligation Difficulty
- **Basic roles**: 1-2 simple tasks per shift
- **Advanced roles**: Complex multi-stage obligations
- **Time pressure**: 30 min - 2 hour deadlines
- **Reputation impact**: -20 to +20 per task

### Performance Thresholds
- **90%+**: Excellent - NPCs trust you completely
- **70-89%**: Good - Occasional suspicion
- **50-69%**: Adequate - Frequent checks
- **30-49%**: Poor - Under scrutiny
- **<30%**: Blown - Cover compromised

### Access vs Obligation Balance
- **Security**: High access, high obligation
- **Medical**: Medium access, medium obligation  
- **Maintenance**: High access, low obligation
- **Corporate**: Medium access, high social obligation
- **Service**: Low access, low obligation

## Testing Considerations

1. **Obligation System**
   - All obligations trigger correctly
   - Time limits enforced
   - Completion detected properly
   - Failures have consequences

2. **Performance Tracking**
   - Actions evaluated correctly
   - Score degrades appropriately
   - NPCs react to performance
   - Reputation persists

3. **Integration Testing**
   - Quest obligations work
   - Detection triggers on failure
   - NPCs perceive role correctly
   - Quick changes function

4. **Edge Cases**
   - Changing during obligations
   - Multiple simultaneous roles
   - Blacklisted role attempts
   - Save/load during obligations

This system transforms disguises from simple access tools into complex role-playing challenges where maintaining cover through authentic behavior is as important as wearing the right clothes.