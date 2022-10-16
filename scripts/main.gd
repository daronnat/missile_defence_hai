extends Node2D

var AUTO_LATIN_SQUARE = true
var ordering_mode = "automatic" # automatic # manual # manual_group_agent
var GET_RANDOM_SEED = false # decide if everything is deterministic or not
var RNG_SEED = 3
var path_folder = "res://text_resources/"
var ORDERING_FILE = "reduced_ordering.json" # "short_ordering.json"

onready var agent_settings = preload("res://scripts/agent_settings.gd")
onready var scenario_script = preload("res://scripts/scenario_settings.gd")
onready var logging_node = get_node('/root/Node2D/consent_form/logging_panel')
onready var obscuring_scene = preload("res://scenes/obscuring_area.tscn")
onready var graph_scene = preload("res://scenes/graph.tscn")
onready var friendly_scene = preload("res://scenes/friendly_object.tscn")
onready var pause_scene = preload("res://scenes/pause_event.tscn")
onready var story_scene = preload("res://scenes/cover_stories.tscn") 
onready var visual_aid_scene = preload("res://scenes/visual_aid.tscn")

signal send_agent_info
signal beginning_round
signal reset_city
signal beginning_wave

var RNG
var gamemode

func _ready():
	setup_rng(RNG_SEED,GET_RANDOM_SEED)
	self.connect("beginning_wave",$crosshair,"_on_beginning_wave")
	self.connect("beginning_round",$crosshair,"_on_beginning_round")
	self.connect("beginning_wave",$agent_avatar,"_on_beginning_wave")
	self.connect("beginning_round",$agent_avatar,"_on_beginning_round")
	self.connect("reset_city",$city1,"_on_reset_city")
	self.connect("reset_city",$city2,"_on_reset_city")
	self.connect("reset_city",$city3,"_on_reset_city")
	self.connect("reset_city",$city4,"_on_reset_city")
	self.connect("send_agent_info",$agent_avatar,"_on_agent_info_get")
	set_basic_parameters()

func setup_rng(a_seed,random):
	RNG = RandomNumberGenerator.new()
	if random == false:
		RNG.set_seed(a_seed)
		prints("MANUAL seed initialised with:",RNG.get_seed())
	else:
		RNG.randomize()
		prints("RANDOM seed initialised with:",RNG.get_seed())

func back_to_main_menu():
	current_scenario = null # prevent game from restarting
	hide_game_elements()
	reset_timers()
	t = -5
	show_main_menu()

func show_consent_form():
	$consent_form.show()
	$consent_form/refuse.grab_focus()

func hide_game_elements():
	$help_status.hide()
	$wait_panel.hide()
	$consent_form/id_panel/next_button/pls_wait.hide()
	$upper_information/timer.hide()
	$tower_gun.hide()
	$tower_base.hide()
	$endgame.hide()
	$agent_avatar.hide()
	$agent_offline.hide()
	$user_avatar.hide()
	$city1.hide()
	$city2.hide()
	$city3.hide()
	$city4.hide()
	$cloud2.hide()
	$cloud1.hide()
	$ammo_label.hide()
	$upper_information/round_counter.hide()
	$upper_information/wave_counter.hide()
	$upper_information/session_counter.hide()

func set_basic_parameters():
	hide_game_elements()
	show_consent_form()

var array_smoke = []

func _on_smoke_spawned(id):
	array_smoke.append(id)

signal controls_enabled

func load_basic_assets():
	if $main_menu/city_test:
		$main_menu/city_test.queue_free()
	$main_menu.hide()
	$upper_information/round_counter.show()
	$upper_information/wave_counter.show()
	$user_avatar.show()
	$upper_information/timer.show()
	$tower_gun.show()
	$tower_base.show()
	$city1.show()
	$city2.show()
	$city3.show()
	$city4.show()
	$cloud2.show()
	$cloud1.show()
	$ammo_label.show()
	emit_signal("controls_enabled")
	start()

var id

func _on_id_received(an_id):
	id = an_id

var participant_ordering

func show_main_menu():
	print("Displaying main menu")
	$main_menu.show()
	$main_menu/tutorial.grab_focus()
	populate_custom_selection(path_folder+"scenarios.json")
#	if ordering_mode == "manual_group_agent":
#		proceed_manual_group_agent()
#	else:
	process_ordering()

func populate_custom_selection(scenario_file):
	var parsed_file = parse_resource_file(scenario_file)
	for k in parsed_file["scenarios"].keys():
		$main_menu/custom_list.add_item(k)

