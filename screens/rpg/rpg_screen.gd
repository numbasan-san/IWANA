class_name RPGScreen
extends Screen

func deactivate(_visible: bool = false):
	super.deactivate(_visible)
	if Player.character and Player.character.rpg_model:
		var player_control = Player.character.rpg_model.get_node("PlayerControl")
		player_control.is_enabled = false

func activate():
	super.activate()
	if Player.character and Player.character.rpg_model:
		var player_control = Player.character.rpg_model.get_node("PlayerControl")
		player_control.is_enabled = true
