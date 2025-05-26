# Inventory System Design

## Overview

The Inventory System implements SCUMM-style item management with a crucial strategic element: limited on-person storage versus infinite barracks storage. This creates meaningful decisions about what to carry, when to make storage runs, and whether maintaining barracks access is worth the time/money cost. The system deeply integrates with puzzle-solving, disguises, and the game's economic pressure.

## Core Concepts

### Storage Duality
- **On-Person Inventory**: Limited slots (8-12 items), always accessible
- **Barracks Storage**: Infinite capacity, requires physical presence
- **Trade-off**: Time and money to reach barracks vs. immediate availability
- **Risk**: Losing barracks access means losing stored items

### Item Philosophy
- **Everything is useful**: No red herring items
- **Combinations matter**: SCUMM-style item combinations for puzzles
- **Weight through slots**: No weight system, just slot limits
- **Context-sensitive**: Items behave differently in different situations

## System Architecture

### Core Components

#### 1. Inventory Manager (Singleton)
```gdscript
# src/core/systems/inventory_manager.gd
extends Node

signal item_added(item_id, location)
signal item_removed(item_id, location)
signal item_combined(item1_id, item2_id, result_id)
signal storage_accessed(location)
signal inventory_full()

# On-person inventory
var personal_inventory: Array = []  # Array of ItemData
var max_personal_slots: int = 10

# Barracks storage (only if player maintains access)
var barracks_storage: Dictionary = {}  # item_id: quantity
var has_barracks_access: bool = true

# Currently selected/held item for interactions
var held_item: ItemData = null

func add_item(item_id: String, quantity: int = 1, force_personal: bool = false) -> bool:
    var item_data = ItemRegistry.get_item(item_id)
    if not item_data:
        return false
    
    # If forcing personal or no barracks access, try personal only
    if force_personal or not has_barracks_access:
        return _add_to_personal(item_data, quantity)
    
    # Otherwise, add to personal if space, else queue for barracks
    if get_free_personal_slots() >= quantity:
        return _add_to_personal(item_data, quantity)
    else:
        # Mark item as pending for barracks storage
        _queue_for_barracks(item_data, quantity)
        UI.show_notification("Inventory full. Item marked for barracks storage.")
        return true

func _add_to_personal(item_data: ItemData, quantity: int) -> bool:
    if not item_data.stackable and quantity > 1:
        # Non-stackable items need individual slots
        if get_free_personal_slots() < quantity:
            emit_signal("inventory_full")
            return false
    elif item_data.stackable:
        # Check if we already have this item
        var existing = _find_item_in_personal(item_data.id)
        if existing:
            existing.quantity += quantity
            emit_signal("item_added", item_data.id, "personal")
            return true
    
    # Add new item(s)
    for i in range(quantity):
        if personal_inventory.size() >= max_personal_slots:
            emit_signal("inventory_full")
            return false
        
        var instance = ItemInstance.new()
        instance.item_data = item_data
        instance.quantity = 1 if not item_data.stackable else quantity
        personal_inventory.append(instance)
        
        if item_data.stackable:
            break  # Only one stack entry needed
    
    emit_signal("item_added", item_data.id, "personal")
    return true

func remove_item(item_id: String, quantity: int = 1, from_personal: bool = true) -> bool:
    if from_personal:
        return _remove_from_personal(item_id, quantity)
    else:
        return _remove_from_barracks(item_id, quantity)

func transfer_to_barracks(item_id: String, quantity: int = -1) -> bool:
    if not has_barracks_access:
        return false
    
    if not _player_at_barracks():
        UI.show_notification("You must be in your barracks to access storage.")
        return false
    
    var removed = _remove_from_personal(item_id, quantity)
    if removed > 0:
        _add_to_barracks(item_id, removed)
        emit_signal("storage_accessed", "barracks")
        return true
    
    return false

func retrieve_from_barracks(item_id: String, quantity: int = 1) -> bool:
    if not has_barracks_access:
        return false
    
    if not _player_at_barracks():
        UI.show_notification("You must be in your barracks to access storage.")
        return false
    
    if not item_id in barracks_storage:
        return false
    
    var available = min(quantity, barracks_storage[item_id])
    if _add_to_personal(ItemRegistry.get_item(item_id), available):
        barracks_storage[item_id] -= available
        if barracks_storage[item_id] <= 0:
            barracks_storage.erase(item_id)
        
        emit_signal("storage_accessed", "barracks")
        return true
    
    return false

func combine_items(item1_id: String, item2_id: String) -> ItemData:
    var combination = ItemCombiner.get_combination(item1_id, item2_id)
    if not combination:
        return null
    
    # Check if player has both items
    if not has_item(item1_id) or not has_item(item2_id):
        return null
    
    # Remove source items
    remove_item(item1_id, 1, true)
    remove_item(item2_id, 1, true)
    
    # Add result
    var result = ItemRegistry.get_item(combination.result_id)
    add_item(combination.result_id, 1, true)  # Force to personal
    
    emit_signal("item_combined", item1_id, item2_id, combination.result_id)
    
    # Trigger any combination events
    if combination.trigger_event:
        EventManager.trigger_event(combination.trigger_event)
    
    return result

func lose_barracks_access():
    has_barracks_access = false
    # Items in barracks become inaccessible but are not deleted
    # Could potentially be recovered later through quests
```

