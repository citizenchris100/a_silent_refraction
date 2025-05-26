# Living World Event System - MVP Design
**Target: Iteration 5 - Game Districts and Time Management**

## Overview

The Living World Event System MVP creates a foundation for scheduled events and basic NPC routines that make the station feel alive. This system works alongside the Time Management System to create consequences for player time choices and establish that the world continues to evolve whether the player witnesses events or not.

## Design Goals

1. **Living Station**: NPCs follow daily routines, moving between locations based on time
2. **Scheduled Events**: Key story events happen at specific times regardless of player presence  
3. **Player Discovery**: Players can learn about missed events through dialog and environmental clues
4. **Foundation for Growth**: MVP architecture supports full implementation without refactoring
5. **Performance Conscious**: Lightweight simulation that won't impact game performance

## Core Components

### 1. Simple Event Scheduler

```gdscript
# src/core/systems/simple_event_scheduler.gd
extends Node

class_name SimpleEventScheduler

signal event_triggered(event_data)
signal npc_location_changed(npc_id, new_location)

var current_time: float = 0.0
var current_day: int = 1
var scheduled_events: Array = []  # Events sorted by trigger time
var npc_locations: Dictionary = {}  # {npc_id: location}
var event_log: Array = []  # History of triggered events

func schedule_event(event_data: Dictionary):
    """
    Schedule an event to trigger at a specific time
    event_data = {
        "id": "unique_id",
        "trigger_time": 1440.5,  # Minutes since game start
        "type": "assimilation",
        "location": "science_lab",
        "npcs_involved": ["scientist_01"],
        "player_discoverable": true
    }
    """
    pass
```

### 2. NPC Schedule Manager

```gdscript  
# src/core/systems/npc_schedule_manager.gd
extends Node

class_name NPCScheduleManager

var npc_routines: Dictionary = {}  # Loaded from JSON
var current_activities: Dictionary = {}  # {npc_id: current_activity}

func get_npc_location_at_time(npc_id: String, game_time: float) -> String:
    """Returns where an NPC should be at a given time"""
    pass

func get_npc_activity_at_time(npc_id: String, game_time: float) -> String:
    """Returns what an NPC should be doing at a given time"""
    pass
```

### 3. Event Discovery System

```gdscript
# src/core/systems/event_discovery.gd
extends Node

class_name EventDiscovery

var witnessed_events: Array = []  # Events player saw directly
var discovered_events: Dictionary = {}  # Events learned about later
var available_clues: Dictionary = {}  # Clues in the world

func add_clue(location: String, event_id: String, clue_data: Dictionary):
    """Place a clue about an event in a location"""
    pass

func discover_event_through_dialog(event_id: String, source_npc: String):
    """Learn about an event through NPC conversation"""
    pass
```

## Serialization Architecture Integration

The Living World Event System maintains significant persistent state that must survive save/load cycles. Following the modular serialization pattern defined in `docs/design/modular_serialization_architecture.md`, this system implements its own EventSerializer that plugs into the SaveManager without requiring modifications to the core save system.

### Key Serialization Requirements

The EventSerializer must handle:
- **Event History**: Compressed log of all triggered events (using RLE compression for similar consecutive events)
- **NPC Locations**: Current position of each scheduled NPC (only saved if different from scheduled location)
- **Discovered Events**: Dictionary of events the player has learned about through clues or dialog
- **Available Clues**: Active clues in the world waiting to be discovered

### Implementation Example

```gdscript
# src/core/serializers/event_serializer.gd
extends BaseSerializer

func _ready():
    # Self-register when event system initializes
    SaveManager.register_serializer("events", self, 20)

func serialize() -> Dictionary:
    return {
        "history": compress_event_history(),  # Custom compression
        "scheduled": SimpleEventScheduler.get_pending_events(),
        "discovered": EventDiscovery.discovered_events,
        "npc_locations": get_non_default_npc_locations()  # Differential save
    }

func deserialize(data: Dictionary) -> void:
    SimpleEventScheduler.load_event_history(decompress_events(data.history))
    SimpleEventScheduler.reschedule_pending_events(data.scheduled)
    EventDiscovery.discovered_events = data.discovered
    restore_npc_locations(data.npc_locations)
```

This approach ensures that as the event system grows in complexity (adding rumors, evidence, etc.), the serialization can evolve independently without touching the core save system.

## Data Structures

### NPC Schedule Format

```json
{
  "npc_schedules": {
    "concierge": {
      "routine": [
        {
          "time_start": "06:00",
          "time_end": "08:00", 
          "location": "barracks_main",
          "activity": "preparing_desk"
        },
        {
          "time_start": "08:00",
          "time_end": "18:00",
          "location": "barracks_main",
          "activity": "working"
        },
        {
          "time_start": "12:00",
          "time_end": "13:00",
          "location": "mall_restaurant",
          "activity": "lunch"
        },
        {
          "time_start": "18:00",
          "time_end": "19:00",
          "location": "barracks_room_103",
          "activity": "personal_time"
        }
      ],
      "variation": 15  // +/- 15 minutes random variation
    }
  }
}
```

