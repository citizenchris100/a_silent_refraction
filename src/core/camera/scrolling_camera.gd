class_name ScrollingCamera
extends Camera2D

# Import validator classes - using string paths to avoid circular dependencies
const BoundsValidatorPath = "res://src/core/camera/bounds_validator.gd"
const DefaultBoundsValidatorPath = "res://src/core/camera/default_bounds_validator.gd"
const TestBoundsValidatorPath = "res://src/core/camera/test_bounds_validator.gd"

# ===== SCROLLING CAMERA: SIGNAL AND STATE DOCUMENTATION =====
#
# ScrollingCamera provides a comprehensive camera system with state management,
# transition events, and UI synchronization capabilities.
#
# === SIGNALS AND USAGE GUIDE ===
#
# 1. State Change Signal
#    signal camera_state_changed(new_state, old_state, transition_reason)
#    - Called when the camera changes state (IDLE, MOVING, FOLLOWING_PLAYER)
#    - Example connection:
#      camera.connect_state_listener(self, "_on_camera_state_changed")
#    - Example handler:
#      func _on_camera_state_changed(new_state, old_state, reason):
#          if new_state == ScrollingCamera.CameraState.MOVING:
#              print("Camera is now moving because: " + reason)
#
# 2. Movement Signals
#    signal camera_move_started(target_position, old_position, move_duration, transition_type)
#    - Called when camera starts moving to a new position
#    - Example connection:
#      camera.connect_move_started_listener(self, "_on_camera_move_started")
#    - Example handler:
#      func _on_camera_move_started(target, old_pos, duration, easing):
#          print("Camera moving from " + str(old_pos) + " to " + str(target))
#
#    signal camera_move_completed(final_position, initial_position, actual_duration)
#    - Called when camera completes its movement
#    - Example connection:
#      camera.connect_move_completed_listener(self, "_on_camera_move_completed")
#    - Example handler:
#      func _on_camera_move_completed(final_pos, initial_pos, duration):
#          print("Camera movement completed in " + str(duration) + " seconds")
#
# 3. Bounds Change Signal
#    signal view_bounds_changed(new_bounds, old_bounds, is_district_change)
#    - Called when camera bounds are updated, typically when entering a new district
#    - Example connection:
#      camera.connect_view_bounds_listener(self, "_on_view_bounds_changed")
#    - Example handler:
#      func _on_view_bounds_changed(new_bounds, old_bounds, is_district_change):
#          if is_district_change:
#              print("Moved to a new district with bounds: " + str(new_bounds))
#
# 4. Transition Progress Signal
#    signal camera_transition_progress(progress_percentage, position, target_position)
#    - Emitted continuously during camera movement, useful for synchronized animations
#    - Example connection:
#      camera.connect("camera_transition_progress", self, "_on_camera_progress")
#    - Example handler:
#      func _on_camera_progress(progress, pos, target):
#          $ProgressBar.value = progress * 100
#
# 5. Transition Event Point Signal
#    signal camera_transition_point_reached(point, position, progress)
#    - Emitted when camera movement reaches specific progress points (25%, 50%, 75%)
#    - Useful for triggering effects at specific moments during transitions
#    - Example connection:
#      camera.connect("camera_transition_point_reached", self, "_on_transition_point")
#    - Example handler:
#      func _on_transition_point(point, pos, progress):
#          if point == 0.5: # At 50% of transition
#              play_transition_effect()
#
# === UI SYNCHRONIZATION SYSTEM ===
#
# UI elements can be registered to automatically synchronize with camera movements.
# This is particularly useful for fade effects, parallax, and transition animations.
#
# 1. Register a UI element:
#    camera.register_ui_element(my_ui_element)
#
# 2. The UI element should implement any of these methods:
#    - sync_with_camera_movement(progress, from_pos, to_pos): Called during transitions
#    - on_camera_state_changed(new_state, old_state): Called on state changes
#    - on_camera_move_completed(): Called when movement completes
#
# 3. The UI element will be automatically unregistered when freed
#
# === TRANSITION EVENT SYSTEM ===
#
# The camera can trigger callbacks at specific points during transitions.
# Default event points are at 25%, 50%, and 75% of movement progress.
#
# 1. Register a callback:
#    camera.register_transition_callback(0.5, self, "_on_halfway")
#
# 2. Callback method:
#    func _on_halfway(point, position, progress):
#        # Trigger effect at halfway point
#        spawn_effect_at(position)
#
# 3. Custom event points:
#    camera.set_transition_event_points([0.25, 0.5, 0.75, 0.9])
#
# === INTEGRATION EXAMPLE ===
#
# # In a UI manager script:
# func _ready():
#     var camera = get_node("../ScrollingCamera")
#     
#     # Register for state changes and movement events
#     camera.connect_state_listener(self, "_on_camera_state_changed")
#     camera.connect_move_started_listener(self, "_on_camera_move_started")
#     camera.connect_move_completed_listener(self, "_on_camera_move_completed")
#     
#     # Register a UI element for automatic synchronization
#     camera.register_ui_element($FadePanel)
#     
#     # Register a callback at 50% of camera movement
#     camera.register_transition_callback(0.5, self, "_on_camera_halfway")
#     
# # Implement the callback
# func _on_camera_halfway(point, position, progress):
#     $TransitionEffect.play()
#

# Easing types enum for camera movement
enum EasingType {
    LINEAR,          # Linear interpolation (no easing)
    EASE_IN,         # Acceleration from zero velocity
    EASE_OUT,        # Deceleration to zero velocity
    EASE_IN_OUT,     # Acceleration until halfway, then deceleration
    EXPONENTIAL,     # Exponential ease-out (more aggressive at start)
    SINE,            # Sine wave-based easing (smooth)
    ELASTIC,         # Overshoot and settle (bouncy)
    CUBIC,           # Cubic easing (smooth acceleration/deceleration)
    QUAD             # Quadratic easing (gentler than cubic)
}

# Camera states enum for state tracking
enum CameraState {
    IDLE,            # Camera is not moving
    MOVING,          # Camera is transitioning between positions
    FOLLOWING_PLAYER # Camera is actively tracking player movement
}
# ScrollingCamera: Handles camera movement for larger-than-screen backgrounds

# Signals for state changes and movement events
signal camera_move_started(target_position, old_position, move_duration, transition_type)
signal camera_move_completed(final_position, initial_position, actual_duration)
signal view_bounds_changed(new_bounds, old_bounds, is_district_change)
signal camera_state_changed(new_state, old_state, transition_reason)

# Debug option for extended signal information
export var signal_debug_mode: bool = false # Enables more detailed signal information for debugging

# Camera properties
export var follow_player: bool = true
export var follow_smoothing: float = 5.0
export var edge_margin: Vector2 = Vector2(150, 100) # Distance from edge that triggers scrolling
export var bounds_enabled: bool = true setget set_bounds_enabled
export var initial_position: Vector2 = Vector2.ZERO # Initial camera position (if Vector2.ZERO, will be centered)
export var initial_view: String = "right" # Which part to show initially: "left", "right", "center"
export(EasingType) var easing_type: int = EasingType.SINE # Type of easing to use for camera movement

# State tracking
var current_camera_state: int = CameraState.IDLE
var previous_camera_state: int = CameraState.IDLE # Keep track of previous state
var target_position: Vector2 = Vector2.ZERO
var is_transition_active: bool = false
var movement_progress: float = 0.0
var movement_start_time: float = 0.0 # Time when movement started 
var transition_reason: String = "" # Why a state transition happened

# Additional signals for the transition event system
signal camera_transition_progress(progress_percentage, position, target_position)
signal camera_transition_point_reached(point, position, progress)

# World view mode flag
var world_view_mode: bool = false

# Variables
# Target player reference with proper setters/getters
var _target_player: Node2D = null

# Bounds validator for decoupled bounds validation
var _bounds_validator # Using untyped variable to avoid circular dependencies

# Test mode flag
export var test_mode: bool = false setget set_test_mode, get_test_mode

# Setter for test_mode
func set_test_mode(value: bool) -> void:
    print("Setting test_mode to: " + str(value))
    test_mode = value
    # Reinitialize the bounds validator
    _initialize_bounds_validator()

# Getter for test_mode
func get_test_mode() -> bool:
    return test_mode

# Setter for target_player with type checking and validation
func set_target_player(player: Node2D) -> void:
    print("Setting target_player to: " + str(player))
    if player == null:
        print("WARNING: Setting target_player to null")
    elif not (player is Node2D):
        push_error("ERROR: target_player must be a Node2D, got " + str(typeof(player)))
        return
        
    _target_player = player
    # Reset state if we had no player and now have one
    if player != null and current_camera_state == CameraState.IDLE:
        set_camera_state(CameraState.FOLLOWING_PLAYER, "Player target assigned")

# Getter for target_player
func get_target_player() -> Node2D:
    return _target_player
    
# Property accessor for backward compatibility    
var target_player: Node2D setget set_target_player, get_target_player
var screen_size: Vector2
var camera_bounds: Rect2
export var auto_adjust_zoom: bool = true # Whether to automatically adjust zoom to fill viewport
export var fill_viewport_height: bool = true # Whether to automatically adjust zoom to fill viewport height
export var min_zoom: float = 0.5 # Minimum zoom level (lower value = more zoomed in)
export var max_zoom: float = 1.5 # Maximum zoom level (higher value = more zoomed out)

# Listener system for managing signal connections
var _state_listeners = {}
var _move_started_listeners = {}
var _move_completed_listeners = {}
var _view_bounds_listeners = {}

# UI synchronization registry
var _ui_elements = [] # Array of registered UI elements to synchronize with camera

# Transition event system - percentage thresholds for triggering events
export var transition_event_points = [0.25, 0.5, 0.75] # Event points as percentage of movement
var _registered_transition_callbacks = {} # Dictionary of callbacks by event point
var _triggered_events = [] # Track which event points have been triggered in current transition

# Debug settings
# Internal debug draw value
var _debug_draw: bool = false

# Setter for debug_draw
func set_debug_draw(value: bool) -> void:
    print("Setting debug_draw to: " + str(value))
    _debug_draw = value
    if value and is_inside_tree():
        setup_debug_overlay()

# Getter for debug_draw
func get_debug_draw() -> bool:
    return _debug_draw
    
# Setter for bounds_enabled
func set_bounds_enabled(value: bool) -> void:
    bounds_enabled = value
    # Update bounds validator if it exists
    if _bounds_validator != null and not test_mode:
        _bounds_validator.set_bounds_enabled(value)

# Property with setter/getter
export var debug_draw: bool = false setget set_debug_draw, get_debug_draw
export var debug_camera_positioning: bool = true  # Enable camera position debug logs
export var debug_background_scaling: bool = true  # Enable background scaling debug logs
export var debug_show_transition_points: bool = true # Show transition event points during movement
export var debug_show_state_changes: bool = true # Show state change visualizations
var debug_font: Font
var debug_overlay: CanvasLayer = null
var debug_markers = {}  # Store debug visual markers
var debug_state_change_history = [] # Store recent state changes for visualization

# Store target positions for debugging
var debug_right_edge_position: Vector2 = Vector2.ZERO
var debug_calculated_position: Vector2 = Vector2.ZERO

