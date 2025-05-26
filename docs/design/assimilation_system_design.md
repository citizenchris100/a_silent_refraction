# Assimilation System Design Document

## Overview

The Assimilation System is the core horror and narrative mechanic of A Silent Refraction. It represents the spread of an alien collective consciousness through the station's population, driven by a sinister economic motive: orchestrating the station's societal breakdown to devalue it for hostile takeover. This system features a two-tier hierarchy of assimilated NPCs and integrates deeply with all other game systems.

## Design Philosophy

- **Economic Horror**: The true horror isn't just bodily invasion, but calculated economic destruction
- **Strategic Spread**: Assimilation follows patterns, not random chance
- **Behavioral Hierarchy**: Leaders maintain cover while drones cause chaos
- **Detectable Patterns**: Observant players can uncover the conspiracy
- **Systemic Integration**: Ties into crime, economy, suspicion, and coalition systems

## Core Concept: The Chinatown Conspiracy

The assimilated aren't just spreading - they're executing a hostile takeover:
1. **Leaders** strategically assimilate key personnel
2. **Drones** engage in antisocial behavior to degrade station value
3. Station property values drop due to crime and dysfunction
4. Assimilated-controlled entities buy the station cheap
5. The collective gains a new outpost for further expansion

## MVP Implementation (Phase 1)

### Core Requirements

The MVP demonstrates basic assimilation mechanics for the Intro and First Quest:

1. **Two-Tier System**: Leaders and Drones with different behaviors
2. **Basic Spread**: Time and event-based assimilation
3. **Visual Indicators**: Subtle changes for assimilated NPCs
4. **Detection Integration**: Works with existing observation mechanics
5. **Save/Load Support**: Assimilation state persistence

### Technical Specification

```gdscript
# AssimilationManager.gd (MVP)
extends Node

class_name AssimilationManager

# Assimilation tracking
var assimilated_npcs: Dictionary = {} # {npc_id: AssimilationData}
var leader_npcs: Array = [] # IDs of leader assimilated
var drone_npcs: Array = [] # IDs of drone assimilated

# Spread configuration
export var daily_assimilation_count: int = 1
export var leader_ratio: float = 0.2 # 20% become leaders

# Strategic targets (key positions)
var priority_targets: Array = [
    "bank_manager",
    "security_chief",
    "dock_manager",
    "detective_01"
]

# Signals
signal npc_assimilated(npc_id: String, assimilation_type: String)
signal assimilation_attempted(npc_id: String, success: bool)
signal station_corruption_changed(corruption_level: float)

class AssimilationData:
    var npc_id: String
    var assimilation_type: String # "leader" or "drone"
    var assimilation_day: int
    var assimilated_by: String # ID of NPC who assimilated them
    var behavior_modifiers: Dictionary = {}

func _ready():
    # Connect to time system
    TimeManager.connect("day_changed", self, "_on_day_changed")
    
    # Connect to event system
    EventManager.connect("story_event", self, "_on_story_event")

func _on_day_changed(day: int):
    # Process daily assimilation
    _process_daily_spread()
    
    # Update drone behaviors
    _update_drone_behaviors()

func _process_daily_spread():
    var targets_today = _select_assimilation_targets()
    
    for target_id in targets_today:
        attempt_assimilation(target_id)

func _select_assimilation_targets() -> Array:
    var targets = []
    var available_npcs = _get_unassimilated_npcs()
    
    # Prioritize strategic targets
    for target in priority_targets:
        if target in available_npcs and randf() < 0.7: # 70% chance
            targets.append(target)
            if targets.size() >= daily_assimilation_count:
                return targets
    
    # Fill remaining slots randomly
    while targets.size() < daily_assimilation_count and available_npcs.size() > 0:
        var random_npc = available_npcs[randi() % available_npcs.size()]
        targets.append(random_npc)
        available_npcs.erase(random_npc)
    
    return targets

func attempt_assimilation(npc_id: String) -> bool:
    var npc = NPCRegistry.get_npc(npc_id)
    if not npc or npc.is_assimilated:
        return false
    
    # Determine type
    var is_leader = false
    if npc_id in priority_targets or randf() < leader_ratio:
        is_leader = true
    
    # Create assimilation data
    var data = AssimilationData.new()
    data.npc_id = npc_id
    data.assimilation_type = "leader" if is_leader else "drone"
    data.assimilation_day = TimeManager.current_day
    data.assimilated_by = _get_nearest_assimilated(npc_id)
    
    # Apply to NPC
    npc.is_assimilated = true
    npc.handle_assimilation()
    
    # Track
    assimilated_npcs[npc_id] = data
    if is_leader:
        leader_npcs.append(npc_id)
    else:
        drone_npcs.append(npc_id)
    
    # Update registry
    NPCRegistry.update_npc_data(npc_id, {"is_assimilated": true})
    
    emit_signal("npc_assimilated", npc_id, data.assimilation_type)
    return true

func _update_drone_behaviors():
    # Drones cause problems
    for drone_id in drone_npcs:
        var npc = NPCRegistry.get_npc(drone_id)
        if npc:
            # Schedule antisocial behaviors
            _schedule_drone_crime(drone_id)

func _schedule_drone_crime(drone_id: String):
    # Simple crime scheduling for MVP
    var crime_types = ["vandalism", "theft", "disturbance"]
    var crime = crime_types[randi() % crime_types.size()]
    
    EventManager.schedule_event({
        "type": "drone_crime",
        "npc_id": drone_id,
        "crime_type": crime,
        "time": TimeManager.current_hour + randi() % 8
    })

func get_station_corruption_level() -> float:
    # Calculate how corrupted the station is
    var total_npcs = NPCRegistry.get_all_npcs().size()
    var assimilated_count = assimilated_npcs.size()
    
    if total_npcs == 0:
        return 0.0
    
    # Weight leaders more heavily
    var corruption = 0.0
    corruption += leader_npcs.size() * 2.0
    corruption += drone_npcs.size() * 1.0
    
    return clamp(corruption / (total_npcs * 1.5), 0.0, 1.0)
```

