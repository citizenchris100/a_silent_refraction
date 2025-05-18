extends Node2D

# WalkableAreaEditor: A dedicated debug tool for creating and editing walkable areas
# This tool provides a comprehensive interface for designing walkable areas with proper
# coordinate space awareness, validation, and automatic code generation.

# Signals
signal area_updated(polygon)
signal code_generated(code)

# Constants
const MIN_VERTICES = 3
const DEFAULT_COLOR = Color(0, 1, 0, 0.35)
const SELECTED_COLOR = Color(1, 0.5, 0, 0.5)
const HOVER_COLOR = Color(0.5, 0.5, 1, 0.5)
const INVALID_COLOR = Color(1, 0, 0, 0.5)
const VERTEX_SIZE = 10
const VERTEX_COLORS = {
    "normal": Color(0, 1, 0, 0.8),
    "selected": Color(1, 0.5, 0, 1),
    "hover": Color(0.5, 0.5, 1, 1),
    "world_view": Color(1, 1, 0, 0.8),
    "game_view": Color(0, 1, 1, 0.8)
}

# Editor modes
enum EditorMode {
    VIEW,       # View/select mode - observe and select vertices
    MOVE,       # Move mode - move selected vertices
    ADD,        # Add mode - add new vertices
    DELETE,     # Delete mode - remove vertices
    DRAG_ALL    # Drag all mode - move the entire polygon
}

# Coordinate capture mode
enum CaptureMode {
    WORLD_VIEW, # Capture in World View mode
    GAME_VIEW   # Capture in Game View mode
}

# Member variables
var current_mode = EditorMode.VIEW
var current_capture_mode = CaptureMode.WORLD_VIEW
var walkable_areas = []
var selected_area = null
var selected_vertex_idx = -1
var hover_vertex_idx = -1
var drag_start_pos = Vector2.ZERO
var original_polygon = PoolVector2Array()
var is_dragging = false
var show_help = true
var vertex_labels = []
var show_vertex_info = true
var snap_enabled = false
var snap_grid_size = 10
var undo_history = []
var redo_history = []
var max_history = 20
var modal_dialog = null
var district = null

# UI elements
var canvas_layer = null
var control_panel = null
var status_label = null
var mode_labels = []
var capture_mode_button = null
var code_output = null

func _ready():
    # Find the district
    find_district()
    
    # Set up UI
    setup_ui()
    
    # Find existing walkable areas
    find_walkable_areas()
    
    # Set up initial state
    set_mode(EditorMode.VIEW)
    
    print("Walkable Area Editor initialized")
    print("Press 1-5 to switch modes, H for help, P to generate code")

func _process(delta):
    update()  # Redraw the editor visuals every frame

func _draw():
    if walkable_areas.empty():
        return
        
    # Draw the walkable areas
    for i in range(walkable_areas.size()):
        var area = walkable_areas[i]
        var is_selected = area == selected_area
        var color = SELECTED_COLOR if is_selected else DEFAULT_COLOR
        
        # Draw the polygon
        draw_colored_polygon(area.polygon, color)
        
        # Draw outline
        var outline_points = area.polygon
        if outline_points.size() > 0:
            for i in range(outline_points.size()):
                var next_i = (i + 1) % outline_points.size()
                draw_line(outline_points[i], outline_points[next_i], Color(1, 1, 1, 0.8), 2)
        
        # Draw vertices
        for j in range(area.polygon.size()):
            var vertex_color = VERTEX_COLORS["normal"]
            
            # Different coloring based on view mode capture
            if show_vertex_info:
                if "captured_in_world_view" in area and area.captured_in_world_view:
                    vertex_color = VERTEX_COLORS["world_view"]
                else:
                    vertex_color = VERTEX_COLORS["game_view"]
            
            # Override color for selected and hover vertices
            if is_selected and j == selected_vertex_idx:
                vertex_color = VERTEX_COLORS["selected"]
            elif is_selected and j == hover_vertex_idx:
                vertex_color = VERTEX_COLORS["hover"]
                
            draw_circle(area.polygon[j], VERTEX_SIZE, vertex_color)
            
            # Draw vertex labels
            if show_vertex_info:
                var vertex_pos = area.polygon[j]
                draw_string(get_font("font", "Label"), vertex_pos + Vector2(15, 0), 
                            str(j) + ": " + str(vertex_pos), Color(1, 1, 1))
    
    # Draw help text if enabled
    if show_help:
        var help_text = [
            "Walkable Area Editor Controls:",
            "1: View/Select Mode - Select vertices",
            "2: Move Mode - Move selected vertices",
            "3: Add Mode - Add new vertices",
            "4: Delete Mode - Delete vertices",
            "5: Drag All Mode - Move entire polygon",
            "H: Toggle this help text",
            "P: Generate GDScript code",
            "C: Toggle capture mode (World View / Game View)",
            "S: Toggle snap to grid",
            "V: Toggle vertex info display",
            "Z: Undo",
            "Y: Redo",
            "T: Test walkable area (validate)",
            "Del: Delete selected area"
        ]
        
        var font = get_font("font", "Label")
        var y_offset = 40
        for line in help_text:
            draw_string(font, Vector2(20, y_offset), line, Color(1, 1, 0))
            y_offset += 20

