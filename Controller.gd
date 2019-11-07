extends Node

var joystick
var socket
var module 

func _ready():
	joystick = get_node("UI/JoyStick")
	socket = get_node("Socket")
	socket._setup(Settings.get_value("server_ip"), int(Settings.get_value("server_port")))
	get_node("UI/Settings").connect("released", self, "goto_setting")
	for button in get_tree().get_nodes_in_group("buttons"):
		button.connect("pressed",self, "button_pressed")
	if(Engine.has_singleton("Vibrate")):
		module = Engine.get_singleton("Vibrate")

func _process(delta):
	var data = "<"
	for axis in get_tree().get_nodes_in_group("axes"):
		if axis.has_method("get_values"):
			var joyData = axis.get_values()
			data += str(joyData.x) +","
			data +=  str(joyData.y) +","
	for button in get_tree().get_nodes_in_group("buttons"):
		data += str(1 if button.is_pressed() else 0)
		data += ","
	data += ">"
	socket.send(data)

func button_pressed():
	if(module):
		module.vibrate(50)

func goto_setting():
	get_tree().change_scene("Setting.tscn")