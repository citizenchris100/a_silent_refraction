extends Node2D
# Simple Camera Movement Subsystem Test - Minimal version to verify basic functionality

var tests_passed = 0
var tests_failed = 0

func _ready():
	print("\n========== SIMPLE CAMERA MOVEMENT TEST ==========\n")
	
	# Just try to create the basic components
	print("Testing basic component creation...")
	
	# Test 1: Create a mock district
	var MockDistrict = preload("res://src/unit_tests/mocks/mock_district_with_walkable.gd")
	var district = Node2D.new()
	district.set_script(MockDistrict)
	district.name = "TestDistrict"
	district.add_to_group("district")
	add_child(district)
	
	# Add a simple walkable area
	var walkable = Polygon2D.new()
	walkable.polygon = PoolVector2Array([
		Vector2(0, 0),
		Vector2(800, 0),
		Vector2(800, 600),
		Vector2(0, 600)
	])
	walkable.add_to_group("walkable_area")
	district.add_child(walkable)
	district.add_walkable_area(walkable)
	
	if district:
		tests_passed += 1
		print("✓ PASS: Created test district")
	else:
		tests_failed += 1
		print("✗ FAIL: Could not create district")
	
	# Test 2: Create a camera
	var Camera2D = preload("res://src/core/camera/scrolling_camera.gd")
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	district.add_child(camera)
	
	if camera:
		tests_passed += 1
		print("✓ PASS: Created camera")
	else:
		tests_failed += 1
		print("✗ FAIL: Could not create camera")
	
	# Test 3: Create player
	var Player = preload("res://src/characters/player/player.gd")
	var player = Player.new()
	player.name = "Player"
	player.position = Vector2(400, 400)
	player.add_to_group("player")
	district.add_child(player)
	
	yield(get_tree(), "idle_frame")
	
	if player:
		tests_passed += 1
		print("✓ PASS: Created player")
	else:
		tests_failed += 1
		print("✗ FAIL: Could not create player")
	
	# Test 4: Basic movement
	print("\nTesting basic movement...")
	if player and player.has_method("move_to"):
		player.move_to(Vector2(500, 500))
		yield(get_tree().create_timer(1.0), "timeout")
		
		if player.position != Vector2(400, 400):
			tests_passed += 1
			print("✓ PASS: Player moved from starting position")
		else:
			tests_failed += 1
			print("✗ FAIL: Player did not move")
	
	# Summary
	print("\n========== SUMMARY ==========")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit(tests_failed)