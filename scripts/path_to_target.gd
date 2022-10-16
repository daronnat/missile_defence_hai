extends Node2D

onready var agent_node = get_node("/root/Node2D/agent_avatar")
onready var main_node = get_node("/root/Node2D")
var POSITION_LIMIT = 99
var LINE_WIDTH = 8
var LINE_COLOUR = Color(1,1,0,0.75)
var optimal_ordering = []

func _process(delta):
	update()
#	print("aaaa")

func _draw():
	draw_lines_to_targets()

func draw_lines_to_targets():
	if not main_node.active_missiles.empty():
		var i = 0
		for m in main_node.active_missiles:
			if i < POSITION_LIMIT:
				draw_line(m.position,m.target_pos,LINE_COLOUR,LINE_WIDTH)
				i+=1
