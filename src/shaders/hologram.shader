shader_type canvas_item;

// Holographic display effect for A Silent Refraction
// Used in holographic terminals, security displays, etc.

// Basic parameters
uniform float scan_line_intensity : hint_range(0.0, 1.0) = 0.2;
uniform vec4 color : hint_color = vec4(0.0, 0.8, 1.0, 0.8);
uniform float flicker_intensity : hint_range(0.0, 0.1) = 0.03;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform float edge_glow : hint_range(0.0, 0.5) = 0.05;
uniform float noise_strength : hint_range(0.0, 0.1) = 0.01;

// Advanced parameters
uniform bool horizontal_distortion = true;
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.002;
uniform float interlace_intensity : hint_range(0.0, 1.0) = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Distortion effect (wobbly horizontal lines)
    vec2 uv = UV;
    if (horizontal_distortion) {
        float wave = sin(uv.y * 50.0 + TIME * time_scale) * distortion_strength;
        uv.x += wave;
    }
    
    // Base texture with distortion
    vec4 base_color = texture(TEXTURE, uv);
    
    // Scan lines
    float scan_line = sin(UV.y * 100.0 + TIME * time_scale) * 0.5 + 0.5;
    scan_line = pow(scan_line, 10.0) * scan_line_intensity;
    
    // Interlacing effect (every other line)
    float interlace = 0.0;
    if (interlace_intensity > 0.0) {
        interlace = step(0.5, fract(UV.y * 100.0)) * interlace_intensity;
    }
    
    // Flicker effect
    float flicker = sin(TIME * 10.0 * time_scale) * 0.5 + 0.5;
    flicker = pow(flicker, 16.0) * flicker_intensity;
    
    // Random noise for static effect
    float noise = random(UV + vec2(TIME * 0.01, TIME * 0.01)) * noise_strength;
    
    // Edge glow
    float edge = (1.0 - base_color.a) * edge_glow;
    
    // Final color
    COLOR = base_color;
    COLOR.rgb = mix(COLOR.rgb, color.rgb, 0.8); // Apply hologram color
    COLOR.rgb += vec3(scan_line); // Add scan lines
    COLOR.rgb -= vec3(interlace); // Subtract interlace darkening
    COLOR.rgb += vec3(flicker); // Add flicker
    COLOR.rgb += vec3(edge); // Add edge glow
    COLOR.rgb += vec3(noise); // Add static noise
    
    // Maintain original alpha for transparency
    COLOR.a = base_color.a;
}