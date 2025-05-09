# A Silent Refraction: Architectural Statement of Purpose

## Core Philosophy
The architecture of A Silent Refraction follows a component-based design with a focus on 
clear separation of concerns and minimal interdependencies. Each system should have a 
well-defined purpose with clean interfaces to other systems.

## Key Components

### Base Systems
- **Game Manager**: Central coordinator for game state and system communication
- **Input Manager**: Handles player input and routes to appropriate handlers
- **Dialog Manager**: Manages conversation UI and dialog flow
- **District Manager**: Handles transition between game locations

### Entity Framework
- **BaseInteractiveObject**: Foundation for all interactive elements
- **BaseNPC**: Extension with state machine for NPCs, dialog, and suspicion systems
- **Player**: Player character with movement and inventory capabilities

### Game Systems
- **Dialog System**: Tree-based conversations with options and consequences
- **Suspicion System**: Tracks NPC reactions to player choices
- **Time System**: Manages game time progression (day/night cycle)
- **Quest System**: Tracks player progress through game objectives

## State Management
NPCs utilize a state machine with the following primary states:
- **IDLE**: Default state when not interacting
- **TALKING**: Engaged in conversation with player
- **SUSPICIOUS**: Alerted by player actions
- **HOSTILE**: Actively opposing the player
- **FOLLOWING**: Accompanying the player (coalition members)

## Design Principles
1. **Minimal Coupling**: Systems communicate through well-defined interfaces
2. **Single Responsibility**: Each class has one primary purpose
3. **State-Driven Behavior**: Entity behavior is determined by internal state
4. **Testability**: All systems should be independently testable
5. **Scalability**: Easy addition of new NPCs, districts, and quests

## File Organization
```
- src/
  - core/        # Core game managers and systems
  - characters/  # Player and NPC implementations
  - districts/   # Game locations
  - ui/          # User interface elements
  - objects/     # Interactive objects
  - quests/      # Quest definitions and tracking
```

This architecture supports the game's central mechanics of investigation, suspicion, and 
coalition-building while maintaining a clean, maintainable codebase.
