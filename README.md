# A Silent Refraction

A SCUMM-style point-and-click adventure game built with Godot 3.5.2.

## Project Overview

In "A Silent Refraction," you play as a courier who unknowingly delivers a mysterious substance to a space station. As the substance begins to assimilate the station's inhabitants, you must navigate a web of intrigue to determine who can be trusted and how to stop the invasion.

The game is designed to be reminiscent of classic Lucas Arts point & click adventure games like The Secret of Monkey Island, with a focus on:
- Point-and-click navigation
- Verb-based interaction system
- Inventory management
- Dialog with NPCs
- Suspicion mechanics

## Technical Stack

- **Game Engine**: Godot 3.5.2
- **Language**: GDScript
- **Platform**: Cross-platform (developed on Linux Mint and Windows)
- **Architecture**: Custom SCUMM-like framework built from scratch

## Project Structure

```
a_silent_refraction/
├── assets/            # Game assets (images, audio, etc.)
├── docs/              # Documentation and design documents
├── src/               # Source code
│   ├── characters/    # Player and NPC implementations
│   ├── core/          # Core game systems
│   ├── districts/     # Game environments/rooms
│   ├── objects/       # Interactive objects
│   └── ui/            # User interface elements
└── tools/             # Development tools and scripts
```

## Setup Instructions

### Prerequisites

- [Godot 3.5.2](https://godotengine.org/download/archive/) (Standard version, not Mono)
- Linux or Windows with Git Bash
- Command line tools for development

### Installation

1. **Install Godot 3.5.2**:
   ```bash
   # Create a directory for Godot
   mkdir -p ~/godot
   
   # Download Godot 3.5.2
   cd ~/godot
   wget https://github.com/godotengine/godot/releases/download/3.5.2-stable/Godot_v3.5.2-stable_x11.64.zip
   
   # Extract and make executable
   unzip Godot_v3.5.2-stable_x11.64.zip
   chmod +x Godot_v3.5.2-stable_x11.64
   
   # Optional: Create a symlink for easier access
   mkdir -p ~/bin
   ln -s ~/godot/Godot_v3.5.2-stable_x11.64 ~/bin/godot
   export PATH="$HOME/bin:$PATH"
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
   ```

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/a_silent_refraction.git
   cd a_silent_refraction
   ```

3. **Run the Game**:
   ```bash
   # Using the Godot binary directly
   ~/godot/Godot_v3.5.2-stable_x11.64 --path /path/to/a_silent_refraction
   
   # Or if you set up the symlink
   godot --path /path/to/a_silent_refraction
   ```

4. **Open in Editor** (if needed):
   ```bash
   # Launch Godot editor with the project
   ~/godot/Godot_v3.5.2-stable_x11.64 -e --path /path/to/a_silent_refraction
   ```

## Iteration Planning System

The project uses a custom iteration planning system via the `iteration_planner.sh` script to manage development tasks. This system helps track progress, organize tasks, and maintain development focus through clearly defined iterations.

### Using the Iteration Planner

Make the script executable:
```bash
chmod +x iteration_planner.sh
```

### Available Commands

#### Initialize the Planning System
```bash
./iteration_planner.sh init
```
Creates the docs directory and initializes the iteration planning system.

#### Create a New Iteration Plan
```bash
./iteration_planner.sh create <iteration_number> "<iteration_name>"
```
Example:
```bash
./iteration_planner.sh create 2 "NPC Framework and Suspicion System"
```
This creates a new iteration plan with predefined tasks based on the iteration number.

#### List Tasks for a Specific Iteration
```bash
./iteration_planner.sh list <iteration_number>

Example:
```bash
./iteration_planner.sh list 2
```

#### Update Task Status
```bash
./iteration_planner.sh update <iteration_number> <task_number> <status>
```
Where status can be: `pending`, `in_progress`, or `complete`

Example:
```bash
./iteration_planner.sh update 2 3 in_progress
```
This marks Task 3 in Iteration 2 as in progress.

#### Generate Progress Report
```bash
./iteration_planner.sh report
```
Displays a progress report across all iterations, showing completion percentages and task statuses.

#### List Tasks for a Specific Iteration
```bash
./iteration_planner.sh list <iteration_number>
```
Example:
```bash
./iteration_planner.sh list 2
```
Shows all tasks for the specified iteration, including their descriptions, current status, and any linked code files.

#### Link Tasks to Code Files
```bash
./iteration_planner.sh link <iteration_number> <task_number> "<file_path>"
```
Example:
```bash
./iteration_planner.sh link 2 1 "src/core/npc/base_npc.gd"
```
This associates Task 1 in Iteration 2 with the specified code file.

### Predefined Iterations

The iteration planner comes with templates for key iterations:

1. **Iteration 1**: Basic Environment and Navigation
   - Project setup
   - Basic room with walkable areas
   - Player character movement
   - Navigation in shipping district

2. **Iteration 2**: NPC Framework and Suspicion System
   - Basic NPCs with interactive capabilities
   - Suspicion system as a core gameplay mechanic
   - Visual style guide application
   - Placeholder art generation

3. **Iteration 3**: Game Districts and Time Management
   - Multiple station districts with transitions
   - Detailed time management system (Persona-style)
   - Day/night cycle and time progression
   - Random NPC assimilation tied to time

4. **Iteration 4**: Investigation Mechanics
   - Quest log system
   - Item/inventory system for evidence collection
   - Puzzles for accessing restricted areas
   - System for logging known assimilated NPCs

## Development Guide

## Git Divergent Branch Resolution

When working with this project, you may encounter situations where your local branch and the remote branch have diverged. This happens when both your local repository and the remote repository have different commits that aren't present in the other.

### Using the Resolution Script

We've included a helpful script to resolve these divergent branch situations:

1. Navigate to the project root directory
2. Run the resolution script:
   ```bash
   ./tools/resolve-git-divergence.sh

### Core Systems

1. **Game Manager** (`src/core/game/game_manager.gd`):
   - Coordinates all game systems
   - Manages interaction between verb UI, objects, and player

2. **District System** (`src/core/districts/base_district.gd`):
   - Base class for all game areas
   - Handles walkable areas and interactive objects

3. **Player Character** (`src/characters/player/player.gd`):
   - Handles movement and animations
   - Responds to player input

4. **Interactive Objects** (`src/objects/base/interactive_object.gd`):
   - Base class for all interactive items
   - Handles interactions with verbs

5. **Verb UI** (`src/ui/verb_ui/verb_ui.gd`):
   - SCUMM-style verb selection interface
   - Handles verb selection and UI display

## License

[MIT License](LICENSE)