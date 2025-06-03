# Iteration 4: Serialization Foundation

## Epic Description
**Phase**: 1 - MVP Foundation  
**Cohesive Goal**: "I can save and load game state"

As a developer, I need a robust serialization system that allows all game systems to save and restore their state. This foundational system will enable save/load functionality and ensure game state persistence across sessions.

## Goals
- Implement modular serialization architecture
- Create self-registering serialization system for all game components
- Establish save/load testing framework
- Document serialization patterns for future systems
- Enable compressed save file format

## Requirements

### Business Requirements
- **B1:** Create a sense of progression and urgency through time management
  - **Rationale:** Time-based gameplay creates strategic choices and replay value
  - **Success Metric:** Players report making meaningful time allocation decisions in test sessions

- **B2:** Expand game world with multiple distinct areas
  - **Rationale:** Diverse environments increase perceived game size and exploration value
  - **Success Metric:** Each district has unique visual identity and gameplay purpose

### User Requirements
- **U1:** As a player, I want to manage my time to prioritize activities
  - **User Value:** Creates strategic decision-making and consequences
  - **Acceptance Criteria:** Different actions consume varying amounts of in-game time

- **U2:** As a player, I want to explore distinct areas of the station
  - **User Value:** Provides variety and discovery
  - **Acceptance Criteria:** Each district has unique visuals, NPCs, and activities

### Technical Requirements
- **T1:** Implement modular serialization architecture
  - **Rationale:** Self-registering systems reduce coupling and maintenance burden
  - **Constraints:** Must support versioning for save compatibility

- **T2:** Use Godot's native serialization capabilities efficiently
  - **Rationale:** Leveraging engine features reduces complexity
  - **Constraints:** Must handle custom resources and node references

- **T3:** Implement save file compression
  - **Rationale:** Reduces storage requirements and improves load times
  - **Constraints:** Compression must not significantly impact save/load performance

## Tasks

### Core Serialization System
- [ ] Task 1: Create SerializationManager singleton
- [ ] Task 2: Implement ISerializable interface
- [ ] Task 3: Create self-registration system for serializable components
- [ ] Task 4: Implement save data versioning system
- [ ] Task 5: Create compressed save file format

### System Integration
- [ ] Task 6: Implement player state serialization
- [ ] Task 7: Implement NPC state serialization
- [ ] Task 8: Implement district state serialization
- [ ] Task 9: Implement game manager state serialization
- [ ] Task 10: Create serialization for time system (prep for I5)

### Testing Framework
- [ ] Task 11: Create unit tests for serialization system
- [ ] Task 12: Implement save/load integration tests
- [ ] Task 13: Create save file validation tools
- [ ] Task 14: Implement backwards compatibility tests

### Documentation
- [ ] Task 15: Document serialization architecture
- [ ] Task 16: Create serialization implementation guide
- [ ] Task 17: Document save file format specification

### Platform Support
- [ ] Task 18: Create platform abstraction layer for hardware detection
- [ ] Task 19: Implement build system for multi-platform support
- [ ] Task 20: Add platform-specific configuration system

### Inventory Serialization
- [ ] Task 21: Create InventorySerializer class
- [ ] Task 22: Implement personal inventory serialization
- [ ] Task 23: Implement barracks storage serialization
- [ ] Task 24: Add container state persistence
- [ ] Task 25: Implement loadout saving system
- [ ] Task 26: Create item instance serialization with conditions
- [ ] Task 27: Add inventory version migration support

### Multi-Perspective System
- [ ] Task 28: Create MultiPerspectiveSerializer for character perspective states

### Observation System Serialization
- [ ] Task 29: Create ObservationSerializer for observation history and discovered clues

### Performance Monitoring
- [ ] Task 30: Implement save/load performance metrics
- [ ] Task 31: Create performance target validation

### Verb System Serialization
- [ ] Task 32: Create VerbSerializer extending BaseSerializer
- [ ] Task 33: Implement VerbStateManager for state persistence
- [ ] Task 34: Add verb preference serialization (hotkeys, custom settings)

