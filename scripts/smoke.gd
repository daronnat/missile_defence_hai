extends Particles2D
onready var main_node = get_node("/root/Node2D")
signal smoke_spawn(id)

func _ready():
	self.connect("smoke_spawn",main_node,"_on_smoke_spawned")
	emit_signal("smoke_spawn",self)
