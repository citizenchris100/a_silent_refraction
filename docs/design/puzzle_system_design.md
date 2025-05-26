# Puzzle System Design

## Overview

The Puzzle System implements SCUMM-style adventure game puzzles within the space station setting, creating logical challenges that integrate naturally with the game's systems. Puzzles range from simple item combinations to complex multi-stage investigations, always respecting player time and providing multiple solution paths when possible. The system emphasizes real-world logic over "moon logic," ensuring solutions make sense within the station's environment.

## Core Concepts

### Puzzle Philosophy
- **Logical solutions**: Every puzzle has a solution that makes sense in-world
- **Multiple approaches**: Use items, social engineering, or system exploitation
- **Integrated challenges**: Puzzles use existing game systems naturally
- **Meaningful obstacles**: Each puzzle serves narrative or gameplay purpose
- **Fair difficulty**: Clear feedback on what's needed, no pixel hunting

### Puzzle Categories
1. **Access Puzzles**: Getting into restricted areas
2. **Investigation Puzzles**: Connecting clues to uncover truth
3. **Social Engineering**: Manipulating NPCs for information/access
4. **Technical Puzzles**: Hacking systems, repairing equipment
5. **Combination Puzzles**: Creating new items from existing ones
6. **Timing Puzzles**: Exploiting schedules and routines

## System Architecture

### Core Components