### Suspicion System Serialization Extension
- [ ] Task 35: Create SuspicionSerializerFull implementation
- [ ] Task 36: Implement suspicion network compression
- [ ] Task 37: Add migration support from MVP to full suspicion system

## User Stories

### Task 1: Create SerializationManager singleton
**User Story:** As a developer, I want a central serialization manager, so that all game systems can save and load their state through a unified interface.

**Design Reference:** `docs/design/modular_serialization_architecture.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. SerializationManager exists as autoload singleton
  2. Provides register(), save(), and load() methods
  3. Handles file I/O operations safely
  4. Includes error handling and validation
  5. Supports multiple save slots (future expansion)

**Implementation Notes:**
- Use Godot's autoload system for singleton
- Implement using GDScript for consistency
- Store saves in user://saves/ directory
- Use .save extension for save files

### Task 2: Implement ISerializable interface
**User Story:** As a developer, I want a standardized interface for serializable objects, so that I can ensure consistent save/load behavior across all game systems.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. ISerializable interface defines serialize() and deserialize() methods
  2. Interface includes get_save_version() for versioning
  3. All serializable classes implement this interface
  4. Clear documentation on implementation requirements
  5. Error handling for malformed data

**Implementation Notes:**
- Create as abstract base class in GDScript
- Include validation methods for data integrity
- Provide example implementations for common patterns
- Consider optional methods for migration between versions

### Task 3: Create self-registration system for serializable components
**User Story:** As a game system, I want to register myself for serialization automatically, so that adding new systems doesn't require modifying the save system.

**Design Reference:** `docs/design/modular_serialization_architecture.md`, `docs/design/serialization_system.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Systems can call register_serializable(self) on ready
  2. Registration handles duplicates gracefully
  3. Supports categorization by system type
  4. Maintains weak references to prevent memory leaks
  5. Provides debugging tools to list registered systems

**Implementation Notes:**
- Use weak references (weakref) to prevent circular dependencies
- Implement categories: "core", "npc", "district", "ui", "gameplay"
- Add debug command to list all registered systems
- Consider using signals for registration events

### Task 4: Implement save data versioning system
**User Story:** As a developer, I want save files to include version information, so that I can maintain backwards compatibility and migrate old saves when the game updates.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T2, T3
- **Acceptance Criteria:**
  1. Each save file includes game version and save format version
  2. System detects version mismatches on load
  3. Supports migration scripts for version upgrades
  4. Warns players about incompatible saves
  5. Maintains version history documentation

**Implementation Notes:**
- Store version in save file header
- Create migration framework for future updates
- Log version changes for debugging
- Consider semantic versioning for save format

### Task 5: Create compressed save file format with validation
**User Story:** As a player, I want my save files to be small, load quickly, and be protected against corruption, so that I don't waste disk space or time and my progress is safe.

