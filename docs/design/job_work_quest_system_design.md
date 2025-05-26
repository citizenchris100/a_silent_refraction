# Job/Work Quest System Design Document

## Overview

The Job/Work Quest System provides district-specific employment opportunities inspired by Grand Theft Auto's mission structure. Each district offers unique job quest lines that serve as both income sources and narrative vehicles, creating opportunities for investigation, character interaction, and moral choices while maintaining economic pressure throughout the game.

## Core Design Principles

### GTA-Style Mission Structure
- Each job starts with an introductory quest to gain employment
- Subsequent shifts become repeatable missions with variations
- Performance affects reputation and unlocks better opportunities
- Jobs provide cover for investigation and access to restricted areas

### Economic Integration
- Jobs are primary legitimate income source
- Pay scales with performance and reputation
- Time investment creates tension with other objectives
- Economic pressure prevents infinite grinding

### Narrative Opportunities
- Jobs expose players to different station perspectives
- Work environments reveal clues about assimilation
- Coworker relationships build trust networks
- Job performance affects ending paths

## System Architecture

### Component Structure

```gdscript
# src/core/systems/job_work_quest_system.gd
extends Node

class_name JobWorkQuestSystem

signal job_unlocked(job_id: String)
signal shift_started(job_id: String, shift_data: ShiftData)
signal shift_completed(job_id: String, performance: float, pay: int)
signal job_reputation_changed(job_id: String, new_reputation: int)
signal job_quest_completed(quest_id: String)

# Job types by district
enum JobType {
    DOCK_WORKER,      # Spaceport - Loading/unloading cargo
    SECURITY_PATROL,  # Security - Mall patrol (First Quest)
    MEDICAL_COURIER,  # Medical - Supply runs
    RETAIL_CLERK,     # Mall - Customer service & loss prevention
    JANITOR          # Barracks - Cleaning & maintenance
}

# Job quest data
class JobQuestData:
    var id: String = ""
    var job_type: int = JobType.DOCK_WORKER
    var district: String = ""
    var quest_name: String = ""
    var quest_giver: String = ""  # NPC who hires you
    var intro_quest_id: String = ""  # One-time quest to get job
    var shift_quests: Array = []  # Repeatable work missions
    var requirements: Dictionary = {}  # Trust, items, skills
    var base_pay: int = 0
    var time_per_shift: int = 0  # In minutes
    var reputation: int = 0  # Job-specific reputation
    var shifts_completed: int = 0
    var last_shift_day: int = -1
    var unlocked: bool = false
    var suspended: bool = false  # For poor performance
    var suspension_until_day: int = 0

# Individual shift instance
class ShiftData:
    var shift_id: String = ""
    var job_id: String = ""
    var variant: String = ""  # Different scenarios
    var start_time: int = 0
    var end_time: int = 0
    var objectives: Array = []
    var performance_score: float = 0.0
    var incidents: Array = []  # Things that happen during shift
    var clues_available: Array = []  # Investigation opportunities
    var npcs_encountered: Array = []  # For trust building
```

## Job Quest Lines by District

### Spaceport - Dock Worker

