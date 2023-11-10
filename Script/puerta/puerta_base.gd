
extends Area2D

@export var zona : String
@export var spawn: String
@export var direccion_def: String

func change_zone(personaje: Personaje):
	var mundo = $/root/Juego/ControladorPantallas.pantalla_mundo.get_node("Mundo")
	var zona_objetivo = $/root/Juego.cargar_zona(zona)
	
	mundo.spawn(personaje, zona_objetivo, spawn, direccion_def)