**Design Reference:** `docs/design/serialization_system.md`, `docs/design/save_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Save files are compressed using zlib
  2. Compression reduces file size by >50%
  3. Load time remains under 2 seconds
  4. File format includes header with version info
  5. Corruption detection via checksum
  6. Checksum calculation and validation implemented
  7. Save file header validation before decompression
  8. Corruption detection with specific error messages

**Implementation Notes:**
- Use Godot's built-in compression (File.COMPRESSION_ZSTD)
- Include metadata header before compressed data
- Implement CRC32 checksum for integrity
- Consider chunked compression for very large saves
- Reference: docs/design/save_system_design.md lines 287-288 (checksum calculation)
- Add validate_checksum() method to detect corruption
- Include save file magic number for format validation

### Task 6: Implement player state serialization
**User Story:** As a player, I want my character's position, inventory, and stats to be saved, so that I can continue my game exactly where I left off.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U1, T1
- **Acceptance Criteria:**
  1. Player position and district are saved
  2. Inventory contents persist between sessions
  3. Character stats and attributes are preserved
  4. Active quests and objectives maintained
  5. Player choices and flags saved

**Implementation Notes:**
- Implement ISerializable in player.gd
- Save inventory as item IDs and quantities
- Include timestamp of last save
- Consider delta saves for frequent autosaves

### Task 7: Implement NPC state serialization
**User Story:** As a player, I want NPCs to remember our interactions and maintain their states, so that the world feels persistent and my actions have lasting consequences.

**BaseNPC Migration Phase 1a-1c:** This task establishes the foundation for the BaseNPC template migration by adding core data structures that will be populated in later iterations.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U2, T1
- **Acceptance Criteria:**
  1. NPC positions and current activities saved
  2. Dialog state and completed conversations persist
  3. Relationship values maintained
  4. NPC schedules and routines preserved
  5. Suspicion levels and flags saved
  6. **Phase 1a:** Personality Dictionary structure added (empty default)
  7. **Phase 1b:** Basic interaction_memory Dictionary implemented
  8. **Phase 1c:** Missing signals added (interaction_finished, etc.)

**Implementation Notes:**
- Extend base_npc.gd with ISerializable
- Compress dialog history to save space
- Only save NPCs that differ from defaults
- Consider pooling similar NPC states
- **Phase 1a:** Add `export var personality: Dictionary = {}` to BaseNPC
- **Phase 1b:** Add `var interaction_memory: Dictionary = {}` for basic tracking
- **Phase 1c:** Add `signal interaction_finished(verb, result)` and other missing signals from template
- These additions ensure forward compatibility without breaking existing NPCs

### Task 8: Implement district state serialization
**User Story:** As a player, I want the game world to remember changes I've made to environments, so that my actions feel impactful and the world responds to my choices.

**Interactive Object Migration Phase 1a-1b:** This task establishes the foundation for Interactive Object persistence by adding core state management and signals.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** U2, T1
- **Acceptance Criteria:**
  1. Object positions and states in districts saved
  2. Opened/closed doors and containers persist
  3. Environmental changes maintained
  4. Spawned items and entities preserved
  5. District-specific flags and triggers saved
  6. **Phase 1a:** Interactive objects emit proper signals (interaction_completed, state_changed)
  7. **Phase 1b:** Basic state Dictionary implemented for all objects

**Implementation Notes:**
- Implement in base_district.gd
- Use diff-based saving for efficiency
- Save only modified objects
- Include district visit timestamps
- **Phase 1a:** Add to interactive_object.gd:
  ```gdscript
  signal interaction_completed(verb, result)
  signal object_taken(object_id)
  signal state_changed(new_state)
  export var object_id: String = ""
  export var object_type: String = "generic"
  ```
- **Phase 1b:** Add basic state management:
  ```gdscript
  var current_state: Dictionary = {}
  func get_state() -> Dictionary
  func set_state(state: Dictionary)
  ```
- **BaseDistrict Phase 2a-2b:** Add sub-location support:
  ```gdscript
  var sub_locations: Dictionary = {}
  var current_sub_location: String = "main"
  func transition_to_sub_location(name: String, entry: String)
  ```

### Task 9: Implement game manager state serialization
**User Story:** As a player, I want the overall game state including time, events, and global flags to be saved, so that the game world maintains continuity between sessions.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Game time and calendar state saved
  2. Active and completed events preserved
  3. Global flags and variables maintained
  4. Achievements and statistics tracked
  5. Difficulty settings and preferences saved

**Implementation Notes:**
- Centralize in game_manager.gd
- Include random seed for reproducibility
- Save event queue and timers
- Track play session statistics

### Task 10: Create serialization for time system (prep for I5)
**User Story:** As a developer, I want the time system to be serialization-ready, so that when we implement it in Iteration 5, save/load functionality works immediately.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T2
- **Acceptance Criteria:**
  1. Time manager implements ISerializable
  2. Current time and date saved
  3. Scheduled events preserved
  4. Time-based triggers maintained
  5. Time advancement history tracked

**Implementation Notes:**
- Create placeholder time_manager.gd
- Design for future expansion
- Include timezone/calendar support
- Consider time manipulation debugging

### Task 11: Create unit tests for serialization system
**User Story:** As a developer, I want comprehensive unit tests for the serialization system, so that I can confidently make changes without breaking save/load functionality.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Tests for each ISerializable implementation
  2. Edge case testing (empty data, corruption)
  3. Performance benchmarks included
  4. Automated test suite runs on changes
  5. Coverage report generated

**Implementation Notes:**
- Use Godot's built-in testing framework
- Mock file I/O for faster tests
- Test both individual components and integration
- Include stress tests with large data sets

### Task 12: Implement save/load integration tests
**User Story:** As a QA tester, I want integration tests that verify the entire save/load process, so that I can ensure all systems work together correctly.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Full game state save/load cycle tests
  2. Cross-system dependency validation
  3. Multi-save slot testing
  4. Concurrent save/load protection
  5. UI integration verification

**Implementation Notes:**
- Create test scenarios for common gameplay
- Verify no data loss in save/load cycles
- Test interruption handling
- Validate save file permissions

### Task 13: Create save file validation tools
**User Story:** As a developer, I want tools to validate and repair save files, so that I can help players recover from corrupted saves and debug issues.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Command-line save file validator
  2. Automatic corruption detection
  3. Basic repair functionality
  4. Save file statistics viewer
  5. Format conversion utilities

**Implementation Notes:**
- Create standalone validation script
- Include in development builds
- Log validation results
- Provide player-friendly error messages

### Task 14: Implement backwards compatibility tests
**User Story:** As a player, I want my old save files to work with new game versions, so that I don't lose progress when the game updates.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T2, T3
- **Acceptance Criteria:**
  1. Test suite for version migration
  2. Sample saves from each version
  3. Automated compatibility checking
  4. Migration success metrics
  5. Rollback capability testing

**Implementation Notes:**
- Maintain library of test saves
- Test each migration path
- Verify no data loss in upgrades
- Document breaking changes

### Task 15: Document serialization architecture
**User Story:** As a developer, I want clear documentation of the serialization architecture, so that I can understand and extend the system effectively.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Architecture diagrams created
  2. Component relationships documented
  3. Data flow clearly explained
  4. Design decisions justified
  5. Extension points identified

**Implementation Notes:**
- Use Mermaid diagrams for architecture
- Include code examples
- Document patterns and anti-patterns
- Create troubleshooting guide

### Task 16: Create serialization implementation guide
**User Story:** As a developer, I want a step-by-step guide for implementing serialization in new systems, so that I can quickly add save support to new features.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Step-by-step implementation tutorial
  2. Code templates provided
  3. Common pitfalls explained
  4. Best practices documented
  5. Example implementations included

**Implementation Notes:**
- Create template files
- Include checklist for new systems
- Provide debugging tips
- Link to architecture documentation

### Task 17: Document save file format specification
**User Story:** As a developer, I want detailed documentation of the save file format, so that I can debug issues and potentially create external tools.

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Binary format fully specified
  2. Header structure documented
  3. Compression details explained
  4. Version differences tracked
  5. Example hex dumps provided

**Implementation Notes:**
- Create format specification document
- Include byte-level layout
- Document endianness and encoding
- Provide parsing examples

### Task 18: Create platform abstraction layer with save directory management
**User Story:** As a developer, I want a platform abstraction layer that detects hardware platforms and manages platform-specific save directories, so that saves work correctly across different operating systems and hardware.

**Design Reference:** `docs/design/save_system_design.md`

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Multi-Platform Support
- **Acceptance Criteria:**
  1. Runtime detection of hardware platform
  2. Platform-specific feature flags
  3. Fallback for unknown platforms
  4. Platform info accessible to all systems
  5. No performance overhead from detection
  6. Platform-specific save directory resolution
  7. File permission handling per platform
  8. Cloud save preparation hooks for future expansion

**Implementation Notes:**
- Check /proc/cpuinfo and device tree
- Create PlatformManager singleton
- Support x86_64, ARM64 (Pi 5), ARM64 (Orange Pi)
- Cache platform info after first detection
- Reference: docs/design/save_system_design.md lines 453-481 (platform-specific save paths)
- Implement get_save_directory() with platform detection
- Handle Windows, Linux, macOS save locations correctly
- Set appropriate file permissions (700 on Unix systems)

### Task 19: Implement build system for multi-platform support
**User Story:** As a developer, I want a unified build system that can produce optimized binaries for both Raspberry Pi 5 and Orange Pi 5 Plus from a single codebase, so that I can maintain one codebase while supporting multiple hardware targets.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Build System Enhancements
- **Acceptance Criteria:**
  1. Single command builds all platform targets
  2. Platform-specific optimizations applied
  3. Docker-based build environment
  4. Automated dependency management
  5. Build artifacts properly organized

**Implementation Notes:**
- Extend existing build scripts
- Add cross-compilation toolchains
- Create Docker containers for each target
- Implement build caching for faster rebuilds

### Task 20: Add platform-specific configuration system
**User Story:** As a developer, I want platform-specific configuration files that automatically load based on detected hardware, so that each platform can have optimized settings without code changes.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Platform Abstraction Layer
- **Acceptance Criteria:**
  1. Config files per platform (pi5.cfg, orangepi5.cfg, default.cfg)
  2. Automatic config selection on startup
  3. Override mechanism for testing
  4. Performance profiles included
  5. Config validation and error handling

**Implementation Notes:**
- Store configs in res://config/platforms/
- Include GPU settings, memory limits, quality presets
- Support hot-reloading for development
- Log which config is loaded

### Task 21: Create InventorySerializer class
**User Story:** As a player, I want my inventory to save and load correctly, so that all my collected items persist between game sessions.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. InventorySerializer extends BaseSerializer
  2. Self-registers with SaveManager at priority 35
  3. Serializes personal and barracks inventories
  4. Handles item instance data correctly
  5. Supports version migration

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 538-618 (Serialization section)
- Reference: docs/design/modular_serialization_architecture.md (BaseSerializer pattern)
- Implement get_version() returning 1
- Use compact format for item data
- Handle both inventory types in one serializer

### Task 22: Implement personal inventory serialization
**User Story:** As a player, I want my on-person inventory to save exactly as I left it, so that I can continue playing without losing any items I'm carrying.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. All personal inventory slots saved
  2. Item quantities preserved correctly
  3. Item conditions (degradation) saved
  4. Custom data per item maintained
  5. Slot positions preserved

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 567-586 (_serialize_personal_inventory method)
- Reference: docs/design/serialization_system.md (compression strategies)
- Use abbreviated keys for space efficiency
- Only save non-default values
- Preserve exact slot arrangement

### Task 23: Implement barracks storage serialization
**User Story:** As a player, I want my barracks storage to persist between sessions, so that my stored items remain safe even when I'm not playing.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. All barracks items saved with quantities
  2. Storage access state preserved
  3. Locked/unlocked status maintained
  4. Simple id:quantity format used
  5. Handles large storage efficiently

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 587-589 (_serialize_barracks_storage method)
- Reference: docs/design/barracks_system_design.md (storage access mechanics)
- Barracks uses simpler format than personal
- Track has_barracks_access boolean
- Consider compression for large storages

### Task 24: Add container state persistence
**User Story:** As a player, I want containers I've searched to remain empty and locked containers to stay locked, so that the world feels persistent and my actions have lasting effects.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Container searched states saved
  2. Container contents preserved
  3. Locked/unlocked states maintained
  4. Per-district container tracking
  5. Minimal save file impact

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 617-618 (_deserialize_world_containers)
- Reference: docs/design/template_interactive_object_design.md (container state persistence)
- Only save modified containers
- Use container IDs for tracking
- Integrate with district serialization

### Task 25: Implement loadout saving system
**User Story:** As a player, I want to save my preferred item loadouts, so that I can quickly switch between different equipment sets for different situations.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Named loadouts saved correctly
  2. Loadout contents preserved
  3. Multiple loadouts supported
  4. Quick swap functionality maintained
  5. Loadout names persist

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 441-463 (loadout system)
- Reference: docs/design/barracks_system_design.md (barracks access requirements)
- Store as name: Array of item_ids
- Maximum 5 loadouts initially
- Must be at barracks to load

### Task 26: Create item instance serialization with conditions
**User Story:** As a player, I want item conditions like wear and special states to be saved, so that my degraded tools and modified items maintain their properties.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Item condition values saved (0.0-1.0)
  2. Custom item data preserved
  3. Quest item states maintained
  4. Disguise equipped status saved
  5. Evidence chain data preserved

**Implementation Notes:**
- Reference: docs/design/inventory_system_design.md lines 205-209 (ItemInstance class)
- Reference: docs/design/template_quest_design.md (quest item states)
- ItemInstance class properties
- Only save non-default conditions
- Support arbitrary custom_data Dictionary

### Task 27: Add inventory version migration support
**User Story:** As a developer, I want inventory saves to migrate gracefully between versions, so that players don't lose items when we update the inventory system.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** T2, T3
- **Acceptance Criteria:**
  1. Version number tracked in saves
  2. Migration paths defined
  3. Item ID changes handled
  4. New properties get defaults
  5. No data loss during migration

**Implementation Notes:**
- Reference: docs/design/modular_serialization_architecture.md (version migration)
- Reference: docs/design/serialization_system.md (migration strategies)
- Start at version 1
- Create migration functions for each version jump
- Log all migrations performed
- Test with sample save files

## Testing Criteria
- SerializationManager successfully saves and loads game state
- All registered systems persist their data correctly
- Save files are compressed and validate properly
- Backwards compatibility is maintained
- Performance targets are met (save <1s, load <2s)
- Save system handles errors gracefully
- Unit tests achieve >90% coverage
- Inventory items persist correctly between sessions
- Item conditions and custom data save/load properly
- Container states maintain across saves
- Loadout system saves and restores correctly
- Inventory migration handles version changes
- Save file corruption detection works correctly
- Platform-specific save directories function properly
- Performance metrics track and validate targets
- Checksum validation prevents data corruption

## Timeline
- Start date: TBD
- Target completion: 2 weeks from start
- Critical for: Iteration 5 (Time System) and Iteration 7 (Save/Sleep)

## Dependencies
- Iteration 2: NPC Framework (need base classes to serialize)
- Iteration 3: Navigation System (completed - provides stable systems to test with)

## Code Links
- src/core/serialization/serialization_manager.gd (to be created)
- src/core/serialization/iserializable.gd (to be created)
- src/core/serializers/inventory_serializer.gd (to be created)
- docs/design/modular_serialization_architecture.md
- docs/design/serialization_system.md
- docs/design/inventory_system_design.md

### Task 28: Create MultiPerspectiveSerializer for character perspective states
**User Story:** As a player, I want character perspective states to persist across save/load cycles, so that characters maintain their correct appearance when loading a save and I don't experience jarring visual transitions.

**Design Reference:** `docs/design/multi_perspective_character_system_plan.md` lines 253-320

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. MultiPerspectiveSerializer extends BaseSerializer
  2. Registers with SaveManager at priority 40
  3. Saves current perspective type per character
  4. Preserves facing direction and animation state
  5. Handles district perspective overrides
  6. Restores character appearance correctly on load

**Implementation Notes:**
- Reference the save system design in multi_perspective_character_system_plan.md
- Serialize current_perspective, facing_direction, animation_state
- Include custom perspective overrides if any
- Use differential saving (only save non-default values)
- Integrate with character controller from Iteration 3

### Task 29: Create ObservationSerializer for observation history and discovered clues
**User Story:** As a player, I want my observation progress and discovered clues to persist across save/load cycles, so that my investigative progress is never lost and pattern analysis can continue between sessions.

**Design Reference:** `docs/design/observation_system_full_design.md` lines 977-1061

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. ObservationSerializer extends BaseSerializer
  2. Registers with SaveManager at priority 35 (medium-high priority)
  3. Saves compressed observation history (last 100 observations)
  4. Preserves discovered clues and pattern analysis data
  5. Maintains observation skills and camera access levels
  6. Handles version migration for observation data format

**Implementation Notes:**
- Reference: docs/design/observation_system_full_design.md (Observation Serialization lines 977-1061)
- Compress observation history to reduce save file size
- Save only essential data: target IDs, observation types, timestamps, success status
- Preserve known_assimilated list for MVP compatibility
- Include observation skills progression and equipment bonuses
- Store captured evidence and identified patterns efficiently

### Task 30: Implement save/load performance metrics
**User Story:** As a developer, I want to measure save/load performance against defined targets, so that I can ensure the save system meets performance requirements and optimize if needed.

**Design Reference:** `docs/design/save_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Measures save time in milliseconds
  2. Measures load time in milliseconds
  3. Tracks save file size in kilobytes
  4. Calculates compression ratio
  5. Logs performance metrics for analysis
  6. Warns when targets are exceeded

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 522-548 (performance targets and measurement)
- Target save time: <1000ms, load time: <2000ms, file size: <1024KB
- Use OS.get_ticks_msec() for timing measurements
- Include metrics in debug builds
- Store metrics in development logs for analysis

