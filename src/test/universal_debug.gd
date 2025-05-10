extends Node

# Universal Debug Scene
# Can load any scene in the game and add debug tools to it

# Configuration
export(String, FILE, "*.tscn") var target_scene_path = ""
export var auto_load_scene = true
export var debug_walkable_areas = true
export var debug_group = "walkable_area"

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
		
		# Add debug overlay
		var debug_script = load("res://src/core/debug/debug_overlay.gd")
		var debug_overlay = debug_script.new()
		debug_overlay.set("target_group", debug_group)
		scene_instance.add_child(debug_overlay)
		
		# Add to the scene container
		$SceneContainer.add_child(scene_instance)
		
		# Hide the scene selector
		$UI/SceneSelector.visible = false
		
		# Show scene name
		$UI/SceneName.text = "Current Scene: " + scene_path.replace("res://", "")
		$UI/SceneName.visible = true
		
		# Show back button
		$UI/BackButton.visible = true
		
		print("Scene loaded successfully")
		return true
	else:
		print("ERROR: Failed to load scene")
		return false

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