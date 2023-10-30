extends Node2D

# Aca van algunas variables globales que afectarían todo el juego
# de manera que sea fácil encontrarlas y cambiarlas

@export var path_personajes: String
@export var path_zonas: String

func cargar_personaje(nombre_personaje: String):
	return $Personajes.cargar(nombre_personaje)


func cargar_zona(nombre_zona: String):
	return $Zonas.cargar(nombre_zona)
	
