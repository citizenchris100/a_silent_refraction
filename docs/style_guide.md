# A Silent Refraction: Visual Style Guide

This document provides a comprehensive guide for the visual style of A Silent Refraction, including color palette guidelines, aesthetic principles, and district-specific design notes.

## 1. Core Aesthetic Philosophy

The game combines elements from:

* Total Recall (1990): Gritty Mars colonization, corporate intrigue
* Alien (1979): Isolated horror, industrial space aesthetic
* Blade Runner (1982): Neon-lit dystopia, moral ambiguity
* SCUMM Games (early 90s): Pixel art style, limited color palette

This creates a retro-futuristic space horror adventure with a distinct visual identity.

## 2. Color Palette

### Canonical Palette

The game uses the following 16-color palette throughout all environments and UI:

| Color | Hex Code | Description | Primary Usage |
|-------|----------|-------------|---------------|
| Dark Black | `#212225` | Deep shadows and outlines | UI borders, deep shadows |
| Dark Purple | `#29272c` | Space and darkness | Space backgrounds, shadows |
| Dark Brown | `#3c3537` | Industrial tones | Machine elements, dark areas |
| Medium Brown | `#494543` | Wood and aged materials | Furniture, structure elements |
| Tan Brown | `#58504b` | Natural surfaces | Floors, walls, terrain |
| Green-Gray | `#5e6259` | Utilitarian surfaces | Walls, industrial elements |
| Purple-Gray | `#726b73` | Cold metal and shadows | Metal surfaces, machinery |
| Rusty Pink | `#907577` | Oxidized metal | Rusty machinery, warning elements |
| Blue Gray | `#7b8e95` | Technical surfaces | Computer interfaces, tech elements |
| Muted Purple | `#b18da1` | Accent highlights | UI highlights, special elements |
| Warm Tan | `#c2a783` | Warm light sources | Lamps, warm accents |
| Pale Green | `#a9c2a4` | Alien presence | The "goo", alien elements |
| Light Gray | `#cec6c0` | Light surfaces | UI elements, bright surfaces |
| Warm Cream | `#e4d2c6` | Skin tones, warm light | Character skin, light sources |
| Pale Yellow | `#f3e9c4` | Bright highlights | UI focus, bright indicators |
| Pale Pink | `#fbede4` | Brightest elements | Highlights, bright UI elements |

### Color Rules

* All game assets must use only colors from this canonical palette
* Use dithering for gradients rather than smooth transitions
* Each district should have its own dominant color theme using palette subsets:
  * Shipping: Industrial browns and grays (`#3c3537`, `#494543`, `#58504b`, `#5e6259`)
  * Mall: Consumer purples and pinks with neon accents (`#726b73`, `#907577`, `#b18da1`)
  * Trading Floor: Financial greens and tans (`#5e6259`, `#a9c2a4`, `#c2a783`)
  * Barracks: Utilitarian grays and blues (`#5e6259`, `#726b73`, `#7b8e95`)
  * Engineering: Mechanical browns and warm accents (`#494543`, `#58504b`, `#c2a783`)

### Special Effect Colors

* The alien "goo" uses `#a9c2a4` (pale green) with dithered animation patterns
* Computer screens primarily use `#7b8e95` (blue gray) with `#f3e9c4` (pale yellow) for text
* Warning indicators use `#907577` (rusty pink) contrasted with `#f3e9c4` (pale yellow)

## 3. District-Specific Design Guidelines

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

**Key Visual Elements**:
- Large cargo containers and crates
- Loading machinery and conveyor belts
- Service corridors with industrial piping
- Warning signage and hazard markings
- Metallic surfaces with visible wear and tear

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

**Key Visual Elements**:
- Surveillance cameras and monitoring equipment
- Heavy security doors with electronic locks
- Sparse, utilitarian furniture
- Official signage and station regulations
- Holding cells with minimal furnishings

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

**Key Visual Elements**:
- Storefronts with varied displays
- Seating areas and small cafes
- Advertisement boards and digital displays
- Decorative elements attempting luxury
- Higher ceilings and more open spaces

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

**Key Visual Elements**:
- Trading terminals and financial displays
- More refined furniture and finishes
- Meeting rooms with glass partitions
- Digital charts and financial data
- Corporate branding and logos

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

**Key Visual Elements**:
- Standardized living quarters with basic furnishings
- Communal areas with seating
- Hallways with numbered rooms
- Personal touches in individual quarters
- Minimal decoration with functional focus

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

**Key Visual Elements**:
- Large machinery and system controls
- Exposed pipes and conduits
- Maintenance access panels
- Technical diagrams and schematics
- Steam and atmospheric effects

## 4. Animation and Effects Guidelines

### The "Goo" (Alien Substance)
- Base Color: Pale Green `#a9c2a4`
- Highlight: Pale Yellow `#f3e9c4`
- Shadow: Green-Gray `#5e6259`
- Animation: Pulsing pattern with dithering
- Subtle glow effect in darkened areas

### Computer Terminals
- Screen Background: Blue Gray `#7b8e95`
- Text: Pale Yellow `#f3e9c4`
- Terminal Frame: Dark Brown `#3c3537` or Purple-Gray `#726b73`
- Highlights: Pale Green `#a9c2a4` or Muted Purple `#b18da1`
- Animation: Flickering text, scrolling data

### Warning Indicators
- Primary: Rusty Pink `#907577`
- Contrast: Pale Yellow `#f3e9c4`
- Frame: Dark Brown `#3c3537`
- Animation: Flashing patterns, rotating lights

### Dithering Patterns

For gradients and transparency effects, use these recommended dithering patterns:

1. **Checkerboard** - Alternating two colors in a checkerboard pattern
2. **Horizontal Lines** - Alternating colors in horizontal lines
3. **Vertical Lines** - Alternating colors in vertical lines
4. **Bayer 2x2** - Standard ordered dithering matrix
5. **Stipple** - Random dot pattern

## 5. Implementation Guidelines

### Asset Creation Workflow

1. Sketch concepts using the full palette
2. Refine designs limiting to district-specific color subsets
3. Implement dithering for transitions and gradients
4. Add animated elements where appropriate
5. Test in-game to ensure cohesion with other district elements

### Technical Considerations

- All assets should be created at their final resolution without scaling
- Avoid anti-aliasing, using dithering instead for transitions
- Maintain pixel-perfect alignment in all assets
- Ensure readability of text against background colors
- Test all animations for visual clarity and performance

### Accessibility Considerations

Despite the limited palette, ensure:
- Text has sufficient contrast with backgrounds (use Pale Yellow on dark colors)
- Interactive elements are distinguishable by shape and color
- Important game elements don't rely solely on color differentiation