### Scheduled Event Format

```json
{
  "scheduled_events": [
    {
      "id": "scientist_01_assimilation",
      "day": 3,
      "time": "14:30",
      "type": "assimilation",
      "location": "science_lab",
      "npcs_involved": ["scientist_01"],
      "witnesses": ["lab_tech_01", "lab_tech_02"],
      "clues": [
        {
          "location": "science_lab",
          "description": "Strange residue on the floor",
          "discovery_dialog": "I found something odd in the lab..."
        }
      ]
    }
  ]
}
```

## MVP Scope

### 5-10 Key NPCs with Full Routines

1. **Concierge** - Central hub character, most players will interact with daily
2. **Security Chief** - Key to understanding station security state
3. **Bank Teller** - Important for economy and coalition quests  
4. **Scientist Lead** - Central to main plot
5. **Dock Foreman** - Shipping district authority figure

Each NPC will have:
- Morning routine (wake up, breakfast, commute)
- Work routine (location-specific activities)
- Break periods (lunch, short breaks)
- Evening routine (dinner, leisure, sleep)

### Event Types in MVP

1. **Assimilation Events** (2-3 per game)
   - Fixed NPCs get assimilated on specific days
   - Leave clues in their last location
   - Other NPCs notice their absence

2. **Security Events** (1-2 per game)
   - Security sweeps at specific times
   - Alert level changes based on discoveries

3. **Economic Events** (1-2 per game)
   - Bank closure for "maintenance"
   - Trading floor volatility affecting prices

4. **Social Events** (2-3 per game)
   - NPCs meeting in specific locations
   - Gossip spreading about recent events

## Integration with Existing Systems

### Time Manager Integration

```gdscript
# In TimeManager
signal time_advanced(new_time)
signal day_changed(new_day)

# EventScheduler listens to these signals
func _ready():
    TimeManager.connect("time_advanced", self, "_on_time_advanced")
    TimeManager.connect("day_changed", self, "_on_day_changed")
```

### District System Integration

```gdscript
# In BaseDistrict
func _ready():
    # Get NPCs that should be in this district at current time
    var npcs_here = NPCScheduleManager.get_npcs_in_location(district_id)
    spawn_scheduled_npcs(npcs_here)
```

### Dialog System Integration

```gdscript
# NPCs reference recent events in dialog
func get_contextual_dialog(npc_id: String) -> DialogTree:
    var recent_events = EventScheduler.get_recent_events()
    var dialog = base_dialog.duplicate()
    
    # Add event-specific dialog options
    for event in recent_events:
        if npc_knows_about_event(npc_id, event):
            dialog.add_option(create_event_dialog(event))
    
    return dialog
```

## Performance Considerations

1. **Lazy Loading**: Only load full NPC data when player enters their district
2. **Time Chunking**: Process events in 15-minute chunks rather than every frame
3. **Simple States**: NPCs have location + activity, not complex AI
4. **Event Pooling**: Reuse event objects to reduce memory allocation

## Testing Strategy

1. **Time Acceleration**: Debug command to advance time rapidly
2. **Event Visualization**: Debug overlay showing all scheduled events
3. **NPC Tracker**: Debug panel showing current location of all NPCs
4. **Event Force**: Debug command to trigger any event immediately

## Success Metrics

1. Players report feeling the station is "alive"
2. Players discover at least 50% of missed events through clues/dialog  
3. No noticeable performance impact (maintain 60 FPS)
4. Players feel time pressure from knowing events happen without them
5. Easy to add new NPCs and events for content creators

## Future Expansion Paths

This MVP provides clear upgrade paths to the full system:
- Add more NPCs by simply creating schedule JSON
- Add conditional events by extending the event scheduler
- Add rumor system by extending event discovery
- Add relationship effects by tracking NPC interactions
- Add performance optimizations without changing API

## Template Compliance

### NPC Template Integration
This system manages NPCs following the structure defined in `template_npc_design.md`:
- Uses the NPC schedule system from the template for daily routines
- Integrates with NPC state machines for location-based behaviors
- Respects NPC personality parameters when determining schedule variations
- Leverages the template's observation mechanics for event discovery

NPCs managed by this system maintain full compatibility with:
- State-based behaviors defined in the template
- Memory systems for tracking where they've been
- Dialog generation based on recent activities
- Assimilation states affecting their schedules

## Risk Mitigation

1. **Save System Compatibility**: All event data must be serializable
2. **Time Paradoxes**: Clear rules for what happens if player prevents an event
3. **Soft Locks**: Ensure critical path events can't be permanently missed
4. **Discovery Balance**: Enough clues that players don't miss everything