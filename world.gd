extends Node3D

const IP_ADRESS = "localhost"
const PORT = 42069
var peer: ENetMultiplayerPeer
@onready var main_menu: Control = $"../main_menu"

@onready var players_container: Node3D = $"players"
@onready var spawn_points = $"spawn_points"
var cur_id = 0

func spawn_player() -> void:
	var player = preload("res://player.tscn").instantiate()
	player.global_position = spawn_points.get_children()[cur_id].global_position
	players_container.add_child(player)
	cur_id += 1


func _ready() -> void:
	Globals.IN_GAME = true
	$"../GUI".visible = true
	spawn_player()
	$"../song".play()
	
