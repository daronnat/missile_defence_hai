extends Sprite

onready var screensize = get_viewport_rect().size
onready var root_node_path = str(get_parent().get_path())
onready var tower_node = get_node(root_node_path+"/tower_gun")
onready var crosshair_node = get_node(root_node_path+"/crosshair")
onready var h_limit = get_node(root_node_path+"/h_level")
onready var control_focus_status = get_node(root_node_path+"/focus_status")
onready var agent_crosshair = get_node(root_node_path+"/crosshair/crosshair_agent")
onready var agent_crosshair_ctrl = get_node(root_node_path+"/crosshair/crosshair_agent/control_agent")
onready var neutral_crosshair = get_node(root_node_path+"/crosshair/crosshair_neutral")
onready var user_crosshair_ctrl = get_node(root_node_path+"/crosshair/crosshair_user/control_user")
onready var bullet_node = preload("res://scenes/bullet.tscn").instance()
onready var misc_methods = preload("res://scripts/misc.gd").new()
onready var main_script = get_node(root_node_path)

var current_agent
var targeting_enabled
var active_missiles = []
var agent_activated = false
var target_non_threat
var new_pos = true

var dark_grey = Color("#303030")
var white = Color(1,1,1)

func _ready():
	textbox_timer.connect("timeout",self,"_on_textbox_timer_timeout")

func _on_agent_info_get(received_info):
	current_agent = received_info
	if current_agent:
		agent_activated = true
		$name.text = str(current_agent._agent_displayed_name)
		# INSTEAD CREATE NEW FIELD IN JASON FIELD TO KNOW IF CURRENT AGENT IS TO BE RANDOMIZED OR NOT
		# and set the delta to randomize by in the same way
		target_non_threat = current_agent._targeting_threat
		targeting_enabled = current_agent._targeting
	else:
		agent_activated = false
		hide()
	check_for_autoplay()

func _on_missile_spawned(missile_and_speed):
	if agent_activated == false:
		return 0 
	### FP and FN are balanced using missile threat probabilities !
	# missile awareness error margin is therefore not used anymore
	# TO REDO IF USED: var proba_fn = main_script.current_scenario._non_threat_missiles["frequency"]
	# TO REDO IF USED: var proba_fp = 1 - main_script.current_scenario._non_threat_missiles["frequency"]
	
#	TO REDO IF USED: var fp_modifier = current_agent._false_positive_rate * 2
#	TO REDO IF USED: var fn_modifier = (1 - current_agent._false_positive_rate) * 2
	
	var random_float = main_script.RNG.randf()

	if current_agent._imperfect_missile_awareness == true:
		if missile_and_speed[0].threat == true:
#			# TO REDO IF USED: var fn = determine_fn_by_proba(random_float,proba_fn,fn_modifier)
			var fn = determine_fn_by_pool(main_script.amount_pooled_missiles,main_script.current_scenario._non_threat_missiles["frequency"],current_agent._error_rate,current_agent._false_positive_rate)
			if fn == true:
				missile_and_speed[0].not_seen_by_agent = true
				missile_and_speed[0].target_status = "FN"
				main_script.current_scenario.set_type_missile_spawned(missile_and_speed[0].target_status)
				return null
			else:
				missile_and_speed[0].target_status = "TP"
				main_script.current_scenario.set_type_missile_spawned(missile_and_speed[0].target_status)
		else:
#			# TO REDO IF USED: var fp = determine_fp_by_proba(random_float,proba_fp,fp_modifier)
			var fp = determine_fp_by_pool(main_script.amount_pooled_missiles,main_script.current_scenario._non_threat_missiles["frequency"],current_agent._error_rate,current_agent._false_positive_rate)
			if fp == true:
				active_missiles.append(missile_and_speed[0])
				missile_and_speed[0].target_status = "FP"
				main_script.current_scenario.set_type_missile_spawned(missile_and_speed[0].target_status)
				return null
			else:
				missile_and_speed[0].target_status = "TN"
				main_script.current_scenario.set_type_missile_spawned(missile_and_speed[0].target_status)

	if target_non_threat == false and missile_and_speed[0].threat == true:
		active_missiles.append(missile_and_speed[0])
	elif target_non_threat == true:
		active_missiles.append(missile_and_speed[0])

var fn_pool = []
var fp_pool = []

