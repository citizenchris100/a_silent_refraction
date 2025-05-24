# Dialog System Architectural Refactoring Plan

**Status: 📋 PLAN**  
**Target: Iteration 3.5 (Post-Navigation)**

## Executive Summary

The current dialog system, while functionally complete, violates several key architectural principles outlined in `docs/reference/architecture.md`. This plan details a comprehensive refactoring to bring the system into full compliance while maintaining all existing functionality.

## Current State Analysis

### Architectural Violations Identified

1. **Tight Coupling Issues**
   - Scene tree dependency throughout the system
   - Direct method calls bypassing signal architecture
   - Brittle `_find_*` methods for component discovery

2. **Single Responsibility Violations**
   - DialogManager: UI creation + NPC management + system discovery
   - BaseNPC: Dialog data + UI logic + state + system coordination
   - GameManager: Dialog flow + input management + scene coordination

3. **Poor Error Handling**
   - Silent failures without structured error reporting
   - No fallback mechanisms for missing components
   - Inconsistent error context preservation

4. **Testing Impediments**
   - Hard scene tree dependencies
   - No dependency injection
   - Monolithic component design

## Refactoring Strategy

### Phase 1: Service Abstraction and Dependency Injection

**Goal**: Remove scene tree dependencies and establish proper service interfaces.

#### 1.1 Create Dialog Service Interface
```gdscript
# src/core/dialog/interfaces/IDialogService.gd
class_name IDialogService
extends Reference

# Abstract interface for dialog services
func show_dialog(npc_data: DialogData) -> void:
    pass

func hide_dialog() -> void:
    pass

func is_dialog_active() -> bool:
    pass

# Signals
signal dialog_started(npc_data)
signal dialog_ended(npc_data)
signal option_selected(option_index, npc_data)
```

#### 1.2 Create Service Registry Pattern
```gdscript
# src/core/services/ServiceRegistry.gd
class_name ServiceRegistry
extends Node

# Singleton service registry for dependency injection
var _services = {}

func register_service(service_name: String, service_instance) -> void:
    _services[service_name] = service_instance

func get_service(service_name: String):
    return _services.get(service_name)

func has_service(service_name: String) -> bool:
    return _services.has(service_name)
```

#### 1.3 Refactor DialogManager as Service Implementation
```gdscript
# src/core/dialog/DialogService.gd
class_name DialogService
extends Node
implements IDialogService

# Clean service implementation with no scene tree dependencies
var _ui_factory: IUIFactory
var _current_dialog_data: DialogData

func _init(ui_factory: IUIFactory):
    _ui_factory = ui_factory

func show_dialog(npc_data: DialogData) -> void:
    _current_dialog_data = npc_data
    _ui_factory.create_dialog_ui(npc_data)
    emit_signal("dialog_started", npc_data)
```

### Phase 2: Component Separation and Interface Design

**Goal**: Separate concerns and establish clean interfaces between components.

#### 2.1 Extract Dialog Data Layer
```gdscript
# src/core/dialog/data/DialogData.gd
class_name DialogData
extends Resource

export var npc_id: String
export var npc_name: String
export var current_node: String
export var dialog_tree: Dictionary
export var suspicion_level: float
export var is_assimilated: bool

func get_current_dialog_node() -> DialogNode:
    # Pure data access with no side effects
    
func apply_assimilation_transform(text: String) -> String:
    # Pure function for text transformation
```

#### 2.2 Create Dialog UI Factory
```gdscript
# src/core/dialog/ui/DialogUIFactory.gd
class_name DialogUIFactory
extends Reference
implements IUIFactory

# Responsible only for UI creation/management
func create_dialog_ui(dialog_data: DialogData) -> Control:
    # Creates UI components based on data

func update_dialog_ui(dialog_data: DialogData) -> void:
    # Updates existing UI with new data

func destroy_dialog_ui() -> void:
    # Clean UI teardown
```

