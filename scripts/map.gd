extends TileMap
class_name Map

#Mouse position assigned in _physics_process()
var mouse_pos

#State determining player turns

const players = ["p1", "p2"]
var current = 0

var map: Rect2
# Player colors 
export (Color) var player_1_col
export (Color) var player_2_col
var player_colors
# Possible directions
const DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT, Vector2(1,1), Vector2(1,-1), Vector2(-1,-1), Vector2(-1,1)]
# Algorithm instance
var flood_fill
# Get game camera
onready var camera = $Camera2D
# Get game UI
onready var score_bar = $UI/UI_container/progress_bar
onready var win_band = $UI/UI_container/win_band
# Player scores
var score = {"p1": 1, "p2": 1}
var max_score = 2
# Cells considered as void :
var ignore := [-1, 3]

#Initialising the first player's turn
func _ready():
	# get the rect of the map
	map = get_used_rect()
	# init the algorithm
	flood_fill = FloodFill.new(map, self, 1-current, current)
	# list of player_colors used when turn change
	player_colors = [player_1_col, player_2_col]
	
	# Used to fill empty spaces (so that it doesn't hinder max score)
	check_isolated_area(true)
	
	# set player tiles with corresponding colors
	tile_set.tile_set_modulate(0, player_1_col)
	tile_set.tile_set_modulate(1, player_2_col)
	
	fill_void()
	
	$UI.visible = true
	set_camera_up()
	update_ui()

#Game loop
func _physics_process(delta):
	mouse_pos = get_global_mouse_position()
	var cell_claimable = is_cell_empty(mouse_pos) and ally_cell_adj(mouse_pos, current)
	
	# if input pressed then claim
	if Input.is_action_just_pressed("claim") and cell_claimable:
		
		if not claim_cell(mouse_pos, current): return
		
		score[players[current]] += 1

		check_isolated_area()
		swap_turn()
		update_ui()
		check_win()
		update_ui()

func swap_turn():
	current = (current+1)%2
	flood_fill.change_ids(1-current,current)
	
func fill_void():
	# iterate through the map if cell valid add to max score 1
	for x in range(map.size.x):
		for y in range(map.size.y):
			if get_cell(x, y) == -1:
				max_score += 1

func highlight_clickable_cells():
	tile_set.tile_set_modulate(3, player_colors[current])

# Update UI according to scores:
func update_ui():
	# visual indication of where you can go
	show_available_position()
	# visual indication of whose turn it is
	VisualServer.set_default_clear_color(player_colors[current])
	
	var new_gradient = Gradient.new()
	var color_1_range = 0.0 + (score["p1"] - score["p2"]) / float(max_score)
	
	new_gradient.colors = PoolColorArray([player_1_col, player_2_col])
	new_gradient.offsets = PoolRealArray([color_1_range, 0.5 + color_1_range])
	new_gradient.set_interpolation_mode(new_gradient.GRADIENT_INTERPOLATE_CONSTANT)
	score_bar.get_texture().set_gradient(new_gradient)
	score_bar.update()

# Center camera and zooms in a way to see the entirety of the tilemap
func set_camera_up():
	var pix_size = get_used_rect().size
	var size = max((pix_size.y * cell_size.y) / get_viewport().get_visible_rect().size.y, 
				  (pix_size.x * cell_size.x) / get_viewport().get_visible_rect().size.x)
	camera.zoom = Vector2(size, size)
	camera.position.x = map.get_center().x * cell_size.x
	camera.position.y = map.get_center().y * cell_size.y

#Claiming a cell
func claim_cell(mouse_pos, cell):
	var target_cell = world_to_map(mouse_pos)
	set_cell(target_cell.x, target_cell.y, cell)
	return true
	
#Is the target cell empty ?
func is_cell_empty(mouse_pos):
	return get_cellv(world_to_map(mouse_pos)) in ignore
		
#check if a cell of the same player is adjacent to the cell the player wants to claim
func ally_cell_adj(mouse_pos, turn):
	var target_cell = world_to_map(mouse_pos)

	# check whether cell clicked has an adjacent player cell
	for dir in DIRECTIONS:
		var adj_cell = target_cell + dir
		if adj_cell != target_cell and get_cellv(adj_cell) == turn:
			return true
	
	return false

func check_win():
	if score["p1"] + score["p2"] >= max_score:
		if score["p1"] > score["p2"]:
			win_band.set_text("Joueur 1 a gagné !")
			win_band.get_child(2).set("custom_colors/default_color", player_1_col)
		elif score["p1"] < score["p2"]:
			win_band.set_text("Joueur 2 a gagné !")
			win_band.get_child(2).set("custom_colors/default_color", player_2_col)
		elif score["p1"] == score["p2"]:
			win_band.set_text("Match nul !")
			win_band.get_child(2).set("custom_colors/default_color", Color.whitesmoke)
		win_band.appear()

func clean_available():
	# clean up old highlighted cells
	var old_av_pos = get_used_cells_by_id(3)
	for old_pos in old_av_pos:
		set_cellv(old_pos, -1)

func show_available_position():
	var av_pos = 0
	clean_available()
		
	var cells = get_used_cells_by_id(current)
	
	tile_set.tile_set_modulate(3, player_colors[current])
	for cell in cells:
		for direction in DIRECTIONS:
			if get_cellv(cell + direction) == -1:
				set_cellv(cell + direction, 3)
				av_pos += 1
				
	if av_pos == 0 and not score["p1"] + score["p2"] >= max_score:
		swap_turn()

func check_isolated_area(prep_mode=false):
	var checked_tiles = []
	
	# Loops through map, and check for secluded spaces
	for x in range(map.size.x):
		for y in range(map.size.y):
			
			var checked = Vector2(x, y) in checked_tiles 
			var is_invalid = not get_cell(x, y) in ignore
			
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
