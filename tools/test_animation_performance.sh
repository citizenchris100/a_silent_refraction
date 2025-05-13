#!/bin/bash
# Script to test animation performance for A Silent Refraction
# Runs performance tests for animated background elements

# Set up variables
DISTRICT_NAME=${1:-"shipping"}
PERFORMANCE_LOG="animation_performance_log.txt"
ELEMENT_COUNTS=(5 10 20 50 100)

# Check if Godot is available
if ! command -v godot &> /dev/null; then
    echo "Error: Godot is required but not found in PATH."
    echo "Please ensure Godot is installed and in your PATH."
    exit 1
fi

# Display header
echo "===== A Silent Refraction Animation Performance Test ====="
echo "Testing district: $DISTRICT_NAME"
echo "$(date)"
echo "========================================================"
echo ""

# Initialize log file
echo "Animation Performance Test - $(date)" > "$PERFORMANCE_LOG"
echo "District: $DISTRICT_NAME" >> "$PERFORMANCE_LOG"
echo "----------------------------------------" >> "$PERFORMANCE_LOG"

# Create temporary test script
TMP_SCRIPT=$(mktemp)
cat > "$TMP_SCRIPT" << EOL
extends SceneTree

# Animation performance test script
var district_name = "$DISTRICT_NAME"
var element_counts = [5, 10, 20, 50, 100]
var test_duration = 5.0 # seconds per test
var results = []

func _init():
    print("Starting animation performance test")
    print("Testing district: " + district_name)
    
    # Run tests for each element count
    for count in element_counts:
        print("\\nTesting with " + str(count) + " elements...")
        var result = test_performance(count)
        results.append(result)
    
    # Output results
    print("\\n\\n===== RESULTS =====")
    print("Element Count | Avg FPS | Min FPS | Memory Usage (MB)")
    print("------------------------------------------------")
    
    for i in range(results.size()):
        var r = results[i]
        print(str(element_counts[i]).pad_zeros(2) + "           | " + 
              str(r.avg_fps).pad_decimals(1) + "    | " + 
              str(r.min_fps).pad_decimals(1) + "    | " + 
              str(r.memory_mb).pad_decimals(1))
    
    # Save to file
    var file = File.new()
    file.open("res://animation_performance_results.json", File.WRITE)
    file.store_string(JSON.print(results, "  "))
    file.close()
    
    print("\\nResults saved to animation_performance_results.json")
    print("Test completed. Exiting.")
    quit()

func test_performance(element_count):
    # Load the district scene
    var scene_path = "res://src/districts/" + district_name + "/" + district_name + "_district.tscn"
    var district_scene = load(scene_path)
    if district_scene == null:
        print("ERROR: Could not load district scene: " + scene_path)
        return {"error": "Scene not found"}
    
    var district = district_scene.instance()
    get_root().add_child(district)
    
    # Wait for district to initialize
    yield(get_tree().create_timer(1.0), "timeout")
    
    # Create test elements
    var added = 0
    var types = ["computer_terminal", "warning_light", "ventilation_fan", "steam_vent", "flickering_light"]
    
    for i in range(element_count):
        var type = types[i % types.size()]
        var position = Vector2(100 + (i % 10) * 50, 100 + (i / 10) * 50)
        
        if district.has_method("add_animated_element"):
            district.add_animated_element(type, "test_" + str(i), position)
            added += 1
    
    print("Added " + str(added) + " test elements")
    
    # Wait for all elements to initialize
    yield(get_tree().create_timer(1.0), "timeout")
    
    # Measure performance
    var frames = 0
    var total_fps = 0
    var min_fps = 1000
    var start_time = OS.get_ticks_msec()
    var end_time = start_time + (test_duration * 1000)
    
    while OS.get_ticks_msec() < end_time:
        var frame_start = OS.get_ticks_msec()
        yield(get_tree(), "idle_frame")
        frames += 1
        
        var frame_time = OS.get_ticks_msec() - frame_start
        var fps = 1000.0 / max(frame_time, 1)
        total_fps += fps
        min_fps = min(min_fps, fps)
        
        # Status update every second
        if frames % 60 == 0:
            print("  Testing: " + str((OS.get_ticks_msec() - start_time) / 1000.0).pad_decimals(1) + "s / " + 
                  str(test_duration).pad_decimals(1) + "s, Current FPS: " + str(fps).pad_decimals(1))
    
    # Calculate results
    var avg_fps = total_fps / frames
    var memory_mb = OS.get_static_memory_usage() / (1024.0 * 1024.0)
    
    print("Test completed:")
    print("  Average FPS: " + str(avg_fps).pad_decimals(1))
    print("  Minimum FPS: " + str(min_fps).pad_decimals(1))
    print("  Memory usage: " + str(memory_mb).pad_decimals(1) + " MB")
    
    # Clean up
    get_root().remove_child(district)
    district.queue_free()
    
    # Wait for cleanup
    yield(get_tree().create_timer(1.0), "timeout")
    
    return {
        "element_count": element_count,
        "avg_fps": avg_fps,
        "min_fps": min_fps,
        "memory_mb": memory_mb,
        "frames_measured": frames
    }
EOL

# Run the test script with Godot
echo "Running animation performance tests..."
godot --script "$TMP_SCRIPT" --path $(pwd)

# Check if results file was generated
if [ -f "animation_performance_results.json" ]; then
    # Format and add to log
    echo "Test Results:" >> "$PERFORMANCE_LOG"
    cat animation_performance_results.json >> "$PERFORMANCE_LOG"
    echo "" >> "$PERFORMANCE_LOG"
    echo "Test completed at $(date)" >> "$PERFORMANCE_LOG"
    
    echo ""
    echo "Test complete! Results saved to: $PERFORMANCE_LOG"
    echo "You can also view the raw JSON results in: animation_performance_results.json"
else
    echo "Test failed or did not complete successfully."
fi

# Clean up
rm -f "$TMP_SCRIPT"