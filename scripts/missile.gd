extends KinematicBody2D

onready var main_node = get_node("/root/Node2D")
onready var agent_node = get_node("/root/Node2D/agent_avatar")
onready var logging_node = get_node("/root/Node2D/consent_form/logging_panel")
var target_status = ""
var threat = true
var not_seen_by_agent = false 
var LIFETIME = 90
var velocity = Vector2(0,0)
var adhoc_rot = 1.58 # arbitrary rotation based on the sprite imported
var initial_position = null
var starting_pos = null
var target_pos = null
var speed = null
var activation_delay = null
var _debug_hit_count = 0
#var DEFAULT_Z_INDEX = self.z_index

func start(starting_position,target_position,set_speed,set_delay=0.00000):
	starting_pos = starting_position
	target_pos = target_position
#	target
	speed = set_speed
	activation_delay = set_delay
	self.position = starting_position
	
#	line_to_target()
#	_draw()

signal missile_spawned(missile_name)
signal missile_deleted(missile_name)

func _ready():
	get_hypothetic_agent_targetting()
	$Sprite.rotate(adhoc_rot)
	$ghost_sprite.rotate(adhoc_rot)
	$ghost_sprite2.rotate(adhoc_rot)
	$ghost_sprite3.rotate(adhoc_rot)
	
	$ghost_sprite.hide()
	$ghost_sprite2.hide()
	$ghost_sprite3.hide()
	
	$unlocked_visual_infos/path.rotate(adhoc_rot)
	$CollisionShape2D.rotate(adhoc_rot)
	$blue_expl.hide()
	hide()
#	$visual_infos/priority.hide()
#	$visual_infos/eta.hide()
	self.connect("missile_spawned",main_node,"_on_missile_spawned")
	self.connect("missile_spawned",agent_node,"_on_missile_spawned")
	self.connect("missile_deleted",main_node,"_on_missile_deleted")
	self.connect("missile_deleted",agent_node,"_on_missile_deleted")
#	correct_visual_rotation()


#	print("THREAT STATUS:",threat)
	if threat == true:
		self.add_to_group("threatening_missiles")
	else:
		self.add_to_group("non_threatening_missiles")



	
#func line_to_target():
#	draw_line(self.global_position, target_pos, Color(255, 255, 255), 50)
#
#func _draw():
#	line_to_target()

func hit():
	var optimal_rank = agent_node.optimal_missile_ordering.find(self)
	var eta_rank = agent_node.eta_missile_ordering.find(self)
	var recency_rank = agent_node.recency_missile_ordering.find(self)
	var obscuring_status = main_node.current_scenario._hidden_missiles.has(self)
	logging_node.on_missile_hit_logging(self,self.position,optimal_rank,eta_rank,recency_rank,
	obscuring_status,threat,target_status)
	if main_node.has_method("modify_score"):
		main_node.modify_score(self)
	if indestructible == false:
		missile_destroyed()
	else:
		_debug_hit_count += 1

var duration_tween = 1

var has_sent_spawn_signal = false