#### 2. Item System
```gdscript
# src/core/systems/item_registry.gd
extends Node

var items: Dictionary = {}  # item_id: ItemData

func _ready():
    _load_all_items()

# src/resources/item_data.gd
extends Resource

class_name ItemData

export var id: String = ""
export var name: String = ""
export var description: String = ""
export var icon: Texture
export var stackable: bool = false
export var max_stack: int = 1
export var category: String = "misc"  # misc, tool, disguise, quest, consumable
export var combinable: bool = true
export var usable: bool = true
export var value: int = 0  # Base credit value
export var illegal: bool = false  # Increases suspicion if detected

# Special properties
export var is_disguise: bool = false
export var disguise_type: String = ""  # civilian, maintenance, security, etc.
export var is_key: bool = false
export var unlocks: Array = []  # Door/container IDs

# Item instance for inventory
class ItemInstance:
    var item_data: ItemData
    var quantity: int = 1
    var condition: float = 1.0  # For degradable items
    var custom_data: Dictionary = {}  # For quest items with state
```

#### 3. Item Combination System
```gdscript
# src/core/systems/item_combiner.gd
extends Node

var combinations: Dictionary = {}  # "item1_id+item2_id": CombinationData

func _ready():
    _load_combinations()

func get_combination(item1_id: String, item2_id: String) -> CombinationData:
    # Check both orderings
    var key1 = item1_id + "+" + item2_id
    var key2 = item2_id + "+" + item1_id
    
    if key1 in combinations:
        return combinations[key1]
    elif key2 in combinations:
        return combinations[key2]
    
    return null

func can_combine(item1_id: String, item2_id: String) -> bool:
    return get_combination(item1_id, item2_id) != null

# src/resources/combination_data.gd
extends Resource

class_name CombinationData

export var item1_id: String = ""
export var item2_id: String = ""
export var result_id: String = ""
export var destroy_sources: bool = true
export var trigger_event: String = ""  # Optional event to trigger
export var required_location: String = ""  # Optional location requirement
export var fail_message: String = "Those items don't combine."
```

### Integration Systems

#### 1. Disguise Integration
```gdscript
# Extension to Inventory Manager
func get_current_disguise() -> String:
    for item in personal_inventory:
        if item.item_data.is_disguise:
            return item.item_data.disguise_type
    
    return "none"  # No disguise equipped

func equip_disguise(item_id: String) -> bool:
    var item = _find_item_in_personal(item_id)
    if not item or not item.item_data.is_disguise:
        return false
    
    # Remove any current disguise
    _unequip_current_disguise()
    
    # Mark new disguise as equipped
    item.custom_data["equipped"] = true
    
    # Notify other systems
    DisguiseManager.on_disguise_changed(item.item_data.disguise_type)
    
    return true
```

#### 2. Quest Item Integration
```gdscript
# Quest items can have special states
func update_quest_item_state(item_id: String, key: String, value):
    var item = _find_item_anywhere(item_id)
    if item:
        item.custom_data[key] = value
        
        # Notify quest system
        QuestManager.on_item_state_changed(item_id, key, value)
```