```gdscript
var dock_worker_job = {
    "id": "dock_worker",
    "job_type": JobType.DOCK_WORKER,
    "district": "spaceport",
    "quest_name": "Heavy Lifting",
    "quest_giver": "foreman_chen",
    
    # Intro quest - prove yourself
    "intro_quest": {
        "id": "dock_intro",
        "name": "New Hire Orientation",
        "description": "Prove you can handle dock work",
        "objectives": [
            "Report to Foreman Chen at Loading Bay 3",
            "Complete cargo loading tutorial",
            "Handle your first real shipment",
            "Don't damage any cargo"
        ],
        "rewards": {
            "job_unlock": "dock_worker",
            "credits": 50,
            "item": "work_gloves"
        }
    },
    
    # Repeatable shift variants
    "shift_variants": [
        {
            "id": "standard_cargo",
            "name": "Standard Cargo Shift",
            "frequency": 0.6,
            "objectives": [
                "Load 10 cargo containers",
                "Verify manifests",
                "Report discrepancies"
            ],
            "incidents": [
                {
                    "chance": 0.2,
                    "type": "damaged_goods",
                    "description": "Container damaged in transit"
                },
                {
                    "chance": 0.1,
                    "type": "suspicious_cargo",
                    "description": "Unmarked containers arrive",
                    "clue": "mysterious_shipments"
                }
            ]
        },
        {
            "id": "rush_delivery",
            "name": "Rush Delivery",
            "frequency": 0.3,
            "objectives": [
                "Expedite priority shipment",
                "Clear landing pad in 30 minutes",
                "Coordinate with customs"
            ],
            "pay_modifier": 1.5,
            "stress_level": "high"
        },
        {
            "id": "night_shift",
            "name": "Skeleton Crew",
            "frequency": 0.1,
            "time_restriction": "night",
            "objectives": [
                "Work with minimal crew",
                "Handle security protocols",
                "Investigation opportunity"
            ],
            "incidents": [
                {
                    "chance": 0.4,
                    "type": "strange_behavior",
                    "description": "Coworkers acting oddly",
                    "clue": "drone_dock_workers"
                }
            ]
        }
    ],
    
    "requirements": {
        "strength": 3,  # Physical requirement
        "trust": {"foreman_chen": 20}
    },
    
    "base_pay": 40,
    "time_per_shift": 240,  # 4 hours
    "performance_bonuses": {
        "no_damage": 10,
        "fast_completion": 15,
        "incident_report": 20
    }
}
```

### Security - Mall Patrol (First Quest)

```gdscript
var security_patrol_job = {
    "id": "mall_security",
    "job_type": JobType.SECURITY_PATROL,
    "district": "mall",
    "quest_name": "Thin Blue Line",
    "quest_giver": "chief_morrison",
    
    # This is the First Quest
    "intro_quest": {
        "id": "first_quest",
        "name": "Mall Security Trial",
        "description": "Complete a trial shift as mall security",
        "objectives": [
            "Get security uniform from Chief Morrison",
            "Learn patrol routes",
            "Handle mall incident",
            "Complete shift without major incidents"
        ],
        "special": "FIRST_QUEST"
    },
    
    "shift_variants": [
        {
            "id": "routine_patrol",
            "name": "Routine Patrol",
            "frequency": 0.5,
            "objectives": [
                "Complete patrol circuit",
                "Check secure areas",
                "Respond to calls"
            ],
            "incidents": [
                {
                    "chance": 0.3,
                    "type": "shoplifter",
                    "description": "Catch shoplifter in act"
                },
                {
                    "chance": 0.2,
                    "type": "drone_vandalism",
                    "description": "Vandalism in progress",
                    "clue": "coordinated_crimes"
                }
            ]
        },
        {
            "id": "vip_protection",
            "name": "VIP Shopping Detail",
            "frequency": 0.2,
            "objectives": [
                "Escort VIP through mall",
                "Prevent incidents",
                "Maintain discretion"
            ],
            "pay_modifier": 2.0,
            "reputation_requirement": 50
        }
    ],
    
    "requirements": {
        "uniform": "security_uniform",
        "badge": "security_badge"
    },
    
    "base_pay": 50,
    "time_per_shift": 240,
    "role_obligations": [
        "Respond to security calls",
        "Maintain patrol schedule",
        "File incident reports"
    ]
}
```

### Medical - Supply Courier

