extends ItemList
class_name LobbiesList

func _ready():
	MultiplayerService.connect("lobbies_received", self, "update_content")
	
func update_content(content):
	clear()
	for item in content:
		add_item(item)
