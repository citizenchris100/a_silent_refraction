# Debug Tools Guide

This guide explains how to use the debug tools for "A Silent Refraction" to help with level design, debugging, and development.

## Introduction

The game includes a comprehensive debug toolset that allows you to:

1. Display real-time coordinates at any position
2. Visualize and edit polygon-based walkable areas
3. Monitor performance with FPS counter
4. Debug camera settings and positioning
5. Execute commands through an in-game console
6. Validate coordinates against walkable areas
7. Debug any scene in the game with customizable tools

## New Unified Debug System

As of May 2025, we've implemented a unified debug system that allows you to enable debug tools at runtime in any scene without modifying the scene files. This makes debugging more flexible and eliminates the need for hardcoded debug tools.

### Using the Debug Console

The easiest way to enable debug tools is through the debug console:

1. Press the `` ` `` (backtick/tilde) key to open the debug console
2. Type `debug on` to enable the debug manager
3. Use function keys to toggle specific tools:
   - **F1**: Toggle coordinate picker
   - **F2**: Toggle polygon visualizer
   - **F3**: Toggle debug console
   - **F4**: Toggle debug overlay
   - **Alt+W**: Toggle world view mode (was previously V key)

### Debug Command Options

The `debug` command supports several options:

```
debug on                  # Enable debug manager
debug off                 # Disable debug manager
debug status              # Show status of all debug tools
debug coordinates         # Toggle coordinate picker
debug polygon             # Toggle polygon visualizer
debug console            # Toggle debug console
debug overlay            # Toggle debug overlay
debug fullview           # Toggle world view mode (Alt+W)
debug worldview          # Toggle world view mode (Alt+W)
debug validate_walkable  # Validate coordinates against walkable areas
debug transform_coords   # Transform coordinates between view modes
```

### Adding Debug Manager Programmatically

You can also add the debug manager programmatically in any scene:

```gdscript
var DebugManager = load("res://src/core/debug/debug_manager.gd")
var debug_manager = DebugManager.add_to_scene(scene, camera)

# Optionally enable specific tools
debug_manager.toggle_coordinate_picker()
debug_manager.toggle_polygon_visualizer()
```

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

## Standardized Debug Groups

The debug system uses standardized group names to categorize and identify nodes for debugging purposes.

### Group Naming Convention

All debug groups follow these rules:

1. Start with the prefix `debug_` for easy identification
2. Use lowercase and underscores for consistent formatting
3. Names should be descriptive of the node's purpose
4. Singular form is used for consistency

### Standard Debug Groups

| Group Name | Purpose | Example Usage |
|------------|---------|---------------|
| `debug_walkable_area` | Defines walkable areas for player navigation | `area.add_to_group("debug_walkable_area")` |
| `debug_interactive` | Objects that can be interacted with | `object.add_to_group("debug_interactive")` |
| `debug_npc` | NPCs for debug tracking | `npc.add_to_group("debug_npc")` |
| `debug_camera` | Camera nodes that can be controlled in debug mode | `camera.add_to_group("debug_camera")` |
| `debug_boundary` | Boundaries/collision areas for debugging | `boundary.add_to_group("debug_boundary")` |
| `debug_trigger` | Event trigger areas | `trigger.add_to_group("debug_trigger")` |
| `debug_spawn_point` | Character/object spawn locations | `spawn.add_to_group("debug_spawn_point")` |
| `debug_visualizer` | Nodes that provide visual debugging | `visualizer.add_to_group("debug_visualizer")` |

### Using Debug Groups

```gdscript
# Adding a node to a debug group
node.add_to_group("debug_walkable_area")

# Finding nodes by debug group
var areas = get_tree().get_nodes_in_group("debug_walkable_area")
for area in areas:
    # Process each area
    print(area.name)

# Checking if a node is in a debug group
if node.is_in_group("debug_walkable_area"):
    # Perform debug operations
    pass
```

### Legacy Group Transition

For backward compatibility during the transition to standardized group names:

```gdscript
# Add to both old and new groups
node.add_to_group("walkable_area")         # Legacy name
node.add_to_group("debug_walkable_area")  # New standard name

