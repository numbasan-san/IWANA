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

<<<<<<< Updated upstream
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
=======
# To ensure a party is always in a consistent state, this constructor should only
# be called when loading a new character from the CharacterManager or from one
# of the functions of this class, and we must make sure that the returned party
# is assigned to the leader's party variable
func _init(leader: Character, size: int = 4):
	_party_max_size = size
	# Ideally, this constructor should only be called with a character not
	# assigned to any party, but if that's not the case this will ensure it
	if leader.party:
		leader.party.remove(leader, false)
	# We are asuming that size will never be less than 1. We must rewrite this
	# code to guarantee that
	members.append(leader)
	leader.is_leader = true
	leader.is_following = false
	new_path()

# Adds a new member to the party.
# Because every character belongs to its own party by default, when adding a
# character that is the sole member of its party we always remove it and add it
# to the new party. Else, we only force it to switch parties if force_party_change
# is true
# The added character will be relocated to the new leader
# The return value indicates if the character was added succesfully
func add(character: Character, force_party_change: bool = false) -> bool:
	if members.size() < _party_max_size:
		if character.party.members.size() == 1 or force_party_change:
			character.party.remove(character, false)
			members.append(character)
			character.party = self
			character.is_leader = false
			
			# We have a special case for the player's party to disable collisions
			# of its members so that it's easier to move around
			if self == Player.party:
				character.disable_collisions()
			
			character.reposition(leader.zone, leader.rpg_model.position, "down")
			add_path_follower(character)
			return true
	
	# If we get here it means the party was already full, or the target was
	# already in another party and we didn't force it to switch
	return false
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
func size():
	return members.size()
=======
func size() -> int:
	return members.size()

# The position of the character in the party
func index(character: Character) -> int:
	return members.find(character)
	
# This should be invoked every time the leader is moved to a different
# zone. The caller must make sure to call clear_path before changing the zone
# Because a party path must follow the leader, it only makes sense if the
# party has a leader, and that leader has a rpg model and is already in a zone
func new_path():
	if leader and leader.rpg_model and leader.zone:
		path = PartyPath.new(self, leader.rpg_model.position)
		leader.zone.add_party_path(path)
		# This will create a path follower for each member including the leader.
		for m in members:
			add_path_follower(m)

func add_path_follower(character: Character):
	if leader and leader.zone:
		var follower = PartyFollower.new(character)
		character.follower_node = follower
		leader.zone.add_party_follower(path, follower)

func remove_path_follower(char: Character):
	if leader and leader.zone and char.follower_node:
		# This means the model was attached to the follower node, and we
		# must place it outside of the path so it won't be erased
		if char.rpg_model and char.rpg_model.get_parent() == char.follower_node:
			var position = char.follower_node.position
			char.reposition(char.zone, position, char.rpg_model.direction)
		leader.zone.remove_party_follower(path, char.follower_node)
		char.follower_node = null

func clear_path():
	# A path only makes sense if there is a leader and it was already in a zone
	if leader and leader.zone:
		for m in members:
			remove_path_follower(m)
		# This should free the path and all followers
		if path:
			leader.zone.remove_party_path(path)
			path = null
		for m in members:
			m.follower_node = null

# Repositions the entire party to a new location, preserving their following status
# and handling paths correctly. Members that are following the leader will be
# placed as children of their follower_node, while the rest will be placed
# directly as children of the zone and the caller must make sure to call their
# reposition function individually to make sure they are correctly placed
func reposition(zone: Zone, position: Vector2, direction: String):
	# Deletes the party path while preserving the models of the members
	clear_path()
	for m in members:
		m.reposition(zone, position, direction, false)
	# At this point the leader is in its new position, so calling this will
	# reform the path where it's standing, including the follower nodes
	new_path()
	for m in members:
		if m.is_following:
			m.rpg_model.reposition(Vector2(0, 0), direction)
			m.call_deferred("_reattach_model", m.follower_node)
	pass
>>>>>>> Stashed changes