func missile_destroyed():
	emit_signal("missile_deleted",self)

	$CollisionShape2D.disabled = true
	$Sprite/Particles2D.emitting = false
	
	$blue_expl.show()
	$tween_expl.interpolate_property($blue_expl,"scale",
		Vector2(0,0),Vector2(0.75,0.75), duration_tween, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween_expl.start()
	
	$tween.interpolate_property($Sprite,"scale",
		$Sprite.scale,Vector2(0,0), duration_tween, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	$tween.start()
	
	$ghost_sprite.hide()
	$ghost_sprite2.hide()
	$ghost_sprite3.hide()
	
	$expl_sound.play()

var indestructible = false
var target = null
var cpt_delta = 0

func manage_particle():
	if main_node and main_node.obscuring_instance:
		if self in main_node.obscuring_instance.hidden_missile:
			$Sprite/Particles2D.emitting = false
			$Sprite/Particles2D.hide()
		else:
			$Sprite/Particles2D.emitting = true
			$Sprite/Particles2D.show()
	else:
		$Sprite/Particles2D.emitting = true
		$Sprite/Particles2D.show()

var time_offset = 0

func _physics_process(delta):
	check_if_arrived()

	last_delta = delta
	cpt_delta+=delta
	
	if cpt_delta < activation_delay:
		hide()
	else:
		if has_sent_spawn_signal == false:
			emit_signal("missile_spawned",[self,speed])
			has_sent_spawn_signal = true
			show()
		
		if $blue_expl.visible == true:
			velocity = Vector2(0,0)
		
		elif (target_pos - position).length() > 5:
			velocity = (target_pos - position).normalized() * speed
	
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			if (collision.collider).get_name() == "TileMap":
				emit_signal("missile_deleted",self)
				queue_free()
			elif (collision.collider).get_name() == "explosion":
				move_and_collide(Vector2(0,0))
			else:
				add_collision_exception_with(collision.collider)

		if cpt_delta > LIFETIME and indestructible == false:
			emit_signal("missile_deleted",self)
			queue_free()
	
		look_at(target_pos)
		
#		if time_offset > 1:
#			correct_visual_rotation()
#			time_offset = 0
#		time_offset+=delta

var one_off_ghost_sprite_rotation = true
func correct_visual_rotation():
	$visual_infos.set_rotation(deg2rad(-self.rotation_degrees))

func _on_Tween_tween_completed(object, key):
	queue_free()

func check_if_arrived():
	if position.distance_to(target_pos) < 10:
		emit_signal("missile_deleted",self)
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("missile_deleted",self)
	queue_free()

###
var BIASED_VISUAL_COORDINATES = false
var biased_delta_coordinates = Vector2(0,0)
var last_delta = 0.016 # average for 60 fps game
func get_hypothetic_agent_targetting():
	# note: DOES NOT take into account agent's behaviour (mistake, lapses etc...)
	# only bias type (random / systematic)
	if agent_node and agent_node.current_agent:
		biased_delta_coordinates = agent_node.apply_agent_bias(self.position,
		agent_node.current_agent._bias_type,agent_node.current_agent._bias_intensity,self)
#		BIASED_VISUAL_COORDINATES = agent_node.current_agent._targeting
	$visual_infos.set_global_position(set_biased_visual_pos())

func set_biased_visual_pos():
	if BIASED_VISUAL_COORDINATES == false:
#		print("NON BIASED")
		return global_position
	else:
		return global_position + biased_delta_coordinates

### VISUAL AIDS BELOW ###

func detect_threat_box(LIMIT):
#	print(LIMIT)
#	get_subset_array
#	for m in agent_node.active_missiles:
#		print(m.threat)
	var n_missiles = get_subset_array(main_node.active_missiles,LIMIT)
#	print(n_missiles)
	if self in n_missiles:
		if threat == true and not_seen_by_agent == false:
			show_red_triangle()
		else:
			show_green_polygon()

func show_red_triangle():
#	if int($visual_infos/priorities/priority.text) in range(1,LIMIT+1):
	disable_green_polygon()
	$visual_infos/threat_shapes.show()
	$visual_infos/threat_shapes/red_triangle.show()
	$ghost_sprite.show()

func show_green_polygon():
#	if int($visual_infos/priorities/priority.text) in range(1,LIMIT+1):
	disable_red_triangle()
	$visual_infos/threat_shapes.show()	
	$visual_infos/threat_shapes/green_polygon.show()
	$ghost_sprite.show()

func disable_green_polygon():
	$visual_infos/threat_shapes/green_polygon.hide()
#	$ghost_sprite.hide()
	
func disable_red_triangle():
	$visual_infos/threat_shapes/red_triangle.hide()
#	$ghost_sprite.hide()
	
func disable_threat_shapes():
#	print("called")
	$visual_infos/threat_shapes.hide()
	$visual_infos/threat_shapes/green_polygon.hide()
	$visual_infos/threat_shapes/red_triangle.hide()
	$ghost_sprite.hide()

###

func set_priority(a_nb):
#	print(a_nb)
	$visual_infos/priorities/priority.text = str(stepify(a_nb,0.01))

func show_priority(limit):
	if $visual_infos/priorities/priority.text == "?":
		hide_priority()
	elif int($visual_infos/priorities/priority.text) <= limit and threat == true:
		$visual_infos/priorities.show()
		$visual_infos/priorities/priority.show()
		$visual_infos/priorities/priority/Panel.show()
	else:
		hide_priority()
#	$ghost_sprite2.show()

func hide_priority():
	$visual_infos/priorities.hide()
	$visual_infos/priorities/priority.hide()
	$visual_infos/priorities/priority/Panel.hide()
	$ghost_sprite2.hide()

###

func manage_prio_square():
	var new_scale
	var new_colour
	match int($visual_infos/priorities/priority.text):
		1:
			enable_prio_square()
			$visual_infos/threat_square/priority_square.rect_scale = Vector2(1,1)
			$visual_infos/threat_square/priority_square.self_modulate = Color(1,1,1,1)
		2:
			enable_prio_square()
			$visual_infos/threat_square/priority_square.rect_scale = Vector2(0.85,0.85)
			$visual_infos/threat_square/priority_square.self_modulate = Color(1,1,1,0.90)
		3:
			enable_prio_square()
			$visual_infos/threat_square/priority_square.rect_scale = Vector2(0.70,0.70)
			$visual_infos/threat_square/priority_square.self_modulate = Color(1,1,1,0.80)
		4:
			enable_prio_square()
			$visual_infos/threat_square/priority_square.rect_scale = Vector2(0.55,0.55)
			$visual_infos/threat_square/priority_square.self_modulate = Color(1,1,1,0.70)
		5:
			enable_prio_square()
			$visual_infos/threat_square/priority_square.rect_scale = Vector2(0.40,0.40)
			$visual_infos/threat_square/priority_square.self_modulate = Color(1,1,1,0.60)
		_:
			disable_prio_square()

func enable_prio_square():
	$visual_infos/threat_square.show()
	$visual_infos/threat_square/priority_square.show()
	$ghost_sprite3.show()

func disable_prio_square():
	$visual_infos/threat_square/priority_square.hide()
	$ghost_sprite3.hide()

###

func show_path(LIMIT):
	if int($visual_infos/priorities/priority.text) in range(1,LIMIT+1):
		$unlocked_visual_infos/path.show()

func hide_path():
	$unlocked_visual_infos/path.hide()

func get_subset_array(array,size):
	var new_array = []
	var i = 0
	while i < size and i < len(array):
		new_array.append(array[i])
		i+=1
	return new_array

### UNUSED VISUAL AIDS ###

#var ETA_OFFSET = 0.5
#func set_eta(a_nb):
#	$visual_infos/eta.text = str(stepify(a_nb,0.01)-ETA_OFFSET)
#
#func show_eta():
#	$visual_infos/eta.show()
#
#func hide_eta():
#	$visual_infos/eta.hide()


#func show_bounding_box():
#	$visual_infos/bounding_box.show()
#
#func hide_bounding_box():
#	$visual_infos/bounding_box.hide()
#
#func friendly_box():
#	$visual_infos/bounding_box.get_stylebox("panel","").set_border_color(Color("7d168600"))
#
#func neutral_box():
#	$visual_infos/bounding_box.get_stylebox("panel","").set_border_color(Color("7dffffff"))
#
#func enemy_box():
#	$visual_infos/bounding_box.get_stylebox("panel","").set_border_color(Color("7d811a00"))
