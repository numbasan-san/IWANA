extends TextureButton

func _on_pressed():
	# Temporal code to change character in dialog mode
	# Change when the scenes controler is ready
	var noby = CharacterManager.load("noby")
	CharacterManager.change_player("noby")
	var daniela = CharacterManager.load("daniela")
	Player.add_to_party(daniela)
	var starting_zone = ZoneManager.load("sala_p1n1")
	ScreenManager.rpg_screen.contents.reposition_character(noby, starting_zone)
	var dummy = CharacterManager.load("dummy")
	var dev_zone = ZoneManager.load("zona_dev_testing")
	ScreenManager.rpg_screen.contents.reposition_character(dummy, dev_zone)
	ScreenManager.push(ScreenManager.rpg_screen)
	ScriptManager.restart()
	disabled = true
