extends ItemList


func _ready():
	var directory = Directory.new()
	
	directory.open("user://")
	
	directory.list_dir_begin(true)
	
	var file = directory.get_next()
	
	while file != "":
		
		if not file.ends_with(".dat"):
			
			file = directory.get_next()
			
			continue
			
		add_item(file)
		
		file = directory.get_next()
