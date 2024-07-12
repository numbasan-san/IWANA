extends Node

# The path where the character scenes must be searched
var folder: String = "res://characters/"

# The character that's currently being controled by the player. It's null if
# there isn't any asigned character
var player: Character
# All the characters that have been loaded, included the player controled one.
# The key is the name of the scene and the value is the Node instance
var _characters: Dictionary

# Obtains a reference to a previously loaded character, or loads it if it hasn't
# been loaded yet. If a character with this name can't be found, null is returned
func load(character_name: String) -> Character:
	character_name = character_name.to_snake_case()
	var character: Character = null
	if _characters.has(character_name):
		character = _characters[character_name]
	else:
		var scn = load(folder + character_name + "/" + character_name + ".tscn")
		if scn:
			character = scn.instantiate()
			_characters[character_name] = character
			add_child(character)
			character.char_name = character_name
		else:
			printerr("We couldn't find a character with name " \
				+ character_name + " in the folder " + folder)
		
	return character

# Frees every node related to this character and removes it from the game. If
# force is false, it will only destroy clones of non unique characters, which
# won't be attached to the CharacterManager and are intended to be disposable.
# If force is true, it will also destroy unique characters and remove them from
# the manager, so they would have to be loaded again if one wants to use them.
func destroy(character: Character, force: bool = false):
	if (not force and is_clone) or force:
		character.party.remove(character, false)
		# dialog and rpg models are freed independently because they might be
		# attached to other nodes
		character.dialog_model.queue_free()
		character.rpg_model.queue_free()
		character.queue_free()
		# If we reach this condition the character is not a clone, so it will be
		# in _characters
		if force:
			_characters.erase(character.char_name)

# Creates a copy of a previously loaded non unique character. This is used to
# easily create generic npcs to populate the world and to use them in combat.
# Clones created with this method will not be added to the CharacterManager and
# are orphans, so there is no guarantee that they can be reached or used by code
# outside of the one that created the clone, and they should be assumed to be
# temporary
func clone(character: Character) -> Character:
	var char_name = character.char_name
	var copy: Character = null
	if _characters.has(char_name) and not character.unique:
		var scn = load(folder + char_name + "/" + char_name + ".tscn")
		if scn:
			copy = scn.instantiate()
			copy._link_components()
			copy.char_name = char_name
	
	return copy

func is_clone(character: Character) -> bool:
	var char_name = character.char_name
	var original = _characters[char_name]
	return character != original
