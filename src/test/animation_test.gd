extends Node2D

# Animation Test
# This scene tests the loading of animated elements to debug any issues

var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.25  # seconds between frames
var debug_label

func _ready():
	print("Animation Test Started")
	debug_label = $DebugLabel
	debug_label.text = "Loading frames..."
	
	# Try to test different paths to see which ones work
	test_texture_loading()
	
	# Try testing the animation element directly
	test_animation_element()

func _process(delta):
	# Update animation if frames were loaded
	if frames.size() > 0:
		animation_timer += delta
		if animation_timer >= frame_delay:
			animation_timer -= frame_delay
			current_frame = (current_frame + 1) % frames.size()
			$TestSprite.texture = frames[current_frame]
	
func test_texture_loading():
	var paths_to_test = [
		"res://src/assets/backgrounds/animated_elements/computer_terminal_shipping_main/frame_0.png",
		"res://assets/backgrounds/animated_elements/computer_terminal_shipping_main/frame_0.png",
		"res://src/assets/backgrounds/shipping_district_bg.png",
		"res://assets/backgrounds/shipping_district_bg.png"
	]
	
	debug_label.text = "Testing paths:\n"
	
	# Create a sprite to show the loaded texture
	var sprite = Sprite.new()
	sprite.name = "TestSprite"
	sprite.position = Vector2(300, 300)
	add_child(sprite)
	
	for path in paths_to_test:
		var texture = load(path)
		if texture:
			debug_label.text += "SUCCESS: " + path + "\n"
			# Add to frames array for animation if it's a frame
			if "frame_" in path:
				frames.append(texture)
			# Show the texture in the sprite
			sprite.texture = texture
		else:
			debug_label.text += "FAILED: " + path + "\n"
	
	debug_label.text += "\nLoaded " + str(frames.size()) + " frames."

func test_animation_element():
	# Try to instantiate an actual animated element
	var element_script_path = "res://src/assets/backgrounds/animated_elements/computer_terminal_shipping_main/computer_terminal.gd"
	var element_script = load(element_script_path)
	
	if element_script:
		debug_label.text += "\nSuccessfully loaded element script"
		var element = Sprite.new()
		element.set_script(element_script)
		element.position = Vector2(600, 300)
		add_child(element)
	else:
		debug_label.text += "\nFailed to load element script: " + element_script_path
		
	# Try direct access to the GD file
	var file = File.new()
	if file.file_exists(element_script_path):
		debug_label.text += "\nFile exists but couldn't be loaded as script"
	else:
		debug_label.text += "\nFile does not exist at: " + element_script_path