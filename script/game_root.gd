class_name Game
extends Node2D

func _input(event):
	if event.is_action_released("toggle_dev"):
		
		if not ScreenManager.dev_screen.enabled:
			ScreenManager.dev_screen.enable()
			return
		if ScreenManager.dev_screen.is_active:
			ScreenManager.dev_screen.deactivate()
		else:
			ScreenManager.dev_screen.activate()