```gdscript
var medical_courier_job = {
    "id": "medical_courier",
    "job_type": JobType.MEDICAL_COURIER,
    "district": "medical",
    "quest_name": "Critical Delivery",
    "quest_giver": "nurse_patel",
    
    "intro_quest": {
        "id": "medical_intro",
        "name": "Emergency Supplies",
        "description": "Help during medical supply crisis",
        "objectives": [
            "Report to Nurse Patel",
            "Retrieve supplies from three locations",
            "Navigate security checkpoints",
            "Deliver before patient crisis"
        ],
        "time_limit": 120,  # 2 hour time limit
        "rewards": {
            "job_unlock": "medical_courier",
            "credits": 75,
            "item": "medical_access_badge",
            "trust": {"nurse_patel": 30}
        }
    },
    
    "shift_variants": [
        {
            "id": "routine_delivery",
            "name": "Supply Run",
            "frequency": 0.6,
            "objectives": [
                "Pick up supplies from warehouse",
                "Deliver to 3 medical stations",
                "Get signatures"
            ],
            "travel_heavy": true
        },
        {
            "id": "biohazard_transport",
            "name": "Hazardous Materials",
            "frequency": 0.2,
            "objectives": [
                "Transport biohazard samples",
                "Maintain cold chain",
                "Follow safety protocols"
            ],
            "incidents": [
                {
                    "chance": 0.15,
                    "type": "sample_leak",
                    "description": "Container compromise detected",
                    "clue": "contamination_spreading"
                }
            ],
            "pay_modifier": 1.8,
            "suspicion_risk": 0.3
        },
        {
            "id": "emergency_blood",
            "name": "Blood Drive",
            "frequency": 0.2,
            "objectives": [
                "Collect blood donations",
                "Screen donors",
                "Rush delivery to surgery"
            ],
            "incidents": [
                {
                    "chance": 0.25,
                    "type": "tainted_blood",
                    "description": "Donor shows unusual symptoms",
                    "clue": "assimilation_blood_markers"
                }
            ]
        }
    ],
    
    "requirements": {
        "disguise": "medical_scrubs",
        "trust": {"medical_staff": 20}
    },
    
    "base_pay": 60,
    "time_per_shift": 180  # 3 hours
}
```

### Mall - Retail Clerk

```gdscript
var retail_clerk_job = {
    "id": "retail_clerk",
    "job_type": JobType.RETAIL_CLERK,
    "district": "mall",
    "quest_name": "Customer Service",
    "quest_giver": "manager_kim",
    
    "intro_quest": {
        "id": "retail_intro",
        "name": "Sales Training",
        "description": "Learn the retail trade",
        "objectives": [
            "Report to Manager Kim at MegaMart",
            "Complete POS system training",
            "Handle difficult customer",
            "Catch your first shoplifter"
        ]
    },
    
    "shift_variants": [
        {
            "id": "sales_floor",
            "name": "Sales Associate",
            "frequency": 0.5,
            "objectives": [
                "Assist 10 customers",
                "Process transactions",
                "Maintain merchandise"
            ],
            "incidents": [
                {
                    "chance": 0.2,
                    "type": "angry_customer",
                    "description": "Customer complaint escalation"
                },
                {
                    "chance": 0.15,
                    "type": "drone_customer",
                    "description": "Customer behaving strangely",
                    "clue": "consumer_behavior_changes"
                }
            ]
        },
        {
            "id": "loss_prevention",
            "name": "Loss Prevention Duty",
            "frequency": 0.3,
            "objectives": [
                "Monitor security cameras",
                "Patrol shop floor",
                "Apprehend shoplifters"
            ],
            "incidents": [
                {
                    "chance": 0.4,
                    "type": "organized_theft",
                    "description": "Coordinated shoplifting attempt",
                    "clue": "drone_theft_ring"
                }
            ],
            "pay_modifier": 1.3
        },
        {
            "id": "inventory_night",
            "name": "Overnight Inventory",
            "frequency": 0.2,
            "time_restriction": "night",
            "objectives": [
                "Count inventory",
                "Restock shelves",
                "Investigate discrepancies"
            ],
            "incidents": [
                {
                    "chance": 0.3,
                    "type": "missing_stock",
                    "description": "Large inventory discrepancy",
                    "clue": "black_market_operation"
                }
            ]
        }
    ],
    
    "requirements": {
        "personality": {"friendliness": 40},
        "clean_record": true  # No theft convictions
    },
    
    "base_pay": 35,
    "time_per_shift": 240,
    "performance_metrics": {
        "sales_target": 500,  # Credits in sales
        "theft_prevented": 100,  # Credits saved
        "customer_satisfaction": 0.8
    }
}
```