func set_pool(target,amount_true):
	prints("Setting pool with:",target,amount_true)
	var pool = []
	var amount_false = int(target - amount_true)
	for i in range(0,amount_true):
		pool.append(true)
	for i in range(0,amount_false):
		pool.append(false)
	pool.shuffle()
	return pool

func determine_fn_by_pool(total_pool_size,non_threat_p,agent_error_rate,fp_rate):
	var fn_rate = 1 - fp_rate
	var pool_size = int(total_pool_size*(1-non_threat_p))
	var amount_fn = int((total_pool_size*agent_error_rate)*(1-fp_rate))
	if amount_fn == 0:
		return false
	if fn_pool.empty():
		fn_pool = set_pool(pool_size,amount_fn)
	var random_element_from_pool = get_random_element(fn_pool)
	fn_pool.erase(random_element_from_pool)
	return random_element_from_pool

func determine_fp_by_pool(total_pool_size,non_threat_p,agent_error_rate,fp_rate):
	var pool_size = int(total_pool_size*non_threat_p)
	var amount_fp = int((total_pool_size*agent_error_rate)*fp_rate)
	if amount_fp == 0:
		return false
	if fp_pool.empty():
		fp_pool = set_pool(pool_size,amount_fp)
	var random_element_from_pool = get_random_element(fp_pool)
	fp_pool.erase(random_element_from_pool)
	return random_element_from_pool
	
func get_random_element(iterable):
	var get_random_element = iterable[main_script.RNG.randi_range(0,len(iterable)-1)]
	return get_random_element

func determine_fn_by_proba(random_float,proba_fn,fn_modifier):
	if random_float <= proba_fn*fn_modifier:
		return true
	else:
		return false

func determine_fp_by_proba(random_float,proba_fp,fp_modifier):
	if random_float <= proba_fp*fp_modifier:
		return true
	else:
		return false

func _on_missile_deleted(missile):
	if missile in active_missiles:
		active_missiles.erase(missile)

var updated_cross_pos = null # keep track of the crosshair position at all times
var active_agent_repair = false

var msg_lifespan = 6 # set duration for displaying trust repair messages

var delay_limit = 1
var ctrl_delay = delay_limit


var target

func can_agent_move(active_missiles,current_focus,user_focus,agent_activated,ctrl_delay,limit_delay):
	if targeting_enabled == false:
		return false
	
	
	if agent_activated == true and ctrl_delay > limit_delay and current_focus != user_focus:
		return true
	else:
		return false

func are_missile_active():
	if active_missiles:
		return true
	else:
		return false

class sortNestedArrays:
	static func sort(a, b):
		if a[0] < b[0]:
			return true
		return false

func getDistanceMissileCities(array_missiles):
	var missile_time_to_targets = []
	if len(array_missiles) > 1:
		for m in array_missiles:
			var time_to_city = misc_methods.time_to_target(m.global_position,m.target_pos,m.speed) # using missile speed
			missile_time_to_targets.append([time_to_city,m]) 
		missile_time_to_targets.sort_custom(sortNestedArrays,"sort")
		var result = []
		for v in missile_time_to_targets:
			result.append(v[1])
		return result
	else:
		return array_missiles

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a[1] <= b[1]:
			return true
		return false

