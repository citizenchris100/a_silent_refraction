extends Node2D

# CoordinateVisualizer: A tool to visualize coordinate transformations in debug mode
# This tool shows how coordinates transform between different coordinate spaces and view modes
# by drawing animated arrows and transformation markers

# Configuration
export var line_color = Color(1, 0.7, 0.2, 0.8)
export var arrow_size = 15
export var point_size = 10
export var animation_time = 1.0
export var animate_transformations = true
export var show_labels = true

# Visualization styles for different coordinate spaces
const SPACE_COLORS = {
	"screen": Color(0, 0.8, 0, 0.8),
	"world": Color(0.8, 0, 0, 0.8),
	"local": Color(0, 0, 0.8, 0.8)
}

# Visualization styles for different view modes
const VIEW_MODE_COLORS = {
	"game": Color(0, 0.8, 0.8, 0.8),
	"world": Color(0.8, 0.4, 0, 0.8)
}

# Coordinate spaces
enum CoordinateSpace {
	SCREEN_SPACE,
	WORLD_SPACE,
	LOCAL_SPACE
}

# View modes
enum ViewMode {
	GAME_VIEW,
	WORLD_VIEW
}

# Animation state
var animations = []
var font

# Reference to coordinate manager
var coordinate_manager = null

func _ready():
	# Load a font for labels
	font = DynamicFont.new()
	var font_data = load("res://src/assets/fonts/Consolas.ttf")
	if not font_data:
		# Use default if custom font not available
		font_data = get_tree().get_root().get_theme_default_font()
	font.font_data = font_data
	font.size = 14
	
	# Get reference to CoordinateManager
	coordinate_manager = CoordinateManager
	
	# Set process enabled
	set_process(true)
	print("CoordinateVisualizer initialized")

func _process(delta):
	# Update animations
	for i in range(animations.size() - 1, -1, -1):
		var anim = animations[i]
		anim.time += delta
		
		if anim.time >= animation_time:
			animations.remove(i)
	
	# Force redraw
	update()

func _draw():
	# Draw active animations
	for anim in animations:
		var progress = min(anim.time / animation_time, 1.0)
		
		# Apply easing
		var eased_progress = ease_progress(progress)
		
		# Draw the transformation visualization
		_draw_transformation(
			anim.from_point,
			anim.to_point,
			anim.from_color,
			anim.to_color,
			eased_progress,
			anim.label
		)

# Visualize a transformation between screen space and world space
func visualize_screen_to_world(screen_pos, label = ""):
	if not coordinate_manager:
		push_error("CoordinateVisualizer: No reference to CoordinateManager")
		return
	
	var world_pos = coordinate_manager.screen_to_world(screen_pos)
	
	add_transformation_animation(
		screen_pos,
		world_pos,
		SPACE_COLORS["screen"],
		SPACE_COLORS["world"],
		label if label else "Screen → World"
	)

# Visualize a transformation between world space and screen space
func visualize_world_to_screen(world_pos, label = ""):
	if not coordinate_manager:
		push_error("CoordinateVisualizer: No reference to CoordinateManager")
		return
	
	var screen_pos = coordinate_manager.world_to_screen(world_pos)
	
	add_transformation_animation(
		world_pos,
		screen_pos,
		SPACE_COLORS["world"],
		SPACE_COLORS["screen"],
		label if label else "World → Screen"
	)

# Visualize a transformation between game view and world view
func visualize_view_mode_transformation(point, from_view_mode, to_view_mode, label = ""):
	if not coordinate_manager:
		push_error("CoordinateVisualizer: No reference to CoordinateManager")
		return
	
	var transformed_point = coordinate_manager.transform_view_mode_coordinates(
		point,
		from_view_mode,
		to_view_mode
	)
	
	var from_color = VIEW_MODE_COLORS["game"] if from_view_mode == ViewMode.GAME_VIEW else VIEW_MODE_COLORS["world"]
	var to_color = VIEW_MODE_COLORS["game"] if to_view_mode == ViewMode.GAME_VIEW else VIEW_MODE_COLORS["world"]
	
	var mode_label = ""
	if from_view_mode == ViewMode.GAME_VIEW and to_view_mode == ViewMode.WORLD_VIEW:
		mode_label = "Game → World View"
	elif from_view_mode == ViewMode.WORLD_VIEW and to_view_mode == ViewMode.GAME_VIEW:
		mode_label = "World → Game View"
	
	add_transformation_animation(
		point,
		transformed_point,
		from_color,
		to_color,
		label if label else mode_label
	)

