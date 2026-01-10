extends GeneralInteractionArea

var dummy_thicc: Character

func _start_battle():
	if character.char_info.affinity == "comerciante":
		dummy_thicc = $"..".character
		var rpg_screen = ScreenManager.get_node("RPGScreen")
		var shop_menu = rpg_screen.get_node("game_layer/shop_menu")
		shop_menu.open()

func disable():
	$CollisionShape2D.disabled = true
