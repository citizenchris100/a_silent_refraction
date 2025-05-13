extends Node
class_name AnimatedBackgroundManager

# This class manages all animated background elements in a district
# It handles loading, updating, and controlling the animations

# Signal emitted when all elements are loaded
signal all_elements_loaded
# Signal emitted when an element's state changes
signal element_state_changed(element_id, state)

# Dictionary of all animated elements, organized by type and id
var elements = {}
# Path to configuration file
var config_path = ""
# Parent district
var district = null
# Flag to track if elements are currently loaded
var elements_loaded = false
# Root node for all animated elements
var elements_root = null

# Constructor
func _init(parent_district):
    district = parent_district
    elements_root = Node2D.new()
    elements_root.name = "AnimatedElements"
    district.add_child(elements_root)
    
# Load animated elements from a configuration file
func load_from_config(config_file_path):
    config_path = config_file_path
    
    # Create file access object
    var file = File.new()
    if not file.file_exists(config_path):
        print("WARNING: Animated elements config file not found at: " + config_path)
        return false
    
    # Open and read the file
    var error = file.open(config_path, File.READ)
    if error != OK:
        print("ERROR: Could not open animated elements config file: " + str(error))
        return false
    
    # Parse JSON
    var json_text = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_text)
    if json_result.error != OK:
        print("ERROR: Could not parse JSON in config file: " + str(json_result.error_string))
        return false
    
    # Load elements from config
    var config = json_result.result
    if not config.has("elements"):
        print("WARNING: Config file has no 'elements' array")
        return false
    
    # Clear existing elements
    clear_elements()
    
    # Load each element
    for element_data in config.elements:
        if not (element_data.has("type") and element_data.has("id") and element_data.has("position")):
            print("WARNING: Skipping element with missing required fields (type, id, position)")
            continue
        
        # Create the element
        add_element(
            element_data.type,
            element_data.id,
            Vector2(element_data.position.x, element_data.position.y),
            element_data.get("properties", {})
        )
    
    elements_loaded = true
    emit_signal("all_elements_loaded")
    return true

# Add a new animated element
func add_element(type, id, position, properties = {}):
    # Create unique key for this element
    var element_key = type + "_" + id
    
    # Check if element already exists
    if elements.has(element_key):
        print("WARNING: Element already exists: " + element_key)
        return null
    
    # Create the element node
    var element = create_element_node(type, id, position, properties)
    if not element:
        return null
    
    # Store the element
    elements[element_key] = element
    
    # Add to scene
    elements_root.add_child(element)
    
    print("Added animated element: " + element_key)
    return element

# Create an element node of a specific type
func create_element_node(type, id, position, properties):
    # The element's node type depends on the animation style
    # For simple animations, we use an AnimatedSprite
    var element = AnimatedSprite.new()
    element.name = type + "_" + id
    element.position = position
    
    # This method would normally load frames based on type
    # For now, we'll use a placeholder animation
    create_placeholder_animation(element, type, properties)
    
    return element

# Create a placeholder animation for development
func create_placeholder_animation(element, type, properties):
    # Create empty SpriteFrames resource
    var frames = SpriteFrames.new()
    frames.remove_animation("default")
    
    # Add animation 
    frames.add_animation("default")
    frames.set_animation_speed("default", 5) # 5 FPS
    
    # Create placeholder frames
    var colors = {
        "computer_terminal": Color(0.0, 0.5, 1.0),
        "steam_vent": Color(0.8, 0.8, 0.8),
        "warning_light": Color(1.0, 0.3, 0.0),
        "sliding_door": Color(0.5, 0.5, 0.5),
        "water_puddle": Color(0.0, 0.7, 1.0),
        "flickering_light": Color(1.0, 1.0, 0.8),
        "conveyor_belt": Color(0.6, 0.6, 0.6),
        "ventilation_fan": Color(0.4, 0.4, 0.4),
        "hologram_display": Color(0.0, 1.0, 0.8),
        "security_camera": Color(0.3, 0.3, 0.3)
    }
    
    # Default color if type not found
    var base_color = colors.get(type, Color(1.0, 0.0, 1.0))
    
    # Create two frames to alternate
    for i in range(2):
        var color = base_color
        # Make second frame slightly brighter
        if i == 1:
            color = Color(
                min(base_color.r + 0.2, 1.0),
                min(base_color.g + 0.2, 1.0),
                min(base_color.b + 0.2, 1.0)
            )
        
        # Create image
        var size = Vector2(32, 32)
        var image = Image.new()
        image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
        
        # Fill with color
        image.lock()
        for y in range(size.y):
            for x in range(size.x):
                image.set_pixel(x, y, color)
        image.unlock()
        
        # Convert to texture
        var texture = ImageTexture.new()
        texture.create_from_image(image)
        
        # Add to frames
        frames.add_frame("default", texture)
    
    # Set frames to element
    element.frames = frames
    element.playing = true
    
    return frames

# Get a specific element by type and id
func get_element(type, id):
    var element_key = type + "_" + id
    if elements.has(element_key):
        return elements[element_key]
    return null

# Get all elements of a specific type
func get_elements_by_type(type):
    var result = []
    for key in elements.keys():
        if key.begins_with(type + "_"):
            result.append(elements[key])
    return result

# Enable or disable all elements of a specific type
func toggle_elements_by_type(type, enabled):
    for element in get_elements_by_type(type):
        element.visible = enabled
        element.playing = enabled

# Clear all elements
func clear_elements():
    for key in elements.keys():
        if elements[key] != null and is_instance_valid(elements[key]):
            elements[key].queue_free()
    elements.clear()
    elements_loaded = false

# Handle district exit
func _on_district_exited():
    clear_elements()

# Get element properties (wrapper for API consistency)
func get_element_property(type, id, property):
    var element = get_element(type, id)
    if element and element.has_method("get_property"):
        return element.get_property(property)
    return null

# Set element property (wrapper for API consistency)
func set_element_property(type, id, property, value):
    var element = get_element(type, id)
    if element and element.has_method("set_property"):
        element.set_property(property, value)
        emit_signal("element_state_changed", type + "_" + id, property)
        return true
    return false

# Helper method to set up element interaction
func connect_element_interaction(type, id, target, method):
    var element = get_element(type, id)
    if element and element.has_signal("interaction"):
        element.connect("interaction", target, method)
        return true
    return false