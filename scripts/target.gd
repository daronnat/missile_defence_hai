extends Area2D
var explosion = preload("res://scenes/explosion.tscn")
var bullet_name = null

func _ready():
	$Tween.interpolate_property(self,"scale",
		scale*4,scale, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()

	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_on_timeout")
	timer.set_wait_time(5)
	timer.set_one_shot(true)
	timer.start()

func start(bullet):
	bullet_name = bullet

func _on_target_body_entered(body):
	if bullet_name == body:
		var expl = explosion.instance()
		expl.set_position(get_position()) # attempt to invoke explosion when missile hit
		get_parent().call_deferred("add_child",expl)
#		emit_signal("end_explosion")
		body.queue_free()
		queue_free()

func _on_timeout():
#	emit_signal("end_explosion")
	queue_free()
