# Click Priority System Documentation

## Overview

The Click Priority System resolves conflicts when multiple clickable elements overlap at the same screen position. It ensures that the most important or contextually relevant element receives the click, following a clear hierarchy. This system is essential for maintaining predictable and intuitive gameplay in A Silent Refraction.

## Priority Hierarchy

The system uses a numeric priority scale where higher numbers take precedence:

```gdscript
enum Priority {
    MOVEMENT = 0,           # Background movement (lowest)
    BACKGROUND_OBJECT = 10, # Decorative interactive elements
    INTERACTIVE_OBJECT = 20,# NPCs, items, interactive props
    UI_ELEMENT = 30,        # UI overlays and menus
    DIALOG = 40            # Dialog boxes (highest)
}
```

### Priority Rules

1. **Dialog blocks everything** - When dialog is active, no other clicks register
2. **UI always wins** - UI elements take precedence over game world
3. **Objects over movement** - Clicking an NPC/object overrides movement
4. **Movement is default** - If nothing else is clicked, move the player

## Architecture

### Core Components

```gdscript
extends Node
class_name ClickPrioritySystem

signal click_processed(click_data)
signal click_rejected(reason)
```

### Click Data Structure

```gdscript
# Click data passed through the system
var click_data = {
    "screen_position": Vector2,
    "world_position": Vector2,
    "player": Node,
    "district": Node,
    "handled": bool,
    "action": String,  # "movement", "object_interaction", "ui_interaction"
    "target_type": int,
    "object": Node     # The clicked object (if any)
}
```

## Processing Flow

### 1. Click Target Discovery

```gdscript
func _find_click_targets(world_position: Vector2, screen_position: Vector2) -> Array:
    var targets = []
    
    # Check UI first (highest priority)
    if _is_position_on_ui(screen_position):
        targets.append({
            "type": TargetType.UI,
            "priority": Priority.UI_ELEMENT,
            "position": screen_position
        })
        return targets  # UI blocks everything
    
    # Check interactive objects
    var interactive_objects = get_tree().get_nodes_in_group("interactive_object")
    for obj in interactive_objects:
        if _is_position_on_object(world_position, obj):
            targets.append({
                "type": TargetType.OBJECT,
                "priority": Priority.INTERACTIVE_OBJECT,
                "object": obj,
                "position": world_position
            })
    
    # Movement is always an option
    if district.is_position_walkable(world_position):
        targets.append({
            "type": TargetType.MOVEMENT,
            "priority": Priority.MOVEMENT,
            "position": world_position
        })
    
    return targets
```

### 2. Priority Resolution

```gdscript
# Sort targets by priority (highest first)
targets.sort_custom(self, "_sort_by_priority")

# Process the highest priority target
if targets.size() > 0:
    var target = targets[0]
    _process_target(target, click_data)
```

### 3. Action Processing

The system determines the appropriate action based on target type:

```gdscript
match target.type:
    TargetType.UI:
        # UI click - typically blocks game action
        emit_signal("click_rejected", "UI element clicked")
        
    TargetType.OBJECT:
        # Interactive object click
        result["action"] = "object_interaction"
        result["object"] = target.object
        emit_signal("click_processed", result)
        
    TargetType.MOVEMENT:
        # Movement click
        result["action"] = "movement"
        result["position"] = target.position
        emit_signal("click_processed", result)
```

## Integration with InputManager

The ClickPrioritySystem is created and managed by InputManager:

```gdscript
# In InputManager
if click_priority_system:
    click_priority_system.process_click({
        "screen_position": screen_position,
        "world_position": world_position,
        "player": player,
        "district": current_district
    })
```

## Object Detection Methods

### Sprite-based Detection

```gdscript
# Check if click hits sprite bounds
var sprite = object.get_node_or_null("Sprite")
if sprite:
    var rect = Rect2(
        object.global_position + sprite.offset - sprite.texture.get_size() / 2,
        sprite.texture.get_size()
    )
    return rect.has_point(world_position)
```

### Collision-based Detection

