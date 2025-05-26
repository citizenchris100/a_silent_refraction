# Coalition/Resistance System Design

## Overview

The Coalition/Resistance System is the player's primary tool for fighting the assimilation conspiracy. Players discover an existing resistance group early in the game and must carefully identify, verify, and recruit unassimilated NPCs while avoiding detection by the assimilated. The system creates a growing network effect where successful recruitment accelerates future efforts through shared intelligence and resources.

## Core Concepts

### Network Effects
- **Intelligence multiplication**: Each coalition member provides information about other NPCs
- **Resource pooling**: Shared credits, items, and safe locations
- **Time efficiency**: Coalition tips save investigation time and reduce risk
- **Collective action**: Larger coalition enables bigger operations

### Trust & Verification
- **No direct questioning**: Can't ask "are you assimilated?" without raising suspicion
- **Quest-based trust**: Complete NPC-specific challenges to earn recruitment
- **Verification through action**: NPCs prove themselves through behavior
- **Infiltration risk**: Wrong recruitment can compromise entire coalition

### Power Dynamics
- **Coalition strength vs assimilation spread**: Visible struggle for station control
- **Tipping points**: Major events triggered by power balance shifts
- **Endgame paths**: Coalition strength determines available endings
- **Daily erosion**: Constant pressure as NPCs get assimilated

## System Architecture

### Core Components

#### 1. Coalition Manager (Singleton)
```gdscript
# src/core/systems/coalition_manager.gd
extends Node

signal member_recruited(npc_id)
signal member_compromised(npc_id)
signal intelligence_received(intel_type, data)
signal coalition_strength_changed(new_strength)
signal heist_unlocked(heist_id)

# Coalition state
var members: Array = []  # Array of member NPCs
var verified_unassimilated: Array = []  # NPCs confirmed safe by network
var suspected_assimilated: Array = []  # NPCs flagged as suspicious
var compromised_members: Array = []  # Infiltrators discovered
var coalition_strength: float = 0.0  # 0-100 power rating

# Resources
var shared_credits: int = 0
var shared_items: Dictionary = {}  # item_id: quantity
var safe_houses: Dictionary = {}  # district: location_id

# Intel network
var intelligence_reports: Array = []
var active_surveillance: Dictionary = {}  # npc_id: watcher_id

func recruit_member(npc_id: String) -> bool:
    var npc_data = NPCRegistry.get_npc(npc_id)
    if not npc_data:
        return false
    
    # Check if actually assimilated (infiltration attempt)
    if AssimilationManager.is_assimilated(npc_id):
        _handle_infiltration_attempt(npc_id)
        return false
    
    # Add to coalition
    members.append(npc_id)
    npc_data.coalition_member = true
    
    # Gain their intelligence
    _process_new_member_intel(npc_id)
    
    # Update coalition strength
    _recalculate_strength()
    
    emit_signal("member_recruited", npc_id)
    
    # Check for heist opportunities
    _check_heist_requirements()
    
    return true

func _process_new_member_intel(npc_id: String):
    var npc_data = NPCRegistry.get_npc(npc_id)
    
    # Each NPC knows about others in their district/profession
    var intel_npcs = _get_npc_intel_network(npc_data)
    
    for target_id in intel_npcs:
        if not target_id in verified_unassimilated + suspected_assimilated:
            # New intelligence!
            var intel = _gather_intel_on_npc(target_id, npc_id)
            
            if intel.verified_safe:
                verified_unassimilated.append(target_id)
                emit_signal("intelligence_received", "verified_safe", {
                    "npc_id": target_id,
                    "source": npc_id,
                    "confidence": intel.confidence
                })
            elif intel.suspected:
                suspected_assimilated.append(target_id)
                emit_signal("intelligence_received", "suspected", {
                    "npc_id": target_id,
                    "source": npc_id,
                    "reason": intel.reason
                })

func get_network_intelligence() -> Dictionary:
    return {
        "verified_safe": verified_unassimilated,
        "suspected": suspected_assimilated,
        "safe_houses": safe_houses,
        "surveillance": active_surveillance
    }

func contribute_resources(credits: int = 0, items: Dictionary = {}):
    shared_credits += credits
    
    for item_id in items:
        if item_id in shared_items:
            shared_items[item_id] += items[item_id]
        else:
            shared_items[item_id] = items[item_id]

func request_resources(credits: int = 0, item_id: String = "") -> bool:
    if credits > 0 and shared_credits >= credits:
        shared_credits -= credits
        EconomyManager.add_credits(credits, "coalition_fund")
        return true
    
    if item_id != "" and item_id in shared_items:
        if shared_items[item_id] > 0:
            shared_items[item_id] -= 1
            InventoryManager.add_item(item_id, 1)
            return true
    
    return false
```

