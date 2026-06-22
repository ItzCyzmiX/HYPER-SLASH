extends Control
@onready var top: ColorRect = get_node("top")
@onready var bottom: ColorRect = get_node("bottom")

var animation = "fade-in"
var play = false

signal anim_finished()

func _ready() -> void:
	
	top.size = DisplayServer.window_get_size() +  Vector2i(10, 10)

	bottom.size = DisplayServer.window_get_size() + Vector2i(10, 10)
	
	set_animation(animation)

func set_animation(str):
	print(get_children())
	animation = str
	if animation == "fade-out":
		top.position.y = -DisplayServer.window_get_size().y / 2 +50
		bottom.position.y =  DisplayServer.window_get_size().y / 2
	else:
		top.position.y = -DisplayServer.window_get_size().y 
		bottom.position.y =  DisplayServer.window_get_size().y 

func _process(delta: float) -> void:
	if play:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.finished.connect(finished)
		if animation == "fade-out":
			tween.tween_property(top, "position:y",  -DisplayServer.window_get_size().y - 50, 1)
			tween.tween_property(bottom, "position:y",  DisplayServer.window_get_size().y + 50, 1)
		else:
			tween.tween_property(top, "position:y",  -DisplayServer.window_get_size().y / 2 + 30, 0.5)
			tween.tween_property(bottom, "position:y",  DisplayServer.window_get_size().y / 2 - 70, 0.5)
		
func finished():
	anim_finished.emit()
	queue_free()