### Barracks - Janitor

```gdscript
var janitor_job = {
    "id": "janitor",
    "job_type": JobType.JANITOR,
    "district": "barracks",
    "quest_name": "Cleaning Duty",
    "quest_giver": "supervisor_jones",
    
    "intro_quest": {
        "id": "janitor_intro",
        "name": "Mop and Bucket Brigade",
        "description": "Take on janitorial duties",
        "objectives": [
            "Report to Supervisor Jones",
            "Clean the common areas",
            "Handle biohazard cleanup",
            "Access restricted area for deep clean"
        ],
        "rewards": {
            "job_unlock": "janitor",
            "credits": 30,
            "item": "master_keycard",  # Important!
            "trust": {"supervisor_jones": 20}
        }
    },
    
    "shift_variants": [
        {
            "id": "routine_cleaning",
            "name": "Standard Cleaning",
            "frequency": 0.6,
            "objectives": [
                "Clean assigned areas",
                "Empty trash",
                "Report maintenance issues"
            ],
            "access_bonus": [  # Areas you can access
                "barracks_residential",
                "barracks_mechanical",
                "barracks_storage"
            ]
        },
        {
            "id": "deep_clean",
            "name": "Deep Clean Special",
            "frequency": 0.2,
            "objectives": [
                "Access restricted areas",
                "Thorough sanitization",
                "Document findings"
            ],
            "incidents": [
                {
                    "chance": 0.4,
                    "type": "strange_substance",
                    "description": "Unknown substance in vents",
                    "clue": "assimilation_residue"
                },
                {
                    "chance": 0.3,
                    "type": "hidden_items",
                    "description": "Items hidden in maintenance",
                    "clue": "resistance_cache"
                }
            ],
            "access_bonus": [
                "all_barracks_areas",
                "maintenance_tunnels"
            ]
        },
        {
            "id": "emergency_cleanup",
            "name": "Biohazard Response",
            "frequency": 0.2,
            "objectives": [
                "Respond to emergency call",
                "Contain biohazard",
                "Sanitize area"
            ],
            "incidents": [
                {
                    "chance": 0.5,
                    "type": "assimilation_scene",
                    "description": "Signs of violent struggle",
                    "clue": "assimilation_attack_evidence"
                }
            ],
            "pay_modifier": 2.0,
            "suspicion_risk": 0.4
        }
    ],
    
    "requirements": {
        "no_criminal_record": true
    },
    
    "base_pay": 35,
    "time_per_shift": 180,
    "special_perks": {
        "universal_access": "Master keycard provides station-wide access",
        "invisible_status": "People ignore janitors",
        "investigation_cover": "Perfect cover for snooping"
    }
}
```

## Job Mechanics

### Shift System

```gdscript
func start_shift(job_id: String) -> void:
    var job = get_job_data(job_id)
    if not job or not job.unlocked:
        return
    
    # Check if already worked today
    if job.last_shift_day == TimeManager.current_day:
        PromptNotificationSystem.show_warning(
            "already_worked",
            "You've already worked this job today.\nCome back tomorrow.",
            "Shift Unavailable"
        )
        return
    
    # Check suspension
    if job.suspended and TimeManager.current_day < job.suspension_until_day:
        var days_left = job.suspension_until_day - TimeManager.current_day
        PromptNotificationSystem.show_warning(
            "job_suspended",
            "You're suspended for %d more days.\nReason: Poor performance" % days_left,
            "Suspended"
        )
        return
    
    # Select shift variant
    var variant = _select_shift_variant(job)
    
    # Create shift instance
    var shift = ShiftData.new()
    shift.shift_id = "shift_" + str(Time.get_ticks_msec())
    shift.job_id = job_id
    shift.variant = variant.id
    shift.start_time = TimeManager.get_current_minutes()
    shift.end_time = shift.start_time + job.time_per_shift
    shift.objectives = variant.objectives.duplicate()
    
    # Start shift quest
    var shift_quest = _create_shift_quest(job, shift, variant)
    QuestManager.add_quest(shift_quest)
    
    # Lock player into shift
    PlayerController.set_working(true, shift.end_time)
    
    # Apply disguise if required
    if job.requirements.has("disguise"):
        DisguiseManager.force_disguise(job.requirements.disguise)
    
    emit_signal("shift_started", job_id, shift)
```

