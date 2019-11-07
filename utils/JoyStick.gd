tool
extends TextureRect

signal Joystick_Start
signal Joystick_End
signal Joystick_Updated

export (float) var radius = 30;
export (float) var dead_zone = 0.05
export (bool) var use_screen_rectangle  = false
export (Rect2) var screen_rectangle = Rect2()
export (Color) var editor_color = Color(1, 0, 0,1)

var joystick_vector = Vector2()
var joystick_touch_id = null
var joystick_active = false

var joystick_ring;


func _ready():
	if (Engine.editor_hint == false):
		joystick_ring = get_node("JoyStick_Ring")
		joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size / 2)
		joystick_vector = Vector2(0,0)
		
		if(use_screen_rectangle == true):
			self.visible = false
		else:
			self.visible = true

func _draw():
	if(Engine.editor_hint  == true):
		print("In Editor")
		var draw_screen_rect = screen_rectangle
		draw_screen_rect.position -= rect_global_position
		
		draw_line(draw_screen_rect.position, draw_screen_rect.position + Vector2(0,  draw_screen_rect.size.y), editor_color, 4)
		draw_line(draw_screen_rect.position + Vector2(0,draw_screen_rect.size.y), draw_screen_rect.position + Vector2(draw_screen_rect.size.x, draw_screen_rect.size.y), editor_color, 4)
		draw_line(draw_screen_rect.position, draw_screen_rect.position + Vector2(draw_screen_rect.size.x, 0), editor_color, 4)
		draw_line(draw_screen_rect.position + Vector2(draw_screen_rect.size.x, 0), draw_screen_rect.position + Vector2(draw_screen_rect.size.x, draw_screen_rect.size.y), editor_color, 4)
		
		#draw_circle(get_center_of_joystick(), radius, Color8(256, 256, 256,128))
		
func get_center_of_joystick():
	return (get_rect().position + get_rect().size /2) - rect_global_position

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var event_is_press = true;
		
		if event is InputEventScreenTouch:
			event_is_press = event.pressed;
		elif event is InputEventMouseButton:
			event_is_press = event.pressed;
		
		if (event_is_press == true):
			if (joystick_active == false):
				
				if (use_screen_rectangle == true):
					
					var event_position = Vector2();
					var event_ID = null;
					
					if event is InputEventScreenTouch:
						event_position = event.position;
						event_ID = event.index;
					elif event is InputEventMouseButton:
						event_position = get_global_mouse_position();
						event_ID = null;
					
					if (screen_rectangle.has_point(event_position)):
						
						rect_global_position = event_position - (rect_size/2);
						
						joystick_touch_id = event_ID;
						
						joystick_active = true;
						visible = true;
						
						joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
						
						joystick_vector = Vector2(0,0);
						
						emit_signal("Joystick_Start");
				
				
				else:
					
					var event_position = Vector2();
					var event_ID = null;
					
					if event is InputEventScreenTouch:
						event_position = event.position;
						event_ID = event.index;
					elif event is InputEventMouseButton:
						event_position = get_global_mouse_position();
						event_ID = null;
					
					if ( ((get_center_of_joystick() + rect_global_position) - event_position).length() <= radius):
						
						joystick_touch_id = event_ID;
						
						joystick_active = true;
						
						joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position) / radius;
						
						joystick_ring.rect_global_position = event_position - (joystick_ring.rect_size/2);
						
						emit_signal("Joystick_Start");
				
				
			
		
		else:
			if (joystick_active == true):
				
				var event_ID = null;
				
				if event is InputEventScreenTouch:
					event_ID = event.index;
				elif event is InputEventMouseButton:
					event_ID = null;
				
				if (joystick_touch_id == event_ID):
					
					joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
					joystick_vector = Vector2(0, 0);
					
					joystick_touch_id = null;
					joystick_active = false;
					
					if (use_screen_rectangle == true):
						visible = false;
					
					emit_signal("Joystick_End");
					
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		
		if (joystick_active == true):
			
			var event_ID = null;
			var event_position = Vector2();
			
			if event is InputEventScreenDrag:
				event_ID = event.index;
				event_position = event.position;
			elif event is InputEventMouseMotion:
				event_ID = null;
				event_position = get_global_mouse_position();
			
			if (event_ID == joystick_touch_id):
				
				if ( ((get_center_of_joystick() + rect_global_position) - event_position).length() <= radius):
					joystick_ring.rect_global_position = event_position - (joystick_ring.rect_size/2);
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position) / radius;
					emit_signal("Joystick_Updated");
				else:
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position).normalized()
					joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2);
					joystick_ring.rect_global_position -= joystick_vector * radius;
					emit_signal("Joystick_Updated");

func set_dead_zone(dz):
	dead_zone = dz

func get_values():
	var data = Vector2(0,0)
	if abs(joystick_vector.x) > dead_zone:
		data.x = joystick_vector.x
	if abs(joystick_vector.y) > dead_zone:
		data.y = joystick_vector.y
	return data