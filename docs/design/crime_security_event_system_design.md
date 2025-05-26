# Crime/Security Event System Design Document

## Overview

The Crime/Security Event System creates dynamic criminal incidents throughout the station, scaling with assimilation spread. Beginning with the First Quest's mall patrol puzzle, the system generates crimes committed by drones that create opportunities for player investigation, security interaction, and moral choices while demonstrating the deteriorating social order as assimilation spreads.

## Core Design Principles

### Dynamic Crime Generation
- Crimes increase proportionally with drone population
- 70% daily chance for each drone to commit a crime
- Leaders coordinate synchronized crime waves
- Crime severity escalates with station corruption

### Player Agency
- Witness crimes in progress or discover aftermath
- Choose to report, intervene, or exploit situations
- Use crimes as investigation opportunities
- Balance safety with information gathering

### System Integration
- Leverages Living World Event System for scheduling
- Driven by Assimilation System's drone behaviors
- Affects Economy System through property values
- Creates content for Investigation/Clue Tracking

## System Architecture

### Component Structure

```gdscript
# src/core/systems/crime_security_event_system.gd
extends Node

class_name CrimeSecurityEventSystem

signal crime_scheduled(crime_data: CrimeEvent)
signal crime_occurred(crime_data: CrimeEvent) 
signal crime_witnessed(crime_data: CrimeEvent, witness_id: String)
signal crime_reported(crime_data: CrimeEvent, reporter_id: String)
signal security_response(location: String, severity: int)
signal patrol_encounter(location: String, security_npc: String)

# Crime types matching Assimilation System
enum CrimeType {
    VANDALISM,    # Property damage, graffiti
    THEFT,        # Stealing from shops/NPCs
    DISTURBANCE,  # Public disruption
    ASSAULT,      # Violence against NPCs
    SABOTAGE      # System/infrastructure damage
}

# Crime event data
class CrimeEvent:
    var id: String = ""
    var type: int = CrimeType.VANDALISM
    var severity: int = 1  # 1-5 scale
    var perpetrator_id: String = ""  # Drone NPC ID
    var victim_id: String = ""  # If applicable
    var location: String = ""
    var district: String = ""
    var scheduled_time: int = 0
    var occurred: bool = false
    var discovered: bool = false
    var reported: bool = false
    var witnesses: Array = []  # NPC IDs who saw it
    var evidence: Dictionary = {}  # Clues left behind
    var coordinated: bool = false  # Part of leader plan
    var economic_damage: int = 0
```

### Integration with Living World Events

```gdscript
func _ready():
    # Subscribe to event system
    EventScheduler.connect("process_event", self, "_on_event_process")
    
    # Subscribe to assimilation changes
    AssimilationManager.connect("npc_assimilated", self, "_on_npc_assimilated")
    AssimilationManager.connect("leader_assigned", self, "_on_leader_assigned")
    
    # Subscribe to time signals
    TimeManager.connect("time_advanced", self, "_check_patrol_schedules")

func schedule_drone_crime(drone_id: String) -> void:
    var drone = NPCManager.get_npc(drone_id)
    if not drone or not drone.is_assimilated:
        return
    
    # 70% chance as per Assimilation System
    if randf() > 0.7:
        return
    
    var crime = CrimeEvent.new()
    crime.id = "crime_" + str(Time.get_ticks_msec())
    crime.perpetrator_id = drone_id
    crime.type = _select_crime_type(drone)
    crime.severity = _calculate_severity(drone)
    crime.location = _select_crime_location(drone)
    crime.district = DistrictManager.get_district_for_location(crime.location)
    
    # Schedule at random time today
    var time_offset = randi() % (18 * 60)  # 6 AM to midnight
    crime.scheduled_time = TimeManager.get_current_minutes() + time_offset
    
    # Register with event system
    var event_data = {
        "type": "crime",
        "crime_data": crime,
        "location": crime.location,
        "actors": [drone_id],
        "discoverable": true
    }
    
    EventScheduler.schedule_event(
        crime.scheduled_time,
        "crime_event",
        event_data
    )
    
    emit_signal("crime_scheduled", crime)
```

## Crime Types and Behaviors

