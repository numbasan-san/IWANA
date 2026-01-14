class_name TransparencyControl
extends Area2D

@export var transparency_value = 0.15
@export var sprite: Sprite2D

func enable_transparency():
	sprite.modulate = Color(1, 1, 1, transparency_value)


func disable_transparency():
	sprite.modulate = Color(1, 1, 1, 1)
