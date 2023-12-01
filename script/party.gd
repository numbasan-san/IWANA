class_name Party

# The characters that are currently in the party. If this is the
# player's party, then the the player controled character must be the first 
# character in this array
var members: Array[Character]

var leader: Character:
	get:
		if members.size() > 0:
			return members[0]
		else:
			return null

# The maximum size of the party. It is set as a variable in case some day it's
# decided this number should change
var _party_max_size: int

func _init(size: int):
	_party_max_size = size

# Adds a new member to the party. We are assuming that if the player doesn't
# control any player, the party must be empty
func add(character: Character):
	if members.size() < _party_max_size:
		members.append(character)
	else:
		printerr("Party | You can't add " + character.name + " to the " \
			+ "party because it's full")

# Removes a character from the party, if it's already there.
func remove(old_character: Character):
	if not members.has(old_character):
		printerr(" Player | The character " + old_character.name + " isn't in" \
			+ " the party")
		return
	else:
		members.erase(old_character)

# Removes all characters from the party
func clear():
	members.clear()

# Asks if the party contains the specified character
func has(character: Character):
	return members.has(character)

# Moves the given character, if it is in the party, to a new position
func move(character: Character, index: int):
	if has(character):
		var ix = members.find(character)
		members.pop_at(ix)
		members.insert(index, character)

# Returns the size of the party
func size():
	return members.size()
