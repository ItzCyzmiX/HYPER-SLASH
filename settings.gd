extends Control

func _ready() -> void:
	
	
	$VBoxContainer/vsync.button_pressed =  DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	
	if GraphicsManager.current_preset == "low":
		$VBoxContainer/quality/quality_list.select(0)
	elif GraphicsManager.current_preset == "mid":
		$VBoxContainer/quality/quality_list.select(1)
	elif GraphicsManager.current_preset == "high":
		$VBoxContainer/quality/quality_list.select(2)
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		$VBoxContainer/screen/screen_list.select(0)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$VBoxContainer/screen/screen_list.select(1)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		$VBoxContainer/screen/screen_list.select(2)
		

func _on_quality_list_item_selected(index: int) -> void:
	if index == 0:
		GraphicsManager.set_preset("low")
	elif index == 1:
		GraphicsManager.set_preset("mid")
	elif index == 2:
		GraphicsManager.set_preset("high")
		
	print(GraphicsManager.current_preset)
	
func _on_screen_list_item_selected(index: int) -> void:
	if index == 0:
		GraphicsManager.set_window_size("windowed")
	elif index == 1:
		GraphicsManager.set_window_size("fullscreen")
	elif index == 2:
		GraphicsManager.set_window_size("borderless")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_vsync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
