# Barracks System Design Document

## Overview

The Barracks System manages player housing in "A Silent Refraction", handling rent payments, eviction processes, and re-admittance. This system creates economic pressure through weekly rent obligations while providing the primary save location and personal storage access. The system operates automatically without direct NPC interaction, using the game's notification system to communicate with players.

## Core Mechanics

### Rent Structure
- **Weekly Rent**: Automatically deducted every Friday
- **Grace Period**: One week after first missed payment
- **Eviction**: After two weeks of non-payment
- **Re-admittance**: Pay Concierge the full amount owed

### System Constants
```gdscript
class BarracksConstants:
    const WEEKLY_RENT = 450  # Credits
    const RENT_DUE_DAY = 5   # Friday (0=Sunday, 6=Saturday)
    const WARNING_DAYS_BEFORE = 2  # Wednesday warning
    const GRACE_PERIOD_DAYS = 7
    
    # Room quality affects sleep
    const ROOM_COMFORT_LEVEL = 1.0
    const STORAGE_ACCESS_ENABLED = true
    
    # Re-admittance
    const CONCIERGE_LOCATION = "barracks_lobby"
    const CONCIERGE_NPC_ID = "barracks_concierge"
```

## Rent Payment System

### Weekly Rent Calculation
```gdscript
class RentManager:
    var weeks_owed: int = 0
    var grace_period_active: bool = false
    var eviction_date: int = -1
    var last_payment_day: int = -1
    
    func get_day_of_week(day: int) -> int:
        # Game starts on Monday (Day 1 = Monday)
        return (day - 1) % 7
    
    func is_rent_due_day(day: int) -> bool:
        return get_day_of_week(day) == RENT_DUE_DAY
    
    func calculate_total_owed() -> int:
        return WEEKLY_RENT * max(weeks_owed, 1)
    
    func get_next_rent_day() -> int:
        var current_day = TimeManager.current_day
        var days_until_friday = (RENT_DUE_DAY - get_day_of_week(current_day) + 7) % 7
        if days_until_friday == 0 and not has_paid_this_week():
            return current_day
        return current_day + days_until_friday
```

### Automatic Rent Collection
```gdscript
func process_rent_collection():
    if not is_rent_due_day(TimeManager.current_day):
        return
    
    if has_paid_this_week():
        return  # Already processed
    
    var rent_due = calculate_total_owed()
    var player_credits = EconomyManager.get_credits()
    
    if player_credits >= rent_due:
        # Successful payment
        EconomyManager.deduct_credits(rent_due)
        weeks_owed = 0
        grace_period_active = false
        last_payment_day = TimeManager.current_day
        
        PromptNotificationSystem.show_info(
            "rent_payment_success",
            "Rent paid successfully!\n\nAmount: %d credits\nNext payment due: %s\nRemaining balance: %d credits" % [
                rent_due,
                get_next_rent_date_string(),
                EconomyManager.get_credits()
            ],
            "Payment Confirmed"
        )
        
        # Log transaction
        EconomyManager.log_transaction({
            "type": "rent_payment",
            "amount": rent_due,
            "day": TimeManager.current_day,
            "weeks_paid": weeks_owed + 1
        })
    else:
        # Failed payment
        handle_missed_payment()
```

### Missed Payment Handling
```gdscript
func handle_missed_payment():
    weeks_owed += 1
    
    if weeks_owed == 1 and not grace_period_active:
        # First missed payment - start grace period
        grace_period_active = true
        eviction_date = TimeManager.current_day + GRACE_PERIOD_DAYS
        
        show_grace_period_notice()
        
        # Notify other systems
        emit_signal("rent_missed_first_time")
        
    elif weeks_owed >= 2:
        # Second missed payment - eviction
        execute_eviction()
```

## Warning System

