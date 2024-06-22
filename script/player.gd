extends Node

# Contains all the information related to the player, like the character it
# controls, the party, etc.

# The character the player controls. When this points to someone, the
# PlayerControl node of Player must be attached to that character
var character: Character

# The zone where the player controlled character is located
var zone: Zone

# The characters that are currently in the player's party. The player controled 
# character must be the first character in this array
var party: Party = Party.new(4)

# A pointer to the path that the player's party is following in the current zone
var party_path: PartyPath

# Switches player control to the given character. If the argument is null, we
# must remove the control from the current character. In theory this function
# would never be called with null, but it's here just in case it's needed for
# debugging
# This method should only be invoked on characters that are already placed
# somewhere in the world
func control(new_character: Character = null):
	if not new_character:
		if not character:
			return
		# If we reach this point, the PlayerControl is attached to the controled
		# character and we must return it to Player
		else:
			clear_party_path()
			var model = character.rpg_model
			var control = model.get_node("PlayerControl") as PlayerControl
			model.call_deferred("remove_child", control)
			call_deferred("add_child", control)
			# Setting the character to null is something that shouldn't occur
			# normally, so we'll just empty the party
			party.clear()
			control.set_deferred("attached", false)
			ZoneManager.set_active(null)
			zone = null
			character = null
	# This is the case when we are setting a new character
	else:
		var control: PlayerControl
		if not character:
			character = new_character
			zone = character.zone
			ZoneManager.set_active(zone)
			control = get_node("PlayerControl")
			call_deferred("remove_child", control)
			new_character.rpg_model.call_deferred("add_child", control)
			# If the player wasn't controling any character, then the party was
			# also empty
			control.set_deferred("attached", true)
			party.add(new_character)
			party.move(new_character, 0)
			new_party_path()
		else:
			clear_party_path()
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
			zone = character.zone
			ZoneManager.set_active(zone)
			new_party_path()
		
		# We do this as a patch so that the control has the same position it had
		# set in the noby scene manually. We must find a better way to set this
		# dynamically for each character
		control.position = Vector2(0, 14)

# This should be invoked every time the main character is moved to a different
# zone, and only after the zone variable is set
func new_party_path():
	# We invoke this just in case this method is being called accidentaly
	# when the player already has a path, though that shouldn't happen
	clear_party_path()
	party_path = PartyPath.new(character.rpg_model.position)
	zone.add_party_path(party_path)

func clear_party_path():
	zone.clear_party_path()
	if party_path:
		party_path.queue_free()
