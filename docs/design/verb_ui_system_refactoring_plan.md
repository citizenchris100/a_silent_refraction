# Verb UI System Architectural Refactoring Plan

**Status: 📋 PLAN**  
**Target: Iteration 3.5 (Post-Navigation)**

## Executive Summary

The current Verb UI system, while functionally complete, violates several key architectural principles outlined in `docs/reference/architecture.md`. This plan details a comprehensive refactoring to bring the system into full compliance while maintaining all existing functionality and enabling future extensibility.

## Current State Analysis

### Architectural Violations Identified

1. **Tight Coupling Issues**
   - GameManager directly searches scene tree for VerbUI
   - Hard-coded UI path dependencies ("UI/VerbUI")
   - No interface abstractions between components

2. **Single Responsibility Violations**
   - VerbUI: UI creation + event handling + state management
   - GameManager: Verb state + UI discovery + interaction routing + dialog coordination
   - InteractionManager: Response logic + default text + verb processing

3. **Poor Error Handling**
   - Silent failures when UI components not found
   - No validation of verb-object combinations
   - Missing error context for interaction failures

4. **Testing Impediments**
   - Cannot test VerbUI without full scene tree
   - Hard dependencies prevent unit testing
   - No mock interfaces for interaction testing

5. **Mixed Abstraction Levels**
   - UI layout hardcoded with business logic
   - Response text mixed with interaction processing
   - No separation between data, logic, and presentation

## Refactoring Strategy

### Phase 1: Service Interface and Dependency Injection

**Goal**: Remove scene tree dependencies and establish proper service interfaces.

#### 1.1 Create Verb System Interface
```gdscript
# src/core/interaction/interfaces/IVerbService.gd
class_name IVerbService
extends Reference

# Abstract interface for verb interaction services
func get_available_verbs() -> Array:
    pass

func set_current_verb(verb_name: String) -> bool:
    pass

func get_current_verb() -> String:
    pass

func process_interaction(verb: String, target_object, context: InteractionContext) -> InteractionResult:
    pass

# Signals
signal verb_changed(old_verb: String, new_verb: String)
signal interaction_processed(result: InteractionResult)
```

#### 1.2 Create UI Service Interface
```gdscript
# src/ui/interfaces/IVerbUIService.gd
class_name IVerbUIService
extends Reference

# Abstract interface for verb UI services
func create_verb_ui(verbs: Array, theme: VerbUITheme) -> void:
    pass

func update_verb_selection(verb_name: String) -> void:
    pass

func set_enabled(enabled: bool) -> void:
    pass

func cleanup() -> void:
    pass

# Signals  
signal verb_button_pressed(verb_name: String)
signal ui_created()
signal ui_destroyed()
```

#### 1.3 Create Interaction Context System
```gdscript
# src/core/interaction/data/InteractionContext.gd
class_name InteractionContext
extends Resource

export var verb: String
export var target_object: Node
export var inventory_item: Node
export var player_position: Vector2
export var timestamp: int
export var metadata: Dictionary = {}

func _init(p_verb: String, p_target: Node, p_inventory: Node = null):
    verb = p_verb
    target_object = p_target
    inventory_item = p_inventory
    timestamp = OS.get_ticks_msec()
```

#### 1.4 Create Interaction Result System
```gdscript
# src/core/interaction/data/InteractionResult.gd
class_name InteractionResult
extends Resource

enum ResultType {SUCCESS, FAILURE, INVALID_VERB, INVALID_TARGET, REQUIRES_INVENTORY}

export var result_type: int = ResultType.SUCCESS
export var response_text: String = ""
export var should_move_player: bool = false
export var target_position: Vector2 = Vector2.ZERO
export var state_changes: Dictionary = {}
export var metadata: Dictionary = {}

func _init(p_type: int, p_text: String):
    result_type = p_type
    response_text = p_text
```

### Phase 2: Component Separation and Interface Design

**Goal**: Separate concerns and establish clean interfaces between components.

