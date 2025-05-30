extends Node2D

# Base class for all subsystem tests
# Provides common functionality for testing multiple integrated components

# ===== TEST STATE =====
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_scenario = ""
var failed_tests = []
var test_start_time = 0

# ===== CONFIGURATION =====
var log_verbose = true
var enable_visual_validation = false
var enable_performance_profiling = false
var capture_test_artifacts = true

# ===== PERFORMANCE MONITORING =====
var performance_monitors = {}
var frame_time_samples = []
var last_frame_time = 0

# ===== VISUAL VALIDATION =====
var visual_captures = {}

# ===== TEST ENVIRONMENT =====
var test_environment = null

# ===== LOGGING METHODS =====

func log_section(title: String):
	print("\n" + "--------------------------------------------------")
	print(" " + title)
	print("--------------------------------------------------")

func log_success(message: String):
	print("[SUCCESS] " + message)

func log_error(message: String):
	print("[ERROR] " + message)

func log_warning(message: String):
	print("[WARNING] " + message)

func log_info(message: String):
	if log_verbose:
		print("[INFO] " + message)

# ===== TEST EXECUTION =====

func start_test(test_name: String):
	current_test = test_name
	test_start_time = OS.get_ticks_msec()
	log_info("Starting test: " + test_name)

func end_test(passed: bool, message: String):
	var duration = (OS.get_ticks_msec() - test_start_time) / 1000.0
	
	if passed:
		tests_passed += 1
		print("  ✓ PASS: %s - %s (%.2fs)" % [current_test, message, duration])
	else:
		tests_failed += 1
		failed_tests.append(current_test)
		print("  ✗ FAIL: %s - %s (%.2fs)" % [current_test, message, duration])

func run_scenario(scenario_name: String, test_func: FuncRef):
	current_scenario = scenario_name
	print("\n===== SCENARIO: %s =====" % scenario_name)
	yield(test_func.call_func(), "completed")

# ===== ASSERTIONS =====

func assert_true(condition: bool, message: String = "") -> bool:
	if not condition:
		log_error("Assertion failed: " + message)
	return condition

func assert_false(condition: bool, message: String = "") -> bool:
	return assert_true(not condition, message)

func assert_eq(actual, expected, message: String = "") -> bool:
	if actual != expected:
		log_error("%s - Expected: %s, Got: %s" % [message, str(expected), str(actual)])
		return false
	return true

func assert_not_null(value, message: String = "") -> bool:
	if value == null:
		log_error("Value is null: " + message)
		return false
	return true

func assert_state(component: Node, expected_state: String, message: String) -> bool:
	if component and component.has_method("get_state"):
		var actual_state = component.get_state()
		if actual_state != expected_state:
			log_error("%s - Expected: %s, Got: %s" % [message, expected_state, actual_state])
			return false
	return true

func assert_within_range(value: float, min_val: float, max_val: float, message: String) -> bool:
	if value < min_val or value > max_val:
		log_error("%s - Value %f outside range [%f, %f]" % [message, value, min_val, max_val])
		return false
	return true

func assert_position_near(actual: Vector2, expected: Vector2, tolerance: float, message: String) -> bool:
	var distance = actual.distance_to(expected)
	if distance > tolerance:
		log_error("%s - Position %s not within %f of %s (distance: %f)" % 
			[message, str(actual), tolerance, str(expected), distance])
		return false
	return true

# ===== PERFORMANCE MONITORING =====

func _process(delta):
	if enable_performance_profiling:
		record_frame_time()

func record_frame_time():
	var current_time = OS.get_ticks_msec()
	if last_frame_time > 0:
		var frame_time = current_time - last_frame_time
		frame_time_samples.append(frame_time)
		
		# Update active monitors
		for monitor_name in performance_monitors:
			var monitor = performance_monitors[monitor_name]
			monitor.frame_times.append(frame_time)
			monitor.frame_count += 1
	
	last_frame_time = current_time

func start_performance_monitor(monitor_name: String):
	performance_monitors[monitor_name] = {
		"start_time": OS.get_ticks_msec(),
		"frame_count": 0,
		"frame_times": []
	}
	log_info("Started performance monitor: " + monitor_name)

func stop_performance_monitor(monitor_name: String) -> Dictionary:
	if not monitor_name in performance_monitors:
		return {}
	
	var monitor = performance_monitors[monitor_name]
	monitor["end_time"] = OS.get_ticks_msec()
	monitor["duration"] = (monitor.end_time - monitor.start_time) / 1000.0
	
	# Calculate statistics
	if monitor.frame_times.size() > 0:
		monitor["avg_frame_time"] = _calculate_average(monitor.frame_times)
		monitor["max_frame_time"] = _calculate_max(monitor.frame_times)
		monitor["min_frame_time"] = _calculate_min(monitor.frame_times)
		monitor["percentile_95"] = _calculate_percentile(monitor.frame_times, 0.95)
	
	log_info("Stopped performance monitor: %s (Duration: %.2fs, Frames: %d)" % 
		[monitor_name, monitor.duration, monitor.frame_count])
	
	return monitor

func validate_performance_targets(perf_data: Dictionary, targets: Dictionary) -> bool:
	var all_passed = true
	
	if "avg_frame_time" in perf_data and "frame_time_avg" in targets:
		if perf_data.avg_frame_time > targets.frame_time_avg:
			log_error("Average frame time %.1fms exceeds target %.1fms" % 
				[perf_data.avg_frame_time, targets.frame_time_avg])
			all_passed = false
	
	if "max_frame_time" in perf_data and "frame_time_max" in targets:
		if perf_data.max_frame_time > targets.frame_time_max:
			log_error("Max frame time %.1fms exceeds target %.1fms" % 
				[perf_data.max_frame_time, targets.frame_time_max])
			all_passed = false
	
	return all_passed

