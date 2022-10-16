extends Node2D

func set_position(a_vector):
	self.global_position = a_vector
	$wall.add_to_group("collision_mask")

func _ready():
#	set_position(Vector2(0,500))
	$wall.show()

#var i = 0

#func set_random_seed(x,y):
#	var new_seed = int(rand_range(x,y))
#	$wall/noise.texture.noise.seed = new_seed

#func _process(delta):
#	i += delta
#	if i > 1:
#		set_random_seed(1,100)
#		i = 0

