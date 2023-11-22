extends Node

# Contains all the information related to the player, like the character it
# controls, the party, etc.

# The character the player controls. When this points to someone, the
# PlayerControl node of Player must be attached to that character
var character: Character

# The characters that are currently in the player's party. The player controled 
# character must be the first character in this array
var party: Array[Character]

# The maximum size of the party. It is set as a variable in case some day it's
# decided this number should change
var _party_max_size: int = 4

# Switches player control to the given character. If the argument is null, we
# must remove the control from the current character. In theory this function
# would never be called with null, but it's here just in case it's needed for
# debugging
# TODO: change this so that it can receive either a character or the name of one
func control(new_character: Character = null):
	if not new_character:
		if not character:
			return
		# If we reach this point, the PlayerControl is attached to the controled
		# character and we must return it to Player
		else:
			var model = character.rpg_model
			var control = model.get_node("PlayerControl") as PlayerControl
			model.call_deferred("remove_child", control)
			call_deferred("add_child", control)
			# Setting the character to null is something that shouldn't occur
			# normally, so we'll just empty the party
			party.clear()
			control.set_deferred("attached", false)
			character = null
	# This is the case when we are setting a new character
	else:
		var control: PlayerControl
		if not character:
			character = new_character
			control = get_node("PlayerControl")
			call_deferred("remove_child", control)
			new_character.rpg_model.call_deferred("add_child", control)
			# If the player wasn't controling any character, then the party was
			# also empty
			control.set_deferred("attached", true)
			party.append(new_character)
		else:
			var model = character.rpg_model
			control = model.get_node("PlayerControl")
			model.call_deferred("remove_child", control)
			new_character.rpg_model.call_deferred("add_child", control)
			# If the target character was already in the party, we will switch
			# their positions
			if party.has(new_character):
				var index = party.find(new_character)
				party[0] = new_character
				party[index] = character
			# For now, if we are changing control to a character outside the
			# party we will empty it and lose all party data. For now, changing
			# control to someone outside the party should only happen during
			# debugging. In the future we should store party data so we can
			# recover it after changing back to an old character
			else:
				party.clear()
				party.append(new_character)
			character = new_character
		
		# We do this as a patch so that the control has the same position it had
		# set in the noby scene manually. We must find a better way to set this
		# dynamically for each character
		control.position = Vector2(0, 14)

# Adds a new member to the party. We are assuming that if the player doesn't
# control any player, the party must be empty
func add_to_party(new_character: Character):
	if not new_character:
		control(new_character)
	else:
		if party.size() < _party_max_size:
			party.append(new_character)
		else:
			printerr("Player | You can't add " + new_character.name + " to the " \
				+ "party because it's full")

# Removes a character from the party, if it's already there.
func remove_from_party(old_character: Character):
	if not party.has(old_character):
		printerr(" Player | The character " + old_character.name + " isn't in" \
			+ " the party")
		return
	else:
		# If we are removing the only member of the party, we lose control
		if party.size() == 1:
			control()
			return
		# If we are removing the leader of the party, we must change it to
		# another one
		elif character == old_character:
			# At this point we are guaranteed that there are at least 2 members
			# in the party, so we can change control to the second one
			control(party[1])
		# If we reach this point, we are guaranteed that the character to remove
		# is in the party and isn't the leader, so we can safely remove it
		party.erase(old_character)
