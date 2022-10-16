extends Area2D

onready var tween_node = get_node("effect")
onready var sound = get_node("explosion_sound")
onready var shape = get_node('CollisionShape2D')
onready var agent_node = get_node('../agent_avatar')
onready var main_node = get_node("/root/Node2D")

signal end_explosion
#var set_radius = 35 # set the radius of the explosion # 720p size
#var set_radius = 53 # size when converted to 1080p
var set_radius = 31 # size to make it match the crosshair radius
var tween_duration = 0.55
var cnt_delta = 0

var hit_check = true

var colors = [Color('#2679ff'),Color('#fc0a0a'),Color('#b51575')]

func _ready():
	shape.get_shape().radius = set_radius
	tween_node.interpolate_property(self,"scale",
		Vector2(1,1),Vector2(1,1),tween_duration,
		Tween.TRANS_CIRC,Tween.EASE_OUT)
	tween_node.start()
	sound.play()
#	self.connect("shot_fired",get_crosshair,"_on_shot_fired")
	self.connect("end_explosion", agent_node, "on_explosion_ended")
	
#	for v in main_node.get_children():
#		print(v.name)
	
	if main_node.has_node('new_graph'):
#		print("yes")
		self.connect("end_explosion", main_node.get_node('new_graph'), "on_explosion_ended")

#	print(">>>>",agent_node)

var node_hit = []

func _process(delta):
	cnt_delta += delta
	if cnt_delta >= 0.04:
		cnt_delta = 0
		update()
		# randomize()
	var collision = get_overlapping_bodies()
	if collision:
		for node in collision:
			if not node in node_hit and node.has_method("hit"):
				node.hit()
				node_hit.append(node)
#				print("hit missile")
				main_node.update_missile_success(true)
				hit_check = false

func _on_effect_tween_completed(object, key):
	if hit_check:
		main_node.update_missile_success(false)
#		print("missed missile")
	emit_signal("end_explosion")
	queue_free()

func _draw():
	var rand_color = colors[rand_range(0, colors.size())]
	draw_circle(shape.position, shape.get_shape().radius*shape.scale.x, rand_color)
