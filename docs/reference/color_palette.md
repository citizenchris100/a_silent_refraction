# A Silent Refraction: Color Palette Guide
**Status: 📚 REFERENCE**

This document provides detailed information about the game's canonical 16-color palette and guidelines for using it in asset creation.

## Canonical 16-Color Palette

The entire game uses this fixed palette for all visuals. No additional colors should be introduced.

| Preview | Color Name | Hex Code | RGB | Description |
|:-------:|------------|----------|-----|-------------|
| ![](https://via.placeholder.com/30/212225/FFFFFF?text=+) | Dark Black | `#212225` | `33,34,37` | The darkest color, used for outlines, deep shadows, and UI borders |
| ![](https://via.placeholder.com/30/29272c/FFFFFF?text=+) | Dark Purple | `#29272c` | `41,39,44` | Used for deep space backgrounds, shadows, and dark areas |
| ![](https://via.placeholder.com/30/3c3537/FFFFFF?text=+) | Dark Brown | `#3c3537` | `60,53,55` | Industrial tones for machinery, dark metallic surfaces |
| ![](https://via.placeholder.com/30/494543/FFFFFF?text=+) | Medium Brown | `#494543` | `73,69,67` | Aged materials, standard wood, dull metal |
| ![](https://via.placeholder.com/30/58504b/FFFFFF?text=+) | Tan Brown | `#58504b` | `88,80,75` | Common surface material for floors, walls, terrain |
| ![](https://via.placeholder.com/30/5e6259/FFFFFF?text=+) | Green-Gray | `#5e6259` | `94,98,89` | Utilitarian surfaces, standard walls, industrial pipes |
| ![](https://via.placeholder.com/30/726b73/FFFFFF?text=+) | Purple-Gray | `#726b73` | `114,107,115` | Cold metal, machinery, shadow midtones |
| ![](https://via.placeholder.com/30/907577/FFFFFF?text=+) | Rusty Pink | `#907577` | `144,117,119` | Oxidized metal, warning indicators, Mars tones |
| ![](https://via.placeholder.com/30/7b8e95/FFFFFF?text=+) | Blue Gray | `#7b8e95` | `123,142,149` | Technical interfaces, computer screens, water |
| ![](https://via.placeholder.com/30/b18da1/FFFFFF?text=+) | Muted Purple | `#b18da1` | `177,141,161` | UI highlights, special elements, luxury surfaces |
| ![](https://via.placeholder.com/30/c2a783/FFFFFF?text=+) | Warm Tan | `#c2a783` | `194,167,131` | Warm light sources, lamps, leather, wood accents |
| ![](https://via.placeholder.com/30/a9c2a4/FFFFFF?text=+) | Pale Green | `#a9c2a4` | `169,194,164` | Alien presence, the "goo", plant life, sci-fi elements |
| ![](https://via.placeholder.com/30/cec6c0/FFFFFF?text=+) | Light Gray | `#cec6c0` | `206,198,192` | Light surfaces, paper, standard UI elements |
| ![](https://via.placeholder.com/30/e4d2c6/FFFFFF?text=+) | Warm Cream | `#e4d2c6` | `228,210,198` | Skin tones, warm light effects, illumination |
| ![](https://via.placeholder.com/30/f3e9c4/FFFFFF?text=+) | Pale Yellow | `#f3e9c4` | `243,233,196` | Bright highlights, UI focus elements, light sources |
| ![](https://via.placeholder.com/30/fbede4/FFFFFF?text=+) | Pale Pink | `#fbede4` | `251,237,228` | The brightest color, highlights, bright UI elements |

## District-Specific Color Schemes

Each district should primarily use a specific subset of the palette to create a unique visual identity:

### Shipping District
**Theme**: Industrial, utilitarian cargo area

**Primary Colors**:
- Dark Brown `#3c3537`
- Medium Brown `#494543`
- Tan Brown `#58504b`
- Green-Gray `#5e6259`

**Accent Colors**:
- Rusty Pink `#907577` (warning signs, equipment)
- Blue Gray `#7b8e95` (computer terminals)
- Warm Tan `#c2a783` (lights, crates)

### Security District
**Theme**: Institutional, authoritarian

**Primary Colors**:
- Dark Purple `#29272c`
- Dark Brown `#3c3537`
- Purple-Gray `#726b73`
- Blue Gray `#7b8e95`

**Accent Colors**:
- Rusty Pink `#907577` (alarms, warnings)
- Pale Yellow `#f3e9c4` (lights, indicators)

### Mall District
**Theme**: Commercial, neon-lit consumer space

**Primary Colors**:
- Purple-Gray `#726b73`
- Rusty Pink `#907577`
- Muted Purple `#b18da1`
- Light Gray `#cec6c0`

**Accent Colors**:
- Blue Gray `#7b8e95` (store signage)
- Pale Green `#a9c2a4` (plants, decorations)
- Pale Yellow `#f3e9c4` (advertisements, lights)

### Trading Floor District
**Theme**: Financial, institutional wealth

**Primary Colors**:
- Green-Gray `#5e6259`
- Blue Gray `#7b8e95`
- Pale Green `#a9c2a4`
- Warm Tan `#c2a783`

**Accent Colors**:
- Muted Purple `#b18da1` (luxury elements)
- Light Gray `#cec6c0` (papers, terminals)
- Pale Yellow `#f3e9c4` (indicators, displays)

### Barracks District
**Theme**: Utilitarian living quarters

**Primary Colors**:
- Medium Brown `#494543`
- Green-Gray `#5e6259`
- Purple-Gray `#726b73`
- Blue Gray `#7b8e95`

**Accent Colors**:
- Warm Tan `#c2a783` (furniture, personal items)
- Light Gray `#cec6c0` (bedding, utilities)
- Warm Cream `#e4d2c6` (skin tones)

### Engineering District
**Theme**: Mechanical, industrial infrastructure

**Primary Colors**:
- Dark Brown `#3c3537`
- Medium Brown `#494543`
- Tan Brown `#58504b`
- Warm Tan `#c2a783`

**Accent Colors**:
- Rusty Pink `#907577` (warning indicators, hot surfaces)
- Blue Gray `#7b8e95` (control panels)
- Pale Yellow `#f3e9c4` (caution stripes, lights)

## Special Elements

### The "Goo" (Alien Substance)
- Base Color: Pale Green `#a9c2a4`
- Highlight: Pale Yellow `#f3e9c4`
- Shadow: Green-Gray `#5e6259`
- Animation: Pulsing pattern with dithering

### Computer Terminals
- Screen Background: Blue Gray `#7b8e95`
- Text: Pale Yellow `#f3e9c4`
- Terminal Frame: Dark Brown `#3c3537` or Purple-Gray `#726b73`
- Highlights: Pale Green `#a9c2a4` or Muted Purple `#b18da1`

### Warning Indicators
- Primary: Rusty Pink `#907577`
- Contrast: Pale Yellow `#f3e9c4`
- Frame: Dark Brown `#3c3537`

## Using the Palette with the Animation Tools

When creating animated elements with the `create_animated_bg_elements.sh` tool, modify the color values to use the canonical palette:

```bash
# Example: Edit computer terminal in script to use canonical colors
convert "$output_dir/frame_${i}.png" \
    -fill "#7b8e95" -draw "rectangle 8,8 56,28" \
    -pointsize 6 -fill "#f3e9c4" -gravity center -annotate 0 "SYSTEM\nONLINE" \
    "$output_dir/frame_${i}.png"
```

## Dithering Patterns

For gradients and transparency effects, use these recommended dithering patterns:

1. **Checkerboard** - Alternating two colors in a checkerboard pattern
2. **Horizontal Lines** - Alternating colors in horizontal lines
3. **Vertical Lines** - Alternating colors in vertical lines
4. **Bayer 2x2** - Standard ordered dithering matrix
5. **Stipple** - Random dot pattern

## Creating Assets with the Palette

### Using ImageMagick

When creating assets with ImageMagick, always restrict to the palette colors:

```bash
# Create image using palette colors
convert -size 64x64 canvas:"#212225" \
    -fill "#494543" -draw "rectangle 4,4 60,60" \
    -fill "#7b8e95" -draw "rectangle 10,10 54,54" \
    -fill "#f3e9c4" -draw "circle 32,32 32,40" \
    output.png
```

### Using External Image Editors

When using external editors like GIMP, Aseprite, or Photoshop:

1. Set up a custom palette with the 16 colors
2. Configure the software to only use those colors
3. Use indexed color mode for strict palette adherence
4. Save in PNG format to preserve exact colors

## Best Practices

1. **Consistency**: Adhere strictly to the palette for all assets
2. **District Identity**: Respect district color themes for visual coherence
3. **Hierarchy**: Use darker colors for backgrounds, brighter for foregrounds
4. **Contrast**: Ensure readable contrast for UI and important elements
5. **Dithering**: Use dithering instead of anti-aliasing or alpha transparency

## Accessibility Considerations

Despite the limited palette, ensure:
- Text has sufficient contrast with backgrounds (use Pale Yellow on dark colors)
- Interactive elements are distinguishable by shape and color
- Important game elements don't rely solely on color differentiation

## Reference Images

To see the palette in action, refer to these reference assets:
- `/src/assets/backgrounds/animated_elements/` - Animated elements using the palette
- `/src/assets/ui/` - UI elements implementing the palette