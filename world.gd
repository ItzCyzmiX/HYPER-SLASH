extends Node3D

@onready var players_container: Node3D = $"players"
@onready var spawn_points = $"spawn_points"
var cur_id = 0

func spawn_player() -> void:
	var player = preload("res://player.tscn").instantiate()
	players_container.add_child(player)
	player.global_position = spawn_points.get_children()[cur_id].global_position
	player.INIT_POS = spawn_points.get_children()[cur_id].global_position

func _ready() -> void:
	spawn_player()
	$"../song".play()
