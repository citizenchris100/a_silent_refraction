# Save System Design Document

## Overview

The save system for "A Silent Refraction" implements a single-slot save model inspired by Dead Rising, where saves only occur when sleeping. This design reinforces the game's themes of consequence and planning, as players must manage their time and resources to reach a safe sleeping location before saving progress. The system leverages the modular serialization architecture to seamlessly integrate all game systems.

## Core Design Philosophy

### Single Save Slot
- Only one save file exists per game installation
- No save scumming or multiple save states
- Every decision has permanent consequences
- Reinforces the weight of player choices

### Sleep-to-Save Mechanic
- Saving is exclusively tied to the sleep action
- Forces players to plan their days carefully
- Creates natural save points that advance time
- Integrates with fatigue and time management systems

## Save Triggers

### Primary Save Method: Sleep
```gdscript
func initiate_sleep():
    if not can_sleep():
        show_cannot_sleep_reason()
        return
    
    # Check if player can afford to sleep here
    var sleep_cost = get_sleep_location_cost()
    if sleep_cost > 0 and EconomyManager.get_credits() < sleep_cost:
        show_notification("You need %d credits to sleep here" % sleep_cost)
        return
    
    # Show sleep confirmation dialog
    var dialog = SleepConfirmDialog.instance()
    dialog.show_time_advance_info()  # "Sleep until 6:00 AM?"
    dialog.show_overnight_risks()     # Assimilation spread warning
    dialog.connect("confirmed", self, "_on_sleep_confirmed")

func _on_sleep_confirmed():
    # Pre-save system updates
    _process_overnight_events()
    
    # Perform save operation using modular architecture
    var save_result = SaveManager.save_game()
    
    if save_result.success:
        # Show save confirmation
        show_save_confirmation()
        
        # Advance time after save completes
        TimeManager.sleep_until_morning()
    else:
        handle_save_failure(save_result.error)
```

### No Manual Saves
- No save menu option
- No quick save functionality
- No auto-saves except through sleep
- Reinforces the intentionality of saving

## Save Locations

### Primary: Barracks Room
```gdscript
class BarracksRoom:
    var bed_interaction_area: Area2D
    var rent_paid: bool = true
    var days_overdue: int = 0
    const COMFORT_LEVEL = 1.0  # Best sleep quality
    
    func can_use_bed() -> bool:
        # Check with Economy System
        return EconomyManager.is_barracks_rent_current() or days_overdue < 3
    
    func interact_with_bed():
        if not can_use_bed():
            show_eviction_notice()
            trigger_homeless_sleep()
            return
        
        # Check time restrictions
        if TimeManager.current_hour < 20 and FatigueSystem.get_exhaustion() < 0.7:
            show_message("You're not tired enough to sleep yet.")
            return
        
        # Check if room is compromised (Coalition infiltration)
        if CoalitionManager.is_barracks_compromised():
            show_message("Your room doesn't feel safe... someone's been here.")
            apply_paranoia_penalty()
        
        initiate_sleep()
    
    func get_sleep_benefits() -> Dictionary:
        return {
            "fatigue_recovery": 1.0,
            "time_advance": "06:00",
            "morale_boost": 5,
            "suspicion_reduction": 10
        }
```

### Fallback: Homeless Squat
```gdscript
class HomelessSquat:
    # Hidden location when evicted from barracks
    const LOCATION = "mall_maintenance_area"
    const WAKE_TIME = "05:00"  # Wake earlier than barracks
    const COMFORT_LEVEL = 0.3  # Poor sleep quality
    const DISCOVERY_RISK = 0.2  # Chance of being discovered
    
    func force_sleep_homeless():
        # No choice - must sleep here when evicted
        show_message("With nowhere else to go, you find a quiet corner in the Mall's maintenance area...")
        
        # Risk of discovery by security
        if randf() < DISCOVERY_RISK:
            handle_security_discovery()
            return
        
        # Apply penalties
        FatigueSystem.apply_poor_sleep_penalty()
        PlayerStats.morale -= 10
        DetectionManager.increase_base_suspicion(5)
        
        # Costs nothing but has risks
        _perform_sleep_save(WAKE_TIME)
        
        # Check for overnight theft
        if randf() < 0.1:  # 10% chance
            var stolen_item = InventoryManager.steal_random_item()
            if stolen_item:
                show_message("Your %s was stolen while you slept!" % stolen_item.name)
```