### Performance Evaluation

```gdscript
func evaluate_shift_performance(shift: ShiftData) -> Dictionary:
    var performance = {
        "base_score": 1.0,
        "bonuses": {},
        "penalties": {},
        "total_pay": 0
    }
    
    var job = get_job_data(shift.job_id)
    
    # Check objective completion
    var completed = 0
    for obj in shift.objectives:
        if obj.completed:
            completed += 1
    
    var completion_rate = float(completed) / shift.objectives.size()
    performance.base_score = completion_rate
    
    # Time bonus/penalty
    var time_taken = TimeManager.get_current_minutes() - shift.start_time
    if time_taken < job.time_per_shift * 0.9:
        performance.bonuses["fast_completion"] = 0.2
    elif time_taken > job.time_per_shift * 1.1:
        performance.penalties["overtime"] = -0.1
    
    # Incident handling
    for incident in shift.incidents:
        if incident.handled_well:
            performance.bonuses["incident_" + incident.type] = 0.15
        else:
            performance.penalties["incident_" + incident.type] = -0.2
    
    # Calculate total score
    var total_score = performance.base_score
    for bonus in performance.bonuses.values():
        total_score += bonus
    for penalty in performance.penalties.values():
        total_score += penalty
    
    total_score = clamp(total_score, 0.0, 1.5)
    performance.performance_score = total_score
    
    # Calculate pay
    var base_pay = job.base_pay
    if shift.variant in job.shift_variants:
        var variant = job.shift_variants[shift.variant]
        if variant.has("pay_modifier"):
            base_pay *= variant.pay_modifier
    
    performance.total_pay = int(base_pay * total_score)
    
    return performance
```

### Reputation System

```gdscript
func update_job_reputation(job_id: String, performance_score: float) -> void:
    var job = get_job_data(job_id)
    if not job:
        return
    
    # Reputation change based on performance
    var rep_change = 0
    if performance_score >= 1.2:
        rep_change = 10  # Excellent
    elif performance_score >= 0.8:
        rep_change = 5   # Good
    elif performance_score >= 0.5:
        rep_change = 0   # Adequate
    else:
        rep_change = -10 # Poor
    
    job.reputation = clamp(job.reputation + rep_change, 0, 100)
    
    # Check for suspension
    if job.reputation <= 0:
        job.suspended = true
        job.suspension_until_day = TimeManager.current_day + 3
        PromptNotificationSystem.show_warning(
            "job_suspended",
            "Your poor performance has resulted in suspension.\nReturn in 3 days.",
            "Suspended from " + job.quest_name
        )
    
    # Check for unlocks
    if job.reputation >= 50 and not has_unlock("job_" + job_id + "_veteran"):
        unlock_veteran_perks(job_id)
    
    emit_signal("job_reputation_changed", job_id, job.reputation)
```

### Investigation Opportunities