func process_ordering():
	participant_ordering = parse_resource_file(path_folder+ORDERING_FILE)
	if ordering_mode == "manual":
		$main_menu/manual_selection_panel.hide()
		if id in participant_ordering[ordering_mode].keys():
			var agent_order = participant_ordering[ordering_mode][id]
			var usage_log_path = $consent_form.active_log_path+id+"_usage.json"
			var file = File.new()
			if file.file_exists(usage_log_path) == true:
				var usage_log = parse_resource_file(usage_log_path)
			##############
				display_menu_items(usage_log["gamemode_played"],agent_order)
			else:
				display_menu_items(null,agent_order)

	elif ordering_mode == "automatic":
		$main_menu/manual_selection_panel.hide()
		print("going automatic...")
		var folder_count = SERVER_FOLDER_COUNT
		auto_idx = get_auto_idx(folder_count,len(participant_ordering["automatic"].keys()))
		var auto_selection = participant_ordering[ordering_mode].keys()[auto_idx]
		# add logic for looping over scenarios in automatic here
		var agent_order = participant_ordering[ordering_mode][auto_selection]
		prints("AUTOMATIC SELECTION:",auto_selection,agent_order)
		
		### LATIN SQUARE BALANCING
		# /!\ CAREFUl, TUTORIAL ARE ASSUMED TO BE ALWAYS FIRST AND THUS KEPT OUT OF THE BALANCING
		# ALSO MIGHT NOT WORK ON ODD NUMBER OF SESSIONS (not including tutorial)
		if AUTO_LATIN_SQUARE == true:
			var idx_ordering = get_idx_progress_ordering(folder_count,len(participant_ordering[ordering_mode]),
			len(agent_order)-1)
			agent_order = balanced_latin_sq_ordering(agent_order,idx_ordering)
			print("BALANCED AGENT ORDER:",agent_order)
		var usage_log_path = $consent_form.active_log_path+id+"_usage.json"
		var file = File.new()
		if file.file_exists(usage_log_path) == true:
			var usage_log = parse_resource_file(usage_log_path)
			display_menu_items(usage_log["gamemode_played"],agent_order)
		else:
			display_menu_items(null,agent_order)

	elif ordering_mode == "manual_group_agent":
#		$main_menu/manual_selection_panel.show()
		proceed_manual_group_agent()
##		print("manual group/agent setting...")
#		var folder_count = SERVER_FOLDER_COUNT
#		auto_idx = get_auto_idx(folder_count,len(participant_ordering["manual_group_agent"].keys()))
#		var auto_selection = participant_ordering[ordering_mode].keys()[auto_idx]
#		# add logic for looping over scenarios in automatic here
#		var agent_order = participant_ordering[ordering_mode][auto_selection]
#		prints("AUTOMATIC SELECTION:",auto_selection,agent_order)
#
#		### LATIN SQUARE BALANCING
#		# /!\ CAREFUl, TUTORIAL ARE ASSUMED TO BE ALWAYS FIRST AND THUS KEPT OUT OF THE BALANCING
#		# ALSO MIGHT NOT WORK ON ODD NUMBER OF SESSIONS (not including tutorial)
##		if AUTO_LATIN_SQUARE == true:
##			var idx_ordering = get_idx_progress_ordering(folder_count,len(participant_ordering[ordering_mode]),
##			len(agent_order)-1)
##			agent_order = balanced_latin_sq_ordering(agent_order,idx_ordering)
##			print("BALANCED AGENT ORDER:",agent_order)
#		var usage_log_path = $consent_form.active_log_path+id+"_usage.json"
#		var file = File.new()
#		if file.file_exists(usage_log_path) == true:
#			var usage_log = parse_resource_file(usage_log_path)
#			display_menu_items(usage_log["gamemode_played"],agent_order)
#		else:
#			display_menu_items(null,agent_order)
#		$main_menu/manual_selection_panel.show()



var selected_agent
var selected_group

func proceed_manual_group_agent():
#	var participant_usage = parse_resource_file($consent_form.active_log_path+id+"_usage.json")
	$main_menu/manual_selection_panel.show()
	if selected_group or selected_agent:
		var agent_order = participant_ordering[ordering_mode][selected_group]
		var usage_log_path = $consent_form.active_log_path+id+"_usage.json"
		var file = File.new()
		if file.file_exists(usage_log_path) == true:
			var usage_log = parse_resource_file(usage_log_path)
			display_menu_items(usage_log["gamemode_played"],agent_order)
		else:
			display_menu_items(null,agent_order)
#	participant_ordering = parse_resource_file(path_folder+ORDERING_FILE)
	
	

func _on_agent_ordering_button_pressed():
	if selected_agent and selected_group:
#		prints("SELECTION:",selected_agent,selected_group)
		$main_menu/manual_selection_panel/warning_msg.hide()
#		participant_ordering
#		var folder_count = SERVER_FOLDER_COUNT
#		auto_idx = get_auto_idx(folder_count,len(participant_ordering["automatic"].keys()))
		var agent_order = participant_ordering[ordering_mode][selected_group]
		print("MANUAL GROUP / AGENT selection:",agent_order)
		var usage_log_path = $consent_form.active_log_path+id+"_usage.json"
		var file = File.new()
		if file.file_exists(usage_log_path) == true:
#			print("if")
			var usage_log = parse_resource_file(usage_log_path)
			display_menu_items(usage_log["gamemode_played"],agent_order)
		else:
#			print("else")
			display_menu_items(null,agent_order)
	else:
		$main_menu/manual_selection_panel/warning_msg.show()
		$main_menu/manual_selection_panel/warning_msg.text = "ERROR\nYou must select one agent AND one group to proceed."

