# Detection/Game Over System Design

## Overview

The Detection/Game Over System implements the game's single failure state: player assimilation. This system creates a multi-stage process where detection by assimilated NPCs leads to investigation, pursuit, and ultimately capture if the player cannot evade or counter the threat. The system integrates deeply with suspicion mechanics, coalition resources, and the assimilation network to create fair but tense failure scenarios.

## Core Concepts

### Detection Philosophy
- **Process, not instant**: Detection unfolds through stages, giving players chances to recover
- **Context matters**: Different actions carry different detection risks
- **Network effect**: Assimilated NPCs share information and coordinate
- **Fair warning**: Players receive clear feedback before critical failure
- **Permanent consequences**: No save scumming means every detection matters

### Failure as Narrative
- **Single failure state**: Being assimilated is the only way to lose
- **Meaningful consequence**: Failure reveals the horror of losing identity
- **Learning opportunity**: Shows what player missed or did wrong
- **Motivates replay**: Understanding failure helps future attempts

## System Architecture

### Core Components

#### 1. Detection Manager (Singleton)
```gdscript
# src/core/systems/detection_manager.gd
extends Node

signal detection_stage_changed(stage, npc_id)
signal pursuit_started(pursuer_ids)
signal escape_window_opened(duration)
signal capture_imminent()
signal game_over_triggered(reason)

enum DetectionStage {
    NONE,
    SUSPICIOUS_BEHAVIOR,  # NPC notices something odd
    INVESTIGATING,        # NPC actively checking
    CONFIRMING,          # NPC verifying with network
    ALERTING,            # Spreading the word
    PURSUING,            # Active chase
    CORNERING,           # Multiple NPCs closing in
    CAPTURING            # Final stage before game over
}

var current_stage: int = DetectionStage.NONE
var detecting_npc: String = ""  # Primary detector
var alerted_npcs: Array = []   # NPCs aware of player
var pursuit_timer: float = 0.0
var escape_routes: Array = []
var detection_evidence: Dictionary = {}  # What gave player away

func trigger_detection(npc_id: String, reason: String, severity: float = 0.5):
    var npc_data = NPCRegistry.get_npc(npc_id)
    if not npc_data:
        return
    
    # Only assimilated NPCs can trigger detection
    if not AssimilationManager.is_assimilated(npc_id):
        return
    
    # Add to evidence
    detection_evidence[reason] = {
        "npc": npc_id,
        "time": TimeManager.current_time,
        "location": DistrictManager.current_district
    }
    
    # Severity determines starting stage
    var starting_stage = _calculate_starting_stage(severity, npc_data)
    
    if starting_stage > current_stage:
        current_stage = starting_stage
        detecting_npc = npc_id
        emit_signal("detection_stage_changed", current_stage, npc_id)
        _process_detection_stage()

func _calculate_starting_stage(severity: float, npc_data: Dictionary) -> int:
    # Leader NPCs are more perceptive
    if npc_data.assimilation_type == "leader":
        severity *= 1.5
    
    # High suspicion NPCs react faster
    var suspicion_mult = 1.0 + npc_data.suspicion_level
    severity *= suspicion_mult
    
    # Map severity to stage
    if severity < 0.3:
        return DetectionStage.SUSPICIOUS_BEHAVIOR
    elif severity < 0.6:
        return DetectionStage.INVESTIGATING
    elif severity < 0.8:
        return DetectionStage.CONFIRMING
    else:
        return DetectionStage.ALERTING

func _process_detection_stage():
    match current_stage:
        DetectionStage.SUSPICIOUS_BEHAVIOR:
            _handle_suspicious_behavior()
        DetectionStage.INVESTIGATING:
            _handle_investigation()
        DetectionStage.CONFIRMING:
            _handle_confirmation()
        DetectionStage.ALERTING:
            _handle_alerting()
        DetectionStage.PURSUING:
            _handle_pursuit()
        DetectionStage.CORNERING:
            _handle_cornering()
        DetectionStage.CAPTURING:
            _handle_capture()

func _handle_suspicious_behavior():
    # NPC notices but isn't sure
    var npc = NPCRegistry.get_npc(detecting_npc)
    DialogManager.queue_ambient_dialog(detecting_npc, "suspicious_mutter")
    
    # Give player time to leave area
    yield(get_tree().create_timer(5.0), "timeout")
    
    if _player_still_nearby(detecting_npc):
        advance_detection_stage()
    else:
        # Player left, slowly decrease detection
        _begin_detection_cooldown()

func _handle_investigation():
    # NPC actively investigating
    var npc = NPCRegistry.get_npc(detecting_npc)
    npc.set_state("INVESTIGATING")
    
    # Check player actions during investigation
    if _player_acting_suspicious():
        advance_detection_stage()
    else:
        # Set timer for investigation duration
        yield(get_tree().create_timer(10.0), "timeout")
        if current_stage == DetectionStage.INVESTIGATING:
            _begin_detection_cooldown()

func _handle_alerting():
    # Spread detection through network
    var network = AssimilationManager.get_assimilated_network(detecting_npc)
    
    for npc_id in network:
        if _npc_in_communication_range(npc_id):
            alerted_npcs.append(npc_id)
            var npc = NPCRegistry.get_npc(npc_id)
            npc.set_state("ALERTED")
    
    # Begin pursuit with multiple NPCs
    if alerted_npcs.size() >= 2:
        current_stage = DetectionStage.PURSUING
        emit_signal("pursuit_started", alerted_npcs)
        _handle_pursuit()

func _handle_pursuit():
    # Active chase mechanics
    pursuit_timer = 30.0  # 30 seconds to escape
    
    # Calculate escape routes based on coalition safe houses
    escape_routes = _calculate_escape_routes()
    
    if escape_routes.size() > 0:
        emit_signal("escape_window_opened", pursuit_timer)
        UI.show_urgent_message("RUN! Find a safe house!")
    else:
        # No escape routes - skip to cornering
        current_stage = DetectionStage.CORNERING
        _handle_cornering()

func _handle_cornering():
    # Multiple NPCs closing in
    emit_signal("capture_imminent")
    
    # Final escape chance through coalition
    if CoalitionManager.members.size() >= 5:
        var rescue = CoalitionManager.attempt_rescue()
        if rescue:
            UI.show_message("Coalition members create a distraction!")
            _escape_successful()
            return
    
    # Check for last-ditch items
    if InventoryManager.has_item("smoke_bomb"):
        UI.show_prompt("Use smoke bomb to escape?")
        # Wait for player input
    else:
        yield(get_tree().create_timer(3.0), "timeout")
        current_stage = DetectionStage.CAPTURING
        _handle_capture()

func _handle_capture():
    # Point of no return
    emit_signal("game_over_triggered", "assimilation")
    
    # Trigger game over sequence
    GameOverManager.trigger_assimilation_ending(detecting_npc, alerted_npcs, detection_evidence)
```

