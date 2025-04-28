## Represents a character in the combat area and allows one to perform some
## operations on it.
class_name CharacterControl extends Container

@export var area_control: DevAreaControl
@export var characters: DevPopupMenu
@export var name_label: Label
@export var auto: Container
@export var auto_enabled: CheckBox
@export var remove: Button

static var scene: PackedScene = preload("res://screens/dev/character_control.tscn")

var cell: CellOverlay:
	set(value):
		cell = value
		characters.text = str(cell.cell_coords)

var combat_area: CombatPartyArea

var character: Character:
	set(char):
		_set_character(char)
	get:
		return _character
var _character: Character

enum Status {
	EMPTY,
	POSITION,
	FULL
}
var status: Status = Status.EMPTY:
	set(value):
		status = value
		match value:
			Status.EMPTY:
				name_label.hide()
				auto.hide()
			Status.FULL:
				name_label.show()
				auto.show()

static func _create() -> CharacterControl:
	return scene.instantiate()

func _set_character(char: Character):
	auto_enabled.disabled = !char.combat_handler.manual_control
	status = Status.FULL
	
	if char:
		name_label.text = char.char_name.to_pascal_case()
		combat_area.add_character(char)
	else:
		name_label.text = ""
		combat_area.remove_character(character)
	_character = char

func _remove_character():
	_set_character(null)

func _fill_character_list():
	CharacterManager.load_all()
	
	var dict = {}
	# This "character" is used to add a coordinate to the formation array without
	# any assigned character. A character can be added later to this location
	# or it can be left empty to save the formation array, so that it can be used
	# later to add characters in a predetermined location.
	dict["Empty"] = null
	for char_name in CharacterManager.characters:
		dict[char_name.to_pascal_case()] = CharacterManager.characters[char_name]
	
	var add_character = func(char: Character):
		if status == Status.EMPTY:
			if char:
				name_label.text = char.char_name.to_pascal_case()
				auto_enabled.disabled = !char.combat_handler.manual_control
				combat_area.add_character_at(char, cell.cell_coords)
				status = Status.FULL
			
			# If we select empty and it was already empty, we do nothing.
		elif status == Status.FULL:
			pass
			
	characters.fill_contents(dict, add_character)

# We use this function to check if there is only one entry in the character
# control list, so we can hide the remove button and make the removal imposible. 
func _is_only_entry() -> bool:
	return get_parent_control().get_child_count() <= 1
