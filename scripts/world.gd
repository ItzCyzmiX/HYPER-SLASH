extends Node3D

@onready var players_container: Node3D = $"players"
@onready var spawn_points = $stage/spawn_points
@onready var world_environment: WorldEnvironment = $WorldEnvironment
var red = 0
var green = 0 
var blue = 0
var cur_id = 0

func spawn_player():
	var player = preload("res://scenes/player.tscn").instantiate()
	
	players_container.add_child(player)
	var spawn_point = spawn_points.get_child(cur_id)
	player.global_position = spawn_point.global_position
	player.INIT_POS = spawn_point.global_position
	cur_id += 1
	
func _ready() -> void:
	
	var p = GraphicsManager.get_preset()
	var env : Environment = world_environment.environment
	
	if env:
		env.ssao_enabled  = p["ssao"]
		env.ssil_enabled  = p["ssil"]
		env.ssr_enabled   = p["ssr"]
		env.glow_enabled  = p["glow"]
		if p.has("sdfgi"):
			env.sdfgi_enabled = p["sdfgi"]

	spawn_player()
	$"../song".play()
	


#func _process(delta: float) -> void:
	#if red < 255 and blue == 0:
		#red = red+10*delta
	#elif blue < 255 and green == 0:
		#red -= 10*delta
		#blue = blue +10*delta  
	#elif green < 255:
		#blue -= 10 * delta 
		#green = green + 10*delta
	#
	#red = clamp(red, 0, 255) 
	#green = clamp(green, 0, 255)
	#blue = clamp(blue, 0, 255)
	#
	#world_environment.environment.background_color = Color(red, green, blue)
