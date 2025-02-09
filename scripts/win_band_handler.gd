extends Control

var win_messages: Array = [
	" has won!",
	" claimed victory!",
	" vanquished!",
	" dominated the arena!"
	]

func _ready():
	randomize()
	modulate.a = 0

func appear():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 1.0, 0.75)
	
func set_text(text):
	$win_label.text = text

func _on_TileMap_game_ended(winner):
	
	if winner is Player:
		win_messages.shuffle()
		set_text(winner.name + win_messages[0])
		$win_label.set("custom_colors/font_color", winner.color)
	else:
		set_text("Draw !")
		$win_label.set("custom_colors/font_color", Color.whitesmoke)
		
	appear()
