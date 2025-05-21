class_name CoordinateSystem
extends Reference

# CoordinateSystem: A utility class that handles coordinate transformations between different spaces
# This class centralizes coordinate transformation operations to reduce coupling and improve maintainability

# Constants
enum ViewMode {
	GAME_VIEW,    # Normal game view with player-centered camera
	WORLD_VIEW    # Debug view showing the entire world/background
}

# Convert screen coordinates to world coordinates
static func screen_to_world(screen_pos: Vector2, camera: Camera2D) -> Vector2:
	if camera.has_method("screen_to_world"):
		return camera.screen_to_world(screen_pos)
	
	# Fallback implementation if camera doesn't provide the method
	var viewport_size = camera.get_viewport_rect().size
	return camera.global_position + ((screen_pos - viewport_size/2) * camera.zoom)

# Convert world coordinates to screen coordinates
static func world_to_screen(world_pos: Vector2, camera: Camera2D) -> Vector2:
	if camera.has_method("world_to_screen"):
		return camera.world_to_screen(world_pos)
	
	# Fallback implementation if camera doesn't provide the method
	var viewport_size = camera.get_viewport_rect().size
	return (world_pos - camera.global_position) / camera.zoom + viewport_size/2

# Apply background scale factor to world coordinates
static func apply_scale_factor(world_pos: Vector2, scale_factor: float) -> Vector2:
	# Validate input
	if world_pos == null:
		print("WARNING: apply_scale_factor received null position")
		return Vector2.ZERO
		
	# Check for NaN values
	if is_nan(world_pos.x) or is_nan(world_pos.y):
		print("WARNING: apply_scale_factor received NaN coordinates: " + str(world_pos))
		return Vector2.ZERO
		
	# Check for infinite values
	if is_inf(world_pos.x) or is_inf(world_pos.y):
		print("WARNING: apply_scale_factor received infinite coordinates: " + str(world_pos))
		return Vector2.ZERO
	
	if scale_factor == 1.0:
		return world_pos
	return world_pos * scale_factor

# Remove background scale factor from world coordinates
static func remove_scale_factor(world_pos: Vector2, scale_factor: float) -> Vector2:
	# Validate input
	if world_pos == null:
		print("WARNING: remove_scale_factor received null position")
		return Vector2.ZERO
		
	# Check for NaN values
	if is_nan(world_pos.x) or is_nan(world_pos.y):
		print("WARNING: remove_scale_factor received NaN coordinates: " + str(world_pos))
		return Vector2.ZERO
		
	# Check for infinite values
	if is_inf(world_pos.x) or is_inf(world_pos.y):
		print("WARNING: remove_scale_factor received infinite coordinates: " + str(world_pos))
		return Vector2.ZERO
	
	if scale_factor == 1.0:
		return world_pos
	return world_pos / scale_factor

# Convert between world view and game view coordinates
# This transforms coordinates captured in full view (zoomed out) to normal game coordinates
static func world_view_to_game_view(world_view_pos: Vector2, district) -> Vector2:
	# Validate input
	if world_view_pos == null:
		print("WARNING: world_view_to_game_view received null position")
		return Vector2.ZERO
		
	# Check for NaN values
	if is_nan(world_view_pos.x) or is_nan(world_view_pos.y):
		print("WARNING: world_view_to_game_view received NaN coordinates: " + str(world_view_pos))
		return Vector2.ZERO
		
	# Check for infinite values
	if is_inf(world_view_pos.x) or is_inf(world_view_pos.y):
		print("WARNING: world_view_to_game_view received infinite coordinates: " + str(world_view_pos))
		return Vector2.ZERO
		
	if district == null:
		print("WARNING: world_view_to_game_view received null district")
		return world_view_pos
	
	# Get the scale factor with safe fallback
	var scale_factor = 1.0
	if has_property(district, "background_scale_factor"):
		scale_factor = district.background_scale_factor
	
	# Apply the transformation with the scale factor
	return remove_scale_factor(world_view_pos, scale_factor)

# Convert between game view and world view coordinates
# This transforms normal game coordinates to coordinates in full view (zoomed out)
static func game_view_to_world_view(game_view_pos: Vector2, district) -> Vector2:
	# Validate input
	if game_view_pos == null:
		print("WARNING: game_view_to_world_view received null position")
		return Vector2.ZERO
		
	# Check for NaN values
	if is_nan(game_view_pos.x) or is_nan(game_view_pos.y):
		print("WARNING: game_view_to_world_view received NaN coordinates: " + str(game_view_pos))
		return Vector2.ZERO
		
	# Check for infinite values
	if is_inf(game_view_pos.x) or is_inf(game_view_pos.y):
		print("WARNING: game_view_to_world_view received infinite coordinates: " + str(game_view_pos))
		return Vector2.ZERO
		
	if district == null:
		print("WARNING: game_view_to_world_view received null district")
		return game_view_pos
	
	# Get the scale factor with safe fallback
	var scale_factor = 1.0
	if has_property(district, "background_scale_factor"):
		scale_factor = district.background_scale_factor
	
	# Apply the transformation with the scale factor
	return apply_scale_factor(game_view_pos, scale_factor)

# Helper method to detect if an object has a specific property
# Works with any object type, not just Nodes
static func has_property(object, property: String) -> bool:
	if object == null:
		return false
	
	# Use the 'in' operator which is more compatible with GDScript's duck typing
	return property in object

# Get the current view mode from a debug manager or fallback to game view
static func get_current_view_mode(debug_manager = null) -> int:
	# Early validation
	if debug_manager == null:
		return ViewMode.GAME_VIEW
		
	# First, check for the simplest case using the 'in' operator
	if "full_view_mode" in debug_manager:
		if debug_manager.full_view_mode:
			print("DEBUG: Detected World View mode via full_view_mode property")
			return ViewMode.WORLD_VIEW
	
	# Fallback method - check for a specific camera zoom that indicates full view
	# Many debug managers show full view by increasing zoom significantly
	if "camera" in debug_manager and debug_manager.camera != null:
		var camera = debug_manager.camera
		if camera.zoom.x > 2.0:  # If zoomed out significantly, it's likely full view mode
			print("DEBUG: Detected World View mode via camera zoom")
			return ViewMode.WORLD_VIEW
	
	# Default to game view if we can't confirm world view
	return ViewMode.GAME_VIEW

# Convert coordinates based on current view mode
# This is a convenience method that automatically detects the view mode and applies
# the appropriate transformation
static func convert_coordinates_for_current_view(pos: Vector2, district, debug_manager = null) -> Vector2:
	# Validate input
	if pos == null:
		print("WARNING: convert_coordinates_for_current_view received null position")
		return Vector2.ZERO
		
	if district == null:
		print("WARNING: convert_coordinates_for_current_view received null district")
		return pos
	
	# Determine the current view mode
	var view_mode = get_current_view_mode(debug_manager)
	
	# Log the conversion operation for debugging
	print("Converting coordinates: pos=" + str(pos) + 
	      ", view_mode=" + ("WORLD_VIEW" if view_mode == ViewMode.WORLD_VIEW else "GAME_VIEW"))
	
	var result
	if view_mode == ViewMode.WORLD_VIEW:
		# We're in World View mode, convert coordinates to Game View
		result = world_view_to_game_view(pos, district)
		print("Converted World View → Game View: " + str(pos) + " → " + str(result))
	else:
		# We're in Game View mode, no conversion needed
		result = pos
		print("No conversion needed in Game View mode")
	
	return result