### Pre-Payment Warnings
```gdscript
func check_payment_warnings():
    var days_until_rent = get_days_until_next_rent()
    
    if days_until_rent == WARNING_DAYS_BEFORE:
        var player_credits = EconomyManager.get_credits()
        var amount_due = calculate_total_owed()
        
        if player_credits < amount_due:
            show_insufficient_funds_warning(amount_due - player_credits)
```

### Warning Notifications
```gdscript
func show_insufficient_funds_warning(shortfall: int):
    PromptNotificationSystem.show_warning(
        "rent_due_insufficient_funds",
        "Rent Payment Due Soon!\n\nRent due: %d credits\nYour balance: %d credits\nShortfall: %d credits\n\nPayment due in 2 days (Friday)" % [
            calculate_total_owed(),
            EconomyManager.get_credits(),
            shortfall
        ],
        "Rent Warning"
    )
    
    # Add to quest log as reminder
    QuestManager.add_reminder({
        "id": "rent_payment_warning",
        "text": "Pay rent by Friday",
        "amount": calculate_total_owed(),
        "day": get_next_rent_day()
    })
```

### Grace Period Notice
```gdscript
func show_grace_period_notice():
    var total_owed = WEEKLY_RENT * 2  # This week + next week
    
    PromptNotificationSystem.show_critical(
        "rent_grace_period",
        "RENT PAYMENT MISSED!\n\nYou have entered a grace period.\n\nTotal owed: %d credits (2 weeks rent)\nDays until eviction: %d\n\nPay the full amount to the Concierge or face eviction!" % [
            total_owed,
            GRACE_PERIOD_DAYS
        ],
        "Payment Overdue!"
    )
    
    # Update time display to show critical deadline
    TimeDisplayUI.add_critical_deadline({
        "text": "Eviction in %d days" % GRACE_PERIOD_DAYS,
        "day": eviction_date,
        "type": "eviction"
    })
```

## Eviction Process

### Execute Eviction
```gdscript
func execute_eviction():
    # Show eviction notice with re-admittance instructions
    show_eviction_notice()
    
    # Revoke access
    has_barracks_access = false
    PlayerData.add_flag("evicted_from_barracks")
    
    # Update sleep system
    SleepSystem.set_player_homeless(true)
    
    # Lock personal storage (items remain but inaccessible)
    InventoryManager.lock_barracks_storage()
    
    # Update save system
    SaveManager.set_save_location("mall_squat")
    
    # Notify all integrated systems
    emit_signal("player_evicted", {
        "day": TimeManager.current_day,
        "amount_owed": calculate_total_owed()
    })
    
    # Add eviction to permanent record
    PlayerStats.add_major_event("evicted_day_%d" % TimeManager.current_day)
```

### Eviction Notice
```gdscript
func show_eviction_notice():
    PromptNotificationSystem.show_critical(
        "barracks_eviction",
        "EVICTION NOTICE\n\nYou have been evicted from your barracks room for non-payment of rent.\n\nAmount owed: %d credits\n\nTo regain access:\n1. Collect %d credits\n2. Visit the Concierge in the Barracks Lobby\n3. Pay the full amount owed\n\nUntil then, you must find alternative sleeping arrangements." % [
            calculate_total_owed(),
            calculate_total_owed()
        ],
        "Evicted!"
    )
    
    # Log for player reference
    add_to_journal({
        "title": "Evicted from Barracks",
        "content": "Pay %d credits to Concierge for re-admittance" % calculate_total_owed(),
        "type": "critical_info"
    })
```

## Re-admittance Process

### Concierge Interaction
```gdscript
func setup_concierge_interaction():
    # Add special dialog option when evicted
    var concierge = NPCManager.get_npc(CONCIERGE_NPC_ID)
    
    if is_evicted() and EconomyManager.get_credits() >= calculate_total_owed():
        concierge.add_context_dialog({
            "id": "pay_back_rent",
            "text": "I'd like to pay my back rent",
            "condition": "player_evicted_can_pay",
            "action": "_handle_rent_repayment"
        })
    elif is_evicted():
        concierge.add_context_dialog({
            "id": "ask_about_rent",
            "text": "About my eviction...",
            "condition": "player_evicted_cannot_pay",
            "response": "You owe %d credits. Come back when you have it." % calculate_total_owed()
        })
```

