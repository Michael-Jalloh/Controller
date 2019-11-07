extends Node

signal loading
signal loaded

var t = Thread.new()

func _ready():
	print("Hello")
	var arg_bytes_loaded = {"name":"bytes_loaded","type":TYPE_INT}
	var arg_bytes_total = {"name":"bytes_total","type":TYPE_INT}
	add_user_signal("loading",[arg_bytes_loaded,arg_bytes_total])
	var arg_result = {"name":"result","type":TYPE_RAW_ARRAY}
	add_user_signal("loaded",[arg_result])
	pass

func Get(domain, url, port, ssl):
	print(domain+ " " + url)
	if(t.is_active()):
		return
	t.start(self, "_load", {"domain":domain,"url":url,"port":int(port),"ssl":ssl,"body":"", "method":HTTPClient.METHOD_GET})
	print("Thread Started")

func Post(domain, url, port, ssl, body):
	print(domain+ " " + url)
	if(t.is_active()):
		print("Thread is Active")
		return
	t.start(self, "_load",  {"domain":domain,"url":url,"port":int(port),"ssl":ssl,"body":body, "method":HTTPClient.METHOD_POST})

func _load(params):
	var err = 0
	var http = HTTPClient.new()
	
	print(params)
	err = http.connect_to_host(params.domain, params.port, params.ssl)
	print(err)
	while(http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("Connecting...")
		OS.delay_msec(100)
	
	var headers =[
	"User-Agent: Pirulo/1.0 (Godot)",
	"Accept: */*"
	]
	
	err = http.request(params.method, params.url,headers, params.body)
	
	while(http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		OS.delay_msec(500)
		
		var rb = PoolByteArray()
		if(http.has_response()):
			headers = http.get_response_headers_as_dictionary()
			while(http.get_status() == HTTPClient.STATUS_BODY):
				http.poll()
				var chuck = http.read_response_body_chunk()
				if(chuck.size() == 0):
					OS.delay_usec(100)
				else:
					rb = rb+chuck
					call_deferred("_send_loading_signal", rb.size(), http.get_response_body_length())
				
				call_deferred("_send_loaded_signal")
				http.close()
				return rb

func _send_loading_signal(l,t):
	emit_signal("loading",l,t)

func _send_loaded_signal():
	var r = t.wait_to_finish()
	emit_signal("loaded",r)
	pass
