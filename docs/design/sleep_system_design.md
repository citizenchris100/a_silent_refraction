# Sleep System Design Document

## Overview

The Sleep System in "A Silent Refraction" enforces mandatory rest periods, integrating with the save system, time management, economy, and player agency. The system creates two distinct experiences: those who maintain their barracks (voluntary sleep with benefits) and those who lose it (forced sleep with penalties). This design reinforces the game's economic pressure and consequence mechanics.

## Core Mechanics

### Two Sleep Modes

#### 1. Barracks Resident (Voluntary Sleep)
- Can sleep anytime after reaching barracks
- Saves game and advances time by system-defined interval
- Better rest quality and morale benefits
- Must return by midnight or face forced return

#### 2. Mall Squat Dweller (Forced Sleep)
- Cannot voluntarily sleep/save
- Must wait until midnight for forced sleep
- Spawns on Mall main floor after sleep
- Reduced rest quality and morale penalties

### System Constants
```gdscript
class SleepSystemConstants:
    const FORCED_SLEEP_TIME = 24  # Midnight (00:00)
    const WAKE_TIME_BARRACKS = 6  # 6:00 AM
    const WAKE_TIME_SQUAT = 5     # 5:00 AM (earlier, worse sleep)
    const SLEEP_DURATION_HOURS = 6 # Fixed sleep duration
    
    const MIDNIGHT_WARNING_TIME = 23.5  # 11:30 PM
    const FINAL_WARNING_TIME = 23.75    # 11:45 PM
    
    # Designer-configurable but not player-accessible
    export var sleep_duration_override: int = -1  # For special events
    export var force_sleep_enabled: bool = true   # For testing
```

## Barracks Sleep Flow

### Voluntary Sleep
```gdscript
class BarracksSleepHandler:
    func can_sleep_in_barracks() -> bool:
        # Check multiple conditions
        if not BarracksManager.has_active_lease():
            return false
            
        if not PlayerLocation.is_in_barracks():
            return false
            
        if DetectionManager.get_state() == DetectionState.PURSUING:
            show_message("You can't sleep while being pursued!")
            return false
            
        return true
    
    func initiate_barracks_sleep():
        if not can_sleep_in_barracks():
            return
            
        # Show sleep dialog
        var dialog = SleepConfirmDialog.instance()
        dialog.set_location("Barracks")
        dialog.set_wake_time(WAKE_TIME_BARRACKS)
        dialog.show_overnight_preview()  # Assimilation spread, etc.
        dialog.connect("confirmed", self, "_on_sleep_confirmed")
    
    func _on_sleep_confirmed():
        # Process overnight events
        process_overnight_events()
        
        # Save game (integrated with save system)
        SaveManager.save_game()
        
        # Advance time
        TimeManager.sleep_until(WAKE_TIME_BARRACKS)
        
        # Apply rest benefits
        FatigueSystem.apply_quality_rest(1.0)  # Full recovery
        PlayerStats.adjust_morale(5)
        
        # Show morning report
        show_morning_report()
```

### Forced Return at Midnight
```gdscript
class MidnightEnforcer:
    var warning_shown = false
    var final_warning_shown = false
    
    func _process(_delta):
        if not BarracksManager.has_active_lease():
            return  # Only affects barracks residents
            
        var current_time = TimeManager.get_current_hour_decimal()
        
        # First warning at 11:30 PM
        if current_time >= MIDNIGHT_WARNING_TIME and not warning_shown:
            show_return_warning()
            warning_shown = true
            
        # Final warning at 11:45 PM
        elif current_time >= FINAL_WARNING_TIME and not final_warning_shown:
            show_final_warning()
            final_warning_shown = true
            
        # Force return at midnight
        elif current_time >= FORCED_SLEEP_TIME:
            force_return_to_barracks()
    
    func show_return_warning():
        var dialog = NotificationDialog.instance()
        dialog.set_message("You're getting tired. You should return to your barracks soon.")
        dialog.set_timer(5.0)  # Auto-dismiss
        dialog.show()
    
    func show_final_warning():
        var dialog = UrgentDialog.instance()
        dialog.set_message("You must return to your barracks immediately!")
        dialog.add_button("OK", "_acknowledge")
        dialog.show()
    
    func force_return_to_barracks():
        # Check if player can afford tram
        var tram_cost = calculate_return_cost()
        
        if EconomyManager.get_credits() >= tram_cost:
            execute_forced_return(tram_cost)
        else:
            # Can't afford tram - go to Mall Squat
            force_mall_squat_sleep("insufficient_funds")
```

