extends CenterContainer

@onready var trail_color_picker: ColorPicker = $VBoxContainer/HBoxContainer/trail_color_picker
@onready var sword_color_picker: ColorPicker = $VBoxContainer/HBoxContainer/sword_color_picker

func _ready() -> void:
	trail_color_picker.color = Color(Globals.TRAIL_COLOR)
	sword_color_picker.color = Color(Globals.SWORD_COLOR)

func _process(delta: float) -> void:
	if Globals.PAUSED:
		visible = true
		
		return 
	else:
		visible = false


func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
