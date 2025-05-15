extends Node

# Universal Debug Scene
# Can load any scene in the game and add debug tools to it

# Configuration
export(String, FILE, "*.tscn") var target_scene_path = ""
export var auto_load_scene = true
export var debug_walkable_areas = true
export var debug_group = "walkable_area"

# Debug options
var enable_coordinate_picker = true
var enable_polygon_visualizer = true
var enable_fps_counter = true
var enable_camera_debug = true
var enable_debug_console = true

# UI elements
var scene_selector
var scene_list = []

func _ready():
	print("Universal Debug Scene Initialized")
	
	# Initialize UI
	initialize_ui()
	
	# Auto-load scene if specified
	if auto_load_scene and target_scene_path != "":
		load_scene(target_scene_path)
	else:
		# Show scene selector
		$UI/SceneSelector.visible = true

# Initialize UI elements
func initialize_ui():
	# Get the scene selector dropdown
	scene_selector = $UI/SceneSelector/OptionButton
	
	# Connect signals
	$UI/SceneSelector/LoadButton.connect("pressed", self, "_on_load_button_pressed")
	
	# Set initial debug options
	enable_coordinate_picker = $UI/SceneSelector/DebugOptions/CoordinatePickerCheck.pressed
	enable_polygon_visualizer = $UI/SceneSelector/DebugOptions/PolygonVisualizerCheck.pressed
	enable_fps_counter = $UI/SceneSelector/DebugOptions/FPSCounterCheck.pressed
	enable_camera_debug = $UI/SceneSelector/DebugOptions/CameraDebugCheck.pressed
	enable_debug_console = $UI/SceneSelector/DebugOptions/DebugConsoleCheck.pressed
	
	# Find all scenes in the project
	find_scenes()
	
	# Populate the dropdown
	populate_scene_list()

# Find all scenes in the project
func find_scenes():
	scene_list = []
	
	# Directories to search
	var dirs = ["res://src/districts", "res://src/core", "res://src/test"]
	
	for dir in dirs:
		var scene_files = find_scenes_in_dir(dir)
		for scene in scene_files:
			scene_list.append(scene)
	
	print("Found " + str(scene_list.size()) + " scenes")

# Find scenes in a directory recursively
func find_scenes_in_dir(path):
	var scenes = []
	var dir = Directory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + "/" + file_name
			
			if dir.current_is_dir():
				# Recursively process subdirectories
				var sub_scenes = find_scenes_in_dir(full_path)
				for scene in sub_scenes:
					scenes.append(scene)
			elif file_name.ends_with(".tscn"):
				# Found a scene
				scenes.append(full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return scenes

# Populate the scene selector dropdown
func populate_scene_list():
	scene_selector.clear()
	
	for i in range(scene_list.size()):
		var scene_path = scene_list[i]
		var display_name = scene_path.replace("res://", "")
		scene_selector.add_item(display_name, i)
		
		# Set selected item if it matches target_scene_path
		if scene_path == target_scene_path:
			scene_selector.select(i)

# Load a scene with debug tools
func load_scene(scene_path):
	print("Loading scene: " + scene_path)
	
	# Clean up any existing scene
	clean_up_loaded_scene()
	
	# Load and instance the scene
	var scene = load(scene_path)
	if scene:
		var scene_instance = scene.instance()
		
		# Add to the scene container first
		$SceneContainer.add_child(scene_instance)
		
		# Wait a frame for scene to initialize
		yield(get_tree(), "idle_frame")
		
		# Try to find a camera in the scene
		var camera = find_camera(scene_instance)
		if camera == null:
			print("WARNING: No camera found in scene. Debug tools may not function correctly.")
		
		# Add debug tools using the new DebugManager
		var DebugManager = load("res://src/core/debug/debug_manager.gd")
		var debug_manager = DebugManager.add_to_scene(scene_instance, camera)
		
		# Enable selected debug tools based on UI options
		if enable_coordinate_picker:
			debug_manager.toggle_coordinate_picker()
			
		if enable_polygon_visualizer:
			debug_manager.toggle_polygon_visualizer()
			
		if enable_debug_console:
			debug_manager.toggle_debug_console()
			
		# Hide the scene selector
		$UI/SceneSelector.visible = false
		
		# Show scene name
		$UI/SceneName.text = "Current Scene: " + scene_path.replace("res://", "")
		$UI/SceneName.visible = true
		
		# Show back button
		$UI/BackButton.visible = true
		
		print("Scene loaded successfully with the new DebugManager and the following tools:")
		print("- Coordinate Picker: " + str(enable_coordinate_picker))
		print("- Polygon Visualizer: " + str(enable_polygon_visualizer))
		print("- Debug Console: " + str(enable_debug_console))
		print("Press F1-F4 to toggle tools or use the debug console command")
		
		return true
	else:
		print("ERROR: Failed to load scene")
		return false
		
# Find a camera in the scene
func find_camera(node):
	# Check if this node is a camera
	if node is Camera2D and node.current:
		return node
	
	# Recursive search for camera
	for child in node.get_children():
		var camera = find_camera(child)
		if camera:
			return camera
	
	return null

# Clean up any loaded scene
func clean_up_loaded_scene():
	for child in $SceneContainer.get_children():
		child.queue_free()

# Called when the Load button is pressed
func _on_load_button_pressed():
	var selected_idx = scene_selector.get_selected_id()
	if selected_idx >= 0 and selected_idx < scene_list.size():
		var selected_scene = scene_list[selected_idx]
		load_scene(selected_scene)

# Called when the Back button is pressed
func _on_back_button_pressed():
	# Clean up the loaded scene
	clean_up_loaded_scene()
	
	# Show the scene selector
	$UI/SceneSelector.visible = true
	
	# Hide scene name and back button
	$UI/SceneName.visible = false
	$UI/BackButton.visible = false

# Debug option checkbox handlers
func _on_CoordinatePickerCheck_toggled(button_pressed):
	enable_coordinate_picker = button_pressed
	print("Coordinate Picker " + ("enabled" if button_pressed else "disabled"))

func _on_PolygonVisualizerCheck_toggled(button_pressed):
	enable_polygon_visualizer = button_pressed
	print("Polygon Visualizer " + ("enabled" if button_pressed else "disabled"))

func _on_FPSCounterCheck_toggled(button_pressed):
	enable_fps_counter = button_pressed
	print("FPS Counter " + ("enabled" if button_pressed else "disabled"))

func _on_CameraDebugCheck_toggled(button_pressed):
	enable_camera_debug = button_pressed
	print("Camera Debug " + ("enabled" if button_pressed else "disabled"))

func _on_DebugConsoleCheck_toggled(button_pressed):
	enable_debug_console = button_pressed
	print("Debug Console " + ("enabled" if button_pressed else "disabled"))