extends Node

# Debug Loader
# A utility class for attaching debug tools to any scene
# IMPORTANT: This is being updated to use the new debug_manager.gd and debug_singleton.gd
# and no longer relies on the deprecated debug_overlay.gd

# Scene cache
var _scene_cache = {}

# Debug manager reference
var debug_manager = null

# Configure debug settings
export var enabled = true
export var target_scene_path = ""
export var walkable_area_group = "debug_walkable_area" # Updated to use standardized group name

func _ready():
	print("Debug Loader initialized")
	
	# If we have a target scene, load it
	if target_scene_path != "":
		load_debug_scene(target_scene_path)

# Load a scene with debug tools
func load_debug_scene(scene_path):
	print("Loading scene with debug tools: " + scene_path)
	
	# Get the original scene
	var scene = _load_scene(scene_path)
	if not scene:
		print("ERROR: Failed to load scene: " + scene_path)
		return null
	
	# Instance the scene
	var scene_instance = scene.instance()
	
	# First try using the singleton if available
	var singleton = null
	if Engine.has_singleton("DebugSingleton") or has_node("/root/DebugSingleton"):
		# Use debug singleton to manage the debug tools
		singleton = get_node("/root/DebugSingleton")
		if singleton and singleton.has_method("enable_debug_tools"):
			# Add the scene to the current tree first
			add_child(scene_instance)
			# Then enable debug tools
			singleton.call("enable_debug_tools", scene_instance)
			print("Debug tools enabled via singleton for scene: " + scene_instance.name)
			return scene_instance
	
	# If singleton not available, use our own debug manager
	add_debug_manager(scene_instance)
	
	# Add the scene to the current tree
	add_child(scene_instance)
	
	return scene_instance

# Add debug manager to an existing scene instance
func add_debug_manager(scene_instance):
	# First find a camera in the scene
	var camera = find_camera(scene_instance)
	if not camera:
		push_error("Failed to find a camera in the scene")
		return null
	
	# Load the debug manager script
	var manager_script = load("res://src/core/debug/debug_manager.gd")
	if not manager_script:
		push_error("Failed to load debug_manager.gd")
		return null
	
	# Create the debug manager instance
	debug_manager = manager_script.new()
	debug_manager.name = "DebugManager"
	
	# Add it to the scene
	scene_instance.add_child(debug_manager)
	
	# Setup camera after adding to scene
	if debug_manager.has_method("setup_camera"):
		debug_manager.call("setup_camera", camera)
	
	# Enable key debug tools
	if debug_manager.has_method("toggle_polygon_visualizer"):
		debug_manager.call("toggle_polygon_visualizer")
		print("Polygon visualizer enabled for walkable area group: " + walkable_area_group)
	
	print("Debug manager added to scene: " + scene_instance.name)
	return debug_manager

# Helper function to load a scene
func _load_scene(path):
	# Check cache first
	if path in _scene_cache:
		return _scene_cache[path]
	
	# Load the scene
	var scene = load(path)
	if scene:
		_scene_cache[path] = scene
	
	return scene

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

# Static function to inject debug manager into any scene
static func inject_debug_manager(scene_instance, target_group = "debug_walkable_area"):
	# Check if we should use the DebugSingleton instead
	var singleton = null
	if Engine.has_singleton("DebugSingleton") or scene_instance.has_node("/root/DebugSingleton"):
		# Use debug singleton to manage the debug tools
		singleton = scene_instance.get_node("/root/DebugSingleton")
		if singleton and singleton.has_method("enable_debug_tools"):
			singleton.call("enable_debug_tools", scene_instance)
			print("Injected debug tools via singleton into: " + scene_instance.name)
			return true
	
	# Fall back to direct creation if singleton not available
	var manager_script = load("res://src/core/debug/debug_manager.gd")
	if not manager_script:
		push_error("Failed to load debug_manager.gd")
		return null
	
	# Create debug manager
	var debug_manager = DebugManager.add_to_scene(scene_instance, find_camera_static(scene_instance))
	if debug_manager:
		# Set properties and enable visualization
		if debug_manager.polygon_visualizer and target_group:
			debug_manager.polygon_visualizer.target_group = target_group
		
		print("Injected debug manager into: " + scene_instance.name)
		return debug_manager
	
	return null

# Static helper to find a camera
static func find_camera_static(node):
	# Check if this node is a camera
	if node is Camera2D and node.current:
		return node
	
	# Recursive search for a camera
	for child in node.get_children():
		var camera = find_camera_static(child)
		if camera:
			return camera
			
	return null