#### 2.1 Extract Verb Configuration System
```gdscript
# src/core/interaction/data/VerbConfiguration.gd
class_name VerbConfiguration
extends Resource

export var verb_definitions: Array = []
export var default_responses: Dictionary = {}
export var verb_aliases: Dictionary = {}

class VerbDefinition:
    extends Resource
    
    export var name: String
    export var display_name: String
    export var description: String
    export var requires_inventory: bool = false
    export var moves_player: bool = true
    export var icon_resource: Texture
    export var hotkey: String = ""
    
    func _init(p_name: String, p_display: String):
        name = p_name
        display_name = p_display

func get_verb_definition(verb_name: String) -> VerbDefinition:
    for verb_def in verb_definitions:
        if verb_def.name == verb_name:
            return verb_def
    return null

func get_default_response(verb_name: String) -> String:
    return default_responses.get(verb_name, "You can't do that.")
```

#### 2.2 Create Verb Processing Service
```gdscript
# src/core/interaction/services/VerbProcessingService.gd
class_name VerbProcessingService
extends Node
implements IVerbService

var _configuration: VerbConfiguration
var _current_verb: String = "Look at"
var _validators: Array = []
var _processors: Array = []

func _init(configuration: VerbConfiguration):
    _configuration = configuration

func get_available_verbs() -> Array:
    return _configuration.verb_definitions

func set_current_verb(verb_name: String) -> bool:
    var verb_def = _configuration.get_verb_definition(verb_name)
    if verb_def == null:
        return false
    
    var old_verb = _current_verb
    _current_verb = verb_name
    emit_signal("verb_changed", old_verb, _current_verb)
    return true

func process_interaction(verb: String, target_object, context: InteractionContext) -> InteractionResult:
    # Validate interaction
    for validator in _validators:
        var validation_result = validator.validate(context)
        if validation_result.result_type != InteractionResult.ResultType.SUCCESS:
            return validation_result
    
    # Process interaction
    for processor in _processors:
        if processor.can_handle(context):
            return processor.process(context)
    
    # Fall back to default response
    var default_text = _configuration.get_default_response(verb)
    return InteractionResult.new(InteractionResult.ResultType.SUCCESS, default_text)

func register_validator(validator: IInteractionValidator) -> void:
    _validators.append(validator)

func register_processor(processor: IInteractionProcessor) -> void:
    _processors.append(processor)
```

#### 2.3 Create UI Factory System
```gdscript
# src/ui/verb_ui/factories/VerbUIFactory.gd
class_name VerbUIFactory
extends Reference

class VerbUITheme:
    extends Resource
    
    export var button_size: Vector2 = Vector2(100, 30)
    export var button_margin: Vector2 = Vector2(10, 5)
    export var columns: int = 3
    export var font: Font
    export var normal_color: Color = Color.WHITE
    export var selected_color: Color = Color.YELLOW
    export var disabled_color: Color = Color.GRAY

func create_verb_ui(parent: Control, verbs: Array, theme: VerbUITheme) -> VerbUIController:
    var container = _create_container(parent)
    var buttons = _create_verb_buttons(container, verbs, theme)
    var controller = VerbUIController.new(container, buttons, theme)
    
    return controller

func _create_container(parent: Control) -> Control:
    var container = Control.new()
    container.name = "VerbUIContainer"
    container.anchor_left = 1.0
    container.anchor_top = 1.0
    container.anchor_right = 1.0
    container.anchor_bottom = 1.0
    parent.add_child(container)
    return container

func _create_verb_buttons(container: Control, verbs: Array, theme: VerbUITheme) -> Array:
    var buttons = []
    
    for i in range(verbs.size()):
        var verb_def = verbs[i]
        var button = _create_verb_button(verb_def, i, theme)
        container.add_child(button)
        buttons.append(button)
    
    return buttons

func _create_verb_button(verb_def: VerbConfiguration.VerbDefinition, index: int, theme: VerbUITheme) -> Button:
    var button = Button.new()
    button.text = verb_def.display_name
    button.rect_min_size = theme.button_size
    
    # Calculate position
    var row = index / theme.columns
    var col = index % theme.columns
    button.rect_position = Vector2(
        theme.button_margin.x + col * (theme.button_size.x + theme.button_margin.x),
        theme.button_margin.y + row * (theme.button_size.y + theme.button_margin.y)
    )
    
    return button
```

