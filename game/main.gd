extends Node

func _ready():
    # Check if escoria is available
    if has_node("/root/escoria"):
        print("Escoria found, initializing game...")
        
        # Wait a moment to ensure Escoria is fully initialized
        await get_tree().create_timer(0.5).timeout
        
        # Change to the start scene
        escoria.change_scene("res://game/rooms/start/start.tscn")
    else:
        print("ERROR: Escoria framework not found!")
        
        # Fallback - directly load the start scene
        get_tree().change_scene_to_file("res://game/rooms/start/start.tscn")