### MVP Behavioral Implementation

```gdscript
# AssimilatedBehaviors.gd (MVP)
extends Reference

class_name AssimilatedBehaviors

# Leader behaviors - maintain cover
static func apply_leader_behavior(npc: BaseNPC):
    # Leaders act normal but make strategic decisions
    npc.personality.suspicion *= 0.7 # Less naturally suspicious
    npc.personality.friendliness *= 1.2 # More approachable
    
    # They still use collective pronouns occasionally
    npc.dialog_slip_chance = 0.1 # 10% chance of revealing speech

# Drone behaviors - cause chaos
static func apply_drone_behavior(npc: BaseNPC):
    # Drones are more obvious
    npc.personality.friendliness *= 0.5
    npc.personality.aggression = 0.8
    npc.personality.lawfulness = 0.2 # Low law-abiding
    
    # More obvious speech patterns
    npc.dialog_slip_chance = 0.4 # 40% chance
    
    # Schedule antisocial activities
    npc.crime_tendency = 0.7 # 70% chance of crime per day

static func get_drone_dialog_modifications() -> Dictionary:
    return {
        "greeting": [
            "We... I mean, hello.",
            "What do you want?",
            "*twitches* Yeah?"
        ],
        "hostile": [
            "Get away from us!",
            "You don't belong here!",
            "The collective will prevail!"
        ]
    }

static func get_leader_dialog_modifications() -> Dictionary:
    return {
        "greeting": [
            "Good day. How may I assist you?",
            "Welcome. Everything is perfectly normal here.",
            "Hello there. Busy day at the station, isn't it?"
        ],
        "suspicion_deflection": [
            "I'm not sure what you mean. Everything seems fine to me.",
            "You're imagining things. Perhaps you need some rest?",
            "That's quite an accusation. Do you have any proof?"
        ]
    }
```

