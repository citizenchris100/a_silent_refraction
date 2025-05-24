# Living World Event System - Full Implementation
**Target: Iteration 12 - Complete Living World Simulation**

## Overview

The Living World Event System full implementation builds upon the MVP foundation to create a deeply reactive and dynamic world. This system adds conditional event chains, a rumor system, evidence mechanics, and sophisticated NPC state management to create a station that feels genuinely alive and responsive to both player actions and the passage of time.

## Design Goals

1. **Dynamic Reactivity**: Events create ripple effects throughout the station
2. **Information Networks**: NPCs share knowledge through a rumor system
3. **Emergent Storytelling**: Conditional events create unique narrative combinations
4. **Deep Simulation**: 20-30 key NPCs with complex routines, 70+ background NPCs
5. **Performance Optimization**: Efficient simulation of 100+ NPCs without frame drops
6. **Player Discovery**: Multiple ways to learn about events (rumors, evidence, deduction)

## Enhanced Components

### 1. Advanced Event Scheduler

```gdscript
# src/core/systems/advanced_event_scheduler.gd
extends Node

class_name AdvancedEventScheduler

# Event categories
var fixed_events: Array = []           # Happen at specific times
var conditional_events: Array = []     # Triggered by world state
var recurring_events: Array = []       # Daily/weekly patterns
var chain_events: Dictionary = {}      # Events that trigger other events

# Enhanced state tracking
var world_state: Dictionary = {
    "station_alert_level": 0,
    "power_status": "normal",
    "assimilation_rate": 0.1,
    "coalition_strength": 0,
    "economic_state": "stable",
    "discovered_plots": []
}

func evaluate_conditional_events():
    """Check all conditional events against current world state"""
    for event in conditional_events:
        if event.check_conditions(world_state):
            trigger_conditional_event(event)

func trigger_chain_reaction(initial_event: Event):
    """One event can trigger multiple follow-up events"""
    if initial_event.id in chain_events:
        for chain_data in chain_events[initial_event.id]:
            schedule_chain_event(chain_data)
```

### 2. NPC State Machine

```gdscript
# src/core/systems/npc_state_machine.gd
extends Node

class_name NPCStateMachine

enum NPCStatus { 
    NORMAL, 
    SUSPICIOUS, 
    INVESTIGATING,
    PANICKED,
    ASSIMILATED, 
    MISSING,
    DETAINED,
    COALITION_MEMBER
}

class NPCState:
    var id: String
    var status: int = NPCStatus.NORMAL
    var location: String
    var activity: String
    var knowledge: Array = []  # Events this NPC knows about
    var relationships: Dictionary = {}  # {other_npc_id: relationship_value}
    var suspicion_level: float = 0.0
    var routine_variation: float = 0.0  # How much they deviate today
    var last_seen: float  # When player last saw them
    var conversation_topics: Array = []  # Available dialog based on knowledge
```

### 3. Rumor Propagation System

```gdscript
# src/core/systems/rumor_system.gd
extends Node

class_name RumorSystem

class Rumor:
    var event_id: String
    var accuracy: float  # 0.0 to 1.0
    var distortion_level: int  # How many times it's been passed on
    var source_npc: String
    var known_by: Array = []  # NPCs who know this rumor
    var details: Dictionary = {}  # What details are preserved/distorted

func propagate_rumor(rumor: Rumor, from_npc: String, to_npc: String):
    """Pass rumor between NPCs with potential distortion"""
    var relationship = NPCStateMachine.get_relationship(from_npc, to_npc)
    var new_accuracy = rumor.accuracy * (0.8 + relationship * 0.2)
    
    # Add distortions based on NPC personalities
    if randf() < rumor.distortion_level * 0.1:
        distort_rumor_details(rumor)
    
    rumor.distortion_level += 1
    rumor.known_by.append(to_npc)

func get_rumor_spread_candidates(npc_id: String) -> Array:
    """Determine who an NPC might share rumors with"""
    var candidates = []
    var npc_location = NPCScheduleManager.get_current_location(npc_id)
    
    # NPCs in same location
    candidates.append_array(get_npcs_in_location(npc_location))
    
    # NPCs with strong relationships
    var relationships = NPCStateMachine.get_npc_relationships(npc_id)
    for other_npc in relationships:
        if relationships[other_npc] > 0.6:  # Strong relationship
            candidates.append(other_npc)
    
    return candidates
```

### 4. Evidence System

