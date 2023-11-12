class_name Personaje extends Node

@export var unico = true

# TODO: cambiar esto por un sistema que no permita varios personajes controlados
# al mismo tiempo por el jugador
var control_jugador = false

# La zona en la que el personaje se encuentra actualmente
var zona: Zona

@export var modelo_dialogo: ModeloDialogo
@export var modelo_rpg: ModeloRPG
@export var modelo_combate: ModeloCombate

func recolocar(zona_nueva: Zona, posicion: Vector2, direccion: String):
	if modelo_rpg:
		modelo_rpg.recolocar(zona_nueva, posicion, direccion)
		zona = zona_nueva