#### 2.4 Create UI Controller
```gdscript
# src/ui/verb_ui/controllers/VerbUIController.gd
class_name VerbUIController
extends Reference
implements IVerbUIService

var _container: Control
var _buttons: Array
var _theme: VerbUIFactory.VerbUITheme
var _current_verb: String = ""
var _enabled: bool = true

signal verb_button_pressed(verb_name: String)

func _init(container: Control, buttons: Array, theme: VerbUIFactory.VerbUITheme):
    _container = container
    _buttons = buttons
    _theme = theme
    _connect_button_signals()

func _connect_button_signals():
    for i in range(_buttons.size()):
        var button = _buttons[i]
        var verb_name = button.text
        button.connect("pressed", self, "_on_verb_button_pressed", [verb_name])

func _on_verb_button_pressed(verb_name: String):
    if not _enabled:
        return
    
    update_verb_selection(verb_name)
    emit_signal("verb_button_pressed", verb_name)

func update_verb_selection(verb_name: String) -> void:
    _current_verb = verb_name
    
    # Update button appearances
    for button in _buttons:
        if button.text == verb_name:
            button.modulate = _theme.selected_color
        else:
            button.modulate = _theme.normal_color

func set_enabled(enabled: bool) -> void:
    _enabled = enabled
    
    for button in _buttons:
        button.disabled = not enabled
        button.modulate = _theme.normal_color if enabled else _theme.disabled_color

func cleanup() -> void:
    if _container and is_instance_valid(_container):
        _container.queue_free()
    _buttons.clear()
```

### Phase 3: Interaction Processing Pipeline

**Goal**: Create a flexible, extensible interaction processing system.

#### 3.1 Interaction Validator Interface
```gdscript
# src/core/interaction/interfaces/IInteractionValidator.gd
class_name IInteractionValidator
extends Reference

# Abstract interface for interaction validation
func validate(context: InteractionContext) -> InteractionResult:
    pass

func get_priority() -> int:
    return 0  # Higher numbers = higher priority
```

#### 3.2 Built-in Validators
```gdscript
# src/core/interaction/validators/VerbExistsValidator.gd
class_name VerbExistsValidator
extends Reference
implements IInteractionValidator

var _configuration: VerbConfiguration

func _init(configuration: VerbConfiguration):
    _configuration = configuration

func validate(context: InteractionContext) -> InteractionResult:
    var verb_def = _configuration.get_verb_definition(context.verb)
    if verb_def == null:
        return InteractionResult.new(
            InteractionResult.ResultType.INVALID_VERB,
            "Unknown verb: " + context.verb
        )
    
    return InteractionResult.new(InteractionResult.ResultType.SUCCESS, "")

func get_priority() -> int:
    return 100  # High priority - check verb exists first
```

```gdscript
# src/core/interaction/validators/TargetExistsValidator.gd
class_name TargetExistsValidator
extends Reference
implements IInteractionValidator

func validate(context: InteractionContext) -> InteractionResult:
    if context.target_object == null or not is_instance_valid(context.target_object):
        return InteractionResult.new(
            InteractionResult.ResultType.INVALID_TARGET,
            "Invalid interaction target."
        )
    
    return InteractionResult.new(InteractionResult.ResultType.SUCCESS, "")

func get_priority() -> int:
    return 90  # High priority - check target exists
```

#### 3.3 Interaction Processor Interface
```gdscript
# src/core/interaction/interfaces/IInteractionProcessor.gd
class_name IInteractionProcessor
extends Reference

# Abstract interface for interaction processing
func can_handle(context: InteractionContext) -> bool:
    pass

func process(context: InteractionContext) -> InteractionResult:
    pass

func get_priority() -> int:
    return 0  # Higher numbers = higher priority
```

