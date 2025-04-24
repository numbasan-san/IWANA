## Represents a character in the combat area and allows one to perform some
## operations on it.
class_name CharacterControl extends HBoxContainer

@export var dev_combat_control: Control
@export var empty_container: Control
@export var full_container: Control
@export var name_label: Label
@export var auto_enabled: CheckBox
@export var remove: Button

var combat_area: CombatPartyArea

var character: Character:
	set(char):
		_set_character(char)
	get:
		return _character
var _character: Character

func _ready():
	_show_contents(character != null)

func _set_character(char: Character):
	if char:
		name_label.text = char.char_name
		combat_area.add_character(char)
	else:
		name_label.text = ""
		combat_area.remove_character(character)
	_character = char
	_show_contents(char != null)

func _remove_character():
	_set_character(null)

func _show_contents(full: bool = true):
	if full:
		empty_container.hide()
		full_container.show()
	else:
		empty_container.show()
		full_container.hide()

func _fill_character_list():
	for char in CharacterManager.characters:
		pass
