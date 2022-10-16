extends Particles2D

func _ready():
	$Sprite/AnimationPlayer.play("expl_stage")
	self.one_shot = true
	$explosion_sound.play()

var cpt_delta = 0
var timeout_limit = 3

onready var initial_energy = $Light2D.energy 

func _process(delta):
	cpt_delta+=delta
	var energy_step =  initial_energy / (timeout_limit*50) # if about 50fps
	$Light2D.energy -= energy_step
	
	if cpt_delta >= timeout_limit:
		queue_free()
