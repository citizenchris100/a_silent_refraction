extends Node2D

# Debug Tools Test Scene
# Tests the coordinate picker and polygon visualizer tools

func _ready():
	print("Debug Tools Test Scene")
	print("=====================")
	print("Instructions:")
	print("- Left-click to capture coordinates with the Coordinate Picker")
	print("- Press C to copy the last clicked coordinates")
	print("- Click on polygon vertices to select them")
	print("- Press P to print the current polygon's coordinates")