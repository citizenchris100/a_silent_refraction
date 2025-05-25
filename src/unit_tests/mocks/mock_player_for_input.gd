extends Node2D
# Mock player for input testing - records move_to calls

var test_parent = null

func move_to(position: Vector2):
	print("Mock player move_to called with: ", position)
	if test_parent and test_parent.has_method("record_move_to"):
		print("Recording position to test parent")
		test_parent.record_move_to(position)
	else:
		print("Warning: test_parent not set or missing record_move_to method")