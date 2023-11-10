extends Node2D

# Aca van algunas variables globales que afectarían todo el juego
# de manera que sea fácil encontrarlas y cambiarlas

@export var personajes: Personajes
@export var zonas: Zonas
@export var pantallas: ControladorPantallas

func _input(event):
	if event.is_action_released("toggle_dev"):
		if not pantallas.pantalla_dev.habilitado:
			pantallas.pantalla_dev.habilitar()
		if pantallas.pantalla_dev.activa:
			pantallas.pantalla_dev.desactivar()
		else:
			pantallas.pantalla_dev.activar()

func cargar_personaje(nombre_personaje: String):
	return $Personajes.cargar(nombre_personaje)


func cargar_zona(nombre_zona: String):
	return $Zonas.cargar(nombre_zona)
	
