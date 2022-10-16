extends Control

signal send_game_mode(mode)

func _on_main_game_pressed():
	get_tree().change_scene("res://scenes/main.tscn")
	var main_node = get_tree().get_root().get_node("Node2D")
	self.connect('send_game_mode', main_node, "_on_game_mode_received")
	emit_signal("send_game_mode","main_game")

func _on_tutorial_toggled():
	emit_signal("send_game_mode","tutorial")
	get_tree().change_scene("res://scenes/main.tscn")
