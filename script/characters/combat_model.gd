class_name CombatModel
extends Node

signal update_portrait
signal update_sprite

@onready var character: Character = get_parent()

@export var portraits: Node
@export var sprites: Node

# The portrait that will be shown in the party and skills menus.
var current_portrait: TextureRect
# The sprite that will be shown in the main combat area.
# TODO: this might need to be changed to handle animations for the skills, being
# hit, etc
var current_sprite: Sprite2D

func _ready():
	if portraits:
		for p in portraits.get_children():
			p.hide()
		set_portrait("Basic")
	if sprites:
		for s in sprites.get_children():
			s.hide()
		set_sprite("Idle")

# Sets the current portrait to one defined in the portraits list
func set_portrait(name: String):
	name = name.to_pascal_case()
	if portraits.has_node(name):
		var old = current_portrait
		if old:
			old.hide()
		current_portrait = portraits.get_node(name)
		var new = current_portrait
		new.show()
		update_portrait.emit(old, new)
	else:
		printerr("CombatModel | " + character.name + " doesn't have a portrait " \
		 + "named " + name)

# Sets the current sprite to one defined in the sprites list
func set_sprite(name: String):
	name = name.to_pascal_case()
	if sprites.has_node(name):
		var old = current_sprite
		if old:
			old.hide()
		current_sprite = sprites.get_node(name)
		var new = current_sprite
		new.show()
		update_sprite.emit(old, new)
	else:
		printerr("CombatModel | " + character.name + " doesn't have a sprite " \
			+ "named " + name)
