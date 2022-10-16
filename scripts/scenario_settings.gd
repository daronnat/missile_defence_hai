extends Node

var main_node

var _gamemode
var _scenarios
var _current_scenario
var _current_round
var _current_round_idx = 0
var _current_round_nb = 0
var _wave_scheduled_events
var _round_limit
var _timelimit
var _wave_settings
var _randomise_waves

var _missile_spawned = 0
var _wave_missile_spawned = 0
var _missile_destroyed = 0
var _wave_missile_destroyed = 0

var _threat_missile_spawned = 0
var _wave_threat_missile_spawned = 0
var _non_threat_missile_spawned = 0 
var _wave_non_threat_missile_spawned = 0

var _threat_missile_destroyed = 0
var _wave_threat_missile_destroyed = 0
var _non_threat_missile_destroyed = 0
var _wave_non_threat_missile_destroyed = 0

var _tp_spawned = 0
var _fp_spawned = 0
var _fn_spawned = 0
var _tn_spawned = 0

var _tp_destroyed = 0
var _fp_destroyed = 0
var _fn_destroyed = 0
var _tn_destroyed = 0

var _wave_tp_spawned = 0
var _wave_fp_spawned = 0
var _wave_fn_spawned = 0
var _wave_tn_spawned = 0

var _wave_tp_destroyed = 0
var _wave_fp_destroyed = 0
var _wave_fn_destroyed = 0
var _wave_tn_destroyed = 0

var _friendly_spawned = 0
var _wave_friendly_spawned = 0
var _friendly_destroyed = 0
var _wave_friendly_destroyed = 0
var _shot_fired = 0
var _user_distance_travelled = 0
var _missile_interval
var _missile_speed
var _current_agent
var _missile_at_once
var _current_wave_idx = 0
var _wave_limit
var _wave_shot_fired = 0

var _activation_delay = 0.5
var _game_pause = false
var _controls_enabled = false
var _temp_spawn_increase
var _complementary_questionnaire = false
var _ammo
var _pause_timing
var _autoplay
#var _questionnaire_limit = null
var cpt_questionnaire = 0
var _questionnaire = false

var _number_city_hit = 0 # total
var _wave_number_city_hit = 0 # total

var _number_city_hit_1 = 0
var _wave_number_city_hit_1 = 0
var _number_city_hit_2 = 0
var _wave_number_city_hit_2 = 0
var _number_city_hit_3 = 0
var _wave_number_city_hit_3 = 0
var _number_city_hit_4 = 0
var _wave_number_city_hit_4 = 0



var _quick_questions = null

var _obscuring_type
var _obscuring_timing
var _obscuring_activated
var _obscuring_position

var _friendly_timing

var _hidden_missiles = []
var _hidden_missiles_hit = 0
var _wave_hidden_missiles_hit = 0

var _cover_story

var _visual_aid
var _visual_aid_timing
var _visual_aid_activated
var _visual_aid_status

var _non_threat_missiles

func _init(param1,param2,calling_node):
	main_node = calling_node
	self._gamemode = param1
	self._scenarios = param2
	set_scenario()

func set_wave_difficulty():
	if self._wave_settings and str(self._current_wave_idx) in self._wave_settings.keys():
		self._missile_interval = self._wave_settings[str(self._current_wave_idx)]["missile_interval"]
		self._missile_speed = self._wave_settings[str(self._current_wave_idx)]["missile_speed"]
		self._obscuring_type = self._wave_settings[str(self._current_wave_idx)]["obscuring"]
		self._obscuring_timing = self._wave_settings[str(self._current_wave_idx)]["obscuring_timing"]
		self._pause_timing = self._wave_settings[str(self._current_wave_idx)]["pause_timing"]
		self._friendly_timing = self._wave_settings[str(self._current_wave_idx)]["friendly_timing"]
		self._visual_aid = self._wave_settings[str(self._current_wave_idx)]["visual_aid"]
		self._visual_aid_timing = self._wave_settings[str(self._current_wave_idx)]["visual_aid_timing"]
		self._non_threat_missiles = self._wave_settings[str(self._current_wave_idx)]["non_threat_missiles"]
		self._wave_scheduled_events = self._wave_settings[str(self._current_wave_idx)]["scheduled"]
#		print("prout")
	else:
		pass

func set_scenario():
#	print(">>>>",_gamemode)
	_current_scenario = _scenarios["scenarios"].get(_gamemode)
#	print("...")
	set_round(0)
	set_wave_limit()
	set_wave(1)
	set_missile_at_once()
	set_questionnaire_limit()
	set_quick_questions()
	set_ammo_count()
	set_autoplay()

func set_ammo_count():
	self._ammo = _current_round["ammo"]

func set_autoplay():
#	print(_current_round)
	self._autoplay = _current_round["autoplay"]

func set_quick_questions():
	self._quick_questions = _current_round["quick_questions"]

func set_questionnaire_limit():
#	if _current_round:
#	self._questionnaire_limit = _current_round["end_questionnaire"]
	self._questionnaire = _current_round["end_questionnaire"]
