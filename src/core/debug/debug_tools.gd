extends Node

# Debug Tools Manager
# A utility class that provides debug tools for any scene
# Central manager for all debug functionality
#
# ======================================================================
# DEPRECATED: This class is deprecated in favor of debug_manager.gd
# Please use DebugManager.add_to_scene(scene, camera) instead, or use
# the debug console command: debug on
# ======================================================================
#
# This class will be removed in a future update. For new code, use:
# var DebugManager = load("res://src/core/debug/debug_manager.gd")
# var debug_manager = DebugManager.add_to_scene(get_tree().current_scene, camera)
#
# See the debug_tools.md documentation for details on the new system.
# ====================================================================

# Debug tool instances
var coordinate_picker
var polygon_visualizer
var fps_counter
var camera_debug
var debug_console

# Configuration options
export var enable_coordinate_picker = true
export var enable_polygon_visualizer = true
export var enable_fps_counter = true
export var enable_camera_debug = true
export var enable_debug_console = true
export var target_group = "walkable_area"

# Creates and attaches debug tools to the given parent node
# DEPRECATED: Please use DebugManager.add_to_scene(scene, camera) instead
static func add_debug_tools(parent, target_group = "walkable_area"):
    # Print deprecation warning
    push_warning("DEPRECATION NOTICE: debug_tools.gd is deprecated and will be removed in a future update.")
    push_warning("Please use debug_manager.gd instead: var debug_manager = DebugManager.add_to_scene(scene, camera)")
    
    # Try to use the new DebugManager if possible
    var DebugManager = load("res://src/core/debug/debug_manager.gd")
    if DebugManager:
        # Try to find a camera
        var camera = null
        for child in parent.get_children():
            if child is Camera2D:
                camera = child
                break
                
        # If we found a camera, use the DebugManager
        if camera:
            push_warning("Automatically redirecting to DebugManager.add_to_scene()")
            return DebugManager.add_to_scene(parent, camera)
    
    # Fallback to old behavior if we couldn't use DebugManager
    var debug_tools = Node.new()
    debug_tools.name = "DebugTools"
    debug_tools.set_script(load("res://src/core/debug/debug_tools.gd"))
    parent.add_child(debug_tools)
    
    # Initialize the tools
    debug_tools.initialize(target_group)
    
    return debug_tools

# Initialize the debug tools
func initialize(target_group = "walkable_area"):
    # Print deprecation warning
    push_warning("DEPRECATION NOTICE: debug_tools.gd is deprecated and will be removed in a future update.")
    push_warning("Please use debug_manager.gd instead: var debug_manager = DebugManager.add_to_scene(scene, camera)")
    push_warning("Or use the debug console command: debug on")
    
    print("Initializing debug tools...")
    
    # Create the CanvasLayer to ensure tools are drawn on top
    var canvas_layer = CanvasLayer.new()
    canvas_layer.name = "DebugLayer"
    canvas_layer.layer = 10  # Set to a high value to ensure it's on top
    add_child(canvas_layer)
    
    # Add coordinate picker if enabled
    if enable_coordinate_picker:
        add_coordinate_picker(canvas_layer)
    
    # Add polygon visualizer if enabled
    if enable_polygon_visualizer:
        add_polygon_visualizer(canvas_layer, target_group)
    
    # Add FPS counter if enabled
    if enable_fps_counter:
        add_fps_counter(canvas_layer)
    
    # Add camera debug tools if enabled
    if enable_camera_debug:
        add_camera_debug(canvas_layer)
    
    # Add debug console if enabled
    if enable_debug_console:
        add_debug_console(canvas_layer)
    
    # Add help label
    add_help_label(canvas_layer)
    
    print("Debug tools initialized successfully")
    print("Debug Controls:")
    print("1-5: Switch between editing modes")
    print("  1: View/Select Mode")
    print("  2: Move Mode (drag vertices)")
    print("  3: Add Mode (add new vertices)")
    print("  4: Delete Mode (remove vertices)")
    print("  5: Drag All Mode (move entire polygon)")
    print("H: Show/hide help overlay")
    print("P: Print/copy polygon data")
    print("C: Copy the last captured coordinate")
    print("F: Toggle FPS display")
    print("`/~: Toggle debug console")

# Add coordinate picker tool
func add_coordinate_picker(parent):
    # Create a Node2D
    coordinate_picker = Node2D.new()
    coordinate_picker.name = "CoordinatePicker"
    
    # Load the script
    var script = load("res://src/core/debug/coordinate_picker.gd")
    coordinate_picker.set_script(script)
    
    # Add to parent
    parent.add_child(coordinate_picker)

# Add polygon visualizer tool
func add_polygon_visualizer(parent, target_group):
    # Create a Node2D
    polygon_visualizer = Node2D.new()
    polygon_visualizer.name = "PolygonVisualizer"
    
    # Load the script
    var script = load("res://src/core/debug/polygon_visualizer.gd")
    polygon_visualizer.set_script(script)
    
    # Set the target group
    polygon_visualizer.target_group = target_group
    
    # Add to parent
    parent.add_child(polygon_visualizer)