```gdscript
# src/core/systems/evidence_system.gd
extends Node

class_name EvidenceSystem

class Evidence:
    var id: String
    var event_id: String  # What event created this evidence
    var location: String
    var discovery_requires: Array = []  # Items/skills needed to find
    var decay_time: float = -1  # How long before evidence disappears
    var discovery_dialog: Dictionary  # What player learns when found
    
func create_evidence_for_event(event: Event):
    """Generate appropriate evidence based on event type"""
    match event.type:
        "assimilation":
            create_assimilation_evidence(event)
        "security_sweep":
            create_security_evidence(event)
        "secret_meeting":
            create_meeting_evidence(event)

func create_assimilation_evidence(event: Event):
    """Leave traces of assimilation"""
    var evidence_items = []
    
    # Biological residue
    evidence_items.append({
        "type": "physical",
        "description": "Strange organic residue",
        "location": event.location,
        "decay_time": 1440.0  # Lasts 1 day
    })
    
    # Personal effects
    evidence_items.append({
        "type": "abandoned_item",
        "description": "%s's personal datapad" % event.target_npc,
        "location": event.location,
        "decay_time": -1  # Permanent
    })
    
    # Environmental damage
    if randf() < 0.3:  # 30% chance
        evidence_items.append({
            "type": "environmental",
            "description": "Damaged wall panel with claw marks",
            "location": event.location
        })
```

### 5. Dynamic Event Generation

```gdscript
# src/core/systems/dynamic_event_generator.gd
extends Node

class_name DynamicEventGenerator

func generate_reactive_events(trigger_event: Event):
    """Create new events based on what just happened"""
    
    match trigger_event.type:
        "assimilation":
            # Missing person report
            schedule_missing_person_event(trigger_event.target_npc, 360.0)
            
            # Friends become suspicious
            var friends = NPCStateMachine.get_close_relationships(trigger_event.target_npc)
            for friend in friends:
                increase_npc_suspicion(friend, 0.2)
                
            # Security investigation if high-profile target
            if is_high_profile_npc(trigger_event.target_npc):
                schedule_security_investigation(trigger_event.location, 120.0)
        
        "coalition_formed":
            # Assimilated become more aggressive
            increase_assimilation_rate(0.1)
            
            # Security crackdown
            schedule_security_crackdown(180.0)
            
        "power_failure":
            # Opportunistic events during chaos
            schedule_looting_event(randf_range(5.0, 15.0))
            schedule_emergency_meeting(30.0)
```

### 6. Performance Optimization System

```gdscript
# src/core/systems/world_simulation_optimizer.gd
extends Node

class_name WorldSimulationOptimizer

enum SimulationLevel { FULL, SIMPLIFIED, QUANTUM }

var simulation_zones: Dictionary = {}  # {zone_id: SimulationLevel}

func determine_simulation_level(npc_id: String) -> int:
    """Decide how detailed NPC simulation should be"""
    
    var npc_location = NPCScheduleManager.get_location(npc_id)
    var player_location = Player.current_location
    
    # Full simulation for NPCs near player
    if are_locations_adjacent(npc_location, player_location):
        return SimulationLevel.FULL
    
    # Simplified for important NPCs elsewhere  
    if is_key_npc(npc_id):
        return SimulationLevel.SIMPLIFIED
    
    # Quantum state for background NPCs
    return SimulationLevel.QUANTUM

func update_quantum_npc(npc_id: String, time_delta: float):
    """Ultra-light simulation for distant NPCs"""
    # Just track location based on schedule
    var scheduled_location = NPCScheduleManager.get_scheduled_location(npc_id, current_time)
    NPCStateMachine.set_npc_location(npc_id, scheduled_location)
    
    # Random chance of state changes
    if randf() < 0.01 * time_delta:  # 1% chance per minute
        apply_random_state_change(npc_id)
```

## Save System Integration

The full Living World implementation creates massive amounts of persistent state that must be efficiently serialized. Building upon the MVP EventSerializer, the full system extends serialization capabilities while maintaining the modular architecture defined in `docs/design/modular_serialization_architecture.md`.

### Extended Serialization Requirements

The enhanced EventSerializer handles:
- **Rumor Network State**: Tracking which of 100+ NPCs know which rumors, with accuracy and distortion levels
- **Evidence Decay Timers**: Active evidence items with remaining lifespans
- **Coalition Strength Matrices**: Complex relationship networks between NPCs
- **Temporal Reputation**: How NPCs' opinions change over time based on events
- **Quantum NPC States**: Efficient storage of background NPC positions without full state

### Differential Serialization Strategy

```gdscript
# src/core/serializers/event_serializer_v2.gd
extends BaseSerializer

func get_version() -> int:
    return 2  # Upgraded from MVP version

func serialize() -> Dictionary:
    var data = .serialize()  # Get base data from v1
    
    # Add full system data with aggressive compression
    data["rumors"] = serialize_rumor_network()  # Only active rumors
    data["evidence"] = serialize_active_evidence()  # Skip decayed items
    data["npc_states"] = serialize_npc_states_differential()  # Only non-default
    data["world_state"] = world_state  # Critical for conditional events
    
    return data

func serialize_rumor_network() -> Array:
    # Compress 100+ NPCs × N rumors into efficient structure
    var compressed = []
    for rumor in RumorSystem.active_rumors:
        compressed.append({
            "id": rumor.event_id,
            "acc": int(rumor.accuracy * 100),  # Store as 0-100 int
            "dist": rumor.distortion_level,
            "known": compress_npc_list(rumor.known_by)  # Bit flags
        })
    return compressed

func compress_npc_list(npc_ids: Array) -> int:
    # Convert list of NPC IDs to bit flags for space efficiency
    var flags = 0
    for id in npc_ids:
        var index = NPCRegistry.get_npc_index(id)
        flags |= (1 << index)
    return flags
```

