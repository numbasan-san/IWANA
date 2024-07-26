class_name CombatModel
extends Node

signal update_portrait
signal update_sprite
signal sprite_animation_ended

var character: Character

@export var portraits: Node
@export var sprites: Node
@export var combat_animation: AnimatedSprite2D

# The portrait that will be shown in the party and skills menus.
var current_portrait: TextureRect

# When in combat mode, this point to the SpriteContainer this character is
# occupying. Outside of combat mode this should be null
var current_container: SpriteContainer = null

func _ready():
	if portraits:
		for p in portraits.get_children():
			p.hide()
		set_portrait("Basic")
	if combat_animation:
		set_sprite("idle")

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
	elif character:
		printerr("CombatModel | " + character.name + " doesn't have a portrait " \
		 + "named " + name)

# Sets the current sprite to one defined in the sprites list
func set_sprite(sprite_name: String):
	sprite_name = sprite_name.to_snake_case()
	if has_sprite(sprite_name):
		combat_animation.animation = sprite_name
		update_sprite.emit(combat_animation)
	elif character:
		printerr("CombatModel | " + character.name + " doesn't have a sprite " \
			+ "named " + sprite_name)

func has_sprite(sprite_name: String):
	sprite_name = sprite_name.to_snake_case()
	return combat_animation and combat_animation.sprite_frames.has_animation(sprite_name)
