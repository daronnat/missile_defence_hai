extends Node2D

func _ready():
	$Area2D.add_to_group("collision_mask")
	
#	vel = Vector2(00,500)
#var vel = Vector2(0,0)
#func _process(delta):
#	vel.x += 100*delta
#	$spotlight.set_position(vel)