### MVP Crime Integration

```gdscript
# DroneCrimeEvents.gd (MVP)
extends Reference

class_name DroneCrimeEvents

# Crime types drones commit
enum CrimeType {
    VANDALISM,    # Damage property
    THEFT,        # Steal items
    DISTURBANCE,  # Public disruption
    ASSAULT,      # Attack others
    SABOTAGE      # Damage systems
}

static func execute_drone_crime(drone_id: String, crime_type: String, location: String):
    var crime_data = {
        "perpetrator": drone_id,
        "type": crime_type,
        "location": location,
        "time": TimeManager.current_time,
        "witnesses": _get_witnesses(location)
    }
    
    # Apply crime effects
    match crime_type:
        "vandalism":
            EconomyManager.modify_district_value(location, -50)
            _create_vandalism_visuals(location)
        
        "theft":
            var victim = _select_theft_victim(location)
            if victim:
                _execute_theft(drone_id, victim)
        
        "disturbance":
            _increase_area_suspicion(location, 0.1)
            _alert_security(location)
    
    # Log crime
    CrimeManager.record_crime(crime_data)
    
    # Emit event
    EventManager.emit_signal("crime_committed", crime_data)

static func _get_witnesses(location: String) -> Array:
    # Get NPCs in location who might witness
    var witnesses = []
    var npcs_in_area = LocationManager.get_npcs_at(location)
    
    for npc_id in npcs_in_area:
        if randf() < 0.6: # 60% chance to witness
            witnesses.append(npc_id)
    
    return witnesses
```

### MVP Serialization (Following Modular Architecture)

```gdscript
# src/core/serializers/assimilation_serializer.gd
extends BaseSerializer

class_name AssimilationSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("assimilation", self, 30)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    var manager = get_node("/root/AssimilationManager")
    if not manager:
        return {}
    
    # Compress assimilation data
    var compressed_data = {}
    for npc_id in manager.assimilated_npcs:
        var data = manager.assimilated_npcs[npc_id]
        compressed_data[npc_id] = _compress_assimilation_data(data)
    
    return {
        "assimilated": compressed_data,
        "leaders": manager.leader_npcs,
        "drones": manager.drone_npcs,
        "corruption": manager.get_station_corruption_level()
    }

func deserialize(data: Dictionary) -> void:
    var manager = get_node("/root/AssimilationManager")
    if not manager:
        return
    
    # Clear existing data
    manager.assimilated_npcs.clear()
    manager.leader_npcs.clear()
    manager.drone_npcs.clear()
    
    # Restore assimilation data
    for npc_id in data.get("assimilated", {}):
        var compressed = data.assimilated[npc_id]
        var assimilation_data = _decompress_assimilation_data(compressed)
        manager.assimilated_npcs[npc_id] = assimilation_data
    
    manager.leader_npcs = data.get("leaders", [])
    manager.drone_npcs = data.get("drones", [])

func _compress_assimilation_data(data: AssimilationManager.AssimilationData) -> Dictionary:
    # Compress to minimal format
    return {
        "t": data.assimilation_type.substr(0, 1), # "l" or "d"
        "d": data.assimilation_day,
        "b": data.assimilated_by if data.assimilated_by != "" else null
    }

func _decompress_assimilation_data(compressed: Dictionary) -> AssimilationManager.AssimilationData:
    var data = AssimilationManager.AssimilationData.new()
    data.npc_id = "" # Will be set by key
    data.assimilation_type = "leader" if compressed.t == "l" else "drone"
    data.assimilation_day = compressed.d
    data.assimilated_by = compressed.get("b", "")
    return data
```

## Full Implementation (Phase 2)

### Extended Requirements

The Full implementation adds sophisticated spread mechanics and economic warfare:

1. **Strategic Assimilation AI**: Leaders plan who to convert
2. **Economic Warfare**: Track station value and property ownership
3. **Behavioral Networks**: Assimilated coordinate actions
4. **Detection Complexity**: Different methods for leaders vs drones
5. **Intervention Mechanics**: Ways to prevent/slow spread
6. **Coalition Impact**: Resistance efforts affect assimilation
7. **Conspiracy Discovery**: Financial paper trail to uncover

