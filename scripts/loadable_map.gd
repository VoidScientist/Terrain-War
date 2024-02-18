extends TileMap
class_name LoadableMap

export var width: int = 5
export var height: int = 5

onready var play_area := Rect2(0, 0, width + 2, height + 2)


func update_play_area():
	play_area = Rect2(0, 0, width + 2, height + 2)


func load_map(f):
	
	var save = FileService.load_data(f)
	var data = save["data"]
	
	if not save.get("nature", null) == "MAP":
		print("data is not map or unrecognized")
		return
	
	var saved_size = data["size"]
	
	width = saved_size.x
	height = saved_size.y
	
	for pos in get_used_cells():
		set_cellv(pos, -1)
	
	for key in data:
		
		if not key is int:
			continue
			
		for pos in data[key]:
			
			set_cellv(pos, key)
	
	play_area = Rect2(Vector2.ZERO, saved_size + Vector2(2,2))
