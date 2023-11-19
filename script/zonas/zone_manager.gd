extends Node

# The path where the zones are searched
var folder: String = "scenes/zones"

# All the loaded zones. The key is the name of the scene and the value is the
# node instance
var _zones: Dictionary

# Obtains a reference to a previously loaded zone, or loads it if it hasb't been
# loaded yet. If a zone with this name can't be found, null is returned
func load(zone_name: String):
	# Note: This only works if all the zones are in the same folder, this code
	# doesn't search in subfolders. Fix it so it does
	
	var zone: Zone
	if _zones.has(zone_name):
		zone = _zones[zone_name]
	else:
		var scn = load("res://" + folder + "/" + zone_name + ".tscn")
		if scn:
			zone = scn.instantiate()
			_zones[zone_name] = zone
			zone.deactivate()
			add_child(zone)
		else:
			printerr("We couldn't find a zone with name " \
				+ zone_name + " in the folder " + folder)
		
	return zone
