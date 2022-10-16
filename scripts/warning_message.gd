extends Panel

func set_text(a_str):
	$Label.text = str(a_str)

func _ready():
	set_text("test")
	$AnimationPlayer.play("blink")
	$AnimationPlayer.set_speed_scale(2.0)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
