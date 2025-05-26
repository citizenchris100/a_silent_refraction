# Inventory UI Design Document

## Overview

The Inventory UI provides a SCUMM-style interface for managing the player's items, integrating with both the limited on-person inventory and infinite barracks storage. The UI must balance classic adventure game aesthetics with the strategic depth of the dual storage system while seamlessly integrating with all game systems.

## Core Design Principles

### SCUMM-Style Foundation
- Grid-based item display with icons
- Verb-based interaction system
- Non-modal overlay that doesn't pause gameplay
- Classic adventure game visual language

### Dual Storage Integration
- Clear distinction between on-person and barracks storage
- Visual feedback for storage limitations
- Easy transfer between storage types
- Cost/time implications clearly communicated

### System Integration Priority
- Must work with existing verb UI system
- Respect time management costs
- Support economy system transactions
- Enable puzzle system combinations
- Facilitate disguise quick-changes

## UI Layout

### Main Inventory Window
```
┌────────────────────────────────────────────────────────────┐
│ INVENTORY                                           [X]    │
├────────────────────────────────────────────────────────────┤
│ On Person (12/15):                     Credits: 450       │
│ ┌──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┐ │
│ │[Key] │[Card]│[Tool]│[Data]│      │      │      │      │ │
│ │ x1   │ x1   │ x1   │ x3   │      │      │      │      │ │
│ ├──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┤ │
│ │[Food]│[Med] │[Suit]│[Box] │      │      │      │      │ │
│ │ x2   │ x1   │ x1   │ x1   │      │      │      │      │ │
│ └──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┘ │
│                                                            │
│ Selected: Security Keycard                                 │
│ "Level 2 access to Habitation District security doors"    │
│                                                            │
│ Actions: [Use] [Examine] [Combine] [Transfer] [Drop]      │
├────────────────────────────────────────────────────────────┤
│ Barracks Storage: [Access] (30 min travel + 10 credits)   │
└────────────────────────────────────────────────────────────┘
```

### Barracks Storage View (When Accessed)
```
┌────────────────────────────────────────────────────────────┐
│ BARRACKS STORAGE                                   [Back]  │
├────────────────────────────────────────────────────────────┤
│ Categories: [All] [Tools] [Documents] [Clothing] [Misc]   │
│ ┌──────────────────────────────────────────────────────┐   │
│ │ • Maintenance Uniform                             x1 │   │
│ │ • Encrypted Data Pad                              x2 │   │
│ │ • Station Blueprints                              x1 │   │
│ │ • Emergency Rations                               x5 │   │
│ │ • Spare ID Cards                                  x3 │   │
│ │ • Research Notes                                  x8 │   │
│ │ • [More items...]                                    │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                            │
│ Transfer to Person: [Take] [Take All Similar]             │
│ Organization: [Sort by Type] [Sort by Date] [Search]       │
└────────────────────────────────────────────────────────────┘
```

## Item Management

### On-Person Inventory
```gdscript
class InventoryUI:
    const MAX_ON_PERSON_SLOTS = 15
    var on_person_items = {}  # slot -> ItemData
    var selected_slot = -1
    
    func can_add_item(item: ItemData) -> bool:
        # Check weight and slot availability
        return get_free_slots() > 0 and current_weight + item.weight <= MAX_WEIGHT
    
    func add_item(item: ItemData) -> bool:
        if not can_add_item(item):
            show_inventory_full_dialog()
            return false
        
        var slot = find_free_slot()
        on_person_items[slot] = item
        update_display()
        
        # Notify other systems
        emit_signal("item_added", item)
        return true
```

### Item Data Structure
```gdscript
class ItemData:
    var id: String
    var name: String
    var description: String
    var icon: Texture
    var weight: float
    var stackable: bool
    var stack_size: int = 1
    var category: String  # "tool", "document", "clothing", etc.
    var combinable_with: Array  # Item IDs this can combine with
    var verb_actions: Dictionary  # verb -> action_result
    var quest_item: bool = false  # Protected from dropping
    var disguise_role: String = ""  # For clothing items
    var evidence_type: String = ""  # For investigation items
    var perishable: bool = false
    var expiry_day: int = -1  # Day when item expires
```

