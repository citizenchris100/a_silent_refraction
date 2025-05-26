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

## Meaningful Gender Dynamics

### Core Concept: 1950s Social Dynamics

The space station society reflects decidedly 1950s-era social attitudes toward gender, creating meaningful gameplay differences based on the player's gender choice. This isn't just cosmetic - it affects dialog, quest difficulty, and social navigation.

### Social Behavior Patterns

#### Male NPCs toward Female Alex:
- **Condescension**: Some male NPCs speak down to female Alex, explaining things unnecessarily
- **Unwanted Advances**: Certain male NPCs will flirt or make inappropriate comments
- **Professional Dismissal**: In male-dominated fields (Engineering, Security), gaining respect is harder
- **"Protective" Attitudes**: Some will try to "shield" female Alex from "dangerous" work

#### Female NPCs toward Female Alex:
- **Competitive Behavior**: Especially in female-dominated fields (Medical, Administrative)
- **Gatekeeping**: Some women who've "made it" are hostile to other women
- **Solidarity**: Progressive female NPCs may offer hidden support
- **Queen Bee Syndrome**: Established women may see female Alex as a threat

#### Male NPCs toward Male Alex:
- **Machismo Competition**: In male-dominated fields, proving masculinity is expected
- **"Old Boys Club"**: Easier initial acceptance but must maintain the facade
- **Physical Challenges**: More likely to face direct confrontation
- **Bro Culture**: Expected to participate in crude humor and posturing

### Implementation Through Existing Systems

#### 1. Dialog System Extensions

The procedural dialog system already supports contextual generation. Add to `DialogContext`:

```gdscript
class DialogContext:
    var player_gender: String  # "male" or "female"
    var npc_gender: String
    var location_type: String  # "workplace", "social", "private"
    var job_field_gender_bias: String  # "male_dominated", "female_dominated", "neutral"
```

Gender-aware dialog templates:
```gdscript
const GENDER_DYNAMICS_TEMPLATES = {
    "condescending_male_to_female": [
        "Let me explain how this actually works, {PLAYER_TITLE}...",
        "Don't worry your pretty head about the technical details.",
        "Maybe you should find someone to help you with this, dear."
    ],
    "competitive_female_to_female": [
        "Oh, another woman trying to make it in {DEPARTMENT}. Good luck.",
        "I've been the only competent woman here for years.",
        "Interesting that they're hiring more... 'diversity' these days."
    ],
    "flirtatious_male_to_female": [
        "Well hello there, beautiful. New to the station?",
        "A pretty thing like you shouldn't be in a place like this.",
        "How about dinner after your shift, sweetheart?"
    ],
    "macho_male_to_male": [
        "Hope you can handle real man's work, rookie.",
        "We don't coddle weaklings in {DEPARTMENT}.",
        "Prove you've got what it takes or get out."
    ]
}
```

#### 2. NPC Personality Traits

Extend NPC personality system with new traits:

```gdscript
"personality": {
    # Existing traits...
    "progressiveness": 0.3,      # 0 = very traditional, 1 = very progressive
    "sexism_level": 0.7,         # 0 = egalitarian, 1 = highly sexist
    "competitiveness": 0.5,       # General competitive nature
    "gender_secure": 0.4,        # How threatened by same-gender competition
    "romantic_aggression": 0.6,  # Likelihood of unwanted advances
    "paternalism": 0.8          # "Protective" attitude toward women
}
```

#### 3. Trust System Modifiers

Gender affects initial trust and trust gain rates:

```gdscript
# In TrustBarriers configuration
const GENDER_TRUST_MODIFIERS = {
    "female_in_male_field": {
        "professional": -15,      # Harder to gain professional respect
        "personal": -5,          # Some personal barriers
        "ideological": -10       # Assumptions about capabilities
    },
    "male_in_male_field_competitive": {
        "professional": -5,      # Must prove masculinity
        "physical": -10         # Expected to be "tough"
    },
    "female_to_female_competitive": {
        "professional": -10,     # Competition in same field
        "emotional": -5         # Less emotional support
    }
}
```

