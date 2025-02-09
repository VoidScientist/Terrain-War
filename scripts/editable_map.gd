extends LoadableMap
class_name EditableMap

onready var camera: FocusingCamera = $FocusingCamera
onready var tutorial_ui: Control = $UI/tutorial_layer
onready var tile_ui: TextureRect = $UI/tile_display/current_tile
onready var tile_display: AnimationPlayer = $UI/tile_display/AnimationPlayer
onready var width_container: LineEdit = $UI/map_size_edit/size_change_container/width_select/custom_with
onready var height_container: LineEdit = $UI/map_size_edit/size_change_container/height_select/custom_height
onready var save_dialog: FileDialog = $UI/save_dialog
onready var load_dialog: FileDialog = $UI/load_dialog

const WALL_TILE := 2
const LINE_COLOR := Color(0.2,0.2,0.3,0.5)
const PLACEABLE_CELL_RANGE := 3

var ui_active: bool = true

var current_cell: int = 0

var grid_activated: bool = true

func _ready():
	generate_borders()
	
	get_tree().root.connect("size_changed", self, "focus_camera")
	
	focus_camera()
	
	tutorial_ui.visible = true 
	
func focus_camera():
	camera.focus_on_area(get_used_rect(), cell_size)

func _physics_process(delta):
	if ui_active: return
	
	var clicked = world_to_map(get_global_mouse_position())
	
	var not_border_x = clicked.x != width + 1 and clicked.x != 0
	var not_border_y = clicked.y != height + 1 and clicked.y != 0
	var in_play_zone = play_area.has_point(clicked)
	var cell_valid = not_border_x and not_border_y and in_play_zone
	
	if Input.is_action_pressed("claim") and cell_valid:
		set_cellv(clicked, current_cell)
		
	if Input.is_action_pressed("delete") and cell_valid:
		set_cellv(clicked, -1)
		
	if Input.is_action_just_pressed("change_cell"):
		current_cell = (current_cell + 1) % PLACEABLE_CELL_RANGE
		update_tile_ui()
		
	if Input.is_action_just_pressed("toggle_grid"):
		grid_activated = !grid_activated
		update()
		
	if Input.is_action_just_pressed("save"):
		
		save_dialog.popup()
		
		ui_active = true
		
	if Input.is_action_just_pressed("load"):
		
		load_dialog.popup()
		
		ui_active = true
		
	if Input.is_action_just_pressed("back_to_menu"):
		var scene = load("res://scenes/main_menu.tscn").instance()
			
		get_tree().root.add_child(scene)
		get_tree().root.remove_child(self)
		
	if Input.is_action_just_pressed("change_size"):
		$UI/map_size_edit.visible = true
		
		ui_active = true
		
func save(f):
	
	var save_data = {}
	
	for i in range(PLACEABLE_CELL_RANGE):
			save_data[i] = get_used_cells_by_id(i)

	save_data["size"] = Vector2(width, height)
	
	FileService.save_data(f, "MAP", save_data)


func generate_borders():
	
	for i in range(height + 2):
		var pos1 = Vector2(0, i)
		var pos2 = Vector2(width + 1, i)
		
		set_cellv(pos1, WALL_TILE)
		set_cellv(pos2, WALL_TILE)
		
	for i in range(width + 2):
		var pos1 = Vector2(i, 0)
		var pos2 = Vector2(i, height + 1)
		
		set_cellv(pos1, WALL_TILE)
		set_cellv(pos2, WALL_TILE)


# --------------------[UI RELATED FUNCTIONS]-------------------------


func _draw():
	if not grid_activated:
		return
	
	for i in range(height + 2):
		var start = Vector2(0, i) * cell_size
		var end = Vector2(width + 1, i) * cell_size
		draw_line(start, end, LINE_COLOR)
		
	for i in range(width + 2):
		var start = Vector2(i, 0) * cell_size
		var end = Vector2(i, height + 1) * cell_size
		draw_line(start, end, LINE_COLOR)


func update_tile_ui():
	tile_ui.texture = tile_set.tile_get_texture(current_cell)
	tile_ui.modulate = tile_set.tile_get_modulate(current_cell)
	
	if tile_display.is_playing():
		tile_display.stop()
	
	tile_display.play("display")


func _on_understood_button_pressed():
	ui_active = false
	tutorial_ui.visible = false
	
	update_tile_ui()


func load_data(f):
	
	load_map(f)
	
	camera.focus_on_area(play_area, cell_size)


func disable_ui():
	# temporary solution to prevent placing cell after saving/loading
	yield(get_tree().create_timer(.2), "timeout")
	
	ui_active = false


func _on_change_size_button_pressed():
	var new_width = width_container.text
	var new_height = height_container.text
	
	if not (new_width.is_valid_integer() and new_height.is_valid_integer()):
		return
		
	width = int(new_width)
	height = int(new_height)
	
	$UI/map_size_edit.visible = false
	
	for pos in get_used_cells():
		set_cellv(pos, -1)
		
	update_play_area()
	
	camera.focus_on_area(play_area, cell_size)
		
	generate_borders()
	
	ui_active = false


func _on_back_pressed():
	$UI/map_size_edit.visible = false
	
	ui_active = false
