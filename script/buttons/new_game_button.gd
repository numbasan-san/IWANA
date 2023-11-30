extends TextureButton

func _on_pressed():
	# Temporal code to change character in dialog mode
	# Change when the scenes controler is ready
	var noby = CharacterManager.load("noby")
	CharacterManager.change_player("noby")
	var daniela = CharacterManager.load("daniela")
	var carla = CharacterManager.load("carla")
	var guille = CharacterManager.load("guillermo")
	Player.add_to_party(daniela)
	Player.add_to_party(carla)
	Player.add_to_party(guille)
	var starting_zone = ZoneManager.load("room_f1n1")
	ScreenManager.rpg_screen.contents.reposition_character(noby, starting_zone)
	var dummy = CharacterManager.load("dummy")
	var dev_zone = ZoneManager.load("dev_testing")
	ScreenManager.rpg_screen.contents.reposition_character(dummy, dev_zone)
	ScreenManager.push(ScreenManager.rpg_screen)
	ScriptManager.restart()
	disabled = true
