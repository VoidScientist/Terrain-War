extends TileMap
class_name Map

export (Color) var player_1_col
export (Color) var player_2_col

onready var camera: Camera2D = $Camera2D
onready var score_bar: TextureRect = $UI/UI_container/progress_bar
onready var win_band: Control = $UI/UI_container/win_band
onready var player_colors := [player_1_col, player_2_col]

const players = ["p1", "p2"]
const DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT, Vector2(1,1), Vector2(1,-1), Vector2(-1,-1), Vector2(-1,1)]

var mouse_pos: Vector2
var flood_fill: FloodFill
var map: Rect2

var score: Dictionary = {"p1": 1, "p2": 1}
var max_score: int = 2
var current: int = 0

var ownerless_tiles := [-1, 3]


func _ready() -> void:
	map = get_used_rect()

	flood_fill = FloodFill.new(map, self, 1-current, current)
	
	tile_set.tile_set_modulate(0, player_1_col)
	tile_set.tile_set_modulate(1, player_2_col)
	
	$UI.visible = true
	
	check_isolated_area(true)
	setup_map()
	set_camera_up()
	update_ui()


func _physics_process(delta) -> void:
	mouse_pos = get_global_mouse_position()
	
	var cell_claimable = is_cell_empty(mouse_pos) and ally_cell_adj(mouse_pos, current)
	
	if Input.is_action_just_pressed("claim") and cell_claimable:
		
		claim_cell(mouse_pos, current)
		
		score[players[current]] += 1

		check_isolated_area()
		swap_turn()
		update_ui()
		check_win()
		update_ui()


func swap_turn() -> void:
	current = (current + 1) % 2
	flood_fill.change_ids(1 - current, current)
	
	
func setup_map() -> void:
	for x in range(map.size.x):
		
		for y in range(map.size.y):
			
			if get_cell(x, y) != -1: continue
			
			max_score += 1


func highlight_clickable_cells() -> void:
	tile_set.tile_set_modulate(3, player_colors[current])


func update_ui() -> void:
	clean_available()
	show_available_position()
	VisualServer.set_default_clear_color(player_colors[current])
	
	var new_gradient = Gradient.new()
	var color_1_range = (score["p1"] - score["p2"]) / float(max_score)
	
	new_gradient.colors = PoolColorArray([player_1_col, player_2_col])
	new_gradient.offsets = PoolRealArray([color_1_range, 0.5 + color_1_range])
	new_gradient.set_interpolation_mode(new_gradient.GRADIENT_INTERPOLATE_CONSTANT)
	score_bar.get_texture().set_gradient(new_gradient)


func set_camera_up() -> void:
	var pix_size = get_used_rect().size
	var size = max((pix_size.y * cell_size.y) / get_viewport().get_visible_rect().size.y, 
				  (pix_size.x * cell_size.x) / get_viewport().get_visible_rect().size.x)
	camera.zoom = Vector2(size, size)
	camera.position.x = map.get_center().x * cell_size.x
	camera.position.y = map.get_center().y * cell_size.y


func claim_cell(mouse_pos, cell) -> void:
	var target_cell = world_to_map(mouse_pos)
	set_cell(target_cell.x, target_cell.y, cell)
	
	
func is_cell_empty(mouse_pos) -> bool:
	return get_cellv(world_to_map(mouse_pos)) in ownerless_tiles


func ally_cell_adj(mouse_pos, turn) -> bool:
	var target_cell = world_to_map(mouse_pos)

	for dir in DIRECTIONS:
		
		var adj_cell = target_cell + dir
		
		if get_cellv(adj_cell) == turn: return true
	
	return false


func check_win() -> void:
	var game_finished = score["p1"] + score["p2"] >= max_score
	
	if not game_finished: return
		
	var winner = 0 if score["p1"] > score["p2"] else 1
	var font_color = player_colors[winner]
	var band_text = "Joueur " + str(winner + 1) + " a gagné!"
	
	if score["p1"] == score["p2"]:
		band_text = "Match nul !"
		font_color = Color.whitesmoke
	
	win_band.set_text(band_text)
	win_band.get_child(2).set("custom_colors/default_color", font_color)
	
	win_band.appear()


func clean_available() -> void:
	var old_av_pos = get_used_cells_by_id(3)
	
	for old_pos in old_av_pos:
		
		set_cellv(old_pos, -1)


func show_available_position() -> void:
	var av_pos = 0
		
	var cells = get_used_cells_by_id(current)
	
	tile_set.tile_set_modulate(3, player_colors[current])
	
	for cell in cells:
		
		for direction in DIRECTIONS:
			
			if not get_cellv(cell + direction) == -1: continue
			
			set_cellv(cell + direction, 3)
			av_pos += 1
				
	if av_pos == 0 and not score["p1"] + score["p2"] >= max_score:
		swap_turn()


func check_isolated_area(prep_mode = false) -> void:
	var checked_tiles = []
	
	for x in range(map.size.x):
		for y in range(map.size.y):
			
			var checked = Vector2(x, y) in checked_tiles 
			var is_invalid = not get_cell(x, y) in ownerless_tiles
			
			if checked or is_invalid: continue
			
			flood_fill.set_start_pos(Vector2(x, y))
			
			var results = flood_fill.check_map()
			var success = results[0]
			var history = results[1]
			
			for pos in history:
				
				checked_tiles.append(pos)
				
				if not success or prep_mode: continue
				
				set_cellv(pos, current)
				score[players[current]] += 1