## System Integration

### Economy System Integration
```gdscript
func integrate_economy():
    # Show current credits
    $CreditsLabel.text = "Credits: %d" % EconomyManager.get_credits()
    
    # Connect to economy signals
    EconomyManager.connect("credits_changed", self, "_on_credits_changed")
    
    # Handle merchant transactions
    func sell_item(item: ItemData):
        var value = EconomyManager.get_item_value(item.id)
        if EconomyManager.add_credits(value):
            remove_item(item)
            show_notification("Sold %s for %d credits" % [item.name, value])
```

### Time Management Integration
```gdscript
func show_transfer_dialog(item: ItemData):
    if player_at_barracks():
        # Instant transfer
        transfer_to_barracks(item)
    else:
        # Calculate time and show in game time
        var travel_time = TimeManager.calculate_travel_time(
            GameManager.current_district, 
            "habitation"  # Barracks location
        )
        var dialog = TransferDialog.instance()
        dialog.setup(item, travel_time)
        dialog.connect("confirmed", self, "_on_transfer_confirmed")

func _on_transfer_confirmed(item: ItemData):
    # Advance time for travel
    TimeManager.advance_time(travel_time * 2)  # Round trip
    # Deduct tram costs
    var cost = TramSystem.calculate_cost(GameManager.current_district, "habitation")
    EconomyManager.deduct_credits(cost * 2)
```

### Quest System Integration
```gdscript
func can_drop_item(item: ItemData) -> bool:
    if item.quest_item:
        show_notification("Cannot drop quest items")
        return false
    
    # Check if item is needed for active quests
    if QuestManager.is_item_required(item.id):
        show_notification("This item is needed for an active quest")
        return false
    
    return true

# Highlight items needed for current objectives
func highlight_quest_items():
    var required_items = QuestManager.get_required_items()
    for slot in on_person_items:
        var item = on_person_items[slot]
        if item.id in required_items:
            highlight_slot(slot, QUEST_HIGHLIGHT_COLOR)
```

### Puzzle System Integration
```gdscript
func start_combine_mode(item: ItemData):
    combination_mode = true
    first_item = item
    
    # Get valid combinations from puzzle system
    var valid_combos = PuzzleManager.get_valid_combinations(item.id)
    highlight_compatible_items(valid_combos)
    
    show_prompt("Select item to combine with " + item.name)

func complete_combination(second_item: ItemData):
    var result = PuzzleManager.try_combination(first_item.id, second_item.id)
    if result:
        remove_item(first_item)
        remove_item(second_item)
        add_item(result)
        show_notification("Created: " + result.name)
        
        # Check if this solves a puzzle
        PuzzleManager.check_puzzle_completion(result.id)
```

### Disguise System Integration
```gdscript
func quick_change_menu():
    var clothing_items = get_items_by_category("clothing")
    if clothing_items.empty():
        show_notification("No uniforms available")
        return
    
    var menu = QuickChangeMenu.instance()
    for item in clothing_items:
        var role = DisguiseManager.get_role_for_item(item.id)
        menu.add_option(item, role)
    
    menu.connect("outfit_selected", self, "_on_outfit_selected")

func _on_outfit_selected(item: ItemData):
    DisguiseManager.equip_disguise(item.id)
    update_equipped_indicator(item)
    
    # Warn about role obligations
    if DisguiseManager.has_active_obligations():
        show_notification("Remember: You must fulfill your role duties!")
```

### NPC Trust/Dialog Integration
```gdscript
func use_item_with_npc(item: ItemData, npc_id: String):
    # Check if this is a gift or evidence
    if NPCTrustManager.is_gift_item(item.id, npc_id):
        var trust_gain = NPCTrustManager.calculate_gift_value(item.id, npc_id)
        show_notification("Gift will improve trust by ~%d" % trust_gain)
    
    # Check if item unlocks dialog options
    if DialogManager.item_unlocks_dialog(item.id, npc_id):
        show_notification("This item may reveal new conversation topics")
    
    # Handle evidence presentation
    if item.evidence_type != "":
        if NPCManager.get_npc(npc_id).is_suspect():
            show_notification("Presenting evidence to a suspect...")
```

