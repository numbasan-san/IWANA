class_name PartyMenu extends Control

@export var party_slots: Array[CharacterCombatContainer]

# If a character is selected then it will be highlighted in the party menu and
# its portrait and skills will be shown in the skills menu
var selected_character: Character
var _selected_index = -1

# Removes the characters loaded in the combat containers so that they stop
# updating and to prepare for the next battle
func clear():
	for c in party_slots:
		c.set_to_character()

func add_character(character: Character):
	for c in party_slots:
		# If we find an empty slot, we assign a character and return
		if not c.character:
			c.set_to_character(character)
			return
	
	# If we reach this point it means all slots were filled and trying to add a
	# new character means something went wrong elsewhere, possibly in the party
	# code
	printerr("PartyMenu | Trying to add " + character.name + " to the party " \
		+ "menu, but it was already full")


func select_character(index: int = -1):
	# In this case we clear the selected character
	if index < 0:
		party_slots[_selected_index].is_selected = false
		selected_character = null
		_selected_index = index
	elif index < Player.party.size():
		selected_character = party_slots[index].character
		_selected_index = index
		party_slots[_selected_index].is_selected = true
	else:
		printerr("PartyMenu | The party doesn't have a character with index " \
			+ str(index))

# Selects the next character in the party. If the last character is selected,
# if loop is true, the next one will be the first member of the party. If it's
# false, the character is deselected
func select_next_character(loop: bool = false):
	# This condition is true if the selected character isn't the last member of
	# the party. It also works when no one is selected
	if _selected_index < Player.party.size() - 1:
		_selected_index += 1
	# If the last member is selected
	else:
		if loop:
			_selected_index = 0
		else:
			_selected_index = -1
		
	select_character(_selected_index)
