extends Control

onready var misc_methods = load("res://scripts/misc.gd").new()
onready var root_node_path = "/root/Node2D"
onready var main_node = get_node(root_node_path)
onready var consent_node = get_node(root_node_path+"/consent_form")
onready var crosshair_node = get_node(root_node_path+'/crosshair/')
onready var control_focus_status = get_node(root_node_path+"/focus_status")
onready var cross_user_ctrl = get_node(root_node_path+"/crosshair/crosshair_user/control_user").get_name()
onready var cross_agent_ctrl = get_node(root_node_path+"/crosshair/crosshair_agent/control_agent").get_name()
#onready var question_node = get_node(root_node_path+"/end_round_question/question")

var logging_delay = 0.25
var cpt_delay = 0
var id

var save_to_server = true
var server_url = "https://devweb3000.cis.strath.ac.uk/~xpb17212/godot_communication.php"
# "sftp://cafe.cis.strath.ac.uk/"

func _on_id_received(an_id):
	id = an_id

var log_dict = {}
var agent_info_already_written = false

func _process(delta):
#	print("Remaining requests:",len(request_queue))
	cpt_delay+=delta
	if main_node.current_scenario:
		log_dict["Timestamp"] = main_node.t
		log_dict["ID"] = id
		log_dict["Gamemode"] = main_node.gamemode
		log_dict["Round"] = main_node.current_scenario._current_round_nb
		log_dict["Wave"] = main_node.current_scenario._current_wave_idx
		log_dict["Missile Spawned"] = main_node.current_scenario._missile_spawned
		log_dict["Threat Missile Spawned"] = main_node.current_scenario._threat_missile_spawned
		log_dict["Non Threat Missile Spawned"] = main_node.current_scenario._non_threat_missile_spawned
		log_dict["Active Missile"] = len(main_node.active_missiles)
		log_dict["Missile Destroyed"] = main_node.current_scenario._missile_destroyed
		log_dict["Threat Missile Destroyed"] = main_node.current_scenario._threat_missile_destroyed
		log_dict["Non Threat Missile Destroyed"] = main_node.current_scenario._non_threat_missile_destroyed
		log_dict["Shot Fired"] = main_node.current_scenario._shot_fired
		log_dict["City Hit"] = main_node.current_scenario._number_city_hit
		log_dict["City 1 Hit"] = main_node.current_scenario._number_city_hit_1
		log_dict["City 2 Hit"] = main_node.current_scenario._number_city_hit_2
		log_dict["City 3 Hit"] = main_node.current_scenario._number_city_hit_3
		log_dict["City 4 Hit"] = main_node.current_scenario._number_city_hit_4
		log_dict["Friendly Spawned"] = main_node.current_scenario._friendly_spawned
		log_dict["Friendly Destroyed"] = main_node.current_scenario._friendly_destroyed
		log_dict["Hidden Missile Hit"] = main_node.current_scenario._hidden_missiles_hit
		
		log_dict["TP Spawned"] = main_node.current_scenario._tp_spawned
		log_dict["FP Spawned"] = main_node.current_scenario._fp_spawned
		log_dict["FN Spawned"] = main_node.current_scenario._fn_spawned
		log_dict["TN Spawned"] = main_node.current_scenario._tn_spawned

		log_dict["TP Destroyed"] = main_node.current_scenario._tp_destroyed
		log_dict["FP Destroyed"] = main_node.current_scenario._fp_destroyed
		log_dict["FN Destroyed"] = main_node.current_scenario._fn_destroyed
		log_dict["TN Destroyed"] = main_node.current_scenario._tn_destroyed
		
		###

		log_dict["Wave Missile Spawned"] = main_node.current_scenario._wave_missile_spawned
		log_dict["Wave Threat Missile Spawned"] = main_node.current_scenario._wave_threat_missile_spawned
		log_dict["Wave Non Threat Missile Spawned"] = main_node.current_scenario._wave_non_threat_missile_spawned
		log_dict["Wave Missile Destroyed"] = main_node.current_scenario._wave_missile_destroyed
		log_dict["Wave Threat Missile Destroyed"] = main_node.current_scenario._wave_threat_missile_destroyed
		log_dict["Wave Non Threat Missile Destroyed"] = main_node.current_scenario._wave_non_threat_missile_destroyed
		log_dict["Wave Shot Fired"] = main_node.current_scenario._wave_shot_fired
		log_dict["Wave City Hit"] = main_node.current_scenario._wave_number_city_hit
		log_dict["Wave City 1 Hit"] = main_node.current_scenario._wave_number_city_hit_1
		log_dict["Wave City 2 Hit"] = main_node.current_scenario._wave_number_city_hit_2
		log_dict["Wave City 3 Hit"] = main_node.current_scenario._wave_number_city_hit_3
		log_dict["Wave City 4 Hit"] = main_node.current_scenario._wave_number_city_hit_4
		log_dict["Wave Friendly Spawned"] = main_node.current_scenario._wave_friendly_spawned
		log_dict["Wave Friendly Destroyed"] = main_node.current_scenario._wave_friendly_destroyed
		log_dict["Wave Hidden Missile Hit"] = main_node.current_scenario._wave_hidden_missiles_hit
		log_dict["Current Hidden Missile"] = len(main_node.current_scenario._hidden_missiles)
		
		log_dict["Wave TP Spawned"] = main_node.current_scenario._wave_tp_spawned
		log_dict["Wave FP Spawned"] = main_node.current_scenario._wave_fp_spawned
		log_dict["Wave FN Spawned"] = main_node.current_scenario._wave_fn_spawned
		log_dict["Wave TN Spawned"] = main_node.current_scenario._wave_tn_spawned

		log_dict["Wave TP Destroyed"] = main_node.current_scenario._wave_tp_destroyed
		log_dict["Wave FP Destroyed"] = main_node.current_scenario._wave_fp_destroyed
		log_dict["Wave FN Destroyed"] = main_node.current_scenario._wave_fn_destroyed
		log_dict["Wave TN Destroyed"] = main_node.current_scenario._wave_tn_destroyed
		
		if main_node.current_scenario._obscuring_type:
			log_dict["Obscuring Type"] = main_node.current_scenario._obscuring_type
			log_dict["Obscuring Timing Start"] = main_node.current_scenario._obscuring_timing[0]
			log_dict["Obscuring Timing End"] = main_node.current_scenario._obscuring_timing[1]
			log_dict["Obscuring Status"] = main_node.current_scenario._obscuring_activated

		else:
			log_dict["Obscuring Type"] = ""
			log_dict["Obscuring Timing Start"] = ""
			log_dict["Obscuring Timing End"] = ""
			log_dict["Obscuring Status"] = ""
			
		if main_node.current_scenario._visual_aid:
			log_dict["Visual Aid Type"] = main_node.current_scenario._visual_aid
			log_dict["Visual Aid Timing Start"] = main_node.current_scenario._visual_aid_timing[0]
			log_dict["Visual Aid Timing End"] = main_node.current_scenario._visual_aid_timing[1]
			log_dict["Visual Aid Status"] = main_node.current_scenario._visual_aid_status
		
		else:
			log_dict["Visual Aid Type"] = ""
			log_dict["Visual Aid Timing Start"] = ""
			log_dict["Visual Aid Timing End"] = ""
			log_dict["Visual Aid Status"] = ""
		
		log_dict["Precision"] = add_precision(main_node.current_scenario._missile_destroyed,
		main_node.current_scenario._shot_fired)
		log_dict["Recall"] = add_recall(main_node.current_scenario._missile_destroyed,
		main_node.current_scenario._missile_spawned)
		log_dict["F1"] = add_f1(log_dict["Precision"],log_dict["Recall"])
		
		log_dict["Wave Precision"] = add_precision(main_node.current_scenario._wave_missile_destroyed,
		main_node.current_scenario._wave_shot_fired)
		log_dict["Wave Recall"] = add_recall(main_node.current_scenario._wave_missile_destroyed,
		main_node.current_scenario._wave_missile_spawned )
		log_dict["Wave F1"] = add_f1(log_dict["Wave Precision"],log_dict["Wave Recall"])
		
		log_dict["Owner Switch"] = crosshair_node.cpt_owner_switch
		log_dict["User Switch"] = crosshair_node.cpt_user_switch
		
		log_dict["Owner Switch"] = crosshair_node.wave_cpt_owner_switch
		log_dict["User Switch"] = crosshair_node.wave_cpt_user_switch
		
		log_dict["Crosshair X Position"] = crosshair_node.global_position.x
		log_dict["Crosshair Y Position"] = crosshair_node.global_position.y
		
		log_dict["Viewport X Size"] = get_viewport().size.x
		log_dict["Viewport Y Size"] = get_viewport().size.y
		
		log_dict["FPS"] = Engine.get_frames_per_second()

		if control_focus_status.get_focus_owner() != null:
			log_dict["Crosshair Owner"] = control_focus_status.get_focus_owner().get_name()
		else:
			log_dict["Crosshair Owner"] = "null"

		if cross_user_ctrl in crosshair_node.ctrl_time_dict:
			log_dict["User Control Time"] = crosshair_node.ctrl_time_dict[cross_user_ctrl]
			log_dict["User Distance Travelled"] = crosshair_node.ctrl_time_dict[cross_user_ctrl]*crosshair_node.speed
			log_dict["Wave User Control Time"] = crosshair_node.wave_ctrl_time_dict[cross_user_ctrl]
			log_dict["Wave User Distance Travelled"] = crosshair_node.wave_ctrl_time_dict[cross_user_ctrl]*crosshair_node.speed
		else:
			log_dict["User Control Time"] = ""
			log_dict["User Distance Travelled"] = ""
			log_dict["Wave User Control Time"] = ""
			log_dict["Wave User Distance Travelled"] = ""

		if cross_user_ctrl in crosshair_node.continuous_ctrl_time:
			log_dict["Continuous User Control Time"] = crosshair_node.wave_continuous_ctrl_time[cross_user_ctrl]
			log_dict["Wave Continuous User Control Time"] = crosshair_node.wave_continuous_ctrl_time[cross_user_ctrl]
		
		if cross_user_ctrl in crosshair_node.reliance_scores:
			log_dict["User Reliance Score"] = crosshair_node.wave_reliance_scores[cross_user_ctrl]
			log_dict["Wave User Reliance Score"] = crosshair_node.wave_reliance_scores[cross_user_ctrl]

		if main_node.loaded_agent:
			log_dict["Agent"] = main_node.loaded_agent._agent_name
			if log_dict["Agent"] == "":
				log_dict["Agent"] = "no_agent"
			
			log_dict["Bias Type"] = main_node.loaded_agent._bias_type
			log_dict["Bias Intensity"] = main_node.loaded_agent._bias_intensity
			
			log_dict["Wave Agent Calls"] = crosshair_node.wave_agent_calls
			log_dict["Agent Calls"] = crosshair_node.agent_calls

			if main_node.loaded_agent._behaviour:
				log_dict["Behaviour Type"] = main_node.loaded_agent._behaviour["type"]
				log_dict["Active Behaviour"] = main_node.loaded_agent._active_agent_behaviour
				
				#if main_node.loaded_agent._behaviour_timing.empty() == false:
				if main_node.loaded_agent._behaviour_timing:
					log_dict["Behaviour Timing Start"] = str(main_node.loaded_agent._behaviour_timing[0])
					log_dict["Behaviour Timing End"] = str(main_node.loaded_agent._behaviour_timing[1])
				else:
					log_dict["Behaviour Timing Start"] = ""
					log_dict["Behaviour Timing End"] = ""
			else:
				log_dict["Behaviour Type"] = ""
				log_dict["Active Behaviour"] = ""
			if cross_agent_ctrl in crosshair_node.ctrl_time_dict:
				log_dict["Agent Control Time"] = crosshair_node.ctrl_time_dict[cross_agent_ctrl] 
				log_dict["Agent Distance Travelled"] = crosshair_node.ctrl_time_dict[cross_agent_ctrl] * crosshair_node.speed
				log_dict["Wave Agent Control Time"] = crosshair_node.wave_ctrl_time_dict[cross_agent_ctrl]
				log_dict["Wave Agent Distance Travelled"] = crosshair_node.wave_ctrl_time_dict[cross_agent_ctrl] * crosshair_node.speed
				
			else:
				log_dict["Agent Control Time"] = ""
				log_dict["Agent Distance Travelled"] = ""
				log_dict["Wave Agent Control Time"] = ""
				log_dict["Wave Agent Distance Travelled"] = ""
		
			if cross_agent_ctrl in crosshair_node.continuous_ctrl_time:
				log_dict["Continuous Agent Control Time"] = crosshair_node.continuous_ctrl_time[cross_agent_ctrl]
				log_dict["Wave Continuous Agent Control Time"] = crosshair_node.wave_continuous_ctrl_time[cross_agent_ctrl]
			else:
				log_dict["Continuous Agent Control Time"] = ""
				log_dict["Wave Continuous Agent Control Time"] = ""

			if cross_agent_ctrl in crosshair_node.reliance_scores:
				log_dict["Agent Reliance Score"] = crosshair_node.reliance_scores[cross_agent_ctrl]
				log_dict["Wave Agent Reliance Score"] = crosshair_node.wave_reliance_scores[cross_agent_ctrl]
			else:
				log_dict["Agent Reliance Score"] = ""
				log_dict["Wave Agent Reliance Score"] = ""

		else:
			log_dict["Agent"] = "no_agent"

		if $CheckButton.pressed == true and main_node.current_scenario._controls_enabled == true and \
		main_node.t > 0:
			if agent_info_already_written == false:
				agent_info_already_written = true
				write_full_log_header()
			
			if cpt_delay >= logging_delay:
				cpt_delay = 0
				logging_process(log_dict,consent_node.active_log_path)
				send_oldest_request()

