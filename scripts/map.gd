extends LoadableMap
class_name PlayableMap

signal game_ended(winner)

const DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT, Vector2(1,1), Vector2(1,-1), Vector2(-1,-1), Vector2(-1,1)]

onready var camera: Camera2D = $Camera2D
onready var score_bar: TextureRect = $UI/UI_container/progress_bar
onready var win_band: Control = $UI/UI_container/win_band
onready var face_map: TileMap = $face_map
onready var players := PlayerService

onready var half_count_faces: int = len(face_map.tile_set.get_tiles_ids()) / 2


var flood_fill: FloodFill

var max_score: int = 0

var current_player: Player

var ownerless_tiles := [-1, 3]


func _ready() -> void:
	
	connect("game_ended", win_band, "_on_TileMap_game_ended")
	
	current_player = players.randomize_turn()

	flood_fill = FloodFill.new(play_area, self)
	
	for player in players.get_players():
		tile_set.tile_set_modulate(player.tile_id, player.color)
		for face in range(half_count_faces):
			face_map.tile_set.tile_set_modulate(half_count_faces * player.tile_id + face, player.color)
			
	for cell in get_used_cells_by_id(0):
		face_map.set_cellv(cell, rand_range(0,half_count_faces))
		
	for cell in get_used_cells_by_id(1):
		face_map.set_cellv(cell, rand_range(half_count_faces,2*half_count_faces))
	
	camera.focus_on_area(play_area, cell_size)
	
	# fills blocked area
	check_isolated_area(true)
	
	max_score = get_max_score()
	
	if max_score == 0:
		emit_signal("game_ended", null)
		back_to_main_menu()
	
	
	update_ui()


func back_to_main_menu():
	update_ui()
			
	players.reset_scores()
	
	# TODO: THIS IS A WAY TO DO IT, BUT QUITE BAD
	# SO MAKE IT BETTER WITH BUTTONS MAYBE?
	
	yield(get_tree().create_timer(5), "timeout")
	
	var scene = load("res://scenes/main_menu.tscn").instance()
	
	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)


func _physics_process(delta) -> void:
	var clicked = world_to_map(get_global_mouse_position())
	
	var is_empty = get_cellv(clicked) in ownerless_tiles
	
	var cell_claimable = is_empty and ally_cell_adj(clicked)
	
	if Input.is_action_just_pressed("claim") and cell_claimable:
		
		place_cell(clicked, current_player.tile_id)
		
		current_player.score += 1
		
		check_isolated_area()
		
		current_player = players.change_turn()
		
		if players.game_finished(max_score):
			emit_signal("game_ended", players.get_winner())
			
			back_to_main_menu()
		
		update_ui()

func place_cell(pos, id):
	set_cellv(pos, id)
	
	var face_start = half_count_faces * id
	face_map.set_cellv(pos, rand_range(face_start, face_start + half_count_faces))
	
func get_max_score() -> int:
	var res = 0
	
	for x in range(play_area.size.x):
		
		for y in range(play_area.size.y):
			
			if get_cell(x, y) != -1: continue
			
			res += 1

	return res


func update_ui() -> void:
	update_available()
	
	VisualServer.set_default_clear_color(current_player.color)
	
	var gradient = players.get_players_gradient(max_score)
	
	score_bar.get_texture().set_gradient(gradient)
	

func ally_cell_adj(clicked) -> bool:
	var current_player_id = current_player.tile_id

	for dir in DIRECTIONS:
		
		var adj_cell = clicked + dir
		
		if get_cellv(adj_cell) == current_player_id: 
			
			return true
	
	return false
	

func update_available() -> void:
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
			
	if av_pos == 0 and not players.game_finished(max_score):
		
		current_player = players.change_turn()


func check_isolated_area(prep_mode = false) -> void:
	var checked_tiles = []
	
	for x in range(play_area.size.x):
		
		for y in range(play_area.size.y):
			
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
				
				place_cell(pos, current_player.tile_id)
				
				current_player.score += 1
