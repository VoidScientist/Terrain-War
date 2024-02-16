extends Control

func _on_play_button_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")
	

func _on_leave_game_pressed():
	get_tree().quit()