### Task 31: Create performance target validation
**User Story:** As a developer, I want automated validation of save/load performance targets, so that performance regressions are caught immediately during development.

**Design Reference:** `docs/design/save_system_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Validates against defined performance targets
  2. Issues warnings for performance degradation
  3. Provides optimization recommendations
  4. Integrates with testing framework
  5. Generates performance reports

**Implementation Notes:**
- Reference: docs/design/save_system_design.md lines 522-548 (performance validation)
- Check save_time_ms, load_time_ms, file_size_kb, compression_ratio
- Push warnings for missed targets
- Include in automated test suite
- Log recommendations for optimization

### Task 32: Create VerbSerializer extending BaseSerializer
**User Story:** As a player, I want my verb UI preferences and current verb selection to persist between game sessions, so that the interface maintains my customizations and selected verb.

**Design Reference:** `docs/design/verb_ui_system_refactoring_plan.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Extends BaseSerializer interface properly
  2. Saves current verb selection
  3. Preserves user preferences (custom hotkeys, verb order)
  4. Stores UI customizations (button size, colors)
  5. Integrates with SaveManager at priority 50
  6. Handles version migration

**Implementation Notes:**
- Reference: docs/design/verb_ui_system_refactoring_plan.md (Phase 7: Serialization lines 812-868)
- Reference: docs/design/modular_serialization_architecture.md (serializer pattern)
- **Priority:** Medium (50) - UI state loads after core game state
- **Data to serialize:**
  ```gdscript
  {
    "current_verb": VerbStateManager.current_verb,
    "verb_preferences": serialize_preferences(),
    "custom_themes": serialize_custom_themes(),
    "ui_enabled": VerbUIController.is_enabled()
  }
  ```