func _on_agent_toggled(button_pressed, extra_arg_0):
	if button_pressed == true:
		untoggle_other_nodes_in_group(extra_arg_0,"checkbox_agents")
		selected_agent = extra_arg_0
	else:
		selected_agent = null

func _on_group_toggled(button_pressed, extra_arg_0):
	if button_pressed == true:
		untoggle_other_nodes_in_group(extra_arg_0,"checkbox_group")
		selected_group = extra_arg_0
	else:
		selected_group = null

func untoggle_other_nodes_in_group(node_name,path):
	for n in self.get_tree().get_nodes_in_group(path):
		if n.name != node_name:
			n.pressed = false

func balanced_latin_sq_ordering(order,idx_ord):
	var tutorial = order.pop_front() # ASSUME THAT TUTORIALS ARE PRESENT IN FIRST SESSION
	var n = len(order)
	var l = []
	for i in range(n):
		var row = []
		for j in range(n):
			var condition
			if j%2:
				condition = floor(j/2)+1
			else:
				condition = n-floor(j/2)
			condition = int(condition + i) % n
			row.append(order[condition])
		l.append(row)
	
	if n % 2:  # Repeat reversed for odd n
		print("balancing...even number of conditions...")
		var to_add = []
		for seq in l:
			var seq_copy = seq.duplicate()
			seq_copy.invert()
			to_add.append(seq_copy)
		l = l + to_add
	
	var result = l[idx_ord].duplicate(true)
	result.insert(0,tutorial) # PUT TUTORIALS BACK IN
	return result

func get_auto_idx(a_nb,limit):
	var result = 0
	for i in range(0,a_nb):
		result+=1
		if result > limit-1:
			result = 0
	return result

func get_idx_progress_ordering(p_id,group_length,ordering_length):
	var iter = 0
	var group_i = 0
	var ordering_i = 0
	for n in range(0,p_id):
		iter+=1
		if iter >= group_length:
			iter = 0
			if ordering_i < ordering_length-1:
				ordering_i += 1
			else:
				ordering_i = 0
	return ordering_i

func display_menu_items(past_sessions,agent_order):
	for agent_setting in agent_order:
		var agent_to_play = agent_setting["session"]
		if past_sessions == null or not agent_to_play in past_sessions:
			hide_other_items(agent_to_play)
			break

func hide_other_items(button_name=""):
	auto_launch(ordering_mode,button_name)
	for element in $main_menu.get_children():
		if element.get_class() == "Button":
			if element.name != button_name:
				element.disabled = true
			else:
				element.show()
				element.disabled = false

func auto_launch(ordering_mode,a_session):
	if ordering_mode in ["automatic","manual_group_agent"]:
		prints("automatic launching of:",a_session)
		_on_gamemode_pressed(a_session)

func _on_Button_pressed():
	for element in $main_menu.get_children():
		if element.get_class() == "Button":
				element.disabled = false
				element.show()

func _on_gamemode_pressed(extra_arg_0): # general way of selecting a gamemode
	prints("Pressed:",extra_arg_0)
	gamemode = extra_arg_0
	logging_node.log_usage(gamemode)
	load_basic_assets()
	reset_var() # to avoid recording missile hit in menu


onready var scenarios = null
var cpt_missile_destroyed = 0
var cpt_city_destroyed = 0

func modify_score(obj):
	### WEIRD BUG when getting the name of two of the same object, safer to detect the string "KinematicBody"
	if obj.get_name() == "missile" or (str(obj)).begins_with("[Kinematic"):
		cpt_missile_destroyed+=1
		if current_scenario:
			current_scenario.missile_destroyed(obj)
			current_scenario.set_type_missile_destroyed(obj.target_status)
			if obj in current_scenario._hidden_missiles:
				current_scenario.hidden_missile_hit()
			
	elif (obj.get_name()).begins_with("city") == true:
		cpt_city_destroyed +=1

### spawning and monitoring missiles ###
var all_cities = ["city1","city2","city3","city4"]
var non_cities = {"right":["non_threat_right1","non_threat_right2"],
"left":["non_threat_left1","non_threat_left2"]}
var all_spawns = ["left_spawn_1","left_spawn_2","mid_spawn_1","mid_spawn_2","right_spawn_1","right_spawn_2"]
var left_spawns = ["right_spawn_group1","right_spawn_group2","right_spawn_group3"]
var right_spawns = ["left_spawn_group1","left_spawn_group2","left_spawn_group3"]
var divided_spawns = {"right":["right_spawn_group1","right_spawn_group2","right_spawn_group3"],
	"left":["left_spawn_group1","left_spawn_group2","left_spawn_group3"]}
var last_spawn = "left"

onready var missile_sce = preload("res://scenes/missile.tscn")

func get_random_element(iterable):
	var get_random_element = iterable[RNG.randi_range(0,len(iterable)-1)]
#	print("Random element:",get_random_element)
	return get_random_element

func get_random_boolean(frequency):
	if frequency < 0 or frequency > 1:
		push_error ("Wrong value for random frequency result")
		return null
	else:
		var rand_result = RNG.randf()
		if rand_result > frequency:
			return true
		else:
			return false