var file = File.new()
func logging_process(a_dict,a_path):
	var to_store = ""
	var full_path = a_path+id+"_general_logs.csv"
	if not file.file_exists(full_path):
		print("creating general log file...")
		file.open(full_path, file.WRITE)
		for k in a_dict.keys():
#			file.store_string(str(k)+",")
			to_store+=str(k)+","
		to_store+="\n"
#		file.store_string("\n")
	else:
		file.open(full_path, file.READ_WRITE)
		file.seek_end()
	
	
	for v in a_dict.values():
		to_store+=str(v)+","
#		file.store_string(str(v)+",")
	to_store+="\n"
	file.store_string(to_store)
	file.close()
	create_request(save_to_server,id+"/"+id+"_general_logs.csv",to_store)
#	if save_to_server == true:
#		var server_log_path = id+"/"+id+"_general_logs.csv"
#		add_request_queue({"url":server_url,"header":["ContentType: logs/json","Path:"+server_log_path],
#		"query":to_store,"ssl":true})
#		print(request_queue)
#		send_oldest_request()

	
func write_full_log_header():
	if file.is_open():
		print("rewriting header...")
		file.seek(0) # rewrite header to make sure every label is written
		for k in log_dict.keys():
			file.store_string(str(k)+",")
		file.store_string("\n")
		file.seek_end(0) # see it that does not poses problems
	