# When checking for nodes
var areas = get_tree().get_nodes_in_group("debug_walkable_area")
if areas.empty():
    # Fall back to legacy group name
    areas = get_tree().get_nodes_in_group("walkable_area")
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
2. For capturing walkable area coordinates in camera tests, press 'Alt+W' first to see the full background
3. Click to capture a coordinate in full view mode
4. The coordinate will be displayed on screen and logged to a file
5. Press 'C' to copy the coordinate for use in your code
6. Press 'Alt+W' again to return to normal view when done with coordinate selection

#### View Mode Indicators:
The coordinate picker now shows the current view mode to help avoid confusion:
- When in World View mode, coordinates are labeled with "WORLD_VIEW"
- When in Game View mode, coordinates are labeled with "GAME_VIEW"
- This helps track which coordinates were captured in which view mode

#### CoordinateManager Integration:
The coordinate picker now uses the CoordinateManager singleton for more accurate transformations:
```gdscript
# Get world position using CoordinateManager
var world_pos = CoordinateManager.screen_to_world(click_pos)

# Store the current view mode for proper context
var current_view_mode = CoordinateManager.get_view_mode()
var mode_text = "WORLD_VIEW" if current_view_mode == CoordinateManager.ViewMode.WORLD_VIEW else "GAME_VIEW"

# Add coordinate to history with mode information
add_coordinate(world_pos, mode_text)
```

#### Log File Location:
Coordinates are automatically logged to a file at:
```
~/.local/share/godot/app_userdata/A Silent Refraction/logs/coordinates.log
```
This file contains all captured coordinates with timestamps and view mode information, which can be used as a reference when designing levels.

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

### Walkable Area Validator

The new walkable area validator tool helps confirm that coordinates are properly located within walkable areas, catching common errors in coordinate transformations and view modes.

#### Features:
- Validates points against all walkable areas in the current district
- Visualizes valid and invalid points with color-coding (green for valid, red for invalid)
- Shows the distance from invalid points to the nearest walkable area edge
- Transforms coordinates between World View and Game View modes automatically
- Displays detailed visualization of all walkable areas for reference

#### Usage through Debug Console:
```
debug validate_walkable Vector2(100,100) Vector2(500,500)
```

#### Usage in Code:
```gdscript
# Create and add the validator
var validator = ValidateWalkableArea.new()
add_child(validator)

# Define points to validate
var test_points = [
    Vector2(100, 100),
    Vector2(500, 500),
    Vector2(2000, 900)
]

# Validate points against walkable areas
var result = validator.validate(test_points)

# result will be true if all points are valid, false if any are invalid
print("All points valid: " + str(result))
```

#### View Mode Handling:
- The validator automatically detects the current view mode from CoordinateManager
- If in World View mode, coordinates are transformed to Game View for validation
- The validator displays a message indicating which transformations were applied
- This helps catch issues where coordinates were captured in one view mode but used in another

#### Visualization:
- Valid points are shown in green with coordinate information
- Invalid points are shown in red with distance to nearest walkable area
- A connecting line shows the path to the closest walkable area edge
- All walkable areas are displayed as semi-transparent polygons with vertex indicators

### FPS Counter

The FPS counter displays the current frame rate of the game, helping you to identify performance issues.

#### Controls:
- **F Key**: Toggle FPS counter visibility

#### Usage:
1. FPS is shown in the bottom-left corner of the screen
2. Numbers are color-coded: green indicates good performance
3. If FPS drops below target, investigate which game elements might be causing performance issues

### Camera Debug Tool

The camera debug tool displays information about the active camera and allows you to manipulate it.

#### Controls:
- **R Key**: Reset camera position and zoom

#### Usage:
1. Camera information is shown near the bottom of the screen
2. Current position and zoom level are displayed
3. Press R to reset the camera if it gets into an unusable state

### Coordinate Transformation Debug Tool

The coordinate transformation debug tool helps developers understand how coordinates are transformed between different spaces and view modes.

#### Features:
- Displays coordinate transformations in real-time
- Shows the effects of background_scale_factor on transformations
- Helps debug issues with walkable areas and camera positioning
- Visualizes the relationships between screen space, world space, and different view modes

