extends Node2D

var saveButton
var IP
var port

func _ready():
	saveButton = get_node("Save")
	IP = get_node("IPAddress")
	port = get_node("Port")
	saveButton.connect("pressed",self, "connection")
	IP.set_text(Settings.get_value("server_ip"))
	port.set_text(Settings.get_value("server_port"))

func connection():
	Settings.set_value("server_ip", IP.get_text())
	Settings.set_value("server_port", port.get_text())
	OS.hide_virtual_keyboard()
	get_tree().change_scene("res://Controller.tscn")