### Technical Specification

```gdscript
# AssimilationManager.gd (Full)
extends Node

class_name AssimilationManager

# Assimilation tracking
var assimilated_npcs: Dictionary = {}
var leader_npcs: Array = []
var drone_npcs: Array = []
var assimilation_network: AssimilationNetwork

# Economic warfare tracking
var station_property_value: float = 1000000.0 # Starting value
var assimilated_assets: Dictionary = {} # Properties owned by assimilated
var target_value_threshold: float = 300000.0 # When to execute takeover

# Strategic planning
var strategic_targets: Dictionary = {} # {npc_id: priority_score}
var assimilation_plan: Array = [] # Ordered list of targets
var leader_assignments: Dictionary = {} # {leader_id: [drone_ids]}

# Detection tracking
var discovered_assimilated: Array = [] # NPCs known to be assimilated
var conspiracy_evidence: Dictionary = {} # Financial evidence collected

# Configuration
export var base_spread_rate: float = 1.0
export var leader_ratio: float = 0.2
export var strategic_planning_enabled: bool = true
export var economic_warfare_enabled: bool = true

# Signals
signal npc_assimilated(npc_id: String, assimilation_type: String)
signal conspiracy_progress(evidence_type: String, details: Dictionary)
signal station_value_changed(old_value: float, new_value: float)
signal takeover_imminent(days_remaining: int)
signal assimilation_prevented(npc_id: String, method: String)

class AssimilationNetwork:
    # Represents the collective consciousness coordination
    var members: Array = []
    var leaders: Array = []
    var objectives: Array = []
    var communication_strength: float = 1.0
    
    func coordinate_action(action_type: String, parameters: Dictionary):
        # Leaders coordinate drone activities
        pass
    
    func share_information(info_type: String, data: Dictionary):
        # Collective knowledge sharing
        pass
    
    func plan_strategic_assimilation() -> Array:
        # AI planning for next targets
        return []

func _ready():
    assimilation_network = AssimilationNetwork.new()
    
    # System connections
    TimeManager.connect("hour_changed", self, "_on_hour_changed")
    TimeManager.connect("day_changed", self, "_on_day_changed")
    EventManager.connect("story_event", self, "_on_story_event")
    EconomyManager.connect("transaction_completed", self, "_on_transaction")
    NPCRegistry.connect("npc_state_changed", self, "_on_npc_state_changed")
    
    # Initialize strategic planning
    if strategic_planning_enabled:
        _analyze_station_hierarchy()
        _create_assimilation_plan()

func _analyze_station_hierarchy():
    # Identify key positions for strategic takeover
    var all_npcs = NPCRegistry.get_all_npcs()
    
    for npc_id in all_npcs:
        var npc_data = NPCRegistry.get_npc_data(npc_id)
        var priority = _calculate_strategic_priority(npc_data)
        strategic_targets[npc_id] = priority
    
    # Sort by priority
    var sorted_targets = []
    for npc_id in strategic_targets:
        sorted_targets.append([npc_id, strategic_targets[npc_id]])
    
    sorted_targets.sort_custom(self, "_sort_by_priority")
    
    # Create ordered plan
    assimilation_plan.clear()
    for target in sorted_targets:
        assimilation_plan.append(target[0])

func _calculate_strategic_priority(npc_data: Dictionary) -> float:
    var priority = 0.0
    
    # Position-based priority
    match npc_data.get("role", ""):
        "bank_manager":
            priority += 100.0
        "security_chief", "security_admin":
            priority += 90.0
        "dock_manager", "trading_floor_manager":
            priority += 80.0
        "doctor", "lab_tech":
            priority += 70.0
        "engineer", "maintenance_chief":
            priority += 60.0
    
    # Access-based priority
    if npc_data.get("has_master_key", false):
        priority += 50.0
    if npc_data.get("security_clearance", 0) > 2:
        priority += 30.0
    
    # Social influence
    var social_connections = npc_data.get("connections", []).size()
    priority += social_connections * 5.0
    
    # Economic influence
    if npc_data.get("wealth", 0) > 10000:
        priority += 40.0
    
    return priority

func attempt_strategic_assimilation(target_id: String, assimilator_id: String = "") -> bool:
    var target = NPCRegistry.get_npc(target_id)
    if not target or target.is_assimilated:
        return false
    
    # Check if assimilator has access to target
    if assimilator_id != "":
        if not _can_reach_target(assimilator_id, target_id):
            # Schedule future attempt
            _schedule_assimilation_attempt(target_id, assimilator_id)
            return false
    
    # Check for protection
    if _is_protected(target_id):
        emit_signal("assimilation_prevented", target_id, "protection")
        return false
    
    # Determine type based on strategic value
    var is_leader = strategic_targets.get(target_id, 0) > 50.0
    
    # Create assimilation data
    var data = AssimilationData.new()
    data.npc_id = target_id
    data.assimilation_type = "leader" if is_leader else "drone"
    data.assimilation_day = TimeManager.current_day
    data.assimilation_hour = TimeManager.current_hour
    data.assimilated_by = assimilator_id
    data.strategic_value = strategic_targets.get(target_id, 0)
    
    # Apply assimilation
    _apply_assimilation(target, data)
    
    # Leader-specific setup
    if is_leader:
        _setup_leader_behavior(target_id)
        leader_npcs.append(target_id)
        assimilation_network.leaders.append(target_id)
    else:
        _setup_drone_behavior(target_id)
        drone_npcs.append(target_id)
        
        # Assign to nearest leader
        var controller = _find_nearest_leader(target_id)
        if controller:
            if not leader_assignments.has(controller):
                leader_assignments[controller] = []
            leader_assignments[controller].append(target_id)
    
    # Update network
    assimilation_network.members.append(target_id)
    
    # Track in systems
    assimilated_npcs[target_id] = data
    NPCRegistry.update_npc_data(target_id, {
        "is_assimilated": true,
        "assimilation_type": data.assimilation_type
    })
    
    # Economic warfare
    if economic_warfare_enabled:
        _process_economic_takeover(target_id)
    
    emit_signal("npc_assimilated", target_id, data.assimilation_type)
    
    # Update conspiracy progress
    _update_conspiracy_metrics()
    
    return true

func _setup_leader_behavior(npc_id: String):
    var npc = NPCRegistry.get_npc(npc_id)
    
    # Leaders maintain perfect cover
    AssimilatedBehaviors.apply_leader_behavior(npc)
    
    # Strategic planning capability
    npc.set_meta("can_plan_assimilation", true)
    npc.set_meta("leadership_level", randf_range(0.7, 1.0))
    
    # Financial manipulation ability
    if npc.role in ["bank_manager", "trader", "dock_manager"]:
        npc.set_meta("can_manipulate_economy", true)

func _setup_drone_behavior(npc_id: String):
    var npc = NPCRegistry.get_npc(npc_id)
    
    # Drones cause chaos
    AssimilatedBehaviors.apply_drone_behavior(npc)
    
    # Crime scheduling
    npc.set_meta("crime_frequency", randf_range(0.5, 0.9))
    npc.set_meta("preferred_crimes", _assign_crime_preferences(npc))
    
    # Behavioral degradation over time
    npc.set_meta("degradation_rate", randf_range(0.1, 0.3))

func _process_economic_takeover(npc_id: String):
    var npc_data = NPCRegistry.get_npc_data(npc_id)
    
    # Transfer assets to collective
    var npc_assets = npc_data.get("owned_assets", [])
    for asset in npc_assets:
        assimilated_assets[asset] = npc_id
    
    # If this NPC has financial influence
    if npc_data.role in ["bank_manager", "trader"]:
        # Begin market manipulation
        _schedule_market_manipulation(npc_id)
    
    # Update station value based on position
    var value_impact = _calculate_value_impact(npc_data)
    modify_station_value(value_impact)

func modify_station_value(change: float):
    var old_value = station_property_value
    station_property_value = max(0, station_property_value + change)
    
    emit_signal("station_value_changed", old_value, station_property_value)
    
    # Check for takeover threshold
    if station_property_value <= target_value_threshold:
        var days_to_takeover = _calculate_takeover_timeline()
        emit_signal("takeover_imminent", days_to_takeover)

func _update_drone_coordination():
    # Leaders coordinate drone activities
    for leader_id in leader_npcs:
        if not leader_assignments.has(leader_id):
            continue
        
        var leader = NPCRegistry.get_npc(leader_id)
        var drones = leader_assignments[leader_id]
        
        # Coordinate crimes for maximum impact
        var coordination_plan = _create_coordination_plan(leader_id, drones)
        
        for action in coordination_plan:
            match action.type:
                "synchronized_crime":
                    _schedule_synchronized_crime(action.participants, action.crime_type)
                
                "targeted_harassment":
                    _schedule_harassment_campaign(action.target, action.participants)
                
                "system_sabotage":
                    _schedule_sabotage(action.system, action.participants)

func _create_coordination_plan(leader_id: String, drone_ids: Array) -> Array:
    var plan = []
    var leader_data = NPCRegistry.get_npc_data(leader_id)
    
    # Prioritize based on leader's position
    match leader_data.role:
        "security_chief":
            # Use drones to create security incidents
            plan.append({
                "type": "synchronized_crime",
                "participants": drone_ids.slice(0, 3),
                "crime_type": "disturbance",
                "purpose": "overwhelm_security"
            })
        
        "bank_manager":
            # Economic disruption
            plan.append({
                "type": "targeted_harassment",
                "target": "wealthy_patrons",
                "participants": drone_ids,
                "purpose": "drive_away_investors"
            })
        
        "maintenance_chief":
            # Infrastructure damage
            plan.append({
                "type": "system_sabotage",
                "system": "life_support",
                "participants": drone_ids.slice(0, 2),
                "purpose": "create_crisis"
            })
    
    return plan

# Detection mechanics
func analyze_npc_for_assimilation(npc_id: String, analyzer_id: String) -> Dictionary:
    var result = {
        "detected": false,
        "confidence": 0.0,
        "evidence": [],
        "assimilation_type": ""
    }
    
    if not assimilated_npcs.has(npc_id):
        return result
    
    var data = assimilated_npcs[npc_id]
    var analyzer = NPCRegistry.get_npc(analyzer_id)
    
    # Base detection chance
    var detection_skill = analyzer.get_meta("investigation_skill", 0.5)
    
    # Drones are easier to detect
    if data.assimilation_type == "drone":
        var drone = NPCRegistry.get_npc(npc_id)
        
        # Check for obvious signs
        if drone.get_meta("recent_crimes", 0) > 0:
            result.evidence.append("criminal_behavior")
            result.confidence += 0.3
        
        if drone.personality.friendliness < 0.3:
            result.evidence.append("antisocial_behavior")
            result.confidence += 0.2
        
        # Speech pattern analysis
        if randf() < detection_skill:
            result.evidence.append("speech_patterns")
            result.confidence += 0.4
    
    # Leaders are much harder
    elif data.assimilation_type == "leader":
        # Need multiple interactions or evidence
        var interactions = analyzer.get_meta("interactions_with_" + npc_id, 0)
        
        if interactions < 3:
            # Not enough data
            result.confidence = randf_range(0.0, 0.2)
        else:
            # Financial irregularities
            if _check_financial_anomalies(npc_id):
                result.evidence.append("financial_irregularities")
                result.confidence += 0.5
            
            # Behavioral analysis over time
            if _analyze_behavior_patterns(npc_id, analyzer_id):
                result.evidence.append("subtle_behavior_changes")
                result.confidence += 0.3
    
    # Determine detection
    result.detected = result.confidence > 0.6
    result.assimilation_type = data.assimilation_type if result.detected else ""
    
    # Track discovery
    if result.detected and not npc_id in discovered_assimilated:
        discovered_assimilated.append(npc_id)
        _process_discovery_consequences(npc_id, analyzer_id)
    
    return result

func _check_financial_anomalies(npc_id: String) -> bool:
    # Check for suspicious financial activity
    var transactions = EconomyManager.get_npc_transactions(npc_id)
    
    for transaction in transactions:
        # Large unexplained transfers
        if transaction.amount > 10000 and transaction.recipient in assimilated_npcs:
            return true
        
        # Property sales below market value
        if transaction.type == "property_sale" and transaction.price < transaction.market_value * 0.7:
            return true
    
    return false

# Coalition integration
func get_coalition_resistance_factor() -> float:
    # Coalition efforts slow assimilation
    var coalition_size = CoalitionManager.get_member_count()
    var coalition_strength = CoalitionManager.get_strength()
    
    # Base resistance
    var resistance = 0.0
    
    # Size matters
    resistance += min(coalition_size * 0.02, 0.5) # Max 50% from size
    
    # Active measures
    if CoalitionManager.has_active_measure("quarantine"):
        resistance += 0.2
    
    if CoalitionManager.has_active_measure("screening"):
        resistance += 0.15
    
    # Protected individuals
    var protected_count = CoalitionManager.get_protected_npcs().size()
    resistance += protected_count * 0.01
    
    return clamp(resistance, 0.0, 0.8) # Max 80% resistance

func _is_protected(npc_id: String) -> bool:
    # Check if NPC is protected by coalition
    return CoalitionManager.is_npc_protected(npc_id)
```

