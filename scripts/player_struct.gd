class_name Player

var id
var color

var score = 0

func _init(new_id, new_color):
	id = new_id
	color = new_color
	
func add_score(value):
	score += value
