# NPC Registry System Documentation

## Overview

The NPC Registry System manages NPCs in the game, providing:

1. **Persistent NPC data tracking** - Store and load NPC information
2. **Assimilation status management** - Track which NPCs have been assimilated
3. **Placeholder sprite generation** - Create visual representations for all NPCs
4. **GDScript integration** - Access and update NPC data during gameplay

## Dependencies

Before using the NPC Registry System, ensure you have:

```bash
# Install jq for JSON processing
sudo apt-get install jq

# Install ImageMagick for sprite generation
sudo apt-get install imagemagick
```

## Usage

### Generate the NPC Registry

```bash
# Run the script to create or update the NPC registry
./tools/create_npc_registry.sh
```

This will:
- Create a JSON registry of all NPCs in the game
- Generate placeholder sprites for each NPC in all required states
- Create a GDScript utility class for NPC data access

### Accessing NPC Data in Godot

The system generates a GDScript file `src/data/npc_data.gd` which should be added to your project as an autoload singleton.

```gdscript
# In project settings, add NpcData as an autoload singleton
# Then use it anywhere in your code:

# Get a specific NPC
var npc = NpcData.get_npc("security_officer_01")
print(npc.name) # "Officer Jenkins"

# Get all NPCs in a location
var shipping_npcs = NpcData.get_npcs_by_location("shipping_main")

# Check if an NPC is assimilated
if npc.assimilated:
    print(npc.name + " has been assimilated!")

# Mark an NPC as assimilated (e.g., during gameplay)
NpcData.set_assimilated("concierge", true)

# Track player knowledge (separate from actual assimilation state)
NpcData.set_known_assimilated("dock_worker_02", true)

# Get counts for UI display
var total_known = NpcData.get_known_assimilated_count()
print("You've identified " + str(total_known) + " assimilated NPCs")
```

### NPC Data Structure

Each NPC in the registry has the following properties:

```json
{
  "id": "security_officer_01",
  "name": "Officer Jenkins",
  "type": "security_officer",
  "location": "security_main",
  "assimilated": false,
  "suspicious_level": 0.0,
  "known_assimilated": false
}
```

### Sprite States

For each NPC, the system generates sprites for four states:

1. **normal.png** - Default state
2. **suspicious.png** - When suspicious of the player
3. **hostile.png** - When actively opposing the player
4. **assimilated.png** - Assimilated state (subtle visual indicator)

## Integration with the Assimilation System

This registry is designed to work with the time-based assimilation system:

```gdscript
# Example: Assimilation manager accesses the registry
func process_daily_assimilation():
    # Get non-assimilated, non-protected NPCs
    var candidates = []
    for npc in NpcData.npc_registry.npcs:
        if !npc.assimilated and !protected_npcs.has(npc.id):
            candidates.append(npc)
    
    # Select NPCs to assimilate
    for i in range(todays_assimilation_count):
        if candidates.size() > 0:
            var selected = candidates[randi() % candidates.size()]
            NpcData.set_assimilated(selected.id, true)
            candidates.erase(selected)
```

## Customization

To add or modify NPCs, edit the `add_npcs()` function in the script. Each NPC requires:

- **ID**: Unique identifier
- **Name**: Display name
- **Type**: NPC type (affects appearance)
- **Location**: Where the NPC is found
- **Assimilated**: Initial assimilation status (true/false)

To add new NPC types, add a new case to the `generate_npc_placeholder()` function with appropriate colors.

## File Locations

- **NPC Registry**: `src/data/npc_registry.json`
- **Placeholder Sprites**: `src/assets/characters/npcs/<npc_id>/<state>.png`
- **GDScript Utility**: `src/data/npc_data.gd`