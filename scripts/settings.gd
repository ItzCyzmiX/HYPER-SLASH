extends Control

func _ready() -> void:
	
	$VBoxContainer/vsync.button_pressed =  DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	
	if GraphicsManager.current_preset == "low":
		$VBoxContainer/quality/quality_list.select(0)
	elif GraphicsManager.current_preset == "mid":
		$VBoxContainer/quality/quality_list.select(1)
	elif GraphicsManager.current_preset == "high":
		$VBoxContainer/quality/quality_list.select(2)
	
	if GraphicsManager.get_cur_screen_size() == "borderless":
		$VBoxContainer/screen/screen_list.select(2)
	elif  GraphicsManager.get_cur_screen_size() == "windowed":
		$VBoxContainer/screen/screen_list.select(0)
	elif  GraphicsManager.get_cur_screen_size() == "fullscreen":
		$VBoxContainer/screen/screen_list.select(1)


func _on_quality_list_item_selected(index: int) -> void:
	if index == 0:
		GraphicsManager.set_preset("low")
	elif index == 1:
		GraphicsManager.set_preset("mid")
	elif index == 2:
		GraphicsManager.set_preset("high")

func _on_screen_list_item_selected(index: int) -> void:
	if index == 0:
		await GraphicsManager.set_window_size("windowed")
	elif index == 1:
		await GraphicsManager.set_window_size("fullscreen")
	elif index == 2:
		await GraphicsManager.set_window_size("borderless")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_vsync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
