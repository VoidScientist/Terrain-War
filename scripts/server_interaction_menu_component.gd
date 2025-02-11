extends Node2D
class_name ServerMenuInteractionComponent

export(NodePath) var color_picker_path

onready var color_picker: ColorPickerButton = get_node(color_picker_path)

export(Color) var current_color = Color(0.35,0.5,0.65)


func _ready():
	assert(color_picker)

	color_picker.color = current_color


func _on_username_entry_text_entered(new_text):
	MultiplayerService.change_username(new_text)
	

func _on_color_popup_closed():
	var new_color = color_picker.color

	if new_color == current_color: return
	
	MultiplayerService.change_color(new_color)

func _on_create_lobby_pressed():
	MultiplayerService.create_lobby()

func _on_refresh_pressed():
	MultiplayerService.request_lobbies()
