extends Node3D

@onready var players_container: Node3D = $"players"
@onready var spawn_point = $spawn_point/Marker3D
@onready var transition_pack: = preload("res://scenes/transition.tscn")
var cur_id = 0

func spawn_player() -> void:
	var player = preload("res://scenes/player.tscn").instantiate()
	players_container.add_child(player)
	player.global_position = spawn_point.global_position
	player.INIT_POS = spawn_point.global_position

func _ready() -> void:
	var p = GraphicsManager.get_preset()
	var env : Environment = $WorldEnvironment.environment
	
	if env:
		env.ssao_enabled  = p["ssao"]
		env.ssil_enabled  = p["ssil"]
		env.ssr_enabled   = p["ssr"]
		env.glow_enabled  = p["glow"]
		if p.has("sdfgi"):
			env.sdfgi_enabled = p["sdfgi"]
	
	var transition = transition_pack.instantiate()
	add_child(transition)
	transition.set_animation('fade-out')
	spawn_player()
	transition.play()
	$"../song".play()