#### 3.4 Built-in Processors
```gdscript
# src/core/interaction/processors/NPCInteractionProcessor.gd
class_name NPCInteractionProcessor
extends Reference
implements IInteractionProcessor

func can_handle(context: InteractionContext) -> bool:
    return context.target_object.is_in_group("npc")

func process(context: InteractionContext) -> InteractionResult:
    var npc = context.target_object
    var verb = context.verb
    
    # Special handling for "Talk to" verb
    if verb == "Talk to" and npc.has_method("start_dialog"):
        var result = InteractionResult.new(
            InteractionResult.ResultType.SUCCESS,
            "Talking to " + npc.npc_name
        )
        result.should_move_player = true
        result.state_changes["start_dialog"] = true
        result.state_changes["target_npc"] = npc
        return result
    
    # Default NPC interaction
    if npc.has_method("interact"):
        var response = npc.interact(verb)
        return InteractionResult.new(InteractionResult.ResultType.SUCCESS, response)
    
    return InteractionResult.new(
        InteractionResult.ResultType.FAILURE,
        "You can't " + verb + " " + npc.npc_name
    )

func get_priority() -> int:
    return 50  # Medium priority - specific to NPCs
```

```gdscript
# src/core/interaction/processors/ObjectInteractionProcessor.gd
class_name ObjectInteractionProcessor
extends Reference
implements IInteractionProcessor

func can_handle(context: InteractionContext) -> bool:
    return context.target_object.is_in_group("interactive_object")

func process(context: InteractionContext) -> InteractionResult:
    var object = context.target_object
    var verb = context.verb
    
    if object.has_method("interact"):
        var response = object.interact(verb)
        var result = InteractionResult.new(InteractionResult.ResultType.SUCCESS, response)
        
        # Determine if player should move (most verbs except "Look at")
        result.should_move_player = (verb != "Look at")
        if result.should_move_player:
            # Calculate position near object
            var direction = (context.target_object.global_position - context.player_position).normalized()
            result.target_position = context.target_object.global_position + direction * 50
        
        return result
    
    return InteractionResult.new(
        InteractionResult.ResultType.FAILURE,
        "You can't " + verb + " that."
    )

func get_priority() -> int:
    return 10  # Lower priority - generic object handling
```

### Phase 4: Signal-Based Event System

**Goal**: Replace direct method calls with proper signal-driven communication.

#### 4.1 Verb System Event Bus
```gdscript
# src/core/interaction/events/VerbEventBus.gd
class_name VerbEventBus
extends Node

# Verb selection events
signal verb_selected(verb_name: String, timestamp: int)
signal verb_changed(old_verb: String, new_verb: String)

# Interaction events
signal interaction_requested(context: InteractionContext)
signal interaction_completed(result: InteractionResult)
signal interaction_failed(error: InteractionError)

# UI events
signal ui_created(ui_controller: VerbUIController)
signal ui_destroyed()
signal ui_enabled_changed(enabled: bool)

# State events
signal player_movement_requested(target_position: Vector2, reason: String)
signal dialog_interaction_requested(npc: Node)
signal inventory_interaction_requested(item: Node, target: Node)
```

