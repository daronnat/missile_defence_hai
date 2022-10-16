extends Area2D

func set_position(a_vector):
	self.global_position = a_vector
#	pass
#	print(position,global_position)

func _ready():
	show()
	$tween_noise.interpolate_property(self, "modulate",
		Color(1,1,1,0), Color(1,1,1,1), 2,
		Tween.TRANS_BACK, Tween.EASE_IN,0)
	$tween_noise.start()
	
func set_random_seed(x,y):
	var new_seed = int(rand_range(x,y))
	$noise.texture.noise.seed = new_seed

var i = 0
func _process(delta):
	i += delta
	if i > 0.5:
		set_random_seed(1,100)
		i = 0

func _on_tween_noise_tween_completed(object, key):
	pass

#	$warning_label.show()
#	$tween_text.interpolate_property($warning_label, "rect_scale",
#			Vector2(0,0), $warning_label.rect_scale, 1.5,
#			Tween.TRANS_EXPO, Tween.EASE_OUT_IN,0)
#	$tween_text.start()

#func _on_tween_text_tween_completed(object, key):
#	$warning_label.hide()
#	$tween_noise.interpolate_property($wall, "modulate",
#			Color(1,1,1,0), Color(1,1,1,1), 1.0,
#			Tween.TRANS_BACK, Tween.EASE_IN,0)
#	$tween_noise.start()
#	$wall.show()
