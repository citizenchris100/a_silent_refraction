extends Control

func _on_start_button_pressed():
    escoria.change_scene("res://game/rooms/start/start.tscn")

func _on_quit_button_pressed():
    get_tree().quit()