#### 2. Detection Triggers
```gdscript
# src/core/systems/detection_triggers.gd
extends Node

# Different actions that can trigger detection
const DETECTION_REASONS = {
    # Dialog-based
    "asked_about_assimilation": 0.8,
    "mentioned_resistance": 0.7,
    "suspicious_question": 0.5,
    "failed_bluff": 0.6,
    
    # Action-based
    "caught_in_restricted_area": 0.6,
    "failed_stealth_check": 0.5,
    "suspicious_item_visible": 0.4,
    "attacking_npc": 0.9,
    
    # Quest-based
    "trap_quest_triggered": 0.8,
    "failed_test_question": 0.7,
    "refused_assimilation_task": 0.9,
    
    # Observation-based
    "staring_too_long": 0.3,
    "following_npc": 0.4,
    "eavesdropping_caught": 0.5
}

func check_dialog_detection(npc_id: String, dialog_choice: String):
    var npc_data = NPCRegistry.get_npc(npc_id)
    if not AssimilationManager.is_assimilated(npc_id):
        return
    
    # Check if dialog choice is suspicious
    var detection_keywords = [
        "assimilation", "infected", "changed", "resistance", 
        "coalition", "something wrong", "acting strange"
    ]
    
    for keyword in detection_keywords:
        if keyword in dialog_choice.to_lower():
            var severity = DETECTION_REASONS.get("suspicious_question", 0.5)
            
            # Increase severity if NPC is already suspicious
            severity *= (1.0 + npc_data.suspicion_level)
            
            DetectionManager.trigger_detection(npc_id, "suspicious_dialog", severity)
            break

func check_area_detection(area_id: String):
    var restricted = AreaRegistry.is_restricted(area_id)
    if not restricted:
        return
    
    # Check for assimilated NPCs who can see player
    var nearby_npcs = NPCManager.get_npcs_in_area(area_id)
    
    for npc_id in nearby_npcs:
        if AssimilationManager.is_assimilated(npc_id):
            var has_clearance = _player_has_clearance(area_id)
            var has_disguise = _player_has_appropriate_disguise(area_id)
            
            if not has_clearance and not has_disguise:
                DetectionManager.trigger_detection(
                    npc_id, 
                    "caught_in_restricted_area",
                    DETECTION_REASONS["caught_in_restricted_area"]
                )
                break
```

