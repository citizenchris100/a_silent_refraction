# Character Gender Selection System

**Status: 🚧 DESIGN PHASE**
**Created: 2025-05-25**

## Overview

This document outlines the implementation of a character gender selection system for A Silent Refraction, allowing players to choose between male and female versions of Alex, the courier protagonist.

## Core Concept

After selecting "New Game," players are presented with a simple binary choice to play as either:
- **Alex (Male)** - The default protagonist as originally conceived
- **Alex (Female)** - An alternative version of the courier character

This choice affects:
1. The player character sprite and animations
2. NPC dialog and pronoun usage
3. Potentially deeper narrative and gameplay ramifications (TBD)

## Design Philosophy

- **Minimal Complexity**: The selection process should be simple and not overwhelm new players
- **Equal Treatment**: Both options should feel equally valid and well-developed
- **Narrative Consistency**: The core story remains the same regardless of choice
- **Authentic to Era**: The UI should match early 90s adventure game aesthetics

## Technical Implementation

### Gender Selection Screen

The gender selection occurs immediately after "New Game" selection:

1. **Flow**:
   ```
   Main Menu → New Game → Gender Selection → Opening Cutscene/Game Start
   ```

2. **UI Elements**:
   - Title: "Select Your Character"
   - Two character portraits (male/female Alex)
   - Simple selection indicator (highlight/border)
   - Confirm button or click-to-select

### Data Structure

```gdscript
# In GameManager or PlayerData singleton
enum Gender { MALE, FEMALE }
var player_gender: Gender = Gender.MALE  # Default

# Character configuration
var character_configs = {
    Gender.MALE: {
        "sprite_prefix": "alex_male",
        "portrait": "alex_male_portrait",
        "pronouns": {
            "subject": "he",
            "object": "him",
            "possessive": "his"
        }
    },
    Gender.FEMALE: {
        "sprite_prefix": "alex_female",
        "portrait": "alex_female_portrait",
        "pronouns": {
            "subject": "she",
            "object": "her",
            "possessive": "her"
        }
    }
}
```

### Sprite Requirements

Each gender variant requires:
- Walk animations (8 directions or minimum 4)
- Idle animations
- Talk animations
- Interact animations
- Any special cutscene animations

### Dialog System Integration

The dialog system must support pronoun substitution:

```gdscript
# Example dialog with pronoun markers
"Ah yes, Mr./Ms. Alex. Your room is 306 on the third floor."
"[SUBJECT] looks tired from [POSSESSIVE] journey."
```

#### Dialog Manager Extension

```gdscript
# src/core/dialog/dialog_manager.gd
extends Node

func process_dialog_text(raw_text: String) -> String:
    var processed = raw_text
    
    # Get player gender data
    var player = get_node("/root/Game/Player")
    var gender_config = player.get_gender_config()
    
    # Replace pronoun markers
    processed = processed.replace("[SUBJECT]", gender_config.pronouns.subject)
    processed = processed.replace("[OBJECT]", gender_config.pronouns.object)
    processed = processed.replace("[POSSESSIVE]", gender_config.pronouns.possessive)
    
    # Replace titles
    processed = processed.replace("Mr./Ms.", "Mr." if player.gender == Player.Gender.MALE else "Ms.")
    
    return processed
```

Note: The dialog system itself doesn't need special serialization as pronouns are resolved at runtime based on the player's saved gender.

## Visual Design Guidelines

### Character Differentiation

Both versions should:
- Maintain the "courier" aesthetic (practical clothing, utility belt)
- Be clearly distinguishable at pixel art scale
- Follow the established color palette
- Avoid stereotypical gendering while being recognizable

### Portrait Specifications

- Size: 64x64 pixels (matching UI scale)
- Style: Consistent with NPC portrait style
- Expression: Neutral/professional
- Background: Transparent or simple gradient

## Save System Integration

The gender selection system follows the modular serialization architecture defined in `docs/design/modular_serialization_architecture.md`.

### PlayerSerializer Extension

The existing PlayerSerializer will be extended to include gender data:

```gdscript
# src/core/serializers/player_serializer.gd
extends BaseSerializer

class_name PlayerSerializer

func get_version() -> int:
    return 2  # Increment from 1 to 2 when gender is added

func serialize() -> Dictionary:
    var player = get_node("/root/Game/Player")
    if not player:
        return {}
    
    return {
        "position": compress_vector2(player.global_position),
        "district": player.current_district,
        "room": player.current_room,
        "facing": player.facing_direction,
        "gender": player.gender,  # NEW: Gender selection
        "inventory": serialize_inventory(player.inventory),
        "stats": {
            "money": player.money,
            "suspicion": player.suspicion_level
        }
    }

func deserialize(data: Dictionary) -> void:
    var player = get_node("/root/Game/Player")
    if not player:
        return
    
    # Handle gender first to load correct sprites
    if "gender" in data:
        player.gender = data.gender
        player.load_gender_sprites()
    
    player.global_position = decompress_vector2(data.position)
    player.current_district = data.district
    player.current_room = data.room
    player.facing_direction = data.facing
    deserialize_inventory(player.inventory, data.inventory)
    player.money = data.stats.money
    player.suspicion_level = data.stats.suspicion

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    if from_version == 1 and to_version == 2:
        # Add default gender for old saves
        data["gender"] = PlayerController.Gender.MALE
        print("Migrated save to include gender selection")
    
    return data
```

### Benefits of This Approach

1. **No Core System Changes**: SaveManager doesn't need modification
2. **Version Migration**: Old saves automatically get default gender
3. **Self-Contained**: Gender logic stays within player system
4. **Future-Proof**: Easy to add more character customization later

## Implementation Priority

This feature should be implemented early in development to avoid:
- Duplicating work on animations
- Rewriting extensive dialog
- Save system compatibility issues

### Suggested Implementation Phase

**Recommendation**: Add to Iteration 1 or create Iteration 1.5
- Before extensive NPC dialog is written
- Before player animations are finalized
- After basic movement system is proven

## Future Considerations

### Potential Deeper Ramifications

Areas where gender choice might affect gameplay:
1. **NPC Interactions**: Different initial suspicion levels or trust
2. **District Access**: Certain areas might have different entry requirements
3. **Quest Variations**: Some quests might have alternate paths
4. **Coalition Building**: Different NPCs might be more/less receptive

### Localization Considerations

The pronoun system must be flexible enough to handle:
- Languages with gendered nouns
- Languages without gender pronouns
- Cultural variations in address (Mr./Ms./Mx.)

## Testing Requirements

1. Both character sprites display correctly
2. Animations work for both genders
3. Dialog pronouns substitute correctly
4. Save/load preserves gender choice
5. All cutscenes work with both models
6. No gender blocks access to critical path

## Questions for Further Discussion

1. Should there be any mechanical differences between choices?
2. How should romantic subplots (if any) be handled?
3. Should some NPCs react differently based on gender?
4. What are the specific "deeper ramifications" envisioned?

## Next Steps

1. Approve basic concept and scope
2. Commission or create character portraits
3. Update sprite creation workflow
4. Modify dialog system for pronoun support
5. Update all planning documents
6. Begin implementation in designated iteration