### Alternative: Coalition Safe Houses
```gdscript
class CoalitionSafeHouse:
    var location_id: String
    var trust_requirement: int = 50
    var network_size_requirement: int = 3
    const COMFORT_LEVEL = 0.7
    
    func can_use_safe_house() -> bool:
        # Must have sufficient trust
        if not CoalitionManager.has_safe_house_access(location_id):
            return false
        
        # Check if compromised
        if AssimilationManager.is_location_compromised(location_id):
            return false
        
        # Check network requirements
        return CoalitionManager.get_active_network_size() >= network_size_requirement
    
    func sleep_at_safe_house():
        # Benefits of coalition protection
        var benefits = {
            "fatigue_recovery": 0.8,
            "coalition_trust": 5,
            "information_gained": check_overnight_intel()
        }
        
        # Risk of infiltration
        CoalitionManager.roll_infiltration_check()
        
        _perform_sleep_save("05:30")
```

## Save UI Flow

### Sleep Confirmation Dialog with System Info
```
┌─────────────────────────────────────────────────┐
│ REST                                            │
├─────────────────────────────────────────────────┤
│                                                 │
│ Sleep until 6:00 AM?                           │
│                                                 │
│ Current time: 22:47 (Day 12)                   │
│ You will sleep for 7 hours 13 minutes          │
│                                                 │
│ Overnight risks:                                │
│ • Assimilation may spread (current: 42%)       │
│ • Rent due in 2 days (450 credits)             │
│ • Marcus expects report by Day 14               │
│                                                 │
│ [Sleep]                    [Stay Awake]         │
└─────────────────────────────────────────────────┘
```

### Save Progress Indicator
```gdscript
func show_save_progress():
    var indicator = SaveProgressUI.instance()
    UI.add_child(indicator)
    
    # Show modular save progress
    SaveManager.connect("module_save_start", indicator, "_on_module_start")
    SaveManager.connect("module_save_complete", indicator, "_on_module_complete")
    
    # Visual feedback for each system being saved
    # "Saving player data..."
    # "Saving NPC states..."
    # "Saving economy data..."
    # etc.
```

### Save Confirmation with Overnight Report
```
┌─────────────────────────────────────────────────┐
│ MORNING REPORT - Day 13, 6:00 AM                │
├─────────────────────────────────────────────────┤
│                                                 │
│ Game Saved Successfully                         │
│                                                 │
│ While you slept:                                │
│ • 2 NPCs were assimilated (44% total)          │
│ • Coalition completed dead drop mission         │
│ • Shop prices increased due to scarcity        │
│ • Your exhaustion has been reset               │
│                                                 │
│                              [Continue]         │
└─────────────────────────────────────────────────┘
```

## Loading System

### Load Only From Main Menu
```gdscript
# As specified in main_menu_start_game_ui_design.md
class MainMenu:
    func _on_load_game_pressed():
        if not SaveManager.save_exists():
            show_no_save_message()
            return
        
        # Show loading progress for each module
        var loading_screen = LoadingScreen.instance()
        get_tree().get_root().add_child(loading_screen)
        
        # Connect to modular load events
        SaveManager.connect("module_load_start", loading_screen, "_on_module_start")
        SaveManager.connect("module_load_complete", loading_screen, "_on_module_complete")
        
        # Load using modular architecture
        var result = SaveManager.load_game()
        
        if result.success:
            # Restore game state at saved location
            _restore_game_state()
        else:
            show_error("Failed to load save: " + result.error)
            loading_screen.queue_free()
```