#var determined_amount_non_threat = null
#var determined_amount_threat = null
var amount_pooled_missiles
var threat_pool = []
func set_random_threat_pool(frequency_non_threat):
	var pool = []
	var target = (current_scenario._timelimit/current_scenario._missile_interval)*current_scenario._missile_at_once
#	amount_pooled_missiles = target
	var determined_amount_non_threat = int(target*frequency_non_threat)
	var determined_amount_threat = int(target - determined_amount_non_threat)
	for i in range(0,determined_amount_non_threat):
		pool.append(false)
	for i in range(0,determined_amount_threat):
		pool.append(true)
	pool.shuffle()
#	print("Threat pool activated:",pool)
	amount_pooled_missiles = len(pool)
	return pool

func use_random_threat_pool(frequency):
	if threat_pool.empty():
		threat_pool = set_random_threat_pool(frequency)
	var random_element_from_pool = get_random_element(threat_pool)
	threat_pool.erase(random_element_from_pool)
#	prints("new length:",len(threat_pool))
	return random_element_from_pool

### quick and dirty way to keep track of hit and misses
var missile_success = []
func update_missile_success(a_bool):
	missile_success.append(a_bool)
	if len(missile_success) > 20:
		missile_success.pop_front()

func spawn_automated_missile(missile_speed,nbr_missile):
	var last_specific_spawn
	var activation_delay = 0
	for m in range(0,nbr_missile):
		var current_spawn
		if last_spawn == "left":
			current_spawn = divided_spawns["right"]
			last_spawn = "right"
		else:
			current_spawn = divided_spawns["left"]
			last_spawn = "left"
		var random_spawn = get_node(get_random_element(current_spawn))
		var missile_threat = true
		if current_scenario._non_threat_missiles["enabled"] == true:
#			missile_threat = get_random_boolean(current_scenario._non_threat_missiles["frequency"])
			missile_threat = use_random_threat_pool(current_scenario._non_threat_missiles["frequency"])
		var active_cities = all_cities
		if missile_threat == false:
			active_cities = non_cities["left"]
			if last_spawn == "right":
				active_cities = non_cities["right"]
		var random_target = get_node(get_random_element(active_cities))
		var random_speed = int(get_random_element(missile_speed))
		activation_delay += current_scenario._activation_delay
		var missile = missile_sce.instance()
		missile.threat = missile_threat
		missile.start(random_spawn.position,random_target.position,random_speed,activation_delay)
		get_parent().add_child(missile)

var active_missiles = []
var cpt_missiles_spawned = 0

func spawn_missile(target,speed,spawn_location):
	var missile = missile_sce.instance()
	missile.start(get_node(spawn_location).position,get_node(target).position,speed)
	get_parent().add_child(missile)

func _on_missile_spawned(missile_and_speed):
	cpt_missiles_spawned += 1
	active_missiles.append(missile_and_speed[0])
	if current_scenario:
		current_scenario.missile_spawned(missile_and_speed[0])

func _on_missile_deleted(missile):
	active_missiles.erase(missile)

func _on_send_building_hit(city_id):
	if current_scenario:
		current_scenario.city_hit(city_id)

func _on_friendly_spawned(friendly):
	if current_scenario:
		current_scenario.friendly_spawned()

func _on_friendly_deleted(friendly):
	if current_scenario:
		current_scenario.friendly_deleted()

var cpt_temp_inc = 0
func check_for_temp_increase_missile(info,delta):
	cpt_temp_inc+=delta
	if info.empty() == false:
		if cpt_temp_inc > int(info["interval"]):
			print("Triggering temporary missile surge...")
			spawn_automated_missile(current_scenario._missile_speed,int(info["quantity"]))
			cpt_temp_inc = 0

var path_to_send = null

func send_path():
	return path_to_send

func _on_next_session_button_pressed():
	beg_game = true
	wait_next_session = false
	$post_session_break.hide()
	t = 0

func _on_game_mode_received(mode):
	print("Gamemode selected: ",mode)

func parse_resource_file(path_to_file):
	print("-> loading resources...")
	var file = File.new()
	file.open(path_to_file, file.READ)
	var json_text = file.get_as_text()
	var result_json = JSON.parse(json_text)
	prints(path_to_file,"parsed with",result_json.error,"error(s).")
	return result_json.result

var current_scenario = null
var agents = null

onready var quick_question_scene = preload("res://scenes/quick_question.tscn")

func start_cloud_animation():
	$cloud2/AnimationPlayer.play("cloud_moving")
	$cloud1/AnimationPlayer.play("cloud_moving")

func start():
	reset_smoke()
	emit_signal("reset_city")
	
	start_cloud_animation()
	
	print("loading scenarios...")
	
	scenarios = parse_resource_file(path_folder+"scenarios.json")
	current_scenario = scenario_script.new(gamemode,scenarios,self)
	current_scenario.randomize_waves()
	
	loading_agent(current_scenario._current_agent)
	
	$tower_gun.get_ammo_info()