```gdscript
func discover_job_clue(job_id: String, clue_id: String) -> void:
    var job = get_job_data(job_id)
    var current_shift = get_current_shift()
    
    if not current_shift or current_shift.job_id != job_id:
        return  # Must be on shift
    
    # Add clue to shift for end-of-shift summary
    current_shift.clues_found.append(clue_id)
    
    # Trigger investigation system
    var context = {
        "found_during_work": true,
        "job_type": job.job_type,
        "job_reputation": job.reputation
    }
    
    InvestigationClueSystem.discover_clue(
        "workplace_investigation",
        clue_id,
        context
    )
    
    # Some clues affect job standing
    if clue_id in ["report_suspicious_activity", "prevent_sabotage"]:
        job.reputation += 5
    elif clue_id in ["caught_snooping", "accessed_restricted"]:
        job.reputation -= 10
```

## Integration with Other Systems

### Economy System Integration

```gdscript
func process_shift_payment(job_id: String, performance: Dictionary) -> void:
    var pay = performance.total_pay
    
    # Apply economic modifiers
    var district = get_job_district(job_id)
    var economic_modifier = EconomyManager.get_district_modifier(district)
    pay = int(pay * economic_modifier)
    
    # Add credits
    EconomyManager.add_credits(pay, "job_payment")
    
    # Show payment notification
    PromptNotificationSystem.show_confirm(
        "job_payment",
        "Shift complete!\n\nPerformance: %s\nPay: %d credits" % [
            _get_performance_rating(performance.performance_score),
            pay
        ],
        "Payment Received"
    )
    
    # Update economic pressure
    EconomyManager.update_time_until_broke()
```

### Disguise System Integration

```gdscript
func validate_job_requirements(job_id: String) -> bool:
    var job = get_job_data(job_id)
    
    # Check disguise requirement
    if job.requirements.has("disguise"):
        var required_disguise = job.requirements.disguise
        if DisguiseManager.current_role != required_disguise:
            PromptNotificationSystem.show_warning(
                "wrong_uniform",
                "You need to be wearing %s to work this job." % required_disguise,
                "Wrong Uniform"
            )
            return false
    
    # Check other requirements
    if job.requirements.has("item"):
        if not InventoryManager.has_item(job.requirements.item):
            return false
    
    return true
```

### Time Management Integration

```gdscript
func _on_shift_time_expired(shift: ShiftData) -> void:
    # Auto-complete shift with penalties
    var uncompleted = 0
    for obj in shift.objectives:
        if not obj.completed:
            uncompleted += 1
    
    if uncompleted > 0:
        shift.performance_score *= 0.7  # 30% penalty
        
    complete_shift(shift)
    
    # Force player out of work mode
    PlayerController.set_working(false)
    
    # Remove forced disguise
    DisguiseManager.remove_forced_disguise()
```

### Crime System Integration

```gdscript
func handle_workplace_crime(crime_event: CrimeEvent) -> void:
    var current_shift = get_current_shift()
    if not current_shift:
        return
    
    # Different jobs handle crimes differently
    match current_shift.job_type:
        JobType.SECURITY_PATROL:
            # Must respond
            add_shift_objective("Respond to " + crime_event.type)
            current_shift.incidents.append({
                "type": "crime_response",
                "crime_id": crime_event.id,
                "mandatory": true
            })
        
        JobType.RETAIL_CLERK:
            if crime_event.type == CrimeType.THEFT:
                # Loss prevention duty
                add_shift_objective("Stop shoplifter")
                current_shift.performance_score *= 0.8  # Penalty if not stopped
        
        _:
            # Optional to report
            add_optional_objective("Report suspicious activity")
```

## Serialization

