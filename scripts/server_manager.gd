extends Node
class_name ServerManager

var peer: NetworkedMultiplayerENet

func create_client():
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client("127.0.0.1", 8000)

	if err != OK: 
		print("Couldn't connect to server. Multiplayer disabled.")
		return false
	
	peer.connect("connection_succeeded", self, "on_connection_succeeded")
	peer.connect("connection_failed", self, "_on_connection_failed")
	
	get_tree().network_peer = peer
	
	return true
	
func _on_connection_failed():
	print("failed to connect to server")
	
func _on_connection_succeeded():
	print("connected to server")
