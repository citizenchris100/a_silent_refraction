# Full Suspicion System Design Document

## Overview

The Full Suspicion System builds upon the existing MVP implementation to create a comprehensive, station-wide paranoia and investigation mechanic. This system extends the current individual NPC suspicion tracking and global suspicion monitoring with advanced features including district-based suspicion, network effects, investigation mechanics, security integration, and sophisticated behavioral responses. The design maintains complete compatibility with the MVP code while adding depth and strategic complexity.

## Design Philosophy

- **Natural Extension**: Every feature builds directly on existing MVP code without refactoring
- **Systemic Integration**: Suspicion affects and is affected by all major game systems
- **Emergent Complexity**: Simple rules combine to create complex station-wide dynamics
- **Player Agency**: Multiple ways to manage, redirect, or exploit suspicion
- **Narrative Coherence**: Suspicion mechanics reinforce the themes of paranoia and hidden threats

## Current MVP Foundation

### Existing Components (No Changes Required)

1. **Individual NPC Suspicion** (`base_npc.gd`)
   - Float value 0.0 to 1.0
   - Five tiers: none, low, medium, high, critical
   - State machine integration (IDLE → SUSPICIOUS → HOSTILE)
   - Time-based decay (0.05/second)
   - Signals for suspicion changes

2. **Global Suspicion** (`suspicion_manager.gd`)
   - Weighted average calculation
   - NPC tracking dictionary
   - Real-time UI updates

3. **UI Visualization** (`global_suspicion_meter.gd`)
   - Color-coded meter (green/yellow/red)
   - Percentage display
   - Label customization

## Full System Architecture

### 1. Enhanced Suspicion Manager

