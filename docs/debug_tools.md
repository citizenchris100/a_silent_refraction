# Debug Tools Guide

This guide explains how to use the debug tools for "A Silent Refraction" to help with level design, especially when defining walkable areas.

## Introduction

The game includes a comprehensive debug toolset that allows you to:

1. Display real-time coordinates at any position
2. Visualize and edit polygon-based walkable areas
3. Debug any scene in the game
4. Save your changes automatically

## Running Debug Tools

There are three ways to launch the debug tools:

```bash
# Basic debug tools with the shipping district
./a_silent_refraction.sh debug

# Universal debug scene with selector for all scenes
./a_silent_refraction.sh debug-universal

# Debug a specific district directly
./a_silent_refraction.sh debug-district shipping
```

## Available Debug Tools

### Coordinate Picker

The coordinate picker shows the exact coordinates of your mouse position and allows you to capture specific points.

#### Controls:
- **Left Click**: Capture a coordinate
- **C Key**: Copy the last captured coordinate to clipboard
- Coordinates are displayed in real-time and recorded in a history list

#### Usage:
1. Hover over the area you want to measure
2. Click to capture a coordinate
3. The coordinate will be displayed and logged to the console
4. Press 'C' to copy the coordinate for use in your code

### Polygon Visualizer and Editor

The polygon visualizer displays and allows editing of walkable areas and other polygon-based elements.

#### Editing Modes:
1. **View/Select Mode (1)**: Default mode that shows all vertices
2. **Move Mode (2)**: Click and drag vertices to reposition them
3. **Add Mode (3)**: Add new vertices between existing points
4. **Delete Mode (4)**: Remove vertices from the polygon
5. **Drag All Mode (5)**: Move the entire polygon at once

#### Controls:
- **Number Keys 1-5**: Switch between editing modes
- **H Key**: Show/hide help overlay with controls
- **P Key**: Print/copy the current polygon data to console and clipboard
- **Z Key**: Undo last change
- **Y Key**: Redo last undone change

#### Vertex Display:
- Each vertex shows its index and coordinates
- The selected vertex is highlighted in red
- All connections between vertices are shown

#### Using the Polygon Editor:

1. **Viewing Polygon Data**:
   - Press 'P' to output the exact polygon data
   - This will print to console and copy to clipboard in the format:
     ```
     polygon = PoolVector2Array(
        100, 200,
        300, 250,
        450, 300,
        ...
     )
     ```

2. **Moving Vertices**:
   - Switch to Move Mode (press '2')
   - Click and drag any vertex to a new position
   - The polygon will update in real-time

3. **Adding Vertices**:
   - Switch to Add Mode (press '3')
   - Click an existing vertex
   - Move to where you want to add a new point
   - Release to create the new vertex between the selected and next vertex

4. **Deleting Vertices**:
   - Switch to Delete Mode (press '4')
   - Click on a vertex to delete it
   - Note: A minimum of 3 vertices is required for a valid polygon

5. **Moving the Entire Polygon**:
   - Switch to Drag All Mode (press '5')
   - Click and drag anywhere on the polygon to move the entire shape

## Universal Debug Mode

The universal debug mode allows you to load and debug any scene in the game.

### Features:
- Select any scene from a dropdown menu
- View scenes with debug overlays automatically added
- Switch between scenes without restarting
- All debug tools available in any scene

### How to Use:
1. Launch universal debug mode: `./a_silent_refraction.sh debug-universal`
2. Select a scene from the dropdown list
3. Click "Load Scene" to load with debug tools active
4. Use the debug tools as described above
5. Click "Back" to return to the scene selector

## Debug Tips and Best Practices

1. **Creating Walkable Areas**:
   - Start with a basic rectangle
   - Use coordinate picker to find key points
   - Add vertices at corners and significant contour points
   - Refine with the polygon editor

2. **Efficient Walkable Areas**:
   - Use the minimum number of vertices needed
   - Make sure to close the polygon properly
   - Keep it slightly smaller than visible floor areas
   - Test with actual navigation

3. **Workflow for New Areas**:
   - Create your background image
   - Launch debug tools with `debug-universal`
   - Use coordinate picker to map out boundaries
   - Create a basic walkable area
   - Refine with the polygon editor
   - Test navigation and fine-tune

4. **Troubleshooting**:
   - If player gets stuck, check for narrow passages
   - If player walks through walls, fix polygon boundaries
   - Use Z/Y for undo/redo if you make mistakes

## Extending Debug Tools

The debug tools are modular and can be extended with new functionality:

- Add the debug overlay to any custom scene:
  ```gdscript
  var debug_overlay = load("res://src/core/debug/debug_overlay.gd").new()
  add_child(debug_overlay)
  ```

- Create debug-only testing scenes

## Example: Creating a New Walkable Area

1. Create a new district with: `./a_silent_refraction.sh new-district example`
2. Debug the district: `./a_silent_refraction.sh debug-district example`
3. Use coordinate picker to identify boundaries
4. Switch to Add Mode (3) and create vertices along the floor
5. Switch to Move Mode (2) to refine positions
6. Press P to copy the polygon data
7. Paste into your district scene file

## Conclusion

The debug tools make it easier to create and refine walkable areas and other polygon-based elements in the game. Use them frequently during level design to ensure accurate boundaries and smooth navigation.