# Add help label
func add_help_label(parent):
    var label = Label.new()
    label.name = "HelpLabel"
    label.rect_position = Vector2(10, 10)
    label.text = """Debug Tools:
1-5: Switch polygon editing modes
  1: View/Select Mode
  2: Move Mode (drag vertices)
  3: Add Mode (add new vertices)
  4: Delete Mode (remove vertices)
  5: Drag All Mode (move entire polygon)
H: Show/hide help overlay
P: Print/copy polygon data
C: Copy coordinates
F: Toggle FPS display
R: Reset camera position
`/~: Toggle debug console
ESC: Exit debug mode"""
    parent.add_child(label)

# Add FPS counter tool
func add_fps_counter(parent):
    # Create a Control node
    fps_counter = Control.new()
    fps_counter.name = "FPSCounter"
    fps_counter.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Create the label
    var label = Label.new()
    label.name = "FPSLabel"
    label.rect_position = Vector2(10, get_viewport().get_visible_rect().size.y - 30)
    label.add_color_override("font_color", Color(0, 1, 0))
    fps_counter.add_child(label)
    
    # Add to parent
    parent.add_child(fps_counter)
    
    # Setup process function
    fps_counter.set_script(GDScript.new())
    fps_counter.get_script().source_code = """
extends Control

var display_fps = true
var update_interval = 0.5  # Update every half second
var time_passed = 0

func _process(delta):
    if display_fps:
        time_passed += delta
        if time_passed >= update_interval:
            $FPSLabel.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
            $FPSLabel.visible = true
            time_passed = 0
    else:
        $FPSLabel.visible = false

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_F:
        display_fps = !display_fps
        print("FPS display " + ("enabled" if display_fps else "disabled"))
"""
    fps_counter.get_script().reload()

# Add camera debugging tools
func add_camera_debug(parent):
    # Create a Control node
    camera_debug = Control.new()
    camera_debug.name = "CameraDebug"
    camera_debug.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Create the label
    var label = Label.new()
    label.name = "CameraLabel"
    label.rect_position = Vector2(10, get_viewport().get_visible_rect().size.y - 50)
    label.add_color_override("font_color", Color(0, 1, 0))
    camera_debug.add_child(label)
    
    # Add to parent
    parent.add_child(camera_debug)
    
    # Setup process function
    camera_debug.set_script(GDScript.new())
    camera_debug.get_script().source_code = """
extends Control

var camera
var display_camera_info = true
var update_interval = 0.5  # Update every half second
var time_passed = 0

func _ready():
    # Try to find the camera
    yield(get_tree(), "idle_frame")
    find_camera()

func _process(delta):
    if !camera:
        find_camera()
        return
        
    if display_camera_info:
        time_passed += delta
        if time_passed >= update_interval:
            var pos = camera.global_position
            var zoom = camera.zoom if "zoom" in camera else Vector2(1, 1)
            $CameraLabel.text = "Camera: pos=(%d, %d) zoom=(%.2f, %.2f)" % [pos.x, pos.y, zoom.x, zoom.y]
            $CameraLabel.visible = true
            time_passed = 0
    else:
        $CameraLabel.visible = false

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_R:
        if camera:
            # Try to reset camera position
            print("Attempting to reset camera position")
            if "reset_position" in camera:
                print("Calling reset_position()")
                camera.reset_position()
            elif "reset_camera" in camera:
                print("Calling reset_camera()")
                camera.reset_camera()
            else:
                print("No reset method found in camera. Setting zoom to (1,1)")
                if "zoom" in camera:
                    camera.zoom = Vector2(1, 1)
                if "target_zoom" in camera:
                    camera.target_zoom = Vector2(1, 1)
                    
                # Default position reset
                if camera.get_parent() is Node2D:
                    var parent_pos = camera.get_parent().global_position
                    print("Resetting to parent position: " + str(parent_pos))
                    camera.global_position = parent_pos

func find_camera():
    camera = get_viewport().get_camera()  # Try the viewport camera first
    
    if !camera:
        # Find the first camera in the scene
        var cameras = get_tree().get_nodes_in_group("camera")
        if cameras.size() > 0:
            camera = cameras[0]
    
    if !camera:
        # Find any Camera2D node
        var cameras = get_tree().get_nodes_in_group("Camera2D")
        if cameras.size() > 0:
            camera = cameras[0]
            
    if camera:
        print("Camera found: " + camera.name)
    else:
        print("No camera found in scene")
"""
    camera_debug.get_script().reload()

# Add debug console
func add_debug_console(parent):
    # Create a CanvasLayer for the console
    debug_console = CanvasLayer.new()
    debug_console.name = "DebugConsole"
    debug_console.layer = 100  # Make sure it's on top of everything
    
    # Load the script
    var script = load("res://src/core/debug/debug_console.gd")
    debug_console.set_script(script)
    
    # Add to parent scene (not the parent container)
    get_tree().get_root().add_child(debug_console)