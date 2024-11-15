extends Control

func resume():
	get_tree().paused = false

func _on_resume_pressed():
	resume()

func _on_options_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var settings_menu = selected_menu.get_node('settings_menu')
	settings_menu.visible = true

func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
