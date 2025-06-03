# Multi-Perspective System Architecture

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Multi-Perspective System                         │
└─────────────────────────────────────────────────────────────────────────┘
                                      │
                ┌─────────────────────┴─────────────────────┐
                │                                           │
                ▼                                           ▼
        ┌──────────────┐                          ┌─────────────────┐
        │ Core System  │                          │ Character Layer │
        └──────────────┘                          └─────────────────┘
                │                                           │
    ┌───────────┴───────────┐                              │
    │                       │                              │
    ▼                       ▼                              ▼
┌─────────────┐    ┌──────────────────┐      ┌────────────────────────┐
│Perspective  │    │Perspective       │      │CharacterPerspective    │
│Type         │    │Configuration     │      │Controller              │
├─────────────┤    ├──────────────────┤      ├────────────────────────┤
│• ISOMETRIC  │    │• direction_count │      │• attach_to_character() │
│• SIDE_SCROLL│    │• speed_multiplier│      │• set_perspective()     │
│• TOP_DOWN   │    │• sprite_scale    │      │• play_animation()      │
│             │    │• camera_zoom     │      │• convert_movement()    │
│• Utilities: │    │• y_sort_enabled  │      │                        │
│ - get_name()│    │                  │      │Signals:                │
│ - to_string()    │• Factory methods:│      │• perspective_changed   │
│ - get_dirs()│    │ - isometric()    │      │• animation_changed     │
└─────────────┘    │ - side_scroll()  │      └────────────────────────┘
                   │ - top_down()     │                   │
                   └──────────────────┘                   │
                            │                             │
                            └─────────────┬───────────────┘
                                          │
                                          ▼
                              ┌────────────────────┐
                              │   Integration      │
                              └────────────────────┘
                                          │
                ┌─────────────────────────┴─────────────────────────┐
                │                                                   │
                ▼                                                   ▼
        ┌──────────────┐                                  ┌─────────────┐
        │   District   │                                  │  Character  │
        ├──────────────┤                                  ├─────────────┤
        │perspective:  │──────perspective_changed────────▶│perspective  │
        │ ISOMETRIC   │                                  │controller   │
        └──────────────┘                                  └─────────────┘
```

## Data Flow

### 1. District Entry Flow
```
Player enters district
        │
        ▼
District.perspective_type
        │
        ▼
emit_signal("perspective_changed", type)
        │
        ▼
CharacterPerspectiveController.set_perspective(type)
        │
        ├─── Load perspective configuration
        │
        ├─── Update internal state
        │
        ├─── Emit perspective_changed signal
        │
        └─── Update character animations
```

### 2. Movement Input Flow
```
Player clicks position
        │
        ▼
Calculate movement vector
        │
        ▼
PerspectiveController.convert_movement_to_direction(vector)
        │
        ├─── Check current perspective type
        │
        ├─── Apply perspective-specific conversion
        │       ├─── ISOMETRIC: 8-way direction
        │       ├─── SIDE_SCROLL: 2-way direction
        │       └─── TOP_DOWN: 4-way direction
        │
        └─── Return direction string ("north", "left", etc.)
                │
                ▼
        Play perspective-specific animation
```

### 3. Animation Resolution Flow
```
play_animation("walk", "south")
        │
        ▼
Build animation name: prefix + state + "_" + direction
        │
        ▼
"iso_walk_south"
        │
        ▼
Check if animation exists
        │
        ├─── YES: Play perspective animation
        │
        └─── NO: Try fallback animation
                    │
                    ▼
            Extract base state ("walk")
                    │
                    ▼
            Play generic animation
```

## Component Relationships

### Class Dependencies
```
CharacterPerspectiveController
    │
    ├──uses──▶ PerspectiveType (constants and utilities)
    │
    ├──uses──▶ PerspectiveConfiguration (settings)
    │
    └──attached to──▶ Character Node (Node2D)
                        │
                        └──contains──▶ AnimatedSprite
```

### Signal Connections
```
GameManager ──district_changed──▶ Player
    │
    └──▶ Player._on_district_changed()
            │
            └──▶ PerspectiveController.set_perspective()
                    │
                    └──emits──▶ perspective_changed signal
                                    │
                                    └──▶ UI updates
                                    └──▶ Camera adjustments
                                    └──▶ Audio system updates
```

## Configuration Loading

### Static Configuration (Compile-time)
```
PerspectiveConfiguration.create_isometric_config()
                │
                ├─── Creates new configuration instance
                ├─── Sets hardcoded values
                └─── Returns configuration
```

### Dynamic Configuration (Runtime)
```
Load from JSON file
        │
        ▼
Parse JSON data
        │
        ▼
PerspectiveConfiguration.from_dict(data)
        │
        ├─── Create configuration instance
        ├─── Populate from dictionary
        ├─── Validate values
        └─── Return configuration
```

## Memory Layout

### PerspectiveController Instance
```
CharacterPerspectiveController
├─ current_perspective: int (4 bytes)
├─ character_node: Node2D reference
├─ perspective_configs: Dictionary
│   ├─ [0]: IsometricConfig
│   ├─ [1]: SideScrollConfig
│   └─ [2]: TopDownConfig
├─ animated_sprite: AnimatedSprite reference
├─ current_direction: String
└─ current_animation_state: String
```

### Configuration Cache
```
perspective_configs (Dictionary)
    │
    ├─── Key: 0 (ISOMETRIC)
    │     └─── Value: PerspectiveConfiguration
    │           ├─ direction_count: 8
    │           ├─ movement_speed_multiplier: 1.0
    │           └─ ... other properties
    │
    ├─── Key: 1 (SIDE_SCROLLING)
    │     └─── Value: PerspectiveConfiguration
    │           ├─ direction_count: 2
    │           ├─ movement_speed_multiplier: 1.2
    │           └─ ... other properties
    │
    └─── Key: 2 (TOP_DOWN)
          └─── Value: PerspectiveConfiguration
                ├─ direction_count: 4
                ├─ movement_speed_multiplier: 1.0
                └─ ... other properties
```

## Performance Characteristics

### Time Complexity
- Perspective lookup: O(1) - Dictionary access
- Direction conversion: O(1) - Simple calculations
- Animation lookup: O(1) - Dictionary access
- Configuration access: O(1) - Cached in memory

### Space Complexity
- Per character: ~200 bytes (controller instance)
- Per perspective: ~100 bytes (configuration)
- Total for 3 perspectives: ~500 bytes per character

### Optimization Points
1. Configurations are loaded once and cached
2. No allocations during normal operation
3. Signal connections are one-time setup
4. Animation names are built with simple string concatenation