- Self-register with SaveManager in _ready()
- Handle missing data gracefully on load

### Task 33: Implement VerbStateManager for state persistence
**User Story:** As a developer, I want a dedicated state manager for the verb system, so that all verb-related state is centralized and easily serializable.

**Design Reference:** `docs/design/verb_ui_system_refactoring_plan.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Manages current verb selection
  2. Tracks verb usage history
  3. Stores custom user settings
  4. Provides clean API for state queries
  5. Supports state change notifications
  6. Integrates with VerbSerializer

**Implementation Notes:**
- Reference: docs/design/verb_ui_system_refactoring_plan.md (Phase 7: VerbStateManager lines 789-811)
- **State tracking:**
  ```gdscript
  var current_verb: String = "Look at"
  var verb_history: Array = []  # Last N verbs used
  var custom_verb_settings: Dictionary = {}
  var verb_statistics: Dictionary = {}  # Usage tracking
  ```
- Emit signals on state changes
- Provide get_save_data() and load_save_data() methods
- Track statistics for achievement system

### Task 34: Add verb preference serialization (hotkeys, custom settings)
**User Story:** As a player, I want my custom verb hotkeys and UI preferences to be saved, so that I don't have to reconfigure them each time I play.

**Design Reference:** `docs/design/verb_ui_system_refactoring_plan.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Custom hotkey mappings persist
  2. Verb display order saves if customized
  3. Hidden/disabled verbs remembered
  4. UI theme customizations preserved
  5. Per-profile preference support
  6. Import/export preferences capability

