# SCUMM-style Hover Text System Design Document

## Overview

The SCUMM-style Hover Text System provides dynamic, context-sensitive text feedback as players hover over interactive elements in "A Silent Refraction". This system integrates with the verb UI, inventory, NPCs, and environment to create the classic adventure game feel while providing crucial information about object states, NPC conditions, and environmental changes.

## Core Design Principles

### Classic SCUMM Aesthetics
- Text appears at bottom of screen above verb UI
- Consistent formatting: "Verb Object" or contextual description
- Clean, readable font (monospace preferred)
- Instant response to mouse movement
- Color coding for different interaction states

### Context-Sensitive Information
- Basic object identification when no verb selected
- Verb + Object format when verb is active
- Dynamic descriptions based on game state
- Hidden information revealed through observation
- Integration with all game systems

## Display Format

### Standard Hover Text Layout
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    [Game View]                          │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ Look at suspicious maintenance worker                   │
├─────────────────────────────────────────────────────────┤
│ Walk | Look | Talk | Use | Take | Give | Push | Open   │
└─────────────────────────────────────────────────────────┘
```

### Text Formation Rules
```gdscript
func format_hover_text(verb: String, object: InteractiveObject) -> String:
    if verb.empty():
        # No verb selected - show object name
        return get_contextual_description(object)
    else:
        # Verb selected - show intended action
        var preposition = get_verb_preposition(verb)
        return "%s %s %s" % [verb, preposition, object.display_name]

func get_verb_preposition(verb: String) -> String:
    match verb:
        "Look": return "at"
        "Talk": return "to"
        "Use": return ""
        "Give": return "to"
        "Pick": return "up"
        _: return ""
```

## System Integration

### NPC State Display
```gdscript
func get_npc_hover_text(npc: BaseNPC) -> String:
    var base_name = npc.display_name
    
    # Add contextual information based on observation
    if ObservationMechanics.has_observed(npc.id):
        var observations = ObservationMechanics.get_observations(npc.id)
        
        # Assimilation status (if detected)
        if observations.has("assimilation_signs"):
            if AssimilationManager.is_assimilated(npc.id):
                base_name = "suspicious " + base_name
            else:
                base_name = "nervous " + base_name
        
        # Trust level indicator
        var trust = NPCTrustManager.get_trust_level(npc.id)
        if trust < 20:
            base_name = "wary " + base_name
        elif trust > 80:
            base_name = "friendly " + base_name
        
        # Current activity
        if observations.has("current_activity"):
            return base_name + " (" + observations.current_activity + ")"
    
    return base_name
```

### Object State Reflection
```gdscript
func get_object_hover_text(obj: InteractiveObject) -> String:
    var description = obj.display_name
    
    # State-based descriptions
    match obj.type:
        "door":
            if obj.is_locked:
                description = "locked " + description
            elif obj.is_open:
                description = "open " + description
                
        "container":
            if obj.is_empty:
                description = "empty " + description
            elif obj.requires_key:
                description = "locked " + description
                
        "terminal":
            if obj.is_active:
                description = "active " + description
            else:
                description = "powered-down " + description
                
        "evidence":
            if PuzzleManager.is_evidence_analyzed(obj.id):
                description += " (analyzed)"
    
    # Ownership information
    if obj.has_owner and NPCTrustManager.knows_owner(obj.id):
        description += " (belongs to " + obj.owner_name + ")"
    
    return description
```

### Inventory Integration
```gdscript
func get_inventory_hover_text(item: ItemData, target: Node = null) -> String:
    if not target:
        # Hovering over item in inventory
        return item.display_name + format_item_count(item)
    
    # Using item on something
    if target is BaseNPC:
        return format_item_npc_interaction(item, target)
    elif target is InteractiveObject:
        return format_item_object_interaction(item, target)
    else:
        return "Use " + item.display_name

func format_item_npc_interaction(item: ItemData, npc: BaseNPC) -> String:
    # Context-sensitive combinations
    if item.type == "evidence" and npc.is_suspect:
        return "Show " + item.display_name + " to " + npc.display_name
    elif item.type == "gift" and NPCTrustManager.would_appreciate(npc.id, item.id):
        return "Give " + item.display_name + " to grateful " + npc.display_name
    else:
        return "Give " + item.display_name + " to " + npc.display_name
