
extends Area2D

@export var escena : String

func change_zone():
	get_tree().change_scene_to_file("res://Escenas/Zonas/" + escena + ".tscn")
