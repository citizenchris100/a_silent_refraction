# A Silent Refraction: Architectural Statement of Purpose
**Status: 📚 REFERENCE**

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
- **Debug System**: Tools for development, testing, and troubleshooting

## State Management
NPCs utilize a state machine with the following primary states:
- **IDLE**: Default state when not interacting
- **TALKING**: Engaged in conversation with player
- **SUSPICIOUS**: Alerted by player actions
- **HOSTILE**: Actively opposing the player
- **FOLLOWING**: Accompanying the player (coalition members)

## Design Principles

### Architectural Foundations
1. **Minimal Coupling**: Systems communicate through well-defined interfaces
2. **Single Responsibility**: Each class has one primary purpose
3. **State-Driven Behavior**: Entity behavior is determined by internal state
4. **Testability**: All systems should be independently testable
5. **Scalability**: Easy addition of new NPCs, districts, and quests

### Code Organization and Quality
6. **DRY (Don't Repeat Yourself)**: Common operations are encapsulated in reusable methods to eliminate code duplication
7. **Abstraction Layers**: Clear separation between different levels of functionality (e.g., UI, logic, data)
8. **Interface Stability**: Public methods maintain backward compatibility while internal implementations can evolve
9. **Progressive Enhancement**: New functionality builds upon established patterns, ensuring consistency

### Error Handling and Debugging
10. **Structured Error Handling**: Consistent exception patterns with descriptive messages and proper context
11. **Error Traceability**: All failures produce clear, contextual error messages to facilitate quick resolution
12. **Context Preservation**: Game state is preserved appropriately when handling errors to prevent corruption

### Development Workflow
13. **Modular Testing**: Components can be tested in isolation with minimal dependencies
14. **Debug-Friendly Design**: Systems provide tools and interfaces for runtime inspection and manipulation
15. **Self-Documentation**: Code uses consistent naming conventions and patterns to aid understanding

### Visual Correctness and User Experience
16. **Visual Correctness Priority**: When architectural purity conflicts with proper visual display, visual correctness takes precedence
17. **Hybrid Architecture Pattern**: Systems may use sophisticated algorithms for validation/testing while overriding for visual requirements
18. **User Experience First**: Player-visible behavior (proper rendering, smooth gameplay) overrides internal architectural elegance when they conflict

## Implementation Guidelines

When implementing or modifying game components:

- Use standardized error handling with appropriate error messages visible in both development and user contexts
- Leverage existing helper methods instead of creating duplicate functionality
- Signal important state changes to dependent systems through the event system
- Follow consistent naming conventions and coding patterns
- Minimize method complexity through small, focused functions
- Add appropriate documentation for public interfaces
- Maintain backward compatibility when modifying existing features
- Implement debug visualizations and tools for complex systems

### Visual Correctness Implementation Pattern

When architectural improvements conflict with visual display requirements:

1. **Acknowledge the Conflict**: Document when "architecturally pure" solutions produce wrong visual results
2. **Implement Hybrid Solutions**: Use sophisticated algorithms for validation/testing, override for visual correctness
3. **Document Overrides Clearly**: Explain why visual requirements necessitate architectural compromises
4. **Test Both Aspects**: Verify both architectural correctness (unit tests) AND visual behavior (integration tests)
5. **Prevent Regression**: Document visual requirements to prevent future "improvements" from breaking display

### Example: Background Scaling vs Bounds Validation

```gdscript
// Default: Use viewport-aware bounds for validation/testing
camera_bounds = calculate_viewport_aware_bounds()

// Visual override: Background scaling requires full bounds access
if background_scaling_active:
    camera_bounds = Rect2(0, 0, scaled_background_size.x, scaled_background_size.y)
    // Override necessary for proper visual display - prevents grey bars
```

**Rationale**: Sophisticated bounds validation is excellent for coordinate validation and testing, but background scaling needs full background access to prevent visual artifacts. Visual correctness wins.

## File Organization
```
- src/
  - core/        # Core game managers and systems
  - characters/  # Player and NPC implementations
  - districts/   # Game locations
  - ui/          # User interface elements
  - objects/     # Interactive objects
  - quests/      # Quest definitions and tracking
  - debug/       # Development and testing tools
```

This architecture supports the game's central mechanics of investigation, suspicion, and 
coalition-building while maintaining a clean, maintainable codebase. The principles and guidelines
ensure consistency, stability, and extensibility as the project evolves.