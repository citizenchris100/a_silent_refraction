extends Node
# Mock InputManager for component testing coordinate interaction

var test_parent = null  # Reference to the test that created us
var current_district = null
var player = null

func _ready():
	# Wait a frame to make sure all nodes are initialized
	yield(get_tree(), "idle_frame")
	
	# Find the player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	# Find the current district
	var districts = get_tree().get_nodes_in_group("district")
	if districts.size() > 0:
		current_district = districts[0]

func process_test_click(screen_position: Vector2):
	"""Process a click at the given screen position"""
	
	# First validate the click position
	if not CoordinateManager.validate_viewport_coordinates(screen_position, true):
		print("  Mock InputManager: Invalid screen position: %s" % str(screen_position))
		return
	
	# Convert screen coordinates to world coordinates using CoordinateManager
	var world_position = CoordinateManager.screen_to_world(screen_position)
	
	# Notify test parent of the converted position
	if test_parent and test_parent.has_method("capture_world_position"):
		test_parent.capture_world_position(world_position)
	
	# Check if the world position is walkable
	if current_district and current_district.has_method("is_position_walkable"):
		if current_district.is_position_walkable(world_position):
			# If walkable, tell the player to move there
			if player and player.has_method("move_to"):
				player.move_to(world_position)
		else:
			# Find closest walkable point
			if current_district.has_method("get_closest_walkable_point"):
				var closest_point = current_district.get_closest_walkable_point(world_position)
				if closest_point != world_position:
					print("  Mock InputManager: Click outside walkable area, adjusted to: %s" % str(closest_point))
					if player and player.has_method("move_to"):
						player.move_to(closest_point)