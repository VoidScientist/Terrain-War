class_name Player

const BASE_SCORE = 0

var name: String
var tile_id: int
var color: Color

var score := BASE_SCORE

func _init(new_name, new_tile_id, new_color):
	name = new_name
	tile_id = new_tile_id
	color = new_color