#### 2. Heist Mission System
```gdscript
# src/core/systems/heist_system.gd
extends Node

class_name HeistSystem

signal heist_started(heist_id)
signal heist_completed(heist_id, success)
signal heist_failed(heist_id, reason)

var available_heists: Array = []
var completed_heists: Array = []
var active_heist: HeistData = null

func check_heist_availability():
    # Check coalition composition for special heists
    var has_security = _coalition_has_role("security")
    var has_maintenance = _coalition_has_role("maintenance")
    var has_medical = _coalition_has_role("medical")
    var has_trader = _coalition_has_role("trader")
    
    # Security + Maintenance = Can disable surveillance
    if has_security and has_maintenance and not "surveillance_heist" in completed_heists:
        _unlock_heist("surveillance_heist")
    
    # Medical + Trader = Can steal medical supplies
    if has_medical and has_trader and not "medical_heist" in completed_heists:
        _unlock_heist("medical_heist")
    
    # Large coalition = Major operations
    if CoalitionManager.members.size() >= 10 and not "mainframe_heist" in completed_heists:
        _unlock_heist("mainframe_heist")

func start_heist(heist_id: String) -> bool:
    if active_heist:
        return false
    
    var heist_data = HeistRegistry.get_heist(heist_id)
    if not heist_data:
        return false
    
    # Check requirements
    if not _validate_heist_requirements(heist_data):
        return false
    
    # Assign roles to coalition members
    var team = _assemble_heist_team(heist_data)
    if team.size() < heist_data.min_team_size:
        return false
    
    active_heist = heist_data
    active_heist.team = team
    active_heist.start_time = TimeManager.current_time
    
    # Begin heist phases
    _start_heist_phase(0)
    
    emit_signal("heist_started", heist_id)
    return true

func _execute_heist_phase(phase_index: int):
    var phase = active_heist.phases[phase_index]
    
    # Each phase has skill checks
    for role in phase.required_roles:
        var member = _get_team_member_for_role(role)
        if not member:
            _fail_heist("Missing required role: " + role)
            return
        
        # Skill check
        var success = _perform_skill_check(member, phase.difficulty)
        if not success:
            _fail_heist("Failed skill check: " + role)
            return
    
    # Phase succeeded
    if phase_index < active_heist.phases.size() - 1:
        # Next phase
        _start_heist_phase(phase_index + 1)
    else:
        # Heist complete!
        _complete_heist()
```

#### 3. Trust Building System
```gdscript
# src/core/systems/trust_system.gd
extends Node

class_name TrustSystem

# Trust levels required for different actions
const TRUST_LISTEN = 10      # Will hear you out
const TRUST_BELIEVE = 30     # Believes in assimilation threat  
const TRUST_CONSIDER = 50    # Will consider joining
const TRUST_JOIN = 70        # Will join coalition
const TRUST_COMMIT = 90      # Will risk everything

var npc_trust_levels: Dictionary = {}  # npc_id: trust_value

func get_trust(npc_id: String) -> int:
    if npc_id in npc_trust_levels:
        return npc_trust_levels[npc_id]
    return 0

func add_trust(npc_id: String, amount: int, reason: String = ""):
    var current = get_trust(npc_id)
    var new_trust = clamp(current + amount, 0, 100)
    npc_trust_levels[npc_id] = new_trust
    
    # Check trust thresholds
    if current < TRUST_BELIEVE and new_trust >= TRUST_BELIEVE:
        DialogManager.unlock_dialog_branch(npc_id, "believes_threat")
    
    if current < TRUST_CONSIDER and new_trust >= TRUST_CONSIDER:
        DialogManager.unlock_dialog_branch(npc_id, "consider_joining")
    
    if current < TRUST_JOIN and new_trust >= TRUST_JOIN:
        QuestManager.unlock_quest(npc_id + "_recruitment")

func check_recruitment_ready(npc_id: String) -> bool:
    return get_trust(npc_id) >= TRUST_JOIN

# Different NPCs require different approaches
func get_trust_building_method(npc_id: String) -> String:
    var npc_data = NPCRegistry.get_npc(npc_id)
    
    match npc_data.personality_type:
        "skeptical":
            return "evidence"  # Need hard proof
        "pragmatic":
            return "mutual_benefit"  # Show what's in it for them
        "idealistic":
            return "moral_appeal"  # Appeal to greater good
        "fearful":
            return "protection"  # Offer safety
        _:
            return "standard"
```

