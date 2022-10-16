extends Node2D

func _ready():
	$Panel/content.text = ""
	var i = 0
	for info in IP.get_local_addresses():
		$Panel/content.text += str(i)+": "+str(info)+"\n"
		i+=1
