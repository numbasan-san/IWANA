
extends Resource
class_name Item

@export var name: String = ""
@export var texture : Texture2D
@export var max_stack: int = 999
@export var effect: Effect
@export var cost: int = 1
@export var sellable: bool = true
@export var consumable: bool = true
@export var description: String = ""
@export var rarity: int = 1
@export var item_type: String = "consumable"


func _init():
	effect = preload("res://combat/effects/effect.gd").new()
