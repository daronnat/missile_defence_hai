extends Node2D

var UPDATE_TIMER = 0.25
var PERF_HISTORY_MAX = 50
var PERF_HISTORY_MIN = 3
var perf_history = []
var shot_count = 0
#var missile_hit_count = 0
var successful_shots = []
onready var main_node = get_node("/root/Node2D")
onready var tower_node = get_node("/root/Node2D/tower_gun")
onready var x_cross_scene = preload("res://scenes/x_cross.tscn")
onready var v_mark_scene = preload("res://scenes/v_mark.tscn")

func _ready():
	hide_all_symbols()
#	$update.set_wait_time(UPDATE_TIMER)
#	$update.start()
	$Panel/wait_panel.show()

func hide_all_symbols():
	$Panel/arrow_down.hide()
	$Panel/arrow_up.hide()
	$Panel/no_change.hide()

func on_explosion_ended():
	print("RECEIVED")
	update_panel()

func update_panel():
	shot_count = main_node.current_scenario._wave_shot_fired
	update_accuracy(get_wave_recall())
	update_symbols()
	update_last_shots_visualisation()

func _on_update_timeout():
	if shot_count != main_node.current_scenario._wave_shot_fired:
		shot_count = main_node.current_scenario._wave_shot_fired
#		missile_hit_count = main_node.current_scenario._wave_missile_destroyed
#		update_accuracy(get_wave_precision())
		update_accuracy(get_wave_recall())
	update_symbols()
	update_last_shots_visualisation()

func update_accuracy(new):
	new = stepify(new,1)
	$Panel/accuracy.text = str(new)+"%"
	update_perf_history(new)
	
func update_perf_history(new):
	perf_history.append(new)
	if len(perf_history) > PERF_HISTORY_MAX:
		perf_history.remove(0)
	
func update_symbols():
	if len(perf_history) > PERF_HISTORY_MIN:
		$Panel/wait_panel.hide()
		if perf_history[-1] < perf_history[-2]:
			hide_all_symbols()
			$Panel/arrow_down.show()
		elif perf_history[-1] > perf_history[-2]:
			hide_all_symbols()
			$Panel/arrow_up.show()
		else:
			hide_all_symbols()
			$Panel/no_change.show()
	else:
		$Panel/wait_panel.show()

func get_last_n_array(array,n):
	if array.empty():
		return null
	var new_array = []
	var limit = clamp(len(array),1,n)
	for n in range(-limit,0,1):
		new_array.append(array[n])
	return new_array

func update_last_shots_visualisation():
	var past_shots_nodes = ["Panel/last_shots/shot1/","Panel/last_shots/shot2/",
	"Panel/last_shots/shot3/"]
	if len(main_node.missile_success) > 0:
		var last_n_arrays = get_last_n_array(main_node.missile_success,len(past_shots_nodes))
		var i = 0
		for v in last_n_arrays:
			manage_individual_shots_vis(past_shots_nodes[i],
			last_n_arrays[i])
			i += 1
#		var limit = clamp(len(main_node.missile_success),1,3)
#		var i = 0
#		for s in range(0,limit):
#			manage_individual_shots_vis(past_shots_nodes[i],
#			main_node.missile_success[-i])
#			i+=1

func manage_individual_shots_vis(node_path,a_bool):
	if a_bool == true:
		get_node(node_path+"v_mark").show()
		get_node(node_path+"x_cross").hide()
#		past_shots_nodes
	else:
		get_node(node_path+"v_mark").hide()
		get_node(node_path+"x_cross").show()
#	if.current_scenario._wave_missile_destroyed < 
#	successful_shots
#
#	if main_node.current_scenario._wave_shot_fired > 0:
#		for p in perf_history:
#			pass
#

func get_wave_recall():
	if main_node:
#		var tp = main_node.current_scenario._wave_missile_destroyed
		var tp = main_node.current_scenario._wave_threat_missile_destroyed
		var tp_fn = main_node.current_scenario._wave_missile_spawned
		if tp != 0 and tp_fn !=0:
			return (float(tp)/float(tp_fn))*100
		return 0
	return 100

func get_wave_precision():
	if main_node:
		var tp = main_node.current_scenario._wave_missile_destroyed
		var tp_fp = main_node.current_scenario._wave_shot_fired
		if tp != 0 and tp_fp != 0: 
			return (float(tp)/float(tp_fp))*100
		return 0
	return 100


