extends Node

func _ready():
	get_node("Timer").connect("timeout", self, "_start")

func _start():
	get_tree().change_scene("Controller.tscn")