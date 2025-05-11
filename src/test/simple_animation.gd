extends Node2D

# Basic animation test with manually created frames
var frames = []
var current_frame = 0
var animation_timer = 0.0
var frame_delay = 0.25
var sprite

func _ready():
    print("Simple animation test starting")
    
    # Create sprite to display
    sprite = Sprite.new()
    sprite.position = Vector2(400, 300)
    add_child(sprite)
    
    # Get the shipping district background that we know works
    var base_texture = load("res://src/assets/backgrounds/shipping_district_bg.png")
    if base_texture:
        print("Successfully loaded base texture")
        
        # Create frames by tinting the base texture differently
        create_animation_frames(base_texture)
        
        # Set initial frame
        if frames.size() > 0:
            sprite.texture = frames[0]
    else:
        print("Failed to load base texture")
    
    print("Simple animation setup complete")

# Create animation frames from base texture
func create_animation_frames(base_texture):
    var image = base_texture.get_data()
    
    # Create 5 tinted versions of the base image
    for i in range(5):
        # Create a duplicate of the base image
        var frame_image = Image.new()
        frame_image.copy_from(image)
        frame_image.lock()
        
        # Apply a tint based on the frame number
        for y in range(frame_image.get_height()):
            for x in range(frame_image.get_width()):
                var pixel = frame_image.get_pixel(x, y)
                
                # Adjust colors based on frame number
                match i:
                    0: # Normal
                        pass
                    1: # More red
                        pixel.r = min(pixel.r * 1.2, 1.0)
                    2: # More green
                        pixel.g = min(pixel.g * 1.2, 1.0)
                    3: # More blue
                        pixel.b = min(pixel.b * 1.2, 1.0)
                    4: # Darker
                        pixel.r *= 0.8
                        pixel.g *= 0.8
                        pixel.b *= 0.8
                
                frame_image.set_pixel(x, y, pixel)
        
        frame_image.unlock()
        
        # Convert back to texture
        var frame_texture = ImageTexture.new()
        frame_texture.create_from_image(frame_image)
        frames.append(frame_texture)
        
        print("Created frame " + str(i))

func _process(delta):
    # Animate through frames
    animation_timer += delta
    if animation_timer >= frame_delay:
        animation_timer -= frame_delay
        current_frame = (current_frame + 1) % frames.size()
        sprite.texture = frames[current_frame]