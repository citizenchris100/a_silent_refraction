# District Access Control System Design

## Overview

The District Access Control System manages keys, keycards, badges, and other access mechanisms throughout the station. While conceptually simple - "you need the thing to get into the place" - the system creates cascading gameplay implications: lost keys trap players, stolen badges raise alarms, and assimilated security personnel can revoke access. The system integrates with puzzles, disguises, and the economic pressure of potentially being locked out of crucial areas.

## Core Concepts

### Access Philosophy
- **Physical possession required**: No abstract "permissions" - must have item
- **Items can be lost/stolen**: Creating vulnerability and tension
- **Multiple access methods**: Keys, cards, codes, biometrics, social engineering
- **Degrading security**: Assimilation corrupts access controls
- **Economic implications**: Replacing lost access costs money/time

### Access Types
1. **Physical Keys** - Traditional locks, can be copied
2. **Keycards** - Electronic, can be deactivated remotely
3. **Biometric** - Fingerprint/retinal, requires disguise or cooperation
4. **Access Codes** - Memorizable but changeable
5. **Badges** - Visual identification, social access
6. **Special Tools** - Maintenance access, lockpicks

## System Architecture

### Core Components

#### 1. Access Control Manager (Singleton)
```gdscript
# src/core/systems/access_control_manager.gd
extends Node

signal access_granted(door_id, method)
signal access_denied(door_id, reason)
signal alarm_triggered(location, severity)
signal access_revoked(item_id, reason)

# Access registry
var access_points: Dictionary = {}  # door_id: AccessPointData
var player_access_items: Array = []  # Currently held access items
var revoked_access: Array = []  # Invalidated items
var copied_keys: Dictionary = {}  # original_id: [copy_ids]

func attempt_access(door_id: String, method: String = "auto") -> bool:
    var access_point = access_points.get(door_id)
    if not access_point:
        push_error("Unknown access point: " + door_id)
        return false
    
    # Check if already open
    if access_point.is_open:
        return true
    
    # Try automatic detection
    if method == "auto":
        method = _detect_best_access_method(access_point)
    
    # Validate access attempt
    var result = _validate_access(access_point, method)
    
    if result.success:
        _grant_access(door_id, method)
        return true
    else:
        _deny_access(door_id, result.reason)
        return false

func _detect_best_access_method(access_point: AccessPointData) -> String:
    # Check inventory for matching items
    for item in InventoryManager.get_items_by_category("access"):
        if _item_grants_access(item, access_point):
            return "item:" + item.id
    
    # Check for known codes
    if access_point.type == "keypad":
        var known_code = _check_known_codes(access_point.id)
        if known_code:
            return "code:" + known_code
    
    # Check disguise-based access
    if access_point.allows_role_access:
        var current_role = DisguiseManager.current_disguise
        if current_role in access_point.authorized_roles:
            return "role:" + current_role
    
    # Check for coalition assistance
    if CoalitionManager.has_member_with_access(access_point.id):
        return "coalition"
    
    return "none"

func _validate_access(access_point: AccessPointData, method: String) -> Dictionary:
    var method_parts = method.split(":")
    var method_type = method_parts[0]
    var method_value = method_parts[1] if method_parts.size() > 1 else ""
    
    match method_type:
        "item":
            return _validate_item_access(access_point, method_value)
        "code":
            return _validate_code_access(access_point, method_value)
        "role":
            return _validate_role_access(access_point, method_value)
        "biometric":
            return _validate_biometric_access(access_point)
        "force":
            return _validate_forced_access(access_point)
        "coalition":
            return _validate_coalition_access(access_point)
        _:
            return {"success": false, "reason": "invalid_method"}

func _validate_item_access(access_point: AccessPointData, item_id: String) -> Dictionary:
    # Check if item is revoked
    if item_id in revoked_access:
        return {"success": false, "reason": "access_revoked", "alert": true}
    
    # Check if item matches lock
    if access_point.type == "keycard_reader":
        var required_level = access_point.security_level
        var card_data = ItemRegistry.get_item(item_id)
        
        if card_data.security_clearance < required_level:
            return {"success": false, "reason": "insufficient_clearance"}
        
        # Check if card is still valid
        if _is_card_deactivated(item_id):
            return {"success": false, "reason": "card_deactivated", "alert": true}
    
    elif access_point.type == "physical_lock":
        if not item_id in access_point.accepted_keys:
            # Check if it's a copied key
            for original in copied_keys:
                if item_id in copied_keys[original]:
                    if original in access_point.accepted_keys:
                        return {"success": true, "method": "copied_key"}
            
            return {"success": false, "reason": "wrong_key"}
    
    return {"success": true}

func revoke_access(item_id: String, reason: String = "security_breach"):
    if not item_id in revoked_access:
        revoked_access.append(item_id)
        emit_signal("access_revoked", item_id, reason)
        
        # Alert player if they have this item
        if InventoryManager.has_item(item_id):
            UI.show_urgent_message("Your %s has been deactivated!" % ItemRegistry.get_item(item_id).name)
        
        # Log security event
        SecuritySystem.log_access_revocation(item_id, reason)

func copy_key(original_key_id: String) -> String:
    var original = ItemRegistry.get_item(original_key_id)
    if not original or original.category != "key":
        return ""
    
    # Generate copy ID
    var copy_id = original_key_id + "_copy_" + str(OS.get_unix_time())
    
    # Track copies (can be detected)
    if not original_key_id in copied_keys:
        copied_keys[original_key_id] = []
    copied_keys[original_key_id].append(copy_id)
    
    # Create copy item
    var copy_data = original.duplicate()
    copy_data.id = copy_id
    copy_data.name = original.name + " (Copy)"
    copy_data.is_contraband = true  # Illegal to have unauthorized copies
    
    ItemRegistry.register_item(copy_data)
    
    return copy_id
```

