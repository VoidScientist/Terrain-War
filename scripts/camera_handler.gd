extends Camera2D
class_name FocusingCamera

func focus_on_area(area: Rect2, cell_size: Vector2) -> void:
	# overall size of tilemap
	var pix_size: Vector2 = area.size
	var center: Vector2 = area.get_center()
	
	# determine the level of zoom to encompass the area
	var viewport = get_viewport()
	
	if not viewport: return
	
	var visible_rect: Rect2 = viewport.get_visible_rect()
	var x_zoom: float = (pix_size.x * cell_size.x) / visible_rect.size.x
	var y_zoom: float = (pix_size.y * cell_size.y) / visible_rect.size.y
	
	# keep camera zoom uniform (no distortion)
	var size: float = max(x_zoom, y_zoom)
	
	# define zoom vector
	zoom = Vector2(size, size)
	
	# centers camera
	position.x = center.x * cell_size.x
	position.y = center.y * cell_size.y
