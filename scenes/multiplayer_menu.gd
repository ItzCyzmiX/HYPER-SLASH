extends CanvasLayer


func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_create_pressed() -> void:
	$container/create_container/sep/ip.text = IP.get_local_addresses()[0]

func _on_join_pressed() -> void:
	print("join server w ip: ", $container/join_container/sep/ip.text)


func _on_ip_text_changed() -> void:
	$container/join_container/join.disabled = $container/join_container/sep/ip.text == ""


func _on_test_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")
