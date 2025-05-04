extends Node

# Test script for A Silent Refraction - Iteration 1
# This file should be saved as res://tests/test_iteration1.gd

func _ready():
    print("Starting Iteration 1 Testing")
    
    # Register with escoria autoload when available
    if Engine.has_singleton("escoria"):
        print("✓ Escoria framework detected")
        escoria.connect("ready", _on_escoria_ready)
    else:
        print("✗ Escoria framework not detected")
    
    # Test project structure
    _test_project_structure()

func _on_escoria_ready():
    print("✓ Escoria initialized successfully")
    
    # Test basic game components
    _test_game_state_manager()
    _test_dialog_manager()
    
    # Queue main menu test (after current frame)
    call_deferred("_test_main_menu")

func _test_project_structure():
    # Check if critical scenes are present
    var scene_paths = [
        "res://game/main.tscn",
        "res://game/ui/main_menu.tscn", 
        "res://game/rooms/start/start.tscn",
        "res://game/characters/player.tscn"
    ]
    
    for path in scene_paths:
        if ResourceLoader.exists(path):
            print("✓ Found scene: " + path)
        else:
            print("✗ Missing scene: " + path)
    
    # Check if critical scripts are present
    var script_paths = [
        "res://game/game_state_manager.gd",
        "res://game/dialogs/dialog_manager.gd",
        "res://game/characters/npc_base.gd"
    ]
    
    for path in script_paths:
        if ResourceLoader.exists(path):
            print("✓ Found script: " + path)
        else:
            print("✗ Missing script: " + path)

func _test_game_state_manager():
    # Reference to game state manager (assumes it's added as autoload)
    var gsm = get_node("/root/GameStateManager")
    
    if gsm:
        print("✓ Game State Manager is accessible")
        
        # Test coalition strength tracking
        var initial_strength = gsm.coalition_strength
        print("  Initial coalition strength: " + str(initial_strength))
        
        # Test location unlocking
        var unlocked_locations = gsm.player_knowledge.locations_unlocked
        print("  Initially unlocked locations: " + str(unlocked_locations))
        
        # Test time management
        print("  Initial time remaining: " + str(gsm.time_remaining))
        var time_spent = gsm.spend_time(10.0)
        print("  After spending 10 time units: " + str(gsm.time_remaining))
    else:
        print("✗ Game State Manager not found or not properly set up")

func _test_dialog_manager():
    # Reference to dialog manager (assumes it's added as autoload)
    var dm = get_node("/root/DialogManager")
    
    if dm:
        print("✓ Dialog Manager is accessible")
        # Check if dialog files are loaded
        print("  Number of loaded dialogs: " + str(dm.dialogs.size()))
    else:
        print("✗ Dialog Manager not found or not properly set up")

func _test_main_menu():
    # Get the current scene
    var current_scene = get_tree().current_scene
    
    if current_scene.name == "main_menu":
        print("✓ Main menu is loaded")
        
        # Test UI elements
        var start_button = current_scene.get_node("VBoxContainer/StartButton")
        var quit_button = current_scene.get_node("VBoxContainer/QuitButton")
        
        if start_button and quit_button:
            print("✓ Menu buttons are present")
            
            # Simulate clicking the start button
            start_button.emit_signal("pressed")
            print("  Start button pressed, game should begin")
        else:
            print("✗ Menu buttons not found")
    else:
        print("✗ Main menu not loaded as expected")

func _test_player_movement():
    # This would need to be called after the player is in a room
    var player = escoria.object_manager.get_object("player")
    
    if player:
        print("✓ Player character is in the scene")
        
        # Get current position
        var initial_pos = player.position
        print("  Initial position: " + str(initial_pos))
        
        # Test walkable areas when implemented
        # This would need interaction with Escoria's navigation system
    else:
        print("✗ Player character not found in scene")

# Add this test script as an autoload for easy testing
# In project settings, add "TestIteration1" as an autoload pointing to this script
