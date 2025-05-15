extends Node

# Global Debug Singleton
# This singleton can be used to enable debug tools from any scene

var debug_console = null
var debug_manager = null

func _ready():
    print("[DEBUG SINGLETON] Initialized - Press backtick (`) key for console")
    set_process_input(true)
    pause_mode = PAUSE_MODE_PROCESS  # Ensure debug tools work even when game is paused

func _input(event):
    # Listen for key presses globally
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_QUOTELEFT:
            print("[DEBUG SINGLETON] Backtick key detected - toggling console")
            toggle_console()
            get_tree().set_input_as_handled()
            
        # V key for toggling full view mode
        elif event.scancode == KEY_V:
            print("[DEBUG SINGLETON] V key detected - toggling full view mode")
            toggle_full_view()
            get_tree().set_input_as_handled()
            
        # F1 key for toggling coordinate picker
        elif event.scancode == KEY_F1:
            print("[DEBUG SINGLETON] F1 key detected - toggling coordinate picker")
            toggle_coordinate_picker()
            get_tree().set_input_as_handled()
            
        # F2 key for toggling polygon visualizer
        elif event.scancode == KEY_F2 and debug_manager and debug_manager.has_method("toggle_polygon_visualizer"):
            print("[DEBUG SINGLETON] F2 key detected - toggling polygon visualizer")
            debug_manager.call("toggle_polygon_visualizer")
            get_tree().set_input_as_handled()

func toggle_console():
    if debug_console == null:
        print("[DEBUG SINGLETON] Creating debug console")
        # Create a CanvasLayer directly
        var console_layer = CanvasLayer.new()
        console_layer.name = "GlobalDebugConsole"
        console_layer.layer = 100  # Make sure it's on top
        
        # Add the script to it
        var script = load("res://src/core/debug/debug_console.gd")
        if script:
            console_layer.set_script(script)
            # Add to scene tree
            get_tree().get_root().add_child(console_layer)
            # Store reference
            debug_console = console_layer
            print("[DEBUG SINGLETON] Debug console created")
            
            # Initialize UI in next frame
            yield(get_tree(), "idle_frame")
            if is_instance_valid(debug_console) and debug_console.has_method("create_console_ui"):
                debug_console.create_console_ui()
                debug_console.show_console()
                print("[DEBUG SINGLETON] Debug console UI initialized")
            else:
                push_error("[DEBUG SINGLETON] Debug console does not have required methods")
        else:
            push_error("[DEBUG SINGLETON] Failed to load debug_console.gd script")
            console_layer.queue_free()
            return
    else:
        # Toggle console visibility
        if debug_console.console_visible:
            debug_console.hide_console()
            print("[DEBUG SINGLETON] Debug console hidden")
        else:
            debug_console.show_console()
            print("[DEBUG SINGLETON] Debug console shown")

func get_or_create_debug_manager(scene):
    # Find a camera in the scene first
    var camera = find_camera(scene)
    if camera == null:
        push_error("[DEBUG SINGLETON] No camera found in scene")
        return null
    
    # Look for existing debug manager in the scene
    if debug_manager != null and is_instance_valid(debug_manager):
        print("[DEBUG SINGLETON] Using existing debug manager")
        return debug_manager
    
    # Create new debug manager
    var debug_manager_script = load("res://src/core/debug/debug_manager.gd")
    if debug_manager_script:
        # Create a standard Node for the debug manager
        debug_manager = Node.new()
        debug_manager.name = "DebugManager"
        debug_manager.set_script(debug_manager_script)
        scene.add_child(debug_manager)
        # Call setup_camera after adding to scene
        if debug_manager.has_method("setup_camera"):
            debug_manager.call("setup_camera", camera)
            print("[DEBUG SINGLETON] Created new debug manager and connected camera")
            return debug_manager
        else:
            print("[DEBUG SINGLETON] Debug manager doesn't have setup_camera method")
            debug_manager.queue_free()
            return null
    else:
        push_error("[DEBUG SINGLETON] Failed to load debug_manager.gd")
        return null

# Helper function to find a camera in a scene
func find_camera(node):
    # Check if this node is a camera
    if node is Camera2D and node.current:
        return node
    
    # Recursive search for a camera
    for child in node.get_children():
        var camera = find_camera(child)
        if camera:
            return camera
    
    return null