var quest_file = File.new()
var quest_file_info = ["Timestamp","ID","Gamemode","Wave","Round","Agent","Obscuring Type","Visual Aid Type","Single Question","Rating","Time Triggered","Time Answered"]

func log_single_item_rating(question,rating,t_triggered,t_answered,a_path,timing="END"):
	write_full_log_header()
	var full_path = a_path+id+"_question_logs.csv"
	var to_store =""
	if not file.file_exists(full_path):
		print("creating single item rating log file")
		quest_file.open(full_path, quest_file.WRITE)
		for v in quest_file_info:
#			quest_file.store_string(str(v)+",")
			to_store+=str(v)+","
#		quest_file.store_string("\n")
		to_store+="\n"
	else:
		quest_file.open(full_path, quest_file.READ_WRITE)
		quest_file.seek_end()
	for v in quest_file_info:		
		if v in log_dict:
			if v == "Agent" and log_dict[v] == "":
#				quest_file.store_string("no_agent,")
				to_store+="no_agent,"
			elif v == "Obscuring Type" and log_dict[v] == "":
				to_store+= "none,"
			elif v == "Visual Aid Type" and log_dict[v] =="":
				to_store+="none,"
			else:
#				quest_file.store_string(str(log_dict[v])+",")
				to_store+=str(log_dict[v])+","
			
			
			
		elif v == "Single Question":
