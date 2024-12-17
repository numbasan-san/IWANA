extends Control

func _on_mute_toggled(button_pressed): # Silencia manualmente la música
	AudioServer.set_bus_mute(0, button_pressed)
