extends Panel

onready var root_node_path = "/root/Node2D"
onready var BYPASS_SCOREBOARD = false
onready var main_node = get_node(root_node_path)
onready var autoplay = get_node(root_node_path+"/consent_form/autoplay_panel/CheckButton")
var city_penalty = -20
var missile_pts = 100

func _ready():
	show()
	show_score()
	
	if autoplay and autoplay.pressed == true:
		hide()
		_on_scoreboard_button_pressed()

	if main_node and main_node.gamemode == "tutorial":
		pass
		hide()
		_on_scoreboard_button_pressed()
	
	if BYPASS_SCOREBOARD == true:
		_on_scoreboard_button_pressed()
	
func show_score():
	if main_node and main_node.current_scenario:
		main_node.current_scenario._controls_enabled = false
		$threat_missile_cnt.text = str(main_node.current_scenario._threat_missile_destroyed) + "/" + \
		str(main_node.current_scenario._threat_missile_spawned)
#		$missile_cnt.text = str(main_node.current_scenario._missile_destroyed)+"/"+ \
#		str(main_node.current_scenario._missile_spawned)
		$city_cnt.text = str(main_node.current_scenario._number_city_hit)
#		$shot_cnt.text = str(main_node.current_scenario._shot_fired)
	$scoreboard_button.grab_focus()

func _on_scoreboard_button_pressed():
	if main_node and main_node.current_scenario:
		if main_node.current_scenario._current_round_nb >= main_node.current_scenario._round_limit:
			main_node.show_end_game_panel()
		else:
			main_node.reset_var()
			main_node.reset_timers()
			main_node.enable_controls()
			main_node.start_next_round()
	queue_free()
