extends CanvasLayer

# Debug Console
# A console for executing debug commands with structured categories and command help
# Integrated with the command_system.gd for better organization

# Configuration
export var console_key = KEY_QUOTELEFT  # Default ` (backtick) key
export var history_size = 10
export var console_height = 300
export var enable_autocomplete = true

# Console UI
var console_container
var input_field
var output_text
var autocomplete_panel
var command_history = []
var history_position = -1

# Command system
var command_system
var current_autocomplete_options = []

# Console state
var console_visible = false

func _ready():
	# Initialize the command system
	command_system = load("res://src/core/debug/command_system.gd").new()
	
	# Setup UI
	create_console_ui()
	
	# Initialize command history
	command_history = []
	history_position = -1
	
	# Register basic commands
	var CommandCategory = command_system.CommandCategory
	
	# General commands
	command_system.register_command(
		"help", 
		funcref(self, "cmd_help"), 
		"Show available commands or get help for a specific command", 
		"help [command_name]", 
		CommandCategory.GENERAL
	)
	
	command_system.register_command(
		"clear", 
		funcref(self, "cmd_clear"), 
		"Clear the console output", 
		"clear", 
		CommandCategory.GENERAL
	)
	
	command_system.register_command(
		"print", 
		funcref(self, "cmd_print"), 
		"Print text to the console", 
		"print <text>", 
		CommandCategory.GENERAL
	)
	
	command_system.register_command(
		"quit", 
		funcref(self, "cmd_quit"), 
		"Exit the game", 
		"quit", 
		CommandCategory.SYSTEM, 
		["exit"]
	)
	
	# Scene commands
	command_system.register_command(
		"scene", 
		funcref(self, "cmd_scene"), 
		"View or change the current scene", 
		"scene [path_to_scene]", 
		CommandCategory.SCENE, 
		["change_scene"]
	)
	
	# Camera commands
	command_system.register_command(
		"set_zoom", 
		funcref(self, "cmd_set_zoom"), 
		"Set camera zoom level", 
		"set_zoom <zoom_level>", 
		CommandCategory.CAMERA, 
		["zoom"]
	)
	
	# Entity commands
	command_system.register_command(
		"spawn_npc", 
		funcref(self, "cmd_spawn_npc"), 
		"Spawn an NPC at the specified position", 
		"spawn_npc <type> [x] [y]", 
		CommandCategory.ENTITY, 
		["spawn", "create_npc"]
	)
	
	# Debug commands
	command_system.register_command(
		"debug", 
		funcref(self, "cmd_debug"), 
		"Toggle debug manager or specific debug tools", 
		"debug [on|off|status|tool_name]", 
		CommandCategory.DEBUG, 
		["dbg"]
	)
	
	# Register debug subcommands
	command_system.register_subcommand(
		"debug", "coordinates", 
		"Toggle the coordinate picker tool",
		"debug coordinates"
	)
	
	command_system.register_subcommand(
		"debug", "polygon", 
		"Toggle the polygon visualizer tool",
		"debug polygon"
	)
	
	command_system.register_subcommand(
		"debug", "console", 
		"Toggle the debug console tool",
		"debug console"
	)
	
	command_system.register_subcommand(
		"debug", "overlay", 
		"Toggle the debug overlay tool",
		"debug overlay"
	)
	
	command_system.register_subcommand(
		"debug", "fullview", 
		"Toggle the full view mode for debug tools",
		"debug fullview"
	)
	
	command_system.register_subcommand(
		"debug", "status", 
		"Show status of all debug tools",
		"debug status"
	)
	
	command_system.register_subcommand(
		"debug", "on", 
		"Enable the debug manager",
		"debug on"
	)
	
	command_system.register_subcommand(
		"debug", "off", 
		"Disable the debug manager",
		"debug off"
	)
	
	command_system.register_command(
		"toggle_fps", 
		funcref(self, "cmd_toggle_fps"), 
		"Toggle FPS counter display", 
		"toggle_fps", 
		CommandCategory.DEBUG, 
		["fps"]
	)
	
	# Initialize
	hide_console()
	
	print("Debug console initialized with command system - press ` to open")

