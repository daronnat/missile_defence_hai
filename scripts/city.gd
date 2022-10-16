extends Area2D

onready var damage = preload("res://scenes/city_explosion.tscn")
onready var smoke = preload("res://scenes/smoke.tscn")
onready var main_node = get_node("/root/Node2D")
var base_hp = 100
var hp = base_hp

signal send_building_hit(city_id)
onready var initial_color = $animated_city.modulate

func _on_reset_city():
	hp = base_hp
	$Light2D.show()
	$Light2D.energy = 1
	$animated_city.show()
	$destroyed_city.hide()
	$CollisionPolygon2D.disabled = false
	$animated_city.modulate = initial_color

func _ready():
	$animated_city/AnimationPlayer.play("city_ok")
	$health.hide()
	self.connect("send_building_hit",main_node,"_on_send_building_hit")

func degrading_city(damaged_position): # control the visual aspect of a city that got hit
	emit_signal("send_building_hit",self)
	if $Light2D.energy > 0.2:
		$Light2D.energy -= 0.2
		initial_energy = $Light2D.energy
	$animated_city.modulate = $animated_city.modulate - Color(0.2,0.2,0.2,0)
	
	var smoke_instance = smoke.instance()
	smoke_instance.set_global_position(damaged_position)
	get_parent().add_child(smoke_instance)

onready var initial_energy = $Light2D.energy

var temp_cpt = 0
# contact reports and contact monitor must be enabled either in code/inspector for the collisions to work
var cpt_delta = 0
func _process(delta):
	temp_cpt += delta
	if temp_cpt > 0.25 and initial_energy > 0.1:
		var rand_idx = rand_range(0,2)
		var energy_array = [-0.05,0.05]
		$Light2D.energy = initial_energy + energy_array[int(rand_idx)]
		temp_cpt = 0
	$Light2D.enabled = false
	cpt_delta += delta
	var collision = get_overlapping_bodies()
	if collision:
		var dmg = damage.instance()
		if collision[0].has_method("hit"):
			var pos_collision = collision[0].get_global_position()
			collision[0].queue_free()
			dmg.set_position(pos_collision)
			get_parent().add_child(dmg)
			degrading_city(pos_collision)
		elif collision[0].has_method("a_bullet"):
			pass
#			print("REMOVING BULLET FROM CITY")
#			collision[0].remove_bullet()

func _on_blink_tween_completed(object, key):
	pass 