### Forced Return Execution
```gdscript
func execute_forced_return(tram_cost: int):
    # Show forced return dialog
    var dialog = ForcedReturnDialog.instance()
    dialog.set_message("You're too exhausted to continue. Returning to barracks...")
    dialog.show()
    
    # Deduct tram fare
    EconomyManager.deduct_credits(tram_cost)
    
    # Calculate travel time
    var travel_time = TramSystem.calculate_time(
        PlayerLocation.current_district,
        "habitation"  # Barracks location
    )
    
    # Apply time cost
    TimeManager.advance_time(travel_time)
    
    # Teleport to barracks
    SceneManager.load_scene("barracks_room")
    PlayerLocation.set_position(BarracksManager.get_bed_position())
    
    # Force sleep
    initiate_barracks_sleep()
```

## Mall Squat Sleep Flow

### Becoming a Squat Dweller
```gdscript
class SquatDwellerManager:
    var is_squat_dweller: bool = false
    var eviction_day: int = -1
    
    func make_squat_dweller(reason: String):
        is_squat_dweller = true
        eviction_day = TimeManager.current_day
        
        # Remove barracks access
        BarracksManager.revoke_access()
        
        # Show notification based on reason
        match reason:
            "eviction":
                show_eviction_notice()
            "insufficient_funds":
                show_broke_notice()
        
        # Update player status
        PlayerStats.add_status("homeless")
        
        # Notify other systems
        emit_signal("became_squat_dweller", reason)
```

### Forced Sleep at Midnight
```gdscript
class SquatSleepEnforcer:
    func _process(_delta):
        if not SquatDwellerManager.is_squat_dweller:
            return
            
        if TimeManager.get_current_hour() >= FORCED_SLEEP_TIME:
            force_mall_squat_sleep("midnight")
    
    func force_mall_squat_sleep(trigger: String):
        # No choice - must sleep
        var dialog = ForcedSquatDialog.instance()
        dialog.set_message("Exhausted, you find a hidden corner in the Mall...")
        dialog.show()
        
        # Process overnight events with penalties
        process_overnight_events_squat()
        
        # Save game
        SaveManager.save_game()
        
        # Advance time (less sleep than barracks)
        TimeManager.sleep_until(WAKE_TIME_SQUAT)
        
        # Apply poor rest penalties
        FatigueSystem.apply_quality_rest(0.5)  # Only 50% recovery
        PlayerStats.adjust_morale(-10)
        DetectionManager.increase_base_suspicion(5)
        
        # Risk of theft
        if randf() < 0.15:  # 15% chance
            handle_overnight_theft()
        
        # Spawn on Mall floor
        spawn_on_mall_floor()
```

### Mall Floor Spawn
```gdscript
func spawn_on_mall_floor():
    # Load Mall district
    SceneManager.load_scene("mall_main_floor")
    
    # Set spawn position (varies to avoid predictability)
    var spawn_points = [
        Vector2(100, 450),   # Near maintenance door
        Vector2(800, 600),   # Behind kiosk
        Vector2(450, 350)    # Corner alcove
    ]
    var spawn = spawn_points[randi() % spawn_points.size()]
    PlayerLocation.set_position(spawn)
    
    # Show wake-up dialog
    var dialog = WakeUpDialog.instance()
    dialog.set_message("You wake up stiff and tired. A security guard eyes you suspiciously.")
    dialog.add_status_summary(get_squat_sleep_summary())
    dialog.show()
    
    # Morning save confirmation
    show_save_confirmation()
```

## Integration with Game Systems

