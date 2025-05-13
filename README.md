# A Silent Refraction

A SCUMM-style point-and-click adventure game built with Godot 3.5.2.

## Project Overview

In "A Silent Refraction," you play as a courier who unknowingly delivers a mysterious substance to a space station. As the substance begins to assimilate the station's inhabitants, you must navigate a web of intrigue to determine who can be trusted and how to stop the invasion.

The game is designed to be reminiscent of classic LucasArts point & click adventure games like The Secret of Monkey Island, with a focus on:

- Point-and-click navigation
- Verb-based interaction system
- Dialog with NPCs and conversation choices
- Suspicion mechanics for NPC interactions
- Dynamic environments with animated background elements
- Investigation and puzzle-solving
- Multiple game endings based on player choices

## Visual Style

The game features a retro-futuristic aesthetic combining elements from:

- Total Recall (1990): Gritty Mars colonization, corporate intrigue
- Alien (1979): Isolated horror, industrial space aesthetic
- Blade Runner (1982): Neon-lit dystopia, moral ambiguity
- SCUMM Games (early 90s): Pixel art style, limited color palette

## Technical Stack

- **Game Engine**: Godot 3.5.2
- **Language**: GDScript
- **Platform**: Cross-platform (developed on Linux Mint and Windows)
- **Architecture**: Custom SCUMM-like framework built from scratch

## Project Structure

├── src/               # Source code
│   ├── characters/    # Player and NPC implementations
│   │   ├── npc/       # NPC classes with dialog and behavior
│   │   └── player/    # Player character implementation
│   ├── core/          # Core game systems
│   │   ├── dialog/    # Dialog management system
│   │   ├── districts/ # Base district functionality
│   │   ├── game/      # Main game manager
│   │   └── input/     # Input handling
│   ├── districts/     # Game environments/rooms
│   │   └── shipping/  # Shipping district implementation
│   ├── objects/       # Interactive objects
│   │   └── base/      # Base interactive object classes
│   ├── test/          # Test scenes for isolated functionality
│   │   ├── dialog_test.tscn    # For testing dialog system
│   │   ├── navigation_test.tscn # For testing navigation system
│   │   └── npc_system_test.tscn # For testing NPC interaction
│   └── ui/            # User interface elements
│       └── verb_ui/   # SCUMM-style verb interface
└── tools/             # Development tools and scripts


## Setup Instructions

### Prerequisites

- Godot 3.5.2 (Standard version, not Mono)
- Linux or Windows with Git Bash
- Command line tools for development
- ImageMagick (for asset generation)
- jq (for JSON processing)

### Installation

1. Install Godot 3.5.2:



2. Clone the Repository:



3. Install required dependencies:

```bash
# For asset generation and NPC registry
sudo apt-get install imagemagick jq
```

4. Run the Game:



## Game Management Script

The project includes a management script (`a_silent_refraction.sh`) to streamline development:

```bash
# Run specific scenes
./a_silent_refraction.sh run         # Run the main game
./a_silent_refraction.sh navigation  # Test navigation system
./a_silent_refraction.sh dialog      # Test dialog system
./a_silent_refraction.sh test        # Run NPC test scene

# Debug tools
./a_silent_refraction.sh debug                # Run debug tools test scene with visualization helpers
./a_silent_refraction.sh debug-universal      # Run universal scene debugger (can load any scene with debug tools)
./a_silent_refraction.sh debug-district NAME  # Debug a specific district (e.g., 'shipping', 'security')

# Project management
./a_silent_refraction.sh clean               # Clean up redundant files
./a_silent_refraction.sh check               # Check project for errors
./a_silent_refraction.sh import              # Import all assets (required after adding new assets)
./a_silent_refraction.sh register-classes    # Register new custom classes with the Godot editor
./a_silent_refraction.sh build               # Build the game for distribution

# Content creation
./a_silent_refraction.sh new-npc <npc_name>         # Create a new NPC
./a_silent_refraction.sh new-district <district_name>  # Create a new district
```

For comprehensive instructions on using these powerful debugging tools, including keyboard shortcuts, editing modes, and workflow tips, see the [Debug Tools Guide](docs/debug_tools.md).


## Iteration Planning System

The project uses a custom iteration planning system via the `iteration_planner.sh` script to manage development tasks. This system helps track progress, organize tasks, and maintain development focus through clearly defined iterations.

### Using the Iteration Planner

Make the script executable:


### Available Commands

#### Initialize the Planning System

Creates the docs directory and initializes the iteration planning system.

