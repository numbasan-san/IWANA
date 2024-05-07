extends Control

func characters_list():
	menus_setting(false, false, true)

func map_list():
	menus_setting(true, false, false)
	
func item_list():
	menus_setting(false, true, false)

func menus_setting(maps, items, characters):
	$selected_menu/maps_menu.visible = maps
	$selected_menu/items_menu.visible = items
	$selected_menu/characters_menu.visible = characters

func _ready():
	menus_setting(false, false, false)
	
func _process(delta):
	test_pause()

func resume():
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	self.visible = false
	menus_setting(false, false, false)

func pause():
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	menus_setting(false, false, false)

func test_pause():
	if Input.is_action_just_pressed("game_menu") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("game_menu") and get_tree().paused:
		resume()

func _on_rojo_pressed():
	characters_list()

func _on_azul_pressed():
	map_list()

func _on_verde_pressed():
	item_list()