### Detection System Integration
```gdscript
func check_suspicious_items():
    var suspicious_items = []
    for slot in on_person_items:
        var item = on_person_items[slot]
        if DetectionManager.is_item_suspicious(item.id, GameManager.current_district):
            suspicious_items.append(item)
    
    if suspicious_items.size() > 0:
        show_warning("Carrying suspicious items increases detection risk!")
        for item in suspicious_items:
            highlight_slot(get_item_slot(item), SUSPICION_COLOR)
```

### District Access Integration
```gdscript
func check_access_items():
    var current_district = GameManager.current_district
    var required_access = DistrictAccessManager.get_required_items(current_district)
    
    for req in required_access:
        if not has_item(req):
            show_notification("Missing: %s for full district access" % req)
```

## Modular Serialization

```gdscript
# src/core/serializers/inventory_serializer.gd
extends BaseSerializer

class_name InventorySerializer

func get_serializer_id() -> String:
    return "inventory"

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    var inv_manager = get_node("/root/Game/InventoryManager")
    if not inv_manager:
        return {}
    
    return {
        "on_person": _serialize_items(inv_manager.on_person_items),
        "barracks": _serialize_items(inv_manager.barracks_items),
        "has_barracks_access": inv_manager.has_barracks_access,
        "equipped_disguise": inv_manager.equipped_disguise_id,
        "last_sort_method": inv_manager.last_sort_method,
        "favorite_items": inv_manager.favorite_items
    }

func deserialize(data: Dictionary) -> void:
    var inv_manager = get_node("/root/Game/InventoryManager")
    if not inv_manager:
        return
    
    inv_manager.on_person_items = _deserialize_items(data.get("on_person", {}))
    inv_manager.barracks_items = _deserialize_items(data.get("barracks", {}))
    inv_manager.has_barracks_access = data.get("has_barracks_access", true)
    inv_manager.equipped_disguise_id = data.get("equipped_disguise", "")
    inv_manager.last_sort_method = data.get("last_sort_method", "type")
    inv_manager.favorite_items = data.get("favorite_items", [])
    
    # Refresh UI if open
    if inv_manager.ui_open:
        inv_manager.refresh_display()

func _serialize_items(items: Dictionary) -> Array:
    var serialized = []
    for slot in items:
        var item = items[slot]
        serialized.append({
            "slot": slot,
            "id": item.id,
            "quantity": item.stack_size,
            "expiry": item.expiry_day if item.perishable else -1
        })
    return serialized

func _deserialize_items(data: Array) -> Dictionary:
    var items = {}
    for item_data in data:
        var item = ItemManager.get_item(item_data.id)
        if item:
            item.stack_size = item_data.get("quantity", 1)
            if item.perishable:
                item.expiry_day = item_data.get("expiry", -1)
            items[item_data.slot] = item
    return items

func _ready():
    # Self-register with medium priority (after core systems, before UI)
    SaveManager.register_serializer("inventory", self, 25)
```

## Performance Optimization

### Lazy Loading
```gdscript
# Only load barracks items when accessed
func load_barracks_items():
    if barracks_items_loaded:
        return
    
    barracks_items = ItemManager.load_barracks_items()
    barracks_items_loaded = true
    
    # Check for expired items
    if TimeManager.is_initialized():
        check_perishable_items()
```

### Icon Caching
```gdscript
var icon_cache = {}

func get_item_icon(item_id: String) -> Texture:
    if not icon_cache.has(item_id):
        icon_cache[item_id] = load("res://assets/items/" + item_id + ".png")
    return icon_cache[item_id]
```

## Visual Design

### Color Coding
```gdscript
const ITEM_COLORS = {
    "common": Color(0.8, 0.8, 0.8),      # Gray
    "important": Color(0.9, 0.9, 0.4),   # Yellow
    "quest": Color(0.4, 0.8, 0.9),       # Cyan
    "combinable": Color(0.8, 0.6, 0.9),  # Purple
    "perishable": Color(0.9, 0.6, 0.4),  # Orange
    "suspicious": Color(0.9, 0.4, 0.4),  # Red
    "disguise": Color(0.6, 0.9, 0.6),    # Green
    "evidence": Color(0.7, 0.7, 0.9)     # Blue
}
```