#### 2. Access Point System
```gdscript
# src/core/access/access_point.gd
extends Area2D

class_name AccessPoint

export var access_point_id: String = ""
export var access_type: String = "keycard_reader"  # physical_lock, keypad, biometric, badge_scanner
export var security_level: int = 1  # 1-5 security clearance
export var is_locked: bool = true
export var alarm_on_fail: bool = false
export var allow_forced_entry: bool = false

# Visual states
export var locked_texture: Texture
export var unlocked_texture: Texture
export var alarm_texture: Texture

# Access configuration
export var accepted_items: Array = []  # Item IDs that grant access
export var authorized_roles: Array = []  # Disguise roles with access
export var access_code: String = ""  # For keypad types
export var biometric_ids: Array = []  # NPCs whose biometrics work

# State
var is_alarmed: bool = false
var failed_attempts: int = 0
var last_attempt_time: float = 0.0

func _ready():
    AccessControlManager.register_access_point(access_point_id, self)
    _update_visual_state()

func interact(verb: String, item: ItemData = null):
    match verb:
        "use":
            if item and item.category == "access":
                attempt_access("item:" + item.id)
            else:
                show_access_interface()
        "examine":
            examine_lock()
        "force":
            attempt_forced_entry()

func attempt_access(method: String):
    var success = AccessControlManager.attempt_access(access_point_id, method)
    
    if success:
        unlock()
    else:
        failed_attempts += 1
        last_attempt_time = TimeManager.current_time
        
        # Check for alarm
        if alarm_on_fail and failed_attempts >= 3:
            trigger_alarm()

func unlock():
    is_locked = false
    _update_visual_state()
    
    # Open associated door/container
    if has_node("Door"):
        $Door.open()
    
    # Log access
    SecuritySystem.log_access(access_point_id, "granted")

func trigger_alarm():
    is_alarmed = true
    _update_visual_state()
    
    AccessControlManager.emit_signal("alarm_triggered", global_position, security_level)
    
    # Alert nearby security
    SecuritySystem.dispatch_security_to(global_position, "unauthorized_access")
    
    # Increase suspicion
    SuspicionManager.increase_global_suspicion(20 * security_level, "triggered_alarm")
```