#### 4. Job System Difficulty

Gender affects job performance evaluation:

```gdscript
# In job_work_quest_system.gd
func calculate_gender_modifier(job_type: String, player_gender: String) -> float:
    var field_bias = get_field_gender_bias(job_type)
    
    if field_bias == "male_dominated" and player_gender == "female":
        return 0.75  # 25% harder to succeed
    elif field_bias == "female_dominated" and player_gender == "female":
        return 0.9   # 10% harder due to competition
    elif field_bias == "male_dominated" and player_gender == "male":
        return 0.95  # 5% harder due to machismo pressure
    else:
        return 1.0   # No modifier

# Gender-biased job fields
const JOB_GENDER_BIAS = {
    "engineering": "male_dominated",
    "security": "male_dominated",
    "dock_work": "male_dominated",
    "medical": "female_dominated",
    "administration": "female_dominated",
    "hospitality": "female_dominated",
    "research": "neutral",
    "maintenance": "neutral"
}
```

### Deeper Ramifications

Areas where gender choice affects gameplay:
1. **Quest Accessibility**: Some quests may be harder/easier to obtain based on gender
2. **Information Gathering**: Different NPCs share different information based on gender dynamics
3. **Coalition Building**: Gender affects which NPCs are naturally allied or opposed
4. **Workplace Events**: Different random events occur based on gender in different jobs
5. **Suspicion Patterns**: Traditional NPCs may find gender-role-breaking behavior suspicious

### Gameplay Impact Examples

#### Security District as Female Alex:
- Guards make dismissive comments about "lady couriers"
- Harder to get information from male officers (-15% trust gain)
- Female security chief either supportive (progressive) or hostile (queen bee)
- May face unwanted advances from lonely night shift guards

#### Medical District as Female Alex:
- Female nurses competitive and gossipy
- Male doctors condescending but potentially flirtatious
- Easier time with progressive female researchers
- Competition for advancement more cutthroat

#### Engineering District as Male Alex:
- Expected to prove physical capability immediately
- Hazing rituals and machismo tests
- Failure seen as "weakness" with harsh social penalties
- Success earns grudging respect but ongoing competition

### Mechanical Benefits and Drawbacks

#### Female Alex:
**Advantages:**
- Progressive NPCs more likely to share sensitive information
- Can leverage sexist assumptions to seem "harmless"
- Solidarity network among progressive women
- Some male NPCs easier to manipulate through flirtation

**Disadvantages:**
- Professional advancement harder in male-dominated fields
- Constant unwanted attention drains time/energy
- Must work harder for same recognition
- Some NPCs simply won't take her seriously

#### Male Alex:
**Advantages:**
- Easier initial acceptance in male-dominated fields
- Taken more seriously in professional contexts
- Old boys' network provides some benefits
- Less sexual harassment to navigate

**Disadvantages:**
- Must constantly prove masculinity
- Emotional vulnerability seen as weakness
- More likely to face physical confrontations
- Progressive NPCs may be more suspicious

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

## Design Validation

This gender dynamics system creates meaningful player choice by:

1. **Affecting Core Gameplay**: Job difficulty, trust building, and information access all change
2. **Creating Different Experiences**: Each playthrough offers unique social navigation challenges
3. **Supporting Narrative Themes**: Reinforces the game's themes of conformity vs. resistance
4. **Using Existing Systems**: Leverages dialog, trust, and job systems without redundancy
5. **Adding Replay Value**: Players will want to experience both perspectives

## Balance Considerations

To ensure both paths remain viable:
- Critical path must be completable regardless of gender
- Each gender gets unique advantages, not just disadvantages
- Progressive NPCs provide alternative routes for both genders
- Time pressure prevents players from grinding past social barriers

## Next Steps

1. Approve basic concept and scope
2. Commission or create character portraits
3. Update sprite creation workflow
4. Modify dialog system for pronoun support
5. Update all planning documents
6. Begin implementation in designated iteration