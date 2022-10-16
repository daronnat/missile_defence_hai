extends Node2D

#onready var checkbox = CheckBox.new()

func _ready():
	for x in range(0,10):
#		var a_checkbox = checkbox
		var a_checkbox = CheckBox.new()
		var new_position = Vector2(x*10,500)
		a_checkbox.rect_position = new_position
		print(new_position)
		add_child(a_checkbox)
	for child in self.get_children():
		print(child)
	
	
#	OS.shell_open("https://strathsci.qualtrics.com/jfe/form/SV_1z5esr21MaTR9UF")
