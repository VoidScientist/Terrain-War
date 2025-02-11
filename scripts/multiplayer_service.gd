extends Node
class_name ServerManager

signal lobbies_received(descs)

var connected: bool = false
var peer: NetworkedMultiplayerENet

func create_client():
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client("127.0.0.1", 8000)

	if err != OK: 
		print("Couldn't connect to server. Multiplayer disabled.")
		return false
		
	get_tree().network_peer = peer
	
	peer.connect("connection_succeeded", self, "_on_connection_succeeded")
	peer.connect("connection_failed", self, "_on_connection_failed")
	peer.connect("server_disconnected", self, "_on_server_disconnected")
	
	return true
	
func _on_connection_failed():
	connected = false
	print("failed to connect to server")
	
func _on_connection_succeeded():
	connected = true
	print("connected to server")
	
func _on_server_disconnected():
	connected = false
	print("lost connection with server")

func change_username(new_username):
	rpc_id(1, "update_username", new_username)

func change_color(new_color):
	rpc_id(1, "update_color", new_color)

func create_lobby():
	rpc_id(1, "create_lobby", "New Lobby", false, "")

func request_lobbies():
	rpc_id(1, "retrieve_lobbies")
	
remote func update_lobbies(descs):
	emit_signal("lobbies_received", descs)