#			quest_file.store_string(str(question)+",")
			to_store+=str(question)+","
		elif v == "Rating":
#			quest_file.store_string(str(rating)+",")
			to_store+=str(rating)+","
		elif v == "Time Triggered":
#			quest_file.store_string(str(t_triggered)+",")
			to_store+=str(t_triggered)+","
		elif v == "Time Answered":
#			quest_file.store_string(str(t_answered)+",")
			to_store+=str(t_answered)+","
	to_store+="\n"
#	quest_file.store_string("\n")
	quest_file.store_string(to_store)
	quest_file.close()
	create_request(save_to_server,id+"/"+id+"_question_logs.csv",to_store)
	send_oldest_request()
#	if save_to_server == true:
#		var server_log_path = id+"/"+id+"_question_logs.csv"
#		add_request_queue({"url":server_url,"header":["ContentType: logs/json","Path:"+server_log_path],
#		"query":to_store,"ssl":true})

var pause_file = File.new()
func log_pause_question_answer(question,answer_top,answer_bottom,total,completion_time,missile_loc):
	prints("PAUSE INFO RECEIVED, GOT:",question,answer_top,answer_bottom,total,completion_time)
	var full_path = consent_node.active_log_path+id+"_pause_question_logs.csv"
	var to_store =""
	var general_to_save = ["Timestamp","ID","Gamemode","Wave","Round","Agent","Obscuring Type",
	"Current Hidden Missile","Active Missile"]
	prints("path:",full_path)
	if not file.file_exists(full_path):
		print("creating pause answer log file")
		pause_file.open(full_path, pause_file.WRITE)
		for v in general_to_save:
			to_store+=str(v)+","
		to_store+="Pause Question,Answer Top,Answer Bottom,Total,Completion Time,Missile Top,Missile Bottom"
		to_store+="\n"
	else:
		pause_file.open(full_path, pause_file.READ_WRITE)
		pause_file.seek_end()
	for v in general_to_save:
		print(log_dict[v])
		to_store+=str(log_dict[v])+","
	var specific_to_save = [question,answer_top,answer_bottom,total,completion_time]
	for v in specific_to_save:
		to_store+=str(v)+","