#	set_friendly(current_scenario["_friendly_timing"])
#	set_friendly()
	set_obscuring(current_scenario["_obscuring_type"])
	set_visual_aid(current_scenario["_visual_aid"])
	set_scheduled_event(current_scenario._wave_scheduled_events)
	set_pause_event()
	clear_friendly()
	set_cover_story()
	
	if gamemode == "tutorial":
		t = -1
	else:
		beginning_siren_msg()

var visual_aid_instance
func set_visual_aid(type):
	if type != "":
		visual_aid_instance = visual_aid_scene.instance()
		add_child(visual_aid_instance)
		visual_aid_instance.set_visual_aid_type(type)
		print('called')
	elif visual_aid_instance:
			visual_aid_instance.queue_free()
			visual_aid_instance = null

func manage_visual_aid(d,timing):
	if visual_aid_instance:
		visual_aid_instance.manage_visual_aid_timing(d,timing)
		current_scenario._visual_aid_activated = visual_aid_instance.visual_aid_activated

var story_instance
func set_cover_story():
	if current_scenario._cover_story.empty() == false:
		get_tree().paused = true
		story_instance = story_scene.instance()
		add_child(story_instance)
		story_instance.start(current_scenario._cover_story["story_text"])

var pause_instance
func manage_pause_event(t,timing):
	if pause_instance:
		pause_instance.check_pause_t(t,timing)
#		print(">>>",t,timing)

func set_pause_event():
	if pause_instance:
		pause_instance.queue_free()
	pause_instance = pause_scene.instance()
	add_child(pause_instance)

func manage_graph():
	var graph_instance = graph_scene.instance()
	add_child(graph_instance)

var obscuring_instance
func set_obscuring(type):
	if obscuring_instance:
		obscuring_instance.queue_free()
	
	if type != "":
		obscuring_instance = obscuring_scene.instance()
		obscuring_instance.set_visual_info(type)
		add_child(obscuring_instance)
	else:
		obscuring_instance = null

func manage_obscuring(d,timing):
	if obscuring_instance:
		obscuring_instance.manage_visual_timing(d,timing)
		current_scenario._obscuring_activated = obscuring_instance.visual_activated
		current_scenario.set_hidden_missiles(obscuring_instance.hidden_missile)

var friendly_instance
func clear_friendly():
	seen_t_friendly = []

var seen_t_friendly = []
func manage_friendly(d,timing):
	if int(d) in timing and not int(d) in seen_t_friendly:
		seen_t_friendly.append(int(d))
		friendly_instance = friendly_scene.instance()
		add_child(friendly_instance)

func loading_agent(current_agent):
	print("Loading agent...")
	if selected_agent and gamemode != "tutorial":
		prints("Manual agent selection:",current_agent,"to",selected_agent)
		current_agent = selected_agent
		current_scenario._current_agent = selected_agent
	agents = parse_resource_file(path_folder+"agents.json")
	if current_agent:
		if current_agent in agents.keys():
#			prints(">>>",current_agent)
			is_agent = true
			loaded_agent = agent_settings.new(current_agent,agents,self)
			emit_signal("send_agent_info",loaded_agent)
			update_agent_bias()
		else:
			print("WARNING: Agent '",current_agent,"' does not exist in the agent resource file.")
	else:
		is_agent = false
		loaded_agent = agent_settings.new("",agents,self)
		emit_signal("send_agent_info",null)

	set_agent_panel(loaded_agent._agent_name)
	set_help_status()

func beginning_siren_msg():
	$siren.play()
	show_beggame_msg()

func set_agent_panel(agent):
	if agent != "no_agent":
		$agent_avatar.show()
		$agent_offline.hide()
	else:
		$agent_avatar.hide()
		$agent_offline.show()

func set_help_status():
	print("Setting agent help status...")
	print("loaded agent help status:",loaded_agent._visible_help_status)
	if loaded_agent._visible_help_status == false:
		$help_status.hide()
		return null
	print("carrying on...")
	if loaded_agent._agent_name == "no_agent":
		$help_status.hide()
	else:
		$help_status.show()
	if loaded_agent._targeting == true:
		$help_status/aiming/status.text = "ON"
		$help_status/aiming/status.set("custom_colors/font_color",Color( 0, 1, 0, 1 ))
	else:
		$help_status/aiming/status.text = "OFF"
		$help_status/aiming/status.set("custom_colors/font_color",Color( 0.75, 0.75, 0.75, 1 ))
	
	if current_scenario["_visual_aid"] != "":
		$help_status/visual_help/status.text = "ON"
		$help_status/visual_help/status.set("custom_colors/font_color",Color( 0, 1, 0, 1 ))
	else:
		$help_status/visual_help/status.text = "OFF"
		$help_status/visual_help/status.set("custom_colors/font_color",Color( 0.75, 0.75, 0.75, 1 ))

func update_timer(delta):
	if t > 0:
		var minutes = int(t) / 60
		var seconds = int(t) % 60
		if seconds < 10:
			seconds="0"+str(seconds)
		$upper_information/timer.show()
		$upper_information/timer.text = "Timer: "+str(int(minutes))+":"+str(seconds)
	else:
		$upper_information/timer.hide()