func create_console_ui():
	# Create container
	console_container = Panel.new()
	console_container.name = "DebugConsole"
	console_container.rect_position = Vector2(0, 0)
	console_container.rect_size = Vector2(get_viewport().size.x, console_height)
	add_child(console_container)
	
	# Create output text
	output_text = RichTextLabel.new()
	output_text.name = "OutputText"
	output_text.rect_position = Vector2(10, 10)
	output_text.rect_size = Vector2(console_container.rect_size.x - 20, console_container.rect_size.y - 50)
	output_text.bbcode_enabled = true
	output_text.scroll_following = true
	console_container.add_child(output_text)
	
	# Create input field
	input_field = LineEdit.new()
	input_field.name = "InputField"
	input_field.rect_position = Vector2(10, console_container.rect_size.y - 35)
	input_field.rect_size = Vector2(console_container.rect_size.x - 20, 30)
	input_field.placeholder_text = "Enter command (type 'help' for available commands)"
	input_field.connect("text_entered", self, "_on_command_entered")
	input_field.connect("text_changed", self, "_on_input_text_changed")
	console_container.add_child(input_field)
	
	# Create autocomplete panel
	if enable_autocomplete:
		autocomplete_panel = PopupMenu.new()
		autocomplete_panel.name = "AutocompletePanel"
		autocomplete_panel.allow_search = true
		autocomplete_panel.connect("id_pressed", self, "_on_autocomplete_selected")
		console_container.add_child(autocomplete_panel)
	
	# Style the console
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.3)
	console_container.add_stylebox_override("panel", style)

func _input(event):
	# Toggle console on toggle_debug_console action (backtick key)
	if event.is_action_pressed("toggle_debug_console"):
		print("[DEBUG CONSOLE] Backtick key detected via input action")
		toggle_console()
		# Prevent event propagation
		get_tree().set_input_as_handled()
		
	# Fallback for direct key detection
	elif event is InputEventKey and event.pressed and event.scancode == KEY_QUOTELEFT:
		print("[DEBUG CONSOLE] Backtick key detected directly")
		toggle_console()
		# Prevent event propagation
		get_tree().set_input_as_handled()
	
	# Handle key navigation when console is visible
	if console_visible and event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_UP:   # Up arrow - previous command
				navigate_history(-1)
				get_tree().set_input_as_handled()
			KEY_DOWN: # Down arrow - next command
				navigate_history(1)
				get_tree().set_input_as_handled()
			KEY_ESCAPE: # Escape - hide console
				hide_console()
				get_tree().set_input_as_handled()
			KEY_TAB: # Tab - autocomplete
				if enable_autocomplete and !input_field.text.empty():
					perform_autocomplete()
					get_tree().set_input_as_handled()

func toggle_console():
	if console_visible:
		print("[DEBUG CONSOLE] Hiding debug console")
		hide_console()
	else:
		print("[DEBUG CONSOLE] Showing debug console")
		show_console()

func show_console():
	console_container.visible = true
	console_visible = true
	input_field.grab_focus()

func hide_console():
	console_container.visible = false
	console_visible = false

func _on_command_entered(text):
	if text.strip_edges() == "":
		return
	
	# Clear input
	input_field.text = ""
	
	# Hide autocomplete if visible
	if enable_autocomplete and autocomplete_panel.visible:
		autocomplete_panel.visible = false
	
	# Add to history
	add_to_history(text)
	
	# Print command
	print_output("> " + text, Color(1, 1, 0))
	
	# Parse and execute command
	execute_command(text)

