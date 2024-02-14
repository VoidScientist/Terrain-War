class_name Player

var name: String
var tile_id: int
var color: Color

var score := 0

func _init(new_name, new_tile_id, new_color):
	name = new_name
	tile_id = new_tile_id
	color = new_color