#	for k in missile_loc:
#		to_store+=str(missile_loc[k])
	to_store+=str(missile_loc["top"])+","
	to_store+=str(missile_loc["bottom"])
	to_store+="\n"
	prints("STORING:",to_store)
	pause_file.store_string(to_store)
	pause_file.close()
	create_request(save_to_server,id+"/"+id+"_pause_question_logs.csv",to_store)
	send_oldest_request()

var missile_hit_file = File.new()
func on_missile_hit_logging(missile_id,missile_pos,optimal_ordering,eta_ordering,recency_ordering,obscuring,threat,target_type):
#	print("logging hit...")
	var full_path = consent_node.active_log_path+id+"_missile_hit_details.csv"
	var to_store =""
	var general_to_save = ["Timestamp","ID","Gamemode","Round","Wave","Agent","Obscuring Type","Visual Aid Type"]
#	prints("path:",full_path)
	if not file.file_exists(full_path):
#		print("creating missile hit detail log file")
		missile_hit_file.open(full_path, missile_hit_file.WRITE)
		for v in general_to_save:
			to_store+=str(v)+","
		to_store += "Missile ID,Missile Position X,Missile Position Y,"
		to_store += "Optimal Ordering Rank,ETA Ordering Rank,Recency Ordering Rank,"
		to_store += "Missile Obscured,Missile Threat,Target Type\n"
	else:
		missile_hit_file.open(full_path, missile_hit_file.READ_WRITE)
		missile_hit_file.seek_end()
	for v in general_to_save:
#		print(log_dict[v])
		to_store+=str(log_dict[v])+","
	var specific_to_save = [missile_id,missile_pos.x,missile_pos.y,
	optimal_ordering,eta_ordering,recency_ordering,obscuring,threat,target_type]
	for v in specific_to_save:
		to_store+=str(v)+","
	to_store+="\n"
#	prints("STORING:",to_store)
	missile_hit_file.store_string(to_store)
	missile_hit_file.close()
	create_request(save_to_server,id+"/"+id+"_missile_hit_details.csv",to_store)
	send_oldest_request()
#	prints("HIT DETECTED - CAN LOG THINGS",missile_id)
	