func execute_command(command_text):
	var parts = command_text.strip_edges().split(" ", false)
	var command = parts[0].to_lower()
	
	# Remove the command from parts
	parts.remove(0)
	
	# Execute the command through the command system
	var result = command_system.execute(command, parts)
	
	# If result is a string, print it
	if result is String and result != "":
		print_output(result)

# Handle input text changes for autocomplete
func _on_input_text_changed(new_text):
	if enable_autocomplete and new_text.strip_edges() != "":
		update_autocomplete_options(new_text)
	else:
		hide_autocomplete()

# Perform autocompletion
func perform_autocomplete():
	var text = input_field.text.strip_edges()
	
	# If we have exactly one option, use it
	if current_autocomplete_options.size() == 1:
		var command = current_autocomplete_options[0].name
		input_field.text = command + " " 
		input_field.caret_position = input_field.text.length()
		hide_autocomplete()
	# Otherwise show the autocomplete panel
	elif current_autocomplete_options.size() > 1:
		show_autocomplete()
	
# Update autocomplete options based on current text
func update_autocomplete_options(text):
	var parts = text.split(" ", false)
	
	# Only provide autocomplete for commands, not arguments
	if parts.size() == 1:
		current_autocomplete_options = command_system.get_commands_by_partial_name(parts[0])
		
		if current_autocomplete_options.size() > 0:
			prepare_autocomplete_panel()
		else:
			hide_autocomplete()
	else:
		hide_autocomplete()

# Prepare the autocomplete panel with current options
func prepare_autocomplete_panel():
	if !enable_autocomplete or current_autocomplete_options.size() == 0:
		return
		
	autocomplete_panel.clear()
	
	for i in range(current_autocomplete_options.size()):
		var cmd = current_autocomplete_options[i]
		autocomplete_panel.add_item(cmd.name, i)
		
	# Only show if there's more than one option
	if current_autocomplete_options.size() > 1:
		show_autocomplete()
		
# Show the autocomplete panel
func show_autocomplete():
	if !enable_autocomplete or current_autocomplete_options.size() == 0:
		return
		
	var pos = input_field.rect_global_position
	pos.y += input_field.rect_size.y
	autocomplete_panel.rect_min_size = Vector2(input_field.rect_size.x, 200)
	autocomplete_panel.rect_position = pos
	autocomplete_panel.popup()

# Hide the autocomplete panel
func hide_autocomplete():
	if enable_autocomplete and autocomplete_panel.visible:
		autocomplete_panel.hide()

# Handle selecting an item from the autocomplete panel
func _on_autocomplete_selected(id):
	if id >= 0 and id < current_autocomplete_options.size():
		var cmd = current_autocomplete_options[id]
		input_field.text = cmd.name + " "
		input_field.caret_position = input_field.text.length()
		hide_autocomplete()

func add_to_history(command):
	if command_history.size() > 0 and command_history[0] == command:
		return  # Don't add duplicate consecutive commands
	
	command_history.push_front(command)
	
	if command_history.size() > history_size:
		command_history.pop_back()
	
	history_position = -1

func navigate_history(direction):
	if command_history.size() == 0:
		return
	
	# Update position
	history_position += direction
	
	# Clamp position
	if history_position < -1:
		history_position = -1
	elif history_position >= command_history.size():
		history_position = command_history.size() - 1
	
	# Update input field
	if history_position == -1:
		input_field.text = ""
	else:
		input_field.text = command_history[history_position]
		input_field.caret_position = input_field.text.length()

func print_output(text, color = Color(1, 1, 1)):
	var bbcode = "[color=#%s]%s[/color]" % [color.to_html(), text]
	output_text.bbcode_text += bbcode + "\n"

# Built-in commands
func cmd_help(args = []):
	# If no arguments, show all commands
	if args.size() == 0:
		return command_system.get_help_overview(true) # Show subcommands in overview
	
	# Otherwise, show help for the specified command
	return command_system.get_command_help(args[0])