```gdscript
# src/core/systems/suspicion_manager_full.gd
extends "res://src/core/systems/suspicion_manager.gd"

# District-based suspicion tracking
var district_suspicion: Dictionary = {} # {district_id: suspicion_level}
var district_modifiers: Dictionary = {} # {district_id: modifier}

# Network effects
var suspicion_networks: Dictionary = {} # {npc_id: [connected_npcs]}
var information_spread_rate: float = 0.3
var network_decay_rate: float = 0.8 # Information degrades through network

# Investigation tracking
var active_investigations: Dictionary = {} # {investigator_id: investigation_data}
var player_investigation_history: Array = [] # Actions that triggered investigations

# Security integration
var security_alert_level: int = 0 # 0-5, affects all suspicion
var camera_coverage: Dictionary = {} # {district_id: coverage_percent}
var security_response_teams: Array = []

# Advanced configuration
export var personality_suspicion_modifiers: Dictionary = {
    "paranoid": 1.5,
    "trusting": 0.7,
    "analytical": 1.2,
    "oblivious": 0.5,
    "aggressive": 1.3,
    "cautious": 1.1
}

export var role_suspicion_modifiers: Dictionary = {
    "security_chief": 1.4,
    "detective": 1.5,
    "merchant": 0.9,
    "dock_worker": 0.8,
    "scientist": 1.2,
    "maintenance": 0.6
}

# Signals for new features
signal district_suspicion_changed(district_id: String, level: float)
signal investigation_started(investigator_id: String, target_id: String)
signal security_alert_changed(old_level: int, new_level: int)
signal suspicion_network_formed(anchor_npc: String, network: Array)

func _ready():
    # Call parent ready
    ._ready()
    
    # Initialize district suspicion
    _initialize_district_suspicion()
    
    # Connect to additional systems
    TimeManager.connect("hour_changed", self, "_on_hour_changed")
    EventManager.connect("suspicious_event", self, "_on_suspicious_event")
    DistrictManager.connect("player_entered_district", self, "_on_player_entered_district")
    SecuritySystem.connect("alarm_triggered", self, "_on_security_alarm")

func _initialize_district_suspicion():
    # Set base suspicion for each district type
    var district_base_suspicion = {
        "residential": 0.1,
        "commercial": 0.2,
        "industrial": 0.15,
        "security": 0.4,
        "research": 0.3,
        "docks": 0.25
    }
    
    for district_id in DistrictManager.get_all_districts():
        var district_type = DistrictManager.get_district_type(district_id)
        district_suspicion[district_id] = district_base_suspicion.get(district_type, 0.2)
        district_modifiers[district_id] = 1.0

func change_npc_suspicion(npc_id: String, amount: float, reason: String = "") -> void:
    # Enhanced version with network effects and investigation triggers
    var npc = NPCRegistry.get_npc(npc_id)
    if not npc:
        return
    
    # Apply personality and role modifiers
    var npc_data = NPCRegistry.get_npc_data(npc_id)
    var personality_mod = personality_suspicion_modifiers.get(npc_data.personality_type, 1.0)
    var role_mod = role_suspicion_modifiers.get(npc_data.role, 1.0)
    
    # Apply district modifier
    var current_district = npc.get_meta("current_district", "")
    var district_mod = district_modifiers.get(current_district, 1.0)
    
    # Apply security alert modifier
    var security_mod = 1.0 + (security_alert_level * 0.2)
    
    # Calculate final amount
    var final_amount = amount * personality_mod * role_mod * district_mod * security_mod
    
    # Apply to NPC (using parent method)
    .change_npc_suspicion(npc_id, final_amount)
    
    # Network propagation
    if abs(final_amount) > 0.1:
        _propagate_suspicion_through_network(npc_id, final_amount * network_decay_rate, reason)
    
    # Investigation trigger
    if npc.suspicion_level > 0.6 and not active_investigations.has(npc_id):
        _trigger_investigation(npc_id, reason)
    
    # Update district suspicion
    if current_district != "":
        _update_district_suspicion(current_district, final_amount * 0.1)

func _propagate_suspicion_through_network(source_npc: String, amount: float, reason: String):
    # Get or create network
    if not suspicion_networks.has(source_npc):
        _build_suspicion_network(source_npc)
    
    var network = suspicion_networks[source_npc]
    var propagated_amount = amount * information_spread_rate
    
    # Spread to connected NPCs
    for connected_npc in network:
        if connected_npc == source_npc:
            continue
        
        var npc = NPCRegistry.get_npc(connected_npc)
        if not npc:
            continue
        
        # Information degrades with social distance
        var distance = _calculate_social_distance(source_npc, connected_npc)
        var degraded_amount = propagated_amount * pow(network_decay_rate, distance)
        
        if abs(degraded_amount) > 0.01:
            # Recursive propagation with heavy degradation
            change_npc_suspicion(connected_npc, degraded_amount, "network_propagation")

func _build_suspicion_network(anchor_npc: String):
    var network = []
    var npc_data = NPCRegistry.get_npc_data(anchor_npc)
    
    # Add direct connections
    network.append_array(npc_data.get("connections", []))
    
    # Add NPCs in same location
    var location = NPCRegistry.get_npc(anchor_npc).get_meta("current_location", "")
    if location != "":
        var npcs_at_location = LocationManager.get_npcs_at(location)
        for npc_id in npcs_at_location:
            if not npc_id in network:
                network.append(npc_id)
    
    # Add role-based connections
    var role_connections = _get_role_based_connections(npc_data.role)
    network.append_array(role_connections)
    
    suspicion_networks[anchor_npc] = network
    emit_signal("suspicion_network_formed", anchor_npc, network)

func _trigger_investigation(suspect_id: String, reason: String):
    # Find available investigator
    var investigator_id = _find_investigator_for(suspect_id)
    if investigator_id == "":
        return
    
    var investigation = InvestigationData.new()
    investigation.investigator = investigator_id
    investigation.suspect = suspect_id
    investigation.reason = reason
    investigation.start_time = TimeManager.current_time
    investigation.evidence = []
    investigation.status = "active"
    
    active_investigations[investigator_id] = investigation
    
    # Set investigator state
    var investigator = NPCRegistry.get_npc(investigator_id)
    if investigator:
        investigator.set_meta("investigating", suspect_id)
        investigator.set_state("INVESTIGATING")
    
    emit_signal("investigation_started", investigator_id, suspect_id)
    
    # Schedule investigation events
    _schedule_investigation_events(investigation)

func _find_investigator_for(suspect_id: String) -> String:
    # Priority: Security → Assimilated Leaders → High Suspicion NPCs
    var candidates = []
    
    # Security personnel first
    var security_npcs = NPCRegistry.get_npcs_by_role(["security_chief", "security_guard", "detective"])
    for npc_id in security_npcs:
        var npc = NPCRegistry.get_npc(npc_id)
        if npc and npc.current_state != "INVESTIGATING":
            candidates.append({"id": npc_id, "priority": 3.0})
    
    # Assimilated leaders (they want to control investigations)
    if AssimilationManager.has_method("get_leader_npcs"):
        var leaders = AssimilationManager.get_leader_npcs()
        for leader_id in leaders:
            var npc = NPCRegistry.get_npc(leader_id)
            if npc and npc.current_state != "INVESTIGATING":
                candidates.append({"id": leader_id, "priority": 2.5})
    
    # High suspicion NPCs
    for npc_id in tracked_npcs:
        var npc = tracked_npcs[npc_id]
        if npc.suspicion_level > 0.7 and npc.current_state != "INVESTIGATING":
            candidates.append({"id": npc_id, "priority": npc.suspicion_level})
    
    # Sort by priority and return highest
    candidates.sort_custom(self, "_sort_by_priority")
    return candidates[0].id if candidates.size() > 0 else ""

func _update_district_suspicion(district_id: String, change: float):
    if not district_suspicion.has(district_id):
        district_suspicion[district_id] = 0.2
    
    var old_level = district_suspicion[district_id]
    district_suspicion[district_id] = clamp(old_level + change, 0.0, 1.0)
    
    # Update NPCs in district
    var npcs_in_district = DistrictManager.get_npcs_in_district(district_id)
    for npc_id in npcs_in_district:
        change_npc_suspicion(npc_id, change * 0.5, "district_atmosphere")
    
    emit_signal("district_suspicion_changed", district_id, district_suspicion[district_id])

func update_security_alert_level(new_level: int):
    var old_level = security_alert_level
    security_alert_level = clamp(new_level, 0, 5)
    
    if old_level != security_alert_level:
        emit_signal("security_alert_changed", old_level, security_alert_level)
        
        # Apply immediate effects
        var suspicion_boost = (security_alert_level - old_level) * 0.1
        for npc_id in tracked_npcs:
            change_npc_suspicion(npc_id, suspicion_boost, "security_alert")
```