func clean_deleted_object_array(an_array):
	if an_array.empty() == false:
		var copy_array = an_array.duplicate()
		for v in copy_array:
			if str(v).begins_with("[Deleted Object]"):
				copy_array.erase(v)
		return copy_array
	else:
		return an_array

var t = -5 # keep track of the timer
var seen_t = [] # store already used timestamps
var loaded_agent = null
var is_agent = null # check if an agent was present during the last interaction or not
var cpt_spawn_missile = 9999

func enable_city_lights(light_status):
	for city in all_cities:
		if light_status == false:
			get_node(city+"/Light2D").enabled = false
		else:
			get_node(city+"/Light2D").enabled = true

func check_if_node_exist(name_to_search,node_to_search):
	for elem in node_to_search.get_children():
		if name_to_search == elem.name:
			return true
	return false

func quick_question():
	var is_quick_question = check_if_node_exist("quick_question",self)
	if is_quick_question == false:
		var instance_quick_ques = quick_question_scene.instance()
#		print(current_scenario._quick_questions)
		if str(current_scenario._current_wave_idx) in current_scenario._quick_questions:
			instance_quick_ques.question_category = \
			current_scenario._quick_questions[str(current_scenario._current_wave_idx)]
		add_child(instance_quick_ques)
		disable_controls()
		# below is a quick and dirty way to make sure nothing get on top of the questions
		if current_scenario["_obscuring_timing"]:
			manage_obscuring(current_scenario["_obscuring_timing"][1]+1,current_scenario["_obscuring_timing"])
		if current_scenario["_visual_aid_timing"]:
			manage_visual_aid(current_scenario["_visual_aid_timing"][1]+1,current_scenario["_visual_aid_timing"])

#func check_for_manually_selected_agent(current_agent):



func when_gameplay_begins():
	end_wave_triggered = false
	loading_agent(current_scenario._current_agent)
#	check_for_manually_selected_agent(selected_agent)
	emit_signal("beginning_wave")
	emit_signal("beginning_round")
	enable_city_lights(true)
	seen_t.append(int(t))
	current_scenario._controls_enabled = true
	current_scenario._game_pause = false
	if gamemode == "tutorial":
		follow_tutorial(current_scenario._current_round_nb)

var remaining_scheduled_event = []
func check_for_scheduled_events(t):
	if remaining_scheduled_event.empty():
		return 0
	var i = 0
	for event in remaining_scheduled_event:
		if int(t) == event["time"]:
			spawn_missile(event["target"],event["speed"],event["location"])
			remaining_scheduled_event.remove(i)
			prints("Remaining events:",len(remaining_scheduled_event),remaining_scheduled_event)
		i+=1

func follow_scenario(missile_interval,missile_speed,cpt_spawn,gamemode,timer):
	if cpt_spawn >= missile_interval:
		spawn_automated_missile(missile_speed,current_scenario._missile_at_once)
		cpt_spawn_missile = 0

func update_round_label(current,total):
	$upper_information/round_counter.text = "Round: "+str(current)+"/"+str(total)

func update_wave_label(current,total):
	if gamemode == "tutorial":
		$upper_information/wave_counter.text = "tutorial"
	else:
		$upper_information/wave_counter.text = "Wave: "+str(current)+"/"+str(total)

func check_for_active_missiles(active_missiles):
	active_missiles = clean_deleted_object_array(active_missiles)
	if active_missiles.empty() == true:
		return false
	else:
		return true

func update_agent_bias():
	if loaded_agent:
		loaded_agent.set_bias_intensity(current_scenario._current_wave_idx)

func next_step_scenario():
	prints("round:",current_scenario._current_round_nb,"/",current_scenario._round_limit)
	if current_scenario._current_wave_idx < current_scenario._wave_limit:
		current_scenario.next_wave()
		update_agent_bias()
		end_wave_triggered = false
		emit_signal("beginning_wave")
		reset_timers()
		enable_controls()
		set_obscuring(current_scenario["_obscuring_type"])
		set_visual_aid(current_scenario["_visual_aid"])
		set_scheduled_event(current_scenario._wave_scheduled_events)
		set_pause_event()
		clear_friendly()
	else:
		if current_scenario._current_round_nb >= current_scenario._round_limit:
			end_session_questionnaire()
		else:
			reset_var()
			reset_timers()
			enable_controls()
			start_next_round()

func set_scheduled_event(events):
	if events:
		remaining_scheduled_event = events

func update_cpt_spawn_missile(t,delta,limit):
	if t > 0:
		if int(t) in range(0,int(limit)):
			cpt_spawn_missile += delta

func disable_controls():
	if current_scenario:
		current_scenario._controls_enabled = false
	$crosshair.hide()

func enable_controls():
	if current_scenario:
		current_scenario._controls_enabled = true
	$crosshair.show()

onready var tutorial = preload("res://scenes/tutorial.tscn")
var tutorial_instance = null

func follow_tutorial(round_nb):
	print("Tutorial engaged")
	t=-99999
	if round_nb == 1:
		tutorial_instance = tutorial.instance()
		add_child(tutorial_instance)
	elif round_nb <= current_scenario._round_limit:
		if tutorial_instance:
			tutorial_instance.show()