#### 3. Game Over Manager
```gdscript
# src/core/systems/game_over_manager.gd
extends Node

signal game_over_started()
signal game_over_complete()

var game_over_scene = preload("res://src/ui/game_over/assimilation_ending.tscn")

func trigger_assimilation_ending(primary_assimilator: String, 
                                participants: Array, 
                                evidence: Dictionary):
    # Pause gameplay
    get_tree().paused = true
    emit_signal("game_over_started")
    
    # Create cinematic sequence
    var ending_sequence = game_over_scene.instance()
    get_tree().root.add_child(ending_sequence)
    
    # Pass context to ending
    ending_sequence.setup_ending({
        "primary": primary_assimilator,
        "participants": participants,
        "evidence": evidence,
        "coalition_size": CoalitionManager.members.size(),
        "days_survived": TimeManager.current_day,
        "closest_to_truth": _calculate_investigation_progress()
    })
    
    # Play ending
    ending_sequence.play()
    yield(ending_sequence, "complete")
    
    # Show what player missed
    _show_post_game_revelations()
    
    # Return to main menu
    emit_signal("game_over_complete")

func _calculate_investigation_progress() -> float:
    var progress = 0.0
    
    # Check major discoveries
    if QuestManager.is_complete("discovered_aether_corp"):
        progress += 0.2
    if QuestManager.is_complete("found_patient_zero"):
        progress += 0.2
    if QuestManager.is_complete("uncovered_conspiracy"):
        progress += 0.3
    if CoalitionManager.coalition_strength > 50:
        progress += 0.2
    if AssimilationManager.identified_leaders.size() > 3:
        progress += 0.1
    
    return progress

func _show_post_game_revelations():
    var revelations = PostGameRevelations.instance()
    get_tree().root.add_child(revelations)
    
    revelations.show_revelations({
        "total_assimilated": AssimilationManager.get_assimilated_count(),
        "missed_coalition": NPCRegistry.get_unrecruited_safe_npcs(),
        "hidden_leaders": AssimilationManager.get_hidden_leaders(),
        "unsolved_mysteries": QuestManager.get_incomplete_investigations()
    })
```

### Integration Systems

#### Suspicion System Integration
```gdscript
# High suspicion affects detection
func modify_detection_severity(base_severity: float, npc_id: String) -> float:
    var npc = NPCRegistry.get_npc(npc_id)
    var suspicion_modifier = npc.suspicion_level
    
    # Critical suspicion means instant detection
    if npc.current_suspicion_tier == "critical":
        return 1.0
    
    # High suspicion increases detection speed
    if npc.current_suspicion_tier == "high":
        base_severity *= 1.5
    
    # Global suspicion affects all detection
    var global_modifier = SuspicionManager.global_suspicion_level * 0.5
    base_severity += global_modifier
    
    return clamp(base_severity, 0.0, 1.0)
```

