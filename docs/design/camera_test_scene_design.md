# Camera Test Scene Design Document

**Status: 📋 DESIGN**  
**Target: Iteration 3, Task 3**  
**Created: May 22, 2025**

## Executive Summary

This document outlines the design for a comprehensive camera test scene that validates all camera system improvements while maintaining the aesthetic and practical nature of "A Silent Refraction". Rather than abstract test patterns, we use practical, in-game style environments that serve dual purposes: thorough technical validation and potential reuse as game assets.

## Design Philosophy

### Core Principles
1. **Practical Over Abstract**: Test backgrounds should look like they belong in the game world
2. **Natural Integration**: Testing elements are incorporated into environmental storytelling
3. **Dual Purpose**: Test assets should be reusable for actual game content where possible
4. **Comprehensive Coverage**: Every camera requirement must be testable through the scene
5. **Visual Clarity**: Issues should be immediately visible without breaking immersion

### Alignment with Game Aesthetic
Following the game design document's vision:
- Total Recall (1990): Industrial Mars colonization aesthetic
- Alien (1979): Isolated space station atmosphere
- Blade Runner (1982): Neon-lit dystopian elements
- SCUMM Games: Pixel art clarity and readability

## Camera Test Scene Architecture

### Scene Structure
```
CameraSystemTest (Node2D)
├── TestEnvironment (Node2D)
│   ├── Background (Sprite) - Swappable test backgrounds
│   ├── Camera (ScrollingCamera)
│   ├── Player (KinematicBody2D)
│   ├── TestObjects (Node2D)
│   └── WalkableAreas (Node2D)
└── UI (CanvasLayer)
    ├── ControlPanel (TabContainer)
    │   ├── MovementPanel
    │   ├── CoordinatePanel
    │   ├── StatePanel
    │   ├── BoundsPanel
    │   └── ScalingPanel
    └── OutputDisplay (RichTextLabel)
```

### UI Panel Specifications

#### Movement Panel - Camera Movement Controls
```
Purpose: Test camera movement behaviors and transitions
Features:
- Direct movement to specific positions
- Player following toggle
- Transition type selection (instant/smooth/linear)
- Speed adjustment slider
- Preset scenario buttons for edge cases
```

#### Coordinate Panel - Transformation Testing
```
Purpose: Validate screen-to-world coordinate conversions
Features:
- Click position tracking
- Real-time coordinate display
- Zoom level controls
- Visual grid overlay toggle
- Transformation validation indicators
```

#### State Panel - State Machine Monitoring
```
Purpose: Monitor camera states and signal emissions
Features:
- Current state display
- State transition history
- Signal emission log
- Manual state trigger buttons
- History clearing function
```

#### Bounds Panel - Boundary Testing
```
Purpose: Test camera boundary constraints
Features:
- Bounds enable/disable toggle
- Manual bounds configuration
- Preset boundary scenarios
- Visual bounds overlay
- Boundary violation indicators
```

#### Scaling Panel - Visual Correctness Validation
```
Purpose: Ensure proper background scaling (prevent grey bars)
Features:
- Background dimension display
- Viewport size information
- Scaling override controls
- Visual validation checklist
- Resolution testing options
```

## Practical Test Background Designs

### 1. Spaceport Loading Dock - Grid Reference Testing

**Purpose**: Natural grid pattern for coordinate reference and transformation testing

**Visual Elements**:
- Industrial metal floor with visible wear patterns
- Loading bay designations painted on floor: "BAY A1", "BAY A2", etc.
- Yellow safety stripes creating organic grid divisions
- Stacked cargo containers with shipping labels
- Overhead crane tracks providing horizontal reference lines
- Numbered tool lockers (001-100) along walls
- Environmental details: oil stains, scuff marks, tire tracks
- Corner emergency exits with illuminated signage

**Technical Testing Features**:
- Grid pattern enables precise coordinate verification
- Bay numbers serve as position references
- Container labels test text readability at various zoom levels
- Safety stripes help identify transformation accuracy