#### 1. Puzzle Manager (Singleton)
```gdscript
# src/core/systems/puzzle_manager.gd
extends Node

signal puzzle_started(puzzle_id)
signal puzzle_progressed(puzzle_id, step)
signal puzzle_solved(puzzle_id, solution_method)
signal puzzle_failed(puzzle_id, reason)
signal hint_revealed(puzzle_id, hint_level)

var active_puzzles: Dictionary = {}  # puzzle_id: PuzzleState
var solved_puzzles: Array = []
var failed_attempts: Dictionary = {}  # puzzle_id: attempt_count
var puzzle_hints: Dictionary = {}  # puzzle_id: hints_revealed

func register_puzzle(puzzle_data: PuzzleData):
    var state = PuzzleState.new()
    state.puzzle_data = puzzle_data
    state.current_step = 0
    state.time_started = TimeManager.current_time
    
    active_puzzles[puzzle_data.id] = state
    emit_signal("puzzle_started", puzzle_data.id)
    
    # Check if coalition has relevant info
    _check_coalition_intelligence(puzzle_data.id)

func attempt_solution(puzzle_id: String, solution: Dictionary) -> bool:
    if not puzzle_id in active_puzzles:
        return false
    
    var state = active_puzzles[puzzle_id]
    var puzzle = state.puzzle_data
    
    # Check solution validity
    var result = _validate_solution(puzzle, solution, state.current_step)
    
    if result.success:
        if state.current_step < puzzle.steps.size() - 1:
            # Multi-step puzzle, advance
            state.current_step += 1
            emit_signal("puzzle_progressed", puzzle_id, state.current_step)
            return true
        else:
            # Puzzle complete
            _complete_puzzle(puzzle_id, solution.method)
            return true
    else:
        # Failed attempt
        _handle_failed_attempt(puzzle_id, result.reason)
        return false

func _validate_solution(puzzle: PuzzleData, solution: Dictionary, step: int) -> Dictionary:
    var puzzle_step = puzzle.steps[step]
    
    # Check solution type
    match puzzle_step.solution_type:
        "item":
            return _validate_item_solution(puzzle_step, solution)
        "combination":
            return _validate_combination_solution(puzzle_step, solution)
        "dialog":
            return _validate_dialog_solution(puzzle_step, solution)
        "timing":
            return _validate_timing_solution(puzzle_step, solution)
        "technical":
            return _validate_technical_solution(puzzle_step, solution)
        _:
            return {"success": false, "reason": "unknown_solution_type"}

func _validate_item_solution(step: PuzzleStep, solution: Dictionary) -> Dictionary:
    var required_item = step.required_items[0]
    var provided_item = solution.get("item", "")
    
    if provided_item == required_item:
        return {"success": true}
    
    # Check for alternative items
    if provided_item in step.alternative_items:
        return {"success": true, "alternative": true}
    
    # Check if item could work but wrong context
    if ItemRegistry.get_item(provided_item).category == ItemRegistry.get_item(required_item).category:
        return {"success": false, "reason": "close_but_wrong", "hint": "Right idea, wrong item"}
    
    return {"success": false, "reason": "wrong_item"}

func _complete_puzzle(puzzle_id: String, method: String):
    var state = active_puzzles[puzzle_id]
    var puzzle = state.puzzle_data
    
    # Calculate completion time
    var time_taken = TimeManager.current_time - state.time_started
    
    # Award rewards
    if puzzle.credit_reward > 0:
        EconomyManager.add_credits(puzzle.credit_reward, "puzzle_" + puzzle_id)
    
    if puzzle.item_rewards.size() > 0:
        for item in puzzle.item_rewards:
            InventoryManager.add_item(item.id, item.quantity)
    
    # Update game state
    if puzzle.unlocks_area != "":
        AreaManager.unlock_area(puzzle.unlocks_area)
    
    if puzzle.reveals_intel != "":
        CoalitionManager.add_intelligence(puzzle.reveals_intel)
    
    # Track completion
    solved_puzzles.append(puzzle_id)
    active_puzzles.erase(puzzle_id)
    
    emit_signal("puzzle_solved", puzzle_id, method)
    
    # Check for chain puzzles
    if puzzle.triggers_puzzle != "":
        var next_puzzle = PuzzleRegistry.get_puzzle(puzzle.triggers_puzzle)
        register_puzzle(next_puzzle)

func _handle_failed_attempt(puzzle_id: String, reason: String):
    if not puzzle_id in failed_attempts:
        failed_attempts[puzzle_id] = 0
    
    failed_attempts[puzzle_id] += 1
    
    var state = active_puzzles[puzzle_id]
    var puzzle = state.puzzle_data
    
    # Apply failure consequences
    if puzzle.failure_increases_suspicion:
        var suspicion_amount = 10 * failed_attempts[puzzle_id]
        SuspicionManager.increase_global_suspicion(suspicion_amount, "failed_puzzle")
    
    if puzzle.failure_alerts_security and failed_attempts[puzzle_id] >= 3:
        SecuritySystem.trigger_alarm(puzzle.location)
    
    if puzzle.trap_puzzle and reason == "trap_triggered":
        DetectionManager.trigger_detection(
            puzzle.trap_npc,
            "puzzle_trap",
            0.8
        )
    
    emit_signal("puzzle_failed", puzzle_id, reason)
    
    # Offer hints after failures
    if failed_attempts[puzzle_id] >= 2:
        _offer_hint(puzzle_id, failed_attempts[puzzle_id] - 1)
```

#### 2. Puzzle Types Implementation