### Vandalism
```gdscript
func execute_vandalism(crime: CrimeEvent) -> void:
    var location_data = LocationManager.get_location(crime.location)
    
    # Leave visible damage
    location_data.add_damage("graffiti_" + crime.id, {
        "type": "graffiti",
        "message": _generate_drone_message(),
        "severity": crime.severity
    })
    
    # Economic impact
    crime.economic_damage = crime.severity * 50
    EconomyManager.reduce_property_value(crime.district, crime.economic_damage)
    
    # Evidence
    crime.evidence["graffiti_style"] = "drone_pattern_" + str(crime.severity)
    crime.evidence["time_window"] = TimeManager.get_time_string()
    
    # Chance of being caught in act
    if randf() < 0.3:
        _check_for_witnesses(crime)
```

### Theft
```gdscript
func execute_theft(crime: CrimeEvent) -> void:
    # Select victim (shop or NPC)
    var victim = _select_theft_victim(crime.location)
    crime.victim_id = victim.id
    
    if victim.type == "shop":
        # Steal items
        var stolen_value = crime.severity * 100
        ShopManager.report_theft(victim.id, stolen_value)
        crime.economic_damage = stolen_value
        
        # Evidence
        crime.evidence["missing_items"] = true
        crime.evidence["forced_entry"] = crime.severity > 3
    else:
        # Pickpocket NPC
        var npc = NPCManager.get_npc(victim.id)
        var stolen = min(npc.credits, crime.severity * 75)
        npc.credits -= stolen
        crime.economic_damage = stolen
        
        # May alert victim
        if randf() < 0.4:
            npc.add_dialog_option("I was robbed!", "theft_victim")
            crime.witnesses.append(victim.id)
```

### Assault
```gdscript
func execute_assault(crime: CrimeEvent) -> void:
    # Select victim NPC
    var victim = _select_assault_victim(crime.location)
    if not victim:
        return
    
    crime.victim_id = victim.id
    crime.severity = max(3, crime.severity)  # Assault is always serious
    
    # Apply injury
    victim.apply_injury("assault_" + crime.id, {
        "severity": crime.severity,
        "visible": true,
        "dialog_change": true
    })
    
    # High chance of witnesses
    _check_for_witnesses(crime, 0.8)
    
    # Immediate security response if witnessed
    if crime.witnesses.size() > 0:
        _trigger_security_response(crime, true)
    
    # Victim becomes evidence
    crime.evidence["injured_npc"] = victim.id
    crime.evidence["injury_type"] = "blunt_trauma"
```

### Sabotage
```gdscript
func execute_sabotage(crime: CrimeEvent) -> void:
    var target = _select_sabotage_target(crime.district)
    
    match target.type:
        "power":
            DistrictManager.disable_power(crime.district, crime.severity * 30)
            crime.evidence["power_outage"] = true
        
        "transport":
            TramSystem.disable_route(crime.district, crime.severity * 60)
            crime.evidence["tram_malfunction"] = true
        
        "communication":
            CommunicationSystem.jam_district(crime.district, crime.severity * 45)
            crime.evidence["comm_interference"] = true
    
    crime.economic_damage = crime.severity * 200
    
    # Sabotage always triggers investigation
    _schedule_security_investigation(crime)
```

## Mall Patrol Puzzle (First Quest)

### Patrol Implementation
```gdscript
class SecurityPatrol:
    var patrol_id: String = ""
    var security_npc: String = ""
    var route: Array = []  # Waypoints
    var schedule: Dictionary = {}  # Time windows
    var current_waypoint: int = 0
    var alert_level: int = 0  # 0=routine, 1=suspicious, 2=alert
    var detection_radius: float = 100.0

func initialize_mall_patrol() -> void:
    # Create patrol for First Quest
    var patrol = SecurityPatrol.new()
    patrol.patrol_id = "mall_security_01"
    patrol.security_npc = "guard_johnson"
    patrol.route = [
        "mall_entrance",
        "mall_fountain", 
        "mall_shops_east",
        "mall_food_court",
        "mall_shops_west",
        "mall_entrance"
    ]
    patrol.schedule = {
        "start": 8 * 60,  # 8 AM
        "end": 22 * 60,   # 10 PM
        "frequency": 30    # Every 30 minutes
    }
    
    active_patrols[patrol.patrol_id] = patrol
    
    # Schedule first patrol
    _schedule_next_patrol(patrol)

func _process_patrol_movement(patrol: SecurityPatrol, delta: float) -> void:
    var guard = NPCManager.get_npc(patrol.security_npc)
    if not guard:
        return
    
    var target = LocationManager.get_waypoint(patrol.route[patrol.current_waypoint])
    var distance = guard.global_position.distance_to(target.position)
    
    if distance < 10.0:
        # Reached waypoint
        patrol.current_waypoint = (patrol.current_waypoint + 1) % patrol.route.size()
        
        # Check area
        _patrol_area_check(patrol, target)
    
    # Check for player detection
    if _can_detect_player(patrol, guard):
        _handle_player_detection(patrol)
```

