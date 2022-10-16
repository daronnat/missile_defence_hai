extends Node2D

var speed = -100
var velocity = Vector2()
var limit_x

func _ready():
	$first_clouds.add_to_group("collision_mask")
	$second_clouds.add_to_group("collision_mask")
	limit_x = get_viewport().size.x
	limit_x = 1920
	velocity = Vector2(speed,0)

func _process(delta):
	var all_clouds = [$first_clouds,$second_clouds]
	for c in all_clouds:
		if c.get_position().x < -limit_x:
			c.position.x=limit_x
		else:
			c.position+=velocity*delta
