extends Node2D

export (String) var player_1_name = "Player 1"
export (String) var player_2_name = "Player 2"

export (Color) var player_1_col = Color( 0.262745, 0.529412, 0.65098, 1 )
export (Color) var player_2_col = Color( 0.607843, 0.235294, 0.235294, 1 )

var players: Array
var current: int

var rand_gen: RandomNumberGenerator

func _ready():
	var player1 = Player.new(player_1_name, 0, player_1_col)
	var player2 = Player.new(player_2_name, 1, player_2_col)
	
	rand_gen = RandomNumberGenerator.new()
	rand_gen.seed = Time.get_unix_time_from_system()

	players = [player1, player2]

func change_name(player_id, new_name):
	players[player_id].name = new_name

func change_color(player_id, new_color):
	players[player_id].color = new_color

func randomize_turn() -> Player:
	current = rand_gen.randi_range(0,1)
	return players[current]
	
func change_turn() -> Player:
	current = (current+1)%2
	return players[current]
	
func get_other() -> Player:
	var other = (current+1)%2
	return players[other]
	
func get_players() -> Array:
	return players

func get_players_percent() -> Array:

	var player1_percent = 0.5
	var total_score = (players[0].score + players[1].score) + 2
	
	if total_score != 0:
		player1_percent = (players[0].score + 1) / float(total_score)
	
	
	return [player1_percent, 1-player1_percent]
	
func reset_scores() -> void:
	for player in players: player.score = Player.BASE_SCORE
	
func game_finished(max_score) -> bool:
	return players[0].score + players[1].score >= max_score

func get_winner() -> Player:
	
	if players[0].score == players[1].score:
		return null
		
	if players[0].score > players[1].score:
		return players[0]
		
	return players[1]