```

### Environmental Context
```gdscript
func get_location_hover_text(position: Vector2) -> String:
    var location = get_location_at_position(position)
    
    if not location:
        return ""
    
    # Walkable area descriptions
    if location.type == "walkable":
        # Distance and time information
        var distance = calculate_distance(player.position, position)
        var walk_time = calculate_walk_time(distance)
        
        # Add fatigue warning if relevant
        if FatigueSystem.would_exhaust_at_distance(distance):
            return "exhausting distance away"
        elif walk_time > 60:
            return "far corner of the room"
        else:
            return ""
    
    # Exit descriptions
    elif location.type == "exit":
        var exit_name = location.leads_to
        
        # Add travel cost information
        if location.requires_tram:
            var cost = TramSystem.calculate_cost(current_district, location.district)
            return "to " + exit_name + " (Tram: " + str(cost) + "¢)"
        else:
            return "to " + exit_name
```

### Disguise System Integration
```gdscript
func get_disguise_aware_text(obj: Node) -> String:
    if not DisguiseManager.is_disguised():
        return get_standard_hover_text(obj)
    
    var current_role = DisguiseManager.get_current_role()
    
    # Role-specific descriptions
    if obj is InteractiveObject:
        if obj.restricted_to_role and obj.allowed_roles.has(current_role):
            return obj.role_specific_name[current_role]
        elif obj.forbidden_to_role == current_role:
            return "off-limits " + obj.display_name
    
    # NPC reactions to disguise
    elif obj is BaseNPC:
        if obj.is_coworker(current_role):
            return "fellow " + current_role + " " + obj.display_name
        elif obj.is_supervisor(current_role):
            return "supervisor " + obj.display_name
```

### Time-Sensitive Descriptions
```gdscript
func add_time_context(base_text: String, obj: Node) -> String:
    # Shop hours
    if obj.has_method("is_shop") and obj.is_shop():
        var hours = obj.get_business_hours()
        var current_hour = TimeManager.current_hour
        
        if current_hour >= hours.close - 1:
            base_text += " (closing soon)"
        elif current_hour < hours.open:
            base_text += " (opens at " + str(hours.open) + ":00)"
    
    # NPC availability
    elif obj is BaseNPC:
        var schedule = NPCScheduleManager.get_schedule(obj.id)
        if schedule.is_leaving_soon():
            base_text += " (about to leave)"
        elif schedule.is_sleeping():
            base_text += " (sleeping)"
    
    return base_text
```

### Detection State Warnings
```gdscript
func add_detection_warnings(base_text: String, action: String) -> String:
    var detection_risk = DetectionManager.calculate_action_risk(action)
    
    if detection_risk > 0.7:
        return base_text + " [HIGH RISK]"
    elif detection_risk > 0.4:
        return base_text + " [risky]"
    
    # Specific warnings
    if action == "Take" and is_theft(current_hover_object):
        return base_text + " [THEFT]"
    elif action == "Use" and is_restricted(current_hover_object):
        return base_text + " [RESTRICTED]"
    
    return base_text
```

## Visual Design

### Text Styling
```gdscript
class HoverTextStyle:
    const DEFAULT_FONT = preload("res://assets/fonts/hover_text_mono.tres")
    const FONT_SIZE = 14
    
    const COLORS = {
        "default": Color(0.9, 0.9, 0.9),
        "interactive": Color(1.0, 1.0, 0.8),
        "suspicious": Color(1.0, 0.7, 0.7),
        "friendly": Color(0.7, 1.0, 0.7),
        "locked": Color(0.8, 0.8, 0.8),
        "dangerous": Color(1.0, 0.5, 0.5),
        "assimilated": Color(0.9, 0.7, 1.0),
        "evidence": Color(0.7, 0.9, 1.0)
    }
    
    func apply_text_style(label: Label, context: String):
        label.add_font_override("font", DEFAULT_FONT)
        label.add_color_override("font_color", COLORS.get(context, COLORS.default))
        
        # Add outline for readability
        label.add_color_override("font_color_shadow", Color.black)
        label.add_constant_override("shadow_offset_x", 1)
        label.add_constant_override("shadow_offset_y", 1)