# Add a new transformation animation
func add_transformation_animation(from_point, to_point, from_color, to_color, label = ""):
	animations.append({
		"from_point": from_point,
		"to_point": to_point,
		"from_color": from_color,
		"to_color": to_color,
		"time": 0.0,
		"label": label
	})

# Draw a transformation visualization with the given progress
func _draw_transformation(from_point, to_point, from_color, to_color, progress, label):
	# Calculate the current point based on progress
	var current_point = from_point.linear_interpolate(to_point, progress)
	
	# Draw the line from start to current point
	draw_line(from_point, current_point, line_color, 2.0)
	
	# Draw the starting point
	_draw_point(from_point, from_color)
	
	# Draw the current point
	_draw_point(current_point, to_color.linear_interpolate(from_color, 1.0 - progress))
	
	# Draw arrow head at current point if progress > 0
	if progress > 0:
		_draw_arrow_head(from_point, current_point, line_color)
	
	# Draw labels if enabled
	if show_labels and label:
		# Draw label at midpoint
		var mid_point = from_point.linear_interpolate(to_point, 0.5)
		
		# Add a small offset to avoid overlapping with the line
		mid_point.y -= 15
		
		draw_string(font, mid_point, label, line_color)

# Draw a point with the given color
func _draw_point(position, color, size = point_size):
	var half_size = size / 2
	draw_circle(position, half_size, color)
	
	# Draw a border
	draw_arc(position, half_size, 0, TAU, 32, Color(0.2, 0.2, 0.2, 0.8), 1.0)

# Draw an arrow head from point a to point b
func _draw_arrow_head(from_point, to_point, color):
	var direction = (to_point - from_point).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	
	var tip = to_point
	var base1 = tip - direction * arrow_size + perpendicular * arrow_size * 0.5
	var base2 = tip - direction * arrow_size - perpendicular * arrow_size * 0.5
	
	var points = PoolVector2Array([tip, base1, base2])
	draw_colored_polygon(points, color)

# Apply easing to the progress value (ease in-out)
func ease_progress(progress):
	if progress < 0.5:
		return 2.0 * progress * progress
	else:
		return -1.0 + (4.0 - 2.0 * progress) * progress

# Public API: Visualize the transformation of a specific point
func visualize_point_transformation(point, from_space, to_space, reference_object = null, label = ""):
	if not coordinate_manager:
		push_error("CoordinateVisualizer: No reference to CoordinateManager")
		return
		
	var transformed_point = coordinate_manager.transform_coordinates(
		point, 
		from_space, 
		to_space, 
		reference_object
	)
	
	var from_space_name = _get_space_name(from_space)
	var to_space_name = _get_space_name(to_space)
	
	var from_color = SPACE_COLORS[from_space_name.to_lower()]
	var to_color = SPACE_COLORS[to_space_name.to_lower()]
	
	var transform_label = from_space_name + " → " + to_space_name
	
	add_transformation_animation(
		point,
		transformed_point,
		from_color,
		to_color,
		label if label else transform_label
	)
	
	return transformed_point

# Helper to get space name from enum
func _get_space_name(space):
	match space:
		CoordinateSpace.SCREEN_SPACE:
			return "Screen"
		CoordinateSpace.WORLD_SPACE:
			return "World"
		CoordinateSpace.LOCAL_SPACE:
			return "Local"
		_:
			return "Unknown"

# Helper to visualize the current mouse position in different spaces
func visualize_mouse_position():
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Screen to World
	visualize_screen_to_world(mouse_pos, "Mouse: Screen → World")
	
	# If coordinate manager exists, also visualize view mode transformation
	if coordinate_manager:
		var world_pos = coordinate_manager.screen_to_world(mouse_pos)
		var current_view_mode = coordinate_manager.get_view_mode()
		var opposite_view_mode = ViewMode.WORLD_VIEW if current_view_mode == ViewMode.GAME_VIEW else ViewMode.GAME_VIEW
		
		visualize_view_mode_transformation(
			world_pos,
			current_view_mode,
			opposite_view_mode,
			"Mouse: View Mode Transform"
		)