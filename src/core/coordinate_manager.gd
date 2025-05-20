extends Node

# CoordinateManager: A singleton service for handling all coordinate transformations in the game
# This class centralizes coordinate transformation logic and provides a consistent API for all components

# Enum for different coordinate spaces
enum CoordinateSpace {
	SCREEN_SPACE,  # UI coordinates relative to the viewport (used by mouse clicks)
	WORLD_SPACE,   # Global game coordinates (used for positioning game objects)
	LOCAL_SPACE    # Coordinates relative to a specific object's parent
}

# Enum for different view modes
enum ViewMode {
	GAME_VIEW,    # Normal game view with gameplay-appropriate camera zoom
	WORLD_VIEW    # Debug view showing the entire world/background (zoomed out)
}

# Cached reference to the current district
var _current_district = null

# The current view mode, defaults to game view
var _current_view_mode = ViewMode.GAME_VIEW

func _ready():
	# Initialize the singleton
	print("CoordinateManager initialized")

# Set the current district for coordinate transformations
# This method should be called whenever the active district changes
func set_current_district(district):
	_current_district = district
	print("CoordinateManager: Current district set to " + district.district_name if district else "null")

# Get the current district
func get_current_district():
	return _current_district

# Set the current view mode
func set_view_mode(view_mode):
	if view_mode != _current_view_mode:
		var mode_name = "GAME_VIEW" if view_mode == ViewMode.GAME_VIEW else "WORLD_VIEW"
		print("CoordinateManager: View mode changed to " + mode_name)
		_current_view_mode = view_mode

# Get the current view mode
func get_view_mode():
	return _current_view_mode

# Transform coordinates from one space to another
func transform_coordinates(coords, from_space, to_space, reference_object = null):
	# Validate inputs
	if coords == null:
		push_error("CoordinateManager: transform_coordinates received null coordinates")
		return Vector2.ZERO
		
	if from_space == to_space:
		return coords  # No transformation needed
	
	# Handle various transformation combinations
	match [from_space, to_space]:
		[CoordinateSpace.SCREEN_SPACE, CoordinateSpace.WORLD_SPACE]:
			return screen_to_world(coords)
			
		[CoordinateSpace.WORLD_SPACE, CoordinateSpace.SCREEN_SPACE]:
			return world_to_screen(coords)
			
		[CoordinateSpace.WORLD_SPACE, CoordinateSpace.LOCAL_SPACE]:
			if reference_object == null:
				push_error("CoordinateManager: reference_object is required for WORLD_SPACE to LOCAL_SPACE transformation")
				return coords
			return world_to_local(coords, reference_object)
			
		[CoordinateSpace.LOCAL_SPACE, CoordinateSpace.WORLD_SPACE]:
			if reference_object == null:
				push_error("CoordinateManager: reference_object is required for LOCAL_SPACE to WORLD_SPACE transformation")
				return coords
			return local_to_world(coords, reference_object)
			
		_:
			push_error("CoordinateManager: Unsupported coordinate transformation from " + 
				str(from_space) + " to " + str(to_space))
			return coords

# Transform screen coordinates to world coordinates
func screen_to_world(screen_pos):
	# Get the appropriate camera
	var camera = _get_current_camera()
	if camera == null:
		push_error("CoordinateManager: screen_to_world - No camera found")
		return screen_pos
	
	# Use the CoordinateSystem utility for the actual transformation
	var world_pos = CoordinateSystem.screen_to_world(screen_pos, camera)
	
	# Apply scale factor if needed and in world view mode
	if _current_district != null and _current_view_mode == ViewMode.WORLD_VIEW:
		if "background_scale_factor" in _current_district:
			var scale_factor = _current_district.background_scale_factor
			if scale_factor != 1.0:
				world_pos = CoordinateSystem.apply_scale_factor(world_pos, scale_factor)
				print("CoordinateManager: Applied scale factor " + str(scale_factor) + 
					" to world position: " + str(world_pos))
	
	return world_pos

# Transform world coordinates to screen coordinates
func world_to_screen(world_pos):
	# Get the appropriate camera
	var camera = _get_current_camera()
	if camera == null:
		push_error("CoordinateManager: world_to_screen - No camera found")
		return world_pos
	
	# Apply scale factor if needed and in world view mode
	var adjusted_pos = world_pos
	if _current_district != null and _current_view_mode == ViewMode.WORLD_VIEW:
		if "background_scale_factor" in _current_district:
			var scale_factor = _current_district.background_scale_factor
			if scale_factor != 1.0:
				adjusted_pos = CoordinateSystem.remove_scale_factor(world_pos, scale_factor)
				print("CoordinateManager: Removed scale factor " + str(scale_factor) + 
					" from world position: " + str(world_pos) + " → " + str(adjusted_pos))
	
	# Use the CoordinateSystem utility for the actual transformation
	return CoordinateSystem.world_to_screen(adjusted_pos, camera)