### Economy System Integration
```gdscript
func integrate_economy():
    # Track rent payment status
    EconomyManager.connect("rent_overdue", self, "_on_rent_overdue")
    EconomyManager.connect("eviction_notice", self, "_on_eviction_notice")
    
    # Calculate forced return costs
    func calculate_return_cost() -> int:
        var current_district = PlayerLocation.current_district
        var base_cost = TramSystem.calculate_cost(current_district, "habitation")
        
        # Late night surcharge
        if TimeManager.get_current_hour() >= 23:
            base_cost = int(base_cost * 1.5)  # 50% surcharge
        
        return base_cost
    
    # Handle economic consequences
    func _on_rent_overdue(days: int):
        if days >= 3:
            trigger_eviction()
```

### Time Management Integration
```gdscript
func integrate_time_system():
    # Fixed sleep durations (not player-configurable)
    func calculate_sleep_duration(sleep_quality: float) -> float:
        var base_duration = SLEEP_DURATION_HOURS
        
        # Special events can modify
        if EventManager.has_active_event("station_alert"):
            base_duration *= 0.8  # Shorter sleep during alerts
        
        return base_duration * 60  # Convert to minutes
    
    # Time advancement
    func advance_sleep_time(location: String):
        var duration = calculate_sleep_duration(get_location_quality(location))
        TimeManager.advance_time(duration)
        
        # Always advance to next day
        if TimeManager.current_hour < 6:
            TimeManager.set_time(get_wake_time(location), 0)
```

### Fatigue System Integration
```gdscript
func integrate_fatigue():
    # Sleep quality affects recovery
    func apply_sleep_recovery(location: String):
        var quality = get_sleep_quality(location)
        
        match location:
            "barracks":
                FatigueSystem.reset_exhaustion()
                FatigueSystem.reset_stimulant_resistance()
                
            "mall_squat":
                FatigueSystem.reduce_exhaustion(0.5)  # Only partial recovery
                # Stimulant resistance doesn't reset
                
            "coalition_safehouse":
                FatigueSystem.reduce_exhaustion(0.8)
                FatigueSystem.reduce_stimulant_resistance(0.5)
    
    # Can't fight sleep at midnight
    func check_forced_sleep_override():
        if TimeManager.get_current_hour() >= FORCED_SLEEP_TIME:
            # Stimulants can't prevent forced sleep
            return true
        return false
```

### Assimilation System Integration
```gdscript
func process_overnight_assimilation():
    # Different spread rates by location
    var spread_modifier = 1.0
    
    if SquatDwellerManager.is_squat_dweller:
        spread_modifier = 1.2  # More spread when player is vulnerable
    
    # Calculate overnight spread
    var spread_result = AssimilationManager.calculate_overnight_spread(spread_modifier)
    
    # Store for morning report
    overnight_events["assimilation"] = spread_result
    
    # Check for critical NPCs
    for npc_id in spread_result.new_assimilations:
        if NPCRegistry.is_critical(npc_id):
            overnight_events["critical_loss"] = npc_id
```

### Detection System Integration
```gdscript
func handle_sleep_detection():
    # Can't sleep while being pursued
    if DetectionManager.get_state() == DetectionState.PURSUING:
        return false
    
    # Sleeping reduces heat
    func apply_overnight_detection_decay():
        var decay_rate = 0.5  # Base decay
        
        if sleeping_in_barracks():
            decay_rate = 0.7  # Better decay in private room
        
        DetectionManager.apply_overnight_decay(decay_rate)
    
    # Mall squat increases base suspicion
    func apply_squat_suspicion():
        if SquatDwellerManager.is_squat_dweller:
            DetectionManager.increase_base_suspicion(5)
            
            # Security might notice patterns
            if SquatDwellerManager.consecutive_squat_nights > 3:
                trigger_security_interest()
```

