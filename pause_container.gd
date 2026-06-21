extends CenterContainer

@onready var trail_color_picker: ColorPicker = $VBoxContainer/HBoxContainer/trail_color_picker
@onready var sword_color_picker: ColorPicker = $VBoxContainer/HBoxContainer/sword_color_picker

func _ready() -> void:
	trail_color_picker.color = Color(Globals.TRAIL_COLOR)
	sword_color_picker.color = Color(Globals.SWORD_COLOR)