### Data Structures

#### Coalition Member Data
```gdscript
# Extension to NPC data
extends "res://src/data/npc_data.gd"

# Coalition-specific data
export var coalition_member: bool = false
export var recruitment_quest: String = ""  # Quest ID to recruit
export var trust_level: int = 0
export var known_associates: Array = []  # NPCs they can vouch for
export var special_role: String = ""  # security, medical, tech, etc.
export var recruitment_difficulty: int = 1  # 1-5 scale
```

#### Heist Data
```gdscript
# src/resources/heist_data.gd
extends Resource

class_name HeistData

export var id: String = ""
export var name: String = ""
export var description: String = ""
export var min_team_size: int = 3
export var required_roles: Array = []  # ["security", "tech", "muscle"]
export var phases: Array = []  # Array of HeistPhase

# Rewards
export var credit_reward: int = 1000
export var item_rewards: Array = []
export var intel_rewards: Array = []
export var reputation_gain: int = 20

# Risks
export var suspicion_increase: int = 30
export var failure_consequences: String = ""

class HeistPhase:
    var name: String = ""
    var description: String = ""
    var required_roles: Array = []
    var difficulty: int = 5  # 1-10
    var time_cost: int = 2  # Hours
    var failure_suspicion: int = 10
```

## MVP Implementation

### Basic Features

1. **Simple Coalition Tracking**
   - List of recruited members
   - Basic trust system (0-100)
   - Member count affects assimilation rate

2. **Basic Intelligence Network**
   - Each member reveals 1-2 verified safe NPCs
   - Simple "acting strange" reports
   - No complex surveillance

3. **Resource Sharing**
   - Shared credit pool
   - Emergency supplies available
   - One safe house per major district

4. **Recruitment Quests**
   - 10-15 NPCs with recruitment quests
   - Simple fetch/solve/prove quests
   - Basic trust thresholds

5. **Coalition Meetings**
   - Weekly meetings at HQ
   - Share intelligence
   - Plan next moves

### MVP Recruitment Examples

```gdscript
# Skeptical Scientist
{
    "npc_id": "scientist_mary",
    "recruitment_method": "evidence",
    "quest": "Find proof of assimilation",
    "trust_required": 70,
    "knows_about": ["scientist_john", "lab_tech_sarah"]
}

# Pragmatic Merchant  
{
    "npc_id": "merchant_chang",
    "recruitment_method": "mutual_benefit",
    "quest": "Protect shop from drone vandalism",
    "trust_required": 60,
    "knows_about": ["merchant_kim", "cashier_alex", "supplier_jones"]
}

# Idealistic Doctor
{
    "npc_id": "doctor_patel",
    "recruitment_method": "moral_appeal",
    "quest": "Help treat injured civilians",
    "trust_required": 50,
    "knows_about": ["nurse_williams", "paramedic_garcia"]
}
```

## Full Implementation

### Advanced Features