func cmd_clear(_args = []):
	output_text.bbcode_text = ""
	return ""

func cmd_print(args):
	if args.size() == 0:
		return "Usage: print <text>"
	
	return args.join(" ")

func cmd_quit(_args = []):
	# Quit the game
	get_tree().quit()
	return "Quitting game..."

func cmd_scene(args):
	if args.size() == 0:
		var current_scene = get_tree().get_current_scene()
		return "Current scene: " + current_scene.name + " (" + current_scene.filename + ")"
	
	# Change scene
	var scene_path = args[0]
	if !scene_path.begins_with("res://"):
		scene_path = "res://" + scene_path
	
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene(scene_path)
		return "Changed scene to: " + scene_path
	else:
		return "Scene not found: " + scene_path

func cmd_toggle_fps(_args = []):
	# Find FPS counter tool
	var fps_counter = find_node_by_name(get_tree().get_root(), "FPSCounter")
	if fps_counter:
		# Simulate F key press to toggle FPS display
		var event = InputEventKey.new()
		event.scancode = KEY_F
		event.pressed = true
		fps_counter._input(event)
		return "FPS counter toggled"
	else:
		return "FPS counter not found"

func cmd_set_zoom(args):
	if args.size() == 0:
		return "Usage: set_zoom <zoom_level>"
	
	var zoom_level = float(args[0])
	var camera = get_viewport().get_camera()
	
	if camera and "zoom" in camera:
		camera.zoom = Vector2(zoom_level, zoom_level)
		return "Camera zoom set to " + args[0]
	else:
		return "No camera found or zoom property not available"

func cmd_spawn_npc(args):
	if args.size() == 0:
		return "Usage: spawn_npc <npc_type> [x] [y]"
	
	var npc_type = args[0]
	var pos_x = 500
	var pos_y = 300
	
	if args.size() >= 3:
		pos_x = int(args[1])
		pos_y = int(args[2])
	
	# Try to load the NPC script
	var script_path = "res://src/characters/npc/" + npc_type + ".gd"
	var script = load(script_path)
	
	if !script:
		return "NPC type not found: " + npc_type
	
	# Create NPC instance
	var npc = Node2D.new()
	npc.set_script(script)
	npc.position = Vector2(pos_x, pos_y)
	
	# Add to current scene
	get_tree().get_current_scene().add_child(npc)
	
	return "Spawned " + npc_type + " at position " + str(pos_x) + ", " + str(pos_y)