# Enhanced debug logging function
func debug_log(category, message, step = ""):
    var step_prefix = "[Step " + str(step) + "] " if step != "" else ""
    if category == "camera" and debug_camera_positioning:
        print("[CAMERA DEBUG] " + step_prefix + message)
    elif category == "scaling" and debug_background_scaling:
        print("[SCALING DEBUG] " + step_prefix + message)
    elif category == "overlay":
        print("[OVERLAY DEBUG] " + step_prefix + message)
    elif category == "trace":
        print("[TRACE] " + step_prefix + message)

# Create a visual debug marker
func create_debug_marker(position, color = Color(1, 0, 0, 0.7), size = 10, name = "marker"):
    if not debug_overlay:
        setup_debug_overlay()
    
    # Create a unique name for the marker
    var marker_name = name + "_" + str(debug_markers.size())
    
    # Create the marker
    var marker = ColorRect.new()
    marker.color = color
    marker.rect_size = Vector2(size, size)
    marker.rect_position = world_to_screen(position) - Vector2(size/2, size/2)
    marker.name = marker_name
    
    debug_overlay.add_child(marker)
    debug_markers[marker_name] = marker
    
    debug_log("overlay", "Created marker '" + marker_name + "' at position " + str(position))
    return marker
    
# Create a temporary visual marker that fades out
func create_temporary_marker(position, color = Color(1, 1, 0, 0.8), size = 15, duration = 1.0, name = "temp_marker"):
    if not debug_overlay or not debug_draw:
        return null
        
    var marker = create_debug_marker(position, color, size, name)
    
    # Create a Tween for fade out effect
    var tween = Tween.new()
    marker.add_child(tween)
    
    # Set up the fade out animation
    tween.interpolate_property(marker, "color", color, Color(color.r, color.g, color.b, 0), 
                              duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
    tween.start()
    
    # Set up auto-removal after fade completes
    yield(tween, "tween_completed")
    if marker and is_instance_valid(marker):
        var marker_name = marker.name
        marker.queue_free()
        debug_markers.erase(marker_name)
    
    return marker

# Create a state change visualization
func create_state_change_visual(old_state, new_state, position = null):
    if not debug_draw or not debug_show_state_changes:
        return
        
    if not position:
        position = global_position
    
    # Create a color based on the state transition
    var color
    match new_state:
        CameraState.IDLE:
            color = Color(0.5, 0.5, 0.5, 0.8) # Gray for idle
        CameraState.MOVING:
            color = Color(1, 0.5, 0, 0.8) # Orange for moving
        CameraState.FOLLOWING_PLAYER:
            color = Color(0, 0.7, 1, 0.8) # Blue for following
            
    # Create a temporary marker for the state change
    var marker = create_temporary_marker(position, color, 20, 2.0, "state_change")
    
    # Add to state change history for visualization
    if marker:
        debug_state_change_history.append({
            "position": position,
            "old_state": old_state,
            "new_state": new_state,
            "time": OS.get_ticks_msec() / 1000.0
        })
        
        # Only keep last 10 state changes
        if debug_state_change_history.size() > 10:
            debug_state_change_history.pop_front()

# Set up the debug overlay canvas layer
func setup_debug_overlay():
    if debug_overlay:
        return
        
    debug_overlay = CanvasLayer.new()
    debug_overlay.name = "CameraDebugOverlay"
    debug_overlay.layer = 100  # Show on top
    add_child(debug_overlay)
    
    # Add overlay title label
    var title = Label.new()
    title.text = "Camera Debug Overlay"
    title.name = "OverlayTitle"
    title.rect_position = Vector2(10, 10)
    title.add_color_override("font_color", Color(1, 1, 0))
    
    # Add background for better visibility
    var bg = ColorRect.new()
    bg.color = Color(0, 0, 0, 0.5)
    bg.rect_position = Vector2(5, 5)
    bg.rect_size = Vector2(200, 30)
    
    debug_overlay.add_child(bg)
    debug_overlay.add_child(title)
    
    debug_log("overlay", "Created debug overlay")

func _ready():
    # Add diagnostics to help troubleshoot property access issues
    print("ScrollingCamera._ready() called - Script Path: " + get_script().get_path())
    print("ScrollingCamera class loaded - Script ID: " + str(get_instance_id()))
    
    # Setup camera properties
    current = true # Make this the active camera
    smoothing_enabled = true
    smoothing_speed = follow_smoothing
    
    # Get screen size
    screen_size = get_viewport_rect().size
    debug_log("trace", "Camera initialized with screen size: " + str(screen_size))
    
    # Initialize camera state
    current_camera_state = CameraState.IDLE
    
    # Set up debug overlay if debug is enabled
    if get_debug_draw():
        setup_debug_overlay()
    else:
        print("Debug drawing is disabled")
    
    # Print target player status
    if get_target_player():
        print("Target player set: " + str(get_target_player().name))
    else:
        print("No target player set")
    
    # Register with the CoordinateManager 
    # Delay this to ensure all nodes are ready
    call_deferred("register_with_coordinate_manager")
    
    # Find player
    yield(get_tree(), "idle_frame") # Wait for scene to be ready
    _find_player()
    
    # Set initial camera bounds based on parent district (if applicable)
    _setup_camera_bounds()
    
    # Initialize the bounds validator
    _initialize_bounds_validator()
    
    # Set initial camera position
    _set_initial_camera_position()
    
    # Set up debug font if debug_draw is enabled
    if debug_draw:
        # Try to load a proper font or use Labels instead
        # Fix for the font rendering errors
        debug_font = DynamicFont.new()
        var font_path = "res://src/assets/fonts/Consolas.ttf"
        var default_font = "res://default_env.tres"
        
        # Try to load the specific font
        var specific_font = File.new()
        if specific_font.file_exists(font_path):
            debug_font.font_data = load(font_path)
            debug_log("overlay", "Loaded specific font for debug overlay")
        else:
            # If specific font doesn't exist, avoid null reference by using fallback
            debug_log("overlay", "Specific font not found, using alternative debug method")
            # We'll handle font rendering with labels instead
            _setup_debug_labels()
    
    # Connect to district signals if parent is a district
    var parent = get_parent()
    if parent is BaseDistrict:
        if parent.has_signal("district_initialized"):
            parent.connect("district_initialized", self, "_on_district_initialized")
            debug_log("camera", "Connected to district_initialized signal")
    
    # Set the initial camera state based on initialization parameters
    if follow_player and target_player:
        set_camera_state(CameraState.FOLLOWING_PLAYER)
        debug_log("camera", "Camera initialized in FOLLOWING_PLAYER state")
    else:
        set_camera_state(CameraState.IDLE)
        debug_log("camera", "Camera initialized in IDLE state")

func _process(delta):
    if !target_player:
        return
        
    # Handle camera movement based on state
    match current_camera_state:
        CameraState.FOLLOWING_PLAYER:
            if follow_player and !world_view_mode:
                _handle_camera_movement(delta)
                
        CameraState.MOVING:
            if is_transition_active:
                _handle_transition_movement(delta)
            else:
                # If transition is complete but we're still in MOVING state, go to IDLE
                set_camera_state(CameraState.IDLE)
                
        CameraState.IDLE:
            # If follow_player is enabled but we're idle, switch to FOLLOWING_PLAYER
            # Don't switch to FOLLOWING_PLAYER when in world view mode
            if follow_player and target_player and !world_view_mode:
                set_camera_state(CameraState.FOLLOWING_PLAYER)
    
    # Only draw debug in editor or debug builds
    if OS.is_debug_build():
        if debug_draw:
            # Update visual debug elements
            update_debug_markers()
            update()
        
        # If using UI labels instead of direct font rendering
        _update_debug_labels()

# Update positions of all debug markers
func update_debug_markers():
    if not debug_overlay:
        return
        
    # Update each marker position
    for marker_name in debug_markers:
        var marker = debug_markers[marker_name]
        if marker_name.begins_with("rightedge"):
            # Update right edge marker position
            marker.rect_position = world_to_screen(debug_right_edge_position) - Vector2(marker.rect_size.x/2, marker.rect_size.y/2)
        elif marker_name.begins_with("calculated"):
            # Update calculated position marker
            marker.rect_position = world_to_screen(debug_calculated_position) - Vector2(marker.rect_size.x/2, marker.rect_size.y/2)

func _find_player():
    # Try to find player in the scene
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        target_player = players[0]
        print("Camera found player: " + target_player.name)
    else:
        print("WARNING: ScrollingCamera could not find a player node")

func _setup_camera_bounds():
    # If parent is a district, use its walkable area to determine bounds
    if get_parent() is BaseDistrict:
        var district = get_parent() as BaseDistrict
        # Calculate bounds from walkable areas
        camera_bounds = _calculate_district_bounds(district)
        print("Camera bounds set from district: ", camera_bounds)
    else:
        # Default bounds to screen size
        camera_bounds = Rect2(0, 0, screen_size.x, screen_size.y)
        print("Using default camera bounds based on screen size")

# Initialize the appropriate bounds validator based on mode
func _initialize_bounds_validator() -> void:
    # Create the appropriate bounds validator based on test mode
    if test_mode:
        print("Initializing TestBoundsValidator for test mode")
        _bounds_validator = load(TestBoundsValidatorPath).new()
    else:
        print("Initializing DefaultBoundsValidator with bounds: " + str(camera_bounds))
        _bounds_validator = load(DefaultBoundsValidatorPath).new(camera_bounds)
        _bounds_validator.set_bounds_enabled(bounds_enabled)
        
    # Output message for validation
    print("BoundsValidator initialized: " + str(_bounds_validator.get_class()))
    
# Provide a way to set a custom bounds validator (for advanced use cases)
func set_bounds_validator(validator) -> void:
    if validator:
        _bounds_validator = validator
    else:
        # Fall back to default if null
        _bounds_validator = load(DefaultBoundsValidatorPath).new(camera_bounds)

func _calculate_district_bounds(district) -> Rect2:
    # Use the BoundsCalculator service to calculate bounds from walkable areas
    # This decouples the camera system from direct walkable area manipulation
    
    print("\n========== DISTRICT BOUNDS CALCULATION STARTED ==========")
    print("Background dimensions: " + str(district.background_size) if "background_size" in district else "Unknown")
    print("Screen size: " + str(screen_size))
    print("Current camera zoom: " + str(zoom))
    print("Number of walkable areas: " + str(district.walkable_areas.size()))
    
    # Use the BoundsCalculator service to calculate bounds
    var result_bounds = BoundsCalculator.calculate_bounds_from_walkable_areas(district.walkable_areas)
    
    # If the calculation returned a zero-size rectangle, use default values
    if result_bounds.size == Vector2.ZERO:
        print("WARNING: BoundsCalculator returned empty bounds, using defaults")
        if "background_size" in district and district.background_size != Vector2.ZERO:
            # Default to background size if available
            result_bounds = Rect2(Vector2.ZERO, district.background_size)
        else:
            # Otherwise use screen size
            result_bounds = Rect2(0, 0, screen_size.x, screen_size.y)
    
    # Apply any district-specific adjustments
    if "background_size" in district and district.background_size != Vector2.ZERO:
        # Consider background size in bounds calculation
        if result_bounds.size.x < district.background_size.x * 0.3:
            print("NOTE: Calculated bounds width is less than 30% of background width.")
            print("This may indicate an issue with walkable area coordinates.")
    
    print("Final district bounds: " + str(result_bounds))
    print("========== DISTRICT BOUNDS CALCULATION COMPLETED ==========\n")
    
    # Store the calculated bounds in the camera_bounds property
    camera_bounds = result_bounds
    
    # Create a debug visualization in development builds
    if OS.is_debug_build() and debug_draw:
        if get_parent() and "add_child" in get_parent():
            BoundsCalculator.create_bounds_visualization(result_bounds, get_parent())
    
    return result_bounds

# Helper method to convert screen coordinates to world coordinates
# This ensures proper conversion regardless of zoom level
func screen_to_world(screen_pos: Vector2) -> Vector2:
    # First validate the screen position to catch any invalid values
    if is_nan(screen_pos.x) or is_nan(screen_pos.y) or is_inf(screen_pos.x) or is_inf(screen_pos.y):
        push_warning("Camera: Invalid screen coordinates detected. Using viewport center as fallback.")
        screen_pos = get_viewport_rect().size / 2
        
    # Calculate the transformation
    var result = global_position + ((screen_pos - get_viewport_rect().size/2) * zoom)
    
    # Validate the result
    result = validate_coordinates(result)
    
    # If CoordinateManager singleton exists, notify it of the transformation
    if Engine.has_singleton("CoordinateManager"):
        var coord_manager = Engine.get_singleton("CoordinateManager")
        debug_log("camera", "Notifying CoordinateManager of screen_to_world transformation: " +
                 str(screen_pos) + " -> " + str(result))
    
    return result

# Helper method to convert world coordinates to screen coordinates
# This ensures proper conversion regardless of zoom level
func world_to_screen(world_pos: Vector2) -> Vector2:
    # First validate the world position
    world_pos = validate_coordinates(world_pos)
        
    # Calculate the transformation
    var result = (world_pos - global_position) / zoom + get_viewport_rect().size/2
    
    # Validate screen coordinates as well (screen can have invalid coordinates too)
    if is_nan(result.x) or is_nan(result.y) or is_inf(result.x) or is_inf(result.y):
        push_warning("Camera: Invalid screen coordinates calculated. Using viewport center as fallback.")
        result = get_viewport_rect().size / 2
    
    # If CoordinateManager singleton exists, notify it of the transformation
    if Engine.has_singleton("CoordinateManager"):
        var coord_manager = Engine.get_singleton("CoordinateManager")
        debug_log("camera", "Notifying CoordinateManager of world_to_screen transformation: " +
                 str(world_pos) + " -> " + str(result))
    
    return result

# Register this camera with the CoordinateManager singleton
func register_with_coordinate_manager():
    if Engine.has_singleton("CoordinateManager"):
        var coord_manager = Engine.get_singleton("CoordinateManager")
        
        # Get parent district if available
        var district = get_parent() if get_parent() is BaseDistrict else null
        
        if district:
            # Register the district with the coordinate manager
            coord_manager.set_current_district(district)
            debug_log("camera", "Registered district with CoordinateManager: " + str(district.name))
        else:
            debug_log("camera", "No parent district found to register with CoordinateManager")
            
        debug_log("camera", "Camera registered with CoordinateManager")
    else:
        debug_log("camera", "CoordinateManager singleton not available for registration")

# Validate coordinates to ensure they are valid and handle edge cases
func validate_coordinates(position: Vector2) -> Vector2:
    # Check for NaN values
    if is_nan(position.x) or is_nan(position.y):
        push_warning("Camera: Invalid coordinate detected (NaN). Using camera position as fallback.")
        return global_position
    
    # Check for infinite values
    if is_inf(position.x) or is_inf(position.y):
        push_warning("Camera: Invalid coordinate detected (Infinite). Using camera position as fallback.")
        return global_position
        
    # Check for extremely large values that likely indicate errors
    if abs(position.x) > 100000 or abs(position.y) > 100000:
        push_warning("Camera: Suspiciously large coordinate detected. Using camera position as fallback.")
        debug_log("camera", "Large coordinate detected: " + str(position))
        return global_position
        
    # Return the validated position
    return position

# Check if a world point is currently visible in the camera view
func is_point_in_view(world_pos: Vector2) -> bool:
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    return current_view.has_point(world_pos)

# Ensure a target position is valid for camera movement (within bounds)
func ensure_valid_target(target_pos: Vector2) -> Vector2:
    var validated_pos = validate_coordinates(target_pos)
    
    # Add debug output to track position changes
    print("ensure_valid_target called with position: " + str(target_pos))
    print("Current test_mode value: " + str(test_mode))
    
    # When in test mode, skip ALL bounds validation
    if test_mode:
        print("[TEST] Bypassing all bounds validation due to test_mode=true for: " + str(target_pos))
        return validated_pos
    
    # Get half size of camera view
    var camera_half_size = screen_size / 2 / zoom
    print("Camera half size: " + str(camera_half_size))
    
    # Use the bounds validator to validate the position
    if _bounds_validator != null:
        var original_pos = validated_pos
        validated_pos = _bounds_validator.validate_position(validated_pos, camera_half_size)
        
        # Log validation result
        if original_pos != validated_pos:
            print("Position adjusted by bounds validator: " + str(original_pos) + " -> " + str(validated_pos))
    else:
        # Fall back to old behavior if validator is null (shouldn't happen, but just in case)
        push_warning("No bounds validator available, using legacy bounds validation")
        if bounds_enabled and camera_bounds.size != Vector2.ZERO:
            # Calculate bounds limits
            var min_x = camera_bounds.position.x + camera_half_size.x
            var max_x = camera_bounds.position.x + camera_bounds.size.x - camera_half_size.x
            var min_y = camera_bounds.position.y + camera_half_size.y
            var max_y = camera_bounds.position.y + camera_bounds.size.y - camera_half_size.y
            
            # Store original position for comparison
            var original_pos = validated_pos
            
            # Clamp position to bounds
            validated_pos.x = clamp(validated_pos.x, min_x, max_x)
            validated_pos.y = clamp(validated_pos.y, min_y, max_y)
            
            # Log if position was adjusted
            if original_pos != validated_pos:
                print("Position adjusted by bounds: " + str(original_pos) + " -> " + str(validated_pos))
    
    return validated_pos

func _handle_camera_movement(delta):
    # Get player's position
    var player_pos = target_player.global_position
    
    # Validate player position to catch any potential issues
    player_pos = validate_coordinates(player_pos)
    
    # Get current camera view rect in world space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    
    # Calculate the area within the view that doesn't trigger scrolling
    var inner_margin = Rect2(
        current_view.position + edge_margin,
        current_view.size - (edge_margin * 2)
    )
    
    # Check if player is outside the inner margin area
    var needs_scroll = !inner_margin.has_point(player_pos)
    
    if needs_scroll:
        # Calculate intelligent target position based on player position relative to inner margin
        var target_pos = global_position
        
        # Determine which edge(s) the player is approaching/crossing
        var player_relative_to_inner = Vector2.ZERO
        
        # X-axis: Check if player is to the left or right of inner margin
        if player_pos.x < inner_margin.position.x:
            # Player is to the left of inner margin
            player_relative_to_inner.x = -1
        elif player_pos.x > inner_margin.position.x + inner_margin.size.x:
            # Player is to the right of inner margin
            player_relative_to_inner.x = 1
            
        # Y-axis: Check if player is above or below inner margin
        if player_pos.y < inner_margin.position.y:
            # Player is above inner margin
            player_relative_to_inner.y = -1
        elif player_pos.y > inner_margin.position.y + inner_margin.size.y:
            # Player is below inner margin
            player_relative_to_inner.y = 1
            
        # Calculate how much to adjust camera position to keep player in view
        if player_relative_to_inner.x != 0 or player_relative_to_inner.y != 0:
            # Option 1: Direct approach - move camera to center on player
            # This is a simple approach that always works but can feel jerky
            target_pos = player_pos
            
            # Option 2: More gradual approach - move camera just enough to bring player back within margins
            # This creates a more natural, controlled scrolling effect
            if player_relative_to_inner.x != 0:
                var margin_x = inner_margin.position.x if player_relative_to_inner.x < 0 else inner_margin.position.x + inner_margin.size.x
                var diff_x = player_pos.x - margin_x
                # Add an extra buffer to prevent oscillation
                diff_x += 5 * player_relative_to_inner.x
                target_pos.x = global_position.x + diff_x
                
            if player_relative_to_inner.y != 0:
                var margin_y = inner_margin.position.y if player_relative_to_inner.y < 0 else inner_margin.position.y + inner_margin.size.y
                var diff_y = player_pos.y - margin_y
                # Add an extra buffer to prevent oscillation
                diff_y += 5 * player_relative_to_inner.y
                target_pos.y = global_position.y + diff_y
        
        # Remember original target position before validation and clamping
        var original_target_pos = target_pos
        
        # Validate and ensure the target position is within bounds
        target_pos = ensure_valid_target(target_pos)
        
        # Smoothly move camera with selected easing function
        var weight = follow_smoothing * delta
        global_position = _apply_easing(global_position, target_pos, weight)
        
        # Only call _ensure_player_visible if our target wasn't significantly clamped
        # This avoids camera oscillation when player is at the edges of bounds
        if original_target_pos.distance_to(target_pos) <= 10:
            _ensure_player_visible()
            
        # Log camera movement for debugging
        debug_log("camera", "Camera following player: " + str(player_pos) + " -> " + str(global_position))

# Ensure the player character is visible after camera movement
func _ensure_player_visible():
    # Skip this check if in world view mode
    if world_view_mode:
        return
        
    if !target_player:
        return
        
    # Get current camera view rect in world space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    
    # Check if player is within the view
    var player_pos = target_player.global_position
    player_pos = validate_coordinates(player_pos) # Validate coordinates
    
    # Use our is_point_in_view method to check if player is visible
    if !is_point_in_view(player_pos):
        debug_log("camera", "Player outside camera view - adjusting camera position")
        
        # Calculate how far outside the view the player is
        var distance_outside = Vector2()
        
        # X distance outside view
        if player_pos.x < current_view.position.x:
            distance_outside.x = player_pos.x - current_view.position.x
        elif player_pos.x > current_view.position.x + current_view.size.x:
            distance_outside.x = player_pos.x - (current_view.position.x + current_view.size.x)
        
        # Y distance outside view
        if player_pos.y < current_view.position.y:
            distance_outside.y = player_pos.y - current_view.position.y
        elif player_pos.y > current_view.position.y + current_view.size.y:
            distance_outside.y = player_pos.y - (current_view.position.y + current_view.size.y)
        
        # Adjust camera position to include player, with a small margin
        var margin = 20  # Extra pixels to add as buffer
        var new_camera_pos = global_position
        
        if distance_outside.x != 0:
            new_camera_pos.x += distance_outside.x + (margin * sign(distance_outside.x))
        
        if distance_outside.y != 0:
            new_camera_pos.y += distance_outside.y + (margin * sign(distance_outside.y))
        
        # Use ensure_valid_target to validate and apply bounds
        new_camera_pos = ensure_valid_target(new_camera_pos)
        
        # Apply the position immediately to avoid oscillation
        var original_smoothing = smoothing_enabled
        smoothing_enabled = false
        global_position = new_camera_pos
        smoothing_enabled = original_smoothing
        
        # Verify player is now within view after adjustment
        if !is_point_in_view(player_pos):
            push_warning("Player still outside camera view after adjustment - centering on player")
            # Last resort: center directly on player
            global_position = ensure_valid_target(player_pos) # Ensure valid target position
        
        debug_log("camera", "Camera repositioned to: " + str(global_position) + " to keep player in view")

# Update camera bounds when the district changes
func update_bounds():
    # Check if parent has walkable_areas property (works for both BaseDistrict and mock districts)
    var parent = get_parent()
    if parent and "walkable_areas" in parent:
        var old_bounds = camera_bounds
        camera_bounds = _calculate_district_bounds(parent)
        
        # Register updated district with CoordinateManager
        register_with_coordinate_manager()
        
        # Update the bounds validator with new bounds
        if _bounds_validator != null and not test_mode:
            _bounds_validator.set_bounds(camera_bounds)
        
        # Emit signal with enhanced bounds information
        emit_signal("view_bounds_changed", camera_bounds, old_bounds, true)
# Called when the parent district is initialized
func _on_district_initialized():
    debug_log("camera", "District initialized - updating camera bounds and registration")
    update_bounds()
    register_with_coordinate_manager()

# Force camera to update its position and bounds immediately
func force_update_scroll():
    # Skip animation and set camera position directly
    update_bounds()
    
    # Reset smoothing temporarily to make the transition immediate
    var original_smoothing = smoothing_enabled
    var original_bounds_enabled = bounds_enabled
    smoothing_enabled = false
    
    # If we have an explicit initial position, respect it
    if initial_position != Vector2.ZERO:
        # Temporarily disable bounds to ensure position is honored exactly
        set_bounds_enabled(false)
        
        # Store whether we were in test mode
        var original_test_mode = test_mode
        
        # Temporarily enable test mode to bypass bounds validation
        if not test_mode:
            set_test_mode(true)
            
        global_position = validate_coordinates(initial_position) # Validate the position
        debug_log("camera", "Respecting explicit initial camera position: " + str(initial_position))
        
        # Restore original test mode
        if original_test_mode != test_mode:
            set_test_mode(original_test_mode)
    
    # Process one frame to update camera
    force_update_transform()
    
    # Restore original settings
    smoothing_enabled = original_smoothing
    set_bounds_enabled(original_bounds_enabled)
    
    # Update camera state
    if follow_player and target_player:
        set_camera_state(CameraState.FOLLOWING_PLAYER)
    else:
        set_camera_state(CameraState.IDLE)
    
    debug_log("camera", "Camera scroll position forcibly updated at: " + str(global_position))

# Calculate the optimal zoom level to ensure the background fills the viewport
func calculate_optimal_zoom():
    print("\n===== CALCULATING OPTIMAL ZOOM =====")
    # Get the district (parent) which has background information
    var district = get_parent()
    
    # Try to find a background node to get actual size
    var background_node = district.get_node_or_null("Background") if district else null
    var bg_texture_size = Vector2.ZERO
    
    if background_node and background_node is Sprite and background_node.texture:
        # Get unscaled texture size first
        bg_texture_size = background_node.texture.get_size()
        print("Found background sprite with texture size: " + str(bg_texture_size))
        
        # Apply any existing scale to get effective size
        var bg_scale = background_node.scale
        var effective_bg_size = Vector2(bg_texture_size.x * bg_scale.x, bg_texture_size.y * bg_scale.y)
        print("Current background scale: " + str(bg_scale))
        print("Effective background size with current scale: " + str(effective_bg_size))
        
        # Calculate proper scale to fill viewport height exactly
        var height_scale = screen_size.y / bg_texture_size.y
        print("Scale needed to fill viewport height: " + str(height_scale))
        
        # Apply the scale to the background
        background_node.scale = Vector2(height_scale, height_scale)
        print("Applied new scale to background: " + str(background_node.scale))
        
        # Center the background vertically - CRITICAL for proper display
        if background_node.centered == false:
            # For non-centered sprites, we need to calculate precise y position for vertical centering
            # This ensures no gray bars at top or bottom
            var viewport_height = screen_size.y
            var scaled_height = bg_texture_size.y * height_scale
            
            # Position y=0 would align to top, we need to offset to center it
            # When scaled_height == viewport_height, this will be 0
            var y_offset = 0
            if scaled_height != viewport_height:
                y_offset = (viewport_height - scaled_height) / 2
            
            background_node.position.y = y_offset
            print("[SCALING DEBUG] Background vertical positioning applied:")
            print("[SCALING DEBUG] - Viewport height: " + str(viewport_height))
            print("[SCALING DEBUG] - Scaled background height: " + str(scaled_height))
            print("[SCALING DEBUG] - Applied y_offset: " + str(y_offset))
        
        # Get the new effective size
        effective_bg_size = Vector2(bg_texture_size.x * height_scale, bg_texture_size.y * height_scale)
        print("New effective background size: " + str(effective_bg_size))
        
        # Keep standard zoom at 1.0 since we're scaling the background instead
        zoom = Vector2(1.0, 1.0)
        print("Camera zoom left at 1.0 (since we're scaling the background)")
        
        # Update district's background_size property if it exists
        if district is BaseDistrict and "background_size" in district:
            district.background_size = effective_bg_size
            print("Updated district.background_size to " + str(effective_bg_size))
        
        # Update camera bounds if needed
        if bounds_enabled and district is BaseDistrict:
            camera_bounds = Rect2(0, 0, effective_bg_size.x, effective_bg_size.y)
            print("Updated camera bounds to match scaled background: " + str(camera_bounds))
            
        # Store scaled size in the district if possible
        if district and "background_size" in district:
            district.background_size = effective_bg_size
    
    # Use district background_size as fallback
    elif district is BaseDistrict and "background_size" in district and district.background_size != Vector2.ZERO:
        var bg_size = district.background_size
        print("Using district background_size: " + str(bg_size))
        
        # Calculate zoom based on height ratio
        var height_ratio = bg_size.y / screen_size.y
        var zoom_value = height_ratio
        
        # Clamp zoom level to reasonable bounds
        zoom_value = clamp(zoom_value, min_zoom, max_zoom)
        
        # Apply the zoom
        zoom = Vector2(zoom_value, zoom_value)
        print("Applied zoom to camera: " + str(zoom))
    else:
        print("Could not find background information - camera zoom unchanged")
    
    print("===== ZOOM CALCULATION COMPLETE =====\n")
    return zoom

func _set_initial_camera_position():
    print("\n===== CAMERA INITIAL POSITION SETUP =====")
    print("Current camera position: " + str(global_position))
    print("Initial position setting: " + str(initial_position))
    print("Initial view setting: " + str(initial_view))
    print("Screen size: " + str(screen_size))
    
    # First calculate and apply optimal zoom if enabled
    if auto_adjust_zoom:
        calculate_optimal_zoom()
    
    if camera_bounds.size == Vector2.ZERO:
        # If bounds aren't set yet, create reasonable default bounds
        print("WARNING: Camera bounds are zero size. Creating default bounds.")
        var district = get_parent()
        if district is BaseDistrict and "background_size" in district and district.background_size != Vector2.ZERO:
            camera_bounds = Rect2(0, 0, district.background_size.x, district.background_size.y)
            print("Created default bounds from district background size: " + str(camera_bounds))
        else:
            # Use screen size as fallback
            camera_bounds = Rect2(0, 0, get_viewport_rect().size.x, get_viewport_rect().size.y)
            print("Created default bounds from screen size: " + str(camera_bounds))
    
    # If an explicit initial position is set, use that
    if initial_position != Vector2.ZERO:
        print("Using explicit initial position: " + str(initial_position))
        global_position = initial_position
        print("Camera positioned at custom initial position: " + str(initial_position))
        print("Final camera position after setting: " + str(global_position))
        print("===== CAMERA INITIAL POSITION SETUP COMPLETE =====\n")
        return
    
    # Otherwise, use the initial_view setting to determine position
    var camera_half_size = screen_size / 2 / zoom
    var new_position = Vector2.ZERO
    
    print("Camera half size (screen size / 2 / zoom): " + str(camera_half_size))
    print("Camera bounds: " + str(camera_bounds))
    
    # Ensure we're only showing a portion of the background based on the view ratio
    # First check if the background is wide enough to scroll (at least 1.5x screen width)
    var scroll_enabled = camera_bounds.size.x >= screen_size.x * 1.5
    print("Background wide enough for scrolling: " + str(scroll_enabled))
    print("Background width: " + str(camera_bounds.size.x) + ", Min width for scrolling: " + str(screen_size.x * 1.5))
    
    match initial_view.to_lower():
        "left":
            print("Using LEFT initial view setting")
            if scroll_enabled:
                # Position camera to show only the left portion of the background
                # We want to show the leftmost portion of the background
                # We need to position the camera so that the left edge of the screen aligns with the left edge of the background
                # Calculate by adding half the screen width to the left edge of the bounds
                var screen_half_width = get_viewport_rect().size.x / 2 / zoom.x
                var left_side_position = camera_bounds.position.x + screen_half_width
                print("Left side position calculation: Left edge " + str(camera_bounds.position.x) + 
                      " + half screen width " + str(screen_half_width) + " = " + str(left_side_position))
                new_position = Vector2(
                    left_side_position,
                    camera_bounds.position.y + camera_bounds.size.y / 2
                )
                print("Positioning camera at left portion: " + str(new_position))
            else:
                # If background isn't wide enough, center it
                new_position = Vector2(
                    camera_bounds.position.x + camera_bounds.size.x / 2,
                    camera_bounds.position.y + camera_bounds.size.y / 2
                )
                print("Warning: Background not wide enough for scrolling - centering instead: " + str(new_position))
            
        "right":
            print("Using RIGHT initial view setting")
            if scroll_enabled:
                # Position camera to show the rightmost portion of the background
                # First try to find the actual background sprite to get accurate dimensions
                var district = get_parent()
                var background_node = district.get_node_or_null("Background") if district else null
                var full_bg_width = 0
                var effective_height = 0
                
                if background_node and background_node is Sprite and background_node.texture:
                    # Calculate the effective width and height with the current scale
                    var bg_texture_size = background_node.texture.get_size()
                    var scale = background_node.scale
                    full_bg_width = bg_texture_size.x * scale.x
                    effective_height = bg_texture_size.y * scale.y
                    print("Using scaled background dimensions: " + str(full_bg_width) + "x" + str(effective_height))
                elif district is BaseDistrict and "background_size" in district and district.background_size != Vector2.ZERO:
                    # Use district background_size as fallback
                    full_bg_width = district.background_size.x
                    effective_height = district.background_size.y
                    print("Using district background_size: " + str(full_bg_width) + "x" + str(effective_height))
                else:
                    # Fallback to camera bounds if full background size not available
                    full_bg_width = camera_bounds.position.x + camera_bounds.size.x
                    effective_height = camera_bounds.position.y + camera_bounds.size.y
                    print("Using camera bounds: " + str(full_bg_width) + "x" + str(effective_height))
                
                # Calculate position accounting for zoom and screen width
                var viewport_size = get_viewport_rect().size
                var screen_half_width = viewport_size.x / 2 / zoom.x
                
                debug_log("camera", "Step 1: Calculating right side position", "RIGHT_VIEW")
                
                # Position camera to show the extreme right edge of the background
                # Subtract half screen width from total background width to show right edge
                var right_side_position = full_bg_width - screen_half_width
                
                # Ensure vertical center positioning
                var center_y = effective_height / 2
                
                debug_log("camera", "Right side position calculation:", "RIGHT_VIEW")
                debug_log("camera", "- Full background width: " + str(full_bg_width), "RIGHT_VIEW")
                debug_log("camera", "- Viewport size: " + str(viewport_size), "RIGHT_VIEW")
                debug_log("camera", "- Half screen width (adjusted for zoom): " + str(screen_half_width), "RIGHT_VIEW")
                debug_log("camera", "- Vertical center: " + str(center_y), "RIGHT_VIEW")
                debug_log("camera", "- Calculated horizontal position: " + str(right_side_position), "RIGHT_VIEW")
                
                # Store the target position for debugging (before any adjustments)
                debug_right_edge_position = Vector2(right_side_position, center_y)
                
                # Create visual debug marker at right edge position if debugging is enabled
                if debug_draw and OS.is_debug_build():
                    create_debug_marker(debug_right_edge_position, Color(1, 0, 0, 0.8), 20, "rightedge")
                    debug_log("overlay", "Created right edge position marker at " + str(debug_right_edge_position), "RIGHT_VIEW")
                
                # Create final camera position
                new_position = Vector2(right_side_position, center_y)
                debug_log("camera", "Step 2: Initial camera position for RIGHT view: " + str(new_position), "RIGHT_VIEW")
                
                # Apply a small adjustment if needed to ensure extreme right edge is visible
                # We add a tiny buffer of 5 pixels to avoid any rounding issues
                if background_node and right_side_position + screen_half_width < full_bg_width:
                    var adjustment = full_bg_width - (right_side_position + screen_half_width) + 5
                    new_position.x += adjustment
                    debug_log("camera", "Step 3: Applied adjustment of " + str(adjustment) + " pixels to show extreme right edge", "RIGHT_VIEW")
                    debug_log("camera", "Step 3: Adjusted final position: " + str(new_position), "RIGHT_VIEW")
                
                # Store the calculated position for debugging (after adjustments)
                debug_calculated_position = new_position
                
                # Create visual debug marker for calculated position
                if debug_draw and OS.is_debug_build():
                    create_debug_marker(debug_calculated_position, Color(0, 1, 0, 0.8), 20, "calculated")
                    debug_log("overlay", "Created calculated position marker at " + str(debug_calculated_position), "RIGHT_VIEW")
            else:
                # If background isn't wide enough, center it
                new_position = Vector2(
                    camera_bounds.position.x + camera_bounds.size.x / 2,
                    camera_bounds.position.y + camera_bounds.size.y / 2
                )
                print("Centering camera on walkable area: " + str(new_position))
            
        "center", _:
            print("Using CENTER initial view setting")
            # Default to center of the background
            new_position = Vector2(
                camera_bounds.position.x + camera_bounds.size.x / 2,
                camera_bounds.position.y + camera_bounds.size.y / 2
            )
            print("Positioning camera at center: " + str(new_position))
    
    # Apply the position
    print("Setting camera position to: " + str(new_position))
    global_position = new_position
    print("Camera position after setting: " + str(global_position))
    
    # Safety check: Make sure camera isn't too far from reasonable bounds
    var district = get_parent()
    print("[CAMERA DEBUG] Checking camera position against walkable area center")
    if district is BaseDistrict and district.walkable_areas.size() > 0:
        var walkable_area = district.walkable_areas[0]
        if walkable_area and walkable_area.polygon.size() > 0:
            # Calculate center of walkable area
            var center = Vector2.ZERO
            print("[CAMERA DEBUG] Walkable area polygon points: " + str(walkable_area.polygon))
            for point in walkable_area.polygon:
                center += point
            center /= walkable_area.polygon.size()
            center = walkable_area.to_global(center)
            print("[CAMERA DEBUG] Calculated walkable area center: " + str(center))
            
            # Check if camera is too far from walkable area center
            var distance = global_position.distance_to(center)
            print("[CAMERA DEBUG] Distance from camera to walkable center: " + str(distance))
            
            # IMPORTANT: Don't override camera position for edge views
            # This prevents the safety check from interfering with showing edges
            if distance > 1000 and initial_view != "right" and initial_view != "left":
                print("[CAMERA DEBUG] WARNING: Camera positioned too far from walkable area center.")
                print("[CAMERA DEBUG] Camera: " + str(global_position) + ", Walkable center: " + str(center))
                print("[CAMERA DEBUG] Adjusting camera to use walkable area center")
                global_position = center
                print("[CAMERA DEBUG] Camera position adjusted to: " + str(global_position))
            elif initial_view == "right" or initial_view == "left":
                print("[CAMERA DEBUG] Maintaining edge view position despite distance from walkable area")
                print("[CAMERA DEBUG] Current camera position: " + str(global_position))
    
    # Calculate and print view ratio for debugging
    var view_width = screen_size.x / zoom.x
    var view_ratio = view_width / camera_bounds.size.x * 100
    print("Camera positioned for initial view: " + initial_view + " at " + str(global_position))
    print("View ratio: " + str(round(view_ratio)) + "% of background is visible (" + 
          str(view_width) + " pixels of " + str(camera_bounds.size.x) + " pixels)")
    print("===== CAMERA INITIAL POSITION SETUP COMPLETE =====\n")

# Set up UI labels for debug info (alternative to font rendering)
# Set camera state and handle state transitions
# You can optionally provide a reason for the state change for debugging
func set_camera_state(new_state: int, reason: String = "") -> void:
    # Don't do anything if state isn't changing
    if current_camera_state == new_state:
        return
        
    var old_state = current_camera_state
    previous_camera_state = current_camera_state
    current_camera_state = new_state
    transition_reason = reason if reason else "manual_transition"
    
    # Store the start position before any state changes
    var start_position = global_position
    
    # Calculate expected move duration based on distance and smoothing
    var expected_duration = 0.0
    if new_state == CameraState.MOVING:
        var distance = start_position.distance_to(target_position)
        expected_duration = distance / (follow_smoothing * 60) # Approximate duration in seconds
        # Reset transition event tracking
        _triggered_events.clear()
        
    # Create debug visualization for state change
    if debug_draw and debug_show_state_changes:
        create_state_change_visual(old_state, new_state, start_position)
    
    # Handle state entry actions
    match new_state:
        CameraState.IDLE:
            is_transition_active = false
            movement_progress = 0.0
            
            # Enhanced signal with more contextual data
            emit_signal("camera_move_completed", global_position, start_position, 
                        OS.get_ticks_msec() / 1000.0 - movement_start_time if movement_start_time > 0 else 0.0)
            
        CameraState.MOVING:
            is_transition_active = true
            movement_progress = 0.0
            movement_start_time = OS.get_ticks_msec() / 1000.0
            
            # Enhanced signal with more contextual data
            emit_signal("camera_move_started", target_position, start_position, 
                       expected_duration, easing_type)
            
        CameraState.FOLLOWING_PLAYER:
            is_transition_active = false
            
    # Emit the enhanced state change signal
    emit_signal("camera_state_changed", new_state, old_state, transition_reason)
    
    # Extended debug logging
    if signal_debug_mode:
        debug_log("camera", "Camera state changed from " + get_state_name(old_state) + 
                 " to " + get_state_name(new_state) + " (Reason: " + transition_reason + ")")
        
        if new_state == CameraState.MOVING:
            debug_log("camera", "Movement details: Start=" + str(start_position) + 
                     ", Target=" + str(target_position) + ", Expected duration=" + 
                     str(expected_duration) + "s")
    else:
        debug_log("camera", "Camera state changed from " + get_state_name(old_state) + 
                  " to " + get_state_name(new_state))

# Get a readable name for a camera state
func get_state_name(state: int) -> String:
    match state:
        CameraState.IDLE:
            return "IDLE"
        CameraState.MOVING:
            return "MOVING"
        CameraState.FOLLOWING_PLAYER:
            return "FOLLOWING_PLAYER"
        _:
            return "UNKNOWN"
            
# ===== STATE LISTENER SYSTEM =====

# Connect a listener for camera state changes
# Returns self for method chaining
func connect_state_listener(listener_object, method_name, binds=[], flags=0) -> ScrollingCamera:
    # Ensure listener is a valid object
    if not is_instance_valid(listener_object):
        push_error("ScrollingCamera: Cannot connect invalid listener object")
        return self
        
    # Store the connection info
    var object_id = listener_object.get_instance_id()
    
    if not _state_listeners.has(object_id):
        _state_listeners[object_id] = {
            "object": listener_object,
            "connections": []
        }
        
        # Set up automatic cleanup when listener is freed
        if listener_object.has_method("connect"):
            listener_object.connect("tree_exiting", self, "_on_listener_freed", [object_id], CONNECT_ONESHOT)
    
    # Connect the signal
    var connection_error = connect("camera_state_changed", listener_object, method_name, binds, flags)
    
    if connection_error == OK:
        _state_listeners[object_id]["connections"].append({
            "signal": "camera_state_changed",
            "method": method_name
        })
        debug_log("camera", "Connected state listener: " + str(listener_object) + " -> " + method_name)
    else:
        push_error("ScrollingCamera: Failed to connect state listener: " + str(connection_error))
    
    return self

# Connect a listener for camera movement started event
# Returns self for method chaining
func connect_move_started_listener(listener_object, method_name, binds=[], flags=0) -> ScrollingCamera:
    # Ensure listener is a valid object
    if not is_instance_valid(listener_object):
        push_error("ScrollingCamera: Cannot connect invalid listener object")
        return self
        
    # Store the connection info
    var object_id = listener_object.get_instance_id()
    
    if not _move_started_listeners.has(object_id):
        _move_started_listeners[object_id] = {
            "object": listener_object,
            "connections": []
        }
        
        # Set up automatic cleanup when listener is freed
        if listener_object.has_method("connect"):
            listener_object.connect("tree_exiting", self, "_on_listener_freed", [object_id], CONNECT_ONESHOT)
    
    # Connect the signal
    var connection_error = connect("camera_move_started", listener_object, method_name, binds, flags)
    
    if connection_error == OK:
        _move_started_listeners[object_id]["connections"].append({
            "signal": "camera_move_started",
            "method": method_name
        })
        debug_log("camera", "Connected move_started listener: " + str(listener_object) + " -> " + method_name)
    else:
        push_error("ScrollingCamera: Failed to connect move_started listener: " + str(connection_error))
    
    return self

# Connect a listener for camera movement completed event
# Returns self for method chaining
func connect_move_completed_listener(listener_object, method_name, binds=[], flags=0) -> ScrollingCamera:
    # Ensure listener is a valid object
    if not is_instance_valid(listener_object):
        push_error("ScrollingCamera: Cannot connect invalid listener object")
        return self
        
    # Store the connection info
    var object_id = listener_object.get_instance_id()
    
    if not _move_completed_listeners.has(object_id):
        _move_completed_listeners[object_id] = {
            "object": listener_object,
            "connections": []
        }
        
        # Set up automatic cleanup when listener is freed
        if listener_object.has_method("connect"):
            listener_object.connect("tree_exiting", self, "_on_listener_freed", [object_id], CONNECT_ONESHOT)
    
    # Connect the signal
    var connection_error = connect("camera_move_completed", listener_object, method_name, binds, flags)
    
    if connection_error == OK:
        _move_completed_listeners[object_id]["connections"].append({
            "signal": "camera_move_completed",
            "method": method_name
        })
        debug_log("camera", "Connected move_completed listener: " + str(listener_object) + " -> " + method_name)
    else:
        push_error("ScrollingCamera: Failed to connect move_completed listener: " + str(connection_error))
    
    return self

# Connect a listener for view bounds changed event
# Returns self for method chaining
func connect_view_bounds_listener(listener_object, method_name, binds=[], flags=0) -> ScrollingCamera:
    # Ensure listener is a valid object
    if not is_instance_valid(listener_object):
        push_error("ScrollingCamera: Cannot connect invalid listener object")
        return self
        
    # Store the connection info
    var object_id = listener_object.get_instance_id()
    
    if not _view_bounds_listeners.has(object_id):
        _view_bounds_listeners[object_id] = {
            "object": listener_object,
            "connections": []
        }
        
        # Set up automatic cleanup when listener is freed
        if listener_object.has_method("connect"):
            listener_object.connect("tree_exiting", self, "_on_listener_freed", [object_id], CONNECT_ONESHOT)
    
    # Connect the signal
    var connection_error = connect("view_bounds_changed", listener_object, method_name, binds, flags)
    
    if connection_error == OK:
        _view_bounds_listeners[object_id]["connections"].append({
            "signal": "view_bounds_changed",
            "method": method_name
        })
        debug_log("camera", "Connected view_bounds listener: " + str(listener_object) + " -> " + method_name)
    else:
        push_error("ScrollingCamera: Failed to connect view_bounds listener: " + str(connection_error))
    
    return self

# Disconnect a listener from all camera signals
# Returns self for method chaining
func disconnect_listener(listener_object) -> ScrollingCamera:
    if not is_instance_valid(listener_object):
        push_error("ScrollingCamera: Cannot disconnect invalid listener object")
        return self
        
    var object_id = listener_object.get_instance_id()
    
    # Disconnect from state change signals
    if _state_listeners.has(object_id):
        if is_connected("camera_state_changed", listener_object, _state_listeners[object_id]["connections"][0]["method"]):
            disconnect("camera_state_changed", listener_object, _state_listeners[object_id]["connections"][0]["method"])
        _state_listeners.erase(object_id)
    
    # Disconnect from move started signals
    if _move_started_listeners.has(object_id):
        if is_connected("camera_move_started", listener_object, _move_started_listeners[object_id]["connections"][0]["method"]):
            disconnect("camera_move_started", listener_object, _move_started_listeners[object_id]["connections"][0]["method"])
        _move_started_listeners.erase(object_id)
    
    # Disconnect from move completed signals
    if _move_completed_listeners.has(object_id):
        if is_connected("camera_move_completed", listener_object, _move_completed_listeners[object_id]["connections"][0]["method"]):
            disconnect("camera_move_completed", listener_object, _move_completed_listeners[object_id]["connections"][0]["method"])
        _move_completed_listeners.erase(object_id)
    
    # Disconnect from view bounds changed signals
    if _view_bounds_listeners.has(object_id):
        if is_connected("view_bounds_changed", listener_object, _view_bounds_listeners[object_id]["connections"][0]["method"]):
            disconnect("view_bounds_changed", listener_object, _view_bounds_listeners[object_id]["connections"][0]["method"])
        _view_bounds_listeners.erase(object_id)
    
    debug_log("camera", "Disconnected all listeners for: " + str(listener_object))
    
    return self

# Called when a listener is freed (auto-cleanup)
func _on_listener_freed(object_id):
    # Clean up state listeners
    if _state_listeners.has(object_id):
        _state_listeners.erase(object_id)
        debug_log("camera", "Auto-removed state listener with ID: " + str(object_id))
    
    # Clean up move started listeners
    if _move_started_listeners.has(object_id):
        _move_started_listeners.erase(object_id)
        debug_log("camera", "Auto-removed move_started listener with ID: " + str(object_id))
    
    # Clean up move completed listeners
    if _move_completed_listeners.has(object_id):
        _move_completed_listeners.erase(object_id)
        debug_log("camera", "Auto-removed move_completed listener with ID: " + str(object_id))
    
    # Clean up view bounds listeners
    if _view_bounds_listeners.has(object_id):
        _view_bounds_listeners.erase(object_id)
        debug_log("camera", "Auto-removed view_bounds listener with ID: " + str(object_id))

# Move camera to a specific target position
func move_to_position(pos: Vector2, immediate: bool = false) -> void:
    # Validate and adjust target position
    target_position = ensure_valid_target(pos)
    
    # Log original request for debugging
    print("move_to_position called with pos=" + str(pos) + ", immediate=" + str(immediate))
    print("Target position after validation: " + str(target_position))
    
    if immediate:
        # Skip animation, set position directly
        var original_smoothing = smoothing_enabled
        smoothing_enabled = false
        var old_position = global_position
        print("Immediate move from " + str(old_position) + " to " + str(target_position))
        global_position = target_position
        smoothing_enabled = original_smoothing
        
        # Emit signals directly for immediate moves
        emit_signal("camera_move_started", target_position, old_position, 0.0, EasingType.LINEAR)
        emit_signal("camera_move_completed", target_position, old_position, 0.0)
        set_camera_state(CameraState.IDLE, "immediate_position_change")
    else:
        # Start animated movement
        print("Starting animated movement to " + str(target_position))
        set_camera_state(CameraState.MOVING, "requested_position_change")
        
# Begin following the player
func start_following_player() -> void:
    if target_player:
        set_camera_state(CameraState.FOLLOWING_PLAYER, "explicit_follow_request")
    else:
        push_warning("Cannot follow player: no player target found")
        
# Stop following the player and stay in place
func stop_following_player() -> void:
    if current_camera_state == CameraState.FOLLOWING_PLAYER:
        set_camera_state(CameraState.IDLE, "explicit_stop_follow_request")
        
# Focus on player immediately (center camera on player position)
func focus_on_player(with_transition: bool = false) -> void:
    if !target_player:
        push_warning("Cannot focus on player: no player target found")
        return
        
    # Get and validate player position
    var player_pos = validate_coordinates(target_player.global_position)
    
    # Move camera to player position
    move_to_position(player_pos, !with_transition)
    
    # After focusing, resume following if that was the previous state
    if follow_player and !with_transition:
        set_camera_state(CameraState.FOLLOWING_PLAYER)
        
# ===== STATE QUERY METHODS =====

# Get current camera state
func get_camera_state() -> int:
    return current_camera_state
    
# Get previous camera state
func get_previous_state() -> int:
    return previous_camera_state

# Get the reason for the last state transition
func get_transition_reason() -> String:
    return transition_reason
    
# Check if camera is currently idle (not moving or following)
func is_idle() -> bool:
    return current_camera_state == CameraState.IDLE
    
# Check if camera is currently moving (transitioning)
func is_moving() -> bool:
    return current_camera_state == CameraState.MOVING
    
# Check if camera is currently following player
func is_following_player() -> bool:
    return current_camera_state == CameraState.FOLLOWING_PLAYER
    
# Get current movement progress (0.0 to 1.0) if transitioning
func get_movement_progress() -> float:
    return movement_progress if is_moving() else 0.0
    
# Get elapsed movement time in seconds
func get_movement_elapsed_time() -> float:
    if movement_start_time <= 0 or not is_moving():
        return 0.0
    return OS.get_ticks_msec() / 1000.0 - movement_start_time

# Calculate estimated remaining time for current transition
# Returns 0 if not in a transition
func get_estimated_movement_time_remaining() -> float:
    if not is_moving() or movement_progress >= 1.0:
        return 0.0
        
    var time_elapsed = get_movement_elapsed_time()
    if movement_progress <= 0 or time_elapsed <= 0:
        return 0.0  # Avoid division by zero
        
    # Estimate based on current progress and elapsed time
    var estimated_total = time_elapsed / movement_progress
    return estimated_total - time_elapsed

# Check if camera is currently at a boundary
# You can specify which boundary to check with the optional direction parameter
# direction can be: "left", "right", "top", "bottom", or "any" (default)
func is_at_boundary(direction: String = "any") -> bool:
    if not bounds_enabled or camera_bounds.size == Vector2.ZERO:
        return false
        
    # Get half size of camera view in world coordinates
    var camera_half_size = screen_size / 2 / zoom
    
    # Calculate camera view edges in world space
    var left_edge = global_position.x - camera_half_size.x
    var right_edge = global_position.x + camera_half_size.x
    var top_edge = global_position.y - camera_half_size.y
    var bottom_edge = global_position.y + camera_half_size.y
    
    # Calculate bounds edges
    var bounds_left = camera_bounds.position.x
    var bounds_right = camera_bounds.position.x + camera_bounds.size.x
    var bounds_top = camera_bounds.position.y
    var bounds_bottom = camera_bounds.position.y + camera_bounds.size.y
    
    # Check specified direction
    match direction.to_lower():
        "left":
            return abs(left_edge - bounds_left) < 2.0
        "right":
            return abs(right_edge - bounds_right) < 2.0
        "top":
            return abs(top_edge - bounds_top) < 2.0
        "bottom":
            return abs(bottom_edge - bounds_bottom) < 2.0
        "any", _:
            return (abs(left_edge - bounds_left) < 2.0 or
                   abs(right_edge - bounds_right) < 2.0 or
                   abs(top_edge - bounds_top) < 2.0 or
                   abs(bottom_edge - bounds_bottom) < 2.0)

# Get the current camera view bounds in world coordinates
func get_current_view_bounds() -> Rect2:
    var camera_half_size = screen_size / 2 / zoom
    return Rect2(
        global_position - camera_half_size,
        camera_half_size * 2
    )
    
# Get the total world camera bounds (typically set by the district)
func get_world_bounds() -> Rect2:
    return camera_bounds
    
# Get the direction to the nearest boundary
# Returns a normalized Vector2 pointing toward the nearest boundary
# Returns Vector2.ZERO if not near any boundary
func get_nearest_boundary_direction(threshold: float = 50.0) -> Vector2:
    if not bounds_enabled or camera_bounds.size == Vector2.ZERO:
        return Vector2.ZERO
        
    # Get camera view in world coordinates
    var camera_half_size = screen_size / 2 / zoom
    var left_edge = global_position.x - camera_half_size.x
    var right_edge = global_position.x + camera_half_size.x
    var top_edge = global_position.y - camera_half_size.y
    var bottom_edge = global_position.y + camera_half_size.y
    
    # Calculate bounds edges
    var bounds_left = camera_bounds.position.x
    var bounds_right = camera_bounds.position.x + camera_bounds.size.x
    var bounds_top = camera_bounds.position.y
    var bounds_bottom = camera_bounds.position.y + camera_bounds.size.y
    
    # Check distances to each boundary
    var left_dist = left_edge - bounds_left
    var right_dist = bounds_right - right_edge
    var top_dist = top_edge - bounds_top
    var bottom_dist = bounds_bottom - bottom_edge
    
    # Find closest boundary
    var direction = Vector2.ZERO
    var min_dist = threshold
    
    if left_dist < min_dist:
        min_dist = left_dist
        direction = Vector2(-1, 0)
        
    if right_dist < min_dist:
        min_dist = right_dist
        direction = Vector2(1, 0)
        
    if top_dist < min_dist:
        min_dist = top_dist
        direction = Vector2(0, -1)
        
    if bottom_dist < min_dist:
        min_dist = bottom_dist
        direction = Vector2(0, 1)
    
    return direction.normalized()

# ===== UI ELEMENT SYNCHRONIZATION =====

# Register a UI element for synchronization with camera movements
# The element must implement specific methods to receive camera updates:
# - sync_with_camera_movement(progress, from_pos, to_pos) -> called during transitions
# - on_camera_state_changed(new_state, old_state) -> called when camera state changes
# - on_camera_move_completed() -> called when camera movement completes
# Returns self for method chaining
func register_ui_element(element) -> ScrollingCamera:
    if not element or not is_instance_valid(element):
        push_error("ScrollingCamera: Cannot register invalid UI element")
        return self
        
    # Check if the element has the required methods
    if not element.has_method("sync_with_camera_movement") and \
       not element.has_method("on_camera_state_changed") and \
       not element.has_method("on_camera_move_completed"):
        push_warning("ScrollingCamera: UI element doesn't implement any of the required synchronization methods")
    
    # Add to registry if not already registered
    if _ui_elements.find(element) == -1:
        _ui_elements.append(element)
        
        # Set up auto-cleanup when element is freed
        if element.has_method("connect"):
            if not element.is_connected("tree_exiting", self, "_on_ui_element_freed"):
                element.connect("tree_exiting", self, "_on_ui_element_freed", [element], CONNECT_ONESHOT)
        
        debug_log("camera", "Registered UI element: " + str(element))
        
        # Connect signals if element has the corresponding methods
        if element.has_method("on_camera_state_changed"):
            connect_state_listener(element, "on_camera_state_changed")
            
        if element.has_method("on_camera_move_completed"):
            connect_move_completed_listener(element, "on_camera_move_completed")
    
    return self

# Unregister a UI element
# Returns self for method chaining
func unregister_ui_element(element) -> ScrollingCamera:
    if not element or not is_instance_valid(element):
        return self
        
    # Find and remove from registry
    var index = _ui_elements.find(element)
    if index != -1:
        _ui_elements.remove(index)
        
        # Disconnect all signals
        disconnect_listener(element)
        
        debug_log("camera", "Unregistered UI element: " + str(element))
    
    return self

# Notify all registered UI elements of camera progress during transitions
func _notify_ui_elements_of_progress(progress: float, from_pos: Vector2, to_pos: Vector2) -> void:
    for element in _ui_elements:
        if is_instance_valid(element) and element.has_method("sync_with_camera_movement"):
            element.sync_with_camera_movement(progress, from_pos, to_pos)

# Called when a UI element is freed
func _on_ui_element_freed(element) -> void:
    if element in _ui_elements:
        unregister_ui_element(element)
        
# ===== TRANSITION EVENT SYSTEM =====

# Check for transition events during movement
func _check_transition_events(old_progress: float, new_progress: float, initial_position: Vector2) -> void:
    for point in transition_event_points:
        # Check if we've crossed this event point during this frame
        if old_progress < point and new_progress >= point and not point in _triggered_events:
            # Add to triggered events so we don't fire it again
            _triggered_events.append(point)
            
            # Emit the transition point signal
            emit_signal("camera_transition_point_reached", point, global_position, new_progress)
            
            # Call any registered callbacks for this point
            _trigger_transition_callbacks(point)
            
            if signal_debug_mode:
                debug_log("camera", "Camera transition point reached: " + str(point * 100) + "%")

# Trigger callbacks registered for a transition point
func _trigger_transition_callbacks(point: float) -> void:
    if not _registered_transition_callbacks.has(point):
        return
        
    var callbacks = _registered_transition_callbacks[point]
    for callback in callbacks:
        var object = callback.object
        var method = callback.method
        var args = callback.args if callback.has("args") else []
        
        if is_instance_valid(object) and object.has_method(method):
            # Call the method with arguments
            if args.empty():
                object.call(method, point, global_position, movement_progress)
            else:
                args.push_front(movement_progress) # Add progress as first argument
                args.push_front(global_position) # Add position as first argument
                args.push_front(point) # Add point as first argument
                object.callv(method, args)

# Register a callback for a specific transition point
# point should be a value between 0.0 and 1.0
# Returns self for method chaining
func register_transition_callback(point: float, object, method: String, args: Array = []) -> ScrollingCamera:
    if not is_instance_valid(object) or not object.has_method(method):
        push_error("ScrollingCamera: Cannot register invalid transition callback")
        return self
        
    # Round point to nearest predefined event point if not exact
    var closest_point = -1.0
    var min_distance = 1.0
    
    for event_point in transition_event_points:
        var distance = abs(event_point - point)
        if distance < min_distance:
            min_distance = distance
            closest_point = event_point
    
    if closest_point < 0:
        push_error("ScrollingCamera: No valid transition points defined")
        return self
        
    # Use closest point instead of exact value
    if abs(closest_point - point) > 0.001:
        debug_log("camera", "Adjusted transition point from " + str(point) + 
                  " to nearest defined point " + str(closest_point))
        point = closest_point
        
    # Initialize the dictionary if needed
    if not _registered_transition_callbacks.has(point):
        _registered_transition_callbacks[point] = []
        
    # Add the callback
    _registered_transition_callbacks[point].append({
        "object": object,
        "method": method,
        "args": args
    })
    
    # Set up auto-cleanup when object is freed
    if object.has_method("connect") and not object.is_connected("tree_exiting", self, "_on_transition_callback_freed"):
        object.connect("tree_exiting", self, "_on_transition_callback_freed", [object], CONNECT_ONESHOT)
    
    debug_log("camera", "Registered transition callback at point " + str(point) + ": " + 
             str(object) + " -> " + method)
             
    return self

# Unregister a callback from a specific transition point
# Returns self for method chaining
func unregister_transition_callback(point: float, object, method: String = "") -> ScrollingCamera:
    if not _registered_transition_callbacks.has(point):
        return self
        
    # Filter out callbacks for this object/method
    var callbacks = _registered_transition_callbacks[point]
    var i = callbacks.size() - 1
    
    while i >= 0:
        var callback = callbacks[i]
        if callback.object == object and (method.empty() or callback.method == method):
            callbacks.remove(i)
            debug_log("camera", "Unregistered transition callback at point " + str(point) + ": " + 
                     str(object) + (" -> " + method if not method.empty() else ""))
        i -= 1
        
    # Remove the point entry if no callbacks left
    if callbacks.empty():
        _registered_transition_callbacks.erase(point)
        
    return self

# Remove all transition callbacks for an object
# Returns self for method chaining
func unregister_all_transition_callbacks(object) -> ScrollingCamera:
    for point in _registered_transition_callbacks.keys():
        unregister_transition_callback(point, object)
    return self

# Called when an object with registered callbacks is freed
func _on_transition_callback_freed(object) -> void:
    unregister_all_transition_callbacks(object)

# Set custom transition event points
# points should be an array of values between 0.0 and 1.0
# Returns self for method chaining
func set_transition_event_points(points: Array) -> ScrollingCamera:
    # Validate points
    var valid_points = []
    for point in points:
        if typeof(point) == TYPE_REAL and point > 0.0 and point < 1.0:
            valid_points.append(point)
            
    # Sort the points
    valid_points.sort()
    
    # Update event points
    transition_event_points = valid_points
    
    # Clear any currently triggered events
    _triggered_events.clear()
    
    # Update event callbacks to match new points
    var old_callbacks = _registered_transition_callbacks.duplicate()
    _registered_transition_callbacks.clear()
    
    # Reassign callbacks to closest new points
    for old_point in old_callbacks:
        var callbacks = old_callbacks[old_point]
        var closest_point = -1.0
        var min_distance = 1.0
        
        for new_point in transition_event_points:
            var distance = abs(new_point - old_point)
            if distance < min_distance:
                min_distance = distance
                closest_point = new_point
                
        if closest_point >= 0:
            if not _registered_transition_callbacks.has(closest_point):
                _registered_transition_callbacks[closest_point] = []
                
            _registered_transition_callbacks[closest_point].append_array(callbacks)
            
    debug_log("camera", "Set transition event points to: " + str(transition_event_points))
    
    return self
    
# Set whether camera should follow player
func set_follow_player(should_follow: bool) -> void:
    follow_player = should_follow
    
    # Update state based on new setting
    if follow_player and target_player:
        set_camera_state(CameraState.FOLLOWING_PLAYER)
    elif current_camera_state == CameraState.FOLLOWING_PLAYER:
        set_camera_state(CameraState.IDLE)

func _setup_debug_labels():
    # Create a canvas layer that stays relative to the camera view
    var canvas = CanvasLayer.new()
    canvas.name = "DebugCanvas"
    canvas.layer = 100  # Make sure it's on top
    add_child(canvas)
    
    # Create a control container for all labels
    var container = Control.new()
    container.name = "DebugLabels"
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(container)
    
    # Create background panel for better readability
    var panel = ColorRect.new()
    panel.name = "DebugBackground"
    panel.color = Color(0, 0, 0, 0.5)
    panel.rect_position = Vector2(10, 10)
    panel.rect_size = Vector2(300, 100)
    container.add_child(panel)
    
    # Create labels for debug info
    var labels = [
        {"name": "CameraPos", "text": "Camera: ", "position": Vector2(15, 15)},
        {"name": "PlayerPos", "text": "Player: ", "position": Vector2(15, 35)},
        {"name": "EasingType", "text": "Easing: ", "position": Vector2(15, 55)},
        {"name": "ViewRatio", "text": "View: ", "position": Vector2(15, 75)},
        {"name": "CameraState", "text": "State: ", "position": Vector2(15, 95)}  # Added state display
    ]
    
    for label_info in labels:
        var label = Label.new()
        label.name = label_info.name
        label.text = label_info.text
        label.rect_position = label_info.position
        label.add_color_override("font_color", Color(1, 1, 0))
        container.add_child(label)
    
    # Create a container for the inner margin visualization
    var margin_vis = ColorRect.new()
    margin_vis.name = "MarginVisualization"
    margin_vis.color = Color(0, 1, 0, 0.2)
    margin_vis.rect_position = edge_margin
    margin_vis.rect_size = get_viewport_rect().size - (edge_margin * 2)
    container.add_child(margin_vis)
    
    # Create label for transition events
    var events_label = Label.new()
    events_label.name = "TransitionEvents"
    events_label.text = "Transition Events: None"
    events_label.rect_position = Vector2(15, 115)
    events_label.add_color_override("font_color", Color(1, 1, 0))
    container.add_child(events_label)
    
    print("Set up UI-based debug display as alternative to font rendering")

# Update debug UI labels (called from _process)
func _update_debug_labels():
    var canvas = get_node_or_null("DebugCanvas")
    if !canvas:
        return
        
    var container = canvas.get_node_or_null("DebugLabels")
    if !container:
        return
    
    # Update camera position label
    var cam_label = container.get_node_or_null("CameraPos")
    if cam_label:
        cam_label.text = "Camera: " + str(global_position)
    
    # Update player position label
    var player_label = container.get_node_or_null("PlayerPos")
    if player_label and target_player:
        player_label.text = "Player: " + str(target_player.global_position)
    
    # Update easing type label
    var easing_label = container.get_node_or_null("EasingType")
    if easing_label:
        var easing_names = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
        easing_label.text = "Easing: " + easing_names[easing_type]
    
    # Update view ratio label
    var ratio_label = container.get_node_or_null("ViewRatio")
    if ratio_label:
        var view_width = screen_size.x / zoom.x
        var view_ratio = view_width / camera_bounds.size.x * 100
        ratio_label.text = "View: " + str(round(view_ratio)) + "% visible"
        
    # Update camera state label
    var state_label = container.get_node_or_null("CameraState")
    if state_label:
        state_label.text = "State: " + get_state_name(current_camera_state)
    
    # Update transition events label
    var events_label = container.get_node_or_null("TransitionEvents")
    if events_label:
        if is_moving() and _triggered_events.size() > 0:
            var events_text = "Transition Events: "
            for i in range(len(_triggered_events)):
                events_text += str(int(_triggered_events[i] * 100)) + "%"
                if i < _triggered_events.size() - 1:
                    events_text += ", "
            events_label.text = events_text
        else:
            events_label.text = "Transition Events: None"
    
    # Update margin visualization
    var margin_vis = container.get_node_or_null("MarginVisualization")
    if margin_vis:
        margin_vis.rect_position = edge_margin
        margin_vis.rect_size = get_viewport_rect().size - (edge_margin * 2)

# For debugging - draw the camera bounds and margins
func _draw():
    if !debug_draw:
        return
        
    # Get current camera view in global space
    var camera_half_size = screen_size / 2 / zoom
    var current_view = Rect2(
        Vector2.ZERO - camera_half_size,
        camera_half_size * 2
    )
    
    # Draw camera edges - color based on state
    var state_colors = {
        CameraState.IDLE: Color(1, 1, 1, 0.3),
        CameraState.MOVING: Color(1, 0.5, 0, 0.4),  # Orange for moving
        CameraState.FOLLOWING_PLAYER: Color(0, 0.7, 1, 0.4)  # Blue for following
    }
    var edge_color = state_colors[current_camera_state]
    draw_rect(current_view, edge_color, false)
    
    # Draw scroll trigger area
    var inner_margin = Rect2(
        current_view.position + edge_margin,
        current_view.size - (edge_margin * 2)
    )
    
    # Inner margin is green when following player, otherwise dimmer
    var inner_color = Color(0, 1, 0, 0.4) if current_camera_state == CameraState.FOLLOWING_PLAYER else Color(0, 0.5, 0, 0.2)
    draw_rect(inner_margin, inner_color, false)
    
    # If transitioning, draw line to target position
    if current_camera_state == CameraState.MOVING and is_transition_active:
        var screen_target = world_to_screen(target_position) - get_viewport_rect().size/2
        draw_line(Vector2.ZERO, screen_target, Color(1, 0.5, 0, 0.7), 2.0)
        draw_circle(screen_target, 5.0, Color(1, 0.5, 0, 0.8))
        
        # Draw transition event points if enabled
        if debug_show_transition_points:
            for point in transition_event_points:
                var progress_pos = _apply_easing(
                    Vector2.ZERO, 
                    screen_target, 
                    point
                )
                
                # Color based on whether point has been triggered
                var point_color = Color(0, 1, 0, 0.8) if point in _triggered_events else Color(1, 1, 0, 0.8)
                var point_size = 8.0 if point in _triggered_events else 6.0
                
                draw_circle(progress_pos, point_size, point_color)
                
                # Draw a small label for the percentage if we have a font
                if debug_font and debug_font.get_height() > 0:
                    var label_text = str(int(point * 100)) + "%"
                    draw_string(debug_font, progress_pos + Vector2(10, 5), label_text, point_color)
                    
    # Draw recent state change history
    if debug_show_state_changes and debug_state_change_history.size() > 0:
        var current_time = OS.get_ticks_msec() / 1000.0
        var i = 0
        for state_change in debug_state_change_history:
            # Only show state changes in the past 10 seconds
            if current_time - state_change.time < 10.0:
                # Convert world position to screen space
                var screen_pos = world_to_screen(state_change.position) - get_viewport_rect().size/2
                
                # Color based on the new state
                var color = state_colors[state_change.new_state]
                color.a = max(0.1, 1.0 - (current_time - state_change.time) / 10.0) # Fade out over time
                
                # Draw dot at state change location
                draw_circle(screen_pos, 4.0, color)
                
                # If we have a font, draw state name
                if debug_font and debug_font.get_height() > 0:
                    var label_text = get_state_name(state_change.new_state)
                    draw_string(debug_font, screen_pos + Vector2(8, -i * 15), label_text, color)
                
                i += 1
    
    # Draw text only if we have a valid font
    if debug_font and debug_font.get_height() > 0:
        var text = "Camera Position: " + str(global_position)
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 20), text, Color(1, 1, 0))
        
        if target_player:
            text = "Player Position: " + str(target_player.global_position)
            draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 40), text, Color(1, 1, 0))
            
        # Add easing type to debug display
        var easing_names = ["LINEAR", "EASE_IN", "EASE_OUT", "EASE_IN_OUT", "EXPONENTIAL", "SINE", "ELASTIC", "CUBIC", "QUAD"]
        text = "Easing: " + easing_names[easing_type]
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 60), text, Color(1, 1, 0))
        
        # Add view ratio information
        var view_width = screen_size.x / zoom.x
        var view_ratio = view_width / camera_bounds.size.x * 100
        text = "View ratio: " + str(round(view_ratio)) + "% visible"
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 80), text, Color(1, 1, 0))
        
        # Add camera state to debug display
        text = "Camera state: " + get_state_name(current_camera_state)
        draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 100), text, Color(1, 1, 0))
        
        # If in MOVING state, show transition progress
        if current_camera_state == CameraState.MOVING:
            text = "Transition: " + str(int(movement_progress * 100)) + "%"
            draw_string(debug_font, Vector2(-camera_half_size.x + 10, -camera_half_size.y + 120), text, Color(1, 0.5, 0))
    else:
        # If font rendering fails, we'll use UI labels instead (set up in _setup_debug_labels)
        _update_debug_labels()

