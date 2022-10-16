extends Node

func show_end_round_question(is_agent):
	var sliders_names = ["difficulty_slider","shapley_slider"] # names of sliders in end round panels
	var question_type = $one_p_end_round_question
	if is_agent:
		question_type = $end_round_question
	var forms_activated = true
	$panel_appear.interpolate_property(question_type, "rect_scale",
		Vector2(0,0), question_type.rect_scale, 2,
		Tween.TRANS_BACK, Tween.EASE_IN_OUT,0)
	$panel_appear.start()
	question_type.show()
	for child in question_type.get_children():
		if(child.get_name() in sliders_names):
			child.grab_focus()
			break

func _on_next_round_pressed():
	var end_round_answer = $one_p_end_round_question/difficulty_slider.value
	var end_round_question = $one_p_end_round_question/question_difficulty.text
	$one_p_end_round_question.hide()
	$one_p_end_round_question/difficulty_slider.value = int($one_p_end_round_question/difficulty_slider.value/2)
