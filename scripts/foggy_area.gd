extends Area2D

#var fog = preload("res://scenes/fog.tscn")
var visual_type = "fog"
var visual
#var shadow = null
#var fog = preload("res://scenes/fog_shader.tscn")
var SPACING = 35 # will determine the number of quadrant for the foggy area
var timing = [1,30] # to change and check timing of main scene instead?
var fog_t = 0
var fog_activated = false
var moving = true
onready var viewport = get_viewport().get_visible_rect().size

func _process(delta):
#	$li
	fog_t+=delta
	
	
#	if visual_type == "fog":
#		visual = 
#	elif visual_type == "darkness":
#		pass
#
	set_duration_fog(fog_t,timing)
#	print(fog_t)

func spawn_fog():
	var area_position = $foggy_area/CollisionShape2D.position
	var area_size = $foggy_area/CollisionShape2D.shape.extents
	var spawn_start = Vector2((area_position.x-area_size.x)+SPACING/2,
	area_position.y-area_size.y+SPACING/2)
	$foggy_area/test_sprite.position = spawn_start
	var i = 0
	for x_n in range(0,int(round(area_size.x/SPACING))):
		for y_n in range(0,int(round(area_size.y/SPACING))):
			i +=1
			var a_fog = fog.instance()
			a_fog.set_position(Vector2(spawn_start.x+x_n*SPACING*2,
			spawn_start.y+y_n*SPACING*2))
			add_child(a_fog)
	print("Done. Number of fog unit(s) spawned:",i)
	
	var start_pos = Vector2(global_position.x+viewport.x,global_position.y)
	var end_pos = Vector2(global_position.x-viewport.x,global_position.y)
#	moving_fog(start_pos,end_pos,timing[1])

func despawn_fog():
	$foggy_area/despawn_tween.interpolate_property(self, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,0)
	$foggy_area/despawn_tween.start()

func set_duration_fog(current_t,timing):
	if int(current_t) > timing[0] and int(current_t) < timing[1] and fog_activated == false:
		spawn_fog()
		fog_activated = true
	elif int(current_t) > timing[1] and fog_activated == true:
		despawn_fog()
		fog_activated = false

func moving_fog(start,end,time):
	prints("Moving the fog from",start,"to",end,"in",time,"second(s).")
	$foggy_area/move_fog_tween.interpolate_property(self, "global_position",
		start, end, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,0)
	$foggy_area/move_fog_tween.start()

func _on_despawn_tween_tween_completed(object, key):
	print("fog disappeared")
	queue_free()
