extends MultiplayerSpawner

@export var nextwork_player: PackedScene  = load("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int):
	if !multiplayer.is_server(): return 
	
	var player: Node = nextwork_player.instantiate() 
	player.name = str(id)