### Rent Repayment
```gdscript
func handle_rent_repayment():
    var amount_owed = calculate_total_owed()
    
    # Deduct payment
    EconomyManager.deduct_credits(amount_owed)
    
    # Reset rent status
    weeks_owed = 0
    grace_period_active = false
    eviction_date = -1
    last_payment_day = TimeManager.current_day
    
    # Restore access
    has_barracks_access = true
    PlayerData.remove_flag("evicted_from_barracks")
    
    # Update systems
    SleepSystem.set_player_homeless(false)
    InventoryManager.unlock_barracks_storage()
    SaveManager.set_save_location("barracks")
    
    # Show confirmation
    show_readmittance_confirmation()
    
    # Notify systems
    emit_signal("player_readmitted", TimeManager.current_day)

### Readmittance Confirmation
```gdscript
func show_readmittance_confirmation():
    PromptNotificationSystem.show_info(
        "barracks_readmittance",
        "Welcome back!\n\nYour barracks access has been restored.\n\nNext rent payment due: %s\nAmount: %d credits\n\nYour belongings in storage are now accessible again." % [
            get_next_rent_date_string(),
            WEEKLY_RENT
        ],
        "Access Restored"
    )
```

## System Integration

### Economy System Integration
```gdscript
func integrate_economy():
    # Track rent as major expense
    EconomyManager.register_recurring_expense({
        "id": "barracks_rent",
        "amount": WEEKLY_RENT,
        "frequency": "weekly",
        "day": RENT_DUE_DAY,
        "critical": true
    })
    
    # Rent affects economic pressure
    func calculate_economic_pressure():
        var days_until_rent = get_days_until_next_rent()
        var rent_pressure = 0.0
        
        if days_until_rent <= 3:
            var shortfall = max(0, calculate_total_owed() - EconomyManager.get_credits())
            rent_pressure = shortfall / float(WEEKLY_RENT)
        
        return rent_pressure
```

### Time Management Integration
```gdscript
func integrate_time_system():
    # Connect to day changes
    TimeManager.connect("day_changed", self, "_on_day_changed")
    
    func _on_day_changed(new_day: int):
        # Check if it's rent day
        if is_rent_due_day(new_day):
            process_rent_collection()
        
        # Check for warnings (Wednesday)
        elif get_day_of_week(new_day) == RENT_DUE_DAY - WARNING_DAYS_BEFORE:
            check_payment_warnings()
        
        # Check eviction date
        elif eviction_date > 0 and new_day >= eviction_date:
            execute_eviction()
```

### Sleep System Integration
```gdscript
func integrate_sleep_system():
    # Barracks access determines sleep location
    func can_sleep_in_barracks() -> bool:
        return has_barracks_access and not is_evicted()
    
    # Comfort level for barracks
    func get_barracks_comfort() -> float:
        if not has_barracks_access:
            return 0.0
        
        # Could be upgraded in future
        return ROOM_COMFORT_LEVEL
    
    # Sleep location validation
    SleepSystem.connect("checking_sleep_location", self, "_validate_barracks_sleep")
```

### Inventory System Integration
```gdscript
func integrate_inventory():
    # Storage access tied to rent status
    func can_access_barracks_storage() -> bool:
        return has_barracks_access and PlayerLocation.is_in_barracks()
    
    # Items remain during eviction but are inaccessible
    func get_storage_status() -> String:
        if not has_barracks_access:
            return "locked_eviction"
        elif not PlayerLocation.is_in_barracks():
            return "remote"
        else:
            return "accessible"
