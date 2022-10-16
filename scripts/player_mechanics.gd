extends Sprite

onready var root_node_path = str(get_parent().get_path())
onready var focus_node = get_node(root_node_path+"/focus_status")
onready var neutral_crosshair = get_node(root_node_path+"/crosshair/crosshair_neutral")
onready var user_crosshair = get_node(root_node_path+"/crosshair/crosshair_user")
onready var user_crosshair_ctrl = get_node(root_node_path+"/crosshair/crosshair_user/control_user")

var dark_grey = Color("#303030")
var yellow = Color("#f7ca00")

func _ready():
	$text_box.self_modulate = dark_grey

func _on_id_received(id):
	$name.text = str(id)
#	$name.text = "You"

func _process(delta):
	if focus_node.get_focus_owner() == user_crosshair_ctrl:
		user_active()
	else:
		user_passive()

func user_active():
	self.z_index = 1
	$cable_user.self_modulate = yellow
	self.show()
	user_crosshair.show()
	neutral_crosshair.hide()

func user_passive():
	self.z_index = 0
	$cable_user.self_modulate = dark_grey
	user_crosshair.hide()
	user_crosshair_ctrl.release_focus()
	