func _input(event):
    # Process keyboard input
    if event is InputEventKey and event.pressed:
        match event.scancode:
            KEY_1:
                set_mode(EditorMode.VIEW)
            KEY_2:
                set_mode(EditorMode.MOVE)
            KEY_3:
                set_mode(EditorMode.ADD)
            KEY_4:
                set_mode(EditorMode.DELETE)
            KEY_5:
                set_mode(EditorMode.DRAG_ALL)
            KEY_H:
                show_help = !show_help
                update()
            KEY_P:
                generate_code()
            KEY_C:
                toggle_capture_mode()
            KEY_S:
                toggle_snap()
            KEY_V:
                show_vertex_info = !show_vertex_info
                update()
            KEY_Z:
                undo()
            KEY_Y:
                redo()
            KEY_T:
                test_walkable_area()
            KEY_DELETE:
                delete_selected_area()
    
    # Process mouse input
    if event is InputEventMouseButton:
        var mouse_pos = get_global_mouse_position()
        
        if event.pressed and event.button_index == BUTTON_LEFT:
            # Left mouse button pressed
            handle_left_mouse_pressed(mouse_pos)
        elif !event.pressed and event.button_index == BUTTON_LEFT:
            # Left mouse button released
            handle_left_mouse_released(mouse_pos)
    
    # Process mouse motion
    if event is InputEventMouseMotion:
        var mouse_pos = get_global_mouse_position()
        handle_mouse_motion(mouse_pos)

func handle_left_mouse_pressed(mouse_pos):
    drag_start_pos = mouse_pos
    is_dragging = true
    
    match current_mode:
        EditorMode.VIEW:
            # Select vertex or area
            select_vertex_or_area(mouse_pos)
        
        EditorMode.MOVE:
            # Start moving a vertex
            if selected_area and selected_vertex_idx >= 0:
                # Save state for undo
                save_state_for_undo()
                
                # Start drag operation
                original_polygon = selected_area.polygon.duplicate()
        
        EditorMode.ADD:
            # Start adding a vertex
            if selected_area:
                # Save state for undo
                save_state_for_undo()
                
                # Find the closest edge
                var closest_edge = find_closest_edge(mouse_pos)
                if closest_edge.valid:
                    # Add a new vertex between the two vertices of the closest edge
                    var new_polygon = selected_area.polygon.duplicate()
                    new_polygon.insert(closest_edge.next_idx, mouse_pos)
                    selected_area.polygon = new_polygon
                    selected_vertex_idx = closest_edge.next_idx
                    emit_signal("area_updated", selected_area.polygon)
        
        EditorMode.DELETE:
            # Delete a vertex
            if selected_area and selected_vertex_idx >= 0:
                # Ensure we have at least MIN_VERTICES vertices
                if selected_area.polygon.size() > MIN_VERTICES:
                    # Save state for undo
                    save_state_for_undo()
                    
                    # Remove the selected vertex
                    var new_polygon = selected_area.polygon.duplicate()
                    new_polygon.remove(selected_vertex_idx)
                    selected_area.polygon = new_polygon
                    selected_vertex_idx = -1
                    emit_signal("area_updated", selected_area.polygon)
                else:
                    print("Cannot delete vertex: minimum " + str(MIN_VERTICES) + " vertices required")
        
        EditorMode.DRAG_ALL:
            # Start dragging the entire polygon
            if selected_area:
                # Save state for undo
                save_state_for_undo()
                
                # Store the original polygon
                original_polygon = selected_area.polygon.duplicate()

