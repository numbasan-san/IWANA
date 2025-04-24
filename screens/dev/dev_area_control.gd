class_name DevAreaControl extends VBoxContainer

@export var area_name: String:
	set(value):
		area_name = value
		name_label.text = value

@export var name_label: Label

func _load_characters():
	for char in CharacterManager.characters:
		pass

func _show_characters():
	pass
