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
- **Platform**: Cross-platform (developed on Linux Mint)
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

### Linux Setup

#### Prerequisites

- [Godot 3.5.2](https://godotengine.org/download/archive/) (Standard version, not Mono)
- Linux is recommended (developed on Linux Mint)
- Command line tools for development

#### Installation

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
bash# Using the Godot binary directly
~/godot/Godot_v3.5.2-stable_x11.64 --path /path/to/a_silent_refraction

# Or if you set up the symlink
godot --path /path/to/a_silent_refraction

Open in Editor (if needed):
bash# Launch Godot editor with the project
~/godot/Godot_v3.5.2-stable_x11.64 -e --path /path/to/a_silent_refraction


Windows Setup
Prerequisites

Godot 3.5.2 (Standard version, not Mono)
Git Bash for command line operations
ImageMagick for image processing scripts

Installation

Install Godot 3.5.2:
bash# Create a directory for Godot
mkdir -p ~/godot

# Download Godot 3.5.2
cd ~/godot
curl -L -o godot.zip https://github.com/godotengine/godot/releases/download/3.5.2-stable/Godot_v3.5.2-stable_win64.exe.zip

# Extract the executable
unzip godot.zip

# Optional: Create a shortcut for easier access
mkdir -p ~/bin
echo '#!/bin/bash
~/godot/Godot_v3.5.2-stable_win64.exe "$@"' > ~/bin/godot
chmod +x ~/bin/godot

# Add to PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

Install ImageMagick (required for development scripts):
bash# Create a temporary directory
mkdir -p ~/temp
cd ~/temp

# Download the installer
curl -L -o imagemagick-installer.exe https://imagemagick.org/archive/binaries/ImageMagick-7.1.1-25-Q16-HDRI-x64-dll.exe

# Run the installer
./imagemagick-installer.exe

# Verify installation
convert --version

Clone the Repository:
bashgit clone https://github.com/yourusername/a_silent_refraction.git
cd a_silent_refraction

Make Scripts Executable:
bash# Ensure all scripts have proper permissions
find ./tools -name "*.sh" -exec chmod +x {} \;

Run the Game:
bash# Using the Godot binary directly
~/godot/Godot_v3.5.2-stable_win64.exe --path .

# Or if you set up the godot shortcut
godot --path .

Open in Editor (if needed):
bash# Launch Godot editor with the project
godot -e --path .


Windows-Specific Notes

Git is configured to handle line endings correctly with git config core.autocrlf input
Some bash scripts may need adjustment if they use Linux-specific commands not available in Git Bash
The project structure and paths should work cross-platform without modifications

Development Guide
Core Systems

Game Manager (src/core/game/game_manager.gd):

Coordinates all game systems
Manages interaction between verb UI, objects, and player


District System (src/core/districts/base_district.gd):

Base class for all game areas
Handles walkable areas and interactive objects


Player Character (src/characters/player/player.gd):

Handles movement and animations
Responds to player input


Interactive Objects (src/objects/base/interactive_object.gd):

Base class for all interactive items
Handles interactions with verbs


Verb UI (src/ui/verb_ui/verb_ui.gd):

SCUMM-style verb selection interface
Handles verb selection and UI display



Adding New Content

Creating a New District:
bash# Create necessary files
mkdir -p src/districts/new_district_name
touch src/districts/new_district_name/new_district_name.gd
touch src/districts/new_district_name/new_district_name.tscn

Adding Interactive Objects:
bash# Create object files
mkdir -p src/objects/category_name
touch src/objects/category_name/object_name.gd
touch src/objects/category_name/object_name.tscn


Current State (Iteration 1)
The project has completed Iteration 1, which includes:

Basic project structure and architecture
Shipping District implementation with walkable areas
Player character with point-and-click movement
SCUMM-style verb interface
Basic interaction system for objects

Roadmap
Iteration 2

Implement basic NPCs with suspicion system
Add dialog interactions
Create observation mechanics

Iteration 3

Add additional districts
Implement time management
Create district navigation

Iteration 4

Add investigation mechanics
Implement puzzles
Create evidence collection system

Iteration 5

Implement coalition building mechanics
Add risk/reward for information sharing

License
[To be determined]