```

### Positioning
```gdscript
func position_hover_text():
    # Always at bottom, above verb UI
    hover_text_panel.anchor_left = 0.0
    hover_text_panel.anchor_right = 1.0
    hover_text_panel.anchor_bottom = 1.0
    
    # Account for verb UI height
    var verb_ui_height = VerbUI.get_height()
    hover_text_panel.margin_bottom = -(verb_ui_height + 5)
    hover_text_panel.margin_top = hover_text_panel.margin_bottom - 30
    
    # Center text
    hover_text_label.align = Label.ALIGN_CENTER
    hover_text_label.valign = Label.VALIGN_CENTER
```

## Advanced Features

### Progressive Information Revelation
```gdscript
class InformationRevealer:
    var revealed_info = {}  # object_id -> revealed_facts
    
    func get_progressive_description(obj: InteractiveObject) -> String:
        var base = obj.display_name
        var facts = revealed_info.get(obj.id, [])
        
        # Reveal information based on player actions
        if "examined" in facts:
            base = obj.examined_name
            
        if "used_correct_item" in facts:
            base += " (unlocked)"
            
        if "overheard_conversation" in facts:
            base += " (important)"
        
        # Puzzle integration
        if PuzzleManager.has_clue_about(obj.id):
            var clue = PuzzleManager.get_clue(obj.id)
            base += " (" + clue.hint + ")"
        
        return base
```

### Compound Object Descriptions
```gdscript
func get_compound_description(primary: Node, secondary: Node) -> String:
    # Item combination previews
    if primary is ItemData and secondary is ItemData:
        if PuzzleManager.can_combine(primary.id, secondary.id):
            return "Combine " + primary.display_name + " with " + secondary.display_name
        else:
            return primary.display_name + " doesn't work with " + secondary.display_name
    
    # Complex interactions
    elif primary is ItemData and secondary is InteractiveObject:
        return get_item_object_result_preview(primary, secondary)
```

### Dynamic Description Updates
```gdscript
var description_cache = {}
var update_timer = 0.0

func _process(delta):
    update_timer += delta
    
    # Update descriptions that might change
    if update_timer > 0.5:  # Every half second
        update_timer = 0.0
        
        if current_hover_object:
            var new_desc = generate_hover_text(current_hover_object)
            if new_desc != current_description:
                current_description = new_desc
                hover_text_label.text = new_desc
                
                # Animate text change
                animate_text_transition()
```

## Serialization Integration

```gdscript
# Saves discovered information for progressive revelation
class HoverTextSerializer extends BaseSerializer:
    func get_serializer_id() -> String:
        return "hover_text_system"
    
    func get_version() -> int:
        return 1
    
    func serialize() -> Dictionary:
        var hover_system = get_node("/root/Game/UI/HoverTextSystem")
        if not hover_system:
            return {}
        
        return {
            "revealed_info": hover_system.information_revealer.revealed_info,
            "examined_objects": hover_system.examined_objects,
            "discovered_names": hover_system.discovered_names,
            "custom_descriptions": hover_system.custom_descriptions
        }
    
    func deserialize(data: Dictionary) -> void:
        var hover_system = get_node("/root/Game/UI/HoverTextSystem")
        if not hover_system:
            return
        
        hover_system.information_revealer.revealed_info = data.get("revealed_info", {})
        hover_system.examined_objects = data.get("examined_objects", [])
        hover_system.discovered_names = data.get("discovered_names", {})
        hover_system.custom_descriptions = data.get("custom_descriptions", {})
    
    func _ready():
        # Low priority UI system
        SaveManager.register_serializer("hover_text_system", self, 85)