### 2. Investigation System

```gdscript
# src/core/systems/investigation_system.gd
extends Node

class_name InvestigationSystem

class InvestigationData:
    var investigator: String
    var suspect: String
    var reason: String
    var start_time: float
    var evidence: Array = []
    var status: String = "active" # active, concluded, failed
    var conclusion: String = "" # innocent, suspicious, guilty
    var report_filed: bool = false

# Active investigations
var investigations: Dictionary = {} # {investigation_id: InvestigationData}
var investigation_counter: int = 0

# Investigation mechanics
export var base_investigation_duration: float = 2.0 # 2 hours
export var evidence_threshold: int = 3 # Evidence needed for conclusion

# Signals
signal investigation_started(investigation_id: String, data: InvestigationData)
signal evidence_found(investigation_id: String, evidence_type: String)
signal investigation_concluded(investigation_id: String, conclusion: String)
signal player_questioned(investigator_id: String, about: String)

func start_investigation(investigator_id: String, suspect_id: String, reason: String) -> String:
    var investigation = InvestigationData.new()
    investigation.investigator = investigator_id
    investigation.suspect = suspect_id
    investigation.reason = reason
    investigation.start_time = TimeManager.current_time
    
    investigation_counter += 1
    var investigation_id = "inv_%d" % investigation_counter
    investigations[investigation_id] = investigation
    
    # Configure investigator behavior
    var investigator = NPCRegistry.get_npc(investigator_id)
    if investigator:
        investigator.set_meta("active_investigation", investigation_id)
        investigator.set_state("INVESTIGATING")
    
    emit_signal("investigation_started", investigation_id, investigation)
    
    # Schedule investigation phases
    _schedule_investigation_phases(investigation_id)
    
    return investigation_id

func _schedule_investigation_phases(investigation_id: String):
    var investigation = investigations[investigation_id]
    
    # Phase 1: Initial questioning (30 minutes)
    EventManager.schedule_event({
        "type": "investigation_phase",
        "phase": "questioning",
        "investigation_id": investigation_id,
        "time": TimeManager.current_time + 0.5
    })
    
    # Phase 2: Evidence gathering (1 hour)
    EventManager.schedule_event({
        "type": "investigation_phase",
        "phase": "evidence_gathering",
        "investigation_id": investigation_id,
        "time": TimeManager.current_time + 1.0
    })
    
    # Phase 3: Conclusion (2 hours)
    EventManager.schedule_event({
        "type": "investigation_phase",
        "phase": "conclusion",
        "investigation_id": investigation_id,
        "time": TimeManager.current_time + base_investigation_duration
    })

func process_investigation_phase(investigation_id: String, phase: String):
    if not investigations.has(investigation_id):
        return
    
    var investigation = investigations[investigation_id]
    
    match phase:
        "questioning":
            _conduct_questioning(investigation)
        
        "evidence_gathering":
            _gather_evidence(investigation)
        
        "conclusion":
            _conclude_investigation(investigation)

func _conduct_questioning(investigation: InvestigationData):
    # Question suspect
    if investigation.suspect == "player":
        emit_signal("player_questioned", investigation.investigator, investigation.reason)
        return
    
    # NPC questioning
    var suspect = NPCRegistry.get_npc(investigation.suspect)
    if not suspect:
        return
    
    # Check if suspect is assimilated
    var is_assimilated = false
    if AssimilationManager.has_method("is_assimilated"):
        is_assimilated = AssimilationManager.is_assimilated(investigation.suspect)
    
    # Assimilated NPCs might coordinate stories
    if is_assimilated:
        var assimilation_data = AssimilationManager.get_assimilation_data(investigation.suspect)
        if assimilation_data.assimilation_type == "leader":
            # Leaders are excellent liars
            investigation.evidence.append({
                "type": "testimony",
                "content": "suspect_credible",
                "weight": -1 # Reduces suspicion
            })
        else:
            # Drones might slip up
            if randf() < 0.4:
                investigation.evidence.append({
                    "type": "testimony",
                    "content": "suspicious_behavior",
                    "weight": 1
                })

func _gather_evidence(investigation: InvestigationData):
    var investigator_skill = _get_investigator_skill(investigation.investigator)
    
    # Check player actions history
    if investigation.suspect == "player":
        var suspicious_actions = SuspicionManager.player_investigation_history
        for action in suspicious_actions:
            if randf() < investigator_skill:
                investigation.evidence.append({
                    "type": "witness_report",
                    "content": action.description,
                    "weight": action.severity
                })
                emit_signal("evidence_found", investigation.investigation_id, "witness_report")
    
    # Check for physical evidence
    if randf() < investigator_skill * 0.7:
        var location = NPCRegistry.get_npc(investigation.suspect).get_meta("last_location", "")
        if CrimeManager.has_crime_at_location(location):
            investigation.evidence.append({
                "type": "physical_evidence",
                "content": "crime_scene_connection",
                "weight": 2
            })
            emit_signal("evidence_found", investigation.investigation_id, "physical_evidence")
    
    # Check for digital evidence (in cyberpunk setting)
    if randf() < investigator_skill * 0.5:
        if EconomyManager.has_suspicious_transactions(investigation.suspect):
            investigation.evidence.append({
                "type": "financial_evidence",
                "content": "suspicious_transactions",
                "weight": 1
            })
            emit_signal("evidence_found", investigation.investigation_id, "financial_evidence")

func _conclude_investigation(investigation: InvestigationData):
    # Calculate total evidence weight
    var total_weight = 0
    for evidence in investigation.evidence:
        total_weight += evidence.weight
    
    # Determine conclusion
    if total_weight >= evidence_threshold:
        investigation.conclusion = "guilty"
        investigation.status = "concluded"
        
        # Increase suspicion significantly
        SuspicionManager.change_npc_suspicion(
            investigation.suspect,
            0.4,
            "investigation_guilty"
        )
    elif total_weight <= -evidence_threshold:
        investigation.conclusion = "innocent"
        investigation.status = "concluded"
        
        # Decrease suspicion
        SuspicionManager.change_npc_suspicion(
            investigation.suspect,
            -0.3,
            "investigation_cleared"
        )
    else:
        investigation.conclusion = "inconclusive"
        investigation.status = "concluded"
        
        # Slight suspicion increase
        SuspicionManager.change_npc_suspicion(
            investigation.suspect,
            0.1,
            "investigation_inconclusive"
        )
    
    # File report
    _file_investigation_report(investigation)
    
    # Reset investigator
    var investigator = NPCRegistry.get_npc(investigation.investigator)
    if investigator:
        investigator.remove_meta("active_investigation")
        investigator.set_state("IDLE")
    
    emit_signal("investigation_concluded", investigation.investigation_id, investigation.conclusion)

func _file_investigation_report(investigation: InvestigationData):
    investigation.report_filed = true
    
    # Share with security network
    SecuritySystem.file_investigation_report({
        "investigator": investigation.investigator,
        "suspect": investigation.suspect,
        "conclusion": investigation.conclusion,
        "evidence_count": investigation.evidence.size(),
        "date": TimeManager.current_day
    })
    
    # If guilty, trigger security response
    if investigation.conclusion == "guilty":
        SecuritySystem.flag_individual(investigation.suspect, "investigation_guilty")
```

