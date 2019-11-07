extends Node

var connection = PacketPeerUDP.new()
var setup = false

func _setup(ip, port):
	print("Start client UDP")
	# Connect
	connection.set_dest_address(ip, port)
	connection.put_var(null)
	setup = true

func _exit_tree():
	connection.close()
	print("Closing Socket")

func send(message):
	if(!setup):
		print("Need to call _setup with ip and port")
		return
	if connection.is_listening():
		connection.put_var(message)