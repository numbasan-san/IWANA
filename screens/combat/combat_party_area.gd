class_name CombatPartyArea extends Control

@export var sprite_containers: Array[SpriteContainer]
@export_range(-1, 1, 2) var direction: int

## If the player is controlling this group, it's characters will appear in the
## party menu and the skill menu will open to select skills.
# TODO: for now, only the right party area should be controlled by the player,
# we could change this later.
var player_controled = false

var characters: Array[Character]

var combat: CombatScreenControl

func _ready():
	for container in sprite_containers:
		container.area = self

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
			characters.append(character)
			# TODO: this could generate some errors if the queue is reordering while the
			# next actor is being selected. This could happen if there is not enough time
			# between when the speed is changed and the next turn. We must add some waiting
			# time after the skills are executed to prevent this.
			character.combat_handler.stats.update_speed.connect(combat._reorder_from_speed_change)
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
			characters.erase(character)
			character.combat_handler.stats.update_speed.disconnect(combat._reorder_from_speed_change)
			character.combat_handler.clear_lasting_effects()
			# We assume the character can only exist in 1 slot at a time
			return
	# If we reach this point it means the character wasn't found
	printerr("CombatPartyArea | Couldn't remove character " + character.name \
		+ " cause it wasn't found.")

func add_all(characters: Array[Character]):
	for char in characters:
		add_character(char)

# Remove every sprite in this area
func clear():
	for s in sprite_containers:
		s.remove_character()
	characters.clear()

func has(character: Character) -> bool:
	return characters.has(character)

func all_defeated() -> bool:
	for c in characters:
		if not c.combat_handler.stats.unconscious:
			return false
	return true
