
extends Area2D

func change_zone(personaje: Personaje):
	var mundo = ScreenManager.rpg_screen.get_node("Mundo")
	var zona_objetivo = ZoneManager.load(get_parent().zona)
	
	mundo.spawn(personaje, zona_objetivo, get_parent().spawn, get_parent().direccion_def)
