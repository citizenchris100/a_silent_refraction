extends "res://src/core/districts/base_district.gd"
# Subsystem Test: Signal Cleanup - Tests proper signal cleanup on scene changes
# This test extends base_district to accurately represent the actual game architecture
#
# TDD NOTE: This test expects signal cleanup functionality that doesn't exist yet.
# Expected failures:
# - GameManager doesn't track signal connections
# - No cleanup happens on scene changes
# - No protection against duplicate connections
# - Memory leaks from orphaned connections are possible
#
# Systems Under Test:
# - GameManager: Should manage and cleanup signal connections
# - Player: Emits movement_state_changed signals
# - ScrollingCamera: Emits camera position/state signals  
# - InputManager: Emits click detection signals
# - District: Manages scene transitions
# - NPCs: Dynamic entities with signal connections
#
# Test Scenarios:
# 1. Scene change cleanup - verify old connections cleaned and new established
# 2. Component removal during runtime - remove components while connected
# 3. Game state transitions - pause/unpause, menu open/close
# 4. Protection against duplicate connections

# Test configuration (manual since we don't extend subsystem_test_base)
var tests_passed = 0
var tests_failed = 0
var current_test = ""
var failed_tests = []
var test_start_time = 0

# Subsystem components
var game_manager: Node
var input_manager: Node
var player_instance: Node2D
var camera_instance: Camera2D
var test_npcs = []

# Signal connection tracking
var initial_connections = {}
var connection_counts = {}
var duplicate_connection_attempts = 0

func _ready():
    # Set up district properties
    district_name = "Signal Cleanup Test District"
    district_description = "Test district for signal cleanup validation"
    
    # Configure camera
    use_scrolling_camera = true
    camera_follow_smoothing = 5.0
    initial_camera_view = "center"
    
    # Create background (MUST be direct child named "Background")
    var background = Sprite.new()
    background.name = "Background"
    background.texture = create_test_texture()
    background.centered = false
    add_child(background)
    
    # Set background size for camera bounds
    background_size = background.texture.get_size()
    
    # Create walkable areas
    create_test_walkable_areas()
    
    # Call parent _ready() - this sets up camera and systems
    ._ready()
    
    # Now set up player using district's method
    setup_player_and_controller(Vector2(960, 540))
    
    # Store references to created components
    store_component_references()
    
    # Run tests
    yield(run_test_scenarios(), "completed")
    
    # Exit with appropriate code
    get_tree().quit(tests_failed)

func create_test_texture() -> Texture:
    var image = Image.new()
    image.create(1920, 1080, false, Image.FORMAT_RGB8)
    image.fill(Color(0.2, 0.2, 0.3))
    var texture = ImageTexture.new()
    texture.create_from_image(image)
    return texture

func create_test_walkable_areas():
    # Simple rectangular walkable area
    walkable_areas.append([
        Vector2(100, 100),
        Vector2(1820, 100),
        Vector2(1820, 980),
        Vector2(100, 980)
    ])

func store_component_references():
    # Find core systems
    game_manager = get_tree().get_nodes_in_group("game_manager")[0] if get_tree().get_nodes_in_group("game_manager").size() > 0 else null
    input_manager = get_tree().get_nodes_in_group("input_manager")[0] if get_tree().get_nodes_in_group("input_manager").size() > 0 else null
    
    # Get player and camera from district setup
    var players = get_tree().get_nodes_in_group("player")
    player_instance = players[0] if players.size() > 0 else null
    
    var cameras = get_tree().get_nodes_in_group("camera")
    camera_instance = cameras[0] if cameras.size() > 0 else null
    
    print("  [INFO] Components found:")
    print("    - GameManager: %s" % ("yes" if game_manager else "no"))
    print("    - InputManager: %s" % ("yes" if input_manager else "no"))
    print("    - Player: %s" % ("yes" if player_instance else "no"))
    print("    - Camera: %s" % ("yes" if camera_instance else "no"))

func run_test_scenarios():
    print("\n" + "============================================================")
    print(" SIGNAL CLEANUP SUBSYSTEM TEST")
    print("============================================================" + "\n")
    
    # Wait for systems to stabilize
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Test 1: Signal connection tracking
    yield(test_signal_connection_tracking(), "completed")
    
    # Test 2: Scene change cleanup
    yield(test_scene_change_cleanup(), "completed")
    
    # Test 3: Component removal during runtime
    yield(test_component_removal(), "completed")
    
    # Test 4: Duplicate connection protection
    yield(test_duplicate_connection_protection(), "completed")
    
    # Generate report
    print_test_summary()

