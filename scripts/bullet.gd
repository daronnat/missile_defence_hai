extends KinematicBody2D

# WARNING: One way collision set (to avoid bullet hitting missiles before explosion)

var speed = 1250
var velocity = Vector2()
onready var agent_node = get_node('../agent_avatar')
signal end_explosion

func _ready():
	self.connect("end_explosion", agent_node, "on_explosion_ended")

func start(pos, dir):
	rotation = dir
	position = pos
	velocity = Vector2(speed, 0).rotated(rotation)

func a_bullet(): # placeholder, may not be relevant anymore
	pass

func remove_bullet():
	emit_signal("end_explosion")
	queue_free()
	
var add_delta = 0
func _physics_process(delta):
	add_delta += delta
	if add_delta >= 10: # delete a bullet after 10s
		print("bullet timeout")
#		queue_free()
		remove_bullet()
	var collision = move_and_collide(velocity * delta)
	if collision: #
#		prints(">>>>>",collision.collider,collision.collider.get_name())
		if (collision.collider).get_name() == "TileMap":
#			queue_free()
			remove_bullet()

# the following works, but every bullet exploding on screen count as an exit
func _on_VisibilityNotifier2D_screen_exited():
	remove_bullet()
#	queue_free()
