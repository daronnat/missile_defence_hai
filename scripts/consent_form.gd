extends Panel

var path_logs = "user://LOGS"
#var path_logs = "res://LOGS"
var active_log_path

signal send_id

onready var root_node_path = str(get_parent().get_path())
onready var main_node = get_node(root_node_path)
onready var user_node = get_node(root_node_path+"/user_avatar")
onready var main_menu = get_node(root_node_path+"/main_menu")
onready var logging_node = get_node(root_node_path+'/consent_form/logging_panel')
onready var main_menu_tutorial = get_node(root_node_path+"/main_menu/tutorial")

var auto_consent = false # if true, bypass consent
var auto_id = false

func _ready():
	createFolderIfDoesntExist(path_logs)
	$id_panel.hide()
	$warning.hide()
	main_menu.hide()
	
	self.connect("send_id",user_node,"_on_id_received")
	self.connect("send_id",logging_node,"_on_id_received")
	self.connect("send_id",main_node,"_on_id_received")
	
	if auto_consent == true:
		only_show_loading()
	
	if auto_id == false:
		$id_panel/next_button.hide()

func only_show_loading():
	for c in self.get_children():
		if c.name == "loading":
			c.show()
		else:
			c.hide()

var t = 0
func _process(delta):
	if auto_consent == true:
		t+=delta
		if t > 1.5:
			auto_consent = false
			_on_next_button_pressed()

func createFolderIfDoesntExist(folder_path):
	var dir = Directory.new()
	var is_dir = dir.dir_exists(folder_path)
	if is_dir == false:
		print("Creating LOGS folder...")
		dir.make_dir(folder_path)
		var file = File.new() 
		file.open(folder_path+"/.gdignore",file.WRITE) # add gdignore file
		file.close()
	else:
		print("LOGS folder found.")
	
	prints("TEST if user is persistent:",OS.is_userfs_persistent())

#var temp = 0
#var one_time = true
#func _process(delta):
#	temp+=delta
#	if temp>1 and one_time == true:
#		one_time =false
#		if auto_consent == true:
#			automatic_consent()

func _on_accept_pressed():
	$refuse.pressed = false
	$accept.pressed = true
	$id_panel.show()
	$warning.hide()
	focus_neighbour_bottom = $id_panel/next_button.get_path()

func _on_refuse_pressed():
	$accept.pressed = false
	$refuse.pressed = true
	$warning.show()
	$id_panel.hide()
	focus_neighbour_bottom = ""
	
var add_test_missile = false
var entered_id
func _on_next_button_pressed():
	self.hide()
	entered_id = $id_panel/participant_id.text
	active_log_path = logging_node.initiate_log_folder(entered_id,path_logs)
#	prints("initiating log path:",active_log_path)
#	logging_node.log_consent(active_log_path)
#	logging_node.send_oldest_request()
#	main_node.show_main_menu()
	main_node.start_folder_count_process()
	
#	prints(root_node_path+"/main_menu/city_test",root_node_path+"/main_menu/city_test")
	# the following is used to "preload" an instance where a missile hit a city
	if add_test_missile != false and auto_consent != true:
		main_node.spawn_missile(root_node_path+"/main_menu/city_test",1,root_node_path+"/main_menu/city_test")


func _on_participant_id_text_changed(new_text):
	if new_text != "":
		$id_panel/next_button.show()
	else:
		$id_panel/next_button.hide()
#	$id_panel/participant_id.show()
#		$id_panel/participant_id.show()
		
