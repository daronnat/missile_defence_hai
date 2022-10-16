extends Node2D

func _ready():
	$darkness.add_to_group("collision_mask")
