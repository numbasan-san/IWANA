class_name Game
extends Node2D

func _input(event):
	if event.is_action_pressed("toggle_dev"):
		if ScreenManager.dev_screen.is_active:
			ScreenManager.dev_screen.deactivate()
		else:
			ScreenManager.dev_screen.activate()
			ScreenManager.dev_screen.contents.show_dev()