### Dynamic Indicators
- Quest items: Pulsing cyan border
- Expiring items: Timer overlay
- Suspicious items: Red warning icon
- Equipped disguise: Green checkmark
- Combinable items: Purple highlight when in combine mode

## Accessibility Features

### Keyboard Navigation
- Tab/Shift+Tab: Navigate slots
- Enter: Select/use item
- E: Examine selected
- C: Start combine mode
- Q: Quick change (disguises)
- T: Transfer to/from barracks
- Escape: Close inventory

### Screen Reader Support
- Item descriptions on focus
- Quantity announcements
- Action availability
- Storage location indicators
- System integration warnings

## Edge Cases and Error Handling

### Inventory Full Scenarios
```gdscript
func handle_inventory_full(new_item: ItemData):
    # Offer intelligent options based on context
    var options = []
    
    # Check for stackable items
    if new_item.stackable and has_item(new_item.id):
        options.append("Stack with existing")
    
    # Check for less valuable items
    var least_valuable = find_least_valuable_item()
    if least_valuable and not least_valuable.quest_item:
        options.append("Drop %s (value: %d)" % [least_valuable.name, least_valuable.value])
    
    # Always offer barracks storage if available
    if has_barracks_access:
        var cost = calculate_storage_trip_cost()
        options.append("Store in barracks (%d credits, %d min)" % [cost, travel_time])
    
    show_inventory_full_dialog(new_item, options)
```

### Lost Barracks Access
```gdscript
func handle_barracks_loss():
    # Check if player has critical items stored
    var critical_items = check_critical_items_in_barracks()
    
    if critical_items.size() > 0:
        # Offer recovery quest
        QuestManager.add_quest("recover_barracks_access", {
            "critical_items": critical_items,
            "urgency": calculate_urgency(critical_items)
        })
        
        show_notification("Critical items trapped in barracks! Find another way in.")
```

### Perishable Item Management
```gdscript
func check_perishable_items():
    var current_day = TimeManager.get_current_day()
    var expired_items = []
    
    for slot in on_person_items:
        var item = on_person_items[slot]
        if item.perishable and item.expiry_day <= current_day:
            expired_items.append(item)
    
    for item in expired_items:
        remove_item(item)
        show_notification("%s has expired and was discarded" % item.name)
        
        # Check if this affects any quests
        QuestManager.notify_item_lost(item.id)
```

## Debug Features

```gdscript
func debug_commands():
    # Debug mode only
    if not OS.is_debug_build():
        return
    
    # Give item
    func debug_give_item(item_id: String, quantity: int = 1):
        var item = ItemManager.get_item(item_id)
        if item:
            for i in quantity:
                add_item(item.duplicate())
    
    # Unlock all storage
    func debug_unlock_all_storage():
        has_barracks_access = true
        # Add additional storage locations when implemented
    
    # Test weight limits
    func debug_fill_inventory():
        while get_free_slots() > 0:
            add_item(ItemManager.get_random_item())
    
    # Test system integrations
    func debug_test_integrations():
        print("Testing Economy: Credits = %d" % EconomyManager.get_credits())
        print("Testing Time: Current = %s" % TimeManager.get_current_time())
        print("Testing Quests: Required items = %s" % QuestManager.get_required_items())
        print("Testing Disguise: Current = %s" % DisguiseManager.get_current_role())
```

## Future Considerations

### Planned Enhancements
- Multiple storage locations (as districts are secured)
- Item crafting system (for puzzle solutions)
- Evidence chain visualization
- Quick-access hotbar for frequently used items
- Item condition/durability for certain objects

### System Evolution
- Coalition storage sharing (trusted members)
- Black market item laundering (remove suspicious tags)
- Time-based item transformations (evidence decay)
- Dynamic pricing based on scarcity/events

## Conclusion

The Inventory UI successfully merges classic SCUMM-style adventure game inventory management with strategic resource decisions through the dual storage system. By integrating deeply with all game systems - from economy and time management to puzzles and detection - the inventory becomes a central hub for player decision-making. The modular serialization architecture ensures the system can evolve without breaking existing saves, while the comprehensive error handling provides a smooth player experience even in edge cases.