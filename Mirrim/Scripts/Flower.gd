extends Area2D


export (String) var next_level_path


onready var parent = get_parent()


func interact_player(body):
	Global.goto_scene(next_level_path)