```gdscript
# src/core/puzzles/access_puzzle.gd
extends BasePuzzle

class_name AccessPuzzle

# Example: Getting into secured lab
func setup_lab_access():
    puzzle_data = {
        "id": "lab_access_alpha",
        "name": "Laboratory Alpha Access",
        "description": "Find a way into the secured laboratory",
        "location": "medical_district",
        "steps": [
            {
                "description": "Bypass security door",
                "solution_type": "multiple_choice",
                "solutions": [
                    {"method": "keycard", "item": "lab_keycard_alpha"},
                    {"method": "hack", "skill": "technical", "difficulty": 7},
                    {"method": "maintenance", "item": "maintenance_uniform", "npc": "maintenance_chief"},
                    {"method": "coalition", "required_members": ["scientist_patel", "tech_rodriguez"]}
                ]
            }
        ],
        "time_cost": 0.5,  # 30 minutes base
        "suspicion_risk": true,
        "unlocks_area": "laboratory_alpha"
    }

# src/core/puzzles/investigation_puzzle.gd  
extends BasePuzzle

class_name InvestigationPuzzle

# Example: Uncovering assimilation source
func setup_conspiracy_investigation():
    puzzle_data = {
        "id": "trace_assimilation_source",
        "name": "Trace the Source",
        "description": "Connect evidence to find assimilation origin",
        "steps": [
            {
                "description": "Gather shipping manifests",
                "solution_type": "evidence_collection",
                "required_evidence": ["manifest_01", "manifest_02", "manifest_03"],
                "locations": ["spaceport_office", "trading_floor", "security_records"]
            },
            {
                "description": "Cross-reference arrival times",
                "solution_type": "deduction",
                "clues": ["All infected districts received shipments from same vessel"],
                "correct_deduction": "USCSS_Theseus"
            },
            {
                "description": "Access ship records",
                "solution_type": "technical",
                "hack_target": "spaceport_database",
                "required_access": "admin",
                "reveals": "aether_corp_connection"
            }
        ],
        "reveals_intel": "assimilation_origin",
        "triggers_puzzle": "confront_patient_zero"
    }

# src/core/puzzles/social_engineering_puzzle.gd
extends BasePuzzle

class_name SocialEngineeringPuzzle

# Example: Getting past suspicious guard
func setup_guard_manipulation():
    puzzle_data = {
        "id": "distract_security_chief",
        "name": "Distract the Chief",
        "description": "Get the security chief away from his post",
        "npc": "security_chief_martinez",
        "steps": [
            {
                "description": "Create a distraction",
                "solution_type": "social",
                "approaches": [
                    {
                        "method": "emergency",
                        "requirement": "fake_emergency_call",
                        "suspicion": 20
                    },
                    {
                        "method": "personal",
                        "requirement": "know_about_family",
                        "dialog_tree": "family_emergency",
                        "suspicion": 5
                    },
                    {
                        "method": "authority",
                        "requirement": "security_uniform",
                        "rank": "lieutenant",
                        "suspicion": 10
                    }
                ]
            }
        ],
        "time_window": 300,  # 5 minutes while distracted
        "failure_alerts_security": true
    }
```

#### 3. Hint System
```gdscript
# src/core/systems/hint_system.gd
extends Node

class_name HintSystem

var hint_levels = {
    1: "subtle",    # Environmental clue highlighting
    2: "moderate",  # NPC dialog hints
    3: "direct",    # Clear direction
    4: "solution"   # Give away answer (costs credits)
}

func provide_hint(puzzle_id: String, hint_level: int):
    var puzzle = PuzzleManager.active_puzzles[puzzle_id]
    if not puzzle:
        return
    
    var hint_type = hint_levels.get(hint_level, "subtle")
    
    match hint_type:
        "subtle":
            _highlight_relevant_objects(puzzle)
        "moderate":
            _queue_npc_hint(puzzle)
        "direct":
            _show_explicit_hint(puzzle)
        "solution":
            if EconomyManager.spend_credits(100, "puzzle_hint"):
                _reveal_solution(puzzle)

func _highlight_relevant_objects(puzzle: PuzzleState):
    var step = puzzle.puzzle_data.steps[puzzle.current_step]
    
    # Subtle glow on relevant items
    for item_id in step.required_items:
        var item_nodes = get_tree().get_nodes_in_group("item_" + item_id)
        for node in item_nodes:
            node.add_highlight_effect(Color.yellow, 0.3)

func _queue_npc_hint(puzzle: PuzzleState):
    # Coalition members provide hints
    var helpful_npc = CoalitionManager.get_nearby_member()
    if helpful_npc:
        var hint_dialog = _generate_contextual_hint(puzzle)
        DialogManager.queue_ambient_dialog(helpful_npc, hint_dialog)

func _show_explicit_hint(puzzle: PuzzleState):
    var step = puzzle.puzzle_data.steps[puzzle.current_step]
    var hint_text = step.explicit_hint
    
    if hint_text == "":
        hint_text = _generate_explicit_hint(step)
    
    UI.show_hint_notification(hint_text, 10.0)
```

### Data Structures

