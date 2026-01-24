## The area of the combat screen where all of the characters fighting on the same
## team are placed.
class_name CombatPartyArea extends Control

## The direction in which all the characters in the area will be looking.
##
## By default the characters on the left side look towards the right and viceversa.
@export var looking_left: bool = true
## All SpriteContainers are placed in a grid according to the formation variable.
@export var combat_grid: CombatGrid
## The potential positions of each SpriteContainer in the grid.
##
## Each element is the position of one character in the format (x, y), that is
## (column, row).
## The size of this array determines the maximum number of characters that can
## be fighting at the same time, so a bigger grid can be used to fine tune the
## positions of the characters without risking having too many using all the screen.
## If the number of active characters is smaller than the size of this array,
## new characters can be added later and they will take the first unoccupied position.
@export var formation: Array[Vector2i]

## This only includes the values in formation that actually fit inside the grid.
##
## We keep this separated and update it as formation or the grid size change, so
## that we don't lose the values set by the user in case the grid changes again.
var valid_formation: Array[Vector2i]:
	get:
		return formation.filter(func(v): return combat_grid.in_grid(v))

## If the player is controlling this group, it's characters will appear in the
## party menu and the skill menu will open to select skills.
# TODO: for now, only the right party area should be controlled by the player,
# we could change this later.
var player_controled = false

# TODO: For now, if the grid is shrunk and containers are removed, this list will
# have more elements than the contents of the grid, which is an error. We must change
# this so we remove those characters, or move them to another array.
var characters: Array[Character]

var combat: CombatScreenControl

# When manually selecting the skill's targets, this will contain the characters
# currently being selected.
var current_targets: Array[Character]

# If the character can be targeted, this signal will be emited when the container
# is selected
signal target_selected(character: Character)

func _ready():
	for container in combat_grid.contents.values():
		container.area = self
	
# Adds a character's sprite at the next valid formation position. If there are no
# more positions available, this does nothing.
func add_character(character: Character):
	if !character:
		return
	if characters.has(character):
		return
	
	# If we ran out of valid positions, we can't add more.
	if characters.size() >= valid_formation.size():
		printerr("CombatPartyArea | Couldn't add character " + character.name \
			+ " cause the area is full.")
		return
	
	# If we don't manually add SpriteContainers to the combat area in the editor,
	# we are guaranteed that the characters match the sprite containers and the
	# children of the grid.
	var sprite_container: SpriteContainer = preload("res://screens/combat/sprite_container.tscn").instantiate()
	# We need to add the containers to the scene tree first so that the
	# set_character function works.
	combat_grid.add_in_next_available(sprite_container, valid_formation)
	sprite_container.area = self
	sprite_container.set_character(character)
	sprite_container.set_direction(looking_left)
	characters.append(character)
	character.combat_handler.stats.update_speed.connect(combat._reorder_from_speed_change)
	
# Adds a character at the given position. If there is already someone in there,
# the replace argument determines if they're replaced or the function fails
func add_character_at(character: Character, position: Vector2i, replace: bool = false):
	if !character:
		return
	if characters.has(character):
		return
	
	var old_char = combat_grid.contents.get(position)
	if old_char:
		if replace:
			remove_character(old_char)
		else:
			printerr("CombatPartyArea | Couldn't add character " + character.name \
				+ " cause the position is occupied.")
			return
	
	# If we don't manually add SpriteContainers to the combat area in the editor,
	# we are guaranteed that the characters match the sprite containers and the
	# children of the grid.
	var sprite_container: SpriteContainer = preload("res://screens/combat/sprite_container.tscn").instantiate()
	# We need to add the containers to the scene tree first so that the
	# set_character function works.
	combat_grid.add(sprite_container, position)
	sprite_container.area = self
	sprite_container.set_character(character)
	sprite_container.set_direction(looking_left)
	characters.append(character)
	character.combat_handler.stats.update_speed.connect(combat._reorder_from_speed_change)

# If that position is in the formation, we remove it.
func remove_position(coords: Vector2i):
	formation.erase(coords)

# If that character is present in any of the containers, it's removed
func remove_character(character: Character):
	for s in combat_grid.contents.values():
		if s.character == character:
			combat_grid.remove_element(s)
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
	var chars_copy = characters.duplicate()
	for char in chars_copy:
		remove_character(char)
	characters.clear()

func has(character: Character) -> bool:
	return characters.has(character)

## Returns the sprite container that is holding the given character, or null if
## the character isn't in this area.
func find(character: Character) -> SpriteContainer:
	for container in combat_grid.contents.values():
		if container.character == character:
			return container
	return null

func get_character_at(coords: Vector2i) -> Character:
	var container = combat_grid.contents.get(coords)
	if container:
		return container.character
	else:
		return null

func get_coords(character: Character) -> Vector2i:
	return combat_grid.find_position(find(character))

func all_defeated() -> bool:
	for c in characters:
		if not c.combat_handler.stats.unconscious:
			return false
	return true

## Enables the targeting on all characters in this area, except those that make
## the given callable return true.
##
## If no exclude function is given, all characters will be allowed.
func show_targets(exclude: Callable = func(char): return false):
	for character in characters:
		if !character.combat_handler.stats.unconscious and !exclude.call(character):
			var container = find(character)
			container.targeting_enabled = true

# Clears the target highlighting for every container and blocks the code that
# allows for their selection
func hide_targets():
	for container in combat_grid.contents.values():
		container.targeting_enabled = false
