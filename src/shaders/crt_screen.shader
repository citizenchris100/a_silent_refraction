shader_type canvas_item;

// CRT/Terminal screen effect for A Silent Refraction
// Used for computer terminals, security monitors, etc.

// Basic parameters
uniform float distortion : hint_range(0.0, 0.2) = 0.05;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float scanline_count : hint_range(10.0, 500.0) = 100.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.2;
uniform vec4 tint_color : hint_color = vec4(0.8, 1.0, 0.7, 1.0); // Default greenish CRT

// Advanced parameters 
uniform float static_noise : hint_range(0.0, 0.1) = 0.01;
uniform float flickering : hint_range(0.0, 0.1) = 0.03;
uniform float rgb_offset : hint_range(0.0, 5.0) = 0.5;
uniform bool pixelate = false;
uniform float pixel_size : hint_range(1.0, 10.0) = 1.0;

// Random function
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Apply pixelation if enabled
    vec2 uv = UV;
    if (pixelate) {
        uv = floor(uv * pixel_size) / pixel_size;
    }
    
    // Screen curve/distortion (barrel distortion)
    vec2 center_uv = uv * 2.0 - 1.0; // Convert to -1 to 1 range
    float distortion_factor = dot(center_uv, center_uv) * distortion;
    center_uv *= 1.0 + distortion_factor; // Apply quadratic distortion
    uv = (center_uv * 0.5 + 0.5); // Convert back to 0-1 range
    
    // Sample texture with chromatic aberration (RGB offset)
    float aberration = rgb_offset * 0.001;
    vec4 color_r = texture(TEXTURE, uv - vec2(aberration, 0.0));
    vec4 color_g = texture(TEXTURE, uv);
    vec4 color_b = texture(TEXTURE, uv + vec2(aberration, 0.0));
    
    vec4 final_color = vec4(color_r.r, color_g.g, color_b.b, color_g.a);
    
    // Out of bounds check (black beyond screen edges)
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        final_color = vec4(0.0, 0.0, 0.0, 1.0);
    }
    
    // Apply scanlines
    float scanline = sin(uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
    scanline = pow(scanline, 3.0) * scanline_intensity;
    final_color.rgb -= scanline;
    
    // Apply vignette (dark corners)
    float vignette = length(center_uv) * vignette_intensity;
    final_color.rgb *= 1.0 - vignette;
    
    // Apply color tint
    final_color.rgb = mix(final_color.rgb, tint_color.rgb, 0.2);
    
    // Apply noise
    float noise = random(UV + vec2(TIME * 0.01, TIME * 0.01)) * static_noise;
    final_color.rgb += noise;
    
    // Apply flickering
    float flicker = sin(TIME * 7.0) * 0.5 + 0.5;
    flicker = pow(flicker, 16.0) * flickering;
    final_color.rgb += flicker;
    
    // Add horizontal interference lines occasionally
    float interference = step(0.98, sin(TIME * 0.5) * 0.5 + 0.5) * step(0.9, random(vec2(TIME)));
    if (interference > 0.0) {
        float line_pos = fract(TIME) * 2.0;
        float line_width = 0.02;
        if (abs(uv.y - line_pos) < line_width) {
            final_color.rgb += 0.2;
        }
    }
    
    COLOR = final_color;
}