func _process(delta):
#	t = 9999
	update()
	if current_scenario:
		t+=delta
		update_timer(t)
		if t < current_scenario._timelimit:
			update_cpt_spawn_missile(t,delta,current_scenario._timelimit)
			if int(t) == 0 and not int(t) in seen_t:
				when_gameplay_begins()
			elif t > 0:
				check_for_scheduled_events(t)
				check_for_temp_increase_missile(current_scenario._temp_spawn_increase,delta)
				follow_scenario(current_scenario._missile_interval,current_scenario._missile_speed,
					cpt_spawn_missile,gamemode,t)

				update_round_label(current_scenario._current_round_nb,current_scenario._round_limit)
				update_wave_label(current_scenario._current_wave_idx,current_scenario._wave_limit)
				manage_obscuring(t,current_scenario["_obscuring_timing"])
				manage_visual_aid(t,current_scenario["_visual_aid_timing"])
				manage_friendly(t,current_scenario["_friendly_timing"])
				manage_pause_event(t,current_scenario["_pause_timing"])

		elif end_wave_triggered == false:
			var is_active_missile = check_for_active_missiles(active_missiles)
			if is_active_missile == false:
				disable_controls()
				var is_requests_queue = check_for_http_requests()
				if is_requests_queue == false:
					delay_action(funcref(self,"quick_question"),1)
					end_wave_triggered = true

var end_wave_triggered = false
var sce_nb = 1
var beg_game = true # set a timer to postpone the beginning of a game
var wait_next_session = false

func check_for_http_requests():
	if logging_node.save_to_server == false:
		$ingame_logging_info.hide()
		return false
	elif logging_node.request_queue.empty() == false:
		logging_node.send_oldest_request()
		$ingame_logging_info/panel/content.text = "Remaining request(s): "+str(len(logging_node.request_queue))
		$ingame_logging_info.show()
		return true
	else:
		$ingame_logging_info.hide()
		return false

func reset_timers():
	seen_t = []
	t = 0
	cpt_spawn_missile = 9999
	cpt_temp_inc = 0

func reset_var():
	current_scenario.reset_round_counters()

func resume_game():
	current_scenario._game_pause = false

func _on_next_round_pressed():
	var question_type = determine_end_round_form()
	var slider_value = find_slider_end_round_form(question_type).value
	logging_node.log_single_item_rating(slider_value,$consent_form.active_log_path)
	question_type.hide() # hide the panel
	show_scoreboard()

func find_slider_end_round_form(end_round_panel):
	var sliders_names = ["difficulty_slider","shapley_slider"] # names of sliders in end round panels
	for child in end_round_panel.get_children():
		if(child.get_name() in sliders_names):
			return child

func determine_end_round_form():
	var question_type = $one_p_end_round_question
	if is_agent == true:
		question_type = $end_round_question
	return question_type

onready var scoreboard = preload("res://scenes/scoreboard.tscn")

func show_scoreboard():
	var instance_scoreboard = scoreboard.instance()
	add_child(instance_scoreboard)
	disable_controls()
	reset_smoke()

func reset_smoke():
	for v in array_smoke: # reset fx effect on cities
		v.queue_free()
	array_smoke = []

func start_next_round():
	if gamemode == "tutorial":
		t = 0
	else:
		$drum.play()
		show_beggame_msg()
		t = -5
	current_scenario.next_round()
	current_scenario.set_wave(1)
	emit_signal("beginning_round")

var delayed_function = null 

func delay_action(function,time):
	$delay_timer.set_wait_time(time)
	$delay_timer.set_one_shot(true) # no loop
	$delay_timer.start()
	delayed_function = function

func _on_delay_timer_timeout():
	delayed_function.call_func()

onready var questionnaire = preload("res://scenes/questionnaire.tscn")
var instance_quest # active instance of the end session questionnaire

func end_session_questionnaire():
	enable_city_lights(false)
	print("End session questionnaire activated")
	instance_quest = questionnaire.instance()
	
	if current_scenario._questionnaire and current_scenario._questionnaire.empty() == false:
		instance_quest.manual_form = current_scenario._questionnaire[current_scenario.cpt_questionnaire]
		current_scenario.cpt_questionnaire += 1
		add_child(instance_quest)
	else:
		show_scoreboard()
	disable_controls()

func show_beggame_msg():
	$beggame_msg.rect_scale = Vector2(0,0)
	$beggame_msg.show()
	var get_label_tween = $beggame_msg/show_msg
	get_label_tween.interpolate_property($beggame_msg, "rect_scale",
		Vector2(0,0), Vector2(0.5,0.5), 4,
		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT,0)
	$beggame_msg.show()
	get_label_tween.start()

func _on_show_msg_tween_completed(object, key):
	$beggame_msg.hide()

func show_end_game_panel():
	var get_end_link = parse_resource_file(path_folder+"end_study_link.json")
	$endgame/endgame_final_online/LineEdit.text = str(get_end_link["link"])
	$endgame/go_main_menu.grab_focus()
	var ordering_completed = check_if_ordering_completed()
	if ordering_completed == true:
		$endgame/endgame_final_online.show()