#### 3. Economic Integration
```gdscript
# Items have value and can be sold
func sell_item(item_id: String, quantity: int = 1) -> int:
    var item_data = ItemRegistry.get_item(item_id)
    if not item_data:
        return 0
    
    if not has_item(item_id, quantity):
        return 0
    
    var total_value = item_data.value * quantity
    
    # Black market items worth more but risky
    if item_data.illegal:
        total_value *= 2
        SuspicionManager.add_suspicion(10, "selling_illegal_goods")
    
    remove_item(item_id, quantity)
    EconomyManager.add_credits(total_value, "item_sale")
    
    return total_value
```

## MVP Implementation

### Basic Features
1. **Simple On-Person Inventory**
   - 10 slots maximum
   - Basic add/remove operations
   - Visual grid interface

2. **Barracks Storage**
   - Infinite capacity when accessible
   - Must be physically present to use
   - Simple transfer interface

3. **Core Items**
   - Food/Water (consumables)
   - Civilian clothes (disguise)
   - Keycard (access item)
   - Evidence items (quest items)

4. **Basic Combinations**
   - Keycard + Scanner = Copied Keycard
   - Wire + Panel = Hacked Panel
   - Evidence + Datapad = Compiled Report

### MVP Item Examples
```gdscript
# Food Ration
{
    "id": "food_ration",
    "name": "Food Ration",
    "category": "consumable",
    "stackable": true,
    "max_stack": 5,
    "value": 10
}

# Maintenance Disguise
{
    "id": "maintenance_uniform",
    "name": "Maintenance Uniform",
    "category": "disguise",
    "is_disguise": true,
    "disguise_type": "maintenance",
    "value": 75
}

# Security Keycard
{
    "id": "security_keycard_1",
    "name": "Level 1 Security Keycard",
    "category": "tool",
    "is_key": true,
    "unlocks": ["security_door_1", "storage_locker_5"],
    "value": 0  # Can't be sold
}
```

## Full Implementation

### Advanced Features

#### 1. Degradation System
```gdscript
# Some items degrade over time or with use
func use_item(item_id: String) -> bool:
    var item = _find_item_in_personal(item_id)
    if not item:
        return false
    
    # Apply degradation
    if item.item_data.degradable:
        item.condition -= 0.1
        
        if item.condition <= 0:
            remove_item(item_id, 1)
            UI.show_notification("%s broke!" % item.item_data.name)
    
    return true
```

#### 2. Container System
```gdscript
# World containers for finding items
class_name Container
extends InteractiveObject

export var container_id: String = ""
export var locked: bool = false
export var required_key: String = ""
export var contents: Array = []  # Array of {item_id, quantity}
export var searched: bool = false

func interact(verb: String, item: ItemData = null):
    if verb == "open" or verb == "search":
        if locked and not _try_unlock(item):
            return "It's locked."
        
        _open_container()
        return "You search the %s." % name
    
    return base.interact(verb, item)

func _open_container():
    searched = true
    
    for content in contents:
        InventoryManager.add_item(content.item_id, content.quantity)
    
    # Clear contents after taking
    contents.clear()
```

#### 3. Smart Storage Management
```gdscript
# Automatic sorting and organization
func auto_sort_inventory():
    personal_inventory.sort_custom(self, "_sort_by_category")
    
func _sort_by_category(a: ItemInstance, b: ItemInstance) -> bool:
    var order = ["quest", "tool", "disguise", "consumable", "misc"]
    var a_index = order.find(a.item_data.category)
    var b_index = order.find(b.item_data.category)
    return a_index < b_index

# Loadout system for quick swapping
var saved_loadouts: Dictionary = {}  # name: Array of item_ids

func save_loadout(name: String):
    var loadout = []
    for item in personal_inventory:
        loadout.append(item.item_data.id)
    saved_loadouts[name] = loadout

func load_loadout(name: String) -> bool:
    if not name in saved_loadouts:
        return false
    
    if not _player_at_barracks():
        return false
    
    # Store current items
    _transfer_all_to_barracks()
    
    # Load saved items
    for item_id in saved_loadouts[name]:
        retrieve_from_barracks(item_id, 1)
    
    return true
```