# Transform local coordinates to world coordinates
func local_to_world(local_pos, reference_object):
	if reference_object == null:
		push_error("CoordinateManager: local_to_world - No reference object provided")
		return local_pos
		
	if not reference_object is Node2D:
		push_error("CoordinateManager: local_to_world - Reference object must be a Node2D")
		return local_pos
		
	return reference_object.to_global(local_pos)

# Transform world coordinates to local coordinates
func world_to_local(world_pos, reference_object):
	if reference_object == null:
		push_error("CoordinateManager: world_to_local - No reference object provided")
		return world_pos
		
	if not reference_object is Node2D:
		push_error("CoordinateManager: world_to_local - Reference object must be a Node2D")
		return world_pos
		
	return reference_object.to_local(world_pos)

# Transform coordinates between different view modes
func transform_view_mode_coordinates(coords, from_view_mode, to_view_mode):
	# Validate inputs
	if coords == null:
		push_error("CoordinateManager: transform_view_mode_coordinates received null coordinates")
		return Vector2.ZERO
		
	if from_view_mode == to_view_mode:
		return coords  # No transformation needed
	
	# Handle transformations between view modes
	if _current_district == null:
		push_error("CoordinateManager: transform_view_mode_coordinates - No current district set")
		return coords
	
	match [from_view_mode, to_view_mode]:
		[ViewMode.WORLD_VIEW, ViewMode.GAME_VIEW]:
			return CoordinateSystem.world_view_to_game_view(coords, _current_district)
			
		[ViewMode.GAME_VIEW, ViewMode.WORLD_VIEW]:
			return CoordinateSystem.game_view_to_world_view(coords, _current_district)
			
		_:
			push_error("CoordinateManager: Unsupported view mode transformation from " + 
				str(from_view_mode) + " to " + str(to_view_mode))
			return coords

# Detect the current view mode from a debug manager
func detect_view_mode_from_debug(debug_manager = null):
	var detected_mode = CoordinateSystem.get_current_view_mode(debug_manager)
	set_view_mode(detected_mode)
	return detected_mode

# Get the current camera
func _get_current_camera():
	if _current_district != null and _current_district.has_method("get_camera"):
		return _current_district.get_camera()
		
	# Fallback: try to find a current camera in the scene
	var viewport = get_viewport()
	if viewport != null:
		return viewport.get_camera()
		
	return null

# Convert a PoolVector2Array of coordinates from one view mode to another
# This is useful for transforming walkable area coordinates in bulk
func transform_coordinate_array(points, from_view_mode, to_view_mode):
	if points == null or points.size() == 0:
		return points
		
	if from_view_mode == to_view_mode:
		return points  # No transformation needed
	
	var result = PoolVector2Array()
	for point in points:
		result.append(transform_view_mode_coordinates(point, from_view_mode, to_view_mode))
	
	return result

# Utility method: Check if coordinates were captured in World View
# This helps catch potential errors when using coordinates in the wrong context
func validate_coordinates_for_view_mode(points, expected_view_mode):
	if points == null or points.size() == 0:
		return false
		
	# If we're not in the expected view mode, show a warning
	if _current_view_mode != expected_view_mode:
		var actual_mode = "WORLD_VIEW" if _current_view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"
		var expected_mode = "WORLD_VIEW" if expected_view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"
		
		push_warning("CoordinateManager: Coordinate validation warning - Current view mode is " + 
			actual_mode + " but coordinates are expected for " + expected_mode)
		
		# For walkable areas specifically, provide detailed warnings
		if expected_view_mode == ViewMode.WORLD_VIEW:
			push_warning("For walkable areas that span the entire background, coordinates should be captured in WORLD_VIEW mode")
			push_warning("Press 'Alt+W' to switch to WORLD_VIEW mode before capturing coordinates")
		
		return false
	
	return true

# Check if viewport coordinates are valid (within the viewport)
# Returns true if the coordinates are within the viewport boundaries
# include_boundary: If true, points exactly on the boundary are considered valid
func validate_viewport_coordinates(screen_pos: Vector2, include_boundary: bool = false) -> bool:
	# Get the current camera
	var camera = _get_current_camera()
	var viewport_size = Vector2.ZERO
	
	if camera != null:
		# Get viewport size from current camera
		viewport_size = camera.get_viewport_rect().size
	else:
		# Fallback to OS window size if no camera is available
		viewport_size = OS.get_window_size()
		push_warning("CoordinateManager: No camera found, using OS window size as fallback: " + str(viewport_size))
	
	# Check if the coordinates are within the viewport boundaries
	if include_boundary:
		return screen_pos.x >= 0 && screen_pos.x <= viewport_size.x && \
			   screen_pos.y >= 0 && screen_pos.y <= viewport_size.y
	else:
		return screen_pos.x >= 0 && screen_pos.x < viewport_size.x && \
			   screen_pos.y >= 0 && screen_pos.y < viewport_size.y