### Coalition System Integration
```gdscript
func integrate_coalition():
    # Coalition safe houses as alternative sleep locations
    func check_coalition_options():
        if not BarracksManager.has_active_lease():
            var safe_houses = CoalitionManager.get_accessible_safe_houses()
            
            for house in safe_houses:
                if house.has_bed and house.trust_level >= 50:
                    add_sleep_option(house)
    
    # Coalition members act overnight
    func process_coalition_overnight():
        var actions = CoalitionManager.get_scheduled_overnight_actions()
        
        for action in actions:
            if action.requires_player_absence:
                # Some missions happen while you sleep
                var result = CoalitionManager.execute_action(action)
                overnight_events["coalition_actions"].append(result)
```

### Quest System Integration
```gdscript
func check_sleep_quest_impacts():
    # Some quests fail if you sleep
    var active_quests = QuestManager.get_active_quests()
    
    for quest in active_quests:
        if quest.fails_on_sleep:
            QuestManager.fail_quest(quest.id, "missed_overnight")
            overnight_events["failed_quests"].append(quest.name)
        
        # Time-sensitive objectives
        if quest.has_overnight_deadline():
            QuestManager.check_overnight_deadline(quest.id)
    
    # Sleeping might advance certain quests
    var sleep_quests = QuestManager.get_sleep_triggered_quests()
    for quest in sleep_quests:
        QuestManager.advance_quest(quest.id, "slept")
```

### Save System Integration
```gdscript
func integrate_save_system():
    # Sleep is the ONLY way to save
    func execute_save_through_sleep():
        # Set save metadata
        SaveManager.set_save_context({
            "location": get_current_sleep_location(),
            "quality": get_sleep_quality(),
            "forced": is_forced_sleep(),
            "day": TimeManager.current_day
        })
        
        # Perform save
        var result = SaveManager.save_game()
        
        if not result.success:
            # Critical - offer retry
            show_save_failure_dialog(result.error)
            return false
        
        return true
```

## Special Sleep Scenarios

### Security Discovery (Mall Squat)
```gdscript
func handle_security_discovery():
    var dialog = SecurityConfrontationDialog.instance()
    dialog.set_message("'Hey! You can't sleep here!' A security guard shakes you awake.")
    
    # Options based on game state
    if DisguiseManager.has_uniform("security"):
        dialog.add_option("Flash security badge", "_bluff_security")
    
    if EconomyManager.get_credits() >= 50:
        dialog.add_option("Bribe (50 credits)", "_bribe_security")
    
    dialog.add_option("Run", "_flee_security")
    dialog.add_option("Comply", "_comply_security")
    
    dialog.show()
```

### Emergency Wake Events
```gdscript
class EmergencyWakeHandler:
    func check_emergency_events():
        # Station-wide emergencies
        if EventManager.should_trigger_emergency():
            var emergency = EventManager.get_emergency_event()
            
            match emergency.type:
                "assimilation_outbreak":
                    wake_for_outbreak()
                "coalition_raid":
                    wake_for_raid()
                "system_malfunction":
                    wake_for_malfunction()
    
    func wake_for_outbreak():
        # Interrupt sleep
        show_emergency_wake("Alarms blare! 'All personnel report to designated safe zones!'")
        
        # Partial rest only
        FatigueSystem.apply_interrupted_sleep(0.3)
        
        # Start emergency event
        EventManager.begin_outbreak_event()
```

## UI Components

### Sleep Confirmation Dialog
```
┌─────────────────────────────────────────────────┐
│ REST IN BARRACKS                                │
├─────────────────────────────────────────────────┤
│                                                 │
│ Sleep until 6:00 AM?                           │
│                                                 │
│ Current time: 22:30 (Day 12)                   │
│                                                 │
│ While you sleep:                                │
│ • Assimilation will spread (~2-3%)             │
│ • Coalition may complete missions               │
│ • Time-sensitive quests may expire             │
│                                                 │
│ [Sleep & Save]              [Stay Awake]        │
└─────────────────────────────────────────────────┘
```

### Forced Return Warning
```
┌─────────────────────────────────────────────────┐
│ ⚠ EXHAUSTION WARNING                           │
├─────────────────────────────────────────────────┤
│                                                 │
│ You're too tired to continue.                  │
│ You must return to your barracks NOW.          │
│                                                 │
│ Tram cost: 30 credits (late night surcharge)   │
│ Current credits: 45                             │
│                                                 │
│                           [Return to Barracks]  │
└─────────────────────────────────────────────────┘
```

