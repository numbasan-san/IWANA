extends Node

# The path where the character scenes must be searched
var folder: String = "scenes/characters"

# The character that's currently being controled by the player. It's null if
# there isn't any asigned character
var player: Character
# All the characters that have been loaded, included the player controled one.
# The key is the name of the scene and the value is the Node instance
var _characters: Dictionary

# Obtains a reference to a previously loaded character, or loads it if it hasn't
# been loaded yet. If a character with this name can't be found, null is returned
func load(character_name: String):
	character_name = character_name.to_snake_case()
	var character: Character = null
	if _characters.has(character_name):
		character = _characters[character_name]
	else:
		var scn = load("res://" + folder + "/" + character_name + ".tscn")
		if scn:
			character = scn.instantiate()
			_characters[character_name] = character
			if character.rpg_model:
				# Se desactiva para evitar colisiones o uso de recursos
				character.rpg_model.deactivate()
			add_child(character)
			character.char_name = character_name
			character.party = Party.new(character)
			
		else:
			printerr("We couldn't find a character with name " \
				+ character_name + " in the folder " + folder)
		
	return character