### Player Detection During Patrol
```gdscript
func _can_detect_player(patrol: SecurityPatrol, guard: BaseNPC) -> bool:
    var player = GameManager.get_player()
    var distance = guard.global_position.distance_to(player.global_position)
    
    if distance > patrol.detection_radius:
        return false
    
    # Check line of sight
    if not _has_line_of_sight(guard, player):
        return false
    
    # Check disguise
    if DisguiseManager.current_role == "security_guard":
        return false  # Blend in
    
    # Check suspicious behavior
    var suspicion_modifier = 1.0
    if player.is_running:
        suspicion_modifier *= 2.0
    if player.is_carrying_suspicious_item():
        suspicion_modifier *= 1.5
    
    return randf() < (0.5 * suspicion_modifier)

func _handle_player_detection(patrol: SecurityPatrol) -> void:
    patrol.alert_level = min(2, patrol.alert_level + 1)
    
    match patrol.alert_level:
        0:
            # Routine - shouldn't happen
            pass
        1:
            # Suspicious
            emit_signal("patrol_encounter", patrol.security_npc, "suspicious")
            _show_security_dialog("suspicious", patrol.security_npc)
        2:
            # Alert
            emit_signal("patrol_encounter", patrol.security_npc, "alert")
            _trigger_security_alert(patrol)
```

## Security Response System

### Response Escalation
```gdscript
func _trigger_security_response(crime: CrimeEvent, immediate: bool = false) -> void:
    var response_time = 0 if immediate else _calculate_response_time(crime)
    
    var response_event = {
        "type": "security_response",
        "crime_id": crime.id,
        "location": crime.location,
        "severity": crime.severity,
        "response_units": _calculate_units_needed(crime)
    }
    
    if immediate:
        _execute_security_response(response_event)
    else:
        EventScheduler.schedule_event(
            TimeManager.get_current_minutes() + response_time,
            "security_response",
            response_event
        )

func _execute_security_response(event_data: Dictionary) -> void:
    var location = event_data.location
    var units = event_data.response_units
    
    # Spawn security NPCs
    for i in range(units):
        var guard = NPCManager.spawn_temporary_npc(
            "security_responder_%d" % i,
            "security_guard",
            location
        )
        guard.set_state("investigating")
        guard.investigation_target = event_data.crime_id
    
    # Increase area security level
    LocationManager.set_security_level(location, 2)
    
    # Check if player is in area
    if GameManager.current_location == location:
        _handle_player_in_crime_scene(event_data)
```

### Crime Discovery
```gdscript
func discover_crime(crime_id: String, discoverer_id: String) -> void:
    var crime = get_crime(crime_id)
    if not crime or crime.discovered:
        return
    
    crime.discovered = true
    crime.witnesses.append(discoverer_id)
    
    # Check if discoverer reports it
    var discoverer = NPCManager.get_npc(discoverer_id)
    if discoverer:
        # Drones don't report drone crimes
        if discoverer.is_assimilated and crime.perpetrator_id in AssimilationManager.get_drone_ids():
            return
        
        # Law-abiding citizens report crimes
        if discoverer.personality.lawfulness > 60:
            _report_crime(crime, discoverer_id)
        
        # Add dialog option about crime
        discoverer.add_temporary_dialog("witnessed_crime", {
            "crime_type": CrimeType.keys()[crime.type],
            "location": crime.location
        })
```

## Integration with Other Systems

### Quest Integration
```gdscript
func create_investigation_quest(crime: CrimeEvent) -> void:
    if crime.severity < 3:  # Only major crimes
        return
    
    var quest_data = {
        "id": "investigate_" + crime.id,
        "name": "Investigate " + CrimeType.keys()[crime.type],
        "category": "investigation",
        "auto_assign": false,
        "clue_sources": {}
    }
    
    # Add clues based on evidence
    for evidence_type in crime.evidence:
        var clue_id = "evidence_" + evidence_type + "_" + crime.id
        quest_data.clue_sources[clue_id] = crime.location
    
    QuestManager.add_dynamic_quest(quest_data)
```