### Full Serialization (Following Modular Architecture)

```gdscript
# src/core/serializers/assimilation_serializer.gd (Full)
extends BaseSerializer

class_name AssimilationSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("assimilation", self, 30)

func get_version() -> int:
    return 2 # Version 2 for full implementation

func serialize() -> Dictionary:
    var manager = get_node("/root/AssimilationManager")
    if not manager:
        return {}
    
    # Compress assimilation data
    var compressed_data = {}
    for npc_id in manager.assimilated_npcs:
        var data = manager.assimilated_npcs[npc_id]
        compressed_data[npc_id] = _compress_assimilation_data(data)
    
    # Compress leader assignments
    var compressed_assignments = {}
    for leader_id in manager.leader_assignments:
        if manager.leader_assignments[leader_id].size() > 0:
            compressed_assignments[leader_id] = manager.leader_assignments[leader_id]
    
    return {
        "assimilated": compressed_data,
        "leaders": manager.leader_npcs,
        "drones": manager.drone_npcs,
        "corruption": manager.get_station_corruption_level(),
        "station_value": manager.station_property_value,
        "assets": manager.assimilated_assets,
        "discovered": manager.discovered_assimilated,
        "evidence": manager.conspiracy_evidence,
        "assignments": compressed_assignments,
        "plan": manager.assimilation_plan.slice(0, 10) # Only save next 10 targets
    }

func deserialize(data: Dictionary) -> void:
    var manager = get_node("/root/AssimilationManager")
    if not manager:
        return
    
    # Clear existing data
    manager.assimilated_npcs.clear()
    manager.leader_npcs.clear()
    manager.drone_npcs.clear()
    manager.leader_assignments.clear()
    
    # Restore assimilation data
    for npc_id in data.get("assimilated", {}):
        var compressed = data.assimilated[npc_id]
        var assimilation_data = _decompress_assimilation_data(compressed)
        assimilation_data.npc_id = npc_id
        manager.assimilated_npcs[npc_id] = assimilation_data
    
    manager.leader_npcs = data.get("leaders", [])
    manager.drone_npcs = data.get("drones", [])
    manager.station_property_value = data.get("station_value", 1000000.0)
    manager.assimilated_assets = data.get("assets", {})
    manager.discovered_assimilated = data.get("discovered", [])
    manager.conspiracy_evidence = data.get("evidence", {})
    manager.leader_assignments = data.get("assignments", {})
    
    # Restore partial plan
    var saved_plan = data.get("plan", [])
    manager.assimilation_plan = saved_plan
    
    # Rebuild network
    manager._rebuild_assimilation_network()

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    if from_version == 1 and to_version == 2:
        # Add new fields for full implementation
        data["station_value"] = 1000000.0
        data["assets"] = {}
        data["discovered"] = []
        data["evidence"] = {}
        data["assignments"] = {}
        data["plan"] = []
    
    return data

func _compress_assimilation_data(data: AssimilationManager.AssimilationData) -> Dictionary:
    # Compress to minimal format
    var compressed = {
        "t": data.assimilation_type.substr(0, 1), # "l" or "d"
        "d": data.assimilation_day,
    }
    
    # Only save non-default values
    if data.assimilated_by != "":
        compressed["b"] = data.assimilated_by
    
    if data.has("assimilation_hour"):
        compressed["h"] = data.assimilation_hour
    
    if data.has("strategic_value") and data.strategic_value > 0:
        compressed["s"] = int(data.strategic_value)
    
    return compressed

func _decompress_assimilation_data(compressed: Dictionary) -> AssimilationManager.AssimilationData:
    var data = AssimilationManager.AssimilationData.new()
    data.assimilation_type = "leader" if compressed.t == "l" else "drone"
    data.assimilation_day = compressed.d
    data.assimilated_by = compressed.get("b", "")
    
    # Full implementation fields
    if compressed.has("h"):
        data.assimilation_hour = compressed.h
    if compressed.has("s"):
        data.strategic_value = float(compressed.s)
    
    return data
```