**Implementation Notes:**
- Reference: docs/design/verb_ui_system_refactoring_plan.md (serialization preferences)
- **Preference structure:**
  ```gdscript
  {
    "hotkeys": {"Look at": "Q", "Talk to": "W", ...},
    "verb_order": ["Look at", "Talk to", "Use", ...],
    "hidden_verbs": ["Pull", "Push"],
    "theme": {"button_size": Vector2(100, 30), "selected_color": "#FFFF00"}
  }
  ```
- Store in user://verb_preferences.cfg
- Support resetting to defaults
- Validate preferences on load

### Task 35: Create SuspicionSerializerFull implementation
**User Story:** As a developer, I want a comprehensive serializer for the full suspicion system that preserves all network effects and investigation states, so that the complex suspicion dynamics persist correctly across game sessions.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T2, T3
- **Acceptance Criteria:**
  1. Serializes all MVP suspicion data for backward compatibility
  2. Saves district suspicion levels and modifiers
  3. Preserves suspicion network structures with compression
  4. Stores active investigation states and history
  5. Maintains security alert levels and flagged individuals
  6. Supports version migration from MVP to full system
  7. Efficient compression for network data and investigation history
  8. Validates data integrity on load

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 969-1056 (Advanced Serialization)
- Extends existing suspicion_serializer.gd with full system features
- Priority 15 (high importance for gameplay state preservation)
- **Network Compression:** Store only active networks with connections
- **Investigation Compression:** Limit to active investigations and last 20 player actions
- **Version Support:** Migrate from version 1 (MVP) to version 2 (full)
- **Data Structure:**
  ```gdscript
  {
    "global_level": float,
    "npc_suspicion": Dictionary,
    "district_suspicion": Dictionary,
    "district_modifiers": Dictionary,
    "security_alert": int,
    "suspicion_networks": Dictionary, // compressed
    "active_investigations": Dictionary, // compressed
    "flagged_individuals": Dictionary,
    "investigation_history": Array // last 20 events
  }
  ```

