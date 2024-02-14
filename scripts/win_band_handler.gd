extends Control

func appear():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 1.0, 0.75)
	
func set_text(text):
	$win_label.bbcode_text = "[center]" + text + "[/center]"

func _on_TileMap_game_ended(winner):
	
	if winner is Player:
		set_text(winner.name + " a gagné!")
		$win_label.set("custom_colors/default_color", winner.color)
		appear()
		return
		
	set_text("Match nul !")
	$win_bg.set("custom_colors/default_color", Color.whitesmoke)
	appear()
