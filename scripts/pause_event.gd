extends Node2D

var t = 0
var seen_t = []
var start_t

onready var main_node = get_node("/root/Node2D")
onready var logging_node = get_node('/root/Node2D/consent_form/logging_panel')

func _ready():
	seen_t = []
	$pause_panel.hide()
	$whitescreen.hide()
	$countdown.hide()
	$pause_panel/resume_button.disabled = true
	
	$pause_panel/question_top/LineEdit.clear()
	$pause_panel/question_bottom/LineEdit.clear()

func _process(delta):
	t += delta
#	$Sprite.show()
#	$Sprite.rotate(delta)
#	check_pause_t(t,[3])
	
func check_pause_t(t,trigger):
	if int(t) in trigger and not int(t) in seen_t:
		get_tree().paused = true
		seen_t.append(int(t))
		start_t = OS.get_ticks_msec()
		$pause_panel.show()
		$whitescreen.show()

func _on_resume_button_pressed():
	$whitescreen.hide()
	$pause_panel.hide()
	start_timer(2)
	prints("Input:",$pause_panel/question_top/LineEdit.text,
	$pause_panel/question_mid/LineEdit.text,$pause_panel/question_bottom/LineEdit.text)
	prints("Completion time:",OS.get_ticks_msec() - start_t)
	
	var missile_placement = find_missile_position(375)
	var comp_time = (OS.get_ticks_msec() - start_t)*0.001
	var total_answer = int($pause_panel/question_top/LineEdit.text)+ \
	int($pause_panel/question_bottom/LineEdit.text)
	
	trigger_logging("SA question",$pause_panel/question_top/LineEdit.text,
	$pause_panel/question_bottom/LineEdit.text,total_answer,comp_time,missile_placement)
	
	prints("missile placement:",missile_placement)
	
func start_timer(delay):
	$countdown.show()
	$Timer.set_wait_time(delay)
	$Timer.set_one_shot(true)
	$Timer.start()
	
func _on_Timer_timeout():
	$countdown.hide()
	resume_game()

func resume_game():
	get_tree().paused = false

func trigger_logging(question,answer_top,answer_bottom,total,completion,missile_loc):
	if main_node and logging_node:
		logging_node.log_pause_question_answer(question,answer_top,answer_bottom,total,completion,missile_loc)
	else:
		prints(question,answer_top,answer_bottom,total,completion,missile_loc)

func _on_LineEdit_text_changed(new_text, extra_arg_0):
#	print(extra_arg_0)
	manage_submit_button()

func manage_submit_button():
	if $pause_panel/question_top/LineEdit.text == "" or $pause_panel/question_bottom/LineEdit.text == "":
		$pause_panel/resume_button.disabled = true
	else:
		$pause_panel/resume_button.disabled = false

func find_missile_position(limits):
	if main_node:
		var missile_arrangement = {"top":0,"bottom":0}
		for m in main_node.active_missiles:
			if m.position.y < limits:
				missile_arrangement["top"] = missile_arrangement["top"] + 1
			else:
				missile_arrangement["bottom"] = missile_arrangement["bottom"] + 1
#		print(missile_arrangement)
		return missile_arrangement
	return false
	
	
