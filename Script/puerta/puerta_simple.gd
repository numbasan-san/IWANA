
extends Area2D

@export var zona : String
@export var posicion_def: Vector2
@export var direccion_def: String

func change_zone(personaje: Personaje):
	var mundo = $/root/Juego/ControladorPantallas.pantallaMundo.get_node("Mundo")
	var zona_objetivo = $/root/Juego.cargar_zona(zona)
	mundo.recolocar_personaje(personaje, zona_objetivo, posicion_def, direccion_def)
