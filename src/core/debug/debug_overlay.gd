extends CanvasLayer

# Debug Overlay System
# A modular system that can be attached to any scene to provide debug tools
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

# Components
var coordinate_picker
var polygon_visualizer

# Configuration
export var enabled = true
export var show_coordinate_picker = true
export var show_polygon_visualizer = true
export var target_group = "walkable_area"

# Keybindings
export var toggle_key = KEY_F3
export var help_key = KEY_F1

# Internal vars
var help_visible = false
var font

func _ready():
	# Print deprecation warning
	push_warning("DEPRECATION NOTICE: debug_overlay.gd is deprecated and will be removed in a future update.")
	push_warning("Please use debug_manager.gd instead: var debug_manager = DebugManager.add_to_scene(scene, camera)")
	push_warning("Or use the debug console command: debug on")
	
	# Set up debug layer
	layer = 100  # Top layer
	
	# Create font for help display
	font = DynamicFont.new()
	font.font_data = load("res://default_font.tres")
	font.size = 14
	
	# Initialize components if enabled
	if enabled:
		initialize_components()
		
	# Set up input processing
	set_process_input(true)
	set_process(true)
	
	print("Debug Overlay initialized. Press F1 for help.")

func initialize_components():
	# Initialize coordinate picker if enabled
	if show_coordinate_picker:
		coordinate_picker = Node2D.new()
		coordinate_picker.name = "CoordinatePicker"
		coordinate_picker.script = load("res://src/core/debug/coordinate_picker.gd")
		add_child(coordinate_picker)
	
	# Initialize polygon visualizer if enabled
	if show_polygon_visualizer:
		polygon_visualizer = Node2D.new()
		polygon_visualizer.name = "PolygonVisualizer"
		polygon_visualizer.script = load("res://src/core/debug/polygon_visualizer.gd")
		if target_group != "":
			polygon_visualizer.set("target_group", target_group)
		add_child(polygon_visualizer)

func _input(event):
	# Toggle debug overlay with F3
	if event is InputEventKey and event.pressed and event.scancode == toggle_key:
		enabled = !enabled
		
		# Remove all children if disabled
		if !enabled:
			for child in get_children():
				if child.name != "HelpText":  # Don't remove help text
					remove_child(child)
		else:
			initialize_components()
			
		print("Debug Overlay " + ("enabled" if enabled else "disabled"))
	
	# Toggle help text with F1
	if event is InputEventKey and event.pressed and event.scancode == help_key:
		help_visible = !help_visible
		update()

func _process(_delta):
	# Force redraw for help text
	if help_visible:
		update()

func _draw():
	# Draw help text if visible
	if help_visible:
		var text = """Debug Tools Help:
F1: Toggle this help
F3: Toggle debug overlay
Left Click: Capture coordinates
C: Copy last coordinate to clipboard
P: Print/copy current polygon data
"""
		
		# Draw background
		var y_offset = 100
		var line_height = 20
		var lines = text.split("\n")
		var max_width = 0
		for line in lines:
			max_width = max(max_width, line.length() * 8)
		
		draw_rect(Rect2(10, y_offset - 10, max_width + 20, (lines.size() + 1) * line_height), Color(0, 0, 0, 0.8))
		
		# Draw text
		for i in range(lines.size()):
			draw_string(font, Vector2(20, y_offset + i * line_height), lines[i], Color(1, 1, 0))

# Static method to easily add debug overlay to any scene
# DEPRECATED: Please use DebugManager.add_to_scene(scene, camera) instead
static func add_to_scene(scene):
	# Print deprecation warning
	push_warning("DEPRECATION NOTICE: debug_overlay.gd is deprecated and will be removed in a future update.")
	push_warning("Please use debug_manager.gd instead: var debug_manager = DebugManager.add_to_scene(scene, camera)")
	
	# Try to use the new DebugManager if possible
	var DebugManager = load("res://src/core/debug/debug_manager.gd")
	if DebugManager:
		# Try to find a camera
		var camera = null
		for child in scene.get_children():
			if child is Camera2D:
				camera = child
				break
				
		# If we found a camera, use the DebugManager
		if camera:
			push_warning("Automatically redirecting to DebugManager.add_to_scene()")
			return DebugManager.add_to_scene(scene, camera)
	
	# Check if the scene already has a debug overlay
	for child in scene.get_children():
		if child.get_class() == "DebugOverlay":
			return child
	
	# Create and add debug overlay (fallback)
	var debug_overlay = load("res://src/core/debug/debug_overlay.gd").new()
	debug_overlay.name = "DebugOverlay"
	scene.add_child(debug_overlay)
	return debug_overlay