class_name DialogModel
extends Node2D

# When creating a new scene for a character that has a dialog model, one must
# make sure that the sprite is initially looking right by default

@export var initial_scale = 0.5

@onready var character: Character = get_parent()

var dialog_position: ContenidosDialogo.Posicion = ContenidosDialogo.Posicion.NINGUNA

var active_image: Sprite2D

func _ready():
	scale = Vector2(initial_scale, initial_scale)
	
	for child in get_children():
		child.hide()
	# This codes assumes that all children (or at least the first one) are of
	# type Sprite2D. If this changes in the future, this code must be rewritten
	if get_child_count() > 0:
		active_image = get_child(0)
		active_image.show()

# The sprite is reflected to look left
func look_left():
	if scale.x > 0:
		apply_scale(Vector2(-1, 1))

# The sprite is reflected to look right
func look_right():
	if scale.x < 0:
		apply_scale(Vector2(-1, 1))

# Changes the active image of this model to another one, if it exists
func change_image(image_name: String):
	image_name = image_name.to_pascal_case()
	var node = get_node(image_name)
	if node:
		active_image.hide()
		active_image = node
		active_image.show()
	else:
		printerr("DialogModel | This character doesn't have an image with name "\
			+ image_name)
