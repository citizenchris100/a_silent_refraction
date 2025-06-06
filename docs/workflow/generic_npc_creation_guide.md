# Generic NPC Creation Guide for Multi-Perspective System

## Overview

This guide provides comprehensive instructions for creating a generic NPC character with full animations for the multi-perspective character system in A Silent Refraction. This character serves dual purposes: validating the multi-perspective system during development and providing a reusable generic NPC for production use in various districts.

## Purpose

The generic NPC character serves multiple roles:
- **System Validation**: Testing multi-perspective sprite loading, animation transitions, and perspective switching
- **Production Asset**: A fully-functional generic NPC that can be deployed in various districts
- **Workflow Validation**: Proving out the complete sprite creation pipeline from concept to implementation
- **Template Reference**: Establishing standards for future NPC creation
- **Performance Baseline**: Setting benchmarks for NPC resource usage

## Character Specifications

### Base Requirements
- **Character Name**: `generic_npc_01`
- **Base Sprite Size**: 64x96 pixels
- **Color Palette**: 16-color canonical palette (defined in style guide)
- **Design Philosophy**: Professional, versatile citizen of the orbital platform
- **File Format**: PNG with transparent background

### Design Guidelines
- Create a neutral, professional appearance suitable for multiple contexts
- Design should work as office worker, technician, or general citizen
- Include subtle details that add character without limiting use cases
- Ensure the design reads well at game scale
- Follow the 32-bit era aesthetic established in the sprite workflow

## Character Design Concept

### Generic NPC Profile
- **Role**: Versatile orbital platform citizen
- **Appearance**: Professional but approachable
- **Suggested Design Elements**:
  - Business casual attire (could work in office, technical, or service roles)
  - Neutral color scheme (grays, blues, or earth tones)
  - Average build and height
  - Minimal accessories (perhaps an ID badge or comm device)
  - Hairstyle that works across multiple contexts
  - Age: 30-45 (mature enough for authority, young enough for action)

### Design Versatility Requirements
The character should believably function as:
- Office worker in corporate districts
- Technician in industrial areas
- Service staff in commercial zones
- Background civilian in any district
- Quest giver or information source
- Minor antagonist if needed

## Required Sprite Assets

### 1. Isometric Perspective (8 Directions)

**Directory**: `src/assets/sprites/generic_npc_01/isometric/`

#### Idle Animations (Single Frame)
- `iso_idle_north.png`
- `iso_idle_northeast.png`
- `iso_idle_east.png`
- `iso_idle_southeast.png`
- `iso_idle_south.png`
- `iso_idle_southwest.png`
- `iso_idle_west.png`
- `iso_idle_northwest.png`

#### Walk Animations (4-6 Frames Each)
- `iso_walk_north_[1-6].png`
- `iso_walk_northeast_[1-6].png`
- `iso_walk_east_[1-6].png`
- `iso_walk_southeast_[1-6].png`
- `iso_walk_south_[1-6].png`
- `iso_walk_southwest_[1-6].png`
- `iso_walk_west_[1-6].png`
- `iso_walk_northwest_[1-6].png`

### 2. Side-Scrolling Perspective (2 Directions)

**Directory**: `src/assets/sprites/generic_npc_01/side_scrolling/`

#### Idle Animations (Single Frame)
- `side_idle_left.png`
- `side_idle_right.png`

#### Walk Animations (4-6 Frames Each)
- `side_walk_left_[1-6].png`
- `side_walk_right_[1-6].png`

### 3. Top-Down Perspective (4 Directions)

**Directory**: `src/assets/sprites/generic_npc_01/top_down/`

#### Idle Animations (Single Frame)
- `top_idle_north.png`
- `top_idle_east.png`
- `top_idle_south.png`
- `top_idle_west.png`

#### Walk Animations (4-6 Frames Each)
- `top_walk_north_[1-6].png`
- `top_walk_east_[1-6].png`
- `top_walk_south_[1-6].png`
- `top_walk_west_[1-6].png`

## Animation Configuration

### Configuration File Location
`src/data/characters/generic_npc_01/animations.json`