#### 4.2 Refactored Game Integration
```gdscript
# src/core/game/VerbSystemCoordinator.gd
class_name VerbSystemCoordinator
extends Node

var _verb_service: IVerbService
var _ui_service: IVerbUIService
var _event_bus: VerbEventBus
var _service_registry: ServiceRegistry

func _ready():
    _service_registry = ServiceRegistry.get_instance()
    _setup_services()
    _connect_signals()

func _setup_services():
    # Create verb configuration
    var config = _create_default_verb_configuration()
    
    # Create and register verb service
    _verb_service = VerbProcessingService.new(config)
    _service_registry.register_service("VerbService", _verb_service)
    
    # Register built-in validators and processors
    _verb_service.register_validator(VerbExistsValidator.new(config))
    _verb_service.register_validator(TargetExistsValidator.new())
    _verb_service.register_processor(NPCInteractionProcessor.new())
    _verb_service.register_processor(ObjectInteractionProcessor.new())
    
    # Create and register UI service
    var ui_factory = VerbUIFactory.new()
    var ui_theme = _create_default_ui_theme()
    var ui_parent = _find_ui_parent()
    
    if ui_parent:
        var ui_controller = ui_factory.create_verb_ui(ui_parent, config.verb_definitions, ui_theme)
        _ui_service = ui_controller
        _service_registry.register_service("VerbUIService", _ui_service)
    
    # Create and register event bus
    _event_bus = VerbEventBus.new()
    _service_registry.register_service("VerbEventBus", _event_bus)

func _connect_signals():
    # Connect UI to verb service
    if _ui_service:
        _ui_service.connect("verb_button_pressed", self, "_on_verb_button_pressed")
    
    # Connect verb service to event bus
    _verb_service.connect("verb_changed", _event_bus, "emit_signal", ["verb_changed"])
    _verb_service.connect("interaction_processed", _event_bus, "emit_signal", ["interaction_completed"])
    
    # Connect event bus to game systems
    _event_bus.connect("interaction_requested", self, "_on_interaction_requested")
    _event_bus.connect("interaction_completed", self, "_on_interaction_completed")

func _on_verb_button_pressed(verb_name: String):
    _verb_service.set_current_verb(verb_name)
    _event_bus.emit_signal("verb_selected", verb_name, OS.get_ticks_msec())

func _on_interaction_requested(context: InteractionContext):
    var result = _verb_service.process_interaction(context.verb, context.target_object, context)
    _event_bus.emit_signal("interaction_completed", result)

func _on_interaction_completed(result: InteractionResult):
    # Handle result based on type
    match result.result_type:
        InteractionResult.ResultType.SUCCESS:
            _handle_successful_interaction(result)
        InteractionResult.ResultType.FAILURE:
            _handle_failed_interaction(result)
        _:
            _handle_other_interaction_result(result)

func _handle_successful_interaction(result: InteractionResult):
    # Update interaction text display
    var interaction_display = _service_registry.get_service("InteractionDisplayService")
    if interaction_display:
        interaction_display.show_text(result.response_text)
    
    # Handle player movement
    if result.should_move_player:
        _event_bus.emit_signal("player_movement_requested", result.target_position, "verb_interaction")
    
    # Handle state changes
    for change_type in result.state_changes:
        match change_type:
            "start_dialog":
                var npc = result.state_changes.get("target_npc")
                if npc:
                    _event_bus.emit_signal("dialog_interaction_requested", npc)
```

### Phase 5: Error Handling and Validation

**Goal**: Implement structured error handling with proper context preservation.

#### 5.1 Interaction Error System
```gdscript
# src/core/interaction/errors/InteractionError.gd
class_name InteractionError
extends Reference

enum ErrorType {
    VERB_NOT_FOUND,
    TARGET_INVALID,
    INVENTORY_REQUIRED,
    PERMISSION_DENIED,
    SYSTEM_ERROR
}

var error_type: int
var message: String
var context: InteractionContext
var timestamp: int
var metadata: Dictionary = {}

func _init(p_type: int, p_message: String, p_context: InteractionContext):
    error_type = p_type
    message = p_message
    context = p_context
    timestamp = OS.get_ticks_msec()

func to_string() -> String:
    var type_name = ErrorType.keys()[error_type]
    return "[%s] %s (Target: %s, Verb: %s)" % [
        type_name, message, 
        context.target_object.name if context.target_object else "null",
        context.verb
    ]
```

