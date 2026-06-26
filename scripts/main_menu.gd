extends CanvasLayer

func _ready() -> void:
	$Control/logo.play("default")
	
func _on_quit_mouse_entered() -> void:
	$VBoxContainer/quit.text = "QUIT"

func _on_quit_mouse_exited() -> void:
	$VBoxContainer/quit.text = "quit"

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_mouse_entered() -> void:
	$VBoxContainer/play.text = "PLAY"

func _on_play_mouse_exited() -> void:
	$VBoxContainer/play.text = "play"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/multiplayer_menu.tscn")
	

func _on_settings_mouse_entered() -> void:
	$VBoxContainer/settings.text = "SETTINGS"

func _on_settings_mouse_exited() -> void:
	$VBoxContainer/settings.text = "settings"

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