```gdscript
# Check Area2D collision shapes
var area = object.get_node_or_null("Area2D")
if area:
    for child in area.get_children():
        if child is CollisionShape2D:
            # Check collision shape
            if shape is CircleShape2D:
                var distance = world_position.distance_to(object.global_position)
                return distance <= shape.radius
```

### Proximity Detection

```gdscript
# Fallback to simple distance check
return world_position.distance_to(object.global_position) < 32
```

## Custom Priority Levels

To add custom priority levels:

```gdscript
# Extend the Priority enum in your game
enum CustomPriority {
    MOVEMENT = 0,
    FLOOR_ITEM = 5,          # Items on ground
    BACKGROUND_OBJECT = 10,
    INTERACTIVE_OBJECT = 20,
    IMPORTANT_NPC = 25,      # Story-critical NPCs
    UI_ELEMENT = 30,
    DIALOG = 40,
    CUTSCENE = 50           # Highest - blocks everything
}
```

## Handling Special Cases

### Overlapping NPCs

When multiple NPCs overlap, additional factors can determine priority:

```gdscript
# Custom NPC priority based on importance
func _get_npc_priority(npc):
    if npc.is_quest_giver:
        return Priority.INTERACTIVE_OBJECT + 5
    elif npc.is_talking:
        return Priority.INTERACTIVE_OBJECT + 3
    else:
        return Priority.INTERACTIVE_OBJECT
```

### Contextual Priority

Priority can change based on game state:

```gdscript
# Adjust priority based on context
func _get_contextual_priority(object, base_priority):
    # During stealth, hidden objects have higher priority
    if game_state.is_stealth_mode and object.is_hidden:
        return base_priority + 10
    return base_priority
```

## Signals and Events

### click_processed

Emitted when a click is successfully processed:

```gdscript
# Connect to processed clicks
priority_system.connect("click_processed", self, "_on_click_processed")

func _on_click_processed(click_data):
    match click_data.action:
        "movement":
            player.move_to(click_data.position)
        "object_interaction":
            handle_object_interaction(click_data.object)
```

### click_rejected

Emitted when a click is rejected:

```gdscript
# Connect to rejected clicks
priority_system.connect("click_rejected", self, "_on_click_rejected")

func _on_click_rejected(reason):
    print("Click rejected: ", reason)
    # Could show feedback to player
```

## Best Practices

1. **Consistent Priorities** - Keep priority levels consistent across the game
2. **Clear Boundaries** - Ensure clickable areas don't overlap unnecessarily
3. **Visual Indicators** - Show hover states for clickable objects
4. **Test Overlaps** - Test areas where multiple objects might overlap
5. **Document Custom Priorities** - If extending the system, document new levels

## Debugging

### Debug Visualization

```gdscript
# Show all potential click targets
func debug_show_targets(world_position):
    var targets = _find_click_targets(world_position, screen_position)
    for target in targets:
        print("Target: ", target.type, " Priority: ", target.priority)
```

### Common Issues

**Wrong object selected**
- Check priority values
- Verify collision/sprite bounds
- Test with debug visualization

**Clicks not registering**
- Ensure object is in correct group
- Check if UI is blocking
- Verify position detection logic

**Movement when expecting object click**
- Object might not be in "interactive_object" group
- Collision detection might be failing
- Priority might be set too low

## Performance Optimization

### Group Filtering
```gdscript
# Use groups to reduce checks
var interactive_objects = get_tree().get_nodes_in_group("interactive_object")
# Instead of checking all nodes in scene
```

### Early Exit
```gdscript
# UI blocks everything, so return early
if _is_position_on_ui(screen_position):
    return [ui_target]  # Don't check anything else
```

### Spatial Partitioning
For scenes with many objects, consider spatial partitioning:
```gdscript
# Only check objects near click position
var nearby_objects = spatial_hash.get_objects_near(world_position, 100)
```

## Future Enhancements

- Priority preview mode (show what would be clicked)
- Dynamic priority based on player state
- Priority profiles for different game modes
- Performance profiling for complex scenes
- Visual priority debugging overlay