### Task 36: Implement suspicion network compression
**User Story:** As a developer, I want efficient compression of suspicion network data, so that save files remain manageable while preserving complex social relationships.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T3
- **Acceptance Criteria:**
  1. Compresses network structures to essential connections only
  2. Rebuilds networks on load with minimal data loss
  3. Maintains network integrity and social distance calculations
  4. Reduces save file size impact by 70%+ vs full network storage
  5. Supports incremental network updates for performance
  6. Validates network consistency on save/load

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 1035-1041 (_compress_networks)
- Store only networks with active connections (size > 0)
- Rebuild role-based and location-based connections from NPC data
- Compress investigation data to essential fields (investigator, suspect, reason, time, evidence count)
- Use lookup tables for common connection types
- Network validation during load to catch corruption

### Task 37: Add migration support from MVP to full suspicion system
**User Story:** As a player, I want my existing save files to continue working when the full suspicion system is implemented, so that I don't lose progress when the game updates.

**Design Reference:** `docs/design/suspicion_system_full_design.md`

**Status History:**
- **⏳ PENDING** (06/02/25)

**Requirements:**
- **Linked to:** T2
- **Acceptance Criteria:**
  1. Detects MVP save format (version 1) vs full format (version 2)
  2. Migrates existing suspicion data without loss
  3. Initializes new full system features with reasonable defaults
  4. Maintains backward compatibility for one version
  5. Provides clear migration success/failure feedback
  6. Handles corrupted migration gracefully

**Implementation Notes:**
- Reference: docs/design/suspicion_system_full_design.md lines 1017-1033 (migrate method)
- **Migration Steps:**
  1. Preserve all existing MVP data (global_level, npc_suspicion)
  2. Initialize district_suspicion from global level (0.8x multiplier)
  3. Set default district_modifiers to 1.0 for all districts
  4. Initialize empty networks and investigations
  5. Set security_alert to 0
- **Validation:** Ensure all required full system fields exist after migration
- **Fallback:** Revert to MVP mode if migration fails
- **Logging:** Track migration success rates for debugging

## Notes
- This iteration was reorganized from the original plan to establish serialization first
- Critical foundation for save/sleep system in Iteration 7
- Self-registration pattern reduces coupling and maintenance
- Consider save file encryption for future anti-cheat measures
- Suspicion system serialization enables complex social dynamics to persist