#### Coalition System Integration
```gdscript
# Coalition provides escape assistance
func calculate_escape_routes() -> Array:
    var routes = []
    
    # Each safe house is a potential escape
    for district in CoalitionManager.safe_houses:
        var safe_house = CoalitionManager.safe_houses[district]
        var distance = DistrictManager.get_distance_to(district)
        
        routes.append({
            "location": safe_house,
            "district": district,
            "distance": distance,
            "risk": _calculate_route_risk(district)
        })
    
    # Coalition members can provide temporary hideouts
    var nearby_members = CoalitionManager.get_members_in_district(
        DistrictManager.current_district
    )
    
    for member_id in nearby_members:
        var member = NPCRegistry.get_npc(member_id)
        if member.trust_level >= 80:  # High trust required
            routes.append({
                "location": member.location,
                "type": "member_hideout",
                "duration": 300  # 5 minutes of safety
            })
    
    return routes
```

#### Time Management Integration
```gdscript
# Detection events affect time flow
func handle_pursuit_time():
    # During pursuit, time moves differently
    TimeManager.set_time_scale(0.5)  # Half speed for tactical decisions
    
    # Escape consumes time
    var escape_time = 0
    
    match current_stage:
        DetectionStage.INVESTIGATING:
            escape_time = 0.25  # 15 minutes
        DetectionStage.PURSUING:
            escape_time = 0.5   # 30 minutes  
        DetectionStage.CORNERING:
            escape_time = 1.0   # 1 hour if coalition rescue
    
    TimeManager.advance_time(escape_time)
    TimeManager.reset_time_scale()
```

#### Economy Integration
```gdscript
# Desperate measures during detection
func attempt_bribe(npc_id: String) -> bool:
    if not AssimilationManager.is_assimilated(npc_id):
        return false  # Can't bribe unassimilated
    
    var npc_data = NPCRegistry.get_npc(npc_id)
    
    # Leaders can't be bribed
    if npc_data.assimilation_type == "leader":
        UI.show_message("Their eyes are cold. Money means nothing to them.")
        return false
    
    # Drones might be distracted by money
    var bribe_amount = 500 * (current_stage + 1)  # Escalating cost
    
    if EconomyManager.can_afford(bribe_amount):
        if randf() < 0.4:  # 40% chance
            EconomyManager.spend_credits(bribe_amount, "desperation_bribe")
            current_stage = max(current_stage - 2, DetectionStage.NONE)
            UI.show_message("The drone takes your credits and wanders off...")
            return true
    
    return false
```

## MVP Implementation

### Basic Features

1. **Simple Detection Stages**
   - Suspicious → Investigating → Pursuing → Game Over
   - Clear visual/audio warnings at each stage
   - 30-second escape window during pursuit

2. **Basic Triggers**
   - Wrong dialog choices with assimilated
   - Caught in restricted areas
   - Failed trap quests

3. **Simple Escape Mechanics**
   - Run to safe house
   - Hide until pursuit ends
   - Coalition rescue (if available)

4. **Basic Game Over**
   - Fade to black
   - "You have been assimilated" message
   - Return to main menu

### MVP Detection Examples
```gdscript
# Dialog trap
{
    "npc": "friendly_merchant",
    "dialog": "Have you noticed anyone acting strange?",
    "responses": [
        {"text": "Yes, the dockworkers seem off", "detection": 0.8},
        {"text": "No, everything seems normal", "detection": 0.0},
        {"text": "Why do you ask?", "detection": 0.3}
    ]
}

# Area trap
{
    "area": "security_office_backroom",
    "restricted": true,
    "watchers": ["security_chief_assimilated"],
    "detection_chance": 0.7
}
```

## Full Implementation

### Advanced Features