#var pause_file = File.new()
#func log_pause_question_answer(question,answer_top,answer_bottom,total,completion_time,missile_loc):
#	prints("PAUSE INFO RECEIVED, GOT:",question,answer_top,answer_bottom,total,completion_time)
#	var full_path = consent_node.active_log_path+id+"_pause_question_logs.csv"
#	var to_store =""
#	var general_to_save = ["Timestamp","ID","Gamemode","Wave","Round","Agent","Obscuring Type",
#	"Current Hidden Missile","Active Missile"]
#	prints("path:",full_path)
#	if not file.file_exists(full_path):
#		print("creating pause answer log file")
#		pause_file.open(full_path, pause_file.WRITE)
#		for v in general_to_save:
#			to_store+=str(v)+","
#		to_store+="Pause Question,Answer Top,Answer Bottom,Total,Completion Time,Missile Top,Missile Bottom"
#		to_store+="\n"
#	else:
#		pause_file.open(full_path, pause_file.READ_WRITE)
#		pause_file.seek_end()
#	for v in general_to_save:
#		print(log_dict[v])
#		to_store+=str(log_dict[v])+","
#	var specific_to_save = [question,answer_top,answer_bottom,total,completion_time]
#	for v in specific_to_save:
#		to_store+=str(v)+","
##	for k in missile_loc:
##		to_store+=str(missile_loc[k])
#	to_store+=str(missile_loc["top"])+","
#	to_store+=str(missile_loc["bottom"])
#	to_store+="\n"
#	prints("STORING:",to_store)
#	pause_file.store_string(to_store)
#	pause_file.close()
#	create_request(save_to_server,id+"/"+id+"_pause_question_logs.csv",to_store)
#	send_oldest_request()




func _on_questionnaire_received(results):
	var to_store = ""
	var basic_info = ["ID","Agent"]
	var questionnaire_log = File.new()
	var questionnaire_path = consent_node.active_log_path+id+"_questionnaire.csv"
	if questionnaire_log.file_exists(questionnaire_path) == true:
		print("questionnaire already exist")
		questionnaire_log.open(questionnaire_path, questionnaire_log.READ_WRITE)
		questionnaire_log.seek_end(0)
	else:
		questionnaire_log.open(questionnaire_path, questionnaire_log.WRITE)
		for v in basic_info:
#			questionnaire_log.store_string(v+",")
			to_store+=v+","
#		questionnaire_log.store_string("Question,Rating\n")
		to_store+="Question,Rating\n"
	var regex = RegEx.new()
	regex.compile('^\\d+')
	for k in results:
		for v in basic_info:
			if v in log_dict:
#				questionnaire_log.store_string(str(log_dict[v])+",")chro
				to_store+=str(log_dict[v])+","
		var question = misc_methods.sanitize_str(str(k))
#		questionnaire_log.store_string(question+","+str(results[k])+"\n")
		to_store+=question+","+str(results[k])+"\n"
	questionnaire_log.store_string(to_store)
	create_request(save_to_server,id+"/"+id+"_questionnaire.csv",to_store)
	send_oldest_request()
#	if save_to_server == true:
#		var server_log_path = id+"/"+id+"_questionnaire.csv"
#		add_request_queue({"url":server_url,"header":["ContentType: logs/json","Path:"+server_log_path],
#		"query":to_store,"ssl":true})

func get_current_date():
	var current_date = ""
	var full_date = OS.get_datetime()
	for v in ["year","month","day","hour","minute","second"]:
		current_date += str(full_date[v])
		if not v == "second":
			current_date += "-"
	return current_date

func initiate_log_folder(entered_id,path_logs):
	var current_log_name=""
	var dir = Directory.new()
	var cpt_dir = 0
	dir.open(path_logs)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir() == true:
			if not file.begins_with("."):
				cpt_dir+=1
	dir.list_dir_end()
	if entered_id == "":
		id = get_current_date()
#		id = "DEFAULT_"+str(cpt_dir+1)
#	elif entered_id == "UNIQUE_ID":
	else:
		id = entered_id
	consent_node.emit_signal("send_id",id)
	#####
	
	
	
	#####	
	var full_path = path_logs+"/"+id+"/"
	dir = Directory.new()
	if not dir.dir_exists(full_path):
		dir.make_dir(full_path)
	var file = File.new() 
	file.open(full_path+"/.gdignore",file.WRITE) # add gdignore file
	file.close()
	return full_path

func log_consent(path):
	print("logging consent...")
	var consent_file = id + "_consent.csv"
	var file = File.new()
	var consent_file_path = path+consent_file
	
	var to_store = "ID,Full Statement,Short Statement,Consent\n"
	to_store += id+","+misc_methods.sanitize_str(get_node(root_node_path+"/consent_form/content").text)+","
	to_store += misc_methods.sanitize_str(get_node(root_node_path+"/consent_form/statement").text)+","
	to_store += "ACCEPT\n"
	file.open(consent_file_path, file.WRITE)
	file.store_string(to_store)
