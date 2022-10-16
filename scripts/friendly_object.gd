extends KinematicBody2D

var velocity = Vector2()
var speed = 150
onready var target = $end.global_position
#var moving = false
var seen_t = []
var was_hit = false
onready var main_node = get_node("/root/Node2D")

signal friendly_spawned(object_name)
signal friendly_deleted(object_name)

func random_straight_position():
	var new_y = main_node.RNG.randi_range(100,800)
	position.y = new_y
	prints("new position:",position)

func _ready():
	self.connect("friendly_spawned",main_node,"_on_friendly_spawned")
	self.connect("friendly_deleted",main_node,"_on_friendly_deleted")
	emit_signal("friendly_spawned",self)
	random_straight_position()

func _physics_process(delta):
	move_plane(delta)

func move_plane(delta):
	if (target - position).length() > 5:
		velocity = (target - position).normalized() * speed
	else:
		plane_arrived()
	rotation = velocity.angle()
	
	if was_hit == false:
		var collision = move_and_collide(velocity*delta)
		if collision:
			if (collision.collider).get_name() in ["explosion","missile"]:
				hit()
			else:
				add_collision_exception_with(collision.collider)

func hit():
	was_hit = true
	emit_signal("friendly_deleted",self)
	$CollisionShape2D.disabled = true
	$animation.show()
	$animation.play("explode")

func plane_arrived():
	print("arrived")
	queue_free()

func _on_animation_animation_finished():
	queue_free()
