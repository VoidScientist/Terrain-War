extends Control

func appear():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 1.0, 0.75)
	
func set_text(text):
	$win_label.bbcode_text = "[center]" + text + "[/center]"