#### Puzzle Data Resource
```gdscript
# src/resources/puzzle_data.gd
extends Resource

class_name PuzzleData

export var id: String = ""
export var name: String = ""
export var description: String = ""
export var category: String = "access"  # access, investigation, social, technical, combination, timing
export var location: String = ""  # Where puzzle exists
export var steps: Array = []  # Array of PuzzleStep

# Requirements
export var required_items: Array = []  # Items needed to start
export var required_knowledge: Array = []  # Intel/clues needed
export var time_cost: float = 0.5  # Base time in hours

# Consequences
export var failure_increases_suspicion: bool = false
export var failure_alerts_security: bool = false
export var trap_puzzle: bool = false
export var trap_npc: String = ""  # Assimilated NPC who set trap

# Rewards
export var credit_reward: int = 0
export var item_rewards: Array = []  # Array of {id, quantity}
export var unlocks_area: String = ""
export var reveals_intel: String = ""
export var triggers_puzzle: String = ""  # Chain puzzles

class PuzzleStep:
    var description: String = ""
    var solution_type: String = ""  # item, combination, dialog, timing, technical
    var required_items: Array = []
    var alternative_items: Array = []  # Other valid solutions
    var required_skills: Dictionary = {}  # skill: level
    var time_limit: float = 0.0  # 0 = no limit
    var explicit_hint: String = ""
    var solution_method: String = ""  # For tracking how solved
```

### Integration Systems

#### Time Management Integration
```gdscript
# Puzzle solving consumes time
func calculate_puzzle_time(puzzle: PuzzleData, method: String) -> float:
    var base_time = puzzle.time_cost
    
    # Modify by solution method
    match method:
        "brute_force":
            base_time *= 2.0  # Takes longer
        "coalition_help":
            base_time *= 0.7  # Faster with help
        "perfect_solution":
            base_time *= 0.5  # Optimal approach
    
    # Modify by player skills
    if puzzle.category == "technical":
        var tech_skill = PlayerStats.get_skill("technical")
        base_time *= (1.0 - tech_skill * 0.1)  # Up to 50% faster
    
    return base_time

# Some puzzles have real-time elements
func start_timed_puzzle(puzzle_id: String):
    var puzzle = active_puzzles[puzzle_id]
    var time_limit = puzzle.puzzle_data.steps[puzzle.current_step].time_limit
    
    if time_limit > 0:
        TimeManager.start_countdown(time_limit, self, "_on_puzzle_timeout", puzzle_id)
        UI.show_countdown_timer(time_limit)
```

#### Inventory Integration
```gdscript
# Complex item combination puzzles
func create_combination_puzzle():
    return {
        "id": "create_explosive",
        "name": "Improvised Explosive",
        "description": "Create a distraction device",
        "solution_type": "combination",
        "recipe": {
            "ingredients": ["cleaning_chemicals", "electronics_scrap", "timer_device"],
            "tool_required": "maintenance_toolkit",
            "location_required": "maintenance_workshop"
        },
        "result": "improvised_explosive",
        "fail_result": "useless_mess",
        "suspicion_on_failure": 30
    }

# Inventory puzzles respect slot limits
func check_puzzle_inventory_requirements(puzzle_id: String) -> bool:
    var puzzle = PuzzleRegistry.get_puzzle(puzzle_id)
    var required_slots = puzzle.required_items.size()
    
    if InventoryManager.get_free_personal_slots() < required_slots:
        UI.show_notification("Need %d free inventory slots" % required_slots)
        return false
    
    return true
```