#### 2.3 Refactor NPC Dialog Controller
```gdscript
# src/characters/npc/dialog/NPCDialogController.gd
class_name NPCDialogController
extends Reference

# Handles dialog logic for a single NPC
var _dialog_service: IDialogService
var _dialog_data: DialogData
var _suspicion_controller: ISuspicionController

func _init(dialog_service: IDialogService, suspicion_controller: ISuspicionController):
    _dialog_service = dialog_service
    _suspicion_controller = suspicion_controller

func start_dialog() -> void:
    _dialog_service.show_dialog(_dialog_data)

func process_option_selection(option_index: int) -> bool:
    # Pure logic processing, returns whether dialog continues
```

### Phase 3: State Management and Serialization

**Goal**: Refactor dialog progress tracking to support clean serialization.

#### 3.1 Dialog Progress Tracker
```gdscript
# src/core/dialog/state/DialogProgressTracker.gd
class_name DialogProgressTracker
extends Reference

# Track dialog progress per NPC
var npc_dialog_states: Dictionary = {}  # {npc_id: DialogState}

class DialogState:
    var current_node: String = "root"
    var visited_nodes: Array = []
    var chosen_options: Dictionary = {}  # {node_id: [chosen_indices]}
    var flags: Dictionary = {}  # Custom dialog flags
    
func get_save_data() -> Dictionary:
    # Clean data structure for serialization
    var data = {}
    for npc_id in npc_dialog_states:
        var state = npc_dialog_states[npc_id]
        data[npc_id] = {
            "node": state.current_node,
            "visited": state.visited_nodes,
            "choices": state.chosen_options,
            "flags": state.flags
        }
    return data

func load_save_data(data: Dictionary) -> void:
    npc_dialog_states.clear()
    for npc_id in data:
        var state = DialogState.new()
        state.current_node = data[npc_id].node
        state.visited_nodes = data[npc_id].visited
        state.chosen_options = data[npc_id].choices
        state.flags = data[npc_id].flags
        npc_dialog_states[npc_id] = state
```

#### 3.2 Serialization Integration

Following the modular serialization architecture from `docs/design/modular_serialization_architecture.md`, the dialog system implements its own serializer that handles all dialog-related persistent state:

```gdscript
# src/core/serializers/dialog_serializer.gd
extends BaseSerializer

class_name DialogSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("dialog", self, 30)

func serialize() -> Dictionary:
    return {
        "progress": DialogProgressTracker.get_save_data(),
        "active_dialog": get_active_dialog_state(),
        "suspicion_changes": get_recent_suspicion_changes()
    }

func deserialize(data: Dictionary) -> void:
    DialogProgressTracker.load_save_data(data.progress)
    restore_active_dialog(data.active_dialog)
    apply_suspicion_changes(data.suspicion_changes)

func get_version() -> int:
    return 1

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    # Handle future dialog system upgrades
    return data
```

This approach ensures dialog state persists correctly across save/load cycles while maintaining clean separation between the dialog system and save system. The refactored DialogProgressTracker provides clean data structures that are easy to serialize, avoiding the pitfalls of trying to serialize complex node references or UI state.

### Phase 4: Signal-Based Communication Architecture

**Goal**: Replace direct method calls with proper signal-driven communication.

#### 4.1 Dialog Event System
```gdscript
# src/core/dialog/events/DialogEventBus.gd
class_name DialogEventBus
extends Node

# Central event coordination for dialog system
signal dialog_requested(npc_id: String)
signal dialog_option_chosen(npc_id: String, option_index: int)
signal dialog_ended(npc_id: String)
signal suspicion_changed(npc_id: String, old_level: float, new_level: float)

# Dialog state events
signal dialog_node_changed(npc_id: String, node_id: String)
signal dialog_text_transformed(npc_id: String, original_text: String, transformed_text: String)
```

#### 4.2 Refactor BaseNPC Integration
```gdscript
# src/characters/npc/base_npc.gd (refactored sections)
class_name BaseNPC
extends Node2D

var _dialog_controller: NPCDialogController
var _event_bus: DialogEventBus

func _ready():
    # Dependency injection through ServiceRegistry
    var registry = ServiceRegistry.get_instance()
    var dialog_service = registry.get_service("DialogService")
    var suspicion_service = registry.get_service("SuspicionService")
    
    _dialog_controller = NPCDialogController.new(dialog_service, suspicion_service)
    _event_bus = registry.get_service("DialogEventBus")
    
    # Signal connections instead of direct calls
    _event_bus.connect("dialog_option_chosen", self, "_on_dialog_option_chosen")

func start_dialog():
    _event_bus.emit_signal("dialog_requested", npc_id)

func _on_dialog_option_chosen(requesting_npc_id: String, option_index: int):
    if requesting_npc_id == npc_id:
        _dialog_controller.process_option_selection(option_index)
```

