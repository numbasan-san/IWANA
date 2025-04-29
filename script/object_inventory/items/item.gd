
extends Resource

class_name Item

@export var name : String = ''
@export var texture : Texture2D
@export var stack : int = 99
@export var effect : Effect

func _init():
	effect = preload("res://combat/effects/effect.gd").new()