**Color Implementation** (using canonical palette):
- Dark Brown (#3c3537): Base floor material
- Medium Brown (#494543): Cargo containers
- Pale Yellow (#f3e9c4): Safety markings and text
- Blue Gray (#7b8e95): Metal fixtures and machinery
- Rusty Pink (#907577): Warning signs and hazard markers

### 2. Security Brig Corridor - Edge Detection Testing

**Purpose**: Natural boundaries for edge detection and grey bar prevention

**Visual Elements**:
- Long prison corridor with cells on both sides
- Red emergency lighting strips along walls
- Security cameras mounted in corners
- Cell doors with observation windows
- Central walkway with worn flooring
- Overhead fluorescent lighting with some flickering
- Security checkpoint at corridor end
- Posted regulations and prisoner notices

**Technical Testing Features**:
- Corridor walls create natural boundary test areas
- Red lighting strips highlight edge zones
- Corner cameras mark boundary intersections
- Long perspective tests camera following behavior

**Environmental Storytelling**:
- Scratches on cell doors
- Makeshift calendars visible in cells
- Security incident reports on bulletin board
- Worn paths showing guard patrol routes

### 3. Mall Atrium - Zoom Level Testing

**Purpose**: Multi-scale detail testing through natural environmental layers

**Visual Elements**:
- Three-level mall with visible shops
- Ground floor: Detailed storefronts with window displays
- Second floor: Medium-detail shops with neon signs
- Third floor: Large anchor store signs
- Central fountain with animated water effect
- Glass elevator with visible mechanisms
- Decorative plants and seating areas
- Advertising kiosks with rotating displays

**Technical Testing Features**:
- Multiple detail levels test zoom clarity
- Store signs readable at appropriate zoom levels
- Fountain ripples test fine movement detail
- Glass surfaces test transparency at different scales

**Shop Examples**:
- "Stellar Styles" clothing boutique (detailed mannequins)
- "Quantum Cafe" (readable menu boards)
- "Nebula Electronics" (product displays)
- "Red Planet Books" (book spine text detail)

### 4. Trading Floor - Movement Path Testing

**Purpose**: Natural pathways for camera movement and pathfinding validation

**Visual Elements**:
- Trading desk clusters creating corridors
- Floor cable management systems showing data routes
- Worn carpet paths from trader movement
- Queue management barriers
- Multiple display screens showing market data
- Central trading pit with tiered seating
- Private meeting rooms with glass walls
- Reception desk with visitor management

**Technical Testing Features**:
- Desk arrangements create navigation challenges
- Cable runs provide movement path indicators
- Worn paths show optimal routes
- Barriers test pathfinding around obstacles

**Interactive Elements**:
- Holographic stock tickers
- Animated graph displays
- Scrolling news feeds
- Blinking communication terminals

### 5. Engineering Deck - Coordinate Testing

**Purpose**: Technical labeling for precise coordinate verification

**Visual Elements**:
- Maintenance hatch grid with alphanumeric labels (MH-A01, MH-B01)
- Pipe junction boxes with coordinate stamps
- Floor grating sections with embedded markers
- Equipment panels with serial numbers
- Color-coded pipe systems
- Diagnostic terminals with location readouts
- Emergency equipment stations
- Ventilation grates with section codes

**Technical Testing Features**:
- Hatch labels provide exact position references
- Junction boxes mark intersection points
- Grating patterns create visual grid
- Serial numbers test text rendering at distance

**Engineering Details**:
- Steam leak effects for movement testing
- Rotating turbine components
- Pressure gauge animations
- Warning light sequences

### 6. Medical Bay - Aspect Ratio Testing

**Purpose**: Various room sizes and viewing angles for aspect ratio validation

**Visual Elements**:
- Examination rooms visible through observation windows
- Wide surgical theater with panoramic viewing glass
- Standard-width patient rooms
- Ultra-wide corridor connecting wings
- Reception area with varied seating arrangements
- Medical equipment of different sizes
- Wall-mounted displays showing patient data
- Quarantine chambers with different dimensions

**Technical Testing Features**:
- Room dimensions match common aspect ratios
- Windows frame different aspect ratio views
- Corridor width tests wide camera bounds
- Equipment placement tests object visibility

**Medical Equipment**:
- Diagnostic beds with monitoring systems
- Surgical tools on sterile trays
- Medicine cabinets with labeled contents
- Emergency crash carts

### 7. Barracks Common Area - Performance Testing

**Purpose**: Dense detail environment for performance stress testing

**Visual Elements**:
- Fully furnished lounge with multiple seating groups
- Entertainment center with active displays
- Kitchen area with appliances and utensils
- Reading nook with bookshelves
- Game tables with pieces in play
- Potted plants with detailed foliage
- Complex patterned carpeting
- Personal items scattered naturally

**Technical Testing Features**:
- High object density tests rendering performance
- Detailed textures stress GPU at zoom
- Multiple animation states for ambiance
- Complex shadows and lighting

**Resident Activity**:
- NPCs reading in chairs
- Chess game in progress
- Someone making coffee
- Cat sleeping on couch

### 8. Station Tram Platform - Scaling Validation

**Purpose**: Critical visual correctness testing, especially background scaling

**Visual Elements**:
- Platform edge with yellow safety line
- Digital arrival/departure boards
- Advertisement posters in various sizes
- Full station map on wall
- Bench seating along platform
- Vending machines with product displays
- Information kiosks
- Platform number indicators

**Technical Testing Features**:
- Platform edge tests boundary rendering
- Safety line verifies edge detection
- Text at multiple scales tests readability
- Map details test zoom preservation

**Dynamic Elements**:
- Scrolling departure times
- Animated advertisements
- Blinking platform lights
- Ambient crowd sounds

## Implementation Guidelines

### Background Creation Process

1. **Canvas Setup**
   - Primary size: 4096x2048 pixels
   - Use only the 16-color canonical palette
   - Create at 1:1 pixel ratio (no anti-aliasing)

2. **Layering Strategy**
   - Background: Base environment structure
   - Midground: Interactive elements and details
   - Foreground: UI reference points and markers
   - Overlay: Testing indicators (toggleable)

3. **Technical Markers**
   - Embed naturally into environment
   - Ensure visibility without breaking immersion
   - Use environmental storytelling for reference points

4. **Performance Considerations**
   - Optimize pattern complexity for rendering
   - Balance detail with performance requirements
   - Test on minimum specification hardware

### Test Scene Implementation

```gdscript
# Example structure for camera test scene controller
extends Node2D

# Test environments
var test_backgrounds = {
    "spaceport": preload("res://src/assets/test_backgrounds/spaceport_dock.png"),
    "security": preload("res://src/assets/test_backgrounds/security_corridor.png"),
    "mall": preload("res://src/assets/test_backgrounds/mall_atrium.png"),
    "trading": preload("res://src/assets/test_backgrounds/trading_floor.png"),
    "engineering": preload("res://src/assets/test_backgrounds/engineering_deck.png"),
    "medical": preload("res://src/assets/test_backgrounds/medical_bay.png"),
    "barracks": preload("res://src/assets/test_backgrounds/barracks_common.png"),
    "tram": preload("res://src/assets/test_backgrounds/tram_platform.png")
}

# Test modes
enum TestMode {
    MOVEMENT,
    COORDINATES,
    STATE,
    BOUNDS,
    SCALING
}

var current_mode = TestMode.MOVEMENT
var current_background = "spaceport"
```

## Testing Procedures

### Visual Validation Checklist
1. **Grey Bar Test**: No grey areas visible at screen edges
2. **Scaling Test**: Background fills viewport appropriately
3. **Movement Test**: Camera follows player smoothly
4. **Boundary Test**: Camera respects defined limits
5. **Coordinate Test**: Click positions accurately mapped
6. **State Test**: Transitions occur as expected
7. **Performance Test**: Maintain 60 FPS in complex scenes

### Regression Prevention
1. Run all test modes when modifying camera system
2. Document any visual anomalies with screenshots
3. Verify against previous test results
4. Update test procedures for new features

## Success Criteria

### Technical Requirements Met
- ✅ All camera movement scenarios testable
- ✅ Coordinate transformations visually verifiable
- ✅ State changes and signals observable
- ✅ Boundary behaviors clearly visible
- ✅ Background scaling issues immediately apparent

### Practical Integration Achieved
- ✅ Test environments look like game locations
- ✅ Testing doesn't break immersion
- ✅ Assets potentially reusable for game
- ✅ Natural environmental markers for reference
- ✅ Maintains game's aesthetic vision

## Future Enhancements

### Additional Test Environments
- Alternative layouts for existing districts
- Different times of day/lighting conditions
- Populated vs. empty versions of spaces
- Emergency/lockdown versions with different lighting

### Advanced Testing Features
- Automated test runs with result logging
- Screenshot comparison for regression detection
- Performance profiling integration
- Save/load camera state configurations

## Conclusion

This camera test scene design provides comprehensive validation capabilities while maintaining the practical, immersive quality expected in "A Silent Refraction". By using in-world environments rather than abstract test patterns, we ensure that camera improvements work correctly in realistic game scenarios while providing developers with powerful testing tools.

The design supports the TDD methodology by making camera behaviors visually verifiable and immediately apparent, allowing for rapid iteration and confidence in system improvements.