### Phase 5: Error Handling and Validation

**Goal**: Implement structured error handling with proper context preservation.

#### 5.1 Dialog Validation System
```gdscript
# src/core/dialog/validation/DialogValidator.gd
class_name DialogValidator
extends Reference

class DialogValidationError:
    var npc_id: String
    var error_type: String
    var message: String
    var context: Dictionary

func validate_dialog_tree(dialog_tree: Dictionary, npc_id: String) -> Array:
    var errors = []
    
    # Validate tree structure
    if not dialog_tree.has("root"):
        errors.append(DialogValidationError.new("missing_root", "Dialog tree missing root node", {"npc_id": npc_id}))
    
    # Validate node references
    for node_id in dialog_tree.keys():
        errors.append_array(_validate_node(dialog_tree[node_id], node_id, npc_id))
    
    return errors

func _validate_node(node: Dictionary, node_id: String, npc_id: String) -> Array:
    var errors = []
    
    # Validate required fields
    if not node.has("text"):
        errors.append(DialogValidationError.new("missing_text", "Node missing text field", {
            "npc_id": npc_id,
            "node_id": node_id
        }))
    
    # Validate option references
    if node.has("options"):
        for option in node.options:
            if option.has("next") and not dialog_tree.has(option.next):
                errors.append(DialogValidationError.new("invalid_reference", "Option references non-existent node", {
                    "npc_id": npc_id,
                    "node_id": node_id,
                    "target": option.next
                }))
    
    return errors
```

#### 5.2 Error Context Service
```gdscript
# src/core/debug/ErrorContextService.gd
class_name ErrorContextService
extends Node

func report_dialog_error(error: DialogValidator.DialogValidationError) -> void:
    # Structured error reporting with context preservation
    var error_message = "[Dialog Error] %s: %s" % [error.error_type, error.message]
    
    # Add context information
    for key in error.context:
        error_message += "\n  %s: %s" % [key, error.context[key]]
    
    # Log to console and potentially to error file
    print_rich("[color=red]%s[/color]" % error_message)
    
    # Emit signal for error handling systems
    emit_signal("dialog_error_occurred", error)
```

### Phase 6: Testing Infrastructure

**Goal**: Enable comprehensive unit testing through dependency injection and interface abstraction.

#### 6.1 Mock Service Implementations
```gdscript
# src/test/mocks/MockDialogService.gd
class_name MockDialogService
extends Reference
implements IDialogService

var show_dialog_called: bool = false
var last_dialog_data: DialogData
var is_active: bool = false

func show_dialog(npc_data: DialogData) -> void:
    show_dialog_called = true
    last_dialog_data = npc_data
    is_active = true
    emit_signal("dialog_started", npc_data)

func hide_dialog() -> void:
    is_active = false
    emit_signal("dialog_ended", last_dialog_data)

func is_dialog_active() -> bool:
    return is_active
```

#### 6.2 Unit Test Examples
```gdscript
# src/test/unit_tests/dialog_controller_test.gd
extends "res://addons/gut/test.gd"

var mock_dialog_service: MockDialogService
var mock_suspicion_service: MockSuspicionService
var dialog_controller: NPCDialogController

func before_each():
    mock_dialog_service = MockDialogService.new()
    mock_suspicion_service = MockSuspicionService.new()
    dialog_controller = NPCDialogController.new(mock_dialog_service, mock_suspicion_service)

func test_start_dialog_calls_service():
    dialog_controller.start_dialog()
    assert_true(mock_dialog_service.show_dialog_called)

func test_process_option_with_suspicion_change():
    var initial_suspicion = 0.5
    var suspicion_change = 0.2
    
    # Set up dialog data with suspicion change
    var option_data = {"suspicion_change": suspicion_change, "next": "test_node"}
    mock_dialog_service.last_dialog_data.set_option_data(0, option_data)
    
    dialog_controller.process_option_selection(0)
    
    assert_eq(mock_suspicion_service.last_suspicion_change, suspicion_change)
```