## Integration with Modular Serialization Architecture

### SaveManager Implementation
```gdscript
# Extends the modular architecture from docs/design/modular_serialization_architecture.md
extends Node

class_name SaveManager

# Save operation using registered serializers
func save_game() -> Dictionary:
    var result = {"success": false, "error": ""}
    
    emit_signal("save_started")
    
    # Create save data structure
    var save_data = SaveData.new()
    save_data.version = SAVE_VERSION
    save_data.timestamp = OS.get_unix_time()
    save_data.save_location = SleepManager.get_current_sleep_location()
    save_data.day = TimeManager.current_day
    
    # Collect data from all registered serializers
    save_data.modules = {}
    for entry in serializer_order:
        var name = entry.name
        var serializer = serializers[name]
        
        emit_signal("module_save_start", name)
        
        # Let each serializer add its data
        var module_data = serializer.serialize()
        if module_data != null:
            save_data.modules[name] = {
                "version": serializer.get_version(),
                "data": module_data
            }
        
        emit_signal("module_save_complete", name)
    
    # Calculate checksum
    save_data.checksum = calculate_checksum(save_data.modules)
    
    # Write atomically
    if write_save_file(save_data):
        result.success = true
        emit_signal("save_completed")
    else:
        result.error = "Failed to write save file"
        emit_signal("save_failed", result.error)
    
    return result
```

### System-Specific Serializer Registration
```gdscript
# Each system self-registers on initialization
func _ready():
    # Core systems (high priority)
    SaveManager.register_serializer("player", PlayerSerializer.new(), 10)
    SaveManager.register_serializer("time", TimeSerializer.new(), 15)
    SaveManager.register_serializer("economy", EconomySerializer.new(), 20)
    
    # Game systems (medium priority)
    SaveManager.register_serializer("inventory", InventorySerializer.new(), 25)
    SaveManager.register_serializer("npcs", NPCSerializer.new(), 30)
    SaveManager.register_serializer("assimilation", AssimilationSerializer.new(), 35)
    SaveManager.register_serializer("coalition", CoalitionSerializer.new(), 40)
    SaveManager.register_serializer("quests", QuestSerializer.new(), 45)
    SaveManager.register_serializer("trust", TrustSerializer.new(), 50)
    
    # World state (lower priority)
    SaveManager.register_serializer("districts", DistrictSerializer.new(), 55)
    SaveManager.register_serializer("detection", DetectionSerializer.new(), 60)
    SaveManager.register_serializer("puzzles", PuzzleSerializer.new(), 65)
    SaveManager.register_serializer("events", EventSerializer.new(), 70)
```

## Overnight Event Processing

### Pre-Save Updates
```gdscript
func _process_overnight_events():
    # Order matters - some systems depend on others
    
    # 1. Time passes first
    TimeManager.advance_to_next_day()
    
    # 2. Assimilation spreads
    var spread_report = AssimilationManager.process_overnight_spread()
    overnight_reports["assimilation"] = spread_report
    
    # 3. Coalition acts (may be affected by new assimilations)
    var coalition_report = CoalitionManager.process_overnight_actions()
    overnight_reports["coalition"] = coalition_report
    
    # 4. Economy updates (rent, market changes)
    var economy_report = EconomyManager.process_overnight_economy()
    overnight_reports["economy"] = economy_report
    
    # 5. NPC schedules update
    NPCManager.process_overnight_movements()
    
    # 6. Detection levels decay
    DetectionManager.apply_overnight_decay()
    
    # 7. Puzzle timers advance
    PuzzleManager.advance_time_sensitive_puzzles()
    
    # 8. Check for ending triggers
    MultipleEndingsManager.check_ending_conditions()
```

