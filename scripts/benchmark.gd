extends Node2D

onready var missile_sce = preload("res://scenes/missile.tscn")
onready var friendly = preload("res://scenes/friendly_object.tscn")
var spawn_delay = 4
var duration = 60
var launch_benchmark = false
var all_fps = []
var perf_threshold = 30
func _ready():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	$progress/AnimationPlayer.play("blink")
	$duration_timer.set_wait_time(duration)
	$duration_timer.set_one_shot(true) # no loop
	$menu.show()
	$results.hide()
	$results/Panel/content.hide()
	$results/Panel/pass.hide()
	$results/Panel/fail.hide()

func get_fps():
	$perf_label.text = "Current FPS: "+str(Engine.get_frames_per_second())
	all_fps.append(Engine.get_frames_per_second())

func update_timer():
	$timer_label.text = "Time left: "+str(round($duration_timer.get_time_left()))

func _process(delta):
	if launch_benchmark == true:
		get_fps()
		spawn_automated_missile(delta)
		update_timer()

var delta_i = spawn_delay
func spawn_automated_missile(d):
	if delta_i >= spawn_delay:
		for c in [$city,$city2,$city3,$city4]:
			var missile = missile_sce.instance()
			missile.start($spawn.position,c.position,150,0)
			get_parent().add_child(missile)
		delta_i = 0
	delta_i += d

func _on_Button_pressed():
	print("Go")
	launch_benchmark = true
	spawn_friendly()
	$menu.hide()
	$duration_timer.start()

func spawn_friendly():
	var friendly_instance = friendly.instance()
	friendly_instance.position = $off_spawn.position
	friendly_instance.speed = 50
	get_parent().add_child(friendly_instance)

func _on_duration_timer_timeout():
	print("Stop")
	launch_benchmark = false
	show_result()

func show_result():
	$progress.hide()
	$noise_wall.hide()
	$results.show()
	
	if mean(all_fps) >= perf_threshold:
		$results/Panel/pass.show()
	else:
		$results/Panel/fail.show()
	
	
#	$results/Panel/content.hide()
#	$results/Panel/content.text = "Average FPS: "+str(mean(all_fps))
#	$results/Panel/content.text += "\nMin FPS: "+str(all_fps.min())
#	$results/Panel/content.text += "\nMax FPS: "+str(all_fps.max())
	
func mean(iterable):
	var sum = 0
	for v in iterable:
		sum += float(v)
	return sum/len(iterable)