#### 4. Evidence Chain System
```gdscript
# For investigation gameplay
class EvidenceChain:
    var pieces: Array = []  # Evidence items collected
    var conclusions: Dictionary = {}  # Deductions made
    
    func add_evidence(item_id: String):
        if not item_id in pieces:
            pieces.append(item_id)
            _check_connections()
    
    func _check_connections():
        # Check if evidence pieces form conclusions
        if "photo_suspicious_meeting" in pieces and "shipping_manifest" in pieces:
            conclusions["smuggling_operation"] = true
            EventManager.trigger_event("discovered_smuggling")
```

### Full System Integration

#### Time Management Integration
```gdscript
# Travel time to barracks
func calculate_barracks_travel_time() -> float:
    var current_district = DistrictManager.get_current_district()
    var barracks_district = "military_district"
    
    if current_district == barracks_district:
        return 0.5  # 30 minutes within district
    else:
        # Use tram system travel time
        return TramSystem.get_travel_time(current_district, barracks_district)
```

#### Assimilation Integration
```gdscript
# Drones might steal items
func on_drone_crime(crime_data: Dictionary):
    if crime_data.crime_type == "theft" and crime_data.target == "player":
        var stolen_item = _get_random_valuable_item()
        if stolen_item:
            remove_item(stolen_item.item_data.id, 1)
            UI.show_notification("A drone stole your %s!" % stolen_item.item_data.name)
```

#### Suspicion Integration
```gdscript
# Carrying illegal items increases suspicion
func calculate_contraband_suspicion() -> float:
    var suspicion = 0.0
    
    for item in personal_inventory:
        if item.item_data.illegal:
            suspicion += 5.0  # Per illegal item
    
    return suspicion

# Security checks at checkpoints
func security_scan() -> Dictionary:
    var found_items = []
    
    for item in personal_inventory:
        if item.item_data.illegal or item.item_data.category == "weapon":
            found_items.append(item.item_data.id)
    
    return {
        "contraband_found": found_items.size() > 0,
        "items": found_items
    }
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/inventory_serializer.gd
extends BaseSerializer

class_name InventorySerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("inventory", self, 35)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    var data = {
        "personal": _serialize_personal_inventory(),
        "barracks": _serialize_barracks_storage(),
        "has_barracks": InventoryManager.has_barracks_access,
        "held_item": _serialize_held_item(),
        "loadouts": InventoryManager.saved_loadouts,
        "containers": _serialize_world_containers()
    }
    
    return data

func _serialize_personal_inventory() -> Array:
    var items = []
    
    for item in InventoryManager.personal_inventory:
        var item_data = {
            "id": item.item_data.id,
            "q": item.quantity
        }
        
        # Only save non-default values
        if item.condition < 1.0:
            item_data["c"] = item.condition
        
        if item.custom_data.size() > 0:
            item_data["d"] = item.custom_data
        
        items.append(item_data)
    
    return items

func _serialize_barracks_storage() -> Dictionary:
    # Barracks uses simple id: quantity format
    return InventoryManager.barracks_storage.duplicate()

func deserialize(data: Dictionary) -> void:
    # Clear current inventory
    InventoryManager.personal_inventory.clear()
    InventoryManager.barracks_storage.clear()
    
    # Restore personal inventory
    for item_data in data.get("personal", []):
        var item = ItemInstance.new()
        item.item_data = ItemRegistry.get_item(item_data.id)
        item.quantity = item_data.get("q", 1)
        item.condition = item_data.get("c", 1.0)
        item.custom_data = item_data.get("d", {})
        
        InventoryManager.personal_inventory.append(item)
    
    # Restore barracks
    InventoryManager.barracks_storage = data.get("barracks", {})
    InventoryManager.has_barracks_access = data.get("has_barracks", true)
    
    # Restore other data
    if data.has("held_item"):
        InventoryManager.held_item = ItemRegistry.get_item(data.held_item)
    
    InventoryManager.saved_loadouts = data.get("loadouts", {})
    
    # Restore container states
    _deserialize_world_containers(data.get("containers", {}))
```

## UI Components

