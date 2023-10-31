extends Node2D

# Aca van algunas variables globales que afectarían todo el juego
# de manera que sea fácil encontrarlas y cambiarlas


func cargar_personaje(nombre_personaje: String):
	return $Personajes.cargar(nombre_personaje)


func cargar_zona(nombre_zona: String):
	return $Zonas.cargar(nombre_zona)
	