This approach ensures save files remain manageable even with 100+ NPCs and complex event histories, while the modular architecture allows the serializer to evolve independently as new features are added.

## Complex Event Examples

### Conditional Event: Security Lockdown

```json
{
  "id": "security_lockdown_protocol",
  "type": "conditional",
  "conditions": [
    {"type": "world_state", "key": "assimilated_count", "operator": ">=", "value": 5},
    {"type": "world_state", "key": "station_alert_level", "operator": "<", "value": 3},
    {"type": "time_window", "after_day": 3}
  ],
  "effects": [
    {"type": "world_state", "key": "station_alert_level", "value": 3},
    {"type": "lock_areas", "areas": ["security_armory", "engineering_core"]},
    {"type": "npc_behavior", "behavior": "increased_suspicion", "multiplier": 1.5}
  ],
  "chain_events": [
    {"event": "security_sweep_all_districts", "delay": 60},
    {"event": "mandatory_identity_verification", "delay": 180}
  ]
}
```

### Chain Event: Coalition Discovery

```json
{
  "id": "coalition_discovered",
  "type": "triggered",
  "trigger": "player_recruiting_witnessed",
  "effects": [
    {"type": "npc_state", "npc": "witness", "state": "investigating"},
    {"type": "rumor", "content": "secret_meetings", "accuracy": 0.7}
  ],
  "chain_events": [
    {
      "event": "witness_reports_to_security",
      "delay": 120,
      "conditions": [{"npc_state": "witness", "not": "assimilated"}]
    },
    {
      "event": "security_infiltration_attempt", 
      "delay": 480,
      "conditions": [{"world_state": "coalition_discovered", "value": true}]
    }
  ]
}
```

## NPC Categories

### Key NPCs (20-30 total)
Full simulation with:
- Complex daily routines with variations
- Relationship tracking with all other NPCs
- Personal story arcs affected by events
- Unique dialog trees that evolve
- Special animations and behaviors
- Can become coalition members or antagonists

### Supporting NPCs (30-40 total)
Simplified simulation with:
- Basic routines (work, eat, sleep)
- Relationship tracking with key NPCs only
- Generic dialog with event reactions
- Can be assimilated or join coalition
- Standard behavior patterns

### Background NPCs (40-50 total)
Quantum simulation with:
- Location-based existence (spawn when needed)
- Simple state (normal, assimilated, missing)
- Minimal dialog options
- Serve as "extras" to populate areas
- Can be referenced in rumors

## Advanced Features

### Information Warfare
- Plant false rumors to mislead other NPCs
- Intercept communications between NPCs
- Use coalition members to spread counter-propaganda
- Track information flow through the station

### Relationship Dynamics
- NPCs form alliances and rivalries
- Betrayals based on pressure/incentives
- Love interests affected by assimilation
- Group dynamics in public spaces

### Environmental Storytelling
- Graffiti appears based on station mood
- Areas deteriorate as order breaks down
- NPCs modify their spaces based on fear
- Evidence accumulates in logical patterns

## Performance Targets

- 100+ NPCs active simultaneously
- Maintain 60 FPS on target hardware
- Event processing < 2ms per frame
- Memory footprint < 50MB for NPC state
- Save file size < 5MB with full state

## Testing Infrastructure

1. **Scenario Generator**: Create specific world states for testing
2. **Time Control**: Speed up/slow down/jump to specific times
3. **Event Visualizer**: See all scheduled/conditional events
4. **NPC Inspector**: Deep dive into any NPC's full state
5. **Rumor Tracker**: Visualize information flow
6. **Performance Profiler**: Identify simulation bottlenecks

## Success Metrics

1. Players report unique experiences in each playthrough
2. 70% of events discovered through investigation/rumors rather than witnessing
3. NPCs behave believably when observed at any time
4. Rumor distortion creates interesting misinformation
5. Performance remains stable throughout full playthrough
6. Save/load maintains complete world state

## Risk Mitigation

1. **Cascade Prevention**: Limits on chain events to prevent infinite loops
2. **State Recovery**: Graceful handling of inconsistent NPC states
3. **Memory Management**: Automatic cleanup of old events/evidence
4. **Soft Lock Prevention**: Critical path events always accessible
5. **Testing Coverage**: Automated tests for all event types

## Integration with Other Systems

### Quest System
- Dynamic quests generated from world events
- Quest outcomes affect future events
- NPCs remember quest-related interactions

### Combat/Suspicion System  
- Suspicion spreads through rumor network
- Group suspicion events (witch hunts)
- Coalition strength affects resistance options

### Economy System
- Economic events based on station stability
- Black market emerges during lockdowns
- Resource scarcity from disrupted routines

This full implementation transforms the MVP's foundation into a living, breathing world where every playthrough tells a unique story shaped by the intersection of player choices and dynamic world events.