### Phase 7: Progressive Integration

**Goal**: Gradually replace the existing system without breaking functionality.

#### 7.1 Adapter Pattern for Backward Compatibility
```gdscript
# src/core/dialog/adapters/LegacyDialogAdapter.gd
class_name LegacyDialogAdapter
extends Node

# Provides backward compatibility during transition
var _new_dialog_service: DialogService
var _legacy_dialog_manager: Node  # Reference to old DialogManager

func _init(new_service: DialogService, legacy_manager: Node):
    _new_dialog_service = new_service
    _legacy_dialog_manager = legacy_manager
    
    # Forward new signals to legacy system
    _new_dialog_service.connect("dialog_started", self, "_forward_to_legacy")

func _forward_to_legacy(dialog_data: DialogData):
    # Convert new format to legacy format during transition
    if _legacy_dialog_manager and _legacy_dialog_manager.has_method("show_dialog"):
        _legacy_dialog_manager.show_dialog(dialog_data.to_legacy_npc())
```

#### 7.2 Feature Flag System
```gdscript
# src/core/debug/FeatureFlags.gd
class_name FeatureFlags
extends Node

export var use_new_dialog_system: bool = false
export var enable_dialog_validation: bool = true
export var debug_dialog_performance: bool = false

func is_enabled(flag_name: String) -> bool:
    return get(flag_name) if has_method(flag_name) else false
```

## Implementation Timeline

### Week 1: Service Infrastructure
- [ ] Implement ServiceRegistry singleton
- [ ] Create IDialogService interface
- [ ] Create DialogService implementation
- [ ] Set up basic dependency injection

### Week 2: Component Separation  
- [ ] Extract DialogData class
- [ ] Create DialogUIFactory
- [ ] Implement NPCDialogController
- [ ] Create dialog validation system

### Week 3: Signal Architecture
- [ ] Implement DialogEventBus
- [ ] Refactor BaseNPC dialog integration
- [ ] Replace direct method calls with signals
- [ ] Add error handling services

### Week 4: Testing and Integration
- [ ] Create mock implementations
- [ ] Write comprehensive unit tests
- [ ] Implement adapter pattern for legacy support
- [ ] Progressive rollout with feature flags

### Week 5: Documentation and Cleanup
- [ ] Update system documentation
- [ ] Remove legacy code
- [ ] Performance optimization
- [ ] Final integration testing

## Success Criteria

### Architectural Compliance
- ✅ **Minimal Coupling**: Services communicate only through well-defined interfaces
- ✅ **Single Responsibility**: Each class has one clear purpose
- ✅ **Testability**: All components can be unit tested in isolation
- ✅ **Error Handling**: Structured error reporting with context preservation

### Functional Preservation
- ✅ All existing dialog functionality maintained
- ✅ Suspicion system integration preserved  
- ✅ Assimilation text transformation working
- ✅ UI behavior identical to current system

### Quality Improvements
- ✅ Unit test coverage > 90%
- ✅ Zero scene tree dependencies in core logic
- ✅ Clear separation between data, logic, and presentation
- ✅ Comprehensive error validation and reporting

## Risk Mitigation

### Technical Risks
- **Complexity**: Use adapter pattern for gradual migration
- **Performance**: Implement performance monitoring during transition
- **Regression**: Maintain comprehensive test suite throughout

### Project Risks  
- **Timeline**: Phase approach allows for partial delivery
- **Team Coordination**: Clear interfaces enable parallel development
- **Scope Creep**: Feature flags allow controlled rollout

## Post-Refactoring Benefits

1. **Maintainability**: Clear component boundaries and responsibilities
2. **Extensibility**: Easy to add new dialog features and NPC types
3. **Testability**: Comprehensive unit test coverage possible
4. **Reliability**: Structured error handling prevents silent failures
5. **Performance**: Reduced coupling enables better optimization
6. **Developer Experience**: Clear interfaces and documentation

This refactoring aligns the dialog system with the architectural principles while maintaining all existing functionality and setting the foundation for future enhancements.