#	print("questionnaire set:",_questionnaire_limit)
	self.cpt_questionnaire = 0
	
	if "complementary_questionnaire" in _current_round:
		self._complementary_questionnaire = _current_round["complementary_questionnaire"]

func get_questionnaire_limit():
	return self._questionnaire_limit

func set_missile_at_once():
	self._missile_at_once = _current_round["default_missile_at_once"]

func set_round(round_nb):
	_round_limit = len(_current_scenario.keys())
	if _round_limit-1 >= round_nb:
		_current_round = _current_scenario.values()[round_nb]
		_current_round_idx = round_nb
		_current_round_nb = _current_round_idx + 1
	else:
		_current_round = _current_scenario.values()[_round_limit-1]
		_current_round_idx = _round_limit-1
		_current_round_nb = _current_round_idx + 1
#	set_wave_scheduled()
	set_missile_at_once()
	set_activation_delay()
	set_temp_spawn_increase()
	set_obscuring_type()
	set_friendly_timing()
	set_pause_timing()
	set_missile_settings()
	set_round_settings()
	set_cover_story()
	set_visual_aid()
	set_non_missile_threat()

func set_wave_limit():
	self._wave_limit = _current_round["waves"]
	self._wave_settings = _current_round["wave_settings"]
	self._randomise_waves = _current_round["randomise_waves"]

func set_wave(wave_nb):
	self._current_wave_idx=wave_nb
	set_wave_difficulty()
	set_wave_limit()
	reset_wave_counters()

func next_wave():
	self._current_wave_idx+=1
	set_wave_difficulty()
	reset_wave_counters()

func randomize_waves():
	if _randomise_waves == false:
		print("Not randomizing waves.")
		return null
	print("randomizing waves...")
#	print("INPUT WAVES:\n",_wave_settings)
	var non_randomised_dict = _wave_settings.duplicate(true)
	var non_randomised_list = []
	for k in non_randomised_dict:
		non_randomised_list.append(non_randomised_dict[k])
#	non_randomised_list.shuffle()
#	non_randomised_list = shuffle_no_same_consecutive(non_randomised_list)
	var randomised_list = shuffle_two_blocks(non_randomised_list)
	var randomised_dict = {}
	var i = 1
	for v in randomised_list:
		randomised_dict[str(i)] = v
		i += 1
	_wave_settings = null
	_wave_settings = randomised_dict.duplicate(true)
	print("RESULT WAVES:\n",_wave_settings)

func shuffle_two_blocks(non_randomised_list):
	var block1 = non_randomised_list.slice(0,2)
	var block2 = non_randomised_list.slice(3,5)
	block1.shuffle()
	block2.shuffle()
	return block1+block2

func shuffle_no_same_consecutive(a_list):
	# randomize()
#	prints("BEFORE:",a_list)
	print("shuffling waves without repetitions")
	var a_list_copy = a_list.duplicate(true)
	var result = []
	var last_item # = a_list_copy[randi()%a_list_copy.size()]
	while len(result)<len(a_list):
		var new_item = a_list_copy[main_node.RNG.randi()%a_list_copy.size()]
		if new_item != last_item:
			result.append(new_item)
			last_item = new_item
#	print("AFTER:",result)
	return result


func reset_round_counters():
	self._number_city_hit = 0
	self._number_city_hit_1 = 0
	self._number_city_hit_2 = 0
	self._number_city_hit_3 = 0
	self._number_city_hit_4 = 0
	self._shot_fired = 0
	self._missile_spawned = 0
	self._threat_missile_spawned = 0
	self._non_threat_missile_spawned = 0 
	self._missile_destroyed = 0
	self._friendly_spawned = 0
	self._friendly_destroyed = 0
	self._hidden_missiles_hit = 0
	self._threat_missile_destroyed = 0
	self._non_threat_missile_destroyed = 0
	self._tp_spawned = 0
	self._fp_spawned = 0
	self._fn_spawned = 0
	self._tn_spawned = 0
	self._tp_destroyed = 0
	self._fp_destroyed = 0
	self._fn_destroyed = 0
	self._tn_destroyed = 0

func reset_wave_counters():
	self._wave_number_city_hit = 0
	self._wave_number_city_hit_1 = 0
	self._wave_number_city_hit_2 = 0
	self._wave_number_city_hit_3 = 0
	self._wave_number_city_hit_4 = 0
	self._wave_shot_fired = 0
	self._wave_missile_spawned = 0
	self._wave_threat_missile_spawned = 0
	self._wave_non_threat_missile_spawned = 0
	self._wave_missile_destroyed = 0
	self._wave_friendly_spawned = 0
	self._wave_friendly_destroyed = 0
	self._wave_hidden_missiles_hit = 0
	self._wave_threat_missile_destroyed = 0
	self._wave_non_threat_missile_destroyed = 0
	self._wave_tp_spawned = 0
	self._wave_fp_spawned = 0
	self._wave_fn_spawned = 0
	self._wave_tn_spawned = 0
	self._wave_tp_destroyed = 0
	self._wave_fp_destroyed = 0
	self._wave_fn_destroyed = 0
	self._wave_tn_destroyed = 0

