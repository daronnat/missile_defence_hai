extends Panel

onready var root_node_path = "/root/Node2D"
onready var questions_file_path = "res://text_resources/questions.json"
onready var main_node = get_node(root_node_path)
onready var logging_node = get_node(root_node_path+'/consent_form/logging_panel')
onready var consent_form = get_node(root_node_path+"/consent_form")
onready var autoplay = get_node(root_node_path+"/consent_form/autoplay_panel/CheckButton")
onready var crosshair_node = get_node(root_node_path+"/crosshair")

var initial_t_trigger = 0
var t_quick_ques_triggered = 0

var parsed_questions_file = null
var questions = null
var question_category = ""
var current_idx = 0
var result = {}

var local_timer

var grading_limit = 0.000000
var ct_grading_step = 0.000000

var user_input = false

func _ready():
	$Button.disabled = true
	show()
	$template.show()
#	$template/progress.hide()
	local_timer = 0
	
	
	
#		if main_node:
#			main_node.next_step_scenario()
#		queue_free()
	
#	if main_node.gamemode == "tutorial":
#		print("tutorial activated")
#		main_node.next_step_scenario()
#		queue_free()
	
	if main_node:
		initial_t_trigger = main_node.t


	if question_category == "":
		_on_Button_pressed()
	else:
		parsed_questions_file = parse_json_questions(questions_file_path)
		questions = parsed_questions_file[question_category]
		next_question(questions,current_idx)
#	display_update_progress()
func parse_json_questions(path_to_file):
	var file = File.new()
	file.open(path_to_file, file.READ)
	var result_json = JSON.parse(file.get_as_text())
	prints(path_to_file,"parsed with",result_json.error,"error(s).")
	return result_json.result

#var progress_i = 1
func display_update_progress():
	if not questions.empty():
		var temp_i = current_idx+1
		$template/progress.text = str(temp_i)+"/"+str(questions.size())
#		prints(">>>>",progress_i,"/",questions.size())
#		progress_i+=1
		
func update_grading_limit(a_delta):
	var TIME_TO_COMPLETE = 1.5
#	limit = (a_delta*TIME_TO_COMPLETE)/$template/HSlider.max_value*a_delta
	var original_time = $template/HSlider.max_value*a_delta
	var multiplier = TIME_TO_COMPLETE/original_time
	var limit = a_delta * multiplier
	return limit
#	prints("time to complete:",TIME_TO_COMPLETE)
#	prints("delta",a_delta)
#	prints("other",$template/HSlider.max_value*a_delta)
#	prints("result:",grading_limit)

func _process(delta):
#	if main_node and not main_node.gamemode == "tutorial":
	if Input.is_action_just_pressed("quick_question_accept"):
		_on_Button_pressed()
	
	if crosshair_node:
		crosshair_node.hide()
	
#	else:
#	if Input.is_action_just_pressed("quick_question_accept"):
#			_on_Button_pressed()
	

	
#	if main_node:
#	if ct_grading_step < grading_limit:
#
#
#	else:
#		ct_grading_step = 0
	grading_limit = update_grading_limit(delta)
#	print(grading_limit)
	if ct_grading_step > grading_limit:
		user_input = true
#		print(ct_grading_step)
		
		if Input.is_action_pressed("ui_right"):
			$template/HSlider.value+=$template/HSlider.step
		elif Input.is_action_pressed("ui_left"):
			$template/HSlider.value-=$template/HSlider.step
		ct_grading_step = 0
	
	ct_grading_step+=delta
	
	
	
	
#	if autoplay and autoplay.pressed == true:
#		print("autoplay activated")
#		if main_node:
#			main_node.reset_smoke()
#			_on_Button_pressed()
			
#			hide()
#			main_node.next_step_scenario()
#			queue_free()
#		_on_Button_pressed()

#	if main_node and main_node.gamemode == "tutorial":
#		hide()
#		_on_Button_pressed()
#		main_node.next_step_scenario()
#		main_node.start_next_round()
#		queue_free()
	local_timer += delta
	grading_limit+=delta
	
func next_question(question_list,idx):
	display_update_progress()
#	user_input = false
	if main_node:
		t_quick_ques_triggered = initial_t_trigger+local_timer
	else:
		t_quick_ques_triggered = local_timer

	if idx < len(question_list):
		$template/header.text = question_list[idx]["header"]
		$template/question.text = question_list[idx]["question"]

		$template/HSlider/l0.text = str(question_list[idx]["l0"])
		$template/HSlider/l1.text = str(question_list[idx]["l1"])
		$template/HSlider/l2.text = str(question_list[idx]["l2"])
		$template/HSlider/l3.text = str(question_list[idx]["l3"])
		$template/HSlider/l4.text = str(question_list[idx]["l4"])
		$template/HSlider/l5.text = str(question_list[idx]["l5"])
		$template/HSlider/l6.text = str(question_list[idx]["l6"])

		$template/HSlider.min_value = question_list[idx]["min_val"]
		$template/HSlider.max_value = question_list[idx]["max_val"]
		$template/HSlider.tick_count = question_list[idx]["max_val"]

		$template/HSlider.value = int(question_list[idx]["start_val"])

		current_idx += 1
		
		$template/HSlider.grab_focus()
	
	$Button.disabled = true
#		delta_grading_step = 
func _on_Button_pressed():
#	print("ON BUTTON PRESSED:",autoplay.pressed)
	if autoplay and autoplay.pressed == true:
		print("autoplay activated")
		if main_node:
			main_node.reset_smoke()
			main_node.next_step_scenario()
			queue_free()

#			_on_Button_pressed()
#	elif $Button.disabled == true:
#		return null
	
	elif main_node and main_node.gamemode == "tutorial":
		print("button pressed + tutorial")
#		trigger_logging()
		main_node.next_step_scenario()
		queue_free()
#		hide()
	elif user_input == true:
		user_input = false
		result[questions[current_idx-1]["question"]]=[$template/HSlider.value,
		t_quick_ques_triggered,
		initial_t_trigger+local_timer]
	
		if current_idx < len(questions):
			next_question(questions,current_idx)
		else:
			trigger_logging()
	
	else:
		trigger_logging()
			
	$Button.disabled = true

func trigger_logging():
	if main_node and logging_node:
		for q in result:
			logging_node.log_single_item_rating(q,result[q][0],result[q][1],result[q][2],
			consent_form.active_log_path,"END")
		main_node.next_step_scenario()
		if crosshair_node:
			crosshair_node.show()
	else:
		print(result)
	queue_free()

func _on_HSlider_changed():
	pass

func _on_HSlider_value_changed(value):
	$Button.disabled = false
