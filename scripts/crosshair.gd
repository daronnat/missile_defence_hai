extends Area2D
#var speed = 1200 # 1080p game
var speed = 800 # 1080p game
var screensize
onready var main_node = get_node("/root/Node2D")

func _ready():
#	set_layer(100)
#	get_viewport_transform().get_layer()
	cross_pos = global_position
	screensize = get_viewport_rect().size
	
	set_light_intensity()
	
#	print("TEST:",agent_mechanics)

func set_light_intensity():
	# quick fix because of the difference in light intensity between HTML exports and others
	if OS.get_name() == "HTML5":
		$Light2D.set_energy(2.75)
	
func start(pos):
	position = pos

func _on_shot_fired(): # to do: identify who shot, the agent or the user?
	pass

var cross_pos = null

onready var control_focus_status = get_node("../focus_status")
onready var cross_neutral = get_node("crosshair_neutral")
onready var cross_user_ctrl = get_node("crosshair_user/control_user")
onready var cross_agent_ctrl = get_node("crosshair_agent/control_agent")
onready var cross_neutral_ctrl = get_node("crosshair_neutral/control_neutral")

onready var agent_mechanics = get_node("../agent_avatar")

var cpt_owner_switch = 0
var cpt_user_switch = 0
func track_owner_switch():
	cpt_owner_switch += 1
	wave_cpt_owner_switch += 1

func track_user_switch(previous,current):
	if previous ==  cross_agent_ctrl and current == cross_user_ctrl:
		cpt_user_switch +=1
		wave_cpt_user_switch += 1

var current_owner = null
var ctrl_time_dict = {}
var continuous_ctrl_time = {}
onready var reliance_scores = {cross_user_ctrl.get_name():0.0,cross_agent_ctrl.get_name():0.0}

var previous_owner
func track_owner_time_distance(delta):
	current_owner = control_focus_status.get_focus_owner()
	if current_owner == cross_user_ctrl or current_owner == cross_agent_ctrl:
		if current_owner.get_name() in ctrl_time_dict:
			ctrl_time_dict[current_owner.get_name()] = ctrl_time_dict[current_owner.get_name()] + delta
			wave_ctrl_time_dict[current_owner.get_name()] = ctrl_time_dict[current_owner.get_name()] + delta
		else:
			ctrl_time_dict[current_owner.get_name()] = delta
			wave_ctrl_time_dict[current_owner.get_name()] = delta

		# increment and decrement points due to who control the crosshair
		if current_owner == cross_user_ctrl:
			reliance_scores[cross_user_ctrl.get_name()] = reliance_scores[cross_user_ctrl.get_name()]-delta
			reliance_scores[cross_agent_ctrl.get_name()] = reliance_scores[cross_agent_ctrl.get_name()]+delta
			
			wave_reliance_scores[cross_user_ctrl.get_name()] = reliance_scores[cross_user_ctrl.get_name()]-delta
			wave_reliance_scores[cross_agent_ctrl.get_name()] = reliance_scores[cross_agent_ctrl.get_name()]+delta
			
		else:
			reliance_scores[cross_user_ctrl.get_name()] = reliance_scores[cross_user_ctrl.get_name()]+delta
			reliance_scores[cross_agent_ctrl.get_name()] = reliance_scores[cross_agent_ctrl.get_name()]-delta
			
			wave_reliance_scores[cross_user_ctrl.get_name()] = reliance_scores[cross_user_ctrl.get_name()]+delta
			wave_reliance_scores[cross_agent_ctrl.get_name()] = reliance_scores[cross_agent_ctrl.get_name()]-delta

		if previous_owner: # record continus interaction
			if current_owner == previous_owner:
				if current_owner.get_name() in continuous_ctrl_time:
					continuous_ctrl_time[current_owner.get_name()] = continuous_ctrl_time[current_owner.get_name()] + delta
					wave_continuous_ctrl_time[current_owner.get_name()] = continuous_ctrl_time[current_owner.get_name()] + delta
										
				else:
					continuous_ctrl_time[previous_owner.get_name()] = delta
					wave_continuous_ctrl_time[previous_owner.get_name()] = delta
			else:
				track_owner_switch()
				track_user_switch(previous_owner,current_owner)
				# reset delta of previous owner
				continuous_ctrl_time[previous_owner.get_name()] = 0
				wave_continuous_ctrl_time[previous_owner.get_name()] = 0
			
		previous_owner = current_owner
	

