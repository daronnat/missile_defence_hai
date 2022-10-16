extends Node2D

var form
onready var logging_node = get_node("/root/Node2D/consent_form/logging_panel")
onready var main_node = get_node("/root/Node2D")
var questionnaire_path = "res://text_resources/questionnaires.json"
signal send_questionnaire_results
#var manual_form
var manual_form = "trust_in_automation"
#var manual_form = "tlx"
#var form_type = "tlx"

func _ready():
	self.z_index = 9 # make sure that nothing overlaps the questionnaire
	
	if main_node and main_node.gamemode == "tutorial":
		print("tutorial -> displaying end game panel instead")
		main_node.show_end_game_panel()
		self.queue_free()
	
#	if main_node:
#		if main_node.current_scenario._questionnaire and main_node.current_scenario._questionnaire.empty() == false:
#			manual_form = main_node.current_scenario._questionnaire[main_node.current_scenario.cpt_questionnaire]
#			main_node.current_scenario.cpt_questionnaire += 1
#		else:
#			manual_form = null
#
	
	if logging_node:
		self.connect("send_questionnaire_results",logging_node,"_on_questionnaire_received")
	else:
		print("no logging node found")
	
	if manual_form:
		start_manual_questionnaire(manual_form)
	else:
		start_automatic_questionnaire()

########## manual questionnaire ################
var active_form = null

func start_manual_questionnaire(form_type):
	active_form = get_node(form_type)
	if form_type == "tlx":
		$tlx.show()
		$tlx/question_block1/HSlider.grab_focus()
		$trust_in_automation.hide()
	elif form_type == "trust_in_automation":
		$trust_in_automation.show()
		$trust_in_automation/page1.show()
		$trust_in_automation/page1/question_block1/HSlider.grab_focus()
		$trust_in_automation/page2.hide()
		$tlx.hide()

	$ScrollContainer.hide()

func _on_next_pressed():
	print(str(active_form.get_path())+"/page1")
	get_node(str(active_form.get_path())+"/page1").hide()
	get_node(str(active_form.get_path())+"/page2").show()
	get_node(str(active_form.get_path())+"/next").hide()
	get_node(str(active_form.get_path())+"/submit").show()
	
	$trust_in_automation/page2/question_block1/HSlider.grab_focus()
#	get_node(active_form/page1.hide()
#	active_form/page2.show()

func process_manual_form():
	var results = {}
	var multiple_pages = []
	for row in active_form.get_children():
		if row.name.begins_with("page"):
			multiple_pages.append(row)
	print(multiple_pages)
	
	if multiple_pages.empty() == true:
		multiple_pages.append(active_form)
	
	for v in multiple_pages:
		for node in v.get_children():
			if node.get_class() == "Control":
				results[str(node.get_node("question").text)]=node.get_node("HSlider").value

	return results

########## automatic questionnaire ################
func start_automatic_questionnaire():
	$tlx.hide()
	$trust_in_automation.hide()
	$ScrollContainer.show()
	var questions = parse_json_questions(questionnaire_path)
	form = generate_form(questions)
	var label = Label.new()
	label.text = "\nOnce you have answered all of the question, you can click on the following button:\n"
	label.set("custom_colors/font_color", Color("#000000"))
	form.add_child(label)
	var button = Button.new()
	button.text = "SUBMIT"
	button.connect("pressed",self,"submit_questionnaire")
	form.add_child(button)
	$ScrollContainer/PanelContainer.add_child(form)

func parse_json_questions(path_to_file):
	var file = File.new()
	file.open(path_to_file, file.READ)
	var result_json = JSON.parse(file.get_as_text())
	prints(path_to_file,"parsed with",result_json.error,"error(s).")
	return result_json.result

func generate_form(dict):
	var layout = VBoxContainer.new()
