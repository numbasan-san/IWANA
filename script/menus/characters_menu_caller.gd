extends Node

func characters_menu_caller():
	var root = "res://scenes/menus/game_menu/characters_menu.tscn"
	if has_node(root):
		var chars_menu = get_node(root)
		chars_menu.load_characters()