func test_signal_connection_tracking():
    print("\n===== SCENARIO: Signal Connection Tracking =====")
    
    start_test("game_manager_tracks_connections")
    
    # TDD: GameManager should have a way to track active connections
    var has_tracking = false
    if game_manager:
        # Check if GameManager has connection tracking (it won't yet)
        has_tracking = (
            game_manager.has_method("get_active_connections") or
            game_manager.has_method("_track_connection") or
            game_manager.get("active_connections") != null
        )
    
    end_test(has_tracking, "GameManager should track active signal connections")
    
    start_test("can_query_connection_count")
    
    # TDD: Should be able to query how many connections exist
    var can_query = false
    if game_manager and game_manager.has_method("get_connection_count"):
        can_query = true
    
    end_test(can_query, "Should be able to query active connection count")
    
    yield(get_tree(), "idle_frame")

func test_scene_change_cleanup():
    print("\n===== SCENARIO: Scene Change Cleanup =====")
    
    start_test("connections_before_scene_change")
    
    # Create test NPCs
    for i in range(3):
        var npc = create_test_npc(Vector2(300 + i * 200, 500))
        test_npcs.append(npc)
    
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Count initial connections
    var initial_count = count_all_signal_connections()
    print("  [INFO] Initial connection count: %d" % initial_count)
    
    # TDD: GameManager should be connected to player/camera
    var gm_connected_to_player = false
    var gm_connected_to_camera = false
    
    if game_manager and player_instance and player_instance.has_signal("movement_state_changed"):
        gm_connected_to_player = player_instance.is_connected("movement_state_changed", game_manager, "_on_player_movement_state_changed")
    
    if game_manager and camera_instance and camera_instance.has_signal("camera_state_changed"):
        gm_connected_to_camera = camera_instance.is_connected("camera_state_changed", game_manager, "_on_camera_state_changed")
    
    end_test(gm_connected_to_player and gm_connected_to_camera, "GameManager should be connected to player and camera signals")
    
    start_test("cleanup_on_scene_change")
    
    # Simulate scene change by removing all NPCs
    cleanup_test_npcs()
    
    # TDD: GameManager should have a cleanup method
    var has_cleanup = false
    if game_manager:
        has_cleanup = game_manager.has_method("cleanup_connections") or game_manager.has_method("_cleanup_signals")
        
        # Try to call cleanup if it exists
        if game_manager.has_method("cleanup_connections"):
            game_manager.cleanup_connections()
    
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Count connections after cleanup
    var after_cleanup_count = count_all_signal_connections()
    print("  [INFO] Connection count after cleanup: %d" % after_cleanup_count)
    
    # Should have fewer connections after cleanup
    var cleaned_up = after_cleanup_count < initial_count or has_cleanup
    end_test(cleaned_up, "Scene change should cleanup old connections")
    
    start_test("no_orphaned_connections")
    
    # Check for orphaned connections to freed objects
    var has_orphans = check_for_orphaned_connections()
    end_test(not has_orphans, "No orphaned connections to freed objects should exist")
    
    yield(get_tree(), "idle_frame")

func test_component_removal():
    print("\n===== SCENARIO: Component Removal During Runtime =====")
    
    start_test("safe_player_removal")
    
    # Store current player reference
    var original_player = player_instance
    var original_player_parent = player_instance.get_parent()
    
    # Count connections before removal
    var before_removal = count_player_connections()
    
    # Remove player
    original_player_parent.remove_child(player_instance)
    yield(get_tree().create_timer(0.5), "timeout")
    
    # TDD: GameManager should detect and cleanup player connections
    var after_removal = count_player_connections()
    var cleaned_player_connections = after_removal == 0
    
    # Re-add player
    original_player_parent.add_child(original_player)
    player_instance = original_player
    
    # TDD: GameManager should reconnect to player
    yield(get_tree().create_timer(0.5), "timeout")
    var after_readd = count_player_connections()
    var reconnected = after_readd > 0
    
    end_test(cleaned_player_connections and reconnected, "Player removal/addition should be handled safely")
    
    start_test("dynamic_npc_lifecycle")
    
    var lifecycle_safe = true
    
    # Add NPCs dynamically
    var dynamic_npcs = []
    for i in range(5):
        var npc = create_test_npc(Vector2(200 + i * 150, 700))
        dynamic_npcs.append(npc)
        
        # TDD: Each NPC should trigger connection in GameManager
        if game_manager and game_manager.has_method("_on_npc_added"):
            # This method should be called but doesn't exist yet
            lifecycle_safe = false
    
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Remove NPCs one by one
    for npc in dynamic_npcs:
        # TDD: GameManager should cleanup NPC connections before free
        if game_manager and game_manager.has_method("_on_npc_removed"):
            # This method should be called but doesn't exist yet
            lifecycle_safe = false
        
        npc.queue_free()
        yield(get_tree(), "idle_frame")
    
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Check system is still stable
    var system_stable = is_system_stable()
    
    end_test(lifecycle_safe and system_stable, "Dynamic NPC lifecycle should be properly managed")
    
    yield(get_tree(), "idle_frame")

