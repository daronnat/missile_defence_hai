extends Node2D

func _ready():
	$Panel/Button.disabled = true
	$Panel/story.hide()
	$Panel/visual_explanations.hide()

func get_sa_nodes_names():
	var result = []
	for v in get_tree().get_nodes_in_group("visualisation_description"):
		result.append(v.name)
	return result

func start(text):
	if text != "":
		if text in get_sa_nodes_names():
			hide_all_sa_explanation()
			var get_node = $Panel/visual_explanations.find_node(text)
			if get_node:
#				print("found",get_node)
				$Panel/visual_explanations.show()
#				get_node.show()
				get_node.show()
				$Panel/story.hide()
#			else:
#				prints(text,"not found in",get_node)
		else:
			hide_all_sa_explanation()
			$Panel/story.show()
			$Panel/visual_explanations.hide()
			$Panel/story.text = str(text)
	else:
		_on_Button_pressed()
	
func _on_Button_pressed():
	get_tree().paused = false
	queue_free()
	print("exit cover stories...")

func hide_all_sa_explanation():
	for n in $Panel/visual_explanations.get_children():
		n.hide()

func _on_CheckBox_toggled(button_pressed):
	if $Panel/Button.disabled == false:
		$Panel/Button.disabled = true
	else:
		$Panel/Button.disabled = false
