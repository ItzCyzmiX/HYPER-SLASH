extends CanvasLayer

var peer = ENetMultiplayerPeer.new()
const PORT = 6969

func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_create_pressed() -> void:
	pass

func _on_join_pressed() -> void:
	pass

func _on_ip_text_changed() -> void:
	pass


func _on_test_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")
