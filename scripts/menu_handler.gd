extends Control

export(NodePath) var multiplayer_path
export(NodePath) var map_selector_path
export(NodePath) var p1_name_path
export(NodePath) var p2_name_path
export(NodePath) var p1_color_path
export(NodePath) var p2_color_path

onready var map_selection: ItemList = get_node(map_selector_path)
onready var multiplayer_button: Button = get_node(multiplayer_path)
onready var p1_name: LineEdit = get_node(p1_name_path)
onready var p2_name: LineEdit = get_node(p2_name_path)
onready var p1_color: ColorPickerButton = get_node(p1_color_path)
onready var p2_color: ColorPickerButton = get_node(p2_color_path)


func _ready():
	assert(multiplayer_button and map_selection and p1_name and p2_name)
	assert(p1_color and p2_color)

	MultiplayerService.create_client()


func _process(delta):
	multiplayer_button.visible = MultiplayerService.connected


func _on_play_button_pressed():
	p1_name.placeholder_text = PlayerService.players[0].name
	p2_name.placeholder_text = PlayerService.players[1].name

	$PLAYMENU.show()
	$MAINPART.hide()


func _on_back_button_pressed():
	$PLAYMENU.hide()
	$MAINPART.show()


func _on_multiplayer_button_pressed():
	
	$MAINPART.hide()
	$MULTIPLAYERMENU.show()


func _on_create_button_pressed():
	var scene = load("res://scenes/map_creator.tscn").instance()

	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)


func _on_leave_game_pressed():
	get_tree().quit()


func _on_start_game_pressed():
	var name1 = p1_name.text
	var name2 = p2_name.text
	var col1 = p1_color.color
	var col2 = p2_color.color

	if name1:
		PlayerService.change_name(0, name1)
	if name2:
		PlayerService.change_name(1, name2)

	PlayerService.change_color(0, col1)
	PlayerService.change_color(1, col2)

	var scene = load("res://scenes/Game.tscn").instance()

	if not map_selection.is_anything_selected():
		return

	var item = map_selection.get_selected_items()[0]
	var file_name = map_selection.get_item_text(item)

	if not file_name:
		return

	scene.load_map("user://" + file_name)

	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)


func _on_multiplayer_back_button_pressed():
	$MULTIPLAYERMENU.hide()
	$MAINPART.show()