#### 3. Access Item Types
```gdscript
# src/resources/access_items.gd
extends Resource

# Physical Key
class PhysicalKey extends ItemData:
    export var key_id: String = ""
    export var key_profile: String = ""  # Shape of key
    export var can_be_copied: bool = true
    export var material: String = "metal"  # Affects copying method
    
    func _init():
        category = "key"
        stackable = false

# Electronic Keycard
class Keycard extends ItemData:
    export var card_id: String = ""
    export var security_clearance: int = 1  # 1-5
    export var access_zones: Array = []  # Specific areas
    export var expiration_date: int = -1  # -1 = no expiration
    export var owner_id: String = ""  # NPC who owns it
    export var can_be_cloned: bool = true
    
    func _init():
        category = "keycard"
        stackable = false
        
    func is_valid() -> bool:
        if expiration_date == -1:
            return true
        return TimeManager.current_day <= expiration_date

# Access Badge
class AccessBadge extends ItemData:
    export var badge_id: String = ""
    export var owner_name: String = ""
    export var owner_photo: Texture
    export var department: String = ""
    export var clearance_level: int = 1
    export var visible_when_worn: bool = true
    
    func _init():
        category = "badge"
        is_disguise = false  # But affects NPC perception
        
    func matches_wearer(character_appearance: Dictionary) -> bool:
        # Basic appearance check
        # More detailed in full implementation
        return true
```

### Integration Systems

#### Puzzle Integration
```gdscript
# Access control creates puzzle opportunities
func create_access_puzzle(locked_area: String) -> PuzzleData:
    var access_point = AccessControlManager.get_access_point(locked_area)
    
    return {
        "id": "access_" + locked_area,
        "name": "Gain access to " + locked_area,
        "solutions": [
            {
                "method": "find_key",
                "hint": "Someone must have the key...",
                "item_location": _determine_key_holder(locked_area)
            },
            {
                "method": "steal_keycard",
                "hint": "That guard's keycard would work...",
                "target_npc": _find_authorized_npc(locked_area)
            },
            {
                "method": "learn_code",
                "hint": "The code might be written down somewhere...",
                "clue_locations": ["office_notepad", "bathroom_graffiti"]
            },
            {
                "method": "coalition_help",
                "requirement": "coalition_member_with_access"
            },
            {
                "method": "force_entry",
                "requirement": "crowbar",
                "consequence": "alarm"
            }
        ]
    }
```

#### Disguise Integration
```gdscript
# Some access is role-based
func check_badge_requirement(access_point: AccessPoint) -> bool:
    if not access_point.requires_badge:
        return true
    
    var current_badge = InventoryManager.get_equipped_badge()
    if not current_badge:
        UI.show_notification("You need an ID badge")
        return false
    
    # Badge must match disguise
    if DisguiseManager.current_disguise != "civilian":
        var expected_dept = RoleRegistry.get_role_department(DisguiseManager.current_disguise)
        if current_badge.department != expected_dept:
            # Suspicious!
            _trigger_badge_mismatch_detection()
            return false
    
    return current_badge.clearance_level >= access_point.security_level
```

#### Economy Integration
```gdscript
# Lost access costs money to replace
func request_replacement_keycard(original_id: String) -> bool:
    var replacement_fee = 50  # Base fee
    var original = ItemRegistry.get_item(original_id)
    
    if original.security_clearance > 3:
        replacement_fee = 200  # High security costs more
    
    if not EconomyManager.can_afford(replacement_fee):
        UI.show_notification("Replacement fee: %d credits" % replacement_fee)
        return false
    
    # Need to file paperwork (time cost)
    var time_cost = 2.0  # 2 hours
    TimeManager.advance_time(time_cost)
    
    # Pay fee
    EconomyManager.spend_credits(replacement_fee, "keycard_replacement")
    
    # Get replacement (might be tracked)
    var replacement = _generate_replacement_card(original_id)
    InventoryManager.add_item(replacement)
    
    # Security logs this
    SecuritySystem.log_replacement_request(original_id, replacement)
    
    return true

# Black market alternative
func purchase_cloned_keycard(target_clearance: int) -> bool:
    var black_market_price = 100 * target_clearance
    
    if not EconomyManager.can_afford(black_market_price):
        return false
    
    if DisguiseManager.current_disguise == "security":
        UI.show_notification("The dealer eyes your uniform suspiciously...")
        return false
    
    EconomyManager.spend_credits(black_market_price, "black_market_keycard")
    
    var cloned_card = _generate_cloned_card(target_clearance)
    cloned_card.is_contraband = true
    
    InventoryManager.add_item(cloned_card)
    
    # Risk of getting scammed
    if randf() < 0.2:  # 20% chance
        cloned_card.functional = false  # Doesn't actually work!
    
    return true
```