#### Usage through Debug Console:
```
debug transform_coords Vector2(100,100)
```

This command performs these transformations:
1. Screen to world space in current view mode
2. World to screen space in current view mode
3. Current view mode to opposite view mode transformation
4. Round-trip transformation back to original coordinate

#### Visualization:
- Points are shown with connecting arrows indicating transformation direction
- Each point is labeled with its coordinate space and value
- The current view mode is displayed prominently
- Background scale factor effects are shown when applicable

### Debug Console

The debug console allows you to execute commands during gameplay.

#### Controls:
- **`/~ Key**: Toggle console visibility
- **Enter**: Execute command
- **Up/Down Arrows**: Navigate command history
- **ESC**: Close console

#### Available Commands:
- **help**: Show list of available commands
- **clear**: Clear the console output
- **print [text]**: Print text to the console
- **quit**: Exit the game
- **scene [path]**: Get current scene info or change scene
- **toggle_fps**: Toggle FPS display
- **set_zoom [level]**: Set camera zoom level
- **spawn_npc [type] [x] [y]**: Spawn an NPC at the specified position
- **validate_walkable Vector2(x,y) ...**: Validate coordinates against walkable areas
- **transform_coords Vector2(x,y)**: Show coordinate transformations between spaces and view modes

#### Usage:
1. Press ` or ~ to open the console
2. Type a command and press Enter to execute
3. Use Up/Down arrows to recall previous commands
4. Type 'help' for a list of available commands

## Universal Debug Mode

The universal debug mode allows you to load and debug any scene in the game.

### Features:
- Select any scene from a dropdown menu
- Enable/disable specific debug tools
- View scenes with debug overlays automatically added
- Switch between scenes without restarting
- All debug tools available in any scene

### How to Use:
1. Launch universal debug mode: `./a_silent_refraction.sh debug-universal`
2. Select which debug tools to enable (coordinate picker, polygon visualizer, etc.)
3. Select a scene from the dropdown list
4. Click "Load Scene" to load with debug tools active
5. Use the debug tools as described above
6. Click "Back" to return to the scene selector

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

3. **Performance Monitoring**:
   - Use the FPS counter during heavy scenes
   - Identify which objects cause frame rate drops
   - Test on different viewport sizes

4. **Camera Debugging**:
   - Use camera debug tool to understand positioning issues
   - Reset camera if zoom or position gets broken
   - Check camera bounds in different scenes

5. **Console Commands**:
   - Use the debug console for quick tests and fixes
   - Spawn NPCs to test interactions
   - Adjust camera settings on the fly

6. **Workflow for New Areas**:
   - Create your background image
   - Launch debug tools with `debug-universal`
   - Use coordinate picker to map out boundaries
   - Create a basic walkable area
   - Refine with the polygon editor
   - Test navigation and fine-tune

7. **Troubleshooting**:
   - If player gets stuck, check for narrow passages
   - If player walks through walls, fix polygon boundaries
   - Use Z/Y for undo/redo if you make mistakes
   - Use debug console to modify game state for testing

## Extending Debug Tools

The debug tools are modular and can be extended with new functionality:

### Using the New DebugManager (Recommended)

- Add the new debug manager to any scene:
  ```gdscript
  var DebugManager = load("res://src/core/debug/debug_manager.gd")
  var debug_manager = DebugManager.add_to_scene(scene, camera)
  ```

- Add custom commands to the debug console:
  ```gdscript
  var console = get_node("DebugConsole")
  console.register_command("my_command", funcref(self, "cmd_my_command"), "Command description")
  
  func cmd_my_command(args):
      # Handle command
      return "Command executed!"
  ```

- Create debug-only testing scenes

### Using Legacy Debug Tools (Deprecated)

> **DEPRECATION NOTICE**: The following components are deprecated and will be removed in a future update:
> - `debug_tools.gd` - Use `debug_manager.gd` instead
> - `debug_overlay.gd` - Use `debug_manager.gd` instead
>
> Please migrate to the new unified debug system described in the "New Unified Debug System" section.

