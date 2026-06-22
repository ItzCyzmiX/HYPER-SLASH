extends Node3D

@onready var players_container: Node3D = $"players"
@onready var spawn_point = $spawn_point/Marker3D
@onready var transition_pack: = preload("res://transition.tscn")
var cur_id = 0

func spawn_player() -> void:
	var player = preload("res://player.tscn").instantiate()
	players_container.add_child(player)
	player.global_position = spawn_point.global_position
	player.INIT_POS = spawn_point.global_position
	$"../Container/VBoxContainer/VBoxContainer/check_trail".toggled.connect(player._on_check_trail_toggled)
	$"../Container/VBoxContainer/VBoxContainer/HBoxContainer/trail_color_picker".color_changed.connect(player._on_trail_color_picker_color_changed)
	$"../Container/VBoxContainer/VBoxContainer/HBoxContainer/sword_color_picker".color_changed.connect(player._on_sword_color_picker_color_changed)
	
func _ready() -> void:
	var transition = transition_pack.instantiate()
	add_child(transition)
	transition.set_animation('fade-out')
	spawn_player()
	transition.play = true
	$"../song".play()