### Economy Impact
```gdscript
func apply_crime_economic_impact(crime: CrimeEvent) -> void:
    # Direct damage
    EconomyManager.reduce_district_value(crime.district, crime.economic_damage)
    
    # Ongoing effects
    match crime.type:
        CrimeType.VANDALISM:
            # Reduces property values
            EconomyManager.add_district_modifier(crime.district, "vandalism", -0.05)
        
        CrimeType.THEFT:
            # Increases prices
            EconomyManager.add_district_modifier(crime.district, "theft_premium", 0.1)
        
        CrimeType.ASSAULT:
            # Reduces foot traffic
            DistrictManager.reduce_npc_traffic(crime.district, 0.3)
```

### Assimilation Coordination
```gdscript
func coordinate_crime_wave(leader_id: String) -> void:
    var leader = NPCManager.get_npc(leader_id)
    if not leader or not leader.is_leader:
        return
    
    var drones = AssimilationManager.get_leader_drones(leader_id)
    var target_district = _select_target_district()
    
    # Schedule synchronized crimes
    var wave_time = TimeManager.get_current_minutes() + (randi() % 120)
    var crime_types = [CrimeType.VANDALISM, CrimeType.THEFT, CrimeType.DISTURBANCE]
    
    for i in range(min(drones.size(), 5)):  # Max 5 simultaneous
        var crime = CrimeEvent.new()
        crime.id = "coordinated_" + leader_id + "_" + str(i)
        crime.perpetrator_id = drones[i]
        crime.type = crime_types[i % crime_types.size()]
        crime.severity = 3  # Coordinated crimes are serious
        crime.location = _select_location_in_district(target_district)
        crime.district = target_district
        crime.scheduled_time = wave_time + (i * 2)  # Stagger by 2 minutes
        crime.coordinated = true
        
        _schedule_crime(crime)
    
    # Alert security after wave
    EventScheduler.schedule_event(
        wave_time + 10,
        "security_alert",
        {
            "alert_level": 2,
            "district": target_district,
            "reason": "multiple_incidents"
        }
    )
```

## Player Interactions

### Witnessing Crimes
```gdscript
func _on_player_witness_crime(crime: CrimeEvent) -> void:
    # Show crime happening
    UI.show_crime_notification(crime)
    
    # Player choices
    var choices = []
    
    # Always can observe
    choices.append({
        "text": "Watch what happens",
        "action": "observe",
        "consequence": "gather_evidence"
    })
    
    # Can intervene if not too dangerous
    if crime.severity <= 3:
        choices.append({
            "text": "Try to stop them",
            "action": "intervene",
            "consequence": "risk_detection"
        })
    
    # Can report if near communication
    if LocationManager.has_nearby_comm_terminal():
        choices.append({
            "text": "Report to security",
            "action": "report",
            "consequence": "security_response"
        })
    
    # Can flee
    choices.append({
        "text": "Leave quickly",
        "action": "flee",
        "consequence": "avoid_involvement"
    })
    
    UI.show_choice_prompt("Crime in progress!", choices)
```

### Security Dialogs
```gdscript
func _show_security_dialog(encounter_type: String, guard_id: String) -> void:
    var guard = NPCManager.get_npc(guard_id)
    var dialog_tree = {}
    
    match encounter_type:
        "suspicious":
            dialog_tree = {
                "start": {
                    "text": "Hold on there. What's your business here?",
                    "responses": [
                        {
                            "text": "Just shopping",
                            "requires": {},
                            "next": "shopping_check"
                        },
                        {
                            "text": "I work here",
                            "requires": {"item": "mall_employee_badge"},
                            "next": "employee_verify"
                        },
                        {
                            "text": "[Bribe] Here's 50 credits to forget you saw me",
                            "requires": {"credits": 50},
                            "next": "bribe_attempt"
                        }
                    ]
                }
            }
        
        "alert":
            dialog_tree = {
                "start": {
                    "text": "Security! Stop right there!",
                    "responses": [
                        {
                            "text": "[Run]",
                            "requires": {},
                            "next": "chase_sequence"
                        },
                        {
                            "text": "[Surrender]",
                            "requires": {},
                            "next": "detention"
                        }
                    ]
                }
            }
    
    DialogManager.start_dialog(guard, dialog_tree)
```