func _on_beginning_round():
	reset_ctrl_time_dict()

func reset_ctrl_time_dict():
	ctrl_time_dict = {}
	continuous_ctrl_time = {}
	reliance_scores = {cross_user_ctrl.get_name():0.0,cross_agent_ctrl.get_name():0.0}
	cpt_user_switch = 0
	cpt_owner_switch = 0
	agent_calls = 0

var wave_ctrl_time_dict = {}
var wave_continuous_ctrl_time = {}
onready var wave_reliance_scores = {cross_user_ctrl.get_name():0.0,cross_agent_ctrl.get_name():0.0}
var wave_cpt_user_switch = 0
var wave_cpt_owner_switch = 0

func reset_wave_ctrl_time_dict():
	wave_ctrl_time_dict = {}
	wave_continuous_ctrl_time = {}
	wave_reliance_scores = {cross_user_ctrl.get_name():0.0,cross_agent_ctrl.get_name():0.0}
	wave_cpt_user_switch = 0
	wave_cpt_owner_switch = 0
	wave_agent_calls = 0

func _on_beginning_wave():
	center_crosshair()
	reset_wave_ctrl_time_dict()

func center_crosshair():
	position = Vector2(screensize.x/2,screensize.y/2.3)

func _process(delta):
	update()
	track_owner_time_distance(delta)
	var velocity = Vector2()
	if not main_node.current_scenario:
		hide()
	else:
		show()
	if main_node.current_scenario and main_node.current_scenario._controls_enabled == true:
		if Input.is_action_just_pressed("user_move_right") or Input.is_action_just_pressed("user_move_left") \
		or Input.is_action_just_pressed("user_move_down") or Input.is_action_just_pressed("user_move_up"):
			cross_user_ctrl.grab_focus()
		else:
			cross_user_ctrl.release_focus()
	
		if Input.is_action_pressed("user_move_right") or Input.is_action_pressed("user_move_left") \
		or Input.is_action_pressed("user_move_down") or Input.is_action_pressed("user_move_up"):
			cross_user_ctrl.grab_focus()
		else:
			cross_user_ctrl.release_focus()
	
		if control_focus_status.get_focus_owner() == cross_user_ctrl:
			if Input.is_action_pressed("user_move_right"):
				velocity.x += speed
			if Input.is_action_pressed("user_move_left"):
				velocity.x -= speed
			if Input.is_action_pressed("user_move_down"):
				velocity.y += speed
			if Input.is_action_pressed("user_move_up"):
				velocity.y -= speed
	
		if control_focus_status.get_focus_owner() == null:
			cross_neutral_ctrl.grab_focus()
			cross_neutral.show()
		
		if Input.is_action_just_pressed("get_focus"):
			agent_called(control_focus_status.get_focus_owner())

	# prevent crosshair from going over screen
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	position += velocity * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)

var wave_agent_calls = 0
var agent_calls = 0
func agent_called(focus_owner):
	print("entering function agent_called")
	if agent_mechanics.agent_activated == true:
		if focus_owner != cross_agent_ctrl:
#		if focus_owner != cross_agent_ctrl and main_node.active_missiles.empty() == false:
			print("Agent called!")
			agent_mechanics.ctrl_delay = agent_mechanics.delay_limit*2 # force reset the ctrl limit to call the agent
			wave_agent_calls+=1
			agent_calls+=1
			
			
#	if agent_activated == true:
#		if Input.is_action_pressed("get_focus") and focus_owner != agent_crosshair_ctrl:
#	if focus_owner != agent_crosshair_ctrl:
#		print("Agent called!")
#		ctrl_delay = delay_limit*2 # force reset the ctrl limit to call the agent
