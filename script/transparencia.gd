class_name TransparencyControl
extends Area2D

@export var transparency_value = 0.15

func enable_transparency():
	$"../Sprite2D".modulate = Color(1, 1, 1, transparency_value)


func disable_transparency():
	$"../Sprite2D".modulate = Color(1, 1, 1, 1)