- Legacy method to add debug tools to a scene:
  ```gdscript
  # DEPRECATED - Don't use in new code
  var debug_tools = load("res://src/core/debug/debug_tools.gd").new()
  add_child(debug_tools)
  debug_tools.initialize()
  ```

## Example: Creating a New Walkable Area

1. Create a new district with: `./a_silent_refraction.sh new-district example`
2. Debug the district: `./a_silent_refraction.sh debug-district example`
3. Use coordinate picker to identify boundaries
4. Switch to Add Mode (3) and create vertices along the floor
5. Switch to Move Mode (2) to refine positions
6. Press P to copy the polygon data
7. Paste into your district scene file

## Example: Setting Up Walkable Areas for Camera Tests

1. Run the camera test: `./a_silent_refraction.sh camera`
2. Press 'Alt+W' to toggle to world view mode (shows the entire background)
3. Click on the corners of the walkable floor area to capture coordinates
4. All coordinates will be saved to the log file at `~/.local/share/godot/app_userdata/A Silent Refraction/logs/coordinates.log`
5. Copy the coordinates from the log file
6. Use these coordinates in the `setup_walkable_area()` function of your scene
7. Validate the coordinates using the ValidateWalkableArea tool:
   ```gdscript
   # In debug console
   debug validate_walkable Vector2(234, 816) Vector2(-2, 826) Vector2(-2, 944) ...
   ```
8. Check that all points are valid (green) and properly located within the walkable area
9. Press 'Alt+W' again to return to normal view and test camera scrolling
10. Test the camera in all view positions (left, center, right) to ensure proper behavior

Note: When capturing coordinates for a walkable area, always use the 'Alt+W' key combination to see the full background first. This ensures you can define a walkable area that spans the entire scene, not just what's visible in the initial camera view.

## Example: Validating Walkable Area Coordinates

1. Run any scene with walkable areas
2. Open the debug console with the backtick key
3. Enable debug tools with `debug on`
4. Use the validate_walkable command:
   ```
   debug validate_walkable Vector2(234, 816) Vector2(-2, 826) Vector2(-2, 944) Vector2(4686, 944) Vector2(4676, 840) Vector2(3672, 854) Vector2(3186, 812) Vector2(1942, 802) Vector2(692, 851) Vector2(480, 889) Vector2(258, 871)
   ```
5. The validator will:
   - Show all walkable areas as semi-transparent green polygons
   - Show valid points in green with coordinate information
   - Show invalid points in red with distance to nearest walkable area
   - Apply necessary coordinate transformations based on current view mode
6. Check any invalid points and adjust them as needed
7. Update the coordinates in your setup_walkable_area() function

## Example: Testing Performance with FPS Counter

1. Launch any scene with debug tools
2. Press F to show the FPS counter
3. Move around the scene and observe performance
4. Use the debug console to spawn multiple NPCs: `spawn_npc security_officer 300 400`
5. Observe how FPS changes with more entities in the scene

## Conclusion

The debug tools provide a powerful suite of features to help with development, testing, and troubleshooting. With the new unified debug system, you can now:

1. Enable debug tools at runtime in any scene without modifying code
2. Toggle specific tools with function keys or console commands
3. Capture and export polygon data for walkable areas
4. View the entire background with the 'Alt+W' key combination in any scene
5. Add debugging to new scenes with a single line of code
6. Validate coordinates against walkable areas to catch common errors
7. Track which view mode coordinates were captured in
8. Visualize coordinate transformations between different spaces

The new unified system significantly improves the developer experience by providing consistent debug tools across all scenes. It eliminates redundancy, ensures proper camera integration, and provides a clean UI. The coordinate validation system helps avoid common errors with walkable areas and camera bounds.

Remember to use `debug on` in the console to enable debug tools when needed, and use function keys (F1-F4) to toggle specific tools. For creating walkable areas, the improved polygon handling, coordinate picking, and validation tools make level design much more efficient and less error-prone.

The CoordinateManager integration ensures that coordinates are properly transformed between different spaces and view modes, making the debug tools more reliable even in complex scenes with custom scaling factors.

Use these tools frequently during development to improve workflow and game quality.