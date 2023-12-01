extends Node

# Contains all the information related to the player, like the character it
# controls, the party, etc.

# The character the player controls. When this points to someone, the
# PlayerControl node of Player must be attached to that character
var character: Character

# The characters that are currently in the player's party. The player controled 
# character must be the first character in this array
var party: Party = Party.new(4)

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
			party.add(new_character)
		else:
			var model = character.rpg_model
			control = model.get_node("PlayerControl")
			model.call_deferred("remove_child", control)
			new_character.rpg_model.call_deferred("add_child", control)
			# If the target character was already in the party, we will switch
			# their positions
			if party.has(new_character):
				party.move(new_character, 0)
			# For now, if we are changing control to a character outside the
			# party we will empty it and lose all party data. For now, changing
			# control to someone outside the party should only happen during
			# debugging. In the future we should store party data so we can
			# recover it after changing back to an old character
			else:
				party.clear()
				party.add(new_character)
			character = new_character
		
		# We do this as a patch so that the control has the same position it had
		# set in the noby scene manually. We must find a better way to set this
		# dynamically for each character
		control.position = Vector2(0, 14)
