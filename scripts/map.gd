extends TileMap
class_name Map

signal game_ended(winner)

onready var camera: Camera2D = $Camera2D
onready var score_bar: TextureRect = $UI/UI_container/progress_bar
onready var win_band: Control = $UI/UI_container/win_band
onready var players: PlayerService = $PlayerService

const DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT, Vector2(1,1), Vector2(1,-1), Vector2(-1,-1), Vector2(-1,1)]

var mouse_pos: Vector2
var flood_fill: FloodFill
var map: Rect2

var score: Dictionary = {"p1": 1, "p2": 1}
var max_score: int = 2

var current_player: Player

var ownerless_tiles := [-1, 3]


func _ready() -> void:
	map = get_used_rect()
	
	current_player = players.randomize_turn()

	flood_fill = FloodFill.new(map, self)
	
	for player in players.get_players():
		tile_set.tile_set_modulate(player.tile_id, player.color)
	
	camera.focus_on_area(get_used_rect(), cell_size)
	
	# apparently this line is for setting up map
	check_isolated_area(true)
	
	max_score = get_max_score()
	
	update_ui()


func _physics_process(delta) -> void:
	mouse_pos = get_global_mouse_position()
	
	var cell_claimable = is_cell_empty(mouse_pos) and ally_cell_adj(mouse_pos)
	
	if Input.is_action_just_pressed("claim") and cell_claimable:
		
		claim_cell(mouse_pos)
		
		current_player.score += 1

		check_isolated_area()
		
		current_player = players.change_turn()
		
		if players.game_finished(max_score):
			emit_signal("game_ended", players.get_winner())
		
		update_ui()

	
func get_max_score() -> int:
	var res = 0
	
	for x in range(map.size.x):
		
		for y in range(map.size.y):
			
			if get_cell(x, y) != -1: continue
			
			res += 1

	return res


func update_ui() -> void:
	show_available_position()
	
	VisualServer.set_default_clear_color(current_player.color)
	
	var gradient = players.get_players_gradient(max_score)
	
	score_bar.get_texture().set_gradient(gradient)
	

func claim_cell(mouse_pos) -> void:
	var target_cell = world_to_map(mouse_pos)
	
	set_cellv(target_cell, current_player.tile_id)
	
	
func is_cell_empty(mouse_pos) -> bool:
	return get_cellv(world_to_map(mouse_pos)) in ownerless_tiles


func ally_cell_adj(mouse_pos) -> bool:
	var target_cell = world_to_map(mouse_pos)
	var current_player_id = current_player.tile_id

	for dir in DIRECTIONS:
		
		var adj_cell = target_cell + dir
		
		if get_cellv(adj_cell) == current_player_id: 
			
			return true
	
	return false
	

func show_available_position() -> void:
	var old_av_pos = get_used_cells_by_id(3)
	
	for old_pos in old_av_pos:
		
		set_cellv(old_pos, -1)
	
	var av_pos = 0
		
	var cells = get_used_cells_by_id(current_player.tile_id)
	
	tile_set.tile_set_modulate(3, current_player.color)
	
	for cell in cells:
		
		for direction in DIRECTIONS:
			
			if not get_cellv(cell + direction) == -1: continue
			
			set_cellv(cell + direction, 3)
			
			av_pos += 1
			
	if av_pos == 0 and not score["p1"] + score["p2"] >= max_score:
		current_player = players.change_turn()


func check_isolated_area(prep_mode = false) -> void:
	var checked_tiles = []
	
	for x in range(map.size.x):
		
		for y in range(map.size.y):
			
			var checked = Vector2(x, y) in checked_tiles 
			var is_player = not get_cell(x, y) in ownerless_tiles
			
			if checked or is_player: continue
			
			flood_fill.set_start_pos(Vector2(x, y))
			
			var enemy = players.get_other()
			var results = flood_fill.check_map(current_player.tile_id, enemy.tile_id)
			var success = results[0]
			var history = results[1]
			
			for pos in history:
				
				checked_tiles.append(pos)
				
				if not success or prep_mode: continue
				
				set_cellv(pos, current_player.tile_id)
				current_player.score += 1
