extends Node

# Debug Loader
# A utility class for attaching debug tools to any scene

# Scene cache
var _scene_cache = {}

# Debug layer
var debug_overlay = null

# Configure debug settings
export var enabled = true
export var target_scene_path = ""
export var walkable_area_group = "walkable_area"

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
	
	# Add debug overlay
	add_debug_overlay(scene_instance)
	
	# Add the scene to the current tree
	add_child(scene_instance)
	
	return scene_instance

# Add debug overlay to an existing scene instance
func add_debug_overlay(scene_instance):
	# Load the debug overlay script
	var overlay_script = load("res://src/core/debug/debug_overlay.gd")
	
	# Create the debug overlay instance
	debug_overlay = overlay_script.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.set("target_group", walkable_area_group)
	
	# Add it to the scene
	scene_instance.add_child(debug_overlay)
	
	print("Debug overlay added to scene: " + scene_instance.name)
	return debug_overlay

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

# Static function to inject debug overlay into any scene
static func inject_debug_overlay(scene_instance, target_group = "walkable_area"):
	# Create debug overlay script
	var overlay_script = load("res://src/core/debug/debug_overlay.gd")
	var debug_overlay = overlay_script.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.set("target_group", target_group)
	
	# Add to scene
	scene_instance.add_child(debug_overlay)
	
	print("Injected debug overlay into: " + scene_instance.name)
	return debug_overlay