#### Create a New Iteration Plan

Example:

This creates a new iteration plan with predefined tasks based on the iteration number.

#### List Tasks for a Specific Iteration

Example:


#### Update Task Status

Where status can be: pending, in_progress, or complete

Example:

This marks Task 3 in Iteration 2 as in progress.

#### Generate Progress Report

Displays a progress report across all iterations, showing completion percentages and task statuses.

#### Link Tasks to Code Files

Example:

This associates Task 1 in Iteration 2 with the specified code file.

## NPC Registry System

The project includes a comprehensive NPC registry system that manages NPCs and their assimilation status throughout the game.

### Using the NPC Registry

```bash
# Generate or update the NPC registry and placeholder sprites
./tools/create_npc_registry.sh
```

This script:
- Creates a JSON-based NPC database with metadata
- Generates placeholder sprites for all NPCs in different states
- Creates a GDScript utility class for accessing NPC data
- Tracks which NPCs are assimilated and known to be assimilated

### Dependencies

The NPC registry system requires:
- ImageMagick (for sprite generation)
- jq (for JSON processing)

Install these dependencies with:
```bash
sudo apt-get install imagemagick jq
```

### NPC States and Assimilation

Each NPC in the registry has:
- Basic information (name, type, location)
- Assimilation status (true/false)
- Suspicion level (0.0 to 1.0)
- Known assimilation status (player's knowledge)

The system supports the game's core assimilation mechanic where NPCs are secretly assimilated over time.

For detailed documentation, see [NPC Registry Usage Guide](docs/npc_registry_usage.md).

## Core Systems

### Game Manager (`src/core/game/game_manager.gd`)
- Coordinates all game systems
- Manages interaction between verb UI, objects, and player
- Handles object clicks and player movement to interaction points

### Input Manager (`src/core/input/input_manager.gd`)
- Handles player input and routes to appropriate systems
- Manages point-and-click movement
- Controls object detection and interaction

### District System (`src/core/districts/base_district.gd`)
- Base class for all game areas
- Handles walkable areas and interactive objects
- Provides boundary checking for player movement
- Supports animated background elements for dynamic environments

### NPC System (`src/characters/npc/base_npc.gd`)
- State machine for NPC behavior (IDLE, TALKING, SUSPICIOUS, HOSTILE, etc.)
- Dialog tree management
- Suspicion tracking and threshold system

### Dialog System (`src/core/dialog/dialog_manager.gd`)
- Manages conversations with NPCs
- Presents dialog options to player
- Handles dialog UI

### Player Character (`src/characters/player/player.gd`)
- Handles movement with acceleration/deceleration
- Responds to point-and-click input
- Stays within walkable area boundaries

### Interactive Objects (`src/objects/base/interactive_object.gd`)
- Base class for all interactive items
- Handles verb-based interactions

### Verb UI (`src/ui/verb_ui/verb_ui.gd`)
- SCUMM-style verb selection interface
- Handles verb selection and UI display

## Development Progress

The project is being developed in iterations, with each iteration focusing on specific features:

### Iteration 1: Basic Environment and Navigation ✅
- Project structure set up
- Basic district (Shipping) created with walkable areas
- Player character implemented with movement capabilities
- Point-and-click navigation system implemented
- Interactive object framework created
- Verb-based interaction system implemented
- Smooth movement with acceleration/deceleration added
- Boundary detection ensures player stays in walkable areas

### Iteration 2: NPC Framework, Suspicion System, and Initial Asset Creation ⏳
- Base NPC class with state machine created
- Dialog system implemented
- NPC suspicion system introduced
- Dialog choices affecting suspicion levels
- Example NPCs (Concierge, Security Officer) implemented
- NPC registry and placeholder generation system
- Initial asset creation for key game areas

### Planned Future Iterations
- Iteration 3.5: Animation Framework and Core Systems ⏳
  - Core animation management system for dynamic backgrounds
  - Animation asset pipeline using Midjourney/RunwayML
  - Animation configuration system and interactive triggers
  - Tram system animations for district transitions
  - Integration with game events and narrative

- Iteration 3: Game Districts, Time Management, Save System, Title Screen, and Asset Expansion
- Iteration 4: Investigation Mechanics, Advanced Inventory, and Mall/Trading Floor Assets
- Iteration 5: Coalition Building
- Iteration 6: Game Progression and Multiple Endings
- Iteration 7: Quest System and Story Implementation

## Testing Systems

The game includes specialized test scenes for focused testing of specific systems:

### Main Game (`./a_silent_refraction.sh run`)
- Runs the complete game with all integrated systems
- Includes NPCs, dialog, interaction, and navigation
- Represents the current production version of the game

### Navigation Test (`./a_silent_refraction.sh navigation`)
- Focused test of the point-and-click navigation system
- Visual indicators for walkable/unwalkable areas
- Tests boundary detection and smooth movement

### Dialog Test (`./a_silent_refraction.sh dialog`)
- Isolated environment for testing the dialog system
- Tests NPC conversations and dialog trees
- Tests suspicion changes through dialog choices

### NPC Test (`./a_silent_refraction.sh test`)
- Simple environment for testing NPC interactions
- Tests NPC state machines and behavior

### Debug Tools (`./a_silent_refraction.sh debug`)
- Visualizes walkable area polygons with vertex indices and coordinates
- Displays real-time mouse coordinates for precise placement
- Helps with level design and debugging collision areas
- Provides polygon editing tools (add/move/delete vertices)
- Includes undo/redo functionality for safe editing

### Universal Debug (`./a_silent_refraction.sh debug-universal`)
- Allows debugging of any scene in the game through a scene selector
- Provides a dropdown menu to choose which scene to load
- Automatically adds debug tools to any selected scene
- Switch between scenes without restarting the game
- Perfect for testing multiple scenes during development

### District Debug (`./a_silent_refraction.sh debug-district NAME`)
- Directly debug a specific district (e.g., `debug-district shipping`)
- Full polygon editing capabilities with multiple editing modes
- Coordinate picking and visualization for precise measurements
- Print/copy polygon data in GDScript format ready for code insertion
- Immediate visualization of changes to walkable areas

For comprehensive instructions on using these powerful debugging tools, including keyboard shortcuts, editing modes, and workflow tips, see the [Debug Tools Guide](docs/debug_tools.md).

## NPC Framework

The game features a robust NPC system with:

- **State Machine**: NPCs transition between states (IDLE, TALKING, SUSPICIOUS, etc.)
- **Dialog System**: Tree-based conversations with player choice and consequences
- **Suspicion System**: NPCs react to player actions with increasing suspicion

To create a new NPC, use the management script:



Then customize its dialog and behavior in `src/characters/npc/SecurityGuard.gd`.

## Asset Management

The project uses the following structure for assets:

```
src/assets/
  backgrounds/     # Background images for districts
  characters/      # Character sprites
    player/        # Player character sprites
    npcs/          # NPC character sprites
  ui/              # UI elements
    buttons/       # Button graphics
    icons/         # Icon graphics
    panels/        # Panel backgrounds
  fonts/           # Custom fonts
  sfx/             # Sound effects
  music/           # Background music
```

### Importing Assets

When adding new assets to the project, they need to be imported by Godot before they can be used. This can be done in two ways:

#### Using the Godot Editor

1. Open the project in the Godot Editor
2. The editor will automatically import new assets
3. Save the project

#### Using Command Line (Recommended)

To import assets without opening the Godot Editor, use:

```bash
godot --path /path/to/project --headless --quit
```

For this project:

```bash
godot --path /home/chris/Documents/repos/a_silent_refraction --headless --quit
```

This command:
- Launches Godot with the project
- Processes and imports all new assets
- Quits immediately without showing the editor UI

You'll need to run this command whenever you add new assets to the project. Consider adding it to your workflow or scripts.

### Asset Generation Tools

The project includes tools for generating placeholder assets:

```bash
# Generate NPC placeholder sprites and registry
./tools/create_npc_registry.sh

# Generate player character placeholder
./tools/create_player_sprite.sh

# Generate placeholder backgrounds
./tools/create_placeholder_bg.sh

# Generate game icon
./tools/create_icon.sh
```

These tools help maintain consistency across assets and speed up development. See the documentation for each tool in the `docs/` directory for details.

### Sprite Creation Workflow

The project includes a comprehensive sprite creation workflow that combines Midjourney for character design, RunwayML for animation, and ImageMagick for processing into 32-bit era game sprites.

For detailed instructions on creating game sprites, see the [Sprite Workflow Guide](docs/sprite_workflow.md). This guide covers:

- Midjourney prompt templates for character generation
- RunwayML animation prompt examples
- Complete processing pipeline with ImageMagick
- Neo Geo and Saturn/32X styling options
- Batch processing multiple characters and animations
- Godot integration for the generated sprite sheets

## Development Scripts

The project includes helpful scripts for development tasks:

### SSH Setup for GitHub

To set up SSH authentication with GitHub (recommended):



This script will:
- Check for or create SSH keys
- Help you add the SSH key to your GitHub account
- Test the connection to GitHub
- Optionally update your repository to use SSH instead of HTTPS

### Branch Cleanup

To clean up all local and remote branches except for main:



**Warning**: This is a destructive operation that will delete branches!

## Project Documentation

The project includes comprehensive documentation to help developers understand the game architecture, design, and implementation plans.

### Core Documentation

| Document | Description | Access Command |
|----------|-------------|----------------|
| [Game Design Document](GAME_DESIGN_DOCUMENT.md) | Full game concept, setting, mechanics, and visual style | `cat GAME_DESIGN_DOCUMENT.md` |
| [Architecture Document](ARCHITECTURE.md) | System architecture, component design, and code organization | `cat ARCHITECTURE.md` |
| [Claude Instructions](CLAUDE.md) | Guidelines for working with Claude.ai on this codebase | `cat CLAUDE.md` |

### Development Planning

| Document | Description | Access Command |
|----------|-------------|----------------|
| [Iteration Progress](docs/iteration_progress.md) | Current development status across all iterations | `cat docs/iteration_progress.md` |
| [Iteration 1 Plan](docs/iterations/iteration1_plan.md) | Basic Environment and Navigation | `cat docs/iterations/iteration1_plan.md` |
| [Iteration 2 Plan](docs/iterations/iteration2_plan.md) | NPC Framework and Suspicion System | `cat docs/iterations/iteration2_plan.md` |
| [Iteration 3 Plan](docs/iterations/iteration3_plan.md) | Game Districts and Time Management | `cat docs/iterations/iteration3_plan.md` |
| [Iteration 4 Plan](docs/iterations/iteration4_plan.md) | Investigation Mechanics and Inventory | `cat docs/iterations/iteration4_plan.md` |
| [Iteration 5 Plan](docs/iterations/iteration5_plan.md) | Coalition Building | `cat docs/iterations/iteration5_plan.md` |
| [Iteration 6 Plan](docs/iterations/iteration6_plan.md) | Game Progression and Endings | `cat docs/iterations/iteration6_plan.md` |
| [Iteration 7 Plan](docs/iterations/iteration7_plan.md) | Quest System and Story Implementation | `cat docs/iterations/iteration7_plan.md` |

### System Design Documents

| Document | Description | Access Command |
|----------|-------------|----------------|
| [Debug Tools Guide](docs/debug_tools.md) | Using the polygon editing and scene debugging tools | `cat docs/debug_tools.md` |
| [NPC Registry Usage](docs/npc_registry_usage.md) | Managing NPCs and their assimilation status | `cat docs/npc_registry_usage.md` |
| [Observation Mechanics](docs/observation_mechanics.md) | NPC assimilation detection system | `cat docs/observation_mechanics.md` |
| [Animated Backgrounds](docs/animated_backgrounds.md) | Creating and managing animated background elements | `cat docs/animated_backgrounds.md` |
| [Animated Backgrounds (Comprehensive)](docs/animated_backgrounds_comprehensive.md) | Detailed guide to the animated background system | `cat docs/animated_backgrounds_comprehensive.md` |
| [Animated Background Workflow](docs/animated_background_workflow.md) | End-to-end workflow for creating animated elements with AI tools | `cat docs/animated_background_workflow.md` |
| [Quest Design](docs/quest_design.md) | Quest system architecture and specific quest designs | `cat docs/quest_design.md` |
| [Sprite Workflow](docs/sprite_workflow.md) | Comprehensive workflow for creating 32-bit era game sprites | `cat docs/sprite_workflow.md` |

### Reading Documentation

You can view any of these documents in several ways:

```bash
# Terminal-based reading (with syntax highlighting if available)
cat docs/debug_tools.md
less docs/debug_tools.md
bat docs/debug_tools.md  # If bat is installed

# Open in your default text editor
xdg-open docs/debug_tools.md  # Linux
open docs/debug_tools.md      # macOS
```

For a better reading experience with Markdown formatting:

```bash
# Install a Markdown viewer (if needed)
sudo apt-get install grip  # Debian/Ubuntu example

# View document with GitHub-style rendering
grip docs/debug_tools.md

# Alternative: Convert to HTML and view in browser
pandoc docs/debug_tools.md -o /tmp/doc.html && xdg-open /tmp/doc.html
```

### Updating Documentation

When making significant changes to the codebase, please update the relevant documentation. This keeps the project maintainable and helps onboard new developers.

## License

MIT License