### Morning Report
```
┌─────────────────────────────────────────────────┐
│ MORNING REPORT - Day 13, 6:00 AM                │
├─────────────────────────────────────────────────┤
│                                                 │
│ You feel well-rested.                          │
│                                                 │
│ While you slept:                                │
│ • 2 NPCs were assimilated (44% station total)  │
│ • Chen completed the dead drop mission         │
│ • Your rent is due today (450 credits)        │
│ • Marcus is looking for you (urgent)           │
│                                                 │
│ [Game Saved]                    [Continue]      │
└─────────────────────────────────────────────────┘
```

## Modular Serialization

```gdscript
class SleepSystemSerializer extends BaseSerializer:
    func get_serializer_id() -> String:
        return "sleep_system"
    
    func get_version() -> int:
        return 1
    
    func serialize() -> Dictionary:
        return {
            "is_squat_dweller": SquatDwellerManager.is_squat_dweller,
            "eviction_day": SquatDwellerManager.eviction_day,
            "consecutive_squat_nights": SquatDwellerManager.consecutive_squat_nights,
            "last_sleep_location": last_sleep_location,
            "last_sleep_quality": last_sleep_quality,
            "forced_return_warnings": {
                "warning_shown": warning_shown,
                "final_warning_shown": final_warning_shown
            },
            "sleep_history": compress_sleep_history()
        }
    
    func deserialize(data: Dictionary) -> void:
        SquatDwellerManager.is_squat_dweller = data.get("is_squat_dweller", false)
        SquatDwellerManager.eviction_day = data.get("eviction_day", -1)
        SquatDwellerManager.consecutive_squat_nights = data.get("consecutive_squat_nights", 0)
        last_sleep_location = data.get("last_sleep_location", "barracks")
        last_sleep_quality = data.get("last_sleep_quality", 1.0)
        
        var warnings = data.get("forced_return_warnings", {})
        warning_shown = warnings.get("warning_shown", false)
        final_warning_shown = warnings.get("final_warning_shown", false)
        
        decompress_sleep_history(data.get("sleep_history", []))
    
    func _ready():
        SaveManager.register_serializer("sleep_system", self, 35)
```

## Debug Commands

```gdscript
class SleepDebugCommands:
    static func register_commands():
        if not OS.is_debug_build():
            return
        
        Console.register_command("force_sleep", self, "_cmd_force_sleep",
            "Force sleep at current location")
        Console.register_command("set_squat_dweller", self, "_cmd_set_squat",
            "Make player a squat dweller")
        Console.register_command("skip_to_midnight", self, "_cmd_skip_midnight",
            "Skip time to midnight")
        Console.register_command("test_emergency_wake", self, "_cmd_test_emergency",
            "Test emergency wake event")
```

## Barracks System Integration

The Sleep System deeply integrates with the Barracks System (to be documented separately):

### Key Barracks System Hooks
- Rent payment tracking and due dates
- Eviction process and grace periods  
- Room access management
- Personal storage access
- Upgrade possibilities (better bed = better rest)
- Roommate/neighbor interactions

## Future Considerations

### Potential Enhancements
- Dream sequences revealing plot hints
- Nightmares based on assimilation exposure
- Sleep quality affected by room upgrades
- Alternative sleep locations discovered through play
- Sleep deprivation hallucinations if avoiding sleep

### Explicitly Not Supported
- Player-configurable sleep duration
- Multiple save slots through sleep
- Sleeping anywhere besides designated locations
- Skipping overnight events
- Pausing overnight processing

## Conclusion

The Sleep System creates a fundamental rhythm to gameplay, forcing players to plan their days around the need to return home (or find shelter). The distinction between barracks residents and squat dwellers creates two different gameplay experiences - one of comfort and agency, the other of survival and constraint. By tying saves exclusively to sleep and making sleep mandatory, the system reinforces the game's themes of consequence, resource management, and the slow erosion of normalcy as the assimilation spreads.