```gdscript
# src/core/serializers/job_system_serializer.gd
extends BaseSerializer

class_name JobSystemSerializer

func get_serializer_id() -> String:
    return "job_system"

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("job_system", self, 55)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "job_states": _serialize_all_jobs(),
        "shift_history": _serialize_shift_history(),
        "current_shift": _serialize_current_shift(),
        "lifetime_earnings": JobWorkQuestSystem.lifetime_earnings,
        "workplace_discoveries": JobWorkQuestSystem.workplace_discoveries
    }

func deserialize(data: Dictionary) -> void:
    if "job_states" in data:
        _deserialize_all_jobs(data.job_states)
    
    if "shift_history" in data:
        _deserialize_shift_history(data.shift_history)
    
    if "current_shift" in data:
        _deserialize_current_shift(data.current_shift)
    
    JobWorkQuestSystem.lifetime_earnings = data.get("lifetime_earnings", 0)
    JobWorkQuestSystem.workplace_discoveries = data.get("workplace_discoveries", [])

func _serialize_all_jobs() -> Dictionary:
    var serialized = {}
    
    for job_id in JobWorkQuestSystem.all_jobs:
        var job = JobWorkQuestSystem.get_job_data(job_id)
        serialized[job_id] = {
            "unlocked": job.unlocked,
            "reputation": job.reputation,
            "shifts_completed": job.shifts_completed,
            "last_shift_day": job.last_shift_day,
            "suspended": job.suspended,
            "suspension_until_day": job.suspension_until_day,
            "intro_quest_complete": job.intro_quest_complete
        }
    
    return serialized
```

## Special Job Mechanics

### Access Benefits
```gdscript
func get_job_access_benefits(job_id: String) -> Array:
    var benefits = []
    
    match job_id:
        "janitor":
            benefits.append("universal_station_access")
            benefits.append("maintenance_tunnel_access")
            benefits.append("after_hours_access")
        
        "security_patrol":
            benefits.append("security_area_access")
            benefits.append("camera_room_access")
            benefits.append("emergency_override_codes")
        
        "medical_courier":
            benefits.append("medical_ward_access")
            benefits.append("pharmacy_access")
            benefits.append("quarantine_zone_entry")
        
        "dock_worker":
            benefits.append("cargo_bay_access")
            benefits.append("shipping_manifest_access")
            benefits.append("customs_bypass")
    
    return benefits
```

### Performance Metrics Display
```gdscript
func show_job_stats_ui() -> void:
    var stats_text = "EMPLOYMENT RECORD\n\n"
    
    for job_id in all_jobs:
        var job = get_job_data(job_id)
        if not job.unlocked:
            continue
        
        stats_text += "%s\n" % job.quest_name
        stats_text += "  Status: %s\n" % _get_job_status(job)
        stats_text += "  Reputation: %d/100\n" % job.reputation
        stats_text += "  Shifts: %d\n" % job.shifts_completed
        stats_text += "  Earnings: %d credits\n\n" % job.total_earned
    
    stats_text += "Lifetime Earnings: %d credits\n" % lifetime_earnings
    stats_text += "Workplace Discoveries: %d clues\n" % workplace_discoveries.size()
    
    UI.show_job_stats(stats_text)
```

## Balancing Considerations

### Economic Balance
```gdscript
const DAILY_NEEDS = 15  # Credits for food/water
const SHIFT_EXHAUSTION = 0.3  # Can't work multiple jobs same day

# Job pay rates balanced around:
# - 2-3 days of work = 1 disguise
# - 1 day of work = 3-4 days survival
# - Can't grind infinitely due to time constraints
```

### Time Investment
- Jobs consume 3-4 hours (major time commitment)
- Forces player to balance income vs investigation
- Creates authentic working-class experience
- Shift timing may conflict with other opportunities

### Reputation Gates
- Poor performance locks out better variants
- Excellent performance unlocks special opportunities
- Suspension forces job diversity
- Reputation affects NPC trust

## Implementation Notes

The Job/Work Quest System creates:
1. **Economic gameplay loop** - Work to survive while investigating
2. **Access opportunities** - Jobs provide cover and access
3. **Discovery mechanics** - Find clues during routine work
4. **Social commentary** - Experience station life from worker perspective
5. **Time pressure** - Balance survival needs with investigation goals
6. **Narrative integration** - Jobs reveal different aspects of conspiracy

Each job provides unique benefits beyond income, encouraging players to try different employment paths and discover how the assimilation affects various sectors of station life. The GTA-inspired structure ensures jobs feel like mini-adventures rather than grinding, with each shift potentially revealing new clues or creating memorable incidents.