
extends Area2D

func change_zone(character: Character):
	var world = ScreenManager.rpg_screen.contents
	var zona_objetivo = ZoneManager.load(get_parent().zona)
	
	world.spawn(character, zona_objetivo, get_parent().spawn, get_parent().direccion_def)
