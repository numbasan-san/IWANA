class_name CombatPartyArea extends Control

@export var sprite_containers: Array[SpriteContainer]
@export_range(-1, 1, 2) var direction: int

# Adds a character's sprite.
# TODO: we must determine if there are only going to be 4 slots to place a
# character per area, so we can add them to the scene, or if there could be
# more, for example enemy parties with more than 4 members or some character
# appears to help the protagonists for a battle, in which case new containers
# would have to be added
func add_character(character: Character):
	for s in sprite_containers:
		if not s.character:
			s.set_character(character)
			s.set_direction(direction)
			return
	# If we reach this point it means all the slots were full so we can't add
	# the new character
	printerr("CombatPartyArea | Couldn't add character " + character.name \
		+ " cause the area is full.")

# If that character is present in any of the containers, it's removed
func remove_character(character: Character):
	for s in sprite_containers:
		if s.character == character:
			s.remove_character()
			# We assume the character can only exist in 1 slot at a time
			return
	# If we reach this point it means the character wasn't found
	printerr("CombatPartyArea | Couldn't remove character " + character.name \
		+ " cause it wasn't found.")

# Remove every sprite in this area
func clear():
	for s in sprite_containers:
		s.remove_character()