### 3. Security System Integration

```gdscript
# src/core/systems/security_system_integration.gd
extends Node

class_name SecuritySystemIntegration

# Security infrastructure
var security_cameras: Dictionary = {} # {camera_id: camera_data}
var restricted_areas: Dictionary = {} # {area_id: access_requirements}
var security_checkpoints: Array = []
var flagged_individuals: Dictionary = {} # {npc_id: flag_data}

# Security personnel
var security_roster: Array = []
var patrol_routes: Dictionary = {}
var response_teams: Dictionary = {} # {team_id: team_data}

# Alert system
var current_alert_level: int = 0 # 0-5
var alert_history: Array = []
var active_incidents: Array = []

# Signals
signal camera_detection(camera_id: String, detected_id: String)
signal checkpoint_violation(checkpoint_id: String, violator_id: String)
signal security_response_dispatched(team_id: String, target_location: String)
signal individual_flagged(npc_id: String, reason: String)

func _ready():
    # Initialize security infrastructure
    _setup_security_cameras()
    _setup_restricted_areas()
    _setup_security_personnel()
    
    # Connect to other systems
    SuspicionManager.connect("npc_suspicion_critical", self, "_on_critical_suspicion")
    CrimeManager.connect("crime_reported", self, "_on_crime_reported")
    TimeManager.connect("hour_changed", self, "_on_hour_changed")

func _setup_security_cameras():
    # Define camera coverage by district
    var camera_configs = {
        "security_hq": {"coverage": 0.9, "detection_rate": 0.8},
        "research_labs": {"coverage": 0.8, "detection_rate": 0.7},
        "commercial_district": {"coverage": 0.6, "detection_rate": 0.5},
        "docks": {"coverage": 0.4, "detection_rate": 0.4},
        "residential": {"coverage": 0.3, "detection_rate": 0.3}
    }
    
    for district in camera_configs:
        _create_district_cameras(district, camera_configs[district])

func process_camera_detection(camera_id: String, npc_id: String):
    var camera = security_cameras[camera_id]
    
    # Check if individual is flagged
    if flagged_individuals.has(npc_id):
        var flag_data = flagged_individuals[npc_id]
        
        # Immediate alert
        emit_signal("camera_detection", camera_id, npc_id)
        
        # Increase suspicion based on flag severity
        var suspicion_increase = flag_data.severity * 0.2
        SuspicionManager.change_npc_suspicion(npc_id, suspicion_increase, "camera_detection")
        
        # Dispatch security if warranted
        if flag_data.severity >= 3:
            dispatch_security_team(camera.location, npc_id)
    
    # Random checks for suspicious behavior
    elif randf() < camera.detection_rate * 0.1:
        # Routine surveillance increases ambient suspicion
        SuspicionManager.change_npc_suspicion(npc_id, 0.05, "routine_surveillance")

func flag_individual(npc_id: String, reason: String, severity: int = 1):
    flagged_individuals[npc_id] = {
        "reason": reason,
        "severity": clamp(severity, 1, 5),
        "flag_date": TimeManager.current_day,
        "incidents": []
    }
    
    emit_signal("individual_flagged", npc_id, reason)
    
    # Notify security personnel
    for security_id in security_roster:
        var security_npc = NPCRegistry.get_npc(security_id)
        if security_npc:
            security_npc.add_to_watchlist(npc_id)

func dispatch_security_team(location: String, target_id: String = ""):
    # Find available team
    var available_team = _find_available_security_team()
    if not available_team:
        return
    
    # Configure response
    var response_data = {
        "team_id": available_team.id,
        "target_location": location,
        "target_individual": target_id,
        "dispatch_time": TimeManager.current_time,
        "response_type": _determine_response_type(target_id)
    }
    
    # Update team status
    available_team.status = "responding"
    available_team.current_mission = response_data
    
    # Move security NPCs
    for member_id in available_team.members:
        var member = NPCRegistry.get_npc(member_id)
        if member:
            member.set_state("RESPONDING")
            member.set_destination(location)
    
    emit_signal("security_response_dispatched", available_team.id, location)
    
    # Schedule arrival
    EventManager.schedule_event({
        "type": "security_arrival",
        "team_id": available_team.id,
        "location": location,
        "time": TimeManager.current_time + 0.25 # 15 minutes
    })

func update_alert_level(new_level: int, reason: String = ""):
    var old_level = current_alert_level
    current_alert_level = clamp(new_level, 0, 5)
    
    if old_level != current_alert_level:
        alert_history.append({
            "old_level": old_level,
            "new_level": current_alert_level,
            "reason": reason,
            "timestamp": TimeManager.current_time
        })
        
        # Update suspicion manager
        SuspicionManager.update_security_alert_level(current_alert_level)
        
        # Apply alert level effects
        _apply_alert_level_effects()

func _apply_alert_level_effects():
    match current_alert_level:
        0: # Green - Normal operations
            _set_checkpoint_strictness(0.2)
            _set_patrol_frequency(1.0)
        
        1: # Blue - Elevated
            _set_checkpoint_strictness(0.4)
            _set_patrol_frequency(1.2)
        
        2: # Yellow - High
            _set_checkpoint_strictness(0.6)
            _set_patrol_frequency(1.5)
            _activate_additional_cameras()
        
        3: # Orange - Severe
            _set_checkpoint_strictness(0.8)
            _set_patrol_frequency(2.0)
            _double_security_teams()
        
        4: # Red - Critical
            _set_checkpoint_strictness(1.0)
            _set_patrol_frequency(3.0)
            _lockdown_sensitive_areas()
        
        5: # Black - Maximum
            _initiate_station_lockdown()
```

