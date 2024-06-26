class_name SpriteContainer
extends CharacterContainer

# TODO: rewrite to do it better, this is just a quick fix
@export var directional: Node2D

# The specific sprite that appears on screen. While the character should
# generally stay in this container until being defeated, the sprite can change
# for various reasons
var sprite: Sprite2D

# Adds the character to this container and moves the sprite to show it on screen
func set_character(new_character: Character = null):
	super.set_character(new_character)
	var model = new_character.combat_model
	_change_sprite(null, model.current_sprite)
	model.update_sprite.connect(_change_sprite)
	

# Clears the container
func remove_character():
	if character:
		character.combat_model.update_sprite.disconnect(_change_sprite)
		_change_sprite(null, null)
	super.remove_character()

# Changes the direction towards which sprites in this container will be looking.
# A negative number makes them look left (assuming original sprites are looking
# left, when the direction is negative we must leave the actual scale value of
# the sprite positive. We do this to mantain a standard that negative numbers
# represent left).
func set_direction(dir: int):
	# If dir is left and sprite is looking right, or if dir is right and sprite
	# is looking left, we flip the value
	if (dir < 0 and directional.scale.x < 0
		or dir >= 0 and directional.scale.x > 0):
		directional.scale.x *= -1

# This function should be called when a signal is emited indicating that the
# character's combat sprite has changed
func _change_sprite(old: Sprite2D, new: Sprite2D):
	# We will add a duplicate of the sprite because we don't need to store
	# changes to it. For the same reason we can free it when not using it as
	# the original will be preserved
	if sprite:
		sprite.free()
		sprite = null
	if new:
		sprite = new.duplicate()
		directional.add_child(sprite)
