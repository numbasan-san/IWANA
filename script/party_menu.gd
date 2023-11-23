class_name PartyMenu extends Control

@export var party_slots: Array[CharacterCombatContainer]

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
