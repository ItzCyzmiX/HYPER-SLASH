extends Node


const IP_ADRESS = "localhost"
const PORT = 42069
var peer: ENetMultiplayerPeer

func start_server():
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 4)
	multiplayer.multiplayer_peer = peer

func start_client():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADRESS, PORT)
	multiplayer.multiplayer_peer = peer