```

### Quest System Integration
```gdscript
func integrate_quest_system():
    # Rent creates implicit quests
    func generate_rent_quest():
        if weeks_owed > 0 or EconomyManager.get_credits() < WEEKLY_RENT:
            QuestManager.add_generated_quest({
                "id": "pay_weekly_rent",
                "name": "Pay Rent",
                "category": "economic",
                "description": "Pay your barracks rent to maintain housing",
                "objectives": [{
                    "text": "Collect %d credits" % calculate_total_owed(),
                    "type": "collect_money",
                    "amount": calculate_total_owed()
                }],
                "time_limit": get_next_rent_day(),
                "failure_consequence": "eviction" if weeks_owed > 0 else "grace_period",
                "auto_complete": true
            })
```

### Detection System Integration
```gdscript
func integrate_detection():
    # Being homeless increases suspicion
    DetectionManager.connect("calculating_base_suspicion", self, "_modify_suspicion")
    
    func _modify_suspicion(modifiers: Dictionary):
        if is_evicted():
            modifiers["homeless"] = 5  # +5 base suspicion
            modifiers["no_fixed_address"] = true
```

### Coalition System Integration
```gdscript
func integrate_coalition():
    # Coalition might help with rent
    func check_coalition_assistance():
        if CoalitionManager.get_trust_level() >= 75 and weeks_owed > 0:
            # High trust coalition might offer help
            CoalitionManager.trigger_assistance_event({
                "type": "rent_assistance",
                "amount": WEEKLY_RENT,
                "condition": "player_facing_eviction"
            })
    
    # Safe houses as alternative if evicted
    func unlock_emergency_housing():
        if is_evicted() and CoalitionManager.has_safe_house_access():
            SleepSystem.add_alternative_location("coalition_safe_house")
```

### NPC System Integration
```gdscript
func integrate_npcs():
    # Some NPCs comment on eviction
    func notify_npc_system():
        if is_evicted():
            NPCManager.add_global_flag("player_evicted")
            
            # Affects certain dialog
            DialogManager.add_context_modifier({
                "condition": "player_evicted",
                "npcs": ["security_guards", "merchants"],
                "modifier": "suspicious_of_homeless"
            })
```

### Assimilation System Integration
```gdscript
func integrate_assimilation():
    # Evicted players are more vulnerable
    func modify_overnight_spread():
        if is_evicted():
            # Sleeping rough means less awareness of spread
            AssimilationManager.add_spread_modifier({
                "source": "player_homeless",
                "modifier": 1.2  # 20% more spread
            })
```

## UI Integration

### Rent Status Display
```gdscript
class RentStatusUI:
    func update_display():
        if not has_barracks_access:
            status_label.text = "Evicted - %d credits owed" % calculate_total_owed()
            status_label.modulate = Color.red
        elif grace_period_active:
            status_label.text = "RENT OVERDUE - Pay by Day %d" % eviction_date
            status_label.modulate = Color.orange
        else:
            var days_until = get_days_until_next_rent()
            status_label.text = "Rent due in %d days" % days_until
            status_label.modulate = Color.white
```

### Calendar Integration
```gdscript
func add_rent_to_calendar():
    CalendarUI.add_recurring_event({
        "id": "weekly_rent",
        "name": "Rent Due",
        "day_of_week": RENT_DUE_DAY,
        "amount": WEEKLY_RENT,
        "type": "expense",
        "critical": true,
        "color": Color.red if weeks_owed > 0 else Color.yellow
    })
```

## Modular Serialization

```gdscript
class BarracksSerializer extends BaseSerializer:
    func get_serializer_id() -> String:
        return "barracks_system"
    
    func get_version() -> int:
        return 1
    
    func serialize() -> Dictionary:
        return {
            "has_access": has_barracks_access,
            "weeks_owed": weeks_owed,
            "grace_period_active": grace_period_active,
            "eviction_date": eviction_date,
            "last_payment_day": last_payment_day,
            "total_rent_paid": total_rent_paid,
            "eviction_count": eviction_count,
            "readmittance_count": readmittance_count
        }
    
    func deserialize(data: Dictionary) -> void:
        has_barracks_access = data.get("has_access", true)
        weeks_owed = data.get("weeks_owed", 0)
        grace_period_active = data.get("grace_period_active", false)
        eviction_date = data.get("eviction_date", -1)
        last_payment_day = data.get("last_payment_day", -1)
        total_rent_paid = data.get("total_rent_paid", 0)
        eviction_count = data.get("eviction_count", 0)
        readmittance_count = data.get("readmittance_count", 0)
        
        # Restore UI state
        if is_evicted():
            setup_evicted_state()
    
    func _ready():
        # Register with medium priority
        SaveManager.register_serializer("barracks_system", self, 30)
