class_name Game
extends Node2D

func _input(event):
	if event.is_action_released("toggle_dev"):
		
		if not ScreenManager.dev_screen.habilitado:
			ScreenManager.dev_screen.habilitar()
			return
		if ScreenManager.dev_screen.activa:
			ScreenManager.dev_screen.desactivar()
		else:
			ScreenManager.dev_screen.activar()