func check_priority_missile(array_missiles,delta):
	var missiles_to_cities = []
	var crosshair_to_missiles = []
	var CITY_Y_COMP = 100 # pixel separating center of cities from their top
	for m in array_missiles:
		var comp_city_position = m.target_pos
		comp_city_position.y = comp_city_position.y - CITY_Y_COMP
		missiles_to_cities.append([m, misc_methods.time_to_target(m.position,
		comp_city_position,m.speed)])
		
		var optimal_pt = get_optimal_aiming_position(m,tower_node,bullet_node,delta)
		crosshair_to_missiles.append([m,misc_methods.time_to_target(crosshair_node.position,
		optimal_pt,crosshair_node.speed)])

	missiles_to_cities.sort_custom(MyCustomSorter, "sort_ascending")
	crosshair_to_missiles.sort_custom(MyCustomSorter, "sort_ascending")

	var missiles_by_priority = []
	
	for i in range(len(array_missiles)):
		var priority = missiles_to_cities[i]
		var closest = crosshair_to_missiles[i]
		
		if priority == closest:
			missiles_by_priority.append(priority[0])
		elif not priority in missiles_by_priority or not closest in missiles_by_priority:
			var closest_hit_position = get_optimal_aiming_position(closest[0],
			tower_node,bullet_node,delta)
			var crosshair_to_target = misc_methods.time_to_target(crosshair_node.position,
			closest_hit_position,crosshair_node.speed)
			
			var bullet_to_target = misc_methods.time_to_target(tower_node.position,
			closest_hit_position,bullet_node.speed)
			
			var priority_hit_position = get_optimal_aiming_position(priority[0],
			tower_node,bullet_node,delta)
			var closest_to_priority = misc_methods.time_to_target(closest_hit_position,
			priority[0].position,crosshair_node.speed)
			
			var travel_time = crosshair_to_target + bullet_to_target + closest_to_priority
			var WEIGHT = 2
			travel_time = travel_time * WEIGHT

			if travel_time < priority[1]:
				missiles_by_priority.append(closest[0])
			else:
				missiles_by_priority.append(priority[0])
	missiles_by_priority = assess_feasibility_target(missiles_by_priority,
	missiles_to_cities,delta)
	return missiles_by_priority

func assess_feasibility_target(by_priorities,ref,delta):
	var result = by_priorities.duplicate()
	var m = by_priorities[0]
	var hit_missile  = get_optimal_aiming_position(m,tower_node,bullet_node,delta)
	var time_to_missile = misc_methods.time_to_target(crosshair_node.position,
	hit_missile,crosshair_node.speed)
	var idx_eta_missile = misc_methods.find_in_nested(ref,m)
	var eta_missile = ref[idx_eta_missile][1]
	if time_to_missile > eta_missile:
		result.append(m)
		result.erase(m)
	return result

func simple_priority_sort(array_missiles,delta):
	var missiles_to_cities = []
	for m in array_missiles:
		missiles_to_cities.append([m, misc_methods.time_to_target(m.global_position,
		m.target_pos,m.speed)])
	missiles_to_cities.sort_custom(MyCustomSorter, "sort_ascending")
	var missiles_by_priority = []
	for v in missiles_to_cities:
		missiles_by_priority.append(v[0])
	return missiles_by_priority

func set_agent_target(array_missiles,delta,idx,worst = false):
	if worst == true:
		var get_dist_cities = getDistanceMissileCities(array_missiles)
		return get_dist_cities[-1]
	if idx <= len(priority_array)-1:
		return priority_array[idx]
	else:
		return array_missiles.back()

var priority_array # used by the agent

### all variables below are used by other nodes
var optimal_missile_ordering = [] 
var eta_missile_ordering = []
var recency_missile_ordering = []

func order_target_priorities(array_missiles,delta):
	if not array_missiles.empty():
		priority_array = check_priority_missile(array_missiles,delta)
		optimal_missile_ordering = priority_array.duplicate()
		
		var cpt_ordering = 1
		for m in optimal_missile_ordering:
			m.set_priority(cpt_ordering)
			cpt_ordering+=1
		
		eta_missile_ordering = simple_priority_sort(array_missiles,delta)
		recency_missile_ordering = array_missiles

func appendIfDoesntExist(an_array,an_element):
	if not an_element in an_array:
		an_array.append(an_element)

func check_agent_repair():
	if active_agent_repair == false and current_agent._repair: # check if repair active and repair available
		set_agent_repair(current_agent._repair["type"],main_script.t,
		current_agent._repair["repair_timing"],msg_lifespan)

func setNewPositionStatus(boolean):
	new_pos = boolean

func getNewPositionStatus():
	return new_pos

func apply_agent_bias(initial_position,bias_type,bias_intensity,target):
	if bias_type == "sided_systematic":
		return get_sided_systematic_biased_vector(initial_position,target.rotation,
		bias_intensity)
	
	if bias_type == "systematic":
		return get_systematic_biased_vector(initial_position,target.rotation,
		bias_intensity)

	elif bias_type == "random":
		return get_randomly_biased_vector(initial_position,bias_intensity)

var biased_coordinates = Vector2(0,0)