func test_duplicate_connection_protection():
    print("\n===== SCENARIO: Duplicate Connection Protection =====")
    
    start_test("prevent_duplicate_connections")
    
    duplicate_connection_attempts = 0
    
    # TDD: Try to connect same signal multiple times
    if game_manager and player_instance and player_instance.has_signal("movement_state_changed"):
        # Attempt multiple connections (GameManager should prevent duplicates)
        for i in range(3):
            # This would normally create duplicates, but GameManager should prevent it
            if game_manager.has_method("connect_to_player"):
                game_manager.connect_to_player(player_instance)
                duplicate_connection_attempts += 1
    
    # Count actual connections
    var actual_connections = 0
    if player_instance and player_instance.has_signal("movement_state_changed"):
        var connections = player_instance.get_signal_connection_list("movement_state_changed")
        for conn in connections:
            if conn.target == game_manager:
                actual_connections += 1
    
    # Should only have 1 connection despite multiple attempts
    var protected = actual_connections <= 1 or duplicate_connection_attempts == 0
    end_test(protected, "Duplicate connections should be prevented")
    
    start_test("connection_integrity_check")
    
    # TDD: GameManager should have a way to verify connection integrity
    var has_integrity_check = false
    if game_manager:
        has_integrity_check = game_manager.has_method("verify_connections") or game_manager.has_method("_check_connection_integrity")
    
    end_test(has_integrity_check, "Should have connection integrity verification")
    
    yield(get_tree(), "idle_frame")

# Helper methods
func create_test_npc(position: Vector2) -> Node2D:
    var npc = Node2D.new()
    npc.position = position
    npc.add_to_group("npc")
    npc.add_to_group("interactive_object")
    add_child(npc)
    
    # Add a simple signal for testing
    npc.add_user_signal("interacted")
    
    # TDD: GameManager should connect to NPC signals
    if game_manager and game_manager.has_method("_connect_npc_signals"):
        game_manager._connect_npc_signals(npc)
    
    return npc

func cleanup_test_npcs():
    for npc in test_npcs:
        if is_instance_valid(npc):
            # TDD: GameManager should disconnect before free
            if game_manager and game_manager.has_method("_disconnect_npc_signals"):
                game_manager._disconnect_npc_signals(npc)
            npc.queue_free()
    test_npcs.clear()

func count_all_signal_connections() -> int:
    var total = 0
    
    # Count player connections
    total += count_player_connections()
    
    # Count camera connections
    if camera_instance:
        for signal_name in ["camera_moved", "camera_state_changed", "bounds_changed", "camera_move_started", "camera_move_completed"]:
            if camera_instance.has_signal(signal_name):
                total += camera_instance.get_signal_connection_list(signal_name).size()
    
    # Count NPC connections
    for npc in get_tree().get_nodes_in_group("npc"):
        if is_instance_valid(npc) and npc.has_signal("interacted"):
            total += npc.get_signal_connection_list("interacted").size()
    
    return total

func count_player_connections() -> int:
    if not player_instance or not player_instance.has_signal("movement_state_changed"):
        return 0
    
    return player_instance.get_signal_connection_list("movement_state_changed").size()

func check_for_orphaned_connections() -> bool:
    # Check if any connections point to freed objects
    var has_orphans = false
    
    if player_instance and player_instance.has_signal("movement_state_changed"):
        var connections = player_instance.get_signal_connection_list("movement_state_changed")
        for conn in connections:
            if not is_instance_valid(conn.target):
                has_orphans = true
                print("  [WARN] Orphaned connection found in player signals!")
    
    return has_orphans

func is_system_stable() -> bool:
    # Check if core systems are still functional
    return (
        game_manager != null and 
        is_instance_valid(game_manager) and
        player_instance != null and 
        is_instance_valid(player_instance) and
        camera_instance != null and
        is_instance_valid(camera_instance)
    )

# Test framework methods
func start_test(test_name: String):
    current_test = test_name
    test_start_time = OS.get_ticks_msec()
    print("\n  Testing: " + test_name)

func end_test(passed: bool, message: String):
    var duration = (OS.get_ticks_msec() - test_start_time) / 1000.0
    
    if passed:
        tests_passed += 1
        print("    ✓ PASS: %s (%.2fs)" % [message, duration])
    else:
        tests_failed += 1
        failed_tests.append(current_test)
        print("    ✗ FAIL: %s (%.2fs)" % [message, duration])

func print_test_summary():
    print("\n" + "--------------------------------------------------")
    print(" Test Summary")
    print("--------------------------------------------------")
    print("Tests Passed: %d" % tests_passed)
    print("Tests Failed: %d" % tests_failed)
    
    if tests_failed > 0:
        print("\nFailed Tests:")
        for test in failed_tests:
            print("  - " + test)
        
        print("\nExpected TDD Failures:")
        print("  - GameManager lacks connection tracking")
        print("  - No cleanup methods exist")
        print("  - No duplicate protection implemented")
        print("  - No NPC lifecycle management")