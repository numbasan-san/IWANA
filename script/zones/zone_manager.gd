extends Node

# The path where the zones are searched
var folder: String = "res://zones"

# All the loaded zones. The key is the name of the scene and the value is the
# node instance
var zones: Dictionary

# Obtains a reference to a previously loaded zone, or loads it if it hasb't been
# loaded yet. If a zone with this name can't be found, null is returned
func load(zone_name: String):
	# Note: This only works if all the zones are in the same folder, this code
	# doesn't search in subfolders. Fix it so it does
	
	var zone: Zone
	if zones.has(zone_name):
		zone = zones[zone_name]
	else:
		var scn = load(folder + "/" + zone_name + ".tscn")
		if scn:
			zone = scn.instantiate()
			zones[zone_name] = zone
			add_child(zone)
			zone.deactivate()
			var a: String = ""
		else:
			printerr("We couldn't find a zone with name " \
				+ zone_name + " in the folder " + folder)

	return zone

# TODO: temporary function to load all zones when activating dev mode. Replace it
# with something better
func load_all():
	# We exclude these files that shouldn't be accessible. This will change
	# when changing the folder structure
	var exclude = ["base_bathroom", "base_classroom_north", "base_classroom_south",
		"base_zone", "temp_construccion", "world"]
	for file in DirAccess.get_files_at(folder):
		var no_ext = file.split(".")[0]
		if not exclude.has(no_ext):
			self.load(no_ext)
		

# This should be invoked when the control is switched to a new character
# to set the zone that character is as the new active zone. If the active zone
# is set to one where the player isn't present, they won't see anything
func set_active(new_zone: Zone):
	var world = ScreenManager.rpg_screen.contents
	var zone = null
	if world.get_child_count() > 0:
		zone = world.get_child(0)
	# If we are activating the zone that is already active, do nothing
	if zone == new_zone:
		return
	
	# In this case new_zone is null, which means we want to remove the active
	# zone
	if not new_zone:
		world.call_deferred("remove_child", zone)
		call_deferred("add_child", zone)
		zone.deactivate()
	# If the player wasn't in any zone, this will be null and we must add
	# the new zone
	elif not zone:
		call_deferred("remove_child", new_zone)
		world.call_deferred("add_child", new_zone)
		new_zone.activate()
	
	# If we reach this point, the player was already in a zone and is moving
	# to a new one, so we must remove the old one and add the new
	else:
		world.call_deferred("remove_child", zone)
		ZoneManager.call_deferred("add_child", zone)
		zone.deactivate()
		
		ZoneManager.call_deferred("remove_child", new_zone)
		world.call_deferred("add_child", new_zone)
		new_zone.activate()
		
