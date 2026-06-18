extends Node3D

const IP_ADRESS = "localhost"
const PORT = 42069
var peer: ENetMultiplayerPeer

@onready var players_container: Node3D = $"players"
@onready var spawn_points = $"spawn_points"
var cur_id = 0
func spawn_player(id):
	if players_container.get_node_or_null(str(id)) == null:
		var player = load("res://player.tscn").instantiate()
		player.name = str(id)
		player.global_position = spawn_points.get_children()[cur_id].global_position
		players_container.add_child(player)
		cur_id += 1

func remove_player(id):
	var p = players_container.get_node_or_null(str(id)) 
	if p: p.queue_free()

func _ready() -> void:
	if '--server' in OS.get_cmdline_args():
		peer = ENetMultiplayerPeer.new()
		peer.create_server(PORT, 4)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connect)
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	
	else:
		peer = ENetMultiplayerPeer.new()
		peer.create_client(IP_ADRESS, PORT)
		multiplayer.multiplayer_peer = peer
		
func _on_peer_connect(id):
	if multiplayer.is_server():
		spawn_player(id)

func _on_peer_disconnect(id):
	if multiplayer.is_server():
		remove_player(id)
