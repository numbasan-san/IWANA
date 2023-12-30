extends TextureButton

func _on_pressed():
	# Temporal code to change character in dialog mode
	# Change when the scenes controler is ready
	var noby = CharacterManager.load("noby")
	CharacterManager.change_player("noby")
	var daniela = CharacterManager.load("daniela")
	var carla = CharacterManager.load("carla")
	var guille = CharacterManager.load("guillermo")
	Player.party.add(daniela)
	Player.party.add(carla)
	Player.party.add(guille)
	var starting_zone = ZoneManager.load("room_f1n1")
	ScreenManager.rpg_screen.contents.spawn(noby, starting_zone)
	var dummy = CharacterManager.load("dummy")
	var dev_zone = ZoneManager.load("dev_testing")
	ScreenManager.rpg_screen.contents.spawn(dummy, dev_zone)
	ScreenManager.push(ScreenManager.rpg_screen)
	ScriptManager.restart()
	disabled = true