#### 1. Infiltration & Betrayal System
```gdscript
func _handle_infiltration_attempt(infiltrator_id: String):
    # Assimilated NPC successfully recruited - disaster!
    compromised_members.append(infiltrator_id)
    
    # Immediate consequences
    var damage = {
        "members_exposed": [],
        "resources_stolen": 0,
        "safe_houses_compromised": []
    }
    
    # Infiltrator exposes other members
    for member_id in members:
        if randf() < 0.3:  # 30% chance each member exposed
            damage.members_exposed.append(member_id)
            SuspicionManager.add_suspicion_to_npc(member_id, 50)
    
    # Steal resources
    damage.resources_stolen = int(shared_credits * 0.4)
    shared_credits = int(shared_credits * 0.6)
    
    # Compromise safe houses
    for district in safe_houses:
        if randf() < 0.5:  # 50% chance each location burned
            damage.safe_houses_compromised.append(district)
            safe_houses.erase(district)
    
    # Trigger paranoia event
    EventManager.trigger_event("coalition_infiltrated", damage)
    
    # Now coalition is paranoid - new verification requirements
    for member_id in members:
        if not member_id in damage.members_exposed:
            var member_data = NPCRegistry.get_npc(member_id)
            member_data.paranoia_level = min(member_data.paranoia_level + 30, 100)
```

#### 2. Ocean's 11 Style Heists

**Example: Mainframe Heist**
```gdscript
{
    "id": "mainframe_heist",
    "name": "Operation Silent Key",
    "description": "Infiltrate central mainframe to discover assimilation source",
    "min_team_size": 6,
    "required_roles": ["hacker", "security", "maintenance", "lookout", "muscle", "face"],
    "phases": [
        {
            "name": "Infiltration",
            "description": "Maintenance creates access, Security disables alarms",
            "required_roles": ["maintenance", "security"],
            "difficulty": 6,
            "time_cost": 2
        },
        {
            "name": "Distraction",
            "description": "Face creates diversion, Muscle handles complications",
            "required_roles": ["face", "muscle"],
            "difficulty": 7,
            "time_cost": 1
        },
        {
            "name": "Data Extraction",
            "description": "Hacker accesses mainframe while Lookout watches",
            "required_roles": ["hacker", "lookout"],
            "difficulty": 8,
            "time_cost": 3
        },
        {
            "name": "Escape",
            "description": "All members coordinate escape routes",
            "required_roles": ["all"],
            "difficulty": 9,
            "time_cost": 1
        }
    ],
    "credit_reward": 5000,
    "intel_rewards": ["assimilation_source", "leader_identities", "corporate_connection"],
    "failure_consequences": "mass_arrests"
}
```

#### 3. Dynamic Power Struggle
```gdscript
func calculate_power_balance() -> Dictionary:
    var coalition_power = 0.0
    var assimilation_power = 0.0
    
    # Coalition factors
    coalition_power += members.size() * 2.0
    coalition_power += completed_heists.size() * 10.0
    coalition_power += shared_credits / 1000.0
    
    # Special role bonuses
    if _coalition_has_role("security_chief"):
        coalition_power += 15.0
    if _coalition_has_role("dock_foreman"):
        coalition_power += 10.0
    
    # Assimilation factors
    assimilation_power += AssimilationManager.get_assimilated_count() * 1.5
    assimilation_power += AssimilationManager.leader_npcs.size() * 20.0
    assimilation_power += AssimilationManager.get_economic_corruption_factor() * 50.0
    
    return {
        "coalition": coalition_power,
        "assimilation": assimilation_power,
        "balance": coalition_power - assimilation_power
    }
```

#### 4. Intelligence Operations
```gdscript
# Surveillance missions
func assign_surveillance(watcher_id: String, target_id: String) -> bool:
    if not watcher_id in members:
        return false
    
    # Remove from other duties
    if watcher_id in active_surveillance.values():
        _remove_from_surveillance(watcher_id)
    
    active_surveillance[target_id] = watcher_id
    
    # Schedule reports
    TimeManager.schedule_recurring_event(
        8,  # Every 8 hours
        self,
        "_surveillance_report",
        {"watcher": watcher_id, "target": target_id}
    )
    
    return true

func _surveillance_report(data: Dictionary):
    var target = NPCRegistry.get_npc(data.target)
    var watcher = NPCRegistry.get_npc(data.watcher)
    
    # Check if surveillance blown
    if randf() < 0.1:  # 10% chance
        SuspicionManager.add_suspicion_to_npc(data.watcher, 20)
        _remove_from_surveillance(data.watcher)
        return
    
    # Gather intelligence
    var report = {
        "target": data.target,
        "time": TimeManager.current_time,
        "observations": []
    }
    
    # Check for assimilation signs
    if AssimilationManager.is_assimilated(data.target):
        report.observations.append("unusual_behavior")
        report.observations.append("secret_meetings")
        
        # Chance to discover other assimilated
        if randf() < 0.3:
            var contact = AssimilationManager.get_random_assimilated_contact(data.target)
            if contact:
                report.observations.append("suspicious_contact:" + contact)
    
    intelligence_reports.append(report)
    emit_signal("intelligence_received", "surveillance", report)
```

