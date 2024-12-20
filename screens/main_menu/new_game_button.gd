extends TextureButton

func _on_pressed():
	var world: World = ScreenManager.rpg_screen.contents as World
	
	# Temporal code to change character in dialog mode
	# Change when the scenes controler is ready
	var noby = CharacterManager.load("noby")
	var daniela = CharacterManager.load("daniela")
	var carla = CharacterManager.load("carla")
	var guille = CharacterManager.load("guillermo")
	var mj = CharacterManager.load("maria_jose")
	var beca = CharacterManager.load("rebeca")
	var lucia = CharacterManager.load("lucia")
	
	# Teachers
	var rosario = CharacterManager.load("rosario")
	var atena = CharacterManager.load("atena")
	var whalter = CharacterManager.load("whalter")
	var barbara = CharacterManager.load("barbara")
	
	var hallway_north = ZoneManager.load("f1n_hallway")
	world.reposition_character(mj, hallway_north, Vector2(6600, 900))
	world.reposition_character(beca, hallway_north, Vector2(6900, 900))
	world.reposition_character(lucia, hallway_north, Vector2(7200, 900))
	world.reposition_character(rosario, hallway_north, Vector2(7500, 900))
	world.reposition_character(atena, hallway_north, Vector2(7800, 900))
	world.reposition_character(whalter, hallway_north, Vector2(8100, 900))
	world.reposition_character(barbara, hallway_north, Vector2(8400, 900))
	var starting_zone = ZoneManager.load("room_f1n1")
	world.spawn(noby, starting_zone)
	Player.control(noby)
	
	Player.party.add(daniela)
	Player.party.add(carla)
	Player.party.add(guille)
	
	var dummy = CharacterManager.load("dummy")
	var dev_zone = ZoneManager.load("dev_testing")
	world.spawn(dummy, dev_zone)
	# We pop the menu screen which leaves the stack empty. The script manager
	# then pushes the dialog screen, which in turn should push the rpg screen
	await ScreenManager.pop(ScreenManager.main_menu_screen, "Out", "Hide")
	ScriptManager.restart()
	disabled = true