#### Coalition Integration
```gdscript
# Coalition members assist with puzzles
func get_coalition_puzzle_help(puzzle_id: String) -> Dictionary:
    var puzzle = active_puzzles[puzzle_id]
    var help_available = {}
    
    # Check member expertise
    for member_id in CoalitionManager.members:
        var member = NPCRegistry.get_npc(member_id)
        var expertise = member.puzzle_expertise
        
        if expertise.has(puzzle.puzzle_data.category):
            help_available[member_id] = {
                "type": "skill_boost",
                "value": expertise[puzzle.puzzle_data.category]
            }
        
        # Some members know solutions
        if member.known_solutions.has(puzzle_id):
            help_available[member_id] = {
                "type": "direct_solution",
                "trust_required": 80
            }
    
    return help_available

# Coalition intel reveals puzzle clues
func check_coalition_intelligence(puzzle_id: String):
    var intel = CoalitionManager.get_network_intelligence()
    var puzzle = PuzzleRegistry.get_puzzle(puzzle_id)
    
    for clue in puzzle.required_knowledge:
        if clue in intel.discovered_intel:
            # Auto-complete investigation steps
            var state = active_puzzles[puzzle_id]
            state.known_clues.append(clue)
            UI.show_notification("Coalition intel reveals: " + clue)
```

#### Suspicion Integration
```gdscript
# Failed puzzles increase suspicion
func apply_puzzle_suspicion(puzzle_id: String, reason: String):
    var puzzle = active_puzzles[puzzle_id].puzzle_data
    var base_suspicion = 10
    
    # Modify by failure type
    match reason:
        "wrong_keycard":
            base_suspicion = 5  # Minor mistake
        "failed_hack":
            base_suspicion = 20  # Triggers alarms
        "caught_sneaking":
            base_suspicion = 30  # Direct observation
        "trap_triggered":
            base_suspicion = 50  # Fell for assimilated trap
    
    # Apply to nearby NPCs
    var nearby = NPCManager.get_npcs_in_radius(player.position, 500)
    for npc in nearby:
        npc.increase_suspicion(base_suspicion * 0.5)
    
    # Global suspicion increase
    SuspicionManager.increase_global_suspicion(base_suspicion * 0.2)
```

## MVP Implementation

### Basic Puzzle Set

1. **Keycard Puzzles**
   - Find keycards to access areas
   - Copy keycards using scanner
   - Combine partial codes

2. **Password Puzzles**
   - Gather password hints from environment
   - Social engineering for codes
   - Brute force with consequences

3. **Item Combination**
   - Soap + Guard = Knockout solution
   - Wire + Panel = Bypass
   - Evidence + Evidence = Deduction

4. **Timing Puzzles**
   - Wait for guard patrols
   - Exploit shift changes
   - Race against detection

### MVP Examples

```gdscript
# Simple keycard puzzle
{
    "id": "security_door_1",
    "name": "Security Door Access",
    "steps": [{
        "solution_type": "item",
        "required_items": ["security_keycard_1"],
        "alternative_items": ["master_keycard", "copied_keycard_1"]
    }],
    "unlocks_area": "security_backroom"
}

# Basic investigation
{
    "id": "find_meeting_location",
    "name": "Secret Meeting",
    "steps": [
        {
            "solution_type": "evidence_collection",
            "required_evidence": ["note_fragment_1", "note_fragment_2"],
            "reveals": "meeting_location"
        }
    ],
    "triggers_puzzle": "infiltrate_meeting"
}

# Social engineering
{
    "id": "get_past_receptionist",
    "name": "Convince the Receptionist",
    "steps": [{
        "solution_type": "dialog",
        "correct_choices": ["maintenance_excuse", "name_drop_supervisor"],
        "failure_increases_suspicion": true
    }]
}
```

## Full Implementation

### Advanced Features