#### 1. Complex Detection Network
```gdscript
# Assimilated share information over time
func propagate_detection_info():
    var propagation_queue = [detecting_npc]
    var informed_npcs = [detecting_npc]
    
    while propagation_queue.size() > 0:
        var current = propagation_queue.pop_front()
        var connections = AssimilationManager.get_npc_connections(current)
        
        for connected_id in connections:
            if not connected_id in informed_npcs:
                # Information degrades with distance
                var degradation = _calculate_info_degradation(current, connected_id)
                
                if degradation > 0.3:  # Minimum threshold
                    informed_npcs.append(connected_id)
                    propagation_queue.append(connected_id)
                    
                    # Mark NPC as aware
                    var npc = NPCRegistry.get_npc(connected_id)
                    npc.player_detection_info = degradation
```

#### 2. Environmental Detection
```gdscript
# Security systems and environmental hazards
class SecurityCamera:
    var camera_id: String
    var coverage_area: Area2D
    var connected_monitor: String  # NPC watching feed
    var detection_delay: float = 2.0
    
    func _on_player_entered():
        if DisguiseManager.current_disguise_blocks_cameras():
            return
        
        yield(get_tree().create_timer(detection_delay), "timeout")
        
        if player_still_in_view():
            var monitor_npc = NPCRegistry.get_npc(connected_monitor)
            if AssimilationManager.is_assimilated(connected_monitor):
                DetectionManager.trigger_detection(
                    connected_monitor,
                    "camera_spotted",
                    0.6
                )
```

#### 3. Psychological Horror Elements
```gdscript
# The walls close in as detection increases
func apply_detection_atmosphere():
    match current_stage:
        DetectionStage.SUSPICIOUS_BEHAVIOR:
            AudioManager.play_subtle_tension()
            CameraManager.add_slight_shake(0.1)
            
        DetectionStage.INVESTIGATING:
            AudioManager.increase_heartbeat()
            LightingManager.dim_peripheral_lights()
            
        DetectionStage.PURSUING:
            AudioManager.play_chase_theme()
            CameraManager.add_panic_shake(0.3)
            UIManager.add_screen_edge_darkness()
            
        DetectionStage.CORNERING:
            AudioManager.muffle_sounds()
            CameraManager.narrow_field_of_view()
            TimeManager.add_slow_motion_effect()
```

#### 4. Cinematic Game Over
```gdscript
# Full assimilation sequence
class AssimilationEnding:
    func play_sequence():
        # Surround player with assimilated
        _position_captors()
        
        # Dialog from primary assimilator
        yield(_play_revelation_dialog(), "completed")
        
        # Show assimilation process
        yield(_show_transformation(), "completed")
        
        # Final moments as consciousness fades
        yield(_fade_to_collective(), "completed")
        
        # Statistics and revelations
        yield(_show_aftermath(), "completed")
    
    func _play_revelation_dialog():
        var dialog = []
        
        if primary_assimilator == "security_chief":
            dialog = [
                "You really thought you could stop us?",
                "We've been watching you since you arrived.",
                "Join us. Resistance is pointless."
            ]
        # ... more contextual dialog
        
        DialogManager.play_forced_sequence(dialog)
```

### Detection Modifiers

#### Personality-Based Detection
```gdscript
# Different NPCs detect differently
func get_npc_detection_modifier(npc_id: String) -> float:
    var npc = NPCRegistry.get_npc(npc_id)
    
    match npc.personality_type:
        "paranoid":
            return 1.5  # Quicker to detect
        "trusting":
            return 0.7  # Slower to detect
        "analytical":
            return 1.2  # Methodical detection
        "distracted":
            return 0.5  # Often misses things
```