#### 5.2 Error Context Service
```gdscript
# src/core/interaction/services/InteractionErrorService.gd
class_name InteractionErrorService
extends Node

signal error_occurred(error: InteractionError)

var _error_history: Array = []
var _max_history_size: int = 100

func report_error(error: InteractionError) -> void:
    # Add to history
    _error_history.append(error)
    if _error_history.size() > _max_history_size:
        _error_history.pop_front()
    
    # Log error with context
    print_rich("[color=red][Verb System Error] %s[/color]" % error.to_string())
    
    # Emit signal for error handling systems
    emit_signal("error_occurred", error)

func get_recent_errors(count: int = 10) -> Array:
    var start_index = max(0, _error_history.size() - count)
    return _error_history.slice(start_index, _error_history.size())

func clear_error_history() -> void:
    _error_history.clear()
```

### Phase 6: Testing Infrastructure

**Goal**: Enable comprehensive unit testing through dependency injection and interface abstraction.

#### 6.1 Mock Service Implementations
```gdscript
# src/test/mocks/MockVerbService.gd
class_name MockVerbService
extends Reference
implements IVerbService

var current_verb: String = "Look at"
var available_verbs: Array = []
var last_interaction_context: InteractionContext
var mock_interaction_result: InteractionResult

func get_available_verbs() -> Array:
    return available_verbs

func set_current_verb(verb_name: String) -> bool:
    var old_verb = current_verb
    current_verb = verb_name
    emit_signal("verb_changed", old_verb, current_verb)
    return true

func get_current_verb() -> String:
    return current_verb

func process_interaction(verb: String, target_object, context: InteractionContext) -> InteractionResult:
    last_interaction_context = context
    return mock_interaction_result if mock_interaction_result else InteractionResult.new(
        InteractionResult.ResultType.SUCCESS,
        "Mock interaction with " + verb
    )
```

#### 6.2 Unit Test Examples
```gdscript
# src/test/unit_tests/verb_processing_service_test.gd
extends "res://addons/gut/test.gd"

var verb_service: VerbProcessingService
var mock_config: VerbConfiguration
var mock_validator: MockInteractionValidator
var mock_processor: MockInteractionProcessor

func before_each():
    mock_config = _create_test_configuration()
    verb_service = VerbProcessingService.new(mock_config)
    
    mock_validator = MockInteractionValidator.new()
    mock_processor = MockInteractionProcessor.new()
    
    verb_service.register_validator(mock_validator)
    verb_service.register_processor(mock_processor)

func test_set_current_verb_with_valid_verb():
    var result = verb_service.set_current_verb("Use")
    assert_true(result)
    assert_eq(verb_service.get_current_verb(), "Use")

func test_set_current_verb_with_invalid_verb():
    var result = verb_service.set_current_verb("InvalidVerb")
    assert_false(result)
    assert_eq(verb_service.get_current_verb(), "Look at")  # Should remain unchanged

func test_process_interaction_calls_validators():
    var context = InteractionContext.new("Look at", Node.new())
    verb_service.process_interaction("Look at", context.target_object, context)
    
    assert_true(mock_validator.validate_called)
    assert_eq(mock_validator.last_context, context)

func test_process_interaction_calls_processors():
    mock_processor.can_handle_return = true
    var context = InteractionContext.new("Use", Node.new())
    
    verb_service.process_interaction("Use", context.target_object, context)
    
    assert_true(mock_processor.can_handle_called)
    assert_true(mock_processor.process_called)

func _create_test_configuration() -> VerbConfiguration:
    var config = VerbConfiguration.new()
    config.verb_definitions = [
        VerbConfiguration.VerbDefinition.new("Look at", "Look at"),
        VerbConfiguration.VerbDefinition.new("Use", "Use"),
        VerbConfiguration.VerbDefinition.new("Talk to", "Talk to")
    ]
    return config
```

### Phase 7: State Management and Serialization

**Goal**: Implement clean state management to support save/load functionality.

#### 7.1 Verb State Management

