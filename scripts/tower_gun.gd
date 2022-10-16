extends StaticBody2D

onready var sound = get_node("fire_sound") 
onready var get_crosshair = get_node("/root/Node2D/crosshair")
onready var get_agent = get_node("/root/Node2D/agent_avatar")
onready var get_node = get_node("/root/Node2D")
onready var Bullet = preload("res://scenes/bullet.tscn")
onready var target_scene = preload("res://scenes/target.tscn")
onready var cross_pos = get_crosshair.get_position()

var _timer = Timer.new()
var can_shoot = true
var infinite_ammo = false
var ammo_qt = 5

var delay_btw_shots = 0.7
signal shot_fired

func _ready():
	self.connect("shot_fired",get_crosshair,"_on_shot_fired")
	self.connect("shot_fired",get_agent,"_on_shot_fired")
	self.connect("shot_fired",get_node,"_on_shot_fired")
	add_child(_timer)

func get_ammo_info():
	if get_node:
		ammo_qt = get_node.current_scenario._ammo
		if str(ammo_qt) == "UNLIMITED":
			infinite_ammo = true
	if infinite_ammo == false:
		get_node("../ammo_label").show()
		get_node("../ammo_label").text = str(ammo_qt)
	else:
		ammo_qt = "UNLIMITED"
		get_node("../ammo_label").hide()
		get_node("../ammo_label").text = "∞"

func start_timer():
	_timer.set_wait_time(delay_btw_shots)
	_timer.set_one_shot(true) # no loop
	_timer.start()

func _process(delta):
	if _timer.is_stopped():
		can_shoot = true
	else:
		can_shoot = false
	cross_pos = get_crosshair.get_position()
	look_at(cross_pos)
	
	if get_node.current_scenario and get_node.current_scenario._controls_enabled == true:
		if Input.is_action_just_pressed("fire_gun"):
			shoot()

var shot_cnt = 0
func shoot():
	if can_shoot == true:
		if infinite_ammo == true:
			fire_bullet()
			shot_cnt+=1 # counts all of the shots so far
		elif ammo_qt > 0:
			ammo_qt-=1
			fire_bullet()
			shot_cnt+=1
		else:
			print("Out of ammo!")

func fire_bullet():
	emit_signal("shot_fired")
	var b = Bullet.instance()
	var target_instance = target_scene.instance()
	target_instance.start(b)
	target_instance.set_position(cross_pos)
	get_parent().add_child(target_instance)
	$tween_barrel.interpolate_property(self, "modulate",
		Color("ff0000"), Color("ffffff"), delay_btw_shots,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT,0)
	$tween_barrel.start()
	b.start($muzzle.global_position, rotation)
	get_parent().add_child(b)
	sound.play()
	start_timer()
	can_shoot=false
	if not infinite_ammo:
		get_node("../ammo_label").text = str(ammo_qt)
