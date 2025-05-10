# A Silent Refraction

A SCUMM-style point-and-click adventure game built with Godot 3.5.2.

## Project Overview

In "A Silent Refraction," you play as a courier who unknowingly delivers a mysterious substance to a space station. As the substance begins to assimilate the station's inhabitants, you must navigate a web of intrigue to determine who can be trusted and how to stop the invasion.

The game is designed to be reminiscent of classic LucasArts point & click adventure games like The Secret of Monkey Island, with a focus on:

- Point-and-click navigation
- Verb-based interaction system
- Dialog with NPCs and conversation choices
- Suspicion mechanics for NPC interactions
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

### Installation

1. Install Godot 3.5.2:



2. Clone the Repository:



3. Run the Game:



## Game Management Script

The project includes a management script (`a_silent_refraction.sh`) to streamline development:

./a_silent_refraction.sh navigation # Test navigation system
./a_silent_refraction.sh dialog     # Test dialog system

# Clean up redundant files
./a_silent_refraction.sh clean

# Check project for errors
./a_silent_refraction.sh check

# Import all assets (required after adding new assets)
./a_silent_refraction.sh import

# Create a new NPC
./a_silent_refraction.sh new-npc <npc_name>

# Create a new district
./a_silent_refraction.sh new-district <district_name>

# Build the game for distribution
./a_silent_refraction.sh build


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

### Iteration 2: NPC Framework and Suspicion System ⏳
- Base NPC class with state machine created
- Dialog system implemented
- NPC suspicion system introduced
- Dialog choices affecting suspicion levels
- Example NPCs (Concierge, Security Officer) implemented

### Planned Future Iterations
- Iteration 3: Game Districts, Time Management, and Save System
- Iteration 4: Investigation Mechanics and Advanced Inventory
- Iteration 5: Coalition Building
- Iteration 6: Game Progression and Multiple Endings

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

## License

MIT License