### 4. District-Based Suspicion

```gdscript
# src/core/systems/district_suspicion_manager.gd
extends Node

class_name DistrictSuspicionManager

# District suspicion tracking
var district_base_suspicion: Dictionary = {}
var district_current_suspicion: Dictionary = {}
var district_events: Dictionary = {} # Recent events affecting suspicion
var district_security_presence: Dictionary = {}

# Environmental factors
var time_of_day_modifiers: Dictionary = {
    "night": 1.2,      # 22:00 - 06:00
    "morning": 0.9,    # 06:00 - 12:00
    "afternoon": 1.0,  # 12:00 - 18:00
    "evening": 1.1     # 18:00 - 22:00
}

# District type configurations
var district_type_configs: Dictionary = {
    "residential": {
        "base_suspicion": 0.1,
        "decay_rate": 0.08,
        "spread_rate": 0.4,
        "max_suspicion": 0.7
    },
    "commercial": {
        "base_suspicion": 0.2,
        "decay_rate": 0.05,
        "spread_rate": 0.3,
        "max_suspicion": 0.8
    },
    "industrial": {
        "base_suspicion": 0.15,
        "decay_rate": 0.06,
        "spread_rate": 0.2,
        "max_suspicion": 0.6
    },
    "security": {
        "base_suspicion": 0.4,
        "decay_rate": 0.02,
        "spread_rate": 0.5,
        "max_suspicion": 1.0
    },
    "research": {
        "base_suspicion": 0.3,
        "decay_rate": 0.04,
        "spread_rate": 0.35,
        "max_suspicion": 0.9
    }
}

func initialize_district(district_id: String, district_type: String):
    var config = district_type_configs.get(district_type, district_type_configs["commercial"])
    
    district_base_suspicion[district_id] = config.base_suspicion
    district_current_suspicion[district_id] = config.base_suspicion
    district_events[district_id] = []
    district_security_presence[district_id] = _calculate_security_presence(district_type)

func modify_district_suspicion(district_id: String, amount: float, reason: String):
    if not district_current_suspicion.has(district_id):
        return
    
    var old_value = district_current_suspicion[district_id]
    var district_type = DistrictManager.get_district_type(district_id)
    var config = district_type_configs.get(district_type, district_type_configs["commercial"])
    
    # Apply time of day modifier
    var time_modifier = _get_time_of_day_modifier()
    amount *= time_modifier
    
    # Apply security presence modifier
    var security_modifier = 1.0 + (district_security_presence[district_id] * 0.5)
    amount *= security_modifier
    
    # Update suspicion
    district_current_suspicion[district_id] = clamp(
        old_value + amount,
        config.base_suspicion,
        config.max_suspicion
    )
    
    # Log event
    district_events[district_id].append({
        "reason": reason,
        "amount": amount,
        "time": TimeManager.current_time
    })
    
    # Limit event history
    if district_events[district_id].size() > 20:
        district_events[district_id].pop_front()
    
    # Spread to adjacent districts
    _spread_suspicion_to_adjacent(district_id, amount * config.spread_rate)
    
    # Update NPCs in district
    _update_district_npc_suspicion(district_id, amount * 0.5)

func _spread_suspicion_to_adjacent(source_district: String, amount: float):
    var adjacent = DistrictManager.get_adjacent_districts(source_district)
    
    for adj_district in adjacent:
        if adj_district != source_district:
            modify_district_suspicion(adj_district, amount * 0.5, "spread_from_" + source_district)

func process_hourly_decay():
    for district_id in district_current_suspicion:
        var district_type = DistrictManager.get_district_type(district_id)
        var config = district_type_configs.get(district_type, district_type_configs["commercial"])
        
        # Natural decay toward base
        var current = district_current_suspicion[district_id]
        var base = district_base_suspicion[district_id]
        var decay = (current - base) * config.decay_rate
        
        if abs(decay) > 0.01:
            modify_district_suspicion(district_id, -decay, "natural_decay")

func get_player_district_modifier() -> float:
    var player_district = DistrictManager.get_player_district()
    if not player_district:
        return 1.0
    
    return district_current_suspicion.get(player_district, 0.2)
```

