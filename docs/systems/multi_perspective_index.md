# Multi-Perspective Character System Documentation

## Overview

The Multi-Perspective Character System enables characters in A Silent Refraction to seamlessly adapt their appearance and movement behavior based on the visual perspective of different game districts. This system is essential for maintaining visual consistency across the game's varied environments.

## Documentation Structure

### 📘 [System Overview](multi_perspective_system.md)
Complete guide to the multi-perspective system including:
- Core components and their responsibilities
- Integration with existing systems
- Configuration files and formats
- Usage examples and best practices
- Testing and debugging information

### 🏗️ [Architecture Documentation](multi_perspective_system_architecture.md)
Technical architecture details including:
- System overview diagrams
- Data flow illustrations
- Component relationships
- Memory layout and performance characteristics
- Signal connections and dependencies

### ⚡ [Quick Reference](multi_perspective_quick_reference.md)
Fast lookup guide for common tasks:
- Quick setup steps
- Common code snippets
- Perspective type reference table
- Animation naming conventions
- Troubleshooting tips

### 📚 [API Reference](multi_perspective_api_reference.md)
Complete API documentation:
- Class and method signatures
- Parameter descriptions
- Return values and signals
- Code examples for each API

## System Components

### Core Files
- **PerspectiveType** (`src/core/perspective/perspective_type.gd`)
  - Enum definitions and utility functions
  
- **PerspectiveConfiguration** (`src/core/perspective/perspective_configuration.gd`)
  - Configuration data structure
  
- **CharacterPerspectiveController** (`src/characters/perspective/character_perspective_controller.gd`)
  - Main controller component

### Configuration Files
- `src/data/perspective_configs/isometric_config.json`
- `src/data/perspective_configs/side_scrolling_config.json`
- `src/data/perspective_configs/top_down_config.json`

### Test Files
- `src/unit_tests/perspective_type_test.gd`
- `src/unit_tests/character_perspective_controller_test.gd`
- `src/component_tests/perspective_district_component_test.gd`

## Quick Start

1. **Add PerspectiveController to your character scene**
2. **Attach it in _ready():**
   ```gdscript
   perspective_controller.attach_to_character(self)
   ```
3. **Set perspective based on district:**
   ```gdscript
   perspective_controller.set_perspective(district.perspective_type)
   ```
4. **Use for movement and animations:**
   ```gdscript
   var direction = perspective_controller.convert_movement_to_direction(move_vector)
   perspective_controller.play_animation("walk", direction)
   ```

## Key Features

- **Three Perspective Types**: Isometric (8-way), Side-scrolling (2-way), Top-down (4-way)
- **Automatic Animation Management**: Perspective-specific animation prefixes with fallback support
- **Configuration System**: JSON-based configuration for easy customization
- **Signal-Based Communication**: Clean integration with existing game systems
- **Performance Optimized**: Cached configurations and minimal runtime allocations

## Integration Points

- **District System**: Districts specify their perspective type
- **Animation System**: Automatic perspective-based animation selection
- **Movement System**: Direction conversion based on current perspective
- **Camera System**: Perspective-aware zoom and positioning
- **Save System**: Perspective state persistence

## Testing

Run all perspective-related tests:
```bash
# Unit tests
./tools/run_unit_tests.sh perspective_type_test character_perspective_controller_test

# Component tests
./tools/run_component_tests.sh perspective_district_component_test
```

## Future Extensions

The system is designed for easy extension:
- Add new perspective types by extending PerspectiveType
- Create custom configurations for special districts
- Override controller behavior for unique characters
- Integrate with additional game systems as needed

## Related Documentation

- [Multi-Perspective Character System Plan](../../design/multi_perspective_character_system_plan.md) - Original design document
- [Point and Click Navigation](../point_and_click_navigation_refactoring_plan.md) - Related navigation system
- [Animation System](../animation_system.md) - Animation framework integration

## Maintenance Notes

When updating the multi-perspective system:
1. Run all tests to ensure compatibility
2. Update relevant documentation sections
3. Consider impact on existing districts and characters
4. Test save/load functionality with perspective changes
5. Verify animation naming conventions are maintained

---

*Last updated: Task 13 implementation (Iteration 3)*