### Integration Systems

#### Time Management Integration
```gdscript
# Coalition activities consume time
func attend_coalition_meeting() -> bool:
    if not _is_meeting_time():
        return false
    
    TimeManager.advance_time(2)  # 2 hour meetings
    
    # Share intelligence
    _pool_coalition_intelligence()
    
    # Plan operations
    _plan_next_operations()
    
    return true
```

#### Economy Integration
```gdscript
# Coalition economics
func get_coalition_shop_discount(shop_id: String) -> float:
    var shop_owner = ShopRegistry.get_owner(shop_id)
    
    if shop_owner in members:
        return 0.7  # 30% discount from coalition shops
    elif shop_owner in verified_unassimilated:
        return 0.9  # 10% discount from sympathizers
    
    return 1.0
```

#### Assimilation Integration
```gdscript
# Coalition slows assimilation
func get_assimilation_resistance_factor() -> float:
    var base_resistance = 0.0
    
    # Each member provides resistance
    base_resistance += members.size() * 0.02  # 2% per member
    
    # Safe houses provide protection
    base_resistance += safe_houses.size() * 0.05  # 5% per safe house
    
    # Active operations
    if active_heist:
        base_resistance += 0.1  # 10% during heists
    
    return clamp(base_resistance, 0.0, 0.5)  # Max 50% slowdown
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/coalition_serializer.gd
extends BaseSerializer

class_name CoalitionSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("coalition", self, 40)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "members": CoalitionManager.members,
        "verified_safe": CoalitionManager.verified_unassimilated,
        "suspected": CoalitionManager.suspected_assimilated,
        "compromised": CoalitionManager.compromised_members,
        "trust_levels": TrustSystem.npc_trust_levels,
        "resources": {
            "credits": CoalitionManager.shared_credits,
            "items": CoalitionManager.shared_items
        },
        "safe_houses": CoalitionManager.safe_houses,
        "heists": {
            "available": HeistSystem.available_heists,
            "completed": HeistSystem.completed_heists,
            "active": _serialize_active_heist()
        },
        "intelligence": {
            "reports": _compress_intelligence_reports(),
            "surveillance": CoalitionManager.active_surveillance
        }
    }

func deserialize(data: Dictionary) -> void:
    CoalitionManager.members = data.get("members", [])
    CoalitionManager.verified_unassimilated = data.get("verified_safe", [])
    CoalitionManager.suspected_assimilated = data.get("suspected", [])
    CoalitionManager.compromised_members = data.get("compromised", [])
    
    TrustSystem.npc_trust_levels = data.get("trust_levels", {})
    
    var resources = data.get("resources", {})
    CoalitionManager.shared_credits = resources.get("credits", 0)
    CoalitionManager.shared_items = resources.get("items", {})
    
    CoalitionManager.safe_houses = data.get("safe_houses", {})
    
    var heists = data.get("heists", {})
    HeistSystem.available_heists = heists.get("available", [])
    HeistSystem.completed_heists = heists.get("completed", [])
    _deserialize_active_heist(heists.get("active", null))
    
    var intel = data.get("intelligence", {})
    _decompress_intelligence_reports(intel.get("reports", []))
    CoalitionManager.active_surveillance = intel.get("surveillance", {})
    
    # Restore coalition state in NPCs
    for member_id in CoalitionManager.members:
        var npc_data = NPCRegistry.get_npc(member_id)
        if npc_data:
            npc_data.coalition_member = true

func _compress_intelligence_reports() -> Array:
    # Only save last 20 reports
    var recent = []
    var start = max(0, CoalitionManager.intelligence_reports.size() - 20)
    
    for i in range(start, CoalitionManager.intelligence_reports.size()):
        var report = CoalitionManager.intelligence_reports[i]
        recent.append({
            "t": report.target,
            "tm": report.time - TimeManager.game_start_time,
            "o": report.observations
        })
    
    return recent
```