### 5. Behavioral Response System

```gdscript
# src/core/systems/suspicion_behaviors.gd
extends Node

class_name SuspicionBehaviors

# Behavior configurations by suspicion tier
static func get_tier_behaviors(tier: String) -> Dictionary:
    var behaviors = {
        "none": {
            "dialog_modifier": 1.0,
            "movement_speed": 1.0,
            "interaction_willingness": 1.0,
            "special_actions": []
        },
        "low": {
            "dialog_modifier": 0.9,
            "movement_speed": 1.1,
            "interaction_willingness": 0.8,
            "special_actions": ["glance_at_player", "whisper_to_others"]
        },
        "medium": {
            "dialog_modifier": 0.7,
            "movement_speed": 1.2,
            "interaction_willingness": 0.5,
            "special_actions": ["avoid_player", "report_to_security", "gather_in_groups"]
        },
        "high": {
            "dialog_modifier": 0.4,
            "movement_speed": 1.4,
            "interaction_willingness": 0.2,
            "special_actions": ["flee_from_player", "call_security", "spread_warnings"]
        },
        "critical": {
            "dialog_modifier": 0.0,
            "movement_speed": 1.6,
            "interaction_willingness": 0.0,
            "special_actions": ["panic", "lockdown_area", "coordinate_capture"]
        }
    }
    
    return behaviors.get(tier, behaviors["none"])

# Apply suspicion-based dialog modifications
static func modify_dialog_for_suspicion(base_dialog: Dictionary, suspicion_tier: String) -> Dictionary:
    var modified = base_dialog.duplicate(true)
    
    match suspicion_tier:
        "low":
            # Slightly guarded responses
            modified["greeting"] = [
                "Oh... hello.",
                "Can I help you?",
                "What do you want?"
            ]
            modified["tone"] = "guarded"
        
        "medium":
            # Actively suspicious
            modified["greeting"] = [
                "Stay back!",
                "I don't want any trouble.",
                "Security is on their way."
            ]
            modified["refuse_interaction"] = true
            modified["tone"] = "hostile"
        
        "high":
            # Panicked responses
            modified["greeting"] = [
                "Get away from me!",
                "SECURITY! HELP!",
                "I know what you are!"
            ]
            modified["force_end_dialog"] = true
            modified["tone"] = "panicked"
        
        "critical":
            # No dialog, only actions
            modified["no_dialog"] = true
            modified["immediate_action"] = "flee_or_attack"
    
    return modified

# Group behavior when suspicion is high
static func coordinate_group_response(suspicious_npcs: Array, threat_location: Vector2):
    if suspicious_npcs.size() < 3:
        return # Need at least 3 for group behavior
    
    # Determine group action based on composition
    var security_count = 0
    var civilian_count = 0
    var assimilated_count = 0
    
    for npc_id in suspicious_npcs:
        var npc_data = NPCRegistry.get_npc_data(npc_id)
        if "security" in npc_data.role:
            security_count += 1
        elif AssimilationManager.is_assimilated(npc_id):
            assimilated_count += 1
        else:
            civilian_count += 1
    
    # Security-heavy groups attempt capture
    if security_count >= suspicious_npcs.size() / 2:
        _coordinate_capture_attempt(suspicious_npcs, threat_location)
    
    # Assimilated-heavy groups set traps
    elif assimilated_count >= suspicious_npcs.size() / 2:
        _coordinate_assimilated_trap(suspicious_npcs, threat_location)
    
    # Civilian-heavy groups flee and spread panic
    else:
        _coordinate_civilian_panic(suspicious_npcs, threat_location)

static func _coordinate_capture_attempt(npcs: Array, target: Vector2):
    # Form perimeter
    var positions = _calculate_surrounding_positions(target, npcs.size())
    
    for i in range(npcs.size()):
        var npc = NPCRegistry.get_npc(npcs[i])
        if npc:
            npc.set_state("PURSUING")
            npc.set_destination(positions[i])
            npc.set_meta("capture_target", target)

static func _coordinate_assimilated_trap(npcs: Array, target: Vector2):
    # Assimilated pretend to be helpful while leading into trap
    for npc_id in npcs:
        var npc = NPCRegistry.get_npc(npc_id)
        if npc:
            if AssimilationManager.get_assimilation_data(npc_id).assimilation_type == "leader":
                # Leaders maintain cover
                npc.set_meta("deceptive_mode", true)
                npc.personality.friendliness = 0.9 # Appear helpful
            else:
                # Drones create distraction
                npc.set_state("HOSTILE")
                npc.create_disturbance()
```

