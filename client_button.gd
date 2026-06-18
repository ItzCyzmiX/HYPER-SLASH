extends Button

func _on_pressed() -> void:
	NetworkHandler.start_client()