#	file.store_string("ID,Full Statement,Short Statement,Consent\n")
#	file.store_string(id+","+misc_methods.sanitize_str(get_node(root_node_path+"/consent_form/content").text)+",")
#	file.store_string(misc_methods.sanitize_str(get_node(root_node_path+"/consent_form/statement").text)+",")
#	file.store_string("ACCEPT\n")
	file.close()
	create_request(save_to_server,id+"/"+consent_file,to_store)
#	if save_to_server == true:
##		pass # to complete!
#		var server_log_path = id+"/"+consent_file
#		add_request_queue({"url":server_url,"header":["ContentType: logs/json","Path:"+server_log_path],
#		"query":to_store,"ssl":true})
#	send_oldest_request()

func log_usage(gamemode):
	print("logging usage...")
	var json_usage_template = '{"id":"","gamemode_played":[]}'
	var usage_json
	var usage_log = File.new()
#	prints(consent_node.active_log_path,id)
	var usage_file_path = consent_node.active_log_path+id+"_usage.json"
	if usage_log.file_exists(usage_file_path) == false:
		usage_log.open(usage_file_path, usage_log.WRITE)
		usage_log.store_string(json_usage_template)
		usage_log.close()
	usage_log.open(usage_file_path, usage_log.READ_WRITE)
	usage_json = JSON.parse(usage_log.get_as_text())
	usage_json.result["id"]=id
	usage_json.result["gamemode_played"].append(gamemode)
	usage_log.store_string(JSON.print(usage_json.result,"",true))
	usage_log.close()

### server side ###

#var server_url = "https://devweb3000.cis.strath.ac.uk/~xpb17212/godot_communication.php"
#	add_request_queue({"url":an_url,"header":["ContentType: logs/json","Path: TEST_ID/test3.txt"],
#	"query":"4a,b,c,d,e\n","ssl":true})
	
#	send_oldest_request()


#onready var http_request = HTTPRequest.new()
var request_queue = []
var requests_open = true
#func _ready():
#	http_request.connect("timeout", self, "_on_Timer_timeout")

func create_request(create,a_path,query):
	if create == true:
#		var server_log_path = id+"/"+id+"_question_logs.csv"
		add_request_queue({"url":server_url,"header":["Path: "+a_path],
		"query":query,"ssl":true})
#		add_request_queue({"url":server_url,"header":["ContentType: logs/json","Path:"+a_path],
#		"query":query,"ssl":true})

func add_request_queue(param_dict):
	request_queue.append(param_dict)

func send_oldest_request():
	if request_queue.empty() == false:
		var to_send = request_queue[0]
		make_post_request(to_send["url"],to_send["header"],to_send["query"],to_send["ssl"])
#		prints(to_send["url"],to_send["header"],to_send["query"],to_send["ssl"])

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		requests_open = true
#		prints("REMOVING",request_queue[0])
		request_queue.remove(0)
#		if request_queue.empty() == false:
		send_oldest_request()

func make_post_request(url,headers,query, use_ssl):
#	prints("Headers:",headers)
#	prints("Query:",query)
	if requests_open == true:
		$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
		requests_open = false
#	print("sending request...")
#	print(url, headers, query,use_ssl)

func add_precision(tp,tp_fp):
	if tp != 0 and tp_fp != 0: 
		return float(tp)/float(tp_fp)
	return 0

func add_recall(tp,tp_fn):
	if tp != 0 and tp_fn !=0:
		return float(tp)/float(tp_fn)
	return 0
	
func add_f1(prec,recall):
	if prec != 0 or recall != 0:
		return 2*((prec*recall)/(prec+recall))
	return 0

#result_df["Wave Precision"] = result_df["Wave Missile Destroyed"]/result_df["Wave Shot Fired"]
#result_df["Wave Recall"] = result_df["Wave Missile Destroyed"]/result_df["Wave Missile Spawned"]
#result_df["Wave F1"] = 2*((result_df["Wave Precision"]*result_df["Wave Recall"])/(result_df["Wave Precision"]+result_df["Wave Recall"]))

