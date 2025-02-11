extends Control
class_name SlidingMenu

export var shown_default: bool = false
export var disappear_dir: Vector2 = Vector2(1,0)

const SHOW_TIME: float = 0.5

func _ready():

	visible = shown_default
	
	if not shown_default:
		rect_position = get_viewport_rect().size.x * disappear_dir 
	else:
		rect_position = Vector2.ZERO
	

func show():
	visible = true
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(0,0), SHOW_TIME)

func hide():
	var screen_size = get_viewport_rect().size
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rect_position", screen_size * disappear_dir, SHOW_TIME)
	
	tween.connect("finished", self, "set_invisible")
	
func set_invisible():
	visible = false