func handle_left_mouse_released(mouse_pos):
    is_dragging = false
    
    # Finish any drag operations
    if selected_area:
        match current_mode:
            EditorMode.MOVE, EditorMode.DRAG_ALL:
                # Update the selected area
                emit_signal("area_updated", selected_area.polygon)

func handle_mouse_motion(mouse_pos):
    # Update hover state
    hover_vertex_idx = -1
    if selected_area:
        for i in range(selected_area.polygon.size()):
            var vertex = selected_area.polygon[i]
            if vertex.distance_to(mouse_pos) < VERTEX_SIZE * 1.5:
                hover_vertex_idx = i
                break
    
    # Handle drag operations
    if is_dragging and selected_area:
        match current_mode:
            EditorMode.MOVE:
                # Move the selected vertex
                if selected_vertex_idx >= 0:
                    var new_polygon = selected_area.polygon.duplicate()
                    var new_pos = mouse_pos
                    if snap_enabled:
                        new_pos = snap_to_grid(new_pos)
                    new_polygon[selected_vertex_idx] = new_pos
                    selected_area.polygon = new_polygon
            
            EditorMode.DRAG_ALL:
                # Move the entire polygon
                var offset = mouse_pos - drag_start_pos
                var new_polygon = PoolVector2Array()
                for i in range(original_polygon.size()):
                    var new_pos = original_polygon[i] + offset
                    if snap_enabled:
                        new_pos = snap_to_grid(new_pos)
                    new_polygon.append(new_pos)
                selected_area.polygon = new_polygon
    
    update()

func select_vertex_or_area(mouse_pos):
    # First, try to select a vertex
    if selected_area:
        for i in range(selected_area.polygon.size()):
            var vertex = selected_area.polygon[i]
            if vertex.distance_to(mouse_pos) < VERTEX_SIZE * 1.5:
                selected_vertex_idx = i
                update_status("Selected vertex " + str(i) + " at " + str(vertex))
                return
    
    # If no vertex selected, try to select an area
    selected_vertex_idx = -1
    selected_area = null
    
    # Check each walkable area
    for area in walkable_areas:
        if is_point_in_polygon(mouse_pos, area.polygon):
            selected_area = area
            update_status("Selected walkable area: " + area.name)
            return
    
    update_status("No walkable area selected")

func set_mode(mode):
    current_mode = mode
    
    # Update UI to show current mode
    if status_label:
        var mode_names = ["View/Select", "Move", "Add", "Delete", "Drag All"]
        status_label.text = "Mode: " + mode_names[mode]
    
    # Update mode button highlights
    for i in range(mode_labels.size()):
        var is_selected = i == mode
        mode_labels[i].add_color_override("font_color", Color(1, 1, 0) if is_selected else Color(1, 1, 1))
        mode_labels[i].add_color_override("font_color_shadow", Color(0, 0, 0, 1) if is_selected else Color(0, 0, 0, 0))
    
    update_status("Switched to " + ["View/Select", "Move", "Add", "Delete", "Drag All"][mode] + " mode")

func toggle_capture_mode():
    current_capture_mode = CaptureMode.GAME_VIEW if current_capture_mode == CaptureMode.WORLD_VIEW else CaptureMode.WORLD_VIEW
    
    # Update capture mode button
    if capture_mode_button:
        capture_mode_button.text = "Capture Mode: " + ["WORLD_VIEW", "GAME_VIEW"][current_capture_mode]
    
    # If we have a selected area, update its capture mode
    if selected_area:
        selected_area.captured_in_world_view = (current_capture_mode == CaptureMode.WORLD_VIEW)
    
    update_status("Capture mode set to " + ["WORLD_VIEW", "GAME_VIEW"][current_capture_mode])