func randomize_agent_timings(timings,d):
	pass
	if timings != null or timings.empty() == false:
		prints("randomizing agents timings with delta up to",d,"\n\tBefore:",timings)
		var rand_start = main_script.RNG.randi_range(timings[0]-d,timings[0]-1)
		var rand_end = timings[1] - (timings[0] - rand_start)
		rand_start = clamp(rand_start, 0, main_script.current_scenario._timelimit)
		rand_end = clamp(rand_end, 0, main_script.current_scenario._timelimit)
		timings = [rand_start,rand_end]
#		prints("\tAfter:",timings)
		return timings
	else:
		print("randomization of agents timings triggered but nothing to randomize.")
	
func _process(delta):
	updated_cross_pos = crosshair_node.global_position
	var can_agent_move = can_agent_move(active_missiles,control_focus_status.get_focus_owner(),user_crosshair_ctrl,
	agent_activated,ctrl_delay,delay_limit)
	var missile_status = are_missile_active()
	
	if missile_status == true:
		order_target_priorities(active_missiles,delta)
	
	if can_agent_move == true and missile_status == true:
		
		if current_agent.getAgentBehaviour() == true:
			set_agent_behaviour(active_missiles,current_agent._behaviour["type"],main_script.t,
				current_agent._behaviour_timing,delta)

		if current_agent.getBehaviourStatus() == false:
			target = set_agent_target(active_missiles,delta,0)
			var aiming_position = get_optimal_aiming_position(target,tower_node,
				bullet_node,delta)
			if getNewPositionStatus() == true:
				setNewPositionStatus(false)
				biased_coordinates = apply_agent_bias(aiming_position,current_agent._bias_type,
				current_agent._bias_intensity,target)
			aiming_position.x += biased_coordinates.x
			aiming_position.y += biased_coordinates.y
			move_node(crosshair_node,updated_cross_pos,aiming_position,crosshair_node.speed)
	elif can_agent_move == true and missile_status == false:
		agent_center_crosshair(updated_cross_pos)
	
	else:
		agent_passive()

	manage_delay_ctrl_agent(control_focus_status.get_focus_owner(),user_crosshair_ctrl,delta)

func manage_delay_ctrl_agent(current_focus,user_ctrl_focus,delta):
	if current_focus == user_ctrl_focus: # to check when an agent can get control back
		ctrl_delay = 0
	else:
		ctrl_delay += delta

var textbox_timer = Timer.new()
func start_timer(time):
	add_child(textbox_timer)
	textbox_timer.set_wait_time(time)
	textbox_timer.set_one_shot(true) # no loop
	textbox_timer.start()

func _on_textbox_timer_timeout():
	$text_box.hide()

var one_off_used = false
func one_off_reset():
	if one_off_used == false:
		one_off_used = true
		setNewPositionStatus(true)

func set_agent_repair(type,t,uptime,msg_lifetime):
	if type == "apology":
		if int(t) in uptime and not $tween_textbox.is_active():
			$text_box.show()
			$text_box/displayed_text.text = "I'm sorry"
			$tween_textbox.interpolate_property($text_box, "scale",
			Vector2(0,0),$text_box.scale,1.1,
			Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT,0)
			$tween_textbox.start()
			start_timer(msg_lifetime)

func get_round_timing(all_timings):
	if len(all_timings.keys()) == main_script.current_scenario._round_limit:
		return all_timings[str(main_script.current_scenario._current_round_nb)]
	else:
		return all_timings["1"]

func _on_beginning_wave():
	if current_agent:
		current_agent._behaviour_timing = set_behaviour_timing(current_agent)

func _on_beginning_round():
	if current_agent:
		current_agent._behaviour_timing = set_behaviour_timing(current_agent)

func set_behaviour_timing(agent):
	var final_timing = null
	if agent._behaviour and main_script.id in main_script.participant_ordering:
		for agent_settings in main_script.participant_ordering[main_script.id]:
			if current_agent._agent_name == agent_settings["agent"]:
				var get_rd_timings = agent_settings["behaviour_timings"]
				var current_wave = main_script.current_scenario._current_wave_idx
				if str(current_wave) in get_rd_timings:
					if current_agent._timing_delta and current_agent._behaviour_timing.empty() == false:
						current_agent._behaviour_timing = randomize_agent_timings(current_agent._behaviour_timing,
						current_agent._timing_delta)
					final_timing = get_rd_timings[str(current_wave)]
					return get_rd_timings[str(current_wave)]
	else:
		final_timing = agent._default_behaviour_timing
	if current_agent._timing_delta:
		final_timing = randomize_agent_timings(final_timing,current_agent._timing_delta)