### Overnight Report Generation
```gdscript
func generate_overnight_report() -> Array:
    var report_items = []
    
    # Assimilation spread (most critical)
    if overnight_reports.assimilation.new_infections > 0:
        report_items.append({
            "priority": "critical",
            "text": "%d NPCs were assimilated (%d%% total)" % [
                overnight_reports.assimilation.new_infections,
                AssimilationManager.get_station_ratio() * 100
            ]
        })
    
    # Coalition actions
    for action in overnight_reports.coalition.completed_actions:
        report_items.append({
            "priority": "high",
            "text": "Coalition: " + action.description
        })
    
    # Economic changes
    if overnight_reports.economy.market_event:
        report_items.append({
            "priority": "medium",
            "text": overnight_reports.economy.market_event
        })
    
    # Quest deadlines
    var approaching_deadlines = QuestManager.get_deadlines_within_days(2)
    for quest in approaching_deadlines:
        report_items.append({
            "priority": "high",
            "text": "Quest deadline approaching: " + quest.name
        })
    
    return report_items
```

## Error Handling

### Save Failures with Recovery
```gdscript
func handle_save_failure(error: String):
    # Never lose progress due to save failure
    var dialog = SaveErrorDialog.instance()
    dialog.set_message("Failed to save game: " + error)
    
    # Offer recovery options
    if error.contains("disk full"):
        dialog.add_option("Free Space and Retry", "_free_space_guide")
    elif error.contains("permission"):
        dialog.add_option("Check Permissions", "_permission_guide")
    
    dialog.add_option("Retry Save", "_retry_save")
    dialog.add_option("Sleep Without Saving", "_sleep_no_save_dangerous")
    dialog.add_option("Cancel Sleep", "_cancel_sleep")
    
    # Log detailed error for debugging
    SaveManager.log_save_error({
        "error": error,
        "modules_saved": get_successfully_saved_modules(),
        "disk_space": OS.get_free_static_memory(),
        "save_size_estimate": estimate_save_size()
    })
```

### Corruption Recovery
```gdscript
func detect_corruption_on_load():
    var validation = SaveManager.validate_save_file()
    
    if not validation.valid:
        var dialog = CorruptionDialog.instance()
        dialog.set_title("Save File Issue Detected")
        
        # Specific corruption feedback
        if validation.missing_modules.size() > 0:
            dialog.add_info("Missing data: " + str(validation.missing_modules))
        
        if validation.checksum_mismatch:
            dialog.add_info("Save file may have been modified")
        
        # Recovery options
        if SaveManager.backup_exists():
            var backup_info = SaveManager.get_backup_info()
            dialog.add_option(
                "Restore from backup (Day %d)" % backup_info.day,
                "_restore_backup"
            )
        
        if validation.partial_recovery_possible:
            dialog.add_option(
                "Attempt partial recovery",
                "_partial_recovery"
            )
        
        dialog.add_option("Start New Game", "_new_game")
        dialog.show()
```

## Platform-Specific Implementation

### Save File Management
```gdscript
class SaveFileManager:
    const SAVE_DIR_NAME = "ASilentRefraction"
    const CURRENT_SAVE = "current.srf"
    const BACKUP_SAVE = "backup.srf"
    const TEMP_SAVE = "temp.srf"
    
    func get_save_directory() -> String:
        var base_dir = ""
        match OS.get_name():
            "Windows":
                base_dir = OS.get_user_data_dir()
            "X11", "Linux":
                base_dir = OS.get_config_dir()
            "OSX":
                base_dir = OS.get_user_data_dir()
            _:
                base_dir = "user://"
        
        return base_dir.plus_file(SAVE_DIR_NAME).plus_file("saves")
    
    func ensure_save_directory() -> bool:
        var dir = Directory.new()
        var save_dir = get_save_directory()
        
        if not dir.dir_exists(save_dir):
            var error = dir.make_dir_recursive(save_dir)
            if error != OK:
                push_error("Cannot create save directory: " + str(error))
                return false
        
        # Set appropriate permissions
        if OS.get_name() in ["X11", "Linux", "OSX"]:
            OS.execute("chmod", ["700", save_dir])
        
        return true
```