#		OS.shell_open($endgame/endgame_final_online/LinkButton.text)
		$endgame/endgame_text.hide()
		$endgame/endgame_header.hide()
		$endgame/go_main_menu.hide()
	else:
		$endgame/endgame_final_online.hide()
		$endgame/endgame_final.hide()
		$endgame/endgame_text.show()
		$endgame/go_main_menu.show()
	$endgame/go_main_menu.grab_focus()
	$upper_information/timer.hide()
	$endgame.show()

func _on_go_main_menu_pressed():
	back_to_main_menu()
var auto_idx
func check_if_ordering_completed():
	var participant_ordering = parse_resource_file(path_folder+ORDERING_FILE) # CHANGE TO SWITCH ORDERING FILES
	if ordering_mode == "manual":
		if id in participant_ordering["manual"].keys():
			var participant_usage = parse_resource_file($consent_form.active_log_path+id+"_usage.json")
			for session_to_play in participant_ordering["manual"][id]:
				if not session_to_play["session"] in participant_usage["gamemode_played"]:
					 return false
			return true
		else:
			return false
	elif ordering_mode == "automatic":
		var participant_usage = parse_resource_file($consent_form.active_log_path+id+"_usage.json")
		var auto_selection = participant_ordering[ordering_mode].keys()[auto_idx]
		var current_auto_session = participant_ordering["automatic"][auto_selection]
		print("Current auto selection:",current_auto_session)
		update_session_counter(len(participant_usage["gamemode_played"]),len(current_auto_session))
		for session_to_play in current_auto_session:
			prints("session to play:",session_to_play)
			if not session_to_play["session"] in participant_usage["gamemode_played"]:
				 return false
		return true
	elif ordering_mode == "manual_group_agent":
#		print("ENTERED check_if_ordering_completed")
		var participant_usage = parse_resource_file($consent_form.active_log_path+id+"_usage.json")
		var current_selection = participant_ordering[ordering_mode][selected_group]
#		selected_group
#		print("CURRENT USAGE:",participant_usage)
#		print("CURRENT SELECTION:",current_selection)
		for session_to_play in current_selection:
#			prints("session to play:",session_to_play)
			if not session_to_play["session"] in participant_usage["gamemode_played"]:
				 return false
		return true
		
#		update_session_counter(len(participant_usage["gamemode_played"]),len(current_auto_session))
#		selected_agent
#		var current_auto_session = participant_ordering["manual_group_agent"][auto_selection]
#		print("Current auto selection:",current_auto_session)
#		update_session_counter(len(participant_usage["gamemode_played"]),len(current_auto_session))
#		for session_to_play in current_auto_session:
#			prints("session to play:",session_to_play)
#			if not session_to_play["session"] in participant_usage["gamemode_played"]:
#				 return false
#		return true
	

func update_session_counter(current,total):
	$upper_information/session_counter.show()
	$upper_information/session_counter.text = "SESSION: "+str(current)+"/"+str(total)

func count_folder(path):
#	print("COUNT FOLDER:",path)
	var dir = Directory.new()
	var cpt_dir = 0
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir() == true:
			if not file.begins_with("."):
				cpt_dir+=1
	dir.list_dir_end()
#	print("folders:",cpt_dir)
	return cpt_dir

func _on_shot_fired():
	if current_scenario:
		current_scenario.shot_fired()

var SERVER_FOLDER_COUNT = null

func get_server_folder_count():
	print("Getting folder count from server...")
	var folder_request = HTTPRequest.new()
	add_child(folder_request)
	folder_request.connect("request_completed", self, "_on_folder_request_completed")
	folder_request.request("https://devweb3000.cis.strath.ac.uk/~xpb17212/count_folder.php")


	
func get_local_folder_count():
	print("Getting folder count from local logs folder...")
	SERVER_FOLDER_COUNT = count_folder($consent_form.path_logs)
	print("local count:",SERVER_FOLDER_COUNT)

func _on_folder_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error!= OK:
		prints("Couldn't read the result, error:",json.error,json.get_error_string())
		prints("result:",result,"response_code:",response_code,"headers:",headers,"body:",body)
	else:
		prints("Server folder count:",json.result)
		SERVER_FOLDER_COUNT = int(json.result)
		end_folder_count_process()

func start_folder_count_process():
	print("contacting servers for folder count and setting waiting panel...")
	$wait_panel.show()
	
	if logging_node.save_to_server == false:
		end_folder_count_process()
		get_local_folder_count()
	else:
		get_server_folder_count()

func end_folder_count_process():
	print("hiding waiting panel...")
	$wait_panel.hide()
	prints("initiating log path:",$consent_form.active_log_path)
	logging_node.log_consent($consent_form.active_log_path)
	logging_node.send_oldest_request()
	show_main_menu()

func _on_LinkButton_pressed():
	OS.shell_open(str($endgame/endgame_final_online/LineEdit.text))

func _on_custom_list_item_selected(index):
	var selection = $main_menu/custom_list.get_item_text(index)
	print("SELECTED FROM LIST:",$main_menu/custom_list.get_item_text(index))
	_on_gamemode_pressed(selection)









