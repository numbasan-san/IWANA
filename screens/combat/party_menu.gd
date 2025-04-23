class_name PartyMenu extends Control

@export var combat: CombatScreenControl
@export var party_slots: Array[PortraitContainer]

var combat_party_area: CombatPartyArea

# If a character is selected then it will be highlighted in the party menu and
# its portrait and skills will be shown in the skills menu
var selected_character: Character
var _selected_index = -1

# Removes the characters loaded in the combat containers so that they stop
# updating and to prepare for the next battle
func clear():
	clear_selection()
	for c in party_slots:
		c.set_character()

func add_character(character: Character):
	for c in party_slots:
		# If we find an empty slot, we assign a character and return
		if not c.character:
			c.set_character(character)
			return
	
	# If we reach this point it means all slots were filled and trying to add a
	# new character means something went wrong elsewhere, possibly in the party
	# code
	printerr("PartyMenu | Trying to add " + character.name + " to the party " \
		+ "menu, but it was already full")


func select_character_index(index: int = -1):
	# In this case we clear the selected character
	if index < 0:
		party_slots[_selected_index].is_selected = false
		selected_character = null
		_selected_index = index
	elif index < Player.party.size:
		selected_character = party_slots[index].character
		party_slots[_selected_index].is_selected = false
		_selected_index = index
		party_slots[_selected_index].is_selected = true
	else:
		printerr("PartyMenu | The party doesn't have a character with index " \
			+ str(index))

func select_character(char: Character):
	var index = 0
	# We start by removing the current selection, if any.
	clear_selection()
	while index < party_slots.size():
		var found = party_slots[index].character
		if found and found == char:
			select_character_index(index)
			return
		index += 1
	# If we reach this point, the character wasn't found and the menu is left
	# with no selection

func clear_selection():
	select_character_index()

# Para terminar el combate por la fuerza.
func _on_run_pressed():
	combat.action_selected.emit(combat.Action.RUN)

# El ataque del jugador.
func _on_attack_pressed():
	combat.skills_menu.set_character(selected_character)
	combat.action_selected.emit(combat.Action.ATTACK)

# La defensa del jugador.
func _on_defense_pressed():
	combat.action_selected.emit(combat.Action.DEFEND)