```gdscript
# src/core/interaction/state/VerbStateManager.gd
class_name VerbStateManager
extends Reference

var current_verb: String = "Look at"
var verb_history: Array = []  # Last N verbs used
var custom_verb_settings: Dictionary = {}  # User preferences
var verb_statistics: Dictionary = {}  # Usage tracking

func get_save_data() -> Dictionary:
    return {
        "current_verb": current_verb,
        "verb_history": verb_history.duplicate(),
        "custom_settings": custom_verb_settings.duplicate(),
        "statistics": verb_statistics.duplicate()
    }

func load_save_data(data: Dictionary) -> void:
    current_verb = data.get("current_verb", "Look at")
    verb_history = data.get("verb_history", [])
    custom_verb_settings = data.get("custom_settings", {})
    verb_statistics = data.get("statistics", {})
```

#### 7.2 Serialization Integration

Following the modular architecture from `docs/design/modular_serialization_architecture.md`, the verb system implements its own serializer:

```gdscript
# src/core/serializers/verb_serializer.gd
extends BaseSerializer

class_name VerbSerializer

func _ready():
    # Medium priority - UI state loads after core game state
    SaveManager.register_serializer("verb_ui", self, 50)

func serialize() -> Dictionary:
    return {
        "current_verb": VerbStateManager.current_verb,
        "verb_preferences": serialize_preferences(),
        "custom_themes": serialize_custom_themes(),
        "ui_enabled": VerbUIController.is_enabled()
    }

func deserialize(data: Dictionary) -> void:
    # Restore current verb selection
    if "current_verb" in data:
        VerbService.set_current_verb(data.current_verb)
        VerbUIController.update_verb_selection(data.current_verb)
    
    # Restore user preferences
    if "verb_preferences" in data:
        restore_preferences(data.verb_preferences)
    
    # Restore custom themes
    if "custom_themes" in data:
        restore_custom_themes(data.custom_themes)
    
    # Restore UI state
    if "ui_enabled" in data:
        VerbUIController.set_enabled(data.ui_enabled)

func serialize_preferences() -> Dictionary:
    # Save any user-modified verb settings
    return {
        "hotkeys": VerbConfiguration.get_custom_hotkeys(),
        "verb_order": VerbConfiguration.get_custom_verb_order(),
        "hidden_verbs": VerbConfiguration.get_hidden_verbs()
    }

func serialize_custom_themes() -> Dictionary:
    # Save any UI customizations
    return {
        "button_size": VerbUITheme.button_size,
        "selected_color": VerbUITheme.selected_color.to_html(),
        "font_size": VerbUITheme.font_size
    }
```

This approach ensures that:
- The player's selected verb persists across saves
- Any UI customizations are preserved
- User preferences (hotkeys, verb order) are maintained
- The system remains decoupled from the core save system

### Phase 8: Progressive Integration and Migration

**Goal**: Gradually replace the existing system without breaking functionality.

#### 8.1 Adapter Pattern for Backward Compatibility
```gdscript
# src/core/interaction/adapters/LegacyVerbAdapter.gd
class_name LegacyVerbAdapter
extends Node

# Provides backward compatibility during transition
var _new_verb_service: IVerbService
var _legacy_game_manager: Node

func _init(new_service: IVerbService, legacy_manager: Node):
    _new_verb_service = new_service
    _legacy_game_manager = legacy_manager
    
    # Forward new signals to legacy system
    _new_verb_service.connect("verb_changed", self, "_forward_verb_change_to_legacy")

func _forward_verb_change_to_legacy(old_verb: String, new_verb: String):
    # Update legacy game manager's current_verb
    if _legacy_game_manager and _legacy_game_manager.has_method("_on_verb_selected"):
        _legacy_game_manager._on_verb_selected(new_verb)

func handle_legacy_object_click(object: Node, position: Vector2):
    # Convert legacy object click to new interaction system
    var context = InteractionContext.new(_new_verb_service.get_current_verb(), object)
    context.player_position = position
    
    var result = _new_verb_service.process_interaction(context.verb, context.target_object, context)
    
    # Convert result back to legacy format
    if _legacy_game_manager and _legacy_game_manager.has_method("display_interaction_result"):
        _legacy_game_manager.display_interaction_result(result.response_text)
```

