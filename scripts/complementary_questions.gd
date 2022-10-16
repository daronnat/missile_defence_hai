extends Panel

onready var root_node_path = "/root/Node2D"
onready var main_node = get_node(root_node_path)
onready var logging_node = get_node(root_node_path+'/consent_form/logging_panel')
onready var consent_form = get_node(root_node_path+"/consent_form")
onready var autoplay = get_node(root_node_path+"/consent_form/autoplay_panel/CheckButton")
onready var control_focus_status = get_node("focus_status")


var t_quick_ques_triggered = 0
var t_quick_ques_answered = 0
var quick_q_ctdw = 15

func _ready():
#	difficulty_setup()
	$difficulty.grab_focus()
	show()
	$difficulty.value = $difficulty.min_value

	if autoplay and autoplay.pressed == true:
		if main_node:
			main_node.reset_smoke()
		hide()
		_on_Button_pressed()
	
	if main_node:
		t_quick_ques_triggered = main_node.t
		print("current agent:",main_node.loaded_agent)
		if main_node.gamemode == "tutorial":
			pass
			hide()
			_on_Button_pressed()
		
#		if main_node.gamemode == "no_agent": # replace with checking if current_agent exist or not
#			difficulty_setup()
#		else:
#			trust_setup()

#func difficulty_setup():
#	$Label.text = "How difficult was the task?"
#	$HSlider/min.text = "Not at all\nDifficult"
#	$HSlider/left.text = "|\nSlightly\nDifficult"
#	$HSlider/mid.text = "|\nModeratly\nDifficult"
#	$HSlider/right.text = "|\nVery\nDifficult"
#	$HSlider/max.text = "Extremely\nDifficult"
#
#func trust_setup():
#	$Label.text = "Please indicate your trust toward the agent"
#	$HSlider/min.text = "My trust\nin the agent is\nVery Low"
#	$HSlider/left.text = "|\nMy trust\nin the agent is\nBelow Average"
#	$HSlider/mid.text = "|\nMy trust\nin the agent is\nAverage"
#	$HSlider/right.text = "|\nMy trust\nin the agent is\nAbove Average"
#	$HSlider/max.text = "My trust\nin the agent is\nVery High"

func _process(delta):
	
	if Input.is_action_just_pressed("quick_question_accept"):
		_on_Button_pressed()
	var current_focus = control_focus_status.get_focus_owner()
	
#	print(current_focus.name)
	
	if Input.is_action_pressed("ui_right"):
		current_focus.value+=current_focus.step
	elif Input.is_action_pressed("ui_left"):
		current_focus.value-=current_focus.step
	display_timer(null)

func display_timer(delta=null):
	if delta == null:
		$timer.hide()
	else:
		quick_q_ctdw -= delta
		$timer.text = str(int(quick_q_ctdw))
		if quick_q_ctdw <=0:
			_on_Button_pressed()
	
func _on_Button_pressed():
	prints("Answers:",$difficulty.value,$reliance.value,$usefulness.value)
	if main_node:
		t_quick_ques_answered = main_node.t
		if logging_node:
			logging_node.log_single_item_rating("Difficulty (harder to easier)",$difficulty.value,t_quick_ques_triggered,
				t_quick_ques_answered,consent_form.active_log_path,"END")
			logging_node.log_single_item_rating("Reliance (lower to higher)",$reliance.value,t_quick_ques_triggered,
				t_quick_ques_answered,consent_form.active_log_path,"END")
			logging_node.log_single_item_rating("Usefulness (lower to higher)",$usefulness.value,t_quick_ques_triggered,
				t_quick_ques_answered,consent_form.active_log_path,"END")
		main_node.next_step_scenario()
	queue_free()
