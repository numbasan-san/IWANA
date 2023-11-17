class_name Game
extends Node2D

# Aca van algunas variables globales que afectarían todo el juego
# de manera que sea fácil encontrarlas y cambiarlas
@export var pantallas: Pantallas

func _input(event):
	if event.is_action_released("toggle_dev"):
		if not pantallas.pantalla_dev.habilitado:
			pantallas.pantalla_dev.habilitar()
			return
		if pantallas.pantalla_dev.activa:
			pantallas.pantalla_dev.desactivar()
		else:
			pantallas.pantalla_dev.activar()
