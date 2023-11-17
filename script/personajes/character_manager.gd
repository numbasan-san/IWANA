extends Node

# The path where the character scenes must be searched
var folder: String = "escenas/personajes"

# The character that's currently being controled by the player. It's null if
# there isn't any asigned character
var player: Personaje
# All the characters that have been loaded, included the player controled one.
# The key is the name of the scene and the value is the Node instance
var _characters: Dictionary

# Obtains a reference to a previously loaded character, or loads it if it hasn't
# been loaded yet. If a character with this name can't be found, null is returned
func load(character_name: String):
	character_name = character_name.to_snake_case()
	var character: Personaje
	if _characters.has(character_name):
		character = _characters[character_name]
	else:
		var scn = load("res://" + folder + "/" + character_name + ".tscn")
		if scn:
			character = scn.instantiate()
			_characters[character_name] = character
			if character.modelo_rpg:
				# Se desactiva para evitar colisiones o uso de recursos
				character.modelo_rpg.desactivar()
			add_child(character)
		else:
			printerr("We couldn't find a character with name " \
				+ character_name + " in the folder " + folder)
		
	return character

# Changes the character currently being controled by the player
# TODO: this code doesn't yet change the player controler, so it currently
# doesn't have an effect
func change_player(character_name: String):
	var character = self.load(character_name)
	if character:
		if player:
			# Add here code to change the player controler
			pass
		player = character
	else:
		printerr("A character named " + character_name + "couldn't be found. \
			The player character wasn't changed.")