#### 1. Multi-Stage Investigations
```gdscript
# Complex investigation spanning districts
{
    "id": "uncover_conspiracy",
    "name": "The Aether Conspiracy",
    "category": "investigation",
    "steps": [
        {
            "name": "Initial Discovery",
            "description": "Find shipping anomalies",
            "solution_type": "evidence_collection",
            "required_evidence": ["manifest_discrepancy", "timeline_oddity", "witness_report"],
            "locations": ["spaceport", "trading_floor", "security"],
            "time_cost": 2.0
        },
        {
            "name": "Connect the Dots",
            "description": "Link evidence to corporation",
            "solution_type": "deduction",
            "evidence_board": true,
            "connections_needed": [
                {"from": "manifest_discrepancy", "to": "aether_corp_stamp"},
                {"from": "timeline_oddity", "to": "patient_zero_arrival"},
                {"from": "witness_report", "to": "suspicious_cargo"}
            ],
            "reveals": "aether_corp_involved"
        },
        {
            "name": "Find Patient Zero",
            "description": "Identify first infected",
            "solution_type": "investigation",
            "search_parameters": {
                "arrival_date": "day_0",
                "ship": "USCSS_Theseus",
                "cargo": "biological_samples"
            },
            "requires_access": ["medical_records", "spaceport_database"],
            "reveals": "patient_zero_identity"
        },
        {
            "name": "Confront the Truth",
            "description": "Face patient zero",
            "solution_type": "confrontation",
            "npc": "patient_zero",
            "dialog_challenge": true,
            "combat_possible": false,
            "reveals": "full_conspiracy"
        }
    ],
    "credit_reward": 5000,
    "reveals_intel": "conspiracy_full_scope",
    "affects_ending": true
}
```

#### 2. Environmental Puzzles
```gdscript
# Use station systems creatively
class EnvironmentalPuzzle:
    func create_vent_puzzle():
        return {
            "id": "vent_infiltration",
            "name": "Through the Vents",
            "description": "Use maintenance shafts to bypass security",
            "requirements": {
                "items": ["screwdriver", "vent_map"],
                "size": "small",  # Can't carry much
                "skills": {"agility": 5}
            },
            "path_choices": [
                {
                    "route": "direct",
                    "risk": "high",
                    "time": 0.5,
                    "detection_chance": 0.6
                },
                {
                    "route": "circuitous", 
                    "risk": "low",
                    "time": 1.5,
                    "detection_chance": 0.1
                }
            ],
            "environmental_hazards": ["steam_jets", "fan_blades", "security_sensors"]
        }
    
    func create_power_puzzle():
        return {
            "id": "reroute_power",
            "name": "Power Distribution",
            "description": "Manipulate station power to open emergency exits",
            "interface": "power_grid_terminal",
            "solution_type": "technical",
            "grid_configuration": {
                "nodes": 12,
                "connections": 18,
                "power_sources": 3,
                "required_output": {"emergency_doors": 500, "life_support": 1000}
            },
            "failure_consequence": "section_blackout",
            "time_limit": 300  # 5 minutes before backup kicks in
        }
```

#### 3. Trap Puzzles
```gdscript
# Assimilated set traps
class TrapPuzzle:
    func create_false_coalition_meeting():
        return {
            "id": "trap_fake_meeting",
            "name": "Coalition Meeting",
            "description": "Urgent meeting called by coalition member",
            "trap_puzzle": true,
            "trap_npc": "assimilated_jenkins",
            "warning_signs": [
                "meeting_location_unusual",  # Isolated area
                "member_behavior_off",        # Speech patterns wrong
                "timing_suspicious"           # During shift change
            ],
            "trap_trigger": {
                "condition": "enter_meeting_room",
                "result": "ambush",
                "assimilated_present": ["jenkins", "martinez", "chen"],
                "escape_possible": true,
                "escape_requirements": ["smoke_bomb", "sprint_ability", "coalition_backup"]
            },
            "avoiding_trap": {
                "method_1": "verify_caller",  # Check with coalition
                "method_2": "send_someone_else",  # Use coalition member
                "method_3": "surveillance_first"  # Scout location
            }
        }
```