#### Assimilation Integration
```gdscript
# Assimilated abuse access control
func on_npc_assimilated(npc_id: String):
    var npc = NPCRegistry.get_npc(npc_id)
    
    # Security personnel can revoke access
    if npc.role in ["security_chief", "it_admin"]:
        # Mass revocation event possible
        if randf() < 0.3:  # 30% chance
            _trigger_security_lockdown(npc.department)
    
    # Assimilated change codes
    if npc.has_knowledge_of_codes:
        for code_id in npc.known_codes:
            _change_access_code(code_id, "compromised")
    
    # Create trap access points
    if npc.role == "maintenance_chief":
        _create_maintenance_trap_doors()

# Access degradation over time
func process_daily_corruption():
    var corruption = AssimilationManager.get_station_corruption_level()
    
    # Random keycard failures
    if randf() < corruption * 0.1:
        var random_card = _get_random_player_keycard()
        if random_card:
            UI.show_message("Your %s flickers and stops working..." % random_card.name)
            random_card.functional = false
    
    # Doors malfunction
    for access_point in access_points.values():
        if randf() < corruption * 0.05:
            access_point.malfunction()
```

## MVP Implementation

### Basic Features

1. **Simple Keys & Keycards**
   - Physical keys for basic doors
   - Keycards with 3 security levels
   - Fixed locations for each key

2. **Basic Access Points**
   - Locked doors
   - Keycard readers
   - Simple keypads

3. **Loss & Replacement**
   - Can lose/drop keys
   - Pay credits to replace
   - Time delay for new cards

### MVP Examples

```gdscript
# Security Level 1 - Public areas
{
    "id": "cafeteria_door",
    "type": "keycard_reader",
    "security_level": 1,
    "accepted_items": ["keycard_level1", "keycard_level2", "keycard_level3"],
    "alarm_on_fail": false
}

# Security Level 3 - Restricted
{
    "id": "security_office",
    "type": "keycard_reader",
    "security_level": 3,
    "accepted_items": ["keycard_level3", "security_master_key"],
    "alarm_on_fail": true,
    "authorized_roles": ["security"]
}

# Physical Lock
{
    "id": "maintenance_closet",
    "type": "physical_lock",
    "accepted_items": ["maintenance_key", "master_key"],
    "allow_forced_entry": true
}

# Keypad
{
    "id": "storage_room",
    "type": "keypad",
    "access_code": "1234",
    "alarm_on_fail": true,
    "failed_attempt_limit": 3
}
```

## Full Implementation

### Advanced Features

#### 1. Biometric Security
```gdscript
class BiometricScanner:
    var scan_type: String = "fingerprint"  # fingerprint, retinal, voice
    var authorized_biometrics: Array = []
    var spoof_difficulty: int = 8  # 1-10
    
    func attempt_biometric_scan(character: Node) -> bool:
        # Check if using someone else's biometrics
        if DisguiseManager.has_biometric_spoof():
            var spoof_quality = DisguiseManager.get_spoof_quality()
            if spoof_quality >= spoof_difficulty:
                return true
            else:
                trigger_spoof_detection()
                return false
        
        # Check actual biometrics
        var bio_id = character.get_biometric_id()
        return bio_id in authorized_biometrics
    
    func obtain_biometric_sample(npc_id: String, method: String):
        match method:
            "unconscious":
                # Scan unconscious NPC
                return _scan_unconscious_npc(npc_id)
            "severed":
                # More gruesome option...
                return _obtain_severed_sample(npc_id)
            "lifted":
                # Lifted prints from glass, etc.
                return _lift_fingerprints(npc_id)
```

