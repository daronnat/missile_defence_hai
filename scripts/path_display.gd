extends Node2D

onready var agent_node = get_node("/root/Node2D/agent_avatar")
var POSITION_LIMIT = 5

var optimal_ordering = []
var eta_ordering = []
var recency_ordering = []

var DEFAULT_DASH_WIDTH = 3
var DEFAULT_DASH_LENGTH = 20
var DEFAULT_SPACING = 10

var delta_delay = 100

func _process(delta):
#	print("hey")
	if delta_delay > 0.10:
		update_positions()
#		_draw()
		update()
		delta_delay = 0
	delta_delay += delta

func insert_crosshair_node_beginning(an_array):
	if agent_node.crosshair_node:
		an_array.insert(0,agent_node.crosshair_node)
	return an_array
#		optimal_ordering.insert(0,agent_node.crosshair_node)

func update_positions():
	
	optimal_ordering = fill_array(agent_node.optimal_missile_ordering)
	eta_ordering = fill_array(agent_node.eta_missile_ordering)
	recency_ordering = fill_array(agent_node.recency_missile_ordering)

func _draw():

	display_paths(optimal_ordering,Color(1,0.65,0,1),6,DEFAULT_DASH_LENGTH,DEFAULT_SPACING)
#	display_paths(eta_ordering,Color(1,1,1,0.3),DEFAULT_DASH_WIDTH,DEFAULT_DASH_LENGTH,DEFAULT_SPACING)
#	display_paths(recency_ordering,Color(0,1,1,0.3),DEFAULT_DASH_WIDTH,DEFAULT_DASH_LENGTH,DEFAULT_SPACING)

func display_paths(ordering,color,dash_width,dash_length,fixed_spacing):
	if agent_node.agent_crosshair.visible == false:
		color.a = 0.40
	
	if len(ordering) < 2:
		return null
	var i = 0
	while i < len(ordering)-1:
		var begin_vector = ordering[i].position
		var end_vector = ordering[i+1].position
		var angle_end = begin_vector.angle_to(end_vector)
		var length_budget = begin_vector.distance_to(end_vector)
		var start_step_vector = begin_vector
		while length_budget > 0:
			var step_length = dash_length 
			if step_length > length_budget:
				step_length = length_budget
			var end_step_vector = start_step_vector.move_toward(end_vector,step_length)
			draw_line(rotate_vector(start_step_vector,end_step_vector,20),end_step_vector,color,dash_width)
			draw_line(rotate_vector(start_step_vector,end_step_vector,340),end_step_vector,color,dash_width)
			start_step_vector = end_step_vector.move_toward(end_vector,fixed_spacing)
			length_budget -= step_length + fixed_spacing
		i += 1

func rotate_vector(point,center,angle):
	angle = deg2rad(angle)
	var rotatedX = cos(angle) * (point.x - center.x) - sin(angle) * (point.y-center.y) + center.x
	var rotatedY = sin(angle) * (point.x - center.x) + cos(angle) * (point.y - center.y) + center.y
	return Vector2(rotatedX,rotatedY)

func fill_array(an_array):
	if an_array.empty() == false:
		var limit = POSITION_LIMIT
		if len(an_array) < POSITION_LIMIT:
			limit = len(an_array)
		var i = 0
		var new_array = []
		while len(new_array) < limit:
			new_array.append(an_array[i])
			i += 1
		new_array = insert_crosshair_node_beginning(new_array)
#		print(new_array)
		return new_array
	return []