#### 4. Dynamic Puzzle Generation
```gdscript
# Puzzles adapt to player actions
class DynamicPuzzleGenerator:
    func generate_access_puzzle(area: String, player_resources: Dictionary):
        var puzzle = PuzzleData.new()
        puzzle.id = "dynamic_" + area + "_" + str(OS.get_ticks_msec())
        puzzle.location = area
        
        var solutions = []
        
        # Add item solution if player has relevant items
        if player_resources.has_keycard:
            solutions.append({
                "method": "keycard",
                "item": _find_matching_keycard(area)
            })
        
        # Add hack solution based on skills
        if player_resources.tech_skill > 5:
            solutions.append({
                "method": "hack",
                "difficulty": _calculate_hack_difficulty(area)
            })
        
        # Add social solution if relevant NPC nearby
        var nearby_npc = _find_authority_npc(area)
        if nearby_npc:
            solutions.append({
                "method": "social",
                "npc": nearby_npc,
                "requirement": "build_trust"
            })
        
        # Always add coalition solution
        solutions.append({
            "method": "coalition",
            "members_needed": _calculate_coalition_requirement(area)
        })
        
        puzzle.steps[0].solutions = solutions
        return puzzle
```

### Puzzle Chain System
```gdscript
# Puzzles that lead to more puzzles
class PuzzleChain:
    var chains = {
        "investigation_main": [
            "find_initial_clue",
            "trace_shipment",
            "access_records",
            "identify_patient_zero",
            "uncover_conspiracy",
            "stop_transmission"
        ],
        "district_liberation": [
            "identify_leader",
            "gather_evidence",
            "expose_leader",
            "rally_district",
            "secure_district"
        ]
    }
    
    func advance_chain(chain_id: String, completed_puzzle: String):
        var chain = chains[chain_id]
        var current_index = chain.find(completed_puzzle)
        
        if current_index >= 0 and current_index < chain.size() - 1:
            var next_puzzle_id = chain[current_index + 1]
            
            # Unlock with context from previous
            var context = _build_context_from_previous(completed_puzzle)
            PuzzleManager.unlock_puzzle(next_puzzle_id, context)
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/puzzle_serializer.gd
extends BaseSerializer

class_name PuzzleSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("puzzles", self, 45)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    var data = {
        "active": _serialize_active_puzzles(),
        "solved": PuzzleManager.solved_puzzles,
        "failed_attempts": PuzzleManager.failed_attempts,
        "hints_revealed": PuzzleManager.puzzle_hints,
        "chains": _serialize_puzzle_chains(),
        "dynamic": _serialize_dynamic_puzzles()
    }
    
    return data

func _serialize_active_puzzles() -> Dictionary:
    var active = {}
    
    for puzzle_id in PuzzleManager.active_puzzles:
        var state = PuzzleManager.active_puzzles[puzzle_id]
        active[puzzle_id] = {
            "step": state.current_step,
            "time_started": state.time_started - TimeManager.game_start_time,
            "clues_found": state.known_clues,
            "attempts": state.attempt_count,
            "method": state.current_method
        }
    
    return active

func deserialize(data: Dictionary) -> void:
    # Restore solved puzzles
    PuzzleManager.solved_puzzles = data.get("solved", [])
    PuzzleManager.failed_attempts = data.get("failed_attempts", {})
    PuzzleManager.puzzle_hints = data.get("hints_revealed", {})
    
    # Restore active puzzles
    var active = data.get("active", {})
    for puzzle_id in active:
        var puzzle_data = PuzzleRegistry.get_puzzle(puzzle_id)
        if puzzle_data:
            PuzzleManager.register_puzzle(puzzle_data)
            
            var state = PuzzleManager.active_puzzles[puzzle_id]
            var saved_state = active[puzzle_id]
            
            state.current_step = saved_state.get("step", 0)
            state.time_started = TimeManager.game_start_time + saved_state.get("time_started", 0)
            state.known_clues = saved_state.get("clues_found", [])
            state.attempt_count = saved_state.get("attempts", 0)
            state.current_method = saved_state.get("method", "")
    
    # Restore chains and dynamic puzzles
    _deserialize_puzzle_chains(data.get("chains", {}))
    _deserialize_dynamic_puzzles(data.get("dynamic", []))
```

## UI Components

