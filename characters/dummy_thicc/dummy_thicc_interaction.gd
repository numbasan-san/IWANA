extends GeneralInteractionArea

var dummy_thicc: Character

func _start_battle():
	if character.char_info.affinity == "Comerciante":
		dummy_thicc = $"..".character
		
		var own_done_quest = QuestsManager.own_quest_done(dummy_thicc.char_info.person)

		if own_done_quest:
			QuestsManager.quest_done(own_done_quest)
			
		var rpg_screen = ScreenManager.get_node("RPGScreen")
		var shop_menu = rpg_screen.get_node("game_layer/shop_menu")
		shop_menu.open()

func disable():
	$CollisionShape2D.disabled = true
