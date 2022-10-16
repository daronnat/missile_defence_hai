extends Node2D

var new_y_value = 0.5
onready var line # = Line2D.new() 
var n_x_ticks = 10 # in pixel
var y_max = 1
var x_ticks

onready var main_node = get_node("/root/Node2D")

func _ready():
	line = Line2D.new()
	x_ticks = get_ticks_positions($Panel.rect_size.x,n_x_ticks)
	print($Panel.rect_size)
	line.width = 3
	line.default_color = Color(0.0, 1.0, 0.0)
	line.z_index = 3
	line.add_point(global_position)
	line.global_position = $Panel/start.global_position
	print(line.position)
	add_child(line)

func get_ticks_positions(graph_x_size,n_ticks):
	var ticks = [0]
	while len(ticks) < n_ticks:
		ticks.append((graph_x_size/n_ticks)*len(ticks))
	return ticks

var cpt_delta = 0
var x_idx = 0
func _process(delta):
	cpt_delta+=delta
	if cpt_delta > 0.2:
		cpt_delta = 0
		x_idx += 1
		var new_point = Vector2()
		
		if x_idx < n_x_ticks:
			new_point.x = x_idx*($Panel.rect_size.x/n_x_ticks)
		else:
			new_point.x = n_x_ticks*($Panel.rect_size.x/n_x_ticks)
		
		if main_node:
			if main_node.current_scenario._wave_shot_fired != 0 and main_node.current_scenario._wave_missile_destroyed !=0:
				new_y_value = float(main_node.current_scenario._wave_missile_destroyed)/main_node.current_scenario._wave_shot_fired
#				print(">>>>>>>>>",new_y_value)
			else:
				new_y_value = 0
		else:
			new_y_value = rand_range(0,1)
		new_point.y = -(($Panel.rect_size.y*new_y_value)/y_max) # -385 #rand_range(-50,-150)
		$Panel/y_value.text = str(stepify(new_y_value,0.01))
		if line.get_point_count() > n_x_ticks:
			line.remove_point(0)
			for i in range(0,line.get_point_count()):
				var new_pos = line.get_point_position(i)
				new_pos.x -= $Panel.rect_size.x/n_x_ticks
				line.set_point_position(i,new_pos)
		line.add_point(new_point)
