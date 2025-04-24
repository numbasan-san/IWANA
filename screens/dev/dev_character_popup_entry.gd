class_name DevCharacterPopupEntry extends HBoxContainer

@export var name_label: Label

var character: Character:
	set(char):
		character = char
		name_label.text = character.char_name