func toggle_snap():
    snap_enabled = !snap_enabled
    update_status("Snap to grid: " + ("Enabled" if snap_enabled else "Disabled"))

func snap_to_grid(pos):
    return Vector2(
        round(pos.x / snap_grid_size) * snap_grid_size,
        round(pos.y / snap_grid_size) * snap_grid_size
    )

func find_closest_edge(pos):
    var result = {"valid": false, "distance": INF, "next_idx": -1}
    
    if not selected_area or selected_area.polygon.size() < 2:
        return result
    
    for i in range(selected_area.polygon.size()):
        var next_i = (i + 1) % selected_area.polygon.size()
        var p1 = selected_area.polygon[i]
        var p2 = selected_area.polygon[next_i]
        
        var closest = get_closest_point_on_line_segment(pos, p1, p2)
        var distance = pos.distance_to(closest)
        
        if distance < result.distance:
            result.valid = true
            result.distance = distance
            result.next_idx = next_i
            result.point = closest
    
    return result

func get_closest_point_on_line_segment(p, v, w):
    var l2 = v.distance_squared_to(w)
    if l2 == 0:
        return v
    
    var t = max(0, min(1, (p - v).dot(w - v) / l2))
    var projection = v + t * (w - v)
    return projection

func is_point_in_polygon(point, polygon):
    if polygon.size() < 3:
        return false
    
    return Geometry.is_point_in_polygon(point, polygon)

func find_district():
    # Try to find a BaseDistrict in the scene hierarchy
    var parent = get_parent()
    while parent:
        if parent is BaseDistrict:
            district = parent
            print("Found district: " + district.district_name)
            
            # Update the CoordinateManager with the current district
            CoordinateManager.set_current_district(district)
            return
        parent = parent.get_parent()
    
    # If not found as a parent, try to find in the current scene
    var current_scene = get_tree().get_current_scene()
    if current_scene is BaseDistrict:
        district = current_scene
        print("Found district as current scene: " + district.district_name)
        
        # Update the CoordinateManager with the current district
        CoordinateManager.set_current_district(district)
    else:
        print("WARNING: No district found, some features may not work correctly")

func find_walkable_areas():
    walkable_areas.clear()
    
    # Find all walkable areas in the current scene
    var areas = []
    
    # First try designer_walkable_area
    areas = get_tree().get_nodes_in_group("designer_walkable_area")
    
    # If none found, try regular walkable_area
    if areas.empty():
        areas = get_tree().get_nodes_in_group("walkable_area")
    
    # Process found areas
    for area in areas:
        if area is Polygon2D and area.polygon.size() >= MIN_VERTICES:
            # Check if the area has view mode information
            if not "captured_in_world_view" in area:
                # Default to current capture mode
                area.captured_in_world_view = (current_capture_mode == CaptureMode.WORLD_VIEW)
            
            walkable_areas.append(area)
    
    print("Found " + str(walkable_areas.size()) + " walkable areas")
    
    # If no areas found, create a default one
    if walkable_areas.empty() and district:
        create_default_walkable_area()

func create_default_walkable_area():
    # Create a default walkable area with a simple rectangle
    var walkable = Polygon2D.new()
    walkable.name = "WalkableArea"
    walkable.color = DEFAULT_COLOR
    
    # Create a reasonable rectangle in the middle of the viewport
    var size = get_viewport_rect().size
    var margin = size.x * 0.1
    walkable.polygon = PoolVector2Array([
        Vector2(margin, size.y * 0.7),
        Vector2(size.x - margin, size.y * 0.7),
        Vector2(size.x - margin, size.y * 0.9),
        Vector2(margin, size.y * 0.9)
    ])
    
    # Add to groups
    walkable.add_to_group("designer_walkable_area")
    walkable.add_to_group("walkable_area")
    
    # Add capture mode information
    walkable.captured_in_world_view = (current_capture_mode == CaptureMode.WORLD_VIEW)
    
    # Add to the scene
    if district:
        district.add_child(walkable)
    else:
        get_tree().get_current_scene().add_child(walkable)
    
    walkable_areas.append(walkable)
    selected_area = walkable
    
    print("Created default walkable area")

