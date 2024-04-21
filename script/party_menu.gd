class_name PartyMenu extends Control

@export var combat: CombatControl
@export var party_slots: Array[PortraitContainer]

# If a character is selected then it will be highlighted in the party menu and
# its portrait and skills will be shown in the skills menu
var selected_character: Character
var _selected_index = -1

# Removes the characters loaded in the combat containers so that they stop
# updating and to prepare for the next battle
func clear():
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


func select_character(index: int = -1):
	# In this case we clear the selected character
	if index < 0:
		party_slots[_selected_index].is_selected = false
		selected_character = null
		_selected_index = index
	elif index < Player.party.size():
		selected_character = party_slots[index].character
		party_slots[_selected_index].is_selected = false
		_selected_index = index
		party_slots[_selected_index].is_selected = true
	else:
		printerr("PartyMenu | The party doesn't have a character with index " \
			+ str(index))

# Selects the next character in the party. If the last character is selected,
# if loop is true, the next one will be the first member of the party. If it's
# false, it stays selected
func select_next_character(loop: bool = false):
	# We initialize as the last member of the party. The only case where this
	# value isn't modified is when the last member of the party is selected and
	# and we aren't looping, so the last member will stay selected
	var next: int = Player.party.size() - 1
	# This condition is true if the selected character isn't the last member of
	# the party. It also works when no one is selected
	if _selected_index < Player.party.size() - 1:
		next = _selected_index + 1
	# If the last member is selected
	else:
		if loop:
			next = 0
		else:
			next = -1
		
	select_character(next)

# Selects the previous character in the party. If the first character is selected,
# if loop is true, the next one will be the last member of the party. If it's
# false, the character is deselected
func select_previous_character(loop: bool = false):
	# We initialize as deselected. The only case where this value isn't modified
	# is when we don't have any member selected and we aren't looping, so it
	# will stay deselected
	var previous: int = -1
	# This condition is true if the selected character isn't the first member of
	# the party or it's the first but we aren't looping. In this last case the
	# result will be deselecting the character
	if _selected_index > 0 or (_selected_index == 0 and not loop):
		previous = _selected_index - 1
	# If the first member is selected while looping or no character is selected
	else:
		if _selected_index == 0:
			previous = Player.party.size() - 1
		# If we aren't looping, the characters stay deselected
		
	select_character(previous)

# Para terminar el combate por la fuerza.
func _on_run_pressed():
	combat.display_text('Como buen cobarde, huiste.')
	await combat.textbox_closed
	await get_tree().create_timer(0.5).timeout
	combat.end_battle()

# El ataque del jugador.
func _on_attack_pressed():
	combat.skills_menu.set_character(selected_character)
	combat.show_skills_menu()

# La defensa del jugador.
func _on_defense_pressed():
	var action = CombatAction.new(Defense.new(), selected_character, null)
	combat.action_queue.append(action)
	select_next_character()
	if not selected_character:
		combat.action_phase()
