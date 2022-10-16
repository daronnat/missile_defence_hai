extends Node2D

onready var main_node = get_node("/root/Node2D")
onready var viewport = get_viewport().get_visible_rect().size
var area_covered = Vector2(0,0)
var visual_activated = false
var visual_type
var loaded_visual
var loaded_instance
var anim_delay = 0

func _ready():
	var get_anim = $large_warning/AnimationPlayer.get_animation("blink")
	if $large_warning/AnimationPlayer.playback_speed != 0:
		anim_delay = get_anim.length/$large_warning/AnimationPlayer.playback_speed
#		print(anim_delay)
#	prints("playback speed:",$large_warning/AnimationPlayer.playback_speed)
#	prints("animation lenght:",get_anim.length)

func display_warning(a_str):
	loaded_instance.hide()
	$large_warning/warning_label.text = str(a_str)
#	$large_warning.show() # to uncomment for showing a warning message
	$large_warning/AnimationPlayer.play("blink")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	$large_warning.hide()
	loaded_instance.show()
	manage_spotlight(true,visual_type)

func _process(delta):
	get_hidden_missiles()

var hidden_missile = []
func get_hidden_missiles():
	hidden_missile = []
	if not loaded_instance:
		return false
	var get_masks = loaded_instance.get_tree().get_nodes_in_group("collision_mask")
	if get_masks:
		for m in get_masks:
			for obj in m.get_overlapping_bodies():
				if "missile" in obj.get_name():
					hidden_missile.append(obj)

func set_visual_info(to_load):
	visual_type = to_load
	match to_load:
		"noise_top":
			loaded_visual = preload("res://scenes/noise_enhanced.tscn")
		"noise_bottom":
			loaded_visual = preload("res://scenes/noise_enhanced.tscn")
		"two_clouds":
			loaded_visual = preload("res://scenes/moving_cloud_wall.tscn")
		"full_darkness":
#			loaded_visual = preload("res://scenes/full_darkness.tscn")
			loaded_visual = preload("res://scenes/dark_sprite.tscn")

func manage_visual_timing(current_t,timing):
#	print(current_t,timing)
	if current_t > timing[0]-anim_delay and current_t < timing[1] and visual_activated == false:
		spawn_visual(visual_type)
		visual_activated = true
		main_node.current_scenario.set_obscuring_status(visual_activated)
		print("display visual")
	elif current_t > timing[1] and visual_activated == true:
		print("despawing visual")
		despawn_visual(visual_type)
		visual_activated = false
		main_node.current_scenario.set_obscuring_status(visual_activated)
#	prints("visual activated:",visual_activated,current_t,timing[1])

func spawn_visual(type):
		if type == "noise_bottom":
			loaded_instance = loaded_visual.instance()
			loaded_instance.set_position(Vector2(0,375))
			display_warning("disuptions, incoming!")
			add_child(loaded_instance)
		elif type == "noise_top":
			loaded_instance = loaded_visual.instance()
			loaded_instance.set_position(Vector2(0,0))
			display_warning("disuptions, incoming!")
			add_child(loaded_instance)
		elif type == "full_darkness":
			loaded_instance = loaded_visual.instance()
#			modulate_background()
			display_warning("sudden darkness, incoming!")
			add_child(loaded_instance)
		elif type == "two_clouds":
			loaded_instance = loaded_visual.instance()
			display_warning("clouds, incoming!")
			add_child(loaded_instance)
		
#		manage_spotlight(true,type)

func modulate_background():
	var get_background = get_node("/root/Node2D/background")
	$modulate.interpolate_property(get_background, "self_modulate",
		get_background.self_modulate, Color("8a8a8a"), 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,0)
	$modulate.start()

func demodulate_background():
	var get_background = get_node("/root/Node2D/background")
	$modulate.interpolate_property(get_background, "self_modulate",
		get_background.self_modulate, Color("ffffff"), 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,0)
	$modulate.start()

func manage_spotlight(status,type):
	if type == "full_darkness":
		main_node.get_node("crosshair/Light2D").enabled = status

func despawn_visual(type):
	print(type," despawning")
	$despawn_tween.interpolate_property(loaded_instance, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,0)
	$despawn_tween.start()
#	if type == "full_darkness":
#		demodulate_background()

func fade_in(node,time):
	prints("fade in",node,"in",time,"second(s).")
	for shader in ["shader_up","shader_down"]:
		var get_shader = loaded_instance.find_node(shader)
		$fade_in_tween.interpolate_property(get_shader, "energy", 
			0, get_shader.energy, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,0)
		$fade_in_tween.start()

func _on_despawn_tween_tween_completed(object, key):
	loaded_instance.queue_free()
	loaded_instance = null
	manage_spotlight(false,visual_type)