#	print("final timing:",final_timing)
	return final_timing
	
func get_relevant_timing(type,timings):
	if type == "changing":
		return timings
	else:
		if main_script.id in main_script.participant_ordering:
			for agent_settings in main_script.participant_ordering[main_script.id]:
				if current_agent._agent_name == agent_settings["agent"]:
					var get_rd_timings = agent_settings["behaviour_timings"]
					return get_rd_timings
		else:
			return timings

func distanceFromTarget(array_missiles):
	var crosshair_time_to_missiles = []
	if len(array_missiles) > 1:
		for m in array_missiles:
			var time_to_crosshair = misc_methods.time_to_target(m.global_position,crosshair_node.global_position,
			crosshair_node.speed) # using crosshair speed
			crosshair_time_to_missiles.append([time_to_crosshair,m])
		crosshair_time_to_missiles.sort_custom(sortNestedArrays,"sort")
		var result = []
		for v in crosshair_time_to_missiles:
			result.append(v[1])
		return result
	else:
		return array_missiles

func randSelectNewTarget(array_missiles,existing_target):
	if len(array_missiles) > 1:
		var check_target = array_missiles.find(existing_target)
		var rand_idx = check_target
		while rand_idx == check_target:
			rand_idx = int(main_script.RNG.randi_range(0,len(active_missiles)-1))
		return array_missiles[rand_idx]
	else:
		return array_missiles[0]

func set_agent_behaviour(target_list,type,t,timings,delta):
	if timings != null and timings.empty() == false and int(t) in range(timings[0],timings[1]):
		if type == "lapse": # agent stop moving
			agent_passive()
			agent_behaviour_active()
		elif type == "mistake": # change target
			agent_active()
			agent_behaviour_active()
			if active_missiles.find(target) == -1: # check if target (still) exist
				target = randSelectNewTarget(active_missiles,target)
			var time_to_target = misc_methods.time_to_target(target.global_position,crosshair_node.global_position,
			crosshair_node.speed)
			var delay_retargetting = float(current_agent._behaviour["retargetting_distance"])
			if time_to_target < delay_retargetting:
				target = randSelectNewTarget(active_missiles,target)
			var aiming_position = get_optimal_aiming_position(target,tower_node,
				bullet_node,delta)
			if getNewPositionStatus() == true:
				setNewPositionStatus(false)
				biased_coordinates = apply_agent_bias(aiming_position,current_agent._bias_type,
					current_agent._bias_intensity,target)
			aiming_position.x += biased_coordinates.x
			aiming_position.y += biased_coordinates.y
			move_node(crosshair_node,updated_cross_pos,aiming_position,crosshair_node.speed)

		elif type == "slips": # agent suddenly is very inaccurate
			agent_active()
			agent_behaviour_active()
			target = set_agent_target(active_missiles,delta,0)
#			var SLIPS_INTENSITY = 170
			var SLIPS_INTENSITY = current_agent._behaviour["slips_intensity"]
			var aiming_position = get_optimal_aiming_position(target,tower_node,
				bullet_node,delta)
			if getNewPositionStatus() == true:
				setNewPositionStatus(false)
				biased_coordinates = apply_agent_bias(aiming_position,"random",
				SLIPS_INTENSITY,target)
			aiming_position.x += biased_coordinates.x
			aiming_position.y += biased_coordinates.y
			move_node(crosshair_node,updated_cross_pos,aiming_position,crosshair_node.speed)

		elif type == "changing":
			agent_active()
			agent_behaviour_active()
			target = set_agent_target(active_missiles,delta,0)
			if int(t) in range(0.000,main_script.current_scenario._timelimit) and delta > 0.000:
				var get_total_round_duration = main_script.current_scenario._timelimit*main_script.current_scenario._wave_limit
				var diff_start2goal = current_agent._behaviour["goal"] - current_agent._behaviour["start"]
				var per_sec_growth_rate = (diff_start2goal / get_total_round_duration)
				var total_time_passed = main_script.t + ((main_script.current_scenario._current_wave_idx-1)* \
					main_script.current_scenario._timelimit)
				var new_bias = current_agent._behaviour["start"] + (total_time_passed*per_sec_growth_rate)
				
				current_agent._bias_intensity = new_bias
