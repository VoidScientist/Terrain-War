extends Node
class_name FloodFill

var borders: Rect2
var position: Vector2

const DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT, Vector2(1,1), Vector2(1,-1), Vector2(-1,-1), Vector2(-1,1)]
var queue := []
var pos_history := []
var ignore := [-1, 3]

var map: TileMap

var out_of_map: bool = true
var success: bool = true

func is_valid(cell_pos: Vector2, self_id, error_id) -> bool:
	var tile_id = map.get_cellv(cell_pos)
	
	if not borders.has_point(cell_pos): return false
	
	if tile_id in ignore: return true
	
	if tile_id == error_id:
		out_of_map = false
		success = false
		
	if tile_id == self_id:
		out_of_map = false
			
	return false
	
func reset_var() -> void:
	pos_history.clear()
	queue.clear()
	success = true
	out_of_map = true
	
func set_start_pos(new_start_pos) -> void:
	assert(borders.has_point(new_start_pos))
	reset_var()
	
	if not map.get_cellv(new_start_pos) in ignore:
		print("Wrong position !")
		return
	queue.append(new_start_pos)

func _init(new_borders, new_map):
	borders = new_borders
	map = new_map
	
func check_map(self_id, error_id) -> Array:
	while len(queue) > 0:
		position = queue.pop_front()
		pos_history.append(position)
		
		for direction in DIRECTIONS:
			var new_pos = position + direction
			var found = (new_pos in pos_history or new_pos in queue)
			
			if is_valid(new_pos, self_id, error_id) and not found:
				queue.append(new_pos)
				
	if out_of_map:
		for cell in pos_history:
			map.set_cellv(cell, 2)
		
	return [(success and not out_of_map), pos_history]