```

## Special Events

### Economic Hardship Assistance
```gdscript
func check_hardship_events():
    # Rare chance of rent reduction
    if EventManager.should_trigger("economic_crisis"):
        WEEKLY_RENT = int(WEEKLY_RENT * 0.8)  # 20% reduction
        PromptNotificationSystem.show_info(
            "rent_reduction_crisis",
            "Station-wide rent reduction due to economic crisis",
            "Economic Update"
        )
    
    # Coalition assistance
    if weeks_owed > 0 and randf() < 0.1:  # 10% chance
        if CoalitionManager.get_network_size() >= 5:
            var assistance = randi() % 200 + 100  # 100-300 credits
            EconomyManager.add_credits(assistance)
            PromptNotificationSystem.show_info(
                "coalition_rent_assistance",
                "Coalition members pooled %d credits to help with rent" % assistance,
                "Coalition Support"
            )
```

### Barracks Events
```gdscript
func trigger_barracks_events():
    # Room inspection (if behind on rent)
    if grace_period_active and randf() < 0.3:
        trigger_room_inspection()
    
    # Neighbor interactions
    if has_barracks_access and EventManager.should_trigger("neighbor_event"):
        trigger_neighbor_interaction()
```

## Debug Features

```gdscript
class BarracksDebugCommands:
    static func register_commands():
        if not OS.is_debug_build():
            return
        
        Console.register_command("evict_player", self, "_cmd_evict",
            "Force player eviction")
        Console.register_command("pay_rent", self, "_cmd_pay_rent",
            "Pay all owed rent")
        Console.register_command("set_rent_day", self, "_cmd_set_day",
            "Jump to next rent day")
        Console.register_command("toggle_rent", self, "_cmd_toggle",
            "Enable/disable rent system")
```

## Future Considerations

### Potential Enhancements
- Room upgrades for better sleep quality
- Roommate system for shared rent
- Alternative housing options
- Rent negotiation through high trust
- Barracks black market access

### Explicitly Not Supported
- Multiple rooms or housing options
- Rent negotiation with NPCs
- Partial rent payments
- Rent forgiveness
- Property ownership

## System Dependencies

The Barracks System integrates with the following systems:

### Required Systems
- **PromptNotificationSystem**: All player notifications and warnings
- **EconomyManager**: Credit transactions and economic tracking
- **TimeManager**: Day tracking and weekly rent cycles
- **SaveManager**: Save location management and data persistence
- **SleepSystem**: Sleep location validation and comfort levels
- **InventoryManager**: Storage access control
- **NPCManager**: Concierge interactions for re-admittance
- **QuestManager**: Rent payment reminders and implicit quests

### Optional Integrations
- **CoalitionManager**: Assistance events and alternative housing
- **DetectionManager**: Homelessness suspicion modifiers
- **AssimilationManager**: Vulnerability modifiers when evicted
- **EventManager**: Special economic events and assistance
- **CalendarUI**: Visual rent due dates
- **TimeDisplayUI**: Critical deadline warnings

## Conclusion

The Barracks System creates a constant economic pressure that drives player behavior and reinforces the game's themes of survival and resource management. By automating rent collection and providing clear consequences for non-payment, the system pushes players to maintain steady income while managing other priorities. The integration with sleep, storage, and social systems makes losing barracks access a significant but recoverable setback that changes how players approach the game.