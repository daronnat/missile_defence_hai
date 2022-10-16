extends Panel

var slides = []
var current_slide
var low_idx_limit = 0
var top_idx_limit
var SKIP_TRY_AGAIN_SLIDES = true

onready var root_node_path = "/root/Node2D"
onready var main_node = get_node(root_node_path)
onready var agent_mechanics = get_node(root_node_path+"/agent_avatar")

func _ready():
	var i = 0
	for row in get_children():
		if row.get_class() == "Control":
			slides.append(row)
			if row.name == "solo_training":
				top_idx_limit = i
			i+=1
	setCurrentSlide(slides[0])
		

func _process(delta):
	if $next.visible == true and Input.is_action_just_released("next_slide"):
		_on_next_pressed()

	if $previous.visible == true and Input.is_action_just_released("previous_slide"):
		_on_previous_pressed()

func tween_display_panel():
	$Tween.interpolate_property(self, "rect_scale",
		Vector2(0,0), rect_scale, 2,
		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT,0)
	$Tween.start()

func _on_next_pressed():
	var current_slide_idx = getCurrentSlideIndex()
	if current_slide_idx < top_idx_limit:
		setCurrentSlide(slides[current_slide_idx+1])
		if slides[current_slide_idx+1].name == "agent_intro":
			low_idx_limit = getCurrentSlideIndex()+1
		if slides[current_slide_idx+1].name == "agent_movement":
			print("agent slide displayed")
			main_node.set_agent_panel("tutorial")
		
		if SKIP_TRY_AGAIN_SLIDES == true:
			if slides[current_slide_idx+1].name == "try_again_solo_training":
				_on_next_pressed()
			elif slides[current_slide_idx+1].name == "try_again_agent_training":
				_on_next_pressed()

func _on_previous_pressed():
	var current_slide_idx = getCurrentSlideIndex()
	if current_slide_idx > low_idx_limit:
		setCurrentSlide(slides[current_slide_idx-1])

func _on_solo_training_pressed():
	top_idx_limit = len(slides)-3
	print("Solo training engaged")
	if main_node:
		main_node.t = -5
		main_node.show_beggame_msg()
	_on_next_pressed()
	hide()

func _on_try_again_solo_pressed():
	print("Trying solo again")
	if main_node:
		main_node.t = -5
		main_node.show_beggame_msg()
	main_node.loading_agent(null)
	main_node.current_scenario._current_round_nb = 1
	hide()

func _on_agent_training_pressed():
	top_idx_limit = len(slides)-1
	
	if SKIP_TRY_AGAIN_SLIDES == true:
		low_idx_limit = top_idx_limit

	_on_next_pressed()
	print("Agent training engaged")
	if main_node:
		main_node.t = -5
		main_node.show_beggame_msg()
		main_node.set_agent_panel(main_node.loaded_agent._agent_name)
		main_node.set_help_status()
	hide()
	main_node.current_scenario._current_round_nb = 1

func _on_try_again_agent_pressed():
	print("trying again with the agent")
	if main_node:
		main_node.t = -5
		main_node.show_beggame_msg()
		main_node.set_agent_panel(main_node.loaded_agent._agent_name)
		main_node.set_help_status()
	hide()
	main_node.current_scenario._current_round_nb = 1

func setCurrentSlide(a_node):
	current_slide = a_node
	for other_node in slides:
		if other_node != a_node:
			other_node.hide()
		else:
			a_node.show()
	if getCurrentSlideIndex() == top_idx_limit:
		$next.hide()
	else:
		$next.show()

	if current_slide.name in ["solo_training","agent_training"]:
		var button = get_node(str(a_node.get_path())+"/"+current_slide.name)
		button.grab_focus()

func getCurrentSlideIndex():
	return slides.find(current_slide)

func _on_end_button_pressed():
#	main_node.current_scenario._current_round_nb = main_node.current_scenario._round_limit+2
##	main_node.end_wave_triggered = true
	main_node.next_step_scenario()
	queue_free()
