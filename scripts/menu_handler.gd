extends Control

onready var map_selection = $PLAYMENU/Control/parameters/ItemList


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
	
	var scene = load("res://scenes/Game.tscn").instance()
	
	if not map_selection.is_anything_selected():
		return
	
	var item = map_selection.get_selected_items()[0]
	var file_name = map_selection.get_item_text(item)
	
	scene.load_map("user://" + file_name)
	
	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)
	

func _on_back_button_pressed():
	$PLAYMENU.visible = false


func _on_create_button_pressed():
	var scene = load("res://scenes/map_creator.tscn").instance()
			
	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)