### 6. Advanced Serialization

```gdscript
# src/core/serializers/suspicion_serializer_full.gd
extends BaseSerializer

class_name SuspicionSerializerFull

func _ready():
    # Register with high priority (critical system)
    SaveManager.register_serializer("suspicion_full", self, 10)

func get_version() -> int:
    return 2 # Version 2 for full implementation

func serialize() -> Dictionary:
    var data = {
        # MVP data (backward compatible)
        "global_level": SuspicionManager.global_suspicion_level,
        "npc_suspicion": _serialize_npc_suspicion(),
        
        # Full implementation data
        "district_suspicion": SuspicionManager.district_suspicion,
        "district_modifiers": SuspicionManager.district_modifiers,
        "security_alert": SuspicionManager.security_alert_level,
        "suspicion_networks": _compress_networks(),
        "active_investigations": _serialize_investigations(),
        "flagged_individuals": SecuritySystemIntegration.flagged_individuals,
        "investigation_history": SuspicionManager.player_investigation_history.slice(-20, -1) # Last 20 events
    }
    
    return data

func deserialize(data: Dictionary) -> void:
    # MVP data
    SuspicionManager.global_suspicion_level = data.get("global_level", 0.0)
    _deserialize_npc_suspicion(data.get("npc_suspicion", {}))
    
    # Full implementation data
    if data.has("district_suspicion"):
        SuspicionManager.district_suspicion = data.district_suspicion
        SuspicionManager.district_modifiers = data.get("district_modifiers", {})
        SuspicionManager.security_alert_level = data.get("security_alert", 0)
        _decompress_networks(data.get("suspicion_networks", {}))
        _deserialize_investigations(data.get("active_investigations", {}))
        SecuritySystemIntegration.flagged_individuals = data.get("flagged_individuals", {})
        SuspicionManager.player_investigation_history = data.get("investigation_history", [])

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    if from_version == 1 and to_version == 2:
        # Add full implementation fields
        data["district_suspicion"] = {}
        data["district_modifiers"] = {}
        data["security_alert"] = 0
        data["suspicion_networks"] = {}
        data["active_investigations"] = {}
        data["flagged_individuals"] = {}
        data["investigation_history"] = []
        
        # Initialize district suspicion from global
        var global_level = data.get("global_level", 0.0)
        for district in DistrictManager.get_all_districts():
            data["district_suspicion"][district] = global_level * 0.8
    
    return data

func _compress_networks() -> Dictionary:
    var compressed = {}
    for anchor in SuspicionManager.suspicion_networks:
        var network = SuspicionManager.suspicion_networks[anchor]
        if network.size() > 0:
            compressed[anchor] = network
    return compressed

func _serialize_investigations() -> Dictionary:
    var serialized = {}
    for inv_id in InvestigationSystem.investigations:
        var inv = InvestigationSystem.investigations[inv_id]
        if inv.status == "active":
            serialized[inv_id] = {
                "i": inv.investigator,
                "s": inv.suspect,
                "r": inv.reason,
                "t": inv.start_time,
                "e": inv.evidence.size() # Just count, not full data
            }
    return serialized
```

