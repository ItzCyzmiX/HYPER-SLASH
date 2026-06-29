extends Node3D

@onready var players_container: Node3D = $"players"
@onready var spawn_points = $stage/spawn_points

var cur_id = 0

func spawn_player(id):
	var player = preload("res://scenes/player.tscn").instantiate()
	player.name = str(id)
	players_container.add_child(player)
	var spawn_point = spawn_points.get_child(cur_id)
	player.global_position = spawn_point.global_position
	player.INIT_POS = spawn_point.global_position
	cur_id += 1
	
func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	
	var p = GraphicsManager.get_preset()
	var env : Environment = $WorldEnvironment.environment
	
	if env:
		env.ssao_enabled  = p["ssao"]
		env.ssil_enabled  = p["ssil"]
		env.ssr_enabled   = p["ssr"]
		env.glow_enabled  = p["glow"]
		if p.has("sdfgi"):
			env.sdfgi_enabled = p["sdfgi"]

	$"../song".play()
	print(players_container.get_child_count())
