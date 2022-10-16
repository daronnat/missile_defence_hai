extends Node

var main_node

var _targeting
var _agents
var _agent_name
var _agent_displayed_name
var _bias_type
var _bias_intensity
var _bias_intensity_info
var _behaviour
var _behaviour_timing
var _default_behaviour_timing
var _active_agent_behaviour = false
var _quadrant
var _repair
var _timing_delta
var _targeting_threat
var _imperfect_missile_awareness
var _missile_awareness_error_margin
var _missile_awareness_mode
var _false_positive_rate
var _error_rate
var _visible_help_status

var _wave_agent_calling = 0
var _agent_calling = 0

func _init(agent,json_agent_file,calling_node):
	main_node = calling_node
	self._agents = json_agent_file
	if agent in _agents:
		self._agent_name = agent
		set_displayed_name()
		set_targeting()
		set_biases()
		set_behaviour()
		set_bias_intensity("default")
		set_targeting_threat()
		set_missile_awareness()
		set_help_status_visibility()
	else:
		self._agent_name = "no_agent"

func set_displayed_name():
	self._agent_displayed_name = _agents[_agent_name]["displayed_name"]

func set_targeting():
	self._targeting = _agents[_agent_name]["targeting"]

func set_help_status_visibility():
	self._visible_help_status = _agents[_agent_name]["visible_help_status"]

func set_biases():
	self._bias_type = _agents[_agent_name]["bias_type"]
	if _bias_type:
		self._bias_intensity_info = _agents[_agent_name]["bias_intensity_info"]
		self._quadrant = int(main_node.RNG.randi_range(1,4)) # quadrant selected for systematic biases

func set_behaviour():
	if _agents[_agent_name]["behaviour"]:
		self._behaviour = _agents[_agent_name]["behaviour"]
		self._default_behaviour_timing = _agents[_agent_name]["behaviour"]["behaviour_timing"]
		self._behaviour_timing = _agents[_agent_name]["behaviour"]["behaviour_timing"]
		if "timing_delta" in _agents[_agent_name]["behaviour"]:
			self._timing_delta = _agents[_agent_name]["behaviour"]["timing_delta"] 
			
func set_bias_intensity(wave_index):
	if not _bias_intensity_info:
		return 0
	if str(wave_index) in self._bias_intensity_info.keys():
		self._bias_intensity = self._bias_intensity_info[str(wave_index)]
	else:
		self._bias_intensity = self._bias_intensity_info["default"]
	
	prints("Agent bias intensity set to:",self._bias_intensity)

func set_targeting_threat():
	self._targeting_threat = _agents[_agent_name]["target_non_threat"]
#	prints("agent targeting non threat?",self._targeting_threat)

func set_missile_awareness():
	self._imperfect_missile_awareness = _agents[_agent_name]["missile_awareness"]["activated"]
	self._error_rate = _agents[_agent_name]["missile_awareness"]["error_rate"]
	self._false_positive_rate = _agents[_agent_name]["missile_awareness"]["false_positive_rate"]

func set_repair():
	if _agents[_agent_name]["repair"]:
		self._repair = _agents[_agent_name]["repair"]

func summary_config_agent():
	return ["CURRENT AGENT CONFIG:",_agent_name,_bias_type,_bias_intensity,_behaviour]

func getBehaviourStatus():
	return self._active_agent_behaviour

func getAgentBehaviour():
	if self._behaviour:
		return true
	else:
		return false