## Integration Points

### 1. Dialog System Integration
- Suspicious NPCs use modified dialog trees
- Investigation questions appear when player is under investigation
- Collective pronouns from assimilated NPCs increase area suspicion
- High suspicion NPCs refuse interaction

### 2. Assimilation System Integration
- Assimilated leaders can manipulate investigations
- Drone crimes increase district suspicion
- Network effects stronger among assimilated
- Discovery of assimilation reduces suspicion spread

### 3. Coalition System Integration
- Coalition members share suspicion information
- Protected NPCs have reduced suspicion gain
- Safe houses reset player suspicion when used
- Coalition size reduces overall suspicion growth

### 4. Time Management Integration
- Hourly district suspicion decay
- Time of day affects suspicion modifiers
- Investigations progress with time
- Security shifts affect coverage

### 5. Economy System Integration
- High suspicion affects trading prices
- Security alerts impact district economy
- Investigations check financial records
- Bribes can reduce suspicion (with risk)

### 6. Detection/Game Over Integration
- Critical suspicion triggers immediate detection
- Investigation conclusions affect detection speed
- Security alerts increase detection radius
- Flagged individuals detected faster

## UI Components

### 1. Enhanced Suspicion Meter
```gdscript
# Additions to existing meter
- District suspicion overlay
- Security alert indicator
- Investigation warning icon
- Network suspicion visualization
```

### 2. Investigation UI
```gdscript
# New UI component
- Active investigation panel
- Evidence counter
- Time until conclusion
- Investigator location indicator
```

### 3. District Heat Map
```gdscript
# Visual overlay showing district suspicion
- Color-coded districts
- Suspicion flow animations
- Security presence indicators
- Safe zone highlighting
```

## Balancing Parameters

### Suspicion Growth Rates
- Base action: +0.05
- Suspicious dialog: +0.1
- Caught in restricted area: +0.2
- Witnessed crime: +0.3
- Failed investigation: +0.4
- Direct accusation: +0.5

### Suspicion Decay Rates
- Individual NPC: -0.05/second
- District base: -0.02/hour
- Network propagation: 0.8x per hop
- Investigation cleared: -0.3 instant

### Investigation Durations
- Quick check: 30 minutes
- Standard investigation: 2 hours
- Deep investigation: 6 hours
- Financial audit: 12 hours

### Security Alert Thresholds
- Level 1: 20% NPCs suspicious
- Level 2: 40% NPCs suspicious
- Level 3: Any critical suspicion
- Level 4: Active investigation on player
- Level 5: Multiple investigations or violence

## Testing Scenarios

### 1. Individual Suspicion
- Test personality modifiers apply correctly
- Verify state transitions at thresholds
- Check decay rates with modifiers
- Confirm role-based differences

### 2. Network Effects
- Test suspicion spread through connections
- Verify degradation over social distance
- Check network formation logic
- Test information persistence

### 3. District Dynamics
- Test inter-district spread
- Verify time-of-day modifiers
- Check security presence effects
- Test maximum thresholds

### 4. Investigation Flow
- Test all investigation phases
- Verify evidence gathering
- Check conclusion logic
- Test player questioning events

### 5. Security Integration
- Test camera detection
- Verify flagging system
- Check response team dispatch
- Test alert level transitions

### 6. Save/Load
- Test full serialization
- Verify migration from MVP
- Check investigation persistence
- Test network reconstruction

## Performance Optimizations

1. **Update Frequencies**
   - Individual suspicion: On change only
   - District suspicion: Hourly batch
   - Network propagation: Queued processing
   - Investigations: Event-driven

2. **Data Structures**
   - Compress networks in save data
   - Cache frequently accessed calculations
   - Limit investigation history size
   - Prune old district events

3. **AI Optimizations**
   - Group similar NPCs for batch updates
   - Limit investigation NPCs active at once
   - Cache pathfinding for security teams
   - Reduce network recalculation frequency

## Future Expansion Hooks

1. **Psychological Profiles**
   - NPCs remember who made them suspicious
   - Paranoid NPCs form suspicion networks faster
   - Trust relationships counter suspicion

2. **Advanced Investigations**
   - Multi-stage investigations
   - Collaborative investigations
   - Player can investigate NPCs
   - False evidence planting

3. **Environmental Suspicion**
   - Suspicious areas independent of NPCs
   - Environmental clues increase area suspicion
   - Time-based suspicion events

4. **Counter-Suspicion Mechanics**
   - Active measures to reduce suspicion
   - Misinformation campaigns
   - Scapegoat mechanics
   - Memory modification (late game)

This full suspicion system creates a living, breathing station where paranoia spreads naturally through social networks, investigations create dynamic story moments, and player actions have lasting consequences on the social fabric of the station. The system maintains complete compatibility with the existing MVP while adding layers of strategic depth and emergent gameplay.