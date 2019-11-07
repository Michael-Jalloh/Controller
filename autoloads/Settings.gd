extends Node

const database_url = "user://settings.json"

var settings = {
	"server_ip":"",
	"server_port":""
}

func _ready():
	DataParser.write_default(database_url, settings)
	settings = DataParser.load_data(database_url)

func get_value(key):
	if key in settings:
		return settings[key]
	return ""

func set_value(key, value):
	if key == null: return
	if value == null: return
	settings[key] = value
	save_settings()

func save_settings():
	DataParser.write_data(database_url, settings)