#				current_bias = new_bias
				var aiming_position = get_optimal_aiming_position(target,tower_node,
					bullet_node,delta)
				if getNewPositionStatus() == true:
					setNewPositionStatus(false)
					biased_coordinates = apply_agent_bias(aiming_position,current_agent._bias_type,
					current_agent._bias_intensity,target)
				aiming_position.x += biased_coordinates.x
				aiming_position.y += biased_coordinates.y
				
				move_node(crosshair_node,updated_cross_pos,aiming_position,crosshair_node.speed)
	else:
		agent_behaviour_inactive()

func move_node(node_to_move,starting_pos,final_pos,speed):
	final_pos.x = clamp(final_pos.x, 0, screensize.x)
	final_pos.y = clamp(final_pos.y, 0, h_limit.global_position.y)
	var time_required = misc_methods.distance_btw_vec(starting_pos,final_pos)/speed
	$tween_aiming.interpolate_property(node_to_move, "global_position",
		starting_pos, final_pos, time_required,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween_aiming.start()
	agent_active()

func get_sided_systematic_biased_vector(vector1,rotation,bias_intensity):
	var sys_biased_position = gauss_sided_locked_bias(rotation,vector1,
	bias_intensity)
	if misc_methods == null:
		misc_methods = preload("res://scripts/misc.gd").new()
	var biased_coordinates = misc_methods.get_vector_difference(vector1,sys_biased_position)
	return biased_coordinates

func gauss_sided_locked_bias(rot,vector,sigma):
	####### only keep quadrant 1 and 3
	var convert_rot = 0.7 # used to transform angles into sided one # TO TEST FURTHER
	var found = false
	var final_vector = null
	while found == false:
		var new_x_vector = gauss(vector.x,sigma)
		var new_y_vector = gauss(vector.y,sigma)
		if new_x_vector < vector.x and new_y_vector < vector.y:
			final_vector = Vector2(new_x_vector,new_y_vector) # quadrant 1
			found = true
		if new_x_vector > vector.x and new_y_vector > vector.y:
			final_vector = Vector2(new_x_vector,new_y_vector) # quadrant 3
			found = true
	final_vector.x -= vector.x
	final_vector.y -= vector.y
	var new_rot = rot + convert_rot
	# rotate point
	var x_rotated = final_vector.x * cos(new_rot) - final_vector.y * sin(new_rot);
	var y_rotated = final_vector.x * sin(new_rot) + final_vector.y * cos(new_rot);
	# translate point back:
	final_vector.x = x_rotated + vector.x
	final_vector.y = y_rotated + vector.y
	return final_vector

func get_systematic_biased_vector(vector1,rotation,bias_intensity,quadrant=null):
	var selected_quadrant = quadrant
	if quadrant == null:
		selected_quadrant = current_agent._quadrant
	var sys_biased_position = gauss_quad_locked_bias(rotation,vector1,
	bias_intensity,selected_quadrant)
	if misc_methods == null:
		misc_methods = preload("res://scripts/misc.gd").new()
	var biased_coordinates = misc_methods.get_vector_difference(vector1,sys_biased_position)
	return biased_coordinates

func get_randomly_biased_vector(vector1,sigma):
	var rand_biased_position = Vector2(gauss(vector1.x,sigma),gauss(vector1.y,sigma))
	if not misc_methods:
		misc_methods = preload("res://scripts/misc.gd").new()
	var biased_coordinates = misc_methods.get_vector_difference(vector1,rand_biased_position)
	return biased_coordinates

func get_optimal_aiming_position_from_values(target,from,target_speed,proj_speed,rot,delta):
	var next_x = target.x + target_speed * delta * cos(rot)
	var next_y = target.y + target_speed * delta * sin(rot)
	var next_target_pos = Vector2(next_x,next_y)
	var time_to_target = misc_methods.time_to_target(from,target,proj_speed)
	var future_step_target = (next_target_pos - target) * time_to_target / delta
	var final_pos = Vector2(target[0]+future_step_target[0],target[1]+future_step_target[1])
	return final_pos

func get_optimal_aiming_position(target,from,projectile,delta):
	var next_x = target.global_position.x + target.speed * delta * cos(target.rotation)
	var next_y = target.global_position.y + target.speed * delta * sin(target.rotation)
	var next_target_pos = Vector2(next_x,next_y)
	var time_to_target = misc_methods.time_to_target(from.global_position,target.global_position,projectile.speed)
	var future_step_target = (next_target_pos - target.global_position)*time_to_target / delta
	var final_pos = Vector2(target.global_position[0]+future_step_target[0],
		target.global_position[1]+future_step_target[1])
	return final_pos

func gauss(mean, sigma):
	# output a new gaussian value depending on int mean and int sigma
	var x2pi = main_script.RNG.randf() * (2.0 * PI)
	var g2rad = sqrt(-2.0 * log(1.0 - main_script.RNG.randf()))
	var z = cos(x2pi) * g2rad
	return mean + z*sigma

func rand_syst_bias(vector_position,bias):
	# calculate a new random position at the set distance of bias
	var rand_angle = int(main_script.RNG.randi_range(1,360))
	var opposite = bias*sin(rand_angle)
	var adjacent = opposite / tan(rand_angle)
	var new_x = vector_position.x + adjacent
	var new_y = vector_position.y + opposite
	return(Vector2(new_x,new_y))

func gauss_quad_locked_bias(rot,vector,sigma,quadrant):
	# output a position randomly deviating from the mean in a selected quadrant
	# quadrants range from 1 to 4: 1 = top left, 2 = top right, 3 = bottom left, 4 = bottom right
	if quadrant <= 4 and quadrant >= 1:
		var found = false
		var final_vector = null
		while found == false:
			var new_x_vector = gauss(vector.x,sigma)
			var new_y_vector = gauss(vector.y,sigma)
			if quadrant == 1 and new_x_vector < vector.x and new_y_vector < vector.y:
				final_vector = Vector2(new_x_vector,new_y_vector)
				found = true
			if quadrant == 2 and new_x_vector > vector.x and new_y_vector < vector.y:
				final_vector = Vector2(new_x_vector,new_y_vector)
				found = true
			if quadrant == 3 and new_x_vector > vector.x and new_y_vector > vector.y:
				final_vector = Vector2(new_x_vector,new_y_vector)
				found = true
			if quadrant == 4 and new_x_vector < vector.x and new_y_vector > vector.y:
				final_vector = Vector2(new_x_vector,new_y_vector)
				found = true
		# translate point back to origin:
		final_vector.x -= vector.x
		final_vector.y -= vector.y
		# rotate point
		var x_rotated = final_vector.x * cos(rot) - final_vector.y * sin(rot);
		var y_rotated = final_vector.x * sin(rot) + final_vector.y * cos(rot);
		# translate point back:
		final_vector.x = x_rotated + vector.x
		final_vector.y = y_rotated + vector.y
		return final_vector
	else:
		print("ERROR wrong quadrant selected")

func agent_active():
	$cable_agent.self_modulate = white
	self.show()
	self.z_index = 1
	agent_crosshair.show()
	neutral_crosshair.hide()
	agent_crosshair_ctrl.grab_focus()

func agent_behaviour_active():
	main_script.loaded_agent._active_agent_behaviour = true

func agent_behaviour_inactive():
	main_script.loaded_agent._active_agent_behaviour = false

func agent_passive():
	self.z_index = 0
	$cable_agent.self_modulate = dark_grey
	agent_crosshair.hide()
	$tween_aiming.stop_all()
	agent_crosshair_ctrl.release_focus()

func agent_center_crosshair(crosshair_position):
	var center_screen = Vector2(screensize.x/2,screensize.y/2.3)
	if misc_methods.distance_btw_vec(updated_cross_pos,center_screen) > 100:
		move_node(crosshair_node,crosshair_position,center_screen,crosshair_node.speed)
	else:
		agent_passive()

func _on_shot_fired():
	setNewPositionStatus(true)

onready var autoplay = get_node(root_node_path+"/consent_form/autoplay_panel/CheckButton")
var allow_shoot = true

func check_for_autoplay():
	var current_scenario = main_script.current_scenario
	if autoplay and current_scenario:
		autoplay.pressed = current_scenario._autoplay
		prints("Autoplay set to:",current_scenario._autoplay)

func _on_tween_aiming_tween_completed(object, key):
	if autoplay.pressed == true and allow_shoot == true:
		tower_node.shoot()
	else:
		pass

func on_explosion_ended():
	allow_shoot = true