#### 2. Dynamic Security Response
```gdscript
class SecurityEscalation:
    var threat_levels = {
        "green": {"response_time": 300, "guards": 0},
        "yellow": {"response_time": 180, "guards": 1},
        "orange": {"response_time": 60, "guards": 2},
        "red": {"response_time": 30, "guards": 4},
        "lockdown": {"response_time": 0, "guards": "all"}
    }
    
    func escalate_security(location: String, reason: String):
        var current_level = get_location_threat_level(location)
        var new_level = _calculate_new_threat_level(current_level, reason)
        
        # Change physical security
        for access_point in get_location_access_points(location):
            access_point.security_level += 1
            access_point.alarm_on_fail = true
        
        # Revoke temporary passes
        for pass in get_temporary_passes(location):
            AccessControlManager.revoke_access(pass, "security_escalation")
        
        # Deploy guards
        SecuritySystem.deploy_guards(location, threat_levels[new_level].guards)
```

#### 3. Access Trading & Sharing
```gdscript
# NPCs might share access
func request_access_from_npc(npc_id: String, access_point_id: String):
    var npc = NPCRegistry.get_npc(npc_id)
    var trust = TrustSystem.get_trust(npc_id)
    
    # Need high trust
    if trust < 70:
        return {"success": false, "response": "I can't help you with that."}
    
    # Check if they have access
    if not npc.has_access_to(access_point_id):
        return {"success": false, "response": "I don't have access either."}
    
    # Might share code
    if randf() < 0.6:
        var code = npc.get_access_code(access_point_id)
        return {"success": true, "response": "The code is " + code, "type": "code"}
    
    # Might lend keycard
    else:
        var keycard = npc.lend_keycard()
        return {"success": true, "response": "Here, but bring it back!", "type": "item", "item": keycard}
```

#### 4. Maintenance Access Routes
```gdscript
# Alternative access through maintenance
class MaintenanceAccess:
    func find_maintenance_route(target_room: String) -> Dictionary:
        if not DisguiseManager.current_disguise in ["maintenance", "engineering"]:
            return {"found": false, "reason": "need_maintenance_knowledge"}
        
        var route = {
            "found": true,
            "path": ["maintenance_shaft_3", "ventilation_junction", "target_room_vent"],
            "requirements": ["screwdriver", "flashlight", "small_size"],
            "risks": ["getting_lost", "steam_burns", "detection_from_below"]
        }
        
        return route
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/access_serializer.gd
extends BaseSerializer

class_name AccessSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("access", self, 60)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "player_access_items": _serialize_access_items(),
        "revoked_access": AccessControlManager.revoked_access,
        "copied_keys": AccessControlManager.copied_keys,
        "changed_codes": _serialize_changed_codes(),
        "access_point_states": _serialize_access_states(),
        "security_escalations": SecurityEscalation.active_escalations,
        "borrowed_items": _serialize_borrowed_access()
    }

func _serialize_access_items() -> Array:
    var items = []
    for item in InventoryManager.get_items_by_category("access"):
        items.append({
            "id": item.id,
            "valid": item.get("functional", true),
            "expiry": item.get("expiration_date", -1),
            "borrowed_from": item.get("borrowed_from", "")
        })
    return items

func _serialize_access_states() -> Dictionary:
    var states = {}
    for ap_id in AccessControlManager.access_points:
        var ap = AccessControlManager.access_points[ap_id]
        states[ap_id] = {
            "locked": ap.is_locked,
            "alarm": ap.is_alarmed,
            "attempts": ap.failed_attempts,
            "code": ap.access_code if ap.type == "keypad" else ""
        }
    return states

func deserialize(data: Dictionary) -> void:
    # Restore access items
    _deserialize_access_items(data.get("player_access_items", []))
    
    AccessControlManager.revoked_access = data.get("revoked_access", [])
    AccessControlManager.copied_keys = data.get("copied_keys", {})
    
    _deserialize_changed_codes(data.get("changed_codes", {}))
    _deserialize_access_states(data.get("access_point_states", {}))
    
    SecurityEscalation.active_escalations = data.get("security_escalations", {})
    _deserialize_borrowed_access(data.get("borrowed_items", []))
```