func next_round():
	set_round(_current_round_idx+1)
	reset_wave_counters()

#func set_wave_scheduled():
#	self._wave_scheduled_events = _current_round["scheduled"]

func set_missile_settings():
	self._missile_interval = _current_round["default_missile_interval"]
	self._missile_speed = _current_round["default_missile_speed"]
#	print("- START\nmissile interval:",_missile_interval)
#	print("missile speed:",_missile_speed)

func set_friendly_timing():
	self._friendly_timing = _current_round["default_friendly_timing"]

func set_visual_aid():
	self._visual_aid = _current_round["default_visual_aid"]
	self._visual_aid_timing = _current_round["default_visual_aid_timing"]

func set_obscuring_type():
	self._obscuring_type = _current_round["default_obscuring"]
	self._obscuring_timing = _current_round["default_obscuring_timing"]

func set_cover_story():
	self._cover_story = _current_round["cover_story"]
#	print(">>>>>>>>>>>>>",_cover_story)

func set_non_missile_threat():
	self._non_threat_missiles = _current_round["default_non_threat_missiles"]

func set_pause_timing():
	self._pause_timing = _current_round["default_pause_timing"]

func get_obscuring_position(pos):
	self._obscuring_position = pos

func set_obscuring_status(boolean):
	self._obscuring_activated = boolean

func get_obscuring_status():
	return self._obscuring_activated

func set_visual_aid_status(boolean):
	self._visual_aid_status = boolean

func get_visual_aid_status():
	return self._visual_aid_status

func set_round_settings():
	self._timelimit = _current_round["duration"]
	self._current_agent = _current_round["agent"]

func set_activation_delay():
	self._activation_delay = _current_round["default_activation_delay"]

func set_temp_spawn_increase():
	self._temp_spawn_increase = _current_round["default_temp_spawn_increase"]
#	print(_temp_spawn_increase)

func missile_destroyed(missile_id):
#	print("Missile destroyed: ",self._missile_destroyed)
	self._missile_destroyed += 1
	self._wave_missile_destroyed += 1
	
	match missile_id.threat:
		true:
#			print("REGISTERING THREATENING MISSILE")
			self._threat_missile_destroyed += 1
			self._wave_threat_missile_destroyed += 1
		false:
#			print("REGISTERING NON THREATENING MISSILE")
			self._non_threat_missile_destroyed += 1
			self._wave_non_threat_missile_destroyed += 1

func set_type_missile_spawned(missile_type):
	match missile_type:
		"TP":
			self._tp_spawned += 1
			self._wave_tp_spawned += 1
		"FP":
			self._fp_spawned += 1
			self._wave_fp_spawned += 1
		"FN":
			self._fn_spawned += 1
			self._wave_fn_spawned += 1
		"TN":
			self._tn_spawned += 1
			self._wave_tn_spawned += 1
	
func set_type_missile_destroyed(missile_type):
	match missile_type:
		"TP":
			self._tp_destroyed += 1
			self._wave_tp_destroyed += 1
		"FP":
			self._fp_destroyed += 1
			self._wave_fp_destroyed += 1
		"FN":
			self._fn_destroyed += 1
			self._wave_fn_destroyed += 1
		"TN":
			self._tn_destroyed += 1
			self._wave_tn_destroyed += 1

func missile_spawned(missile_id):
	self._missile_spawned += 1
	self._wave_missile_spawned += 1
	
	match missile_id.threat:
		true:
			self._threat_missile_spawned += 1
			self._wave_threat_missile_spawned += 1
		false:
			self._non_threat_missile_spawned += 1
			self._wave_non_threat_missile_spawned += 1

func friendly_spawned():
	self._friendly_spawned += 1
	self._wave_friendly_spawned += 1

func friendly_deleted():
	self._friendly_destroyed += 1
	self._wave_friendly_destroyed += 1

func set_hidden_missiles(an_array):
	self._hidden_missiles = an_array

func hidden_missile_hit():
	self._hidden_missiles_hit += 1
	self._wave_hidden_missiles_hit += 1

func shot_fired():
	self._shot_fired += 1
	self._wave_shot_fired += 1

func city_hit(city_id):
	self._number_city_hit += 1
	self._wave_number_city_hit += 1
	match city_id.name[-1]:
		"1":
			self._number_city_hit_1 += 1
			self._wave_number_city_hit_1 += 1
		"2":
			self._number_city_hit_2 += 1
			self._wave_number_city_hit_2 += 1
		"3":
			self._number_city_hit_3 += 1
			self._wave_number_city_hit_3 += 1
			
		"4":
			self._number_city_hit_4 += 1
			self._wave_number_city_hit_4 += 1


func user_distance_travelled(pixel_nb):
	self._user_distance_travelled += pixel_nb
