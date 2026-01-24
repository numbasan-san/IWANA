extends TextureButton

func _on_pressed():
	var world: World = ScreenManager.rpg_screen.contents as World
	
	# TODO: Move this to a better place
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
	#var rosario = CharacterManager.load("rosario")
	#var atena = CharacterManager.load("atena")
	#var whalter = CharacterManager.load("whalter")
	#var barbara = CharacterManager.load("barbara")
	
	var hallway_north = ZoneManager.load("f1n_hallway")
	world.reposition_character(mj, hallway_north, Vector2(4544, 512))
	world.reposition_character(beca, hallway_north, Vector2(4730, 512))
	world.reposition_character(lucia, hallway_north, Vector2(4900, 512))
	#world.reposition_character(rosario, hallway_north, Vector2(7500, 900))
	#world.reposition_character(atena, hallway_north, Vector2(7800, 900))
	#world.reposition_character(whalter, hallway_north, Vector2(8100, 900))
	#world.reposition_character(barbara, hallway_north, Vector2(8400, 900))
	var starting_zone = ZoneManager.load("room_f1n1")
	world.spawn(noby, starting_zone)
	Player.control(noby)
	
	Player.party.add(daniela)
	Player.party.add(carla)
	Player.party.add(guille)
	
	var dev_zone = ZoneManager.load("dev_testing")
	
	# Dummy with high health to test player skills
	var dummyDef = CharacterManager.load("dummy")
	dummyDef.char_name = "Dummy Def"
	dummyDef.combat_handler.stats.base_damage = 0
	dummyDef.combat_handler.stats.base_max_health = 9999
	world.spawn(dummyDef, dev_zone, "SpawnDummy1")
	
	# Dummy with a high attack to test player defense, healing and death
	var dummyAtk = dummyDef.clone()
	dummyAtk.char_name = "Dummy Atk"
	dummyAtk.combat_handler.stats.base_damage = 30
	dummyAtk.combat_handler.stats.base_max_health = 20
	world.spawn(dummyAtk, dev_zone, "SpawnDummy2")
	
	# Dummy with a party with balanced attack and defense to test general combat
	var dummyPar1 = dummyDef.clone()
	dummyPar1.char_name = "Dummy Party 1"
	world.spawn(dummyPar1, dev_zone, "SpawnDummy3")
	var dummyPar2 = dummyPar1.clone()
	dummyPar2.char_name = "Dummy Party 2"
	dummyPar2.combat_handler.stats.base_damage = 1
	dummyPar2.combat_handler.stats.base_defense = 3
	dummyPar2.combat_handler.stats.base_max_health = 40
	dummyPar2.rpg_model.get_node("GeneralInteraction").disable
	dummyPar2.disable_collisions()
	world.spawn(dummyPar2, dev_zone, "SpawnDummy3")
	var dummyPar3 = dummyPar1.clone()
	dummyPar3.char_name = "Dummy Party 3"
	dummyPar3.combat_handler.stats.base_damage = 3
	dummyPar3.combat_handler.stats.base_defense = 1
	dummyPar3.combat_handler.stats.base_max_health = 25
	dummyPar3.rpg_model.get_node("GeneralInteraction").disable
	dummyPar3.disable_collisions()
	world.spawn(dummyPar3, dev_zone, "SpawnDummy3")
	var dummyPar4 = dummyPar1.clone()
	dummyPar4.char_name = "Dummy Party 4"
	dummyPar4.combat_handler.stats.base_damage = 7
	dummyPar4.combat_handler.stats.base_defense = 0
	dummyPar4.combat_handler.stats.base_max_health = 10
	dummyPar4.rpg_model.get_node("GeneralInteraction").disable
	dummyPar4.disable_collisions()
	world.spawn(dummyPar4, dev_zone, "SpawnDummy3")
	
	var party = dummyPar1.party
	party.add(dummyPar2)
	party.add(dummyPar3)
	party.add(dummyPar4)
	
	var dummy_thicc = CharacterManager.load("dummy_thicc")
	var lab = ZoneManager.load("laboratory")
	
	world.reposition_character(dummy_thicc, lab, Vector2(8, 8))
	# We pop the menu screen which leaves the stack empty. The script manager
	# then pushes the dialog screen, which in turn should push the rpg screen
	await ScreenManager.pop(ScreenManager.main_menu_screen, "Out", "Hide")
	ScriptManager.restart()
	disabled = true
