## Represents a character in the combat area and allows one to perform some
## operations on it.
class_name CharacterControl extends Container

@export var area_control: DevAreaControl
@export var characters: DevPopupMenu
@export var name_label: Label
@export var auto: Container
@export var auto_enabled: CheckBox
@export var remove_button: Button

static var scene: PackedScene = preload("res://screens/dev/character_control.tscn")

var cell: CellOverlay:
	set(value):
		cell = value
		characters.text = str(cell.cell_coords)
		characters.show()

var combat_area: CombatPartyArea

# This only changes the character associated with this control, without altering
# the underlaying combat area.
var character: Character:
	set(char):
		if char:
			auto_enabled.button_pressed = !char.combat_handler.manual_control
			status = Status.FULL
			name_label.text = char.char_name.to_pascal_case()
		else:
			auto_enabled.button_pressed = false
			status = Status.EMPTY
			name_label.text = ""
		_character = char
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
	var instance = scene.instantiate()
	instance._fill_character_list()
	return instance

# Adds a new character to the cell contained in this control, modifying the combat
# area. If there was already a character there, the replace argument dictates if
# the old character is replaced or the function fails. 
func add_character(char: Character, replace: bool = false):
	var old_char = combat_area.get_character_at(cell.cell_coords)
	if old_char:
		if replace:
			combat_area.remove_character(old_char)
		else:
			return
	var old_coords = combat_area.get_coords(char)
	# If we are adding a character already in combat, we change its position.
	if old_coords:
		var old_control = area_control.find(char)
		if old_control:
			old_control.character = null
		combat_area.combat_grid.switch_positions(old_coords, cell.cell_coords)
		return
	# At this point there wasn't any character in this cell, or the previous one
	# was removed, so now we can use the same cell.
	combat_area.add_character_at(char, cell.cell_coords)
	character = char

# Deletes the character from the combat area without deleting this control.
func remove_character():
	if character:
		combat_area.remove_character(character)
		character = null

# Called when the remove button is clicked, removes the character associated with
# this control from the area and deletes the control.
func delete():
	if character:
		combat_area.remove_character(character)
	get_parent_control().remove_child(self)

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
				add_character(char)
			
			# If we select empty and it was already empty, we do nothing.
		elif status == Status.FULL:
			if char:
				add_character(char, true)
			else:
				remove_character()
			
	characters.fill_contents(dict, add_character)

# We use this function to check if there is only one entry in the character
# control list, so we can hide the remove button and make the removal imposible. 
func _is_only_entry() -> bool:
	return get_parent_control().get_child_count() <= 1
