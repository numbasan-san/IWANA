class_name DevAreaControl extends Control

@export var area_name: String:
	set(value):
		area_name = value
		name_label.text = value

@export var name_label: Label
@export var characters: VBoxContainer
@export var grid_overlay: CombatAreaOverlay
@export var add_button: Button

var combat_area: CombatPartyArea:
	set(value):
		combat_area = value
		grid_overlay.combat_area = value
		for char in $VBoxContainer/Characters.get_children():
			char.combat_area = value
		load_characters()

func load_characters():
	clear()
	for char in combat_area.characters:
		var coords = combat_area.get_coords(char)
		add_character_at(char, coords)

# TODO: We are assuming that we only call this function to initialize the overlays
# with the caracters starting a battle. Consider renaming it to reflect that, or
# change it so it doesn't create new cells.
func add_character_at(character: Character, coords: Vector2i):
	var new_control = CharacterControl._create()
	new_control.area_control = self
	new_control.combat_area = combat_area
	new_control.cell = grid_overlay.cells_overlay._get_cell_with_coords(coords)
	new_control.character = character
	characters.add_child(new_control)
	
func _add_empty_character_control():
	# We disable the button so that we can't press it several times and queue
	# the addition of the same cell.
	add_button.disabled = true
	var new_control = CharacterControl._create()
	new_control.area_control = self
	new_control.combat_area = combat_area
	new_control.cell = await grid_overlay.cells_overlay.cell_selected
	new_control.cell.button_pressed = false
	
	# There wasn't already a character on that cell, we can continue with the addition.
	if !combat_area.combat_grid.contents.get(new_control.cell.cell_coords):
		new_control._fill_character_list()
		characters.add_child(new_control)
		combat_area.formation.append(new_control.cell.cell_coords)
	
	add_button.disabled = false

func find(character: Character) -> CharacterControl:
	for control in characters.get_children():
		if control.character == character:
			return control
	return null

func clear():
	while characters.get_child_count() > 0:
		# We remove the character control without removing the character from the
		# combat area.
		characters.get_child(0).free()
