class_name DialogContents
extends Control

enum Position { LEFT, CENTER, RIGHT, NONE = -1 }

@export var background_folder: String

@export var background: TextureRect
@export var left_area: Control
@export var center_area: Control
@export var right_area: Control

@export var name_label: Label
@export var text_label: Label

# Adds the grafic associated with a character to the left, center or right of
# the character area
# If the character had already been added to that side, it does nothing
# If the character had already been added to a different side, it switches sides
func add_character(character: Character, pos: Position):
	var model: DialogModel = character.dialog_model
	
	# If the character doesn't have a dialog model, generally because it isn't
	# designed to appear in dialogs, or it's already in that position, nothing
	# is done
	if not model or model.dialog_position == pos:
		return
	
	# If we reach this point, we have to remove the model from an area. After
	# calling this function the model will be outside of the screen and attached
	# to its character
	remove_character(character)
	character.remove_child(model)
	# TODO: add code to handle animated transitions
	var target_area = Control
	var target_position: Position
	match pos:
		Position.LEFT:
			target_area = left_area
			target_position = Position.LEFT
			model.look_right()
		Position.CENTER:
			target_area = center_area
			target_position = Position.CENTER
			model.look_right()
		Position.RIGHT:
			target_area = right_area
			target_position = Position.RIGHT
			model.look_left()
	
	target_area.add_child(model)
	model.dialog_position = target_position
	model.show()
	_reorder(target_area)

# Removes the model associated with the character if it already is in the
# character area. If reorder is true the remaining characters are moved so that
# they are evenly spread. It can be left as false if one desires to reordem
# later, for example if one wants to remove several before reordering
func remove_character(character: Character, reorder: bool = true):
	var model: DialogModel = character.dialog_model
	if not model or model.dialog_position == Position.NONE:
		return
	var area: Control
	match model.dialog_position:
		Position.LEFT:
			area = left_area
		Position.CENTER:
			area = center_area
		Position.RIGHT:
			area = right_area
	model.hide()
	model.get_parent().remove_child(model)
	if reorder:
		_reorder(area)
	character.add_child(model)
	model.dialog_position = Position.NONE

# Removes all character models present in an area
func empty_area(area: Control):
	for model in area.get_children():
		if model is DialogModel:
			remove_character(model.character, false)
	_reorder(area)

# Removes all characters in the dialog screen
func empty():
	empty_area(left_area)
	empty_area(center_area)
	empty_area(right_area)

# Changes the background image of the dialog screen. If empty, it removes the
# background to see through to the screen below. If the image doesn't exist, an
# error is thrown and nothing is changed
func change_background(image_name: String):
	if not image_name:
		background.hide()
		return
	
	# If the image name doesn't have an extension, we assume .png
	if not image_name.get_extension():
		image_name = image_name + ".png"
	var texture = load("res://".path_join(background_folder).path_join(image_name))
	if not texture:
		printerr("DialogContents | Couldn't find an image with name "\
			+ image_name.get_basename().get_file())
		return
	background.texture = texture
	background.show()

# Changes the lines of dialogo on screen and / or who says them
func change_dialog(who: String, what: String):
	name_label.text = who
	text_label.text = what

# Changes the image being shown for a given character. The image must be
# associated with a Sprite2D node in the dialog model
func change_image(character: Character, target_image: String):
	character.dialog_model.change_image(target_image)

# Changes the position of the characters in an area depending on how many there
# are. Characters must have been added or removed before calling this function
# or else it won't have any effect
func _reorder(area: Control):
	# We are going to show the characters centered in this area, leaving the
	# left and right edges free
	var segments = area.get_child_count() + 2
	var i = 1
	while i < segments - 1:
		var vector = Vector2(i * area.size.x / segments, area.size.y)
		area.get_child(i - 1).position = vector
		i += 1