## UI Components

### Access Interface
```gdscript
# src/ui/access/access_interface.gd
extends Control

onready var access_type_label = $AccessType
onready var keypad_ui = $KeypadInterface
onready var card_reader_ui = $CardReaderInterface
onready var biometric_ui = $BiometricInterface

func show_for_access_point(access_point: AccessPoint):
    access_type_label.text = access_point.access_type.capitalize()
    
    # Hide all interfaces
    for child in get_children():
        if child.has_method("hide"):
            child.hide()
    
    # Show appropriate interface
    match access_point.access_type:
        "keypad":
            keypad_ui.show()
            keypad_ui.setup(access_point.digit_count)
        "keycard_reader":
            card_reader_ui.show()
            card_reader_ui.show_card_slots()
        "biometric":
            biometric_ui.show()
            biometric_ui.setup(access_point.scan_type)
    
    popup_centered()
```

### Lost Access UI
```gdscript
# src/ui/access/lost_access_ui.gd
extends Control

onready var lost_item_label = $LostItemLabel
onready var replacement_cost = $ReplacementCost
onready var time_required = $TimeRequired
onready var request_button = $RequestButton

func show_replacement_options(lost_item: ItemData):
    lost_item_label.text = "Lost: " + lost_item.name
    
    var cost = _calculate_replacement_cost(lost_item)
    var time = _calculate_replacement_time(lost_item)
    
    replacement_cost.text = "Cost: %d credits" % cost
    time_required.text = "Time: %s" % _format_time(time)
    
    request_button.disabled = not EconomyManager.can_afford(cost)
    
    show()
```

## Balance Considerations

### Access Hierarchy
- **Level 1**: Public areas, 10 credits to replace
- **Level 2**: Staff areas, 25 credits to replace  
- **Level 3**: Restricted areas, 50 credits to replace
- **Level 4**: Secure areas, 100 credits to replace
- **Level 5**: Critical areas, 200 credits to replace

### Time Costs
- **Replacement processing**: 1-3 hours depending on level
- **Lock picking**: 15-30 minutes per attempt
- **Finding alternate routes**: 30-60 minutes
- **Borrowing from NPCs**: Relationship building time

### Security Responses
- **1 failed attempt**: Logged
- **3 failed attempts**: Local alarm
- **5 failed attempts**: Security dispatched
- **Forced entry**: Immediate response

## Testing Considerations

1. **Access Validation**
   - All legitimate keys work
   - Revoked access properly denied
   - Copied keys function correctly
   - Role-based access works

2. **Loss Scenarios**
   - Can drop/lose keys
   - Replacement system works
   - Can't get permanently locked out
   - Alternative routes available

3. **Integration Testing**
   - Disguises grant appropriate access
   - Economy affects replacement
   - Assimilation corrupts security
   - Puzzles have multiple solutions

4. **Edge Cases**
   - Multiple simultaneous access attempts
   - Access during alerts
   - Borrowed items returned
   - Save/load with revoked access

## Template Compliance

### NPC Template Integration
Security personnel follow `template_npc_design.md`:
- Gate guards use full NPC state machine with security-specific states
- Personality affects enforcement strictness
- Memory system tracks who they've allowed through
- Dialog generation includes access-related topics
- Assimilation affects security behavior

### District Template Integration
Access points follow `template_district_design.md`:
- Each district defines its own access requirements
- Entry/exit points integrated with walkable areas
- Security checkpoints are interactive areas
- Access state persists with district data
- Emergency overrides tied to district alert levels

This system creates meaningful consequences for access management while ensuring players always have some path forward, even if it's expensive or dangerous.