# Handle camera transitions when in MOVING state
func _handle_transition_movement(delta):
    # Calculate movement progress based on delta time
    var transition_speed = follow_smoothing * delta
    var old_progress = movement_progress
    movement_progress += transition_speed
    
    # Clamp progress to [0, 1]
    movement_progress = clamp(movement_progress, 0.0, 1.0)
    
    # Calculate new position using easing
    var start_position = global_position
    var initial_position = target_position - (target_position - start_position) / movement_progress if movement_progress > 0 else start_position
    global_position = _apply_easing(start_position, target_position, movement_progress)
    
    # Notify UI elements of progress
    _notify_ui_elements_of_progress(movement_progress, initial_position, target_position)
    
    # Emit transition progress signal
    emit_signal("camera_transition_progress", movement_progress, global_position, target_position)
    
    # Check for transition event points
    _check_transition_events(old_progress, movement_progress, initial_position)
    
    # Create visual debug markers for transition points
    if debug_draw and debug_show_transition_points:
        for i in range(len(_triggered_events)):
            var event_point = _triggered_events[i]
            if old_progress < event_point and movement_progress >= event_point:
                # Interpolate position at exact event point
                var event_position = _apply_easing(initial_position, target_position, event_point)
                create_temporary_marker(event_position, Color(1, 1, 0, 0.8), 15, 1.0, "transition_point")
    
    # Enhanced logging in debug mode
    if signal_debug_mode:
        debug_log("camera", "Camera transition: Progress " + str(movement_progress) + 
                  ", Position " + str(global_position) + 
                  ", Target " + str(target_position) + 
                  ", Elapsed time: " + str(OS.get_ticks_msec() / 1000.0 - movement_start_time) + "s")
    else:
        debug_log("camera", "Camera transition: Progress " + str(movement_progress) + 
                  ", Position " + str(global_position) + 
                  ", Target " + str(target_position))
    
    # Check if we've reached the target
    if movement_progress >= 1.0 or global_position.distance_to(target_position) < 1.0:
        # Transition complete - snap to exact target position
        var actual_duration = OS.get_ticks_msec() / 1000.0 - movement_start_time
        global_position = target_position
        is_transition_active = false
        
        # Final notification to UI elements with progress = 1.0
        _notify_ui_elements_of_progress(1.0, initial_position, target_position)
        
        # Emit completion signal with enhanced data before changing state
        emit_signal("camera_move_completed", target_position, initial_position, actual_duration)
        
        # Transition to appropriate next state
        if follow_player and target_player:
            set_camera_state(CameraState.FOLLOWING_PLAYER, "movement_complete_follow_enabled")
        else:
            set_camera_state(CameraState.IDLE, "movement_complete")
            
        debug_log("camera", "Camera transition completed to " + str(global_position) + 
                  ", took " + str(actual_duration) + "s")