## Integration with Other Systems

### BaseNPC Integration
- Extends existing `is_assimilated` flag
- Adds `assimilation_type` property
- Modifies personality based on type
- Integrates with observation mechanics

### Suspicion System
- Drone behavior increases area suspicion
- Leader detection requires deeper investigation
- False accusations increase player suspicion

### Economy System
- Tracks station property value
- Assimilated NPCs manipulate markets
- Crime reduces district values
- Financial evidence trail

### Crime Event System
- Drones automatically commit crimes
- Leaders coordinate crime waves
- Crime types affect different systems

### Coalition System
- Coalition provides protection
- Active measures slow spread
- Information sharing reveals patterns

### Quest System
- Investigation quests to uncover conspiracy
- Financial document quests
- Protecting key NPCs quests

### Time Management
- Daily assimilation attempts
- Time-based behavioral changes
- Scheduled coordinated actions

### Dialog System
- Assimilation text transformations
- Type-specific dialog patterns
- Investigation dialog options

### Save System
- Follows modular serialization architecture
- Self-registering serializer
- Version migration support
- Compressed data format

## Testing Checklist

### MVP Testing
- [ ] Basic assimilation spreads daily
- [ ] Leaders vs drones properly assigned
- [ ] Visual changes apply correctly
- [ ] Drones commit crimes
- [ ] Station value decreases
- [ ] Save/load preserves state through serializer

### Full Testing
- [ ] Strategic targeting works
- [ ] Leaders coordinate drones
- [ ] Economic manipulation functions
- [ ] Detection mechanics work for both types
- [ ] Coalition resistance applies
- [ ] Conspiracy can be uncovered
- [ ] Complex behavioral networks form
- [ ] Serializer handles all data correctly
- [ ] Migration from v1 to v2 works

## Performance Considerations

- Update assimilation checks only on day change
- Batch crime scheduling for efficiency
- Limit coordination calculations to active leaders
- Cache detection results for repeated checks
- Compress save data to minimize file size

## Future Enhancements

- Visual corruption of environments
- Assimilated-only areas of station
- Reverse assimilation research
- Multiple collective factions
- Psychological profiles affecting resistance