#### 7.2 Feature Flag Integration
```gdscript
# src/core/debug/VerbSystemFeatureFlags.gd
class_name VerbSystemFeatureFlags
extends Node

export var use_new_verb_system: bool = false
export var enable_verb_validation: bool = true
export var debug_interaction_performance: bool = false
export var log_interaction_history: bool = false

func is_new_system_enabled() -> bool:
    return use_new_verb_system

func should_validate_verbs() -> bool:
    return enable_verb_validation

func should_debug_performance() -> bool:
    return debug_interaction_performance
```

## Implementation Timeline

### Week 1: Service Infrastructure
- [ ] Implement VerbConfiguration and VerbDefinition classes
- [ ] Create IVerbService and IVerbUIService interfaces
- [ ] Create InteractionContext and InteractionResult classes
- [ ] Set up ServiceRegistry integration

### Week 2: Component Separation
- [ ] Extract VerbProcessingService from GameManager
- [ ] Create VerbUIFactory and VerbUIController
- [ ] Implement validator and processor interfaces
- [ ] Create built-in validators and processors

### Week 3: Event System Integration
- [ ] Implement VerbEventBus
- [ ] Create VerbSystemCoordinator
- [ ] Replace direct method calls with signals
- [ ] Add error handling services

### Week 4: Testing and Validation
- [ ] Create mock implementations for all interfaces
- [ ] Write comprehensive unit tests
- [ ] Implement interaction error system
- [ ] Add interaction validation pipeline

### Week 5: Integration and Migration
- [ ] Implement adapter pattern for legacy support
- [ ] Progressive rollout with feature flags
- [ ] Performance optimization and profiling
- [ ] Documentation and cleanup

## Success Criteria

### Architectural Compliance
- ✅ **Minimal Coupling**: Services communicate only through well-defined interfaces
- ✅ **Single Responsibility**: Each class has one clear purpose
- ✅ **Testability**: All components can be unit tested in isolation
- ✅ **Error Handling**: Structured error reporting with context preservation

### Functional Preservation
- ✅ All existing verb functionality maintained
- ✅ UI behavior identical to current system
- ✅ Object interaction system preserved
- ✅ NPC integration working seamlessly

### Quality Improvements
- ✅ Unit test coverage > 90%
- ✅ Zero scene tree dependencies in core logic
- ✅ Clear separation between data, logic, and presentation
- ✅ Extensible verb definition system
- ✅ Comprehensive interaction validation

## Risk Mitigation

### Technical Risks
- **UI Integration Complexity**: Use adapter pattern for gradual UI migration
- **Performance Overhead**: Implement performance monitoring and optimization
- **Signal System Complexity**: Clear documentation and examples for signal flow

### Project Risks
- **Integration Timeline**: Phase approach allows for partial delivery
- **Backward Compatibility**: Adapter pattern ensures no functionality loss
- **Testing Coverage**: Comprehensive mocks enable thorough testing

## Post-Refactoring Benefits

1. **Extensibility**: Easy to add new verbs, validators, and processors
2. **Maintainability**: Clear component boundaries and responsibilities
3. **Testability**: Comprehensive unit test coverage for all components
4. **Reliability**: Structured error handling and validation pipeline
5. **Performance**: Reduced coupling enables better optimization
6. **Developer Experience**: Clear interfaces and configuration-driven system
7. **Customization**: Configurable verb definitions, UI themes, and interaction behaviors

## Template Compliance

### Interactive Object Template Integration
The refactored Verb UI system ensures proper integration with `template_interactive_object_design.md`:
- All verb interactions follow the standard `interact(verb, item)` interface
- Validates verb support before passing to interactive objects
- Respects object state machines for available verbs
- Integrates with visual/audio feedback from objects
- Properly handles item combination through the template interface

The system enforces:
- Consistent verb handling across all interactive objects
- Standard response patterns for unsupported verbs
- Proper state-based verb availability
- Correct item combination validation
- Integration with object serialization for verb states

This refactoring brings the Verb UI system into full compliance with the architectural principles while maintaining all existing functionality and providing a foundation for future enhancements like custom verbs, themed UIs, and advanced interaction mechanics.