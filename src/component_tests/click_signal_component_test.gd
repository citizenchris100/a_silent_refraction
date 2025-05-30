extends Node2D
# Component Test: Tests signal communication between click handling systems

# ===== TEST CONFIGURATION =====
var test_name = "ClickSignalComponentTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""

# Mock components
var input_manager = null
var priority_system = null 
var feedback_system = null

# Signal tracking
var signals_received = []

func _ready():
	print("\n==================================================")
	print(" %s COMPONENT TEST SUITE" % test_name.to_upper())
	print("==================================================\n")
	
	run_tests()
	
	print("\n==================================================")
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print("==================================================\n")
	
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	print("\n===== TEST: Basic Signal Flow =====")
	
	# Create mock components
	setup_components()
	
	# Test 1: Verify components exist
	start_test("Components created successfully")
	end_test(input_manager != null and priority_system != null and feedback_system != null,
		"All components should be created")
	
	# Test 2: Test signal emission
	start_test("InputManager emits click signal")
	signals_received.clear()
	
	# Simulate a click
	input_manager.emit_signal("click_detected", {"position": Vector2(100, 100)})
	yield(get_tree(), "idle_frame")
	
	end_test(signals_received.has("click_detected"),
		"Click detected signal should be emitted")
	
	# Test 3: Test priority system response
	start_test("Priority system processes clicks")
	signals_received.clear()
	
	# This should trigger the chain
	input_manager.emit_signal("click_detected", {
		"position": Vector2(200, 200),
		"is_ui_click": false
	})
	yield(get_tree(), "idle_frame")
	
	end_test(signals_received.has("click_processed"),
		"Priority system should process valid clicks")
	
	# Test 4: Test UI click rejection
	start_test("Priority system rejects UI clicks")
	signals_received.clear()
	
	input_manager.emit_signal("click_detected", {
		"position": Vector2(300, 300),
		"is_ui_click": true
	})
	yield(get_tree(), "idle_frame")
	
	end_test(signals_received.has("click_rejected"),
		"Priority system should reject UI clicks")
	
	# Cleanup
	cleanup_components()

func setup_components():
	# Create simple mock components
	input_manager = Node.new()
	input_manager.add_user_signal("click_detected", [{"name": "data", "type": TYPE_DICTIONARY}])
	add_child(input_manager)
	
	priority_system = Node.new()
	priority_system.add_user_signal("click_processed", [{"name": "data", "type": TYPE_DICTIONARY}])
	priority_system.add_user_signal("click_rejected", [{"name": "data", "type": TYPE_DICTIONARY}])
	add_child(priority_system)
	
	feedback_system = Node.new()
	add_child(feedback_system)
	
	# Connect signals
	input_manager.connect("click_detected", self, "_on_click_detected")
	priority_system.connect("click_processed", self, "_on_click_processed")
	priority_system.connect("click_rejected", self, "_on_click_rejected")
	
	# Track all signals
	input_manager.connect("click_detected", self, "_track_signal", ["click_detected"])
	priority_system.connect("click_processed", self, "_track_signal", ["click_processed"])
	priority_system.connect("click_rejected", self, "_track_signal", ["click_rejected"])

func cleanup_components():
	if input_manager:
		input_manager.queue_free()
	if priority_system:
		priority_system.queue_free()
	if feedback_system:
		feedback_system.queue_free()

# Signal handlers
func _on_click_detected(data):
	# Priority system logic
	if data and data.has("is_ui_click") and data.is_ui_click:
		priority_system.emit_signal("click_rejected", data)
	elif data and data.has("position"):
		var processed_data = data.duplicate()
		processed_data["priority"] = "movement"
		priority_system.emit_signal("click_processed", processed_data)

func _on_click_processed(data):
	# Feedback system would show feedback
	pass

func _on_click_rejected(data):
	# Feedback system might show different feedback
	pass

func _track_signal(data, signal_name):
	signals_received.append(signal_name)

# Test helpers
func start_test(test_name: String):
	current_test = test_name
	print("\n[TEST] " + test_name)

func end_test(passed: bool, message: String):
	if passed:
		tests_passed += 1
		print("  ✓ PASS: %s" % message)
	else:
		tests_failed += 1
		print("  ✗ FAIL: %s" % message)