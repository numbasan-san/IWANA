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
var party: Party

signal control_changed(character: Character)
signal control_removed

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
			var model = character.rpg_model
			var control = model.get_node("PlayerControl") as PlayerControl
			model.remove_child(control)
			add_child(control)
			control.attached = false
			ZoneManager.set_active(null)
			for m in party.members:
				m.enable_collisions()
			party = null
			zone = null
			character = null
			control_removed.emit()
	# This is the case when we are setting a new character
	else:
		var control: PlayerControl
		if not character:
			character = new_character
			zone = character.zone
			party = character.party
			ZoneManager.set_active(zone)
			control = get_node("PlayerControl")
			remove_child(control)
			character.rpg_model.add_child(control)
			control.attached = true
			
			# When we control a character, it becomes the party leader if it
			# wasn't already
			if not character.is_leader:
				# When choosing a new leader it should automatically trigger a
				# path reset
				party.move(character, 0)
		else:
			var model = character.rpg_model
			control = model.get_node("PlayerControl")
			model.remove_child(control)
			new_character.rpg_model.add_child(control)
			
			character = new_character
			for m in party.members:
				m.enable_collisions()
			party = character.party
			# If the new character wasn't the leader of its party, this will
			# force it to change
			party.move(character, 0)
			zone = character.zone
			ZoneManager.set_active(zone)
		for m in party.members:
			if not m.is_leader:
				m.disable_collisions()
		control_changed.emit(character)
		# We do this as a patch so that the control has the same position it had
		# set in the noby scene manually. We must find a better way to set this
		# dynamically for each character
		control.position = Vector2(0, 14)
