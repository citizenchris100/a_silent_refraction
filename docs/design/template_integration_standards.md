# Template Integration Standards

## Overview

This document establishes mandatory standards for how all systems in "A Silent Refraction" must integrate with the five core template documents. These standards ensure consistent implementation patterns, promote code reuse, and maintain architectural integrity across the entire codebase.

## Core Templates

1. **template_npc_design.md** - Defines NPC structure, states, and behaviors
2. **template_interactive_object_design.md** - Defines interactive object interface and patterns
3. **template_quest_design.md** - Defines quest structure and progression systems
4. **template_district_design.md** - Defines district layout and integration requirements
5. **template_dialog_design.md** - Defines dialog generation and management patterns

## Mandatory Compliance Rules

### 1. NPC Creation Standards

Any system creating or managing NPCs MUST:

```gdscript
# REQUIRED: Extend from BaseNPC
extends "res://src/characters/npc/base_npc.gd"

# REQUIRED: Call parent ready
func _ready():
    ._ready()
    # Custom initialization here

# REQUIRED: Add to groups
func _ready():
    add_to_group("npc")
    add_to_group("interactive_object")
```

**Mandatory Implementation:**
- Use the standard state machine (IDLE, TALKING, SUSPICIOUS, HOSTILE, ASSIMILATED)
- Implement personality parameters that drive behavior
- Support the observation mechanics from the template
- Integrate with the dialog generation system
- Provide proper save/load serialization

**Prohibited Practices:**
- Creating custom NPC classes that don't extend BaseNPC
- Implementing separate dialog systems per NPC type
- Bypassing the standard state machine
- Hardcoding behaviors instead of using personality parameters

### 2. Interactive Object Standards

Any system creating interactive objects MUST:

```gdscript
# REQUIRED: Implement interact method
func interact(verb: String, item: Node = null) -> String:
    match verb:
        "EXAMINE":
            return examine()
        "USE":
            return use(item)
        _:
            return "I can't %s that." % verb.to_lower()

# REQUIRED: Join interactive_object group
func _ready():
    add_to_group("interactive_object")
```

**Mandatory Implementation:**
- Support all standard verbs (EXAMINE, USE, TAKE, TALK_TO, etc.)
- Implement state machines for multi-state objects
- Provide visual/audio feedback for state changes
- Return meaningful responses for unsupported actions
- Serialize all stateful data

**Prohibited Practices:**
- Creating objects that only respond to specific verbs
- Implementing interaction logic outside the interact() method
- Ignoring the item parameter for combinations
- Failing to join the interactive_object group

### 3. Quest Creation Standards

Any system creating quests MUST:

```gdscript
# REQUIRED: Use standard quest structure
var quest_data = {
    "id": "unique_quest_id",
    "name": "Quest Name",
    "description": "Quest description",
    "parts": [
        {
            "id": "part_1",
            "objectives": [
                {
                    "id": "obj_1",
                    "type": "collect|talk|discover|defeat",
                    "target": "target_id",
                    "required": 1,
                    "current": 0
                }
            ]
        }
    ],
    "prerequisites": [],
    "rewards": {}
}
```

**Mandatory Implementation:**
- Use the three-tier hierarchy (Quest → Parts → Objectives)
- Support linear, branching, and parallel progression
- Implement proper objective tracking
- Provide time limits where appropriate
- Integrate with the quest log UI

**Prohibited Practices:**
- Creating flat quest structures without parts
- Hardcoding quest progression logic
- Bypassing the objective system
- Creating quests without save/load support

### 4. District Creation Standards

Any system creating districts MUST:

```gdscript
# REQUIRED: Extend BaseDistrict
extends "res://src/core/districts/base_district.gd"

# REQUIRED: Implement required methods
func _create_background():
    # Set up background sprite
    pass

func _create_walkable_areas():
    # Define walkable polygons
    pass

func _create_interactive_objects():
    # Place interactive elements
    pass
```

**Mandatory Implementation:**
- Background as direct child named "Background"
- WalkableAreas container with proper polygons
- Set background_size for camera bounds
- Implement entry/exit handlers
- Support district-specific events

**Prohibited Practices:**
- Creating districts without walkable areas
- Implementing custom camera systems
- Bypassing the base district initialization
- Creating inaccessible areas without purpose

### 5. Dialog Integration Standards

Any system using dialog MUST:

```gdscript
# REQUIRED: Use DialogManager for all dialog
DialogManager.start_dialog(npc_id, dialog_tree)

# REQUIRED: Dialog trees follow template structure
var dialog_tree = {
    "nodes": {
        "start": {
            "text": generate_contextual_text(npc),
            "options": generate_options(npc, context)
        }
    }
}
```

**Mandatory Implementation:**
- Use personality-driven text generation
- Incorporate context (time, location, events)
- Support assimilation speech patterns
- Integrate with suspicion system
- Track dialog history

**Prohibited Practices:**
- Hardcoding dialog text
- Creating separate dialog UIs
- Ignoring personality parameters
- Bypassing the dialog history system

## Integration Requirements

### Cross-Template Integration

Systems often need to integrate multiple templates:

1. **NPCs in Districts**: NPCs must respect district boundaries and walkable areas
2. **Quest Objects**: Quest items must be proper interactive objects
3. **Dialog Triggers**: Dialog options can start quests or give items
4. **District Quests**: Quests can be location-specific

### System Responsibilities

Each system MUST document:
1. Which templates it uses
2. How it extends template functionality
3. Any additional requirements it adds
4. Integration points with other systems

### Validation Checklist

Before marking any system as complete, verify:

- [ ] All NPCs extend BaseNPC and follow state patterns
- [ ] All interactive elements use the interact() interface
- [ ] All quests follow the three-tier structure
- [ ] All districts properly define walkable areas
- [ ] All dialog uses the centralized dialog system
- [ ] Save/load works for all stateful elements
- [ ] Template compliance is documented in design docs

## Enforcement

### Code Review Requirements

All PRs must:
1. Demonstrate template compliance
2. Include template reference in documentation
3. Pass template validation tests
4. Not introduce template violations

### Testing Standards

Create tests that verify:
1. Template interfaces are properly implemented
2. Required methods exist and function correctly
3. State serialization works as expected
4. Integration points function properly

## Migration Guide

For existing systems not yet compliant:

1. **Identify Violations**: Audit current implementation
2. **Plan Migration**: Create incremental migration plan
3. **Implement Changes**: Follow templates strictly
4. **Test Thoroughly**: Verify nothing breaks
5. **Document Updates**: Update design docs

## Conclusion

These standards ensure that "A Silent Refraction" maintains consistent patterns across all systems. By following these templates, developers can:
- Implement features faster using established patterns
- Avoid bugs from inconsistent implementations
- Ensure all systems integrate smoothly
- Maintain code quality as the project grows

**Remember**: Templates exist to make development easier and more consistent. When in doubt, follow the template exactly. Only deviate with explicit approval and documentation.