# Apply the selected easing function to interpolate between start and end positions
func _apply_easing(start_pos: Vector2, end_pos: Vector2, weight: float) -> Vector2:
    # Clamp weight to [0, 1] range
    weight = clamp(weight, 0, 1)
    
    # Apply the selected easing based on the enum
    match easing_type:
        EasingType.LINEAR:
            return start_pos.linear_interpolate(end_pos, weight)
            
        EasingType.EASE_IN:
            # Quadratic ease in: t²
            var factor = weight * weight
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.EASE_OUT:
            # Quadratic ease out: 1-(1-t)²
            var factor = 1.0 - (1.0 - weight) * (1.0 - weight)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.EASE_IN_OUT:
            # Quadratic ease in/out
            var factor = 2 * weight * weight if weight < 0.5 else 1 - pow(-2 * weight + 2, 2) / 2
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.EXPONENTIAL:
            # Exponential ease out
            var factor = 1 - pow(2, -10 * weight)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.SINE:
            # Sine-based easing (smooth)
            var factor = sin(weight * PI/2)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.ELASTIC:
            # Elastic easing (bouncy)
            var c4 = (2 * PI) / 3
            var factor = 0.0
            
            if weight == 0:
                factor = 0
            elif weight == 1:
                factor = 1
            else:
                factor = pow(2, -10 * weight) * sin((weight * 10 - 0.75) * c4) + 1
                
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.CUBIC:
            # Cubic ease out
            var factor = 1 - pow(1 - weight, 3)
            return start_pos.linear_interpolate(end_pos, factor)
            
        EasingType.QUAD:
            # Quadratic ease out (same as EASE_OUT but listed separately for clarity)
            var factor = 1 - pow(1 - weight, 2)
            return start_pos.linear_interpolate(end_pos, factor)
            
        _:  # Default to linear if unknown type
            return start_pos.linear_interpolate(end_pos, weight)

# Static helper method to get or create a ScrollingCamera
# This is especially useful for tests
static func get_or_create_camera(parent = null) -> Camera2D:
    print("ScrollingCamera.get_or_create_camera() called")
    
    # Try to find an existing ScrollingCamera in the scene
    var cameras = []
    if Engine.get_main_loop() and Engine.get_main_loop().root:
        # Use get_tree().get_nodes_in_group() which is the correct API
        if Engine.get_main_loop().has_method("get_tree"):
            var tree = Engine.get_main_loop().get_tree()
            if tree:
                cameras = tree.get_nodes_in_group("camera")
    
    for cam in cameras:
        if cam.get_script() == load("res://src/core/camera/scrolling_camera.gd"):
            print("Found existing ScrollingCamera: " + cam.name)
            return cam
            
    # Create a new ScrollingCamera
    print("Creating new ScrollingCamera")
    var camera = Camera2D.new()
    camera.name = "ScrollingCamera"
    camera.set_script(load("res://src/core/camera/scrolling_camera.gd"))
    camera.add_to_group("camera")
    
    # Add to parent if provided
    if parent and parent.has_method("add_child"):
        parent.add_child(camera)
        
    return camera