#	layout.margin_top=1000
#	print(layout.margin_left)
	var header = Label.new()
	header.text = "Please rate the following statements\n"
	header.set("custom_colors/font_color", Color("#000000"))
	header.uppercase = true
	layout.add_child(header)
	header.rect_position.y+=100
	var cpt = 1
	for k in dict["questions"]["rating_scales"]:
		var row = HBoxContainer.new()
		layout.add_child(row)
		var label = Label.new()
		label.set("custom_colors/font_color", Color("#000000"))
		label.rect_size = Vector2(2,2)
#		label.set_scale(Vector2(0.15,0.15))
		label.text = str(cpt)+". "+k["question"]
		label.name = "question"+str(cpt)

#		label.add_font_override("font",load("res://fonts/small_lato_normal.tres"))
#		label.add_font_override("rect_size",load("res://fonts/small_lato_normal.tres"))
#		set_scale(Vector2(0.15,0.15))
#		prints("LABEL SCALE",label.rect_scale)

		row.add_child(label)
		row = HBoxContainer.new()
		layout.add_child(row)
		label = Label.new()
		label.set("custom_colors/font_color", Color("#000000"))
		label.text = str(k["label_beg"])
		row.add_child(label)
		row.add_child(generate_hslider(k["max_rate"]))
		label = Label.new()
		label.set("custom_colors/font_color", Color("#000000"))
		label.text = "\n"+str(k["label_end"])+"\n"
		row.add_child(label)
		layout.add_child(HSeparator.new())
		cpt+=1
	return layout

func generate_hslider(size):
	size = int(size)
	var ui_node = HSlider.new()
	ui_node.min_value = 1
	ui_node.max_value = size
	ui_node.step = 1
#	ui_node.value = int(size/2)+1
	ui_node.value = 1
	ui_node.rect_min_size = Vector2(1000,20)
	ui_node.tick_count = ui_node.max_value
	ui_node.scrollable = false
	return ui_node

func process_form(form):
	var results = {}
	var cpt_q = -1
	for row in form.get_children():
		for elem in row.get_children():
			if elem.name.begins_with("question"): # check if it's a question
				results[elem.text] = 0
				cpt_q+=1
			elif elem.get_class() == "HSlider":
				results[results.keys()[cpt_q]] = elem.value
	return results

###############################################################

func submit_questionnaire():
	print("submitting questionnaire...")
	var results
	
	if manual_form:
		results = process_manual_form()
	else:
		results = process_form(form)

	if logging_node:
		emit_signal("send_questionnaire_results",results)
	else:
		print(results)

	if main_node:
		print(manual_form)
		prints(main_node.current_scenario.cpt_questionnaire,"/",len(main_node.current_scenario._questionnaire))
#		print(main_node.current_scenario.cpt_questionnaire)
		var instance_quest # active instance of the end session questionnaire
		instance_quest = load("res://scenes/questionnaire.tscn").instance()
		
		if main_node.current_scenario.cpt_questionnaire < len(main_node.current_scenario._questionnaire):
			instance_quest.manual_form = main_node.current_scenario._questionnaire[main_node.current_scenario.cpt_questionnaire]
			main_node.current_scenario.cpt_questionnaire += 1
			
#			if main_node.current_scenario.cpt_questionnaire >= len(main_node.current_scenario._questionnaire):
#
			
#			instance_quest.manual_form = true
			main_node.add_child(instance_quest)
			self.queue_free()
			
		else:
			
			
#		instance_quest.manual_form = true
		
		
		#	if current_scenario._questionnaire and current_scenario._questionnaire.empty() == false:
#		instance_quest.manual_form = current_scenario._questionnaire[0]
			self.queue_free()
			main_node.show_scoreboard()
			
#		if main_node.current_scenario.cpt_questionnaire < main_node.current_scenario._questionnaire_limit:
#			main_node.current_scenario.cpt_questionnaire += 1
#			var instance_quest # active instance of the end session questionnaire
#			instance_quest = load("res://scenes/questionnaire.tscn").instance()
#			instance_quest.manual_form = true
#			main_node.add_child(instance_quest)
#		else:
#			main_node.current_scenario.cpt_questionnaire = 0
#			main_node.show_scoreboard()
	else:
		self.queue_free()
	


