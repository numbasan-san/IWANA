extends TextureButton

func _on_pressed():
	var world: World = ScreenManager.rpg_screen.contents as World
	
	# Temporal code to change character in dialog mode
	# Change when the scenes controler is ready
	var noby = CharacterManager.load("noby")
	CharacterManager.change_player("noby")
	var daniela = CharacterManager.load("daniela")
	var carla = CharacterManager.load("carla")
	var guille = CharacterManager.load("guillermo")
	var mj = CharacterManager.load("maria_jose")
	var beca = CharacterManager.load("rebeca")
	var lucia = CharacterManager.load("lucia")
	
	Player.party.add(daniela)
	Player.party.add(carla)
	Player.party.add(guille)
	
	var hallway_north = ZoneManager.load("f1n_hallway")
	world.reposition_character(daniela, hallway_north, Vector2(6000, 900))
	world.reposition_character(carla, hallway_north, Vector2(6300, 900))
	world.reposition_character(mj, hallway_north, Vector2(6600, 900))
	world.reposition_character(beca, hallway_north, Vector2(6900, 900))
	world.reposition_character(lucia, hallway_north, Vector2(7200, 900))
	var starting_zone = ZoneManager.load("room_f1n1")
	world.spawn(noby, starting_zone)
	var dummy = CharacterManager.load("dummy")
	var dev_zone = ZoneManager.load("dev_testing")
	world.spawn(dummy, dev_zone)
	# The rpg screen will be hidden initially so that the dialog screen can
	# be shown without starting the rpg music
	await ScreenManager.push(ScreenManager.rpg_screen, "Out", "Hide")
	ScriptManager.restart()
	disabled = true
