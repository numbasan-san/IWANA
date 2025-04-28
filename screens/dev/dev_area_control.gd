class_name DevAreaControl extends Control

@export var area_name: String:
	set(value):
		area_name = value
		name_label.text = value

@export var name_label: Label
@export var characters: VBoxContainer
@export var grid_overlay: CombatAreaOverlay

var combat_area: CombatPartyArea:
	set(value):
		combat_area = value
		grid_overlay.combat_area = value
		for char in $VBoxContainer/Characters.get_children():
			char.combat_area = value

func _load_characters():
	for char in CharacterManager.characters:
		pass

func _show_characters():
	pass

# TODO: We are assuming that we only call this function to initialize the overlays
# with the caracters starting a battle. Consider renaming it to reflect that, or
# change it so it doesn't create new cells.
func _add_character_at(character: Character, coords: Vector2i):
	var new_control = CharacterControl._create()
	new_control.combat_area = combat_area
	new_control.character = character
	new_control.cell = grid_overlay.cells_overlay._get_cell_with_coords(coords)
	new_control._fill_character_list()
	characters.add_child(new_control)
	
func _add_empty_character_control():
	var new_control = CharacterControl._create()
	new_control.combat_area = combat_area
	new_control.cell = await grid_overlay.cells_overlay.cell_selected
	new_control.cell.button_pressed = false
	new_control._fill_character_list()
	characters.add_child(new_control)
	combat_area.formation.append(new_control.cell.cell_coords)
