extends CenterContainer

#@onready var trail_color_picker: ColorPicker = $VBoxContainer/VBoxContainer/HBoxContainer/trail_color_picker
@onready var sword_color_picker: ColorPicker = $VBoxContainer/VBoxContainer/HBoxContainer/sword_color_picker

func _ready() -> void:
	sword_color_picker.color = Color(Globals.SWORD_COLOR)


func _on_quit_pressed() -> void:
	Globals.IN_GAME = false 
	Globals.PAUSED = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
