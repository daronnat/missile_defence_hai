extends Node2D

var delay = 14.5
var set_delay = true
var i = 0

func _ready():
	$cloud/AnimationPlayer.play("moving_top")
#	$cloud2/AnimationPlayer.play("animation_bottom")

func _process(delta):
	if set_delay == true:
		i+=delta
		if i > delay:
			set_delay = false
			$cloud2/AnimationPlayer.play("animation_bottom")