# Toggle debug manager tools
func cmd_debug(args):
	var current_scene = get_tree().get_current_scene()
	print("[DEBUG CONSOLE] Debug command received with args: ", args)
	
	# First look for the global debug singleton
	var debug_singleton = get_node_or_null("/root/DebugSingleton")
	
	if debug_singleton:
		print("[DEBUG CONSOLE] Using DebugSingleton")
		var result = debug_singleton.execute_command("debug", args, current_scene)
		if result:
			return "Debug tools " + ("enabled" if args.size() == 0 or args[0] == "on" else "disabled") + " via global singleton"
	
	# Fall back to the old way if singleton not available
	var debug_manager = current_scene.get_node_or_null("DebugManager")
	print("[DEBUG CONSOLE] Local DebugManager found: ", debug_manager != null)
	
	# Check if args specify on/off
	var turn_on = true
	if args.size() > 0:
		if args[0].to_lower() == "off":
			turn_on = false
		elif args[0].to_lower() != "on":
			return "Usage: debug [on|off|status|tool_name]"

	# Special case for 'status' argument
	if args.size() > 0 and args[0].to_lower() == "status":
		if debug_manager:
			var status = "Debug Manager Status:\n"
			status += "- Coordinate Picker: " + ("ON" if debug_manager.coordinate_picker_visible else "OFF") + "\n"
			status += "- Polygon Visualizer: " + ("ON" if debug_manager.polygon_visualizer_visible else "OFF") + "\n"
			status += "- Debug Console: " + ("ON" if debug_manager.console_visible else "OFF") + "\n"
			status += "- Debug Overlay: " + ("ON" if debug_manager.overlay_visible else "OFF") + "\n"
			status += "- Full View Mode: " + ("ON" if debug_manager.full_view_mode else "OFF")
			return status
		else:
			return "Debug Manager is not active in this scene"
	
	# Special case for specific tool toggling
	if args.size() > 0 and not (args[0].to_lower() == "on" or args[0].to_lower() == "off" or args[0].to_lower() == "status"):
		var tool_name = args[0].to_lower()
		
		if debug_manager == null:
			# Create debug manager first if requesting a specific tool
			debug_manager = create_debug_manager(current_scene)
			if debug_manager == null:
				return "Could not create Debug Manager - no camera found in scene"
		
		# Toggle the requested tool
		match tool_name:
			"coordinates", "coordinate", "picker":
				debug_manager.toggle_coordinate_picker()
				return "Toggled coordinate picker " + ("ON" if debug_manager.coordinate_picker_visible else "OFF")
			"polygon", "visualizer":
				debug_manager.toggle_polygon_visualizer()
				return "Toggled polygon visualizer " + ("ON" if debug_manager.polygon_visualizer_visible else "OFF")
			"console":
				debug_manager.toggle_debug_console()
				return "Toggled debug console " + ("ON" if debug_manager.console_visible else "OFF")
			"overlay":
				debug_manager.toggle_debug_overlay()
				return "Toggled debug overlay " + ("ON" if debug_manager.overlay_visible else "OFF")
			"fullview", "view":
				debug_manager.toggle_full_view()
				return "Toggled full view " + ("ON" if debug_manager.full_view_mode else "OFF")
			_:
				return "Unknown tool name. Available tools: coordinates, polygon, console, overlay, fullview"
		
	# Main debug manager toggle functionality
	if turn_on:
		if debug_manager:
			print("[DEBUG CONSOLE] Debug manager already active")
			return "Debug Manager is already active in this scene"
		else:
			# Try to create the debug manager
			print("[DEBUG CONSOLE] Creating debug manager")
			debug_manager = create_debug_manager(current_scene)
			if debug_manager:
				print("[DEBUG CONSOLE] Debug manager created successfully")
				return "Debug Manager added to scene. Use function keys (F1-F4) to toggle tools"
			else:
				print("[DEBUG CONSOLE] Failed to create debug manager - no camera found")
				return "Could not create Debug Manager - no camera found in scene"
	else:
		if debug_manager:
			debug_manager.queue_free()
			return "Debug Manager removed from scene"
		else:
			return "Debug Manager is not active in this scene"

# Helper function to create the debug manager
func create_debug_manager(scene):
	# Find a camera in the scene
	var camera = find_camera(scene)
	if camera:
		# Load debug manager script
		var debug_manager_script = load("res://src/core/debug/debug_manager.gd")
		if debug_manager_script:
			# Create a Node for the debug manager
			var debug_manager = Node.new()
			debug_manager.name = "DebugManager"
			debug_manager.set_script(debug_manager_script)
			scene.add_child(debug_manager)
			
			# Setup camera after adding to scene
			if debug_manager.has_method("setup_camera"):
				debug_manager.call("setup_camera", camera)
				print("[DEBUG CONSOLE] Debug manager created and connected to camera")
				return debug_manager
			else:
				print("[DEBUG CONSOLE] Debug manager doesn't have setup_camera method")
				debug_manager.queue_free()
		else:
			print("[DEBUG CONSOLE] Failed to load debug_manager.gd")
	else:
		print("[DEBUG CONSOLE] No camera found in scene")
	return null

# Find the main camera in a scene
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

# Utility function to find a node by name
func find_node_by_name(root, name):
	if root.name == name:
		return root
	
	for child in root.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null