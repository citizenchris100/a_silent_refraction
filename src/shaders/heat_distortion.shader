shader_type canvas_item;

// Heat/Steam distortion effect for A Silent Refraction
// Used near machinery, vents, engines, etc.

uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float distortion_speed : hint_range(0.1, 5.0) = 1.0;
uniform sampler2D noise_texture : hint_default_white; // Optional noise texture
uniform bool use_noise_texture = false;
uniform vec2 distortion_direction = vec2(0.0, 1.0); // Default upward distortion
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

// Parameters for adding a subtle haze/tint
uniform bool add_haze = false;
uniform vec4 haze_color : hint_color = vec4(1.0, 1.0, 1.0, 0.05);
uniform float haze_intensity : hint_range(0.0, 1.0) = 0.1;

// Generate procedural noise if no texture is provided
vec2 random(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    
    // Cubic Hermite curve
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    // 4 corners of the tile
    float a = dot(random(i), f);
    float b = dot(random(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(random(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(random(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    
    // Blend
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y) * 0.5 + 0.5;
}

void fragment() {
    // Calculate the distortion offset based on time and position
    vec2 uv = UV;
    
    // Choose between provided noise texture or procedural noise
    float noise_value;
    if (use_noise_texture) {
        // Sample the provided noise texture
        noise_value = texture(noise_texture, uv + TIME * 0.1 * time_scale).r;
    } else {
        // Generate procedural noise
        float scale = 5.0;
        noise_value = noise(uv * scale + TIME * distortion_speed * time_scale);
    }
    
    // Apply the distortion
    vec2 offset = distortion_direction * noise_value * distortion_strength;
    
    // Sample the main texture with the distorted UVs
    vec4 color = texture(TEXTURE, uv + offset);
    
    // Add subtle haze/tint if enabled
    if (add_haze) {
        float haze_factor = noise_value * haze_intensity;
        color.rgb = mix(color.rgb, haze_color.rgb, haze_factor);
    }
    
    COLOR = color;
}