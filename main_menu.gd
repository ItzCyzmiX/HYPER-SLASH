extends CanvasLayer
@onready var transition: Control = $Transition


func _ready() -> void:
	$Control/logo.play("default")
	transition.set_animation('fade-in')
	transition.connect("anim_finished", switch_scene)
	
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
	transition.play = true
	
func switch_scene():
	get_tree().change_scene_to_file("res://world.tscn")