# ===== VISUAL VALIDATION =====

func capture_visual_state(state_name: String) -> Dictionary:
	if not enable_visual_validation:
		return {}
	
	# Wait a frame to ensure rendering is complete
	yield(get_tree(), "idle_frame")
	
	# Capture viewport
	var viewport = get_viewport()
	var image = viewport.get_texture().get_data()
	
	var capture = {
		"name": state_name,
		"image": image,
		"timestamp": OS.get_ticks_msec(),
		"viewport_size": viewport.size
	}
	
	visual_captures[state_name] = capture
	log_info("Captured visual state: " + state_name)
	
	return capture

func validate_visual_correctness(initial: Dictionary, final: Dictionary) -> bool:
	# Override in derived classes for specific validation
	return true

func has_grey_bars() -> bool:
	# Check viewport edges for grey bars
	var viewport = get_viewport()
	var image = viewport.get_texture().get_data()
	image.flip_y()
	
	# Check top and bottom edges
	for x in range(0, image.get_width(), 10):
		var top_color = image.get_pixel(x, 0)
		var bottom_color = image.get_pixel(x, image.get_height() - 1)
		
		# Grey is typically around (0.5, 0.5, 0.5)
		if _is_grey(top_color) or _is_grey(bottom_color):
			return true
	
	# Check left and right edges
	for y in range(0, image.get_height(), 10):
		var left_color = image.get_pixel(0, y)
		var right_color = image.get_pixel(image.get_width() - 1, y)
		
		if _is_grey(left_color) or _is_grey(right_color):
			return true
	
	return false

func _is_grey(color: Color) -> bool:
	# Check if color is greyish (all components similar and not too dark/bright)
	var avg = (color.r + color.g + color.b) / 3.0
	var max_diff = max(abs(color.r - avg), max(abs(color.g - avg), abs(color.b - avg)))
	return max_diff < 0.1 and avg > 0.3 and avg < 0.7

# ===== CLEANUP =====

func cleanup_and_exit(exit_code: int):
	log_section("Test Summary")
	print("Tests Passed: %d" % tests_passed)
	print("Tests Failed: %d" % tests_failed)
	
	if tests_failed > 0:
		print("\nFailed Tests:")
		for test in failed_tests:
			print("  - " + test)
	
	# Cleanup
	if test_environment:
		test_environment.queue_free()
	
	# Clear any remaining nodes
	for child in get_children():
		child.queue_free()
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit(exit_code)

# ===== UTILITY METHODS =====

func _calculate_average(values: Array) -> float:
	if values.empty():
		return 0.0
	var sum = 0.0
	for v in values:
		sum += v
	return sum / values.size()

func _calculate_max(values: Array) -> float:
	if values.empty():
		return 0.0
	var max_val = values[0]
	for v in values:
		if v > max_val:
			max_val = v
	return max_val

func _calculate_min(values: Array) -> float:
	if values.empty():
		return 0.0
	var min_val = values[0]
	for v in values:
		if v < min_val:
			min_val = v
	return min_val

func _calculate_percentile(values: Array, percentile: float) -> float:
	if values.empty():
		return 0.0
	
	var sorted = values.duplicate()
	sorted.sort()
	
	var index = int(sorted.size() * percentile)
	if index >= sorted.size():
		index = sorted.size() - 1
	
	return sorted[index]

func wait_for_system_response(timeout: float = 5.0):
	"""Wait for systems to reach stable state"""
	var timer = 0.0
	while timer < timeout:
		yield(get_tree(), "idle_frame")
		timer += get_process_delta_time()
		
		# Check if system is stable (override in derived class)
		if is_system_stable():
			return
	
	log_warning("System did not stabilize within timeout")

func is_system_stable() -> bool:
	"""Override to implement stability check"""
	return true

func generate_subsystem_report():
	"""Generate detailed subsystem test report"""
	log_section("Subsystem Test Report")
	
	# Performance summary
	if performance_monitors.size() > 0:
		print("\nPerformance Summary:")
		for monitor_name in performance_monitors:
			var monitor = performance_monitors[monitor_name]
			if "avg_frame_time" in monitor:
				print("  %s:" % monitor_name)
				print("    Duration: %.2fs" % monitor.duration)
				print("    Avg Frame Time: %.1fms (%.1f FPS)" % 
					[monitor.avg_frame_time, 1000.0 / monitor.avg_frame_time])
				print("    Max Frame Time: %.1fms" % monitor.max_frame_time)
				print("    95th Percentile: %.1fms" % monitor.percentile_95)
	
	# Visual validation summary
	if visual_captures.size() > 0:
		print("\nVisual Captures:")
		for capture_name in visual_captures:
			var capture = visual_captures[capture_name]
			print("  - %s: %dx%d" % [capture_name, capture.viewport_size.x, capture.viewport_size.y])

func initialize_component(component_name: String) -> bool:
	"""Override to initialize specific components"""
	log_info("Initializing component: " + component_name)
	yield(get_tree(), "idle_frame")
	return true

func verify_component_connections() -> bool:
	"""Override to verify component connections"""
	return true

func create_test_environment() -> Node2D:
	"""Override to create test environment"""
	var env = Node2D.new()
	env.name = "TestEnvironment"
	add_child(env)
	return env