#### Disguise Effectiveness
```gdscript
# Disguises affect detection differently
func apply_disguise_modifier(base_detection: float) -> float:
    var disguise = DisguiseManager.current_disguise
    var area = DistrictManager.current_area
    
    if disguise == "maintenance" and area.type == "mechanical":
        return base_detection * 0.3  # Blend in perfectly
    elif disguise == "civilian" and area.type == "public":
        return base_detection * 0.5  # Somewhat effective
    elif disguise == "none" and area.restricted:
        return base_detection * 1.5  # Stand out badly
    
    return base_detection
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/detection_serializer.gd
extends BaseSerializer

class_name DetectionSerializer

func _ready():
    # Self-register with high priority (critical game state)
    SaveManager.register_serializer("detection", self, 20)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "current_stage": DetectionManager.current_stage,
        "detecting_npc": DetectionManager.detecting_npc,
        "alerted_npcs": DetectionManager.alerted_npcs,
        "pursuit_timer": DetectionManager.pursuit_timer,
        "detection_evidence": DetectionManager.detection_evidence,
        "escape_routes": _serialize_escape_routes(),
        "informed_network": DetectionManager.informed_npcs,
        "camera_alerts": SecuritySystem.active_camera_alerts
    }

func deserialize(data: Dictionary) -> void:
    DetectionManager.current_stage = data.get("current_stage", 0)
    DetectionManager.detecting_npc = data.get("detecting_npc", "")
    DetectionManager.alerted_npcs = data.get("alerted_npcs", [])
    DetectionManager.pursuit_timer = data.get("pursuit_timer", 0.0)
    DetectionManager.detection_evidence = data.get("detection_evidence", {})
    _deserialize_escape_routes(data.get("escape_routes", []))
    DetectionManager.informed_npcs = data.get("informed_network", [])
    SecuritySystem.active_camera_alerts = data.get("camera_alerts", [])
    
    # Resume detection state if active
    if DetectionManager.current_stage > 0:
        DetectionManager._process_detection_stage()
```

## UI Components

### Detection Warning UI
```gdscript
# src/ui/detection/detection_warning_ui.gd
extends Control

onready var stage_indicator = $StageIndicator
onready var timer_bar = $TimerBar
onready var escape_hints = $EscapeHints

func _ready():
    DetectionManager.connect("detection_stage_changed", self, "_on_stage_changed")
    DetectionManager.connect("escape_window_opened", self, "_on_escape_window")

func _on_stage_changed(stage: int, npc_id: String):
    show()
    
    match stage:
        DetectionManager.DetectionStage.SUSPICIOUS_BEHAVIOR:
            stage_indicator.text = "Something's not right..."
            stage_indicator.modulate = Color.yellow
            
        DetectionManager.DetectionStage.INVESTIGATING:
            stage_indicator.text = "You're being watched!"
            stage_indicator.modulate = Color.orange
            _pulse_warning()
            
        DetectionManager.DetectionStage.PURSUING:
            stage_indicator.text = "RUN!"
            stage_indicator.modulate = Color.red
            _flash_screen_edges()
```

### Escape Route Overlay
```gdscript
# src/ui/detection/escape_overlay.gd
extends Control

func show_escape_routes(routes: Array):
    clear()
    
    for route in routes:
        var marker = ESCAPE_MARKER.instance()
        marker.setup(route)
        add_child(marker)
        
        # Draw path to escape route
        var path = PathfindingManager.get_path_to(route.location)
        _draw_escape_path(path, route.risk)
```

## Balance Considerations

### Detection Timing
- **Suspicious**: 5 seconds to leave area
- **Investigating**: 10 seconds to act normal
- **Pursuing**: 30 seconds to reach safety
- **Cornering**: 5 seconds for last resort

### Detection Thresholds
- **Minor infractions**: 0.3-0.5 severity
- **Major mistakes**: 0.6-0.8 severity
- **Critical errors**: 0.9+ severity (instant alert)

### Escape Difficulty
- **Early game**: Multiple escape routes, slow detection
- **Mid game**: Fewer routes, moderate detection
- **Late game**: Limited routes, fast detection
- **High corruption**: Almost impossible to escape

## Testing Considerations

1. **Detection Flow**
   - Test each stage transitions properly
   - Verify escape windows work
   - Test interruption mechanics

2. **Integration Testing**
   - Suspicion affects detection speed
   - Coalition provides escape routes
   - Disguises reduce detection
   - Time advances appropriately

3. **Fairness Testing**
   - Player has warning before failure
   - Escape is possible but challenging
   - Clear feedback on what went wrong

4. **Edge Cases**
   - Multiple simultaneous detections
   - Detection during other events
   - Save/load during detection

This system creates a tense but fair failure state that reinforces the game's themes while providing players with meaningful ways to avoid or escape detection through careful play and smart use of game systems.