### Puzzle Interface
```gdscript
# src/ui/puzzles/puzzle_interface.gd
extends Control

onready var puzzle_name = $PuzzleName
onready var description = $Description
onready var progress_bar = $ProgressBar
onready var hint_button = $HintButton
onready var inventory_grid = $InventoryGrid

func show_puzzle(puzzle_id: String):
    var puzzle = PuzzleManager.active_puzzles[puzzle_id]
    if not puzzle:
        return
    
    puzzle_name.text = puzzle.puzzle_data.name
    description.text = _get_current_step_description(puzzle)
    
    if puzzle.puzzle_data.steps.size() > 1:
        progress_bar.max_value = puzzle.puzzle_data.steps.size()
        progress_bar.value = puzzle.current_step + 1
        progress_bar.show()
    else:
        progress_bar.hide()
    
    # Show relevant inventory items
    if puzzle.puzzle_data.category in ["item", "combination"]:
        inventory_grid.show()
        inventory_grid.filter_relevant_items(puzzle)
    
    show()
```

### Investigation Board
```gdscript
# src/ui/puzzles/investigation_board.gd
extends Control

onready var evidence_grid = $EvidenceGrid
onready var connection_lines = $ConnectionLines
onready var deduction_panel = $DeductionPanel

func setup_investigation(puzzle_id: String):
    var puzzle = PuzzleManager.active_puzzles[puzzle_id]
    
    # Place evidence pieces
    for evidence in puzzle.known_clues:
        var piece = EVIDENCE_PIECE.instance()
        piece.setup(evidence)
        evidence_grid.add_child(piece)
        piece.connect("selected", self, "_on_evidence_selected")
    
    # Allow drawing connections
    connection_lines.enable_drawing = true
    
    # Show deduction options
    _populate_deductions(puzzle)
```

## Balance Considerations

### Puzzle Difficulty Curve
- **Tutorial**: Single-step puzzles with obvious solutions
- **Early Game**: 2-3 step puzzles with multiple solutions
- **Mid Game**: Complex puzzles requiring preparation
- **Late Game**: Multi-district investigation chains
- **Optional**: Extreme puzzles for completionists

### Time Investment
- **Quick Puzzles**: 15-30 minutes (0.25-0.5 hours game time)
- **Standard Puzzles**: 30-60 minutes (0.5-1 hour)
- **Complex Puzzles**: 1-2 hours
- **Investigation Chains**: 3-5 hours total

### Failure Consequences
- **Minor**: 5-10 suspicion increase
- **Moderate**: 20-30 suspicion, failed attempts logged
- **Major**: 50+ suspicion, security alerted
- **Critical**: Detection sequence triggered

### Resource Requirements
- **Basic**: 1-2 common items
- **Intermediate**: 3-4 items or coalition help
- **Advanced**: Rare items, high skills, or major coalition support
- **Expert**: Multiple rare resources and perfect execution

## Testing Considerations

1. **Solution Validation**
   - All intended solutions work
   - Alternative solutions properly recognized
   - No unintended solutions possible
   - Clear feedback on why solutions fail

2. **Integration Testing**
   - Time consumption accurate
   - Suspicion increases appropriately
   - Coalition help functions correctly
   - Inventory requirements checked

3. **Trap Testing**
   - Warning signs visible to attentive players
   - Escape routes function properly
   - Detection triggers appropriately
   - Coalition warnings work

4. **Chain Testing**
   - Puzzles unlock in correct sequence
   - Context carries between puzzles
   - No soft-locks in chains
   - Progress saves correctly

## Template Compliance

### Interactive Object Template Integration
Puzzle elements follow `template_interactive_object_design.md`:
- All puzzle components are interactive objects
- Support full verb interactions (USE, EXAMINE, COMBINE, etc.)
- State machines track puzzle progress
- Visual/audio feedback for state changes
- Proper save/load support for puzzle states

### Quest Template Integration
Puzzle sequences follow `template_quest_design.md`:
- Puzzles integrated as quest objectives
- Multi-part puzzles use quest part structure
- Optional puzzle objectives for alternative solutions
- Time-sensitive puzzles use quest deadlines
- Puzzle hints delivered through quest system

This system creates engaging puzzles that leverage all game systems while maintaining logical, space station-appropriate solutions that respect player intelligence and time.