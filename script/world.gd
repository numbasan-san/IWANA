extends Node2D

# Reconsider if this should go here or in another class
# This enum is used in the spawn function to determine what should be done if a
# named spawn point isn't found.
enum SpawnFallback{ ERROR, ZERO, FIRST }

# The zone where the player currently is and is shown on screen
var player_zone: Zone

# Removes the character from the current new_zone and places it in a new one
func reposition_character(
		character: Character,
		new_zone: Zone,
		new_position: Vector2 = Vector2(0, 0),
		new_direction: String = 'down'):
	
	# First we move the character to the new zone. For NPCs this is enough
	character.reposition(new_zone, new_position, new_direction)
	
	# If the character is controled by the player, then its old zone is the
	# child of World node and we must check if it needs to be changed
	if CharacterManager.player == character:
		
		# If the player is moving to the same zone, there are no changes
		if player_zone == new_zone:
			return
		# If the player wasn't in any zone, this will be null and we must add
		# the new zone
		elif not player_zone:
			ZoneManager.call_deferred("remove_child", new_zone)
			call_deferred("add_child", new_zone)
			player_zone = new_zone
			new_zone.activate()
		
		# If we reach this point, the player was already in a zone and is moving
		# to a new one, so we must remove the old one and add the new
		else:
			call_deferred("remove_child", player_zone)
			ZoneManager.call_deferred("add_child", player_zone)
			player_zone.deactivate()
			
			ZoneManager.call_deferred("remove_child", new_zone)
			call_deferred("add_child", new_zone)
			new_zone.activate()
			
			player_zone = new_zone

# Moves a character to a new position determined by a spawn node that had to be
# previously placed in the new zone, and looking in the specified direction
# If fallback has the value ERROR, an error is printed on console and the
# position isn't changed. If it's ZERO, the character will be placed in
# the position (0, 0). One must design the zones so that this point is free of
# obstacles. If it's FIRST, the first spawn point in the spawn list of the zone
# will be chosen. If there are no spawn points, an error is thrown
func spawn(
		character: Character,
		new_zone: Zone,
		spawn_point: String = "Default",
		new_direction: String = 'down',
		fallback = SpawnFallback.ZERO):
	
	var spawn_node = new_zone.spawn_points.get_node(spawn_point)
	var new_position: Vector2
	
	# Try to find the specified spawn point and place the character there
	if spawn_node:
		new_position = spawn_node.position
	# If there is no spawn with that name, perform a fallback action
	else:
		# Print an error and stop the function
		if fallback == SpawnFallback.ERROR:
			printerr("World | Spawn point " + spawn_point + " not found")
			return
		# Pick the first spawn point in the list
		elif fallback == SpawnFallback.FIRST:
			spawn_node = new_zone.spawn_points.get_child(0)
			# If a spawn point is found, choose that one
			if spawn_node:
				new_position = spawn_node.position
			# Else, throw an error
			else:
				printerr("World | Spawn point " + spawn_point + " not found " \
					+ "and no other spawn points were defined in the zone")
				return
		# Use position (0, 0)
		elif fallback == SpawnFallback.ZERO:
			new_position = Vector2(0, 0)
	# If the execution reaches this point, we have a valid position
	reposition_character(character, new_zone, new_position, new_direction)

