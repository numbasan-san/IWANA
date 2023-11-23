class_name CombatModel
extends Node

signal update_portrait

@export var portraits: Node
@export var sprites: Node

var current_portrait: TextureRect

func _ready():
	if portraits:
		set_portrait("Basic")

func set_portrait(name: String):
	name = name.to_pascal_case()
	if portraits.has_node(name):
		var old = current_portrait
		current_portrait = portraits.get_node(name)
		var new = current_portrait
		update_portrait.emit(old, new)
	else:
		printerr("CombatModel | This model doesn't have a portrait named " + name)