```

## Performance Optimization

### Caching Strategy
```gdscript
class HoverTextCache:
    var static_descriptions = {}  # Objects that don't change
    var dynamic_descriptions = {}  # Objects that need updates
    var last_update_frame = {}
    
    func get_description(obj: Node) -> String:
        var obj_id = obj.get_instance_id()
        
        # Static objects
        if obj.has_method("is_static") and obj.is_static():
            if obj_id in static_descriptions:
                return static_descriptions[obj_id]
            else:
                var desc = generate_description(obj)
                static_descriptions[obj_id] = desc
                return desc
        
        # Dynamic objects - cache for a few frames
        var current_frame = Engine.get_frames_drawn()
        if obj_id in dynamic_descriptions:
            if current_frame - last_update_frame.get(obj_id, 0) < 30:
                return dynamic_descriptions[obj_id]
        
        # Generate new description
        var desc = generate_description(obj)
        dynamic_descriptions[obj_id] = desc
        last_update_frame[obj_id] = current_frame
        return desc
```

### Efficient Mouse Detection
```gdscript
var last_mouse_position = Vector2()
var hover_check_distance = 5.0  # Pixels

func _input(event):
    if event is InputEventMouseMotion:
        # Only update if mouse moved significantly
        if event.position.distance_to(last_mouse_position) > hover_check_distance:
            last_mouse_position = event.position
            update_hover_object()
```

## Accessibility Features

### High Contrast Mode
```gdscript
func apply_high_contrast():
    # White text on black background
    hover_text_panel.modulate = Color.black
    hover_text_label.modulate = Color.white
    
    # Larger font
    var font = hover_text_label.get_font("font")
    font.size = Settings.accessibility_font_size
    
    # Stronger outline
    hover_text_label.add_constant_override("shadow_offset_x", 2)
    hover_text_label.add_constant_override("shadow_offset_y", 2)
```

### Screen Reader Support
```gdscript
signal hover_text_changed(text)

func update_hover_text(new_text: String):
    hover_text_label.text = new_text
    emit_signal("hover_text_changed", new_text)
    
    # Screen reader announcement
    if Settings.screen_reader_enabled:
        ScreenReader.announce(new_text)
```

## Debug Features

```gdscript
class HoverDebugMode:
    static func show_debug_info(obj: Node) -> String:
        if not OS.is_debug_build():
            return ""
        
        var debug_info = []
        
        # Object ID
        debug_info.append("ID: " + str(obj.get_instance_id()))
        
        # Interaction flags
        if obj.has_method("get_interaction_flags"):
            debug_info.append("Flags: " + str(obj.get_interaction_flags()))
        
        # State info
        if obj is BaseNPC:
            debug_info.append("State: " + obj.current_state)
            debug_info.append("Assim: " + str(AssimilationManager.is_assimilated(obj.id)))
        
        return " [" + ", ".join(debug_info) + "]"
```

## Integration Examples

### Quest-Aware Descriptions
```gdscript
func add_quest_context(base_text: String, obj: Node) -> String:
    var active_quests = QuestManager.get_quests_involving_object(obj)
    
    if active_quests.empty():
        return base_text
    
    # Prioritize most important quest
    var quest = active_quests[0]
    
    if quest.is_objective_target(obj):
        return base_text + " [Quest: " + quest.name + "]"
    elif quest.provides_hint_for(obj):
        return base_text + " (might be useful)"
    
    return base_text
```

### Coalition Network Awareness
```gdscript
func add_coalition_info(base_text: String, npc: BaseNPC) -> String:
    if not CoalitionManager.is_member(npc.id):
        # Show recruitment potential
        if CoalitionManager.can_recruit(npc.id):
            return "potential ally " + base_text
    else:
        # Show role in coalition
        var role = CoalitionManager.get_member_role(npc.id)
        return base_text + " (" + role + ")"
    
    return base_text
```

## Conclusion

The SCUMM-style Hover Text System serves as the primary method for players to understand and interact with the game world. By providing dynamic, context-sensitive descriptions that integrate with all game systems, it creates an information-rich environment that rewards observation and experimentation. The progressive revelation of information and state-aware descriptions support both the adventure game puzzle-solving and the deeper narrative of uncovering the assimilation threat.