### Configuration Structure
```json
{
  "character_name": "generic_npc_01",
  "base_size": {
    "width": 64,
    "height": 96
  },
  "perspectives": {
    "isometric": {
      "sprite_path": "res://src/assets/sprites/generic_npc_01/isometric/",
      "scale_factor": 1.0,
      "animations": {
        "idle": {
          "directions": ["north", "northeast", "east", "southeast", 
                        "south", "southwest", "west", "northwest"],
          "frame_count": 1,
          "fps": 1,
          "loop": false
        },
        "walk": {
          "directions": ["north", "northeast", "east", "southeast", 
                        "south", "southwest", "west", "northwest"],
          "frame_count": 6,
          "fps": 8,
          "loop": true
        }
      }
    },
    "side_scrolling": {
      "sprite_path": "res://src/assets/sprites/generic_npc_01/side_scrolling/",
      "scale_factor": 1.0,
      "animations": {
        "idle": {
          "directions": ["left", "right"],
          "frame_count": 1,
          "fps": 1,
          "loop": false
        },
        "walk": {
          "directions": ["left", "right"],
          "frame_count": 6,
          "fps": 10,
          "loop": true
        }
      }
    },
    "top_down": {
      "sprite_path": "res://src/assets/sprites/generic_npc_01/top_down/",
      "scale_factor": 0.8,
      "animations": {
        "idle": {
          "directions": ["north", "east", "south", "west"],
          "frame_count": 1,
          "fps": 1,
          "loop": false
        },
        "walk": {
          "directions": ["north", "east", "south", "west"],
          "frame_count": 6,
          "fps": 8,
          "loop": true
        }
      }
    }
  }
}
```

## Scene Structure

### Scene File Location
`src/characters/npcs/generic/generic_npc_01.tscn`

### Node Hierarchy
```
GenericNPC01 (Node2D)
├── AnimatedSprite
├── CollisionShape2D
│   └── RectangleShape2D (64x96)
├── PerspectiveController (Node)
├── InteractionArea (Area2D)
│   └── CollisionShape2D (interaction zone)
└── DebugLabel (Label) [Optional for development]
```

### Scene Configuration
1. **GenericNPC01 Node**
   - Script: `res://src/characters/npcs/generic/generic_npc_01.gd`
   - Groups: `npcs`, `generic_npcs`, `interactable`

2. **AnimatedSprite Node**
   - Frames: Load all perspective animations
   - Animation: Set default to "iso_idle_south"
   - Centered: true
   - Offset: (0, -48) to align feet with position

3. **CollisionShape2D Node**
   - Shape: RectangleShape2D
   - Extents: (32, 48)
   - Position: (0, -48)

4. **PerspectiveController Node**
   - No additional configuration needed

5. **InteractionArea Node**
   - For dialogue and interaction triggers
   - Slightly larger than character collision

## Script Implementation

### Script File Location
`src/characters/npcs/generic/generic_npc_01.gd`

### Production-Ready Script Structure
```gdscript
extends "res://src/characters/npc/base_npc.gd"

# NPC Configuration
export var npc_name: String = "Generic Citizen"
export var npc_id: String = "generic_npc_01"
export var default_dialogue: String = "dialogue_generic_greeting"

# References
onready var animated_sprite = $AnimatedSprite
onready var perspective_controller = $PerspectiveController
onready var interaction_area = $InteractionArea
onready var debug_label = $DebugLabel

# State
var current_state = "idle"
var current_direction = "south"
var is_interacting = false

func _ready():
    # Call parent ready
    ._ready()
    
    # Attach perspective controller
    perspective_controller.attach_to_character(self)
    
    # Connect signals
    perspective_controller.connect("perspective_changed", self, "_on_perspective_changed")
    perspective_controller.connect("animation_changed", self, "_on_animation_changed")
    interaction_area.connect("body_entered", self, "_on_interaction_area_entered")
    interaction_area.connect("body_exited", self, "_on_interaction_area_exited")
    
    # Set initial perspective from district
    var district = get_parent()
    if district and district.has("perspective_type"):
        perspective_controller.set_perspective(district.perspective_type)
    
    # Configure debug mode
    if debug_label:
        debug_label.visible = false  # Default off for production

func _on_perspective_changed(old_perspective, new_perspective):
    if debug_label:
        debug_label.text = "Perspective: %s" % PerspectiveType.get_perspective_name(new_perspective)
    
    # Play idle animation in new perspective
    perspective_controller.play_animation("idle", current_direction)

func _on_animation_changed(animation_name):
    if debug_label:
        print("[%s] Playing animation: %s" % [npc_id, animation_name])

func _on_interaction_area_entered(body):
    if body.is_in_group("player"):
        # Show interaction prompt
        is_interacting = true
        emit_signal("player_nearby", true)

func _on_interaction_area_exited(body):
    if body.is_in_group("player"):
        # Hide interaction prompt
        is_interacting = false
        emit_signal("player_nearby", false)

# Production-ready movement functions
func patrol_between_points(point_a: Vector2, point_b: Vector2):
    # Simple patrol behavior for background activity
    pass

func face_player():
    # Turn to face player during interactions
    var player = get_tree().get_nodes_in_group("player")[0]
    if player:
        var direction_vector = player.global_position - global_position
        current_direction = perspective_controller.convert_movement_to_direction(direction_vector)
        perspective_controller.play_animation("idle", current_direction)

# Interface implementation
func interact(verb: String, item = null):
    # Handle interactions based on verb
    match verb:
        "talk":
            face_player()
            start_dialogue(default_dialogue)
        "look":
            return "A typical citizen of the orbital platform."
        _:
            return "They don't respond to that."
```