## UI Components

### Coalition HQ Interface
```gdscript
# src/ui/coalition/coalition_hq_ui.gd
extends Control

onready var member_list = $MemberList
onready var intel_board = $IntelBoard
onready var resource_pool = $ResourcePool
onready var operation_planner = $OperationPlanner

func open_hq():
    if not _player_at_hq():
        return
    
    _refresh_all_displays()
    show()

func _refresh_member_list():
    member_list.clear()
    
    for member_id in CoalitionManager.members:
        var npc = NPCRegistry.get_npc(member_id)
        var trust = TrustSystem.get_trust(member_id)
        
        var entry = MEMBER_ENTRY.instance()
        entry.set_member_data(npc, trust)
        member_list.add_child(entry)
```

### Intelligence Network UI
```gdscript
# src/ui/coalition/intel_network_ui.gd
extends Control

onready var verified_list = $VerifiedList
onready var suspected_list = $SuspectedList
onready var surveillance_grid = $SurveillanceGrid

func refresh_intel():
    var intel = CoalitionManager.get_network_intelligence()
    
    # Show verified safe NPCs
    verified_list.clear()
    for npc_id in intel.verified_safe:
        var npc = NPCRegistry.get_npc(npc_id)
        verified_list.add_item("%s - %s [SAFE]" % [npc.name, npc.location])
    
    # Show suspected assimilated
    suspected_list.clear()
    for npc_id in intel.suspected:
        var npc = NPCRegistry.get_npc(npc_id)
        suspected_list.add_item("%s - %s [WARNING]" % [npc.name, npc.location])
```

## Balance Considerations

### Coalition Growth Rate
- **Early game**: 1-2 recruits per day maximum
- **Mid game**: 2-4 recruits per day with intel network
- **Late game**: Rapid recruitment or rapid loss

### Trust Building Time
- **Initial contact**: 1 hour conversation
- **Quest completion**: 2-6 hours depending on complexity
- **Trust threshold**: 3-5 interactions to recruit

### Infiltration Risk
- **Base chance**: 5% any recruited NPC is assimilated
- **With verification**: 1% chance with proper vetting
- **Consequences**: Loss of 30-50% resources, multiple members exposed

### Power Balance
- **Tipping points**:
  - 25% coalition: Assimilation slows
  - 50% coalition: Major heists available
  - 75% coalition: Victory path unlocked
  - 25% assimilated: Prices increase
  - 50% assimilated: Districts locked down
  - 75% assimilated: Escape path only

## Testing Considerations

1. **Trust System**
   - Verify quest completion grants appropriate trust
   - Test trust thresholds unlock correct options
   - Ensure trust persists across saves

2. **Intelligence Network**
   - Test information propagation
   - Verify surveillance detection chances
   - Test infiltration consequences

3. **Heist System**
   - Test team composition requirements
   - Verify phase progression
   - Test failure consequences

4. **Balance Testing**
   - Full playthrough coalition viability
   - Test both victory conditions achievable
   - Verify no soft-locks from low coalition

## Template Compliance

### NPC Template Integration
Coalition members and recruits follow `template_npc_design.md`:
- Trust-building integrates with NPC relationship systems
- Recruitment dialog uses procedural generation based on personality
- Members maintain schedules and can be tracked/observed
- Assimilated infiltrators use the NPC assimilation states

### Quest Template Integration
Coalition activities follow `template_quest_design.md`:
- Verification quests use the modular quest structure
- Trust-building missions follow objective hierarchies
- Heist planning uses multi-part quest system
- Time-sensitive operations use quest deadlines

This system creates a meaningful resistance narrative where every recruitment matters, intelligence networks provide tangible benefits, and the constant threat of infiltration maintains tension throughout the game.