### Inventory Grid
```gdscript
# src/ui/inventory/inventory_grid.gd
extends GridContainer

const SLOT_SCENE = preload("res://src/ui/inventory/inventory_slot.tscn")

export var slot_count: int = 10
var slots: Array = []

func _ready():
    columns = 5  # 5x2 grid
    _create_slots()
    
    InventoryManager.connect("item_added", self, "_on_item_changed")
    InventoryManager.connect("item_removed", self, "_on_item_changed")

func _create_slots():
    for i in range(slot_count):
        var slot = SLOT_SCENE.instance()
        slot.slot_index = i
        slot.connect("item_clicked", self, "_on_slot_clicked")
        slot.connect("item_dropped", self, "_on_item_dropped")
        add_child(slot)
        slots.append(slot)

func refresh_display():
    # Clear all slots
    for slot in slots:
        slot.clear()
    
    # Fill with current inventory
    var items = InventoryManager.personal_inventory
    for i in range(min(items.size(), slots.size())):
        slots[i].set_item(items[i])
```

### Barracks Storage UI
```gdscript
# src/ui/inventory/barracks_storage_ui.gd
extends Control

onready var storage_list = $StorageList
onready var transfer_button = $TransferButton
onready var retrieve_button = $RetrieveButton

func open_storage():
    if not InventoryManager.has_barracks_access:
        UI.show_notification("You no longer have barracks access!")
        return
    
    if not InventoryManager._player_at_barracks():
        UI.show_notification("You must be at your barracks!")
        return
    
    _refresh_storage_list()
    show()

func _refresh_storage_list():
    storage_list.clear()
    
    for item_id in InventoryManager.barracks_storage:
        var quantity = InventoryManager.barracks_storage[item_id]
        var item_data = ItemRegistry.get_item(item_id)
        
        var text = "%s x%d" % [item_data.name, quantity]
        storage_list.add_item(text)
        storage_list.set_item_metadata(storage_list.get_item_count() - 1, item_id)
```

## Puzzle Design Integration

### Example Puzzles

1. **Multi-Part Key**
   - Find three keycard fragments
   - Combine at security terminal
   - Creates master keycard

2. **Chemical Mixture**
   - Collect specific chemicals
   - Combine in correct order
   - Wrong order creates useless sludge

3. **Evidence Assembly**
   - Gather various clues
   - Combine photos with documents
   - Build case against assimilated leader

### Combination Hints
```gdscript
# Verb UI shows combination hints
func get_combination_hint(item1: ItemData, verb: String) -> String:
    if verb == "use":
        var possible_combinations = ItemCombiner.get_possible_combinations(item1.id)
        if possible_combinations.size() > 0:
            return "This might combine with something..."
    
    return ""
```

## Balance Considerations

### Inventory Pressure
- **10 slots** forces hard choices
- **Essential items** (food, water) take 2-3 slots minimum
- **Quest items** often need 3-4 slots
- **Tools/disguises** compete for remaining space

### Barracks Trade-offs
- **Time cost**: 30-60 minutes round trip
- **Money cost**: Tram fare if different district
- **Risk**: Could lose access through story events
- **Benefit**: Unlimited storage for collections

### Item Distribution
- **Common items**: Found in containers, shops
- **Rare items**: Quest rewards, hidden locations
- **Unique items**: One-of-a-kind, critical for puzzles
- **Consumables**: Regularly needed, create ongoing pressure

## Testing Considerations

1. **Inventory Management**
   - Test full inventory scenarios
   - Verify stack behavior
   - Test transfer operations

2. **Combination System**
   - Test all combinations work
   - Verify failed combinations
   - Test location-specific combinations

3. **Barracks Access**
   - Test losing/regaining access
   - Verify time calculations
   - Test items remain safe when access lost

4. **Integration Testing**
   - Disguise equipping
   - Quest item states
   - Economic transactions
   - Security scans

## Template Compliance

### Interactive Object Template Integration
All inventory items follow the structure defined in `template_interactive_object_design.md`:
- Items implement the standard `interact(verb, item)` interface
- Support verb-based interactions (USE, EXAMINE, COMBINE)
- Include state persistence for items with multiple states
- Integrate with the observation and examination systems

Items created by this system are interactive objects that can be:
- Examined for detailed descriptions
- Combined with other items or environment objects
- Used in specific contexts based on their properties
- Properly serialized/deserialized through the save system

This system creates meaningful inventory decisions while supporting classic adventure game puzzles and integrating with the game's time/economic pressure mechanics.