func generate_code():
    if selected_area == null:
        update_status("No walkable area selected")
        return
    
    # Generate GDScript code for the selected walkable area
    var code = "func setup_walkable_area():\n"
    code += "    var walkable = Polygon2D.new()\n"
    code += "    walkable.name = \"" + selected_area.name + "\"\n"
    code += "    walkable.color = Color(0, 1, 0, 0.35)  # Semi-transparent green\n"
    
    # Add comment about the view mode
    code += "    \n"
    code += "    # NOTE: These coordinates were captured in " + ("WORLD_VIEW" if selected_area.captured_in_world_view else "GAME_VIEW") + " mode\n"
    
    # Add the polygon coordinates
    code += "    walkable.polygon = PoolVector2Array([\n"
    for i in range(selected_area.polygon.size()):
        var point = selected_area.polygon[i]
        var comment = ""
        
        # Add position-based comments to help with understanding the shape
        if i == 0:
            comment = "  # Starting point"
        elif i == selected_area.polygon.size() - 1:
            comment = "  # Last point"
        elif i <= selected_area.polygon.size() * 0.25:
            comment = "  # First quarter"
        elif i <= selected_area.polygon.size() * 0.5:
            comment = "  # Second quarter"
        elif i <= selected_area.polygon.size() * 0.75:
            comment = "  # Third quarter"
        else:
            comment = "  # Fourth quarter"
        
        code += "        Vector2(" + str(int(point.x)) + ", " + str(int(point.y)) + ")," + comment + "\n"
    
    code += "    ])\n"
    code += "    \n"
    code += "    # Add to groups for proper identification\n"
    code += "    walkable.add_to_group(\"designer_walkable_area\")\n"
    code += "    walkable.add_to_group(\"walkable_area\")\n"
    code += "    add_child(walkable)\n"
    code += "    \n"
    code += "    # Set visibility for debugging only\n"
    code += "    walkable.visible = OS.is_debug_build()\n"
    code += "    \n"
    code += "    return walkable\n"
    
    # Show the generated code to the user
    if code_output:
        code_output.text = code
        code_output.visible = true
    
    # Emit signal with generated code
    emit_signal("code_generated", code)
    
    update_status("Generated code for " + selected_area.name)
    
    # Copy to clipboard
    OS.clipboard = code
    print("Code copied to clipboard")

func setup_ui():
    # Create a canvas layer for UI
    canvas_layer = CanvasLayer.new()
    canvas_layer.layer = 100
    add_child(canvas_layer)
    
    # Create a panel for controls
    control_panel = Panel.new()
    control_panel.rect_position = Vector2(10, 10)
    control_panel.rect_size = Vector2(200, 200)
    canvas_layer.add_child(control_panel)
    
    # Create a title label
    var title = Label.new()
    title.rect_position = Vector2(10, 10)
    title.rect_size = Vector2(180, 20)
    title.text = "Walkable Area Editor"
    title.align = Label.ALIGN_CENTER
    title.add_color_override("font_color", Color(1, 1, 0))
    control_panel.add_child(title)
    
    # Create mode buttons
    var modes = ["1: View", "2: Move", "3: Add", "4: Delete", "5: Drag"]
    var y_offset = 40
    
    for i in range(modes.size()):
        var button = Label.new()
        button.rect_position = Vector2(10, y_offset)
        button.rect_size = Vector2(180, 20)
        button.text = modes[i]
        button.add_color_override("font_color", Color(1, 1, 1))
        control_panel.add_child(button)
        mode_labels.append(button)
        y_offset += 20
    
    # Create capture mode button
    capture_mode_button = Button.new()
    capture_mode_button.rect_position = Vector2(10, y_offset)
    capture_mode_button.rect_size = Vector2(180, 25)
    capture_mode_button.text = "Capture Mode: WORLD_VIEW"
    capture_mode_button.connect("pressed", self, "toggle_capture_mode")
    control_panel.add_child(capture_mode_button)
    y_offset += 35
    
    # Create status label
    status_label = Label.new()
    status_label.rect_position = Vector2(10, y_offset)
    status_label.rect_size = Vector2(180, 40)
    status_label.text = "Ready"
    status_label.autowrap = true
    control_panel.add_child(status_label)
    
    # Create code output panel (hidden by default)
    code_output = TextEdit.new()
    code_output.rect_position = Vector2(220, 10)
    code_output.rect_size = Vector2(400, 400)
    code_output.visible = false
    code_output.readonly = true
    code_output.syntax_highlighting = true
    code_output.show_line_numbers = true
    canvas_layer.add_child(code_output)
    
    # Adjust control panel size
    control_panel.rect_size.y = y_offset + 50