# Function to toggle coordinate picker 
func toggle_coordinate_picker():
    print("[DEBUG SINGLETON] Toggling coordinate picker")
    
    var scene = get_tree().get_current_scene()
    var manager = get_or_create_debug_manager(scene)
    
    if manager and manager.has_method("toggle_coordinate_picker"):
        manager.call("toggle_coordinate_picker") 
        return true
    else:
        # Create coordinate picker directly if needed
        var root = get_tree().get_root()
        var existing_picker = root.get_node_or_null("GlobalCoordinatePicker")
        
        if existing_picker:
            # Toggle existing picker
            existing_picker.visible = !existing_picker.visible
            print("[DEBUG SINGLETON] Toggled existing coordinate picker: ", existing_picker.visible)
            return true
        else:
            # Create a new coordinate picker
            var CoordinatePicker = load("res://src/core/debug/coordinate_picker.gd")
            if CoordinatePicker:
                var picker = Node2D.new()
                picker.set_script(CoordinatePicker)
                picker.name = "GlobalCoordinatePicker"
                root.add_child(picker)
                print("[DEBUG SINGLETON] Created global coordinate picker")
                return true
    
    print("[DEBUG SINGLETON] Failed to create coordinate picker")
    return false

# Special function to toggle full view mode
func toggle_full_view():
    # Get current scene
    var scene = get_tree().get_current_scene()
    
    # Try to find or create debug manager
    var manager = get_or_create_debug_manager(scene)
    if manager and manager.has_method("toggle_full_view"):
        print("[DEBUG SINGLETON] Toggling full view via debug manager")
        manager.call("toggle_full_view")
        return true
    else:
        # Fallback for scenes without a debug manager
        # Find the camera directly
        var camera = find_camera(scene)
        if camera:
            print("[DEBUG SINGLETON] Toggling full view directly via camera")
            # Very simple implementation - toggle zoom between 1.0 and 3.0
            if camera.zoom.x < 2.0:
                # Zoomed in - zoom out to see more
                camera.zoom = Vector2(3.0, 3.0)
                print("[DEBUG SINGLETON] Camera zoomed out: zoom=", camera.zoom)
            else:
                # Zoomed out - zoom in to normal view
                camera.zoom = Vector2(1.0, 1.0)
                print("[DEBUG SINGLETON] Camera zoomed in: zoom=", camera.zoom)
            return true
    
    print("[DEBUG SINGLETON] Could not toggle full view - no camera found")
    return false

# Public API for enabling debug from any script
func enable_debug_tools(scene):
    print("[DEBUG SINGLETON] Enabling debug tools")
    var manager = get_or_create_debug_manager(scene)
    if manager:
        # Enable all debug tools for convenience
        if manager.has_method("toggle_coordinate_picker"):
            manager.call("toggle_coordinate_picker")
            print("[DEBUG SINGLETON] Enabled coordinate picker")
        if manager.has_method("toggle_polygon_visualizer"):
            manager.call("toggle_polygon_visualizer") 
            print("[DEBUG SINGLETON] Enabled polygon visualizer")
        return true
    return false

# Handle debug commands from console
func execute_command(command, args=[], scene=null):
    print("[DEBUG SINGLETON] Executing command: " + command + " with args: ", args)
    
    match command:
        "debug":
            # Get current scene if not provided
            if scene == null:
                scene = get_tree().get_current_scene()
                
            if args.size() == 0 or args[0] == "on":
                return enable_debug_tools(scene)
            elif args[0] == "off":
                if debug_manager != null and is_instance_valid(debug_manager):
                    debug_manager.queue_free()
                    debug_manager = null
                    return true
            # Handle specific debug toggles with enhanced typo tolerance
            elif args[0].find("coord") >= 0 or args[0].find("pick") >= 0:
                print("[DEBUG SINGLETON] Toggling coordinate picker via command: " + args[0])
                return toggle_coordinate_picker()
            elif args[0].find("full") >= 0 or args[0].find("view") >= 0:
                print("[DEBUG SINGLETON] Toggling full view via command: " + args[0])
                return toggle_full_view()
            # More commands can be added here as needed
    
    return false