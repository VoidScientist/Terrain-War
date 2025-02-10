extends Node
class_name ServerManager

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
