extends Node

onready var file = File.new()
onready var dir = Directory.new()

func load_data(url):
	if url == null: return
	if !file.file_exists(url): return
	var err = file.open(url, File.READ)
	print(err)
	var data = {}
	data = parse_json(file.get_as_text())
	file.close()
	return data

func write_data(url, dict):
	if url == null: return
	var err =file.open(url, File.WRITE)
	print(err)
	file.store_line(to_json(dict))
	file.close()
	return

func write_default(url, dict):
	if !file.file_exists(url):
		write_data(url, dict)
		return

func creat_dir(directory):
	if !dir.dir_exists(directory):
		dir.make_dir(directory)