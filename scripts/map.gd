extends TileMap
class_name Map

#Mouse position assigned in _physics_process()
var mousePos
#State determining player turns
enum TURNS {PLAYER1, PLAYER2}
export (TURNS) var playerTurn
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
var p1_score = 1
var p2_score = 1
var max_score = 2
# Cells considered as void :
var ignore := [-1, 3]

#Initialising the first player's turn
func _ready():
	# get the rect of the map
	map = get_used_rect()
	# init the algorithm
	flood_fill = FloodFill.new(map, self, 1-playerTurn, playerTurn)
	# list of player_colors used when turn change
	player_colors = [player_1_col, player_2_col]
	
	# Used to fill empty spaces (so that it doesn't hinder max score)
	check_isolated_area(true)
	
	# set player tiles with corresponding colors
	tile_set.tile_set_modulate(0, player_1_col)
	tile_set.tile_set_modulate(1, player_2_col)
	
	fillVoid()
	
	$UI.visible = true
	set_camera_up()
	update_ui()

#Game loop
func _physics_process(delta):
	mousePos = get_global_mouse_position()
	# check if cell can be placed
	var isCellClaimable = isCellEmpty(mousePos) and isPlayerCellAdjacent(mousePos, playerTurn)
	
	# if input pressed then claim
	if Input.is_action_just_pressed("claim") and isCellClaimable:
		# make the cell the color of the player turn
		# TODO: REFACTOR THIS
		match playerTurn:
			TURNS.PLAYER1:
				if claimCell(mousePos, 0):
					p1_score += 1
				flood_fill.change_ids(1,0)
				check_isolated_area()
				playerTurn = TURNS.PLAYER2
			TURNS.PLAYER2:
				if claimCell(mousePos, 1):
					p2_score += 1
				flood_fill.change_ids(0,1)
				check_isolated_area()
				playerTurn = TURNS.PLAYER1
		
		check_win()
		update_ui()
		
func _process(delta):
	# visual indication of where you can go
	show_available_position()
	# visual indication of whose turn it is
	VisualServer.set_default_clear_color(player_colors[playerTurn])

func fillVoid():
	# iterate through the map if cell valid add to max score 1
	for x in range(map.size.x):
		for y in range(map.size.y):
			if get_cell(x, y) == -1:
				max_score += 1

func highlight_clickable_cells():
	tile_set.tile_set_modulate(3, player_colors[playerTurn])

# Update UI according to scores:
func update_ui():
	var new_gradient = Gradient.new()
	new_gradient.colors = PoolColorArray([player_1_col, player_2_col])
	var color_1_range = 0.0 + (p1_score - p2_score) / float(max_score)
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
func claimCell(mousePos, cell):
	var cellClicked = world_to_map(mousePos)
	
	set_cell(cellClicked.x, cellClicked.y, cell)
	return true
	
#Is the target cell empty ?
func isCellEmpty(mousePos):
	return get_cellv(world_to_map(mousePos)) in ignore
		
#check if a cell of the same player is adjacent to the cell the player wants to claim
func isPlayerCellAdjacent(mousePos, turn):
	var cellClicked = world_to_map(mousePos)

	# check whether cell clicked has an adjacent player cell
	for dir in DIRECTIONS:
		var adjCell = cellClicked + dir
		if adjCell != cellClicked and get_cellv(adjCell) == turn:
			return true
	
	return false

func check_win():
	if p1_score + p2_score >= max_score:
		if p1_score > p2_score:
			win_band.set_text("Joueur 1 a gagné !")
			win_band.get_child(2).set("custom_colors/default_color", player_1_col)
		elif p1_score < p2_score:
			win_band.set_text("Joueur 2 a gagné !")
			win_band.get_child(2).set("custom_colors/default_color", player_2_col)
		elif p1_score == p2_score:
			win_band.set_text("Match nul !")
			win_band.get_child(2).set("custom_colors/default_color", Color.whitesmoke)
		win_band.appear()

func show_available_position():
	var av_pos = 0
	# clean up old highlighted cells
	var old_av_pos = get_used_cells_by_id(3)
	for old_pos in old_av_pos:
		set_cellv(old_pos, -1)
		
	var cells = get_used_cells_by_id(playerTurn)
	
	tile_set.tile_set_modulate(3, player_colors[playerTurn])
	for cell in cells:
		for direction in DIRECTIONS:
			if get_cellv(cell + direction) == -1:
				set_cellv(cell + direction, 3)
				av_pos += 1
				
	if av_pos == 0 and not p1_score + p2_score >= max_score:
		swapTurn()

func swapTurn():
	match playerTurn:
			TURNS.PLAYER1:
				playerTurn = TURNS.PLAYER2
			TURNS.PLAYER2:
				playerTurn = TURNS.PLAYER1

func check_isolated_area(prep_mode=false):
	var checked_tiles = []
	# Loops through map, and check for secluded spaces
	for x in range(map.size.x):
		for y in range(map.size.y):
			if not Vector2(x, y) in checked_tiles and get_cell(x, y) in ignore:
				flood_fill.set_start_pos(Vector2(x, y))
				var success = flood_fill.check_map()[0]
				var history = flood_fill.check_map()[1]
				for pos in history:
					checked_tiles.append(pos)
					if success and not prep_mode:
						set_cellv(pos, playerTurn)
						swapTurn()
			
