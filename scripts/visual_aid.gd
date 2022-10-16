extends Node2D

onready var main_node = get_node("/root/Node2D")
onready var plan_scene = preload("res://scenes/path_display.tscn")
var plan_display_instance = null
onready var graph_scene = preload("res://scenes/new_graph.tscn")
var graph_instance = null
onready var path_target_scene = preload("res://scenes/path_to_target.tscn")
var path_target_instance = null

var visual_aid_type
var visual_aid_activated = false

var boxes_activated = false
var threat_activated = false

var threat_shapes_activated = false
var text_activated = false


var prio_square_activated = false
var path_activated = false

var plan_display_activated = false
var graph_display_activated = false

var VISUAL_AID_LIMIT = 5
#var TEXT_LIMIT = 5
#var PATH_LIMIT = 3

func _ready():
	print("visual aid management scene added")
#	print("ready:",threat_shapes_activated)
	deactivate_all_visual_aid()
#	print("ready")
#	$control_panel.hide() 

func manage_visual_aid_timing(current_t,timing):
#	print(visual_aid_activated)
#	print(current_t,timing)
	if int(current_t) > timing[0] and int(current_t) < timing[1] and visual_aid_activated == false:
#		print(current_t,timing)
#		print("oui")
		activate_visual_aid(visual_aid_type)
		visual_aid_activated = true
		main_node.current_scenario.set_visual_aid_status(visual_aid_activated)
#		print("display visual aid")
	elif int(current_t) > timing[1] and visual_aid_activated == true:
#		print("non")
#		print("deactivate visual aid")
		deactivate_all_visual_aid()
		visual_aid_activated = false
		main_node.current_scenario.set_visual_aid_status(visual_aid_activated)

func set_visual_aid_type(type):
	visual_aid_type = type
	prints("visual aid set to",type)

func activate_visual_aid(visual_aid_type):
#	visual_aid_type = type
#	print(visual_aid_type)
#	print("type:",visual_aid_type)
#	print(visual_aid_type)
	match visual_aid_type:
		
#		"boxes":
#			deactivate_all_visual_aid()
##			_on_boxes_toggled(true)
#			$control_panel/boxes.pressed = true
#		"threat":
#			deactivate_all_visual_aid()
#			$control_panel/threat.pressed = true
		"threat_shapes":
			deactivate_all_visual_aid()
			threat_shapes_activated = true
			
#			$control_panel/threat_shape.pressed = true
		"ordering_info":
			deactivate_all_visual_aid()
			text_activated = true
#			$control_panel/text_infos.pressed = true
		"threat_prio":
			deactivate_all_visual_aid()
			prio_square_activated = true
#			$control_panel/prio_square.pressed = true
		"missile_paths":
			deactivate_all_visual_aid()
			path_activated = true
#			$control_panel/path.pressed = true
		"plan_display":
			deactivate_all_visual_aid()
			plan_display_activated = true
#			$control_panel/paths.pressed = true
		"graph_display":
			deactivate_all_visual_aid()
			graph_display_activated = true
#			$control_panel/graph.pressed = true

func deactivate_all_visual_aid():
	print("deactivating all visual aids...")
	for b in self.get_tree().get_nodes_in_group("visual_aid_checkbox"):
		b.pressed = false
	if plan_display_instance:
			plan_display_instance.queue_free()
			plan_display_instance = null
	if graph_instance:
			graph_instance.queue_free()
			graph_instance = null
	if path_target_instance:
		path_target_instance.queue_free()
		path_target_instance = null


#func _on_threat_shape_toggled(button_pressed):
#	threat_shapes_activated = button_pressed
#
#func _on_text_infos_toggled(button_pressed):
#	text_activated = button_pressed
#
#func _on_prio_square_toggled(button_pressed):
#	prio_square_activated = button_pressed
#
#func _on_path_toggled(button_pressed):
#	path_activated = button_pressed
#
#func _on_paths_toggled(button_pressed):
#	plan_display_activated = button_pressed
#
#func _on_graph_toggled(button_pressed):
#	graph_display_activated = button_pressed

var cpt_delta = 0
func _process(delta):
	if cpt_delta > 0.5:
		manage_visual_type()
		cpt_delta = 0
	cpt_delta+=delta

func manage_visual_type():
#	if boxes_activated == true:
#		for m in main_node.active_missiles:
#			m.show_bounding_box()
#	else:
#		for m in main_node.active_missiles:
#			m.hide_bounding_box()
			
#	if threat_activated == true:
#		for m in main_node.active_missiles:
#			m.enemy_box()
##			m.detect_threat_box()
#	else:
#		for m in main_node.active_missiles:
#			m.neutral_box()
##			m.hide_threat_box()
#	print(main_node.current_scenario)
	if text_activated == true:
		for m in main_node.active_missiles:
			m.show_priority(VISUAL_AID_LIMIT)
			m.correct_visual_rotation()
	else:
		for m in main_node.active_missiles:
			m.hide_priority()

	if path_activated == true:
		for m in main_node.active_missiles:
			m.show_path(VISUAL_AID_LIMIT)
			m.correct_visual_rotation()
#		if path_target_instance == null:
#			path_target_instance = path_target_scene.instance()
#			main_node.add_child(path_target_instance)
	else:
		for m in main_node.active_missiles:
			m.hide_path()
#		if path_target_instance:
#			deactivate_all_visual_aid()
	if prio_square_activated == true:
		for m in main_node.active_missiles:
			m.manage_prio_square()
			m.correct_visual_rotation()
	else:
		for m in main_node.active_missiles:
			pass
			m.disable_prio_square()
	
#	print(threat_shapes_activated)
#	print(threat_shapes_activated)
	if threat_shapes_activated == true:
		for m in main_node.active_missiles:
#			m.show_red_triangle()
			m.detect_threat_box(VISUAL_AID_LIMIT)
			m.correct_visual_rotation()
			
#			m.show_green_polygon()
	else:
		for m in main_node.active_missiles:
			pass
#			print("deactivating")
			m.disable_threat_shapes()

	if plan_display_activated == true:
		if plan_display_instance == null:
			plan_display_instance = plan_scene.instance()
			main_node.add_child(plan_display_instance)
	else:
		if plan_display_instance:
			deactivate_all_visual_aid()
#		if plan_display_instance:
#			plan_display_instance.queue_free()

	if graph_display_activated == true:
		if graph_instance == null:
			graph_instance = graph_scene.instance()
			main_node.add_child(graph_instance)
	else:
		if graph_instance:
			deactivate_all_visual_aid()


func _on_show_panel_toggled(button_pressed):
	if button_pressed == true:
		$control_panel.show()
	else:
		$control_panel.hide()
