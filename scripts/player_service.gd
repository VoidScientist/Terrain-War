extends Node2D
class_name PlayerService

export (Color) var player_1_col
export (Color) var player_2_col

var players: Array
var current: int

func _ready():
	var player1 = Player.new("Player1", 0, player_1_col)
	var player2 = Player.new("Player2", 1, player_2_col)

	players = [player1, player2]

func randomize_turn():
	var current = round(rand_range(0,1))
	return players[current]
	
func change_turn():
	current = (current + 1) % 2
	return players[current]
	
func get_players():
	return players

func get_players_gradient(max_score):
	var new_gradient = Gradient.new()
	var color_1_range = (players[0].score - players[1].score) / float(max_score)
	
	new_gradient.colors = PoolColorArray([player_1_col, player_2_col])
	new_gradient.offsets = PoolRealArray([color_1_range, 0.5 + color_1_range])
	new_gradient.set_interpolation_mode(new_gradient.GRADIENT_INTERPOLATE_CONSTANT)
	
	return new_gradient
	
func game_finished(max_score) -> bool:
	return players[0].score + players[1].score >= max_score

func get_winner():
	if players[0].score == players[1].score:
		return null
		
	if players[0].score > players[1].score:
		return players[0]
		
	return players[1]