## Serialization

```gdscript
# src/core/serializers/crime_security_serializer.gd
extends BaseSerializer

class_name CrimeSecuritySerializer

func get_serializer_id() -> String:
    return "crime_security"

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("crime_security", self, 50)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "active_crimes": _serialize_active_crimes(),
        "crime_history": _serialize_crime_history(),
        "patrol_states": _serialize_patrols(),
        "security_levels": LocationManager.get_all_security_levels(),
        "player_security_record": _serialize_player_record(),
        "district_crime_stats": _serialize_district_stats()
    }

func deserialize(data: Dictionary) -> void:
    if "active_crimes" in data:
        _deserialize_active_crimes(data.active_crimes)
    
    if "patrol_states" in data:
        _deserialize_patrols(data.patrol_states)
    
    if "security_levels" in data:
        LocationManager.set_all_security_levels(data.security_levels)
    
    if "player_security_record" in data:
        _deserialize_player_record(data.player_security_record)
```

## Crime Statistics and Tracking

```gdscript
# Track crime trends for narrative
var crime_statistics = {
    "total_crimes": 0,
    "crimes_by_type": {},
    "crimes_by_district": {},
    "reported_crimes": 0,
    "solved_crimes": 0,
    "player_interventions": 0,
    "economic_impact": 0
}

func update_crime_stats(crime: CrimeEvent) -> void:
    crime_statistics.total_crimes += 1
    
    var type_key = CrimeType.keys()[crime.type]
    if not crime_statistics.crimes_by_type.has(type_key):
        crime_statistics.crimes_by_type[type_key] = 0
    crime_statistics.crimes_by_type[type_key] += 1
    
    if not crime_statistics.crimes_by_district.has(crime.district):
        crime_statistics.crimes_by_district[crime.district] = 0
    crime_statistics.crimes_by_district[crime.district] += 1
    
    crime_statistics.economic_impact += crime.economic_damage
    
    # Check for station breakdown threshold
    if crime_statistics.total_crimes > 100:
        EventScheduler.trigger_event("social_breakdown")
```

## Performance Considerations

1. **Event Batching**
   - Process crimes in 15-minute chunks
   - Limit simultaneous crimes to 10
   - Cull old crime records after 7 days

2. **Patrol Optimization**
   - Only process patrols in active districts
   - Use distance checks before line-of-sight
   - Cache patrol routes

3. **Crime Aftermath**
   - Persist only significant crimes
   - Clean up evidence after discovery
   - Merge similar crimes in same location

## Testing Scenarios

1. **First Quest Mall Patrol**
   - Test patrol route timing
   - Verify detection mechanics
   - Check disguise bypass

2. **Crime Wave Coordination**
   - Spawn leader and drones
   - Trigger coordinated crime
   - Verify security response

3. **Economic Impact**
   - Generate various crimes
   - Check district value changes
   - Verify price modifications

## Template Compliance

### NPC Template Integration
Security NPCs and criminals follow `template_npc_design.md`:
- Security guards use the full NPC state machine with patrol states
- Criminal NPCs (especially drones) use modified behavioral states
- All NPCs maintain schedules that integrate with patrol/crime timing
- Dialog generation reflects their security role or criminal behavior
- Assimilation states properly affect security/criminal behaviors

Security-specific extensions:
- Additional states for PATROLLING, INVESTIGATING, PURSUING
- Enhanced observation mechanics for detecting crimes
- Memory system tracks witnessed crimes and known criminals
- Personality affects enforcement style (strict vs lenient)

## Implementation Notes

The Crime/Security Event System creates a living world where:
1. Social order visibly deteriorates as assimilation spreads
2. Players must navigate increasing danger and chaos
3. Security becomes both obstacle and potential ally
4. Crimes provide investigation opportunities
5. Economic pressure increases through property damage
6. Moral choices arise from witnessing crimes

The system starts subtle with the First Quest's mall patrol puzzle and escalates to station-wide coordinated crime waves as the conspiracy deepens, providing both gameplay challenges and narrative reinforcement of the assimilation threat.