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

Clone the Repository:
bashgit clone https://github.com/yourusername/a_silent_refraction.git
cd a_silent_refraction

Run the Game:
bash# Using the provided script
./a_silent_refraction.sh run

# Or to run the NPC test scene specifically
./a_silent_refraction.sh test


Game Management Script
The project includes a management script (a_silent_refraction.sh) to streamline development:
bash# Show available commands
./a_silent_refraction.sh help

# Run the main game
./a_silent_refraction.sh run

# Run the NPC test scene
./a_silent_refraction.sh test

# Clean up redundant files
./a_silent_refraction.sh clean

# Check project for errors
./a_silent_refraction.sh check

# Create a new NPC
./a_silent_refraction.sh new-npc <npc_name>

# Create a new district
./a_silent_refraction.sh new-district <district_name>
NPC Framework
The game features a robust NPC system with:

State Machine: NPCs transition between states (IDLE, TALKING, SUSPICIOUS, etc.)
Dialog System: Tree-based conversations with player choice and consequences
Suspicion System: NPCs react to player actions with increasing suspicion

To create a new NPC, use the management script:
bash./a_silent_refraction.sh new-npc SecurityGuard
Then customize its dialog and behavior in src/characters/npc/SecurityGuard.gd.
Iteration Planning System
The project uses a custom iteration planning system via the iteration_planner.sh script to manage development tasks. This system helps track progress, organize tasks, and maintain development focus through clearly defined iterations.
Using the Iteration Planner
Make the script executable:
bashchmod +x iteration_planner.sh
Available Commands
Initialize the Planning System
bash./iteration_planner.sh init
Creates the docs directory and initializes the iteration planning system.
Create a New Iteration Plan
bash./iteration_planner.sh create <iteration_number> "<iteration_name>"
Example:
bash./iteration_planner.sh create 2 "NPC Framework and Suspicion System"
This creates a new iteration plan with predefined tasks based on the iteration number.
List Tasks for a Specific Iteration
bash./iteration_planner.sh list <iteration_number>
Example:
bash./iteration_planner.sh list 2
Update Task Status
bash./iteration_planner.sh update <iteration_number> <task_number> <status>
Where status can be: pending, in_progress, or complete
Example:
bash./iteration_planner.sh update 2 3 in_progress
This marks Task 3 in Iteration 2 as in progress.
Generate Progress Report
bash./iteration_planner.sh report
Displays a progress report across all iterations, showing completion percentages and task statuses.
Link Tasks to Code Files
bash./iteration_planner.sh link <iteration_number> <task_number> "<file_path>"
Example:
bash./iteration_planner.sh link 2 1 "src/core/npc/base_npc.gd"
This associates Task 1 in Iteration 2 with the specified code file.
Predefined Iterations
The iteration planner comes with templates for key iterations:

Iteration 1: Basic Environment and Navigation

Project setup
Basic room with walkable areas
Player character movement
Navigation in shipping district


Iteration 2: NPC Framework and Suspicion System

Basic NPCs with interactive capabilities
Suspicion system as a core gameplay mechanic
Visual style guide application
Placeholder art generation


Iteration 3: Game Districts and Time Management

Multiple station districts with transitions
Detailed time management system (Persona-style)
Day/night cycle and time progression
Random NPC assimilation tied to time


Iteration 4: Investigation Mechanics

Quest log system
Item/inventory system for evidence collection
Puzzles for accessing restricted areas
System for logging known assimilated NPCs



Development Guide
Git Divergent Branch Resolution
When working with this project, you may encounter situations where your local branch and the remote branch have diverged. This happens when both your local repository and the remote repository have different commits that aren't present in the other.
Using the Resolution Script
We've included a helpful script to resolve these divergent branch situations:

Navigate to the project root directory
Run the resolution script:
bash./tools/resolve-git-divergence.sh


Core Systems

Game Manager (src/core/game/game_manager.gd):

Coordinates all game systems
Manages interaction between verb UI, objects, and player


District System (src/core/districts/base_district.gd):

Base class for all game areas
Handles walkable areas and interactive objects


NPC System (src/characters/npc/base_npc.gd):

State machine for NPC behavior
Dialog tree management
Suspicion tracking


Dialog System (src/core/dialog/dialog_manager.gd):

Manages conversations with NPCs
Presents dialog options to player
Handles dialog UI


Player Character (src/characters/player/player.gd):

Handles movement and animations
Responds to player input


Interactive Objects (src/objects/base/interactive_object.gd):

Base class for all interactive items
Handles interactions with verbs


Verb UI (src/ui/verb_ui/verb_ui.gd):

SCUMM-style verb selection interface
Handles verb selection and UI display



License
MIT License