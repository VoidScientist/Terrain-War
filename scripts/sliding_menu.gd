extends Control
class_name SlidingMenu

export var shown_default: bool = false
export var disappear_dir: Vector2 = Vector2(1,0)

export var show_time: float = 0.5

func _ready():
	
	if shown_default: return
	
	visible = false
	rect_position = Vector2(get_viewport_rect().size.x, 0)

func show():
	visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rect_position", Vector2(0,0), show_time)

func hide():
	var screen_width = get_viewport_rect().size
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "rect_position", screen_width * disappear_dir, show_time)
	
	tween.connect("finished", self, "set_invisible")
	
func set_invisible():
	visible = false
