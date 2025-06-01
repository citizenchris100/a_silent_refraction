extends Node2D
# VSync Settings Test: Validates that rendering settings are configured correctly

# ===== TEST CONFIGURATION =====
var run_all_tests = true
var log_debug_info = true

# Test state
var test_name = "VSyncSettingsTest"
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var current_suite = ""
var failed_tests = []

func _ready():
	var separator = ""
	for i in range(50):
		separator += "="
	
	print("\n" + separator)
	print(" %s TEST SUITE" % test_name.to_upper())
	print(separator + "\n")
	
	run_tests()
	
	print("\n" + separator)
	print(" SUMMARY: %d passed, %d failed" % [tests_passed, tests_failed])
	print(separator + "\n")
	
	if tests_failed == 0:
		print("[PASS] All %s tests passed!" % test_name)
	else:
		print("[FAIL] Some tests failed!")
		for failed in failed_tests:
			print("  - " + failed)
	
	# Clean exit for headless testing
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit(tests_failed)

func run_tests():
	if run_all_tests:
		run_test_suite("VSync Configuration Tests", funcref(self, "test_suite_vsync_config"))

func run_test_suite(suite_name: String, test_func: FuncRef):
	current_suite = suite_name
	print("\n===== TEST SUITE: %s =====" % suite_name)
	test_func.call_func()

func test_suite_vsync_config():
	# Test 1: VSync should be enabled
	start_test("test_vsync_is_enabled")
	var vsync_enabled = ProjectSettings.get_setting("rendering/quality/vsync/use_vsync")
	if log_debug_info:
		print("  VSync enabled: %s" % str(vsync_enabled))
	end_test(vsync_enabled == true, "VSync should be enabled")
	
	# Test 2: VSync via compositor should be disabled
	start_test("test_vsync_via_compositor_is_disabled")
	var vsync_via_compositor = ProjectSettings.get_setting("rendering/quality/vsync/vsync_via_compositor")
	if log_debug_info:
		print("  VSync via compositor: %s" % str(vsync_via_compositor))
	end_test(vsync_via_compositor == false, "VSync via compositor should be disabled")
	
	# Test 3: Pixel snap should be enabled
	start_test("test_pixel_snap_is_enabled")
	var pixel_snap = ProjectSettings.get_setting("rendering/quality/2d/use_pixel_snap")
	if log_debug_info:
		print("  Pixel snap enabled: %s" % str(pixel_snap))
	end_test(pixel_snap == true, "Pixel snap should be enabled for SCUMM-style graphics")
	
	# Test 4: Check if settings are malformed
	start_test("test_settings_not_malformed")
	# Check raw project.godot content to ensure settings aren't corrupted
	var file = File.new()
	var settings_valid = true
	var malformed_lines = []
	
	if file.open("res://project.godot", File.READ) == OK:
		var line_num = 0
		while not file.eof_reached():
			line_num += 1
			var line = file.get_line()
			# Check for malformed VSync settings (comments merged with settings)
			if line.find("#") != -1 and line.find("vsync") != -1:
				malformed_lines.append("Line %d: %s" % [line_num, line])
				settings_valid = false
			if line.find("#") != -1 and line.find("pixel_snap") != -1:
				malformed_lines.append("Line %d: %s" % [line_num, line])
				settings_valid = false
		file.close()
		
		if log_debug_info and malformed_lines.size() > 0:
			print("  Found malformed settings:")
			for line in malformed_lines:
				print("    - %s" % line)
	else:
		settings_valid = false
		if log_debug_info:
			print("  Could not open project.godot for validation")
	
	# Clean up File object reference
	file = null
	
	end_test(settings_valid, "Project settings should not be malformed")

# Helper functions
func start_test(test_name: String):
	current_test = test_name
	if log_debug_info:
		print("\n[TEST] " + test_name)

func end_test(passed: bool, message: String):
	if passed:
		tests_passed += 1
		print("  ✓ PASS: %s: %s" % [current_test, message])
	else:
		tests_failed += 1
		failed_tests.append(current_test)
		print("  ✗ FAIL: %s: %s" % [current_test, message])