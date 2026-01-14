extends Node

func items_menu_caller():
	var root = "res://scenes/menus/game_menu/items_menu.tscn"
	if has_node(root):
		var items_menu = get_node(root)
		items_menu.load_items()