## Creation Workflow

Following the complete pipeline from `docs/workflow/sprite_workflow.md`:

### Step 1: Create Character in Midjourney

Use this prompt for a versatile generic NPC:
```
full body character, pixel art style, 32-bit video game sprite, 
clean lines, limited color palette, front-facing neutral T-pose, 
transparent background, generic office worker or technician, 
business casual attire, neutral expression, holding datapad, 
practical clothing, ID badge visible, age 35-40, 
style of street fighter character --ar 1:2 --v 6
```

Alternative variations:
- Replace "office worker" with "maintenance technician" for industrial districts
- Replace "datapad" with "clipboard" for administrative roles
- Adjust attire descriptions based on intended versatility

### Step 2: Generate Animations with RunwayML

Create the following animation sequences:

#### Idle Animation
```
character idle breathing animation, subtle movement, standing in place, 
gentle sway, small breathing motion, video game idle pose, 
minimal movement, clean white background
```

#### Walk Cycle
```
character walking cycle, steady professional pace, looping animation, 
arcade game style movement, clear distinct steps, arms swinging naturally, 
minimal vertical bobbing, consistent speed, white background
```

#### Talk Animation (Optional but useful)
```
character talking animation, subtle hand gestures, 
professional conversation stance, facing camera, minimal movement, 
simple background, video game dialog animation
```

### Step 3: Process with Master Pipeline

Run the complete 32-bit styling pipeline:
```bash
# For each animation type
./master_sprite_pipeline.sh generic_npc_01 idle runway_idle.mp4
./master_sprite_pipeline.sh generic_npc_01 walk runway_walk.mp4
./master_sprite_pipeline.sh generic_npc_01 talk runway_talk.mp4
```

### Step 4: Generate Directional Variants
1. **Isometric Directions**:
   - Rotate/modify base sprite for 8 directions
   - Ensure 45-degree angles for diagonals
   - Add clear directional indicators

2. **Side-Scrolling Directions**:
   - Create left-facing version
   - Mirror for right-facing version
   - Add profile-specific details

3. **Top-Down Directions**:
   - Create 4 cardinal directions
   - Ensure clear up/down/left/right indicators
   - Maintain centered pivot point

### Step 3: Create Walk Animations
1. **Frame Planning**:
   - Frame 1: Contact position
   - Frame 2: Recoil
   - Frame 3: Passing position
   - Frame 4: High point
   - Frame 5: Passing position (opposite)
   - Frame 6: Contact position (opposite)

2. **Animation Guidelines**:
   - Keep movement subtle (4-8 pixel shifts)
   - Maintain consistent volume
   - Add slight arm/leg movement indicators
   - Ensure smooth loops

### Step 5: Create Perspective-Specific Variants

Since RunwayML generates side-view animations, you'll need to create perspective variants:

1. **For Isometric View**:
   - Use the side-view as reference
   - Create 3/4 view variants for 8 directions
   - Maintain consistent proportions
   - Apply perspective-appropriate shading

2. **For Top-Down View**:
   - Create overhead perspective versions
   - Simplify detail for readability
   - Focus on clear silhouettes
   - Reduce to 4 cardinal directions

3. **Tools for Perspective Conversion**:
   - Use image editing software to manually adjust
   - Or use the sprite rotation utilities in the workflow
   - Maintain consistency across all frames

### Step 6: Final Processing and Organization
1. Create directory structure as specified
2. Name files according to convention
3. Generate Godot import files:
   ```bash
   ./generate_import_files.sh
   ```
4. Verify imports in Godot editor

## Production Considerations

### Reusability Guidelines

To ensure maximum reusability of this generic NPC:

1. **Neutral Design Choices**:
   - Avoid district-specific clothing or accessories
   - Use colors that work in various lighting conditions
   - Keep facial features generic but pleasant
   - Design works for both background and interactive roles

2. **Versatile Animation Set**:
   - Idle animation should work for standing, waiting, or working
   - Walk cycle appropriate for patrol or purposeful movement
   - Talk animation subtle enough for various conversation types
   - Consider adding a "work" animation for typing/operating equipment

3. **Configuration Flexibility**:
   - Design the sprite to work with color tinting/palette swaps
   - Ensure accessories can be added via overlay sprites
   - Keep base design modular for easy customization

### Performance Optimization

Since this NPC will be used multiple times:

1. **Sprite Sheet Optimization**:
   - Use sprite atlases to reduce draw calls
   - Share animation frames where possible
   - Optimize frame counts (6 frames for walk, not 12)

2. **Memory Considerations**:
   - Keep total sprite sheet under 512x512 if possible
   - Use indexed color mode for smaller file sizes
   - Consider LOD (Level of Detail) versions for distant NPCs

## Testing Procedures

### Unit Testing
1. **Sprite Loading Test**:
   - Verify all sprites load correctly
   - Check for missing textures
   - Validate file paths

2. **Animation Playback Test**:
   - Test each animation state
   - Verify frame sequences
   - Check loop behavior

3. **Direction Conversion Test**:
   - Test movement vector to direction conversion
   - Verify all directions accessible
   - Check edge cases

### Integration Testing
1. **Perspective Switching**:
   - Test transitions between all perspective types
   - Verify sprite changes correctly
   - Check for animation continuity

2. **Movement Testing**:
   - Test character movement in each perspective
   - Verify direction changes
   - Check animation synchronization

3. **Performance Testing**:
   - Monitor frame rate with animations
   - Check memory usage
   - Test with multiple instances

## Quality Checklist

### Sprite Quality
- [ ] All sprites are 64x96 pixels
- [ ] Transparent backgrounds on all files
- [ ] Consistent character proportions across all perspectives
- [ ] Professional appearance suitable for production use
- [ ] 16-color canonical palette applied
- [ ] No anti-aliasing artifacts
- [ ] Clean pixel art style matching 32-bit era aesthetic
- [ ] Readable at game zoom levels

### Animation Quality
- [ ] Smooth walk cycles (no popping)
- [ ] Consistent timing across directions
- [ ] Proper loop points
- [ ] Natural movement feel
- [ ] No missing frames

### File Organization
- [ ] Correct directory structure
- [ ] Proper file naming convention
- [ ] All files in PNG format
- [ ] Import files generated
- [ ] Configuration JSON valid

### Technical Integration
- [ ] Scene structure correct
- [ ] Script properly attached
- [ ] PerspectiveController connected
- [ ] Animations play correctly
- [ ] No console errors

## Common Issues and Solutions

### Issue: Sprites appear offset
**Solution**: Check AnimatedSprite offset property and collision shape alignment

### Issue: Animation doesn't loop
**Solution**: Verify loop property in AnimatedSprite and animation configuration

### Issue: Wrong direction plays
**Solution**: Check direction conversion logic and animation naming

### Issue: Perspective switch fails
**Solution**: Ensure all required animations exist for target perspective

### Issue: Performance degradation
**Solution**: Optimize sprite sizes and reduce frame counts if needed

## Deliverables Summary

### Required Files
1. **Sprite Assets**: ~46-84 PNG files
   - Isometric: 8 idle + 48 walk frames (+ optional talk animations)
   - Side-scrolling: 2 idle + 12 walk frames (+ optional talk animations)
   - Top-down: 4 idle + 24 walk frames (+ optional talk animations)

2. **Configuration**: 1 JSON file
   - Complete animation definitions
   - Perspective configurations
   - Timing and loop settings
   - NPC-specific parameters

3. **Scene Files**: 1 .tscn file
   - Production-ready node hierarchy
   - Configured components
   - Interaction areas
   - Script attachment

4. **Script**: 1 .gd file
   - Full NPC functionality
   - Interaction system integration
   - Dialogue support
   - Debug features

5. **Documentation**: 
   - This creation guide
   - Usage notes for level designers
   - Customization guidelines

## Usage in Production

### Deployment Guidelines

1. **District Placement**:
   ```gdscript
   # In district scene
   var generic_npc = preload("res://src/characters/npcs/generic/generic_npc_01.tscn").instance()
   generic_npc.position = Vector2(100, 200)
   generic_npc.npc_name = "Office Worker"
   generic_npc.default_dialogue = "dialogue_office_worker_greeting"
   add_child(generic_npc)
   ```

2. **Customization Options**:
   - Change `npc_name` for different contexts
   - Assign different dialogue trees
   - Add patrol paths or standing positions
   - Tint sprite for variety

3. **Performance Guidelines**:
   - Limit to 10-15 instances per scene
   - Use visibility culling for off-screen NPCs
   - Consider static NPCs for distant backgrounds

## Next Steps

1. **System Validation**: Use this NPC to validate the multi-perspective system
2. **Production Testing**: Deploy in test districts to ensure versatility
3. **Template Creation**: Use as base for creating more specific NPC types
4. **Documentation**: Create usage guide for level designers
5. **Optimization**: Profile performance with multiple instances

This generic NPC serves as both a system validation tool and a production-ready asset, demonstrating the complete workflow from concept to implementation.