## Debug Features

### Development Tools
```gdscript
class DebugSaveCommands:
    # Only available in debug builds
    static func register_debug_commands():
        if not OS.is_debug_build():
            return
        
        Console.register_command("force_save", self, "_cmd_force_save",
            "Force save without sleeping")
        Console.register_command("corrupt_save", self, "_cmd_corrupt_save",
            "Corrupt save file for testing")
        Console.register_command("analyze_save", self, "_cmd_analyze_save",
            "Show save file analytics")
        Console.register_command("export_save", self, "_cmd_export_save",
            "Export save file for debugging")
    
    static func _cmd_analyze_save():
        var analysis = SaveManager.analyze_current_save()
        print("=== Save File Analysis ===")
        print("File size: %d KB" % (analysis.file_size / 1024))
        print("Modules: %d" % analysis.module_count)
        print("Largest module: %s (%d KB)" % [
            analysis.largest_module,
            analysis.largest_module_size / 1024
        ])
        print("Compression ratio: %.2f:1" % analysis.compression_ratio)
        print("Day: %d" % analysis.game_day)
        print("Play time: %.1f hours" % (analysis.play_time / 3600.0))
        print("NPCs saved: %d" % analysis.npc_count)
        print("Assimilation: %.1f%%" % (analysis.assimilation_ratio * 100))
```

## Save System Metrics

### Performance Targets
```gdscript
const SAVE_PERFORMANCE_TARGETS = {
    "save_time_ms": 1000,      # Complete save in < 1 second
    "load_time_ms": 2000,      # Complete load in < 2 seconds  
    "file_size_kb": 1024,      # Typical save < 1 MB
    "compression_ratio": 10.0   # 10:1 compression minimum
}

func measure_save_performance():
    var metrics = {}
    var start_time = OS.get_ticks_msec()
    
    # Measure save
    SaveManager.save_game()
    metrics.save_time = OS.get_ticks_msec() - start_time
    
    # Measure file size
    var file = File.new()
    file.open(SaveManager.get_current_save_path(), File.READ)
    metrics.file_size = file.get_len()
    file.close()
    
    # Check against targets
    for metric in SAVE_PERFORMANCE_TARGETS:
        if metrics[metric] > SAVE_PERFORMANCE_TARGETS[metric]:
            push_warning("Save performance below target: " + metric)
```

## Integration with Sleep System

The save system is fundamentally tied to the sleep system. The Sleep System document will detail:

### Sleep System Requirements for Save System
- Sleep location types and their properties
- Fatigue thresholds that allow/force sleep
- Time-of-day restrictions for different locations
- Sleep quality factors affecting recovery
- Overnight event processing order
- Special sleep events (nightmares, visions)
- Wake-up interruptions (raids, emergencies)
- Alternative sleep locations discovered through gameplay

### Data Passed to Sleep System
```gdscript
var sleep_context = {
    "location": current_sleep_location,
    "comfort_level": location.comfort_level,
    "safety_level": calculate_location_safety(),
    "time_slept": calculate_sleep_duration(),
    "overnight_events": overnight_reports,
    "fatigue_before": FatigueSystem.get_exhaustion(),
    "suspicion_before": DetectionManager.get_suspicion_level()
}
```

## Conclusion

The save system reinforces "A Silent Refraction's" core themes of consequence and planning by tying saves exclusively to sleep. By leveraging the modular serialization architecture, each game system can evolve independently while maintaining save compatibility. The overnight event processing creates emergent narrative moments, while the various sleep locations provide strategic choices balancing safety, cost, and comfort. The single-slot design ensures every decision has weight, making each save point a meaningful checkpoint in the player's journey to either escape or control the station.