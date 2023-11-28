extends Area2D

func change_zone(character: Character):
	var world = ScreenManager.rpg_screen.contents
	var target_zone = ZoneManager.load(get_parent().zone)
	
	world.spawn(character, target_zone, get_parent().spawn, get_parent().spawn_direction)
