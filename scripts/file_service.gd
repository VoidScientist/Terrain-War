extends Node
class_name FileService

static func save_data(f, nature, variant):
	
	var file = File.new()
	
	file.open(f, File.WRITE)
	
	file.store_var( {"nature": nature, "data": variant} )
	
	file.close()
	
static func load_data(f) -> Dictionary:
	
	var file = File.new()
	
	file.open(f, File.READ)
	
	var data = file.get_var(true)
	
	file.close()
	
	return data	
