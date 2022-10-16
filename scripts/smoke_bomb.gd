extends Area2D

var cpt_delta = 0
var dur_tween = 2
#onready var fog =  preload("res://scenes/fog.tscn")
onready var fog =  preload("res://scenes/smoke_area.tscn")
var rotate_center = false
func _ready():
	#explode()
	pass
	#print(get_viewport_rect().size/2)
	

func _process(delta):
	cpt_delta += delta
	if rotate_center == true:
		$center_bomb.rotate(cpt_delta)

func explode():
	print("explosion")
	$tween_explode.interpolate_property(self,"modulate",
		Color("ffffff"), Color("787878"), dur_tween, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$tween_explode.start()

func _on_Tween_tween_completed(object, key):
	print("explosion completed")
	rotate_center = true
	var fog_instance = fog.instance()
	fog_instance.position = position
	get_parent().add_child(fog_instance)
	
	
	
	
	
	
	
	
	
