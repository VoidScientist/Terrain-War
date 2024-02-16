extends Control

func _on_play_button_pressed():
	$PLAYMENU.visible = true
	$PLAYMENU/AnimationPlayer.play_backwards("fade")

func _on_leave_game_pressed():
	get_tree().quit()


func _on_start_game_pressed():
	var name1 = $PLAYMENU/Control/parameters/player1.text
	var name2 = $PLAYMENU/Control/parameters/player2.text
	var col1 = $PLAYMENU/Control/player1_picker.color
	var col2 = $PLAYMENU/Control/player2_picker.color
	
	if name1:
		PlayerService.change_name(0, name1)
	if name2:
		PlayerService.change_name(1, name2)
		
	PlayerService.change_color(0, col1)
	PlayerService.change_color(1, col2)

	get_tree().change_scene("res://scenes/Game.tscn")

func _on_back_button_pressed():
	$PLAYMENU.visible = false