func update_status(message):
    if status_label:
        status_label.text = message
    print(message)

func save_state_for_undo():
    if selected_area == null:
        return
    
    # Add current state to undo history
    undo_history.append({
        "area": selected_area,
        "polygon": selected_area.polygon.duplicate()
    })
    
    # Limit history size
    if undo_history.size() > max_history:
        undo_history.pop_front()
    
    # Clear redo history when a new action is performed
    redo_history.clear()

func undo():
    if undo_history.size() == 0:
        update_status("Nothing to undo")
        return
    
    # Get the last state
    var state = undo_history.pop_back()
    
    # Save current state for redo
    redo_history.append({
        "area": state.area,
        "polygon": state.area.polygon.duplicate()
    })
    
    # Restore the previous state
    state.area.polygon = state.polygon
    
    # Update selection
    selected_area = state.area
    selected_vertex_idx = -1
    
    update_status("Undo successful")
    emit_signal("area_updated", selected_area.polygon)

func redo():
    if redo_history.size() == 0:
        update_status("Nothing to redo")
        return
    
    # Get the last state
    var state = redo_history.pop_back()
    
    # Save current state for undo
    undo_history.append({
        "area": state.area,
        "polygon": state.area.polygon.duplicate()
    })
    
    # Restore the redone state
    state.area.polygon = state.polygon
    
    # Update selection
    selected_area = state.area
    selected_vertex_idx = -1
    
    update_status("Redo successful")
    emit_signal("area_updated", selected_area.polygon)

func test_walkable_area():
    if selected_area == null:
        update_status("No walkable area selected")
        return
    
    # Use the Validate Walkable Area tool to test coordinates
    var validator = ValidateWalkableArea.new()
    get_tree().get_current_scene().add_child(validator)
    
    # Convert polygon to array of points
    var points = []
    for point in selected_area.polygon:
        points.append(point)
    
    # Validate the points
    var result = validator.validate(points)
    
    update_status("Validation result: " + ("All points valid" if result else "Some points invalid"))
    
    # Keep validator visible for a few seconds then remove it
    yield(get_tree().create_timer(5.0), "timeout")
    validator.queue_free()

func delete_selected_area():
    if selected_area == null:
        update_status("No walkable area selected")
        return
    
    # Save state for undo
    save_state_for_undo()
    
    # Remove from groups
    selected_area.remove_from_group("designer_walkable_area")
    selected_area.remove_from_group("walkable_area")
    
    # Remove from walkable_areas array
    walkable_areas.erase(selected_area)
    
    # Remove from scene
    selected_area.queue_free()
    
    # Clear selection
    selected_area = null
    selected_vertex_idx = -1
    
    update_status("Walkable area deleted")
    
    # If no areas remaining, create a default one
    if walkable_areas.empty():
        create_default_walkable_area()

static func add_to_scene(scene, camera = null):
    # Create a new instance of the editor
    var editor = load("res://src/core/debug/walkable_area_editor.gd").new()
    editor.name = "WalkableAreaEditor"
    
    # Add to the scene
    scene.add_child(editor)
    
    return editor