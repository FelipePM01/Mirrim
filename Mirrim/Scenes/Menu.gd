extends Node2D


func _on_BtnPlay_pressed():
	Global.goto_scene("res://Scenes/Levels/Level1.tscn")


func _on_BtnExit_pressed():
	get_tree().quit()
